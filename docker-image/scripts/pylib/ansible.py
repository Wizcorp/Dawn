from __future__ import absolute_import

import os

from ansible.config.manager import ConfigManager
from ansible.errors import (AnsibleFileNotFound, AnsibleParserError,
                            AnsibleUndefinedVariable)
from ansible.inventory.manager import InventoryManager
from ansible.module_utils._text import to_bytes
from ansible.module_utils.six import binary_type, text_type
from ansible.parsing.dataloader import DataLoader
from ansible.parsing.vault import is_encrypted
from ansible.playbook.play import Play
from ansible.playbook.task import Task
from ansible.template import Templar
from ansible.utils.vars import combine_vars
from ansible.vars.hostvars import HostVars
from ansible.vars.manager import VariableManager


# this is a custom loader that ignores anything that is encrypted with vault
class CustomLoader(DataLoader):
    def _get_file_contents(self, file_name):
        '''
        Reads the file contents from the given file name, and will decrypt them
        if they are found to be vault-encrypted.
        '''
        if not file_name or not isinstance(file_name, (binary_type, text_type)):
            raise AnsibleParserError("Invalid filename: '%s'" % str(file_name))

        b_file_name = to_bytes(self.path_dwim(file_name))
        # This is what we really want but have to fix unittests to make it pass
        # if not os.path.exists(b_file_name) or not os.path.isfile(b_file_name):
        if not self.path_exists(b_file_name) or not self.is_file(b_file_name):
            raise AnsibleFileNotFound("Unable to retrieve file contents", file_name=file_name)

        show_content = True
        try:
            with open(b_file_name, 'rb') as f:
                data = f.read()
                if is_encrypted(data):
                    data = b"\n"
                    show_content = False

            return (data, show_content)

        except (IOError, OSError) as e:
            raise AnsibleParserError("an error occurred while trying to read "
                                     "the file '%s': %s" % (file_name, str(e)))


# loads the environment data from the ansible variables
class AnsibleEnvironment():
    _cache = {}

    def __init__(self):
        initial_dir = os.getcwd()
        ansible_basedir = os.path.join(
            os.environ.get("PROJECT_ENVIRONMENT_FILES_PATH"), "ansible")

        # Move to project directory
        os.chdir(os.environ.get("PROJECT_ENVIRONMENT_FILES_PATH"))

        # Load list of inventories from config:w
        config = ConfigManager('/etc/ansible/ansible.cfg')
        sources = config.data.get_setting('DEFAULT_HOST_LIST').value

        loader = CustomLoader()
        loader.set_basedir(ansible_basedir)

        # load the inventory, set the basic playbook directory
        self._inventory = InventoryManager(loader=loader, sources=sources)
        var_manager = VariableManager(loader=loader, inventory=self._inventory)
        play = Play.load(dict(hosts=['all']), loader=loader, variable_manager=var_manager)

        # Move back to directory of origin
        os.chdir(initial_dir)

        control_group = self._inventory.groups['control']
        control_host = None

        if len(control_group.get_hosts()) > 0:
            control_host = control_group.get_hosts()[0]

        # Hostvars
        hostvars = {}
        for host in self._inventory.get_hosts():
            hostvars[host.name] = host.vars

        # make sure we load all magic variables on top of the global variables
        self._vars = combine_vars(
            var_manager.get_vars(
                play=play,
                task=Task(),
                host=control_host
            ),
            {
                'hostvars': hostvars,
                'env': os.environ
            }
        )

        # create the template renderer
        self._templar = Templar(loader=loader, variables=self._vars)

        # setup some easy variables that we use a lot
        self._vars['control_ip'] = self.get_var(
            "hostvars[groups['control'][0]]['ansible_host']")
        self._vars['edge_ip'] = self.get_var(
            "hostvars[groups['edge'][0]]['ansible_host']")
        self._vars['monitor_ip'] = self.get_var(
            "hostvars[groups['monitor'][0]]['ansible_host']")

    def get_var(self, name, cache=True):
        if name not in self._cache or not cache:
            try:
                self._cache[name] = self._templar.template("{{%s}}" % name)
            except AnsibleUndefinedVariable:
                self._cache[name] = None
        return self._cache.get(name)

    def set_var(self, name, value):
        self._vars[name] = value

    def template(self, *templates):
        return '\n'.join([self._templar.template(tpl) for tpl in templates])

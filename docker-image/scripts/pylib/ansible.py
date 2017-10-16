from __future__ import absolute_import

from ansible.compat.six import string_types
from ansible.errors import AnsibleFileNotFound, AnsibleParserError
from ansible.inventory import Inventory
from ansible.module_utils._text import to_bytes
from ansible.parsing.dataloader import DataLoader
from ansible.parsing.vault import is_encrypted
from ansible.template import Templar
from ansible.vars import VariableManager, combine_vars

import os


# this is a custom loader that ignores anything that is encrypted with vault
class CustomLoader(DataLoader):
    def _get_file_contents(self, file_name):
        '''
        Reads the file contents from the given file name, and will decrypt them
        if they are found to be vault-encrypted.
        '''
        if not file_name or not isinstance(file_name, string_types):
            raise AnsibleParserError("Invalid filename: '%s'" % str(file_name))

        b_file_name = to_bytes(file_name)
        if not self.path_exists(b_file_name) or not self.is_file(b_file_name):
            raise AnsibleFileNotFound("the file_name '%s' does not exist, or "
                                      "is not readable" % file_name)

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
        ansible_basedir = os.path.join(
            os.environ.get("PROJECT_ENVIRONMENT_FILES_PATH"), "ansible")

        loader = CustomLoader()
        loader.set_basedir(ansible_basedir)

        var_manager = VariableManager()

        # load the inventory, set the basic playbook directory
        self._inventory = Inventory(
            loader=loader,
            variable_manager=var_manager
        )
        self._inventory.set_playbook_basedir(ansible_basedir)

        group = self._inventory.get_group("all")

        # make sure we load all magic variables on top of the global variables
        self._vars = combine_vars(
            self._inventory.get_group_vars(group, return_results=True),
            var_manager._get_magic_variables(loader, False, None, None,
                                             False, False)
        )
        self._vars['groups'] = self._inventory.get_group_dict()
        self._vars['env'] = os.environ

        hostvars = {}
        for host in self._inventory.get_hosts():
            hostvars[host.name] = host.get_vars()

        self._vars['hostvars'] = hostvars

        # create the template renderer
        self._templar = Templar(loader=loader, variables=self._vars)

        # setup some easy variables that we use a lot
        self._vars['control_ip'] = self.template(
            "hostvars[groups['control'][0]]['ansible_ssh_host']")
        self._vars['edge_ip'] = self.template(
            "hostvars[groups['edge'][0]]['ansible_ssh_host']")
        self._vars['monitor_ip'] = self.template(
            "hostvars[groups['monitor'][0]]['ansible_ssh_host']")

    def get_var(self, name, cache=True):
        if name not in self._cache or not cache:
            self._cache[name] = self._templar.template("{{%s}}" % name)
        return self._cache.get(name)

    def set_var(self, name, value):
        self._vars[name] = value

    def template(self, *templates):
        return '\n'.join([self._templar.template(tpl) for tpl in templates])

FROM alpine:3.5

# Arguments to inject at build time
ARG binary_name=dawn
ARG root_folder=/dawn
ARG shell_user=dawn
ARG configuration_folder=dawn
ARG configuration_filename=dawn.yml
ARG ansible_version=2.2.3.0
ARG terraform_version=0.9.5
ARG vault_version=0.7.2
ARG docker_version=17.05.0-ce

# Update the package list
RUN apk update && apk upgrade

# Install general dependencies
RUN apk add --no-cache \
    make \
    bash \
    figlet \
    git \
    openssh \
    rsync \
    curl \
    wget \
    vim \
    sudo \
    python2 \
    py-pip \
    unzip \
    jq \
    libssl1.0

# Install Ansible and configuration
RUN apk add --no-cache \
        gcc \
        python2-dev \
        musl-dev \
        libffi-dev \
        openssl-dev \
    && pip install \
        boto \
        http://releases.ansible.com/ansible/ansible-${ansible_version}.tar.gz \
        ansible-modules-hashivault \
    && apk del \
        gcc \
        python2-dev \
        musl-dev \
        libffi-dev \
        openssl-dev

ADD ./ansible.cfg /etc/ansible/

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
      -O /tmp/terraform.zip \
    && cd /usr/bin \
    && unzip -q /tmp/terraform.zip \
    && rm /tmp/terraform.zip

# Install Vault
RUN wget -q https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip \
      -O /tmp/vault.zip \
    && cd /usr/bin \
    && unzip -q /tmp/vault.zip \
    && rm /tmp/vault.zip

# Install Docker binaries
RUN wget -q https://get.docker.com/builds/Linux/x86_64/docker-${docker_version}.tgz \
      -O /tmp/docker.tgz \
    && cd /tmp \
    && tar -zxf docker.tgz \
    && rm docker.tgz \
    && mv docker/* /usr/bin \
    && rmdir docker

# Environment
ENV BINARY_NAME="${binary_name}"
ENV CONFIG_FOLDER="${configuration_folder}"
ENV CONFIG_FILENAME="${configuration_filename}"
ENV PROJECT_FILES_PATH="${root_folder}/project/${configuration_folder}"
ENV PROJECT_CONFIG_FILE_PATH="${PROJECT_FILES_PATH}/${configuration_filename}"
ENV ANSIBLE_ROLES_PATH="/etc/ansible/roles:${root_folder}/ansible/roles"

# Create the directory structure, install Ansible Galaxy roles
RUN mkdir -p ${root_folder}/project
ADD ./ansible ${root_folder}/ansible

RUN cd ${root_folder}/ansible \
    && ansible-galaxy install -r requirements.yml

ADD ./templates ${root_folder}/templates
ADD ./scripts ${root_folder}/scripts

# Add user to sudoer
ENV SHELL_USER=${shell_user}
RUN adduser -D -s /bin/bash ${shell_user}
RUN chown -fR ${shell_user}.${shell_user} ${root_folder}
RUN echo "${shell_user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Volumes. The first one is where the project files will be found;
# The second one will be mounted from
# %APP_DATA%/projects/[project_name]/[environment_name]
VOLUME ${root_folder}/project
VOLUME /home/${shell_user}

# The following two volumes should only be mounted during
# development
VOLUME ${root_folder}/ansible
VOLUME ${root_folder}/templates

# Entrypoint will help create new environments
# as well as set up the local shell to connect
# to said environment
ENV ROOT_FOLDER=${root_folder}
ENV PATH="${PATH}:${ROOT_FOLDER}/scripts/"
ENTRYPOINT ["docker_entrypoint.sh"]

# Set working directory
WORKDIR ${root_folder}

# By default, we present the end-user with a shell
CMD ["bash"]

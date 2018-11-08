# Compile teleport for musl
FROM golang:1.8-alpine as teleport

ARG teleport_version=v2.5.7

RUN apk add -U git openssl openssh-client make gcc musl-dev \
	&& wget -O /tmp/teleport.tar.gz https://github.com/gravitational/teleport/archive/${teleport_version}.tar.gz \
	&& mkdir -p /go/src/github.com/gravitational/teleport \
	&& tar -C /go/src/github.com/gravitational/teleport -xvf /tmp/teleport.tar.gz --strip-components=1 \
	&& cd /go/src/github.com/gravitational/teleport \
	&& make

FROM alpine:3.5

# Arguments to inject at build time
ARG binary_name=dawn
ARG root_folder=/dawn
ARG shell_user=dawn
ARG configuration_folder=dawn
ARG configuration_filename=dawn.yml
ARG ansible_version=2.5.1
ARG terraform_version=0.11.7
ARG vault_version=0.10.0
ARG docker_version=18.03.0-ce

# Update the package list
RUN apk update && apk upgrade

# Install general dependencies
RUN apk add --no-cache \
    make \
    bash \
    figlet \
    git \
    openssh \
    openssl \
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
RUN wget -q https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz \
      -O /tmp/docker.tgz \
    && cd /tmp \
    && tar -zxf docker.tgz \
    && rm docker.tgz \
    && mv docker/* /usr/bin \
    && rmdir docker

# Install Teleport binaries
COPY --from=teleport /go/src/github.com/gravitational/teleport/build/tctl /usr/bin/tctl
COPY --from=teleport /go/src/github.com/gravitational/teleport/build/teleport /usr/bin/teleport
COPY --from=teleport /go/src/github.com/gravitational/teleport/build/tsh /usr/bin/tsh

# Environment
ENV BINARY_NAME="${binary_name}"
ENV CONFIG_FOLDER="${configuration_folder}"
ENV CONFIG_FILENAME="${configuration_filename}"
ENV PROJECT_FILES_PATH="${root_folder}/project/${configuration_folder}"
ENV PROJECT_CONFIG_FILE_PATH="${PROJECT_FILES_PATH}/${configuration_filename}"
ENV ANSIBLE_ROLES_PATH="/etc/ansible/roles:${root_folder}/ansible/roles"

# Create the directory structure, install Ansible Galaxy roles
RUN mkdir -p ${root_folder}/project/ansible
ADD ./ansible/requirements.yml ${root_folder}/ansible/requirements.yml

RUN cd ${root_folder}/ansible \
    && ansible-galaxy install -r requirements.yml

ADD ./ansible ${root_folder}/ansible
ADD ./templates ${root_folder}/templates
ADD ./scripts ${root_folder}/scripts

# Add user to sudoer
ENV SHELL_USER=${shell_user}
RUN adduser -D -s /bin/bash ${shell_user}
RUN chown -fR ${shell_user}.${shell_user} ${root_folder}
RUN echo "${shell_user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Setup teleport
RUN sudo mkdir -p /var/lib/teleport \
	&& sudo chown ${shell_user} /var/lib/teleport

# inputrc
RUN echo -en '# mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving \n \
"\\e[1;5C": forward-word \n \
"\\e[1;5D": backward-word \n \
"\\e[5C": forward-word \n \
"\\e[5D": backward-word \n \
"\\e\\e[C": forward-word \n \
"\\e\\e[D": backward-word \n \
' > /etc/inputrc

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

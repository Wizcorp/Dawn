FROM alpine:3.5
MAINTAINER Marc Trudel <mtrudel@wizcorp.jp>

# Update the package list
RUN apk update 

# Install general dependencies
RUN apk add \
    bash \
    openssh \
    rsync \
    curl \
    wget \
    vim \
    python2 \
    py-pip \
    unzip

# Install Ansible
RUN apk add ansible

# Install Ansible Python dependencies
RUN pip install boto

# Install Terraform
RUN wget -nv https://releases.hashicorp.com/terraform/0.8.5/terraform_0.8.5_linux_amd64.zip \
      -O /tmp/terraform.zip \
    && cd /usr/bin \
    && unzip /tmp/terraform.zip

# Create the directory structure
RUN mkdir -p /dawn/project
ADD ./ansible /dawn/ansible
ADD ./templates /dawn/templates
ADD ./scripts /dawn/scripts
ADD motd /etc/motd

# Volume
VOLUME /dawn/project

# Entrypoint will help create new environments
# as well as set up the local shell to connect
# to said environment
ENTRYPOINT ./dawn/scripts/docker_entrypoint.sh

# By default, we present the end-user with a shell
CMD /usr/bin/bash --login

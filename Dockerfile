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

# Install Ansible and configuration
RUN apk add ansible
ADD ./ansible.cfg /etc/ansible/

# Install Ansible Python dependencies
RUN pip install boto

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/0.8.5/terraform_0.8.5_linux_amd64.zip \
      -O /tmp/terraform.zip \
    && cd /usr/bin \
    && unzip -q /tmp/terraform.zip \
    && rm /tmp/terraform.zip

# Install docker binaries
RUN wget -q https://get.docker.com/builds/Linux/x86_64/docker-1.13.1.tgz \
      -O /tmp/docker.tgz \
    && cd /tmp \
    && tar -zxf docker.tgz \
    && rm docker.tgz \
    && mv docker/* /usr/bin \
    && rmdir docker

# Create the directory structure
RUN mkdir -p /dawn/project
ADD ./ansible /dawn/ansible
ADD ./templates /dawn/templates
ADD ./scripts /dawn/scripts
ADD motd /etc/motd

# Volumes. The first one is where the project files will be found;
# The second one will be mounted from 
# %APP_DATA%/projects/[project_name]/[environment_name]
VOLUME /dawn/project
VOLUME /root

# Entrypoint will help create new environments
# as well as set up the local shell to connect
# to said environment
ENTRYPOINT ["/dawn/scripts/docker_entrypoint.sh"]

# Set working directory
WORKDIR /dawn/project

# By default, we present the end-user with a shell
CMD ["bash"]

# Rottnest dockerfile
# This builds a docker image containing Rottnest

FROM ubuntu:26.04

# Locales
RUN apt-get update
RUN apt-get install -y locales language-pack-en
RUN locale-gen en_US.UTF-8
RUN update-locale
ENV LANG en_US.utf8

# Add python backports
RUN apt-get install -y software-properties-common git bash wget gcc build-essential
# RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y
# RUN apt install -y python3.11-minimal python3.11 libpython3.11-stdlib libpython3.11-minimal python3.11-venv python3.11-distutils
# RUN ln -s /usr/bin/python3.11 /usr/bin/python
# RUN python -m ensurepip
# RUN ln -s /usr/local/bin/pip3.11 /usr/local/bin/pip



# Timezone setup for docker
ENV TZ=Australia/Sydney
RUN apt-get update
RUN apt install -y git make tzdata

# Setup Rottnest user and location
RUN useradd -mUs /bin/bash rottnest
WORKDIR /home/rottnest
COPY ./ ./

# Install dependencies
RUN bash ./distro_scripts/ubuntu/ubuntu_apt_helper.sh

# Pyenv setup
# This gets the correct python version

# Change user and run install Rottnest repos, exposes ports
USER rottnest
EXPOSE 5175/tcp
EXPOSE 8080/tcp

ENV HOME  /home/rottnest
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN git clone https://github.com/pyenv/pyenv.git /home/rottnest/.pyenv


# RUN echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
# RUN bash -c '/home/rottnest/.pyenv/bin/pyenv init'
RUN pyenv install 3.11
RUN pyenv global 3.11

RUN python -m venv /home/rottnest/.venv
RUN bash -c 'source /home/rottnest/.venv/bin/activate'

# CMD bash
# Runs installation of repos
RUN bash -c 'source /home/rottnest/.venv/bin/activate && ./distro_scripts/ubuntu/ubuntu_install.sh'

# Run the headless version of rottnest
CMD bash -c 'source /home/rottnest/.venv/bin/activate && /home/rottnest/run_rottnest_headless.sh'

# Rottnest dockerfile
# This builds a docker image containing Rottnest

FROM ubuntu:24.04

# Locales
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Timezone setup for docker
ENV TZ=Australia/Sydney
RUN apt-get update && apt install -y git make tzdata && rm -rf /var/lib/apt/lists/*

# Setup Rottnest user and location
RUN useradd rottnest && chsh rottnest -s /bin/bash && git clone https://github.com/QSI-BAQS/rottnest /home/rottnest && chown rottnest /home/rottnest
WORKDIR /home/rottnest

# Install dependencies
RUN cd /home/rottnest && ./distro_scripts/ubuntu/ubuntu_apt_helper.sh && rm -rf /var/lib/apt/lists/*

# Pyenv setup
# This gets the correct python version
RUN su rottnest -c "git clone https://github.com/pyenv/pyenv.git ~/.pyenv && ~/.pyenv/bin/pyenv init --install && ~/.pyenv/bin/pyenv install 3.11 && ~/.pyenv/bin/pyenv global 3.11"

# Install Rottnest repos 
RUN su rottnest -c "source ~/.bashrc && pyenv global 3.11 && cd /home/rottnest && ./distro_scripts/ubuntu/ubuntu_install.sh"

# Npm Versioning
RUN su rottnest -c "source ~/.bashrc && nvm install 24 && NODE_VER=$(ls /home/rottnest/.nvm/versions/node/)"

# Expose front end port
EXPOSE 5175/tcp
EXPOSE 8080/tcp

CMD su rottnest -c "source ~/.bashrc && pyenv global 3.11 && cd /home/rottnest/rottnest/applications/rottnest_js && npx vite --port 5175 --host 0.0.0.0 & source ~/.bashrc && cd /home/rottnest/rottnest/applications/rottnest_py && /home/rottnest/.pyenv/shims/python src/rottnest/server/server.py &" 


FROM ubuntu:20.04

RUN apt-get update -y && apt-get upgrade -y  
RUN useradd -m docker
RUN apt-get install -y curl jq
WORKDIR /home/docker
RUN curl -o actions-runner-linux-x64-2.304.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.304.0/actions-runner-linux-x64-2.304.0.tar.gz
#RUN echo "292e8770bdeafca135c2c06cd5426f9dda49a775568f45fcc25cc2b576afc12f  actions-runner-linux-x64-2.304.0.tar.gz" | shasum -a 256 -c
RUN tar xzf ./actions-runner-linux-x64-2.304.0.tar.gz

#RUN apt-get install -y --no-install-recommends curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip
#RUN chown -R docker ~docker 
RUN echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select Paris' | debconf-set-selections
RUN DEBIAN_FRONTEND="noninteractive" apt install -y tzdata
RUN bash ./bin/installdependencies.sh

ADD start.sh start.sh
RUN chmod +x start.sh
RUN chown docker:docker . -R
USER docker
ENTRYPOINT ["./start.sh"]

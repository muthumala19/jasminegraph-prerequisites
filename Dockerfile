FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --no-install-recommends -y apt-transport-https
RUN apt-get update
RUN apt-get install --no-install-recommends -y curl gnupg2 ca-certificates software-properties-common nlohmann-json3-dev

RUN apt-get install --no-install-recommends -y git cmake build-essential sqlite3 libsqlite3-dev libssl-dev librdkafka-dev libboost-all-dev libtool libxerces-c-dev libflatbuffers-dev

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install --no-install-recommends -y python3.11-dev
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN apt-get install --no-install-recommends -y libjsoncpp-dev libspdlog-dev pigz
RUN python3.11 get-pip.py
RUN pip install tensorflow==2.13.0
RUN pip install -U scikit-learn
RUN pip install joblib
RUN pip install threadpoolctl

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get install --no-install-recommends -y docker-ce-cli

WORKDIR /home/ubuntu
RUN mkdir software
WORKDIR /home/ubuntu/software

RUN git clone --single-branch --depth 1 https://github.com/mfontanini/cppkafka.git

RUN git clone --single-branch --depth 1 --branch v5.1.1-DistDGL-v0.5 https://github.com/KarypisLab/METIS.git
WORKDIR /home/ubuntu/software/METIS
RUN git submodule update --init
RUN make config shared=1 cc=gcc prefix=/usr/local
RUN make install

RUN mkdir /home/ubuntu/software/cppkafka/build
WORKDIR /home/ubuntu/software/cppkafka/build
RUN cmake ..
RUN make -j4
RUN make install

FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --no-install-recommends -y apt-transport-https
RUN apt-get update
RUN apt-get install --no-install-recommends -y curl gnupg2 ca-certificates software-properties-common nlohmann-json3-dev

RUN apt-get install --no-install-recommends -y git cmake build-essential sqlite3 libsqlite3-dev libssl-dev librdkafka-dev libboost-all-dev libtool libxerces-c-dev libflatbuffers-dev libjsoncpp-dev libspdlog-dev pigz

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install --no-install-recommends -y python3.8-dev python3-pip python3.8-distutils
RUN python3.8 -m pip install stellargraph
RUN python3.8 -m pip install chardet scikit-learn joblib threadpoolctl pandas
RUN python3.8 -m pip cache purge

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get install --no-install-recommends -y docker-ce-cli
RUN rm -f /var/lib/apt/lists/* || echo "Some files were not deleted"

WORKDIR /home/ubuntu
RUN mkdir software
WORKDIR /home/ubuntu/software

RUN git clone --single-branch --depth 1 https://github.com/mfontanini/cppkafka.git

RUN git clone --single-branch --depth 1 --branch v5.1.1-DistDGL-v0.5 https://github.com/KarypisLab/METIS.git
WORKDIR /home/ubuntu/software/METIS
RUN git submodule update --init
RUN find . -type f -print0 | xargs -0 sed -i '/-march=native/d'
RUN make config shared=1 cc=gcc prefix=/usr/local
RUN make install

RUN apt-get purge -y --autoremove git curl

RUN mkdir /home/ubuntu/software/cppkafka/build
WORKDIR /home/ubuntu/software/cppkafka/build
RUN cmake ..
RUN make -j4
RUN make install
WORKDIR /home/ubuntu/software
RUN rm -rf /home/ubuntu/software/*

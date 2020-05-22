FROM ubuntu:18.04
WORKDIR /home/ubuntu
RUN mkdir software
WORKDIR /home/ubuntu/software
RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce && \
    apt-get update && apt-get install -y git && \
    apt-get install -y cmake && \
    git clone https://github.com/google/flatbuffers.git
WORKDIR /home/ubuntu/software/flatbuffers
RUN git checkout tags/v1.10.0 && \
    apt-get update && \
    apt-get install -y build-essential && \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release && \
    make
WORKDIR /home/ubuntu/software
RUN apt-get install -y wget
#RUN wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz
RUN git clone https://github.com/chinthakarukshan/metis.git
WORKDIR /home/ubuntu/software/metis
RUN tar -xvf metis-5.1.0.tar.gz
WORKDIR /home/ubuntu/software/metis/metis-5.1.0
RUN sed -i '/#define IDXTYPEWIDTH 32/c\#define IDXTYPEWIDTH 64' include/metis.h && \
    make config shared=1 cc=gcc-7 && \
    make install
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/gabime/spdlog.git && \
    apt-get install -y sqlite3 && \
    apt-get install -y libsqlite3-dev && \
    apt install -y librdkafka-dev && \
    apt-get update && \
    apt-get install -y libboost-all-dev
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/mfontanini/cppkafka.git && \
    apt-get install -y libssl-dev
WORKDIR /home/ubuntu/software/cppkafka
RUN mkdir build
WORKDIR /home/ubuntu/software/cppkafka/build
RUN cmake .. && \
    make && \
    make install
WORKDIR /home/ubuntu/software
RUN wget https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.2.2.tar.gz  && \
    tar -xvf xerces-c-3.2.2.tar.gz
WORKDIR /home/ubuntu/software/xerces-c-3.2.2
RUN sh configure --disable-transcoder-icu && \
    make install
WORKDIR /home/ubuntu/software
RUN git clone https://github.com/open-source-parsers/jsoncpp.git
WORKDIR /home/ubuntu/software/jsoncpp
RUN git checkout tags/1.8.4 && \
    mkdir -p build/debug
WORKDIR /home/ubuntu/software/jsoncpp/build/debug
RUN cmake -DCMAKE_BUILD_TYPE=debug -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DARCHIVE_INSTALL_DIR=. -G "Unix Makefiles" ../.. && \
    make
WORKDIR /home/ubuntu/software
RUN wget http://zlib.net/pigz/pigz-2.4.tar.gz && \
    tar -xvf pigz-2.4.tar.gz
WORKDIR /home/ubuntu/software/pigz-2.4
RUN make
ENV PATH="/home/ubuntu/software/pigz-2.4/pigz:${PATH}"
WORKDIR /home/ubuntu/software
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get update && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y python3.5-dev && \
    apt-get install -y libtool && \
    git clone https://github.com/DamithaSenevirathne/jasminegraph-prerequisites.git
ENV HOME="/home/ubuntu"
WORKDIR /home/ubuntu/software/jasminegraph-prerequisites
RUN pip install -r requirements
CMD ["bash"]

#
# Quorum node Docker file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

#
# Creates a Docker image which runs a single stand-alone Quorum node.
#

# Ubuntu.
FROM ubuntu

# Install the required tools.
RUN apt-get update && apt-get install -y build-essential git-core golang-go openjdk-8-jdk vim

# Install and build Quorum.
ENV APP_ROOT /app
RUN mkdir -p ${APP_ROOT}
WORKDIR ${APP_ROOT}

RUN git clone https://github.com/jpmorganchase/quorum.git --depth=1
ENV QUORUM_ROOT ${APP_ROOT}/quorum

WORKDIR ${QUORUM_ROOT}
RUN make all
ENV PATH ${PATH}:${QUORUM_ROOT}/build/bin

# Install Istanbul to make creating Quorum nodes easier.
RUN go get github.com/getamis/istanbul-tools/cmd/istanbul
ENV PATH ${PATH}:/root/go/bin

# Create the Quorum node. Based on https://docs.goquorum.com/en/latest/Getting%20Started/Creating-A-Network-From-Scratch/.
ENV NODE_ROOT ${APP_ROOT}/node
RUN mkdir -p ${NODE_ROOT}
WORKDIR ${NODE_ROOT}

RUN istanbul setup --num 1 --nodes --quorum --save --verbose
RUN mkdir -p ${NODE_ROOT}/data/geth

# Initialise the node account.
RUN printf "password\npassword\n" > password.in
RUN geth --datadir ${NODE_ROOT}/data account new < password.in > account.out
RUN rm password.in

# Put the account address into the genesis file.
RUN sed -i ':a;N;$!ba;s/\(.*{\)\(.*\)\(}.*\)/\2/g' account.out
RUN sed -i ':a;N;$!ba;s/\("alloc":\s{\n\s*"\).*\(":\s{\)/\1'$(cat account.out)'\2/g' genesis.json
RUN rm account.out

# Copy the files into the relevant places.
RUN cp static-nodes.json data/
RUN cp 0/nodekey data/geth/

# TODO Copy genesis.json, static-nodes.json and nodekey to external directory.

# EXPOSE the ports.
ARG RPC_PORT=22000
ENV RPC_PORT ${RPC_PORT}
EXPOSE ${RPC_PORT}

ARG QUORUM_PORT=30300
ENV QUORUM_PORT ${QUORUM_PORT}
EXPOSE ${QUORUM_PORT}

# Replace the Quorum port in the static nodes file.
RUN sed -i 's/:30303/:'${QUORUM_PORT}'/g' static-nodes.json

# Initialise the node.
RUN geth --datadir data init genesis.json

# Command runs Quorum with output redirected.
WORKDIR ${APP_ROOT}
ENV PRIVATE_CONFIG ignore

COPY docker/quorum.sh ./
RUN chmod +x quorum.sh
CMD ./quorum.sh

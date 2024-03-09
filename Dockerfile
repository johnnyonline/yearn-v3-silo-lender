FROM ubuntu:22.04

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.foundry/bin

RUN apt-get update \
 && apt-get install curl git build-essential sudo software-properties-common python3 python3-pip -y \
 && sudo add-apt-repository ppa:ethereum/ethereum \
 && sudo apt-get update \
 && sudo apt-get install solc -y \
 && pip3 install slither-analyzer solc-select \
 && solc-select install 0.8.24 \
 && solc-select use 0.8.24 \
 # install foundry
 && curl -L https://foundry.paradigm.xyz | bash \
 && foundryup \
 && forge update lib/forge-std \
 # https://github.com/paritytech/substrate/issues/1070
 && curl https://sh.rustup.rs -sSf | sh -s -- -y

WORKDIR /amplify-contracts

# docker build -t yearn-dev .
# docker run -it --rm -v "/${PWD}:/yVaults-v3-strategies" yearn-dev bash
FROM ruby:3
RUN apt update && apt install xz-utils && rm -rf /var/lib/apt/lists/*
RUN mkdir /tmp/node && \
    cd /tmp/node && \
    curl -o node.tar.xz -sSL https://nodejs.org/dist/v16.10.0/node-v16.10.0-linux-x64.tar.xz && \
    tar -C /usr/local --strip-components 1 -xvf node.tar.xz && \
    rm -rfv /tmp/node

RUN npm install -g yarn
RUN mkdir -p /docrb
WORKDIR /docrb

COPY lib/docrb ./docrb
RUN cd docrb && bundle install --without development

COPY lib/docrb-react ./docrb-react
RUN cd docrb-react && yarn install --production --frozen-lockfile

COPY lib/docker/run /docrb

ENTRYPOINT ["./run"]

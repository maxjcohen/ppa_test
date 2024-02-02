FROM debian:bookworm-slim

RUN apt update && apt install -y \
    make

COPY . /usr/local/src/aciah

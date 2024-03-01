FROM debian:bookworm-slim

# Install depedencies
RUN apt update && apt install -y \
    apt-utils \
    curl \
    debmake \
    devscripts \
    tar

# Add packaging script
WORKDIR /usr/local/src
COPY ./docker/docker-package.sh .
CMD ["./docker-package.sh"]

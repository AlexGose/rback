from ubuntu:20.04

RUN apt-get update -y \
  && apt-get install -y \
    rsync

WORKDIR /code
USER 1000
SHELL ["/bin/bash","-c"]

CMD ["tests/bats/bin/bats","tests/"]

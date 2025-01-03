FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl build-essential

# download
RUN curl -sL https://github.com/kr/beanstalkd/archive/v$version.tar.gz | tar xvz -C /tmp

# build and install
RUN cd /tmp/beanstalkd-$version
RUN make
RUN cp beanstalkd /usr/bin

# cleanup package manager
RUN apt-get remove --purge -y curl build-essential && apt-get autoclean && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EXPOSE 11300
ENTRYPOINT ["/usr/bin/beanstalkd -b /var/cache/beanstalkd"]

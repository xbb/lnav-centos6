FROM centos:6 as build

RUN yum -y update && \
    yum -y install centos-release-scl && \
    yum clean all

# https://www.softwarecollections.org/en/scls/rhscl/devtoolset-7/
RUN yum -y install devtoolset-7-gcc devtoolset-7-binutils devtoolset-7-gcc-c++ && yum clean all
RUN /usr/bin/scl enable devtoolset-7 true

RUN yum -y install "https://www.softwarecollections.org/en/scls/praiskup/autotools/epel-6-x86_64/download/praiskup-autotools-epel-6-x86_64.noarch.rpm" && yum clean all
RUN yum -y install autotools-latest && yum clean all
RUN /usr/bin/scl enable autotools-latest true

RUN yum -y install git zlib-devel ncurses-devel pcre-devel && yum clean all

RUN curl -L -o /tmp/sqlite-autoconf-3290000.tar.gz "https://sqlite.org/2019/sqlite-autoconf-3290000.tar.gz" && \
    tar xzf /tmp/sqlite-autoconf-3290000.tar.gz -C /tmp && \
    cd /tmp/sqlite-autoconf-3290000 && \
    ./configure && make && make install && ldconfig && \
    cd /tmp && rm -rf /tmp/sqlite-autoconf-3290000-*

RUN curl -L -o /tmp/readline-6.3.tar.gz "https://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz" && \
    tar xzf /tmp/readline-6.3.tar.gz -C /tmp && \
    cd /tmp/readline-6.3 && \
    ./configure && make && make install && ldconfig && \
    cd /tmp && rm -rf /tmp/readline-*

RUN git clone https://github.com/tstack/lnav.git /tmp/lnav && cd /tmp/lnav && \
    git checkout v0.8.5 && \
    source scl_source enable devtoolset-7 autotools-latest && \
    ./autogen.sh && ./configure && make

FROM centos:6

COPY --from=build /tmp/lnav/src/lnav /usr/bin/lnav

ENTRYPOINT ["/usr/bin/lnav"]

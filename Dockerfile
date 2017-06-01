FROM mysql:5.7

RUN apt-get update && apt-get install -y apt-transport-https dpkg-dev && \
    apt-get install -y --no-install-recommends bison cmake libncurses5-dev zlib1g-dev wget

COPY groonga.list /etc/apt/sources.list.d/
RUN echo "deb-src http://repo.mysql.com/apt/debian/ jessie mysql-${MYSQL_MAJOR}" >> /etc/apt/sources.list.d/mysql.list

RUN apt-get update && \
    apt-get install -y --allow-unauthenticated groonga-keyring && \
    apt-get update && \
    apt-get install -y --no-install-recommends libgroonga-dev \
            groonga-normalizer-mysql groonga-tokenizer-mecab

ENV MROONGA_VERSION=7.02
ENV MYSQL_SOURCE_VERSION=5.7.18

RUN cd /usr/src && \
    apt-get source mysql-community-source && \
    cd mysql-community-${MYSQL_SOURCE_VERSION} && \
    mkdir build && cd build && \
    cmake -DINSTALL_PLUGINDIR=/usr/lib/mysql/plugin -DDOWNLOAD_BOOST=1 -DDOWNLOAD_BOOST_TIMEOUT=1800 -DWITH_BOOST=/usr/src/boost .. && \
    make && \

    cd /usr/src && \
    wget https://packages.groonga.org/source/mroonga/mroonga-${MROONGA_VERSION}.tar.gz && \
    tar xzf mroonga-${MROONGA_VERSION}.tar.gz && \
    cd mroonga-${MROONGA_VERSION} && \
    ./configure --with-mysql-source=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION} \
                --with-mysql-build=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build \
                --with-mysql-config=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build/scripts/mysql_config && \
    make install && \
    ln -s /usr/local/share/mroonga/install.sql /docker-entrypoint-initdb.d/mroonga-install.sql && \

    rm -rf /usr/src/* /var/lib/apt/lists/*

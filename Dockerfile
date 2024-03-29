FROM mysql:5.7

ENV MROONGA_VERSION=12.03
ENV MYSQL_SOURCE_VERSION=5.7.38

RUN apt-get update && apt-get install -y apt-transport-https dpkg-dev wget && \
    apt-get install -y --no-install-recommends bison cmake libncurses5-dev libssl-dev zlib1g-dev && \
    \
    echo "deb-src http://repo.mysql.com/apt/debian/ buster mysql-${MYSQL_MAJOR}" >> /etc/apt/sources.list.d/mysql.list && \
    \
    wget https://packages.groonga.org/debian/groonga-apt-source-latest-buster.deb && \
    apt install -y --no-install-recommends ./groonga-apt-source-latest-buster.deb && \
    rm -f groonga-apt-source-latest-buster.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends libgroonga-dev \
            groonga-normalizer-mysql groonga-tokenizer-mecab && \
    \
    cd /usr/src && \
    apt-get source mysql-community-source && \
    cd mysql-community-${MYSQL_SOURCE_VERSION} && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_PLUGINDIR=lib/mysql/plugin \
          -DDOWNLOAD_BOOST=1 -DDOWNLOAD_BOOST_TIMEOUT=1800 -DWITH_BOOST=/usr/src/boost .. && \
    make && \
    cd libservices && make install && \
    \
    cd /usr/src && \
    wget https://packages.groonga.org/source/mroonga/mroonga-${MROONGA_VERSION}.tar.gz && \
    tar xzf mroonga-${MROONGA_VERSION}.tar.gz && \
    cd mroonga-${MROONGA_VERSION} && \
    ./configure --prefix=/usr \
                --with-mysql-source=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION} \
                --with-mysql-build=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build \
                --with-mysql-config=/usr/src/mysql-community-${MYSQL_SOURCE_VERSION}/build/scripts/mysql_config && \
    make install && \
    ln -s /usr/share/mroonga/install.sql /docker-entrypoint-initdb.d/mroonga-install.sql && \
    \
    apt-get purge -y --auto-remove dpkg-dev bison cmake libncurses5-dev libssl-dev zlib1g-dev wget && \
    rm -rf /usr/src/* /var/lib/apt/lists/*

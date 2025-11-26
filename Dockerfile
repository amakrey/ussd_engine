FROM bitnami/minideb:latest

RUN /bin/bash -c apt-get update && apt-get install -y --no-install-recommends ca-certificates curl netbase wget && rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c set -ex; if ! command -v gpg > /dev/null; then apt-get update; apt-get install -y --no-install-recommends gnupg dirmngr; rm -rf /var/lib/apt/lists/*; fi
RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends 		git 		mercurial 		openssh-client 		subversion 				procps 	&& rm -rf /var/lib/apt/lists/*
RUN /bin/sh -c set -ex; 	apt-get update; 	apt-get install -y --no-install-recommends 		autoconf 		automake 		bzip2 		dpkg-dev 		file 		g++ 		gcc 		imagemagick 		libbz2-dev 		libc6-dev 		libcurl4-openssl-dev 		libdb-dev 		libevent-dev 		libffi-dev 		libgdbm-dev 		libglib2.0-dev 		libgmp-dev 		libjpeg-dev 		libkrb5-dev 		liblzma-dev 		libmagickcore-dev 		libmagickwand-dev 		libmaxminddb-dev 		libncurses5-dev 		libncursesw5-dev 		libpng-dev 		libpq-dev 		libreadline-dev 		libsqlite3-dev 		libssl-dev 		libtool 		libwebp-dev 		libxml2-dev 		libxslt-dev 		libyaml-dev 		make 		patch 		unzip 		xz-utils 		zlib1g-dev 				$( 			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then 				echo 'default-libmysqlclient-dev'; 			else 				echo 'libmysqlclient-dev'; 			fi 		) 	; 	rm -rf /var/lib/apt/lists/*
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
RUN /bin/sh -c apt-get update  \
    && apt-get install -y --no-install-recommends 		libbluetooth-dev 		tk-dev 	 \
    && rm -rf /var/lib/apt/lists/*
ENV GPG_KEY=97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION=3.13
RUN /bin/sh -c set -ex 		&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" 	 \
    && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" 	 \
    && export GNUPGHOME="$(mktemp -d)" 	 \
    && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" 	 \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz 	 \
    && { command -v gpgconf > /dev/null  \
    && gpgconf --kill all || :; } 	 \
    && rm -rf "$GNUPGHOME" python.tar.xz.asc 	 \
    && mkdir -p /usr/src/python 	 \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz 	 \
    && rm python.tar.xz 		 \
    && cd /usr/src/python 	 \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" 	 \
    && ./configure 		--build="$gnuArch" 		--enable-loadable-sqlite-extensions 		--enable-optimizations 		--enable-option-checking=fatal 		--enable-shared 		--with-system-expat 		--with-system-ffi 		--without-ensurepip 	 \
    && make -j "$(nproc)" 		PROFILE_TASK='-m test.regrtest --pgo 			test_array 			test_base64 			test_binascii 			test_binhex 			test_binop 			test_bytes 			test_c_locale_coercion 			test_class 			test_cmath 			test_codecs 			test_compile 			test_complex 			test_csv 			test_decimal 			test_dict 			test_float 			test_fstring 			test_hashlib 			test_io 			test_iter 			test_json 			test_long 			test_math 			test_memoryview 			test_pickle 			test_re 			test_set 			test_slice 			test_struct 			test_threading 			test_time 			test_traceback 			test_unicode 		' 	&& make install 	&& ldconfig 		&& find /usr/local -depth 		\( 			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) 			-o 			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) 		\) -exec rm -rf '{}' + 	&& rm -rf /usr/src/python 		&& python3 --version \
RUN /bin/sh -c cd /usr/local/bin 	&& ln -s idle3 idle 	&& ln -s pydoc3 pydoc 	&& ln -s python3 python 	&& ln -s python3-config python-config \
ENV PYTHON_PIP_VERSION=20.3.4
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/ffe826207a010164265d9cc807978e3604d18ca0/get-pip.py
ENV PYTHON_GET_PIP_SHA256=b86f36cc4345ae87bfd4f10ef6b2dbfa7a872fbff70608a1e43944d283fd0eee
RUN /bin/sh -c set -ex; 		wget -O get-pip.py "$PYTHON_GET_PIP_URL"; 	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; 		python get-pip.py 		--disable-pip-version-check 		--no-cache-dir 		"pip==$PYTHON_PIP_VERSION" 	; 	pip --version; 		find /usr/local -depth 		\( 			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) 			-o 			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) 		\) -exec rm -rf '{}' +; 	rm -f get-pip.py
CMD ["python3"]
RUN /bin/sh -c mkdir -p /usr/src/app # buildkit
WORKDIR /usr/src/app
COPY requirements.txt /tmp/
COPY default.txt /tmp/
RUN /bin/sh -c pip install --no-cache-dir --exists-action w -r /tmp/requirements.txt # buildkit
CMD ["/bin/bash","./run.sh"]
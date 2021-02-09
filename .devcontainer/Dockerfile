FROM centos:7

LABEL \
  description="MdpPro Centos 7 Development Container" \
  name="mdppro-dev"

USER 0
RUN set -eux; \
  yum install --assumeyes --setopt=tsflags=nodocs \
    centos-release-scl-rh \
    epel-release \
    ;\
  yum install --assumeyes --setopt=tsflags=nodocs \
    devtoolset-9-binutils \
    devtoolset-9-gcc \
    devtoolset-9-gcc-c++ \
    ; \
  yum install --assumeyes --setopt=tsflags=nodocs \
    # This repository gives us more modern versions of some software, such as Git.
    https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm; \
  yum install --assumeyes --setopt=tsflags=nodocs \
    git \
    make \
    wget \
    # Required by GLEW
    libX11-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    # Required for Qt5
    bison \
    expat-devel \
    fontconfig-devel \
    freetype-devel \
    gperf \
    libxcb-devel \
    libxkbcommon-devel \
    openssl-devel \
    which \
    zlib-devel \
    # Required by ZooKeeper
    ant \
    autoconf \
    automake \
    java-11-openjdk-devel \
    libtool \
    ; \
  yum --assumeyes clean all; \
  wget \
    --output-document=cmake.sh \
    https://github.com/Kitware/CMake/releases/download/v3.19.3/cmake-3.19.3-Linux-x86_64.sh; \
  chmod 744 cmake.sh; \
  mkdir /opt/cmake; \
  ./cmake.sh --prefix=/opt/cmake --skip-license --exclude-subdir; \
  ln -s /opt/cmake/bin/ccmake /usr/bin/ccmake; \
  ln -s /opt/cmake/bin/ctest /usr/bin/ctest; \
  ln -s /opt/cmake/bin/cpack /usr/bin/cpack; \
  ln -s /opt/cmake/bin/cmake /usr/bin/cmake; \
  wget \
    --output-document=externpro.sh \
    https://github.com/distributePro/externpro/releases/download/18.01.3/externpro-18.01.3-gcc631-64-Linux.sh; \
  chmod 744 externpro.sh; \
  ./externpro.sh \
    --include-subdir \
    --skip-license \
    --prefix=/opt/extern; \
  rm externpro.sh; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh; \
  chmod 744 git-completion.bash git-prompt.sh; \
  echo ". ~/git-completion.bash" >> ${HOME}/.bashrc; \
  echo ". ~/git-prompt.sh" >> ${HOME}/.bashrc; \
  echo "alias ls='ls --color=auto'" >> ${HOME}/.bashrc; \
  echo "PS1='\n\[\e[01;39m\]ovsrpro-dev \[\e[01;35m\]\w\[\e[01;36m\]\$(__git_ps1)\[\e[0m\]\n'" >> ${HOME}/.bashrc

# environment: gcc version, enable scl binaries
ENV GCC_VER=gcc911 \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-9/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["/bin/bash"]


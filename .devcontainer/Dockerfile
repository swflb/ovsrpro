FROM centos/devtoolset-6-toolchain-centos7:latest

LABEL \
  description="Ovsrpro Centos 7 Development Container" \
  name="ovsrpro-dev"

USER 0
RUN set -eux; \
  yum --assumeyes update; \
  yum install --assumeyes \
    epel-release \
    # This repository gives us more modern versions of some software, such as Git.
    https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm; \
  yum install --assumeyes \
    cmake3 \
    git \
    make \
    wget; \
  # yum --assumeyes clean all; \
  ln -s cmake3 /usr/bin/cmake; \
  ln -s ctest3 /usr/bin/ctest; \
  ln -s cpack3 /usr/bin/cpack; \
  yum install --assumeyes \
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
    libtool; \
  yum --assumeyes clean all; \
  wget https://github.com/distributePro/externpro/releases/download/18.01.2/externpro-18.01.2-gcc631-64-Linux.sh; \
  chmod 744 externpro-18.01.2-gcc631-64-Linux.sh; \
  ./externpro-18.01.2-gcc631-64-Linux.sh \
    --include-subdir \
    --skip-license \
    --prefix=/opt/extern; \
  rm externpro-18.01.2-gcc631-64-Linux.sh; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh; \
  chmod 744 git-completion.bash git-prompt.sh; \
  echo ". ~/git-completion.bash" >> ${HOME}/.bashrc; \
  echo ". ~/git-prompt.sh" >> ${HOME}/.bashrc; \
  echo "alias ls='ls --color=auto'" >> ${HOME}/.bashrc; \
  echo "PS1='\n\[\e[01;39m\]ovsrpro-dev \[\e[01;35m\]\w\[\e[01;36m\]\$(__git_ps1)\[\e[0m\]\n'" >> ${HOME}/.bashrc

CMD ["/bin/bash"]
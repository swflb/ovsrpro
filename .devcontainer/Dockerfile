FROM centos/devtoolset-6-toolchain-centos7:latest

LABEL \
  description="Externpro Centos 7 Development Container" \
  name="ovsrpro-dev"

USER 0
RUN set -eux; \
  yum --assumeyes --quiet update; \
  yum install --assumeyes \
    epel-release \
    # This repository gives us more modern versions of some software, such as Git.
    https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm; \
  yum install --assumeyes \
    cmake3 \
    git \
    gtk2-devel \
    make \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    ncurses-devel \
    ninja-build \
    python-devel \
    wget \
    fontconfig \
    freetype \
    glibs \
    openssl \
    dbus \
    libXScrnSaver \
    libXtst \
    pciutils \
    EGL \
    expat \
    bison \
    gperf \
    ant \
    javac \
    ; \
  yum --assumeyes --quiet clean all; \
  ln -s cmake3 /usr/bin/cmake; \
  ln -s ctest3 /usr/bin/ctest; \
  ln -s cpack3 /usr/bin/cpack

RUN set -eux; \
  mkdir -p /opt/extern; \
  pushd /opt/extern; \
  wget \
    https://github.com/distributePro/externpro/releases/download/18.01.2/externpro-18.01.2-gcc631-64-Linux.sh; \
  chmod +x ./externpro*; \
  ./externpro-18.01.2-gcc631-64-Linux.sh --skip-license --include-subdir; \
  rm ./externpro-18.01.2-gcc631-64-Linux.sh; \
  popd; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash; \
  wget \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh; \
  chmod 744 git-completion.bash git-prompt.sh; \
  echo ". ~/git-completion.bash" >> ${HOME}/.bashrc; \
  echo ". ~/git-prompt.sh" >> ${HOME}/.bashrc; \
  echo "alias ls='ls --color=auto'" >> ${HOME}/.bashrc

RUN echo "PS1='\n\[\e[01;39m\]ovsrpro-dev \[\e[01;35m\]\w\[\e[01;36m\]\$(__git_ps1)\[\e[0m\]\n'" >> ${HOME}/.bashrc

CMD ["/bin/bash"]


FROM gcc:4.9.4
# assumes this alread has git installed
#RUN apt-get -y update && apt-get install -y git
RUN mkdir /opt/externpro
COPY externpro-16.01.1-gcc494-64-Linux.sh /opt/externpro/
RUN cd /opt/externpro
RUN chmod +x /opt/externpro/externpro-16.01.1-gcc494-64-Linux.sh
RUN yes | /opt/externpro/externpro-16.01.1-gcc494-64-Linux.sh --prefix=/opt/externpro
RUN dpkg -i /opt/externpro/externpro-16.01.1-gcc494-64-Linux/pkg/cmake-3.3.2-Linux-x86_64.deb

#CMD cmake --version && git --version && ls -al /opt/externpro/
CMD cd /tmp
CMD git clone --recurse-submodules https://github.com/distributePro/ovsrpro.git
CMD cd ovsrpro
CMD git checkout 17.02.1
CMD mkdir _bld
CMD cd _bld
CMD cmake .. -DXP_STEP=build
CMD make -j8
CMD make package


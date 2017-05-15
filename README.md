# ovsrpro

builds overseer [projects](projects/README.md) by leveraging externpro

Supports compiling the following projects from source for both Windows and Linux:
- FFmpeg (https://www.ffmpeg.org)
- GLEW (http://glew.sourceforge.net)
- HDF5 (http://www.hdfgroup.org)
- MIT Kerberos (http://web.mit.edu/kerberos)
- librdkafka (https://github.com/edenhill/librdkafka)
- NOVAS (http://aa.usno.navy.mil/software/novas/novas_info.php)
- OpenH264 (http://www.openh264.org)
- PostreSQL (http://www.postresql.org)
- Qt5 (http://code.qt.io)
- Qwt (http://qwt.sourceforge.net)
- ZooKeeper (https://github.com/apache/zookeeper.git)

Depends on an installed version of externpro (https://github.com/smanders/externpro).

YASM assembler is expected to be present for building FFmpeg and OpenH264 projects.

Some additional packages may need to be installed for the Qt Web modules to build, here is a list of ones that commonly need to be installed on a CentOS 6 system (additional ones may be required depending on system configuration):
 - dbus-devel
 - libXScrnSaver-devel
 - libXtst-devel
 - pciutils-devel
 - mesa-libEGL-devel
 - gperf
 - expat-devel
  

All projects can be built as static or shared libraries.  For static windows
builds, libraries are compiled with the /MT flag.

Each built project has a corresponding folder inside the share directory that
contains files pertinent to the project (i.e. README and/or LICENSE files, flags
used at compile time, etc.)

To build an install package with these packages, perform the following steps:
```bash
git clone https://github.com/distributePro/ovsrpro.git
cd ovsrpro
git checkout <tag>		# where tag is, for example 17.02.1
mkdir ovsrpro-build
cd ovsrpro-build
cmake ../ovsrpro -DXP_STEP=build
make -j8			# where the -j8 specifies the number of cpus to use
make package
```

For custom builds, the following cmake options are available (via the -D option)
- XP_BUILD_DEBUG - build a debug version of the libraries along with the release
- XP_BUILD_STATIC - build static libraries rather than dynamic.  Note that some
  project build systems build both static and shared by default
- XP_DEFAULT - Compiles all of the available packages.  To only compile a subset
  of the packages, set XP_DEFAULT=0 and specify the individual packages desired.
- XP_STEP - may be used to define which steps to complete of the build process
          - see the externpro documentation for available options
- PACKAGE_TYPE - optionally specify a non-default CPACK_GENERATOR to use, if not
  present the default STGZ generator is used. (RPM is the only other generator
  type that has been tested)

Available package options when XP_DEFAULT=0 or is not defined
- XP_PRO_FFMPEG - build the FFmpeg package
- XP_PRO_GLEW - build the GLEW package
- XP_PRO_HDF5 - build the HDF5 package
- XP_PRO_KERBEROS - build the MIT kerberos package
- XP_PRO_LIBRDKAFKA - build the librdkafka package
- XP_PRO_NOVAS - build the novas package
- XP_PRO_OPENH264 - build the OpenH264 package
- XP_PRO_PSQL - build the postgresql package
- XP_PRO_QT5 - build the qt5 package
- XP_PRO_QWT - build the qwt package
- XP_PRO_ZOOKEEPER - build the zookeeper package


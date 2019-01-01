# ovsrpro

Build Overseer [dependencies](projects/README.md) by leveraging externpro
(https://github.com/smanders/externpro).

## Installing ovsrpro

1. Download the installer for the release you need, for the your development
   environment (OS, compiler, etc). See
   https://github.com/distributePro/ovsrpro/releases.
1. Download the SHA256 checksum file for your release.
1. Validate the checksum.
1. Run the installer.

```
sha256sum --check ovsrpro-18.10.1-gcc631-64-Linux.sh.sha256
sudo ovsrpro-18.10.1-gcc631-64-Linux.sh --prefix=/opt/extern/ --include-subdir
```

The recommended location for installation is */opt/extern/*. We also recommend
using the subdirectory. Both these options are in the example above.

## Building ovsrpro

### Project Dependencies

Certain projects have build dependencies, which you need to install on your
system. Install the appropriate development packages on your system using apt or
yum.

| Project | Required Libraries | Required Tools |
|:---|:---|:---|
| Qt5 | fontconfig | |
| | freetype | |
| | glib2 | |
| | openssl | |
| ZooKeeper | | ant |
| | | javac |

### Building

1. Create a build directory.
1. Clone the repository.
1. In the repository, checkout the version you wish to build.
1. In the build directory, run CMake.
1. In the build directory, build the projects.
1. In the build directory, create an installation package.

```
mkdir -p ~/repositories/ovsrpro/release
cd ~/repositories/ovsrpro
git clone git://github.com/distributePro/ovsrpro.git
cd ovsrpro
git checkout 18.10.1
cd ../release
cmake -D XP_STEP=build ../ovsrpro
cmake --build . -- -j3
cpack
```

Some additional packages may need to be installed for the Qt Web modules to
build, here is a list of ones that commonly need to be installed on a CentOS 6
system (additional ones may be required depending on system configuration):

| Yum | Apt |
|:----|:----|
| dbus-devel          | libdbus-1-dev |
| libXScrnSaver-devel | libxss-dev |
| libXtst-devel       | libxtst-dev |
| pciutils-devel      | libpci-dev |
| mesa-libEGL-devel   | libegl1-mesa-dev |
| gperf               | gperf |
| expat-devel         | libexpat1-dev |
|                     | bison |

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
- XP\_BUILD\_DEBUG - build a debug version of the libraries along with the release
- XP\_BUILD\_STATIC - build static libraries rather than dynamic.  Note that some
  project build systems build both static and shared by default
- XP\_DEFAULT - Compiles all of the available packages.  To only compile a subset
  of the packages, set XP\_DEFAULT=0 and specify the individual packages desired.
- XP\_STEP - may be used to define which steps to complete of the build process
          - see the externpro documentation for available options
- PACKAGE\_TYPE - optionally specify a non-default CPACK\_GENERATOR to use, if not
  present the default STGZ generator is used. (RPM is the only other generator
  type that has been tested)

Available package options when XP\_DEFAULT=0 or is not defined
- XP\_PRO\_CPPZMQ - build the cppzmq package (depends on zeromq)
- XP\_PRO\_GLEW - build the GLEW package
- XP\_PRO\_HDF5 - build the HDF5 package
- XP\_PRO\_KERBEROS - build the MIT kerberos package
- XP\_PRO\_LIBRDKAFKA - build the librdkafka package
- XP\_PRO\_NOVAS - build the novas package
- XP\_PRO\_PSQL - build the postgresql package
- XP\_PRO\_QT5 - build the qt5 package
- XP\_PRO\_QWT - build the qwt package
- XP\_PRO\_ZEROMQ - build the zeromq package
- XP\_PRO\_ZOOKEEPER - build the zookeeper package


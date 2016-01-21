# ovsrpro

builds overseer [projects](projects/README.md) by leveraging externpro

Supports compiling the following projects from source for both Windows and Linux:
- GLEW (http://glew.sourceforge.net)
- HDF5 (http://www.hdfgroup.org)
- MIT Kerberos (http://web.mit.edu/kerberos)
- librdkafka (https://github.com/edenhill/librdkafka)
- postresql (http://www.postresql.org)
- QT5 (http://code.qt.io)
- zookeeper (https://github.com/apache/zookeeper.git)

Note: Depends on an installed version of externpro (https://github.com/smanders/externpro)

All projects can be built as static or shared libraries.  For static windows
builds, libraries are compiled with the /MT flag.

To build an install package with these packages, perform the following steps:
- $ git clone https://github.com/distributePro/ovsrpro.git
- $ mkdir ovsrpro-build
- $ cd ovsrpro-build
- $ cmake ../ovsrpro -DXP_STEP=build -DXP_DEFAULT=1
- $ make package

For custom builds, the following cmake options are available (via the -D option)
- XP_BUILD_DEBUG - build a debug version of the libraries along with the release
- XP_BUILD_STATIC - build static libraries rather than dynamic.  Note that some
  project build systems build both static and shared by default
- XP_DEFAULT - Compiles all of the available packages.  To only compile a subset
  of the packages, set XP_DEFAULT=0 and specify the individual packages desired.
- XP_STEP - may be used to define which steps to complete of the build process
          - see the externpro documentation for available options
Available package options when XP_DEFAULT=0 or is not defined
-XP_PRO_GLEW - build the GLEW package
-XP_PRO_HDF5 - build the HDF5 package
-XP_PRO_KERBEROS - build the MIT kerberos package
-XP_PRO_LIBRDKAFKA - build the librdkafka package
-XP_PRO_PSQL - build the postgresql package
-XP_PRO_QT5 - build the qt5 package
-XP_PRO_ZOOKEEPER - build the zookeeper package


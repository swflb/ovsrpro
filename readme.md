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
sudo ./ovsrpro-18.10.1-gcc631-64-Linux.sh --prefix=/opt/extern/ --include-subdir
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
| Qt5 WebEngine | dbus | |
| | libXScrnSaver | |
| | libXtst | |
| | pciutils | |
| | EGL | |
| | expat | |
| | | bison |
| | | gperf |
| ZooKeeper | | ant |
| | | javac |

#### externpro

In addition to the above, you need to install externpro. **The version of
externpro you install must exactly match the version specified in the root
CMakeLists.txt file of ovsrpro!**

1. Navigate to
   https://github.com/distributePro/ovsrpro/blob/master/CMakeLists.txt
1. Change the branch to the tag you want to build.
1. Look for the line that reads `set(externpro_REV nn.nn.nn)`.
1. Make a note of the version (the 'nn.nn.nn' part).
1. Copy the externpro installer matching the version, OS, compiler, etc. Linux
   packages for externpro are not publicly available. If you don't have a local
package available, you'll just have to build it yourself.
1. Install externpro:
   ```
   sudo ./externpro-18.08.4-gcc631-64-Linux.sh --prefix=/opt/extern --include-subdir
   ```

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

Now, you can install your package, using the instructions above.

### CMake Options

For custom builds, the following CMake options are available:

| Option | Default | Description |
|:---|:---|:---|
| `XP_BUILD_DEBUG` | `on` | Build debug versions of the projects. Note that release versions are always built. |
| `XP_DEFAULT` | `on` | Compiles all of the available packages. To only compile a subset of the packages, set `XP_DEFAULT=off` and specify the individual packages desired. This is easier to do using cmake-gui or ccmake. |
| `XP_STEP` | `patch` | Specify which steps to complete of the build process. See the externpro documentation for available options. |
| `PACKAGE_TYPE` | `STGZ` | Specify a non-default CPack generator to use. |


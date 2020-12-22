# Building ovsrpro

This document describes the process for building ovsrpro.
First, it provides the steps to manually build the software.
Then, it details how you can use [Visual Studio Code](https://code.visualstudio.com/) and a development container to make the process a bit easier.

## Manual Build Process

Ovsrpro uses CMake to generate a build system.
Some dependencies must be installed on your system.
See [.devcontainer/Dockerfile](.devcontainer/Dockerfile) for the packages you need to install.
They are listed in the `yum install` command.

After you install the necessary tools and dependencies, you just need to run CMake two times.
The first run configures the build system and the second builds the software.
After the software is built, run CPack to generate the package.

```bash
cmake -D XP_STEP=build path/to/repository
cmake --build . --parallel $(nproc)
cpack
```

That's it.

## Using VS Code and the Development Container

This repository provides a [Dockerfile](.devcontainer/Dockerfile) and [devcontainer.json](.devcontainer/devcontainer.json) file.
You can use these with Visual Studio Code for remote container development.
This document will get you started.

By default, the container mounts directories from your host filesystem:

```text
Host               Container
-----------------------------------
<parent>/          /workspaces/
  <repository>/      <repository>/
  _bldpkgs/          _bldpkgs/
  build/             build/
```

This serves two purposes.
First, files written by the build process to *\_bldpkgs/* and *build/* persist on the host.
Second, assuming *parent/* is not on the system partition, this avoids writing excessive data to the system partition as would occur without the mounts.
These are three individual mounts, so nothing else in *parent/* on the host is mounted into the container.
These directories must already exist on the host; if they don't, the container will fail to start.

### Starting the Container

First, you need to install the relevant tools: Docker, VS Code, and the Remote Containers extension.
Next, open the repository in VS Code.
Use the VS Code command palette to run `Remote-Containers: Rebuild and Reopen in Container`.

### Configuring the CMake Project

After the container is open, use VS Code to configure the project.
In the command palette, run `CMake: Configure`.

The default configuration sets the CMake variable `XP_STEP` to *build*.
The build step will then download, unpack, patch, and build all the projects.
To use a different step, you must run CMake on the command line, or change the `cmake.configureArgs` VS Code setting.

### Building the Software

After the CMake project is configured, use the `CMake: Build` command in VS Code to build the project.
The normal VS Coe CMake interface can be used, such as selecting a specific target to build.

### Creating the Package

After the software is all built, run CPack to build the package.
This must be done manually; the CMake extension for VS Code does not support CPack.
Open a terminal and change to the build directory.
Then run CPack:

```bash
cpack
```

### More Reading

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)

########################################
# qt5
########################################
# NOTES: see instructions http://wiki.qt.io/Building-Qt-5-from-Git
# requires git >=1.6.x, Perl >= 5.14, Python >= 2.6, and postgres >= 7.3 to
# build.
########################################
xpProOption(qt5)
set(QT5_VER v5.5.0)
set(QT5_REPO http://code.qt.io/qt/qt5.git)
set(QT5_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qt5_repo)
set(QT5_INSTALL_PATH ${STAGE_DIR}/qt5)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "lgpl" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${QT5_REPO} "Qt5 main repo"
  VER ${QT5_VER}
  GIT_ORIGIN ${QT5_REPO}
  GIT_TAG ${QT5_VER}
)
set(QT5_REMOVE_SUBMODULES
  qtandroidextras
  qtwebchannel
  qtwebengine
  qtwebkit
  qtwebkit-examples
  qtwebsockets)
#######################################
# setup the configure options
macro(setConfigureOptions)
  # Define configure parameters
  set(QT5_CONFIGURE
    -qt-zlib
    -qt-pcre
    -qt-libpng
    -qt-libjpeg
    -qt-freetype
    -opengl desktop
    #-openssl
    -qt-sql-psql
    -qmake
    -opensource
    -confirm-license
    -make libs
    -nomake examples
    -nomake tools
    -nomake tests
    -prefix ${QT5_INSTALL_PATH})
  # Check whether to include debug build
  if(${XP_BUILD_DEBUG})
    list(APPEND QT5_CONFIGURE -debug-and-release)
  else()
    list(APPEND QT5_CONFIGURE -release)
  endif()
  # Check if this is a static build
  if(${XP_BUILD_STATIC})
    list(APPEND QT5_CONFIGURE -static)
  endif()
  if(WIN32)
    list(APPEND QT5_CONFIGURE -platform win32-msvc2013)
  else()
    list(APPEND QT5_CONFIGURE -platform linux-g++ -c++11)
  endif() # OS type
endmacro(setConfigureOptions)
#######################################
# Update the qmake conf with the /MT flag for static windows builds
macro(setQtQmakeConf)
  if(WIN32)
    if(${XP_BUILD_STATIC})
      # Copy the qmake conf file to setup the /MT compiler flag and enable
      # multiple cores while compiling
      configure_file(${CMAKE_SOURCE_DIR}/projects/qt5-msvc-desktop-mt.conf
                     ${QT5_REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf
                     COPYONLY)
    else()
      # Copy the qmake conf file to setup the /MD compiler flag and enable
      # multiple cores while compiling
      configure_file(${CMAKE_SOURCE_DIR}/projects/qt5-msvc-desktop-md.conf
                     ${QT5_REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf
                     COPYONLY)
    endif()
  endif()
endmacro(setQtQmakeConf)
#######################################
# mkpatch_qt5 - initialize and clone the main repository
function(mkpatch_qt5)

endfunction(mkpatch_qt5)
########################################
# download - initialize the git submodules
function(download_qt5)
  # checkout the repository and update/init all submodules
  ExternalProject_Add(qt5_repo
    DOWNLOAD_DIR ${QT5_REPO_PATH}
    GIT_REPOSITORY ${QT5_REPO}
    GIT_TAG ${QT5_VER}
    PATCH_COMMAND "" UPDATE_COMMAND "" CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND "")
endfunction(download_qt5)
########################################
# patch - remove any of the unwanted submodules
# so that they do not configure/compile
function(patch_qt5)
  foreach(RemoveModule ${QT5_REMOVE_SUBMODULES})
    file(REMOVE_RECURSE ${QT5_REPO_PATH}/${RemoveModule})
  endforeach()
endfunction(patch_qt5)
########################################
# Decides which build command to use jom/nmake/make
macro(findBuildCommand BUILD_COMMAND)
  if(WIN32)
    if(EXISTS "c:\\jom\\jom.exe")
      set(${BUILD_COMMAND} "c:\\jom\\jom.exe")
    else()
      set(${BUILD_COMMAND} "nmake -j")
    endif()
  else()
    set(${BUILD_COMMAND} "make -j")
  endif()
endmacro()
# build - configure then build the libraries
function(build_qt5)
  setConfigureOptions()
  setQtQmakeConf()

  # Determine which build command to use (jom/nmake/make)
  findBuildCommand(QT_BUILD_COMMAND)

  # Create a target to run configure
  ExternalProject_Add(qt5_configure
    DOWNLOAD_COMMAND "" UPDATE_COMMAND "" PATCH_COMMAND ""
    SOURCE_DIR ${QT5_REPO_PATH}
    CONFIGURE_COMMAND configure ${QT5_CONFIGURE}
    BUILD_COMMAND "" INSTALL_COMMAND ""
  )

  # Create a separate target to build and install...this is because for some
  # reason even though the configure succeeds just fine, it stops before
  # executing the build and install commands (may be because configure exits
  # with warnings about static builds)
  add_custom_target(qt5_build
    COMMAND cd ${QT5_REPO_PATH}
    COMMAND ${QT_BUILD_COMMAND}
    COMMAND ${QT_BUILD_COMMAND} install
  )

  # Copy the useop file to the staging area
  configure_file(${PRO_DIR}/use/useop-qt5-config.cmake
                 ${STAGE_DIR}/share/cmake/
                 COPYONLY)
endfunction(build_qt5)

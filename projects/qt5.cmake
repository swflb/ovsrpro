########################################
# qt5
########################################
# NOTES: see instructions http://wiki.qt.io/Building-Qt-5-from-Git
# build/configure tools: Perl >= 5.14
#                        Python >= 2.6
# depends: openssl from externpro
#          psql from ovsrpro
# After installation, the qt.conf file in OVSRPRO_INSTALL_PATH/qt5/bin
# must be manually modified setting the "Prefix" value to the qt5 installation
# path (e.g. C:/Program Files/ovsrpro 0.0.1-vc120-64/qt5)
########################################
xpProOption(qt5)
set(QT5_VER v5.5.1)
set(QT5_REPO http://code.qt.io/qt/qt5.git)
set(QT5_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qt5)
set(QT5_DOWNLOAD_FILE qt-everywhere-opensource-src-5.5.1.tar.gz)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "lgpl" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${QT5_REPO} "Qt5 main repo"
  VER ${QT5_VER}
  GIT_ORIGIN ${QT5_REPO}
  GIT_TAG ${QT5_VER}
  DLURL http://download.qt.io/archive/qt/5.5/5.5.1/single/${QT5_DOWNLOAD_FILE}
  DLMD5 59f0216819152b77536cf660b015d784
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
  set(QT5_INSTALL_PATH ${STAGE_DIR}/qt5)
  # Define configure parameters
  set(QT5_CONFIGURE
    -qt-zlib
    -qt-pcre
    -qt-libpng
    -qt-libjpeg
    -qt-freetype
    -opengl desktop
    -openssl
    -qt-sql-psql
    -opensource
    -confirm-license
    -make libs
    -nomake examples
    -make tools
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
    list(APPEND QT5_CONFIGURE -platform win32-msvc2013 -qmake -mp)
  else()
    if(${XP_BUILD_STATIC})
      list(APPEND QT5_CONFIGURE
      # Add include and library paths for postgres for static builds
      -I ${STAGE_DIR}/include/psql
      -L ${STAGE_DIR}/lib -lpq)
    endif()
    list(APPEND QT5_CONFIGURE -platform linux-g++
      -c++11
      -qt-xcb
      -qt-xkbcommon-x11
      -optimized-qmake
      -verbose
      -no-nis
      -no-cups
      -no-iconv
      -no-evdev
      -no-tslib
      -no-icu
      -no-android-style-assets
      -no-gstreamer)
  endif() # OS type
endmacro(setConfigureOptions)
#######################################
# mkpatch_qt5 - initialize and clone the main repository
function(mkpatch_qt5)
  xpRepo(${PRO_QT5})
endfunction(mkpatch_qt5)
########################################
# download - initialize the git submodules
function(download_qt5)
  xpNewDownload(${PRO_QT5})
endfunction(download_qt5)
########################################
# patch - remove any of the unwanted submodules
# so that they do not configure/compile
function(patch_qt5)
  xpPatch(${PRO_QT5})
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()

  # Remove the modules that aren't wanted
  foreach(RemoveModule ${QT5_REMOVE_SUBMODULES})
    ExternalProject_Add_Step(qt5 qt5_remove_${RemoveModule}
      COMMENT "Removing ${RemoveModule}"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${RemoveModule}
      DEPENDEES download
      )
  endforeach()

  # if this didn't come from the repo (direct download) need to
  # add a .gitignore...it is used by the configure scripts to
  # determine whether to compile the configure.exe
  if (NOT EXISTS ${QT5_REPO_PATH}/qtbase/.gitignore)
    ExternalProject_Add_Step(qt5 qt5_add_gitignore
      COMMENT "Creating empty gitignore file"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      COMMAND ${CMAKE_COMMAND} -E touch ${QT5_REPO_PATH}/qtbase/.gitignore
      DEPENDEES download)
  endif()

  # setup the mkspec file appropriately for static/dynamic
  if(WIN32)
    if(${XP_BUILD_STATIC})
      set(QT5_MKSPEC ${PATCH_DIR}/qt5-msvc-desktop-mt.conf)
    else()
      set(QT5_MKSPEC ${PATCH_DIR}/qt5-msvc-desktop-md.conf)
    endif()

    ExternalProject_Add_Step(qt5 qt5_setup_mkspec
      COMMENT "Preparing MKSPEC"
      COMMAND ${CMAKE_COMMAND} -E copy ${QT5_MKSPEC} ${QT5_REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf
      DEPENDEES download)
  endif()
endfunction(patch_qt5)
macro(qt5CheckDependencies)
  find_program(python python)
  if(${python} MATCHES python-NOTFOUND)
    message(FATAL_ERROR "python required for qt5")
  endif()

  find_program(perl perl)
  if(${perl} MATCHES perl-NOTFOUND)
    message(FATAL_ERROR "perl required for qt5")
  endif()
endmacro()
########################################
# build - configure then build the libraries
function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()

  # Make sure the psql target this depends on has been created
  if(NOT (XP_DEFAULT OR XP_PRO_PSQL))
    message(FATAL "qt5 requires psql")
    return()
  endif()

  # Make sure the qt5 target this depends on has been created
  if(NOT TARGET qt5)
    patch_qt5()
  endif()

  qt5CheckDependencies()

  setConfigureOptions()

  # Create a separate target to build and install...this is because for some
  # reason even though the configure succeeds just fine, it stops before
  # executing the build and install commands (may be because configure exits
  # with warnings about static builds)
  add_custom_target(qt5_configure ALL
    COMMENT "Configuring qt5"
    WORKING_DIRECTORY ${QT5_REPO_PATH}
    COMMAND ./configure ${QT5_CONFIGURE}
    DEPENDS qt5 psql_build)

  # On windows, add the include directories for open ssl and postgres
  if(WIN32)
    set(XP_INCLUDE_DIR ${XP_ROOTDIR}/include) # for open ssl
    set(OPENSSL_LIB_DIR ${XP_ROOTDIR}/lib) # for open ssl
    add_custom_target(qt5_build ALL
      COMMENT "Configuration complete...building qt5"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      # The postgres and openssl includes seem to conflict with other libraries...they need to
      # be included after all other options, which can be done with VS using the _CL_ environment
      # variable
      COMMAND set _CL_=%_CL_% /I"${XP_INCLUDE_DIR}" /I"${STAGE_DIR}/include/psql"
      COMMAND set LIB=${OPENSSL_LIB_DIR}\;${STAGE_DIR}/lib\;%LIB%
      COMMAND echo %LIB%
      COMMAND echo %_CL_%
      COMMAND nmake
      COMMAND nmake install
      COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-qt5-config.cmake ${STAGE_DIR}/share/cmake/useop-qt5-config.cmake
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/qt.conf ${STAGE_DIR}/qt5/bin/qt.conf
      DEPENDS qt5 qt5_configure psql_build
    )
  else()
    add_custom_target(qt5_build ALL
      COMMENT "Configuration complete...building qt5"
      WORKING_DIRECTORY ${QT5_REPO_PATH}
      COMMAND make -j2
      COMMAND make install
      COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-qt5-config.cmake ${STAGE_DIR}/share/cmake/useop-qt5-config.cmake
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/qt.conf ${STAGE_DIR}/qt5/bin/qt.conf
      DEPENDS qt5 qt5_configure psql_build
    )

  endif()

  # Copy the various LICENSE files to STAGE_DIR
  add_custom_command(TARGET qt5_build POST_BUILD
    WORKING_DIRECTORY ${QT5_REPO_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LGPL_EXCEPTION.txt ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.FDL ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.GPLv2 ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.GPLv3 ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.LGPLv21 ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.LGPLv3 ${STAGE_DIR}/share/qt5
    COMMAND ${CMAKE_COMMAND} -E copy ${QT5_REPO_PATH}/LICENSE.PREVIEW.COMMERCIAL ${STAGE_DIR}/share/qt5
  )

  configure_file(${PRO_DIR}/use/useop-qt5-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-qt5-config.cmake
                 COPYONLY)
endfunction(build_qt5)

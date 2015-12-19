########################################
# qt5
########################################
# NOTES: see instructions http://wiki.qt.io/Building-Qt-5-from-Git
# requires git >=1.6.x, Perl >= 5.14, Python >= 2.6, and postgres >= 7.3 to
# build.
########################################
xpProOption(qt5)
set(VER v5.5.0)
string(REPLACE "." "_" VER_ ${VER})
set(REPO https://code.qt.io/qt/qt5)
set(REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qt5_repo)
set(BUILD_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qt5)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "lgpl" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${REPO} "Qt5 self hosted repo"
  VER ${VER}
  GIT_ORIGIN git://code.qt.io/qt/qt5.git
  GIT_TAG ${VER} # what to 'git checkout'
  )
########################################
function(mkpatch_qt5)
  xpRepo(${PRO_QT5})
  # Get all the submodules
  ExternalProject_Add_Step(qt5_repo UpdateSubmodules
    COMMAND ${GIT_EXECUTABLE} submodule update --init
    COMMENT "Updating Qt5 submodules"
    WORKING_DIRECTORY ${REPO_PATH})
  # remove unwanted modules so they don't compile
  if(WIN32)
    set(DELETE_COMMAND "rmdir /Q /S")
  else()
    set(DELETE_COMMAND "rm -rf")
  endif()
  set(REMOVE_SUBMODULES
    qtandroidextras
    qtwebchannel
    qtwebengine
    qtwebkit
    qtwebkit-examples)
  foreach(submodule ${REMOVE_SUBMODULES})
    ExternalProject_Add_Step(qt5_repo Delete${submodule}
      COMMAND ${DELETE_COMMAND} ${submodule}
      COMMENT "Deleting uneeded Qt5 submodules (${submodule})"
      WORKING DIRECTORY ${REPO_PATH})
  endforeach()
endfunction()
########################################
function(download_qt5)
  message("Download from git repo via mkpatch step")
endfunction()
########################################
function(patch_qt5)
  message("No Qt5 patch needed")
endfunction()
########################################
function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()
  # Define configure parameters
  set(XP_CONFIGURE
    "-qt-zlib"
    "-qt-pcre"
    "-qt-libpng"
    "-qt-libjpeg"
    "-qt-freetype"
    "-opengl desktop"
    #"-openssl"
    "-qt-sql-psql"
    "-qmake"
    "-c++11"
    "-opensource"
    "-confirm-license"
    "-make libs"
    "-nomake examples"
    "-nomake tools"
    "-nomake tests"
    "-prefix ${BUILD_PATH}")
  # Check whether to include debug build
  if(${XP_BUILD_DEBUG})
    list(APPEND XP_CONFIGURE "-debug-and-release")
  else()
    list(APPEND XP_CONFIGURE "-release")
  endif()
  # Check if this is a static build
  if(${XP_BUILD_STATIC})
    list(APPEND XP_CONFIGURE "-static")
  endif()
  if(WIN32)
    list(APPEND XP_CONFIGURE "-platform win32-msvc2013")
    if(${XP_BUILD_STATIC})
      # Copy the qmake conf file to setup the /MT compiler flag
      file(COPY ${CMAKE_SOURCE_DIR}/qt5-msvc-desktop.conf
           DESTINATION ${REPO_PATH}/qtbase/mkspecs/common/msvc-desktop.conf)
    endif()
  else()
    list(APPEND XP_CONFIGURE
      "-platform linux-g++")
  endif() # OS type
#  configure_file(${PRO_DIR}/use/usexp-qt5-config.cmake ${STAGE_DIR}/share/cmake/
#  @ONLY NEWLINE_STYLE LF)
  # Run Configure on the repository
  ExternalProject_Add_Step(qt5_repo ConfigureQt5
    COMMAND "configure ${XP_CONFIGURE}"
    COMMENT "Configuring QT5"
    WORKING_DIRECTORY ${REPO_PATH})
  xpCmakeBuild(qt5 "" "{XP_CONFIGURE}")
endfunction()

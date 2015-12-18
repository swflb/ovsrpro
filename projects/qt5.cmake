########################################
# qt5
########################################
# NOTES: see instructions http://wiki.qt.io/Building-Qt-5-from-Git
# requires git >=1.6.x, Perl >= 5.14, & Python >= 2.6 to build.
########################################
xpProOption(qt5)
set(VER v5.5.0)
string(REPLACE "." "_" VER_ ${VER})
set(REPO https://code.qt.io/qt/qt5)
set(PRO_QT5
  NAME qt5
  WEB "Qt" http://qt.io/ "Qt - Home"
  LICENSE "lgpl" http://www.qt.io/qt-licensing-terms/ "LGPL"
  DESC "One Qt Code: Create Powerful Applications & Devices"
  REPO "repo" ${REPO} "Qt5 self hosted repo"
  VER ${VER}
  GIT_ORIGIN https://code.qt.io/qt/qt5.git
  GIT_UPSTREAM https://code.qt.io/qt/qt5.git
  GIT_TAG ${VER} # what to 'git checkout'
  GIT_REF qt5-${VER} # create patch from this tag to 'git checkout'
  DLNAME qt-everywhere-opensource-src-5.5.1.tar.gz
  DLURL http://download.qt.io/official_releases/qt/5.5/5.5.1/single/${DLNAME}
  DLMD5 59f0216819152b77536cf660b015d784
  # PATCH ${PATCH_DIR}/qt5.patch
  # DIFF ${REPO}/compare/
  )
########################################
function(mkpatch_qt5)
  xpRepo(${PRO_QT5})
endfunction()
########################################
function(download_qt5)
  xpNewDownload(${PRO_QT5})
endfunction()
########################################
function(patch_qt5)
  xpPatch(${PRO_QT5})
endfunction()
########################################
function(stringToList stringlist lvalue var)
  if(NOT "${stringlist}" STREQUAL "")
    string(STRIP ${stringlist} stringlist) # remove leading and trailing spaces
    string(REPLACE " -" ";-" listlist ${stringlist})
    foreach(item ${listlist})
      list(APPEND templist ${lvalue}=${item})
    endforeach()
    set(${var} "${templist}" PARENT_SCOPE)
  endif()
endfunction()
########################################
function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()
  if(WIN32)
    message(FATAL_ERROR "no windows yet")
  else()
    set(XP_CONFIGURE
      -static
      -qt-zlib
      -qt-pcre
      -qt-libpng
      -qt-libjpeg
      -qt-freetype
      -qt-xcb
      -qt-xkbcommon
      -opengl desktop
      -qt-sql-psql
      -c++11
      -opensource
      -confirm-license
      -make libs
      -nomake examples
      -nomake tools
      -nomake tests
      -skip qtwebchannel
      -skip qtwebengine
      -skip qtwebkit
      -skip qtwebkit-examples
      -skip qtenginio
      -skip qt3d
      )
    configure_file(${PRO_DIR}/use/usexp-qt5-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
    xpCmakeBuild(qt5 "" "${XP_CONFIGURE}")
  endif() # OS type
endfunction()


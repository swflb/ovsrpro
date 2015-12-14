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
  GIT_ORIGIN git://code.qt.io/qt/qt5.git
  GIT_UPSTREAM git://code.qt.io/qt/qt5.git
  # GIT_TAG xp-${VER_} # what to 'git checkout'
  # GIT_REF hdf5-${VER_} # create patch from this tag to 'git checkout'
  # DLURL ${REPO}/archive/${VER}.tar.gz
  # DLMD5 3c0d7a8c38d1abc7b40fc12c1d5f2bb8
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
function(build_qt5)
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    return()
  endif()
  xpCmakeBuild(qt5 "" "${XP_CONFIGURE}")
endfunction()

########################################
# hdf5
xpProOption(hdf5)
set(VER 1.8.15-patch1)
string(REPLACE "." "_" VER_ ${VER})
set(REPO https://github.com/smanders/hdf5)
set(PRO_HDF5
  NAME hdf5
  WEB "HDF5" http://www.hdfgroup.org/HDF5/ "The HDF Group HDF5 website"
  LICENSE "open" http://www.hdfgroup.org/products/licenses.html "BSD-style"
  DESC "Hierarchical Data Format 5"
  REPO "repo" ${REPO} "forked hdf5 repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/hdf5.git
  GIT_UPSTREAM git://github.com/live-clones/hdf5.git
  GIT_TAG xp-${VER_} # what to 'git checkout'
  GIT_REF hdf5-${VER_} # create patch from this tag to 'git checkout'
  DLURL http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-${VER}.tar.bz2
  DLMD5 3c0d7a8c38d1abc7b40fc12c1d5f2bb8
  PATCH ${PATCH_DIR}/hdf5.patch
  DIFF ${REPO}/compare/
  )
########################################
function(mkpatch_hdf5)
  xpRepo(${PRO_HDF5})
endfunction()
########################################
function(download_hdf5)
  xpNewDownload(${PRO_HDF5})
endfunction()
########################################
function(patch_hdf5)
  xpPatch(${PRO_HDF5})
endfunction()
########################################
function(build_hdf5)
  if(NOT (XP_DEFAULT OR XP_PRO_HDF5))
    return()
  endif()
  #configure_file(${PRO_DIR}/use/usexp-hdf5-config.cmake ${STAGE_DIR}/share/cmake/
  #  @ONLY NEWLINE_STYLE LF
  #  )
  #xpCmakeBuild(hdf5)
endfunction()

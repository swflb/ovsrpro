########################################
# novas 
########################################
xpProOption(novas)
set(NOVAS_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/novas)
set(VER 3.1)
if(WIN32)
  set(NOVAS_DLURL https://github.com/distributePro/NOVAS/archive/3.1.zip)
  set(NOVAS_DLMD5 284551d075b0fde91336bbe814e7b2d0)
else()
  set(NOVAS_DLURL https://github.com/distributePro/NOVAS/archive/3.1.tar.gz)
  set(NOVAS_DLMD5 32e0be0a4ffe9e44ef2d12a0e2da546c)
endif()
set(PRO_NOVAS
  NAME novas
  WEB "NOVAS" https://github.com/distributePro/NOVAS "NOVAS"
  LICENSE "open" https://github.com/distributePro/NOVAS/blob/3.1/README.txt "(See Section IV. Using NOVAS in Your Applications)"
  DESC "NOVAS is an integrated package of ANSI C functions for computing many commonly needed quantities in positional astronomy."
  VER ${VER}
  DLURL ${NOVAS_DLURL}
  DLMD5 ${NOVAS_DLMD5}
  DLNAME novasc3.1.tar.gz
  PATCH ${PATCH_DIR}/novas.patch
  REPO "repo" "https://github.com/distributePro/NOVAS" "Mirror of the NOVAS C library"
  GIT_ORIGIN git://github.com/distributepro/NOVAS.git
  GIT_TAG ${VER} # what to 'git checkout'
  GIT_REF ${VER} # create path from this tag to 'git checkout'
)
########################################
function(build_novas)
  if (NOT (XP_DEFAULT OR XP_PRO_NOVAS))
    return()
  endif()
  configure_file(${PRO_DIR}/use/useop-novas-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )
  xpCmakeBuild(novas)
endfunction()

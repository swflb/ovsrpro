########################################
# novas 
########################################
xpProOption(zeromq)
set(ZEROMQ_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zeromq)
if(WIN32)
  set(ZEROMQ_DLURL https://github.com/zeromq/libzmq/releases/download/v4.2.1/zeromq-4.2.1.zip)
  set(ZEROMQ_DLMD5 064d8d96a91a53f560eb81ddb32c5a71)
else()
  set(ZEROMQ_DLURL https://github.com/zeromq/libzmq/releases/download/v4.2.1/zeromq-4.2.1.tar.gz)
  set(ZEROMQ_DLMD5 820cec2860a72c3257881a394d83bfc0)
endif()
set(PRO_ZEROMQ
  NAME zeromq
  WEB "ZEROMQ" https://zeromq.org "ZEROMQ"
  LICENSE "open" https://github.com/zeromq/libzmq/blob/master/README.md "(See License Section. GNU Lesser General Public LIcense.)"
  DESC "ZEROMQ is a lightweight messaging kernel is a library that extends standard socket interfaces."
  VER 4.2.1
  DLURL ${ZEROMQ_DLURL}
  DLMD5 ${ZEROMQ_DLMD5}
  #PATCH ${PATCH_DIR}/zeromq.patch
)
########################################
#function(patch_zeromq)
#  if(NOT (XP_DEFAULT OR XP_PRO_ZEROMQ))
#    return()
#  endif()

#  xpPatch(${PRO_ZEROMQ})
#endfunction()
########################################
function(build_zeromq)
  if (NOT (XP_DEFAULT OR XP_PRO_ZEROMQ))
    return()
  endif()
  configure_file(${PRO_DIR}/use/useop-zeromq-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )

  xpCmakeBuild(zeromq)

endfunction()

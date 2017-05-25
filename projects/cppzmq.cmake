########################################
# novas 
########################################
xpProOption(cppzmq)
set(CPPZMQ_VER 4.2.1)
set(CPPZMQ_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/cppzmq)
set(CPPZMQ_DLURL https://github.com/zeromq/cppzmq/archive/v${CPPZMQ_VER}.tar.gz)
set(CPPZMQ_DLMD5 72d1296f26341d136470c25320936683)
set(PRO_CPPZMQ
  NAME cppzmq
  WEB "CPPZMQ" https://github.com/zeromq/cppzmq "CPPZMQ"
  LICENSE "MIT" https://github.com/zeromq/cppzmq/blob/master/LICENSE "MIT"
  DESC "CPPZMQ is a minimal c++ binding to the libzmq functions."
  VER ${CPPZMQ_VER}
  DLURL ${CPPZMQ_DLURL}
  DLMD5 ${CPPZMQ_DLMD5}
)
########################################
function(build_cppzmq)
  if (NOT (XP_DEFAULT OR XP_PRO_CPPZMQ))
    return()
  endif()

  # Make sure libzmq is available
  if(NOT (XP_DEFAULT OR XP_PRO_ZEROMQ))
    message(FATAL_ERROR "cppzmq requires zeromq")
    return()
  endif()

  configure_file(${PRO_DIR}/use/useop-cppzmq-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
  )
 
 set(XP_CONFIGURE
    -DZeroMQ_DIR=${STAGE_DIR}/share/cmake/ZeroMQ
  )

  xpCmakeBuild(cppzmq "" "${XP_CONFIGURE}")
  add_dependencies(cppzmq zeromq_Release)

endfunction()

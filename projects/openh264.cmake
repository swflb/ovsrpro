########################################
# openh264
xpProOption(openh264)
set(VER 1.4.0)
set(REPO https://github.com/cisco/openh264)
set(OPENH264_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/openh264)
set(PRO_OPENH264
  NAME openh264
  WEB "OpenH264" http://www.openh264.org/ "OpenH264 website"
  LICENSE "open" http://http://www.openh264.org/LICENSE.txt "Two-Clause BSD"
  DESC "OpenH264 is a codec library which supports H.264 encoding and decoding. It is suitable for use in real time applications such as WebRTC."
  REPO "repo" ${REPO} "openh264 repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/cisco/openh264.git
  GIT_TAG v${VER} # what to 'git checkout'
  DLURL https://github.com/cisco/openh264/archive/v${VER}.tar.gz
  DLMD5 ca77b91a7a33efb4c5e7c56a5c0f599f
  )
########################################
function(mkpatch_openh264)
  xpRepo(${PRO_OPENH264})
endfunction()
########################################
function(download_openh264)
  xpNewDownload(${PRO_OPENH264})
endfunction()
########################################
function(patch_openh264)
  xpPatch(${PRO_OPENH264})
endfunction()
########################################
function(build_openh264)
  if(NOT (XP_DEFAULT OR XP_PRO_OPENH264))
    return()
  endif()

  if(WIN32)
   # HAVEN'T ATTEMPTED THIS YET...
  else()

    # Check if this is a static build
    if(${XP_BUILD_STATIC})
      set(OPENH264_INSTALL_CMD install-static)
    else()
      set(OPENH264_INSTALL_CMD install-shared)
    endif()

    add_custom_target(openh264_build ALL
      COMMENT "Building OpenH264 with ASM=yasm flag"
      WORKING_DIRECTORY ${OPENH264_SRC_PATH}
      COMMAND make ASM=yasm PREFIX=${STAGE_DIR} ${OPENH264_INSTALL_CMD}
      DEPENDS openh264
    )

    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET openh264_build POST_BUILD
        COMMENT "Building OpenH264 with BUILDTYPE=Debug and ASM=yasm flags"
        WORKING_DIRECTORY ${OPENH264_SRC_PATH}
        COMMAND make clean
        COMMAND make BUILDTYPE=Debug ASM=yasm PREFIX=${STAGE_DIR} SHAREDLIB_DIR=${STAGE_DIR}/lib/openh264debug ${OPENH264_INSTALL_CMD}
      )
    endif()
  endif()

  # Copy LICENSE file to STAGE_DIR
  add_custom_command(TARGET openh264_build POST_BUILD
    WORKING_DIRECTORY ${OPENH264_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/openh264
    COMMAND ${CMAKE_COMMAND} -E copy ${OPENH264_SRC_PATH}/LICENSE ${STAGE_DIR}/share/openh264
  )

  configure_file(${PRO_DIR}/use/useop-openh264-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  #xpCmakeBuild(openh264)
endfunction()

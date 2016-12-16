########################################
# openh264
xpProOption(openh264)
set(VER 1.4.0)
set(REPO https://github.com/distributepro/openh264)
set(PRO_OPENH264
  NAME openh264
  WEB "OpenH264" http://www.openh264.org/ "OpenH264 website"
  LICENSE "open" http://http://www.openh264.org/LICENSE.txt "Two-Clause BSD"
  DESC "OpenH264 is a codec library which supports H.264 encoding and decoding. It is suitable for use in real time applications such as WebRTC."
  REPO "repo" ${REPO} "forked openh264 repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/distributepro/openh264.git
  GIT_UPSTREAM git://github.com/cisco/openh264.git
  GIT_TAG xp-v${VER} # what to 'git checkout'
  GIT_REF v${VER} # create patch from this tag to 'git checkout'
  DLURL https://github.com/cisco/openh264/archive/v${VER}.tar.gz
  DLMD5 ca77b91a7a33efb4c5e7c56a5c0f599f
  DLNAME openh264-${VER}.tar.gz
  PATCH ${PATCH_DIR}/openh264.patch
  DIFF ${REPO}/compare/cisco:
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

  # Check if this is a static build
  if(${XP_BUILD_STATIC})
    set(OPENH264_INSTALL_CMD install-static)
  else()
    set(OPENH264_INSTALL_CMD install-shared)
  endif()

  configure_file(${PRO_DIR}/use/useop-openh264-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )

  xpSetPostfix()

  ExternalProject_Get_Property(openh264 SOURCE_DIR)
  ExternalProject_Add(openh264_Debug DEPENDS openh264
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND $(MAKE) clean && $(MAKE) BUILDTYPE=Debug PREFIX=${STAGE_DIR} POSTFIX=${CMAKE_DEBUG_POSTFIX} ${OPENH264_INSTALL_CMD}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/openh264 && ${CMAKE_COMMAND} -E copy_if_different ${SOURCE_DIR}/LICENSE ${STAGE_DIR}/share/openh264
    )

  ExternalProject_Add(openh264_Release DEPENDS openh264_Debug
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND $(MAKE) clean && $(MAKE) ASM=yasm PREFIX=${STAGE_DIR} POSTFIX=${CMAKE_RELEASE_POSTFIX} ${OPENH264_INSTALL_CMD}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/openh264 && ${CMAKE_COMMAND} -E copy_if_different ${SOURCE_DIR}/LICENSE ${STAGE_DIR}/share/openh264
    )

endfunction()

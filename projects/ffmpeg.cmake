########################################
# ffmpeg
xpProOption(ffmpeg)
set(VER 2.6.2)
set(REPO https://github.com/ndrasmussen/FFmpeg)
set(FFMPEG_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/ffmpeg)
set(FFMPEG_DOWNLOAD_FILE ffmpeg-${VER}.tar.bz2)
set(PRO_FFMPEG
  NAME ffmpeg
  WEB "FFmpeg" https://www.ffmpeg.org/ "FFmpeg website"
  LICENSE "LGPL" https://www.ffmpeg.org/legal.html "Lesser GPL v2.1"
  DESC "complete, cross-platform solution to record, convert and stream audio and video"
  REPO "repo" ${REPO} "forked FFmpeg repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/ndrasmussen/FFmpeg.git
  GIT_UPSTREAM git://github.com/FFmpeg/FFmpeg.git
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF n${VER} # create patch from this tag to 'git checkout'
  DLURL http://ffmpeg.org/releases/${FFMPEG_DOWNLOAD_FILE}
  DLMD5 e75d598921285d6775f20164a91936ac
  PATCH ${PATCH_DIR}/ffmpeg.patch
  DIFF ${REPO}/compare/FFmpeg:
  )
########################################
function(mkpatch_ffmpeg)
  xpRepo(${PRO_FFMPEG})
endfunction()
########################################
function(download_ffmpeg)
  xpNewDownload(${PRO_FFMPEG})
endfunction()
########################################
function(patch_ffmpeg)
  xpPatch(${PRO_FFMPEG})
endfunction()
########################################
function(build_ffmpeg)
  if(NOT (XP_DEFAULT OR XP_PRO_FFMPEG))
    return()
  endif()

  # Make sure the openh264 target this depends on has been created
  if(NOT (XP_DEFAULT OR XP_PRO_OPENH264))
    message(FATAL_ERROR "ffmpeg requires openh264")
    return()
  endif()

  # May want to add other options here such as --extra-cflags and --extra-cxxflags
  set(FFMPEG_CFG --enable-libopenh264 --prefix=${STAGE_DIR})

  # Check if this is a static build
  if(${XP_BUILD_STATIC})
    # Nothing extra to add for static builds...
  else()
    list(APPEND FFMPEG_CFG --enable-shared --disable-static)
  endif()

  # There may be more that's needed here, haven't attempted it yet...
  if(WIN32)
    list(APPEND FFMPEG_CFG --toolchain=msvc)
  endif()

  configure_file(${PRO_DIR}/use/useop-ffmpeg-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )

  xpSetPostfix()

  ExternalProject_Get_Property(ffmpeg SOURCE_DIR)
  ExternalProject_Add(ffmpeg_Release DEPENDS ffmpeg
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env PKG_CONFIG_PATH=${STAGE_DIR}/lib/pkgconfig ./configure ${FFMPEG_CFG} --disable-debug --build-suffix=${CMAKE_RELEASE_POSTFIX}
    BUILD_COMMAND $(MAKE) clean && $(MAKE) && $(MAKE) install
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    )
  ExternalProject_Add(ffmpeg_Debug DEPENDS ffmpeg_Release
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env PKG_CONFIG_PATH=${STAGE_DIR}/lib/pkgconfig ./configure ${FFMPEG_CFG} --enable-debug --disable-stripping --build-suffix=${CMAKE_DEBUG_POSTFIX}
    BUILD_COMMAND $(MAKE) clean && $(MAKE) && $(MAKE) install-libs
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    )
   add_dependencies(ffmpeg_Release openh264_Release)

  ExternalProject_Get_Property(ffmpeg DOWNLOAD_DIR)
  ExternalProject_Add(ffmpeg_install_files DEPENDS ffmpeg_Release
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${NULL_DIR} CONFIGURE_COMMAND "" BUILD_COMMAND ""
    INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/LICENSE.md ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/README.md ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.GPLv2 ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.GPLv3 ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.LGPLv2.1 ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.LGPLv3 ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${DOWNLOAD_DIR}/${FFMPEG_DOWNLOAD_FILE} ${STAGE_DIR}/share/ffmpeg &&
      ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/ffmpeg.patch ${STAGE_DIR}/share/ffmpeg &&
      echo "Compile flags used when building the library (after applying 'ffmpeg.patch' file to the source tree): '${FFMPEG_CFG}'" > ${STAGE_DIR}/share/ffmpeg/compileFlags
    )

endfunction()

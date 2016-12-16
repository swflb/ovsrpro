########################################
# ffmpeg
xpProOption(ffmpeg)
set(VER 2.6.2)
set(REPO https://github.com/ndrasmussen/FFmpeg)
set(FFMPEG_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/ffmpeg)
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
  DLURL http://ffmpeg.org/releases/ffmpeg-${VER}.tar.bz2
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

  if(WIN32)
   # HAVEN'T ATTEMPTED THIS YET...
  else()
    set(FFMPEG_CFG --enable-libopenh264)

    # Check if this is a static build
    if(${XP_BUILD_STATIC})
      # Nothing extra to add for static builds...
    else()
      list(APPEND FFMPEG_CFG --enable-shared --disable-static)
    endif()

    add_custom_target(ffmpeg_build ALL
      COMMENT "Building FFmpeg with these flags: ${FFMPEG_CFG} --disable-debug"
      WORKING_DIRECTORY ${FFMPEG_SRC_PATH}
      COMMAND ${CMAKE_COMMAND} -E env PKG_CONFIG_PATH=${STAGE_DIR}/lib/pkgconfig ./configure ${FFMPEG_CFG} --prefix=${STAGE_DIR} --disable-debug
      COMMAND make -j4
      COMMAND make install
      DEPENDS ffmpeg openh264_Release
    )

    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET ffmpeg_build POST_BUILD
        COMMENT "Building FFmpeg with these flags: ${FFMPEG_CFG}"
        WORKING_DIRECTORY ${FFMPEG_SRC_PATH}
        COMMAND make clean
        COMMAND ${CMAKE_COMMAND} -E env PKG_CONFIG_PATH=${STAGE_DIR}/lib/pkgconfig ./configure ${FFMPEG_CFG} --prefix=${STAGE_DIR} --libdir=${STAGE_DIR}/lib/ffmpegdebug
        COMMAND make -j4
        COMMAND make install-libs
      )
    endif()
  endif()  

  # Copy LICENSE and README files to STAGE_DIR
  add_custom_command(TARGET ffmpeg_build POST_BUILD
    WORKING_DIRECTORY ${FFMPEG_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/LICENSE.md ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/README.md ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.GPLv2 ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.GPLv3 ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.LGPLv2.1 ${STAGE_DIR}/share/ffmpeg
    COMMAND ${CMAKE_COMMAND} -E copy ${FFMPEG_SRC_PATH}/COPYING.LGPLv3 ${STAGE_DIR}/share/ffmpeg
    COMMAND echo "Compile flags used when building the library: '${FFMPEG_CFG}'" > ${STAGE_DIR}/share/ffmpeg/compileFlags
  )

  configure_file(${PRO_DIR}/use/useop-ffmpeg-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  #xpCmakeBuild(ffmpeg)
endfunction()

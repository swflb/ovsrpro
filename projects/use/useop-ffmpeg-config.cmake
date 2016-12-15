# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

unset(FFMPEG_INCLUDE_DIR CACHE)
unset(FFMPEG_LIBRARY_DIR CACHE)

set(FFMPEG_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(FFMPEG_LIB_DIR ${OP_ROOTDIR}/lib)

# determine OP_BUILD_STATIC
include(${CMAKE_CURRENT_LIST_DIR}/opopts.cmake)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(OP_BUILD_STATIC)
  if(WIN32)
    # HAVEN'T ATTEMPTED WINDOWS BUILD YET...
  else()
    if(${build_type} STREQUAL debug)
      set(FFMPEG_LIBS
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libavcodec.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libavdevice.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libavfilter.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libavformat.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libavutil.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libswresample.a
        ${FFMPEG_LIB_DIR}/ffmpegdebug/libswscale.a)
    else()
      set(FFMPEG_LIBS
        ${FFMPEG_LIB_DIR}/libavcodec.a
        ${FFMPEG_LIB_DIR}/libavdevice.a
        ${FFMPEG_LIB_DIR}/libavfilter.a
        ${FFMPEG_LIB_DIR}/libavformat.a
        ${FFMPEG_LIB_DIR}/libavutil.a
        ${FFMPEG_LIB_DIR}/libswresample.a
        ${FFMPEG_LIB_DIR}/libswscale.a)
    endif()
  endif()
else()
  set(FFMPEG_LIBS
    avcodec
    avdevice
    avfilter
    avformat
    avutil
    swresample
    swscale)
endif()

include_directories(SYSTEM ${FFMPEG_INCLUDE_DIR})

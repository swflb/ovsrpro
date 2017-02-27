# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

unset(OPENH264_INCLUDE_DIR CACHE)
unset(OPENH264_LIBRARY_DIR CACHE)

set(OPENH264_INCLUDE_DIR ${OP_ROOTDIR}/include/wels)
set(OPENH264_LIB_DIR ${OP_ROOTDIR}/lib)

# determine OP_BUILD_STATIC
include(${CMAKE_CURRENT_LIST_DIR}/opopts.cmake)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(OP_BUILD_STATIC)
  if(WIN32)
    # HAVEN'T ATTEMPTED WINDOWS BUILD YET...
  else()
    if(${build_type} STREQUAL debug)
      set(OPENH264_LIB ${OPENH264_LIB_DIR}/libopenh264-d.a)
    else()
      set(OPENH264_LIB ${OPENH264_LIB_DIR}/libopenh264.a)
    endif()
  endif()
endif()

include_directories(SYSTEM ${OPENH264_INCLUDE_DIR})

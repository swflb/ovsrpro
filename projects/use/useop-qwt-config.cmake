# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

unset(QWT_INCLUDE_DIR CACHE)
unset(QWT_LIBRARY_DIR CACHE)

set(QWT_INCLUDE_DIR ${OP_ROOTDIR}/include/)
set(QWT_LIB_DIR ${OP_ROOTDIR}/lib)

# determine OP_BUILD_STATIC
include(${CMAKE_CURRENT_LIST_DIR}/opopts.cmake)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(OP_BUILD_STATIC)
  if(WIN32)
    if(${build_type} STREQUAL debug)
      set(QWT_LIB ${QWT_LIB_DIR}/qwtd.lib)
    else()
      set(QWT_LIB ${QWT_LIB_DIR}/qwt.lib)
    endif()
  else()
    set(QWT_LIB ${QWT_LIB_DIR}/libqwt.a)
  endif()
endif()

link_directories(${QWT_LIB_DIR})
include_directories(SYSTEM ${QWT_INCLUDE_DIR})

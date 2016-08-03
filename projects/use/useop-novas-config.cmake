# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(NOVAS_INCLUDE_DIR CACHE)
unset(NOVAS_LIBRARY_DIRS CACHE)
unset(NOVAS_LIBS CACHE)

set(NOVAS_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(NOVAS_LIBS_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(NOVAS_LIBS ${NOVAS_LIBS_DIR}/novasd.lib)
  else()
    set(NOVAS_LIBS ${NOVAS_LIBS_DIR}/novas.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(NOVAS_LIBS ${NOVAS_LIBS_DIR}/libnovasd.a)
  else()
    set(NOVAS_LIBS ${NOVAS_LIBS_DIR}/libnovas.a)
  endif()
endif()

# Add the novas headers to the system includes
include_directories(SYSTEM ${NOVAS_INCLUDE_DIR})

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(CPPZMQ_INCLUDE_DIR CACHE)
unset(CPPZMQ_LIBRARY_DIRS CACHE)
unset(CPPZMQ_LIBS CACHE)

set(CPPZMQ_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(CPPZMQ_LIBS_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

  if(${build_type} STREQUAL debug)
    set(CPPZMQ_LIBS ${CPPZMQ_LIBS_DIR}/cppzmq-d.a)
  else()
    set(CPPZMQ_LIBS ${CPPZMQ_LIBS_DIR}/cppzmq.a)
  endif()

# Add the novas headers to the system includes
include_directories(SYSTEM ${ZEROMQ_INCLUDE_DIR})

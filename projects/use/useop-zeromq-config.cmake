# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(ZEROMQ_INCLUDE_DIR CACHE)
unset(ZEROMQ_LIBRARY_DIRS CACHE)
unset(ZEROMQ_LIBS CACHE)

set(ZEROMQ_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(ZEROMQ_LIBS_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(ZEROMQ_LIBS ${ZEROMQ_LIBS_DIR}/libzmq-d.lib)
  else()
    set(ZEROMQ_LIBS ${ZEROMQ_LIBS_DIR}/libzmq.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(ZEROMQ_LIBS ${ZEROMQ_LIBS_DIR}/libzmq-d.a)
  else()
    set(ZEROMQ_LIBS ${ZEROMQ_LIBS_DIR}/libzmq.a)
  endif()
endif()

# Add the zeromq headers to the system includes
include_directories(SYSTEM ${ZEROMQ_INCLUDE_DIR})
include_directories(SYSTEM ${ZEROMQ_INCLUDE_DIR}/zeromq)

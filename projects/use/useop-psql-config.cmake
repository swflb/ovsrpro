# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(PSQL_INCLUDE_DIR CACHE)
unset(PSQL_LIBRARY_DIRS CACHE)

# Set the PSQL variables...
set(PSQL_ROOT_DIR ${OP_ROOTDIR}/psql)
set(PSQL_INCLUDE_DIR ${OP_ROOTDIR}/include/psql)
set(PSQL_LIB_DIR ${OP_ROOTDIR}/lib)

if(WIN32)
  if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(PSQL_LIBS ${PSQL_LIB_DIR}/libpqd.lib)
  else()
    set(PSQL_LIBS
      ${PSQL_LIB_DIR}/libpq.lib)
  endif()
endif()

# Add the psql headers to the system includes
include_directories(SYSTEM ${PSQL_INCLUDE_DIR})
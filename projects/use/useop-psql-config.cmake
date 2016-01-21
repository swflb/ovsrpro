# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(PSQL_INCLUDE_DIR CACHE)
unset(PSQL_LIBRARY_DIRS CACHE)

# Set the PSQL variables...
set(PSQL_ROOT_DIR ${OP_ROOTDIR}/psql)
set(PSQL_INCLUDE_DIR ${OP_ROOTDIR}/include/psql ${OPENSSL_INCLUDE_DIR})
set(PSQL_LIB_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(PSQL_LIBS ${PSQL_LIB_DIR}/libpqd.lib)
  else()
    set(PSQL_LIBS
      ${PSQL_LIB_DIR}/libpq.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(PSQL_LIBS
      ${PSQL_LIB_DIR}/psqldebug/libpq.a
    )
  else()
    set(PSQL_LIBS
      ${PSQL_LIB_DIR}/libpq.a
    )
  endif()
endif()

# Add the psql headers to the system includes
include_directories(SYSTEM ${PSQL_INCLUDE_DIR})

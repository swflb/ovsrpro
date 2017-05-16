# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(LIBRDKAFKA_INCLUDE_DIR CACHE)
unset(LIBRDKAFKA_LIBRARY_DIRS CACHE)
unset(LIBRDKAFKA_LIB CACHE)

set(LIBRDKAFKA_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(LIBRDKAFKA_LIBS_DIR ${OP_ROOTDIR}/lib)
include_directories(SYSTEM ${LIBRDKAFKA_INCLUDE_DIR})

xpFindPkg(PKGS openssl zlib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(LIBRDKAFKA_LIBS
      ${LIBRDKAFKA_LIBS_DIR}/librdkafkad.lib
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka++d.lib
      ${externpro_DIR}/lib/zlibstatic-sd.lib
      ${externpro_DIR}/lib/ssl-sd.lib)
  else()
    set(LIBRDKAFKA_LIBS
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka.lib
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka++.lib
      ${externpro_DIR}/lib/zlibstatic-s.lib
      ${externpro_DIR}/lib/ssl-s.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(LIBRDKAFKA_LIBS
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka++-d.a
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka-d.a
    )
  else()
    set(LIBRDKAFKA_LIBS
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka++.a
      ${LIBRDKAFKA_LIBS_DIR}/librdkafka.a
    )
  endif()

  list(APPEND LIBRDKAFKA_LIBS
    sasl2
    ${ZLIB_LIBRARIES}
    pthread
    rt
    ${OPENSSL_LIBRARIES}
    crypto
  )
endif()

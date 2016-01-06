# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(LIBRDKAFKA_INCLUDE_DIR CACHE)
unset(LIBRDKAFKA_LIBRARY_DIR CACHE)
unset(LIBRDKAFKA_LIBS CACHE)

# Set the include and libs paths
set(LIBRDKAFKA_INCLUDE_DIR ${OP_ROOTDIR}/include)
set(LIBRDKAFKA_LIBRARY_DIR ${OP_ROOTDIR}/lib)
set(LIBRDKAFKA_LIBS rdkafka rdkafka++ z pthread rt)

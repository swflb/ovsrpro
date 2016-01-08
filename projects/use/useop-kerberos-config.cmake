# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(KERBEROS_INCLUDE_DIR CACHE)
unset(KERBEROS_LIBRARY_DIR CACHE)
unset(KERBEROS_LIB CACHE)

# Set the include and libs paths
set(KERBEROS_INCLUDE_DIR ${OP_ROOTDIR}/include/kerberos)
set(KERBEROS_LIBS_DIR ${OP_ROOTDIR}/lib)
set(KERBEROS_LIB comerr@numBits@.lib
                 getopt.lib
                 gssapi@numBits@.lib
                 k5sprt@numBits@.lib
                 krb5_@numBits@.lib
                 wshelp@numBits@.lib
                 xpprof@numBits@.lib
)

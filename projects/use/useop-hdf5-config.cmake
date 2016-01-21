# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(HDF5_INCLUDE_DIR CACHE)
unset(HDF5_LIBRARY_DIR CACHE)

# Set the HDF5 variables
set(HDF5_INCLUDE_DIR ${OP_ROOTDIR}/include/hdf5)
set(HDF5_LIB_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  if(${build_type} STREQUAL debug)
    set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5_D.lib)
    set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp_D.lib)
    set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_D.lib)
    set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp_D.lib)
    set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools_D.lib)
    set(HDF5_SZIP_LIBRARY ${HDF5_LIB_DIR}/libszip_D.lib)
    set(HDF5_ZLIB_LIBRARY ${HDF5_LIB_DIR}/libzlib_D.lib)
  else()
    set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5.lib)
    set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp.lib)
    set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl.lib)
    set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp.lib)
    set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools.lib)
    set(HDF5_SZIP_LIBRARY ${HDF5_LIB_DIR}/libszip.lib)
    set(HDF5_ZLIB_LIBRARY ${HDF5_LIB_DIR}/libzlib.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(HDF5_LIBS
      ${HDF5_LIB_DIR}/libz_debug.a
      ${HDF5_LIB_DIR}/libszip_debug.a
      dl
    )
    set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5_debug.a ${HDF5_LIBS})
    set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp_debug.a ${HDF5_LIBS})
    set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_debug.a ${HDF5_LIBS})
    set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp_debug.a ${HDF5_LIBS})
    set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools_debug.a ${HDF5_LIBS})
  else()
    set(HDF5_LIBS
      ${HDF5_LIB_DIR}/libz.a
      ${HDF5_LIB_DIR}/libszip.a
      dl
    )
    set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5.a ${HDF5_LIBS})
    set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp.a ${HDF5_LIBS})
    set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl.a ${HDF5_LIBS})
    set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp.a ${HDF5_LIBS})
    set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools.a ${HDF5_LIBS})
  endif()
endif()

include_directories(SYSTEM ${HDF5_INCLUDE_DIR})

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Remove any old cached data
unset(HDF5_INCLUDE_DIR CACHE)
unset(HDF5_LIBRARY_DIR CACHE)

# Set the HDF5 variables
set(HDF5_INCLUDE_DIR ${OP_ROOTDIR}/include/hdf5)
set(HDF5_LIB_DIR ${OP_ROOTDIR}/lib)

if(WIN32)
  if(CMAKE_BUILD_TYPE MATCHES DEBUG)
  else()
    set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5.lib)
    set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp.lib)
    set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl.lib)
    set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp.lib)
    set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools.lib)
    set(HDF5_FORTRAN_LIBRARY ${HDF5_LIB_DIR}/libhdf5_fortran.lib)
    set(HDF5_F90CSTUB_LIBRARY ${HDF5_LIB_DIR}/libhdf5_f90cstub.lib)
    set(HDF5_HL_FORTRAN_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_fortran.lib)
    set(HDF5_HL_F90CSTRUB_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_f90cstub.lib)
  endif()
else()
  set(HDF5_C_LIBRARY ${HDF5_LIB_DIR}/libhdf5.a)
  set(HDF5_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_cpp.a)
  set(HDF5_HL_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl.a)
  set(HDF5_HL_CXX_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_cpp.a)
  set(HDF5_TOOLS_LIBRARY ${HDF5_LIB_DIR}/libhdf5_tools.a)
  set(HDF5_FORTRAN_LIBRARY ${HDF5_LIB_DIR}/libhdf5_fortran.a)
  set(HDF5_F90CSTUB_LIBRARY ${HDF5_LIB_DIR}/libhdf5_f90cstub.a)
  set(HDF5_HL_FORTRAN_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_fortran.a)
  set(HDF5_HL_F90CSTRUB_LIBRARY ${HDF5_LIB_DIR}/libhdf5_hl_f90cstub.a)
endif()

include_directories(SYSTEM ${HDF5_INCLUDE_DIR})

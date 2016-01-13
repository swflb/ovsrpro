# Sets the windows compiler flags for the appropriate static linkinking
# @param[in] static_flag the old compiler flag to use
# MUST be either /MD or /MT
macro(opSetWindowsStaticFlags STATIC_FLAG)
  if(WIN32)
    if(${STATIC_FLAG} MATCHES "/MT")
      set(REPLACE_FLAG "/MD")
    else()
      set(REPLACE_FLAG "/MT")
    endif()
    foreach (flag_var
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      if(${flag_var} MATCHES "${REPLACE_FLAG}")
        string (REGEX REPLACE "${REPLACE_FLAG}" "${STATIC_FLAG}" ${flag_var} "${${flag_var}}")
      else()
        set(${flag_var} "${${flag_var}} ${STATIC_FLAG}")
      endif()
    endforeach ()
  endif()
endmacro()

MESSAGE("cur: ${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE) # remove relative parts
if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/opfunmac.cmake)
  include(${CMAKE_CURRENT_LIST_DIR}/opfunmac.cmake)
elseif(EXISTS ${OP_ROOTDIR}/share/cmake/opfunmac.cmake)
  include(${OP_ROOTDIR}/share/cmake/opfunmac.cmake)
else()
  message(FATAL_ERROR "Could not find opfunmac.cmake")
endif()
link_directories(${OP_ROOTDIR}/lib)
include_directories(SYSTEM ${OP_ROOTDIR}/include)
# TODO: append to the cmake module path (issue with spaces in path and cmake's check_type_size?)
#list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
list(APPEND OP_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

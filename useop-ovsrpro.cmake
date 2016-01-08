# Sets the windows compiler flags for the appropriate static linkinking
# @param[in] static_flag the old compiler flag to use
# MUST be either /MD or /MT
macro(opSetWindowsStaticFlags STATIC_FLAG)
  if(WIN32)
    set(CompilerFlags
            CMAKE_CXX_FLAGS
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_C_FLAGS
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_RELEASE)
    if(${STATIC_FLAG} MATCHES "/MT")
      set(REPLACE_FLAG "/MD")
    else()
      set(REPLACE_FLAG "/MT")
    endif()
    foreach(CompilerFlag ${CompilerFlags})
      if(${${CompilerFlag}} MATCHES "${REPLACE_FLAG}")
        string(REPLACE ${REPLACE_FLAG} ${STATIC_FLAG} ${CompilerFlag} "${${CompilerFlag}}")
      elseif(NOT (${${CompilerFlag}} MATCHES "${STATIC_FLAG}"))
        set(${CompilerFlag} "${${CompilerFlag}} ${STATIC_FLAG}")
      endif()
    endforeach()
    unset(CompilerFlags)
    unset(REPLACE_FLAG)
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

########################################
# opfunmac.cmake
#  op = intended to be used both internally (by ovsrpro) and externally
#  fun = functions
#  mac = macros
# functions and macros should begin with op prefix
# functions create a local scope for variables, macros use the global scope

set(opThisDir ${CMAKE_CURRENT_LIST_DIR})
include(CMakeParseArguments)
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

macro(opFindPkg)
  cmake_parse_arguments(FP "" "" PKGS ${ARGN})
  foreach(pkg ${FP_PKGS})
    string(TOUPPER ${pkg} PKG)
    if(NOT ${PKG}_FOUND)
      string(TOLOWER ${pkg} pkg)
      unset(useop-${pkg}_DIR CACHE)
      find_package(useop-${pkg} PATHS ${OP_MODULE_PATH} NO_DEFAULT_PATH)
      mark_as_advanced(useop-${pkg}_DIR)
    endif()
  endforeach()
endmacro()

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

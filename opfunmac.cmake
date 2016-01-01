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

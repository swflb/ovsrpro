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

macro(opExecuteMkPatch)
  if(NOT GIT_EXECUTABLE)
    message("skipping mkpatch step...requires GIT_EXECUTABLE to be set")
  else()
    include(${CMAKE_BINARY_DIR}/pro_mkpatch.cmake)
  endif()
endmacro(opExecuteMkPatch)

macro(opExecuteDownload)
  opExecuteMkPatch()
  include(${CMAKE_BINARY_DIR}/pro_download.cmake)
endmacro(opExecuteDownload)

macro(opExecutePatch)
  opExecuteDownload()
  include(${CMAKE_BINARY_DIR}/pro_patch.cmake)
endmacro(opExecutePatch)

macro(opExecuteBuild)
  opExecutePatch()
  include(${CMAKE_BINARY_DIR}/pro_patch.cmake)
  include(${CMAKE_BINARY_DIR}/pro_build.cmake)
  install(DIRECTORY ${STAGE_DIR}/ DESTINATION . USE_SOURCE_PERMISSIONS)
  proSetCpackOpts()
  include(CPack)
endmacro(opExecuteBuild)

macro(opExecuteStep)
  if(${XP_STEP} STREQUAL "mkpatch")
    opExecuteMkPatch()
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "download")
    opExecuteDownload()
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "patch")
    opExecutePatch()
    xpMarkdownReadmeFinalize()
  elseif(${XP_STEP} STREQUAL "build")
    opExecuteBuild()
  else()
    message(AUTHOR_WARNING "Invalid XP_STEP specified.")
  endif()
  xpGenerateCscopeDb()
endmacro(opExecuteStep)

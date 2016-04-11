cmake_minimum_required(VERSION 3.0)
project(ovsrpro)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}) # Findexternpro.cmake
set(externpro_REV 16.01.1)
find_package(externpro REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${externpro_DIR}/share/cmake)
include(macpro)
proInit()
proAddProjectDir(projects)
if(PACKAGE_TYPE AND ${XP_STEP} STREQUAL "build")
  # This must be set before proExecuteStep otherwise the generator will be STGZ
  set(CPACK_GENERATOR ${PACKAGE_TYPE})
  set(CPACK_PACKAGE_RELOCATABLE FALSE)
  set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
  # Call proGetBuildLists and proSetStageDir here to populate some needed variables
  # (i.e. GIT_REV) these are also called by the cmake-generated pro_build.cmake file  
  proGetBuildLists()
  proSetStageDir()
  set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}/${PROJECT_NAME}-${GIT_REV}-${CMAKE_SYSTEM_NAME}")
  if(PACKAGE_TYPE STREQUAL "RPM")
    # This will add the ovsrpro libraries to the LD_LIBRARY_PATH environment variable
    configure_file(ovsrprolibs.in ${CMAKE_BINARY_DIR}/ovsrprolibs @ONLY NEWLINE_STYLE LF)
    set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE ${CMAKE_BINARY_DIR}/ovsrprolibs)
    # This will remove the ovsrpro libraries from the LD_LIBRARY_PATH on uninstall
    set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/removeovsrprolibs)
  endif()
endif()
proExecuteStep()

# move some needed cmake files into place
configure_file(Findovsrpro.cmake ${STAGE_DIR}/share/cmake/Findovsrpro.cmake COPYONLY)
configure_file(opfunmac.cmake ${STAGE_DIR}/share/cmake/opfunmac.cmake COPYONLY)
configure_file(opopts.cmake.in
  ${STAGE_DIR}/share/cmake/opopts.cmake
  @ONLY NEWLINE_STYLE LF)
configure_file(useop-ovsrpro.cmake ${STAGE_DIR}/share/cmake/useop-ovsrpro.cmake COPYONLY)

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
  set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
  if(PACKAGE_TYPE STREQUAL "RPM")
    # Older versions of cmake have issues with the @ symbol in some names in the Qt library when building an RPM
    cmake_minimum_required(VERSION 3.3)
    # This will expose the shared object files in ovsrpro by adding a .conf file to /etc/ld.so.conf.d/ and run ldconfig
    configure_file(ovsrproconf.sh.in ${CMAKE_BINARY_DIR}/ovsrproconf.sh @ONLY NEWLINE_STYLE LF)
    set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE ${CMAKE_BINARY_DIR}/ovsrproconf.sh)
    # This will remove the ovsrpro.conf file from /etc/ld.so.conf.d/ and run ldconfig on uninstall
    set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE ${CMAKE_CURRENT_SOURCE_DIR}/removeovsrproconf.sh)
    # This is a workaround for removing some unwanted duplicate paths in the resulting RPM
    # The proper way to correct the issue would be to convert the projects to use cmake (as externpro's build system expects)
    set(CPACK_RPM_USER_BINARY_SPECFILE ${CMAKE_CURRENT_SOURCE_DIR}/ovsrpro.spec.in)
  endif()
endif()
proExecuteStep()

if(${XP_STEP} STREQUAL "build")
# move some needed cmake files into place
configure_file(Findovsrpro.cmake ${STAGE_DIR}/share/cmake/Findovsrpro.cmake COPYONLY)
configure_file(opfunmac.cmake ${STAGE_DIR}/share/cmake/opfunmac.cmake COPYONLY)
configure_file(opopts.cmake.in
  ${STAGE_DIR}/share/cmake/opopts.cmake
  @ONLY NEWLINE_STYLE LF)
endif()

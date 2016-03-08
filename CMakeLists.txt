cmake_minimum_required(VERSION 3.0)
project(ovsrpro)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}) # Findexternpro.cmake
set(externpro_REV 15.10.2)
find_package(externpro REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${externpro_DIR}/share/cmake)
include(macpro)
proInit()
proAddProjectDir(projects)
proExecuteStep()

# move some needed cmake files into place
configure_file(Findovsrpro.cmake ${STAGE_DIR}/share/cmake/Findovsrpro.cmake COPYONLY)
configure_file(opfunmac.cmake ${STAGE_DIR}/share/cmake/opfunmac.cmake COPYONLY)
configure_file(opopts.cmake.in
  ${STAGE_DIR}/share/cmake/opopts.cmake
  @ONLY NEWLINE_STYLE LF)
configure_file(useop-ovsrpro.cmake ${STAGE_DIR}/share/cmake/useop-ovsrpro.cmake COPYONLY)

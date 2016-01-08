cmake_minimum_required(VERSION 3.0)
project(ovsrpro)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}) # Findexternpro.cmake
set(externpro_REV 15.10.2)
set(ovsrpro_REV 0.0.1)
find_package(externpro REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${externpro_DIR}/share/cmake)
include(macpro)
include(opfunmac)
include(useop-ovsrpro.cmake)
proInit()
proAddProjectDir(projects)
proExecuteStep()

# move some needed cmake files into place
MESSAGE("Stage: ${STAGE_DIR}")
configure_file(Findovsrpro.cmake ${STAGE_DIR}/share/cmake/Findovsrpro.cmake COPYONLY)
configure_file(opfunmac.cmake ${STAGE_DIR}/share/cmake/opfunmac.cmake COPYONLY)
configure_file(useop-ovsrpro.cmake ${STAGE_DIR}/share/cmake/useop-ovsrpro.cmake COPYONLY)

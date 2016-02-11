set(prj node)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
if(MSVC)
  set(${PRJ}_LIBRARIES ${XP_ROOTDIR}/lib/node.lib)
  set(${PRJ}_EXE ${XP_ROOTDIR}/bin/node.exe)
  set(reqVars ${PRJ}_LIBRARIES ${PRJ}_EXE)
else()
  set(${PRJ}_LIBRARIES)
  set(${PRJ}_EXE ${XP_ROOTDIR}/bin/node)
  set(reqVars ${PRJ}_EXE)
endif()
set(Npm_SCRIPT ${XP_ROOTDIR}/node_modules/npm/bin/npm-cli.js)
list(APPEND reqVars Npm_SCRIPT)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
# RAPIDJSON_FOUND - RapidJSON was found
# RAPIDJSON_INCLUDE_DIR - the RapidJSON include directory
set(prj rapidjson)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
unset(${PRJ}_INCLUDE_DIR CACHE)
find_path(${PRJ}_INCLUDE_DIR rapidjson/rapidjson.h PATHS ${XP_ROOTDIR}/include NO_DEFAULT_PATH)
set(reqVars ${PRJ}_INCLUDE_DIR)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
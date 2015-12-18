# PROTOBUF_FOUND - protobuf was found
# PROTOBUF_INCLUDE_DIRS - the protobuf include directory
# PROTOBUF_LIBRARIES - the protobuf libraries
# PROTOBUF_PROTOC_EXECUTABLE - the protobuf compiler (protoc) executable
if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()
set(prj qt5)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
# targets file (-targets) installed to lib/cmake
include(${XP_ROOTDIR}/lib/cmake/${prj}-targets.cmake)
string(TOUPPER ${prj} PRJ)
unset(${PRJ}_INCLUDE_DIRS CACHE)
find_path(${PRJ}_INCLUDE_DIRS qt5.h PATHS ${XP_ROOTDIR}/include NO_DEFAULT_PATH) # is this corect?
set(${PRJ}_LIBRARIES libqt5) # does this need to specify all the qt5 libraries being built?
set(reqVars ${PRJ}_INCLUDE_DIRS ${PRJ}_LIBRARIES)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})

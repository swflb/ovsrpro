if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

# Save the module path to restore previous state
set(PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
# Set the module path to force find_package to find the ovsrpro version of qt
set(CMAKE_MODULE_PATH ${OP_ROOTDIR}/qt5/lib/cmake/Qt5)
# find the Qt5 package
find_package(Qt5 REQUIRED COMPONENTS
             Concurrent
             Core
             Gui
             Multimedia
             MultimediaWidgets
             Network
             OpenGL
             Sql
             Svg
             Test
             Widgets
             Xml
             XmlPatterns)
set(CMAKE_MODULE_PATH ${PREV_MODULE_PATH})
unset(PREV_MODULE_PATH)

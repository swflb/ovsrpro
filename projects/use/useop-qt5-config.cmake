if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)
set(QT5_BASE_PATH ${OP_ROOTDIR}/qt5)

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
               XmlPatterns
             PATHS ${QT5_BASE_PATH}/lib/cmake/Qt5
             NO_CMAKE_PATH
             NO_CMAKE_ENVIRONMENT_PATH
             NO_SYSTEM_ENVIRONMENT_PATH
             NO_CMAKE_BUILDS_PATH
             NO_CMAKE_PACKAGE_REGISTRY
             NO_CMAKE_SYSTEM_PATH
             NO_CMAKE_SYSTEM_PACKAGE_REGISTRY)

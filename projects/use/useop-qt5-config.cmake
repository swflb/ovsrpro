if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)
set(QT5_BASE_PATH ${OP_ROOTDIR}/qt5)
if(WIN32)
  if(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(QT5_PLATFORM_LIB
      ${QT5_BASE_PATH}/plugins/platforms/qwindowsd.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qicod.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qjp2d.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qsvgd.lib
      ${QT5_BASE_PATH}/lib/Qt5PlatformSupportd.lib
      ${QT5_BASE_PATH}/lib/Qt5Svgd.lib
      ${QT5_BASE_PATH}/lib/qtharfbuzzngd.lib
      ${QT5_BASE_PATH}/lib/qtfreetyped.lib
      winmm.lib
      imm32.lib
      opengl32.lib)
  else()
    set(QT5_PLATFORM_LIB
      ${QT5_BASE_PATH}/plugins/platforms/qwindows.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qico.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qjp2.lib
      ${QT5_BASE_PATH}/plugins/imageformats/qsvg.lib
      ${QT5_BASE_PATH}/lib/Qt5PlatformSupport.lib
      ${QT5_BASE_PATH}/lib/Qt5Svg.lib
      ${QT5_BASE_PATH}/lib/qtharfbuzzng.lib
      ${QT5_BASE_PATH}/lib/qtfreetype.lib
      winmm.lib
      imm32.lib
      opengl32.lib)
  endif()
endif()

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


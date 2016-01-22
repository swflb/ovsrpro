if(COMMAND xpFindPkg)
  xpFindPkg(PKGS openssl) # dependencies
endif()

# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)
set(QT5_BASE_PATH ${OP_ROOTDIR}/qt5)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)

  if(${build_type} STREQUAL debug)
    set(QT5_MAIN_LIB ${QT5_BASE_PATH}/lib/qtmaind.lib)
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
    set(QT5_MAIN_LIB ${QT5_BASE_PATH}/lib/qtmain.lib)
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

    # define the qtpcre and qtharfbuzzng libraries as dependencies to QtWidgets
    get_target_property(linked_libs
      Qt5::Widgets INTERFACE_LINK_LIBRARIES
    )
    get_target_property(QT5WIDGETS_LOCATION
      Qt5::Widgets LOCATION)
    get_filename_component(QT5_LIB_PATH ${QT5WIDGETS_LOCATION} DIRECTORY)

    set(debugpcre "${QT5_LIB_PATH}/qtpcred.lib")
    set(debugharfbuzzng "${QT5_LIB_PATH}/qtharfbuzzngd.lib")
    set(releasepcre "${QT5_LIB_PATH}/qtpcre.lib")
    set(releaseharfbuzzng "${QT5_LIB_PATH}/qtharfbuzzng.lib")
    set(releaseqwindows "${QT5_BASE_PATH}/plugins/platforms/qwindows.lib")
    set(debugqwindows "${QT5_BASE_PATH}/plugins/platforms/qwindowsd.lib")

    set(debug_gen_expr "$<$<CONFIG:Debug>:${debugpcre}>;$<$<CONFIG:Debug>:${debugharfbuzzng}>;$<$<CONFIG:Debug>:${debugqwindows}>")
    set(nondebug_gen_expr "$<$<NOT:$<CONFIG:Debug>>:${releasepcre}>;$<$<NOT:$<CONFIG:Debug>>:${releaseharfbuzzng}>;$<$<NOT:$<CONFIG:Debug>>:${releaseqwindows}>")
    set(gen_expr "${debug_gen_expr};${nondebug_gen_expr}")
    set(ssl_lib ssl-s$<$<CONFIG:Debug>:d>.lib)
    set(crypto_lib crypto-s$<$<CONFIG:Debug>:d>.lib)

    set_target_properties(
      Qt5::Widgets
      PROPERTIES
      INTERFACE_LINK_LIBRARIES "${gen_expr};${linked_libs}"
    )
    set_target_properties(
      Qt5::Core
      PROPERTIES
      INTERFACE_LINK_LIBRARIES "${gen_expr};${linked_libs}"
    )
    set_target_properties(
      Qt5::Network
      PROPERTIES
      INTERFACE_LINK_LIBRARIES "ws2_32;${ssl_lib};crypt32;msi"
    )
    set_target_properties(
      Qt5::Gui
      PROPERTIES
      INTERFACE_LINK_LIBRARIES "${externpro_DIR}/lib/glew32.lib;glu32;opengl32"
    )
    set_target_properties(
      Qt5::Sql
      PROPERTIES
      INTERFACE_LINK_LIBRARIES "${PSQL_LIBS}"
    )
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

# copy the qt5 plugins to the output directory
# @param plugin_dirs a list of plugin directories to copy
macro(opDeployQt5Plugins plugin_dirs)
  foreach(plugindir IN LISTS plugin_dirs)
    get_filename_component(plugindirname ${plugindir} NAME)

    file(GLOB pluginfiles ${QT5_BASE_PATH}/plugins/${plugindir}/*)
    foreach(pluginfile ${pluginfiles})
      get_filename_component(pluginfilename ${pluginfile} NAME)
      file(COPY ${pluginfile}
           DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${plugindirname}
      )
    endforeach()
  endforeach()
endmacro()

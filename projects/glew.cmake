########################################
# glew
########################################
xpProOption(glew)
########################################
set(GLEW_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/glew)
set(PRO_GLEW
  NAME glew
  WEB "GLES" http://glew.sourceforge.net/ "The OpenGL Extension Wrangler Library"
  LICENSE "" "" ""
  DESC "The OpenGL Extension Wrangler Library (GLEW) is a cross-platform open-source C/C++ extension loading library."
  VER 1.13.0
  DLURL https://sourceforge.net/projects/glew/files/glew/1.13.0/glew-1.13.0.tgz/download
  DLMD5 7cbada3166d2aadfc4169c4283701066
)
########################################
function(mkpatch_glew)
  xpRepo(${PRO_GLEW})
endfunction()
########################################
function(download_glew)
  xpNewDownload(${PRO_GLEW})
endfunction()
########################################
function(patch_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW))
    return()
  endif()

  xpPatch(${PRO_GLEW})

  if(WIN32)
    # fix the static debug build to use /MTd
    ExternalProject_Add_Step(glew glew_updateDebug
      COMMENT "Patching glew's static debug to use /MTd"
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/glew_static.vcxproj ${GLEW_SRC_PATH}/build/vc12/glew_static.vcxproj
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/glew.sln ${GLEW_SRC_PATH}/build/vc12/glew.sln
      DEPENDEES download
    )
  endif()
endfunction()
########################################
function(build_glew)
  if(NOT (XP_DEFAULT OR XP_PRO_GLEW))
    return()
  endif()

  if(NOT TARGET glew)
    patch_glew()
  endif()

  if(WIN32)
    add_custom_target(glew_build
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build Release
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/include/GL ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Release/Win32 ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Release/Win32 ${STAGE_DIR}/bin
      DEPENDS glew
    )
    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET glew_build POST_BUILD
        WORKING_DIRECTORY ${GLEW_SRC_PATH}
        COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build Debug
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Debug/Win32 ${STAGE_DIR}/lib
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Debug/Win32 ${STAGE_DIR}/bin
        DEPENDS glew
      )
    endif()
  endif()
endfunction()

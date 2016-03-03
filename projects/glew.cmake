########################################
# glew
########################################
xpProOption(glew)
########################################
set(GLEW_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/glew)
set(PRO_GLEW
  NAME glew
  WEB "GLES" http://glew.sourceforge.net/ "The OpenGL Extension Wrangler Library"
  LICENSE "open" http://glew.sourceforge.net/credits.html "Modified BSD, Mesa 3-D (MIT), and Khronos (MIT)"
  DESC "The OpenGL Extension Wrangler Library (GLEW) is a cross-platform open-source C/C++ extension loading library."
  REPO "repo" https://github.com/nigels-com/glew "GLEW repo on github"
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
  else()
    ExternalProject_Add_Step(glew glew_installlocation
      COMMENT "Updating glew install location"
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/glew-Makefile ${GLEW_SRC_PATH}/Makefile
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
    add_custom_target(glew_build ALL
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      #COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build "Release"
      COMMAND msbuild ${GLEW_SRC_PATH}/build/vc12/glew.sln /p:Configuration=Release\;Platform=x64 /t:glew_static:rebuild\;glew_shared:rebuild
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/include/GL ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Release/x64 ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Release/x64 ${STAGE_DIR}/bin
      DEPENDS glew
    )
    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET glew_build POST_BUILD
        WORKING_DIRECTORY ${GLEW_SRC_PATH}
        #COMMAND devenv ${GLEW_SRC_PATH}/build/vc12/glew.sln /build "Debug"
        COMMAND msbuild ${GLEW_SRC_PATH}/build/vc12/glew.sln /p:Configuration=Debug\;Platform=x64 /t:glew_static:rebuild\;glew_shared:rebuild
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/lib/Debug/x64 ${STAGE_DIR}/lib
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/bin/Debug/x64 ${STAGE_DIR}/bin
        DEPENDS glew
      )
    endif()
  else()
    add_custom_target(glew_build ALL
      WORKING_DIRECTORY ${GLEW_SRC_PATH}
      COMMAND make
      COMMAND make install.lib install.include install.bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/include/GL ${STAGE_DIR}/include/GL
      COMMAND ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/install/lib64/libGLEW.a ${STAGE_DIR}/lib/libGLEW.a
      COMMAND ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/install/lib64/libGLEW.so.1.13.0 ${STAGE_DIR}/lib/libGLEW.so.1.13.0
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${GLEW_SRC_PATH}/install/bin ${STAGE_DIR}/bin
      DEPENDS glew
    )
    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET glew_build POST_BUILD
        WORKING_DIRECTORY ${GLEW_SRC_PATH}
        COMMAND rm -rf install
        COMMAND make clean
        COMMAND make debug
        COMMAND make install.lib install.include install.bin
        COMMAND ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/install/lib64/libGLEW.a ${STAGE_DIR}/lib/libGLEWd.a
        COMMAND ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/install/lib64/libGLEW.so.1.13.0 ${STAGE_DIR}/lib/libGLEWd.so.1.13.0
        DEPENDS glew
      )
    endif()
  endif()

  # Copy LICENSE file to STAGE_DIR
  add_custom_command(TARGET glew_build POST_BUILD
    WORKING_DIRECTORY ${GLEW_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/glew   
    COMMAND ${CMAKE_COMMAND} -E copy ${GLEW_SRC_PATH}/LICENSE.txt ${STAGE_DIR}/share/glew    
  )

  configure_file(${PRO_DIR}/use/useop-glew-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-glew-config.cmake
                 COPYONLY)
endfunction()

########################################
# librdkafka
########################################
xpProOption(librdkafka)
set(LIBRDKAFKA_VER 16.08.2)
set(LIBRDKAFKA_REPO https://github.com/distributePro/librdkafka)
set(LIBRDKAFKA_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/librdkafka)
set(PRO_LIBRDKAFKA
  NAME librdkafka
  WEB "librdkafka" https://github.com/edenhill/librdkafka "librdkafka on github"
  LICENSE "open" https://github.com/edenhill/librdkafka/blob/master/LICENSE "2-clause BSD license"
  DESC "librdkafka is a C library implementation of the Apache Kafka protocol, containing both Producer and Consumer support"
  REPO "repo" ${LIBRDKAFKA_REPO} "distributePro fork of librdkafka repo on github"
  VER ${LIBRDKAFKA_VER}
  GIT_ORIGIN ${LIBRDKAFKA_REPO}
  GIT_TAG ${LIBRDKAFKA_VER}
  DLURL ${LIBRDKAFKA_REPO}/archive/${LIBRDKAFKA_VER}.tar.gz
  DLMD5 ebe69970fee006e61fd76cabff5cc4cc
  DLNAME librdkafka-${LIBRDKAFKA_VER}.tar.gz
)
########################################
# mkpatch_librdkafka
function(mkpatch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpRepo(${PRO_LIBRDKAFKA})
endfunction(mkpatch_librdkafka)
########################################
# download
function(download_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpNewDownload(${PRO_LIBRDKAFKA})
endfunction(download_librdkafka)
########################################
# patch
function(patch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpPatch(${PRO_LIBRDKAFKA})

  if(WIN32)
    # setup the patch file with knowledge of the externpro directory
    set(tmpPatchFile ${CMAKE_BINARY_DIR}/xpbase/tmp/librdkafka_repo/librdkafka-windows.patch)
    configure_file(${PATCH_DIR}/librdkafka-windows.patch
                   ${tmpPatchFile} NEWLINE_STYLE UNIX)
MESSAGE("CONFIGURED!!!")
    ExternalProject_Add_Step(librdkafka librdkafka_win_patch
      WORKING_DIRECTORY ${LIBRDKAFKA_SRC_PATH}
      COMMAND ${GIT_EXECUTABLE} apply ${tmpPatchFile}
      DEPENDEES patch
    )
  endif()
endfunction(patch_librdkafka)
########################################
# Add zlib to the desired target
macro(addLibs target)
  if(WIN32)
    message("adding libs to ${target}")
    target_link_libraries(${target}
      ${XP_ROOTDIR}/lib/zlibstatic-s.lib
      ${XP_ROOTDIR}/lib/crypto-s.lib
      ${XP_ROOTDIR}/lib/ssl-s.lib)
  endif()
endmacro()
########################################
# build
function(build_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  # Make sure the librdkafka target this depends on has been created
  if(NOT TARGET librdkafka_repo)
    patch_librdkafka()
  endif()

  # define the header files
  set(hdr_files
    ${LIBRDKAFKA_SRC_PATH}/src/rdkafka.h
    ${LIBRDKAFKA_SRC_PATH}/src-cpp/rdkafkacpp.h
  )

  if(WIN32)
    add_custom_target(librdkafka_build ALL
      WORKING_DIRECTORY ${LIBRDKAFKA_SRC_PATH}/win32
      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafka:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafkacpp:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafka:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafkacpp:rebuild
      COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/win32/x64/Debug/librdkafkad.lib ${STAGE_DIR}/lib/librdkafkad.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/win32/x64/Debug/librdkafka++d.lib ${STAGE_DIR}/lib/librdkafka++d.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/win32/x64/Release/librdkafka.lib ${STAGE_DIR}/lib/librdkafka.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/win32/x64/Release/librdkafka++.lib ${STAGE_DIR}/lib/librdkafka++.lib
      DEPENDS librdkafka
    )
    # copy the header files to the staging area
    foreach(hdr_file ${hdr_files})
      get_filename_component(hdr_name ${hdr_file} NAME)
      add_custom_command(TARGET librdkafka_build POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${hdr_file} ${STAGE_DIR}/include/librdkafka/${hdr_name}
      )
    endforeach()
  else()
    add_custom_target(librdkafka_build ALL
      WORKING_DIRECTORY ${LIBRDKAFKA_SRC_PATH}
      COMMAND ./configure --prefix=${STAGE_DIR}
      COMMAND make
      COMMAND make install
      DEPENDS librdkafka
    )
  endif()

  # Copy CONFIGURATION.md, INTRODUCTION.md, README.md and LICENSE files to STAGE_DIR
  add_custom_command(TARGET librdkafka_build POST_BUILD
    WORKING_DIRECTORY ${LIBRDKAFKA_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/CONFIGURATION.md ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/INTRODUCTION.md ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE.pycrc ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE.queue ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE.snappy ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE.tinycthread ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/LICENSE.wingetopt ${STAGE_DIR}/share/librdkafka
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBRDKAFKA_SRC_PATH}/README.md ${STAGE_DIR}/share/librdkafka
  )

  configure_file(${PRO_DIR}/use/useop-librdkafka-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-librdkafka-config.cmake
                 COPYONLY)

endfunction(build_librdkafka)

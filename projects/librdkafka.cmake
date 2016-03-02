########################################
# qt5
########################################
xpProOption(librdkafka)
set(KAFKA_VER master)
set(KAFKA_REPO https://github.com/edenhill/librdkafka)
set(KAFKA_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/librdkafka_repo)
set(PRO_KAFKA
  NAME librdkafka
  WEB "librdkafka" https://github.com/edenhill/librdkafka "librdkafka"
  LICENSE "bsd2" https://github.com/edenhill/librdkafka "BSD2"
  DESC "librdkafka is a C library implementation of the Apache Kafka protocol, containing both Producer and Consumer support"
  REPO "repo" ${KAFKA_REPO}
  VER ${KAFKA_VER}
  GIT_ORIGIN ${KAFKA_REPO}
  GIT_TAG ${KAFKA_VER}
)
########################################
# mkpatch_librdkafka
function(mkpatch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpRepo(${PRO_KAFKA})
endfunction(mkpatch_librdkafka)
########################################
# download
function(download_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpRepo(${PRO_KAFKA})
endfunction(download_librdkafka)
########################################
# patch
function(patch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  if(NOT TARGET librdkafka_repo)
    xpRepo(${PRO_KAFKA})
  endif()

  if(WIN32)
    # setup the patch file with knowledge of the externpro directory
    set(tmpPatchFile ${CMAKE_BINARY_DIR}/xpbase/tmp/librdkafka_repo/librdkafka-windows.patch)
    configure_file(${PATCH_DIR}/librdkafka-windows.patch
                   ${tmpPatchFile} NEWLINE_STYLE UNIX)
MESSAGE("CONFIGURED!!!")
    ExternalProject_Add_Step(librdkafka_repo librdkafka_win_patch
      WORKING_DIRECTORY ${KAFKA_REPO_PATH}
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
    ${KAFKA_REPO_PATH}/src/rdkafka.h
    ${KAFKA_REPO_PATH}/src-cpp/rdkafkacpp.h
  )

  if(WIN32)
    add_custom_target(librdkafka_build ALL
      WORKING_DIRECTORY ${KAFKA_REPO_PATH}/win32
      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafka:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Release\;Platform=x64 /t:librdkafkacpp:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafka:rebuild
      COMMAND msbuild librdkafka.sln /p:Configuration=Debug\;Platform=x64 /t:librdkafkacpp:rebuild
      COMMAND ${CMAKE_COMMAND} -E copy ${KAFKA_REPO_PATH}/win32/x64/Debug/librdkafkad.lib ${STAGE_DIR}/lib/librdkafkad.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${KAFKA_REPO_PATH}/win32/x64/Debug/librdkafka++d.lib ${STAGE_DIR}/lib/librdkafka++d.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${KAFKA_REPO_PATH}/win32/x64/Release/librdkafka.lib ${STAGE_DIR}/lib/librdkafka.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${KAFKA_REPO_PATH}/win32/x64/Release/librdkafka++.lib ${STAGE_DIR}/lib/librdkafka++.lib
      DEPENDS librdkafka_repo
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
      WORKING_DIRECTORY ${KAFKA_REPO_PATH}
      COMMAND ./configure --prefix=${STAGE_DIR}
      COMMAND make
      COMMAND make install
      DEPENDS librdkafka_repo
    )
  endif()

  configure_file(${PRO_DIR}/use/useop-librdkafka-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-librdkafka-config.cmake
                 COPYONLY)

endfunction(build_librdkafka)

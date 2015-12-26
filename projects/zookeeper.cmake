########################################
# zookeeper
########################################
xpProOption(zookeeper)
set(ZK_REPO https://github.com/apache/zookeeper.git)
set(ZK_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo)
set(ZK_SRC_PATH ${ZK_REPO_PATH}/src/c/src)
set(ZK_INCLUDE_PATH ${ZK_REPO_PATH}/src/c/include)
set(ZK_INSTALL_PATH ${CMAKE_BINARY_DIR}/xpbase/Install/zookeeper)
set(ZK_VER "release-3.4.7")
set(PRO_ZOOKEEPER
  NAME zookeeper
  WEB "Zookeeper" https://zookeeper.apache.org/ "Zookeeper - Home"
  LICENSE "Apache V2.0" http://www.apache.org/licenses/ "Apache V2.0"
  DESC "Apache ZooKeeper is an effort to develop and maintain an open-source server which enables highly reliable distributed coordination."
  REPO "repo" ${ZK_REPO} "Zookeeper main repo"
  VER ${ZK_VER}
  GIT_ORIGIN ${ZK_REPO}
  GIT_TAG ${ZK_VER}
)
########################################
# mkpatch_zookeeper
function(mkpatch_zookeeper)
  xpRepo(${PRO_ZOOKEEPER})
endfunction(mkpatch_zookeeper)
########################################
# download
function(download_zookeeper)
  xpRepo(${PRO_ZOOKEEPER})
endfunction(download_zookeeper)
########################################
# patch
function(patch_zookeeper)
  if(NOT TARGET zookeeper_repo)
    xpRepo(${PRO_ZOOKEEPER})
  endif()
  ExternalProject_Add_Step(zookeeper_repo zookeeper_x64Patch
    COMMENT "Patching Zookeeper for x64"
    WORKING_DIRECTORY ${ZK_REPO_PATH}
    COMMAND ${GIT_EXECUTABLE} apply ${PATCH_DIR}/zookeeper-mt_adapter-x64-fix.patch
    DEPENDEES download
  )
  if(WIN32)
    ExternalProject_Add_Step(zookeeper_repo zookeeper_winconfigPatch
      COMMAND ${GIT_EXECUTABLE} apply ${PATCH_DIR}/zookeeper-winconfig.patch
      COMMENT "Applying winconfig patch"
      WORKING_DIRECTORY ${ZK_REPO_PATH}
      DEPENDEES download zookeeper_x64Patch
    )
  endif(WIN32)

  # Copy some generated files that are not directly part of the repository
  ExternalProject_Add_Step(zookeeper_repo copyJute-c
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper.jute.c ${ZK_SRC_PATH}/zookeeper.jute.c
    COMMENT "Copying Jute C file"
    DEPENDEES download
  )
  ExternalProject_Add_Step(zookeeper_repo copyJute-h
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper.jute.h ${ZK_INCLUDE_PATH}/zookeeper.jute.h
    COMMENT "Copying Jute H file"
    DEPENDEES download
  )
endfunction(patch_zookeeper)
########################################
# Set the Windows compiler flag
# Replaces ARGV1 with ARGV2 - meant for switching between /MD and /MT
macro(setWindowsCompilerFlags OLD_VAL NEW_VAL)
  if(WIN32)
    set(CompilerFlags
            CMAKE_CXX_FLAGS
            CMAKE_CXX_FLAGS_DEBUG
            CMAKE_CXX_FLAGS_RELEASE
            CMAKE_C_FLAGS
            CMAKE_C_FLAGS_DEBUG
            CMAKE_C_FLAGS_RELEASE)
    foreach(CompilerFlag ${CompilerFlags})
      if(${${CompilerFlag}} MATCHES "${OLD_VAL}")
        string(REPLACE ${OLD_VAL} ${NEW_VAL} ${CompilerFlag} "${${CompilerFlag}}")
      else()
        set(${CompilerFlag} "${${CompilerFlag}} ${NEW_VAL}")
      endif()
      message("${${CompilerFlag}}")
    endforeach()
  else()
    message(FATAL_ERROR "Setting Windows Compiler Flags on a non-windows platform")
  endif()
endmacro(setWindowsCompilerFlags)
########################################
# build
function(build_zookeeper)
  if(NOT TARGET zookeeper_build)
    # Gather the zookeeper source files
    set(zookeeper_src_files
      ${ZK_SRC_PATH}/mt_adaptor.c
      ${ZK_SRC_PATH}/recordio.c
      ${ZK_SRC_PATH}/winport.c
      ${ZK_SRC_PATH}/zk_hashtable.c
      ${ZK_SRC_PATH}/zk_log.c
      ${ZK_SRC_PATH}/zookeeper.c
      ${ZK_SRC_PATH}/hashtable/hashtable.c
      ${ZK_SRC_PATH}/hashtable/hashtable_itr.c
      ${ZK_SRC_PATH}/zookeeper.jute.c
      ${ZK_SRC_PATH}/winport.h
      ${ZK_SRC_PATH}/zk_adaptor.h
      ${ZK_SRC_PATH}/zk_hashtable.h
      ${ZK_SRC_PATH}/hashtable/hashtable.h
      ${ZK_SRC_PATH}/hashtable/hashtable_itr.h
      ${ZK_SRC_PATH}/hashtable/hashtable_private.h
    )
    set(zookeeper_hdr_files
      ${ZK_INCLUDE_PATH}/proto.h
      ${ZK_INCLUDE_PATH}/recordio.h
      ${ZK_INCLUDE_PATH}/winconfig.h
      ${ZK_INCLUDE_PATH}/winstdint.h
      ${ZK_INCLUDE_PATH}/zookeeper.h
      ${ZK_INCLUDE_PATH}/zookeeper.jute.h
      ${ZK_INCLUDE_PATH}/zookeeper_log.h
      ${ZK_INCLUDE_PATH}/zookeeper_version.h
    )

    if(WIN32)
      list(APPEND ${zookeeper_src_files}
        ${ZK_SRC_PATH}/winport.c)
      list(APPEND ${zookeeper_hdr_files}
        ${ZK_SRC_PATH}/winport.h)
    endif(WIN32)

    # Determine build type
    if(${XP_BUILD_STATIC})
      set(ZK_BUILD_TYPE STATIC)
    else()
      set(ZK_BUILD_TYPE SHARED)
    endif()

    # indicate that all the files are GENERATED so they don't need to exist when
    # creating the target...they will be available after download
    set_source_files_properties(${zookeeper_src_files} ${zookeeper_hdr_files}
      PROPERTIES GENERATED TRUE)

    # create the library
    add_library(zookeeper_build STATIC
                ${zookeeper_src_files} ${zookeeper_hdr_files})
    target_include_directories(zookeeper_build PUBLIC ${ZK_INCLUDE_PATH})

    # Use /MT for a static windows build, and add the 'd' for debug builds
    if(${XP_BUILD_STATIC})
      if(WIN32)
        target_compile_options(zookeeper_build PUBLIC "/MT$<$<STREQUAL:$<CONFIGURATION>,Debug>:d>")
      endif(WIN32)
    endif(${XP_BUILD_STATIC})

    # Set the library output properties
    set_target_properties(zookeeper_build PROPERTIES
      OUTPUT_NAME libzookeeper-mt
      ARCHIVE_OUTPUT_DIRECTORY ${STAGE_DIR}/lib
      ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${STAGE_DIR}/lib
      ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${STAGE_DIR}/lib
      LIBRARY_OUTPUT_DIRECTORY ${STAGE_DIR}/lib
      LIBRARY_OUTPUT_DIRECTORY_DEBUG ${STAGE_DIR}/lib
      LIBRARY_OUTPUT_DIRECTORY_RELEASE ${STAGE_DIR}/lib
      RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin
      RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin
      RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin)

    # Copy the find package cmake file to the staging directory
    add_custom_command(TARGET zookeeper_build POST_BUILD
      COMMENT "Copy useop-zookeeper-config.cmake to staging area"
      COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-zookeeper-config.cmake ${STAGE_DIR}/share/cmake/useop-zookeeper-config.cmake)

    # Copy the include files to the staging directory
    foreach(hdrfile ${zookeeper_hdr_files})
      get_filename_component(file_name_only ${hdrfile} NAME)
      add_custom_command(TARGET zookeeper_build POST_BUILD
        COMMENT "Moving ${hdrfile} to staging area"
        COMMAND ${CMAKE_COMMAND} -E copy ${hdrfile} ${STAGE_DIR}/include/zookeeper/${file_name_only})
    endforeach()

    add_dependencies(zookeeper_build zookeeper_repo)
  endif()
endfunction(build_zookeeper)

########################################
# zookeeper
########################################
xpProOption(zookeeper)
set(ZK_REPO https://github.com/apache/zookeeper.git)
set(ZK_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo)
set(ZK_SRC_PATH ${ZK_REPO_PATH}/src/c/src)
set(ZK_INCLUDE_PATH ${ZK_REPO_PATH}/src/c/include)
set(ZK_INSTALL_PATH ${CMAKE_BINARY_DIR}/xpbase/Install/zookeeper)
set(ZK_VER "release-3.4.6")
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
set(CPP_UNIT_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/cppunit)
set(CPP_UNIT_VER 1.12.1)
set(CPP_UNIT
  NAME cppunit
  WEB "CppUnit" http://cppunit.sourceforge.net "CppUnit-C++ port of JUnit"
  LICENSE "LGPL" http://cppunit.sourceforge.net/doc/cvs "LGPL"
  DESC "C++ port of JUnit"
  VER ${CPP_UNIT_VER}
  DLURL http://sourceforge.net/projects/cppunit/files/cppunit/1.12.1/cppunit-1.12.1.tar.gz
  DLMD5 bd30e9cf5523cdfc019b94f5e1d7fd19
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
  if(NOT (XP_DEFAULT OR XP_PRO_ZOOKEEPER))
    return()
  endif()

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
      COMMAND ${GIT_EXECUTABLE} apply ${PATCH_DIR}/zookeeper-winport.c.patch
      COMMAND ${GIT_EXECUTABLE} apply ${PATCH_DIR}/zookeeper-winport.h.patch
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
# download cpp unit
macro(downloadCppUnit)
  xpNewDownload(${CPP_UNIT})
endmacro(downloadCppUnit)
########################################
# Some helper stuff to clean up the builds
macro(getZookeeperFiles)
  # Gather the zookeeper source files
  set(zookeeper_src_files
    ${ZK_SRC_PATH}/mt_adaptor.c
    ${ZK_SRC_PATH}/recordio.c
    ${ZK_SRC_PATH}/zk_hashtable.c
    ${ZK_SRC_PATH}/zk_log.c
    ${ZK_SRC_PATH}/zookeeper.c
    ${ZK_SRC_PATH}/hashtable/hashtable.c
    ${ZK_SRC_PATH}/hashtable/hashtable_itr.c
    ${ZK_SRC_PATH}/zookeeper.jute.c
    ${ZK_SRC_PATH}/zk_adaptor.h
    ${ZK_SRC_PATH}/zk_hashtable.h
    ${ZK_SRC_PATH}/hashtable/hashtable.h
    ${ZK_SRC_PATH}/hashtable/hashtable_itr.h
    ${ZK_SRC_PATH}/hashtable/hashtable_private.h
  )
  set(zookeeper_hdr_files
    ${ZK_INCLUDE_PATH}/proto.h
    ${ZK_INCLUDE_PATH}/recordio.h
    ${ZK_INCLUDE_PATH}/zookeeper.h
    ${ZK_INCLUDE_PATH}/zookeeper.jute.h
    ${ZK_INCLUDE_PATH}/zookeeper_log.h
    ${ZK_INCLUDE_PATH}/zookeeper_version.h
  )

  if(WIN32)
    list(APPEND zookeeper_src_files
      ${ZK_SRC_PATH}/winport.c
#      ${ZK_SRC_PATH}/gettimeofday.c
      )
    list(APPEND zookeeper_hdr_files
      ${ZK_SRC_PATH}/winport.h
      ${ZK_INCLUDE_PATH}/winconfig.h
      ${ZK_INCLUDE_PATH}/winstdint.h)
  else()
    list(APPEND zookeeper_hdr_files
      ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo/src/c/config.h)
  endif()

  # indicate that all the files are GENERATED so they don't need to exist when
  # creating the target...they will be available after download
  set_source_files_properties(${zookeeper_src_files} ${zookeeper_hdr_files}
    PROPERTIES GENERATED TRUE)
endmacro()
macro(setZookeeperTargetProperties target debug)
  set(lib_name zookeeper)

  if(${debug})
    set(lib_name ${lib_name}d)
  endif()

  if(WIN32)
    set(lib_name lib${lib_name}-mt)
  else()
    set(lib_name ${lib_name}-mt)
  endif()

  set_target_properties(${target} PROPERTIES
    OUTPUT_NAME ${lib_name}
    ARCHIVE_OUTPUT_DIRECTORY ${STAGE_DIR}/lib
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${STAGE_DIR}/lib
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${STAGE_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY ${STAGE_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ${STAGE_DIR}/lib
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${STAGE_DIR}/lib
    RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin
    RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin
    RUNTIME_OUTPUT_DIRECTORY ${STAGE_DIR}/bin)

  add_dependencies(${target} zookeeper_repo)
endmacro()
macro(setWindowsCompileOptions target debug)
  if(WIN32)
    if(${XP_BUILD_STATIC})
      if(${debug})
        target_compile_options(${target} PUBLIC "/MTd" "/Z7")
      else()
        target_compile_options(${target} PUBLIC "/MT")
      endif()
    else()
      if(${debug})
        target_compile_options(${target} PUBLIC "/MDd" "/Z7")
      else()
        target_compile_options(${target} PUBLIC "/MD")
      endif()
    endif()
  endif()
endmacro()
macro(zookeeperUnixConfiguration target)
  if(UNIX)
    if(NOT TARGET download_cppunit-1.12.1.tar.gz)
      downloadCppUnit()
    endif()

    if(NOT TARGET zookeeper_unzip_cppunit)
      add_custom_target(zookeeper_unzip_cppunit
        COMMENT "Unzipping cpp unit"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/xpbase/Source
        DEPENDS download_cppunit-${CPP_UNIT_VER}.tar.gz
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${DWNLD_DIR}/cppunit-${CPP_UNIT_VER}.tar.gz
      )
    endif()

    if(NOT TARGET zookeeper_configure)
      add_custom_target(zookeeper_configure
        COMMENT "Bootstrapping autoconf, automake, and libtool and configuring zookeeper"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo/src/c
        DEPENDS zookeeper_repo zookeeper_unzip_cppunit
        COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo ant compile_jute
        COMMAND ${CMAKE_COMMAND} -E env ACLOCAL=\"aclocal -I ${CMAKE_BINARY_DIR}/xpbase/Source/cppunit-${CPP_UNIT_VER}\" autoreconf -if
        COMMAND ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo/src/c/configure --without-cppunit
      )
    endif()

    target_include_directories(${target} PRIVATE ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo/src/c)
    add_dependencies(${target} zookeeper_configure)
  endif()
endmacro()
macro(createZookeeperBuildTargets)
  # Determine build type
  if(${XP_BUILD_STATIC})
    set(ZK_BUILD_TYPE STATIC)
  else()
    set(ZK_BUILD_TYPE SHARED)
  endif()

  # Create the release build
  add_library(zookeeper_build ${${ZK_BUILD_TYPE}}
              ${zookeeper_src_files} ${zookeeper_hdr_files})
  target_include_directories(zookeeper_build PUBLIC ${ZK_INCLUDE_PATH})
  setZookeeperTargetProperties(zookeeper_build 0)
  setWindowsCompileOptions(zookeeper_build 0)
  zookeeperUnixConfiguration(zookeeper_build)

  # Create the debug build
  if(${XP_BUILD_DEBUG})
    add_library(zookeeper_build_debug ${${ZK_BUILD_TYPE}}
                ${zookeeper_src_files} ${zookeeper_hdr_files})
    target_include_directories(zookeeper_build_debug PUBLIC ${ZK_INCLUDE_PATH})
    setZookeeperTargetProperties(zookeeper_build_debug 1)
    setWindowsCompileOptions(zookeeper_build_debug 1)
    zookeeperUnixConfiguration(zookeeper_build_debug)
  endif()
endmacro()
macro(installZookeeper)
  # Copy the include files to the staging directory
  foreach(hdrfile ${zookeeper_hdr_files})
    get_filename_component(file_name_only ${hdrfile} NAME)
    add_custom_command(TARGET zookeeper_build POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy ${hdrfile} ${STAGE_DIR}/include/zookeeper/${file_name_only})
  endforeach()

  # Copy the find package cmake file to the staging directory
  configure_file(${PRO_DIR}/use/useop-zookeeper-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-zookeeper-config.cmake
                 COPYONLY)
endmacro()
########################################
# build
function(build_zookeeper)
  if(NOT (XP_DEFAULT OR XP_PRO_ZOOKEEPER))
    return()
  endif()

  # Gather together all of the source files needed
  getZookeeperFiles()

  # Create the library targets
  createZookeeperBuildTargets()

  # Copy the header files and the use cmake to the staging area
  installZookeeper()

endfunction(build_zookeeper)

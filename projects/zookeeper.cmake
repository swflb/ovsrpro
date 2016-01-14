########################################
# zookeeper
# Note: Requires apache ant in the system path (http://ant.apache.org/)
# Note: Requires JDK in the system path
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

  ExternalProject_Add_Step(zookeeper_repo zookeeper_patch
    WORKING_DIRECTORY ${ZK_REPO_PATH}
    COMMAND ${GIT_EXECUTABLE} apply ${PATCH_DIR}/zookeeper-mt_adapter-x64-fix.patch
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper-winconfig.h ${ZK_REPO_PATH}/src/c/include/zookeeper-winconfig.h
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper.sln ${ZK_REPO_PATH}/src/c/zookeeper.sln
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper.vcxproj ${ZK_REPO_PATH}/src/c/zookeeper.vcxproj
    COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/zookeeper.vcxproj.filters ${ZK_REPO_PATH}/src/c/zookeeper.vcxproj.filters
    DEPENDEES patch
  )
  add_custom_target(zookeeper_ant ALL
    WORKING_DIRECTORY ${ZK_REPO_PATH}
    COMMAND ant compile_jute
    DEPENDS zookeeper_repo
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
  set(zookeeper_hdr_files
    ${ZK_INCLUDE_PATH}/proto.h
    ${ZK_INCLUDE_PATH}/recordio.h
    ${ZK_INCLUDE_PATH}/zookeeper.h
    ${ZK_INCLUDE_PATH}/zookeeper_log.h
    ${ZK_INCLUDE_PATH}/zookeeper_version.h
    ${ZK_REPO_PATH}/src/c/generated/zookeeper.jute.h
  )

  if(WIN32)
    list(APPEND zookeeper_hdr_files
      ${ZK_SRC_PATH}/winport.h
      ${ZK_INCLUDE_PATH}/winconfig.h
      ${ZK_INCLUDE_PATH}/winstdint.h)
  else()
    list(APPEND zookeeper_hdr_files
      ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper_repo/src/c/config.h)
  endif()
endmacro()
########################################
# build
function(build_zookeeper)
  if(NOT (XP_DEFAULT OR XP_PRO_ZOOKEEPER))
    return()
  endif()

  if(NOT TARGET zookeeper_repo)
    patch_zookeeper()
  endif()

  # Gather together all of the source files needed
  getZookeeperFiles()

  if(WIN32)
    add_custom_target(zookeeper_build ALL
      WORKING_DIRECTORY ${ZK_REPO_PATH}/src/c
      COMMAND msbuild ${ZK_REPO_PATH}/src/c/zookeeper.sln /p:Configuration=Release\;Platform=x64 /t:zookeeper:rebuild
      COMMAND msbuild ${ZK_REPO_PATH}/src/c/zookeeper.sln /p:Configuration=Debug\;Platform=x64 /t:zookeeper:rebuild
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/zookeeper
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy ${ZK_REPO_PATH}/src/c/x64/Debug/libzookeeperd-mt.lib ${STAGE_DIR}/lib/libzookeeperd-mt.lib
      COMMAND ${CMAKE_COMMAND} -E copy ${ZK_REPO_PATH}/src/c/x64/Release/libzookeeper-mt.lib ${STAGE_DIR}/lib/libzookeeper-mt.lib
      DEPENDS zookeeper_repo zookeeper_ant
    )

    foreach(hdr_file ${zookeeper_hdr_files})
      get_filename_component(hdr_name ${hdr_file} NAME)
      add_custom_command(TARGET zookeeper_build POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${hdr_file} ${STAGE_DIR}/include/zookeeper/${hdr_name}
      )
    endforeach()
  else()
    if(NOT TARGET download_cppunit-1.12.1.tar.gz)
      downloadCppUnit()
    endif()

    add_custom_target(zookeeper_configure
      WORKING_DIRECTORY ${ZK_REPO_PATH}/src/c
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${DWNLD_DIR}/cppunit-${CPP_UNIT_VER}.tar.gz
      COMMAND ${CMAKE_COMMAND} -E env ACLOCAL=\"aclocal -I ${ZK_REPO_PATH}/src/c/cppunit-${CPP_UNIT_VER}\" autoreconf -if -W none
      DEPENDS zookeeper_repo zookeeper_ant download_cppunit-${CPP_UNIT_VER}.tar.gz
    )
    add_custom_target(zookeeper_build ALL
      WORKING_DIRECTORY ${ZK_REPO_PATH}/src/c
      COMMAND ./configure --without-cppunit --prefix=${STAGE_DIR}
      COMMAND make
      COMMAND make install
      DEPENDS zookeeper_repo zookeeper_configure download_cppunit-${CPP_UNIT_VER}.tar.gz
    )
  endif()

endfunction(build_zookeeper)

########################################
# zookeeper
# Note: Requires apache ant in the system path (http://ant.apache.org/)
# Note: Requires JDK in the system path
# Note: Requres gnu32 for windows to use sed, find, and xargs (c:\program files(x86)\gnuwin32)
########################################
xpProOption(zookeeper)
set(ZK_REPO https://github.com/apache/zookeeper)
set(ZK_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/zookeeper)
set(ZK_SRC_PATH ${ZK_REPO_PATH}/src/c/src)
set(ZK_INSTALL_PATH ${CMAKE_BINARY_DIR}/xpbase/Install/zookeeper)
set(ZK_VER 3.6.2)
if(WIN32)
  set(ZOO_PATCH ${PATCH_DIR}/zookeeper-windows.patch)
else()
  set(ZOO_PATCH "${PATCH_DIR}/zookeeper.patch")
endif()
set(PRO_ZOOKEEPER
  NAME zookeeper
  WEB "Zookeeper" https://zookeeper.apache.org/ "Zookeeper - Home"
  LICENSE "open" http://www.apache.org/licenses/ "Apache V2.0"
  DESC "Apache ZooKeeper is an effort to develop and maintain an open-source server which enables highly reliable distributed coordination. -- [windows-only patch](../patches/zookeeper-windows.patch)"
  REPO "repo" ${ZK_REPO} "Zookeeper main repo"
  VER ${ZK_VER}
  GIT_ORIGIN ${ZK_REPO}
  GIT_TAG release-${ZK_VER}
  DLURL ${ZK_REPO}/archive/release-${ZK_VER}.tar.gz
  DLMD5 f9cce4a74d28784fa1774ceb8ec52bf1
  DLNAME zookeeper-release-${ZK_VER}.tar.gz
  PATCH ${ZOO_PATCH} #This is only defined for Windows builds
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
# Some helper stuff to clean up the builds
macro(zookeepercheckDependencies)
  find_program(javac javac)
  mark_as_advanced(javac)
  if(NOT javac)
    message(FATAL_ERROR "javac required for zookeeper")
  endif()

  if(XP_DEFAULT OR XP_PRO_ZOOKEEPER)
    find_package(Java REQUIRED COMPONENTS Development)
    find_program(mvn mvn)
    if(NOT mvn)
      message(FATAL_ERROR "Maven is required to build zookeeper.")
    endif()
  endif()

endmacro()
########################################
# build
function(build_zookeeper)
  if(NOT (XP_DEFAULT OR XP_PRO_ZOOKEEPER))
    return()
  endif()

  zookeeperCheckDependencies()

  configure_file(${PRO_DIR}/use/useop-zookeeper-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-zookeeper-config.cmake
                 COPYONLY)

  ExternalProject_Get_Property(zookeeper SOURCE_DIR)
  ExternalProject_Add(
    zookeeper_maven
    DEPENDS zookeeper
    DOWNLOAD_COMMAND ""
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND mvn --batch-mode clean compile -DskipTests
    BUILD_IN_SOURCE true
    INSTALL_COMMAND ""
  )
  set(
    cmake_options
    -DWANT_CPPUNIT:bool=off
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_INCLUDEDIR=include/zookeeper
    # This must be OFF (case sensitive) to disable OpenSSL.
    -DWITH_OPENSSL:STRING=OFF
    -DCMAKE_DEBUG_POSTFIX=d
  )
  xpCmakeBuild(zookeeper zookeeper_maven "${cmake_options}")
endfunction(build_zookeeper)

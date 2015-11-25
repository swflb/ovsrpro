xpProOption(librdkafka)
set(REPO https://github.com/smanders/librdkafka)
set(REPO_UPSTREAM https://github.com/edenhill/librdkafka)
set(VER 0.8.6)
set(PRO_LIBRDKAFKA
  NAME librdkafka
  WEB "librdkafka" http://kafka.apache.org "Apache Kafka website"
  LICENSE "open" ${REPO_UPSTREAM}/blob/${VER}/LICENSE "2-clause BSD license"
  DESC "Apache Kafka C/C++ client library"
  REPO "repo" ${REPO} "forked librdkafka repo on github"
  VER ${VER}
  GIT_ORIGIN git://github.com/smanders/librdkafka.git
  GIT_UPSTREAM git://github.com/edenhill/librdkafka.git
  #GIT_TAG xp${VER}
  #GIT_REF ${VER}
  GIT_TAG ${VER}
  DLURL ${REPO}/archive/${VER}.tar.gz
  DLMD5 1b77543f9be82d3f700c0ef98f494990
  DLNAME librdkafka-${VER}.tar.gz
  #PATCH ${PATCH_DIR}/librdkafka.patch
  DIFF ${REPO}/compare/edenhill:
  )
########################################
function(mkpatch_librdkafka)
  xpRepo(${PRO_LIBRDKAFKA})
endfunction()
########################################
function(download_librdkafka)
  xpNewDownload(${PRO_LIBRDKAFKA})
endfunction()
########################################
function(patch_librdkafka)
  xpPatch(${PRO_LIBRDKAFKA})
endfunction()
########################################
function(stringToList stringlist lvalue var)
  if(NOT "${stringlist}" STREQUAL "")
    string(STRIP ${stringlist} stringlist) # remove leading and trailing spaces
    string(REPLACE " -" ";-" listlist ${stringlist})
    foreach(item ${listlist})
      list(APPEND templist ${lvalue}=${item})
    endforeach()
    set(${var} "${templist}" PARENT_SCOPE)
  endif()
endfunction()
########################################
function(build_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()
  if(BUILD_WITH_CMAKE)
    if(NOT (XP_DEFAULT OR XP_PRO_ZLIB))
      message(FATAL_ERROR "librdkafka.cmake: requires zlib")
      return()
    endif()
    if(NOT DEFINED zlibTgts)
      build_zlib(zlibTgts)
    endif()
    configure_file(${PRO_DIR}/use/usexp-librdkafka-config.cmake ${STAGE_DIR}/share/cmake/
      @ONLY NEWLINE_STYLE LF
      )
    set(XP_CONFIGURE
      -DZLIB_MODULE_PATH=ON
      )
    xpCmakeBuild(librdkafka "${zlibTgts}" "${XP_CONFIGURE}")
  else() # BUILD_WITH_CONFIGURE
    xpBuildOnlyRelease()
    include(${MODULES_DIR}/flags.cmake) # populates CMAKE_*_FLAGS
    xpStringRemoveIfExists(CMAKE_CXX_FLAGS "-std=c++11")
    stringToList("${CMAKE_CXX_FLAGS}" "--CXXFLAGS" cxxflags)
    stringToList("${CMAKE_C_FLAGS}" "--CFLAGS" cflags)
    stringToList("${CMAKE_EXE_LINKER_FLAGS}" "--LDFLAGS" ldflags)
    set(XP_CONFIGURE_BASE <SOURCE_DIR>/configure ${cxxflags} ${cflags} ${ldflags}
      --prefix=${STAGE_DIR} --enable-static
      )
    set(XP_CONFIGURE_Debug ${XP_CONFIGURE_BASE})
    set(XP_CONFIGURE_Release ${XP_CONFIGURE_BASE})
    foreach(cfg ${BUILD_CONFIGS})
      set(XP_CONFIGURE_CMD ${XP_CONFIGURE_${cfg}})
      set(KAFKA_TARGET librdkafka_${cfg})
      addproject_kafka(${KAFKA_TARGET})
    endforeach() # cfg
  endif() # BUILD_WITH
endfunction()
########################################
macro(addproject_kafka XP_TARGET)
  if(XP_BUILD_VERBOSE)
    message(STATUS "target ${XP_TARGET}")
    xpVerboseListing("[CONFIGURE]" "${XP_CONFIGURE_CMD}")
  else()
    message(STATUS "target ${XP_TARGET}")
  endif()
  ExternalProject_Get_Property(librdkafka SOURCE_DIR)
  ExternalProject_Add(${XP_TARGET} DEPENDS librdkafka
    DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
    SOURCE_DIR ${SOURCE_DIR}
    CONFIGURE_COMMAND ${XP_CONFIGURE_CMD}
    BUILD_COMMAND   # use default
    BUILD_IN_SOURCE 1 # <BINARY_DIR>==<SOURCE_DIR>
    INSTALL_COMMAND # use default
    )
  set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
endmacro()

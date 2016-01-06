#######################################
# Postgresql
#######################################
xpProOption(psql)
#######################################
# setup some pathing variables
set(PSQL_DOWNLOAD_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/psql)
set(PSQL_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/psql)
#######################################
# setup the postgres sql download
set(PRO_PSQL
  NAME psql
  WEB "PostgreSQL" http://www.postgresql.org/ "PostgreSQL"
  LICENSE "" "" ""
  DESC "PostgreSQL redistributable binaries"
  VER 9.4.5
  GIT_ORIGIN https://github.com/postgres/postgres.git
  GIT_TAG REL9_4_5
  DLURL https://ftp.postgresql.org/pub/source/v9.4.5/postgresql-9.4.5.tar.gz
  DLMD5 1ae5b653dfb5d88ce237b865c7d3d1cd
)
#######################################
function(mkpatch_psql)
  xpRepo(${PRO_PSQL})
endfunction()
#######################################
function(download_psql)
  xpNewDownload(${PRO_PSQL})
endfunction()
#######################################
function(patch_psql)
  xpPatch(${PRO_PSQL})

  if(${XP_BUILD_STATIC})
    ExternalProject_Add_Step(psql updateToStatic
      COMMENT "Replacing win32.mak file to enable /MT compiler flag"
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/psql-win32-static.mak ${PSQL_REPO_PATH}/src/interfaces/libpq/win32.mak
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/psql-win32-top-level-static.mak ${PSQL_REPO_PATH}/src/win32.mak
      DEPENDEES download
    )
  endif()
endfunction()
#######################################
function(build_psql)
  if(NOT (XP_DEFAULT OR XP_PRO_PSQL))
    return()
  endif()
  if(TARGET psql_build)
    return()
  endif()

  # Make sure the psql download is available...
  if(NOT TARGET psql)
    patch_psql()
  endif()

  xpFindPkg(PKGS openssl)

  if(WIN32)
    add_custom_target(psql_build ALL
      COMMENT "Configuring and building psql"
      WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
      COMMAND nmake /f win32.mak CPU=AMD64 SSL_INC=${OPENSSL_INCLUDE_DIR} SSL_LIB_PATH=${XP_ROOTDIR}/lib LIB_ONLY
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/Release/libpq.lib ${STAGE_DIR}/lib/libpq.lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${PSQL_REPO_PATH}/src/include ${STAGE_DIR}/include/psql
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/pg_config_paths.h ${STAGE_DIR}/include/psql/pg_config_paths.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/fe-auth.h ${STAGE_DIR}/include/psql/fe-auth.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-events.h ${STAGE_DIR}/include/psql/libpq-events.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-fe.h ${STAGE_DIR}/include/psql/libpq-fe.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-int.h ${STAGE_DIR}/include/psql/libpq-int.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/pqexpbuffer.h ${STAGE_DIR}/include/psql/pqexpbuffer.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/win32.h ${STAGE_DIR}/include/psql/win32.h
      DEPENDS psql
    )

    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET psql_build POST_BUILD
        COMMENT "Build psql - debug"
        WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
        COMMAND nmake /f win32.mak CPU=AMD64 SSL_INC=${OPENSSL_INCLUDE_DIR} SSL_LIB_PATH=${XP_ROOTDIR}/lib DEBUG=1 LIB_ONLY
        COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/Debug/libpqd.lib ${STAGE_DIR}/lib/libpqd.lib
      )
    endif()
  else()
    add_custom_target(psql_build ALL
      COMMENT "Configuring and building psql"
      WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
      COMMAND ./configure --libdir=${STAGE_DIR}/LIBRARY_OUTPUT_DIRECTORY --includedir ${STAGE_DIR}/include/psql
      COMMAND make -j5
      COMMAND make install
    )
  endif()

  # Just move the psql download to the staging directory
#  add_custom_target(psql_build ALL
#    COMMENT "Copying psql download and use file to staging area"
#    COMMAND ${CMAKE_COMMAND} -E copy_directory ${PSQL_DOWNLOAD_PATH} ${STAGE_DIR}/psql
#    COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-psql-config.cmake ${STAGE_DIR}/share/cmake
#    DEPENDS psql
#  )
endfunction()

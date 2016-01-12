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
  if(NOT (XP_DEFULAT OR XP_PRO_PSQL))
    return()
  endif()

  xpPatch(${PRO_PSQL})

  if(WIN32)
    if(${XP_BUILD_STATIC})
      ExternalProject_Add_Step(psql updateToStatic
        COMMENT "Replacing win32.mak file to enable /MT compiler flag"
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/psql-win32-static.mak ${PSQL_REPO_PATH}/src/interfaces/libpq/win32.mak
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/psql-win32-top-level-static.mak ${PSQL_REPO_PATH}/src/win32.mak
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/psql-win32error-static_patch.c ${PSQL_REPO_PATH}/src/port/win32error.c
        DEPENDEES download
      )
    endif()
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
    set(lib_path ${PSQL_REPO_PATH}/src/interfaces/libpq/Release/libpq.lib)
    add_custom_target(psql_build ALL
      COMMENT "Configuring and building psql"
      WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
      COMMAND nmake /f win32.mak CPU=AMD64 SSL_INC=${OPENSSL_INCLUDE_DIR} SSL_LIB_PATH=${XP_ROOTDIR}/lib LIB_ONLY
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${PSQL_REPO_PATH}/src/include ${STAGE_DIR}/include/psql
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/pg_config_paths.h ${STAGE_DIR}/include/psql/pg_config_paths.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/fe-auth.h ${STAGE_DIR}/include/psql/fe-auth.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-events.h ${STAGE_DIR}/include/psql/libpq-events.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-fe.h ${STAGE_DIR}/include/psql/libpq-fe.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/libpq-int.h ${STAGE_DIR}/include/psql/libpq-int.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/pqexpbuffer.h ${STAGE_DIR}/include/psql/pqexpbuffer.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/win32.h ${STAGE_DIR}/include/psql/win32.h
      COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-psql-config.cmake ${STAGE_DIR}/share/cmake/useop-psql-config.cmake
      DEPENDS psql
    )

    if(${XP_BUILD_STATIC})
      # add the windows Secur32.lib to the static library
      add_custom_command(TARGET psql_build POST_BUILD
        WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
        COMMAND lib /out:${STAGE_DIR}/lib/libpq.lib ${lib_path} Secur32.lib
      )
    else()
      add_custom_command(TARGET psql_build POST_BUILD
        WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
        COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/Release/libpq.lib ${STAGE_DIR}/lib/libpq.lib
      )
    endif()

    if(${XP_BUILD_DEBUG})
      add_custom_command(TARGET psql_build POST_BUILD
        COMMENT "Build psql - debug"
        WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
        COMMAND nmake /f win32.mak CPU=AMD64 SSL_INC=${OPENSSL_INCLUDE_DIR} SSL_LIB_PATH=${XP_ROOTDIR}/lib DEBUG=1 LIB_ONLY
        COMMAND ${CMAKE_COMMAND} -E copy ${PSQL_REPO_PATH}/src/interfaces/libpq/Debug/libpqd.lib ${STAGE_DIR}/lib/libpqd.lib
      )

      set(lib_path ${PSQL_REPO_PATH}/src/interfaces/libpq/Debug/libpqd.lib)
      if(${XP_BUILD_STATIC})
        # add the windows Secur32.lib to the static library
        add_custom_command(TARGET psql_build POST_BUILD
          WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
          COMMAND lib /out:${STAGE_DIR}/lib/libpqd.lib ${lib_path} Secur32.lib
        )
      else()
        add_custom_command(TARGET psql_build POST_BUILD
          WORKING_DIRECTORY ${PSQL_REPO_PATH}/src
          COMMAND ${CMAKE_COMMAND} -E copy ${lib_path} ${STAGE_DIR}/lib/libpqd.lib
        )
      endif()
    endif()
  else()
    add_custom_target(psql_build ALL
      COMMENT "Configuring and building psql"
      WORKING_DIRECTORY ${PSQL_REPO_PATH}
      COMMAND ./configure --prefix=${STAGE_DIR}/psql --libdir=${STAGE_DIR}/lib --includedir ${STAGE_DIR}/include/psql --without-readline --with-openssl
      COMMAND make -j5
      COMMAND make -C src/bin install
      COMMAND make -C src/include install
      COMMAND make -C src/interfaces install
      DEPENDS psql
    )
  endif()
endfunction()

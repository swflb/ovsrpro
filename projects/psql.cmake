#######################################
# Postgresql
#######################################
xpProOption(psql)
#######################################
# setup some pathing variables
set(PSQL_DOWNLOAD_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/psql)
#######################################
# setup the postgres sql download
if(WIN32)
  set(PSQL_DOWNLOAD_URL "http://get.enterprisedb.com/postgresql/postgresql-9.4.5-3-windows-x64-binaries.zip")
  set(PSQL_MD5 fb38a056f0dd30fff46757909fac3c41)
else()
  set(PSQL_DOWNLOAD_URL "http://get.enterprisedb.com/postgresql/postgresql-9.4.5-3-linux-x64-binaries.tar.gz")
  set(PSQL_MD5 a26e9f1cd1203de6d2f2d73ec3de935c)
endif()
set(PRO_PSQL
  NAME psql
  WEB "PostgreSQL" http://www.postgresql.org/ "PostgreSQL"
  LICENSE "" "" ""
  DESC "PostgreSQL redistributable binaries"
  VER 9.4.5.3
  DLURL ${PSQL_DOWNLOAD_URL}
  DLMD5 ${PSQL_MD5}
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

  # Just move the psql download to the staging directory
  add_custom_target(psql_build ALL
    COMMENT "Copying psql download and use file to staging area"
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${PSQL_DOWNLOAD_PATH} ${STAGE_DIR}/psql
    COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-psql-config.cmake ${STAGE_DIR}/share/cmake
    DEPENDS psql
  )
endfunction()

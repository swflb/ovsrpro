#######################################
# kerberos
# NOTE: Requires GnuWin32 in C:\program Files (x86)\GnuWin32
# NOTE: Requires Perl64 in C:\Perl64\
#######################################
xpProOption(kerberos)
#######################################
# setup some pathing variables
set(KERBEROS_DOWNLOAD_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/kerberos)
if(WIN32)
  set(KERBEROS_DL_URL http://web.mit.edu/kerberos/dist/kfw/4.0/kfw-4.0.1-src.zip)
  set(KERBEROS_DL_MD5 6d58ca865beb5b5c145dc4f579753d33)
else()
  set(KERBEROS_DL_URL http://web.mit.edu/kerberos/dist/krb5/1.12/krb5-1.12.5.tar.gz)
  set(KERBEROS_DL_MD5 d38d4592aeca049e1e1a0a7f0cd97aef)
endif()
#######################################
set(PRO_KERBEROS
  NAME kerberos
  WEB "Kerberos" http://web.mit.edu/kerberos/ "Kerberos"
  LICENSE "" "" ""
  DESC "Kerberos is a network authentication protocol"
  VER 4.0.1
  DLURL ${KERBEROS_DL_URL}
  DLMD5 ${KERBEROS_DL_MD5}
)
#######################################
function(mkpatch_kerberos)
  xpRepo(${PRO_KERBEROS})
endfunction()
#######################################
function(download_kerberos)
  xpNewDownload(${PRO_KERBEROS})
endfunction()
#######################################
function(patch_kerberos)
  xpPatch(${PRO_KERBEROS})

  if(WIN32)
    ExternalProject_Add_Step(kerberos kerberos_windows_minimal_patch
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}
      COMMENT "Applying kerberos minimal patch"
      # eliminate executables that we won't ever need for linking etc.
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-minimal-Makefile.in ${KERBEROS_DOWNLOAD_PATH}/src/Makefile.in
      # fix the install script due to theh parts we removed
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-Makefile.in ${KERBEROS_DOWNLOAD_PATH}/src/windows/Makefile.in
      # fix libecho to work on 64 bit...
      COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-libecho.c ${KERBEROS_DOWNLOAD_PATH}/src/util/windows/libecho.c
      DEPENDEES download
    )

    if(${XP_BUILD_STATIC})
      ExternalProject_Add_Step(kerberos kerberos_windows_static_patch
        WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}
        COMMENT "Updating kerberos to /MT flags"
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/kerberos-windows-static-win-pre.in ${KERBEROS_DOWNLOAD_PATH}/src/config/win-pre.in
        DEPENDEES download
      )
    endif()
  endif()
endfunction()
#######################################
function(build_kerberos)
  if(NOT (XP_DEFAULT OR XP_PRO_KERBEROS))
    return()
  endif()

  if(NOT TARGET kerberos)
    patch_kerberos()
  endif()

  if(WIN32)
    if(${XP_BUILD_DEBUG})
      set(NODEBUG 0)
    else()
      set(NODEBUG 1)
    endif()

    set(ADD_TO_PATH "C:\\Program Files (x86)\\GnuWin32\\bin\;C:\\Perl64\\bin\;")

    if(${XP_BUILD_STATIC})
      opSetWindowsStaticFlags(/MT)
    endif()

    add_custom_target(kerberos_build ALL
      COMMENT "Building kerberos"
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}/src
      # build the 64 bit libraries
      COMMAND set PATH=%PATH%\;${ADD_TO_PATH}
      COMMAND nmake clean
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/kerberos
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake -f Makefile.in prep-windows
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos CL=/D_XKEYCHECK_H=1 nmake NODEBUG=${NODEBUG}
      COMMAND ${CMAKE_COMMAND} -E env CPU=AMD64 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake install NODEBUG=${NODEBUG}
      DEPENDS kerberos
    )

    set(SIMPLE_PATH "C:\\windows\\system32\;C:\\windows\;C:\\windows\\System32\\Wbem\;")
    # for a 32-bit build, do something like this...
    add_custom_target(kerberos_x86
      COMMENT "Building x86 kerberos"
      # Setup the environment for x86 as the generator should have used amd64
      WORKING_DIRECTORY ${KERBEROS_DOWNLOAD_PATH}/src
      COMMAND set PATH=${SIMPLE_PATH}\;${ADD_TO_PATH}
      COMMAND set INCLUDE=
      COMMAND set LIB=
      COMMAND set LIBPATH=
      COMMAND CALL "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\vcvarsall.bat" x86
      COMMAND echo after: %PATH%
      # Configure/build/install
      COMMAND nmake clean
      COMMAND ${CMAKE_COMMAND} -E env CPU=i386 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake -f Makefile.in prep-windows
      COMMAND ${CMAKE_COMMAND} -E env CPU=i386 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos CL=/D_XKEYCHECK_H=1 nmake NODEBUG=${NODEBUG}
      COMMAND ${CMAKE_COMMAND} -E env CPU=i386 KRB_INSTALL_DIR=${STAGE_DIR}/kerberos nmake install NODEBUG=${NODEBUG}
      DEPENDS kerberos
    )
  endif()
endfunction()

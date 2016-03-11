########################################
# qwt
########################################
xpProOption(qwt)
########################################
set(QWT_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/qwt)
if(WIN32)
  set(QWT_DL_URL https://sourceforge.net/projects/qwt/files/qwt/6.1.2/qwt-6.1.2.zip/download)
  set(QWT_DL_MD5 b43a4e93c59b09fa3eb60b2406b4b37f)
else()
  set(QWT_DL_URL https://sourceforge.net/projects/qwt/files/qwt/6.1.2/qwt-6.1.2.tar.bz2/download)
  set(QWT_DL_MD5 9c88db1774fa7e3045af063bbde44d7d)
endif()

set(PRO_QWT
  NAME qwt
  WEB "Qwt" http://http://qwt.sourceforge.net/ "Qwt - Qt Widgets for Technical Applications"
  LICENSE "LGPL" http://qwt.sourceforge.net/qwtlicense.html "LGPL with exceptions"
  DESC "The Qwt library contains GUI Components and utility classes which are primarily useful for programs with a technical background."
  VER 6.1.2
  DLURL ${QWT_DL_URL}
  DLMD5 ${QWT_DL_MD5}
  PATCH ${PATCH_DIR}/qwtconfig.pri.patch  
)
########################################
function(mkpatch_qwt)
  xpRepo(${PRO_QWT})
endfunction()
########################################
function(download_qwt)
  xpNewDownload(${PRO_QWT})
endfunction()
########################################
function(patch_qwt)
  if(NOT (XP_DEFAULT OR XP_PRO_QWT))
    return()
  endif()

  xpPatch(${PRO_QWT})
endfunction()
########################################
function(build_qwt)
  if(NOT (XP_DEFAULT OR XP_PRO_QWT))
    return()
  endif()

  if(NOT TARGET qwt)
    patch_qwt()
  endif()

  # Make sure the qt5 target this depends on has been created
  if(NOT (XP_DEFAULT OR XP_PRO_QT5))
    message(FATAL_ERROR "qwt requires qt5")
    return()
  endif()

  if(${XP_BUILD_STATIC})
    add_custom_target(qwt_configure ALL
      WORKING_DIRECTORY ${QWT_SRC_PATH}
      # Invoke qmake from the QT5 that was just built
      COMMAND ${STAGE_DIR}/qt5/bin/qmake qwt.pro "INSTALL_PATH=${STAGE_DIR}" "STATIC_BUILD=true"
      DEPENDS qwt qt5_build
    )
  else()
    add_custom_target(qwt_configure ALL
      WORKING_DIRECTORY ${QWT_SRC_PATH}
      # Invoke qmake from the QT5 that was just built
      COMMAND ${STAGE_DIR}/qt5/bin/qmake qwt.pro "INSTALL_PATH=${STAGE_DIR}" "STATIC_BUILD=false"
      DEPENDS qwt qt5_build
    )
  endif()

  # Haven't tested building on windows but this *should* work...
  if(WIN32)
    add_custom_target(qwt_build ALL
      WORKING_DIRECTORY ${QWT_SRC_PATH}
      COMMAND nmake
      COMMAND nmake install
      DEPENDS qwt qwt_configure qt5_build
    )
  else()
    add_custom_target(qwt_build ALL
      WORKING_DIRECTORY ${QWT_SRC_PATH}
      COMMAND make
      COMMAND make install
      DEPENDS qwt qwt_configure qt5_build
    ) 
  endif()

  # Copy LICENSE file to STAGE_DIR
  add_custom_command(TARGET qwt_build POST_BUILD
    WORKING_DIRECTORY ${QWT_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/qwt
    COMMAND ${CMAKE_COMMAND} -E copy ${QWT_SRC_PATH}/COPYING ${STAGE_DIR}/share/qwt
  )

  configure_file(${PRO_DIR}/use/useop-qwt-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-qwt-config.cmake
                 COPYONLY)
endfunction()

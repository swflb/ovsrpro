########################################
# hdf5
########################################
xpProOption(hdf5)
set(HDF5_SRC_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/hdf5)
if(WIN32)
  set(HDF5_DLURL http://www.hdfgroup.org/ftp/HDF5/current/src/CMake-hdf5-1.8.16.zip)
  set(HDF5_DLMD5 f909d87f2a913d9ec6a970c1063f907b)
else()
  set(HDF5_DLURL http://www.hdfgroup.org/ftp/HDF5/current/src/CMake-hdf5-1.8.16.tar.gz)
  set(HDF5_DLMD5 a7559a329dfe74e2dac7d5e2d224b1c2)
endif()
set(PRO_HDF5
  NAME hdf5
  WEB "HDF GROUP" http://www.hdfgroup.org "The HDF Group"
  LICENSE "" "" ""
  DESC "HDF5 is a data model, library, and file format for storing and managing data"
  VER 1.8.16
  DLURL ${HDF5_DLURL}
  DLMD5 ${HDF5_DLMD5}
)
########################################
function(mkpatch_hdf5)
  xpRepo(${PRO_HDF5})
endfunction()
########################################
function(download_hdf5)
  xpNewDownload(${PRO_HDF5})
endfunction()
########################################
function(patch_hdf5)
  if(NOT (XP_DEFAULT OR XP_PRO_HDF5))
    return()
  endif()

  xpPatch(${PRO_HDF5})

  if(WIN32)
    if(${XP_BUILD_STATIC})
      ExternalProject_Add_Step(hdf5 hdf5_setFlags
        WORKING_DIRECTORY ${HDF5_SRC_PATH}
        # Update hdf5 to use /MT
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${HDF5_SRC_PATH}/hdf5-1.8.16/UserMacros.cmake
        # Decompress SZip, update to use /MT, then re-zip
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${HDF5_SRC_PATH}/SZip.tar.gz
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${HDF5_SRC_PATH}/SZip/UserMacros.cmake
        COMMAND ${CMAKE_COMMAND} -E tar cfvz ${HDF5_SRC_PATH}/SZip.tar.gz ${HDF5_SRC_PATH}/SZip
        # Decompress ZLib, update to use /MT, then re-zip
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${HDF5_SRC_PATH}/ZLib.tar.gz
        COMMAND ${CMAKE_COMMAND} -E copy ${PATCH_DIR}/hdf5-windows-static-UserMacros.cmake ${HDF5_SRC_PATH}/ZLib/UserMacros.cmake
        COMMAND ${CMAKE_COMMAND} -E tar cfvz ${HDF5_SRC_PATH}/ZLib.tar.gz ${HDF5_SRC_PATH}/ZLib
        DEPENDEES download
      )
    endif()
  endif()
endfunction()
########################################
function(build_hdf5)
  if (NOT (XP_DEFAULT OR XP_PRO_HDF5))
    return()
  endif()

  if(NOT TARGET hdf5)
    patch_hdf5()
  endif()

  if(WIN32)
    set(generator VS201364)
    set(ZIP_NAME HDF5-1.8.16-win64)
    set(ZIP_EXT zip)
    set(BASE_INSTALL_PATH ${ZIP_NAME})
  else()
    set(generator Unix)
    set(ZIP_NAME HDF5-1.8.16-Linux)
    set(ZIP_EXT tar.gz)
    set(BASE_INSTALL_PATH ${ZIP_NAME}/HDF_Group/HDF5/1.8.16)
  endif()

  # Build hdf5
  add_custom_target(hdf5_build ALL
    WORKING_DIRECTORY ${HDF5_SRC_PATH}
    COMMAND ctest -S HDF518config.cmake,BUILD_GENERATOR=${generator},INSTALLDIR=${STAGE_DIR}/hdf5,CTEST_BUILD_CONFIGURATION=Release -C Release -V
    DEPENDS hdf5
  )

  add_custom_command(TARGET hdf5_build POST_BUILD
    WORKING_DIRECTORY ${HDF5_SRC_PATH}
    # Unzip the install folder
    COMMAND ${CMAKE_COMMAND} -E tar xvf ${ZIP_NAME}.${ZIP_EXT}
    # Move the files where they're needed
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/hdf5
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/include ${STAGE_DIR}/include/hdf5
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/bin ${STAGE_DIR}/bin
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/lib ${STAGE_DIR}/lib
  )

  # build the debug version of hdf5
  if(${XP_BUILD_DEBUG})
    add_custom_target(hdf5_build_debug ALL
      WORKING_DIRECTORY ${HDF5_SRC_PATH}
      COMMAND ctest -S HDF518config.cmake,BUILD_GENERATOR=${generator},INSTALLDIR=${STAGE_DIR}/hdf5,CTEST_BUILD_CONFIGURATION=Debug -C Debug -V
      DEPENDS hdf5
    )
    add_custom_command(TARGET hdf5_build_debug POST_BUILD
      WORKING_DIRECTORY ${HDF5_SRC_PATH}
      # Unzip the install folder
      COMMAND ${CMAKE_COMMAND} -E tar xvf ${ZIP_NAME}.${ZIP_EXT}
      # Move the files where they're needed
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/include/hdf5
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/include ${STAGE_DIR}/include/hdf5
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/bin ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${BASE_INSTALL_PATH}/lib ${STAGE_DIR}/lib
    )
  endif()

  # Copy COPYING and RELEASE.txt from the hdf5 install share folder to STAGE_DIR
  add_custom_command(TARGET hdf5_build POST_BUILD
    WORKING_DIRECTORY ${HDF5_SRC_PATH}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/share/hdf5
    COMMAND ${CMAKE_COMMAND} -E copy ${BASE_INSTALL_PATH}/share/COPYING ${STAGE_DIR}/share/hdf5
    COMMAND ${CMAKE_COMMAND} -E copy ${BASE_INSTALL_PATH}/share/RELEASE.txt ${STAGE_DIR}/share/hdf5
  )

  configure_file(${PRO_DIR}/use/useop-hdf5-config.cmake
                 ${STAGE_DIR}/share/cmake/useop-hdf5-config.cmake
                 COPYONLY)
endfunction()

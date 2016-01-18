########################################################
#  Include file for user options
########################################################

#-----------------------------------------------------------------------------
#------------------- E X A M P L E   B E G I N--------------------------------
#-----------------------------------------------------------------------------
# Option to Build with User Defined Values
#-----------------------------------------------------------------------------
MACRO (MACRO_USER_DEFINED_LIBS)
  set (USER_DEFINED_VALUE "FALSE")
ENDMACRO (MACRO_USER_DEFINED_LIBS)

#-------------------------------------------------------------------------------
option (BUILD_USER_DEFINED_LIBS "Build With User Defined Values" OFF)
if (BUILD_USER_DEFINED_LIBS)
  MACRO_USER_DEFINED_LIBS ()
endif (BUILD_USER_DEFINED_LIBS)
#-----------------------------------------------------------------------------
#------------------- E X A M P L E   E N D -----------------------------------
#-----------------------------------------------------------------------------

MACRO (TARGET_STATIC_CRT_FLAGS)
  if (MSVC AND NOT BUILD_SHARED_LIBS)
    foreach (flag_var
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      if (${flag_var} MATCHES "/MD")
        string (REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
      endif (${flag_var} MATCHES "/MD")
      if (${flag_var} MATCHES "/Zi")
        string (REGEX REPLACE "/Zi" "/Z7" ${flag_var} "${${flag_var}}")
      endif()
    endforeach (flag_var)
    foreach (flag_var
        CMAKE_Fortran_FLAGS CMAKE_Fortran_FLAGS_DEBUG CMAKE_Fortran_FLAGS_RELEASE
        CMAKE_Fortran_FLAGS_MINSIZEREL CMAKE_Fortran_FLAGS_RELWITHDEBINFO)
      if (${flag_var} MATCHES "/libs:dll")
        string (REGEX REPLACE "/libs:dll" "/libs:static" ${flag_var} "${${flag_var}}")
      endif (${flag_var} MATCHES "/libs:dll")
    endforeach (flag_var)
    set (WIN_COMPILE_FLAGS "")
    set (WIN_LINK_FLAGS "/NODEFAULTLIB:MSVCRT")
  endif (MSVC AND NOT BUILD_SHARED_LIBS)
ENDMACRO (TARGET_STATIC_CRT_FLAGS)

#-----------------------------------------------------------------------------
option (BUILD_STATIC_CRT_LIBS "Build With Static CRT Libraries" ON)
message("CRT: ${BUILD_STATIC_CRT_LIBS}")
if (BUILD_STATIC_CRT_LIBS)
  TARGET_STATIC_CRT_FLAGS ()
endif (BUILD_STATIC_CRT_LIBS)

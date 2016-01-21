# Get the path to the overseer pro install
get_filename_component(OP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(OP_ROOTDIR ${OP_ROOTDIR} ABSOLUTE)

unset(GLEW_INCLUDE_DIR CACHE)
unset(GLEW_LIBRARY_DIR CACHE)

set(GLEW_INCLUDE_DIR ${OP_ROOTDIR}/include/GL)
set(GLEW_LIB_DIR ${OP_ROOTDIR}/lib)

string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)

if(WIN32)
  add_definitions(/DGLEW_STATIC=1)
  if(${build_type} STREQUAL debug)
    set(GLEW_LIB ${GLEW_LIB_DIR}/glew32sd.lib)
  else()
    set(GLEW_LIB ${GLEW_LIB_DIR}/glew32s.lib)
  endif()
else()
  if(${build_type} STREQUAL debug)
    set(GLEW_LIB ${GLEW_LIB_DIR}/libGLEW.a)
  else()
    set(GLEW_LIB ${GLEW_LIB_DIR}/libGLEWd.a)
  endif()
endif()

include_directories(SYSTEM ${GLEW_INCLUDE_DIR})

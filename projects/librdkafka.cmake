########################################
# qt5
########################################
xpProOption(librdkafka)
set(KAFKA_VER 0.9.0)
set(KAFKA_REPO https://github.com/edenhill/librdkafka)
set(KAFKA_REPO_PATH ${CMAKE_BINARY_DIR}/xpbase/Source/librdkafka_repo)
set(PRO_KAFKA
  NAME librdkafka
  WEB "librdkafk" https://github.com/edenhill/librdkafka "librdkafka"
  LICENSE "bsd2" https://github.com/edenhill/librdkafka "BSD2"
  DESC "librdkafka is a C library implementation of the Apache Kafka protocol, containing both Producer and Consumer support"
  REPO "repo" ${KAFKA_REPO}
  VER ${KAFKA_VER}
  GIT_ORIGIN ${KAFKA_REPO}
  GIT_TAG ${KAFKA_VER}
)
########################################
# mkpatch_librdkafka
function(mkpatch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpRepo(${PRO_KAFKA})
endfunction(mkpatch_librdkafka)
########################################
# download
function(download_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  xpRepo(${PRO_KAFKA})
endfunction(download_librdkafka)
########################################
# patch
function(patch_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  if(NOT TARGET librdkafka_repo)
    xpRepo(${PRO_KAFKA})
  endif()
endfunction(patch_librdkafka)
########################################
# Add zlib to the desired target
macro(addLibs target)
  if(WIN32)
    message("adding libs to ${target}")
    target_link_libraries(${target}
      ${XP_ROOTDIR}/lib/zlibstatic-s.lib
      ${XP_ROOTDIR}/lib/crypto-s.lib
      ${XP_ROOTDIR}/lib/ssl-s.lib)
  endif()
endmacro()
########################################
# build
function(build_librdkafka)
  if(NOT (XP_DEFAULT OR XP_PRO_LIBRDKAFKA))
    return()
  endif()

  # Make sure the librdkafka target this depends on has been created
  if(NOT TARGET librdkafka)
    patch_librdkafka()
  endif()

  if(UNIX)
    add_custom_target(librdkafka_build
      COMMENT "Configuring and building librdkafka"
      WORKING_DIRECTORY ${KAFKA_REPO_PATH}
      COMMAND ./configure --prefix ${STAGE_DIR}/
      COMMAND make
      COMMAND make install
      COMMAND ${CMAKE_COMMAND} -E copy ${PRO_DIR}/use/useop-librdkafka-config.cmake ${STAGE_DIR}/share/cmake/useop-librdkafka-config.cmake
      DEPENDS librdkafka_repo
    )
    return()    
  endif()

  # define the src files
  set(c_files
    ${KAFKA_REPO_PATH}/src/rdkafka.c
    ${KAFKA_REPO_PATH}/src/rdkafka_broker.c
    ${KAFKA_REPO_PATH}/src/rdkafka_msg.c
    ${KAFKA_REPO_PATH}/src/rdkafka_topic.c
    ${KAFKA_REPO_PATH}/src/rdkafka_conf.c
    ${KAFKA_REPO_PATH}/src/rdkafka_timer.c
    ${KAFKA_REPO_PATH}/src/rdkafka_offset.c
    ${KAFKA_REPO_PATH}/src/rdkafka_transport.c
    ${KAFKA_REPO_PATH}/src/rdkafka_buf.c
    ${KAFKA_REPO_PATH}/src/rdkafka_queue.c
    ${KAFKA_REPO_PATH}/src/rdkafka_op.c
    ${KAFKA_REPO_PATH}/src/rdkafka_request.c
    ${KAFKA_REPO_PATH}/src/rdkafka_cgrp.c
    ${KAFKA_REPO_PATH}/src/rdkafka_pattern.c
    ${KAFKA_REPO_PATH}/src/rdkafka_partition.c
    ${KAFKA_REPO_PATH}/src/rdkafka_subscription.c
    ${KAFKA_REPO_PATH}/src/rdkafka_assignor.c
    ${KAFKA_REPO_PATH}/src/rdkafka_range_assignor.c
    ${KAFKA_REPO_PATH}/src/rdkafka_roundrobin_assignor.c
    ${KAFKA_REPO_PATH}/src/rdcrc32.c
    ${KAFKA_REPO_PATH}/src/rdgz.c
    ${KAFKA_REPO_PATH}/src/rdaddr.c
    ${KAFKA_REPO_PATH}/src/rdrand.c
    ${KAFKA_REPO_PATH}/src/rdlist.c
    ${KAFKA_REPO_PATH}/src/tinycthread.c
    ${KAFKA_REPO_PATH}/src/rdlog.c
    ${KAFKA_REPO_PATH}/src/trex.c
  )
  set(cpp_files
    ${KAFKA_REPO_PATH}/src-cpp/RdKafka.cpp
    ${KAFKA_REPO_PATH}/src-cpp/ConfImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/HandleImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/ConsumerImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/ProducerImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/KafkaConsumerImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/TopicImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/TopicPartitionImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/MessageImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/QueueImpl.cpp
    ${KAFKA_REPO_PATH}/src-cpp/MetadataImpl.cpp
  )

  # define the header files
  set(hdr_files
    ${KAFKA_REPO_PATH}/src/rdkafka.h
    ${KAFKA_REPO_PATH}/src-cpp/rdkafkacpp.h
  )

  xpFindPkg(PKGS zlib)
  include_directories(SYSTEM ${ZLIB_INCLUDE_DIRS})

  # indicate that all the files are GENERATED so they don't need to exist when
  # creating the target...they will be available after download
  set_source_files_properties(${c_files} ${cpp_files} ${hdr_files}
    PROPERTIES GENERATED TRUE)

  # Create the c dll
  add_library(librdkafka-shared SHARED ${c_files})
  add_dependencies(librdkafka-shared librdkafka_repo)
  set_target_properties(librdkafka-shared PROPERTIES
    OUTPUT_NAME librdkafka)
  addLibs(librdkafka-shared)

  # Create the c++ dll
  add_library(librdkafka++-shared SHARED ${cpp_files})
  add_dependencies(librdkafka++-shared librdkafka_repo)
  set_target_properties(librdkafka++-shared PROPERTIES
    OUTPUT_NAME librdkafka++)
  addLibs(librdkafka++-shared)

  if(${XP_BUILD_STATIC})
    # Create the c lib
    add_library(librdkafka-mt STATIC ${c_files})
    add_dependencies(librdkafka-mt librdkafka_repo)

    # Create the c++ lib
    add_library(librdkafka++-mt STATIC ${cpp_files})
    add_dependencies(librdkafka++-mt librdkafka_repo)
    link_libraries(librdkafka++-mt librdkafka-mt)

    # Replace MD with MT in windows
    if(WIN32)
      target_compile_options(librdkafka-mt PUBLIC "/MT$<$<STREQUAL:$<CONFIGURATION>,Debug>:d>")
      target_compile_options(librdkafka++-mt PUBLIC "/MT$<$<STREQUAL:$<CONFIGURATION>,Debug>:d>")
    endif()
  endif()

endfunction(build_librdkafka)

# ------------------------------------------------------------------------------
# Proto codegeneration plugin
# ------------------------------------------------------------------------------

add_executable(rpc_generator_exe
  rpc_generator/main.cpp 
  rpc_generator/rpc_generator.cpp
  rpc_generator/rpc_generator.h)
target_link_libraries(rpc_generator_exe libprotobuf libprotoc)

# ------------------------------------------------------------------------------
# Proto compilation
# ------------------------------------------------------------------------------

function(generate_proto PROTO_NAME)
  get_filename_component(PROTO_PATH "protos/${PROTO_NAME}.proto" ABSOLUTE)
  get_filename_component(IMPORTS_DIR ${PROTO_PATH} DIRECTORY)

  set(PROTO_DIR "${CMAKE_CURRENT_BINARY_DIR}/proto")

  set(PROTO_SRC "${PROTO_DIR}/${PROTO_NAME}.pb.cc")
  set(PROTO_HDR "${PROTO_DIR}/${PROTO_NAME}.pb.h")

  set(CLIENT_SRC "${PROTO_DIR}/${PROTO_NAME}.client.cc")
  set(CLIENT_HDR "${PROTO_DIR}/${PROTO_NAME}.client.h")

  add_custom_command(
    OUTPUT "${PROTO_SRC}" "${PROTO_HDR}" "${CLIENT_SRC}" "${CLIENT_HDR}"
    COMMAND $<TARGET_FILE:protoc>
    ARGS 
      --cpp_out "${PROTO_DIR}"
      --rpc_out "${PROTO_DIR}"
      -I "${IMPORTS_DIR}"
      --plugin=protoc-gen-rpc=$<TARGET_FILE:rpc_generator_exe>
      "${PROTO_PATH}"
    DEPENDS "${PROTO_PATH}" rpc_generator_exe
  )

  add_library(${PROTO_NAME}
    rpc_generator/rpc_client_base.h
    rpc_generator/rpc_client_base.cpp
    ${PROTO_SRC}
    ${PROTO_HDR}
    ${CLIENT_SRC}
    ${CLIENT_HDR}
  )
  target_link_libraries(${PROTO_NAME}
    grpc++_reflection
    grpc++
    libprotobuf
    Boost::fiber
  )

  target_include_directories(${PROTO_NAME} PUBLIC rpc_generator)
endfunction()

# gmod-open-sdk: SourceSDK::tier1 / mathlib / tier2 / tier2_interfaces for Garry's Mod's x86-64 beta (MSVC, x64, /MT Release), the
# targets VPhysics-Jolt's gmod-beta profile expects. Sources and file lists come from the SDK's own VPC projects (gmod/src); the
# tier0 / vstdlib import libraries are generated from export-name .def files (gmod/src/lib/beta/x64), so no game binary is stored.
cmake_minimum_required(VERSION 3.20)
set(GOSDK_SRC "${CMAKE_CURRENT_LIST_DIR}/../gmod/src")
get_filename_component(GOSDK_SRC "${GOSDK_SRC}" ABSOLUTE)

# the .cpp files of a VPC project, skipping entries conditioned on other platforms
function(gosdk_vpc_files out vpc)
  file(STRINGS "${vpc}" lines REGEX "\\$File")
  get_filename_component(dir "${vpc}" DIRECTORY)
  set(files "")
  foreach(l IN LISTS lines)
    if(l MATCHES "\\[\\$(POSIX|LINUX|OSX|X360|PS3|LINUXALL|GL)\\]" OR l MATCHES "\\[!\\$WINDOWS\\]")
      continue()
    endif()
    if(l MATCHES "\\$File[ \t]+\"([^\"]+\\.cpp)\"")
      set(f "${CMAKE_MATCH_1}")
      string(REPLACE "\\" "/" f "${f}")
      string(REPLACE "$SRCDIR" "${GOSDK_SRC}" f "${f}")
      if(NOT IS_ABSOLUTE "${f}")
        set(f "${dir}/${f}")
      endif()
      if(EXISTS "${f}")
        list(APPEND files "${f}")
      endif()
    endif()
  endforeach()
  set(${out} "${files}" PARENT_SCOPE)
endfunction()

add_library(gosdk_headers INTERFACE)
add_library(SourceSDK::headers ALIAS gosdk_headers)
target_include_directories(gosdk_headers INTERFACE "${GOSDK_SRC}/public" "${GOSDK_SRC}/public/tier0" "${GOSDK_SRC}/public/tier1"
  "${GOSDK_SRC}/public/mathlib" "${GOSDK_SRC}/common")
target_compile_definitions(gosdk_headers INTERFACE WIN32 _WIN32 WIN64 _WIN64 PLATFORM_64BITS COMPILER_MSVC COMPILER_MSVC64 GAME_GMOD
  _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE _ALLOW_RUNTIME_LIBRARY_MISMATCH _ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH
  _ALLOW_MSC_VER_MISMATCH
  RAD_TELEMETRY_DISABLED)

# import libraries for the game's tier0.dll / vstdlib.dll, from export names only
foreach(m tier0 vstdlib)
  set(lib "${CMAKE_CURRENT_BINARY_DIR}/gosdk_${m}.lib")
  add_custom_command(OUTPUT "${lib}" COMMAND "${CMAKE_AR}" /nologo /machine:x64 "/def:${GOSDK_SRC}/lib/beta/x64/${m}.def" "/out:${lib}"
    DEPENDS "${GOSDK_SRC}/lib/beta/x64/${m}.def" VERBATIM)
  add_custom_target(gosdk_${m}_implib DEPENDS "${lib}")
  add_library(gosdk_${m} INTERFACE)
  add_dependencies(gosdk_${m} gosdk_${m}_implib)
  target_link_libraries(gosdk_${m} INTERFACE "${lib}")
endforeach()

function(gosdk_static name vpc)
  gosdk_vpc_files(srcs "${vpc}")
  add_library(gosdk_${name} STATIC ${srcs})
  target_link_libraries(gosdk_${name} PUBLIC gosdk_headers)
  set_target_properties(gosdk_${name} PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded" CXX_STANDARD 17)
  target_compile_options(gosdk_${name} PRIVATE /W0 /MP)
endfunction()

gosdk_static(tier1 "${GOSDK_SRC}/tier1/tier1.vpc")
target_compile_definitions(gosdk_tier1 PRIVATE TIER1_STATIC_LIB)
target_link_libraries(gosdk_tier1 PUBLIC gosdk_tier0 gosdk_vstdlib)
gosdk_static(mathlib "${GOSDK_SRC}/mathlib/mathlib.vpc")
target_compile_definitions(gosdk_mathlib PRIVATE MATHLIB_LIB)
target_link_libraries(gosdk_mathlib PUBLIC gosdk_tier1)
gosdk_static(tier2 "${GOSDK_SRC}/tier2/tier2.vpc")
target_compile_definitions(gosdk_tier2 PRIVATE TIER2_STATIC_LIB)
target_link_libraries(gosdk_tier2 PUBLIC gosdk_tier1)

add_library(SourceSDK::tier1 ALIAS gosdk_tier1)
add_library(SourceSDK::mathlib ALIAS gosdk_mathlib)
add_library(SourceSDK::tier2 ALIAS gosdk_tier2)
add_library(SourceSDK::tier2_interfaces ALIAS gosdk_tier2)

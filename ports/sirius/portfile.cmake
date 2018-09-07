# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

set(SIRIUS_VERSION 0.2.0)
set(SIRIUS_REVISION_COMMIT ec466a3328515aa3302d811e0c27dae45f26bd0b)
set(SIRIUS_ARCHIVE_SHA512 0d4cb35f68fa81582da61c08a66c0f3c2acfc895e76e74624a65b6c10fe8ff2a6943d1bf863d20dd30aac5b0cc96532bff57f3a1ca36518a17adc718b19a9e00)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hlysunnaram/SIRIUS
    HEAD_REF feature/multiplatform-support
    REF ${SIRIUS_REVISION_COMMIT}
    SHA512 ${SIRIUS_ARCHIVE_SHA512}
)

set(USE_CXX_STATIC_RUNTIME OFF)
if (VCPKG_CRT_LINKAGE MATCHES "static")
    set(USE_CXX_STATIC_RUNTIME ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSIRIUS_VERSION=${SIRIUS_VERSION}
        -DSIRIUS_REVISION_COMMIT=${SIRIUS_REVISION_COMMIT}
        -DUSE_CXX_STATIC_RUNTIME=${USE_CXX_STATIC_RUNTIME}
        -DENABLE_CACHE_OPTIMIZATION=ON
        -DENABLE_UNIT_TESTS=OFF
        -DENABLE_DOCUMENTATION=OFF
        -DENABLE_SIRIUS_EXECUTABLE=OFF
    OPTIONS_RELEASE
        -DENABLE_GSL_CONTRACTS=OFF
    OPTIONS_DEBUG
        -DENABLE_GSL_CONTRACTS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake)

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake-modules)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sirius RENAME copyright)

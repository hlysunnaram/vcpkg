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
set(SIRIUS_REVISION_COMMIT 6a0d7cdb748dea8f37960d4ae02ac7f5d75e35e9)
set(SIRIUS_ARCHIVE_SHA512 4dfeb7f84add10dea7b65d70599fe3b90a3bbf787e0479f6aedd98f4b0235eed746c1bbec71e1db7597a2b554319f4117972b73c20e7f9f82f4f58b98e9778b7)

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

# move license files into sirus package directory
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/sirius RENAME copyright)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/LICENSE-3RD-PARTY.md
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/sirius RENAME copyright-3rd-party.md)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/third_party
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/sirius)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/share/cmake-modules
    ${CURRENT_PACKAGES_DIR}/share/LICENSE
    ${CURRENT_PACKAGES_DIR}/share/LICENSE-3RD-PARTY.md
    ${CURRENT_PACKAGES_DIR}/share/third_party)
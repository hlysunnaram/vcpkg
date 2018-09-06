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

if (EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

set(SIRIUS_VERSION 0.2.0)
set(SIRIUS_REVISION_COMMIT 2e7c8e5f17724f43e7db4232a83f91194c909761)
set(SIRIUS_ARCHIVE_SHA512 a16e405367c127fa3ce87ef809685dfafa3b8ba25e73898ee1fab5be16a3d6cac59f00cfe0286f0648596adb72d8f3bc08ac32835615178dba51cee089b29a1f)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hlysunnaram/SIRIUS
    REF ${SIRIUS_REVISION_COMMIT}
    SHA512 ${SIRIUS_ARCHIVE_SHA512}
    HEAD_REF feature/multiplatform-support-install
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

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sirius RENAME copyright)

vcpkg_copy_pdbs()

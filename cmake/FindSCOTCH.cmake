message(STATUS "Searching for PTSCOTCHparmetis library ...")
# Removed "lib" prefix and ".a" extension to support shared and static libs
find_library(ptscotchparmetis_lib NAMES ptscotchparmetisv3 HINTS ENV SCOTCH_PATH PATH_SUFFIXES lib)
find_path(ptscotchparmetis_inc parmetis.h HINTS ENV SCOTCH_PATH PATH_SUFFIXES include)

message(STATUS "Searching for SCOTCH library ...")
find_library(scotch_lib NAMES scotch HINTS ENV SCOTCH_PATH PATH_SUFFIXES lib)
find_path(scotch_inc scotch.h HINTS ENV SCOTCH_PATH PATH_SUFFIXES include)

message(STATUS "Searching for PTSCOTCH library ...")
find_library(ptscotch_lib NAMES ptscotch HINTS ENV SCOTCH_PATH PATH_SUFFIXES lib)
find_path(ptscotch_inc ptscotch.h HINTS ENV SCOTCH_PATH PATH_SUFFIXES include)

message(STATUS "Searching for SCOTCHerr library ...")
find_library(scotcherr_lib NAMES scotcherr HINTS ENV SCOTCH_PATH PATH_SUFFIXES lib)
find_path(scotcherr_inc scotch.h HINTS ENV SCOTCH_PATH PATH_SUFFIXES include)

message(STATUS "Searching for PTSCOTCHerr library ...")
find_library(ptscotcherr_lib NAMES ptscotcherr HINTS ENV SCOTCH_PATH PATH_SUFFIXES lib)
find_path(ptscotcherr_inc ptscotch.h HINTS ENV SCOTCH_PATH PATH_SUFFIXES include)

# Use UNKNOWN IMPORTED so CMake accepts either .a or .so libraries
add_library(PTSCOTCHparmetis::PTSCOTCHparmetis UNKNOWN IMPORTED)
add_library(SCOTCH::SCOTCH UNKNOWN IMPORTED)
add_library(PTSCOTCH::PTSCOTCH UNKNOWN IMPORTED)
add_library(SCOTCHerr::SCOTCHerr UNKNOWN IMPORTED)
add_library(PTSCOTCHerr::PTSCOTCHerr UNKNOWN IMPORTED)

set_target_properties(SCOTCH::SCOTCH PROPERTIES
  IMPORTED_LOCATION "${scotch_lib}"
  INTERFACE_INCLUDE_DIRECTORIES "${scotch_inc}")

set_target_properties(SCOTCHerr::SCOTCHerr PROPERTIES
  IMPORTED_LOCATION "${scotcherr_lib}"
  INTERFACE_INCLUDE_DIRECTORIES "${scotcherr_inc}")

set_target_properties(PTSCOTCH::PTSCOTCH PROPERTIES
  IMPORTED_LOCATION "${ptscotch_lib}"
  INTERFACE_INCLUDE_DIRECTORIES "${ptscotch_inc}")

set_target_properties(PTSCOTCHerr::PTSCOTCHerr PROPERTIES
  IMPORTED_LOCATION "${ptscotcherr_lib}"
  INTERFACE_INCLUDE_DIRECTORIES "${ptscotcherr_inc}")

set_target_properties(PTSCOTCHparmetis::PTSCOTCHparmetis PROPERTIES
  IMPORTED_LOCATION "${ptscotchparmetis_lib}"
  INTERFACE_INCLUDE_DIRECTORIES "${ptscotchparmetis_inc}")

## Interfaces and links (Fixed missing SCOTCHerr and ordered per SCOTCH manual)
target_link_libraries(PTSCOTCHparmetis::PTSCOTCHparmetis INTERFACE 
  PTSCOTCH::PTSCOTCH 
  SCOTCH::SCOTCH 
  SCOTCHerr::SCOTCHerr)

## Finalize find_package
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} REQUIRED_VARS scotch_lib scotch_inc)
find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} REQUIRED_VARS ptscotch_lib ptscotch_inc)
find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} REQUIRED_VARS scotcherr_lib scotcherr_inc)
find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} REQUIRED_VARS ptscotcherr_lib ptscotcherr_inc)
find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME} REQUIRED_VARS ptscotchparmetis_lib ptscotchparmetis_inc)

## Find version of scotch if possible
if( EXISTS "${scotch_inc}/scotch.h" )
  file(READ "${scotch_inc}/scotch.h" header_content)

  string(REGEX MATCH "SCOTCH_VERSION ([0-9]+)" VERSION_MAJOR_MATCH "${header_content}")
  if(VERSION_MAJOR_MATCH)
    set(SCOTCH_VERSION_MAJOR "${CMAKE_MATCH_1}")
  endif()

  string(REGEX MATCH "SCOTCH_RELEASE ([0-9]+)" VERSION_MINOR_MATCH "${header_content}")
  if(VERSION_MINOR_MATCH)
    set(SCOTCH_RELEASE "${CMAKE_MATCH_1}")
    message(STATUS "SCOTCH_RELEASE: ${SCOTCH_RELEASE}")
  else()
    message(WARNING "Could not find SCOTCH_RELEASE in scotch.h")
  endif()
  endif()

  string(REGEX MATCH "SCOTCH_PATCHLEVEL ([0-9]+)" VERSION_PATCH_MATCH "${header_content}")
  if(VERSION_PATCH_MATCH)
    set(SCOTCH_PATCHLEVEL "${CMAKE_MATCH_1}")
    message(STATUS "SCOTCH_PATCHLEVEL: ${SCOTCH_PATCHLEVEL}")
  else()
    message(WARNING "Could not find VERSION_PATCH in scotch.h")
  endif()
  set(SCOTCH_VERSION "${SCOTCH_VERSION_MAJOR}.${SCOTCH_RELEASE}.${SCOTCH_PATCHLEVEL}")
endif()

message(STATUS "Found SCOTCH: ${scotch_lib}")
message(STATUS "Found PTSCOTCH: ${ptscotch_lib}")
message(STATUS "Found SCOTCHerr: ${scotcherr_lib}")
message(STATUS "Found PTSCOTCHerr: ${ptscotcherr_lib}")
message(STATUS "Found PTSCOTCHparmetis: ${ptscotchparmetis_lib}")
message(STATUS "SCOTCH version: ${SCOTCH_VERSION}")

# Auto-inject the Fortran API macro directly into the target for version 7.0.5+
if(SCOTCH_VERSION VERSION_GREATER_EQUAL "7.0.5")
  target_compile_definitions(PTSCOTCHparmetis::PTSCOTCHparmetis INTERFACE SCOTCH_705)
endif()

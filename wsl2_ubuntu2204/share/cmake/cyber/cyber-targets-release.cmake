#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cyber" for configuration "Release"
set_property(TARGET cyber APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(cyber PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libcyber.so"
  IMPORTED_SONAME_RELEASE "libcyber.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS cyber )
list(APPEND _IMPORT_CHECK_FILES_FOR_cyber "${_IMPORT_PREFIX}/lib/libcyber.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)


include(RockHopperUtils)


function(_target_rockhopper_extensions __target __cache_name)

  get_property(_project_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  foreach(LANG ${_project_languages})

    option(
      ${__cache_name}_ENABLE_${LANG}_EXTENSIONS
      "Enable the use of ${LANG} compiler extensions. (Not recomended; may lead to warning clashes)"
      OFF)

    if(${__cache_name}_ENABLE_${LANG}_EXTENSIONS)
      message(NOTICE "Enabling ${LANG} extensions is not recomended.")
    endif()

    target_compile_definitions(${__target} PUBLIC
      ${LANG}_EXTENSIONS=${${__cache_name}_ENABLE_${LANG}_EXTENSIONS})

  endforeach()

endfunction()


function(_target_rockhopper_warnings __target __cache_name)

  option(
    ${__cache_name}_ENABLE_ROCKHOPPER_STANDARDS_WARNINGS
    "Enable RockHopper Standards' set of compiler warnings."
    ON)

  if(NOT ${${__cache_name}_ENABLE_ROCKHOPPER_STANDARDS_WARNINGS})

    message(NOTICE "Disabling RockHopper Standards' set of compiler warnings is not recommended.")
    return()

  endif()

  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR
      CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

    target_compile_options(${__target} PUBLIC -Werror -Wall -Wextra)
    target_compile_options(${__target} PUBLIC -Wpedantic -Wconversion -Wshadow -Weffc++)
    target_compile_options(${__target} PUBLIC -Wno-unused)

  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")

    target_compile_options(${__target} PUBLIC /WX /Wall)

  else()
    message(NOTICE "Unsupported compiler ${CMAKE_CXX_COMPILER_ID}\
      Cannot set RockHopper Standards' set of compiler warnings.")
  endif()

endfunction()


function(target_rockhopper_standards __target)

  set(ARGS_OPTIONAL
    )
  set(ARGS_SINGLE
    # (optional) A custom name for target-specific cache options.
    "CACHE_NAME"
    )
  set(ARGS_MULTIPLE
    )

  _rockhopper_validate_target(${__target})
  _rockhopper_parse_exact_args(ARG "${ARGS_OPTIONAL}" "${ARGS_SINGLE}" "${ARGS_MULTIPLE}" ${ARGN})

  if(NOT ARG_CACHE_NAME)
    _rockhopper_cache_name(${__target} ARG_CACHE_NAME)
  endif()

  _target_rockhopper_extensions(${__target} ${ARG_CACHE_NAME})
  _target_rockhopper_warnings(${__target} ${ARG_CACHE_NAME})

endfunction()

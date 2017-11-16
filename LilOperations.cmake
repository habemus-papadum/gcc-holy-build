## find programs
## defines LIL_<NAME> in parent scope
function (lil_find_program name)
    string(TOUPPER ${name} cap_name)
    find_program(LIL_${cap_name} ${name})
    if (NOT LIL_${cap_name})
        message(FATAL_ERROR "Your host system does not have the required '${name}' program available.")
    endif()
    set(LIL_${cap_name} ${LIL_${cap_name}} PARENT_SCOPE)
endfunction()

##################################################################################################
## Log/Setup/Check key variables
macro (lil_log var)
    message(STATUS "${var} = ${${var}}")
endmacro()




##################################################################################################
## Helper to linearize a sequence of steps in a chain
## Uses some moderate Cmake-fu
## Many of the build steps form a linear dependency chain
## This helper helps enforce that dependency structure.
## it works by remembering the current chain and the last step
## Nomeclature: chain > step > work
macro(lil_chain_step step chain)
    set(LIL_LAST_CHAIN ${chain})

    ## a new chain
    if ("${LIL_LAST_${LIL_LAST_CHAIN}_STEP}" STREQUAL "")
        add_custom_target(${chain}-begun
                ALL
                COMMAND ${LIL_TRUE})
        add_custom_target(${chain}-completed
                ALL
                COMMAND ${LIL_TRUE}
                DEPENDS ${chain}-begun)
        add_custom_target(${step}-begun
                ALL
                COMMAND ${LIL_TRUE}
                DEPENDS ${chain}-begun)

    else()
        add_custom_target(${step}-begun
                ALL
                COMMAND ${LIL_TRUE}
                DEPENDS ${LIL_LAST_${LIL_LAST_CHAIN}_STEP}-completed ${chain}-begun)
    endif()
    add_custom_target(${step}-completed
            ALL
            COMMAND ${LIL_TRUE}
            DEPENDS ${step}-begun)
    add_dependencies(${chain}-completed ${step}-completed)
    set (LIL_LAST_${LIL_LAST_CHAIN}_STEP ${step})
endmacro()

## Within a given step, there will be various work items
## This helper makes sure that work does not begin until a step has begun,
## and a step is not complete until all work items are complete.
##
## Note: the work items do not always form a linear depenency chain.
## Instead dependencies between work items are recorded as needed via
## CMake's add_dependency
macro(add_step_work work)
    add_dependencies(${work} ${LIL_LAST_${LIL_LAST_CHAIN}_STEP}-begun)
    add_dependencies(${LIL_LAST_${LIL_LAST_CHAIN}_STEP}-completed ${work})
endmacro()
## END Helper to linearize a sequence of steps in a chain
##################################################################################################

lil_find_program(true)
##################################################################################################
macro (lil_retrieve_fork fork)
    ExternalProject_Add(
            ${fork}-download
            URL "https://api.github.com/repos/${LIL_GH_USER}/${fork}/tarball/${LIL_TAG}"
            SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/work/${fork}
            DOWNLOAD_NAME ${fork}.tar.gz

            ## empty strings "" get elided from the array when passed to EP
            CONFIGURE_COMMAND ${LIL_TRUE}
            BUILD_COMMAND     ${LIL_TRUE}
            INSTALL_COMMAND   ${LIL_TRUE}
            ${ARGN}
    )
    add_step_work(${fork}-download)
endmacro()
##################################################################################################

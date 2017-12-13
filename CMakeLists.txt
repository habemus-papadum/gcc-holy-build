cmake_minimum_required(VERSION 3.2.2)
project(gcc-holy-build)

################################################################################
## Main Configuration                                                          #
## ============================================================================#
##                                                                             #
## Github user for the forks of gcc and binutils                               #
set(LIL_GH_USER habemus-papadum CACHE STRING "Github user")                    #
##                                                                             #
## the tag to pull on the github fork                                          #
set(LIL_TAG ${LIL_GH_USER}/holy-build-0.1.0 CACHE STRING "Github fork version")#
##                                                                             #
## Docker image to use for holy building                                       #
set(LIL_DOCKER_IMAGE "habemuspapadum/holy-gcc-builder:0.1.0" CACHE STRING      #
        "Docker Holy Builder")                                                 #
##                                                                             #
################################################################################


################################################################################
##                                                                             #
## Prelude -- sanity checks and basic configuration                            #
## ============================================================================#
##                                                                             #
## nearly all build logic is implemented via cmake's External Project(EP)      #
include(ExternalProject)                                                       #
include("${CMAKE_CURRENT_LIST_DIR}/LilOperations.cmake")                       #
##                                                                             # 
lil_log(LIL_GH_USER)                                                           #
lil_log(LIL_TAG)                                                               #
lil_log(LIL_DOCKER_IMAGE)                                                      #
##                                                                             #
################################################################################

################################################################################
if ($ENV{TRAVIS})
    message(STATUS "Running within Travis...")
endif()

lil_find_program(tar)
lil_find_program(docker)

string(REPLACE "/" "-" file_tag ${LIL_TAG})

set(work_dir ${CMAKE_CURRENT_BINARY_DIR}/work)
set(out_dir ${CMAKE_CURRENT_BINARY_DIR}/gcc-holy-build-${file_tag})
file(MAKE_DIRECTORY ${work_dir})
file(MAKE_DIRECTORY ${out_dir})

################################################################################
configure_file(
    build-in-docker.sh
    ${work_dir}/build-in-docker.sh
    COPYONLY)
configure_file(
        gcc-postfix.sh
        ${work_dir}/gcc-postfix.sh
        COPYONLY)


################################################################################
## creates a chain of steps (helps organize build steps)
lil_chain_step(build-gcc main-chain)
## Download forks
lil_retrieve_fork(gcc)


## using cmake EP infrastructure so that we can leverage its intelligent
## incremental build capabilities

################################################################################
ExternalProject_Add_Step(gcc-download build-in-docker
        COMMAND
        ${LIL_DOCKER}
        run
        --rm
        -v ${work_dir}:/work
        -v ${out_dir}:/opt/lilinjn/gcc-holy-build
        ${LIL_DOCKER_IMAGE}
        bash
        /work/build-in-docker.sh $ENV{TRAVIS}

        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Build binutils and gcc inside docker"

        DEPENDEES install
        )

################################################################################
ExternalProject_Add_Step(gcc-download gcc-postfix
        COMMAND
        ${LIL_DOCKER}
        run
        --rm
        -v ${work_dir}:/work
        -v ${out_dir}:/opt/lilinjn/gcc-holy-build
        ${LIL_DOCKER_IMAGE}
        bash
        /work/gcc-postfix.sh

        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Apply gcc postfix"

        DEPENDEES build-in-docker
        )


################################################################################
ExternalProject_Add_Step(gcc-download create-tar-ball
        COMMAND
        ${LIL_TAR}
        cvzf
        gcc-holy-build-${file_tag}.tar.gz
        gcc-holy-build-${file_tag}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Create tarball"

        DEPENDEES gcc-postfix
        )

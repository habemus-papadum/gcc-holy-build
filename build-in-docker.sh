#!/bin/bash

TRAVIS=$1
set -ex

export PATH=/opt/rh/devtoolset-2/root/usr/bin/:$PATH
cd /work
install_dir=/opt/lilinjn/gcc-holy-build
num_procs=$(getconf _NPROCESSORS_ONLN)
num_procs=$(( num_procs+2 ))
redirect=/dev/stdout

progress(){
  while true
  do
    echo  "------------------TRAVIS HELPER-----------------"
    sleep 300
  done
}
if [ "${TRAVIS}" = true ]; then
        redirect=/dev/null
        progress &
        progress_pid=$!
fi

(
mkdir -p gcc-build
cd gcc-build
../gcc/configure                   \
    --prefix=${install_dir}        \
    --disable-multilib             \
    --disable-nls                  \
    --enable-languages=c,c++ > $redirect

make -j $num_procs > $redirect
make install
)

if [ "${TRAVIS}" = true ]; then
        kill ${progress_pid}
fi

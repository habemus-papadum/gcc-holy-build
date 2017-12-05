##

This repo provides a (reasonably) portable, relocatable `x86_64-pc-linux-gnu` `gcc` which can be used to bootstrap builds of other tools. 

## Versions
 * `gcc-6_3_0` 

## Compatability 
Will run on most `glibc` `x86_64` linux distros since 2007 cf. [Holy Build Box](https://github.com/phusion/holy-build-box#which-linux-distributions-do-binaries-compiled-with-holy-build-box-support)

The [release](https://github.com/habemus-papadum/gcc-holy-build/releases) [tarball](https://github.com/habemus-papadum/gcc-holy-build/releases/download/v0.1.1/gcc-holy-build-habemus-papadum-v1-branch.tar.gz) can be extracted in any convenient location. 

## Motivation
My preferred toolchain is a custom built [clang]().  This repo provides a known valid bootstrap compiler for this toolchain.  Having pre-made binaries reduces build times, also simplifying travis time limit issues.  

N.B.: This gcc is probably not useful for building most types of software.  At the very least such software should have some way to find the compiler's shared libs (e.g. `libstdc++.so` and `libgcc_s.so`), perhaps by building it with `rpath`'s or running it w/ `LD_LIBRARY_PATH`, both of which are completely tedious.  However, in building my clang toolchain, the first step is to build a transient clang (with this gcc and which has `rpath`'s to the correct libs), and then the transient clang is used to build one or more "proper" clangs.   (N.B.: this example is a little contrived.  Using `--static-libgcc`  and `--static-libstdc++` would also have been helpful.  But really, this gcc is best used for building transient software, and, in general, this probably means other bootstrap c/c++ compilers.)  

Among other things, this allows for creating sysroots that are `libgcc*` free, and can be used to create pure clang based distros (which I am not interested, but you might be...).


## Issues
Despite being able to leverage the wonderful [Holy Build Box](https://github.com/phusion/holy-build-box), building a portable gcc is a bit of a tricky thing to do.  If you encounter issues such as
* Complaints related to `__locale`
* Missing `crt*.o` files
* Missing headers

then please consider filing an [Issue](https://github.com/habemus-papadum/gcc-holy-build/issues), as I would be be curious to know more details.  

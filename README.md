# Ubuntu Root Filesystem

运行`make`即可获取到Ubuntu Core Minimal系统。

**注意事项：**  
由于使用到了Host的设备节点，所以在使用make获取文件系统的时候，2-3次最好重启一下系统，否则会遇到/dev设备节点无法挂载等等各种不可预知的问题。

## Refers

* [Debian for ARM](http://www.cnblogs.com/zengjfgit/p/6413894.html)
* [Installing Ubuntu Rootfs on NXP i.MX6 boards](https://community.nxp.com/docs/DOC-330147)
* [ubuntu 下出现E: Sub-process /usr/bin/dpkg returned an error code](http://blog.csdn.net/yusiguyuan/article/details/24269129)
* [Thread: The system has no more ptys.](https://ubuntuforums.org/showthread.php?t=1190892)
* [6.2.2. Mounting and Populating /dev](http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kernfs.html#ch-system-bindmount)
* [gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz](https://releases.linaro.org/archive/14.09/components/toolchain/binaries/)
* [Make: how to continue after a command fails?](https://stackoverflow.com/questions/2670130/make-how-to-continue-after-a-command-fails)
* [Can not write log, openpty() failed (/dev/pts not mounted?)](http://mqjing.blogspot.tw/2013/07/chroot-pts-w-can-not-write-log-openpty.html)

## pre-install package

在这里面加入需要预安装的`packages`：
* [customize/install_packages](customize/install_packages)

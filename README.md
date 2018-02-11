# Ubuntu Root Filesystem

运行`make`即可获取到Ubuntu Core Minimal系统。

**注意事项：**  
* 由于使用到了Host的设备节点，所以在使用make获取文件系统的时候，2-3次最好重启一下系统，否则会遇到/dev设备节点无法挂载等等各种不可预知的问题。  
* **强烈建议使用虚拟机折腾，由于会涉及到本机的/dev目录下的操作，误操作可能导致本机出现各种不可预知的问题，血的教训**

## Refers

* [Debian for ARM](http://www.cnblogs.com/zengjfgit/p/6413894.html)
* [Installing Ubuntu Rootfs on NXP i.MX6 boards](https://community.nxp.com/docs/DOC-330147)
* [ubuntu 下出现E: Sub-process /usr/bin/dpkg returned an error code](http://blog.csdn.net/yusiguyuan/article/details/24269129)
* [Thread: The system has no more ptys.](https://ubuntuforums.org/showthread.php?t=1190892)
* [6.2.2. Mounting and Populating /dev](http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kernfs.html#ch-system-bindmount)
* [gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz](https://releases.linaro.org/archive/14.09/components/toolchain/binaries/)
* [Make: how to continue after a command fails?](https://stackoverflow.com/questions/2670130/make-how-to-continue-after-a-command-fails)
* [Can not write log, openpty() failed (/dev/pts not mounted?)](http://mqjing.blogspot.tw/2013/07/chroot-pts-w-can-not-write-log-openpty.html)
* [Installing Ubuntu Rootfs on NXP i.MX6 boards](https://community.nxp.com/docs/DOC-330147)

## pre-install package

在这里面加入需要预安装的`packages`：
* [customize/install_packages](customize/install_packages)

## Upstart Init 

```
root@zengjf:/etc/init# init --help
Usage: init [OPTION]...
Process management daemon.

Options:
      --confdir=DIR           specify alternative directory to load
                                configuration files from
      --default-console=VALUE
                              default value for console stanza
      --no-dbus               do not connect to a D-Bus bus
      --no-inherit-env        jobs will not inherit environment of init
      --logdir=DIR            specify alternative directory to store job output
                                logs in
      --no-log                disable job logging
      --chroot-sessions       enable chroot sessions
      --no-startup-event      do not emit any startup event (for testing)
      --restart               flag a re-exec has occurred
      --state-fd=FD           specify file descriptor to read serialisation
                                data from
      --session               use D-Bus session bus rather than system bus (for
                                testing)
      --startup-event=NAME    specify an alternative initial event (for
                                testing)
      --user                  start in user mode (as used for user sessions)
      --write-state-file      attempt to write state file on every re-exec
  -q, --quiet                 reduce output to errors only
  -v, --verbose               increase output to include informational messages
      --help                  display this help and exit
      --version               output version information and exit

This daemon is normally executed by the kernel and given process id 1 to denote
its special status.  When executed by a user process, it will actually run
/sbin/telinit.

Report bugs to <upstart-devel@lists.ubuntu.com>
root@zengjf:/etc/init#
```

* 由上mail可知，该init程序是Upstart init daemon；
* [Upstart Init Ref](http://manpages.ubuntu.com/manpages/trusty/man5/init.5.html)

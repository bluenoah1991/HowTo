# How to debug Android

## JDB Debug
    adb devices
    adb jdwp
    adb shell
    adb connect ipaddr:port

    adb forward tcp:5000 jdwp:<pid>
    jdb -connect com.sun.jdi.SocketAttach:hostname=localhost,port=5000

## Install and Uninstall Apk

    adb shell pm list packages
    adb shell pm uninstall com.xxx.yyy.zzz
    adb push localFilePath deviceFilePath
    adb pull deviceFilePath localFilePath
    adb shell pm install /sdcard/xxx.apk

## Priviledge Promotion

    mount -o rw,remount -t yaffs2 /dev/block/mtdblock3 /system
    adb remount

## GDB Debug

    gdbserver :5000 --attach 1234
    gdbserver :5001 ./a.out

> android-ndk-r10e\toolchains\arm-linux-androideabi-4.9\prebuilt\windows-x86_64\bin\arm-linux-androideabi-gdb.exe

    (gdb) target remote 10.0.0.1:5000

## android.os.Debug

    import android.os.Debug;

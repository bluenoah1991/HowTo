@echo off

call :1
call :2
call :3
call :4

goto :finish

:1
IF EXIST out\chromium_static_debug_x86 (
echo chromium_static_debug_x86 already EXISTS!
) ELSE (
gn gen --ide=vs2017 out/chromium_static_debug_x86 --args="is_debug = true is_component_build = false enable_nacl = false target_cpu = \"x86\""
)
goto :end

:2
IF EXIST out\chromium_static_debug_x64 (
echo chromium_static_debug_x64 already EXISTS!
) ELSE (
gn gen --ide=vs2017 out/chromium_static_debug_x64 --args="is_debug = true is_component_build = false enable_nacl = false target_cpu = \"x64\""
)
goto :end

:3
IF EXIST out\chromium_static_release_x86 (
echo chromium_static_release_x86 already EXISTS!
) ELSE (
gn gen --ide=vs2017 out/chromium_static_release_x86 --args="is_debug = false is_component_build = false enable_nacl = false target_cpu = \"x86\""
)
goto :end

:4
IF EXIST out\chromium_static_release_x64 (
echo chromium_static_release_x64 already EXISTS!
) ELSE (
gn gen --ide=vs2017 out/chromium_static_release_x64 --args="is_debug = false is_component_build = false enable_nacl = false target_cpu = \"x64\""
)
goto :end

:finish
echo Finish!

:end
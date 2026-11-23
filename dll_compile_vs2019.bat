@echo off
setlocal
set "workspace=%~dp0.."
set "sdk_scripts=%workspace%\sdk\Server\scripts"
set "patch_file=%~dp0sdk-cpp14-win32-abi.patch"
set "build_dir=%~dp0build\dll-release"
set "client_flags=/MT /O2"
set "client_link_flags="

if /i "%~1"=="debug" (
    set "build_dir=%~dp0build\dll-debug"
    set "client_flags=/MTd /Od /Zi /D FONLINE_CLIENT"
    set "client_link_flags=/debug"
)

if not exist "%sdk_scripts%\fonline_tla.cpp" (
    echo SDK source not found: "%sdk_scripts%\fonline_tla.cpp" 1>&2
    exit /b 1
)

set "vs_installer=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
set "vs_path="
if exist "%vs_installer%\vswhere.exe" (
    pushd "%vs_installer%" || exit /b 1
    for /f "delims=" %%I in ('vswhere.exe -latest -products * -version "[16.0,17.0)" -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath') do set "vs_path=%%I"
    popd
)
if not defined vs_path (
    echo Visual Studio 2019 with MSVC x86 tools was not found. 1>&2
    exit /b 1
)
call "%vs_path%\VC\Auxiliary\Build\vcvars32.bat"
if errorlevel 1 exit /b 1

git -C "%workspace%" apply --reverse --check "%patch_file%" >nul 2>&1
if errorlevel 1 (
    git -C "%workspace%" apply --check "%patch_file%"
    if errorlevel 1 (
        echo SDK ABI patch could not be applied. Check the SDK version and local edits. 1>&2
        exit /b 1
    )
    git -C "%workspace%" apply "%patch_file%"
    if errorlevel 1 exit /b 1
    echo Applied SDK ABI patch.
) else (
    echo SDK ABI patch is already applied.
)

if not exist "%build_dir%\." mkdir "%build_dir%"
pushd "%build_dir%" || exit /b 1

echo Building server DLL...
cl /nologo /MT /std:c++14 /W3 /O2 /Gd /D __SERVER /Fofonline_tla.obj /c "%sdk_scripts%\fonline_tla.cpp"
if errorlevel 1 goto :failed
link /nologo /dll /incremental:no /machine:I386 fonline_tla.obj /out:fonline_tla.dll
if errorlevel 1 goto :failed

echo Building client DLL...
cl /nologo %client_flags% /std:c++14 /W3 /Gd /D __CLIENT /Fofonline_tla_client.obj /Fdfonline_tla_client.pdb /c "%sdk_scripts%\fonline_tla.cpp"
if errorlevel 1 goto :failed
link /nologo /dll %client_link_flags% /incremental:no /machine:I386 fonline_tla_client.obj /out:fonline_tla_client.dll
if errorlevel 1 goto :failed

copy /y fonline_tla.dll "%sdk_scripts%\fonline_tla.dll" >nul
if errorlevel 1 goto :failed
copy /y fonline_tla_client.dll "%sdk_scripts%\fonline_tla_client.dll" >nul
if errorlevel 1 goto :failed

echo Built both DLLs in "%sdk_scripts%".
popd
exit /b 0

:failed
popd
exit /b 1

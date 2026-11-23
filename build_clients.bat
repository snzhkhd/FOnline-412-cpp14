@echo off
setlocal
set "build_dir=%~dp0build"

cmake -S "%~dp0." -B "%build_dir%" -G "Visual Studio 16 2019" -A Win32 -DFONLINE_CLIENT_D3D=OFF
if errorlevel 1 exit /b 1
cmake --build "%build_dir%" --config Release --target FOnlineClient
if errorlevel 1 exit /b 1

cmake -S "%~dp0." -B "%build_dir%\d3d" -G "Visual Studio 16 2019" -A Win32 -DFONLINE_CLIENT_D3D=ON
if errorlevel 1 exit /b 1
cmake --build "%build_dir%\d3d" --config Release --target FOnlineClient
exit /b %errorlevel%

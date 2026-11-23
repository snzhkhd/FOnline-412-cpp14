@echo off
setlocal
set "build_dir=%~dp0build"

cmake -S "%~dp0." -B "%build_dir%" -G "Visual Studio 16 2019" -A Win32
if errorlevel 1 exit /b 1
cmake --build "%build_dir%" --config Release --target ASCompiler
exit /b %errorlevel%

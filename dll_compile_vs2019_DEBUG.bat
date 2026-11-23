@echo off
call "%~dp0dll_compile_vs2019.bat" debug
exit /b %errorlevel%

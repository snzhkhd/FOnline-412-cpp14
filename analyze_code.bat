@echo off
setlocal
set "build_dir=%~dp0build\analysis"
set "report=%build_dir%\analysis.log"

cmake -S "%~dp0." -B "%build_dir%" -G "Visual Studio 16 2019" -A Win32 -DFONLINE_CLIENT_D3D=OFF
if errorlevel 1 exit /b 1

echo Running MSVC static analysis. Report: "%report%"
cmake --build "%build_dir%" --config Release --clean-first --target FOnlineServer FOnlineClient ASCompiler -- /p:RunCodeAnalysis=true > "%report%" 2>&1
set "result=%errorlevel%"
if not "%result%"=="0" (
    echo Build or analysis failed. See "%report%". 1>&2
    exit /b %result%
)

powershell.exe -NoProfile -File "%~dp0summarize_analysis.ps1" -AnalysisDirectory "%build_dir%"
exit /b %errorlevel%

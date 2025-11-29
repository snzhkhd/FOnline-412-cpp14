@echo off

@:: 1. Настраиваем окружение VS 2019 (x86)
@:: Если у вас VS установлена в другую папку, поправьте путь.
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"

@:: Удаляем старые файлы
@del "fonline_tla.dll"
@del "fonline_tla_client.dll"

@:: -----------------------------------------------------------
@:: СБОРКА СЕРВЕРНОЙ DLL
@:: -----------------------------------------------------------
@echo Building SERVER DLL...
@:: Флаги:
@:: /nologo - без лишнего текста
@:: /MT     - статическая линковка (важно, чтобы совпадало с движком!)
@:: /std:c++14 - стандарт C++
@:: /O2     - оптимизация (для релиза)
@:: /W3     - уровень предупреждений
@:: /D "__SERVER" - дефайн для кода
cl.exe /nologo /MT /std:c++14 /W3 /O2 /Gd /D "__SERVER" /Fo"fonline_tla.obj" /FD /c "fonline_tla.cpp"

@:: Линковка
link.exe /nologo /dll /incremental:no /machine:I386 "fonline_tla.obj" /out:"fonline_tla.dll"


@:: -----------------------------------------------------------
@:: СБОРКА КЛИЕНТСКОЙ DLL
@:: -----------------------------------------------------------
@echo Building CLIENT DLL (DEBUG)...
cl.exe /nologo /MTd /std:c++14 /W3 /Od /Zi /Gd /D "__CLIENT" /D "FONLINE_CLIENT" /Fo"fonline_tla_client.obj" /Fd"fonline_tla_client.pdb" /FD /c "fonline_tla.cpp"

link.exe /nologo /dll /debug /incremental:no /machine:I386 "fonline_tla_client.obj" /out:"fonline_tla_client.dll"

@:: -----------------------------------------------------------
@:: Очистка мусора
@:: -----------------------------------------------------------
@del "fonline_tla.obj"
@del "fonline_tla.exp"
@del "fonline_tla.lib"
@del "fonline_tla_client.obj"
@del "fonline_tla_client.exp"
@del "fonline_tla_client.lib"

@echo.
@echo Done!
@pause

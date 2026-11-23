# Сборка FOnline 412 C++14

Проверенная конфигурация — Windows, Visual Studio 2019 (MSVC v142), Windows SDK и CMake 3.20 или новее. Установите в Visual Studio компонент «Разработка классических приложений на C++». Для сборки DLL нужны Git и компилятор MSVC x86. Используйте **Release Win32** для движка и нативных скриптовых DLL.

Откройте PowerShell в общей папке, где находятся репозиторий и SDK:

```text
work/
  FOnline-412-cpp14/
    CMakeLists.txt
    build_server.bat
    build_clients.bat
    build_ascompiler.bat
    dll_compile_vs2019.bat
    sdk-cpp14-win32-abi.patch
  sdk/
    Client/
    Server/
      scripts/
        fonline_tla.cpp
    Tools/
      ASCompiler/
```

Команды ниже запускаются из этой общей папки. CMake складывает результаты в `FOnline-412-cpp14/build`. Для запуска клиенту и серверу нужны конфигурация и данные из соответствующей папки SDK.

## Сборка батниками

Запускайте нужные команды из общей папки:

```powershell
.\FOnline-412-cpp14\build_server.bat
.\FOnline-412-cpp14\build_clients.bat
.\FOnline-412-cpp14\build_ascompiler.bat
.\FOnline-412-cpp14\dll_compile_vs2019.bat
```

Сервер и ASCompiler собираются отдельно. `build_clients.bat` последовательно собирает OpenGL и D3D9 в разных папках. Все три батника оставляют EXE в папках сборки. Пути к результатам и команды копирования в SDK приведены ниже.

## Патч SDK и скриптовые DLL

`dll_compile_vs2019.bat` находит инструменты MSVC x86 через `vswhere.exe`. Он автоматически применяет `sdk-cpp14-win32-abi.patch` к исходному SDK, пропускает этот шаг на уже обновлённом SDK и останавливается с ошибкой, если патч не подходит. CMake не применяет патч. Патч синхронизирует размер массива `Critter::Scores` с движком и добавляет проверки смещений полей при компиляции DLL.

Батник собирает обе DLL во временной папке сборки. После успешной линковки он обновляет файлы в `sdk/Server/scripts`:

- `fonline_tla.dll` — серверная DLL.
- `fonline_tla_client.dll` — клиентская DLL для OpenGL и D3D9.

Перед обновлением DLL остановите сервер. Пересобирайте DLL при изменении их исходников, заголовков SDK или ABI движка. Вариант `dll_compile_vs2019_DEBUG.bat` использует ту же процедуру, но собирает клиентскую DLL в Debug. Серверная DLL в этом варианте собирается в Release.

Чтобы вручную проверить, применён ли патч, из общей папки выполните `git apply --reverse --check .\FOnline-412-cpp14\sdk-cpp14-win32-abi.patch`. Код возврата `0` означает, что изменения уже присутствуют.

## Сервер, клиент OpenGL и ASCompiler

Подготовьте сборку Release Win32 и соберите нужные цели. Можно перечислить несколько целей или выполнить одну команду сборки отдельно.

```powershell
cmake -S .\FOnline-412-cpp14 -B .\FOnline-412-cpp14\build -G "Visual Studio 16 2019" -A Win32 -DFONLINE_CLIENT_D3D=OFF
cmake --build .\FOnline-412-cpp14\build --config Release --target FOnlineServer
cmake --build .\FOnline-412-cpp14\build --config Release --target FOnlineClient
cmake --build .\FOnline-412-cpp14\build --config Release --target ASCompiler
```

При необходимости соберите редактор карт командой `cmake --build .\FOnline-412-cpp14\build --config Release --target Mapper`.

## Клиент Direct3D 9

Используйте отдельную папку сборки, чтобы сохранить оба варианта клиента:

```powershell
cmake -S .\FOnline-412-cpp14 -B .\FOnline-412-cpp14\build\d3d -G "Visual Studio 16 2019" -A Win32 -DFONLINE_CLIENT_D3D=ON
cmake --build .\FOnline-412-cpp14\build\d3d --config Release --target FOnlineClient
```

D3D9-клиент требует 32-битную `d3dx9_42.dll` из компонентов DirectX 9.

## Где взять файлы и как их обновить

Пути к результатам указаны относительно `FOnline-412-cpp14`.

| Компонент | Результат сборки | Папка для запуска |
| --- | --- | --- |
| Сервер | `build/bin/server/Release/FOnlineServer.exe` | `sdk/Server` |
| Клиент OpenGL | `build/bin/client/Release/FOnlineClient.exe` | `sdk/Client` |
| Клиент D3D9 | `build/d3d/bin/client/Release/FOnlineD3D.exe` | `sdk/Client` |
| ASCompiler | `build/bin/tools/Release/ASCompiler.exe` | `sdk/Tools/ASCompiler` |
| Mapper | `build/bin/tools/Release/Mapper.exe` | `sdk/Tools/Mapper` |

Скопируйте только те файлы, которые собрали. Пример размещает новые версии под отдельными именами рядом с файлами SDK:

```powershell
Copy-Item .\FOnline-412-cpp14\build\bin\server\Release\FOnlineServer.exe .\sdk\Server\FOnlineServer-cpp14.exe
Copy-Item .\FOnline-412-cpp14\build\bin\client\Release\FOnlineClient.exe .\sdk\Client\FOnlineClient-cpp14.exe
Copy-Item .\FOnline-412-cpp14\build\d3d\bin\client\Release\FOnlineD3D.exe .\sdk\Client\FOnlineD3D-cpp14.exe
Copy-Item .\FOnline-412-cpp14\build\bin\tools\Release\ASCompiler.exe .\sdk\Tools\ASCompiler\ASCompiler-cpp14.exe
```

Сервер пересобирайте, когда меняется его код, настройки сборки или ABI. Остановите запущенный экземпляр перед заменой его EXE или DLL. Для запуска сервера используйте `sdk/Server/FOnlineServer-cpp14.exe`, для автоматического старта добавьте аргумент `-start`. Клиенты запускаются из `sdk/Client` и используют `FOnline.cfg`, если рядом нет конфигурации с тем же именем, что у EXE.

Оба клиента используют один и тот же сервер. Для смены OpenGL на Direct3D 9 достаточно собрать и запустить соответствующий клиент.

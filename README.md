# FOnline CMake Build System

Этот проект представляет собой современную систему сборки для FOnline, использующую CMake для построения всех компонентов проекта.

## Компоненты проекта

- **Client** - клиентская часть игры
- **Server** - серверная часть игры
- **ASCompiler** - компилятор скриптов AngelScript
- **Mapper** - редактор карт

## Требования

- CMake 3.20 или выше
- Компилятор C++ с поддержкой C++14
- Для Windows: Visual Studio 2019 или выше
- Для Linux: GCC 7 или выше, либо Clang 6 или выше

## Сборка

### Windows

1. Убедитесь, что у вас установлены Visual Studio и CMake
2. Откройте командную строку или PowerShell
3. Выполните команды:

```cmd
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019" -A Win32
cmake --build . --config Release
```

### Linux/macOS

1. Убедитесь, что у вас установлены GCC/Clang и CMake
2. Откройте терминал
3. Выполните команды:

```bash
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

## Конфигурация

CMakeLists.txt файл настроен с учетом следующих особенностей:

- Использование C++14 стандарта
- Поддержка Windows-specific библиотек из папки Lib
- Настройка зависимостей для DirectX, OpenGL и других библиотек
- Поддержка многопоточной компиляции
- Исключено использование StlPort (как в оригинальных проектах)

## Вывод

Собранные исполняемые файлы будут находиться в подкаталогах:

- `bin/client/` - клиент
- `bin/server/` - сервер
- `bin/tools/` - ASCompiler и Mapper
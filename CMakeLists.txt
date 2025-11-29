cmake_minimum_required(VERSION 3.20)

# Set project name and version
project(FOnline VERSION 1.0.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Find required packages
find_package(Threads REQUIRED)

# Check if we're on Windows and find additional libraries
if(WIN32)
    # On Windows, we might need additional libraries
    find_library(DINPUT8_LIBRARY dinput8)
    find_library(DXGUID_LIBRARY dxguid)
    find_library(WINMM_LIBRARY winmm)
    find_library(WS2_32_LIBRARY ws2_32)
    find_library(DSOUND_LIBRARY dsound)
    find_library(DDRAW_LIBRARY ddraw)
endif()

add_compile_definitions(_ITERATOR_DEBUG_LEVEL=0)

# Define common include directories
set(COMMON_INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/Source
)

# Define common compile definitions
set(COMMON_COMPILE_DEFINITIONS
    _CRT_SECURE_NO_WARNINGS
    _CRT_SECURE_NO_DEPRECATE
    _CRT_NONSTDC_NO_DEPRECATE
)

# Define common source files used across multiple targets
set(COMMON_ANGELSCRIPT_SOURCES
    Source/AngelScript/as_atomic.cpp
    Source/AngelScript/as_builder.cpp
    Source/AngelScript/as_bytecode.cpp
    Source/AngelScript/as_callfunc.cpp
    Source/AngelScript/as_callfunc_x64_gcc.cpp
    Source/AngelScript/as_callfunc_x64_msvc.cpp
    Source/AngelScript/as_callfunc_x86.cpp
    Source/AngelScript/as_compiler.cpp
    Source/AngelScript/as_configgroup.cpp
    Source/AngelScript/as_context.cpp
    Source/AngelScript/as_datatype.cpp
    Source/AngelScript/as_gc.cpp
    Source/AngelScript/as_generic.cpp
    Source/AngelScript/as_globalproperty.cpp
    Source/AngelScript/as_memory.cpp
    Source/AngelScript/as_module.cpp
    Source/AngelScript/as_objecttype.cpp
    Source/AngelScript/as_outputbuffer.cpp
    Source/AngelScript/as_parser.cpp
    Source/AngelScript/as_restore.cpp
    Source/AngelScript/as_scriptcode.cpp
    Source/AngelScript/as_scriptengine.cpp
    Source/AngelScript/as_scriptfunction.cpp
    Source/AngelScript/as_scriptnode.cpp
    Source/AngelScript/as_scriptobject.cpp
    Source/AngelScript/as_string.cpp
    Source/AngelScript/as_string_util.cpp
    Source/AngelScript/as_thread.cpp
    Source/AngelScript/as_tokenizer.cpp
    Source/AngelScript/as_typeinfo.cpp
    Source/AngelScript/as_variablescope.cpp
    Source/AngelScript/preprocessor.cpp
    Source/AngelScript/scriptany.cpp
    Source/AngelScript/scriptarray.cpp
    Source/AngelScript/scriptdictionary.cpp
    Source/AngelScript/scriptfile.cpp
    Source/AngelScript/scriptmath.cpp
    Source/AngelScript/scriptstring.cpp
)

set(COMMON_ZLIB_SOURCES
    Source/Zlib/adler32.c
    Source/Zlib/compress.c
    Source/Zlib/crc32.c
    Source/Zlib/deflate.c
    Source/Zlib/infback.c
    Source/Zlib/inffast.c
    Source/Zlib/inflate.c
    Source/Zlib/inftrees.c
    Source/Zlib/ioapi.c
    Source/Zlib/trees.c
    Source/Zlib/uncompr.c
    Source/Zlib/unzip.c
    Source/Zlib/zutil.c
)

set(COMMON_DATFILE_SOURCES
    Source/datfile/cfile.cpp
    Source/datfile/unlzss.cpp
)

set(COMMON_CRYPTO_SOURCES
    Source/SHA2/sha2.c
)

set(COMMON_FILE_SOURCES
    Source/FileSystem.cpp
    Source/DataFile.cpp
    Source/FileManager.cpp
)

set(COMMON_MISC_SOURCES
    Source/Common.cpp
    Source/Crypt.cpp
    Source/Debugger.cpp
    Source/Exception.cpp
    Source/IniParser.cpp
    Source/Log.cpp
    Source/ScriptPragmas.cpp
    Source/Text.cpp
    Source/Timer.cpp
    Source/MsgFiles.cpp
)

# Client target
set(CLIENT_SOURCES
    ${COMMON_ANGELSCRIPT_SOURCES}
    ${COMMON_ZLIB_SOURCES}
    ${COMMON_DATFILE_SOURCES}
    ${COMMON_CRYPTO_SOURCES}
    ${COMMON_FILE_SOURCES}
    ${COMMON_MISC_SOURCES}
    Source/3dStuff.cpp
    Source/BufferManager.cpp
    Source/Client.cpp
    Source/ClientInterface.cpp
    Source/ConstantsManager.cpp
    Source/CraftManager.cpp
    Source/CritterCl.cpp
    Source/CritterType.cpp
    Source/GraphicLoader.cpp
    Source/HexManager.cpp
    Source/Item.cpp
    Source/ItemHex.cpp
    Source/ItemManager.cpp
    Source/Keyboard.cpp
    Source/ResourceManager.cpp
    Source/Script.cpp
    Source/SoundManager.cpp
    Source/SpriteManager.cpp
    Source/SpriteManagerFont.cpp
    Source/Sprites.cpp
    Source/StdAfx.cpp
    Source/MainClient.cpp
    Source/Acm/acmstrm.cpp
    Source/GL/glew.c
    Source/LegacyFix.cpp
)

add_executable(FOnlineClient ${CLIENT_SOURCES})
target_include_directories(FOnlineClient PRIVATE ${COMMON_INCLUDE_DIRS} Source/Dx9)
target_compile_definitions(FOnlineClient PRIVATE ${COMMON_COMPILE_DEFINITIONS} FONLINE_CLIENT AS_NO_THREADS)
target_link_libraries(FOnlineClient PRIVATE Threads::Threads)
if(MSVC)

    target_link_options(FOnlineClient PRIVATE /NXCOMPAT:NO /DYNAMICBASE:NO /STACK:4194304)
    # Игнорируем конфликт типов библиотек
    target_link_options(FOnlineClient PRIVATE $<$<CONFIG:Debug>:/NODEFAULTLIB:LIBCMT>)
    
    target_link_options(FOnlineClient PRIVATE /FORCE:MULTIPLE)
    # Статическая линковка
    set_property(TARGET FOnlineClient PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    target_compile_definitions(FOnlineClient PRIVATE _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
endif()
if(WIN32)
    target_link_libraries(FOnlineClient PRIVATE
        ${DINPUT8_LIBRARY}
        ${DXGUID_LIBRARY}
        ${WINMM_LIBRARY}
        ${WS2_32_LIBRARY}
        ${DSOUND_LIBRARY}
        ${DDRAW_LIBRARY}
        opengl32
        glu32
        legacy_stdio_definitions.lib
        oldnames.lib
    )
    # Add Windows-specific libraries from Lib directory
    target_link_directories(FOnlineClient PRIVATE ${CMAKE_SOURCE_DIR}/Lib ${CMAKE_SOURCE_DIR}/Lib/Dx9/x86)
    target_link_libraries(FOnlineClient PRIVATE
        IL.lib jpeg.lib libogg_static.lib libpng15.lib libtheora_static.lib
        libvorbis_static.lib libvorbisfile_static.lib portaudio.lib pthreadVC2.lib
        dxguid.lib d3d9.lib d3dx9.lib
    )
endif()
set_target_properties(FOnlineClient PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/client
)

# Server target
set(SERVER_SOURCES
    ${COMMON_ANGELSCRIPT_SOURCES}
    ${COMMON_ZLIB_SOURCES}
    ${COMMON_DATFILE_SOURCES}
    ${COMMON_CRYPTO_SOURCES}
    ${COMMON_FILE_SOURCES}
    ${COMMON_MISC_SOURCES}
    Source/AI.cpp
    Source/BufferManager.cpp
    Source/ConstantsManager.cpp
    Source/CraftManager.cpp
    Source/Critter.cpp
    Source/CritterManager.cpp
    Source/CritterType.cpp
    Source/Dialogs.cpp
    Source/Item.cpp
    Source/ItemManager.cpp
    Source/Jobs.cpp
    Source/Map.cpp
    Source/MapManager.cpp
    Source/ProtoMap.cpp
    Source/Script.cpp
    Source/Server.cpp
    Source/ServerClient.cpp
    Source/ServerItem.cpp
    Source/ServerNpc.cpp
    Source/ServerScript.cpp
    Source/StdAfx.cpp
    Source/ThreadSync.cpp
    Source/Vars.cpp
    Source/MainServer.cpp
    Source/LegacyFix.cpp
)

add_executable(FOnlineServer ${SERVER_SOURCES})
target_include_directories(FOnlineServer PRIVATE ${COMMON_INCLUDE_DIRS})
target_compile_definitions(FOnlineServer PRIVATE ${COMMON_COMPILE_DEFINITIONS} FONLINE_SERVER SCRIPT_MULTITHREADING)
target_link_libraries(FOnlineServer PRIVATE Threads::Threads)
if(WIN32)
    target_link_libraries(FOnlineServer PRIVATE
        ${WINMM_LIBRARY}
        ${WS2_32_LIBRARY}
        legacy_stdio_definitions.lib
        oldnames.lib
    )
    # Add Windows-specific libraries from Lib directory
    target_link_directories(FOnlineServer PRIVATE ${CMAKE_SOURCE_DIR}/Lib)
    target_link_libraries(FOnlineServer PRIVATE
        IL.lib jpeg.lib libogg_static.lib libpng15.lib libtheora_static.lib
        libvorbis_static.lib libvorbisfile_static.lib portaudio.lib pthreadVC2.lib
    )
endif()
set_target_properties(FOnlineServer PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/server
)

# ASCompiler target
set(ASCOMPILER_SOURCES
    ${COMMON_ANGELSCRIPT_SOURCES}
    ${COMMON_ZLIB_SOURCES}
    ${COMMON_DATFILE_SOURCES}
    ${COMMON_CRYPTO_SOURCES}
    ${COMMON_FILE_SOURCES}
    ${COMMON_MISC_SOURCES}
    Source/ASCompiler.cpp
    Source/Zlib/gzclose.c
    Source/Zlib/gzlib.c
    Source/Zlib/gzread.c
    Source/Zlib/gzwrite.c
)

add_executable(ASCompiler ${ASCOMPILER_SOURCES})
target_include_directories(ASCompiler PRIVATE ${COMMON_INCLUDE_DIRS})
target_compile_definitions(ASCompiler PRIVATE ${COMMON_COMPILE_DEFINITIONS} FONLINE_SCRIPT_COMPILER)
target_link_libraries(ASCompiler PRIVATE Threads::Threads)
if(WIN32)
    target_link_libraries(ASCompiler PRIVATE
        ${WINMM_LIBRARY}
        ${WS2_32_LIBRARY}
        legacy_stdio_definitions.lib
        oldnames.lib
    )
    # Add Windows-specific libraries from Lib directory
    target_link_directories(ASCompiler PRIVATE ${CMAKE_SOURCE_DIR}/Lib)
    target_link_libraries(ASCompiler PRIVATE
        IL.lib jpeg.lib libogg_static.lib libpng15.lib libtheora_static.lib
        libvorbis_static.lib libvorbisfile_static.lib portaudio.lib pthreadVC2.lib
    )
endif()
set_target_properties(ASCompiler PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/tools
)

# Mapper target
set(MAPPER_SOURCES
    ${COMMON_ANGELSCRIPT_SOURCES}
    ${COMMON_ZLIB_SOURCES}
    ${COMMON_DATFILE_SOURCES}
    ${COMMON_CRYPTO_SOURCES}
    ${COMMON_FILE_SOURCES}
    ${COMMON_MISC_SOURCES}
    Source/3dStuff.cpp
    Source/ConstantsManager.cpp
    Source/CritterCl.cpp
    Source/CritterManager.cpp
    Source/CritterType.cpp
    Source/GraphicLoader.cpp
    Source/HexManager.cpp
    Source/Item.cpp
    Source/ItemHex.cpp
    Source/ItemManager.cpp
    Source/Keyboard.cpp
    Source/Mapper.cpp
    Source/ProtoMap.cpp
    Source/ResourceManager.cpp
    Source/Script.cpp
    Source/SpriteManager.cpp
    Source/SpriteManagerFont.cpp
    Source/Sprites.cpp
    Source/StdAfx.cpp
    Source/MainMapper.cpp
    Source/GL/glew.c
    Source/LegacyFix.cpp
)

add_executable(Mapper ${MAPPER_SOURCES})
target_include_directories(Mapper PRIVATE ${COMMON_INCLUDE_DIRS} Source/Dx9)
target_compile_definitions(Mapper PRIVATE ${COMMON_COMPILE_DEFINITIONS} FONLINE_MAPPER AS_NO_THREADS)
target_link_libraries(Mapper PRIVATE Threads::Threads)
if(WIN32)
    target_link_libraries(Mapper PRIVATE
        ${DINPUT8_LIBRARY}
        ${DXGUID_LIBRARY}
        ${WINMM_LIBRARY}
        ${WS2_32_LIBRARY}
        ${DSOUND_LIBRARY}
        ${DDRAW_LIBRARY}
        opengl32
        glu32
        legacy_stdio_definitions.lib
        oldnames.lib
    )
    # Add Windows-specific libraries from Lib directory
    target_link_directories(Mapper PRIVATE ${CMAKE_SOURCE_DIR}/Lib ${CMAKE_SOURCE_DIR}/Lib/Dx9/x86)
    target_link_libraries(Mapper PRIVATE
        IL.lib jpeg.lib libogg_static.lib libpng15.lib libtheora_static.lib
        libvorbis_static.lib libvorbisfile_static.lib portaudio.lib pthreadVC2.lib
        dxguid.lib d3d9.lib d3dx9.lib
    )
endif()
set_target_properties(Mapper PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/tools
)

# Install rules
install(TARGETS FOnlineClient FOnlineServer ASCompiler Mapper
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Additional compile options for all targets
if(MSVC)
    # Microsoft Visual C++ specific options
    target_compile_options(FOnlineClient PRIVATE /W3 /MP)
    target_compile_options(FOnlineServer PRIVATE /W3 /MP)
    target_compile_options(ASCompiler PRIVATE /W3 /MP)
    target_compile_options(Mapper PRIVATE /W3 /MP)
    add_compile_definitions(
        HAVE_STRUCT_TIMESPEC
        _SILENCE_CXX17_STRSTREAM_DEPRECATION_WARNING
        _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
        _HAS_STD_BYTE=0 
    )
    # Set runtime library options
    set_property(TARGET FOnlineClient FOnlineServer ASCompiler Mapper
        PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
    )
else()
    # GCC/Clang specific options
    target_compile_options(FOnlineClient PRIVATE -Wall -Wextra -pthread)
    target_compile_options(FOnlineServer PRIVATE -Wall -Wextra -pthread)
    target_compile_options(ASCompiler PRIVATE -Wall -Wextra -pthread)
    target_compile_options(Mapper PRIVATE -Wall -Wextra -pthread)
endif()

# Set Windows subsystem for GUI applications
set_target_properties(FOnlineClient PROPERTIES WIN32_EXECUTABLE TRUE)
set_target_properties(Mapper PROPERTIES WIN32_EXECUTABLE TRUE)
set_target_properties(FOnlineServer PROPERTIES WIN32_EXECUTABLE FALSE)
set_target_properties(ASCompiler PROPERTIES WIN32_EXECUTABLE FALSE)


#include <stdio.h>

// 1. Фикс для _wopen
#pragma comment(linker, "/alternatename:?_wopen@@YAHPB_WHH@Z=__wopen")

// 2. Фикс для ___iob_func (САМОЕ ВАЖНОЕ)
// Мы создаем массив байт, достаточный, чтобы вместить 3 старых структуры FILE.
// Старые библиотеки будут писать сюда флаги, но так как мы этот массив не читаем,
// ничего страшного не случится.
// 3 файла * 64 байта (с запасом) = массив.
char fake_iob_array[3][64] = { 0 };

// Объявляем функцию с ДВУМЯ подчеркиваниями. 
// На x86 это превратится в ___iob_func (то, что ищут jpeg/libpng).
extern "C" void* __cdecl __iob_func(void)
{
    // Возвращаем указатель на наш фальшивый массив.
    // Теперь PortAudio и libpng не получат NULL и не вызовут Access Violation.
    return fake_iob_array;
}

// 3. Отключаем вывод PortAudio (чтобы он не спамил в наш фальшивый файл)
extern "C" void PaUtil_DebugPrint(const char *format, ...)
{
    // Пусто
}
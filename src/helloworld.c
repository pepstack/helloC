/**
 * @file helloworld.c
 * @author 350137278@qq.com
 * @brief 一个最简单 C 程序
 * @version 0.1
 * @date 2024-09-28
 * 
 * @copyright Copyright (c) 2024, mapaware.top
 * 
 * @note
 *   下载本工程:
 *     https://github.com/pepstack/helloC.git
 * 
 *   vscode 预定义变量:
 *     https://code.visualstudio.com/docs/editor/variables-reference
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/**
 * helloworld 程序主入口
 * 
 */
int main(int argc, char * argv[])
{
#ifdef __MINGW64__
	printf("hello world from MingW.\n");
#else
    printf("hello world from Linux.\n");
#endif

    return 0;
}
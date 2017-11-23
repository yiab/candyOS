/*****************************************************************
 * Copyright(c) 2012, 武汉中原电子集团 应用电子研发中心
 * All rights reserved.
 * *
 * 文件名称:
 *
 * 摘要:
 *
 * 作者:
 *
 * 完成日期:
 *****************************************************************/
/*--------------------------- 预处理区 --------------------------*/
/***************************** 头文件 ****************************/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

/*-------------------------- 变量实现区 -------------------------*/
/**************************** 全局变量 ***************************/

/**************************** 文件变量 ***************************/

/*------------------------ 局部函数声明区 -----------------------*/
static void mem_test(long size, long times);

/*-------------------------- 函数实现区 --------------------------*/
int main(int argc, char *argv[])
{
    long size = 0;
    long times = 0;

    if(3 != argc)
    {
        printf("Usage:\n");
        printf("        %s size(MB) times\n", argv[0]);
        exit(-1);
    } 

    size = atol(argv[1]) * 1024 * 1024;
    times = atol(argv[2]);

    mem_test(size, times);

    return 0;
}
static void my_memcpy(char *ptr1, char *ptr2, int size)
{
	int c = size >> 2;
	int d = size - (c << 2);

/*	printf("%d = %d * 4 + %d.\n", size, c, d);
*/
	int *p1 = (int *) ptr1;
	int *p2 = (int *) ptr2;
	int i = 0;
	for (i = 0; i < c; i++)
	{
		*(p1++) = *(p2++);
		
	}
	
	char *t1 = (char *) p1;
	char *t2 = (char *) p2;
	for (i = 0; i < d; i++)
	{
		*(t1++) = *(t2++);
	}
}

static void mem_test(long size, long times)
{
    int i = 0;
    char *p_mem1 = NULL;
    char *p_mem2 = NULL;
    clock_t start = 0;
    clock_t finish = 0;
    clock_t test_time = 0;


    p_mem1 = (char *) malloc(size);
    if(NULL == p_mem1)
    {
        printf("not Mem enough.\n");
        goto P_MEM1_MALLOC_ERR;
    }

    p_mem2 = (char *) malloc(size);
    if(NULL == p_mem2)
    {
        printf("not Mem enough.\n");
        goto P_MEM2_MALLOC_ERR;
    }

	char *ptr1,*ptr2;
	ptr1 = p_mem1;
	ptr2 = p_mem2;
    start = clock();

    for(i=0;i<times;i++)
    {
        my_memcpy(ptr1, ptr2, size);
        char *tmp;
        tmp = ptr1; ptr1 = ptr2; ptr2 = tmp;
    }

    finish = clock();
    test_time = finish - start;

    printf("copy %ld MB %ld times cost: %f s\n", size/1024, times, 1.0*test_time/CLOCKS_PER_SEC);

    free(p_mem2);

P_MEM2_MALLOC_ERR:
    free(p_mem1);
    return;

P_MEM1_MALLOC_ERR:
    return;

}

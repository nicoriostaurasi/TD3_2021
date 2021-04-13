#include "../inc/functions.h"

__attribute__((section(".my_func")))
int performSum(int a,int b)
{
    return a+b;
}
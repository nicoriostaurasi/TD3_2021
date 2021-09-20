#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define SMOBJ_NAME "/myMemoryObj"

int main(void)
{   
    char buf[]="Hello this is the writting process\n";
    int fd;
    char *ptr;
    fd=shm_open(SMOBJ_NAME,O_RDWR,0);

    if(fd==-1)
    {
        printf("error, shared memory could not be open\n");
        exit(1);
    }
    ptr=mmap(0,sizeof(buf),PROT_WRITE,MAP_SHARED,fd,0);

    if(ptr==MAP_FAILED)
    {
        printf("Error in memory mapping\n");
    }

    memcpy(ptr,buf,sizeof(buf));


    close(fd);
    return 0;
} 
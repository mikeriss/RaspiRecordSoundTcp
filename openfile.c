#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#define MB (1024*1024)



int main()
{
  int fd = 0;
  int byteRead = 0;
  char * Memory = malloc(0.5*MB);
	if((fd = open("test4.wav",O_RDONLY)) == -1) printf("Error file open\n");
  printf("%d\n",fd);
  
  if((byteRead = read(fd,Memory,480044)) == -1) printf("Read failure\n");
  printf("%d\n",byteRead);
  
  close(fd);
}

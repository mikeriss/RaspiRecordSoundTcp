#include <stdio.h> //printf
#include <string.h>    //strlen
#include <sys/socket.h>    //socket
#include <arpa/inet.h> //inet_addr
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>

void error(char *msg) {
    perror(msg);
    exit(0);
}



int main(int argc , char *argv[])
{
    struct timeval time;
    
    while(1)
    {
      gettimeofday(&time, 0);
      if((time.tv_sec+1)%5 == 0) 
      {
        sleep(1);
        printf("%d\n", time.tv_sec); 
      }
    }
    //printf("%d", time.tv_sec);
 
    return 0;
}
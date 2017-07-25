#include <stdio.h> //printf
#include <string.h>    //strlen
#include <sys/socket.h>    //socket
#include <arpa/inet.h> //inet_addr
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>

#define SRV_IP "192.168.0.13"
#define PORT 55056
#define FIVESECONDS 5 

#define MB (1024*1024)

void error(char *msg) {
    perror(msg);
    exit(0);
}

int Record(int durationInSec)
{
  	char *buf;
	asprintf(&buf,"arecord -r 48000 -f S16_LE -D plughw:CARD=AK5371 -d %d test3.wav",durationInSec); /* do not forget error check */
	system(buf);
	free(buf); //dont forget
}


//malloc buffer, read file, 
//returns pointer of file read

int openFile(char *path)
{
  printf("readFile called");
    //open the file and read
  int fd = 0;
	if((fd = open(path,O_RDONLY)) == -1) error("Error file open\n");
  //printf("%d\n",fd);
  
  return fd;
}

int ReadFile(int fd, char* Memory, int size)
{
  int byteRead;
  if((byteRead = read(fd,Memory,480044)) == -1) error("Read failure\n");
  printf("Bytes Read: %d\n",byteRead); 
  
  return byteRead;
] 

int main(int argc , char *argv[])
{
    int sock;
    struct sockaddr_in server;
    char message[1000] , server_reply[2000];
	struct timeval time;
     
    //Create socket
    sock = socket(AF_INET , SOCK_STREAM , 0);
    if (sock == -1) error("Could not create socket");

    puts("Socket created");
     
    server.sin_addr.s_addr = inet_addr(SRV_IP);
    server.sin_family = AF_INET;
    server.sin_port = htons( PORT );
 
    //Connect to remote server
    if (connect(sock , (struct sockaddr *)&server , sizeof(server)) < 0) error("connect failed. Error");
     
    puts("Connected\n");
    char *Memory = malloc(0.5*MB);
    int fd = openFile("test3.wav");
    //keep communicating with server
    while(1)
    {
	  gettimeofday(&time, 0);
      if((time.tv_sec+3)%5 == 0) 
      {
        record(3); 
		printf("%d\n", time.tv_sec); 
		
        if( send(sock , Memory , readFile(fd, Memory, 288044 ) , 0) < 0)
        {
            printf("send failed\n");
            break;
        }
		sleep(0.8);
      }
		
         
    }
     
    free(Memory);
    close(sock);
    return 0;
}
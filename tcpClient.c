#include <stdio.h> //printf
#include <string.h>    //strlen
#include <sys/socket.h>    //socket
#include <arpa/inet.h> //inet_addr
#include <stdlib.h>

#define SRV_IP "192.168.0.13"
#define PORT 55056

void error(char *msg) {
    perror(msg);
    exit(0);
}
 
int main(int argc , char *argv[])
{
    int sock;
    struct sockaddr_in server;
    char message[1000] , server_reply[2000];
     
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
     
    //keep communicating with server
    message = "HALLO\0 from Raspi";
    while(1)
    {
        printf("Enter message : ");
        scanf("%s" , message);
         
        //Send some data
        if( send(sock , message , strlen(message) , 0) < 0)
        {
            puts("Send failed");
            break;
        }
        
        sleep(FIVESECONDS);
        //Receive a reply from the server
        //if( recv(sock , server_reply , 2000 , 0) < 0)
        //{
        //    puts("recv failed");
        //    break;
        //}
         
        //puts("Server reply :");
        //puts(server_reply);
    }
    printf("something failed");
    close(sock);
    return 0;
}
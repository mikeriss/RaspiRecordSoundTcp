#include <stdio.h>
#include <stdlib.h>

int main()
{
	printf("Hallo\n");
	printf("%s\n", system("arecord -r 48000 -f S16_LE -D plughw:CARD=AK5371 -d 5 test4.wav"));
  printf("end record");
}

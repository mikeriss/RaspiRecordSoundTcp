CFLAGS += -W -Wall -Wextra -Werror  -std=c11
DFLAGS = -ggdb3

all: RecordNReadFileAndSendTcp

output: RecordNReadFileAndSendTcp.o
	$(CC) $(CFLAGS) $^ -o $@

RecordNReadFileAndSendTcp:

clean:
	$(RM) *.o 
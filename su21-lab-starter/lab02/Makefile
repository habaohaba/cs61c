CC=gcc
CFLAGS=-Wall -std=c99 -g

all: linked_list 

linked_list: linked_list.o test_linked_list.o
	$(CC) -o linked_list linked_list.o test_linked_list.o

linked_list.o: linked_list.c linked_list.h
	$(CC) $(CFLAGS) -c linked_list.c

test_linked_list.o: test_linked_list.c linked_list.h
	$(CC) $(CFLAGS) -c test_linked_list.c

bit_ops: bit_ops.c test_bit_ops.c
	$(CC) -o bit_ops bit_ops.c test_bit_ops.c

vector: vector vector.c test_vector.c
	$(CC) -g vector.c test_vector.c -o vector 

clean:
	rm linked_list linked_list.o test_linked_list.o bit_ops vector

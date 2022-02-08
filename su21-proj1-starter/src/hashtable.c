#include "hashtable.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
 * This creates a new hash table of the specified size and with
 * the given hash function and comparison function.
 */
HashTable *createHashTable(int size, unsigned int (*hashFunction)(void *),
                           int (*equalFunction)(void *, void *)) {
  int i = 0;
  HashTable *newTable = malloc(sizeof(HashTable));
  if (NULL == newTable) {
    fprintf(stderr, "malloc failed \n");
    exit(1);
  }
  newTable->size = size;
  newTable->data = malloc(sizeof(HashBucket *) * size);
  if (NULL == newTable->data) {
    fprintf(stderr, "malloc failed \n");
    exit(1);
  }
  for (i = 0; i < size; i++) {
    newTable->data[i] = NULL;
  }
  newTable->hashFunction = hashFunction;
  newTable->equalFunction = equalFunction;
  return newTable;
}

/*
 * This inserts a key/data pair into a hash table.  To use this
 * to store strings, simply cast the char * to a void * (e.g., to store
 * the string referred to by the declaration char *string, you would
 * call insertData(someHashTable, (void *) string, (void *) string).
 */
void insertData(HashTable *table, void *key, void *data) {
  // -- TODO --
  // HINT:
  // 1. Find the right hash bucket location with table->hashFunction.
  // 2. Allocate a new hash bucket struct.
  // 3. Append to the linked list or create it if it does not yet exist. 
  int location = table->hashFunction(key) % table->size;
  //malloc memory size
  HashBucket *newBucket = malloc(sizeof(HashBucket));
  newBucket->key = malloc(sizeof(void));
  newBucket->data = malloc(sizeof(char) * (strlen(data) + 1));
  newBucket->next = malloc(sizeof(HashBucket));
  //set value
  newBucket->*key = *key;
  newBucket->data = strcpy(newBucket->data, data);
  newBucket->next = NULL;
  //check if data[location] is empty.
  if (table->data[location] == NULL) {
      table->data[location] = newBucket;
      return;
  }
  //check if key exist
  HashBucket *prev = table->data[location];
  for(HashBucket *curr = table->data[location]; curr != NULL; curr = prev->next) {
    if (table->equalFunction(curr->key, key)) {
        curr->data = strcpy(curr->data, data);
        free(newBucket->key);
        free(newBucket->data);
        free(newBucket->next);
        free(newBucket);
        return;
    }
    prev = curr;
  }
  //append new bucket if key does not exist.
  prev->next = newBucket;
}

/*
 * This returns the corresponding data for a given key.
 * It returns NULL if the key is not found. 
 */
void *findData(HashTable *table, void *key) {
  // -- TODO --
  // HINT:
  // 1. Find the right hash bucket with table->hashFunction.
  // 2. Walk the linked list and check for equality with table->equalFunction.
  int location = table->hashFunction(key) % table->size;
  for (hashBucket *curr = table->data[location]; curr != NULL; curr = curr->next){
      if(table->equalFunction(curr->key, key)) { 
          return curr->data;
      }
  } 
  return NULL;
}

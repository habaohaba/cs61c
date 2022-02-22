/*
 * Include the provided hash table library.
 */
#include "hashtable.h"

/*
 * Include the header file.
 */
#include "philphix.h"

/*
 * Standard IO and file routines.
 */
#include <stdio.h>

/*
 * General utility routines (including malloc()).
 */
#include <stdlib.h>

/*
 * Character utility routines.
 */
#include <ctype.h>

/*
 * String utility routines.
 */
#include <string.h>

/*
 * This hash table stores the dictionary.
 */
HashTable *dictionary;

/*
 * The MAIN routine.  You can safely print debugging information
 * to standard error (stderr) as shown and it will be ignored in 
 * the grading process.
 */
int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "Specify a dictionary\n");
    return 1;
  }
  /*
   * Allocate a hash table to store the dictionary.
   */
  fprintf(stderr, "Creating hashtable\n");
  dictionary = createHashTable(0x61C, &stringHash, &stringEquals);

  fprintf(stderr, "Loading dictionary %s\n", argv[1]);
  readDictionary(argv[1]);
  fprintf(stderr, "Dictionary loaded\n");

  fprintf(stderr, "Processing stdin\n");
  processInput();

  /*
   * The MAIN function in C should always return 0 as a way of telling
   * whatever program invoked this that everything went OK.
   */
  return 0;
}

/*
 * This should hash a string to a bucket index.  void *s can be safely cast
 * to a char * (null terminated string)
 */
unsigned int stringHash(void *s) {
  //fprintf(stderr, "need to implement stringHash\n");
  /* To suppress compiler warning until you implement this function, */
  unsigned int hashNumber = 0;
  char *c = s;
  while (*c != '\0') {
      hashNumber = hashNumber + *c;
      c = c + 1;
  }
  return hashNumber;
}

/*
 * This should return a nonzero value if the two strings are identical 
 * (case sensitive comparison) and 0 otherwise.
 */
int stringEquals(void *s1, void *s2) {
  //fprintf(stderr, "You need to implement stringEquals");
  /* To suppress compiler warning until you implement this function */
  char *c1 = (char *) s1;
  char *c2 = (char *) s2;
  if (strcmp(c1, c2) == 0) {
      return 1;
  } else {
      return 0;
  }
}

/*
 * This function should read in every word and replacement from the dictionary
 * and store it in the hash table.  You should first open the file specified,
 * then read the words one at a time and insert them into the dictionary.
 * Once the file is read in completely, return.  You will need to allocate
 * (using malloc()) space for each word.  As described in the spec, you
 * can initially assume that no word is longer than 60 characters.  However,
 * for the final bit of your grade, you cannot assumed that words have a bounded
 * length.  You CANNOT assume that the specified file exists.  If the file does
 * NOT exist, you should print some message to standard error and call exit(61)
 * to cleanly exit the program.
 */
void readDictionary(char *dictName) {
  // -- TODO --
  //fprintf(stderr, "You need to implement readDictionary\n");

  //open file
  FILE *fp;
  fp = fopen(dictName, "r");
  if (fp == NULL) {
      fprintf(stderr, "Can not open dict.\n");
      exit(61);
  }
  //process word
  char string1[70];
  char string2[70];
  fscanf(fp, "%s", string1);
  int status = fscanf(fp, "%s", string2);
  while (status != EOF){
      char *key = malloc(sizeof(char) * (strlen(string1)+1));
      char *data = malloc(sizeof(char) * (strlen(string2)+1));
      strcpy(key, string1);
      strcpy(data, string2);
      key[strlen(string1)] = '\0';
      data[strlen(string2)] = '\0';
      insertData(dictionary, key, data);
      fscanf(fp, "%s", string1);
      status = fscanf(fp, "%s", string2);
  } 
  //close file
  fclose(fp);
}

/*
 * This should process standard input (stdin) and perform replacements as 
 * described by the replacement set then print either the original text or 
 * the replacement to standard output (stdout) as specified in the spec (e.g., 
 * if a replacement set of `taest test\n` was used and the string "this is 
 * a taest of  this-proGram" was given to stdin, the output to stdout should be 
 * "this is a test of  this-proGram").  All words should be checked
 * against the replacement set as they are input, then with all but the first
 * letter converted to lowercase, and finally with all letters converted
 * to lowercase.  Only if all 3 cases are not in the replacement set should 
 * it report the original word.
 *
 * Since we care about preserving whitespace and pass through all non alphabet
 * characters untouched, scanf() is probably insufficent (since it only considers
 * whitespace as breaking strings), meaning you will probably have
 * to get characters from stdin one at a time.
 *
 * Do note that even under the initial assumption that no word is longer than 60
 * characters, you may still encounter strings of non-alphabetic characters (e.g.,
 * numbers and punctuation) which are longer than 60 characters. Again, for the 
 * final bit of your grade, you cannot assume words have a bounded length.
 */
void processInput() {
  //fprintf(stderr, "You need to implement processInput\n");
  char c;
  char word[70];
  int i = 0;
  while ((c = fgetc(stdin)) != EOF) {
    if (isalpha(c)) {
        word[i] = c;
        i++;
    } else {
        //not alpha
        word[i] = '\0';
        if (word[0] != '\0') {
            //catch a world
            char tmp[70];
            char *out;
            strcpy(tmp, word);
            //condition one
            out = findData(dictionary, tmp);
            if (out != NULL) {
                fprintf(stdout, "%s", out);
            } else {
                //conditoin two
                for (int j =1; tmp[j] != '\0'; j++) {
                        tmp[j] = tolower(tmp[j]);
                    } 
                out = findData(dictionary, tmp);
                if (out != NULL) {
                    fprintf(stdout, "%s", out);
                } else {
                    //condition three
                    tmp[0] = tolower(tmp[0]);
                    out = findData(dictionary, tmp);
                    if (out != NULL) {
                        fprintf(stdout, "%s", out);
                    } else {
                    //print same world
                    fprintf(stdout, "%s", word);
                    }
                }
            }
        }
        i = 0;
        putchar(c);
    }
  }
}

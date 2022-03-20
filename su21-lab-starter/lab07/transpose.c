#include "transpose.h"

/* The naive transpose function as a reference. */
void transpose_naive(int n, int blocksize, int *dst, int *src) {
    for (int x = 0; x < n; x++) {
        for (int y = 0; y < n; y++) {
            dst[y + x * n] = src[x + y * n];
        }
    }
}

/* Implement cache blocking below. You should NOT assume that n is a
 * multiple of the block size. */
void transpose_blocking(int n, int blocksize, int *dst, int *src) {
    // YOUR CODE HERE
    for (int start_x  = 0; start_x < n; start_x = start_x + blocksize) {
        for (int start_y = 0; start_y < n; start_y = start_y + blocksize) {
            for (int x = start_x; x < start_x + blocksize; x++) {
                for (int y = start_y; y < start_y + blocksize; y++) {
                    if (x < n && y < n) {
                        dst[y + x * n] = src[x + y * n];
                    }
                }            
            } 
        }
    }
}

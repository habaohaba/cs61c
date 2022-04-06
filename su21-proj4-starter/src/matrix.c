#include "matrix.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

// Include SSE intrinsics
#if defined(_MSC_VER)
#include <intrin.h>
#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__i386__))
#include <immintrin.h>
#include <x86intrin.h>
#endif

/* Below are some intel intrinsics that might be useful
 * void _mm256_storeu_pd (double * mem_addr, __m256d a)
 * __m256d _mm256_set1_pd (double a)
 * __m256d _mm256_set_pd (double e3, double e2, double e1, double e0)
 * __m256d _mm256_loadu_pd (double const * mem_addr)
 * __m256d _mm256_add_pd (__m256d a, __m256d b)
 * __m256d _mm256_sub_pd (__m256d a, __m256d b)
 * __m256d _mm256_fmadd_pd (__m256d a, __m256d b, __m256d c)
 * __m256d _mm256_mul_pd (__m256d a, __m256d b)
 * __m256d _mm256_cmp_pd (__m256d a, __m256d b, const int imm8)
 * __m256d _mm256_and_pd (__m256d a, __m256d b)
 * __m256d _mm256_max_pd (__m256d a, __m256d b)
*/

/* Generates a random double between low and high */
double rand_double(double low, double high) {
    double range = (high - low);
    double div = RAND_MAX / range;
    return low + (rand() / div);
}

/* Generates a random matrix */
void rand_matrix(matrix *result, unsigned int seed, double low, double high) {
    srand(seed);
    for (int i = 0; i < result->rows; i++) {
        for (int j = 0; j < result->cols; j++) {
            set(result, i, j, rand_double(low, high));
        }
    }
}

/*
 * Allocates space for a matrix struct pointed to by the double pointer mat with
 * `rows` rows and `cols` columns. You should also allocate memory for the data array
 * and initialize all entries to be zeros. `parent` should be set to NULL to indicate that
 * this matrix is not a slice. You should also set `ref_cnt` to 1.
 * You should return -1 if either `rows` or `cols` or both have invalid values. Return -2 if any
 * call to allocate memory in this function fails. Remember to set the error messages in numc.c.
 * Return 0 upon success.
 */
int allocate_matrix(matrix **mat, int rows, int cols) {
    //check whether rows cols invalid
    if (rows <= 0 || cols <= 0) {
        return -1;
    }
    //allocate memory for matrix
    *mat = malloc (sizeof(matrix));
    if (*mat == NULL) {
        return -2;
    }
    int n = rows * cols;
    //allocate memory for data array
    (*mat)->data = malloc (n * sizeof(double));
    if ((*mat)->data == NULL) {
        return -2;
    }
    for (int i = 0; i < n; i ++) {
        *((*mat)->data + i) = 0;
    }
    (*mat)->rows = rows;
    (*mat)->cols = cols;
    (*mat)->ref_cnt = 1;
    (*mat)->parent = NULL;
    return 0;
}

/*
 * Allocates space for a matrix struct pointed to by `mat` with `rows` rows and `cols` columns.
 * Its data should point to the `offset`th entry of `from`'s data (you do not need to allocate memory)
 * for the data field. `parent` should be set to `from` to indicate this matrix is a slice of `from`.
 * You should return -1 if either `rows` or `cols` or both have invalid values. Return -2 if any
 * call to allocate memory in this function fails.
 * Remember to set the error messages in numc.c.
 * Return 0 upon success.
 */
int allocate_matrix_ref(matrix **mat, matrix *from, int offset, int rows, int cols) {
    //check whether rows cols invalid
    if (rows <= 0 || cols <= 0) {
        return -1;
    }
    //allocate memory for matrix
    *mat = malloc (sizeof(matrix));
    if (*mat == NULL) {
        return -2;
    }
    (*mat)->data = from->data + offset;
    (*mat)->rows = rows;
    (*mat)->cols = cols;
    (*mat)->ref_cnt = 1;
    (*mat)->parent = from;
    //parent's data referrence-count plus one
    from->ref_cnt++;
    return 0;
}

/*
 * You need to make sure that you only free `mat->data` if `mat` is not a slice and has no existing slices,
 * or that you free `mat->parent->data` if `mat` is the last existing slice of its parent matrix and its parent matrix has no other references
 * (including itself). You cannot assume that mat is not NULL.
 */
void deallocate_matrix(matrix *mat) {
    if (mat != NULL) {
        if (mat->parent == NULL && mat->ref_cnt == 1) {
            //not a slice and has no existing slices
            free(mat->data);
        } else if (mat->parent != NULL) {
            if (mat->parent->ref_cnt == 2) {
                free(mat->parent->data); 
            } else {
                mat->parent->ref_cnt--;
            }
        } 
    }
}

/*
 * Returns the double value of the matrix at the given row and column.
 * You may assume `row` and `col` are valid.
 */
double get(matrix *mat, int row, int col) {
    return *(mat->data + col + row * mat->cols);
}

/*
 * Sets the value at the given row and column to val. You may assume `row` and
 * `col` are valid
 */
void set(matrix *mat, int row, int col, double val) {
    *(mat->data + col + row * mat->cols) = val;
}

/*
 * Sets all entries in mat to val
 */
void fill_matrix(matrix *mat, double val) {
    int n = mat->rows * mat->cols;
    for (int i = 0; i < n; i++) {
        *(mat->data + i) = val;
    } 
}

/*
 * Store the result of adding mat1 and mat2 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int add_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (mat1->rows != mat2->rows || mat1->cols != mat2->cols) {
        return 1;
    } else {
        int n = mat1->rows * mat2->cols;
        for (int i = 0; i < n; i++) {
            *(result->data + i) = *(mat1->data + i) + *(mat2->data + i); 
        }
        result->rows = mat1->rows;
        result->cols = mat2->cols;
        return 0;
    }
}

/*
 * (OPTIONAL)
 * Store the result of subtracting mat2 from mat1 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int sub_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (mat1->rows != mat2->rows || mat1->cols != mat2->cols) {
        return 1;
    } else {
        int n = mat1->rows * mat2->cols;
        for (int i = 0; i < n; i++) {
            *(result->data + i) = *(mat1->data + i) - *(mat2->data + i); 
        }
        result->rows = mat1->rows;
        result->cols = mat2->cols;
        return 0;
    }
}

/*
 * Store the result of multiplying mat1 and mat2 to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 * Remember that matrix multiplication is not the same as multiplying individual elements.
 */
int mul_matrix(matrix *result, matrix *mat1, matrix *mat2) {
    if (mat1->cols != mat2->rows) {
        return 1;
    } else {
        for (int i = 0; i < mat1->rows; i++) {
            for (int j = 0; j < mat2->cols; j++) { 
                int sum = 0;
                for (int k = 0; k < mat1->cols; k++) {
                    sum = sum + *(mat1->data + k + i * mat1->cols) * *(mat2->data + j + k * mat2->cols); 
                }
                *(result->data + j + i * mat1->cols) = sum;
            }
        }
        result->rows = mat1->rows;
        result->cols = mat2->cols;
        return 0;
    }
}

/*
 * Store the result of raising mat to the (pow)th power to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 * Remember that pow is defined with matrix multiplication, not element-wise multiplication.
 */
int pow_matrix(matrix *result, matrix *mat, int pow) {
    //check whether mat is square matrix
    if (mat->rows != mat->cols) {
        return 1;
    }
    //create mid matrix
    matrix mid;
    matrix *mid_pointer = &mid;
    mid.rows = mat->rows;
    mid.cols = mat->cols;
    int n = mat->rows * mat->cols;
    double mid_data[n];
    mid.data = mid_data;
    for (int i = 0; i < n; i++) {
        *(mid.data + i) = 0;
    }
    //create one matrix
    matrix one;
    matrix *one_pointer = &one;
    one.rows = mat->rows;
    one.cols = mat->cols;
    double one_data[n];
    one.data = one_data;
    for (int i = 0; i < n; i++) {
        if (i % (mat->rows + 1) == 0) {
            *(one.data + i) = 1;
        } else {
            *(one.data + i) = 0;
        }
    }
    //calculate
    mul_matrix(result, one_pointer, one_pointer);
    for (int i = 0; i < pow; i++) { 
        mul_matrix(mid_pointer, result, one_pointer);
        mul_matrix(result, mid_pointer, mat);
    }
    return 0;
}

/*
 * (OPTIONAL)
 * Store the result of element-wise negating mat's entries to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int neg_matrix(matrix *result, matrix *mat) {
    int n = mat->rows * mat->cols;
    for (int i = 0; i < n; i++) {
        *(result->data + i) = -*(mat->data + i);
    }
    return 0;
}

/*
 * Store the result of taking the absolute value element-wise to `result`.
 * Return 0 upon success and a nonzero value upon failure.
 */
int abs_matrix(matrix *result, matrix *mat) {
    int n = mat->rows * mat->cols;
    for (int i = 0; i < n; i++) {
        if (*(mat->data + i) < 0) {
            *(result->data + i) = -*(mat->data + i);
        } else {
            *(result->data + i) = *(mat->data + i);
        }
    }
    return 0;
}

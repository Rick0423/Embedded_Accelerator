#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <stdint.h>

#define MATRIX_SIZE 64

//利用嵌入式设备或主机进行传统矩阵乘法用于对比

// 矩阵乘法函数
void matrix_multiply(int8_t A[MATRIX_SIZE][MATRIX_SIZE], int8_t B[MATRIX_SIZE][MATRIX_SIZE], int16_t C[MATRIX_SIZE][MATRIX_SIZE]) {
    // 遍历结果矩阵 C 的每个元素
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            C[i][j] = 0;  // 初始化结果矩阵中的元素为 0

            // 计算 C[i][j]
            for (int k = 0; k < MATRIX_SIZE; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}

// 打印矩阵
void print_matrix(int8_t matrix[MATRIX_SIZE][MATRIX_SIZE]) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            printf("%4d", matrix[i][j]);
            printf(" ");
        }
        printf("\n");
    }
}

void print_matrix_2(int16_t matrix[MATRIX_SIZE][MATRIX_SIZE]) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            printf("%4d", matrix[i][j]);
            printf(" ");
        }
        printf("\n");
    }
}



int main() {
    srand(time(NULL));
    // 声明并初始化矩阵 A 和 B
    int8_t A[MATRIX_SIZE][MATRIX_SIZE];
    int8_t B[MATRIX_SIZE][MATRIX_SIZE];
    int16_t C[MATRIX_SIZE][MATRIX_SIZE];  // 结果矩阵 C

    for (int i = 0; i < MATRIX_SIZE; i++){
        for(int j = 0; j < MATRIX_SIZE; j++){
            A[i][j] = (int)(i / 2) - 32;
            B[i][j] = (int)(i / 2) - 32;
        }
    }


    // 打印读取的矩阵
    printf("\nMatrix A:\n");
    print_matrix(A);
    printf("\nMatrix B:\n");
    print_matrix(B);


    struct timeval st_time;
    gettimeofday(&st_time,NULL);
    // 调用矩阵乘法函数
    matrix_multiply(A, B, C);
    struct timeval ed_time;
    gettimeofday(&ed_time,NULL);
    printf("time:%ld us.\n",ed_time.tv_sec*1000000+ed_time.tv_usec-st_time.tv_sec*1000000-st_time.tv_usec);

    // 打印结果矩阵 C
    printf("Result Matrix C:\n");
    print_matrix_2(C);

    return 0;
}

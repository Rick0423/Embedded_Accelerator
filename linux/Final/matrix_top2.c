#include "xdma_rw_matrix.c"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <errno.h>
#include <sys/types.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

// 定义常量
#define MATRIX_SIZE 64
#define MATRIX_SIZE_SQUARE (MATRIX_SIZE * MATRIX_SIZE)
#define FLAG_ADDR 0x00002000        // 假设flag地址
#define START_ADDR 0x00001000   //启动计算需要读取的寄存器地址

// 展平矩阵
void flatten_matrix_row_major(const int8_t matrix[MATRIX_SIZE][MATRIX_SIZE], int8_t *flattened) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            flattened[i * MATRIX_SIZE + j] = matrix[i][j];
        }
    }
}

void flatten_matrix_col_major(const int8_t matrix[MATRIX_SIZE][MATRIX_SIZE], int8_t *flattened) {
    for (int j = 0; j < MATRIX_SIZE; j++) {
        for (int i = 0; i < MATRIX_SIZE; i++) {
            flattened[j * MATRIX_SIZE + i] = matrix[i][j];
        }
    }
}

int dev_read_mapped(int dev_fd, uint64_t addr, uint8_t *buffer, uint64_t size)
{
    off_t pgsz = sysconf(_SC_PAGESIZE);
    off_t target = addr;
    off_t offset = target & (pgsz - 1);
    off_t target_aligned = target & (~(pgsz - 1));
    
    void *map = mmap(NULL, offset + size, PROT_READ | PROT_WRITE, MAP_SHARED, dev_fd, target_aligned);
    if (map == MAP_FAILED) {
        perror("mmap failed");
        return -1;
        close(dev_fd);
    }

    uint8_t *mapped_address = (uint8_t *)map;
    mapped_address += offset;

    memcpy(buffer, mapped_address, size); // Copy the data to the buffer

    if (munmap(map, offset + size) == -1) {
        perror("munmap failed");
        return -1;
    }
    return 0;
}

// 打印矩阵
void print_matrix(int8_t *matrix) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            printf("%4d", matrix[i * MATRIX_SIZE + j]);
        }
        printf("\n");
    }
}

void convert_to_int16_array(const int8_t *input, int16_t *output) {
    int index;
    for (int i = 0; i < MATRIX_SIZE * MATRIX_SIZE; i++) {
            // 每两个相邻的字节拼接成一个 16 位整数
            index = i * 2;  // 计算字节数组中的索引位置
            output[i] = (input[index + 1] << 8) | (input[index] & 0xFF);  // 按大端字节序拼接
    }
}


int main() {
    srand(time(NULL));
    const char *dev_write = "/dev/xdma0_h2c_0";
    const char *dev_read = "/dev/xdma0_c2h_0";
    const char *dev_control = "/dev/xdma0_user";
    uint64_t addr_matrix1 = 0x00000000;
    uint64_t addr_matrix2 = 0x00002000;
    uint64_t addr_result = 0x00006000;
    int dev_fd = -1;

    // 打开设备
    dev_fd = open(dev_write, O_RDWR);
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open write device %s\n", dev_write);
        return -1;
    }

    // 定义矩阵并初始化（示例数据）
    int8_t flattened_A[MATRIX_SIZE * MATRIX_SIZE];
    int8_t flattened_B[MATRIX_SIZE * MATRIX_SIZE];
    int8_t result[2 * MATRIX_SIZE * MATRIX_SIZE];
    int16_t final_result[MATRIX_SIZE * MATRIX_SIZE];

    for (int i = 0; i < MATRIX_SIZE * MATRIX_SIZE; i++) {
        flattened_A[i] = (int8_t)(i / 64) - 32; // Example data
        flattened_B[i] = (int8_t)(i / 64) - 32; // Example data
    }

    struct timeval st_time_2;
    gettimeofday(&st_time_2,NULL);
    // 将第一个矩阵写入 FPGA
    if (write_to_fpga(dev_write, addr_matrix1, flattened_A) != 0) {
        printf("Failed to write the first matrix to device.\n");
        close(dev_fd);
        return -1;
    }
    // 将第二个矩阵写入 FPGA
    if (write_to_fpga(dev_write, addr_matrix2, flattened_B) != 0) {
        printf("Failed to write the second matrix to device.\n");
        close(dev_fd);
        return -1;
    }
    close(dev_fd);
    //读取控制寄存器以启动计算
    dev_fd = open(dev_control, O_RDWR);
    struct timeval st_time_1;
    gettimeofday(&st_time_1,NULL);
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open control device %s\n", dev_control);
        close(dev_fd);
        return -1;
    }
    int8_t flag = 0;
    dev_read_mapped(dev_fd,START_ADDR,&flag,1);
    //读标志寄存器，等待计算完成
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open control device %s\n", dev_control);
        close(dev_fd);
        return -1;
    }
    flag = 0;
    while(!flag){
        dev_read_mapped(dev_fd,FLAG_ADDR,&flag,1);
        usleep(10);
    }
    struct timeval ed_time_1;
    gettimeofday(&ed_time_1,NULL);
    printf("time without transaction:%ld us.\n",ed_time_1.tv_sec*1000000+ed_time_1.tv_usec-st_time_1.tv_sec*1000000-st_time_1.tv_usec);
    close(dev_fd);
    // 等待 FPGA 计算完成
   // while (!check_flag(dev_fd)) {
   //     usleep(100000);  // 等待100ms
   // }

    dev_fd = open(dev_read, O_RDWR);
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open read device %s\n", dev_read);
        close(dev_fd);
        return -1;
    }
    // 读取计算结果
    if (read_from_fpga(dev_read, addr_result, result) != 0) {
        printf("Failed to read result from device.\n");
        close(dev_fd);
        return -1;
    }
    printf("Finished reading result.\n");
    convert_to_int16_array(result,final_result);
    printf("Result matrix:\n");
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            printf("%4d", final_result[i * MATRIX_SIZE + j]);
            printf(" ");
        }
        printf("\n");
    }
    struct timeval ed_time_2;
    gettimeofday(&ed_time_2,NULL);
    printf("time including transaction:%ld us.\n",ed_time_2.tv_sec*1000000+ed_time_2.tv_usec-st_time_2.tv_sec*1000000-st_time_2.tv_usec);
    // 关闭设备
    close(dev_fd);
    return 0;
}

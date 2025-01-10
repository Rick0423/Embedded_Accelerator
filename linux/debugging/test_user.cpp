#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/mman.h>
//测试通过AXI -Lite接口读写寄存器
int dev_read(int dev_fd, uint64_t addr, uint8_t *buffer, uint64_t size) {
    off_t offset = addr & (sysconf(_SC_PAGESIZE) - 1);
    off_t target_aligned = addr & (~(sysconf(_SC_PAGESIZE) - 1));
    
    void *map = mmap(NULL, offset + size, PROT_READ | PROT_WRITE, MAP_SHARED, dev_fd, target_aligned);
    if (map == MAP_FAILED) {
        perror("mmap failed");
        return -1;
    }

    uint8_t *mapped_address = (uint8_t *)map;
    mapped_address += offset;

    memcpy(buffer, mapped_address, size); // Copy the data to the buffer

    if (munmap(map, offset + size) == -1) {
        perror("munmap failed");
        return -1;
    }
    close(dev_fd);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <device> <address> [size]\n", argv[0]);
        return -1;
    }

    const char *dev_control = argv[1];
    uint64_t address = strtoull(argv[2], NULL, 16); // Read address in hexadecimal
    int size = (argc > 3) ? atoi(argv[3]) : 2; // Optional size argument, default to 2 bytes

    int dev_fd = open(dev_control, O_RDWR);
    if (dev_fd < 0) {
        perror("Failed to open device");
        return -1;
    }

    uint8_t buffer[size];
    if (dev_read(dev_fd, address, buffer, size) != 0) {
        close(dev_fd);
        return -1;
    }

    printf("Read data: ");
    for (int i = 0; i < size; i++) {
        printf("%02x ", buffer[i]);
    }
    printf("\n");

    close(dev_fd);
    return 0;
}

# 使用交叉编译工具链
CC ?= aarch64-linux-gnu-gcc

# 默认目标
all: reg_rw dma_to_device dma_from_device performance test_chrdev

# dma_to_device 目标规则
dma_to_device: dma_to_device.o
	$(CC) -lrt -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

# dma_from_device 目标规则
dma_from_device: dma_from_device.o
	$(CC) -lrt -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

# performance 目标规则
performance: performance.o
	$(CC) -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

# reg_rw 目标规则
reg_rw: reg_rw.o
	$(CC) -o $@ $<

# test_chrdev 目标规则
test_chrdev: test_chrdev.o
	$(CC) -o $@ $<

# 通用规则
%.o: %.c
	$(CC) -c -std=c99 -o $@ $< -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_LARGE_FILE_SOURCE

# 清理规则
clean:
	rm -rf reg_rw *.o *.bin dma_to_device dma_from_device performance test_chrdev

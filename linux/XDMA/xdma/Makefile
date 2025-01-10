SHELL = /bin/bash
#
# optional makefile parameters:
# - DEBUG=<0|1>,	enable verbose debug print-out in the driver
# - config_bar_num=,	xdma pci config bar number
# - xvc_bar_num=,	xvc pci bar #
# - xvc_bar_offset=,	xvc register base offset
# 
ifneq ($(xvc_bar_num),)
	XVC_FLAGS += -D__XVC_BAR_NUM__=$(xvc_bar_num)
endif

ifneq ($(xvc_bar_offset),)
	XVC_FLAGS += -D__XVC_BAR_OFFSET__=$(xvc_bar_offset)
endif

$(warning XVC_FLAGS: $(XVC_FLAGS).)

topdir := $(shell cd $(src)/.. && pwd)

TARGET_MODULE := xdma

EXTRA_CFLAGS := -I$(topdir)/include $(XVC_FLAGS)
ifeq ($(DEBUG),1)
	EXTRA_CFLAGS += -D__LIBXDMA_DEBUG__
endif
ifneq ($(config_bar_num),)
	EXTRA_CFLAGS += -DXDMA_CONFIG_BAR_NUM=$(config_bar_num)
endif

ARCH ?= arm64
CROSS_COMPILE ?= aarch64-linux-gnu-
KERNEL_DIR := /home/hyj/work/phytium-linux-kernel-linux-5.10/
BUILDSYSTEM_DIR := $(KERNEL_DIR)
PWD := $(shell pwd)

ifneq ($(KERNELRELEASE),)
	$(TARGET_MODULE)-objs := libxdma.o xdma_cdev.o cdev_ctrl.o cdev_events.o cdev_sgdma.o cdev_xvc.o cdev_bypass.o xdma_mod.o xdma_thread.o
	obj-m := $(TARGET_MODULE).o
else
all:
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) modules

clean:
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	@/bin/rm -f *.ko modules.order *.mod.c *.o *.o.ur-safe .*.o.cmd

install: all
	@echo "installing kernel modules to $(KERNEL_DIR)/xdma ..."
	@mkdir -p -m 755 $(KERNEL_DIR)/xdma
	@install -v -m 644 *.ko $(KERNEL_DIR)/xdma
	@depmod -a -b $(KERNEL_DIR) || true

uninstall:
	@echo "Un-installing $(KERNEL_DIR)/xdma ..."
	@/bin/rm -rf $(KERNEL_DIR)/xdma
	@depmod -a -b $(KERNEL_DIR)
endif

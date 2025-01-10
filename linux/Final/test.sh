#!/bin/bash

# 输出开始提示
echo "开始执行脚本，重新扫描 PCI 设备..."

# 第一步：重新扫描 PCI 设备
echo 1 > /sys/bus/pci/rescan
if [ $? -eq 0 ]; then
    echo "PCI 设备扫描成功。"
else
    echo "PCI 设备扫描失败！请检查权限或系统状态。" >&2
    exit 1
fi

# 第二步：执行 /root/tools/check_xdma.sh
echo "正在运行 check_xdma.sh 脚本..."
/root/tools/check_xdma.sh
if [ $? -eq 0 ]; then
    echo "check_xdma.sh 执行成功。"
else
    echo "check_xdma.sh 执行失败！请检查脚本。" >&2
    exit 1
fi

# 第三步：加载 xdma.ko 模块
echo "正在加载 xdma.ko 模块..."
insmod /root/hyj/XDMA/xdma/xdma.ko
if [ $? -eq 0 ]; then
    echo "xdma.ko 模块加载成功。"
else
    echo "xdma.ko 模块加载失败！请检查模块路径或依赖。" >&2
    exit 1
fi

# 输出完成提示
echo "所有操作完成！"

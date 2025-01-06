# Matrix Multiplication Accelerator for Embedded Systems

## Overview

This project focuses on the design and implementation of an efficient matrix multiplication accelerator targeting embedded systems. The system leverages FPGA hardware acceleration in conjunction with a Linux-based embedded system to speed up matrix multiplication operations, which are crucial in deep learning applications, such as training and inference of Convolutional Neural Networks (CNNs). By using FPGA, the system offers high parallelism, low power consumption, and real-time processing, making it ideal for embedded and edge computing scenarios.

## Key Features

- **FPGA Acceleration**: Accelerates matrix multiplication through hardware parallelism and optimized data handling.
- **Embedded Linux System**: Uses a Linux-based system to interface with the FPGA and manage tasks via PCIe.
- **High Performance**: Achieves significant improvements in computation efficiency compared to traditional CPU-based methods.
- **Low Latency**: Optimized for low latency in deep learning inference and real-time processing.
- **Flexible Architecture**: The system supports scalable matrix sizes and can be adapted for different hardware setups.

## System Architecture

The system is composed of two main parts:
1. **Linux Host**: Controls the system, manages input/output operations, and communicates with the FPGA over PCIe.
2. **FPGA Accelerator**: Handles the matrix multiplication computations using optimized hardware logic.

Data is transferred between the Linux system and the FPGA using high-speed PCIe interfaces, and the computation results are written back to the host memory.

### Functional Flow

1. **Linux Side:**
   - Transmits matrix data (A, B) to the FPGA.
   - Monitors FPGA status via AXI-Lite interface.
   - Retrieves computed results (matrix C) from the FPGA.

2. **FPGA Side:**
   - Stores matrices A and B in BRAM.
   - Uses systolic array processing with ping-pong buffering for efficient computation.
   - Writes the results back to BRAM for Linux-side retrieval.

---

## FPGA Design


- **AXI Interface**: Uses AXI-Lite for control signals and AXI-MM for data transfer to/from FPGA's BRAM.
- **Matrix Multiplication Unit**: Implements matrix multiplication using a pulse array technique for efficient data reuse, with minimal memory access and maximum throughput.
- **Modular Design**: The FPGA design includes modules for control, data transfer, and matrix multiplication, optimized for performance and resource utilization.

---


## Embedded System Design

The Linux host interacts with the FPGA using the XDMA (PCIe DMA) driver, facilitating high-performance data transfers. The system supports both reading and writing of matrix data between the FPGA and host memory. The control flow on the Linux side ensures proper synchronization with the FPGA through the AXI-Lite interface.



### Data Interaction

- **Matrix Transmission:** 
  - Use `write()` and `read()` operations for high-throughput data exchange via XDMA.
  - Memory mapping (`mmap`) and alignment are used for AXI-Lite operations.
- **Control Signals:** Monitored via AXI-Lite registers.


## References

1. [Xilinx XDMA Overview](https://adaptivesupport.amd.com/s/article/65444?language=en_US)
2. [dma_ip_drivers](https://github.com/Xilinx/dma_ip_drivers/tree/master)
3. [Xilinx-FPGA-PCIe-XDMA-Tutorial](https://github.com/WangXuan95/Xilinx-FPGA-PCIe-XDMA-Tutorial)


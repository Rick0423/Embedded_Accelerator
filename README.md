# FPGA-Based Matrix Multiplication Accelerator for Embedded Systems

## Introduction

This project implements a high-efficiency matrix multiplication accelerator by integrating an FPGA-based hardware accelerator with an embedded Linux system. The goal is to significantly improve the computational efficiency of matrix operations, particularly for applications like deep learning, where matrix multiplications are ubiquitous.

By offloading the computationally intensive matrix operations to the FPGA, this system meets real-time requirements and maximizes resource utilization.

---

## System Architecture

### Overview

The system is divided into two main components:
1. **Embedded Linux Device:** Responsible for managing data transmission and control.
2. **FPGA Accelerator:** Performs matrix multiplication computations.

Data exchange between the embedded device and FPGA is facilitated using a PCIe interface, with the following key components:
- **PCIe Interface**
- **XDMA IP Core**
- **AXI Bus and AXI-Lite Bus**
- **Block RAM (BRAM)**

The overall architecture is shown below:

Embedded Device ↔ PCIe ↔ XDMA ↔ FPGA


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

### Key Components

- **PCIe XDMA Core:** Enables high-speed data transfer between Linux and FPGA.
- **AXI-Lite Bus:** Handles control signals.
- **AXI Bus:** Transfers matrix data.
- **BRAM:** Stores matrices A, B, and C.
- **Processing Engine (PE Array):** Implements systolic array-based matrix multiplication.

### Matrix Multiplication Flow

1. **Data Storage:** Matrices A and B are split into smaller blocks and stored in BRAM.
2. **Computation:** 
   - A systolic array processes blocks of A and B in parallel using pipelined operations.
   - Ping-pong buffers are utilized to ensure smooth data flow.
3. **Result Output:** The computed matrix C is written back to BRAM.

---

## Embedded System Design

### Data Interaction

- **Matrix Transmission:** 
  - Use `write()` and `read()` operations for high-throughput data exchange via XDMA.
  - Memory mapping (`mmap`) and alignment are used for AXI-Lite operations.
- **Control Signals:** Monitored via AXI-Lite registers.

### Matrix Operations

- **Linux-Side Computation:** The embedded device handles lightweight control tasks and offloads matrix multiplication to the FPGA.
- **FPGA Acceleration:** The system achieves faster computation by leveraging FPGA resources compared to CPU-only processing.

---

## Performance

### Benchmark Results

| Platform        | Average Time (us) |
|------------------|-------------------|
| CPU (Embedded)   | 10,000 - 20,000   |
| CPU (Host)       | 3,000 - 6,000     |

- **FPGA Computation Cycle:** 1,600 cycles (~1.4 µs at 1 MHz clock).

This demonstrates a significant improvement over pure CPU-based matrix multiplication.

---

## Project Contributions

- **Linux Driver Integration:**
  - Developed and configured XDMA drivers for PCIe communication.
  - Automated driver loading and device initialization.
- **FPGA Design:**
  - Implemented matrix storage, systolic array computation, and data flow control.
  - Optimized BRAM usage and PCIe bandwidth.



# Future Work

1. **Scalability Improvements:** Extend support for larger matrices by implementing hierarchical storage and computation schemes.
2. **Dynamic Configuration:** Enable runtime reconfiguration of matrix dimensions.
3. **Optimization:** Enhance data transfer efficiency to further reduce latency.

---

## References

- Xilinx XDMA Documentation
- AXI and BRAM Integration Guides
- Systolic Array Algorithm for Matrix Multiplication

---

Thank you for your interest in this project! For further details, feel free to explore the source code or contact the contributors.
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

## FPGA Design

- **AXI Interface**: Uses AXI-Lite for control signals and AXI-MM for data transfer to/from FPGA's BRAM.
- **Matrix Multiplication Unit**: Implements matrix multiplication using a pulse array technique for efficient data reuse, with minimal memory access and maximum throughput.
- **Modular Design**: The FPGA design includes modules for control, data transfer, and matrix multiplication, optimized for performance and resource utilization.

## Linux Host Integration

The Linux host interacts with the FPGA using the XDMA (PCIe DMA) driver, facilitating high-performance data transfers. The system supports both reading and writing of matrix data between the FPGA and host memory. The control flow on the Linux side ensures proper synchronization with the FPGA through the AXI-Lite interface.

### Steps to Run the Project

1. **Compile and Deploy XDMA Driver**: Cross-compile the XDMA driver and deploy it on the embedded Linux system.
2. **Matrix Data Transfer**: Use custom functions to read and write matrix data between the Linux system and FPGA via PCIe.
3. **Matrix Multiplication**: Once the data is transferred, trigger the FPGA to start the multiplication and monitor its progress through the AXI-Lite interface.
4. **Retrieve Results**: After computation, collect the result matrix from the FPGA and return it to the Linux system.

## Performance

- The FPGA-based accelerator can compute matrix multiplications with significantly reduced latency (around 1600 cycles, or ~2 microseconds), outperforming the CPU-based execution by factors of 3-5x.
- Due to the small data volume (64x64 matrices), the overall system is limited by PCIe overhead but still offers substantial speedup in embedded systems.

## Conclusion

This project demonstrates the feasibility of using FPGA-based acceleration to significantly improve the performance of matrix multiplication tasks in embedded systems. The system is especially beneficial in applications that require real-time data processing with low power consumption, such as deep learning inference on edge devices.

## References

1. [Xilinx XDMA Overview](https://adaptivesupport.amd.com/s/article/65444?language=en_US)
2. [Xilinx XDMA Driver Repository](https://github.com/Xilinx/dma_ip_drivers/tree/master)
3. [Matrix Multiplication Tutorial](https://github.com/WangXuan95/Xilinx-FPGA-PCIe-XDMA-Tutorial)


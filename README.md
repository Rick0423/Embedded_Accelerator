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


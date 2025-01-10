
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/timeb.h>




// function : dev_read
// description : read data from device to local memory (buffer), (i.e. device-to-host)
// parameter :
//       dev_fd : device instance
//       addr   : source address in the device
//       buffer : buffer base pointer
//       size   : data size(16bit)
// return:
//       int : 0=success,  -1=failed
int dev_read (int dev_fd, uint64_t addr, int8_t *buffer, uint64_t size) {
    if ( addr != lseek(dev_fd, addr, SEEK_SET) )                                 // seek
        return -1;                                                               // seek failed
    if ( size != read(dev_fd, buffer, size) )                                    // read device to buffer
        return -1;                                                               // read failed
    return 0;
}


// function : dev_write
// description : write data from local memory (buffer) to device, (i.e. host-to-device)
// parameter :
//       dev_fd : device instance
//       addr   : target address in the device
//       buffer : buffer base pointer
//       size   : data size
// return:
//       int : 0=success,  -1=failed
int dev_write (int dev_fd, uint64_t addr, int8_t *buffer, uint64_t size) {
    if ( addr != lseek(dev_fd, addr, SEEK_SET) )                                 // seek
        return -1;                                                               // seek failed
    if ( size != write(dev_fd, buffer, size) )                                   // write device from buffer
        return -1;                                                               // write failed
    return 0;
}




// function : get_millisecond
// description : get time in millisecond
static uint64_t get_millisecond () {
    struct timeb tb;
    ftime(&tb);
    return (uint64_t)tb.millitm + (uint64_t)tb.time * 1000UL;
    // tb.time is the number of seconds since 00:00:00 January 1, 1970 UTC time;
    // tb.millitm is the number of milliseconds in a second
}



// function : parse_uint
// description : get a uint64 value from string (support hexadecimal and decimal)
int parse_uint (char *string, uint64_t *pvalue) {
    if ( string[0] == '0'  &&  string[1] == 'x' )                // HEX format "0xXXXXXXXX"
        return sscanf( &(string[2]), "%lx", pvalue);
    else                                                         // DEC format
        return sscanf(   string    , "%lu", pvalue);
}



#define MATRIX_SIZE 64

//direction:"t"for to device,use xdma0_h2c_0, otherwise "f"
int write_to_fpga(const char* dev_name ,uint64_t address, int8_t *matrix){
    int dev_fd = -1;
    uint64_t millisecond;

    //Open device
    dev_fd = open(dev_name, O_RDWR);
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open device %s\n", dev_name);
        return -1;
    }

    millisecond = get_millisecond();
    
    //Write data to fpga
    if (dev_write(dev_fd, address, matrix, MATRIX_SIZE * MATRIX_SIZE) != 0) {
        printf("*** ERROR: failed to write to device %s\n", dev_name);
        close(dev_fd);
        return -1;
    }
    millisecond = get_millisecond() - millisecond;
    millisecond = (millisecond > 0) ? millisecond : 1; // avoid divide-by-zero

    printf("Write successful: time=%lu ms, data rate=%.1lf KBps\n", millisecond,
           (double)(MATRIX_SIZE * MATRIX_SIZE) / millisecond);

    close(dev_fd);
    return 0;
}

int read_from_fpga(const char *dev_name, uint64_t address, int8_t *buffer) {
    int dev_fd = -1;
    uint64_t millisecond;

    // Open device
    dev_fd = open(dev_name, O_RDWR);
    if (dev_fd < 0) {
        printf("*** ERROR: failed to open device %s\n", dev_name);
        return -1;
    }

    // Start timer
    millisecond = get_millisecond();

    // Read data from the device
    if (dev_read(dev_fd, address, buffer, 2* MATRIX_SIZE * MATRIX_SIZE) != 0) {
        printf("*** ERROR: failed to read from device %s\n", dev_name);
        close(dev_fd);
        return -1;
    }

    // Stop timer
    millisecond = get_millisecond() - millisecond;
    millisecond = (millisecond > 0) ? millisecond : 1; // avoid divide-by-zero

    printf("Read successful: time=%lu ms, data rate=%.1lf KBps\n", millisecond,
           (double)(MATRIX_SIZE * MATRIX_SIZE) / millisecond);

    close(dev_fd);
    return 0;
}


// int main() {
//     const char *dev_write = "/dev/xdma0_h2c_0";
//     const char *dev_read = "/dev/xdma0_c2h_0";
//     uint64_t address = 0x00000010;

//     // Example: Write data
//     int8_t write_buffer[MATRIX_SIZE * MATRIX_SIZE];
//     for (int i = 0; i < MATRIX_SIZE * MATRIX_SIZE; i++) {
//         write_buffer[i] = (int8_t)(i / 64); // Example data
//     }
//     if (write_to_fpga(dev_write, address, write_buffer) != 0) {
//         printf("Failed to write to device.\n");
//     }

//     // Example: Read data
//     int8_t read_buffer[MATRIX_SIZE * MATRIX_SIZE];
//     if (read_from_fpga(dev_read, address, read_buffer) != 0) {
//         printf("Failed to read from device.\n");
//     } else {
//         // Print read matrix
//         printf("Read data:\n");
//         for (int i = 0; i < MATRIX_SIZE; i++) {
//             for (int j = 0; j < MATRIX_SIZE; j++) {
//                 printf("%4d", read_buffer[i * MATRIX_SIZE + j]);
//             }
//             printf("\n");
//         }
//     }

//     return 0;
// }



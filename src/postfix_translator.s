.section .bss
input_buffer: .space 256            # Allocate 256 bytes for input buffer

.section .data


.section .text
.global _start

_start:
    # Read input from standard input
    mov $0, %eax                    # syscall number for sys_read
    mov $0, %edi                    # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi    # pointer to the input buffer
    mov $256, %edx                  # maximum number of bytes to read
    syscall                         # perform the syscall

    call print_func
    jmp exit_program  


print_func:
    # Assumes edx has size and rsi has address (popped from stack)
    mov $1, %eax              # syscall number for sys_write
    mov $1, %edi              # file descriptor 1 (stdout)
    syscall
    ret

exit_program:
    # Exit the program
    mov $60, %eax               # syscall number for sys_exit
    xor %edi, %edi              # exit code 0
    syscall

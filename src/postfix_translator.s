.section .bss
input_buffer: .space 256            # Allocate 256 bytes for input buffer
output_buffer: .space 256

.section .data
# I format variables for printing
i_format_first_instruction: .string " 00000 000 00010 0010011\n"  # also try .asciz
i_format_second_instruction: .string " 00000 000 00001 0010011\n"

# R format variables for printing
r_format_instruction: .string " 00010 00001 000 00001 0110011\n"
add_op_binary: .string "0000000"
sub_op_binary: .string "0100000"
mul_op_binary: .string "0000001"
xor_op_binary: .string "0000100"
and_op_binary: .string "0000111"
or_op_binary: .string "0000110"

.section .text
.global _start

_start:
    # Read input from standard input
    mov $0, %eax                    # syscall number for sys_read
    mov $0, %edi                    # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi    # pointer to the input buffer
    mov $256, %edx                  # maximum number of bytes to read
    syscall                         # perform the syscall

    lea input_buffer(%rip), %r8
    lea output_buffer(%rip), %r9

    mov $0, %ax
    jmp process_next_unit

    call print_func

process_next_unit:                  # Decide which action to take
    mov $0, %r11
    mov $0, %r12

    # Check if end of line
    cmp $'\n', (%r8)
    je exit_program

    # Check if whitespace
    cmp $32, (%r8)
    je get_next_decimal

    # Check if operation
    cmp $43, (%r8)
    je add_operation

    cmp $45, (%r8)
    je sub_operation

    cmp $42, (%r8)
    je mul_operation

    cmp $94, (%r8)
    je xor_operation

    cmp $38, (%r8)
    je and_operation

    cmp $124, (%r8)
    je or_operation

    # Else, this is a number
    jmp get_decimal_number

get_decimal_number:                 # Current character is a number
    mul $10, %ax                    # Accumulate the result in register ax
    mov $0, %r10
    mov (%r8), %r10
    sub $48, %r10
    add %r10, %ax
    inc %r8
    jmp process_next_unit


get_next_decimal:                   # Current character is white space
    push %ax
    mov $0, %ax
    inc %r8
    jmp process_next_unit

add_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea add_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func

    add %r12, %r11
    push %r11
    jmp process_next_unit

sub_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea sub_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func

    sub %r12, %r11
    push %r11
    jmp process_next_unit

mul_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea mul_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func

    mul %r12, %r11
    push %r11
    jmp process_next_unit

xor_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea xor_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func
    
    xor %r12, %r11
    push %r11
    jmp process_next_unit

and_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea and_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func

    and %r12, %r11
    push %r11
    jmp process_next_unit

or_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %edx
    call print_func
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %edx
    call print_func

    lea or_op_binary(%rip), %rsi
    mov $7, %edx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %edx
    call print_func

    or %r12, %r11
    push %r11
    jmp process_next_unit

decimal_to_binary:              # Function that converts a decimal number to a binary number
    # IMPLEMENT
    ret

print_func:
    mov $1, %eax              # syscall number for sys_write
    mov $1, %edi              # file descriptor 1 (stdout)
    syscall
    mov $0, %rsi
    mov $0, %edx
    ret

exit_program:
    # Exit the program
    mov $60, %eax               # syscall number for sys_exit
    xor %edi, %edi              # exit code 0
    syscall

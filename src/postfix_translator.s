.section .bss
input_buffer: .space 256            # Allocate 256 bytes for input buffer
output_buffer: .space 12

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

    mov $0, %rax
    jmp process_next_unit

process_next_unit:                  # Decide which action to take
    mov $0, %r11
    mov $0, %r12

    # Check if end of line
    cmpb $'\n', (%r8)
    je exit_program

    # Check if whitespace
    cmpb $' ', (%r8)
    je get_next_decimal

    # Check if operation
    cmpb $43, (%r8)
    je add_operation

    cmpb $45, (%r8)
    je sub_operation

    cmpb $42, (%r8)
    je mul_operation

    cmpb $94, (%r8)
    je xor_operation

    cmpb $38, (%r8)
    je and_operation

    cmpb $124, (%r8)
    je or_operation

    # Else, this is a number
    jmp get_decimal_number

get_decimal_number:                 # Current character is a number
    mov $0, %rcx
    mov $10, %rcx
    mul %rcx                         # Accumulate the result in register rax
    mov $0, %r10
    mov (%r8), %r10
    sub $48, %r10
    add %r10, %rax
    inc %r8
    jmp process_next_unit


get_next_decimal:                   # Current character is white space
    push %rax
    mov $0, %rax
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
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax                # Clean contents of %rax to prevent multiplying garbuage value inside in the get_decimal_number label

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
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

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

    mov $0, %rax
    mov %r11, %rax
    mul %r12                # Multiply value in rax with the value in r12
    push %rax
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

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
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

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
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

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
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

decimal_to_binary:              # Function that converts a decimal number to a binary number
    push $11                    # Set a counter to loop 12 times, keep this counter in stack
    add $11, %r9

loop_part:
    shr $1, %r13   
    jc carry_flag_1
    jmp carry_flag_0

carry_flag_1:
    movb $49, (%r9)
    dec %r9
    jmp after_jc

carry_flag_0:
    movb $48, (%r9)
    dec %r9

after_jc:
    mov $0, %rax                # Loop until all 12 bytes of the output buffer are filled with ascii values (until counter is 0)
    pop %rax                    # Put the counter value into %rax
    cmp $0, %rax                # If counter is zero, loop back to decimal_to_binary
    sub $1, %rax
    push %rax
    ja loop_part
    
    pop %rax                    # If looped 12 times, return
    mov $0, %rax

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

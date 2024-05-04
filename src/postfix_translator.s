.section .bss
input_buffer: .space 256                            # Allocate 256 bytes for input buffer
output_buffer: .space 12

.section .data
# I format variables for printing
i_format_first_instruction: .string " 00000 000 00010 0010011\n"
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
    mov $0, %rax                                    # syscall number for sys_read
    mov $0, %rdi                                    # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi                    # pointer to the input buffer
    mov $256, %rdx                                  # maximum number of bytes to read
    syscall                                         # perform the syscall

    lea input_buffer(%rip), %r8
    lea output_buffer(%rip), %r9

    mov $0, %rax
    mov $0, %r15
    mov $0, %rbx
    jmp process_next_unit

process_next_unit:                                  # Decide which action to take
    mov $0, %r11
    mov $0, %r12

    # Check if end of line
    cmpb $'\n', (%r8)
    je exit_program

    # Check if whitespace
    cmpb $' ', (%r8)
    je get_next_decimal

    # Check if operation
    cmpb $'+', (%r8)
    je add_operation

    cmpb $'-', (%r8)
    je sub_operation

    cmpb $'*', (%r8)
    je mul_operation

    cmpb $'^', (%r8)
    je xor_operation

    cmpb $'&', (%r8)
    je and_operation

    cmpb $'|', (%r8)
    je or_operation

    # Else, this is a number
    jmp get_decimal_number

get_decimal_number:                                 # Current character is a number
    mov $0, %rax
    imul $10, %rbx
    movzb (%r8), %rax
    sub $'0', %rax
    add %rax, %rbx                                  # Accumulate the result in the %rbx register

    inc %r8
    jmp process_next_unit

get_next_decimal:                                   # Current character is a white space, push the accumulated decimal
    push %rbx
    mov $0, %rbx
    mov $0, %rax
    inc %r8
    jmp process_next_unit

add_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary                          # Convert popped decimal to binary representation
    lea output_buffer(%rip), %rsi
    mov $12, %rdx                                   # Read 12 bytes of the output buffer
    call print_func                                 # Print the binary representation
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func                                 # Print the i-format instruction's remanining part

    # Below is the same process but for the first decimal number, so above comments apply to this section too
    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea add_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func                                 # Print operator code
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func                                 # Print the r-format instruction's remanining part

    add %r12, %r11                                  # Do the operation
    push %r11                                       # Push the result of the operation to stack
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                               # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                         # The next character after the operator is whitespace so bypass it
    mov $0, %rax                                    # Clean contents of %rax to prevent multiplying garbuage value inside in the get_decimal_number label

    jmp process_next_unit

# The logic in all of the operations are the same, so comments in the add_operation apply to others as well
sub_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea sub_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func

    sub %r12, %r11
    push %r11
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

# The logic in all of the operations are the same, so comments in the add_operation apply to others as well
mul_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea mul_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func

    mov $0, %rax
    mov %r11, %rax
    mul %r12                                  # Multiply value in rax with the value in r12
    push %rax
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                         # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                   # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

# The logic in all of the operations are the same, so comments in the add_operation apply to others as well
xor_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea xor_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func
    
    xor %r12, %r11
    push %r11
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

# The logic in all of the operations are the same, so comments in the add_operation apply to others as well
and_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea and_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func

    and %r12, %r11
    push %r11
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                           # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                     # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

# The logic in all of the operations are the same, so comments in the add_operation apply to others as well
or_operation:
    pop %r12
    mov $0, %r13
    mov %r12, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_first_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    pop %r11
    mov $0, %r13
    mov %r11, %r13
    call decimal_to_binary
    lea output_buffer(%rip), %rsi
    mov $12, %rdx
    call print_func
    lea output_buffer(%rip), %r9
    lea i_format_second_instruction(%rip), %rsi
    mov $25, %rdx
    call print_func

    lea or_op_binary(%rip), %rsi
    mov $7, %rdx
    call print_func
    lea r_format_instruction(%rip), %rsi
    mov $31, %rdx
    call print_func

    or %r12, %r11
    push %r11
    inc %r8

    # Check if end of line
    cmpb $'\n', (%r8)                       # The next character is new line character, so the program terminates
    je exit_program

    inc %r8                                 # The next character after the operator is whitespace so bypass it
    mov $0, %rax

    jmp process_next_unit

decimal_to_binary:                          # Function that converts a decimal number to a binary number
    mov $12, %r15                           # Set a counter to loop 12 times
    add $11, %r9

loop_part:
    sub $1, %r15
    shr $1, %r13                            # Shift the register to right by 1, effectively dividing it with 2
    jc carry_flag_1
    jmp carry_flag_0

carry_flag_1:
    movb $'1', (%r9)
    dec %r9                                 # Fill the output_buffer reversely to get the binary representation of the decimal
    jmp after_jc

carry_flag_0:
    movb $'0', (%r9)
    dec %r9

after_jc:
    cmp $0, %r15                            # Loop until all 12 bytes of the output buffer are filled with ascii values (until counter is 0)
    ja loop_part                            

    ret                                     # If looped 12 times, return back to the operation label

print_func:
    mov $1, %rax                            # syscall number for sys_write
    mov $1, %rdi                            # file descriptor 1 (stdout)
    syscall
    mov $0, %rsi
    mov $0, %rdx
    ret

exit_program:
    # Exit the program
    mov $60, %rax                           # syscall number for sys_exit
    xor %rdi, %rdi                          # exit code 0
    syscall

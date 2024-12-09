;;//PREPEND BEGIN
.model small
.stack
.data
    ARRAY db 10 DUP(0)   ; 数组，长度为10
    LEN db ?          ; 数组长度
    INDEX db ?           ; 循环索引
    CURRENT_NUM db ?     ; 当前元素
    PRIME_SUM db 0        ; 质数和
    NONPRIME_SUM db 0         ; 非质数和

.code

print_num proc near 
    push dx     ; 保存寄存器
    mov dh,dl   ; 保存dl
    and dh,80h  ; 判断是否为负数
    jnz negL    ; 若为负数，跳转到negL
    jmp nxt    ; 若为正数，跳转到nxt
negL:   ; 若为负数，先输出负号
    mov dh,dl   ; 保存dl
    mov dl, '-' ; 输出负号
    mov ah, 02h ; 功能号2，输出字符
    int 21h    ; 调用中断
    neg dh    ; 取反dh
    mov dl,dh   ; 将dh赋给dl
nxt:
    xor  ah, ah     ; 除法时，ah必须为0
    mov  al, dl    ; 将dl赋给al
    mov  dh, 10   ; 除数为10
    div  dh     ; 除以10
    ;除以10后商是否为0
    test al, 0ffh   ;若为0，则代表原数为一位数
    jz   single ;商不为0，至少为两位数
    push ax     ;保存ax
    xor  ah, ah     ;除法时，ah必须为0
    div  dh     ;除以10
    test al, 0ffh   ;同理，若商为0，代表为两位数
    jz   two    ;商为0时，余数不可能也为0，这样是个位数
    push ax     ;保存ax
    mov  dl, al     ;余数为个位数
    add  dl, '0'    ;转换为字符
    mov  ah, 02h    ;功能号2，输出字符
    int  21h    ;调用中断
    pop  ax     ;恢复ax
two:
    mov  dl, ah     ;余数为十位数
    add  dl, '0'    ;转换为字符
    mov  ah, 02h    ;功能号2，输出字符
    int  21h    ;调用中断
    pop  ax     ;恢复ax
single:
    mov  dl, ah     ;余数为个位数
    add  dl, '0'    ;转换为字符
    mov  ah, 02h    ;功能号2，输出字符
    int  21h    ;调用中断
    pop  dx    ;恢复寄存器
    ret
print_num endp

start:
    mov ax,@data     ; 初始化数据段寄存器
    mov ds,ax     ; 初始化数据段寄存器
    ; 输入数组长度
    MOV AH, 01H          ; 设置DOS功能调用的子功能号为01H（读取字符）
    INT 21H              ; 执行DOS功能调用
    SUB AL, '0'          ; 将输入字符转换为数字
    MOV LEN, AL

    ; 输入数组元素
    MOV INDEX, 0         ; 初始化循环索引为0

INPUT_LOOP:
    MOV AH, 01H          ; 设置DOS功能调用的子功能号为01H（读取字符）
    INT 21H              ; 执行DOS功能调用
    SUB AL, '0'          ; 将输入字符转换为数字
    MOV CURRENT_NUM, AL

    MOV AL, INDEX
    mov bx,offset ARRAY
    mov cl,CURRENT_NUM
    xor si,si
    ;xor ch,ch
    xor ah,ah
    add si,bx
    add si,ax
    MOV [si], cl ; 将当前元素保存到数组中
    INC INDEX            ; 循环索引加1
    mov al,INDEX
    mov ah,LEN
    CMP al, ah      ; 判断循环索引是否达到数组长度
    JB INPUT_LOOP        ; 如果循环索引小于数组长度，继续输入下一个元素
    MOV INDEX, 0         ; 初始化循环索引为0
;;//PREPEND END

;;//TEMPLATE BEGIN
;;//书写代码
    ; 循环判断数组中的数是否是质数，如果是质数，则将数保存在一个寄存器中，若不未质数则将数保存在另一个寄存器中
    ; 累加质数的负数和和非质数和
    xor dh, dh  ;存储非质数和
    xor ch, ch  ;存储质数和

    check_loop:
        ; 判断是否为质数
        MOV al, INDEX
        mov bx,offset ARRAY
        add bx, ax
        mov al, [bx]         ; 加载当前数组元素  
        cmp al, 1
        jbe ntzs ; 如果为1，则不为质数
        ; 循环判断是否有因数
        mov bl, al
        mov cl, 2
    pdzs:
        cmp cl, bl           ; 如果 cl >= bl，说明是质数  
        jge iszs  
        mov al, bl           ; 将要判断的数放入 ax  
        xor ah, ah           ; 清空ah  
        div cl               ; ax / cl，结果在al，余数在ah 
        cmp ah, 0            ; 判断余数是否为0  
        je ntzs              ; 如果余数为0，则不是质数  
        inc cl               ; 继续判断下一个数  
        jmp pdzs  

    ntzs:
        add dh, [bx]           ; 累加非质数 
        jmp next_index

    iszs:
        add ch, bl           ; 累加质数
        jmp next_index

    next_index:
        inc INDEX
        mov al,INDEX
        mov ah,LEN
        CMP al, ah 
        JB check_loop      ;使用了保留字（例如 C 或 SIZE）作为标识符。所以不可以使用loop作为标识符

        ; 累加质数的负数和和非质数
        mov al, dh
        sub al, ch
        mov dl, al

;;//TEMPLATE END

;;//APPEND BEGIN
    call print_num ; 显示结果
    mov ah,4CH   ; 设置DOS功能调用的子功能号为4CH（程序退出）
    int 21H     ; 执行DOS功能调用

end start
;;//APPEND END
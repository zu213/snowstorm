org 0x100

start:
    ; 1) First we draw the Initial screen
    mov ah, 0x00       
    mov al, 0x13        
    int 0x10

    mov bx, 10 ; bx used for random number
    mov si, 10
    mov cx, 1000 ; cx used for loop

draw_pixel:
    ; Draw initial pixels in loop
    call distribute_snowflake
    
    mov ax, 0xA000
    mov es, ax
    mov di, bx
    mov al, 0x0F
    mov [es:di], al

    loop draw_pixel

    ; setup duration for animate is cx
    mov cx, 1000
    mov dx, 0

animate:
    ;2) Next we animate the snow
    mov ebx, 64000

change_pixel: ; iterate through the pixels editing them
    sub ebx, 1
    mov ax, 0xA000
    mov es, ax
    mov di, bx

    ; if we find a white pixel change it to black
    mov al, [es:di]    
    cmp al, 0x0F
    je change_to_black

return_from_black: ; jump back here if change to black
    cmp ebx, 0
    jg change_pixel ; loop through all pixels on screen

    ; After looping we paint a new row of pixels for new snow
    mov bx, 5 ; set this for number of new snows per row
    call paint_new_pixel

    loop animate ; loop for duration of animation

    ; Return to text mode (mode 3)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Exit the program
    mov ah, 0x4C
    int 0x21

; jumping functions

change_to_black:
    mov al, 0x00
    mov [es:di], al
    add di, 319
    test cl, 1
    jz move_left ; alternate between the snow moving left or right

    add di, 2 ; move_right

move_left:
    mov al, 0x0F 
    mov [es:di], al
    sub di, 321

    jmp return_from_black

distribute_snowflake:
    ; function used for inital snow distribution
    imul bx, 13
    add bx, 15
    ret

paint_new_pixel: ; paint the new row of pixels
    mov ax, 0xA000  
    mov es, ax
    ; We need more randoness for the new row so we use the system clock
    rdtsc            ; Get the current time stamp counter into EDX:EAX
    xor edx, edx           
    add ax, si        ; modify it slightly for bonus randomness 
    imul ax, 13

    mov si, 320
    div si ; fit it to the first rows size

print_colour:
    mov di, dx

    ; Add the new snowflake
    mov al, 0x0F
    mov [es:di], al

    sub bx, 1
    cmp bx, 0
    jg paint_new_pixel ;loop until bx is 0

    ret

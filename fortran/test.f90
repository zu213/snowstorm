program snow_animation
    implicit none
    
    ! Terminal dimensions
    integer, parameter :: width = 80
    integer, parameter :: height = 24
    integer, parameter :: num_flakes = 60
    
    ! Snowflake properties
    integer :: x(num_flakes), y(num_flakes)
    real :: speed(num_flakes)
    
    ! Screen buffer
    character(len=1) :: screen(width, height)
    
    ! Variables
    integer :: i, j, frame
    real :: random_val
    character(len=20) :: clear_screen, hide_cursor, show_cursor, move_home
    integer :: count_rate, count_start, count_now
    real :: target_delay
    
    ! ANSI escape sequences
    clear_screen = char(27)//'[2J'
    hide_cursor = char(27)//'[?25l'
    show_cursor = char(27)//'[?25h'
    move_home = char(27)//'[H'
    
    ! Hide cursor
    write(*, '(A)', advance='no') hide_cursor
    
    ! Initialize random seed
    call random_seed()
    
    ! Get system clock rate
    call system_clock(count_rate=count_rate)
    target_delay = 0.05  ! 50 milliseconds between frames
    
    ! Initialize snowflakes
    do i = 1, num_flakes
        call random_number(random_val)
        x(i) = 1 + int(random_val * (width - 1))
        call random_number(random_val)
        y(i) = 1 + int(random_val * (height - 1))
        call random_number(random_val)
        speed(i) = 0.3 + random_val * 0.7
    end do
    
    ! Main animation loop
    do frame = 1, 1000
        ! Clear screen buffer
        screen = ' '
        
        ! Update and draw snowflakes
        do i = 1, num_flakes
            ! Update position (y increases = move down)
            y(i) = y(i) + 1
            
            ! Wrap around when snowflake reaches bottom
            if (y(i) > height) then
                call random_number(random_val)
                y(i) = 1
                x(i) = 1 + int(random_val * (width - 1))
            end if
            
            ! Draw snowflake
            if (x(i) >= 1 .and. x(i) <= width .and. &
                y(i) >= 1 .and. y(i) <= height) then
                screen(x(i), y(i)) = '*'
            end if
        end do
        
        ! Move cursor to home, clear screen, and display frame
        write(*, '(A)', advance='no') clear_screen
        write(*, '(A)', advance='no') move_home
        
        do j = 1, height
            do i = 1, width
                write(*, '(A)', advance='no') screen(i, j)
            end do
            write(*, '(A)') ''
        end do
        
        ! Delay using system clock for sub-second timing
        call system_clock(count_start)
        do
            call system_clock(count_now)
            if ((count_now - count_start) / real(count_rate) >= target_delay) exit
        end do
        
        ! Check if user wants to quit (optional)
        if (mod(frame, 50) == 0) then
            ! Could add input check here
        end if
    end do
    
    ! Show cursor again
    write(*, '(A)') show_cursor
    
    print *, ''
    print *, 'Animation complete!'

end program snow_animation
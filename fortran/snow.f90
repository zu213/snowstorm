program snow_animation
    implicit none
    
    ! Image dimensions
    integer, parameter :: width = 400
    integer, parameter :: height = 300
    integer, parameter :: num_frames = 60
    integer, parameter :: num_flakes = 150
    
    ! Snowflake properties
    real :: x(num_flakes), y(num_flakes)
    real :: speed(num_flakes)
    real :: size(num_flakes)
    
    ! Image buffer (RGB)
    integer :: image(width, height, 3)
    
    ! Loop variables
    integer :: frame, i, j, k
    integer :: px, py, radius
    character(len=50) :: filename
    real :: random_val
    
    ! Initialize random seed
    call random_seed()
    
    ! Initialize snowflakes with random positions and speeds
    do i = 1, num_flakes
        call random_number(random_val)
        x(i) = random_val * width
        call random_number(random_val)
        y(i) = random_val * height
        call random_number(random_val)
        speed(i) = 1.0 + random_val * 2.5  ! Speed between 1 and 3.5 pixels per frame
        call random_number(random_val)
        size(i) = 1.0 + random_val * 2.0   ! Size between 1 and 3 pixels
    end do
    
    ! Create frames directory
    call execute_command_line('mkdir -p frames', wait=.true.)
    
    ! Generate frames
    do frame = 1, num_frames
        ! Clear image to black
        image = 0
        
        ! Update and draw each snowflake
        do i = 1, num_flakes
            ! Update position
            y(i) = y(i) + speed(i)
            
            ! Wrap around if snowflake goes off bottom
            if (y(i) > height) then
                call random_number(random_val)
                y(i) = 0.0
                x(i) = random_val * width
            end if
            
            ! Draw snowflake (as a small circle/square)
            px = int(x(i))
            py = int(y(i))
            radius = int(size(i))
            
            ! Draw pixels around the snowflake position
            do j = -radius, radius
                do k = -radius, radius
                    if (px+j >= 1 .and. px+j <= width .and. &
                        py+k >= 1 .and. py+k <= height) then
                        ! White snowflake
                        image(px+j, py+k, 1) = 255
                        image(px+j, py+k, 2) = 255
                        image(px+j, py+k, 3) = 255
                    end if
                end do
            end do
        end do
        
        ! Write frame to PPM file in frames subdirectory
        write(filename, '(A,I4.4,A)') 'frames/frame_', frame, '.ppm'
        call write_ppm(filename, image, width, height)
        
        print *, 'Generated frame ', frame, ' of ', num_frames
    end do
    
    print *, ''
    print *, 'Animation complete! Frames saved in frames/ directory'
    print *, 'To view: convert frames/frame_*.ppm animation.gif'
    print *, 'Or use: ffmpeg -framerate 15 -i frames/frame_%04d.ppm output.mp4'
    
contains

    subroutine write_ppm(filename, img, w, h)
        character(len=*), intent(in) :: filename
        integer, intent(in) :: w, h
        integer, intent(in) :: img(w, h, 3)
        integer :: i, j, unit_num
        character(len=20) :: header
        
        unit_num = 10
        
        ! Open file for binary/unformatted writing
        open(unit=unit_num, file=filename, status='replace', &
             access='stream', form='unformatted')
        
        ! Write PPM header as raw bytes
        write(unit_num) 'P6', char(10)
        write(header, '(I0,1X,I0)') w, h
        write(unit_num) trim(header), char(10)
        write(unit_num) '255', char(10)
        
        ! Write pixel data as raw bytes
        do j = 1, h
            do i = 1, w
                write(unit_num) char(img(i, j, 1)), &
                                char(img(i, j, 2)), &
                                char(img(i, j, 3))
            end do
        end do
        
        close(unit_num)
    end subroutine write_ppm

end program snow_animation
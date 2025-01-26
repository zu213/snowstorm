program sdl_graphics
  use iso_c_binding
  implicit none

  ! SDL2 definitions
  interface
    subroutine SDL_Init(flags) bind(C, name="SDL_Init")
      import :: c_int
      integer(c_int), value :: flags
    end subroutine SDL_Init

    subroutine SDL_CreateWindow(title, x, y, w, h, flags) bind(C, name="SDL_CreateWindow")
      import :: c_int, c_char
      character(c_char), dimension(*), intent(in) :: title
      integer(c_int), value :: x, y, w, h, flags
    end subroutine SDL_CreateWindow

    subroutine SDL_CreateRenderer(window, index, flags) bind(C, name="SDL_CreateRenderer")
      import :: c_int
      integer(c_int), value :: window, index, flags
    end subroutine SDL_CreateRenderer

    subroutine SDL_RenderClear(renderer) bind(C, name="SDL_RenderClear")
      import :: c_int
      integer(c_int), value :: renderer
    end subroutine SDL_RenderClear

    subroutine SDL_SetRenderDrawColor(renderer, r, g, b, a) bind(C, name="SDL_SetRenderDrawColor")
      import :: c_int
      integer(c_int), value :: renderer, r, g, b, a
    end subroutine SDL_SetRenderDrawColor

    subroutine SDL_RenderPresent(renderer) bind(C, name="SDL_RenderPresent")
      import :: c_int
      integer(c_int), value :: renderer
    end subroutine SDL_RenderPresent

    subroutine SDL_Delay(ms) bind(C, name="SDL_Delay")
      import :: c_int
      integer(c_int), value :: ms
    end subroutine SDL_Delay

    subroutine SDL_Quit() bind(C, name="SDL_Quit")
    end subroutine SDL_Quit
  end interface

  integer(c_int) :: window, renderer
  integer(c_int), parameter :: SDL_INIT_VIDEO = 32
  integer(c_int), parameter :: SDL_WINDOW_SHOWN = 4
  integer(c_int), parameter :: SDL_RENDERER_ACCELERATED = 2

  ! Initialize SDL
  call SDL_Init(SDL_INIT_VIDEO)

  ! Create a window
  window = 0
  call SDL_CreateWindow("Simple SDL2 Window", 100, 100, 640, 480, SDL_WINDOW_SHOWN)

  ! Create a renderer
  renderer = 0
  call SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED)

  ! Set draw color to red (255, 0, 0)
  call SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)

  ! Clear screen
  call SDL_RenderClear(renderer)

  ! Present the renderer
  call SDL_RenderPresent(renderer)

  ! Wait for 2 seconds
  call SDL_Delay(2000)

  ! Clean up and quit
  call SDL_Quit

end program sdl_graphics

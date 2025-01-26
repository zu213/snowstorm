// To run/compile rust we navigate to this folder and run 'cargo run'

extern crate minifb;
// Import a bunch of stuff to simplify
use minifb::{Window, WindowOptions};
use rand::Rng;
use std::thread;
use std::time::Duration;

const WIDTH: usize = 320;
const HEIGHT: usize = 240;
const LENGTH: usize = WIDTH * HEIGHT;

fn main() {
    // Create a window
    let mut window = Window::new(
        "Snow",
        WIDTH,
        HEIGHT,
        WindowOptions {
            resize: false,
            ..WindowOptions::default()
        },
    ).expect("Unable to create window");

    // Create a buffer to hold pixel data
    let mut buffer: Vec<u32> = vec![0; WIDTH * HEIGHT];
    let mut rng = rand::thread_rng();
    let mut random_int: usize;

    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {
        for y in (0..HEIGHT).rev() {
            for x in 0..WIDTH {
                if buffer[y * WIDTH + x] == 0xFFFFFF {
                    if (y + 1) * WIDTH + x + 3 < LENGTH {
                        random_int = rng.gen_range(0..3);                  
                        buffer[y * WIDTH + x + 319 + random_int] = 0xFFFFFF;
                    }
                    buffer[y * WIDTH + x] = 0x000000;
                }
            }
        }
        thread::sleep(Duration::from_millis(50));

        // Add a new snow to top row
        for _z in 0..1 {
            random_int = rng.gen_range(0..WIDTH);
            buffer[random_int] = 0xFFFFFF;
        }

        // Update the window with the buffer
        window.update_with_buffer(&buffer, WIDTH, HEIGHT).expect("Failed to update buffer");

        // Sleep to control the frame rate
        std::thread::sleep(std::time::Duration::from_millis(16)); // 60 FPS
    }
}
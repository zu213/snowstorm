#include <SDL.h>
#include <stdio.h>
#include <cstdlib>
#include <ctime>

//Screen dimension constants
const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

void addSnowflakes(Uint32* pixels, int snowflakes) {
	for (int i = 0; i < snowflakes; ++i) {
		int x = rand() % SCREEN_WIDTH;
		pixels[x] = 0xFFFFFFFF;
	}
}

void animateSnowflakes(SDL_Renderer* renderer, SDL_Texture* texture) {
	// get bitmap of pixels
	Uint32* pixels = new Uint32[SCREEN_WIDTH * SCREEN_HEIGHT];
	SDL_Rect rect = { 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT };

	// iterate through bitmap
	SDL_RenderReadPixels(renderer, &rect, SDL_PIXELFORMAT_ARGB8888, pixels, SCREEN_WIDTH * sizeof(Uint32));
	for (int i = SCREEN_HEIGHT - 2; i >= 0; i--) {
		for (int j = 0; j < SCREEN_WIDTH; j++) {
			if (pixels[i * SCREEN_WIDTH + j] == 0xFFFFFFFF) {
				pixels[i * SCREEN_WIDTH + j] = 0x00000000;
				int direction = rand() % 5 - 2;
				pixels[(i + 1) * SCREEN_WIDTH + j + direction] = 0xFFFFFFFF;
			}
		}
	}

	addSnowflakes(pixels, 2);

	SDL_UpdateTexture(texture, NULL, pixels, SCREEN_WIDTH * sizeof(Uint32));
	
}

int main( int argc, char* args[] )
{
	SDL_Window* window = NULL;

	SDL_Renderer* renderer = NULL;

	SDL_Surface* screenSurface = NULL;

	//Initialize SDL
	if( SDL_Init( SDL_INIT_VIDEO ) < 0 ) {
		printf( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
		return -1;
	}

	// Create the window
	window = SDL_CreateWindow( "Snow", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
	if( window == NULL ) {
		printf( "Window could not be created! SDL_Error: %s\n", SDL_GetError() );
		return -1;
	}

	// Create the renderer
	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
	if (!renderer) {
		printf("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
		SDL_DestroyWindow(window);
		SDL_Quit();
		return -1;
	}

	// create a texture
	SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
		SDL_TEXTUREACCESS_STREAMING, SCREEN_WIDTH, SCREEN_HEIGHT);

	// initial setup
	SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
	SDL_RenderClear(renderer);
	SDL_RenderPresent(renderer);
            
    // Main loop
    SDL_Event e; 
	bool quit = false; 
	while (!quit) {
		// Handle quitting
		while (SDL_PollEvent(&e)) {
			if (e.type == SDL_QUIT) {
				quit = true;
			}
		}

		// Update snowflake positions

		animateSnowflakes(renderer, texture);

		SDL_RenderClear(renderer);
		// Copy the updated texture to the renderer and present it
		SDL_RenderCopy(renderer, texture, NULL, NULL);
		SDL_RenderPresent(renderer);

		// Framerate
		SDL_Delay(40);
	}

	//Destroy window and quit sdl
	SDL_DestroyWindow( window );
	SDL_Quit();

	return 0;
}

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
//gcc file.c -o executable

#define WIDTH 320
#define HEIGHT 240
const int length = WIDTH * HEIGHT;
DWORD pixels[WIDTH * HEIGHT] = {0};
HDC hdc;
HDC hdcMem;
HBITMAP hBitmap;
BITMAPINFO bitmapInfo;
int random;

void setupNewSnow(){
    random = rand() % WIDTH;
    pixels[random] = RGB(255, 255, 255);
}

void animateSnow(){
    // SLEEP - this will change speed snow falls
    Sleep(50);
    // You can also modify pixels here
    int pixelIndex = HEIGHT * WIDTH - 1;
    setupNewSnow();

    for(int i = HEIGHT; i > 0; i--){
        for(int j = 0; j < WIDTH; j++){
            if(GetRValue(pixels[pixelIndex]) == 255){
                pixels[pixelIndex] = RGB(0, 0, 0);
                if(pixelIndex + WIDTH < length){
                    random = rand() % 3;
                    pixels[pixelIndex + WIDTH - 1 + random] = RGB(255, 255, 255);
                }
            }
            pixelIndex--;
        }
    }
}


void setupScreen(HWND hwnd, WPARAM wParam, LPARAM lParam){
    hdc = GetDC(hwnd);
    hdcMem = CreateCompatibleDC(hdc);

    // Create bitmap and put it into memory
    hBitmap = CreateCompatibleBitmap(hdc, WIDTH, HEIGHT);
    SelectObject(hdcMem, hBitmap);

    // Set important parts of the bitmap
    bitmapInfo.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bitmapInfo.bmiHeader.biWidth = WIDTH;
    bitmapInfo.bmiHeader.biHeight = -HEIGHT;
    bitmapInfo.bmiHeader.biPlanes = 1;
    bitmapInfo.bmiHeader.biBitCount = 32;
    bitmapInfo.bmiHeader.biCompression = BI_RGB;

    // load pixels from bitmap
    
    GetDIBits(hdcMem, hBitmap, 0, HEIGHT, pixels, &bitmapInfo, DIB_RGB_COLORS);

}

void editScreen(HWND hwnd, WPARAM wParam, LPARAM lParam){

    animateSnow(pixels, WIDTH, HEIGHT);

    // Update the bitmap with modified pixel data
    SetDIBits(hdcMem, hBitmap, 0, HEIGHT, pixels, &bitmapInfo, DIB_RGB_COLORS);
    BitBlt(hdc, 0, 0, WIDTH, HEIGHT, hdcMem, 0, 0, SRCCOPY);
}

// Windows procedure 
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            editScreen(hwnd, wParam, lParam);
            break;
        }

        case WM_DESTROY:
            PostQuitMessage(0);
            break;

        default:
            return DefWindowProc(hwnd, uMsg, wParam, lParam);
    }
    return 0;
}

int main() {
    // initialise random
    srand(time(NULL));   // Initialization, should only be called once.

    // Setup window details
    WNDCLASS wc = {0};
    wc.lpfnWndProc = WindowProc;
    wc.lpszClassName = "Snow";
    wc.hInstance = GetModuleHandle(NULL);
    RegisterClass(&wc); // Let windows create the window

    // Create window
    HWND hwnd = CreateWindowEx(0, wc.lpszClassName, "Snow",
                               WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 240,
                               NULL, NULL, wc.hInstance, NULL);

    // setup snow
    setupScreen(hwnd, WIDTH, HEIGHT);

    // Main message loop - Windows work this way you need to keep doing this to update the graphics
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    // Cleanup
    DeleteObject(hBitmap);
    DeleteDC(hdcMem);
    ReleaseDC(hwnd, hdc);

    return 0;
}
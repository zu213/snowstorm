#include <windows.h>
#include <stdio.h>
//gcc file.c -o executable

void paint_snow(){

}

// Windows procedure 
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            // Setup the window context
            HDC hdc = GetDC(hwnd);
            HDC hdcMem = CreateCompatibleDC(hdc);
            int width = 320, height = 240;

            // Create bitmap and put it into memory
            HBITMAP hBitmap = CreateCompatibleBitmap(hdc, width, height);
            SelectObject(hdcMem, hBitmap);

            // Drawing on bit map (set colour then draw)
            SetBkColor(hdcMem, RGB(255, 255, 255));
            SetTextColor(hdcMem, RGB(0, 0, 0));

            SetPixel(hdcMem, 100, 100, RGB(255, 0, 0));


            // Set important parts of the bitmap
            BITMAPINFO bitmapInfo;
            bitmapInfo.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
            bitmapInfo.bmiHeader.biWidth = width;
            bitmapInfo.bmiHeader.biHeight = -height;
            bitmapInfo.bmiHeader.biPlanes = 1;
            bitmapInfo.bmiHeader.biBitCount = 32;
            bitmapInfo.bmiHeader.biCompression = BI_RGB;

            // load pixels from bitmap
            DWORD *pixels = (DWORD *)malloc(width * height * sizeof(DWORD));
            GetDIBits(hdcMem, hBitmap, 0, height, pixels, &bitmapInfo, DIB_RGB_COLORS);

            // You can also modify pixels here
            int pixelIndex = (50 * width) + 50;
            pixels[pixelIndex] = RGB(0, 0, 255);

            // Update the bitmap with modified pixel data
            SetDIBits(hdcMem, hBitmap, 0, height, pixels, &bitmapInfo, DIB_RGB_COLORS);
            BitBlt(hdc, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);

            // Cleanup
            free(pixels);
            DeleteObject(hBitmap);
            DeleteDC(hdcMem);
            ReleaseDC(hwnd, hdc);
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
    // Setup window details
    WNDCLASS wc = {0};
    wc.lpfnWndProc = WindowProc;
    wc.lpszClassName = "Snow";
    wc.hInstance = GetModuleHandle(NULL);
    RegisterClass(&wc); // Let windows create the window

    // Create window
    HWND hwnd = CreateWindowEx(0, wc.lpszClassName, "Pixel Manipulation in Windows",
                               WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 240,
                               NULL, NULL, wc.hInstance, NULL);

    // Main message loop - Windows work this way you need to keep doing this to update the graphics
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}
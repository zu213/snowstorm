import core.sys.windows.windows;
import std.stdio;
import core.thread;
import std.random;
import core.time;
import std.datetime;
import core.stdc.stdlib;

// Window procedure function
extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) nothrow;

void main()
{
    // Define the window class structure
    WNDCLASS wc = {};
    wc.lpfnWndProc = &WndProc; // The window procedure function
    wc.hInstance = GetModuleHandle(null);
    wc.lpszClassName = cast(const(wchar)*) "GDI_Window"; // Cast string to const(wchar)*

    // Register the window class
    if (RegisterClassW(&wc) == 0)
    {
        writeln("Window class registration failed.");
        return;
    }

    // Create the window
    HWND hwnd = CreateWindowExW(
        0, 
        wc.lpszClassName, 
        cast(const(wchar)*) "GDI Example Window", // Cast string to const(wchar)*
        WS_OVERLAPPEDWINDOW, 
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600, 
        null, null, wc.hInstance, null);

    if (hwnd == null)
    {
        writeln("Window creation failed.");
        return;
    }

    // Show the window
    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);
    
    // Initialize background
    backgroundPaint(hwnd);

    // Message loop
    MSG msg;
    while (GetMessageW(&msg, null, 0, 0) != 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);

        // Trigger paint by invalidating the window
        InvalidateRect(hwnd, null, true);  // Invalidate the entire window
        UpdateWindow(hwnd); // Force WM_PAINT to be sent

        Thread.sleep( dur!("msecs")( 50 ) ); // Delay to slow down the animation loop
    }
}

// Function to paint the background once (called during window creation)
void backgroundPaint(HWND hwnd)
{
    PAINTSTRUCT ps;
    HDC hdc = BeginPaint(hwnd, &ps);

    // Set the background color to black
    COLORREF color = RGB(0, 0, 0); 
    HBRUSH hBrush = CreateSolidBrush(color); // Create a brush with the desired color

    RECT rect;
    GetClientRect(hwnd, &rect); // Get the client area of the window
    FillRect(hdc, &rect, hBrush); 

    // Clean up
    DeleteObject(hBrush);

    // End painting
    EndPaint(hwnd, &ps);
}

// Window procedure function for handling messages
extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam)
{
    static bool backgroundPainted = false; // Flag for background painting
    static HBITMAP hBitmap;  // Bitmap handle
    static void* pBits;
    static HDC hdcMem;       // Memory device context for offscreen rendering
    static BITMAPINFO bmi;   // Bitmap info structure

    switch (msg)
    {
        case WM_ERASEBKGND:
        {
            // Skip background erasure (to avoid flickering)
            return 0;
        }

        case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // Get the width and height of the window
            RECT rect;
            GetClientRect(hwnd, &rect);
            int width = rect.right - rect.left;
            int height = rect.bottom - rect.top;

            // Initialize bitmap and buffer if not already done
            if (hBitmap is null) {
                // Create a compatible DC for offscreen rendering
                hdcMem = CreateCompatibleDC(hdc);

                // Create a bitmap with the window dimensions
                hBitmap = CreateCompatibleBitmap(hdc, width, height);
                SelectObject(hdcMem, hBitmap);

                // Set up the BITMAPINFO structure for the bitmap
                bmi.bmiHeader.biSize = cast(uint) BITMAPINFOHEADER.sizeof;
                bmi.bmiHeader.biWidth = width;
                bmi.bmiHeader.biHeight = -height;
                bmi.bmiHeader.biPlanes = 1;
                bmi.bmiHeader.biBitCount = 32; // 32-bit color (ARGB)
                bmi.bmiHeader.biCompression = BI_RGB;

                // Allocate memory for the pixel data buffer
                GetDIBits(hdcMem, hBitmap, 0, height, null, &bmi, DIB_RGB_COLORS);
                pBits = malloc(width * height * 4);
                GetDIBits(hdcMem, hBitmap, 0, height, pBits, &bmi, DIB_RGB_COLORS);
            }

            // Modify pixel data directly in the buffer (for example, changing a pixel color)
            int white = RGB(255, 255, 255); // White color
            int black = RGB(0, 0, 0); // Black color
            int* pixelData = cast(int*)pBits;  // Treat the buffer as an array of 32-bit integers (ARGB)

            // Traverse the buffer and change pixel colors as needed
            for (int i = height -1; i > 0; i--) {
                for (int j = 0; j < width; j++) {
                    int index = i * width + j;
                    if (pixelData[index] == white) {
                        pixelData[index] = black; // Change white to black
                        if (i < height - 1) {
                            pixelData[(i + 1) * width + j] = white; // Move white to next row
                        }
                    }
                }
            }

			int randomNumber = uniform(1, 799);


            COLORREF color = RGB(255, 0, 0); // Red color
			pixelData[randomNumber + 1000] = white;
			writeln("This is D!", randomNumber,pixelData[randomNumber]);
            // Update the bitmap with the modified buffer
            SetDIBits(hdc, hBitmap, 0, height, pBits, &bmi, DIB_RGB_COLORS);

            // Blit the bitmap to the screen
            BitBlt(hdc, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);

            // Clean up and end painting
            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        default:
            return DefWindowProcW(hwnd, msg, wParam, lParam);
    }
}

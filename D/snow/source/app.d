import core.sys.windows.windows;
import std.stdio;
import core.thread;
import std.random;
import core.time;
import std.datetime;
import core.stdc.stdlib;

extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) nothrow;

void main()
{
	// Setup some window details
    WNDCLASS wc = {};
    wc.lpfnWndProc = &WndProc; 
    wc.hInstance = GetModuleHandle(null);
    wc.lpszClassName = cast(const(wchar)*) "SNOW";

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
        cast(const(wchar)*) "Snow",
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

	SetTimer(hwnd, 1, 50, null); // setup timer to autoamtically fire messages to keep message loop going

    // Message loop
    MSG msg;
    while (GetMessageW(&msg, null, 0, 0) != 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);

        // Trigger paint by invalidating the window
        InvalidateRect(hwnd, null, true);  // Invalidate the entire window
        UpdateWindow(hwnd); // Force update window

 		// Delay to slow down the animation loop, this stops user interaction making the snow fall faster
        Thread.sleep( dur!("msecs")( 50 ) );
    }
}

// Handle windows message loop
extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam)
{
    static bool backgroundPainted = false; 
    static HBITMAP hBitmap; // Use bitmap for speed
    static void* pBits;
    static HDC hdcMem;
    static BITMAPINFO bmi;

    switch (msg)
    {
        case WM_ERASEBKGND:
        {
            return 0;
        }

        case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            RECT rect;
            GetClientRect(hwnd, &rect);
            int width = rect.right - rect.left;
            int height = rect.bottom - rect.top;

            // Initialize bitmap and buffer if not already done
            if (hBitmap is null) {
                hdcMem = CreateCompatibleDC(hdc);
                hBitmap = CreateCompatibleBitmap(hdc, width, height);
                SelectObject(hdcMem, hBitmap);

                // Set up the BITMAPINFO
                bmi.bmiHeader.biSize = cast(uint) BITMAPINFOHEADER.sizeof;
                bmi.bmiHeader.biWidth = width;
                bmi.bmiHeader.biHeight = -height;
                bmi.bmiHeader.biPlanes = 1;
                bmi.bmiHeader.biBitCount = 32;
                bmi.bmiHeader.biCompression = BI_RGB;

                GetDIBits(hdcMem, hBitmap, 0, height, null, &bmi, DIB_RGB_COLORS);
                pBits = malloc(width * height * 4);
                GetDIBits(hdcMem, hBitmap, 0, height, pBits, &bmi, DIB_RGB_COLORS);
            }

            int white = RGB(255, 255, 255);
            int black = RGB(0, 0, 0);
            int* pixelData = cast(int*)pBits;
            int localRandomNumber;

            // Loop through buffer and move snow
            for (int i = height -1; i > 0; i--) {
                for (int j = 0; j < width; j++) {
                    int index = i * width + j;
                    if (pixelData[index] == white) {
                        pixelData[index] = black;
                        if (i < height - 1) {
                            localRandomNumber = uniform(1,4);
                            pixelData[(i + 1) * width + j - 2 + localRandomNumber] = white;
                        }
                    }
                }
            }

			// add new random snow
			int randomNumber = uniform(1, 799);
			pixelData[randomNumber + 1000] = white;
			
            // Update the bitmap with the modified buffer
            SetDIBits(hdc, hBitmap, 0, height, pBits, &bmi, DIB_RGB_COLORS);
            BitBlt(hdc, 0, 0, width, height, hdcMem, 0, 0, SRCCOPY);

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

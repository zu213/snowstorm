// dub build/ dub run in parent folder to run this 'snow' run this


import core.sys.windows.windows;
import std.stdio;
import core.thread;
import core.time;

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

    // Message loop
    MSG msg;
    while (GetMessageW(&msg, null, 0, 0) != 0)
    {
        TranslateMessage(&msg);
        DispatchMessageW(&msg);

		InvalidateRect(hwnd, null, true);  // Invalidate the entire window
        UpdateWindow(hwnd); // Force WM_PAINT to be sent

        Thread.sleep( dur!("msecs")( 50 ) );
    }
}

// Window procedure function
extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg)
    {

		case WM_ERASEBKGND:
        {
            // background colour case
            HDC hdc = cast(HDC)wParam;

            COLORREF color = RGB(0,0,0); 
            HBRUSH hBrush = CreateSolidBrush(color); // Create a brush with the desired color

            RECT rect;
            GetClientRect(hwnd, &rect); // Get the client area of the window
            FillRect(hdc, &rect, hBrush); 

            // Clean up
            DeleteObject(hBrush);

            return 1;
        }

        case WM_PAINT:
        {
                        // Start drawing
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // Change a specific pixel (for example at coordinates (150, 150))
            int x = 150;
            int y = 150;
            COLORREF color = RGB(255, 0, 0); // Red color

            // Set the pixel at (150, 150) to red
            SetPixel(hdc, x, y, color);

            // Clean up
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

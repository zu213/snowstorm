import core.sys.windows.windows;
import std.stdio;

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
    }
}

// Window procedure function
extern (Windows) LRESULT WndProc(HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg)
    {
        case WM_PAINT:
        {
            // Start drawing
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            RECT rect;
            rect.left = 100;
            rect.top = 100;
            rect.right = 400;
            rect.bottom = 300;

            // Set the brush color to red
            HBRUSH hBrush = CreateSolidBrush(RGB(255, 0, 0));
            FillRect(hdc, &rect, hBrush);

            // Clean up
            DeleteObject(hBrush);
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

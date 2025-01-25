with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;

procedure Snow is

   -- Declare the MSG (message) structure for the message loop
   type MSG is record
      hwnd    : Interfaces.C.long;
      message : Interfaces.C.long;
      wParam  : Interfaces.C.long;
      lParam  : Interfaces.C.long;
      time    : Interfaces.C.long;
      pt      : Interfaces.C.long;
   end record;

   -- Declare the WNDCLASS type
   type WNDCLASS is record
      style          : Interfaces.C.long;
      lpfnWndProc    : access function (hwnd    : Interfaces.C.long;
                                          msg     : Interfaces.C.long;
                                          wParam  : Interfaces.C.long;
                                          lParam  : Interfaces.C.long) 
                                          return Interfaces.C.long;
      cbClsExtra     : Interfaces.C.long;
      cbWndExtra     : Interfaces.C.long;
      hInstance      : Interfaces.C.long;
      hIcon          : Interfaces.C.long;
      hCursor        : Interfaces.C.long;
      hbrBackground  : Interfaces.C.long;
      lpszMenuName   : access Interfaces.C.Char;
      lpszClassName  : access Interfaces.C.Char;
   end record;

   -- Declare external Windows functions using pragma Import
   function CreateWindowExA (ExStyle       : Interfaces.C.long;
                             ClassName     : access Interfaces.C.Char;
                             WindowName    : access Interfaces.C.Char;
                             Style         : Interfaces.C.long;
                             X, Y, Width, Height : Interfaces.C.long;
                             hWndParent, hMenu, hInstance, lpParam : Interfaces.C.long) 
                             return Interfaces.C.long;
      pragma Import (C, CreateWindowExA, "CreateWindowExA");

   procedure ShowWindow (hwnd : Interfaces.C.long; nCmdShow : Interfaces.C.long);
      pragma Import (C, ShowWindow, "ShowWindow");

   function GetLastError return Interfaces.C.long;
      pragma Import (C, GetLastError, "GetLastError");

   function GetModuleHandleA(lpModuleName : access Interfaces.C.Char) return Interfaces.C.long;
      pragma Import (C, GetModuleHandleA, "GetModuleHandleA");

   procedure UpdateWindow (hwnd : Interfaces.C.long);
      pragma Import (C, UpdateWindow, "UpdateWindow");

   function RegisterClassA (lpWndClass : access WNDCLASS) return Interfaces.C.long;
      pragma Import (C, RegisterClassA, "RegisterClassA");

   function BeginPaint (hwnd : Interfaces.C.long; lpPaint : Interfaces.C.long) 
                        return Interfaces.C.long;
      pragma Import (C, BeginPaint, "BeginPaint");

   function EndPaint (hwnd : Interfaces.C.long; lpPaint : Interfaces.C.long) 
                      return Interfaces.C.long;
      pragma Import (C, EndPaint, "EndPaint");

   function GetMessageA (lpMsg : access MSG; hwnd : Interfaces.C.long; 
                         wMsgFilterMin, wMsgFilterMax : Interfaces.C.long) 
                         return Interfaces.C.long;
      pragma Import (C, GetMessageA, "GetMessageA");

   procedure TranslateMessage (lpMsg : access MSG);
      pragma Import (C, TranslateMessage, "TranslateMessage");

   procedure DispatchMessageA (lpMsg : access MSG);
      pragma Import (C, DispatchMessageA, "DispatchMessageA");

   procedure PostQuitMessage (nExitCode : Interfaces.C.long);
      pragma Import (C, PostQuitMessage, "PostQuitMessage");

   procedure PostMessageA (hwnd    : Interfaces.C.long;
                          msg     : Interfaces.C.long;
                          wParam  : Interfaces.C.long;
                          lParam  : Interfaces.C.long);
      pragma Import (C, PostMessageA, "PostMessageA");

   -- Window procedure to handle messages (e.g., close event)
   function WndProc (hwnd    : Interfaces.C.long;
                     msg     : Interfaces.C.long;
                     wParam  : Interfaces.C.long;
                     lParam  : Interfaces.C.long) 
                     return Interfaces.C.long is
   begin
      case msg is
         when 15 => -- WM_PAINT message
            -- Handle paint here (you could add custom drawing)
            Ada.Text_IO.Put_Line("Painting the window...");
            return 0;
         when 2 => -- WM_CLOSE message
            PostQuitMessage(0);
         when others =>
            return 0;
      end case;
      return 0;
   end WndProc;

   -- Window handle and other constants
   HWnd : Interfaces.C.long;

   ClassName : constant String := "SimpleWindowClass";
   WindowName : constant String := "Ada GDI Window";
   terminator : constant Character := '0';

   -- Convert Ada string to C-style string (pointer to C.char)
   function To_C_String(S : String) return access Interfaces.C.Char is
      C_Char_Array : array (1 .. S'Length + 1) of Interfaces.C.Char;
   begin
      -- Populate C_Char_Array with characters from S
      for I in 1 .. S'Length loop
         C_Char_Array(I) := Interfaces.C.Char(S(I));
      end loop;

      -- Null-terminate the C string (adding the null byte)
      C_Char_Array(S'Length + 1) := Interfaces.C.Char'('0'); -- Space character as terminator

      -- Return access to the dynamically allocated array
      return new Interfaces.C.Char'(C_Char_Array(1));  -- Dynamically allocate and return the pointer
   end To_C_String;

begin
   -- Register the window class
   declare
      WndClassa : aliased WNDCLASS;
   begin
      WndClassa.style := Interfaces.C.long'(0);
      WndClassa.lpfnWndProc := WndProc'Access;
      WndClassa.cbClsExtra := Interfaces.C.long'(0);
      WndClassa.cbWndExtra := Interfaces.C.long'(0);
      WndClassa.hInstance := GetModuleHandleA(null);
      WndClassa.hIcon := Interfaces.C.long'(0);
      WndClassa.hCursor := Interfaces.C.long'(0);
      WndClassa.hbrBackground := Interfaces.C.long'(0);
      WndClassa.lpszMenuName := null;
      WndClassa.lpszClassName := To_C_String(ClassName);

      Ada.Text_IO.Put_Line("HWnd value: " & Interfaces.C.Long'Image(RegisterClassA(WndClassa'Access)));

   end;

   -- Create the window using Windows API
   HWnd := CreateWindowExA (0,
                            To_C_String(ClassName),  -- Pass the access type here
                            To_C_String(WindowName),  -- Pass the access type here
                            110, 20, 220, 500, 500,540, 0, 0, 0);

   -- Check if the window was created successfully
   -- Show the window
   ShowWindow(HWnd, 1);  -- 1 means SW_SHOWNORMAL (show the window)
   UpdateWindow(HWnd);

   -- Print "Hello, World!" to the console
   Ada.Text_IO.Put_Line("Hello, World!");

   -- Manually trigger the WM_PAINT message (request a paint)
   PostMessageA(HWnd, 15, 0, 0);  -- 15 corresponds to WM_PAINT

   -- Enter the message loop
   loop
      declare
         msga : aliased MSG;
      begin
         -- Get a message from the message queue
         if Integer(GetMessageA(msga'Access, HWnd, 0, 0)) = 0 then
            Ada.Text_IO.Put_Line("Bye, World!");
            exit;
         end if;

         -- Translate and dispatch the message
         TranslateMessage(msga'Access);
         DispatchMessageA(msga'Access);
      end;
   end loop;
end Snow;

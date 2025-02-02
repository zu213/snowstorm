with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

procedure Snow is
   use Interfaces.C;

   -- Ensure Windows API expects stdcall convention
   function WndProc (hwnd    : long;
                     msg     : long;
                     wParam  : long;
                     lParam  : long) return long;
   pragma Convention (Stdcall, WndProc);  -- FIXED: Use Stdcall instead of C

   -- Define Windows API types
   type MSG is record
      hwnd    : long;
      message : long;
      wParam  : long;
      lParam  : long;
      time    : long;
      pt      : long;
   end record;

   type WNDCLASS is record
      style          : long;
      lpfnWndProc    : access function (hwnd    : long;
                                        msg     : long;
                                        wParam  : long;
                                        lParam  : long) return long
                        with Convention => Stdcall;
      cbClsExtra     : long;
      cbWndExtra     : long;
      hInstance      : long;
      hIcon          : System.Address;
      hCursor        : System.Address;
      hbrBackground  : System.Address;
      lpszMenuName   : access Interfaces.C.Strings.chars_ptr;
      lpszClassName  : Interfaces.C.Strings.chars_ptr;
   end record;

   -- Declare Windows API functions
   function RegisterClassA (lpWndClass : access WNDCLASS) return long;
   pragma Import (Stdcall, RegisterClassA, "RegisterClassA");

   function CreateWindowExA (ExStyle       : long;
                             ClassName     : Interfaces.C.Strings.chars_ptr;
                             WindowName    : Interfaces.C.Strings.chars_ptr;
                             Style         : long;
                             X, Y, Width, Height : long;
                             hWndParent, hMenu    : access long;
                             hInstance : long;
                             lpParam: System.Address) 
                             return long;
   pragma Import (Stdcall, CreateWindowExA, "CreateWindowExA");

   function GetLastError return long;
   pragma Import (Stdcall, GetLastError, "GetLastError");

   function GetModuleHandleA(lpModuleName : access Interfaces.C.Char) return long;
   pragma Import (Stdcall, GetModuleHandleA, "GetModuleHandleA");

   procedure ShowWindow (hwnd : long; nCmdShow : long);
   pragma Import (Stdcall, ShowWindow, "ShowWindow");

   procedure UpdateWindow (hwnd : long);
   pragma Import (Stdcall, UpdateWindow, "UpdateWindow");

   function GetMessageA (lpMsg : access MSG; hwnd : long; wMsgFilterMin, wMsgFilterMax : long) 
                         return long;
   pragma Import (Stdcall, GetMessageA, "GetMessageA");

   procedure TranslateMessage (lpMsg : access MSG);
   pragma Import (Stdcall, TranslateMessage, "TranslateMessage");

   procedure DispatchMessageA (lpMsg : access MSG);
   pragma Import (Stdcall, DispatchMessageA, "DispatchMessageA");

   procedure PostQuitMessage (nExitCode : long);
   pragma Import (Stdcall, PostQuitMessage, "PostQuitMessage");

   -- Ensure WndProc has correct convention
   function WndProc (hwnd    : long;
                     msg     : long;
                     wParam  : long;
                     lParam  : long) return long is
   begin
      case msg is
         when 15 => -- WM_PAINT message
            Ada.Text_IO.Put_Line("Painting the window...");
            return 0;
         when 2 => -- WM_CLOSE message
            PostQuitMessage(0);
            return 0;
         when others =>
            return 0;
      end case;
   end WndProc;

   -- Window Handle
   HWnd : long;

   -- Window Class and Window Name
   ClassName  : constant String := "SimpleWindowClass";
   WindowName : constant String := "AdaGDIWindow";

   -- Convert Ada string to C-style string
   function To_C_String(S : String) return Interfaces.C.Strings.chars_ptr is
   begin
      return Interfaces.C.Strings.New_String(S);
   end To_C_String;

begin
   -- Register the window class
   declare
      WndClassa : aliased WNDCLASS;
      Result    : long;
      ClassName_C  : Interfaces.C.Strings.chars_ptr := To_C_String(ClassName);
      WindowName_C : Interfaces.C.Strings.chars_ptr := To_C_String(WindowName);
   begin
      WndClassa.lpszClassName := ClassName_C;
      WndClassa.lpszMenuName  := null;  -- No menu
      WndClassa.style         := 0;
      WndClassa.lpfnWndProc   := WndProc'Access;  -- FIXED: WndProc has correct convention
      WndClassa.cbClsExtra    := 0;
      WndClassa.cbWndExtra    := 0;
      WndClassa.hInstance     := GetModuleHandleA(null);
      WndClassa.hIcon         := System.Null_Address;
      WndClassa.hCursor       := System.Null_Address;
      WndClassa.hbrBackground := System.Null_Address;

      --Result := GetModuleHandleA(null);
      Ada.Text_IO.Put_Line("hInstance before window creation: " & long'Image(WndClassa.hInstance));

      Ada.Text_IO.Put_Line("Class Name: " & Interfaces.C.Strings.Value(ClassName_C));
      -- Register the class
      Result := RegisterClassA(WndClassa'Access);
      Ada.Text_IO.Put_Line("RegisterClassA result: " & long'Image(Result));
      if Result = 0 then
         Ada.Text_IO.Put_Line("RegisterClassA failed!");
         Ada.Text_IO.Put_Line("Error code: " & long'Image(GetLastError));
         return;
      else
         Ada.Text_IO.Put_Line("RegisterClassA succeeded.");
      end if;
      Ada.Text_IO.Put_Line("Window Name: " & Interfaces.C.Strings.Value(WindowName_C));
      Ada.Text_IO.Put_Line("Class Name: " & Interfaces.C.Strings.Value(ClassName_C));
      Ada.Text_IO.Put_Line("hInstance before window creation: " & long'Image(WndClassa.hInstance));

      -- Create the window
      HWnd := CreateWindowExA (0,
                               ClassName_C,  -- Must match the registered class name
                               WindowName_C,
                               0,   -- WS_OVERLAPPEDWINDOW
                               200, 0, 200, 0,
                               null, null, WndClassa.hInstance, System.Null_Address);

      if HWnd = 0 then
         declare
            ErrCode : long := GetLastError;
         begin
            Ada.Text_IO.Put_Line("CreateWindowExA failed!");
            Ada.Text_IO.Put_Line("Error code: " & long'Image(ErrCode));
         end;
         return;
      end if;

      -- Show and update the window
      ShowWindow(HWnd, 1);
      UpdateWindow(HWnd);

      -- Message loop
      loop
         declare
            msga : aliased MSG;
         begin
            if Integer(GetMessageA(msga'Access, HWnd, 0, 0)) = 0 then
               Ada.Text_IO.Put_Line("Exiting message loop.");
               exit;
            end if;
            TranslateMessage(msga'Access);
            DispatchMessageA(msga'Access);
         end;
      end loop;
   end;
end Snow;

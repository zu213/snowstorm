with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with Ada.Numerics.Discrete_Random;

procedure Snow is
   use Interfaces.C;

   -- Ensure Windows API expects C convention
   function WndProc (hwnd    : long;
                     msg     : long;
                     wParam  : long;
                     lParam  : long) return long;
   pragma Convention (C, WndProc);  -- FIXED: Use C instead of C

   -- Define Windows API types
   type MSG is record
      hwnd    : long;
      message : long;
      wParam  : long;
      lParam  : long;
      time    : long;
      pt      : long;
   end record;

   type WNDCLASSEX is record
      cbSize        : Interfaces.C.unsigned_long;
      style          : long;
      lpfnWndProc    : access function (hwnd    : long;
                                        msg     : long;
                                        wParam  : long;
                                        lParam  : long) return long
                        with Convention => C;
      cbClsExtra     : long;
      cbWndExtra     : long;
      hInstance      : Interfaces.C.unsigned_long;
      hIcon          : System.Address;
      hCursor        : System.Address;
      hbrBackground  : System.Address;
      lpszMenuName   : System.Address;
      lpszClassName  : Interfaces.C.Strings.chars_ptr;
      hIconSm        : System.Address;
   end record;

   -- Import many functions esp Windows api ones
   function RegisterClassExA (lpWndClass : access WNDCLASSEX) return long;
   pragma Import (Stdcall, RegisterClassExA, "RegisterClassExA");

   function CreateWindowExA (ExStyle       : Interfaces.C.unsigned_long;
                             ClassName     : Interfaces.C.Strings.chars_ptr;
                             WindowName    : Interfaces.C.Strings.chars_ptr;
                             Style         : Interfaces.C.unsigned_long;
                             X, Y, Width, Height : int;
                             hWndParent, hMenu    : System.Address;
                             hInstance : Interfaces.C.unsigned_long;
                             lpParam: System.Address) 
                             return long;
   pragma Import (Stdcall, CreateWindowExA, "CreateWindowExA");

   function FillRect(hdc : System.Address; lprc : System.Address; hbr : System.Address) return int;
   pragma Import(Stdcall, FillRect, "FillRect");

   function GetModuleHandleA(lpModuleName : access Interfaces.C.Char) return  Interfaces.C.unsigned_long;
   pragma Import (Stdcall, GetModuleHandleA, "GetModuleHandleA");

   procedure ShowWindow (hwnd : long; nCmdShow : long);
   pragma Import (Stdcall, ShowWindow, "ShowWindow");

   procedure UpdateWindow (hwnd : long);
   pragma Import (Stdcall, UpdateWindow, "UpdateWindow");

   function PeekMessageA (
   lpMsg         : access MSG;
   hwnd          : long;
   wMsgFilterMin : long;
   wMsgFilterMax : long;
   wRemoveMsg    : unsigned_long
   ) return int;
   pragma Import (Stdcall, PeekMessageA, "PeekMessageA");

   procedure TranslateMessage (lpMsg : access MSG);
   pragma Import (Stdcall, TranslateMessage, "TranslateMessage");

   procedure DispatchMessageA (lpMsg : access MSG);
   pragma Import (Stdcall, DispatchMessageA, "DispatchMessageA");

   procedure PostQuitMessage (nExitCode : long);
   pragma Import (Stdcall, PostQuitMessage, "PostQuitMessage");

   procedure Sleep (Milliseconds : Interfaces.C.unsigned_long);
   pragma Import (Stdcall, Sleep, "Sleep");

   function GetDC(hwnd : long) return System.Address;
   pragma Import(Stdcall, GetDC, "GetDC");

   function CreateCompatibleDC(hdc : System.Address) return System.Address;
   pragma Import(Stdcall, CreateCompatibleDC, "CreateCompatibleDC");

   function CreateCompatibleBitmap(hdc : System.Address; nWidth, nHeight : int) return System.Address;
   pragma Import(Stdcall, CreateCompatibleBitmap, "CreateCompatibleBitmap");

   function SelectObject(hdc, hgdiobj : System.Address) return System.Address;
   pragma Import(Stdcall, SelectObject, "SelectObject");

   function BitBlt(hdcDest : System.Address; nXDest, nYDest, nWidth, nHeight : int;
                   hdcSrc : System.Address; nXSrc, nYSrc : int; dwRop : unsigned_long) return int;
   pragma Import(Stdcall, BitBlt, "BitBlt");

   function SetPixel(hdc : System.Address; X, Y : int; Color : Interfaces.C.unsigned_long) return Interfaces.C.unsigned_long;
   pragma Import(Stdcall, SetPixel, "SetPixel");

   function GetStockObject (i : int) return System.Address;
   pragma Import (Stdcall, GetStockObject, "GetStockObject");

   function GetPixel(hdc : System.Address; X, Y : Interfaces.C.int) return Interfaces.C.unsigned_long;
   pragma Import(Stdcall, GetPixel, "GetPixel");

   function Random_Integer(top: Standard.Integer) return Integer is
      subtype My_Range is Integer range 1 .. top;
      package Random is new Ada.Numerics.Discrete_Random(My_Range);
      Gen : Random.Generator;
      Rand_Num : My_Range;
   begin
      Random.Reset(Gen);
      Rand_Num := Random.Random(Gen);
      return Rand_Num;
   end Random_Integer;

   -- Ensure WndProc has correct convention
   function WndProc (hwnd    : long;
                     msg     : long;
                     wParam  : long;
                     lParam  : long) return long is
   begin
      case msg is
         when 15 => -- WM_PAINT message
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
   ClassName  : constant String := "SimpleWindowClass1234" & ASCII.NUL;
   WindowName : constant String := "Snow" & ASCII.NUL;

   -- Halper function to convert Ada string to C-style string
   function To_C_String(S : String) return Interfaces.C.Strings.chars_ptr is
   begin
      return Interfaces.C.Strings.New_String(S);
   end To_C_String;

begin
   -- Register the window class
   declare
      WndClassa : aliased WNDCLASSEX;
      Result    : long;
      ClassName_C  : Interfaces.C.Strings.chars_ptr := To_C_String(ClassName);
      hInstance1, hInstance2 : Interfaces.C.unsigned_long;
      WindowName_C : Interfaces.C.Strings.chars_ptr := To_C_String(WindowName);
      Exists : Interfaces.C.int;
      memDC, hBitmap, oldBitmap, blackBrush, hdc : System.Address;
      return2: int;
      rect : aliased array (1 .. 4) of Interfaces.C.int := (0, 0, 320, 240); -- Full window size
   begin

      -- Registering class is legacy
      WndClassa.cbSize := WNDCLASSEX'Size / 8;
      WndClassa.lpszClassName := ClassName_C;
      WndClassa.lpszMenuName  := System.Null_Address;
      WndClassa.style         := 0;
      WndClassa.lpfnWndProc   := WndProc'Access;
      WndClassa.cbClsExtra    := 0;
      WndClassa.cbWndExtra    := 0;
      WndClassa.hInstance     := GetModuleHandleA(null);
      WndClassa.hIcon         := System.Null_Address;
      WndClassa.hCursor       := System.Null_Address;
      WndClassa.hbrBackground := GetStockObject(1); -- black background
      WndClassa.hIconSm      := System.Null_Address;
      WndClassa.hInstance := GetModuleHandleA(null);

      Result := RegisterClassExA(WndClassa'Access);

      -- create the window
      HWnd := CreateWindowExA (16#00000100#,
                               To_C_String("STATIC"),  -- This is static as registering a class doesnt work :(
                               WindowName_C,
                               16#00CF0000#,
                               100,100,320,240,
                               System.Null_Address, System.Null_Address, WndClassa.hInstance, System.Null_Address);

      -- Show and update the window
      ShowWindow(HWnd, 1);
      UpdateWindow(HWnd);

      -- make bitmap for faster updates
      hdc := GetDC(hwnd);
      hBitmap := CreateCompatibleBitmap(hdc, 320, 240);
      memDC := CreateCompatibleDC(hdc);

      -- Set the background color to black
      blackBrush := GetStockObject(4);
      return2 := FillRect(memDC, rect'Address, blackBrush);

      -- Select the bitmap into memory DC
      oldBitmap := SelectObject(memDC, hBitmap);
      return2 := BitBlt(hdc, 0, 0, 320, 240, memDC, 0, 0, 16#00CC0020#); -- SRCCOPY (copy directly)

      -- Message loop
      loop
         declare
            msga                        : aliased MSG;
            X, Y, hasMessage, returnVal : int;
            returnVal3, Color           : Interfaces.C.unsigned_long;
         begin
         -- Use peak so loop isn't stalled
            hasMessage := PeekMessageA(msga'Access, HWnd, 0, 0, 1);
            if hasMessage /= 0 then
               TranslateMessage(msga'Access);
               DispatchMessageA(msga'Access);
            end if;

            Sleep(1);

            -- Animate snow
            for Y in reverse 1 .. 238 loop
               for X in 0 .. 319 loop
                  Color := GetPixel(memDC, Interfaces.C.int(X), Interfaces.C.int(Y));
                  if Color = 16#FFFFFF# then
                     returnVal3 := SetPixel(memDC, Interfaces.C.int(X), Interfaces.C.int(Y), 16#000000#);
                     returnVal3 := SetPixel(memDC, Interfaces.C.int(X - 1 + Random_Integer(2)), Interfaces.C.int(Y + 1), 16#FFFFFF#);
                  end if;
               end loop;
            end loop;

            -- Add random pixel
            returnVal3 := SetPixel(memDC, Interfaces.C.int(Random_Integer(320)), Interfaces.C.int(1), 16#FFFFFF#);
            -- Copy the memory DC to the window
            returnVal := BitBlt(hdc, 0, 0, 320, 240, memDC, 0, 0, 16#00CC0020#); -- SRCCOPY (copy directly)
            UpdateWindow(HWnd); 
         end;
      end loop;
   end;
end Snow;

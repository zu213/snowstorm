
-- This doesnt compile because linking the necessary windows libraries seems to be nigh on undocumented.

with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;



procedure Snow is

   -- Define the MSG (message) structure to receive messages from the window
   type MSG is record
      hwnd    : Interfaces.C.long;  -- HWnd as long (we'll treat it as an integer)
      message : Interfaces.C.long;
      wParam  : Interfaces.C.long;
      lParam  : Interfaces.C.long;
      time    : Interfaces.C.long;
      pt      : Interfaces.C.long;
   end record;



   -- No need to manually set MSG'Size, let Ada handle it automatically

   -- Declare external Windows functions using pragma Import
   function CreateWindowExA (ExStyle       : Interfaces.C.long;
                             ClassName     : access Interfaces.C.Char;
                             WindowName    : access Interfaces.C.Char;
                             Style         : Interfaces.C.long;
                             X, Y, Width, Height : Interfaces.C.long;
                             hWndParent, hMenu, hInstance, lpParam : Interfaces.C.long) 
                             return Interfaces.C.long;
      pragma Import (C, CreateWindowExA, "CreateWindowExA");

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

   -- Window Procedure that processes messages sent to the window
   function WndProc (hwnd    : Interfaces.C.long;
                     msg     : Interfaces.C.long;
                     wParam  : Interfaces.C.long;
                     lParam  : Interfaces.C.long) 
                     return Interfaces.C.long is
   begin
      case msg is
         when 15 =>  -- WM_PAINT message
            -- Painting commands would go here
            null;
         when 2 =>  -- WM_DESTROY message
            PostQuitMessage(0);
         when others =>
            return 0;
      end case;
      return 0;
   end WndProc;

   -- Declare window handle
   HWnd : Interfaces.C.long;

   -- Declare class and window names as C-compatible strings
   ClassName : constant String := "GDI_Window";
   WindowName : constant String := "GDI Example Window";

   -- C-compatible string type conversion
   function To_C_String(S : String) return access Interfaces.C.Char is
      result : access Interfaces.C.Char;
      Length : Integer := S'Length;
      C_Char_Array : array (1 .. Length + 1) of Interfaces.C.Char;
   begin
      for I in 1 .. Length loop
         -- Directly assign the character converted to C.Char
         C_Char_Array(I) := Interfaces.C.Char(S(I));
      end loop;
      -- Ensure null-terminated string for C
      C_Char_Array(Length + 1) := Interfaces.C.Char'(' ');
      result := new Interfaces.C.Char'(C_Char_Array(1));
      return result;
   end To_C_String;

begin
   -- Create the window using the A versions of the functions that expect `Char` (ANSI)
   HWnd := CreateWindowExA (0, To_C_String(ClassName), To_C_String(WindowName), 
                            0, 0, 0, 500, 500, 0, 0, 0, 0);

   -- Enter the message loop
   loop
      declare
         msga : aliased MSG;
      begin

         -- Get a message from the message queue, passing a pointer to `msg`
         if Integer(GetMessageA(msga'Access, HWnd, 0, 0)) = 0 then
            exit;
         end if;

         -- Translate and dispatch the message
         TranslateMessage(msga'Access);
         DispatchMessageA(msga'Access);
      end;
   end loop;
end Snow;

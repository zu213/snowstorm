
-- This doesnt compile because linking the necessary windows libraries seems to be nigh on undocumented.

with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;



procedure Snow is

   -- Define the MSG (message) structure to receive messages from the window
   type MSG is record
      hwnd    : Interfaces.C.long;
      message : Interfaces.C.long;
      wParam  : Interfaces.C.long;
      lParam  : Interfaces.C.long;
      time    : Interfaces.C.long;
      pt      : Interfaces.C.long;
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
         when 15 =>
            -- Painting commands would go here
            null;
         when 2 =>
            PostQuitMessage(0);
         when others =>
            return 0;
      end case;
      return 0;
   end WndProc;

   HWnd : Interfaces.C.long;

   ClassName : constant String := "GDI_Window";
   WindowName : constant String := "GDI Example Window";

   function To_C_String(S : String) return access Interfaces.C.Char is
      result : access Interfaces.C.Char;
      Length : Integer := S'Length;
      C_Char_Array : array (1 .. Length + 1) of Interfaces.C.Char;
   begin
      for I in 1 .. Length loop
         C_Char_Array(I) := Interfaces.C.Char(S(I));
      end loop;
      C_Char_Array(Length + 1) := Interfaces.C.Char'(' ');
      result := new Interfaces.C.Char'(C_Char_Array(1));
      return result;
   end To_C_String;

begin
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

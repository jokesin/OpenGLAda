--------------------------------------------------------------------------------
-- Copyright (c) 2013, Felix Krause <contact@flyx.org>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;

with Interfaces.C.Strings;

with Glfw.API;
with Glfw.Enums;

package body Glfw.Windows is
   procedure Raw_Position_Callback (Raw  : System.Address;
                                    X, Y : Interfaces.C.int);
   procedure Raw_Size_Callback (Raw  : System.Address;
                                Width, Height : Interfaces.C.int);
   procedure Raw_Close_Callback (Raw  : System.Address);
   procedure Raw_Refresh_Callback (Raw  : System.Address);
   procedure Raw_Focus_Callback (Raw : System.Address; Focused : Bool);
   procedure Raw_Iconify_Callback (Raw : System.Address; Iconified : Bool);
   procedure Raw_Framebuffer_Size_Callback (Raw : System.Address;
                                            Width, Height : Interfaces.C.int);
   procedure Raw_Mouse_Button_Callback (Raw    : System.Address;
                                        Button : Input.Mouse.Button;
                                        State  : Input.Button_State;
                                        Mods   : Input.Keys.Modifiers);
   procedure Raw_Mouse_Position_Callback (Raw : System.Address;
                                          X, Y : Input.Mouse.Coordinate);
   procedure Raw_Mouse_Scroll_Callback (Raw  : System.Address;
                                        X, Y : Input.Mouse.Scroll_Offset);
   procedure Raw_Mouse_Enter_Callback (Raw  : System.Address;
                                       Action : Input.Mouse.Enter_Action);
   procedure Raw_Key_Callback (Raw : System.Address;
                               Key : Input.Keys.Key;
                               Scancode : Input.Keys.Scancode;
                               Action   : Input.Keys.Action);
   procedure Raw_Character_Callback (Raw  : System.Address;
                                     Char : Interfaces.C.unsigned);

   pragma Convention (C, Raw_Position_Callback);
   pragma Convention (C, Raw_Size_Callback);
   pragma Convention (C, Raw_Close_Callback);
   pragma Convention (C, Raw_Refresh_Callback);
   pragma Convention (C, Raw_Focus_Callback);
   pragma Convention (C, Raw_Iconify_Callback);
   pragma Convention (C, Raw_Framebuffer_Size_Callback);
   pragma Convention (C, Raw_Mouse_Button_Callback);
   pragma Convention (C, Raw_Mouse_Position_Callback);
   pragma Convention (C, Raw_Mouse_Scroll_Callback);
   pragma Convention (C, Raw_Mouse_Enter_Callback);
   pragma Convention (C, Raw_Key_Callback);
   pragma Convention (C, Raw_Character_Callback);

   procedure Raw_Position_Callback (Raw  : System.Address;
                                    X, Y : Interfaces.C.int) is
   begin
      API.Get_Window_User_Pointer (Raw).Position_Changed
        (Integer (X), Integer (Y));
   end Raw_Position_Callback;

   procedure Raw_Size_Callback (Raw  : System.Address;
                                Width, Height : Interfaces.C.int) is
   begin
      API.Get_Window_User_Pointer (Raw).Size_Changed
        (Natural (Width), Natural (Height));
   end Raw_Size_Callback;

   procedure Raw_Close_Callback (Raw  : System.Address) is
   begin
      API.Get_Window_User_Pointer (Raw).Closing;
   end Raw_Close_Callback;

   procedure Raw_Refresh_Callback (Raw  : System.Address) is
   begin
      API.Get_Window_User_Pointer (Raw).Refresh;
   end Raw_Refresh_Callback;

   procedure Raw_Focus_Callback (Raw : System.Address; Focused : Bool) is
   begin
      API.Get_Window_User_Pointer (Raw).Focus_Changed (Boolean (Focused));
   end Raw_Focus_Callback;

   procedure Raw_Iconify_Callback (Raw : System.Address; Iconified : Bool) is
   begin
      API.Get_Window_User_Pointer (Raw).Iconification_Changed
        (Boolean (Iconified));
   end Raw_Iconify_Callback;

   procedure Raw_Framebuffer_Size_Callback (Raw : System.Address;
                                            Width, Height : Interfaces.C.int) is
   begin
      API.Get_Window_User_Pointer (Raw).Framebuffer_Size_Changed
        (Natural (Width), Natural (Height));
   end Raw_Framebuffer_Size_Callback;

   procedure Raw_Mouse_Button_Callback (Raw    : System.Address;
                                        Button : Input.Mouse.Button;
                                        State  : Input.Button_State;
                                        Mods   : Input.Keys.Modifiers) is
   begin
      API.Get_Window_User_Pointer (Raw).Mouse_Button_Changed
        (Button, State, Mods);
   end Raw_Mouse_Button_Callback;

   procedure Raw_Mouse_Position_Callback (Raw : System.Address;
                                          X, Y : Input.Mouse.Coordinate) is
   begin
      API.Get_Window_User_Pointer (Raw).Mouse_Position_Changed (X, Y);
   end Raw_Mouse_Position_Callback;


   procedure Raw_Mouse_Scroll_Callback (Raw  : System.Address;
                                        X, Y : Input.Mouse.Scroll_Offset) is
   begin
      API.Get_Window_User_Pointer (Raw).Mouse_Scrolled (X, Y);
   end Raw_Mouse_Scroll_Callback;


   procedure Raw_Mouse_Enter_Callback (Raw  : System.Address;
                                       Action : Input.Mouse.Enter_Action) is
   begin
      API.Get_Window_User_Pointer (Raw).Mouse_Entered (Action);
   end Raw_Mouse_Enter_Callback;

   procedure Raw_Key_Callback (Raw : System.Address;
                               Key : Input.Keys.Key;
                               Scancode : Input.Keys.Scancode;
                               Action   : Input.Keys.Action) is
   begin
      API.Get_Window_User_Pointer (Raw).Key_Changed (Key, Scancode, Action);
   end Raw_Key_Callback;

   procedure Raw_Character_Callback (Raw  : System.Address;
                                     Char : Interfaces.C.unsigned) is
      function Convert is new Ada.Unchecked_Conversion
        (Interfaces.C.unsigned, Wide_Wide_Character);
   begin
      API.Get_Window_User_Pointer (Raw).Character_Entered (Convert (Char));
   end Raw_Character_Callback;

   procedure Init(Object        : not null access Window;
                  Width, Height : Natural;
                  Title         : String;
                  Monitor       : Monitors.Monitor;
                  Share_Resources_With : access Window'Class := null) is
      use type System.Address;
      C_Title : Interfaces.C.Strings.chars_ptr
        := Interfaces.C.Strings.New_String (Title);
      Share : System.Address;
   begin
      if Object.Handle /= System.Null_Address then
         raise Operation_Exception with "Window has already been initialized";
      end if;
      if Share_Resources_With = null then
         Share := System.Null_Address;
      else
         Share := Share_Resources_With.Handle;
      end if;

      Object.Handle := API.Create_Window (Interfaces.C.int (Width),
                                          Interfaces.C.int (Height),
                                          C_Title, Monitor.Raw_Pointer, Share);
      Interfaces.C.Strings.Free (C_Title);
      API.Set_Window_User_Pointer (Object.Handle, Object);
   end Init;

   procedure Enable_Callback (Object  : not null access Window;
                              Subject : Callback) is
   begin
      case Subject is
         when Position => API.Set_Window_Pos_Callback (Object.Handle, Raw_Position_Callback'Access);
         when Size => API.Set_Window_Size_Callback (Object.Handle, Raw_Size_Callback'Access);
         when Close => API.Set_Window_Close_Callback (Object.Handle, Raw_Close_Callback'Access);
         when Refresh => API.Set_Window_Refresh_Callback (Object.Handle, Raw_Refresh_Callback'Access);
         when Focus => API.Set_Window_Focus_Callback (Object.Handle, Raw_Focus_Callback'Access);
         when Iconify => API.Set_Window_Iconify_Callback (Object.Handle, Raw_Iconify_Callback'Access);
         when Framebuffer_Size => API.Set_Framebuffer_Size_Callback (Object.Handle, Raw_Framebuffer_Size_Callback'Access);
         when Mouse_Button => API.Set_Mouse_Button_Callback (Object.Handle, Raw_Mouse_Button_Callback'Access);
         when Mouse_Position => API.Set_Cursor_Pos_Callback (Object.Handle, Raw_Mouse_Position_Callback'Access);
         when Mouse_Scroll => API.Set_Scroll_Callback (Object.Handle, Raw_Mouse_Scroll_Callback'Access);
         when Mouse_Enter => null;
         when Key => null;
         when Char => null;
      end case;
   end Enable_Callback;

   procedure Get_OpenGL_Version (Object : not null access Window;
                                 Major, Minor, Revision : out Natural) is
      Value : Interfaces.C.int;
   begin
      Value := API.Get_Window_Attrib (Object.Handle, Enums.Context_Version_Major);
      Major := Natural (Value);
      Value := API.Get_Window_Attrib (Object.Handle, Enums.Context_Version_Minor);
      Minor := Natural (Value);
      Value := API.Get_Window_Attrib (Object.Handle, Enums.Context_Revision);
      Revision := Natural (Value);
   end Get_OpenGL_Version;

end Glfw.Windows;

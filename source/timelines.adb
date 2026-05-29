with Ada.Text_IO;
with Timelines.Test;
with Ada.Calendar;

package body Timelines is

  --procedure Read(T: out Time_Line_Record, Input_File_Name: in String);

  function "=" (Left, Right : in Ada.Calendar.Time) return Boolean is
    use Ada.Calendar;
  begin
    return not (Left < Right) and not (Right < Left);
  end "=";

  procedure Read_And_Print_Timeline(Input_File_Name: in String) is

  begin

    Timelines.Test.Lexer_Test(Input_File_Name);

  end Read_And_Print_Timeline;


--  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String) is

--  begin
  --  Ada.Text_IO.Open(Lexer.Input_File, Ada.Text_IO.In_File, Input_File_Name);
    
    --Ada.Text_IO.Close(Lexer.Input_File);
 -- end Init_Lexer;


end Timelines;

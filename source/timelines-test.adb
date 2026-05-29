with Ada.Text_IO;
with Timelines.Lexer;

package body Timelines.Test is


  procedure Lexer_Test(Input_File_Name: in String) is

    Lexer_Instance: Lexer.Lexer_Type;
    Current_Token: Lexer.Token_Type;

    use type Lexer.Token_Category;

  begin

    Ada.Text_IO.Put_Line("Reading file with name: " & Input_File_Name);

    Lexer.Init_Lexer(Lexer_Instance, Input_File_Name);

    loop
      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Error then
        Ada.Text_IO.Put("Line " & Lexer.Get_Line(Current_Token)'Image & ", ");
        Ada.Text_IO.Put("Column " & Lexer.Get_Column(Current_Token)'Image & ": ");
        Ada.Text_IO.Put("Error: " & Lexer.Get_Value(Current_Token));

      else

        Ada.Text_IO.Put("Line " & Lexer.Get_Line(Current_Token)'Image & ", ");
        Ada.Text_IO.Put("Column " & Lexer.Get_Column(Current_Token)'Image & ": ");
        Ada.Text_IO.Put("Category: " & Lexer.Get_Category(Current_Token)'Image & " / ");
        Ada.Text_IO.Put("Value: " & Lexer.Get_Value(Current_Token));
        Ada.Text_IO.New_Line;

      end if;

      if Lexer.Get_Category(Current_Token) = Lexer.Last_Event then
        Ada.Text_IO.Put_Line("EOF reached.");
      end if;

      exit when Lexer.Get_Category(Current_Token) = Lexer.Error or Lexer.Get_Category(Current_Token) = Lexer.Last_Event;

    end loop;

    Lexer.Finalize_Lexer(Lexer_Instance);

  end Lexer_Test;


end Timelines.Test;

with Timelines.Lexer;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Strings.Unbounded;


package body Timelines.Parser is

  procedure Read_Timeline(Input_File_Name: in String; Year_Of_Interest: in Ada.Calendar.Year_Number; TC: out Timeline_Container) is

    use type Lexer.Token_Category;

    Lexer_Instance: Lexer.Lexer_Type;
    Current_Token: Lexer.Token_Type;
    Current_Event_Column: Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String("???");


    procedure Start_Reading is
    begin

      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Column then

        Current_Event_Column := Lexer.Get_Value(Current_Token);

        if not Has_Event_Column(TC, Current_Event_Column) then
          Add_Event_Column(TC, Current_Event_Column);
        end if;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error encountered: " & Lexer.Get_Value_As_String(Current_Token) );

      else

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                "Definition of first column expected");

      end if; 

    end Start_Reading;


  begin

    Lexer.Init_Lexer(Lexer_Instance, Input_File_Name);

    declare
    begin

      Init_Timeline_Container(TC, Year_Of_Interest);

      Start_Reading;

    exception
      when Event: others =>
        Ada.Text_IO.Put_Line("Problem while reading input encountered: "
                              & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );
    end;

    Lexer.Finalize_Lexer(Lexer_Instance);

  exception
    when Event: others =>
      Ada.Text_IO.Put_Line("Problem with input file handling: "
                            & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );

  end Read_Timeline;

end Timelines.Parser;

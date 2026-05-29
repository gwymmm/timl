with Ada.Text_IO;
with Ada.Strings.Unbounded;

private package Timelines.Lexer is

  type Lexer_Type is limited private;

  type Token_Type is private;

  type Token_Category is (Column, Event, Date, Date_Separator, Error, Last_Event);

  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String);

  function In_Error_State(Lexer: in Lexer_Type) return Boolean;

  function End_Of_File_Reached(Lexer: in Lexer_Type) return Boolean;

  procedure Next_Token(Lexer: in out Lexer_Type; Token: out Token_Type);

  procedure Finalize_Lexer(Lexer: in out Lexer_Type);

  function Get_Line(T: Token_Type) return Positive;

  function Get_Column(T: Token_Type) return Positive;

  function Get_Category(T: Token_Type) return Token_Category;

  function Get_Value(T: Token_Type) return String;

private

  type Lexer_Type is 
    record
      Input_File: Ada.Text_IO.File_Type;
      End_Of_File_Reached: Boolean;
      In_Error_State: Boolean;
   end record;

  type Token_Location is
    record
      Line_Number: Ada.Text_IO.Positive_Count;
      Column_Number: Ada.Text_IO.Positive_Count;
  end record;

  type Token_Type is
    record
      Category: Token_Category;
      Location: Token_Location;
      Value: Ada.Strings.Unbounded.Unbounded_String;
  end record;

end Timelines.Lexer;
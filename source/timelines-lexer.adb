with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Characters.Handling;

package body Timelines.Lexer is

  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String) is
  begin
    Ada.Text_IO.Open(Lexer.Input_File, Ada.Text_IO.In_File, Input_File_Name);
    Lexer.End_Of_File_Reached := False;
    Lexer.In_Error_State := False;
  end Init_Lexer;


  procedure Finalize_Lexer(Lexer: in out Lexer_Type) is
  begin
    Ada.Text_IO.Close(Lexer.Input_File);
  end Finalize_Lexer;


  function In_Error_State(Lexer: in Lexer_Type) return Boolean is
    (Lexer.In_Error_State);

  function End_Of_File_Reached(Lexer: in Lexer_Type) return Boolean is
    (Lexer.End_Of_File_Reached);


  function Get_Line(T: Token_Type) return Positive is
    ( Positive(T.Location.Line_Number) );

  function Get_Column(T: Token_Type) return Positive is
    ( Positive(T.Location.Column_Number) );

  function Get_Category(T: Token_Type) return Token_Category is
    ( T.Category );

  function Get_Value(T: Token_Type) return String is
    ( Ada.Strings.Unbounded.To_String(T.Value) );


-- main lexer function
  procedure Next_Token(Lexer: in out Lexer_Type; Token: out Token_Type) is

    package CH renames Ada.Characters.Handling;

    Current_Token: Token_Type;

    procedure Next_Char(C: out Character) is
    begin

      Token.Location.Line_Number :=  Ada.Text_IO.Line(Lexer.Input_File);
      Token.Location.Column_Number :=  Ada.Text_IO.Col(Lexer.Input_File);

      if Ada.Text_IO.End_Of_File(Lexer.Input_File) then
        Lexer.End_Of_File_Reached := True;
        C := '?';

      -- 'Get' would skip line terminators, we convert them to whitespace instead to make them visible for the Lexer
      elsif Ada.Text_IO.End_Of_Line(Lexer.Input_File) then
        C := ' ';
        Ada.Text_IO.Skip_Line(Lexer.Input_File);
      else
        Ada.Text_IO.Get(Lexer.Input_File, C);
      end if;

    end Next_Char;

-- lexer grammar
    Current_Character: Character;

    procedure Read_Date is
    begin

      Next_Char(Current_Character);

      if Lexer.End_Of_File_Reached then

        Lexer.In_Error_State := True;
        Token.Category := Error;
        Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
          "Unexpected end of file encountered. An event needs to be specified for each date.");

      elsif CH.Is_Digit(Current_Character) or Current_Character = '-' then

        Ada.Strings.Unbounded.Append(Token.Value, Current_Character);
        Read_Date;

      elsif CH.Is_Space(Current_Character) then

        Token.Category := Date;

      end if;

      return;

    end Read_Date;


    procedure Read_Column_Or_Event is
    begin

      Next_Char(Current_Character);

      if Lexer.End_Of_File_Reached then

        Token.Category := Last_Event;

      elsif CH.Is_Alphanumeric(Current_Character) or Current_Character = '_' then

        Ada.Strings.Unbounded.Append(Token.Value, Current_Character);
        Read_Column_Or_Event;

      elsif CH.Is_Space(Current_Character) then

        Token.Category := Event;

      elsif Current_Character = ':' then

        Token.Category := Column;

      else

        Lexer.In_Error_State := True;
        Token.Category := Error;
        Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
          "Unexpected character encountered: " & Current_Character);

      end if;

      return;

    end Read_Column_Or_Event;


    procedure Start_Reading is
    begin

      Next_Char(Current_Character);

      if Lexer.End_Of_File_Reached then

        Lexer.In_Error_State := True;
        Token.Category := Error;
        Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
          "Unexpected end of file encountered. Further input expected (column name, date or event).");

      elsif Current_Character = '#' then

        Ada.Text_IO.Skip_Line(Lexer.Input_File);
        Start_Reading;

      elsif CH.Is_Space(Current_Character) then

        Start_Reading;

      elsif CH.Is_Letter(Current_Character) then

        Ada.Strings.Unbounded.Append(Token.Value, Current_Character);
        Read_Column_Or_Event;

      elsif CH.Is_Digit(Current_Character) then

        Ada.Strings.Unbounded.Append(Token.Value, Current_Character);
        Read_Date;

      elsif Current_Character = '-' then

        Next_Char(Current_Character);

        if Lexer.End_Of_File_Reached or Current_Character /= '-' then
          Lexer.In_Error_State := True;
          Token.Category := Error;
          Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
            "Unexpected character sequence. Expected '--' as date separator.");
          return;
        end if;

        Next_Char(Current_Character);

        if Lexer.End_Of_File_Reached or not CH.Is_Space(Current_Character) then
          Lexer.In_Error_State := True;
          Token.Category := Error;
          Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
            "Unexpected character sequence. Expected '--' as date separator followed by a whitespace character.");
          return;
        end if;

        Token.Category := Date_Separator;

      else

        Lexer.In_Error_State := True;
        Token.Category := Error;
        Token.Value := Ada.Strings.Unbounded.To_Unbounded_String(
          "Unexpected character encountered: " & Current_Character);

      end if;

      return;

    end Start_Reading;


  begin

    Token.Value := Ada.Strings.Unbounded.Null_Unbounded_String;

    Start_Reading;

  end Next_Token;

end Timelines.Lexer;
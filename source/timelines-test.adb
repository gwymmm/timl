with Ada.Text_IO;
with Timelines.Lexer;
with Ada.Strings.Unbounded;
with Ada.Calendar;

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


  procedure Timeline_Datastructure_Test is

    use Ada.Strings.Unbounded;
    use Ada.Calendar;

    TC: Timeline_Container;
    Y: constant Year_Number := 2026;

  begin

    Init_Timeline_Container(TC, Year_Of_Interest => Y);
    Add_Event_Column(TC, To_Unbounded_String("Bavarian Holidays"));
    Add_Event_Column(TC, To_Unbounded_String("Indian Holidays"));

    Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Neujahrstag"), Time_Of(Y,1,1));
    Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Heilige Drei Könige"), Time_Of(Y,1,6));
    Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Fastnacht"), Time_Of(Y,2,16));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Karfreitag"), Time_Of(Y,4,3));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Ostermontag"), Time_Of(Y,4,6));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Tag der Arbeit"), Time_Of(Y,5,1));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Muttertag"), Time_Of(Y,5,10));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Vatertag"), Time_Of(Y,5,14));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Pfingstmontag"), Time_Of(Y,5,25));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Fronleichnam"), Time_Of(Y,6,4));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Maria Himmelfahrt"), Time_Of(Y,8,15));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Tag der deutschen Einheit"), Time_Of(Y,10,3));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Allerheiligen"), Time_Of(Y,11,1));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Weihnachtstag"), Time_Of(Y,12,25));
    --Set_Event(TC, To_Unbounded_String("Bavarian Holidays"), To_Unbounded_String("Zweiter Weihnachtsfeiertag"), Time_Of(Y,12,26));

    Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Republic Day"), Time_Of(Y,1,26));
    Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Holi"), Time_Of(Y,3,4));
    Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Id-ul-Fitr"), Time_Of(Y,3,21));
    Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Rama Navami"), Time_Of(Y,3,26));
    Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Mahavir Jayanti"), Time_Of(Y,3,31));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Good Friday"), Time_Of(Y,4,3));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Buddha Purnima"), Time_Of(Y,5,1));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Id-ul-Zuha"), Time_Of(Y,5,27));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Muharram"), Time_Of(Y,6,26));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Independence Day"), Time_Of(Y,8,15));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Id-e-Milad"), Time_Of(Y,8,26));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Janmashtami"), Time_Of(Y,9,4));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Mahatma Gandhi Jayanti"), Time_Of(Y,10,2));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Dussehra"), Time_Of(Y,10,20));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Diwali"), Time_Of(Y,11,8));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Guru Nanak Jayanti"), Time_Of(Y,11,24));
    --Set_Event(TC, To_Unbounded_String("Indian Holidays"), To_Unbounded_String("Christmas Day"), Time_Of(Y,12,25));

    Print_Timeline(TC);

  end Timeline_Datastructure_Test;


end Timelines.Test;

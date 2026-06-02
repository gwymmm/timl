with Timelines.Test;
with Ada.Calendar.Arithmetic;

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


  procedure Init_Timeline_Container(TC: out Timeline_Container; Year_Of_Interest: in Ada.Calendar.Year_Number) is

    First_Day_Of_Year: constant Ada.Calendar.Time := Ada.Calendar.Time_Of(Year_Of_Interest, Month => 1, Day => 1);

    Current_Date: Ada.Calendar.Time := First_Day_Of_Year;
    Current_Index: Positive := 1;

  begin

    Time_Axes.Reserve_Capacity(TC.Time_Axis, TIMELINE_INTERVAL_IN_DAYS);

    while Ada.Calendar.Year(Current_Date) = Year_Of_Interest loop

      Time_Axes.Append(TC.Time_Axis, Current_Date);
      Date_Maps.Insert(TC.Date_To_Time_Axis_Index_Map, Key => Current_Date, New_Item => Current_Index);

      Current_Date := Ada.Calendar.Arithmetic."+"(Current_Date, 1);
      Current_Index := Current_Index + 1;
    end loop;

  end Init_Timeline_Container;


  function Has_Event_Column(TC: in Timeline_Container; Col_Name: in Ada.Strings.Unbounded.Unbounded_String) return Boolean is
  begin
    return Col_Name_Maps.Contains(TC.Col_Name_To_Col_Index_Map, Key => Col_Name);
  end Has_Event_Column;


  procedure Add_Event_Column(TC: in out Timeline_Container; New_Col_Name: in Ada.Strings.Unbounded.Unbounded_String) is

    Time_Line_Length: constant Ada.Containers.Count_Type := Time_Axes.Length(TC.Time_Axis);

    Empty_Event: constant Ada.Strings.Unbounded.Unbounded_String :=
      Ada.Strings.Unbounded.To_Unbounded_String(" ");

    Empty_Event_Column: constant Events.Vector :=
      Events.To_Vector(New_Item => Empty_Event, Length => Time_Line_Length);

    New_Index: constant Positive := Col_Names_Vectors.Last_Index(TC.Col_Names) + 1;

  begin

    Col_Name_Maps.Insert(TC.Col_Name_To_Col_Index_Map, Key => New_Col_Name, New_Item => New_Index);
    Col_Names_Vectors.Append(TC.Col_Names, New_Col_Name);
    Event_Columns.Append(TC.Columns, Empty_Event_Column);

  end Add_Event_Column;


--  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String) is

--  begin
  --  Ada.Text_IO.Open(Lexer.Input_File, Ada.Text_IO.In_File, Input_File_Name);

    --Ada.Text_IO.Close(Lexer.Input_File);
 -- end Init_Lexer;


end Timelines;

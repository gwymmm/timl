with Timelines.Test;
with Ada.Calendar.Arithmetic;
with Ada.Calendar.Formatting;
with Ada.Text_IO;
with Ada.Strings.Fixed;
with Ada.Integer_Text_IO;

package body Timelines is

  --procedure Read(T: out Time_Line_Record, Input_File_Name: in String);

  function "=" (Left, Right : in Ada.Calendar.Time) return Boolean is
    use Ada.Calendar;
  begin
    return not (Left < Right) and not (Right < Left);
  end "=";


  procedure Read_And_Print_Timeline(Input_File_Name: in String) is

  begin

    --Timelines.Test.Lexer_Test(Input_File_Name);
    Timelines.Test.Timeline_Datastructure_Test;

  end Read_And_Print_Timeline;


  procedure Init_Timeline_Container(TC: out Timeline_Container; Year_Of_Interest: in Ada.Calendar.Year_Number) is

    First_Day_Of_Year: constant Ada.Calendar.Time := Ada.Calendar.Time_Of(Year_Of_Interest, Month => 1, Day => 1);

    Current_Date: Ada.Calendar.Time := First_Day_Of_Year;
    Current_Index: Positive := 1;

    package Positive_IO is new Ada.Text_IO.Integer_IO(Positive);

  begin

    Time_Axes.Reserve_Capacity(TC.Time_Axis, TIMELINE_INTERVAL_IN_DAYS);

    while Ada.Calendar.Year(Current_Date) = Year_Of_Interest loop

      Time_Axes.Append(TC.Time_Axis, Current_Date);
      Date_Maps.Insert(TC.Date_To_Time_Axis_Index_Map, Key => Current_Date, New_Item => Current_Index);

      Current_Date := Ada.Calendar.Arithmetic."+"(Current_Date, 1);
      Current_Index := Current_Index + 1;

    end loop;

    for C in Date_Maps.Iterate(TC.Date_To_Time_Axis_Index_Map) loop
      Ada.Text_IO.Put( Ada.Calendar.Formatting.Image(Date_Maps.Key(C),True) );
      Ada.Text_IO.Put("  :  ");
      Positive_IO.Put(Date_Maps.Element(C), 4);
      Ada.Text_IO.New_Line;
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


  procedure Set_Event(TC: in out Timeline_Container; Event_Column: in Ada.Strings.Unbounded.Unbounded_String;
      Event_Name: in Ada.Strings.Unbounded.Unbounded_String; Event_Date: in Ada.Calendar.Time) is

    Row_Index: constant Positive := Date_Maps.Element(TC.Date_To_Time_Axis_Index_Map, Event_Date);
    Column_Index: constant Positive := Col_Name_Maps.Element(TC.Col_Name_To_Col_Index_Map, Event_Column);

--    Col_Pointer: Event_Columns.Reference_Type := Event_Columns.Reference(TC.Columns, Column_Index);

  begin

    TC.Columns(Column_Index)(Row_Index) := Event_Name;
--    Col_Pointer(Row_Index) := Event_Name;

  end Set_Event;


  function Get_Event(TC: in Timeline_Container; Event_Column: in Ada.Strings.Unbounded.Unbounded_String;
      Event_Date: in Ada.Calendar.Time) return Ada.Strings.Unbounded.Unbounded_String is

    Row_Index: constant Positive := Date_Maps.Element(TC.Date_To_Time_Axis_Index_Map, Event_Date);
    Column_Index: constant Positive := Col_Name_Maps.Element(TC.Col_Name_To_Col_Index_Map, Event_Column);

  begin

    return TC.Columns(Column_Index)(Row_Index);

  end Get_Event;

  procedure Print_Timeline(TC: in Timeline_Container) is

    use Ada.Strings.Fixed;
    use Ada.Strings.Unbounded;
    Field_Separator: constant String := 2 * ' ';
    Row_Indent: constant String := " ";

    package Positive_IO is new Ada.Text_IO.Integer_IO(Positive);

    Index_Field_Width: constant Ada.Text_IO.Field := String'("Index")'Length;
    Date_Field_Width: constant Ada.Text_IO.Field := String'("2026-09-10 23:00:01")'Length;
    Weekday_Field_Width: constant Ada.Text_IO.Field := String'("Weekday")'Length;
    Month_Field_Width: constant Ada.Text_IO.Field := String'("Month")'Length;
    Day_Field_Width: constant Ada.Text_IO.Field := String'("Day")'Length;

    First_Row_Index: constant Positive := Time_Axes.First_Index(TC.Time_Axis);
    Last_Row_Index: constant Positive := Time_Axes.Last_Index(TC.Time_Axis);

    First_Column_Index: constant Positive := Col_Names_Vectors.First_Index(TC.Col_Names);
    Last_Column_Index: constant Positive := Col_Names_Vectors.Last_Index(TC.Col_Names);

    Column_Width_Array: array (First_Column_Index .. Last_Column_Index) of Positive := (others => 1);


    function Get_Max_Entry_Length(Column_Idx: in Positive) return Positive is

      Current_Max: Positive := Length(TC.Col_Names(Column_Idx));
      Current_Length: Positive := 1;

    begin

      for Row_Idx in First_Row_Index .. Last_Row_Index loop

        Current_Length := Length(TC.Columns(Column_Idx)(Row_Idx));

        if Current_Length > Current_Max then
          Current_Max := Current_Length;
        end if;

      end loop;

      return Current_Max;

    end Get_Max_Entry_Length;


  function Pad(Str: in String; Field_Width: in Positive) return String is

    Whitespaces_To_Fill: constant Natural := Field_Width - Str'Length;

  begin

    return (Whitespaces_To_Fill * ' ') & Str;

  end Pad;


  function To_Weekday_Name(Day_Of_Week: in Ada.Calendar.Formatting.Day_Name) return String is

    use Ada.Calendar.Formatting;

  begin

    return (case Day_Of_Week is
      when Monday => "MON",
      when Tuesday => "TUE",
      when Wednesday => "WED",
      when Thursday => "THU",
      when Friday => "FRI",
      when Saturday => "SAT",
      when Sunday => "SUN");

  end To_Weekday_Name;

  function To_Month_Name(Month_Number: in Integer) return String is

  begin

    return (case Month_Number is
      when 1 => "JAN",
      when 2 => "FEB",
      when 3 => "MAR",
      when 4 => "APR",
      when 5 => "MAY",
      when 6 => "JUN",
      when 7 => "JUL",
      when 8 => "AUG",
      when 9 => "SEP",
      when 10 => "OCT",
      when 11 => "NOV",
      when 12 => "DEC",
      when others => "???");

  end To_Month_Name;

  begin

    Ada.Text_IO.Put(Row_Indent);

    Ada.Text_IO.Put("Index");
    Ada.Text_IO.Put(Field_Separator);

    Ada.Text_IO.Put( Pad("Date", Date_Field_Width) );
    Ada.Text_IO.Put(Field_Separator);

    Ada.Text_IO.Put("Month");
    Ada.Text_IO.Put(Field_Separator);

    Ada.Text_IO.Put("Day");
    Ada.Text_IO.Put(Field_Separator);

    Ada.Text_IO.Put("Weekday");
    Ada.Text_IO.Put(Field_Separator);

    for Column_Idx in First_Column_Index .. Last_Column_Index loop

      Column_Width_Array(Column_Idx) := Get_Max_Entry_Length(Column_Idx);

      Ada.Text_IO.Put( Pad( To_String(TC.Col_Names(Column_Idx) ), Column_Width_Array(Column_Idx) ) );

      if Column_Idx = Last_Column_Index then
        Ada.Text_IO.New_Line;
      else
        Ada.Text_IO.Put(Field_Separator);
      end if;

    end loop;


    for Row_Idx in First_Row_Index .. Last_Row_Index loop

      Ada.Text_IO.Put(Row_Indent);

      Positive_IO.Put(Row_Idx, Width => Index_Field_Width);
      Ada.Text_IO.Put(Field_Separator);

      Ada.Text_IO.Put( Ada.Calendar.Formatting.Image(TC.Time_Axis(Row_Idx), True) );
      Ada.Text_IO.Put(Field_Separator);

      Ada.Text_IO.Put( Pad( To_Month_Name( Ada.Calendar.Month(TC.Time_Axis(Row_Idx)) ), Month_Field_Width) );
      Ada.Text_IO.Put(Field_Separator);

      Ada.Integer_Text_IO.Put( Ada.Calendar.Day(TC.Time_Axis(Row_Idx)), Width => Day_Field_Width );
      Ada.Text_IO.Put(Field_Separator);

      Ada.Text_IO.Put( Pad( To_Weekday_Name(Ada.Calendar.Formatting.Day_Of_Week(TC.Time_Axis(Row_Idx))), Weekday_Field_Width) );
      Ada.Text_IO.Put(Field_Separator);

      for Column_Idx in First_Column_Index .. Last_Column_Index loop

        Ada.Text_IO.Put( Pad( To_String(TC.Columns(Column_Idx)(Row_Idx)), Column_Width_Array(Column_Idx) ) );
        Ada.Text_IO.Put(Field_Separator);

        if Column_Idx = Last_Column_Index then
          Ada.Text_IO.New_Line;
        else
          Ada.Text_IO.Put(Field_Separator);
        end if;

      end loop;
    end loop;

  end Print_Timeline;

--  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String) is

--  begin
  --  Ada.Text_IO.Open(Lexer.Input_File, Ada.Text_IO.In_File, Input_File_Name);

    --Ada.Text_IO.Close(Lexer.Input_File);
 -- end Init_Lexer;


end Timelines;

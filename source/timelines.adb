with Timelines.Test;
with Ada.Calendar.Arithmetic;
with Ada.Text_IO;
with Ada.Strings.Fixed;

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
    Field_Separator: constant String := 2 * ' ';

    package Positive_IO is new Ada.Text_IO.Integer_IO(Positive);

    Index_Field_Width: constant Ada.Text_IO.Field := 4;

    First_Row_Index: constant Positive := Time_Axes.First_Index(TC.Time_Axis);
    Last_Row_Index: constant Positive := Time_Axes.Last_Index(TC.Time_Axis);

    First_Column_Index: constant Positive := Col_Names_Vectors.First_Index(TC.Col_Names);
    Last_Column_Index: constant Positive := Col_Names_Vectors.Last_Index(TC.Col_Names);

    Column_Width_Array: array (First_Column_Index .. Last_Column_Index) of Positive := (others => 1);


    function Get_Max_Entry_Length(Column_Idx: in Positive) return Positive is

      use Ada.Strings.Unbounded;
      Current_Max: Positive := Length(TC.Col_Names(Column_Idx));

    begin

      return Current_Max;

    end Get_Max_Entry_Length;


  begin

    for Column_Idx in First_Column_Index .. Last_Column_Index loop

      Column_Width_Array(Column_Idx) := Get_Max_Entry_Length(Column_Idx);

    end loop;


    for Row_Idx in First_Row_Index .. Last_Row_Index loop

      Positive_IO.Put(Row_Idx, Width => Index_Field_Width);
      Ada.Text_IO.Put(Field_Separator);

      for Column_Idx in First_Column_Index .. Last_Column_Index loop

        null;

      end loop;
    end loop;

  end Print_Timeline;

--  procedure Init_Lexer(Lexer: out Lexer_Type; Input_File_Name: in String) is

--  begin
  --  Ada.Text_IO.Open(Lexer.Input_File, Ada.Text_IO.In_File, Input_File_Name);

    --Ada.Text_IO.Close(Lexer.Input_File);
 -- end Init_Lexer;


end Timelines;

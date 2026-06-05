with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;
with Ada.Strings.Unbounded;
with Ada.Calendar;

package Timelines is

  type Timeline_Container is private;

  --procedure Read(T: out Time_Line_Record, Input_File_Name: in String);

  procedure Read_And_Print_Timeline(Input_File_Name: in String);

  procedure Print_Timeline(TC: in Timeline_Container);

  procedure Init_Timeline_Container(TC: out Timeline_Container; Year_Of_Interest: in Ada.Calendar.Year_Number);

  procedure Add_Event_Column(TC: in out Timeline_Container; New_Col_Name: in Ada.Strings.Unbounded.Unbounded_String);

  function Has_Event_Column(TC: in Timeline_Container; Col_Name: in Ada.Strings.Unbounded.Unbounded_String) return Boolean;

  procedure Set_Event(TC: in out Timeline_Container; Event_Column: in Ada.Strings.Unbounded.Unbounded_String;
      Event_Name: in Ada.Strings.Unbounded.Unbounded_String; Event_Date: in Ada.Calendar.Time);

  function Get_Event(TC: in Timeline_Container; Event_Column: in Ada.Strings.Unbounded.Unbounded_String;
      Event_Date: in Ada.Calendar.Time) return Ada.Strings.Unbounded.Unbounded_String;

private

  package Events is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Strings.Unbounded.Unbounded_String, "=" => Ada.Strings.Unbounded."=");

  package Event_Columns is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Events.Vector, "=" => Events."=");

  package Col_Names_Vectors is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Strings.Unbounded.Unbounded_String, "=" => Ada.Strings.Unbounded."=");

  function "=" (Left, Right : in Ada.Calendar.Time) return Boolean;

  package Time_Axes is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Calendar.Time, "=" => Ada.Calendar."=");

  package Date_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Calendar.Time,
    Element_Type => Positive, "<" => Ada.Calendar."<", "=" => "=");

  package Col_Name_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Strings.Unbounded.Unbounded_String,
    Element_Type => Positive, "<" => Ada.Strings.Unbounded."<", "=" => "=");

  TIMELINE_INTERVAL_IN_DAYS: constant Ada.Containers.Count_Type := 366;

  type Timeline_Container is
    record
      Time_Axis: Time_Axes.Vector;
      Date_To_Time_Axis_Index_Map: Date_Maps.Map;
      Columns: Event_Columns.Vector;
      Col_Names: Col_Names_Vectors.Vector;
      Col_Name_To_Col_Index_Map: Col_Name_Maps.Map;
    end record;

end Timelines;

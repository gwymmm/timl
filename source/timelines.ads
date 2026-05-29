with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;
with Ada.Strings.Unbounded;
with Ada.Calendar;

package Timelines is

  type Timeline_Container is private;

  --procedure Read(T: out Time_Line_Record, Input_File_Name: in String);

  procedure Read_And_Print_Timeline(Input_File_Name: in String);

private

  package Events is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Strings.Unbounded.Unbounded_String, "=" => Ada.Strings.Unbounded."=");

  package Event_Columns is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Events.Vector, "=" => Events."=");

  function "=" (Left, Right : in Ada.Calendar.Time) return Boolean;

  package Time_Axes is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Calendar.Time, "=" => Timelines."=");

  package Date_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Calendar.Time,
    Element_Type => Positive, "<" => Ada.Calendar."<", "=" => "=");

  package Col_Name_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Strings.Unbounded.Unbounded_String,
    Element_Type => Positive, "<" => Ada.Strings.Unbounded."<", "=" => "=");

  type Timeline_Container is 
    record
      Time_Axis: Time_Axes.Vector;
      Date_To_Time_Axis_Index_Map: Date_Maps.Map;
      Columns: Event_Columns.Vector;
      Col_Name_To_Col_Index_Map: Col_Name_Maps.Map;
    end record;  

end Timelines;

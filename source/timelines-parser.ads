with Ada.Calendar;

private package Timelines.Parser is

  procedure Read_Timeline(Input_File_Name: in String; Year_Of_Interest: in Ada.Calendar.Year_Number; TC: out Timeline_Container);

end Timelines.Parser;
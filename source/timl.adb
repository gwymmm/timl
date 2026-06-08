with Ada.Text_IO;
with Ada.Command_Line;
with Timelines;

procedure Timl is

  package IO renames Ada.Text_IO;
  package CMD renames Ada.Command_Line;

begin

  IO.Put_Line("Start of test");

  if CMD.Argument_Count = 1 then
    IO.Put_Line("This is the first argument:" & CMD.Argument(1));
  end if;

  Timelines.Read_And_Print_Timeline(CMD.Argument(1));

end Timl;

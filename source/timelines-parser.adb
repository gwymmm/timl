with Timelines.Lexer;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Strings.Unbounded;

with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;


package body Timelines.Parser is

  procedure Read_Timeline(Input_File_Name: in String; Year_Of_Interest: in Ada.Calendar.Year_Number; TC: out Timeline_Container) is

    use type Lexer.Token_Category;

    Lexer_Instance: Lexer.Lexer_Type;
    Current_Token: Lexer.Token_Type;
    Current_Event_Column: Ada.Strings.Unbounded.Unbounded_String := Ada.Strings.Unbounded.To_Unbounded_String("???");
    Current_First_Date: Ada.Calendar.Time;
    Current_Second_Date: Ada.Calendar.Time;
    Current_Event_Name: Ada.Strings.Unbounded.Unbounded_String;


    procedure Continue_Reading is
    begin

      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Column then

        Current_Event_Column := Lexer.Get_Value(Current_Token);

        if not Has_Event_Column(TC, Current_Event_Column) then
          Add_Event_Column(TC, Current_Event_Column);
        end if;

      Read_Event_Entry;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Date then

        declare
        begin

          Current_First_Date := Ada.Calendar.Formatting.Value(Lexer.Get_Value_As_String(Current_Token) & " 00:00:00",
                  Ada.Calendar.Time_Zones.UTC_Time_Offset);

        exception
        when Event: Constraint_Error =>
          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: Reading of date failed (expected format YYYY-MM-DD); Details: "
                                  & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );
          return;
        end;

        Read_Event_Entry_Continued;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error encountered: " & Lexer.Get_Value_As_String(Current_Token) );

      else

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                "Definition of column or event expected");

      end if;

    end Continue_Reading;


    procedure Read_Event_Entry_Continued is
    begin

      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Event or Lexer.Get_Category(Current_Token) = Lexer.Last_Event then

        if not Date_Is_Covered_By_Timeline(TC, Current_First_Date) then
          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: Date not covered by timeline.");
          return;
        end if;

        if not Is_Empty_Event_Slot(TC, Current_Event_Column, Current_First_Date) then
          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: Entry already present for defined column and date.");
          return;
        end if;

        Current_Event_Name := Lexer.Get_Value(Current_Token);
        Set_Event(TC, Current_Event_Column, Current_Event_Name, Current_First_Date);

        if Lexer.Get_Category(Current_Token) = Lexer.Last_Event then
          return;
        else
          Continue_Reading;
        end if;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Date_Separator then

        Lexer.Next_Token(Lexer_Instance, Current_Token);

        -- read date interval case --
        if Lexer.Get_Category(Current_Token) = Lexer.Date then

          declare
          begin

          Current_Second_Date := Ada.Calendar.Formatting.Value(Lexer.Get_Value_As_String(Current_Token) & " 00:00:00",
                    Ada.Calendar.Time_Zones.UTC_Time_Offset);

          exception
          when Event: Constraint_Error =>
            Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                    ": Error: Reading of date failed (expected format YYYY-MM-DD); Details: "
                                    & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );
            return;
          end;

          Lexer.Next_Token(Lexer_Instance, Current_Token);

          if Lexer.Get_Category(Current_Token) = Lexer.Event or Lexer.Get_Category(Current_Token) = Lexer.Last_Event then

            Current_Event_Name := Lexer.Get_Value(Current_Token);

            if Timelines."<"(Current_Second_Date, Current_First_Date) then
              Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                      ": Error: Date interval is empty (right date < left date).");
              return;
            end if;

            declare
              Current_Date: Ada.Calendar.Time := Current_First_Date;
              Last_Date_Plus_One: Ada.Calendar.Time := Ada.Calendar.Arithmetic."+"(Current_Second_Date, 1);
            begin

              while Timelines."<"(Current_Date, Last_Date_Plus_One) loop

                if not Date_Is_Covered_By_Timeline(TC, Current_Date) then
                  Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                          ": Error: Date not covered by timeline.");
                  return;
                end if;

                if not Is_Empty_Event_Slot(TC, Current_Event_Column, Current_Date) then
                  Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                          ": Error: Entry already present for defined column and date.");
                  return;
                end if;

                Set_Event(TC, Current_Event_Column, Current_Event_Name, Current_Date);
                Ada.Calendar.Arithmetic."+"(Current_Date, 1);

              end loop;

            end;

            if Lexer.Get_Category(Current_Token) = Lexer.Last_Event then
              return;
            else
              Continue_Reading;
            end if;

            elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

              Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                      ": Error: " & Lexer.Get_Value_As_String(Current_Token) );

            else

              Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                      ": Error: Definition of event expected");

          end if;

        elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: " & Lexer.Get_Value_As_String(Current_Token) );

        else

          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: End date in date interval expected");

        end if;
        -- end of read date interval case --

      elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error: " & Lexer.Get_Value_As_String(Current_Token) );

      else

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error: Definition of event expected");

      end if;

    end Read_Event_Entry_Continued;


    procedure Read_Event_Entry is
    begin

      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Date then

        declare
        begin

        Current_First_Date := Ada.Calendar.Formatting.Value(Lexer.Get_Value_As_String(Current_Token) & " 00:00:00",
                  Ada.Calendar.Time_Zones.UTC_Time_Offset);

        exception
        when Event: Constraint_Error =>
          Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                  ": Error: Reading of date failed (expected format YYYY-MM-DD); Details: "
                                  & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );
          return;
        end;

        Ada.Text_IO.Put_Line("Calling Read_Event_Entry_Continued");
        Read_Event_Entry_Continued;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error: " & Lexer.Get_Value_As_String(Current_Token) );

      else

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error: Definition of event expected");

      end if;


    end Read_Event_Entry;


    procedure Start_Reading is
    begin

      Lexer.Next_Token(Lexer_Instance, Current_Token);

      if Lexer.Get_Category(Current_Token) = Lexer.Column then

        Current_Event_Column := Lexer.Get_Value(Current_Token);

        if not Has_Event_Column(TC, Current_Event_Column) then
          Add_Event_Column(TC, Current_Event_Column);
        end if;

      Read_Event_Entry;

      elsif Lexer.Get_Category(Current_Token) = Lexer.Error then

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                ": Error encountered: " & Lexer.Get_Value_As_String(Current_Token) );

      else

        Ada.Text_IO.Put_Line("Line " & Lexer.Get_Line(Current_Token)'Image &
                                "Definition of first column expected");

      end if; 

    end Start_Reading;


  begin

    Lexer.Init_Lexer(Lexer_Instance, Input_File_Name);

    declare
    begin

      Init_Timeline_Container(TC, Year_Of_Interest);

      Start_Reading;

    exception
      when Event: others =>
        Ada.Text_IO.Put_Line("Problem while reading input encountered: "
                              & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );
    end;

    Lexer.Finalize_Lexer(Lexer_Instance);

  exception
    when Event: others =>
      Ada.Text_IO.Put_Line("Problem with input file handling: "
                            & Ada.Exceptions.Exception_Name(Event) & ", " & Ada.Exceptions.Exception_Message(Event) );

  end Read_Timeline;

end Timelines.Parser;

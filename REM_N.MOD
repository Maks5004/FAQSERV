MODULE REM_N;

 IMPORT FIO,IO,Str;
 FROM SYSTEM IMPORT Registers;
 FROM Lib    IMPORT CommandType,Environment,ParamStr,Intr,Delay;

 VAR F        : FIO.File;
     cc,INS   : ARRAY[1..14] OF CHAR;
     R        : Registers;
     OK       : BOOLEAN;
     Dt,Vr    : CARDINAL;
     Count    : CARDINAL;
     Sc,Screen[0B800H:0H] : ARRAY[1..25],[1..80] OF RECORD
                                                     S:CHAR;
                                                     A:BYTE;
                                                    END;
 PROCEDURE Write(STR:ARRAY OF CHAR;X,Y,COLB,COLF:CARDINAL);
 VAR L,C:CARDINAL;
 BEGIN
  L:=Str.Length(STR);
  FOR C:=0 TO L-1 DO
  Sc[Y][X+C].A:=BYTE(16*COLB+COLF);
  Sc[Y][X+C].S:=STR[C];
  END;
  Screen:=Sc;
 END Write;

 PROCEDURE WrCop;


 BEGIN
  Write("▄▄▄▄▄▄▄▄",1,1,15,1);
  Write("▀▀▀▀▀▀▀▀",1,2,0,4);

  Write('Замена русских "Н" и "р" латинскими буквами',11,1,0,14);
  Write("Copyright (C) 1999 Mamonov Maksim 2:5004/14.18@FidoNet",11,2,0,14);
  Write("─══════════════════════════════════════════════════════════════─",1,3,0,2);
 END WrCop;

 PROCEDURE GetTime(F:CARDINAL);
 BEGIN;
  R.AH:=57H;
  R.AL:=00H;
  R.BX:=F;
  Intr(R,21H);
  Dt:=R.DX;
  Vr:=R.CX;
 END GetTime;

 PROCEDURE SetTime(F:CARDINAL);
 BEGIN;
  R.AH:=57H;
  R.AL:=01H;
  R.BX:=F;
  R.DX:=Dt;
  R.CX:=Vr;
  Intr(R,21H);
 END SetTime;

 PROCEDURE REMOVE;

 VAR A,C : LONGCARD;
     F   : FIO.File;
     CH  : CHAR;

 BEGIN
  F:=FIO.Open(INS);
  GetTime(F);
  C:=FIO.Size(F);
  FOR A:=0 TO C DO
   FIO.Seek(F,A);
   CH:=FIO.RdChar(F);
   IF CH="H" THEN
    FIO.Seek(F,A);
    FIO.WrChar(F,"H");
    Count:=Count+1;
   END;
   IF CH="p" THEN
    FIO.Seek(F,A);
    FIO.WrChar(F,"p");
    Count:=Count+1;
   END;
  END;
  SetTime(F);
  FIO.Close(F);
 END REMOVE;

BEGIN
  WrCop;
  Delay(200);
  Count:=0;
  ParamStr(INS,1);
  IF INS[1]='' THEN INS:="$.$" END;
  IF FIO.Exists(INS)=FALSE THEN
  ELSE
   REMOVE;
  END;
  Write(" Пpоизведено - ",2,4,0,15);
  Str.CardToStr(LONGINT(Count),cc,10,OK);
  Write(cc,17,4,0,14);
  Write(" замен.",23,4,0,15);
END REM_N.

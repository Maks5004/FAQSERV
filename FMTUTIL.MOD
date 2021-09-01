MODULE FmtUtil;

 IMPORT FIO,Str,IO;
 FROM IO IMPORT RdKey;
 FROM Lib IMPORT Delay;
 FROM Lib    IMPORT CommandType,Environment,ParamStr,ParamCount,Intr;

 TYPE String=ARRAY[0..255] OF CHAR;

 VAR C,O,C1   : BOOLEAN;
     File     : FIO.DirEntry;
     PrStr    : ARRAY[1..40] OF CHAR;
     T,L      : CARDINAL;
     CH       : CHAR;
     S,D      : String;
     F,FF     : FIO.File;
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

  Write("FMT Util для FAQ Server v1.0",11,1,0,14);
  Write("Copyright (C) 1999 Mamonov Maksim 2:5004/14.18@FidoNet",11,2,0,14);
  Write("─══════════════════════════════════════════════════════════════─",1,3,0,2);
 END WrCop;


BEGIN
  ParamStr(PrStr,1);
  Str.Caps(PrStr);

  C:=Str.Match(PrStr,"/RUN");
  IF C=TRUE THEN
    WrCop;
    Delay(500);
    FF:=FIO.Create("NAME.DAT");

    S:="*.*";
    C:=FIO.ReadFirstEntry(S,FIO.FileAttr{FIO.readonly,FIO.hidden,FIO.system,FIO.volume,FIO.archive},File);
    LOOP
      Str.Caps(File.Name);
      C:=Str.Match(File.Name,"*EXE");
      C1:=Str.Match(File.Name,"NAME.DAT");
      IF (C=TRUE) OR (C1=TRUE)
      THEN ELSE
       Write("             ",2,4,0,15);
       Write(File.Name,2,4,0,15);
       FIO.WrStr(FF,File.Name);
       FIO.WrLn(FF);

       F:=FIO.Append(File.Name);
       FIO.WrLn(F);
       FIO.WrStr(F,"->");FIO.WrLn(F);
       FIO.WrStr(F,"|end");
       FIO.Close(F);

       Write(" - Ok",15,4,0,14);
      END;
      C:=FIO.ReadNextEntry(File);
      IF C=FALSE THEN EXIT END;
    END;
    FIO.Close(FF);
  ELSE
    WrCop;
    Write(" Запуск: ",3,4,0,14);
    Write("FMTUTIL.EXE /RUN ",13,4,0,15);
    Write("Нажмите любую клавишу...",1,24,0,4);

    CH:=RdKey();
  END;
END FmtUtil.

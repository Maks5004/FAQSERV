MODULE FAQServ;

 IMPORT FIO,Lib,Str,Storage,IO;
 FROM SYSTEM IMPORT Registers;

 TYPE String=ARRAY[0..255] OF CHAR;

 VAR I1         : ADDRESS;
     YY         : Storage.HeapRecPtr;
     TC         : CARDINAL;
     R          : Registers;
     Sc,Screen[0B800H:0H] : ARRAY[1..25],[1..80] OF RECORD
                                                     S:CHAR;
                                                     A:BYTE;
                                                    END;

     ServName   : String;
     FEPath     : String;
     NMPath     : String;
     FAQCommand : String;
     AnswerDir  : String;
     Help       : String;
     List       : String;
     MLSize     : LONGCARD;
     FAQAddress : String;
     Origin     : String;
     FailedText : String;
     LOGPath    : String;
     ReqKeepDir : String;
     UnPack     : String;

     Req      : String;
     zakaz    : String;
     Client   : String;
     ClientFI : String;
     Arch     : String;
     Length   : LONGCARD;
     LOG      : FIO.File;
     year     : CARDINAL;
     month,
     day,
     hour,min,
     sec      : SHORTCARD;

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
  Write("▀▀▀▀▀▀▀▀",1,1,1,15);
  Write("▀▀▀▀▀▀▀▀",1,2,0,4);

  Write("FAQ Server v1.0",11,1,0,14);
  Write("Copyright (C) 1999-2000 Mamonov Maksim 2:5004/28.18@FidoNet",11,2,0,14);
  Write("─══════════════════════════════════════════════════════════════─",1,3,0,2);
 END WrCop;


   PROCEDURE Clear;
   BEGIN
    R.AX:=0600H;
    R.BH:=0H;
    R.CX:=00;
    R.DX:=184FH;
    Lib.Intr(R,10H);
   END Clear;

 PROCEDURE GetTime;
 BEGIN;
  R.AH:=2AH;
  Lib.Dos(R);
  year:=R.CX;
  month:=R.DH;
  day:=R.DL;
  R.AH:=2CH;
  Lib.Dos(R);
  hour:=R.CH;
  min:=R.CL;
  sec:=R.DH
 END GetTime;


PROCEDURE Send(file,ToName,Subj,Addr:ARRAY OF CHAR);
VAR S,St:String;
BEGIN
  Str.Append(St,"POST ");
  Str.Append(St,file);
  Str.Append(St," netmail ");
  Str.Append(St,' -From "');
  Str.Append(St,ServName);
  Str.Append(St,'" -To "');
  Str.Append(St,ToName);
  Str.Append(St,'" -Subj "');
  Str.Append(St,Subj);
  Str.Append(St,'" -Flags Pvt+Kill"');
  Str.Append(St,'" -Addr ');
  Str.Append(St,Addr);
  S:=FEPath;
  Str.Append(S,"FEUTIL.EXE");

  Storage.HeapAllocate(Storage.MainHeap,I1,20000);
  TC:=Lib.Execute(S,St,I1,20000);
  Storage.HeapDeallocate(Storage.MainHeap,I1,20000);
END Send;

PROCEDURE ReadCTL;
VAR F:CARDINAL;
    I:INTEGER;
    SS:String;
    Ok:BOOLEAN;
BEGIN
 IF FIO.Exists("FAQSERV.CTL")=TRUE THEN
   F:=FIO.Open("FAQSERV.CTL");
   WHILE FIO.EOF=FALSE DO
     FIO.RdStr(F,SS);
     I:=INTEGER(Str.Pos(SS,";"));
     IF I=-1 THEN
       I:=INTEGER(Str.Pos(SS,"FAQName"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,8);
         ServName:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"FailedText"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,11);
         FailedText:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"ReqKeepDir"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,11);
         ReqKeepDir:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"UnPack"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,7);
         UnPack:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"FAQAddress"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,11);
         FAQAddress:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"Origin"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,7);
         Origin:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"FEPath"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,7);
         FEPath:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"LOGPath"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,8);
         LOGPath:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"NMPath"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,7);
         NMPath:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"FAQCommand"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,11);
         FAQCommand:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"AnswerDir"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,10);
         AnswerDir:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"Help"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,5);
         Help:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"List"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,5);
         List:=SS;
       END;
       I:=INTEGER(Str.Pos(SS,"MLSize"));
       IF I=-1 THEN ELSE
         Str.Delete(SS,I,7);
         MLSize:=Str.StrToCard(SS,10,Ok);
       END;
     END;
   END;
   FIO.Close(F);
 ELSE
   IO.WrStr(" FTNSERV.CTL не найден!");
   HALT;
 END;
END ReadCTL;

PROCEDURE RSend(STR:String;SABJ:ARRAY OF CHAR);
VAR F,F1:FIO.File;
    l:CARDINAL;
    GK,TT:String;

BEGIN;
 IF FIO.Exists(STR)=TRUE THEN
  F:=FIO.Open(STR);

  FIO.WrStr(LOG," Команда ");
  FIO.WrStr(LOG,SABJ);
  FIO.WrStr(LOG," - ");
  FIO.WrStr(LOG,STR);
  FIO.WrStr(LOG," ");
  FIO.WrLngCard(LOG,FIO.Size(F),1);
  Length:=Length+FIO.Size(F);
  FIO.WrStr(LOG," байт");
  FIO.WrLn(LOG);
  LOOP
    F1:=FIO.Create("temp.$$$");
    FIO.WrStr(F1," Copyright (C) 1999 Mamonov Maksim 2:5004/28.18@FidoNet");FIO.WrLn(F1);
    FIO.WrStr(F1," ServName: ");FIO.WrStr(F1,ServName);FIO.WrLn(F1);FIO.WrLn(F1);
    FIO.RdStr(F,TT);
    IF (TT[0]="|") AND (TT[1]="e") AND (TT[2]="n") AND (TT[3]="d") THEN EXIT; END;

    WHILE NOT((TT[0]="-") AND (TT[1]=">")) DO
     IF (TT[0]="-") AND (TT[1]=">") THEN ELSE FIO.WrStr(F1,TT); FIO.WrLn(F1); END;
     FIO.RdStr(F,TT);
    END;
    FIO.WrStr(F1,"---");FIO.WrLn(F1);
    FIO.WrStr(F1," * Origin: ");FIO.WrStr(F1,Origin);FIO.WrStr(F1," (");FIO.WrStr(F1,FAQAddress);FIO.WrStr(F1,")");
    FIO.Close(F1);

    Storage.HeapAllocate(Storage.MainHeap,I1,20000);
    TC:=Lib.Execute("rem_n.exe","temp.$$$",I1,20000);
    Storage.HeapDeallocate(Storage.MainHeap,I1,20000);

    Send("temp.$$$",ClientFI,SABJ,Client);
  END;
  FIO.Close(F);
  FIO.Erase("temp.$$$");

 ELSE
  FIO.WrStr(LOG," Команда ");
  FIO.WrStr(LOG,SABJ);
  FIO.WrStr(LOG," - ");
  FIO.WrStr(LOG,STR);
  FIO.WrStr(LOG," ");
  FIO.WrStr(LOG," не найден!");
  FIO.WrLn(LOG);
 END;
END RSend;

PROCEDURE Zakaz;
VAR SSS     : ARRAY[0..20],[0..10] OF CHAR;
    F,l,i   : CARDINAL;
    I       : INTEGER;
    Path    : String;
    F1,FILE,
    FILE1   : String;

  PROCEDURE UNPACK(File:String;Sabj:ARRAY OF CHAR);
  VAR C,PM:String;
  BEGIN
   CASE UnPack[0] OF
    |"A","a":C:="ARJ.EXE";
             PM:="e ";
             Str.Append(PM,AnswerDir);
             Str.Append(PM,Arch);
             Str.Append(PM," ");
             Str.Append(PM,File);
    |"R","r":C:="UNRAR.EXE";
             PM:="e ";
             Str.Append(PM,AnswerDir);
             Str.Append(PM,Arch);
             Str.Append(PM," ");
             Str.Append(PM,File);
    |"Z","z":C:="PKUNZIP.EXE";
             PM:="-e ";
             Str.Append(PM,AnswerDir);
             Str.Append(PM,Arch);
             Str.Append(PM," ");
             Str.Append(PM,File);
  END;
   Storage.HeapAllocate(Storage.MainHeap,I1,20000);
   TC:=Lib.Execute(C,PM,I1,20000);
   Storage.HeapDeallocate(Storage.MainHeap,I1,20000);
   RSend(File,Sabj);
   FIO.Erase(File);
  END UNPACK;

  PROCEDURE Seek(Com:ARRAY OF CHAR;VAR SS1:String);
  VAR T,F   : CARDINAL;
      I   : INTEGER;
      D,TT: String;
      D1  : ARRAY[0..240] OF CHAR;
      Ok  : BOOLEAN;

  BEGIN
    F:=FIO.Open(FAQCommand);
    SS1:=FailedText;
    LOOP
      D1:="";
      FIO.RdStr(F,TT);
      IF TT[0]="+" THEN
        Str.Delete(TT,I,1);
        Arch:=TT;
      END;
      IF (TT[0]="|") AND (TT[1]="e") AND (TT[2]="n") AND (TT[3]="d") THEN EXIT; END;
      T:=0;
      WHILE T<=Str.Length(Com) DO
       D1[T]:=Com[T];
       INC(T);
      END;
      Str.Append(D1,"=");
      I:=INTEGER(Str.Pos(TT,D1));
      IF I=0 THEN
        Str.Delete(TT,I,Str.Length(Com)+1);
        SS1:=TT;
        EXIT;
      END;
    END;
    FIO.Close(F);
  END Seek;

BEGIN
 l:=0;
 IF zakaz[l]="" THEN
   FIO.WrStr(LOG," Письмо пустое.");FIO.WrLn(LOG);
 ELSE
   Str.Item(SSS[l],zakaz,Str.CHARSET{CHR(32)},l);
   WHILE ORD(SSS[l][0])>0 DO
     INC(l);
     Str.Item(SSS[l],zakaz,Str.CHARSET{' '},l);
   END;
   FOR i:=0 TO l-1 DO
     IF SSS[i][0]="%" THEN
       IF ((SSS[i][1]="h") OR (SSS[i][1]="H")) AND
          ((SSS[i][2]="e") OR (SSS[i][2]="E")) AND
          ((SSS[i][3]="l") OR (SSS[i][3]="L")) AND
          ((SSS[i][4]="p") OR (SSS[i][4]="P")) THEN
          RSend(Help,SSS[i]);
       END;
       IF ((SSS[i][1]="l") OR (SSS[i][1]="L")) AND
          ((SSS[i][2]="i") OR (SSS[i][2]="I")) AND
          ((SSS[i][3]="s") OR (SSS[i][3]="S")) AND
          ((SSS[i][4]="t") OR (SSS[i][4]="T")) THEN

         RSend(List,SSS[i]);
       END;
     ELSE
      Seek(SSS[i],FILE);
      UNPACK(FILE,SSS[i]);
     END;
   END;
 END;
END Zakaz;


PROCEDURE ScanMail;
VAR R          : FIO.PathStr;
    E,C        : BOOLEAN;
    I          : INTEGER;
    L,F        : CARDINAL;
    File,H     : FIO.DirEntry;
    W          : FIO.PathTail;
    S,S1       : String;
    AA,kom     : ARRAY[0..35] OF CHAR;
    node,net   : LONGCARD;
    a,point    : String;

BEGIN
  S:=NMPath;
  Str.Append(S,"*.MSG");
  FIO.WrStr(LOG," Просматриваю почту...");FIO.WrLn(LOG);

  C:=FIO.ReadFirstEntry(S,FIO.FileAttr{FIO.readonly,FIO.directory,FIO.hidden,FIO.system,FIO.volume,FIO.archive},File);
  LOOP
    S1:=NMPath;
    Str.Append(S1,File.Name);
    F:=FIO.Open(S1);
     FIO.Seek(F,36);
     L:=FIO.RdBin(F,kom,36);
     I:=INTEGER(Str.Pos(kom,ServName));
     IF I=-1 THEN ELSE
       FIO.WrStr(LOG," Обнаружено сообщение на имя ");
       FIO.WrStr(LOG,ServName);FIO.WrLn(LOG);

       FIO.Seek(F,0);
       L:=FIO.RdBin(F,ClientFI,36);
       FIO.Seek(F,72);
       L:=FIO.RdBin(F,zakaz,72);

       FIO.Seek(F,168);
       L:=FIO.RdBin(F,node,2);
       FIO.Seek(F,172);
       L:=FIO.RdBin(F,net,2);

       FIO.Seek(F,190);
       FIO.RdStr(F,a);
       I:=INTEGER(Str.Pos(a,"FMPT"));
       IF I=-1 THEN ELSE
         Str.Delete(a,I,6);
         point:=a;
       END;
       FIO.RdStr(F,a);
       I:=INTEGER(Str.Pos(a,"FMPT"));
       IF I=-1 THEN ELSE
         Str.Delete(a,I,6);
         point:=a;
       END;
       FIO.RdStr(F,a);
       I:=INTEGER(Str.Pos(a,"FMPT"));
       IF I=-1 THEN ELSE
         Str.Delete(a,I,6);
         point:=a;
       END;

       Client:="2:";
       Str.CardToStr(net,a,10,E);
       Str.Append(Client,a);
       Str.Append(Client,"/");
       Str.CardToStr(node,a,10,E);
       Str.Append(Client,a);
       Str.Append(Client,".");
       Str.Append(Client,point);

       (****************)
       FIO.WrStr(LOG," От ");
       FIO.WrStr(LOG,ClientFI);
       FIO.WrStr(LOG," (");
       FIO.WrStr(LOG,Client);
       FIO.WrStr(LOG," )");
       FIO.WrLn(LOG);
       FIO.WrStr(LOG," Со следующим заказом:");
       FIO.WrLn(LOG);FIO.WrStr(LOG," ");
       FIO.WrStr(LOG,zakaz);
       FIO.WrLn(LOG);

       Str.Caps(zakaz);
       Zakaz;
       Req:="/C MOVE ";
       Str.Append(Req,S1);
       Str.Append(Req," ");
       Str.Append(Req,ReqKeepDir);

       Storage.HeapAllocate(Storage.MainHeap,I1,20000);
       TC:=Lib.Execute("C:\COMMAND.COM",Req,I1,20000);
       Storage.HeapDeallocate(Storage.MainHeap,I1,20000);

       FIO.WrStr(LOG," Команда COMMAND.COM");
       FIO.WrStr(LOG,Req);
       FIO.WrStr(LOG," выполнена.");
       FIO.WrLn(LOG);

       (****************)

     END;
    FIO.Close(F);
    C:=FIO.ReadNextEntry(File);
    IF C=FALSE THEN EXIT END;
  END;

END ScanMail;


BEGIN
 WrCop;

 ServName:="FAQ Server";
 Length:=0;
 ReadCTL;
 Str.Append(LOGPath,"FAQSERV.LOG");
 IF FIO.Exists(LOGPath)=FALSE THEN
   LOG:=FIO.Create(LOGPath);
   FIO.WrStr(LOG,"--=== FAQ SERVER LOG FILE ===--");FIO.WrLn(LOG);
 ELSE
   LOG:=FIO.Append(LOGPath);
 END;

 GetTime;
 FIO.WrStr(LOG,"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
 FIO.WrLn(LOG);
 FIO.WrStr(LOG,"Процесс начат [");
 FIO.WrCard(LOG,year,1);FIO.WrStr(LOG,".");
 FIO.WrShtCard(LOG,month,1);FIO.WrStr(LOG,".");
 FIO.WrShtCard(LOG,day,1);FIO.WrStr(LOG," ");
 FIO.WrShtCard(LOG,hour,1);FIO.WrStr(LOG,":");
 FIO.WrShtCard(LOG,min,1);FIO.WrStr(LOG,":");
 FIO.WrShtCard(LOG,sec,1);FIO.WrStr(LOG,"]");
 FIO.WrLn(LOG);

 ScanMail;

 FIO.WrStr(LOG,"Всего отослано - ");
 FIO.WrLngCard(LOG,Length,1);
 FIO.WrStr(LOG," байт.");
 FIO.WrLn(LOG);

 GetTime;
 FIO.WrStr(LOG,"Процесс закончен [");
 FIO.WrCard(LOG,year,1);FIO.WrStr(LOG,".");
 FIO.WrShtCard(LOG,month,1);FIO.WrStr(LOG,".");
 FIO.WrShtCard(LOG,day,1);FIO.WrStr(LOG," ");
 FIO.WrShtCard(LOG,hour,1);FIO.WrStr(LOG,":");
 FIO.WrShtCard(LOG,min,1);FIO.WrStr(LOG,":");
 FIO.WrShtCard(LOG,sec,1);FIO.WrStr(LOG,"]");
 FIO.WrLn(LOG);

 FIO.Close(LOG);
 Clear;
END FAQServ.



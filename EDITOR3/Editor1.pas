﻿/// This game is powered by ASPHYRE EXTRERME by AfterWrap
/// Code by: ШЕВЧУК СТАНСЛАВ
unit Editor1;

interface

uses
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, Asphyre2D, AsphyreCanvas, AsphyreSubsc, AsphyreDevices,
     AsphyreTimers, AsphyreDb, AsphyreImages, AsphyreFonts, AsphyreDef, AsphyreSprite,
     AsphyreKeyboard, SoundSystem, AsphyreMouse, Xparticles, ExtCtrls, StdCtrls,
     GuiBasic, Menus, jpeg;

type

     TObj= record
         Img,Name:string;
         Index,R,G,B,anim,Tip,sizeX,sizeY,offsetX,offsetY,OffsetZ,Angle0:integer;
         parns:array[1..6] of string;
     end;


     TTile = class(TSprite)
     private
          ObjName:String;
          Chang:Boolean;
          tip,r,g,b,angle0,h,w:integer;
          t:single;
          oldnapr,oldcol:byte;
          ID: Integer;
          parnames:array[1..6] of string;
          pars:array[1..6] of string;
     public
          procedure Move(const MoveCount: Single); override;
          procedure Draw; override;
          procedure Dead; override;
     end;

       TLaser = class(TSprite)
     private
        x0,y0:integer;
        direction,lascolor:byte;
         public
          procedure Move(const MoveCount: Single); override;
          procedure Draw; override;
     end;


          TMainForm = class(TForm)
          Fonts: TAsphyreFonts;
          Images: TAsphyreImages;
          Device: TAsphyreDevice;
          MyCanvas: TAsphyreCanvas;
          AGraphics: TASDb;
          Timer: TAsphyreTimer;
    AFonts: TASDb;
    GuiBase: TGuiBase;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    HD: TASDb;
    ASDb1: TASDb;
    FX: TASDb;
    Images2: TAsphyreImages;

          procedure DeviceInitialize(Sender: TObject; var Success: boolean);
          procedure DeviceRender(Sender: TObject);

          procedure BackGround;

          procedure ZoomIn;
          procedure ZoomOut;

          procedure SavePreview(Sender: TObject);
          procedure Setka;

          procedure CreateMapObj;
          function GetMapObjs(px,py:single):TLIST;

          procedure TimerTimer(Sender: TObject);
          procedure FormCreate(Sender: TObject);
          procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerProcess(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure N4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SaveDialogCanClose(Sender: TObject; var CanClose: Boolean);
    procedure OpenDialogCanClose(Sender: TObject; var CanClose: Boolean);
    procedure OpenDialogShow(Sender: TObject);
    procedure SaveDialogShow(Sender: TObject);
    procedure SaveDialogClose(Sender: TObject);
    procedure OpenDialogClose(Sender: TObject);
    procedure ProgramCursor;
      private
          Fs: TFileStream;
          FileSize: Integer;
          Engine: TSpriteEngine;
          Layer1Pos: Single;
          Layer2Pos: Single;
          LeftEdge, RightEdge: Integer;

          procedure LoadSettings;
          procedure LoadObjs;

          procedure LoadMap(filename:string);
          procedure SaveMap(filename:string);
          procedure CreateMap;

          Function GetObjNumber(Objname:string):integer;

          procedure AddEvents;

          procedure Iface;
          procedure MiniMap;


          procedure LoadMapData(FileName:string);
          function GetFiles(var Dir, Filter: shortstring): TStringList;

          function mouseonmm(x,y:integer):boolean;

          procedure CreateMM;

          procedure ClearDop;
          procedure LoadDop(filename:string);

          procedure o1(Sender:TObject);
          procedure o2(Sender:TObject);
          procedure o3(Sender:TObject);
          procedure o4(Sender:TObject);
          procedure o5(Sender:TObject);
          procedure o6(Sender:TObject);
          procedure o7(Sender:TObject);
          procedure o8(Sender:TObject);
          procedure o9(Sender:TObject);
          procedure o10(Sender:TObject);
          procedure o11(Sender:TObject);
          procedure o12(Sender:TObject);
          procedure o13(Sender:TObject);
          procedure o14(Sender:TObject);

          procedure pback(Sender:TObject);
          procedure pnext(Sender:TObject);

          procedure OtherSizeChange(Sender:TObject);

          procedure NewOkClick(Sender:TObject);
          procedure NewClick(Sender:TObject);
          procedure Hidemm(Sender:TObject);
          procedure Showobj(Sender:TObject);
          procedure Chooseobj(Sender:TObject);
          procedure RemoveButtonClick(Sender:TObject);
          procedure AcceptClick(Sender:TObject);

          procedure SaveClick(Sender:TObject);
          procedure LoadClick(Sender:TObject);
          procedure SettingsClick(Sender:TObject);
          procedure NoSaveClick(Sender:TObject);
          procedure NewCancelClick(Sender:TObject);
          procedure ExitClick(Sender:TObject);

          procedure LasBoxClick(Sender:TObject);
          procedure BuildLasers;
          procedure DrawLasers;

          procedure Exit2Click(Sender:TObject);
          procedure NoExitClick(Sender:TObject);

          procedure Killhelp(Sender:TObject);
          procedure Showhelp(Sender:TObject);
     public
          { Public declarations }
     end;

const
  mapdir='\..\UserMaps';

  minWScale=0.1;
  maxWScale=2;
  normWScale=1.0;

  HudH=250;

  RedW:array[0..9] of Integer=(50,255,245,255,15,25,75,155,255,0);
  GreenW:array[0..9] of Integer=(50,25,195,255,255,225,145,25,255,0);
  BlueW:array[0..9] of Integer=(50,25,25,25,25,255,255,255,255,0);
var
     MainForm: TMainForm;
     UserRefreshRate: Integer;

     DopImages:TStringList;
     DopAsdb:TStringList;

     HelpText:TStringList;

     Ramka1,Ramka2:Trect;

     _MapFile:String;
     Lang:String='RUS';

     Lasers:array[1..256] of TTile;
     Mirrors:array[1..128] of TTile;
     lasercount,mirrorcount:integer;

     ShowLas,Disableback:boolean;

     newmenu,popmenu,savemenu,exitmenu,getstarted,neednew:boolean;
     showmm,showgrid:boolean;

     MapName,MapAuthor,MapAbout:String;

     gamescaleX,GamescaleY,Lagcount,resx,resY:real;
     ///Фон
     layerX,layery:real;
     mmscale:real;

     DownOffset,MM_X,MM_Y:integer;
     needarrow:byte;

     //// DeBug
     Dop1,Dop2:real;

     go:boolean;
     xd,yd,mx,my:integer;

     dir0:string;

     MapList:TList;

     mapsizeY,mapsizeX,ObjCount, ObjCount2,choose,page:integer;

     MiniBitMap:TBitMap;

     Developer:boolean;

     Objs, Objs2: array [0..512] of Tobj;

implementation
uses GuiButton, GuiListBox, GuiEdit, GuiCheckBox, GuiLabel, GuiForms;

{$R *.dfm}
function GetNumScrollLines: Integer;
 begin
   SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Result, 0);

end;

function TMainform.GetFiles(var Dir,Filter:shortstring):TStringList;
var
  OldDir:string;
  W:cardinal;
  sSr:TSearchRec;
begin
  Result:=TStringList.Create;
  OldDir:=GetCurrentDir;
  SetCurrentDir(Dir);
  W:=FindFirst(Filter,faAnyFile,sSR);
  While W=0 do begin
    Result.Add(sSR.Name);
    W:=FindNext(sSR);
  end;
  SetCurrentDir(OldDir);
end;

function TMainForm.GetMapObjs(px, py: single): TLIST;
var ppx,ppy:real;
    Obj:TObject;
    I:integer;
begin
  ppx:=(px/gamescaleX/resx+layerX);
  ppy:=(py/gamescaley/resy+layerY);
  Result:=TList.Create;
  Result.Clear;

  for i := 0 to Engine.Count - 1 do
    Begin
      Obj:=Engine.Items[i];
      if (Obj is TTile)and(Obj<>nil) then Begin
        if (ppx>TTile(Obj).X)
          and(ppx<TTile(Obj).X+TTile(Obj).ImageWidth*TTile(Obj).ScaleX)
          and (ppy>TTile(Obj).y)
          and(ppy<TTile(Obj).y+TTile(Obj).ImageHeight*TTile(Obj).ScaleY) then
            Result.Add(Obj);
      End;
    End;

end;

function TMainForm.GetObjNumber(Objname: string):integer;
var i,j:integer;
begin
j:=-1;
  for i:=0 to objcount do
  Begin
    if Objs[i].Name=objname then
      j:=i;
  End;
  Result:=j;
end;

procedure TMainForm.Hidemm(Sender: TObject);
begin
with GuiBase.Taskbar do
   TGuiCheckBox(Ctrl['Showmm']).Checked:=false;
end;

procedure TMainForm.LasBoxClick(Sender: TObject);
begin
inherited;

with GuiBase do
  if TGuiCheckbox(ctrl['Lasbox']).Checked=true then
  Begin
    ShowLas:=true;
    BuildLasers;
  End else
    ShowLas:=false;

end;

procedure TMainForm.LoadClick(Sender: TObject);
begin
//
 Timer.Enabled:=false;
 OpenDialog.Execute;
 Timer.Enabled:=true;
end;

procedure TMainForm.LoadDop(filename:string);
var i,j:integer;
det:string;
begin
  SetCurrentDir(Dir0);
  //if Hidet then det:='_HD'
  // else det:='_LD'
  AGraphics.FileName:='..\Data\Graphics\'+filename+{det+}'_HD.asdb';
  j:=images.Count;
  images.LoadFromASDb(AGraphics);
   //showmessage('+1');
  for i:=j to images.Count-1 do
    DopImages.Add(images[i].Name);
end;

procedure TMainForm.LoadMap(filename:string);
var i,j,mapobjcount,numb,k,l:integer;
  loadmap:TStringList;
  MyTile:Ttile;
  badobj:boolean;
  par:string;
begin
///
///
///
  choose:=1;

  Engine.Clear;

  mapsizex:=50;
  mapsizey:=50;

  DopAsdb.Clear;
  loadmap:=TStringList.Create;
  loadmap.LoadFromFile(filename);

  badobj:=false;
  mapobjcount:=0;
  cleardop;

  MapName := '';
  MapAuthor := '';
  MapAbout := '';


  i:=0;
  while (i<LoadMap.Count - 1)and(Loadmap[i]<>'//') do
   Begin

      if Pos('SizeX: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        mapsizex:=strtoint(par);


      End;
      if Pos('SizeY: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        mapsizey:=strtoint(par);

      End;

      if Pos('Load: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Load: '));
        loaddop(par);
        DopAsdb.Add(par);
      End;

      if Pos('Author: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Author: '));
        MapAuthor:=par;
      End;
      if Pos('Name: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Name: '));
        MapName:=par;
      End;
      if Pos('About: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('About: '));
        MapAbout:=par;
      End;

 {   for j := 1 to n do   End;

  if Pos(Parnames[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Parnames[k]));
                                 pars[l]:=par; }

     inc(i);
   End;

  with GuiBase.Taskbar do Begin
          TGuiEdit(Ctrl['Name']).Text:=MapName;
          TGuiEdit(Ctrl['Author']).Text:=MapAuthor;
          TGuiEdit(Ctrl['About']).Text:=MapAbout;
  End;

  for I :=0 to LoadMap.Count - 1 do
  Begin
    if Loadmap[i]='//' then
    Begin
      inc(mapobjcount);

      par:=Loadmap[i+1] ;
      delete(par,1,length('Name: '));
      numb:=GetObjNumber(par);

      if numb<>-1 then
         Begin

          MyTile:=TTile.Create(Engine);
            with MyTile  do
               begin
                   // zxc   Loadmap[i]
                   

                    par:=Loadmap[i+1] ;
                    delete(par,1,length('Name: '));
                    ObjName:=par;

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);

                    par:=Loadmap[i+4] ;
                    delete(par,1,length('Z: '));
                    Z:=strtoint(par);

                    for j := 1 to 6 do Begin
                      parnames[j]:=Objs[numb].parns[j];
                      pars[j]:='0';
                    End;

                     Tip:=Objs[numb].Tip;      name:=Objs[numb].Name;
                     ImageName :='Box1';
                     if Images.Find(Objs[numb].Img)<>-1 then
                     ImageName := Objs[numb].Img;
                     Patternindex:=Objs[numb].Index;



                     if tip=70 then
                    Begin
                      //Z:=10;
                      DrawFx:=FxAdd;
                      ScaleX:=4;
                      ScaleY:=4;
                      Alpha:=128;
                      //DoCenter:=true;
                    End;

                    l:=0;

                    r:=255;
                    g:=255;
                    b:=255;

                    h:=Objs[numb].sizeX;
                    w:=Objs[numb].sizeY;

                    j:=5;


                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                      for k := 1 to 6 do
                         if Parnames[k]<>'' then
                          if Pos(Parnames[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Parnames[k])+2);
                                 pars[l]:=par;

                                 if (Parnames[k]='mirrorX')or(Parnames[k]='MirrorX') then
                                 Begin
                                  try
                                   if par='1' then
                                     mirrorX:=true;
                                  finally
                                  end;
                                 End;

                                 if (Parnames[k]='mirrorY')or(Parnames[k]='MirrorY') then
                                 Begin
                                  try
                                   if par='1' then
                                     mirrorY:=true;
                                  finally
                                  end;
                                 End;

                                 if (Parnames[k]='Angle') then
                                 Begin
                                  OffsetX:=ImageWidth*ScaleX/2;
                                  OffsetY:=ImageHeight*ScaleY/2;
                                  DrawMode:=1;
                                  try
                                    ANGLE:=StrToInt(pars[k])/180*pi;
                                  finally
                                  end;
                                 End;

                                 if (Parnames[k]='Color')or(Parnames[k]='color') then
                                 Begin
                                   if (par='1')or(par='2')or(par='3')or
                                      (par='4')or(par='5')or(par='6')or
                                      (par='7')or(par='8')or(par='9')or (par='10')
                                   then
                                     Begin
                                       r:=redw[strtoint(par)];
                                       g:=greenw[strtoint(par)];
                                       b:=bluew[strtoint(par)];
                                     End;
                                 End;

                      End;
                      inc(j);
                    End;
               end;

            with GuiBase.Taskbar do
               TGuiListBox(Ctrl['ListBox']).Items.AddObject(MyTile.ObjName+
               '('+inttostr(trunc(MyTile.X/100))+','+inttostr(trunc(MyTile.Y/100))+')',MyTile);

         End else
         badobj:=true;
    End;

   End;

   with GuiBase.Taskbar do
   TGuiCheckBox(Ctrl['Lasbox']).Checked:=Showlas;

  if mapobjcount=0 then
    Showmessage('Не удаётся загрузить карту :(')
  else
    if badobj=true then
      Showmessage('ВНИМАНИЕ! Есть "битые" объекты! Карта загшружена не полностью');

         CreateMM;
end;

procedure TMainForm.LoadMapData(FileName: string);
begin
  {  Fs := TFileStream.Create(ExtractFilePath(Application.ExeName) + FileName, fmOpenRead);
     Fs.ReadBuffer(FileSize, SizeOf(FileSize));
     SetLength(MapData, FileSize);
     Fs.ReadBuffer(MapData[0], SizeOf(TMapRec) * FileSize);
     Fs.Destroy;   }
end;

procedure TMainForm.LoadObjs;
  const
  n=13;
  Param:array[1..n] of String=('Img: ','Index: ','R: ','G: ','B: ','Type: ',
                              'Anim: ','SizeX: ','SizeY: ','*','OffsetX: ','OffsetY: ','OffsetZ: ');

  var s,files:TstringList;
  i,j,k,l:integer;
  s1,s2:ShortString;
  par,name,filename:String;
begin
  s:=TstringList.Create;
  files:=TstringList.Create;

  Setcurrentdir(Dir0);
  s1:='..\Data\Objects\';
  s2:='*.obj';
  files:=Getfiles(s1,s2);

  ObjCount:=files.Count;
 // SetLength(Objs,ObjCount);

  for k:=0 to files.Count-1 do
  Begin
    filename:=files[k];
    s.LoadFromFile(Dir0+'\'+s1+filename);
    name:=filename;
    delete(name,length(name)-3,4);
    Objs[k].Name:=name;
    l:=0;
    /// Умолчим)
    Objs[k].R:=255;
    Objs[k].G:=255;
    Objs[k].B:=255;
    Objs[k].Index:=0;
    Objs[k].Img:='';
    Objs[k].sizeX:=0;
    Objs[k].sizeY:=0;
    Objs[k].OffsetX:=0;
    Objs[k].OffsetY:=0;
    //showmessage(name);
    for I := 0 to s.Count - 1 do
      Begin
        for j := 1 to n do
          Begin
            if Pos(Param[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(param[j]));
               case j of
                  1: {Img} Objs[k].Img:=par;
                  2: {Index} Objs[k].Index:=StrToInt(par);
                  3: {R} Objs[k].R:=StrToInt(par);
                  4: {G} Objs[k].G:=StrToInt(par);
                  5: {B} Objs[k].B:=StrToInt(par);
                  6: {Type} Objs[k].Tip:=StrToInt(par);
                  7: {Anim} Objs[k].anim:=StrToInt(par);
                  8: {SizeX} Objs[k].sizeX:=StrToInt(par);
                  9: {SizeY} Objs[k].sizeY:=StrToInt(par);
                  10: {*parns} Begin
                    if l<6 then inc(l);
                    Objs[k].parns[l]:=par;
                  End;
                  11: {OffsetX} Objs[k].OffsetX:=StrToInt(par);
                  12: {OffsetY} Objs[k].OffsetY:=StrToInt(par);
                  13: {OffsetZ} Objs[k].OffsetZ:=StrToInt(par);
               end;
             End;
          End;
    End;
  end;

  if Developer then
  Begin
    for I := 0 to ObjCount do
      Objs2[i]:=Objs[i];
      ObjCount2:=ObjCount;
  End else
  Begin
    ObjCount2:=0;
    for I := 0 to ObjCount do
    begin
     if (Objs[i].Name<>'bombin') and
        (Objs[i].Name<>'bl1') and
        (Objs[i].Name<>'bl2') and
        (Objs[i].Name<>'arcade') and
        (Objs[i].Name<>'hint') and
        (Objs[i].Name<>'event') and
        (Objs[i].Name<>'bossturrel1') and
        (Objs[i].Name<>'darkness') and
        (Objs[i].Name<>'levlight') and
        (Objs[i].Name<>'mayak') and
        (Objs[i].Name<>'noway') and
        (Objs[i].Name<>'plasmid') and
        (Objs[i].Name<>'rbox') and
        (Objs[i].Name<>'Robot') and
        (Objs[i].Name<>'bombin') and
        (Objs[i].Name<>'rrbox') and
        (Objs[i].Name<>'rock2') and
        (Objs[i].Name<>'scanzone') then
        Begin
           Objs2[ObjCount2]:=Objs[i];
           inc(ObjCount2);
        End;
     end;
  End;

  s.Destroy;
  files.Destroy;
end;

procedure TMainForm.LoadSettings;
var S,s2:TstringList;
begin

    //// ПО УМОЛЧАНИЮ
       Device.Width:=Screen.width;
       Device.Height:=Screen.Height;
       WindowState:=wsMaximized;
       
       Developer:=false;
       if fileexists('Developer.loc') then
        Begin
         S2:=TStringList.Create;
         S2.LoadFromFile('Developer.loc');
         try
           if s2[0]='1' then
            Developer:=true;
         except
            Developer:=false;
         end;
         S2.Destroy
        End;

       if fileexists('Vsync.loc') then
        Device.Vsync:=true;
       Device.BitDepth:=bdHigh;
      //device.Windowed:=true;

        if fileexists('Lang.loc') then
        Begin
         S:=TStringList.Create;
         S.LoadFromFile('Lang.loc');
         try
           Lang:=s[0];
         except
           Lang:='RUS';
         end;
         S.Destroy
        End;

       ShowLas:=false;

       mapsizeX:=150;
       mapsizeY:=150;

     //  mainform.Position:=poScreenCenter;

      if fileexists('NoBackground.loc') then
       Disableback:=true;

      if fileexists('FullScreen.loc') then
       Device.Windowed:=false;
       
end;


procedure TMainForm.MiniMap;
var xx,yy:integer;
begin
///
 xx:=GuiBase.Ctrl['Form6'].Left+8;
 yy:=GuiBase.Ctrl['Form6'].Top+28;

 MiniBitMap.Canvas.Brush.Color:=clNavy;
 MiniBitMap.Canvas.FillRect(Ramka1);
 MiniBitMap.Canvas.FillRect(Ramka2);

 if images2.Find('Minimap')<>-1 then
  Images2.Image['Minimap'].LoadFromBitmap(MiniBitMap,false,clBlack,0);

 if Images2.Find('MiniMap')<>-1 then
   MyCanvas.DrawStretch(Images2.Image['MiniMap'],0, xx,yy,xx+200,yy+200,false,false,clwhite4,fxNone);


 Mycanvas.rectangle(MM_X+xx+round(layerx*mmscale/100),MM_Y+yy+round(layery*mmscale/100),
 round(device.Width/gamescaleX*mmscale/100),round((device.Height-hudh)/gamescaleY*mmscale/100),
            crgb1(255,255,255,225),crgb1(0,0,0,0),FxBlend);

end;

function TMainForm.mouseonmm(x, y: integer): boolean;
var mmx,mmy:integer;
begin
  Result:=false;

  if GuiBase.Ctrl['Form6'].Visible then
  Begin
  mmx:=GuiBase.Ctrl['Form6'].Left;
  mmy:=GuiBase.Ctrl['Form6'].Top;

  if (x>mmx)and(x<mmx+220)and(y>mmy)and(y<mmy+272) then
    Result:=true;
  End;


  if GuiBase.Ctrl['Form10'].Visible then
  Begin

    mmx:=GuiBase.Ctrl['Form10'].Left;
    mmy:=GuiBase.Ctrl['Form10'].Top;

    if (x>mmx)and(x<mmx+500)and(y>mmy)and(y<mmy+192) then
      Result:=true;

  End;

end;

procedure TMainForm.N4Click(Sender: TObject);
begin
close;
end;

procedure TMainForm.NewCancelClick(Sender: TObject);
begin
//
newmenu:=false;
end;

procedure TMainForm.NewClick(Sender: TObject);
begin
savemenu:=true;
newmenu:=true;
neednew:=true;
end;

procedure TMainForm.NewOkClick;
var ind,i:integer;
    s:string;  b:boolean;
begin
////
 if neednew then
 Begin
  Engine.Clear;
  DopAsdb.Clear;
  _MapFile:='';
 End;

//  with GuiBase.Taskbar do
//    ind:=TGuiListBox(Ctrl['ListBox1']).ItemIndex;

  with GuiBase.Taskbar do Begin
        MapName := TGuiEdit(Ctrl['Name']).Text;
        MapAuthor := TGuiEdit(Ctrl['Author']).Text;
        MapAbout := TGuiEdit(Ctrl['About']).Text;
  End;

    if ind<>-1 then newmenu:=false;

{  case ind of
    0: mapsizeX:=50;
    1: mapsizeX:=100;
    2: mapsizeX:=150;
    3: mapsizeX:=200;
    4: mapsizeX:=300;
  end;}
   with GuiBase.Taskbar do Begin
    mapsizeX:=100;
    mapsizeY:=100;
    try
      mapsizeX:= StrToInt(TGuiEdit(Ctrl['Sx']).Text);
      mapsizeY:= StrToInt(TGuiEdit(Ctrl['Sy']).Text);
    finally

    end;
   End;

   for i:=1 to 18 do
   with GuiBase.Taskbar do
   Begin
    b:=TGuiCheckBox(Ctrl['CheckBox'+inttostr(i)]).Checked;
    if b=true then
    Begin
      s:=TGuiCheckBox(Ctrl['CheckBox'+inttostr(i)]).Caption;
      if i=18 then
        s:='..\Languages\'+LANG+'\'+TGuiCheckBox(Ctrl['CheckBox'+inttostr(i)]).Caption;
      DopAsdb.Add(s);
    End;
   End;

   clearDop;

  if DopAsdb.Count>0 then
   for i := 0 to DopAsdb.Count-1 do
   Begin
    loaddop(Dopasdb[i]);
   End;


  // mapsizeY:=mapsizeX;

     with GuiBase.Taskbar do
      TGuiCheckbox(ctrl['Lasbox']).Checked:=false;

     if neednew then
     with GuiBase.Taskbar do
               TGuiListBox(Ctrl['ListBox']).Items.Clear;
   CreateMM;
end;

procedure TMainForm.NoExitClick(Sender: TObject);
begin
//
exitmenu:=false;
end;

procedure TMainForm.NoSaveClick(Sender: TObject);
begin
//
savemenu:=false;
end;

procedure TMainForm.o1(Sender: TObject);
begin
//
choose:=page*14+1;
end;

procedure TMainForm.o10(Sender: TObject);
begin
choose:=page*14+10;
end;

procedure TMainForm.o11(Sender: TObject);
begin
choose:=page*14+11;
end;

procedure TMainForm.o12(Sender: TObject);
begin
choose:=page*14+12;
end;

procedure TMainForm.o13(Sender: TObject);
begin
choose:=page*14+13;
end;

procedure TMainForm.o14(Sender: TObject);
begin
choose:=page*14+14;
end;

procedure TMainForm.o2(Sender: TObject);
begin
choose:=page*14+2;
end;

procedure TMainForm.o3(Sender: TObject);
begin
  choose:=page*14+3;
end;

procedure TMainForm.o4(Sender: TObject);
begin
  choose:=page*14+4;
end;

procedure TMainForm.o5(Sender: TObject);
begin
  choose:=page*14+5;
end;

procedure TMainForm.o6(Sender: TObject);
begin
  choose:=page*14+6;
end;

procedure TMainForm.o7(Sender: TObject);
begin
  choose:=page*14+7;
end;

procedure TMainForm.o8(Sender: TObject);
begin
  choose:=page*14+8;
end;

procedure TMainForm.o9(Sender: TObject);
begin
  choose:=page*14+9;
end;

procedure TMainForm.OpenDialogCanClose(Sender: TObject; var CanClose: Boolean);
var i,j:integer;
    fn:string;
begin
  for i := 0 to Engine.Count - 1 do
    Engine.Items[i].Dead;
  Engine.Dead;
  LoadMap(Opendialog.FileName);
//  Createmap;
  SetCurrentDir(Dir0);
  Timer.Enabled:=true;
  Newmenu:=false;
  SaveDialog.FileName:=Opendialog.FileName;


 fn:=SaveDialog.FileName;
 for i:=1 to length(fn) do
  if copy(fn,i,1)='\' then
       j:=i;
  delete(fn,1,j);

  _MapFile:=fn;


  with GuiBase.Taskbar do
    TGuiCheckbox(ctrl['Lasbox']).Checked:=false;
  ShowLas:=false;
end;

procedure TMainForm.OpenDialogClose(Sender: TObject);
begin
 Timer.Enabled:=true;
end;

procedure TMainForm.OpenDialogShow(Sender: TObject);
begin
 Timer.Enabled:=false;
 //SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE)
end;

procedure TMainForm.OtherSizeChange(Sender: TObject);
var ind:integer;
begin
 with GuiBase.Taskbar do Begin
    ind:=TGuiListBox(Ctrl['ListBox1']).ItemIndex;

  case ind of
    0: mapsizeX:=50;
    1: mapsizeX:=100;
    2: mapsizeX:=150;
    3: mapsizeX:=200;
    4: mapsizeX:=300;
  end;
   mapsizeY:=mapsizeX;

  TGuiEdit(Ctrl['Sx']).Text:=IntToStr(MapSizeX);
  TGuiEdit(Ctrl['Sy']).Text:=IntToStr(MapSizeY);
 End;

end;

procedure TMainForm.pback(Sender: TObject);
begin
if page>0 then
  dec(page)
end;

procedure TMainForm.pnext(Sender: TObject);
begin
if page*14<ObjCount2-14 then
  inc(page)
end;

procedure TMainForm.ProgramCursor;
begin
if needarrow=0 then
MyCanvas.Draw(Images.Image['cursor_editor'],mx,my,0,FxBlend)
 else
 case needarrow of
   1: MyCanvas.Draw(Images.Image['cursor_scroll'],mx-16,my,0,FxBlend);
   2: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx-16,my-16,pi,1,0,FxBlend);
   3: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx+16,my,pi*3/2,1,0,FxBlend);
   4: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx-16,my,pi/2,1,0,FxBlend);

   5: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx+16,my+16,pi*7/4,1,0,FxBlend);
   6: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx+16,my-16,pi*5/4,1,0,FxBlend);
   7: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx-16,my+16,pi/4,1,0,FxBlend);
   8: MyCanvas.DrawRot(Images.Image['cursor_scroll'],mx-16,my-16,pi*3/4,1,0,FxBlend)
 end;
end;

procedure TMainForm.RemoveButtonClick(Sender: TObject);
var index,i:integer;
 obj:TObject;
begin
popmenu:=false;
with GuiBase.Taskbar do
 index:=TGuiListBox(Ctrl['ListBox']).ItemIndex;


  if Index<>-1 then Begin

   with GuiBase.Taskbar do
    if ((TGuiListBox(Ctrl['ListBox']).Items.Objects[index])<>nil) then
     Obj:=(TGuiListBox(Ctrl['ListBox']).Items.Objects[index]);

     if Obj is TTile then
       TTile(Obj).Dead;



 with GuiBase.Taskbar do Begin
  //TGuiListBox(Ctrl['ListBox']).Items.Delete(index);
  TGuiListBox(Ctrl['ListBox']).ItemIndex:=-1;
 End;
 
End;
end;

procedure TMainForm.SaveClick(Sender: TObject);
begin
/// ЗДЕСЬ
  Timer.Enabled:=false;
  Savedialog.Execute;
  savemenu:=false;
end;

procedure TMainForm.SaveDialogCanClose(Sender: TObject; var CanClose: Boolean);
var fn,filename:string;
  i,j:integer;
begin
  FileName:= SaveDialog.FileName;
  
  if Pos('.map',SaveDialog.FileName)=0 then
  FileName:= SaveDialog.FileName+'.map';

 // showmessage(SaveDialog.FileName);

 fn:=SaveDialog.FileName;
 for i:=1 to length(fn) do
  if copy(fn,i,1)='\' then
       j:=i;
  delete(fn,1,j);


  _MapFile:=fn;

 if fileexists(FileName) then Begin
     if MessageDLG('Вы уверены, что хотите перезаписать уже существующий '+fn+' ?',mtConfirmation,mbOKCancel,0)=mrOk then
     Savemap(FileName) ;
 end else Savemap(FileName) ;

 SetCurrentDir(Dir0);
 Timer.Enabled:=true;
end;

procedure TMainForm.SaveDialogClose(Sender: TObject);
begin
 Timer.Enabled:=true;
end;

procedure TMainForm.SaveDialogShow(Sender: TObject);
begin
 Timer.Enabled:=false;
end;

procedure TMainForm.SaveMap(filename:string);
var mapfile:TStringList;
    i,j:integer;
    _mapObject:TTile;
begin
///

 mapfile:=TStringList.Create;
   mapfile.Add('SizeX: '+inttostr(mapsizex));
   mapfile.Add('SizeY: '+inttostr(mapsizey));


   mapfile.Add('Name: '+MapName);
   mapfile.Add('Author: '+MapAuthor);
   mapfile.Add('About: '+MapAbout);

   if DopAsdb.Count>0 then
    for i:=0 to DopAsdb.Count-1  do
       mapfile.Add('Load: '+(DopAsdb[i]));


   for I := 0 to Engine.Count - 1 do
    if Engine[i]<>nil then
     if Engine[i] is TTile then Begin
       _mapObject:=TTile(Engine[i]);
       mapfile.Add('//');
       mapfile.Add('Name: '+_mapObject.ObjName);

       mapfile.Add('X: '+inttostr(round(_mapObject.x)));
       mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
       mapfile.Add('Z: '+inttostr(round(_mapObject.z)));

       for j := 1 to 6 do
         if (_mapobject.parnames[j]<>'') then
            if (_mapobject.pars[j]<>'') then
                mapfile.Add(_mapobject.parnames[j]+': '+_mapobject.pars[j]);
     End;
     
   mapfile.SaveToFile(filename);
   mapfile.Destroy;
end;

procedure TMainForm.SavePreview(Sender: TObject);
begin
//
// MiniBitMap.Canvas.
  if _MapFile<>'' then
  Begin
    try
      MiniBitMap.SaveToFile(Dir0+mapDir+'\Previews\'+_MapFile+'.bmp');
    finally
      Showmessage('Сохранено в:'+mapDir+'\Previews\'+_MapFile+'.bmp')
    end;
  End
    else
      Showmessage('Не задано имя файла карты. Сохраните карту и попробуйте снова.')
end;

procedure TMainForm.Setka;
var i,j,xx,yy,X1,Y1:integer;
  MyColor:cardinal;
  _Img:TAsphyreImage;
begin
  resX:=clientWidth/Device.Width;
  resY:=clientHeight/Device.Height;

  xx:=trunc(((mx)/gamescaleX/resx+layerX)/100)*100;
  yy:=trunc(((my)/gamescaleY/resy+layerY)/100)*100;

  with mycanvas do Begin

  if showgrid then Begin
     for i := 0 to mapsizeX+1 do Begin
      x1:=round((-layerx+i*100)*gamescaleX);
       if (i=0)or(i=mapsizex+1) then
        MyColor:=crgb1(255,55,55,255)
          else MyColor:=crgb1(255,255,255,105);

     if (X1>-100*gamescaleX)and(X1<device.Width+100*gamescaleX) then
       MyCanvas.Line(x1,0,x1,device.Height,MyColor,MyColor,FxBlend);
     End;

     for i := 0 to mapsizeY+1 do Begin
      y1:=round((-layery+i*100)*gamescaleY);
      if (i=0)or(i=mapsizey+1) then
        MyColor:=crgb1(255,55,55,255)
          else MyColor:=crgb1(255,255,255,105);
     if (y1>-100*gamescaleX)and(y1<device.Height+100*gamescaleX) then
       MyCanvas.Line(0,y1,device.Width,y1,MyColor,MyColor,FxBlend);
     End;

  End;
  { for i := 0 to mapsizeX do

     for j := 0 to mapsizeY do Begin

       x1:=round((-layerx+i*100)*gamescaleX);
       y1:=round((-layery+j*100)*gamescaleY);

       if (X1>-100*gamescaleX)and(y1>-100*gamescaleX)
       and(X1<device.Width+100*gamescaleX)and(y1<device.Height+100*gamescaleX) then

       rectangle(x1,y1,round(101*gamescaleX),round(101*gamescaleY),
            crgb1(255,255,255,105),crgb1(0,0,0,0),FxBlend);
     End; }


        rectangle(trunc((xx-layerX)*gamescaleX),trunc((yy-layerY)*gamescaleY),
                  trunc(gamescaleX*Objs2[choose-1].sizeX),trunc(gamescaleY*Objs2[choose-1].sizeY),
            crgb1(255,55,55,255),crgb1(0,0,0,0),FxBlend);

       if Objs2[choose-1].Img<>'' then
       Begin
        _Img:=Images.Image[Objs2[choose-1].Img];

        if Objs2[choose-1].Tip=70 then
         MyCanvas.DrawStretch(_Img,0,trunc((xx-layerX+Objs2[choose-1].offsetX)*gamescaleX),
            trunc((yy-layerY+Objs2[choose-1].offsetY)*gamescaleY),
            trunc((xx+Objs2[choose-1].offsetX-layerX+_img.PatternSize.x*4)*gamescaleX),
            trunc((yy-layerY+_img.PatternSize.Y*4+Objs2[choose-1].offsetY)*gamescaleY),
            false,false,crgb4(100,255,100,255),fxAdd)
             else
        MyCanvas.DrawStretch(_Img,0,trunc((xx-layerX+Objs2[choose-1].offsetX)*gamescaleX),
            trunc((yy-layerY+Objs2[choose-1].offsetY)*gamescaleY),
            trunc((xx+Objs2[choose-1].offsetX-layerX+_img.PatternSize.x)*gamescaleX),
            trunc((yy-layerY+_img.PatternSize.Y+Objs2[choose-1].offsetY)*gamescaleY),
            false,false,crgb4(100,255,100,180),fxBlend);


       End;

  End;
end;


procedure TMainForm.SettingsClick(Sender: TObject);
var i,j:integer;
begin
  newmenu:=true;
  neednew:=false;
  for j := 1 to 18 do
    with GuiBase.Taskbar do
      TGuiCheckBox(Ctrl['CheckBox'+inttostr(j)]).Checked:=false;

  for i := 0 to DopAsdb.Count - 1 do
  Begin

    for j := 1 to 17 do
      with GuiBase.Taskbar do
      Begin
        if DopAsdb[i]=TGuiCheckBox(Ctrl['CheckBox'+inttostr(j)]).Caption then
           TGuiCheckBox(Ctrl['CheckBox'+inttostr(j)]).Checked:=true;
      End;


    if Pos('..\Languages\',DopAsdb[i])>=1 then
      with GuiBase.Taskbar do
        TGuiCheckBox(Ctrl['CheckBox18']).Checked:=true;
  End;


   with GuiBase.Taskbar do Begin
      TGuiEdit(Ctrl['Sx']).Text:= IntToStr(mapsizeX);
      TGuiEdit(Ctrl['Sy']).Text:= IntToStr(mapsizeY);
   End;
end;

procedure TMainForm.Showhelp(Sender: TObject);
begin
   inherited;
   with GuiBase do
   if TGuiCheckBox(Ctrl['HelpBox']).Checked then
     GuiBase.Ctrl['Form10'].Show
     else
       GuiBase.Ctrl['Form10'].Hide
end;

procedure TMainForm.Showobj(Sender: TObject);
var index,i,j:Integer;
 Obj:Tobject;
begin
popmenu:=false;
with GuiBase.Taskbar do
 index:=TGuiListBox(Ctrl['ListBox']).ItemIndex;


  if Index<>-1 then Begin

    for I := 0 to Engine.Count - 1 do
      TTile(Engine[i]).Chang:=false;

   with GuiBase.Taskbar do
    if ((TGuiListBox(Ctrl['ListBox']).Items.Objects[index])<>nil) then
     Obj:=(TGuiListBox(Ctrl['ListBox']).Items.Objects[index]);

    with Guibase do
    Begin
     if TGuiCheckBox(Ctrl['HelpBox']).Checked then
     Begin
      for j := 0 to 7 do
         TGuiLabel(Ctrl['Label'+inttostr(j+14)]).Text:='';


      if FileExists((Dir0+'\Hints_'+LANG+'\'+TTile(Obj).ObjName+'.txt')) then
      Begin
        HelpText.LoadFromFile(Dir0+'\Hints_'+LANG+'\'+TTile(Obj).ObjName+'.txt');
       // TGuiLabel(Ctrl['Label18']).Text:=Dir0+'\Hints\'+TTile(Obj).ObjName+'.txt';

         for j := 0 to 7 do
         try
         TGuiLabel(Ctrl['Label'+inttostr(j+14)]).Text:=HelpText[j];
         except

         end;

      End else
      Begin
      // TGuiLabel(Ctrl['Label14']).Text:=Dir0+'\Hints\'+TTile(Obj).ObjName+'.txt';

        
      End;

     End;
    End;

     if Obj is TTile then
     Begin
       TTile(Obj).Chang:=true;
         with GuiBase.Taskbar do Begin
          TGuiEdit(Ctrl['Edit7']).Text:=IntToStr(round(TTile(Obj).X));
          TGuiEdit(Ctrl['Edit8']).Text:=IntToStr(round(TTile(Obj).Y));
          TGuiEdit(Ctrl['Edit9']).Text:=IntToStr(round(TTile(Obj).Z));

          TGuiLabel(Ctrl['Label9']).Text:=TTile(Obj).ObjName; //inttostr(TTile(Obj).tip); //TipNames[TTile(Obj).tip];

          for j := 1 to 6 do Begin
            TGuiLabel(Ctrl['par'+inttostr(j)]).Visible:=false;
            if (TTile(Obj).parnames[j]<>'') then Begin
              TGuiLabel(Ctrl['par'+inttostr(j)]).Visible:=true;
              TGuiLabel(Ctrl['par'+inttostr(j)]).Text:=TTile(Obj).parnames[j];
              TGuiEdit(Ctrl['Edit'+inttostr(j)]).Visible:=true;
              TGuiEdit(Ctrl['Edit'+inttostr(j)]).Text:=TTile(Obj).pars[j];
            End;
            TGuiEdit(Ctrl['Edit'+inttostr(j)]).Visible:=TGuiLabel(Ctrl['par'+inttostr(j)]).Visible;
          End;

         End;

      End;
   End;



  

end;

procedure TMainForm.AcceptClick(Sender: TObject);
var i,index,j,k:integer;
 Obj:Tobject;
begin
  with GuiBase.Taskbar do
   index:=TGuiListBox(Ctrl['ListBox']).ItemIndex;
  if Index<>-1 then Begin

   with GuiBase.Taskbar do
    if ((TGuiListBox(Ctrl['ListBox']).Items.Objects[index])<>nil) then
     Obj:=(TGuiListBox(Ctrl['ListBox']).Items.Objects[index]);

    with GuiBase.Taskbar do
    Begin
     if Obj is TTile then
     Begin
      for i:=1 to 6 do
      Begin
         if (TTile(Obj).parnames[i]='mirrorX')or(TTile(Obj).parnames[i]='MirrorX') then
         Begin
          k:=strtoint((TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text));
          if k=1 then
            TTile(Obj).mirrorX:=true;
         End;

          if (TTile(Obj).parnames[i]='mirrorY')or(TTile(Obj).parnames[i]='MirrorY') then
          Begin
           k:=strtoint((TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text));
           if k=1 then
            TTile(Obj).mirrorY:=true;
          End;



        if (TTile(Obj).parnames[i]='Angle') then
        Begin
            k:=strtoint((TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text));
            TTile(Obj).OffsetX:=TTile(Obj).ImageWidth*TTile(Obj).ScaleX/2;
            TTile(Obj).OffsetY:=TTile(Obj).ImageHeight*TTile(Obj).ScaleY/2;
            TTile(Obj).DrawMode:=1;
            TTile(Obj).Angle:=pi*k/180;
        End else
       if (TTile(Obj).parnames[i]='Color')or(TTile(Obj).parnames[i]='color') then
       Begin
        if (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='1') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='2') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='3') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='4') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='5') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='6') or
           (TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text='7')
         then
            Begin
              k:=strtoint((TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text));
              TTile(Obj).R:=Redw[k];
              TTile(Obj).G:=Greenw[k];
              TTile(Obj).B:=Bluew[k];
            End;
       End;
      End;


       TTile(Obj).X:=Strtoint(TGuiEdit(Ctrl['Edit7']).Text);
       TTile(Obj).Y:=Strtoint(TGuiEdit(Ctrl['Edit8']).Text);
       TTile(Obj).Z:=Strtoint(TGuiEdit(Ctrl['Edit9']).Text);
       for I := 1 to 6 do
          if TGuiEdit(Ctrl['Edit'+inttostr(i)]).Visible=true then
            TTile(Obj).pars[i]:=(TGuiEdit(Ctrl['Edit'+inttostr(i)]).Text);
     End;
    End;
  End;
end;

procedure TMainForm.AddEvents();
begin
 // This code accesses two buttons and add their events.
 // Notice that 'Ctrl' property allows you to access any AsphyreGUI
 // control within the set.


 GuiBase.Ctrl['Form6'].Left:= 1060;
 GuiBase.Ctrl['Form6'].Top := 10;

 with GuiBase do
  begin
  // TGuiButton(Ctrl['CloseButton']).OnClick := CloseButtonClick;
 //  TGuiButton(Ctrl['AddButton']).OnClick   := AddButtonClick;

    TGuiButton(Ctrl['RemoveButton']).OnClick:= RemoveButtonClick;
    TGuiButton(Ctrl['New_ok']).OnClick := NewOkClick;
    TGuiButton(Ctrl['Hidemm']).OnClick := Hidemm;
    TGuiButton(Ctrl['Accept']).OnClick := AcceptClick;

    TGuiButton(Ctrl['Obj1']).OnClick := o1;
    TGuiButton(Ctrl['Obj2']).OnClick := o2;
    TGuiButton(Ctrl['Obj3']).OnClick := o3;
    TGuiButton(Ctrl['Obj4']).OnClick := o4;
    TGuiButton(Ctrl['Obj5']).OnClick := o5;
    TGuiButton(Ctrl['Obj6']).OnClick := o6;
    TGuiButton(Ctrl['Obj7']).OnClick := o7;
    TGuiButton(Ctrl['Obj8']).OnClick := o8;
    TGuiButton(Ctrl['Obj9']).OnClick := o9;
    TGuiButton(Ctrl['Obj10']).OnClick := o10;
    TGuiButton(Ctrl['Obj11']).OnClick := o11;
    TGuiButton(Ctrl['Obj12']).OnClick := o12;
    TGuiButton(Ctrl['Obj13']).OnClick := o13;
    TGuiButton(Ctrl['Obj14']).OnClick := o14;


    TGuiButton(Ctrl['pnext']).OnClick := pnext;
    TGuiButton(Ctrl['pback']).OnClick := pback;


    TGuiListBox(Ctrl['ListBox']).OnChange := Showobj;
    TGuiListBox(Ctrl['ListBox2']).OnChange := ChooseObj;

    TGuiButton(Ctrl['New']).OnClick := NewClick;
    TGuiButton(Ctrl['Save']).OnClick := SaveClick;
    TGuiButton(Ctrl['SavePreview']).OnClick := SavePreview;
    TGuiButton(Ctrl['Save2']).OnClick := SaveClick;
    TGuiButton(Ctrl['Load']).OnClick := LoadClick;
    TGuiButton(Ctrl['Settings']).OnClick := SettingsClick;
    TGuiButton(Ctrl['Exit']).OnClick := ExitClick;

    TGuiCheckBox(Ctrl['LasBox']).OnChange:= LasBoxClick;
    TGuiCheckBox(Ctrl['HelpBox']).OnChange := Showhelp;
    TGuiListBox(Ctrl['ListBox1']).OnChange := OtherSizeChange;

    TGuiButton(Ctrl['Exit2']).OnClick := Exit2Click;
    TGuiButton(Ctrl['NoExit']).OnClick := NoExitClick;

    TGuiButton(Ctrl['NoSave']).OnClick := NosaveClick;
    TGuiButton(Ctrl['New_Cancel']).OnClick := NewcancelClick;

    TGuiButton(Ctrl['pback']).ImageIndex:= images.Find('back1');
    TGuiButton(Ctrl['pnext']).ImageIndex:= images.Find('next');

    TGuiButton(Ctrl['killhelp']).OnClick := KillHelp;

     GuiBase.Ctrl['Form10'].Hide;

     GuiBase.Ctrl['Form4'].Left:= (Device.Width-600)div 2;
     GuiBase.Ctrl['Form4'].Top := (Device.Height-384)div 2;

     GuiBase.Ctrl['Form8'].Left:= (Device.Width-GuiBase.Ctrl['Form8'].Width) div 2;
     GuiBase.Ctrl['Form8'].Top := (Device.Width-GuiBase.Ctrl['Form8'].Height-hudh) div 2;

     GuiBase.Ctrl['Form9'].Left:= (Device.Width-GuiBase.Ctrl['Form9'].Width) div 2;
     GuiBase.Ctrl['Form9'].Top := (Device.Width-GuiBase.Ctrl['Form9'].Height-hudh) div 2;
  end;
end;

procedure TMainForm.BackGround;
var i,j:integer;
  x0,y0:double;
begin
     MyCanvas.DrawStretch(Images.Image['back'], 0, 0, 0, Device.Width, Device.Height, false,false, clWhite4, fxNone);

     x0:=-layerX*0.25*gamescaleX;
     y0:=-layerY*0.25*gamescaley;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -2 to 2 do
       for j:= -2 to 2 do
     MyCanvas.DrawStretch(Images.Image['fon_3'], 0, (i-1)*(Device.Width div 2)+round(x0),
      round(y0)+(j-1)*(Device.Height div 2),round(x0)+(i)*Device.Width div 2,
      round(y0)+(j)*Device.Height div 2,
      false,false, clWhite4, fxAdd);

     x0:=-layerX*0.35*gamescaleX;
     y0:=-layerY*0.35*gamescaley;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_2'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);

     x0:=-layerX*0.5*gamescaleX;
     y0:=-layerY*0.5*gamescaley;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_3'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);
end;

procedure TMainForm.BuildLasers;
var i,j,_x1,_y1,_x2,_y2,napr,ii,jj,nextnapr,col,k,l,m,n,o,p:integer;
    mirrortype,virtnapr:integer;
    gonext,virt:boolean;
    SMMap:array of array of boolean;
begin

  SetLength(SMMap,mapsizeX+1,mapSizeY+1);

   for i := 0 to mapsizeX do
    for j := 0 to mapsizeY do
    Begin
     SMMAP[i,j]:=false;
    End;

  lasercount:=0;
  mirrorcount:=0;

 {Стираю старые}  {Генерация Мини-карты}
  for I := 0 to Engine.Count - 1 do
  Begin
    if Engine[i] is TLaser then
      Engine[i].Dead
      else
      Begin
         if Engine[i] is TTile then
         Begin
            case TTile(Engine[i]).tip of
              34..40,50..53:
              Begin
                inc(mirrorcount);
                Mirrors[mirrorcount]:=TTile(Engine[i]);
              End;
              33:
              Begin
                inc(lasercount);
                Lasers[lasercount]:=TTile(Engine[i]);
              End;
            end;


            case TTile(Engine[i]).tip of
             1,5..7,16,17,18,19,20,22,26,27,28,30,31..36,39,40,50..54,55..70:
                Begin


                    m:=trunc(TTile(Engine[i]).x) div 100;
                    n:=trunc(TTile(Engine[i]).x+TTile(Engine[i]).PatternWidth-5) div 100;
                    o:=trunc(TTile(Engine[i]).y) div 100;
                    p:=trunc(TTile(Engine[i]).y+TTile(Engine[i]).PatternHeight-5) div 100;

                    TTile(Engine[i]).oldcol:=0;
                    TTile(Engine[i]).oldnapr:=0;

                    if (TTile(Engine[i]).tip=34)or(TTile(Engine[i]).tip=35)
                    or(TTile(Engine[i]).tip=39)or(TTile(Engine[i]).tip=40) then
                    Begin
                      n:=m;
                      p:=o;
                    End;

                    if (TTile(Engine[i]).tip<>26)and(TTile(Engine[i]).tip<>28)and(TTile(Engine[i]).tip<>70) then
                     for k:=m to n do
                      for l:=o to p do
                        if (k>=0)and(l>=0)and(k<=mapsizex)and(l<=mapsizey) then
                          SmMAP[k,l]:=true;
                End;
              end;
          End;
      End;
  End;




{  for I := 1 to MirrorCount do
   if Mirrors[i]<>nil then
   Begin
     (Mirrors[i]).kdr:=0;
     if TTile(Mirrors[i]).tip>=39 then
     Begin
       TTile(Mirrors[i]).Push;
     End;
   End; }

  i:=0;
  while I < LaserCount do
  Begin
  inc(i);

  if i>=256 then
        break;

  if Lasers[i]<>nil then
  BEGIN

   if (TTile(Lasers[i]).tip)<34 then
   Begin
     virt:=false;

     napr:=0;
     if pos('1',TTile(Lasers[i]).objname)>0 then
        napr:=1 else
        if pos('2',TTile(Lasers[i]).objname)>0 then
          napr:=2 else
          if pos('3',TTile(Lasers[i]).objname)>0 then
            napr:=3 else
            if pos('4',TTile(Lasers[i]).objname)>0 then
              napr:=4;
              
    try
      col:=strtoint(TTile(Lasers[i]).pars[1]);
    except
      col:=8
    end;

   End else
   Begin

      virt:=true;
      napr:=TTile(Lasers[i]).oldnapr;
      col:=TTile(Lasers[i]).oldcol;
   End;





    nextnapr:=napr;

   ///// x1,y1
    case napr of
     1:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).PatternWidth)-3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).PatternHeight/2)+3;
      End;
     2:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).PatternWidth/2)+3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).PatternHeight)-5;
      End;
     3:Begin
       _x1:=trunc(TTile(Lasers[i]).x)+3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).PatternHeight/2)+3;
     End;
     4:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).PatternWidth/2)+3;
       _y1:=trunc(TTile(Lasers[i]).y)+3;
      End;
   end;

   gonext:=true;
   {Ð—ÐÐŸÐ£Ð¡ÐšÐÐ® Ð¦Ð˜ÐšÐ› ÐŸÐžÐ¡Ð¢Ð ÐžÐ•ÐÐ˜Ð¯ Ð¡Ð˜Ð¡Ð¢Ð•ÐœÐ« ÐžÐ¢Ð ÐÐ–Ð•ÐÐ˜Ð™ Ð›Ð£Ð§Ð}
   while Gonext do
   Begin

     for J := 1 to 50 do
     begin
       {Ð¦Ð˜ÐšÐ› ÐŸÐžÐ˜Ð¡ÐšÐ Ð—Ð•Ð ÐšÐÐ›}

       /// ÐšÐžÐžÐ Ð”Ð˜ÐÐÐ¢Ð ÐŸÐ ÐžÐ’Ð•Ð ÐšÐ˜
       case napr  of
         1:Begin
           _x2:=_x1+J*100;
           _y2:=_y1;
          End;
         2:Begin
           _x2:=_x1;
           _y2:=_y1+J*100;
          End;
         3:Begin
           _x2:=_x1-J*100;
           _y2:=_y1;
          End;
         4:Begin
           _x2:=_x1;
           _y2:=_y1-J*100;
          End;
       end;
         ii:=_x2 div 100;
         jj:=_y2 div 100;

       if (ii>0)and(ii<mapsizeX)and(jj>0)and(jj<mapsizeY) then
       BEGIN
          if SMMap[ii,jj]=true then
          begin
            gonext:=false;

            if napr mod 2 <>0 then
              _x2:=ii*100+50
                else
                  _y2:=jj*100+50;

            for k := 1 to mirrorcount do
             if Mirrors[k]<>nil then
               if (abs(TSprite(Mirrors[k]).x+TSprite(Mirrors[k]).PatternWidth/2-_x2)<TSprite(Mirrors[k]).PatternWidth/2)
               and(abs(TSprite(Mirrors[k]).y+TSprite(Mirrors[k]).PatternHeight/2-_y2)<TSprite(Mirrors[k]).PatternHeight/2) then
                 //if (TTile(Mirrors[k]).tip=35)or(TTile(Mirrors[k]).tip=34) then
                   Begin
                     mirrortype:=TTile(Mirrors[k]).tip-33;

                     if mirrortype>4 then
                          mirrortype:=mirrortype-5;


                     if napr mod 2 <>0 then
                      _x2:=trunc(TSprite(Mirrors[k]).x+58)
                      else
                        _y2:=trunc(TSprite(Mirrors[k]).y+58);

                      gonext:=true;
                      nextnapr:=0;
                      if mirrortype<3 then
                      Begin
                          //TTile(Mirrors[k]).kdr:=1;


                      case napr of
                       1:if mirrortype=1 then
                           nextnapr:=2
                           else
                             nextnapr:=4;
                       2:if mirrortype=1 then
                           nextnapr:=1
                           else
                             nextnapr:=3;
                       3:if mirrortype=1 then
                           nextnapr:=4
                           else
                             nextnapr:=2;
                       4:if mirrortype=1 then
                           nextnapr:=3
                           else
                             nextnapr:=1;
                       end;

                           {мнимые}
                       if TTile(Mirrors[k]).tip<39 then
                       Begin
                            case napr of
                          1:if mirrortype=1 then
                           virtnapr:=4
                           else
                             virtnapr:=2;
                          2:if mirrortype=1 then
                           virtnapr:=3
                           else
                             virtnapr:=1;
                          3:if mirrortype=1 then
                           virtnapr:=2
                           else
                             virtnapr:=4;
                          4:if mirrortype=1 then
                           virtnapr:=1
                           else
                             virtnapr:=3;
                          end;

                          if virtnapr<>TTile(Mirrors[k]).oldnapr then
                          Begin
                            inc(lasercount);
                            Lasers[lasercount]:=TTile(Mirrors[k]);
                            Lasers[lasercount].oldcol:=col;
                            TTile(Mirrors[k]).oldnapr:=virtnapr;
                          End;

                        
                      end;


                      End;

                      if nextnapr=0 then
                        gonext:=false;

                      if mirrortype>=12 then
                      Begin
                        case  mirrortype of
                          12:_x2:=trunc(TSprite(Mirrors[k]).x+236);
                          13:_x2:=trunc(TSprite(Mirrors[k]).x+65);
                          14:_y2:=trunc(TSprite(Mirrors[k]).y+236);
                          15:_y2:=trunc(TSprite(Mirrors[k]).y+65);
                        end;
                        
                        {(Mirrors[k]).pars[2]:=col;
                        (Mirrors[k]).kdr:=1;
                        (Mirrors[k]).Push;}
                      End else
                      if (Mirrors[k].tip=39)or(Mirrors[k].tip=40) then
                      Begin
                         {Mirrors[k].kdr:=1;
                         Mirrors[k].Push;}
                      End;



                      break;
                   End;
            break;
          end;
       END else
          BEGIN
           /// Ð¯Ñ‡ÐµÐ¹ÐºÐ° Ð’ÐÐ• ÑÐµÑ‚Ð¸
           gonext:=false;
           break;
          END;
     {ÐšÐžÐÐ•Ð¦ Ð¦Ð˜ÐšÐ›Ð ÐŸÐžÐ˜Ð¡ÐšÐ Ð—Ð•Ð ÐšÐÐ›}
     end;

         //// Ð¡ÐžÐ—Ð”ÐÐ® Ð¡ÐŸÐ ÐÐ™Ð¢
           if napr>0 then
           
             with TLaser.Create(Engine)  do
               BEGIN
                   ImageName := 'box1';

                    if _x1<_x2 then
                      x:=_x1
                        else
                          x:=_x2;
                    if _y1<_y2 then
                      y:=_y1
                        else
                          y:=_y2;

                    ScaleX:=2;
                    ScaleY:=2;
                    DrawMode:=5;

                    if napr mod 2=0 then
                    begin
                      ImageName := 'las';
                      ScaleY:=abs(_y1-_y2)/PatternHeight;
                    end
                     else
                      begin
                        ImageName := 'las2';
                        ScaleX:=abs(_x1-_x2)/PatternWidth;
                      end;
                    lascolor:=col;

                    Red:=RedW[lascolor];
                    Green:=GreenW[lascolor];
                    Blue:=BlueW[lascolor];

                    Fhe:=trunc(imageHeight*scaleY);
                    FWi:=trunc(imageWidth*scaleX);
                    {SpriteHeight:=trunc(PatternHeight*ScaleY);
                    {SpriteWidth:=trunc(PatternWidth*ScaleX);   }

                    if virt then alpha:=100;
                    

                    DoCollision := True;
                    CollideMethod:=cmRect;
                    direction:=napr;
                    z:=4;

                   { if (direction=1)or(direction=3) then
                        for k := Trunc(x) div 100+1 to Trunc(x+SpriteWidth) div 100-1 do
                          AIMaP[k,trunc(y) div 100]:=true
                            else
                            for k := Trunc(y) div 100+1 to Trunc(y+SpriteHeight) div 100-1 do
                              AIMaP[trunc(x) div 100,k]:=true;  }
                    
               END;

               if gonext then
               Begin
                 _x1:=_x2;
                 _y1:=_y2;

                 napr:=nextnapr;
                 
               End;
    {ÐšÐžÐÐ•Ð¦ Ð¦Ð˜ÐšÐ›Ð ÐŸÐžÐ¡Ð¢Ð ÐžÐ•ÐÐ˜Ð¯ Ð¡Ð˜Ð¡Ð¢Ð•ÐœÐ« ÐžÐ¢Ð ÐÐ–Ð•ÐÐ˜Ð™ Ð›Ð£Ð§Ð}
   End;

  END;
  End;

end;

procedure TMainForm.Chooseobj(Sender: TObject);
var i,index:integer;
begin

  with GuiBase.Taskbar do
   Begin
    index:=TGuiListBox(Ctrl['ListBox2']).ItemIndex;
        for I := 0 to TGuiListBox(Ctrl['ListBox']).Items.Count - 1 do
            if TGuiListBox(Ctrl['ListBox2']).Items.Objects[index]=
                  TGuiListBox(Ctrl['ListBox']).Items.Objects[i] then
              Begin
               TGuiListBox(Ctrl['ListBox']).ItemIndex:=i;
               TGuiListBox(Ctrl['ListBox']).OnChange(Sender);
              End;
             
   End;
   popmenu:=false
end;

procedure TMainForm.ClearDop;
var i,j:integer;
begin
  for I := 0 to DopImages.Count - 1 do
  Begin
   j:=images.Find(DopImages[i]);
   //showmessage(DopImages[i]);
   images.Remove(j);
  End;
  DopImages.Clear;
 // iface;

end;

procedure TMainForm.CreateMap;
var
   i:Integer;
begin
  //
  if True then

    {   with  TTile.Create(Engine) do
               begin
                    ImageName := 'Box1';
                    X := 0;//-MapData[i].X/48*2;
                    Y := 0;//-MapData[i].Y/48*2;
                    CollideMethod := cmRect;
                    DoCollision := True;
               end;}
end;

procedure TMainForm.CreateMapObj;
var px,py:real;
 MapO:TTile;
 i:integer;
 obj:Tobject;
begin
//
resX:=clientWidth/Device.Width;
resY:=clientHeight/Device.Height;

 px:=trunc(((mx)/gamescaleX/resx+layerX)/100)*100;
 py:=trunc(((my)/gamescaleY/resy+layerY)/100)*100;


 ShowLas:=false;

         if (px>=0)and(py>=0)
         and(px<mapsizex*100+1)and(py<mapsizey*100+1) then

          if Objs2[choose-1].Tip=4 then
               for i := 0 to Engine.Count - 1 do Begin
                  Obj:=Engine.Items[i];
                  if Obj is TTile then
                    if TTile(Obj).tip=4 then
                      Engine.Items[i].Dead;
               End;

           MapO:= TTile.Create(Engine);
            with Mapo  do
               begin
                   // zxc
                    ObjName:=Objs2[choose-1].Name;
                    ImageName := Objs2[choose-1].Img;
                    Patternindex:=Objs2[choose-1].Index;
                    Tip:=Objs2[choose-1].Tip;
                    X := px+Objs2[choose-1].offsetX;//-MapData[i].X/48*2;
                    Y := py+Objs2[choose-1].OffsetY;//-MapData[i].Y/48*2;

                    h:=Objs2[choose-1].sizeX;
                    w:=Objs2[choose-1].sizeY;


                    if tip=1 then
                    Z:=-1;

                    if tip=70 then
                    Begin
                      Z:=-1;
                      DrawFx:=FxAdd;
                      ScaleX:=4;
                      ScaleY:=4;
                      //DoCenter:=true;
                      Alpha:=128;
                    End;

                    if tip=5 then
                    Begin
                     if ObjName='door1' then
                      //X:=X-57;
                     if ObjName='door2' then
                      //Y:=Y-59;
                     z:=1;
                    end;


                    if Tip=8 then
                    Begin
                     //X:=X+16;
                     //Y:=Y+16;
                     z:=1;
                    End;

                    if Tip=8 then
                    Begin
                     z:=-2;
                    End;

                    if Tip=2 then
                    Begin
                     z:=-5;
                    End;
                    if tip=8 then
                    z:=5;

                    if Objs2[choose-1].OffsetZ<>0 then
                      Z:=Objs2[choose-1].OffsetZ;

                    
                    CollideMethod := cmRect;
                    DoCollision := True;

                    r:=255;
                    g:=255;
                    b:=255;
                    
                    for i := 1 to 6 do Begin
                      parnames[i]:=Objs2[choose-1].parns[i];
                      pars[i]:='0';
                    End;
             end;

   with GuiBase.Taskbar do
   TGuiCheckBox(Ctrl['Lasbox']).Checked:=Showlas;

  with GuiBase.Taskbar do
     TGuiListBox(Ctrl['ListBox']).Items.AddObject(Objs2[choose-1].Name+
          '('+inttostr(trunc(Mapo.X/100))+','+inttostr(trunc(Mapo.Y/100))+')',MapO);
end;

procedure TMainForm.CreateMM;
var img1:TAsphyreImage;
    i,j:integer;
begin
SetCurrentdir(dir0);


  MiniBitMap.Width:=200;
  MiniBitMap.Height:=200;
  //B.SetSize(mapSizeX,mapSizeY);
  MiniBitMap.Canvas.Rectangle(0,0,200,200);


if images2.Find('Minimap')<>-1 then
  Images2.Image['Minimap'].LoadFromBitmap(MiniBitMap,false,clBlack,0);


  if MapSizeX>=MapSizeY then
    mmscale:=200/(MapSizeX+1)
      else mmscale:=200/(MapSizeY+1);

  MM_X:=0;
  MM_Y:=0;

  Ramka1.Left:=0;
  Ramka1.Top:=0;
  Ramka1.Right:=0;
  Ramka1.Bottom:=0;
  Ramka2.Left:=0;
  Ramka2.Top:=0;
  Ramka2.Right:=0;
  Ramka2.Bottom:=0;

  if MapSizeX<>MapSizeY then
  Begin
   if MapSizeX>MapSizeY then
   Begin
     MM_Y:=trunc(mmscale*(MapSizeX+1-MapSizeY)/2);
     Ramka1.Left:=0;
     Ramka1.Top:=0;
     Ramka1.Right:=200;
     Ramka1.Bottom:=MM_Y;

     Ramka2.Left:=0;
     Ramka2.Top:=200-MM_Y;
     Ramka2.Right:=200;
     Ramka2.Bottom:=200;
   End
     else
     Begin
       MM_X:=trunc(mmscale*(MapSizeY+1-MapSizeX)/2);
       Ramka1.Left:=0;
       Ramka1.Top:=0;
       Ramka1.Right:=MM_X;
       Ramka1.Bottom:=200;

       Ramka2.Left:=200-MM_X;
       Ramka2.Top:=0;
       Ramka2.Right:=200;
       Ramka2.Bottom:=200;
     End;

  End;

  Ramka1.Left:=0;
  Ramka1.Top:=0;

end;


procedure TTile.Dead;
var i:integer;
begin
  inherited;

with Mainform.GuiBase.Taskbar do
  for I := TGuiListBox(Ctrl['ListBox']).Items.Count-1 Downto 0 do
    Begin
      if self=TGuiListBox(Ctrl['ListBox']).Items.Objects[i] then
          TGuiListBox(Ctrl['ListBox']).Items.Delete(i);
    End;

end;

procedure TTile.Draw;
begin
inherited;

if Showmm then
Begin
with MiniBitMap.Canvas do
 Begin
  if tip=1 then
  Pen.Color:=$BE9C5E
   else  if tip=2 then
    Pen.Color:=$775E31
    else  if tip=3 then
    Pen.Color:=clMaroon
     else  if tip=4 then
      Pen.Color:=clAqua
      else  if tip=12 then
      Pen.Color:=clRed
       else  if (tip=10)or(tip=11) then
        Pen.Color:=clMoneyGreen
       else
       if (tip=5)or(tip=7)or(tip=6)or(tip=16)or(tip=21)or(tip=17)then Begin
         if pars[1]<>'' then
         Pen.Color:=rgb(Redw[strtoint(pars[1])],Greenw[strtoint(pars[1])],Bluew[strtoint(pars[1])])
       End
       else Pen.Color:=clOlive;
  if chang then Pen.Color:=clWhite;
  Brush.Color:=Pen.Color;

  if (tip=3)or(tip=4)or(tip=12)or(tip=10)or(tip=11) then
   Ellipse(MM_X+round(x*mmscale) div 100, MM_Y+round(y*mmscale) div 100,
      MM_X+round(x*mmscale+imagewidth*mmscale) div 100+1,MM_Y+round(y*mmscale+imageHeight*mmscale) div 100+1)
   else
    if Pen.color<>clOlive then
    Rectangle(MM_X+round(x*mmscale) div 100, MM_Y+ round(y*mmscale) div 100,
       MM_X+round(x*mmscale+(imagewidth-1)*mmscale) div 100+1,MM_Y+round(y*mmscale+(imageHeight-1)*mmscale+1) div 100);

 end;
End;

 

 if (tip=8) and (pars[1]<>'') and(pars[2]<>'') and (parnames[1]='Width')  then
 Begin
  Mainform.Mycanvas.Rectangle(trunc((x+32-strtoint(pars[1])-Engine.WorldX)*Engine.WorldScaleX),
  trunc((y+32-strtoint(pars[2])-Engine.WorldY)*Engine.WorldScaleY),
  trunc(strtoint(pars[1])*2*Engine.WorldScaleX),
  trunc(strtoint(pars[2])*2*Engine.WorldScaleY),
  crgb1(250,250,250,200),crgb1(250,250,250,100),FxBlend);
 End;

  if (tip=22) and ((pars[1]='1') or (pars[1]='2')or (pars[1]='3')or
      (pars[1]='4')or (pars[1]='5') or (pars[1]='6')or (pars[1]='7')) then
 Begin
  Mainform.Mycanvas.Fillrect(trunc((x+20-Engine.WorldX)*Engine.WorldScaleX),
  trunc((y+20-Engine.WorldY)*Engine.WorldScaleY),
  trunc((imagewidth-40)*Engine.WorldScaleX),
  trunc((imageheight-40)*Engine.WorldScaleY),
  crgb1(redw[strtoint(pars[1])],greenw[strtoint(pars[1])],bluew[strtoint(pars[1])],200),FxBlend);
 End;

 if (tip=23) and (pars[1]<>'') and(pars[2]<>'') and (parnames[1]='DistY') then
 Begin
  Mainform.Mycanvas.FrameRect(trunc(((x+128)-Engine.WorldX)*Engine.WorldScaleX),
  trunc(((y+128)-Engine.WorldY)*Engine.WorldScaleY),
  trunc((-strtoint(pars[2])-200)*Engine.WorldScaleX),
  trunc((strtoint(pars[1])+200)*Engine.WorldScaleY),
  crgb1(250,50,50,200),FxBlend);
 End;


end;

procedure TTile.Move;
var xcolor1,xcolor2: cardinal;
begin
     inherited;
///
 if Chang then Begin
  t:=t+MoveCount/20;
  if t>4*pi then
    t:=0;

  Blue:=200+round(55*cos(t));
  red:=Blue;
  Green:=Blue;
 end
 else
 Begin
  Blue:=b;
  red:=r;
  Green:=g;
   if tip=11 then
     Green:=150;
   if tip=30 then
   Begin
      xcolor1:=clwhite;
      xcolor2:=clwhite;
      try
        xColor1:=crgb1(redw[strtoint(pars[1])],greenw[strtoint(pars[1])],bluew[strtoint(pars[1])],255);
        xColor2:=crgb1(redw[strtoint(pars[2])],greenw[strtoint(pars[2])],bluew[strtoint(pars[2])],255);
      finally
        if h>w then
        Begin
          Color1:= xcolor1;
          Color2:= xcolor2;    // []
          Color3:= xcolor2;
          Color4:= xcolor1;
        End else
        Begin
          Color1:= xcolor1;
          Color2:= xcolor1;   /// ^_
          Color3:= xcolor2;
          Color4:= xcolor2;
        End;
        DrawMode:=2;
      end;
     { Blue:=b;
      red:=r;
      Green:=g;}
   End;
 End;



end;


procedure TMainForm.DeviceInitialize(Sender: TObject; var Success: boolean);
begin
     // load all images from ASDb
     Success := Images.LoadFromASDb(Asdb1);
     Success := Images.LoadFromASDb(AGraphics);
     Success := Images.LoadFromASDb(HD);
     Success := Images.LoadFromASDb(AFonts);
     Success := Images.LoadFromASDb(FX);

      // load all Fonts from ASDb
     Success := Fonts.LoadFromASDb(AFonts);
     AFonts.FileName:='EmptyMap.asdb';
     Success := Images2.LoadFromASDb(AFonts);

      if (Success) then
     Success:= GuiBase.Taskbar.LoadFromFile('main_'+LANG+'.gui');

     // start rendering only if succeeded loading stuff
     Timer.Enabled := Success;

end;

procedure TMainForm.TimerProcess(Sender: TObject);
var i,count:integer;
VecMov:TPoint2;
begin

end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
     // render the scene
     {Device.Render(RGB(55, 140, 210), True);}

     ///// МАСШТАБЫ
      Engine.WorldScaleX:=GameScaleX;
      Engine.WorldScaleY:=GameScaleY;

      ///Engine.VisibleArea:= Rect(round(-Device.Height/Engine.WorldScaleX), round(-Device.Height/Engine.WorldScaleY),
      //round((Device.Width*2)/Engine.WorldScaleX), round((Device.Height*2)/Engine.WorldScaleY));

        Engine.VisibleArea:= Rect(round(-100/Engine.WorldScaleX),round(-100/Engine.WorldScaleY),
      //round((Device.Width)/resolutionScaleX), round((Device.Height)/resolutionScaleY));
      round((Device.Width)/Engine.WorldScaleX), round((Device.Height)/Engine.WorldScaleY));


      if go then Begin
       engine.WorldX:=engine.WorldX+(mx-xd)*lagcount*0.1;
       engine.WorldY:=engine.WorldY+(my-yd)*lagcount*0.1;
      End;
      if Engine.WorldX<-20 then Engine.WorldX:=-20;
      if Engine.WorldY<-20 then Engine.WorldY:=-20;

      if Engine.WorldX>mapsizeX*100-Device.Width/GameScaleX+120 then Engine.WorldX:=mapsizeX*100-Device.Width/GameScaleX+120;
      if Engine.WorldY>mapsizeY*100-Device.Height/GameScaleY+120+HudH/GameScaleY then Engine.WorldY:=mapsizeY*100-Device.Height/GameScaleY+120+HudH/GameScaleY;

      layerX:=Engine.WorldX;
      layerY:=Engine.WorldY;

      
      Device.Render(RGB(0, 0, 0), True);
      GuiBase.Update();


     // Label1.Caption:='X: '+inttostr(round(layerX))+ ' Y: '+inttostr(round(layerY));

      // do calculations while Direct3D is still rendering
      Timer.Process();


   needarrow:=0;
    if my<10 then
    Begin
     Engine.WorldY:=Engine.WorldY-25*lagcount;
     needarrow:=1;

    End;
    if my>Device.height-32 then
    Begin
     Engine.WorldY:=Engine.WorldY+25*lagcount;
     needarrow:=2;
    End;

    if mx<10 then
    Begin
     Engine.WorldX:=Engine.WorldX-25*lagcount;
     if needarrow=1 then
      needarrow:=5
       else
        if needarrow=2 then
          needarrow:=6
           else
            needarrow:=3;
    End;
    if mx>Device.width-32 then
    Begin
     Engine.WorldX:=Engine.WorldX+25*lagcount;
     if needarrow=1 then
      needarrow:=7
       else
        if needarrow=2 then
          needarrow:=8
           else
            needarrow:=4;
    End;


      // flip back buffers
      Device.Flip();
end;

procedure TMainForm.ZoomIn;
begin
//
  GameScaleX:=GameScaleX*2;
  if GameScaleX>{maxWscale}1 then
    GameScaleX:={maxWScale}1
    else Begin
    // engine.WorldX:=engine.WorldX+Device.Width/2;
    // engine.WorldY:=engine.WorldY+Device.Height/2;
    End;

  GameScaleY:=GameScaleX;

end;

procedure TMainForm.ZoomOut;
begin
//
  GameScaleX:=GameScaleX/2;
  if GameScaleX<minWscale then
    GameScaleX:=minWScale
    else Begin
     //engine.WorldX:=engine.WorldX-Device.Width*Gamescalex/2;
     //engine.WorldY:=engine.WorldY-Device.Width/2;
    End;
      // cv

  if (mapsizex*100)*gamescaleX<Device.Width then Gamescalex:=GamescaleX*2;
  
  GameScaleY:=GameScaleX;

end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
if getstarted=false then Begin
if Device.Windowed=true then Begin
            top:=0;
            left:=0;
          //  width:=screen.Width;
          //  height:=screen.Height;
            borderstyle:=bsnone;
          //  Device.Width:=width;
          //  Device.Height:=Height;
    top:=(Screen.Height-1024)div 2;
    left:=(Screen.Width-1280)div 2;

    DownOffset:=0;
    width:=1280;
   { if screen.Height>=1024 then
    Height:=1024
     else
     Begin}
       Height:=Screen.Height;
       Device.Height:=Height;
       top:=0;
       DownOffset:=1024-Screen.Height;
   //  End;

     if screen.Width>=1280 then
     Begin
       Width:=Screen.Width;
       Device.Width:=Width;
       left:=0;

     End;

    GuiBase.Ctrl['Form1'].Top := GuiBase.Ctrl['Form1'].Top-DownOffset;
    GuiBase.Ctrl['Form2'].Top := GuiBase.Ctrl['Form2'].Top-DownOffset;
    GuiBase.Ctrl['Form3'].Top := GuiBase.Ctrl['Form3'].Top-DownOffset;
    GuiBase.Ctrl['Form5'].Top := GuiBase.Ctrl['Form5'].Top-DownOffset;

    GuiBase.Ctrl['Form4'].Top := GuiBase.Ctrl['Form4'].Top-DownOffset div 2;
    GuiBase.Ctrl['Form8'].Top := GuiBase.Ctrl['Form8'].Top-DownOffset div 2;
    GuiBase.Ctrl['Form9'].Top := GuiBase.Ctrl['Form9'].Top-DownOffset div 2;


    getstarted:=true;

    if (screen.Width<1280) then Begin
     showmessage('Для запуска редактора, разрешене экрана должно быть не меньше 1280x720!');
     close;
    End;

End else Loadsettings;
End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   MonitorFrequency, I: Integer;
   DC: THandle;
   Img1:TAsphyreImage;
begin
   ///  Screen.Cursor := crNone;
    choose:=1;

    borderstyle:=bsnone;

    DopImages:=TStringList.Create;
    DopAsdb:=TStringList.Create;
    HelpText:=TStringList.Create;

    Dir0:=GetCurrentDir;

    Savedialog.InitialDir:=Dir0+Mapdir;
    Opendialog.InitialDir:=Dir0+Mapdir;
    
    MiniBitMap:=TBitMap.Create;

    MapList:=TList.Create;

    NewMenu:=true;

     LoadSettings;
     // initialize Asphyre device
     if (not Device.Initialize()) then
     begin
          MessageDlg('Unable to initialize Asphyre device!', mtError, [mbOk], 0);
          Close();
          Exit;
     end;
     DC   := GetDC(Handle);

     Engine := TSpriteEngine.Create;
     Engine.Image := Images;
     Engine.Canvas := MyCanvas;

       // Create Particle Manager


      // add AsphyreGUI events
    AddEvents();

 


     LoadObjs;
     //LoadMapData('..\Data\TEST.map');
     CreateMap;


     ///MiniMap Create
     CreateMM;

     GameScaleX:=1;
     GameScaleY:=1;


    // Music.Songs.Items[0].Play;
end;

procedure TMainForm.DeviceRender(Sender: TObject);
var I:Integer;
begin
    // Keyboard.Update;
     LagCount:=Timer.Delta;

  if Disableback=false then
    BackGround;

  with MiniBitMap.Canvas do Begin
     Pen.Color:=clBlack;
     Brush.Color:=Pen.Color;
   Rectangle(0,0,300,300);
  End;

   Engine.Move(Timer.Delta);
   Engine.Dead;
   Engine.Draw;

  SETKA;

  Iface;

  Guibase.Draw;

  if showmm then    MiniMap;

   if (borderstyle<>bsnone)or(needarrow<>0) then
      Begin
         Screen.Cursor := crNone;
         programcursor;
      End else
             Screen.Cursor := crdefault;

   {  Fonts[0].TextOut('VisibleArea: '+IntToStr(Engine.VisibleArea.Left)+','+
     IntToStr(Engine.VisibleArea.top)+','+ IntToStr(Engine.VisibleArea.Right)+','+
     IntToStr(Engine.VisibleArea.Bottom),
     50 ,130, cRGB1(100, 200, 255));}
end;

procedure TMainForm.DrawLasers;
begin

 
{ Begin
  Mainform.Mycanvas.FrameRect(trunc(((x+128)-Engine.WorldX)*Engine.WorldScaleX),
  trunc(((y+128)-Engine.WorldY)*Engine.WorldScaleY),
  trunc((-strtoint(pars[2])-200)*Engine.WorldScaleX),
  trunc((strtoint(pars[1])+200)*Engine.WorldScaleY),
  crgb1(250,50,50,200),FxBlend);
 End;  }

end;

procedure TMainForm.Exit2Click(Sender: TObject);
begin
//
close;
end;

procedure TMainForm.ExitClick(Sender: TObject);
begin
//
savemenu:=true;
exitmenu:=true;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     // finalize Asphyre device
     MapList.Destroy;
     MiniBitMap.Destroy;
     HelpText.Destroy;
     Device.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState);
var
  Index: Integer;
begin
     // leave the program on ESC button
     if (Key = VK_ESCAPE) then Begin // Close();
           savemenu:=true;
           exitmenu:=true;
     End;

     if (Key = VK_F1) then
     Begin
        if Device.Windowed then
         if Mainform.BorderStyle=bsNone then
           Mainform.BorderStyle:=bsToolWindow
            else Mainform.BorderStyle:=bsNone;
     End;

     if (Key = VK_RETURN) then
     AcceptClick(self);
     { if Developer then
        console:=not(console);}

     // switch between full-screen and windowed mode on Alt + Enter
     if (Key = VK_RETURN) and (ssAlt in Shift) then
     begin
          // switch windowed mode
          Device.Windowed := not Device.Windowed;
          if Device.Windowed=false then Begin
            top:=0;
            left:=0;
            width:=screen.Width;
            height:=screen.Height;
            borderstyle:=bsnone;
            Device.Width:=width;
            Device.Height:=Height;
          End else LoadSettings;
          if Device.Windowed then Mainform.BorderStyle:=bsSizeable
           else Mainform.BorderStyle:=bsNone;
            width:=1280;
            Height:=1024;
            BorderStyle:=bsNone;
            top:=(Screen.Height-1024)div 2;
            left:=(Screen.Width-1280)div 2;
     end;
         // gfhfgh

    if key=vk_up then
     Engine.WorldY:=Engine.WorldY-50*lagcount;
    if key=vk_down then
     Engine.WorldY:=Engine.WorldY+50*lagcount;
    if key=vk_left then
     Engine.WorldX:=Engine.WorldX-50*lagcount;
    if key=vk_right then
     Engine.WorldX:=Engine.WorldX+50*lagcount;

end;


procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var MyList:TList;
  i,j:integer;
  Obj:Tobject;
  s:string;
begin

if Button=mbMiddle then Begin
  go:=true;
  xd:=x;
  yd:=y;
End;


if Button=mbRight then
  if my<Device.Height*resy-HudH then
    if (not(newmenu))then
     if not((mouseonmm(mx,my))) then
  Begin
    MyList:=TList.Create;
    mx:=x;
    my:=y;

    popmenu:=false;  
    MyList:=GetMapObjs(mx,my);

   with GuiBase.Taskbar do
   Begin
     TGuiListBox(Ctrl['ListBox2']).Items.Clear;

     If Mylist.count<>0 then
     Begin

      if MyList.Count=1 then Begin
        for I := 0 to MyList.Count - 1 do
          for j := 0 to TGuiListBox(Ctrl['ListBox']).Items.Count - 1 do
            if MyList.Items[i]=TGuiListBox(Ctrl['ListBox']).Items.Objects[j] then
              Begin
                TGuiListBox(Ctrl['ListBox']).ItemIndex:=j;
                TGuiListBox(Ctrl['ListBox']).OnChange(Sender);
              End;

      End else
        for I := 0 to MyList.Count - 1 do
          for j := 0 to TGuiListBox(Ctrl['ListBox']).Items.Count - 1 do
            if MyList.Items[i]=TGuiListBox(Ctrl['ListBox']).Items.Objects[j] then
              Begin
                Obj:=TGuiListBox(Ctrl['ListBox']).Items.Objects[j];
                s:=TGuiListBox(Ctrl['ListBox']).Items[j];
                TGuiListBox(Ctrl['ListBox2']).Items.AddObject(s,obj)
              End;
     End;

   End;

   if mylist.Count>1 then
    popmenu:=true;

   if mx>Device.Width-240 then mx:=Device.Width-240;
   GuiBase.Ctrl['Form7'].Left:= mx;
   GuiBase.Ctrl['Form7'].Top := my;
  ///
    MyList.Destroy;
End;

if Button=mbLeft then Begin


  if my<Device.Height*resy-HudH then
  Begin
    mx:=x;
    my:=y;
    if (newmenu=false)and(popmenu=false)and(exitmenu=false)and(savemenu=false) then
     if not((mouseonmm(mx,my))) then CreateMapObj;
  End;
End;

end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
mx:=x;
my:=y;
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
go:=false;
end;



procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if wheeldelta>0 then ZoomIn;
  if wheeldelta<0 then ZoomOut
end;

procedure TMainForm.Iface;
var i:integer;
    Mycolor:cardinal;
    A:TasphyreImage;
begin
///
   MyColor:=crgb1(0,0,0,185);
   MyCanvas.Rectangle(0, Device.Height-HudH, Device.Width,HudH,
                Mycolor,MyColor,FxBlend);

 GuiBase.Ctrl['Form1'].Left:= Device.Width-380;
 GuiBase.Ctrl['Form1'].Top := Device.Height-HudH;

 GuiBase.Ctrl['Form2'].Left:= 8;
 GuiBase.Ctrl['Form2'].Top := Device.Height-HudH+100;

 GuiBase.Ctrl['Form3'].Left:= Device.Width-380*2;
 GuiBase.Ctrl['Form3'].Top := Device.Height-HudH;

 GuiBase.Ctrl['Form5'].Left:= 8;
 GuiBase.Ctrl['Form5'].Top := Device.Height-HudH;

 GuiBase.Ctrl['Form4'].Visible:=false;

 if popmenu=true then GuiBase.Ctrl['Form7'].Visible:=true
     else GuiBase.Ctrl['Form7'].Visible:=false;

 if savemenu=true then GuiBase.Ctrl['Form8'].Visible:=true
     else
     Begin
      GuiBase.Ctrl['Form8'].Visible:=false;

      if exitmenu=true then GuiBase.Ctrl['Form9'].Visible:=true
         else
         Begin
          GuiBase.Ctrl['Form9'].Visible:=false;
          if (newmenu) then Begin
            GuiBase.Ctrl['Form4'].Visible:=true;
            GuiBase.Ctrl['Form1'].Enabled:=false;
            GuiBase.Ctrl['Form2'].Enabled:=false;
            GuiBase.Ctrl['Form3'].Enabled:=false;
            GuiBase.Ctrl['Form5'].Enabled:=false;
          End else
          Begin
            GuiBase.Ctrl['Form4'].Visible:=false;
            GuiBase.Ctrl['Form1'].Enabled:=true;
            GuiBase.Ctrl['Form2'].Enabled:=true;
            GuiBase.Ctrl['Form3'].Enabled:=true;
            GuiBase.Ctrl['Form5'].Enabled:=true;
          End;

         End;

    End;



 with GuiBase.Taskbar do
 if TGuiListBox(Ctrl['ListBox']).ItemIndex<>-1 then
  GuiBase.Ctrl['Form3'].Visible:=true
   else   GuiBase.Ctrl['Form3'].Visible:=false;

 with GuiBase.Taskbar do
  if TGuiCheckBox(Ctrl['Showmm']).Checked then Begin
    ShowMM:=true;
    GuiBase.Ctrl['Form6'].Visible:=true;
  End else Begin
     GuiBase.Ctrl['Form6'].Visible:=false;
     Showmm:=false;
  End;

   with GuiBase.Taskbar do Begin
      showgrid:= TGuiCheckBox(Ctrl['ShowGrid']).Checked;
      TGuiLabel(Ctrl['Fps']).Text:='FPS: '+IntToStr(Timer.FrameRate);
   End;


  with GuiBase do
  begin
     TGuiForm(Ctrl['Form2']).Caption:='Объекты (стр. '+inttostr(page+1)+')';

   for I := 1 to 14 do
    Begin
      if choose-page*14=i then
       TGuiButton(Ctrl['Obj'+inttostr(i)]).Border.Color1(crgb1(255,55,55,255))
        else  TGuiButton(Ctrl['Obj'+inttostr(i)]).Border.Color1(crgb1(125,155,183,255));

      if page*14+i<ObjCount2+1 then Begin
        TGuiButton(Ctrl['Obj'+inttostr(i)]).Visible:=true;
        TGuiButton(Ctrl['Obj'+inttostr(i)]).ImageIndex:= images.Find(Objs2[page*14+i-1].Img);
        if images.Find(Objs2[page*14+i-1].Img)=-1 then
        Begin
          TGuiButton(Ctrl['Obj'+inttostr(i)]).ImageIndex:= images.Find('noasdb');
          TGuiButton(Ctrl['Obj'+inttostr(i)]).Enabled:=false;
        End else TGuiButton(Ctrl['Obj'+inttostr(i)]).Enabled:=true;

        A:=Images[TGuiButton(Ctrl['Obj'+inttostr(i)]).ImageIndex];
        if A.Size.x>A.Size.y then
        Begin
          TGuiButton(Ctrl['Obj'+inttostr(i)]).GlyphWidth:=40;
          TGuiButton(Ctrl['Obj'+inttostr(i)]).GlyphHeight:=round(40*A.Size.y/A.Size.X);
        End else
        Begin
          TGuiButton(Ctrl['Obj'+inttostr(i)]).GlyphHeight:=40;
          TGuiButton(Ctrl['Obj'+inttostr(i)]).GlyphWidth:=round(40*A.Size.X/A.Size.Y);
        End;
                        
      end else TGuiButton(Ctrl['Obj'+inttostr(i)]).Visible:=false;
    End;

  end;



end;

procedure TMainForm.Killhelp(Sender: TObject);
begin
   GuiBase.Ctrl['Form10'].Hide;
    with GuiBase do
      TGuiCheckBox(Ctrl['HelpBox']).Checked:=false;
end;

{ TLaser }

procedure TLaser.Draw;
begin
  inherited;
if Showmm then
if alpha>100 then
Begin

with MiniBitMap.Canvas do
 Begin
 Pen.Color:=rgb(Redw[LasColor],Greenw[LasColor],Bluew[LasColor]);

 MoveTo(MM_X+round(x*mmscale) div 100, MM_Y+ round(y*mmscale) div 100);
 if direction mod 2<>0 then
  LineTo(MM_X+round(x*mmscale+(imagewidth)*ScaleX*mmscale) div 100,MM_Y+ round(y*mmscale) div 100)
    else
     LineTo(MM_X+round(x*mmscale) div 100,MM_Y+round(y*mmscale+(imageHeight)*ScaleY*mmscale) div 100)

 end;
End;

end;

procedure TLaser.Move(const MoveCount: Single);
begin
  inherited;
 if showlas=false then dead;

end;

end.

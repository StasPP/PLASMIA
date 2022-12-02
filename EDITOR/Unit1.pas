/// This game is powered by ASPHYRE EXTRERME by AfterWrap
/// Code by: ÿ≈¬◊”  —“¿Õ—À¿¬
unit Unit1;

interface

uses
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, Asphyre2D, AsphyreCanvas, AsphyreSubsc, AsphyreDevices,
     AsphyreTimers, AsphyreDb, AsphyreImages, AsphyreFonts, AsphyreDef, AsphyreSprite,
     AsphyreKeyboard, SoundSystem, AsphyreMouse, Xparticles;

type

     TAIState = (Stop, Hunt, Runaway, Die);
     TParType = (pFire, pCloud, pWarer, pFog, pTrasser, pExplode);
     TArmoType = (aSin, aTrasser, aSimple, aNone);
     TTileAttribute=(taNormal, taPlatform, taBlock, taTreasure, taSlope);
     TEffectType=(eShine,eFlame,eLamp);

     TMapRec = record
          X, Y: Integer;
          ImageName: string[10];
     end;

     TWeapons = record
          Count: Integer;
          CurrentTime:real;
     end;

     TTile = class(TAnimatedSprite)
     private
          FCollideRight: Integer;
          FCollideBottom: Integer;
     public
          ID: Integer;
          procedure Move(const MoveCount: Single); override;
     end;

     TEnemy=class(TAnimatedSprite)
     private
          FCollideRight: Integer;
          FCollideBottom: Integer;
          AIState:TAIState;
          MCount:Single;
     public
          procedure Move(const MoveCount: Single); override;
          procedure OnCollision(const Sprite: TSprite); override;
     end;

     TArmoSprite=class(TAnimatedSprite)
     private
          ArmoType:TarmoType;
          VeloX,VeloY,L,x0,y0,t,a:real;
          MaxL,num:integer;
     public
          procedure Move(const MoveCount: Single); override;
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;

     TParticle=class(TParticleSprite)
     private
        x0,y0:integer;
        AllLife:real;
        ParType:TParType;
     public
          procedure Move(const MoveCount: Single); override;
     end;

     TEffectSprite=class(TAnimatedSprite)
     private
          EffectType:TEffectType;
          x0,y0,_r,x1,y1,t,alf0,alf1,Eticks:real;
          Cred,CGreen,CBlue,CAlpha:real;
          EffName:string;
          procedure CRGB(_R,_G,_B,_A:Integer; MCount: Single);
     public
          procedure Move(const MoveCount: Single); override;
     end;

     TPlayer=class(TAnimatedSprite)
     private
       _x0,_y0:single;
       PAlf,oalf:double;
       GunPos:array[1..2] of TPoint;
       RAGunPos:array[1..2,1..2] of Real;  ///// alf0 Ë R ‰Îˇ „Ì∏Á‰ ÔÛ¯ÂÍ

       Childs:TList;
          procedure Turn(MCount: Single);
          procedure Explode;
          function GetA0(dx,dy:integer):real;
     public
          procedure Move(const MoveCount: Single); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;

          TMainForm = class(TForm)
          Fonts: TAsphyreFonts;
          Images: TAsphyreImages;
          Device: TAsphyreDevice;
          MyCanvas: TAsphyreCanvas;
          AGraphics: TASDb;
          Timer: TAsphyreTimer;
          Keyboard: TAsphyreKeyboard;
          SoundSystem1: TSoundSystem;
          Mouse: TAsphyreMouse;
          AFonts: TASDb;
          ALoader: TASDb;

          procedure DeviceInitialize(Sender: TObject; var Success: boolean);
          procedure DeviceRender(Sender: TObject);
          procedure ShowDevConsole;

          procedure BackGround;
          procedure Hud;
          procedure PostFilter;

          procedure ZoomIn;
          procedure ZoomOut;
          procedure ZoomMiddle;

          procedure TimerTimer(Sender: TObject);
          procedure MouseUpdate;

          procedure GameProcess(Mdelta:real);
          procedure GameInit;

          procedure FormCreate(Sender: TObject);
          procedure FormDestroy(Sender: TObject);
          procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerProcess(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

      private
          Fs: TFileStream;
          FileSize: Integer;
          MapData: array of TMapRec;
          Engine: TSpriteEngine;
          Layer1Pos: Single;
          Layer2Pos: Single;
          LeftEdge, RightEdge: Integer;

          procedure LoadSettings;
          procedure LoadMapData(FileName:string);
          procedure CreateMap;
     public
          { Public declarations }
     end;

const
  minWScale=0.5;
  maxWScale=2;
  normWScale=1.0;

  //// ÷¬≈“¿
  RedW:array[1..9] of Integer=(255,255,255,25,25,25,155,255,0);
  GreenW:array[1..9] of Integer=(25,125,255,255,225,25,25,255,0);
  BlueW:array[1..9] of Integer=(25,25,25,25,255,255,255,255,0);
  AlphaW:array[1..9] of Integer=(255,255,255,255,255,255,255,255,0);

  /// œ”ÿ », “»œ€ “–¿≈ “Œ–»… œ”À‹, — Œ–Œ—“» œ”À‹, ƒ¿À‹ÕŒ—“» œ”À‹
  WReloadTimes:array[1..10] of Integer=(20,20,20,20,20,20,20,40,40,40);
  WSpeed:array[1..10] of real=(20,20,20,20,20,20,20,10,10,10);
  WLMax:array[1..10] of Integer=(1500,1500,1500,1500,1500,1500,1500,1000,1000,1000);
  WArmoTypes:array[1..10] of Tarmotype=(aTrasser, aTrasser, aTrasser, aTrasser,
                                        aTrasser, aTrasser, aTrasser, aSimple,
                                        aNone, aNone);
var
     MainForm: TMainForm;
     UserRefreshRate: Integer;

    //// Speed
     LagCount:real;

    //// MODE
     Console:Boolean;
     Developer:Boolean;

    ///Console
     cony:real;

    /// POST-FILTER
     MotionBlur:Boolean;
     currentmot:integer;
     FadeIn:real;  ///«‡ÚÂÏÌÂÌËÂ ˝Í‡Ì‡.

     ///◊‡ÒÚËˆ˚
     ParMgr: TXParticleManager;
     Ticks: real = 0;
     EffList: array of TXParticleSystem;

     //// »„ÓÍ
     Health:real;
     CurrentWeapon,AltWeapon:integer;
     CanChangeWeapon:Boolean;
     Weapons:array[1..10] of Tweapons;
     WaitShoot,GameOver:boolean;


     //// Ã˚¯¸
     mx,my,mspd,alf,RV:double;

     //// Ã‡Ò¯Ú‡·
     ResolutionScaleX, ResolutionScaleY, GameScaleX,GameScaleY:real;
     widescreen:byte;
     virtualH,virtualW:integer;

     ///‘ÓÌ
     layerX,layery:real;

     //// DeBug
     Dop1,Dop2:real;

implementation

{$R *.dfm}
function GetNumScrollLines: Integer;
 begin
   SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Result, 0);

end;

procedure FireEff(Posx,PosY:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to 10 do

      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1.0;
               ScaleY := 1.0;

               X := PosX + Random(20)-10-imageWidth/2;
               Y := PosY + Random(20)-10-imageHeight/2;
               Z:=random(5)-2;

               LifeTime := 15;
               Decay := 1.5;

               Red:=255;
               Green:=50;
               Blue:=0;

               DrawFx := fxAdd;
               UpdateSpeed := 0.5;
               VelocityX := 0;
               VelocityY := 0;
               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               visible:=false;
               alllife:=lifetime;
           end;
End;

procedure SparkEff(Posx,PosY:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to 15 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles2.image';
               ScaleX := 1.0;
               ScaleY := 1.0;

               X := PosX-imageWidth/2;
               Y := PosY-imageWidth/2;
               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=150;
               Blue:=0;

               LifeTime := 25;
               VelocityX := (random- 0.5)*5;
               VelocityY := (random- 0.5)*5;

               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               visible:=false;
               alllife:=lifetime;
           end;
End;

procedure ExplodeEff(Posx,PosY:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to 90 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 2;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 1.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=50;
               Blue:=10;

               LifeTime := 50+random(50);
               VelocityX := cos(i/12*pi)*(random(5)+10);
               VelocityY := sin(i/12*pi)*(random(5)+10);

               X := PosX-imageWidth/2*scaleX;
               Y := PosY-imageWidth/2*scaley;

               AccelX :=-0.1*cos(i/180*pi);
               AccelY :=-0.1*sin(i/180*pi);

               ParType:=PType;

               visible:=false;
               alllife:=lifetime;
           end;

End;

procedure TrasserEff(Posx,PosY:real;_r,_g,_b,kind:integer; PType:TParType);
var i:integer;
Begin

     for i := 1 to 5 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1.0;
               ScaleY := 1.0;

               X := PosX + Random(20)-10-imageWidth/2;
               Y := PosY + Random(20)-10-imageHeight/2;
               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;
               Red:=_r;
               Green:=_g;
               Blue:=_b;

               if kind=1 then
                Begin
                  LifeTime := 50;
                  VelocityX := random- 0.15;
                  VelocityY := random- 0.15;
                End
                 else

                  if kind=2 then
                   Begin
                    LifeTime := 150;
                    VelocityX := random- 0.15;
                    VelocityY := random- 0.15;
                    AnimStart:=1;
                   End
                    else
                  if kind=3 then
                   Begin
                    VelocityX := random- 0.15;
                    VelocityY := random- 0.15;
                   End
                    else

                      Begin
                        LifeTime := 150;
                        VelocityX := 0;
                        VelocityY := 0;
                        AnimStart:=0;
                      End;

               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               visible:=false;
               alllife:=lifetime;
           end;
End;

procedure TMainForm.LoadMapData(FileName: string);
begin
    Fs := TFileStream.Create(ExtractFilePath(Application.ExeName) + FileName, fmOpenRead);
     Fs.ReadBuffer(FileSize, SizeOf(FileSize));
     SetLength(MapData, FileSize);
     Fs.ReadBuffer(MapData[0], SizeOf(TMapRec) * FileSize);
     Fs.Destroy;
end;

procedure TMainForm.LoadSettings;

  const
  n=10;
  Commands:array[1..n] of String=('ResolutionX: ','ResolutionY: ','BitCount: ',
  'Windowed: ','AA: ','MouseSpeed: ','VSync: ','Console: ','BigWindow: ',
  'WideScreen: ');
  // Õ¿—“–Œ… »!!!

  var s:TstringList;
  i,j:integer;
  par:String;
begin

    s:=TstringList.Create;
    s.LoadFromFile('Data\Config.cfg');

    //// œŒ ”ÃŒÀ◊¿Õ»ﬁ
       Device.Width:=1024;
       Device.Height:=768;
       Device.BitDepth:=bdHigh;
       Developer:=false;
       Device.Vsync:=false;
       mspd:=2;
       Device.Windowed:=false;
       Widescreen:=0;

    ///// «¿√–”« ¿
    for I := 0 to s.Count - 1 do
      Begin
        for j := 1 to n do
          Begin
            if Pos(commands[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(commands[j]));
               case j of

                  1:{ResolutionX:} Begin
                     Device.Width:=Strtoint(par);
                  End;
                  2:{ResolutionY:} Begin
                     Device.Height:=Strtoint(par);
                  End;
                  3:{BitCount:} Begin
                     if par='32' then
                       Device.BitDepth:=bdHigh
                         else  Device.BitDepth:=bdLow;
                  End;
                  4:{Windowed:} Begin
                    if par='y' then
                      Device.Windowed:=true
                       else Device.Windowed:=false;
                  End;
                  5:{AA:} Begin
                     if par='y' then
                      MyCanvas.Antialias:=true
                       else MyCanvas.Antialias:=false;
                  End;
                  6:{MouseSpeed:} Begin
                    mspd:=StrToInt(par);
                  End;
                  7:{VSync:} Begin
                     if par='y' then
                      Device.VSync:=true
                       else Device.Vsync:=false;
                  End;
                  8:{Console:} Begin
                     if par='y' then
                      Developer:=true
                       else Developer:=false;
                  End;
                  9:{BigWindow:} Begin
                     if par='y' then Begin
                       ClientWidth:=1024;
                       ClientHeight:=768;
                     End
                       else
                       Begin
                          ClientWidth:=800;
                          ClientHeight:=600;
                       End;
                  End;
                  10:{WideScreen:} Begin
                     if par='3:4' then WideScreen:=0;
                     if par='16:10' then WideScreen:=1;
                     if par='16:9' then WideScreen:=2;
                     if par='LCD' then WideScreen:=3;
                  End;

               end;
             End;
          End;
      End;

    s.destroy;
end;

procedure TMainForm.MouseUpdate;
var h,w,i:integer;
begin
     Mouse.Update;

     //// X,Y
     Mx:=mx+Mouse.Displace.X*mspd;
     My:=my+Mouse.Displace.y*mspd;
     if mx<0 then mx:=0;
     if mx>Device.Width then mx:=Device.Width;
     if my<0 then my:=0;
     if my>Device.Height then my:=Device.Height;

     /// ALF
     h:=Mainform.Device.Height div 2;
     w:=Mainform.Device.Width div 2;
     if (MX-w)<>0 then
      if (MX-w)>0 then Begin
         alf:=arctan((-MY+h)/(MX-w));
      End
         else  Begin
           alf:=pi - arctan((MY-h)/(MX-w));
         End;
     if alf<0 then alf:=alf+2*pi;

     //// RV
     RV:=SQRT(SQR(MX-w)+SQR(MY-h));
     RV:=RV/Engine.WorldScaleX;

     //////// WEAPON (—“¿–¿ﬂ ÃŒƒ≈À‹ ”œ–¿¬À≈Õ»ﬂ)
    { if Mouse.MouseWheel>0 then
          dec(CurrentWeapon)
          else  if Mouse.MouseWheel<0 then
             inc(CurrentWeapon);
     if CurrentWeapon>9 then CurrentWeapon:=1;
     if CurrentWeapon<=0 then CurrentWeapon:=9;
     dop1:=CurrentWeapon;  }

     //////// SHOT
      if Mouse.Pressed[0] then
        WaitShoot:=true;

     //////// Ã≈Õﬂ≈Ã œ”ÿ ”

    if Mouse.Released[1] then CanChangeWeapon:=true;
     if CanChangeWeapon=True then
      if Mouse.Pressed[1] then Begin
       i:=CurrentWeapon;
       CurrentWeapon:=AltWeapon;
       AltWeapon:=i;
       CanChangeWeapon:=false;
      End;
     if CurrentWeapon>9 then CurrentWeapon:=1;
     if CurrentWeapon<=0 then CurrentWeapon:=9;

     ///SCALE
      if Mouse.Pressed[3] then Begin
         ZoomIn;
      End else Begin
         if GamescaleX<>normWScale then
           ZoomMiddle;
      End;

end;

procedure TMainForm.PostFilter;
begin
//////
{   if MotionBlur=True then Begin

         for I := 0 to currentmot do
           MyCanvas.Draw(Images.Image['Motion'+inttostr(i)], 0, 0, 0, fxBlend);

   End;}
end;

procedure TMainForm.ShowDevConsole;
var i:integer;
    Mycolor:cardinal;
begin
     if console then
     Begin
      if cony<250 then
        cony:=cony+lagcount*5
      else
        cony:=250
     end else
       Begin
          if cony>0 then
            cony:=cony-lagcount*5
          else
            cony:=0;
       End;

     if cony<0 then cony:=0;
     if cony>250 then cony:=250;

     MyColor:=crgb1(0,0,0,155);
     if cony<>0 then
      MyCanvas.Rectangle(0, 0, trunc(VirtualW*ResolutionScaleX),trunc(cony*ResolutionScaleY),
                Mycolor,MyColor,FxBlend);

     Fonts[1].Scale:=ResolutionScaleX;
     Fonts[1].TextOut('FPS: '+IntToStr(Timer.FrameRate)+' // DELTA: '+FloatToStr(Timer.delta*10),
        50 *ResolutionScaleX,(10-250+cony )*ResolutionScaleY, cRGB1(255, 255, 255));
     Fonts[1].TextOut('WORLD X: '+IntToStr(trunc(Engine.WorldX))+' Y: '+IntToStr(trunc(Engine.WorldY))
        +' Scale: '+FloatToStr(GameScaleX),50 *ResolutionScaleX, (60-250+cony )*ResolutionScaleY, cRGB1(250, 250, 55));
     Fonts[1].TextOut('ALFA: '+IntToStr(trunc(alf*180/pi)) ,
        50 *ResolutionScaleX, (110-250+cony )*ResolutionScaleY, cRGB1(200, 200, 255));
     Fonts[1].TextOut('VisibleArea: '+IntToStr(Engine.VisibleArea.Left)+','+
     IntToStr(Engine.VisibleArea.top)+','+ IntToStr(Engine.VisibleArea.Right)+','+
     IntToStr(Engine.VisibleArea.Bottom),
     50 *ResolutionScaleX,(160-250+cony )*ResolutionScaleY, cRGB1(100, 200, 255));

      Fonts[1].TextOut('Sprites: ' + IntToStr(Engine.Count) ,
        50 *ResolutionScaleX, (210-250+cony )*ResolutionScaleY, cRGB1(200, 100, 155));

      Fonts[1].TextOut('dop: ' + IntToStr(round(dop1)) ,
        350 *ResolutionScaleX,(210-250+cony )*ResolutionScaleY, cRGB1(200, 100, 155));

      Fonts[1].TextOut('Scroll: ' + IntToStr(GetNumScrollLines) ,
        700 *ResolutionScaleX,(210-250+cony )*ResolutionScaleY, cRGB1(200, 100, 155));
end;

procedure TMainForm.BackGround;
var i,j:integer;
  x0,y0:double;
begin
     MyCanvas.DrawStretch(Images.Image['fon_1'], 0, 0, 0, Device.Width, Device.Height, false,false, clWhite4, fxNone);

     x0:=-layerX*0.25;
     y0:=-layerY*0.25;
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

     x0:=-layerX*0.35;
     y0:=-layerY*0.35;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_2'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);

     x0:=-layerX*0.5;
     y0:=-layerY*0.5;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_3'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);

     {MyCanvas.DrawPortion(Images.Image['fon_3'], 0, 0, 0, Round(Engine.WorldX*0.5),
     Round(Engine.WorldY*0.5),Device.Width, Device.Height,
     2,2,false,false,false, clWhite4, fxNone);}
    { MyCanvas.DrawPortion(Images.Image['back1'], 0, 0, 0, Round(Engine.WorldX),
     Round(Engine.WorldY),Device.Width , Device.Height, clWhite4, fxBlend);}
  //   MyCanvas.DrawPortion(Images.Image['back1'], 0, 0, 520, Round(Engine.WorldX*0.5) - 440, Round(Engine.WorldY*0.5), Round(Engine.WorldX*0.5)+640, Round(Engine.WorldY*0.5)+447, clWhite4, fxBlend);
end;

procedure TMainForm.CreateMap;
var
   i:Integer;
begin

          with  TPlayer.Create(Engine) do
               begin
                    ImageName := 'Player';
                    X := 200;
                    Y := 200;
                    AnimCount:=73;
                    AnimSpeed:=0;
                    CollideMethod := cmRect;
                    DoCollision := True;
               end;

     for i := FileSize - 1 downto 0 do
     begin
          if (MapData[i].ImageName<>'Enemy1') and  (MapData[i].ImageName<>'Enemy2') and (MapData[i].ImageName<>'Enemy3') then
          begin
               with  TTile.Create(Engine) do
               begin
                    ImageName := MapData[i].ImageName;
                    X := MapData[i].X - 540;//-MapData[i].X/48*2;
                    Y := MapData[i].Y - 150;//-MapData[i].Y/48*2;
                    CollideMethod := cmRect;
                    DoCollision := True;
                    FCollideRight:=PatternWidth;
                    FCollideBottom:=PatternHeight;
               end;
          end
          else
         //create Enemy
          begin
               with TEnemy.Create(Engine) do
               begin
                    ImageName := MapData[i].ImageName;
                    X := MapData[i].X - 540;
                    Y := MapData[i].Y - 150;
                    DoCollision := True;
                    CollideMethod := cmRect;
                    FCollideRight:=PatternWidth;
                    FCollideBottom:=PatternHeight;
                   // State:=Walkleft;
                   // JumpState:=jsfalling;
                    AnimCount:= PatternCount;
              end;
         end;
    end;
end;

procedure TTile.Move;
begin
     inherited;
     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + FCollideRight),
                    Round(Y + FCollideBottom));

     if ImageName='Spring1' then
     CollideRect := Rect(Round(X),
                    Round(Y+25),
                    Round(X + FCollideRight),
                    Round(Y + FCollideBottom));
end;


procedure TEnemy.Move(const MoveCount: Single);
begin
     inherited;

     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + Self.FCollideRight),
                    Round(Y + Self.FCollideBottom));

                     SetAnim(ImageName,0,AnimCount, 0.2, True, False, True);
     if (AIState <> Die) then
    { begin
          case AIState of
               Hunt:
               begin
                     X:=X-1.5*MoveCount;
                         SetAnim(ImageName,0,AnimCount, 0.2, True, False, True);

               end;
               WalkRight:
               begin
                    X:=X+1.5*MoveCount;
                    SetAnim(ImageName,0,AnimCount, 0.2, True, True, True);


               end;
          end;
     end;     }


    if ImageName='Enemy3' then AnimSpeed:=0.075;
    if Y> 600 then Dead;
    MCount:=MoveCount;
    Collision;
end;

procedure TEnemy.OnCollision(const Sprite: TSprite);
begin
  //
end;

procedure TMainForm.DeviceInitialize(Sender: TObject; var Success: boolean);
begin
     // load all images from ASDb
     Success := Images.LoadFromASDb(AGraphics);

     // if succeeded with images, load all fonts too
     if (Success) then
          Success := Fonts.LoadFromASDb(AFonts);

     // start rendering only if succeeded loading stuff
     Timer.Enabled := Success;

     if widescreen = 0  then Begin
      /// 3:4
         VirtualW:=1600;
         VirtualH:=1200;
     End else
     if widescreen = 1  then Begin
      /// 16:10
         VirtualW:=1600;
         VirtualH:=90;
     End else
     if widescreen = 2  then Begin
      /// 16:9
         VirtualW:=1680;
         VirtualH:=1050;
     End else
     if widescreen = 3  then Begin
      /// 5:4
         VirtualW:=1600;
         VirtualH:=1280;
     End;
         ResolutionScaleX:=Device.Width/VirtualW;
         ResolutionScaleY:=Device.Height/VirtualH;
end;

procedure TMainForm.TimerProcess(Sender: TObject);
var i,count:integer;
VecMov:TPoint2;
begin

{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

 { ParMgr.Update(Timer.Delta/10);


  VecMov.x:=0;
  VecMov.y:=10;
  // "Comet Fall"
  Count := Length(EffList);
  for i := 0 to Count - 1 do
  begin
    if (EffList[i] <> nil) then
    begin
      // Move comet
      EffList[i].Move(VecMov);

      // is comet hit ground
      if (EffList[i].Position.y > 600) then
      begin
        // Launch explotion
        ParMgr.Launch('GroundExplode_inner2.pss', EffList[i].Position);
        ParMgr.Launch('GroundExplode_inner.pss', EffList[i].Position);
        ParMgr.Launch('GroundExplode.pss', EffList[i].Position);

        // Stop particle emission
        EffList[i].Stop();

        // Remove comet from list
        EffList[i] := nil;
        EffList[i] := EffList[Count - 1];
        SetLength(EffList, Count - 1);
      end;
    end;
  end;   }

{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{œ≈–≈ƒ≈À¿“‹!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

 // Ticks:=Ticks+Timer.Delta;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
     // render the scene
     {Device.Render(RGB(55, 140, 210), True);}

     ///// Ã¿—ÿ“¿¡€
      Engine.WorldScaleX:=GameScaleX*ResolutionScaleX;
      Engine.WorldScaleY:=GameScaleY*ResolutionScaleY;

      Engine.VisibleArea:= Rect(round(-Device.Height/Engine.WorldScaleX), round(-Device.Height/Engine.WorldScaleY),
      round((Device.Width*2)/Engine.WorldScaleX), round((Device.Height*2)/Engine.WorldScaleY));

      Device.Render(RGB(0, 0, 0), True);

      // G
       GameProcess(Timer.Delta);
      // do calculations while Direct3D is still rendering
      Timer.Process();


      // flip back buffers
      Device.Flip();
end;

procedure TMainForm.ZoomIn;
begin
//
  GameScaleX:=GameScaleX+0.01*Lagcount;
  if GameScaleX>maxWscale then
    GameScaleX:=maxWScale;
  GameScaleY:=GameScaleX;
end;

procedure TMainForm.ZoomMiddle;
var step:real;
begin
//
  step:=0.01*Lagcount;
  if (GameScaleX<normWscale-step) then
    GameScaleX:=GameScaleX+Step
      else
        if (GameScaleX>normWscale+step) then
          GameScaleX:=GameScaleX-Step
          else
            GameScaleX:=normWScale;
            
  GameScaleY:=GameScaleX;
end;

procedure TMainForm.ZoomOut;
begin
//
  GameScaleX:=GameScaleX+0.01*Lagcount;
  if GameScaleX>normWscale then
    GameScaleX:=normWScale;
  GameScaleY:=GameScaleX;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   MonitorFrequency, I: Integer;
   DC: THandle;
   Img1:TAsphyreImage;
begin
     Screen.Cursor := crNone;

     LoadSettings;
     GameInit;
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
      ParMgr := TXParticleManager.Create();
      ParMgr.Canvas  := MyCanvas;
      ParMgr.Texture := Images.Image['particles.image'];
      ALoader.FileName:='Data\Graphics\Particles.asdb';
      ALoader.Update;
      ParMgr.AddAllFromASDb(ALoader);

      SetLength(EffList, 0);

     LoadMapData('Data\TEST.map');
     CreateMap;

     ///NewGame

     GameScaleX:=1;
     GameScaleY:=1;

    // Music.Songs.Items[0].Play;
end;

procedure TMainForm.DeviceRender(Sender: TObject);
var I:Integer;
begin
     Keyboard.Update;
     LagCount:=Timer.Delta;
     MouseUpdate;

  BackGround;

     Engine.Move(Timer.Delta);
     Engine.Dead;
     Engine.Draw;
     

  ParMgr.Render(-round(Engine.WorldX),-round(Engine.WorldY));

  PostFilter;

  Hud;
  if (Developer) then
   if (cony>0)or(console) then
    ShowDevConsole;

  


end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     // finalize Asphyre device
     Device.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState);
var
  Index: Integer;
begin
     // leave the program on ESC button
     if (Key = VK_ESCAPE) then Close();


     if (Key = VK_RETURN) then
      if Developer then
        console:=not(console);

     // switch between full-screen and windowed mode on Alt + Enter
     if (Key = VK_RETURN) and (ssAlt in Shift) then
     begin
          // switch windowed mode
          Device.Windowed := not Device.Windowed;
          if Device.Windowed then Mainform.BorderStyle:=bsSizeable
           else Mainform.BorderStyle:=bsNone;
     end;
         // gfhfgh

     if (Key = VK_SPACE) then Begin
       // inc(CurrentWeapon);
      if CurrentWeapon>=10 then CurrentWeapon:=1;
               health:=health-5;
     End;

{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
  {   if (Key = VK_SPACE) and (Ticks > 25) then
  begin
    // Increase comet list capacity and add new comet
    Index := Length(EffList);
    SetLength(EffList, Index + 1);
    EffList[Index] := ParMgr.Launch('FireBall.pss', Point2(250 + Random(600), 0));

    Ticks := 0;
  end;
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
end;


procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
showmessage(inttostr(wheelDelta))
//SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Result, 0);

end;

procedure TMainForm.GameInit;
begin
///

  ///»ÌËˆË‡ÎËÁËÛ˛ ”Ô‡‚ÎÂÌËÂ
  Currentweapon:=1;
  AltWeapon:=6;
  CanChangeWeapon:=true;
  Health:=100;
  GameOver:=false;
  
  Weapons[1].Count:=20;
  Weapons[6].Count:=35;
end;

procedure TMainForm.GameProcess(Mdelta: real);
begin

 /// œ”ÿ »
    if Weapons[currentweapon].CurrentTime<WReloadTimes[currentweapon] then
        Weapons[currentweapon].CurrentTime:= Weapons[currentweapon].CurrentTime+ MDelta;



end;

procedure TMainForm.Hud;
var mycolor:Cardinal;
begin

  With MyCanvas do Begin

    /// ‡ÏÍ‡
    MyColor:=crgb1(0,0,0,215);
    Rectangle(0,0,round(1600*ResolutionScaleX),round(50*ResolutionScaleY),Mycolor,MyColor,FxBlend);
    Rectangle(0,round((VirtualH-50)*ResolutionScaleY),round(1600*ResolutionScaleX),round(50*ResolutionScaleY),Mycolor,MyColor,FxBlend);

    DrawStretch(Images.Image['Hud_0'],0, trunc(500*ResolutionScaleX),
      trunc(5*ResolutionScaleY), trunc(550*ResolutionScaleX),
      trunc(55*ResolutionScaleY),false,false,
      cRGB4(redw[currentWeapon] div 2,Greenw[currentWeapon]div 2
      ,Bluew[currentWeapon] div 2,250),fxBlend);

    ///
    Fonts[1].Scale:=ResolutionScaleX;
    Fonts[1].TextOut(IntToStr(Weapons[currentweapon].Count),
      500 *ResolutionScaleX, 10 *ResolutionScaleY, cRGB1(255, 255, 255));

    //  ”–—Œ–
    DrawStretch(Images.Image['Cursor'],0, trunc(Mx-15*ResolutionScaleX),
      trunc(My-15*ResolutionScaleY), trunc(Mx+15*ResolutionScaleX),
      trunc(My+15*ResolutionScaleY),false,false,
      cRGB4(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],250),
      fxBlend);
  End;


  // MyCanvas.Line(Device.Width/2,Device.Height/2,MX,MY,clred,clblue,fxNone);
end;

{ TPlayer }

constructor TPlayer.Create(const AParent: TSpriteEngine);
  const
   PlayerPoints:array [1..25] of String =('l1','l2','l3','l4','l5','l6','l7',
   'r1','r2','r3','r4','r5','r6','r7','a1','a2','a3','sphere','soplo','dop',
   'crash_1','crash_2','crash_3','crash_4','crash_5');
   GunPoints:array [1..2] of String =('gun1','gun2');
  var
   PointList:TStringList;
   i,j:integer;

   Eff:TeffectSprite;
begin
  inherited;
    /////
    Childs:=TList.Create;

    //// «¿√–”« ¿ CHILDÓ‚:
    PointList:=TStringList.Create;
    PointList.LoadFromFile('Data\Locs\Points.pts');
    for I := 0 to (PointList.Count - 1)div 3  do
      for j := 1 to 25 do
       if PointList[I*3]=PlayerPoints[j] then
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    _R:=SQRT(SQR(x0)+SQR(y0));
                    Visible:=false;
                    EffectType:=eLamp;
                    EffName:=PlayerPoints[j];
                    z:=5;
                    DrawMode:=1;
                    
                    alf0:=geta0(round(x0),round(y0));
                    Childs.add(eff);
                    // showmessage(inttostr(round(alf0*180/pi)));
                   { if y0<>0 then
                    alf0:=arctan(x0/y0)*180/pi
                     else alf0:=0;}
               end;

          End;




    /// √Õ®«ƒ¿ œ”ÿ≈ 

    PointList.LoadFromFile('Data\Locs\Points2.pts');

    for I := 0 to (PointList.Count - 1)div 3  do
      for j := 1 to 2 do
       if PointList[I*3]=GunPoints[j] then
          Begin
             GunPos[j].X:= strtoint( PointList[I*3+1] );
             GunPos[j].Y:= strtoint( PointList[I*3+2] );
             RAGunPos[j,1]:=SQRT(SQR(GunPos[j].X)+SQR(GunPos[j].Y));
             RAGunPos[j,2]:=geta0(round(GunPos[j].X),round(GunPos[j].Y));
          End;

    PointList.Destroy;
end;

procedure TPlayer.Explode;
begin
  ExplodeEff(x+128,y+128,PExplode);

end;

function TPlayer.GetA0(dx, dy: integer): real;
begin
  if (dx)<>0 then
  Begin
    if (dx)>0 then
    Begin
      result:=-arctan((dy)/(dx));
    End
    else
      Begin
        result:=-pi + arctan((-dy)/(dx));
      End;
  End
  else
    Begin
      result:=0;
    End;

    while result<0 do
      result:=result+2*pi;
    while result>2*pi do
      result:=result-2*pi;
end;

procedure TPlayer.Move(const MoveCount: Single);
const maxR=800;
      minR=50;
var i:integer;
    curR,_alf:real;
    spr:TSprite;
begin
  inherited;

  if health>0 then
  Begin
    /// œÀ¿¬Õ€… œŒ¬Œ–Œ“
    Turn(MoveCount);

    CurR:=RV;
    if CurR>maxR then curR:=MaxR
      else
        if CurR<minR then curR:=0;
    ///// œ≈–≈Ã≈Ÿ≈Õ»≈
    x:=x+Cos(Palf)*MoveCount*CurR/100;
    y:=y-Sin(Palf)*MoveCount*CurR/100;

    ////  ¿ƒ–
    animstart:=round((Palf*180/pi)/5);
    imageindex:=animstart;
    animpos:=animstart;
  End
   else
    BEGIN
      Visible:=false;
      if not(GameOver) then
      Begin              
        GameOver:=true;
        ///// ¡Ë„ ¡‡‰‡-¡ÛÏ
        Explode;
      End;
    END;

  ////  ¿Ã≈–¿
  Engine.WorldX:=(X+128)-(Mainform.Device.Width)/WorldScaleX/2 ;
  if Engine.WorldY<> (Y-128/WorldScaleY) then
      Engine.Worldy := (Y+128)-(Mainform.Device.Height)/WorldScaleY/2 ;

  if health>0 then
  /// —“–≈À‹¡¿
  if CurrentWeapon<>0 then
  if WaitShoot then
    if (Weapons[currentweapon].Count>0)  ////////////////// !!!!!!!!!!
      and (Weapons[currentweapon].CurrentTime>=WReloadTimes[currentweapon]) then
      Begin
        dec(Weapons[currentweapon].Count);
        Weapons[currentweapon].CurrentTime:=0;
        for I := 1 to 2 do Begin
          /// ¬€◊»—Àﬂ≈Ã œŒÀŒ∆≈Õ»≈ "√Õ®«ƒ"
          GunPos[i].X:=128+round(X+RAGunPos[i,1]*Cos(RAGunPos[i,2]+palf));
          GunPos[i].Y:=128+round(Y-RAGunPos[i,1]*Sin(RAGunPos[i,2]+palf));
          /// ¬€œ”—  TARMOSPRITE
           _alf:=round((palf*180/pi)/5)*5;
              with  TArmoSprite.Create(Engine) do
               begin
                    ImageName := 'Shot1';
                    X := GunPos[i].X {- ImageWidth div 2};
                    Y := GunPos[i].Y {- ImageHeight div 2};
                    x0:=x;
                    y0:=y;
                    CollideMethod := cmRect;
                    DoCollision := True;
                    VeloX:=Wspeed[CurrentWeapon]*Cos(palf);
                    VeloY:=-Wspeed[CurrentWeapon]*Sin(palf);
                    Angle:=-_alf*pi/180;
                    DrawMode:=1;
                    L:=0;
                    MaxL:=WLMax[CurrentWeapon];
                    if i=1 then num:=-1;
                    if i=2 then num:=1;
                    ArmoType:=WArmoTypes[currentweapon]; 
                    Red:=redw[currentWeapon];
                    Green:=Greenw[currentWeapon];
                    Blue:=Bluew[currentWeapon];
                    //Drawfx:=fxOneColor;
                    scaleX:=0.5; scaleY:=0.5;
               end;
       End;
  end else Waitshoot:=false;

  // —“ŒÀ ÕŒ¬≈Õ»ﬂ
  Collision;

  /// œ≈–≈ƒ¿◊¿ √ÀŒ¡¿À‹Õ€’ ƒ¿ÕÕ€’
  _alf:=round((oalf*180/pi)/5)*5;
  for I := 0 to Childs.Count - 1 do
    if (Childs[i]<>nil) then
    Begin
     Spr:=Childs[i];
     if spr is TeffectSprite then
     Begin
      TeffectSprite(spr).x1:=x;
      TeffectSprite(spr).y1:=y;
      TeffectSprite(spr).alf1:=_alf;
     End;
    End;

  ///  ŒŒ–ƒ»Õ¿“€ —ÀŒ®¬ ‘ŒÕ¿
  layerX:=x;
  layerY:=y;
end;

procedure TPlayer.Turn(MCount: Single);
var nextalf,step:real;
begin
////
  oalf:=palf;

  nextalf:=alf;

  if abs(palf-nextalf)>abs(palf-nextalf-2*pi) then
    nextalf:=nextalf+2*pi;
  if abs(palf-nextalf)>abs(palf-nextalf+2*pi) then
    nextalf:=nextalf-2*pi;

   step:=MCount/10;

   if palf<nextalf-step then
    palf:=palf+step
     else
       if palf>nextalf+step then
        palf:=palf-step
         else palf:=nextalf;


    while palf<0 do
      palf:=palf+2*pi;
    while palf>2*pi do
      palf:=palf-2*pi;

end;

{ TEffect }

procedure TEffectSprite.CRGB(_R, _G, _B,_A: Integer; MCount:Single);
var Step:real;
begin

  Step:=Mcount*4;

  if Cred<_R-Step then
    Cred:=Cred+Step
      else
         if Cred>_R+Step then
          Cred:=Cred-Step
           else
            Cred:=_R;

  if CGreen<_G-Step then
    CGreen:=CGreen+Step
      else
         if CGreen>_G+Step then
          CGreen:=CGreen-Step
           else
            CGreen:=_G;

  if CBlue<_B-Step then
    CBlue:=CBlue+Step
      else
         if CBlue>_B+Step then
          CBlue:=CBlue-Step
           else
            CBlue:=_B;

   if CAlpha<_A-Step then
    CAlpha:=CAlpha+Step
      else
         if CAlpha>_A+Step then
          CAlpha:=CAlpha-Step
           else
            CAlpha:=_A;
end;

procedure TEffectSprite.Move(const MoveCount: Single);
var S:string;
 Index:integer;
begin
  inherited Move(MoveCount);

  ////////Œ√ŒÕ‹ » »√–Œ ¿
    if EffectType=eLamp then Begin
      Visible:=false;

      //alf1:=round((alf*180/pi)/5)*5;
      Angle:=-alf1*pi/180;
                                 
      x:=X1+128+_R*Cos(-Angle+alf0);    /////////!!!!
      y:=Y1+128-_R*Sin(-Angle+alf0);

      if effName = 'sphere' then
      Begin
          imagename:='sphere';

          AnimSpeed:=0.2;
          AnimCount:=36;

          Visible:=true;
          Drawfx:=fxOneColor;

          scaleX:=0.8;
          scaleY:=0.8;

          if currentWeapon>0 then
          Begin
            if weapons[currentWeapon].Count>0 then
              CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                  Alphaw[currentWeapon],MoveCount)
            else
              CRGB(redw[currentWeapon]div 2,Greenw[currentWeapon]div 2,
                  Bluew[currentWeapon]div 2,Alphaw[currentWeapon]div 2,MoveCount);
            Alpha:=round(Calpha);
            Red:=round(CRed);
            Green:=round(CGreen);
            Blue:=round(CBlue);
          End;
              {«ƒ≈—‹ - ÷¬≈“}
      End
        else
          if (effName = 'a1') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              // if currenentWeap=N then Begin
              if altWeapon>0 then Begin
                if weapons[altWeapon].Count>0 then
                CRGB(redw[AltWeapon],Greenw[AltWeapon],Bluew[AltWeapon],
                  Alphaw[AltWeapon],MoveCount)
                   else CRGB(redw[AltWeapon]div 2,Greenw[AltWeapon] div 2,
                   Bluew[AltWeapon]div 2,Alphaw[AltWeapon]div 2,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;
          End
        else
          if (effName = 'l1') or (effName = 'r1') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                if Weapons[currentWeapon].Count>=30 then
                  CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],MoveCount)
                      else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l2') or (effName = 'r2') then
          Begin
              imagename:=effName;
              Visible:=true;

              if (health<15)and(health>0) then
                if effname='l2' then Begin
                 visible:=false;
                    // ¬˚ÔÛÒÍ‡˛ ËÒÍ˚
                    Eticks:=Eticks+MoveCount;
                    if Eticks>150 then Begin
                      SparkEff(x,y, pFire);
                      Eticks:=0;
                    End;
                end;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
               if Weapons[currentWeapon].Count>=25 then
                CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],MoveCount)
                      else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l3') or (effName = 'r3') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                 if Weapons[currentWeapon].Count>=20 then
                  CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],MoveCount)
                      else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l4') or (effName = 'r4') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                 if Weapons[currentWeapon].Count>=15 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],MoveCount)
                        else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l5') or (effName = 'r5') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                 if Weapons[currentWeapon].Count>=10 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],MoveCount)
                        else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l6') or (effName = 'r6') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                if Weapons[currentWeapon].Count>=5 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],MoveCount)
                        else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l7') or (effName = 'r7') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if currentWeapon>0 then Begin
                if Weapons[currentWeapon].Count>=1 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],MoveCount)
                        else  CRGB(0,0,0,0,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'a2') or (effName = 'a3') then
          Begin
              imagename:=effName;
              Visible:=true;

              {«ƒ≈—‹ - ÷¬≈“}
              if AltWeapon>0 then Begin
                if weapons[altWeapon].Count>0 then
                CRGB(redw[AltWeapon],Greenw[AltWeapon],Bluew[AltWeapon],
                  Alphaw[AltWeapon],MoveCount)
                   else CRGB(redw[AltWeapon]div 2,Greenw[AltWeapon] div 2,
                   Bluew[AltWeapon]div 2,Alphaw[AltWeapon]div 2,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
           if (effName = 'soplo') then
          Begin
              // ¬˚ÔÛÒÍ‡˛ Ó„ÓÌ¸
              visible:=false;
              if (health>0) then
              Eticks:=Eticks+MoveCount;
              if Eticks>2 then
              Begin
                FireEff(x,y, pFire);
                Eticks:=0;
              End
            end
          else
        if (effName = 'crash_1')then
          Begin
              imagename:=effname;
              Visible:=true;
               if health<20 then
                CRGB(0,0,0,255,MoveCount)
                 else  CRGB(0,0,0,0,MoveCount);
              Alpha:=Round(cAlpha);
          End else
        if (effName = 'crash_2')then
          Begin
              imagename:=effname;
              Visible:=true;
               if health<25 then
                CRGB(0,0,0,255,MoveCount)
                 else  CRGB(0,0,0,0,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_4')then
          Begin
              imagename:=effname;
              Visible:=true;
               if health<30 then
                CRGB(0,0,0,255,MoveCount)
                 else  CRGB(0,0,0,0,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_5')then
          Begin
              imagename:=effname;
              Visible:=true;
               if health<15 then
                CRGB(0,0,0,255,MoveCount)
                 else  CRGB(0,0,0,0,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_3') then
          Begin
              visible:=false;

              // ¬˚ÔÛÒÍ‡˛ ËÒÍ˚
              if (health<20)and(health>0) then
              Eticks:=Eticks+MoveCount;
              if Eticks>15 then
              Begin
                SparkEff(x,y, pFire);
                Eticks:=0;
              End;
      End;

      if health<=0 then  Visible:=false;
    End;

   ///// ƒ–”√»≈ ›‘‘≈ “€

end;

{ TParticle }

procedure TParticle.Move(const MoveCount: Single);
begin
  inherited;

  visible:=true;

  if ParType=pFire then
    alpha:=round((lifetime/alllife)*100);

  if ParType=pTrasser then
    alpha:=round((lifetime/alllife)*100);

  if ParType=pExplode then
    if Lifetime>=alllife*0.7 then
    Begin
      Alpha:=round(255*((Lifetime-alllife*0.7)/(0.3*alllife)));
    End;
end;

{ TArmoSprite }

constructor TArmoSprite.Create(const AParent: TSpriteEngine);
begin
  inherited;
  t:=0;
  if ArmoType=aSin then
  Begin
    x0:=x;
    y0:=y;
  End;
end;

procedure TArmoSprite.Move(const MoveCount: Single);
const
  TrasserTime=2;
var
  VeloXi,VeloYi,sina:real;
begin
  inherited;

  if ArmoType=aSimple then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
     Begin
       Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
     End;
    if L>=maxL then Dead;
  End;

  if ArmoType=aTrasser then
  Begin
    t:=t+MoveCount;
    if t>TrasserTime then
    Begin
      t:=0;
      {—Œ«ƒ¿Õ»≈ ◊¿—“»÷}
      TrasserEff(x,y,Red,Green,Blue,1, pTrasser);
    End;
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>=maxL then Dead;
  End;

  if ArmoType=aSin then
 Begin
    t:=t+MoveCount;
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X0:=x0+VeloXi;
    y0:=y0+VeloYi;
    sina:=Sin(L/maxL*pi/2)*num*a;
    x:=x0+VeloYi*Sina;
    y:=y0-VeloXi*Sina;
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));

     if t>TrasserTime then Begin
      t:=0;
      TrasserEff(x,y,Red,Green,Blue,2, pTrasser);
     End;

    if L>=maxL*0.7 then
     Begin
       Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
     End;
     a:=20*(maxL-L)/maxL;
    if L>=maxL then Dead;
 End;

end;

procedure TArmoSprite.OnCollision(const Sprite: TSprite);
begin
  inherited;
///
end;

end.

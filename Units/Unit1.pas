//---------------------------------------------------------------------------
// Side-Scrolling Action game example             Modified: 20-Apr-2006
// Copyright (c) 2000 - 2006  Afterwarp Interactive
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//---------------------------------------------------------------------------

unit Unit1;

interface

uses
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, Asphyre2D, AsphyreCanvas, AsphyreSubsc, AsphyreDevices,
     AsphyreTimers, AsphyreDb, AsphyreImages, AsphyreFonts, AsphyreDef, AsphyreSprite,
     AsphyreKeyboard, SoundSystem, AsphyreMouse;

type

     TActorState = (StandLeft, StandRight, WalkLeft, WalkRight, Die);

     TTileAttribute=(taNormal, taPlatform, taBlock, taTreasure, taSlope);
     TMapRec = record
          X, Y: Integer;
          ImageName: string[10];
     end;

     TTile = class(TAnimatedSprite)
     private
          FCollideRight: Integer;
          FCollideBottom: Integer;
     public
          ID: Integer;
          procedure Move(const MoveCount: Single); override;
     end;

     TActor = class(TJumperSprite)
     private
          FState: TActorState;
          FMoveSpeed: Single;
          FLeft, FTop, FRight, FBottom: Integer;
     public
          procedure Move(const MoveCount: Single); override;
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
          property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
          property State: TActorState read FState write FState;
          property Left: Integer read FLeft write FLeft;
          property Top: Integer read FTop write FTop;
          property Right: Integer read FRight write FRight;
          property Bottom: Integer read FBottom write FBottom;
     end;

     TEnemy=class(TjumperSprite)
     private
          FState: TActorState;
          FCollideRight: Integer;
          FCollideBottom: Integer;
     public
          procedure Move(const MoveCount: Single); override;
          procedure OnCollision(const Sprite: TSprite); override;
          property State: TActorState read FState write FState;
     end;

     TSpray=class(TPlayerSprite)
     private
     x0,y0:single;
     public
          procedure Move(const MoveCount: Single); override;
     end;

     TGreenApple=class(TJumperSprite)
     private
     x0,y0:single;
     public
          procedure Move(const MoveCount: Single); override;
          procedure OnCollision(const Sprite: TSprite); override;
     end;

     TMainForm = class(TForm)
          Fonts: TAsphyreFonts;
          Images: TAsphyreImages;
          Device: TAsphyreDevice;
          MyCanvas: TAsphyreCanvas;
          ASDb: TASDb;
          Timer: TAsphyreTimer;
          Keyboard: TAsphyreKeyboard;
    SoundSystem1: TSoundSystem;
    AsphyreMouse1: TAsphyreMouse;
          procedure DeviceInitialize(Sender: TObject; var Success: boolean);
          procedure TimerTimer(Sender: TObject);
          procedure FormCreate(Sender: TObject);
          procedure DeviceRender(Sender: TObject);
          procedure FormDestroy(Sender: TObject);
          procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
      private
          Fs: TFileStream;
          FileSize: Integer;
          MapData: array of TMapRec;
          Engine: TSpriteEngine;
          Layer1Pos: Single;
          Layer2Pos: Single;
          LeftEdge, RightEdge: Integer;
          FruitCount: Integer;
          Actor: TActor;
          procedure LoadMapData(FileName:string);
          procedure CreateMap;
     public
          { Public declarations }
     end;

var
     MainForm: TMainForm;
     UserRefreshRate: Integer;

     currentmot:integer;
     MotionBlur:Boolean;
     {CamScale:real;
     ResScale:real; }

implementation

{$R *.dfm}

procedure SprayBox(PosX, PosY: Single);
var
     i: Integer;
begin
     for i := 0 to 40 do
     begin
          with TParticleSprite.Create(MainForm.Engine) do
          begin
               ImageName := 'Star';
               X := PosX + Random(20);
               Y := PosY + Random(20);
               Z:=5;
               LifeTime := 150;
               Decay := 1;
               ScaleX := 1.0;
               ScaleY := 1.0;
               DrawFx := fxBlend;
               UpdateSpeed := 0.5;
               VelocityX := -4 + Random * 8;
               VelocityY := -Random * 7;
               AccelX := 0;
               AccelY := 0.2 + Random / 2;
          end;
     end;
end;

procedure TSpray.Move(const MoveCount: Single);
begin
     Accelerate;
     UpdatePos;
     Alpha:=Alpha-5;
     if Alpha<0 then Dead;
end;

procedure SprayFruit(PosX, PosY: Single);
var
   i: Integer;
begin
     for i:=0 to 31 do
     begin
          with TSpray.Create(MainForm.Engine) do
          begin
               ImageName:='flare';
               DrawFx:= fxAdd;
               X:= PosX;
               Y:= PosY;
               Z:= 5;
               ScaleX:=0.52;
               ScaleY:=0.52;
               Red:=255;
               Green:=50;
               Blue:=0;
               Acceleration :=0.5;
               MinSpeed := 0.8;
               MaxSpeed := 1.0;
               Direction:= i*8;
          end;
     end;
end;

procedure TGreenApple.Move(const MoveCount: Single);
begin
     inherited;
       
     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + PatternWidth),
                    Round(Y + PatternHeight));
     Collision;
end;

procedure TGreenApple.OnCollision(const Sprite: TSprite);
begin
     if (Sprite is TTile) then
     begin
          if  (TTile(Sprite).ImageName='Ground1')  or (TTile(Sprite).ImageName='Rock1') or ( TTile(Sprite).ImageName= 'Rock2')  then
          begin
               JumpState:=jsNone;
               Y:=TTile(Sprite).Y-28;
          end;
     end;
end;

procedure CreateGreenApple(PosX, PosY: Single);
begin
     Randomize;
     if Random(3)=1 then
     begin
          with TGreenApple.Create(MainForm.Engine) do
          begin
               ImageName:='Fruit'+ IntToStr(2+Random(2));
               X:= PosX;
               Y:= PosY;
               Z:=5;
               CollideMethod:= cmRect;
               DoCollision:= True;
               DoJump:=True;
          end;
     end;
end;

procedure TMainForm.LoadMapData(FileName: string);
begin
     Fs := TFileStream.Create(ExtractFilePath(Application.ExeName) + FileName, fmOpenRead);
     Fs.ReadBuffer(FileSize, SizeOf(FileSize));
     SetLength(MapData, FileSize);
     Fs.ReadBuffer(MapData[0], SizeOf(TMapRec) * FileSize);
     Fs.Destroy;
end;

procedure TMainForm.CreateMap;
var
   i:Integer;
begin

     Actor := TActor.Create(Engine);
     for i := FileSize - 1 downto 0 do
     begin
          if (MapData[i].ImageName<>'Enemy1') and  (MapData[i].ImageName<>'Enemy2') and (MapData[i].ImageName<>'Enemy3') then
          begin
               with  TTile.Create(Engine) do
               begin
                    ImageName := MapData[i].ImageName;
                    X := MapData[i].X - 540;
                    Y := MapData[i].Y - 150;
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
                    State:=Walkleft;
                    JumpState:=jsfalling;
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

procedure TActor.Move(const MoveCount: Single);
var animspd:real;
begin
     inherited;
    //UserRefreshRate:=10;

     if Y > 1200 then
     begin
          Engine.Clear;
          Mainform.CreateMap;
       //   MainForm.Music.Songs.Find('Music1').Play;
          MainForm.FruitCount:=0;
          Exit;
     end;
     Left :=   Round(X + 45);
     Top :=    Round(Y + 45);
     Right :=  Round(X + 65);
     Bottom := Round(Y + 110);
     CollideRect := Rect(Left, Top, Right, Bottom);
     //falling--when walk out of tile edge
     if (Self.Right < MainForm.LeftEdge) or (Self.Left > MainForm.RightEdge) then
     begin
          if JumpState <> jsJumping then
               JumpState := jsFalling;
     end;

     if MainForm.Keyboard.Key[205] and (state<>die)then
     begin
          State := WalkRight;
          X := X + MoveSpeed;
          case JumpState of
               jsNone:
               begin
                 animspd:=0.65-UserRefreshRate/300;

                  {   if UserRefreshRate=60 then SetAnim('Walk', 0, 12, vb0.45, True, False, True);
                     if UserRefreshRate=75 then SetAnim('Walk', 0, 12, 0.4, True, False, True);
                     if UserRefreshRate=85 then SetAnim('Walk', 0, 12, 0.35, True, False, True);
                     if UserRefreshRate=100 then SetAnim('Walk', 0, 12, 0.3, True, False, True);
                     if UserRefreshRate=120 then SetAnim('Walk', 0, 12, 0.25, True, False, True); }
                 SetAnim('Walk', 0, 12, animspd, True, False, True);
               end;
               jsJumping: SetAnim('Jump', 0, 3, 0.06, False, False, True);
               jsFalling: SetAnim('Jump', 3, 3, 0, False, False, True);
          end;
     end;

     if MainForm.Keyboard.Key[203]and (state<>die) then
     begin
          State := WalkLeft;
          X := X - MoveSpeed;
          case JumpState of
               jsNone:
               begin
                    animspd:=0.65-UserRefreshRate/300;
                    {if UserRefreshRate=60 then  SetAnim('Walk', 0, 12, 0.45, True, True, True);
                    if UserRefreshRate=75 then  SetAnim('Walk', 0, 12, 0.4, True, True, True);
                    if UserRefreshRate=85 then  SetAnim('Walk', 0, 12, 0.35, True, True, True);
                    if UserRefreshRate=100 then  SetAnim('Walk', 0, 12, 0.3, True, True, True);
                    if UserRefreshRate=120 then  SetAnim('Walk', 0, 12, 0.25, True, True, True); }

                    SetAnim('Walk', 0, 12, animspd, True, True, True);

               end;
               jsJumping: SetAnim('Jump', 0, 3, 0.06, False, True, True);
               jsFalling: SetAnim('Jump', 3, 3, 0, False, True, True);
          end;
     end;

     if MainForm.Keyboard.KeyReleased[205] and (state<>die)then
     begin
          State := StandRight;
          if JumpState = jsNone then
               SetAnim('Idle', 0, 12, 0.25, True, False, True);
     end;

     if MainForm.Keyboard.KeyReleased[203]and (state<>die) then
     begin
          State := StandLeft;
          if JumpState = jsNone then
               SetAnim('Idle', 0, 12, 0.25, True, True, True);
     end;


     if (JumpState = jsNone) then
     begin
          if (MainForm.Keyboard.Keypressed[29]) or (MainForm.Keyboard.Keypressed[57]) and (state<>die)then
          begin
               DoJump := True;
            //   MainForm.Music.Songs.Items[1].Play;
               Animpos := 0;
               case State of
                    StandRight:
                    begin

                        Animspd:= 0.1-UserRefreshRate/1500;
                         {if UserRefreshRate=60 then SetAnim('Jump', 0, 3, 0.06, True, False, True);
                         if UserRefreshRate=75 then SetAnim('Jump', 0, 3, 0.05, True, False, True);
                         if UserRefreshRate=85 then SetAnim('Jump', 0, 3, 0.04, True, False, True);
                         if UserRefreshRate=100 then SetAnim('Jump', 0, 3, 0.03, True, False, True);
                         if UserRefreshRate=120 then SetAnim('Jump', 0, 3, 0.02, True, False, True); }
                        SetAnim('Jump', 0, 3, Animspd, True, False, True);
                    end;
                    StandLeft:
                    begin

                         Animspd:= 0.1-UserRefreshRate/1500;

                        { if UserRefreshRate=60 then SetAnim('Jump', 0, 3, 0.06, True, True, True);
                         if UserRefreshRate=75 then SetAnim('Jump', 0, 3, 0.05, True, True, True);
                         if UserRefreshRate=85 then SetAnim('Jump', 0, 3, 0.04, True, True, True);
                         if UserRefreshRate=100 then SetAnim('Jump', 0, 3, 0.03, True, True, True);
                         if UserRefreshRate=120 then SetAnim('Jump', 0, 3, 0.03, True, True, True); }

                        SetAnim('Jump', 0, 3, Animspd, True, True, True);
                    end;
               end;
          end;
     end;


    { if Engine.WorldX< (X-350) then
            Engine.WorldX := X - 350;

     if Engine.WorldX> (X-345) then
            Engine.WorldX := X - 345; }




     //  ¿Ã≈–¿ X

    // if (State = StandLeft)or (State = WalkLeft) then  Begin

     if Engine.WorldX> (X-400/WorldScaleX) then
        Engine.WorldX := Engine.WorldX+((X-400/WorldScaleX)-Engine.WorldX)/20;

   //  End;

      // if (State = StandRight)or (State = WalkRight) then  Begin

     if Engine.WorldX<  (X-400/WorldScaleX)  then
        Engine.WorldX := Engine.WorldX+((X-400/WorldScaleX)-Engine.WorldX)/20;

    // End;


     if Engine.WorldY<> (Y-400*WorldScaleY) then
            Engine.Worldy := (Y-400/WorldScaleY);

   {  if Y<(Y-250)*WorldScaleY/2+Mainform.Device.Height*WorldScaleY/2 then
     begin
         // if Engine.WorldY< (Y-250)*WorldScaleY+Mainform.Device.Height*WorldScaleY/2 then
                 Engine.WorldY := (Y - 250)*WorldScaleY/2+Mainform.Device.Height*WorldScaleY/2;
     end;}

     if UserRefreshRate=60 then
     begin
          MainForm.Layer1pos:=Engine.Worldx*2*0.25-20000;
          MainForm.Layer2pos:=Engine.Worldx*1*0.25-20000;
     end;
     if  (UserRefreshRate=75)  then
     begin
          MainForm.Layer1pos:=Engine.Worldx*1.5*0.5-20000;
          MainForm.Layer2pos:=Engine.Worldx*0.5-20000;
     end;
     if  (UserRefreshRate=85)  then
     begin
          MainForm.Layer1pos:=Engine.Worldx*1.5*0.5-20000;
          MainForm.Layer2pos:=Engine.Worldx*1*0.5-20000;
     end;
     if  (UserRefreshRate=100)  then
     begin
          MainForm.Layer1pos:=Engine.Worldx*1.5*0.5-20000;
          MainForm.Layer2pos:=Engine.Worldx*1*0.5-20000;
     end;
     if  (UserRefreshRate=120)  then
     begin
          MainForm.Layer1pos:=Engine.Worldx*1*0.5-20000;
          MainForm.Layer2pos:=Engine.Worldx*1*0.25-20000;
     end;
     Collision;
end;

procedure TActor.OnCollision(const Sprite: TSprite);
var
   TileName: string;
   TileLeft, TileRight,
   TileTop, TileBottom: Integer;
begin
     if (Sprite is TTile) then
     begin
          TileName:=TTile(Sprite).ImageName;
          //only those tile can collision
          if (TileName='Ground1') or (TileName ='Rock2') or (TileName = 'Rock1') or (TileName='Box1') or (TileName='Box2') or(TileName='Box3') or (TileName='Box4') or (TileName='Spring1') then
          begin
               TileLeft := Trunc(TTile(Sprite).X);
               TileTop := Trunc(TTile(Sprite).Y);
               TileRight := Trunc(TTile(Sprite).X) + TTile(Sprite).PatternWidth;
               TileBottom := Trunc(TTile(Sprite).Y) + TTile(Sprite).PatternHeight;
               MainForm.LeftEdge:= Trunc(TTile(Sprite).X);
               MainForm.RightEdge:=Trunc(TTile(Sprite).X) + TTile(Sprite).PatternWidth;
          end;
          //Falling-- land at ground
          if JumpState = jsFalling then
          begin
               if  (TileName = 'Ground1') or (TileName = 'Rock2')or (TileName = 'Rock1') or (TileName='Box1') or (TileName='Box2') or(TileName='Box3') or (TileName='Box4') then
               begin
                    if(Self.Right - 4 > TileLeft) and
                    (Self.Left + 3 < TileRight)   and
                    (Self.Bottom-12 < TileTop)   then
                    begin
                         JumpState := jsNone;
                         case UserRefreshRate of
                              60:
                              begin
                                    JumpSpeed := 0.49;
                                    JumpHeight := 13.3;
                                    MaxFallSpeed := 9;
                              end;
                              75:
                              begin
                                    JumpSpeed := 0.3;
                                    JumpHeight := 10.5;
                                    MaxFallSpeed := 9;
                              end;
                              85:
                              begin
                                    JumpSpeed := 0.2;
                                    JumpHeight := 8.5;
                                    MaxFallSpeed := 8;
                              end;
                              100:
                              begin
                                    JumpSpeed := 0.13;
                                    JumpHeight := 6.9;
                                    MaxFallSpeed := 8;
                              end;
                              120:
                              begin
                                   JumpSpeed := 0.1;
                                   JumpHeight := 5;
                                   MaxFallSpeed := 8;
                              end;
                          end;
                         Self.Y := TileTop - 102;

                         case State of
                             StandLeft: SetAnim('Idle', 0, 12, 0.25, True, True, True);
                             StandRight:SetAnim('Idle', 0, 12, 0.25, True, False, True);
                             WalkLeft:  SetAnim('walk', 0, 12, 0.2, True, True, True);
                             WalkRight: SetAnim('walk', 0, 12, 0.2, True, False, True);
                         end;
                    end;
               end;
          end;
          // jumping-- touch top tiles
          if JumpState = jsJumping then
          begin
               if (TileName = 'Rock2')or (TileName = 'Rock1') or (TileName='Box1') or (TileName='Box2') or(TileName='Box3') or (TileName='Box4')then
               begin
                    if (Self.Right-4 > TileLeft)  and
                       (Self.Left+3  < TileRight) and
                       (Self.Top< TileBottom-5)   and
                       (Self.Bottom>TileTop+8)    then
                    begin
                         Jumpstate:= jsfalling;
                         if  (TileName='Box1') or (TileName='Box2') or(TileName='Box3') or (TileName='Box4') then
                         begin
                            //   MainForm.Music.Songs.Items[2].Play;
                              TTile(Sprite).Dead;
                              SprayBox(TTile(Sprite).X, TTile(Sprite).Y);
                              CreateGreenApple(TTile(Sprite).X, TTile(Sprite).Y);
                         end;
                    end;
               end;
          end;

          //tiles collision
          if (TileName = 'Rock2')or (TileName = 'Rock1') or (TileName='Box1') or (TileName='Box2') or(TileName='Box3') or (TileName='Box4') or (TileName='Spring1')then
          begin
               if State=WalkLeft then
               begin
                     if (Self.Left + 8 > TileRight) and
                        (Self.Top+10< TileBottom)   and
                        (Self.Bottom-8>TileTop)     then
                           Self.X := TTile(Sprite).X+(TTile(sprite).PatternWidth-45)-3;
               end;

               if State=WalkRight then
               begin
                    if (Self.Right-8  < TileLeft) and
                       (Self.Top+10< TileBottom)  and
                       (Self.Bottom-8>TileTop)    then
                          Self.X := TTile(Sprite).X - (Self.PatternWidth-45)+3; // 64= self right
               end;
          end;
          //get  fruit
          if (TileName='Fruit1') or (TileName='Fruit4')   then
          begin
                  Inc(MainForm.FruitCount);
                //  MainForm.Music.Songs.Find('GetFruit').Play;
                  TTile(Sprite).Dead;
                  SprayFruit(TTile(Sprite).X+10, TTile(Sprite).Y+10);
          end;

          //
          if (TileName='Spring1') and (JumpState=jsFalling)  then
          begin
          //     MainForm.Music.Songs.Find('Rebon').Play;
               Self.Y:=TileTop-85;
               JumpState:=jsNone;
               DoJump:=True;
               if UserRefreshRate=60 then
               begin
                    JumpSpeed := 0.5;
                    JumpHeight := 20.5;
                    MaxFallSpeed := 12;
               end;
               if UserRefreshRate=75 then
               begin
                    JumpSpeed := 0.25;
                    JumpHeight := 14.5;
                    MaxFallSpeed := 10;
               end;
               if UserRefreshRate=85 then
               begin
                    JumpSpeed := 0.2;
                    JumpHeight := 13;
                    MaxFallSpeed := 8.5;
               end;
               if UserRefreshRate=100 then
               begin
                    JumpSpeed := 0.12;
                    JumpHeight := 10;
                    MaxFallSpeed := 8.5;
               end;
               if UserRefreshRate=120 then
               begin
                    JumpSpeed := 0.12;
                    JumpHeight := 10;
                    MaxFallSpeed := 8.5;
               end;
               AnimPos:=0;
               case State of
                    StandRight: SetAnim('Jump', 0, 3, 0.06, False, False, True);
                    StandLeft: SetAnim('Jump', 0, 3, 0.06, False, True, True);
               end;
               TTile(Sprite).AnimPos:=0;
               TTile(Sprite).SetAnim('Spring1',0,6,0.2,False,False,True);
          end;
     end;

     // get green Apple
    if (Sprite is TGreenApple) then
    begin
         if TGreenApple(Sprite).JumpState= jsNone then
         begin
         //     MainForm.Music.Songs.Find('GetGreenApple').Play;
              TTile(Sprite).Dead;
         end;
    end;

    //    jump fall and kill enemy
    if (Sprite is TEnemy) then
    begin
         if (jumpState=jsNone) or (JumpState=jsJumping) then
         begin
          // MainForm.Music.Songs.Find('Dead').Play;
           //  MainForm.Music.Songs.Find('Music1').Stop;;
              State:=Die;
             // Sleep(1000);
              Docollision:= False;
              DoJump:=True;
              JumpSpeed:=0.1;
              JumpHeight:=5;
              AnimPos:=0;
              SetAnim('Dead',0,6,0.1,True,False,True);
         end;
         if (jumpState=jsFalling) and (Y+100< TEnemy(Sprite).Y)  then
         begin
           // MainForm.Music.Songs.Find('Ka').Play;;
              JumpState:= jsNone;
              DoJump:=True;
              if UserRefreshRate=85 then
              begin
                   JumpSpeed := 0.2;
                   JumpHeight := 7;
              end;
              if UserRefreshRate=60 then
              begin
                   JumpSpeed := 0.5;
                   JumpHeight := 10;
              end;
              with TEnemy(Sprite) do
              begin
                   Y:=Y-1;
                   State:=Die;
                   DoCollision:=False;
                   DoAnimate:=False;
                   MirrorY:= True;
                   DoJump:=True;
                   JumpSpeed := 0.2;
                   JumpHeight := 5;
              end;
         end;
    end;
end;

constructor TActor.Create(const AParent: TSpriteEngine);
begin
     inherited;
     X := 810;
     Y := 200;
     CollideMethod := cmRect;
     ImageName := 'Idle';
     AnimStart := 0;
     AnimCount := 12;
     AnimSpeed := 0.25;
     AnimLooped := True;
     DoAnimate := True;
     DoCollision := True;
     State := StandLeft;


     FMoveSpeed:=5 - UserRefreshRate/30;

      {case UserRefreshRate of

         60: FMoveSpeed:=3;
          75: FMoveSpeed:=2.5;
          85: FMoveSpeed := 2;
          100: FMoveSpeed:=1.5;
          120: FMoveSpeed:=1;
     end; }
     Animpos := 5;
     JumpSpeed := 0.2;
     JumpHeight := 8.5;
     MaxFallSpeed := 8;
     JumpState := jsjumping;
     State := StandRight;
end;

procedure TEnemy.Move(const MoveCount: Single);
begin
     inherited;

     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + Self.FCollideRight),
                    Round(Y + Self.FCollideBottom));
     if (State <> Die) then
     begin
          case State of
               WalkLeft:
               begin
                    if UserRefreshRate=60 then
                    begin
                         X:=X-1.5;
                         SetAnim(ImageName,0,AnimCount, 0.4, True, False, True);
                    end;
                    if UserRefreshRate=75 then
                    begin
                         X:=X-1.25;
                         SetAnim(ImageName,0,AnimCount, 0.35, True, False, True);
                    end;
                    if UserRefreshRate=85 then
                    begin
                         X:=X-1;
                         SetAnim(ImageName,0,AnimCount, 0.3, True, False, True);
                    end;
                    if UserRefreshRate=100 then
                    begin
                         X:=X-1;
                         SetAnim(ImageName,0,AnimCount, 0.25, True, False, True);
                    end;
                     if UserRefreshRate=120 then
                    begin
                         X:=X-0.5;
                         SetAnim(ImageName,0,AnimCount, 0.2, True, False, True);
                    end;
               end;
               WalkRight:
               begin
                    if UserRefreshRate=60 then
                    begin
                         X:=X+1.5;
                         SetAnim(ImageName,0,AnimCount, 0.4, True, True, True);
                    end;
                    if UserRefreshRate=75 then
                    begin
                         X:=X+1.25;
                         SetAnim(ImageName,0,AnimCount, 0.35, True, True, True);
                    end;
                    if UserRefreshRate=85 then
                    begin
                         X:=X+1;
                         SetAnim(ImageName,0,AnimCount, 0.3, True, True, True);
                    end;
                     if UserRefreshRate=100 then
                    begin
                         X:=X+1;
                         SetAnim(ImageName,0,AnimCount, 0.25, True, True, True);
                    end;
                    if UserRefreshRate=120 then
                    begin
                         X:=X+0.5;
                         SetAnim(ImageName,0,AnimCount, 0.2, True, True, True);
                    end;
               end;
          end;
     end;


    if ImageName='Enemy3' then AnimSpeed:=0.15;
    if Y> 600 then Dead;
    Collision;
end;

procedure TEnemy.OnCollision(const Sprite: TSprite);
begin
     if(Sprite is TTile) then
     begin
          if (TTile(Sprite).ImageName='Ground1') or (TTile(Sprite).ImageName='Rock2' )then
          JumpState:=jsNone;
        //  y:=TTile(sprite).Y-150;
          if TTile(Sprite).ImageName='Test1' then
          begin
               if State=WalkLeft then
               begin
                    X:=X+3;
                    State:=WalkRight;
               end
               else
               begin
                    X:=X-3;
                    State:=WalkLeft;
               end;
          end;

     end;
end;

procedure TMainForm.DeviceInitialize(Sender: TObject; var Success: boolean);
begin
     // load all images from ASDb
     Success := Images.LoadFromASDb(ASDb);

     // if succeeded with images, load all fonts too
     if (Success) then
          Success := Fonts.LoadFromASDb(ASDb);

     // start rendering only if succeeded loading stuff
     Timer.Enabled := Success;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
     // render the scene
     {Device.Render(RGB(55, 140, 210), True);}

      Device.Render(RGB(100, 100, 100), True);


     // do calculations while Direct3D is still rendering
     Timer.Process();

     // flip back buffers
     Device.Flip();
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   MonitorFrequency, I: Integer;
   DC: THandle;
   Img1:TAsphyreImage;
begin
     Screen.Cursor := crNone;

     // initialize Asphyre device
     if (not Device.Initialize()) then
     begin
          MessageDlg('Unable to initialize Asphyre device!', mtError, [mbOk], 0);
          Close();
          Exit;
     end;
     DC   := GetDC(Handle);
     MonitorFrequency := GetDeviceCaps(DC, VREFRESH);
     case MonitorFrequency of
          60..70:UserRefreshRate:=60;
          71..75:UserRefreshRate:=75;
          76..85:UserRefreshRate:=85;
          86..100:UserRefreshRate:=100;
          101..120:UserRefreshRate:=120;
     end;

     Engine := TSpriteEngine.Create;
     Engine.Image := Images;
     Engine.Canvas := MyCanvas;
     Engine.VisibleArea:= Rect(-300, -200, 1024+300, 768+200);
     LoadMapData('Data\TEST.map');
     CreateMap;

     //// ÃŒ» œ≈–≈Ã≈ÕÕ€≈

     MotionBlur:=true;

     //// ÃŒ”ÿ≈Õ - ¡Àﬁ–

     CurrentMot:=0;


      for I := 0 to 30 do Begin
        Img1:=Images.Add;
        Img1.Name:='Motion'+inttostr(i);
      End;

      Engine.WorldScaleX:=0.5;
     Engine.WorldScaleY:=0.5;
    // Music.Songs.Items[0].Play;
end;

procedure TMainForm.DeviceRender(Sender: TObject);
var I:Integer;
begin
     Keyboard.Update;
   //  MyCanvas.DrawStretch(Images.Image['back3'], 0, 0, Device.Width, Device.Height,false,false, clWhite4, fxNone);
     MyCanvas.DrawPortion(Images.Image['back2'], 0, 0, 360, Trunc(Layer2Pos) - 440, 0, 640, 447, clWhite4, fxBlend);
     MyCanvas.DrawPortion(Images.Image['back1'], 0, 0, 520, Trunc(Layer1Pos) - 440, 0, 640, 447, clWhite4, fxBlend);

   //  Engine.worldScaleX:=0.5;
  //   Engine.worldScaleY:=0.5;
     Engine.Draw;
     Engine.Move(1{timer.Delta});
     Engine.Dead;

     if MotionBlur=True then Begin

         for I := 0 to currentmot do
           MyCanvas.Draw(Images.Image['Motion'+inttostr(i)], 0, 0, 0, fxBlend{Add});

     End;
    // MyCanvas.Draw(Images.Image['Jump'],20,20,0,fxBlend);
     Fonts[1].TextOut('X'+IntToStr(FruitCount), 50, 30, cRGB1(255, 100, 100));
     Fonts[1].TextOut('FPS: '+IntToStr(Timer.FrameRate)+' // DELTA: '+FloatToStr(Timer.delta) , 50, 80, cRGB1(255, 255, 255));
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     // finalize Asphyre device
     Device.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState);
begin
     // leave the program on ESC button
     if (Key = VK_ESCAPE) then Close();

     // switch between full-screen and windowed mode on Alt + Enter
     if (Key = VK_RETURN) and (ssAlt in Shift) then
     begin
          // switch windowed mode
          Device.Windowed := not Device.Windowed;
          if Device.Windowed then Mainform.BorderStyle:=bsSizeable
           else Mainform.BorderStyle:=bsNone;

     end;
end;





procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button=mbRight then Engine.WorldScaleX:=Engine.WorldScaleX+0.5;
                 Engine.WorldScaleY:=Engine.WorldScaleX;
                 showmessage('ya!');

end;

end.


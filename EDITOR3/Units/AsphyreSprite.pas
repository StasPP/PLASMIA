//---------------------------------------------------------------------------
// AsphyreSprite.pas                                    Modified: 11-Feb-2006
// Asphyre Sprite Engine
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

unit AsphyreSprite;

interface
uses
     Windows, Types, Classes, SysUtils, Math, AsphyreDef, AsphyreDevices, AsphyreCanvas,
     AsphyreImages;

type

     TCollideMethod = (cmRadius, cmRect, cmQuadrangle, cmPolygon);
     TAnimPlayMode = (pmForward, pmBackward, pmPingPong);
     TJumpState = (jsNone, jsJumping, jsFalling);
     TImageType = (itSingleImage, itSpriteSheet);

     TSprite = class;

     TSpriteEngine = class
     private
          FSpriteList: TList;
          FDeadList: TList;
          FWorldX, FWorldY,FWorldScaleX, FWorldScaleY : Single;
          FCanvas: TAsphyreCanvas;
          FImage: TAsphyreImages;
          FVisibleArea: TRect;
          function GetSprite(const Index: Integer): TSprite;
          function GetCount: Integer;
     public
          constructor Create;
          destructor Destroy; override;
          procedure Add(const Sprite: TSprite);
          procedure Remove(const Sprite: TSprite);
          procedure Change(Sprite: TSprite; Dest: TSpriteEngine);
          procedure Move(MoveCount: Single);
          procedure Draw;
          procedure Collision;
          procedure Clear;
          procedure Dead;
          property Canvas: TAsphyreCanvas read FCanvas write FCanvas;
          property Image: TAsphyreImages read FImage write FImage;
          property Items[const Index: Integer]: TSprite read GetSprite; default;
          property Count: Integer read GetCount;
          property WorldX: Single read FWorldX write FWorldX;
          property WorldY: Single read FWorldY write FWorldY;
          property WorldScaleX: Single read FWorldScaleX write FWorldScaleX;
          property WorldScaleY: Single read FWorldScaleY write FWorldScaleY;
          property VisibleArea: TRect read FVisibleArea  write FVisibleArea;
     end;

     TSprite = class(TObject)
     private
          FEngine: TSpriteEngine;
          FName: string;
          FX, FY: Single;
          FZ: Integer;
          FX1, FY1, FX2, FY2, FX3, FY3, FX4, FY4: Single;
          FWorldX, FWorldY,FWorldScaleX, FWorldScaleY: Single;
          FVisible: Boolean;
          FDrawFx: Integer;
          FColorOp: Integer;
          FMirrorX, FMirrorY: Boolean;
          FCenterX, FCenterY: Single;
          FDoCenter: Boolean;
          FColor1, FColor2, FColor3, FColor4: Cardinal;
          FRed, FGreen, FBlue: Integer;
          FAlpha: Integer;
          FDoCollision: Boolean;
          FCollisioned: Boolean;
          FAngle: Single;
          FImageName: string;
          FPatternIndex: Integer; //for SpriteSheet
          FImageIndex: Integer; //for Single Image
          FScaleX, FScaleY: Single;
          FOffsetX, FOffsetY: Single;
          FIsDead: Boolean;
          FMoved: Boolean;
          FDrawMode: Integer;
          FCollidePos: TPoint2;
          FCollideRadius: Integer;
          FCollideRect: TRect;
          FTag: Integer;
          FCollideQuadrangle: TPoint4;
          FCollideMethod: TCollideMethod;
          FImageType: TImageType;
          function GetImageWidth: Integer;
          function GetImageHeight: Integer;
          function GetPatternWidth: Integer;
          function GetPatternHeight: Integer;
          function GetPatternCount: Integer;
     protected
          procedure SetName(const Value: string); virtual;
          procedure SetRed(const Value: Integer); virtual;
          procedure SetGreen(const Value: Integer); virtual;
          procedure SetBlue(const Value: Integer); virtual;
          procedure SetAlpha(const Value: Integer); virtual;
          procedure SetImageName(const Value: string); virtual;
          procedure SetPatternIndex(const Value: Integer); virtual;
          procedure SetDrawMode(const Value: Integer); virtual;
          procedure SetX(const Value: Single); virtual;
          procedure SetY(const Value: Single); virtual;
          procedure SetZ(const Value: Integer); virtual;
     public
          constructor Create(const AParent: TSpriteEngine); virtual;
          destructor Destroy; override;
          procedure Assign(const Value: TSprite); virtual;
          procedure Collision(const Other: TSprite); overload; virtual;
          procedure Collision; overload; virtual;
          procedure Dead; virtual;
          procedure OnCollision(const Sprite: TSprite); virtual;
          procedure Move(const MoveCount: Single); virtual;
          procedure Draw; virtual;
          procedure SetColor(const Color: TColor4); overload;
          procedure SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal=255); overload;
          procedure SetPos(X, Y: Single); overload;
          procedure SetPos(X, Y: Single; Z: Integer); overload;
          property IsDead: Boolean read FIsDead;
          property Visible: Boolean read FVisible write FVisible;
          property X: Single read FX write SetX;
          property Y: Single read FY write SetY;
          property Z: Integer read FZ write SetZ;
          property X1: Single read FX1 write FX1;
          property Y1: Single read FY1 write FY1;
          property X2: Single read FX2 write FX2;
          property Y2: Single read FY2 write FY2;
          property X3: Single read FX3 write FX3;
          property Y3: Single read FY3 write FY3;
          property X4: Single read FX4 write FX4;
          property Y4: Single read FY4 write FY4;
          property ImageName: string read FImageName write SetImageName;
          property PatternIndex: Integer read FPatternIndex write SetPatternIndex;
          property ImageIndex : Integer read FImageIndex write FImageIndex;
          property ImageWidth: Integer read GetImageWidth;
          property ImageHeight: Integer read GetImageHeight;
          property PatternWidth: Integer read GetPatternWidth;
          property PatternHeight: Integer read GetPatternHeight;
          property PatternCount: Integer read GetPatternCount;
          property Red: Integer read FRed write SetRed default 255;
          property Green: Integer read FGreen write SetGreen default 255;
          property Blue: Integer read FBlue write SetBlue default 255;
          property Alpha: Integer read FAlpha write SetAlpha default 255;
          property Color1: Cardinal read FColor1 write FColor1;
          property Color2: Cardinal read FColor2 write FColor2;
          property Color3: Cardinal read FColor3 write FColor3;
          property Color4: Cardinal read FColor4 write FColor4;
          property Angle: Single read FAngle write FAngle;
          property CenterX: Single read FCenterX write FCenterX;
          property CenterY: Single read FCenterY write FCenterY;
          property ScaleX: Single read FScaleX write FScaleX;
          property ScaleY: Single read FScaleY write FScaleY;
          property OffsetX: Single read FOffsetX write FOffsetX;
          property OffsetY: Single read FOffsetY write FOffsetY;
          property WorldX: Single read FWorldX write FWorldX;
          property WorldY: Single read FWorldY write FWorldY;
          property WorldScaleX: Single read FWorldScaleX write FWorldScaleX;
          property WorldScaleY: Single read FWorldScaleY write FWorldScaleY;
          property DoCenter: Boolean read FDoCenter write FDoCenter;
          property MirrorX: Boolean read FMirrorX write FMirrorX;
          property MirrorY: Boolean read FMirrorY write FMirrorY;
          property DrawFx: Integer read FDrawFx write FDrawFx;
          property ColorOp: Integer read FColorOp write FColorOp;
          property Name: string read FName write SetName;
          property DrawMode: Integer read FDrawMode write SetDrawMode;
          property Moved: Boolean read FMoved write FMoved;
          property DoCollision: Boolean read FDoCollision write FDoCollision;
          property CollidePos: TPoint2 read FCollidePos write FCollidePos;
          property CollideRadius: Integer read FCollideRadius write FCollideRadius;
          property CollideRect: TRect read FCollideRect write FCollideRect;
          property CollideQuadrangle: TPoint4 read FCollideQuadrangle write FCollideQuadrangle;
          property CollideMethod: TCollideMethod read FCollideMethod write FCollideMethod;
          property Collisioned: Boolean read FCollisioned write FCollisioned;
          property Engine: TSpriteEngine read FEngine write FEngine;
          property Tag: Integer read FTag write FTag;
          property ImageType: TImageType read FImageType write FImageType;
     end;

     TAnimatedSprite = class(TSprite)
     private
          FDoAnimate: Boolean;
          FAnimLooped: Boolean;
          FAnimStart: Integer;
          FAnimCount: Integer;
          FAnimSpeed: Single;
          FAnimPos: Single;
          FAnimEnded: Boolean;
          FDoFlag1, FDoFlag2: Boolean;
          FAnimPlayMode: TAnimPlayMode;
          procedure SetAnimStart(Value: Integer);
     public
          constructor Create(const AParent: TSpriteEngine); override;
          procedure Assign(const Value: TSprite); override;
          procedure Draw; override;
          procedure Move(const MoveCount: Single); override;
          procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped, DoMirror, DoAnimate: Boolean; PlayMode: TAnimPlayMode=pmForward); overload; virtual;
          procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped: Boolean;  PlayMode: TAnimPlayMode=pmForward); overload; virtual;
          property AnimPos: Single read FAnimPos write FAnimPos;
          property AnimStart: Integer read FAnimStart write SetAnimStart;
          property AnimCount: Integer read FAnimCount write FAnimCount;
          property AnimSpeed: Single read FAnimSpeed write FAnimSpeed;
          property AnimLooped: Boolean read FAnimLooped write FAnimLooped;
          property DoAnimate: Boolean read FDoAnimate write FDoAnimate;
          property AnimEnded: Boolean read FAnimEnded;
          property AnimPlayMode: TAnimPlayMode read FAnimPlayMode write FAnimPlayMode;
     end;

     TParticleSprite = class(TAnimatedSprite)
     private
          FAccelX: Real;
          FAccelY: Real;
          FVelocityX: Real;
          FVelocityY: Real;
          FUpdateSpeed : Single;
          FDecay: Real;
          FLifeTime: Real;
     public
          constructor Create(const AParent: TSpriteEngine); override;
          procedure Move(const MoveCount: Single); override;
          property AccelX: Real read FAccelX write FAccelX;
          property AccelY: Real read FAccelY write FAccelY;
          property VelocityX: Real read FVelocityX write FVelocityX;
          property VelocityY: Real read FVelocityY write FVelocityY;
          property UpdateSpeed : Single read FUpdateSpeed write FUpdateSpeed;
          property Decay: Real read FDecay write FDecay;
          property LifeTime: Real read FLifeTime write FLifeTime;
     end;

     TPlayerSprite = class(TAnimatedSprite)
     private
          FSpeed: Single;
          FAcc: Single;
          FDcc: Single;
          FMinSpeed: Single;
          FMaxSpeed: Single;
          FVelocityX: Single;
          FVelocityY: Single;
          FDirection: Integer;
          procedure SetSpeed(Value: Single);
          procedure SetDirection(Value: Integer);
     public
          constructor Create(const AParent: TSpriteEngine); override;
          procedure UpdatePos;
          procedure FlipXDirection;
          procedure FlipYDirection;
          procedure Accelerate; virtual;
          procedure Deccelerate; virtual;
          procedure Stop; virtual; abstract;
          procedure Resume; virtual; abstract;
          procedure Update; virtual; abstract;
          property Speed: Single read FSpeed write SetSpeed;
          property MinSpeed: Single read FMinSpeed write FMinSpeed;
          property MaxSpeed: Single read FMaxSpeed write FMaxSpeed;
          property VelocityX: Single read FVelocityX write FVelocityX;
          property VelocityY: Single read FVelocityY write FVelocityY;
          property Acceleration: Single read FAcc write FAcc;
          property Decceleration: Single read FDcc write FDcc;
          property Direction: Integer read FDirection write SetDirection;
     end;

     TJumperSprite = class(TPlayerSprite)
     private
         FJumpCount: Integer;
         FJumpSpeed: Single;
         FJumpHeight: Single;
         FMaxFallSpeed: Single;
         FDoJump: Boolean;
         FJumpState: TJumpState;
         procedure SetJumpState(Value: TJumpState);
    public
         constructor Create(const AParent: TSpriteEngine); override;
         procedure Move(const MoveCount: Single); override;
         procedure Accelerate; override;
         procedure Deccelerate; override;
         property JumpCount: Integer read FJumpCount write FJumpCount;
         property JumpState: TJumpState read FJumpState write SetJumpState;
         property JumpSpeed: Single read FJumpSpeed write FJumpSpeed;
         property JumpHeight: Single read FJumpHeight write FJumpHeight;
         property MaxFallSpeed: Single read FMaxFallSpeed write FMaxFallSpeed;
         property DoJump: Boolean read  FDoJump write FDoJump;
    end;

implementation

{    TSpriteEngine    }
constructor TSpriteEngine.Create;
begin
     inherited;
     FSpriteList := TList.Create;
     FDeadList := TList.Create;
     FWorldX := 0;
     FWorldY := 0;
     FVisibleArea.Left:=-150;
     FVisibleArea.Top:=-150;
     FVisibleArea.Right:=1024;
     FVisibleArea.Bottom:=768;
end;

destructor TSpriteEngine.Destroy;
begin
     while FSpriteList.Count > 0 do
          TSprite(FSpriteList.Items[FSpriteList.Count - 1]).Free;
     FSpriteList.Free;
     FDeadList.Free;
     inherited Destroy;
end;

procedure TSpriteEngine.Move(MoveCount: Single);
var
     i: Integer;
begin
     for i := 0 to FSpriteList.Count - 1 do
          TSprite(FSpriteList.Items[i]).Move(MoveCount);
end;

procedure TSpriteEngine.Clear;
begin
     while Count > 0 do
          Items[Count - 1].Free;
end;

procedure TSpriteEngine.Dead;
begin
     while FDeadList.Count > 0 do
          TSprite(FDeadList.Items[FDeadList.Count - 1]).Free;
end;

procedure TSpriteEngine.Draw;
var
     i: Integer;
begin
     for i := 0 to FSpriteList.Count - 1 do
           TSprite(FSpriteList.Items[i]).Draw;
end;

procedure TSpriteEngine.Collision;
var
     i, j: Integer;
begin
     for i := 0 to FSpriteList.Count - 1 do
     begin
          for j := i + 1 to FSpriteList.Count - 1 do
          begin
               if (TSprite(FSpriteList.Items[i]).DoCollision) and
                  (TSprite(FSpriteList.Items[j]).DoCollision) then
                    TSprite(FSpriteList.Items[i]).Collision(TSprite(FSpriteList.Items[j]));
          end;
     end;
end;

procedure TSpriteEngine.Remove(const Sprite: TSprite);
begin
     FSpriteList.Remove(Sprite);
end;

function TSpriteEngine.GetSprite(const Index: Integer): TSprite;
begin
     if (FSpriteList <> nil) and (Index >= 0) and (Index < FSpriteList.Count) then
          Result := FSpriteList[Index]
     else
          Result := nil;
end;

function TSpriteEngine.GetCount: Integer;
begin
     if FSpriteList <> nil then
          Result := FSpriteList.Count
     else
          Result := 0;
end;

procedure TSpriteEngine.Add(const Sprite: TSprite);
var
     L, H, Dif, I: Integer;
begin
     L := 0;
     H := FSpriteList.Count - 1;
     while (L <= H) do
     begin
          I := (L + H) div 2;
          Dif := TSprite(FSpriteList.Items[I]).FZ - Sprite.FZ;
          if (Dif < 0) then
               L := I + 1
          else
               H := I - 1;
     end;
     FSpriteList.Insert(L, Sprite);
end;

procedure TSpriteEngine.Change(Sprite: TSprite; Dest: TSpriteEngine);
begin
     Dest.Add(Sprite);
     Sprite.Engine := Dest;
     FSpriteList.Remove(Sprite);
end;

{  TSprite }

constructor TSprite.Create;
begin
     inherited Create;
     FEngine := AParent;
     FX := 200;
     FY := 200;
     FZ := 0;
     FName := '';
     FImageType := itSpriteSheet;
     FColor1 := $FFFFFFFF;
     FColor2 := $FFFFFFFF;
     FColor3 := $FFFFFFFF;
     FColor4 := $FFFFFFFF;
     FCenterX := 0;
     FCenterY := 0;
     FX1 := 0;
     FY1 := 0;
     FX2 := 10;
     FY2 := 0;
     FX3 := 10;
     FY3 := 10;
     FX4 := 0;
     FY4 := 10;
     FZ := 0;
     FRed := 255;
     FGreen := 255;
     FBlue := 255;
     FAlpha := 255;
     FPatternIndex := 0;
     FAngle := 0;
     FScaleX := 1;
     FScaleY := 1;
     FDoCenter := False;
     FOffsetX := 0;
     FOffsetY := 0;
     FMirrorX := False;
     FMirrorY := False;
     FDoCollision := False;
     FIsDead := False;
     FMoved := True;
     FDrawFx := FxBlend;
     FDrawMode := 0;
     FVisible := True;
     FTag := 0;
     Engine.Add(Self);
end;

destructor TSprite.Destroy;
begin
     Engine.Remove(Self);
     Engine.FDeadList.Remove(Self);
     inherited;
end;

procedure TSprite.Assign(const Value: TSprite);
begin
     FName := Value.Name;
     FImageName := Value.ImageName;
     FImageType := Value.ImageType;
     FX  := Value.X;
     FY  := Value.Y;
     FZ  := Value.Z;
     FX1 := Value.X1;
     FY1 := Value.Y1;
     FX2 := Value.X2;
     FY2 := Value.Y2;
     FX3 := Value.X3;
     FY3 := Value.Y3;
     FX4 := Value.X4;
     FY4 := Value.Y4;
     FOffsetX := Value.OffsetX;
     FOffsetY := Value.OffsetY;
     FCenterX := Value.CenterX;
     FCenterY := Value.CenterY;
     FMirrorX := Value.MirrorX;
     FMirrorY := Value.MirrorY;
     FWorldX  := Value.WorldX;
     FWorldY  := Value.WorldY;
     FScaleX := Value.ScaleX;
     FScaleY := Value.ScaleY;
     FDoCenter := Value.DoCenter;
     FRed := Value.Red;
     FGreen := Value.Green;
     FBlue := Value.Blue;
     FAlpha := Value.Alpha;
     FColor1 := Value.Color1;
     FColor2 := Value.Color2;
     FColor3 := Value.Color3;
     FColor4 := Value.Color4;
     FPatternIndex := Value.PatternIndex;
     FImageIndex := Value.ImageIndex;
     FCollideMethod := Value.CollideMethod;
     FDoCollision := Value.DoCollision;
     FCollisioned := Value.Collisioned;
     FCollidePos := Value.CollidePos;
     FCollideRadius := Value.CollideRadius;
     FCollideRect := Value.CollideRect;
     FCollideQuadrangle := Value.CollideQuadrangle;
     Angle := Value.Angle;
     FMoved := Value.Moved;
     FIsDead := Value.IsDead;
     FDrawFx := Value.DrawFx;
     FDrawMode := Value.DrawMode;
     FVisible := Value.Visible;
     FTag := Value.Tag;
end;

function TSprite.GetImageWidth: Integer;
begin
     Result := FEngine.Image.Image[ImageName].VisibleSize.X;
end;

function TSprite.GetImageHeight: Integer;
begin
     Result := FEngine.Image.Image[ImageName].VisibleSize.Y;
end;

function TSprite.GetPatternWidth: Integer;
begin
     Result := FEngine.Image.Image[ImageName].PatternSize.X;
end;

function TSprite.GetPatternHeight: Integer;
begin
     Result := FEngine.Image.Image[ImageName].PatternSize.Y;
end;

function TSprite.GetPatternCount: Integer;
begin
     Result := FEngine.Image.Image[ImageName].PatternCount;
end;

procedure TSprite.Draw;
var
     ImgName: string;
begin
     if (FX > FEngine.WorldX + FEngine.VisibleArea.Left)   and
        (FY > FEngine.WorldY + FEngine.FVisibleArea.Top)   and
        (FX < FEngine.WorldX + FEngine.FVisibleArea.Right) and
        (FY < FEngine.WorldY + FEngine.FVisibleArea.Bottom)then


     begin
          if not FVisible then Exit;
          case ImageType of
               itSingleImage: ImgName := FImageName + IntToStr(FImageIndex);
               itSpriteSheet: ImgName := FImageName;
          end;

          case FDrawMode of
                //1 color mode
               0: FEngine.Canvas.DrawColor1(FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         (FX + FOffsetX + FWorldX - FEngine.FWorldX)*FWorldScaleX,
                         (FY + FOffsetY + FWorldY - FEngine.FWorldY)*FWorldScaleY ,
                         FScaleX*FWorldScaleX, FScaleY*FWorldScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         FRed, FGreen, FBlue, FAlpha, FDrawFx);

               // 1 color mode +Rotaton,  no CenterX,CenterY
               1: FEngine.Canvas.DrawRotateC(FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         (FX + FWorldX + FOffsetX - FEngine.FWorldX)*FWorldScaleX,
                         (FY + FWorldY + FOffsetY - FEngine.FWorldY)*FWorldScaleY,
                         FAngle, FScaleX, FScaleY,
                         FMirrorX, FMirrorY,
                         cRGB4(FRed, FGreen, FBlue, FAlpha), FDrawFx);

               //4 color mode
               2: FEngine.Canvas.DrawColor4(FEngine.Image.Image[ImgName],
                         FPatternIndex,
                        (FX + FOffsetX + FWorldX - FEngine.FWorldX)*FWorldScaleX,
                         (FY + FOffsetY + FWorldY - FEngine.FWorldY)*FWorldScaleY ,
                         FScaleX*FWorldScaleX, FScaleY*FWorldScaleY, FDoCenter,
                         FMirrorX, FMirrorY,
                         Color1, Color2, Color3, Color4, FDrawFx);

                //1 color  mode+transform
               3: FEngine.Canvas.DrawTransForm(FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         FX1 + FWorldX + FOffsetX - FEngine.FWorldX, FY1 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX2 + FWorldX + FOffsetX - FEngine.FWorldX, FY2 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX3 + FWorldX + FOffsetX - FEngine.FWorldX, FY3 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX4 + FWorldX + FOffsetX - FEngine.FWorldX, FY4 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FMirrorX, FMirrorY,
                         cRGB4(FRed, FGreen, FBlue, FAlpha), FDrawFx);

               //4 color mode+transform
               4: FEngine.Canvas.DrawTransForm(FEngine.Image.Image[ImgName],
                         FPatternIndex,
                         FX1 + FWorldX + FOffsetX - FEngine.FWorldX, FY1 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX2 + FWorldX + FOffsetX - FEngine.FWorldX, FY2 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX3 + FWorldX + FOffsetX - FEngine.FWorldX, FY3 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FX4 + FWorldX + FOffsetX - FEngine.FWorldX, FY4 + FWorldY + FOffsetY - FEngine.FWorldY,
                         FMirrorX, FMirrorY,
                         cColor4(Color1, Color2, Color3, Color4), FDrawFx);
          end;
     end;
end;

procedure TSprite.SetColor(const Color: TColor4);
begin

end;

procedure TSprite.SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal=255);
begin
     FRed := Red;
     FGreen := Green;
     FBlue := Blue;
     FAlpha := Alpha;
end;

procedure TSprite.SetPos(X, Y: Single);
begin
     FX := X;
     FY := Y;
end;

procedure TSprite.SetPos(X, Y: Single; Z: Integer);
begin
     FX := X;
     FY := Y;
     FZ := Z;
end;


procedure TSprite.SetRed(const Value: Integer);
begin
     inherited;
     Self.FRed := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSprite.SetGreen(const Value: Integer);
begin
     inherited;
     Self.FGreen := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSprite.SetBlue(const Value: Integer);
begin
     inherited;
     Self.FBlue := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSprite.SetAlpha(const Value: Integer);
begin
     inherited;
     Self.FAlpha := Value;
     SetColor(cRGB4(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSprite.SetName(const Value: string);
begin
     Self.FName := Value;
end;

procedure TSprite.SetPatternIndex(const Value: Integer);
begin
     Self.FPatternIndex := Value;
     if FImageName = ' ' then Exit;
end;

procedure TSprite.SetImageName(const Value: string);
begin
     Self.FImageName := Value;
end;

procedure TSprite.SetX(const Value: Single);
begin
     Self.FX := Value;
end;

procedure TSprite.SetY(const Value: Single);
begin
     Self.FY := Value;
end;

procedure TSprite.SetZ(const Value: Integer);
begin
     if FZ <> Value then
     begin
          FZ := Value;
          FEngine.FSpriteList.Remove(Self);
          FEngine.Add(Self);
     end;
end;

procedure TSprite.SetDrawMode(const Value: Integer);
begin
     Self.FDrawMode := Value;
     if FDrawMode > 4 then FDrawMode := 0;
end;

procedure TSprite.Move(const MoveCount: Single);
begin
    worldScaleX:=FEngine.WorldScaleX;
    worldScaley:=FEngine.WorldScaleY;
     if not FMoved then Exit;
end;

procedure TSprite.Dead;
begin
     if not FIsDead then
     begin
          FIsDead := True;
          FEngine.FDeadList.Add(Self);
     end;
end;

procedure TSprite.Collision(const Other: TSprite);
var
     Delta: Real;
     IsCollide: Boolean;
begin
     IsCollide := False;
     FCollisioned := False;

     if (FDoCollision) and
          (Other.FDoCollision) and
          (not FIsDead) and
          (not Other.FIsDead) then
     begin
          case FCollideMethod of
               cmRadius:
                    begin
                         Delta := Sqrt(Sqr(Self.CollidePos.X - Other.CollidePos.X) +
                              Sqr(Self.CollidePos.Y - Other.CollidePos.Y));
                         IsCollide := (Delta < (Self.CollideRadius + Other.CollideRadius));
                         Collisioned := IsCollide;
                    end;

               cmRect:
                    begin
                         IsCollide := OverlapRect(Self.CollideRect, Other.CollideRect);
                         Collisioned := IsCollide;
                    end;

               cmQuadrangle:
                    begin
                         IsCollide := OverlapQuadrangle(Self.CollideQuadrangle, Other.CollideQuadrangle);
                         Collisioned := IsCollide;
                    end;

               cmPolygon:
                    begin

                    end;

          end;

          if IsCollide then
          begin
               OnCollision(Other);
               Other.OnCollision(Self);
          end;
     end;

end;

procedure TSprite.Collision;
var
   i: Integer;
begin
     for i:=0 to Engine.Count-1 do
        Self.Collision(Engine.Items[i]);
end;

procedure TSprite.OnCollision(const Sprite: TSprite);
begin
end;                    

{  TAnimSprite  }

constructor TAnimatedSprite.Create(const AParent: TSpriteEngine);
begin
     inherited;
     FDoAnimate := True;
     FAnimLooped := True;
     FAnimStart := 0;
     FAnimCount := 0;
     FAnimSpeed := 0;
     FAnimPos := 0;
     FAnimPlayMode := pmForward;
     FDoFlag1 := False;
     FDoFlag2 := False;
end;

procedure TAnimatedSprite.Assign(const Value: TSprite);
begin
     if (Value is TAnimatedSprite) then
     begin
          DoAnimate := TAnimatedSprite(Value).DoAnimate;
          AnimStart := TAnimatedSprite(Value).AnimStart;
          AnimCount := TAnimatedSprite(Value).AnimCount;
          AnimSpeed := TAnimatedSprite(Value).AnimSpeed;
          AnimLooped := TAnimatedSprite(Value).AnimLooped;
     end;
     inherited;
end;

procedure TAnimatedSprite.SetAnimStart(Value: Integer);
begin
     if FAnimStart <> Value then
     begin
          FAnimStart := Value;
          FAnimPos := Value;
     end;
end;

procedure TAnimatedSprite.Draw;
begin
     if (X > Engine.WorldX + Engine.VisibleArea.Left)   and
        (Y > Engine.WorldY + Engine.VisibleArea.Top)    and
        (X < Engine.WorldX + Engine.VisibleArea.Right)  and
        (Y < Engine.WorldY + Engine.VisibleArea.Bottom) then
          inherited;
end;

procedure TAnimatedSprite.Move(const MoveCount: Single);

begin
    worldScaleX:=FEngine.WorldScaleX;
    worldScaley:=FEngine.WorldScaleY;
     if not Moved then Exit;
     if not FDoAnimate then Exit;
     case FAnimPlayMode of

          pmForward: //12345 12345  12345
               begin
                    FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
                    if (FAnimPos > FAnimStart + FAnimCount ) then
                    begin
                         if (Trunc(FAnimPos)) = FAnimStart + FAnimCount then FAnimEnded := True;
                         if FAnimLooped then FAnimPos := FAnimStart
                         else
                         begin
                              FAnimPos := FAnimStart + FAnimCount-1 ;
                              FDoAnimate := False;
                         end;
                    end;
               end;

          pmBackward: //54321 54321 54321
               begin
                    FAnimPos := FAnimPos - FAnimSpeed * MoveCount;
                    if (FAnimPos < FAnimStart) then
                         if FAnimLooped then
                              FAnimPos := FAnimStart + FAnimCount - 1
                         else
                         begin
                              FAnimPos := FAnimStart;
                              FDoAnimate := False;
                         end;
               end;

          pmPingPong: // 12345432123454321
               begin
                    FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
                    if FAnimLooped then
                    begin
                         if (FAnimPos > FAnimStart + FAnimCount - 1) or (FAnimPos < FAnimStart) then
                              FAnimSpeed := -FAnimSpeed;
                    end
                    else
                    begin
                         if (FAnimPos > FAnimStart + FAnimCount) or (FAnimPos < FAnimStart) then
                              FAnimSpeed := -FAnimSpeed;
                         if (Trunc(FAnimPos)) = (FAnimStart + FAnimCount) then
                              FDoFlag1 := True;
                         if (Trunc(FAnimPos) = FAnimStart) and (FDoFlag1) then
                              FDoFlag2 := True;
                         if (FDoFlag1) and (FDoFlag2) then
                         begin
                             // FAnimPos := FAnimStart;
                              FDoAnimate := False;
                              FDoFlag1 := False;
                              FDoFlag2 := False;
                         end;
                    end;
               end;
     end;
     FPatternIndex := Trunc(FAnimPos);
     FImageIndex := Trunc(FAnimPos);

end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped, DoMirror, DoAnimate: Boolean;
                  PlayMode: TAnimPlayMode=pmForward);
begin
     ImageName := AniImageName;
     FAnimStart := AniStart;
     FAnimCount := AniCount;
     FAnimSpeed := AniSpeed;
     FAnimLooped:= AniLooped;
     MirrorX := DoMirror;
     FDoAnimate := DoAnimate;
     FAnimPlayMode := PlayMode;
end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped: Boolean;
                  PlayMode: TAnimPlayMode=pmForward);
begin
     ImageName := AniImageName;
     FAnimStart := AniStart;
     FAnimCount := AniCount;
     FAnimSpeed := AniSpeed;
     FAnimLooped:= AniLooped;
     FAnimPlayMode := PlayMode;
end;


{ ParticleSprite}

constructor TParticleSprite.Create(const AParent: TSpriteEngine);
begin
     inherited;
     FAccelX := 0;
     FAccelY := 0;
     FVelocityX := 0;
     FVelocityY := 0;
     FUpdateSpeed :=0;
     FDecay := 0;
     FLifeTime := 1;
end;

procedure TParticleSprite.Move(const MoveCount: Single);
begin
     inherited;
    worldScaleX:=FEngine.WorldScaleX;
    worldScaley:=FEngine.WorldScaleY;
     X:= X + FVelocityX * UpdateSpeed;
     Y:= Y + FVelocityY * UpdateSpeed;
     FVelocityX := FVelocityX + FAccelX * UpdateSpeed;
     FVelocityY := FVelocityY + FAccelY * UpdateSpeed;
     FLifeTime := FLifeTime - FDecay;
     if FLifeTime <= 0 then Dead;
end;

{  TPlayerSprite   }

constructor TPlayerSprite.Create(const AParent: TSpriteEngine);
begin
     inherited;
     FVelocityX := 0;
     FVelocityY := 0;
     Acceleration := 0;
     Decceleration := 0;
     Speed := 0;
     MinSpeed := 0;
     MaxSpeed := 0;
     FDirection := 0;
end;

procedure TPlayerSprite.SetSpeed(Value: Single);
begin
     if FSpeed > FMaxSpeed then
          FSpeed := FMaxSpeed
     else
          if FSpeed < FMinSpeed then
               FSpeed := FMinSpeed;
     FSpeed := Value;
     VelocityX := Cos256(FDirection) * Speed;
     VelocityY := Sin256(FDirection) * Speed;
end;
procedure TPlayerSprite.SetDirection(Value: Integer);
begin
     FDirection := Value;
     VelocityX := Cos256(FDirection) * Speed;
     VelocityY := Sin256(FDirection) * Speed;
end;

procedure TPlayerSprite.FlipXDirection;
begin
     if FDirection >= 64 then
          FDirection := 192 + (64 - FDirection)
     else
          if FDirection > 0 then
               FDirection := 256 - FDirection;
end;

procedure TPlayerSprite.FlipYDirection;
begin
     if FDirection > 128 then
          FDirection := 128 + (256 - FDirection)
     else
          FDirection := 128 - FDirection;
end;

procedure TPlayerSprite.Accelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed := FSpeed + FAcc;
          if FSpeed > FMaxSpeed then
               FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
          VelocityY := Sin256(FDirection) * Speed;
     end;
end;

procedure TPlayerSprite.Deccelerate;
begin
     if FSpeed <> FMinSpeed then
     begin
          FSpeed := FSpeed - FAcc;
          if FSpeed < FMaxSpeed then
               FSpeed := FMinSpeed;
          VelocityX := Cos256(FDirection) * Speed;
          VelocityY := Sin256(FDirection) * Speed;
     end;
end;

procedure TPlayerSprite.UpdatePos;
begin
     inherited;
     X := X + VelocityX;
     Y := Y + VelocityY;
end;

{ TJumperSprite }

constructor TJumperSprite.Create(const AParent: TSpriteEngine);
begin
     inherited;
     FVelocityX := 0;
     FVelocityY := 0;
     MaxSpeed := FMaxSpeed;
     FDirection := 0;
     FJumpState := jsNone;
     FJumpSpeed := 0.25;
     FJumpHeight := 8;
     Acceleration := 0.2;
     Decceleration := 0.2;
     FMaxFallSpeed := 5;
     DoJump:= False;
end;

procedure TJumperSprite.SetJumpState(Value: TJumpState);
begin
     if FJumpState <> Value then
     begin
          FJumpState := Value;
          case Value of
               jsNone,
               jsFalling:
               begin
                    FVelocityY := 0;
               end;
          end;
     end;
end;

procedure TJumperSprite.Accelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed > FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSprite.Deccelerate;
begin
     if FSpeed <> FMaxSpeed then
     begin
          FSpeed:= FSpeed+FAcc;
          if FSpeed < FMaxSpeed then
             FSpeed := FMaxSpeed;
          VelocityX := Cos256(FDirection) * Speed;
     end;
end;

procedure TJumperSprite.Move(const MoveCount: Single);
begin
    inherited;
            worldScaleX:=FEngine.WorldScaleX;
            worldScaley:=FEngine.WorldScaleY;

   case FJumpState of
          jsNone:
          begin

               if DoJump then
               begin

                    FJumpState := jsJumping;
                    VelocityY := -FJumpHeight;
               end;
          end;
          jsJumping:
          begin
               Y:=Y+FVelocityY;
               VelocityY:=FVelocityY+FJumpSpeed;
               if VelocityY > 0 then
                  FJumpState := jsFalling;
          end;
          jsFalling:
          begin
               Y:=Y+FVelocityY;
               VelocityY:=VelocityY+FJumpSpeed;
               if VelocityY > FMaxFallSpeed then
                  VelocityY := FMaxFallSpeed;
          end;
     end;

     DoJump := False;
end;



end.

//------------------------------------------------------------------------------
// XParticles.pas
// XParticle System                                              Version 1.7.0
//
// Author: 2morrowMan
// E-mail: 2morrowMan@mail.ru
//------------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//------------------------------------------------------------------------------

unit XParticles;

interface

uses XObjects, SmoothColorUnit, Classes, Types, Graphics, SysUtils, AsphyreDef,
  AsphyreImages, AsphyreCanvas, Vectors2, Math, AsphyreDb;
 
//------------------------------------------------------------------------------
{$IFDEF SUPPORTS_INLINE}
{$INLINE AUTO}
{$ENDIF}
  
//------------------------------------------------------------------------------
const
  MAX_PARTICLES_DEF = 5000;
  MAX_PSYSTEMS = 100;
  FORCE_KOEF: Single = 10.0;

  PI_2 = 1.57079632;

  PSS_EXT = '.pss';

//------------------------------------------------------------------------------
type
  TAnimType = (atNone, atForward, atBackward);

//------------------------------------------------------------------------------
  TXParticleSprite = record
    Pattern: integer;
    FrameEnd: integer;
    AnimType: TAnimType;
    DrawFx: cardinal;
  end;

//------------------------------------------------------------------------------
  PXParticle = ^TXParticle;
  TXParticle = record
    Frame,
    FrameDelta: Single;

    Location,
    Displacement: TPoint2; // From system position to particle spaw point

    Velocity: TPoint2;
    Gravity: Single;

    Accel,
    TangentialAccel: Single;

    Angle,
    AngleDelta: Single;

    Scale,
    ScaleDelta: Single;

    Color,
    ColorDelta: TSmoothColor;

    Age,
    MidAge,
    TerminalAge: Single;
  end;

//------------------------------------------------------------------------------
    {TAreaShape = (asRect, asEllipse, asPoint);

//------------------------------------------------------------------------------
    TArea = record
      Rect: TPoint4;
      Shape: TAreaShape;
    end;

//------------------------------------------------------------------------------
    TSpawnArea = record
      Area: TArea;
      InnerArea: TArea;
    end;}

//------------------------------------------------------------------------------
  PXParticleSettings = ^TXParticleSettings;
  TXParticleSettings = record
    Sprite: TXParticleSprite; // Particle texture settings
    EmissionRate: integer; // Particles per second
    LifeTime: Single;

    ParticleLifeMin,
    ParticleLifeMax: Single;

    Direction,
    Spread: Single;
    Relative: boolean;

    VelMin,
    VelMax: Single;

    GravityMin,
    GravityMax: Single;

    AccelMin,
    AccelMax: Single;

    TangentialAccelMin,
    TangentialAccelMax: Single;

    ScaleStart,
    ScaleMid,
    ScaleEnd,
    ScaleRnd: Single;

    SpinStart,
    SpinMid,
    SpinEnd,
    SpinRnd: Single;

    ColorStart,
    ColorMid,
    ColorEnd: Cardinal;
    ColorRnd,
    AlphaRnd: Single;

    // "Middle" of particle LifeTime (in %)
    Middle: Single;
    InverseRender: Boolean;
  end;

//------------------------------------------------------------------------------
  TEmitters = array of TPoint;

//------------------------------------------------------------------------------
  TEmittersFileHeader = record
    Count: Cardinal;
  end;

//------------------------------------------------------------------------------
  TXParticleSystem = class(TXObject)
  private
    FTexture: TAsphyreImage;

    FParticles: array of TXParticle;
    FCapacity: Integer;
    FSettings: TXParticleSettings;
    FEmitters: TEmitters;
    FUpdSpeed,
    FResidue: Single;
    FAge,
    FEmissionResidue: Single;
    FPrevLocation: TPoint2;
    FAngle: Single;
    FParticlesAlive: integer;

    procedure SetCapacity(Value: Integer);
  protected
    procedure UpdateSys(DeltaTime: Single);
    procedure RenderParticle(Canvas: TAsphyreCanvas; Tex: TAsphyreImage;
      X, Y, Angle, Scale, Pattern: Single; Color: Cardinal; DrawFx: Cardinal);

  public
    constructor Create(Capacity_: Integer = MAX_PARTICLES_DEF);
    destructor Destroy(); override;

    procedure Render(Canvas: TAsphyreCanvas; dx: Integer = 0; dy: Integer = 0);
    procedure Update(const DeltaTime: Single); override;

    function Load(const PSS: TXParticleSettings): boolean;
    function LoadFromStream(Stream: TStream): boolean;
    function SaveToStream(Stream: TStream): boolean;
    function LoadFromFile(const FileName: string): boolean;
    function LoadFromAsdb(ASDb: TASDb; const Key: string): boolean;
    procedure NullSettings();

    procedure StartAt(const Pos: TPoint2);
    procedure Start();
    procedure Stop(KillParticles: boolean = false);
    procedure Move(const DeltaPos: TPoint2; MoveParticles: boolean = false);
    procedure MoveTo(const Pos: TPoint2; MoveParticles: boolean = false);

    procedure AddParticle(x, y: integer);

    // Return the ID of new emitter
    function EmitterAdd(const NewEmitter: TPoint): integer;

    procedure EmittersAdd(const NewEmitters: array of TPoint);
    procedure EmittersAddFromImage(Image: TAsphyreImage; Color: Cardinal);
    procedure EmittersAddFromBitmap(Image: TBitmap; Color: Cardinal);
    procedure EmittersSaveToFile(const FileName: string);
    function EmittersLoadFromFile(const FileName: string): boolean;

    procedure RemoveEmitter(Index: Integer);
    procedure RemoveAllEmitters();
    procedure ScaleEmitters(Scale: Single);

    property Capacity: Integer read FCapacity write SetCapacity;
    property Texture: TAsphyreImage read FTexture write FTexture;
    property Emitters: TEmitters read FEmitters;
    property Settings: TXParticleSettings read FSettings write FSettings;
    property ParticlesAlive: integer read FParticlesAlive;
    property Age: Single read FAge;
    property Angle: Single read FAngle write FAngle;
  end;

//------------------------------------------------------------------------------
  TXParticleManager = class
  private
    FCanvas: TAsphyreCanvas;
    FTexture: TAsphyreImage;

    FSysCount: integer;

    // Alive particle systems
    FSystems: array[0..MAX_PSYSTEMS - 1] of TXParticleSystem;
    // Settings list
    FSettings: array of TXParticleSettings;
    FNameList: array of ShortString;

    function GetSystem(Index: Integer): TXParticleSystem;
    function GetSettings(Index: Integer): PXParticleSettings;
    function GetSettingsCount(): integer;
    function GetParticlesAlive(): integer;
  public
    constructor Create();
    destructor Destroy(); override;

    // in sec
    procedure Update(const DeltaTime: Single);
    procedure Render(dx: integer = 0; dy: integer = 0);

    function Add(const PSS: TXParticleSettings; const Name: string): integer;
    function AddFromASDb(ASDb: TASDb; const Key: string): integer;
    function AddAllFromASDb(ASDb: TASDb): integer;

    // Return settings Index by Name  
    function IndexOf(Name: string): integer;

    function Launch(Index: Integer; const Pos: TPoint2): TXParticleSystem; overload;
    function Launch(const Name: string; const Pos: TPoint2): TXParticleSystem; overload;
    function LaunchEx(const PSS: TXParticleSettings;
      pTexture: TAsphyreImage; const Pos: TPoint2): TXParticleSystem;

    procedure StopAll();

    function IsPSAlive(PS: TXParticleSystem): boolean;
    
    procedure KillPS(PS: TXParticleSystem);
    procedure KillAll();

    property Texture: TAsphyreImage read FTexture write FTexture;
    property Systems[Index: Integer]: TXParticleSystem read GetSystem;
    property Settings[Index: Integer]: PXParticleSettings read GetSettings;
    property SystemCount: Integer read FSysCount;
    property SettingsCount: Integer read GetSettingsCount;
    property ParticlesAlive: Integer read GetParticlesAlive;
  published
    property Canvas: TAsphyreCanvas read FCanvas write FCanvas;
  end;

//------------------------------------------------------------------------------
var
  RRSeed: integer = 0;

//------------------------------------------------------------------------------
function RandomSingle(const Min, Max: Single): Single;

//------------------------------------------------------------------------------
implementation

uses DXTextures, AsphyreDevices;

//------------------------------------------------------------------------------
// Helper routins
//------------------------------------------------------------------------------
function RandomSingle(const Min, Max: Single): Single;
var
  Mi, Ma: Single;
begin
  Mi := Min;
  Ma := Max;

  if (Min > Max) then
  begin
    Mi := Max;
    Ma := Min;
  end;

  RRSeed := 214013 * RRSeed + 2531011;
  Result := Mi + (RRSeed shr 16) * (1.0 / 65535.0) * (Ma - Mi);
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//  TXParticleSystem CLASS
//------------------------------------------------------------------------------
constructor TXParticleSystem.Create(Capacity_: Integer = MAX_PARTICLES_DEF);
begin
  inherited Create;

  SetCapacity(Capacity_);
  FEmissionResidue := 0.0;
  FParticlesAlive  := 0;
  FAge             := -1.0;
  FUpdSpeed        := 0.0;
  FResidue         := 0.0;
  FAngle           := 0.0;
  FPrevLocation    := 0.0;

  NullSettings();
  SetLength(FEmitters, 0);
  EmittersAdd([Point(0, 0)]);
end;

//------------------------------------------------------------------------------
destructor TXParticleSystem.Destroy();
begin
  Stop(true);
  FTexture := nil;
  RemoveAllEmitters();
  SetCapacity(0);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SetCapacity(Value: Integer);
begin
  if (Value = FCapacity) then Exit;

  FCapacity := Value;
  Setlength(FParticles, FCapacity);
end;

//------------------------------------------------------------------------------
function TXParticleSystem.Load(const PSS: TXParticleSettings): boolean;
begin
  FSettings := PSS;
  Result    := true;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.LoadFromStream(Stream: TStream): boolean;
var
  PSS: TXParticleSettings;
begin
  if (Stream <> nil) then
  begin
    Stream.Position := 0;
    Result := (Stream.Read(PSS, SizeOf(TXParticleSettings)) > 0);
    Load(PSS);
  end
  else
    Result := false;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.SaveToStream(Stream: TStream): boolean;
begin
  if (Stream <> nil) then
    Result := (Stream.Write(FSettings, SizeOf(TXParticleSettings)) > 0)
  else
    Result := false;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.LoadFromFile(const FileName: string): boolean;
var
  Stream: TFileStream;
begin
  Result := false;
  if (not FileExists(FileName)) then Exit;

  Stream := TFileStream.Create(FileName, fmOpenRead);
  Stream.Position := 0;
  Result := LoadFromStream(Stream);
  Stream.Free();
end;

//------------------------------------------------------------------------------
function TXParticleSystem.LoadFromAsdb(ASDb: TASDb; const Key: string): boolean;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create();

  if (not ASDb.ReadStream(Key, Stream)) then
  begin
    Result := false;
    Exit;
  end;

  Result := LoadFromStream(Stream);

  Stream.Free();
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.NullSettings();
begin
  FillChar(FSettings, SizeOf(TXParticleSettings), 0);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Render(Canvas: TAsphyreCanvas; dx: Integer = 0; dy: Integer = 0);
var
  i: integer;
  Par: PXParticle;
begin
  if (FParticlesAlive <= 0) then Exit;

  if (FSettings.InverseRender) then
    for i := FParticlesAlive - 1 downto 0 do
    begin
      Par := @FParticles[i];

      RenderParticle(Canvas, FTexture, dx + Par.Location.x,
        dy + Par.Location.y, Par.Angle, Par.Scale, Par.Frame,
        FromSmoothColor(Par.Color), FSettings.Sprite.DrawFx);
    end
  else
    for i := 0 to FParticlesAlive - 1 do
    begin
      Par := @FParticles[i];

      RenderParticle(Canvas, FTexture, dx + Par.Location.x,
        dy + Par.Location.y, Par.Angle, Par.Scale, Par.Frame,
        FromSmoothColor(Par.Color), FSettings.Sprite.DrawFx);
    end;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.RenderParticle(Canvas: TAsphyreCanvas; Tex: TAsphyreImage;
  X, Y, Angle, Scale, Pattern: Single; Color: Cardinal; DrawFx: Cardinal);
begin
  if (Tex = nil) or
    (X + (Tex.PatternSize.X div 2) < 0) or
    (Y + (Tex.PatternSize.Y div 2) < 0) or
    (X - (Tex.PatternSize.X div 2) > Canvas.Device.Width) or
    (Y - (Tex.PatternSize.Y div 2) > Canvas.Device.Height) then
    Exit;
                                                   
  //Canvas.Draw(Tex, X, Y, FPattern, FDrawFx);
  Canvas.DrawRot(Tex, X, Y, Angle, Scale, Color, Trunc(Pattern), DrawFx);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.AddParticle(x, y: integer);
var
  ang, c_rnd, a_rnd: Single;
  Par: PXParticle;

  r, g, b, a: Single;
  Pnt: TPoint;
  CosPhi, SinPhi: Extended;
  EmitterCount: Integer;
begin
  EmitterCount := Length(FEmitters);
  if (FParticlesAlive >= FCapacity) or (EmitterCount = 0) then Exit;

  Par := @FParticles[FParticlesAlive];

  Par.Age := 0.0;
  Par.TerminalAge := RandomSingle(FSettings.ParticleLifeMin, FSettings.ParticleLifeMax);
  Par.MidAge := Par.TerminalAge * FSettings.Middle;

  // Spawn location
  Par.Location := FPrevLocation + ((FPosition - FPrevLocation) * RandomSingle(0.0, 1.0));

  // Random select start point
  Pnt := FEmitters[Random(EmitterCount)];
  //Par.Location.x := x + Par.Location.x + Pnt.X + RandomSingle(-1.0, 1.0);
  //Par.Location.y := y + Par.Location.y + Pnt.Y + RandomSingle(-1.0, 1.0);
  Par.Location.x := x + Par.Location.x + Pnt.X;
  Par.Location.y := y + Par.Location.y + Pnt.Y;

  Par.Displacement := FPosition - Par.Location;

  //Particles direction and velocity
  ang := FSettings.Direction + FAngle +
    RandomSingle(0.0, FSettings.Spread) - FSettings.Spread / 2.0;

  if (FSettings.Relative) then
    ang := ang + VecAngle4(Point2(0, 0), FPrevLocation - FPosition);
  // SinCos is twice as fast as calling Sin and Cos separately for the same angle.
  SinCos(Ang, SinPhi, CosPhi);
  Par.Velocity.x := SinPhi;
  Par.Velocity.y := CosPhi;
  Par.Velocity   := RandomSingle(FSettings.VelMin, FSettings.VelMax) * Par.Velocity;

  // GRAVITY
  Par.Gravity := RandomSingle(FSettings.GravityMin, FSettings.GravityMax);

  // ACCELeration
  Par.Accel := RandomSingle(FSettings.AccelMin, FSettings.AccelMax);
  Par.TangentialAccel := RandomSingle(FSettings.TangentialAccelMin, FSettings.TangentialAccelMax);

  // SCALE
  Par.Scale := RandomSingle(FSettings.ScaleStart, FSettings.ScaleStart +
    (FSettings.ScaleMid - FSettings.ScaleStart) * FSettings.ScaleRnd);
  Par.ScaleDelta := (FSettings.ScaleMid - Par.Scale) / Par.MidAge;

  // SPIN
  Par.Angle := RandomSingle(FSettings.SpinStart, FSettings.SpinStart +
    (FSettings.SpinMid - FSettings.SpinStart) * FSettings.SpinRnd);
  Par.AngleDelta := (FSettings.SpinMid - Par.Angle) / Par.MidAge;

  // ANIM
  Par.Frame := FSettings.Sprite.Pattern;
  if (FSettings.Sprite.FrameEnd >= 0) and
    (FSettings.Sprite.Pattern <> FSettings.Sprite.FrameEnd) then
    Par.FrameDelta := (FSettings.Sprite.FrameEnd - Par.Frame) / Par.TerminalAge
  else
    Par.FrameDelta := 0.0;

  // Define start COLOR
  r := (FSettings.ColorStart and $FF);
  g := (FSettings.ColorStart shr 8) and $FF;
  b := (FSettings.ColorStart shr 16) and $FF;
  a := (FSettings.ColorStart shr 24) and $FF;
  c_rnd := RandomSingle(0.0, FSettings.ColorRnd);
  a_rnd := RandomSingle(0.0, FSettings.AlphaRnd);
  Par.Color := SmoothRGBA(
    (r + ((FSettings.ColorMid and $FF - r) * c_rnd)),
    (g + (((FSettings.ColorMid shr 8) and $FF - g) * c_rnd)),
    (b + (((FSettings.ColorMid shr 16) and $FF - b) * c_rnd)),
    (a + (((FSettings.ColorMid shr 24) and $FF - a) * a_rnd)),
    true);

  Par.ColorDelta := SmoothColorDelta(Par.Color, FSettings.ColorMid, Par.MidAge);
  {}
  Inc(FParticlesAlive);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Update(const DeltaTime: Single);
begin
  UpdateSys(DeltaTime);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.UpdateSys(DeltaTime: Single);
var
  i, Index, Shift: integer;
  fAux, TimeLeft: Single;
  Par: PXParticle;
  AccelVec, AccelVec2: TPoint2;

  ParticlesNeeded: Single;
  ParticlesCreated: integer;

  Middle: boolean;
begin
  if (FAge >= 0) then
  begin
    FAge := FAge + DeltaTime;
    if (FAge >= FSettings.LifeTime) then FAge := -1.0;
  end;

  // Update all ALIVE particles and remove dead

  Index := 0;
  Shift := 0;
  while (Index < FParticlesAlive) do
  begin
    if (Index > FCapacity - 1) then Break;

    if (Shift > 0) then
      FParticles[Index] := FParticles[Index + Shift];

    Par := @FParticles[Index];

    // If particle LifeTime is over remove it
    Par.Age := Par.Age + DeltaTime;
    if (Par.Age >= Par.TerminalAge) then
    begin
      Dec(FParticlesAlive);
      Inc(Shift);
      Continue;
    end;

    Middle := ((Par.Age - DeltaTime < Par.MidAge) and (Par.Age >= Par.MidAge));

    AccelVec  := Par.Location - (FPosition + Par.Displacement);
    //AccelVec := Par.Location - FPosition;
    AccelVec  := VecNorm2(AccelVec);
    AccelVec2 := AccelVec;
    AccelVec  := AccelVec * Par.Accel;

    // Rotate
    fAux := AccelVec2.x;
    AccelVec2.x := -AccelVec2.y;
    AccelVec2.y := fAux;

    AccelVec2 := AccelVec2 * Par.TangentialAccel;
    Par.Velocity := Par.Velocity + ((AccelVec + AccelVec2) * FORCE_KOEF * DeltaTime);
    Par.Velocity.y := Par.Velocity.y + (Par.Gravity * FORCE_KOEF * DeltaTime);

    Par.Location := Par.Location + Par.Velocity * DeltaTime;

    Par.Angle := Par.Angle + Par.AngleDelta * DeltaTime;
    Par.Scale := Par.Scale + Par.ScaleDelta * DeltaTime;    
    Par.Frame := Par.Frame + Par.FrameDelta * DeltaTime;

    // MIDDLE.
    if (Middle) then
    begin
      TimeLeft := Par.TerminalAge - Par.MidAge;
      // SPIN
      Par.AngleDelta := (FSettings.SpinEnd - Par.Angle) / TimeLeft;
      // SCALE
      Par.ScaleDelta := (FSettings.ScaleEnd - Par.Scale) / TimeLeft;
      // COLOR
      Par.ColorDelta := SmoothColorDelta(Par.Color, FSettings.ColorEnd, TimeLeft);
    end;

    Par.Color := NormSmoothColor(Par.Color + Par.ColorDelta * DeltaTime);
    Inc(Index);
  end;

  // Generate NEW particles      
  if (FAge >= 0.0) then
  begin
    ParticlesNeeded  := FSettings.EmissionRate * DeltaTime + FEmissionResidue;
    ParticlesCreated := Round(ParticlesNeeded);
    FEmissionResidue := ParticlesNeeded - ParticlesCreated;

    for i := 0 to ParticlesCreated - 1 do
    begin
      if (FParticlesAlive >= FCapacity) then Break;     
      AddParticle(0, 0);
    end;
  end;

  FPrevLocation := FPosition;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.EmitterAdd(const NewEmitter: TPoint): integer;
var
  Count: integer;
begin
  Count := Length(FEmitters);
  SetLength(FEmitters, Count + 1);
  FEmitters[Count] := NewEmitter;
  Result := Count;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.EmittersAdd(const NewEmitters: array of TPoint);
var
  i: integer;
begin
  for i := 0 to Length(NewEmitters) - 1 do
    EmitterAdd(NewEmitters[i]);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.EmittersAddFromImage(Image: TAsphyreImage; Color: Cardinal);
var
  x, y: integer;
begin
  if (not Assigned(Image)) then Exit;

  SetLength(FEmitters, 0);

  for x := 0 to Image.PatternSize.X - 1 do
    for y := 0 to Image.PatternSize.Y - 1 do
      if (Image.Pixels[x, y, 0] = Color) then
        EmittersAdd([Point(x, y)]);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.EmittersAddFromBitmap(Image: TBitmap; Color: Cardinal);
var
  x, y: integer;
begin
  if (not Assigned(Image)) then Exit;

  SetLength(FEmitters, 0);

  for x := 0 to Image.Width - 1 do
    for y := 0 to Image.Height - 1 do
      if (Image.Canvas.Pixels[x, y] = Color) then
        EmittersAdd([Point(x, y)]);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.EmittersSaveToFile(const FileName: string);
var
  EmtHdr: TEmittersFileHeader;
  Stream: TFileStream;
begin
  EmtHdr.Count := Length(FEmitters);

  Stream := TFileStream.Create(FileName, fmCreate);
  Stream.Position := 0;
  try
    Stream.WriteBuffer(EmtHdr, SizeOf(EmtHdr));
    Stream.WriteBuffer(FEmitters[0], SizeOf(FEmitters[0]) * EmtHdr.Count);
  finally
    Stream.Free();
  end;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.EmittersLoadFromFile(const FileName: string): boolean;
var
  EmtHdr: TEmittersFileHeader;
  Stream: TFileStream;
begin
  Result := true;

  if (not FileExists(FileName)) then Exit;

  Stream := TFileStream.Create(FileName, fmOpenRead);
  Stream.Position := 0;
  try
    try
      Stream.ReadBuffer(EmtHdr, SizeOf(EmtHdr));
      SetLength(FEmitters, EmtHdr.Count);
      Stream.ReadBuffer(FEmitters[0], SizeOf(FEmitters[0]) * EmtHdr.Count);
    except
      Result := false;
    end;
  finally
    Stream.Free();
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.ScaleEmitters(Scale: Single);
var
  i: integer;
begin
  for i := 0 to Length(FEmitters) - 1 do
  begin
    FEmitters[i].X := Round(FEmitters[i].X * Scale);
    FEmitters[i].Y := Round(FEmitters[i].Y * Scale);
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.RemoveEmitter(Index: Integer);
var
  LastId: integer;
begin
  LastId := Length(FEmitters) - 1;
  if (Index < 0)or(Index > LastId - 1) then Exit;

  FEmitters[Index] := FEmitters[LastId];
  SetLength(FEmitters, LastId);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.RemoveAllEmitters();
begin
  SetLength(FEmitters, 0);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.StartAt(const Pos: TPoint2);
begin
  Stop();
  MoveTo(Pos);
  Start();
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Start();
begin
  if (Length(FEmitters) = 0) then Exit;

  if (FSettings.Lifetime <= 0.0) then
    FAge := -1.0
  else
    FAge := 0.0;

  FResidue := 0.0;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Stop(KillParticles: boolean = false);
begin
  FAge := -1.0;
  if (KillParticles) then FParticlesAlive := 0;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Move(const DeltaPos: TPoint2; MoveParticles: boolean = false);
var
  i: Integer;

begin
  if (MoveParticles) then
  begin
    for i := 0 to FParticlesAlive - 1 do
      FParticles[i].Location := FParticles[i].Location + DeltaPos;

    FPrevLocation := FPrevLocation + DeltaPos;
  end
  else
  begin
    if (Age < 0.0) then
      FPrevLocation := FPosition + DeltaPos
    else
      FPrevLocation := FPosition;
  end;

  FPosition := FPosition + DeltaPos;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.MoveTo(const Pos: TPoint2; MoveParticles: boolean = false);
begin
  Move(Pos - FPosition, MoveParticles);
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TXParticleManager.
//------------------------------------------------------------------------------
constructor TXParticleManager.Create();
begin
  FCanvas   := nil;
  FTexture  := nil;
  FSysCount := 0;
end;

//------------------------------------------------------------------------------
destructor TXParticleManager.Destroy();
begin
  KillAll();

  inherited;
end;
//------------------------------------------------------------------------------
procedure TXParticleManager.Update(const DeltaTime: Single);
var
  i: integer;
begin
  i := 0;
  while (i <= FSysCount - 1) do
  begin
    FSystems[i].Update(DeltaTime);

    if (FSystems[i] <> nil) and (FSystems[i].Age < 0.0) and
      (FSystems[i].ParticlesAlive = 0) then
    begin
      FSystems[i].Free();
      FSystems[i] := FSystems[FSysCount - 1];
      Dec(FSysCount);
    end
    else Inc(i);
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleManager.Render(dx: integer = 0; dy: integer = 0);
var
  i: integer;
begin
  for i := 0 to FSysCount - 1 do
    FSystems[i].Render(FCanvas, dx, dy)
end;

//------------------------------------------------------------------------------
// Return ID of added Settings 
function TXParticleManager.Add(const PSS: TXParticleSettings; const Name: string): integer;
var
  cnt: integer;
begin
  cnt := Length(FSettings);
  Inc(cnt);
  SetLength(FSettings, cnt);
  SetLength(FNameList, cnt);
  Result := cnt - 1;
  FSettings[Result] := PSS;
  FNameList[Result] := LowerCase(Name);
end;

//------------------------------------------------------------------------------
// Return ID of added Settings 
function TXParticleManager.AddFromASDb(ASDb: TASDb; const Key: string): integer;
var
  tmpSys: TXParticleSystem;
begin
  tmpSys := TXParticleSystem.Create();
  tmpSys.LoadFromAsdb(ASDb, Key);
  Result := Add(tmpSys.Settings, Key);
  tmpSys.Free();
end;

//------------------------------------------------------------------------------
// Return added Settings count
function TXParticleManager.AddAllFromASDb(ASDb: TASDb): integer;
var
  i, cnt: integer;
begin
  cnt := 0;
  for i := 0 to ASDb.RecordCount - 1 do
    if (ExtractFileExt(ASDb.RecordKey[i]) = PSS_EXT) then
    begin
      AddFromASDb(ASDb, ASDb.RecordKey[i]);
      Inc(cnt);
    end;

  Result := cnt;
end;

//------------------------------------------------------------------------------
// Launch particles by ID
function TXParticleManager.Launch(Index: Integer; const Pos: TPoint2): TXParticleSystem;
begin
  Result := nil;
  if (Index >= 0)and(Index < Length(FSettings)) then
    Result := LaunchEx(FSettings[Index], FTexture, Pos);
end;

//------------------------------------------------------------------------------
// Launch particles by Name
function TXParticleManager.Launch(const Name: string; const Pos: TPoint2): TXParticleSystem;
var
  Index: integer;
begin
  Result := nil;
  Index := IndexOf(Name);
  if (Index >= 0) then
    Result := Launch(Index, Pos);  
end;

//------------------------------------------------------------------------------
function TXParticleManager.LaunchEx(const PSS: TXParticleSettings;
  pTexture: TAsphyreImage; const Pos: TPoint2): TXParticleSystem;
var
  NewSys: TXParticleSystem;
begin
  if (FSysCount >= MAX_PSYSTEMS) then
  begin
    Result := nil;
    Exit;
  end;

  NewSys := TXParticleSystem.Create();
  with NewSys do
  begin
    Load(PSS);
    Texture := pTexture;
    MoveTo(Pos);
    Start();
  end;
  
  FSystems[FSysCount] := NewSys;
  Result := NewSys;

  Inc(FSysCount);
end;

//------------------------------------------------------------------------------
procedure TXParticleManager.StopAll();
var
  i: integer;
begin
  for i := 0 to FSysCount - 1 do
    FSystems[i].Stop();
end;

//------------------------------------------------------------------------------
function TXParticleManager.IsPSAlive(PS: TXParticleSystem): boolean;
var
  i: integer;
begin
  Result := false;

  for i := 0 to FSysCount - 1 do
    if (FSystems[i] = PS) then
    begin
      Result := true;
      Break;
    end;
end;

//------------------------------------------------------------------------------
procedure TXParticleManager.KillPS(PS: TXParticleSystem);
var
  i: integer;
begin
  for i := 0 to FSysCount - 1 do
  begin
    if (FSystems[i] = PS) then
    begin
      FSystems[i].Free();
      FSystems[i] := FSystems[FSysCount - 1];
      FNameList[i] := FNameList[FSysCount - 1];
      Dec(FSysCount);
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleManager.KillAll();
var
  i: integer;
begin
  for i := 0 to FSysCount - 1 do FSystems[i].Free();
  FSysCount := 0;
  SetLength(FNameList, 0);
end;

//------------------------------------------------------------------------------
function TXParticleManager.GetSystem(Index: Integer): TXParticleSystem;
begin
  Result := nil;
  if (Index >= 0)and(Index < SystemCount) then
    Result := FSystems[Index];
end;

//------------------------------------------------------------------------------
function TXParticleManager.GetSettings(Index: Integer): PXParticleSettings;
begin
  Result := nil;
  if (Index > 0)and(Index < SettingsCount) then
    Result := @FSettings[Index];
end;

//------------------------------------------------------------------------------
// Return settings ID by Name
function TXParticleManager.IndexOf(Name: string): integer;
var
  i: integer;
begin
  Result := -1;
  Name := LowerCase(Name);
  for i := 0 to Length(FNameList) - 1 do
    if (Name = FNameList[i]) then
    begin
      Result := i;
      break;
    end;
end;

//------------------------------------------------------------------------------
function TXParticleManager.GetSettingsCount(): integer;
begin
  Result := Length(FSettings);
end;

//------------------------------------------------------------------------------
function TXParticleManager.GetParticlesAlive(): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to FSysCount - 1 do
    Result := Result + FSystems[i].ParticlesAlive;
end;

//------------------------------------------------------------------------------
end.


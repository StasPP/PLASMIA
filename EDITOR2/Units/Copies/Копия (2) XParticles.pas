//------------------------------------------------------------------------------
// XParticles.pas
// XParticle System                                              Version 1.8.0
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

uses XObjects, SmoothColorUnit, Classes, Types, Graphics, SysUtils, AsphyreTypes,
  AsphyreImages, AsphyreCanvas, Vectors2, Math, AsphyreDb, AsphyreDevices,
  AsphyreEffects, AsphyreXML, MediaUtils, XMLUtils;
 
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
  {TXParticleSprite = record
    Pattern: integer;
    FrameEnd: integer;
    AnimType: TAnimType;
    DrawFx: cardinal;
  end;}

//------------------------------------------------------------------------------
  PXParticle = ^TXParticle;
  TXParticle = record
    Frame,
    FrameDelta: Single;

    Location,
    Displacement: TPoint2; // From system position to particle spawn point

    Velocity: TPoint2;
    Gravity: Single;

    Accel,
    TangAccel: Single;

    Angle,
    AngleDelta: Single;

    Scale,
    ScaleDelta: TPoint2;

    Color,
    ColorDelta: TSmoothColor;
    RenderColor: Cardinal;

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
    Uid: string;//[32];

    TexUid  : string;//[32];
    Texture : TAsphyreImage;
    Pattern : integer;
    DrawFx  : cardinal;

    FrameEnd: integer;
    AnimType: TAnimType;

    BackwardRender: Boolean;

    //Sprite: TXParticleSprite; // Particle texture settings
    EmissionRate: integer; // Particles per second
    LifeTime: Single;

    ParticleLifeMin,
    ParticleLifeMax: Single;
    Middle: Single;

    Direction: Single;
    Relative : boolean;
    Spread   : Single;
    ThreadCount  : Integer;
    ThreadIndexed: Boolean;   

    VelMin,
    VelMax: Single;

    GravityMin,
    GravityMax: Single;

    AccelMin,
    AccelMax: Single;

    TangAccelMin,
    TangAccelMax: Single;

    ScaleStart,
    ScaleMid,
    ScaleEnd: TPoint2;
    ScaleRnd: Single;

    SpinMin,
    SpinMax: Single;
    {SpinStart,
    SpinMid,
    SpinEnd,
    SpinRnd: Single;}

    ColorStart,
    ColorMid,
    ColorEnd: Cardinal;
    ColorRnd,
    AlphaRnd: Single;

    ClipRect: TRect;
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
    FTexture    : TAsphyreImage;
    FDevice     : TAsphyreDevice;
    FDeviceIndex: Integer;

    FCapacity : Integer;
    FParticles: array of TXParticle;
    FSettings : TXParticleSettings;
    FEmitters : TEmitters;

    FAge,
    FEmissionResidue: Single;
    FAngle: Single;
    FParticlesAlive: integer;

    // helpers
    FPrevLocation: TPoint2;
    FResidue     : Single;
    FThreadIndex : Integer;

    procedure SetTexture(Value: TAsphyreImage);
    procedure SetCapacity(Value: Integer);
    function GetEmitterCount(): Integer;
    function GetClipRect(): TRect;
    procedure SetClipRect(const Value: TRect);
    procedure SetDeviceIndex(Index: Integer);
  protected
    procedure UpdateSys(DeltaTime: Single);
    procedure ProccessParticle(pPar: PXParticle; Time: Single);
    procedure RenderParticle(Canvas: TAsphyreCanvas; Tex: TAsphyreImage;
      X, Y, Angle, Pattern: Single; Scale: TPoint2; Color: Cardinal; DrawFx: Cardinal);
    procedure ValidateClipRect();
  public
    constructor Create(Capacity_: Integer = MAX_PARTICLES_DEF);
    destructor Destroy(); override;

    procedure UpdateTexture();

    procedure Render(dx: Integer = 0; dy: Integer = 0);// inline;
    procedure Update(DeltaTime: Single); override;

    function Load(const PSS: TXParticleSettings): boolean;
    function LoadFromStream(Stream: TStream): boolean;
    function SaveToStream(Stream: TStream): boolean;
    function LoadFromFile(const FileName: string): boolean;
    function LoadFromAsdb(ASDb: TASDb; const Key: string): boolean;
    procedure ResetSettings();

    function  ParseSettingsFile(const FileName: string): Boolean;
    procedure ParseXML(Node: TXMLNode);
    procedure SaveToXMLFile(const FileName: string);
    
    function  ParseEmittersFile(const FileName: string): Boolean;
    procedure ParseEmittersXML(Node: TXMLNode);
    procedure SaveEmittersToXMLFile(const FileName: string);

    procedure StartAt(const Pos: TPoint2);
    procedure Start();
    procedure Stop(RemoveParticles: boolean = false);
    procedure Move(const DeltaPos: TPoint2; MoveParticles: boolean = false);
    procedure MoveTo(const Pos: TPoint2; MoveParticles: boolean = false);

    function AddParticle(x, y: integer): PXParticle;

    // Return the ID of new emitter
    function EmitterAdd(const NewEmitter: TPoint): integer;

    procedure EmittersAdd(const NewEmitters: array of TPoint);
    //procedure EmittersAddFromImage(Image: TAsphyreImage; Color: Cardinal);
    procedure EmittersAddFromBitmap(Image: TBitmap; Color: Cardinal);
    procedure EmittersSaveToFile(const FileName: string);
    function EmittersLoadFromFile(const FileName: string): boolean;

    procedure RemoveEmitter(Index: Integer);
    procedure RemoveAllEmitters();
    procedure ScaleEmitters(Scale: TPoint2);

    property DeviceIndex: Integer read FDeviceIndex write SetDeviceIndex;
    property Texture : TAsphyreImage read FTexture write SetTexture;
    property ClipRect: TRect read GetClipRect write SetClipRect;
    property Settings: TXParticleSettings read FSettings;
    property Emitters: TEmitters read FEmitters;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Age     : Single read FAge;
    property Angle   : Single read FAngle write FAngle;
    property ParticlesAlive: integer read FParticlesAlive;
    property EmitterCount: Integer read GetEmitterCount;
  end;

//------------------------------------------------------------------------------
  TXParticleManager = class
  private
    FDeviceIndex: Integer;

    FSystems : array[0..MAX_PSYSTEMS - 1] of TXParticleSystem;
    FSettings: array of TXParticleSettings;
    FSysCount: integer;

    function GetSystem(Index: Integer): TXParticleSystem;
    function GetSettings(Index: Integer): PXParticleSettings;
    function GetSettingsCount(): integer;
    function GetParticlesAlive(): integer;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure UpdateTextures();

    // in sec
    procedure Update(DeltaTime: Single);
    procedure Render(dx: integer = 0; dy: integer = 0);

    function Add(const PSS: TXParticleSettings): integer;
    function AddFromASDb(ASDb: TASDb; const Key: string): integer;
    function AddAllFromASDb(ASDb: TASDb): integer;

    // Return settings Index by Name  
    function IndexOf(Name: string): integer;

    function Launch(Index: Integer; const Pos: TPoint2): TXParticleSystem; overload;
    function Launch(const Name: string; const Pos: TPoint2): TXParticleSystem; overload;
    function LaunchEx(const PSS: TXParticleSettings; const Pos: TPoint2): TXParticleSystem;

    procedure StopAll();

    function IsPSAlive(PS: TXParticleSystem): boolean;
    
    procedure KillPS(PS: TXParticleSystem);
    procedure KillAll();

    procedure ParseXML(Node: TXMLNode);
    function ParseXMLFile(const FileName: string): Boolean;

    property DeviceIndex: Integer read FDeviceIndex write FDeviceIndex;
    property Systems[Index: Integer]: TXParticleSystem read GetSystem;
    property Settings[Index: Integer]: PXParticleSettings read GetSettings;
    property SystemCount: Integer read FSysCount;
    property SettingsCount: Integer read GetSettingsCount;
    property ParticlesAlive: Integer read GetParticlesAlive;
  end;

//------------------------------------------------------------------------------
var
  RRSeed: integer = 0;

//------------------------------------------------------------------------------
function RandomSingle(const Min, Max: Single): Single;

//------------------------------------------------------------------------------
implementation

uses Direct3D9;

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
  FResidue         := 0.0;
  FAngle           := 0.0;
  FPosition        := Point2(0.0, 0.0);
  FPrevLocation    := Point2(0.0, 0.0);

  FThreadIndex     := 0;

  ResetSettings();
  SetLength(FEmitters, 0);
  EmitterAdd(Point(0, 0));

  FDeviceIndex := 0;
  FDevice      := Devices[FDeviceIndex];
end;

//------------------------------------------------------------------------------
destructor TXParticleSystem.Destroy();
begin
  Stop(true);
  FDevice  := nil;
  FTexture := nil;
  RemoveAllEmitters();
  SetCapacity(0);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.UpdateTexture();
begin
  if (FDevice <> nil) and (FSettings.TexUid <> '') then
    SetTexture(TAsphyreImage(FDevice.Images.Image[FSettings.TexUid]));
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SetTexture(Value: TAsphyreImage);
begin
  FTexture := Value;
  FSettings.Texture := Value;
  if (FTexture <> nil) then FSettings.TexUid := FTexture.Name;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SetCapacity(Value: Integer);
begin
  if (Value = FCapacity) then Exit;

  SetLength(FParticles, Value);
  FCapacity := Value;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.GetClipRect(): TRect;
begin
  Result := FSettings.ClipRect;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SetClipRect(const Value: TRect);
begin
  FSettings.ClipRect := Value;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SetDeviceIndex(Index: Integer);
begin
  FDeviceIndex := Index;
  FDevice      := Devices[Index];
end;

//------------------------------------------------------------------------------
function TXParticleSystem.Load(const PSS: TXParticleSettings): boolean;
begin
  FSettings := PSS;
  FTexture  := FSettings.Texture;
  ValidateClipRect();
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
procedure TXParticleSystem.ResetSettings();
begin
  FillChar(FSettings, SizeOf(TXParticleSettings), 0);
  FSettings.ScaleStart := Point2(1.0, 1.0);
  FSettings.ScaleMid   := Point2(1.0, 1.0);
  FSettings.ScaleEnd   := Point2(1.0, 1.0);
  FSettings.Middle     := 0.5;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.ValidateClipRect();
begin
  if (FSettings.ClipRect.Left >= FSettings.ClipRect.Right)and(FDevice <> nil) then
    FSettings.ClipRect.Right := FDevice.Params.BackBufferWidth;

  if (FSettings.ClipRect.Top >= FSettings.ClipRect.Bottom)and(FDevice <> nil) then
    FSettings.ClipRect.Bottom := FDevice.Params.BackBufferHeight;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Render(dx: Integer = 0; dy: Integer = 0);
var
  i: integer;
  Par: PXParticle;
begin
  if (FParticlesAlive <= 0) then Exit;

  if (FSettings.BackwardRender) then
    for i := FParticlesAlive - 1 downto 0 do
    begin
      Par := @FParticles[i];

      RenderParticle(FDevice.Canvas, FTexture, dx + Par.Location.x,
        dy + Par.Location.y, Par.Angle, Par.Frame,  Par.Scale,
        Par.RenderColor, FSettings.DrawFx);
    end
  else
    for i := 0 to FParticlesAlive - 1 do
    begin
      Par := @FParticles[i];

      RenderParticle(FDevice.Canvas, FTexture, dx + Par.Location.x,
        dy + Par.Location.y, Par.Angle, Par.Frame, Par.Scale,
        Par.RenderColor, FSettings.DrawFx);
    end;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.RenderParticle(Canvas: TAsphyreCanvas; Tex: TAsphyreImage;
  X, Y, Angle, Pattern: Single; Scale: TPoint2; Color: Cardinal; DrawFx: Cardinal);
var
  Pos   : TPoint2;
  Size  : TPoint2;
  Middle: TPoint2;
  CRect : TRect;
begin
  CRect := ClipRect;

  if (Tex <> nil) then Size := Point2(Tex.PatternSize.x * Scale.x, Tex.PatternSize.y * Scale.y)
  else Size := Point2(Scale.x, Scale.y); //Point2(1.0, 1.0);

  if ((X + (Size.x / 2) < CRect.Left) or
     (Y + (Size.y / 2) < CRect.Top) or
     (X - (Size.x / 2) > CRect.Right) or
     (Y - (Size.y / 2) > CRect.Bottom)) then Exit;


  Pos := Point2(x, y);
  Middle := Point2(Size.x * 0.5, Size.y * 0.5);

  if (Tex <> nil) then
  begin
    Canvas.UseImage(Tex, Trunc(Pattern));
    //Canvas.UseImage(Tex, Trunc(Pattern), pRotate4(Point2(0, 0), Size, Middle, Angle, 1.0));
    Canvas.TexMap(pRotate4(Point2(X, Y), Size, Middle, Angle, 1.0), cColor4(Color), DrawFx or fxfDiffuse);
    //Canvas.TexMap(pRotate4c(Point2(X, Y), Size, Angle, 1.0), cColor4(Color), DrawFx);
    //Canvas.TexMap(Tex, pRotate4(Pos, Size, Middle, Angle, 1.0), cColor4(Color),
    //  tPattern(Trunc(Pattern)), DrawFx)
  end
  else
  begin
    //if (Size.x = 1.0)and(Size.y = 1.0) then
    Canvas.PutPixel(X, Y, Color, DrawFx)
    //else Canvas.FillQuad(pRotate4(Pos, Size, Middle, Angle, 1.0), cColor4(Color), DrawFx);
  end;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.AddParticle(x, y: integer): PXParticle;
var
  ang, rnd, c_rnd, a_rnd: Single;
  Par: PXParticle;

  r, g, b, a: Cardinal;
  Pnt: TPoint;
  CosPhi, SinPhi: Extended;
  EmitterCount: Integer;
begin
  Result := nil;
  EmitterCount := Length(FEmitters);
  if (FParticlesAlive >= FCapacity) or (EmitterCount = 0) then Exit;

  Par := @FParticles[FParticlesAlive];

  Par.Age         := 0.0;
  Par.TerminalAge := RandomSingle(FSettings.ParticleLifeMin, FSettings.ParticleLifeMax);
  Par.MidAge      := Par.TerminalAge * FSettings.Middle;

  // New particle will be rendomly located between previous and current position
  Par.Location := FPrevLocation + ((FPosition - FPrevLocation) * RandomSingle(0.0, 1.0));

  // Random select start point
  Pnt := FEmitters[Random(EmitterCount)];
  //Par.Location.x := x + Par.Location.x + Pnt.X + RandomSingle(-1.0, 1.0);
  //Par.Location.y := y + Par.Location.y + Pnt.Y + RandomSingle(-1.0, 1.0);
  Par.Location.x := x + Par.Location.x + Pnt.X;
  Par.Location.y := y + Par.Location.y + Pnt.Y;

  Par.Displacement := FPosition - Par.Location;

  //Particles direction and velocity
  if (FSettings.ThreadCount > 0) then
  begin
    if (FThreadIndex >= FSettings.ThreadCount) then FThreadIndex := 0;
    ang := FSettings.Spread / FSettings.ThreadCount;
    if (FSettings.ThreadIndexed) then ang := ang * FThreadIndex
    else ang := ang * Random(FSettings.ThreadCount);
    Inc(FThreadIndex);
  end
  else ang := RandomSingle(0.0, FSettings.Spread) - FSettings.Spread / 2.0;

  ang := FSettings.Direction + FAngle + ang;
  if (FSettings.Relative) then
    ang := ang + Angle2(FPrevLocation - FPosition - Point2(0, 0));
  // SinCos is twice as fast as calling Sin and Cos separately for the same angle.
  SinCos(Ang, SinPhi, CosPhi);
  Par.Velocity.x := SinPhi;
  Par.Velocity.y := CosPhi;
  rnd := RandomSingle(FSettings.VelMin, FSettings.VelMax);
  Par.Velocity   := Par.Velocity * Point2(rnd, rnd);

  // GRAVITY
  Par.Gravity := RandomSingle(FSettings.GravityMin, FSettings.GravityMax);

  // ACCELeration
  Par.Accel := RandomSingle(FSettings.AccelMin, FSettings.AccelMax);
  Par.TangAccel := RandomSingle(FSettings.TangAccelMin, FSettings.TangAccelMax);

  // SCALE
  rnd := RandomSingle(0.0, FSettings.ScaleRnd);
  Par.Scale.x := FSettings.ScaleStart.x +
    (FSettings.ScaleMid.x - FSettings.ScaleStart.x) * rnd;
  Par.Scale.y := FSettings.ScaleStart.y +
    (FSettings.ScaleMid.y - FSettings.ScaleStart.y) * rnd;
  Par.ScaleDelta.x := (FSettings.ScaleMid.x - Par.Scale.x) / Par.MidAge;
  Par.ScaleDelta.y := (FSettings.ScaleMid.y - Par.Scale.y) / Par.MidAge;

  // SPIN
  Par.AngleDelta := RandomSingle(FSettings.SpinMin, FSettings.SpinMax);
  Par.Angle      := Par.AngleDelta;

  // ANIM
  Par.Frame := FSettings.Pattern;
  if (FSettings.FrameEnd >= 0) and
    (FSettings.Pattern <> FSettings.FrameEnd) then
    Par.FrameDelta := (FSettings.FrameEnd - Par.Frame) / Par.TerminalAge
  else Par.FrameDelta := 0.0;

  // Define start COLOR
  a := (FSettings.ColorStart shr 24) and $FF;
  r := (FSettings.ColorStart shr 16) and $FF;
  g := (FSettings.ColorStart shr 8) and $FF;
  b := (FSettings.ColorStart and $FF);
  c_rnd := RandomSingle(0.0, FSettings.ColorRnd);
  a_rnd := RandomSingle(0.0, FSettings.AlphaRnd);
  Par.Color := SmoothRGBA(
    (a + (((FSettings.ColorMid shr 24) and $FF - a) * a_rnd)),
    (r + (((FSettings.ColorMid shr 16) and $FF - r) * c_rnd)),
    (g + (((FSettings.ColorMid shr 8) and $FF - g) * c_rnd)),
    (b + ((FSettings.ColorMid and $FF - b) * c_rnd)), true);

  Par.ColorDelta  := SmoothColorDelta(Par.Color, FSettings.ColorMid, Par.MidAge);
  Par.RenderColor := FromSmoothColor(Par.Color);
  {}
  Inc(FParticlesAlive);
  Result := Par;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.ProccessParticle(pPar: PXParticle; Time: Single);
var
  AccelVec, AccelVec2: TPoint2;
  Middle: boolean;
  fAux, TimeLeft: Single;
begin
    if (pPar = nil) or (Time = 0.0) then Exit;    

    Middle := ((pPar.Age - Time < pPar.MidAge) and (pPar.Age >= pPar.MidAge));

    pPar.Age := pPar.Age + Time;

    AccelVec  := pPar.Location - (FPosition + pPar.Displacement);
    //AccelVec := pPar.Location - FPosition;
    AccelVec  := Norm2(AccelVec);
    AccelVec2 := AccelVec;
    AccelVec  := AccelVec * pPar.Accel;

    // Rotate
    fAux        := AccelVec2.x;
    AccelVec2.x := -AccelVec2.y;
    AccelVec2.y := fAux;

    AccelVec2       := AccelVec2 * pPar.TangAccel;
    pPar.Velocity   := pPar.Velocity + ((AccelVec + AccelVec2) * FORCE_KOEF * Time);
    pPar.Velocity.y := pPar.Velocity.y + (pPar.Gravity * FORCE_KOEF * Time);

    pPar.Location := pPar.Location + pPar.Velocity * Time;

    pPar.Angle := pPar.Angle + pPar.AngleDelta * Time;
    pPar.Scale := pPar.Scale + pPar.ScaleDelta * Time;
    pPar.Frame := pPar.Frame + pPar.FrameDelta * Time;

    // MIDDLE.
    if (Middle) then
    begin
      TimeLeft := pPar.TerminalAge - pPar.MidAge;
      // SPIN
      //pPar.AngleDelta := (FSettings.SpinEnd - pPar.Angle) / TimeLeft;
      // SCALE
      pPar.ScaleDelta.x := (FSettings.ScaleEnd.x - pPar.Scale.x) / TimeLeft;
      pPar.ScaleDelta.y := (FSettings.ScaleEnd.y - pPar.Scale.y) / TimeLeft;
      // COLOR
      pPar.ColorDelta := SmoothColorDelta(pPar.Color, FSettings.ColorEnd, TimeLeft);
    end;

    pPar.Color       := NormSmoothColor(pPar.Color + pPar.ColorDelta * Time);
    pPar.RenderColor := FromSmoothColor(pPar.Color);
end;
                       
//------------------------------------------------------------------------------
procedure TXParticleSystem.Update(DeltaTime: Single);
begin
  UpdateSys(DeltaTime);
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.UpdateSys(DeltaTime: Single);
var
  i, Index, Shift: integer;
  Par: PXParticle;
  ParticlesNeeded: Single;
  ParticlesCreated: integer;
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
    if (Index >= FCapacity) then Break;

    Par := @FParticles[Index + Shift];

    // If particle LifeTime is over remove it
    if (Par.Age >= Par.TerminalAge) then
    begin
      Dec(FParticlesAlive);
      Inc(Shift);
      Continue;
    end;

    // Copy next NOT dead particle to free cell
    if (Shift > 0) then
    begin
      FParticles[Index] := FParticles[Index + Shift];
      Par := @FParticles[Index];
    end;

    ProccessParticle(Par, DeltaTime);

    Inc(Index);
  end;

  // Generate NEW particles
  if (FAge > 0.0) then
  begin
    ParticlesNeeded  := FSettings.EmissionRate * DeltaTime + FEmissionResidue;
    ParticlesCreated := Round(ParticlesNeeded);
    FEmissionResidue := ParticlesNeeded - ParticlesCreated;

    for i := 0 to ParticlesCreated - 1 do
    begin
      if (FParticlesAlive >= FCapacity) then Break;
      AddParticle(0, 0);     
      //Par := AddParticle(0, 0);
      //ProccessParticle(Par, DeltaTime - DeltaTime / ParticlesCreated * (i + 1));
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
{procedure TXParticleSystem.EmittersAddFromImage(Image: TAsphyreImage; Color: Cardinal);
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
}

//------------------------------------------------------------------------------
procedure TXParticleSystem.EmittersAddFromBitmap(Image: TBitmap; Color: Cardinal);
var
  x, y: integer;
begin
  if (not Assigned(Image)) then Exit;

  RemoveAllEmitters();

  for x := 0 to Image.Width - 1 do
    for y := 0 to Image.Height - 1 do
      if (Image.Canvas.Pixels[x, y] = Color) then EmittersAdd([Point(x, y)]);
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
procedure TXParticleSystem.ScaleEmitters(Scale: TPoint2);
var
  i: integer;
begin
  for i := 0 to Length(FEmitters) - 1 do
  begin
    FEmitters[i].X := Round(FEmitters[i].X * Scale.x);
    FEmitters[i].Y := Round(FEmitters[i].Y * Scale.y);
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
function TXParticleSystem.GetEmitterCount(): Integer;
begin
  Result :=Length(FEmitters);
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

  ValidateClipRect();

  if (FSettings.Lifetime <= 0.0) then FAge := -1.0
  else FAge := 0.0;

  FResidue := 0.0;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.Stop(RemoveParticles: boolean = false);
begin
  FAge := -1.0;
  if (RemoveParticles) then FParticlesAlive := 0;
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
    if (FAge < 0.0) then FPrevLocation := FPosition + DeltaPos
    else FPrevLocation := FPosition;
  end;
  
  FPosition := FPosition + DeltaPos;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.MoveTo(const Pos: TPoint2; MoveParticles: boolean = false);
begin
  Move(Pos - FPosition, MoveParticles);
end;

//------------------------------------------------------------------------------
function TXParticleSystem.ParseSettingsFile(const FileName: string): Boolean;
var
  Root, Node: TXMLNode;
begin
  Result := false;
  Root := LoadXMLFromFile(FileName);
  if (Root = nil) or (LowerCase(Root.Name) <> 'xparticles') then
  begin
    Root.Free();
    Exit;
  end;

  Node := Root.ChildNode['xsettings'];
  if (Node <> nil) then
  begin
    ParseXML(Node);
    Result := true;
  end;

  Node := Root.ChildNode['emitters'];
  if (Node <> nil) then
  begin
    ParseEmittersXML(Node);
    Result := true;
  end;

  Root.Free();
end;


//------------------------------------------------------------------------------
procedure TXParticleSystem.ParseXML(Node: TXMLNode);
var
  Aux, HlpNode: TXMLNode;
  Sett : TXParticleSettings;
  float: Single;
begin
  if (Node = nil) or (LowerCase(Node.Name) <> 'xsettings') then Exit;

  //<system uid="prototype" lifeTime="8640000" backwardRender="false"/>
  Aux := Node.ChildNode['system'];
  if (Aux <> nil) then
  begin
    Sett.Uid := Aux.FieldValue['uid'];
    Sett.LifeTime := ParseFloat(Aux.FieldValue['lifetime']);
    Sett.BackwardRender := ParseBool(Aux.FieldValue['backwardrender']);
  end;

  //<texture image="images/particles" pattern="0" drawFx="fxuAdd"/>
  Aux := Node.ChildNode['texture'];
  if (Aux <> nil) then
  begin
    Sett.TexUid  := Aux.FieldValue['image'];
    Sett.Pattern := ParseInt(Aux.FieldValue['pattern'], 0);
    Sett.DrawFx  := StrToDrawFx(Aux.FieldValue['drawfx']);
  end;

  //<particle lifemin="1.5" lifemax="2.1" middle="0.5"/>
  Aux := Node.ChildNode['particle'];
  if (Aux <> nil) then
  begin
    Sett.ParticleLifeMin := ParseFloat(Aux.FieldValue['lifemin']);
    Sett.ParticleLifeMax := ParseFloat(Aux.FieldValue['lifemax']);
    Sett.Middle          := ParseFloat(Aux.FieldValue['middle']);
  end;

  //<color start="$FFFFFFFF" mid="$80FFFFFF" end="$10FFFFFF" rnd="0.0"/>
  Aux := Node.ChildNode['color'];
  if (Aux <> nil) then
  begin
    Sett.ColorStart := ParseCardinal(Aux.FieldValue['start'], $0);
    Sett.ColorMid   := ParseCardinal(Aux.FieldValue['mid'], $0);
    Sett.ColorEnd   := ParseCardinal(Aux.FieldValue['end'], $0);
    Sett.ColorRnd   := ParseFloat(Aux.FieldValue['rnd'], 0.0);
  end;

  //<anim frameEnd="-1" type="single"/>
  Aux := Node.ChildNode['anim'];
  if (Aux <> nil) then
  begin
    Sett.FrameEnd := ParseInt(Aux.FieldValue['frameend'], 0);
    //Sett.Sprite.AnimType := ParseInt(Aux.FieldValue['type'], 0);
  end;

  //<emission rate="777" direction="90.0" relative="false" spread="30"
	//  threadcount="0" ThreadIndexed="false"/>
  Aux := Node.ChildNode['emission'];
  if (Aux <> nil) then
  begin
    Sett.EmissionRate := ParseInt(Aux.FieldValue['rate'], 0);
    float             := ParseFloat(Aux.FieldValue['direction'], 0.0);
    Sett.Direction    := float / 180 * PI;
    Sett.Relative     := ParseBool(Aux.FieldValue['relative']);
    float             := ParseFloat(Aux.FieldValue['spread'], 0.0);
    Sett.Spread       := float / 180 * PI;

    Aux := Aux.ChildNode['threads'];
    if (Aux <> nil) then
    begin
      Sett.ThreadCount   := ParseInt(Aux.FieldValue['count'], 1);
      Sett.ThreadIndexed := ParseBool(Aux.FieldValue['indexed']);
    end;
  end;

  {
   <scale rnd="0.0">
	  <start x="1.0" y="1.0"/>
	  <mid x="1.0" y="1.0"/>
	  <end x="1.0" y="1.0"/>
	</scale>
  }
  Aux := Node.ChildNode['scale'];
  if (Aux <> nil) then
  begin
    Sett.ScaleRnd   := ParseFloat(Aux.FieldValue['rnd'], 0.0);
    Sett.ScaleStart := ParsePoint2(Aux.ChildNode['start'], Point2(1.0, 1.0));
    Sett.ScaleMid   := ParsePoint2(Aux.ChildNode['mid'], Point2(1.0, 1.0));
    Sett.ScaleEnd   := ParsePoint2(Aux.ChildNode['end'], Point2(1.0, 1.0));
  end;

  //<spin min="0" max="0" />
  Aux := Node.ChildNode['spin'];
  if (Aux <> nil) then
  begin
    float        := ParseFloat(Aux.FieldValue['min'], 0.0);
    Sett.SpinMin := float / 180 * PI;
    float        := ParseFloat(Aux.FieldValue['max'], 0.0);
    Sett.SpinMax := float / 180 * PI;
  end;

  {
  <forces>
	  <velocity min="20" max="70"/>
	  <gravity min="0" max="0"/>
	  <accel min="0" max="0"/>
	  <tangAccel min="0" max="0"/>
	</forces>
  }
  HlpNode := Node.ChildNode['forces'];
  if (HlpNode <> nil) then
  begin
    Aux := HlpNode.ChildNode['velocity'];
    if (Aux <> nil) then
    begin
      Sett.VelMin := ParseFloat(Aux.FieldValue['min'], 0.0);
      Sett.VelMax := ParseFloat(Aux.FieldValue['max'], 0.0);
    end;
    Aux := HlpNode.ChildNode['gravity'];
    if (Aux <> nil) then
    begin
      Sett.GravityMin := ParseFloat(Aux.FieldValue['min'], 0.0);
      Sett.GravityMax := ParseFloat(Aux.FieldValue['max'], 0.0);
    end;
    Aux := HlpNode.ChildNode['accel'];
    if (Aux <> nil) then
    begin
      Sett.AccelMin := ParseFloat(Aux.FieldValue['min'], 0.0);
      Sett.AccelMax := ParseFloat(Aux.FieldValue['max'], 0.0);
    end;
    Aux := HlpNode.ChildNode['tangaccel'];
    if (Aux <> nil) then
    begin
      Sett.TangAccelMin := ParseFloat(Aux.FieldValue['min'], 0.0);
      Sett.TangAccelMax := ParseFloat(Aux.FieldValue['max'], 0.0);
    end;
  end;

  //<clipRect left="0" top="0" right="0" bottom="0">
  Aux := Node.ChildNode['cliprect'];
  if (Aux <> nil) then
  begin
    Sett.ClipRect.Left   := ParseInt(Aux.FieldValue['left'], 0);
    Sett.ClipRect.Top    := ParseInt(Aux.FieldValue['top'], 0);
    Sett.ClipRect.Right  := ParseInt(Aux.FieldValue['right'], 0);
    Sett.ClipRect.Bottom := ParseInt(Aux.FieldValue['bottom'], 0);
  end;

  {
  <emitters source="emitters.xml">
	  <point x="0" y="0">
	</emitters>
  }
  ParseEmittersXML(Node.ChildNode['emitters']);
  if (EmitterCount = 0) then EmitterAdd(Point(0, 0));

  Load(Sett);
  UpdateTexture();
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SaveToXMLFile(const FileName: string);
var
  Root, SNode, Child, SubChild: TXMLNode;
  PrevDecimalSeparator: Char;
  //i: Integer;
begin
  PrevDecimalSeparator := DecimalSeparator;
  DecimalSeparator := '.';       

  Root := TXMLNode.Create('xparticles');
  SNode := Root.AddChild('xsettings');
  //<system uid="prototype" lifetime="8640000" backwardRender="false"/>
  Child := SNode.AddChild('system');
  Child.AddField('uid', FSettings.Uid);
  Child.AddField('lifetime', FloatToStrF(FSettings.LifeTime, ffFixed, 10, 3));
  Child.AddField('backwardrender', FSettings.BackwardRender);

  //<texture image="images/particles" pattern="0" drawfx="fxuAdd"/>
  Child := SNode.AddChild('texture');
  Child.AddField('image', FSettings.TexUid);
  Child.AddField('pattern', FSettings.Pattern);
  Child.AddField('drawfx', DrawFxToStr(FSettings.DrawFx));

  //<particle lifemin="2.1" lifemax="2.1" middle="0.5"/>
  Child := SNode.AddChild('particle');
  Child.AddField('lifemin', FloatToStrF(FSettings.ParticleLifeMin, ffFixed, 10, 3));
  Child.AddField('lifemax', FloatToStrF(FSettings.ParticleLifeMax, ffFixed, 10, 3));
  Child.AddField('middle', FloatToStrF(FSettings.Middle, ffFixed, 10, 3));

	//<color start="$FF8080FF" mid="$FF800000" end="$00FFFF00" rnd="0.0"/>
  Child := SNode.AddChild('color');
  Child.AddField('start', '$' + IntToHex(FSettings.ColorStart, 8));
  Child.AddField('mid', '$' + IntToHex(FSettings.ColorMid, 8));
  Child.AddField('end', '$' + IntToHex(FSettings.ColorEnd, 8));
  Child.AddField('rnd', FloatToStrF(FSettings.ColorRnd, ffFixed, 10, 3));

  //<anim frameend="-1" type="atNone"/>
  Child := SNode.AddChild('anim');
  Child.AddField('frameend', FSettings.FrameEnd);
  Child.AddField('type', FSettings.AnimType);

	{<emission rate="400" direction="0.0" relative="false" spread="360.0">
	  <threads count="3" indexed="true"/>
	</emission> }
  Child := SNode.AddChild('emission');
  Child.AddField('rate', FSettings.EmissionRate);
  Child.AddField('direction', Round(FSettings.Direction / PI * 180));
  Child.AddField('relative', FSettings.Relative);
  Child.AddField('spread', Round(FSettings.Spread / PI * 180));
  Child := Child.AddChild('threads');
  Child.AddField('count', FSettings.ThreadCount);
  Child.AddField('indexed', FSettings.ThreadIndexed);

	{<scale rnd="0.0">
	  <start x="1.0" y="1.0"/>
	  <mid x="1.0" y="1.0"/>
	  <end x="1.0" y="1.0"/>
	</scale>}
  Child := SNode.AddChild('scale');
  Child.AddField('rnd', FloatToStrF(FSettings.ScaleRnd, ffFixed, 10, 3));
  SubChild := Child.AddChild('start');
  SubChild.AddField('x', FloatToStrF(FSettings.ScaleStart.x, ffFixed, 10, 3));
  SubChild.AddField('y', FloatToStrF(FSettings.ScaleStart.y, ffFixed, 10, 3));
  SubChild := Child.AddChild('mid');
  SubChild.AddField('x', FloatToStrF(FSettings.ScaleMid.x, ffFixed, 10, 3));
  SubChild.AddField('y', FloatToStrF(FSettings.ScaleMid.y, ffFixed, 10, 3));
  SubChild := Child.AddChild('end');
  SubChild.AddField('x', FloatToStrF(FSettings.ScaleEnd.x, ffFixed, 10, 3));
  SubChild.AddField('y', FloatToStrF(FSettings.ScaleEnd.y, ffFixed, 10, 3));

	//<spin min="0" max="0" />
  Child := SNode.AddChild('spin');
  Child.AddField('min', Round(FSettings.SpinMin / PI * 180));
  Child.AddField('max', Round(FSettings.SpinMax / PI * 180));

	{<forces>
	  <velocity min="200" max="200"/>
	  <gravity min="0" max="0"/>
	  <accel min="-20" max="-20"/>
	  <tangaccel min="11" max="11"/>
	</forces>}
  Child := SNode.AddChild('forces');
  SubChild := Child.AddChild('velocity');
  SubChild.AddField('min', FloatToStrF(FSettings.VelMin, ffFixed, 10, 3));
  SubChild.AddField('max', FloatToStrF(FSettings.VelMax, ffFixed,  10, 3));
  SubChild := Child.AddChild('gravity');
  SubChild.AddField('min', FloatToStrF(FSettings.GravityMin, ffFixed,  10, 3));
  SubChild.AddField('max', FloatToStrF(FSettings.GravityMax, ffFixed,  10, 3));
  SubChild := Child.AddChild('accel');
  SubChild.AddField('min', FloatToStrF(FSettings.AccelMin, ffFixed,  10, 3));
  SubChild.AddField('max', FloatToStrF(FSettings.AccelMax, ffFixed,  10, 3));
  SubChild := Child.AddChild('tangaccel');
  SubChild.AddField('min', FloatToStrF(FSettings.TangAccelMin, ffFixed,  10, 3));
  SubChild.AddField('max', FloatToStrF(FSettings.TangAccelMax, ffFixed,  10, 3));

	//<cliprectt left="0" top="0" right="0" bottom="0"/>
  {Child := SNode.AddChild('cliprectt');
  Child.AddField('left', FSettings.ClipRect.Left);
  Child.AddField('top', FSettings.ClipRect.Top);
  Child.AddField('right', FSettings.ClipRect.Right);
  Child.AddField('bottom', FSettings.ClipRect.Bottom);
  }

  Root.SaveToFile(FileName);
  Root.Free();

  DecimalSeparator := PrevDecimalSeparator;
end;

//------------------------------------------------------------------------------
function TXParticleSystem.ParseEmittersFile(const FileName: string): Boolean;
var
  Root, Node: TXMLNode;
begin
  Result := false;
  Root := LoadXMLFromFile(FileName);
  if (Root = nil) or (LowerCase(Root.Name) <> 'xparticles') then
  begin
    Root.Free();
    Exit;
  end;

  Node := Root.ChildNode['emitters'];
  if (Node <> nil) then
  begin
    ParseEmittersXML(Node);
    Result := true;
  end;

  Root.Free();
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.ParseEmittersXML(Node: TXMLNode);
var
  i   : Integer;
  pnt : TPoint;
  pnt2: TPoint2;
  src : string;
begin
  {
  <emitters source="emitters.xml">
	  <point x="0" y="0">
	</emitters>
  }
  if (Node = nil) or (Node.Name <> 'emitters') then Exit;

  RemoveAllEmitters();
  src := Node.FieldValue['source'];
  if (FileExists(src)) then ParseEmittersFile(src);
  
  for i := 0 to Node.ChildCount - 1 do
  begin
    if (Node.Child[i].Name = 'point') then
    begin
      pnt2 := ParsePoint2(Node.Child[i]);
      pnt.x := Round(pnt2.x);
      pnt.Y := Round(pnt2.y);
      EmitterAdd(pnt);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleSystem.SaveEmittersToXMLFile(const FileName: string);
var
  i: Integer;
  Root, Node, PointNode: TXMLNode;
begin
  Root := LoadXMLFromFile(FileName);

  if (Root = nil) then Root := TXMLNode.Create('xparticles');

  Node := Root.AddChild('emitters');
  Node.AddField('source', '');
  for i := 0 to EmitterCount - 1 do
  begin
    PointNode := Node.AddChild('point');
    PointNode.AddField('x', FEmitters[i].x);
    PointNode.AddField('y', FEmitters[i].y);
  end;

  Root.SaveToFile(FileName);
  Root.Free();
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TXParticleManager.
//------------------------------------------------------------------------------
constructor TXParticleManager.Create();
begin
  FDeviceIndex := 0;
  FSysCount    := 0;
end;

//------------------------------------------------------------------------------
destructor TXParticleManager.Destroy();
begin
  KillAll();

  inherited;
end;
//------------------------------------------------------------------------------
procedure TXParticleManager.UpdateTextures();
var
  i: Integer;
  uid: string;
begin
  for i := 0 to SettingsCount - 1 do
  begin
    uid := FSettings[i].TexUid;
    if (uid <> '') then
      FSettings[i].Texture := TAsphyreImage(Devices[FDeviceIndex].Images.Image[uid])
    else FSettings[i].Texture := nil;
  end;
end;

//------------------------------------------------------------------------------
procedure TXParticleManager.Update(DeltaTime: Single);
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
    FSystems[i].Render(dx, dy)
end;

//------------------------------------------------------------------------------
// Return ID of added Settings 
function TXParticleManager.Add(const PSS: TXParticleSettings): integer;
var
  cnt: integer;
begin
  cnt := Length(FSettings);
  Inc(cnt);
  SetLength(FSettings, cnt);
  Result := cnt - 1;
  FSettings[Result] := PSS;
  // convert to LowerCase
  FSettings[Result].Uid := LowerCase(FSettings[Result].Uid);
  //FSettings[Result].Texture := TAsphyreImage(FDevice.Images.Image[FSettings[Result].Uid]);
end;

//------------------------------------------------------------------------------
// Return ID of added Settings 
function TXParticleManager.AddFromASDb(ASDb: TASDb; const Key: string): integer;
var
  tmpSys: TXParticleSystem;
begin
  tmpSys := TXParticleSystem.Create();
  tmpSys.LoadFromAsdb(ASDb, Key);
  Result := Add(tmpSys.Settings);
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
    Result := LaunchEx(FSettings[Index], Pos);
end;

//------------------------------------------------------------------------------
// Launch particles by Name
function TXParticleManager.Launch(const Name: string; const Pos: TPoint2): TXParticleSystem;
var
  Index: integer;
begin
  Result := nil;
  Index := IndexOf(Name);
  if (Index >= 0) then Result := Launch(Index, Pos);  
end;

//------------------------------------------------------------------------------
function TXParticleManager.LaunchEx(const PSS: TXParticleSettings;
  const Pos: TPoint2): TXParticleSystem;
var
  NewSys: TXParticleSystem;
begin
  if (FSysCount >= MAX_PSYSTEMS) then
  begin
    Result := nil;
    Exit;
  end;

  NewSys := TXParticleSystem.Create();
  NewSys.DeviceIndex := FDeviceIndex;
  NewSys.Load(PSS);
  NewSys.MoveTo(Pos, true);
  NewSys.Start();
  
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
  for i := 0 to Length(FSettings) - 1 do
    if (Name = FSettings[i].Uid) then
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
procedure TXParticleManager.ParseXML(Node: TXMLNode);
var
  xps: TXParticleSystem;
begin
  if (Node = nil) then Exit;
  
  xps := TXParticleSystem.Create(0);
  xps.ParseXML(Node);
  Add(xps.Settings);
  xps.Free();
end;

//------------------------------------------------------------------------------
function TXParticleManager.ParseXMLFile(const FileName: string): Boolean;
var
  Root, Node, ChildNode: TXMLNode;
  i, j: Integer;
  Name: string;
begin
  Result := false;
  Root := LoadXMLFromFile(FileName);
  if (Root = nil) then
  begin
    Root.Free();
    Exit;
  end;

  if (LowerCase(Root.Name) <> 'xparticles') and
     (LowerCase(Root.Name) <> 'unires') then Exit;  

  for i := 0 to Root.ChildCount - 1 do
  begin
    Node := Root.Child[i];
    if (Node <> nil) then
    begin
      Name := LowerCase(Node.Name);
      if (Name = 'particle-group') then
      begin
        for j := 0 to Node.ChildCount - 1 do
        begin
          ChildNode := Node.Child[j];
          if (ChildNode <> nil) and (ChildNode.Name = 'particles') then
          begin
            Name := ChildNode.FieldValue['source'];
            Result := ParseXMLFile(Name);
          end;
        end;
        
        Continue;
      end;

      if (Name = 'xsettings') then
      begin
        ParseXML(Node);
        Result := true;
      end;
    end;
  end;

  Root.Free();
end;

//------------------------------------------------------------------------------
end.


unit AsphyrePuppet;
//---------------------------------------------------------------------------
// AsphyrePuppet.pas                                    Modified: 31-Mar-2006
// Majk, Gurroa                                                  Version 0.60
//---------------------------------------------------------------------------
// Changes since v0.55:
//  + add ModelsCache, updates on AsphyrePMath
//
// Changes since v0.50:
//  + several lines runtines are drawed search for DrawLine procedure
//
// Changes since v0.30:
//  + BasicPuppet now handle it's BoundBox as a width and height of model
//    automaticly taken from model's DXMesh
//  + 3DMouse function that return first model in the direction of mouseCursor from
//    AsphyreCamera
//  * some fixes to AsphyreModel runtime functions
//
// Changes since v0.00:
//  + simple TAsphyrePuppet and TBasicPuppet objects
//---------------------------------------------------------------------------
// This unit depends on AfterWarp asphyre package
// http://www.afterwarp.net
//---------------------------------------------------------------------------
interface

uses AsphyreDef, AsphyreMatrix, AsphyreModels, AsphyreMath, AsphyrePMath,
     AsphyreCameras, AsphyreFacing, AsphyreImages, AsphyreModelsCache,
     DXMeshes, DXBase, Direct3D9, Lines3D, Forms;

const
  ZeroPoint3: TPoint3 = (x: 0; y: 0; z: 0);

{$DEFINE DEBUG}

type
  // To gain access to TDXMesh protected functions
  TDXMeshAccess = class(TDXMesh);
  // For accessing meshFVF
  PTexturedMeshFVF = ^TTexturedMeshFVF;
  TTexturedMeshFVF = record
    Vertex : TD3DVector;
    Normal : TD3DVector;
    TexAddr: Cardinal;
  end;

  PPoint3 = ^TPoint3;
  PQuadPoints3 = ^TQuadPoints3;
  PRealRect = ^TRealRect;
  PRect3 = ^TRect3;
  PBox = ^TBox;

  TPuppetState = record
    Rotation: TPoint3;
    Scale: TPoint3;
    Position: TPoint3;
  end;

  TRealRect = record
    Left, Top, Right, Bottom: Real;
  end;

  TRect3 = record
    Left, Top, Right, Bottom: TPoint3;
  end;

  TBox = record
    case Integer of
      0: (Top, Bottom: TRect3);
      1: (TopLeft, TopTop, TopRight, TopBottom,
          BottomLeft, BottomTop, BottomRight, BottomBottom: TPoint3);
    end;

  // Common 3DObject top functions
  T3DObject = class(TObject)
  private
    FVisible: Boolean;
  public
    function Draw(const Mtx: TMatrix4; Camera: TAsphyreCamera): Boolean; virtual;
    procedure Update(const Mtx: TMatrix4); virtual;

    property Visible: Boolean read FVisible write FVisible;
  end;

  // 3DObject cointainer for AsphyreModel
  T3DModelObject = class(T3DObject)
  private
    FModel: TAsphyreModel;
    FCenter: TPoint3;
    FVector: TVector4;
    FBounds: TBox;
    FSize: TPoint3;
    procedure SetModel(const Value: TAsphyreModel);
    procedure UpdateCenterBoundBox;
    function GetBoundBox: TBox;
  public
    constructor Create;
    // Model assigned to this object
    property Model: TAsphyreModel read FModel write SetModel;

    // Read only properties
    property BoundBox: TBox read GetBoundBox;
    property Center: TPoint3 read FCenter write FCenter;
    property Vector: TVector4 read FVector write FVector;
    property Size: TPoint3 read FSize;

    // Draw model if Visible
    function Draw(const Mtx: TMatrix4; Camera: TAsphyreCamera): Boolean; override;
    function DrawCache(Mtx: PMatrix4; AsphyreModelsCache: TAsphyreModelsCache): Boolean;
    // Updates stored FBounds from actual position
    procedure Update(const Mtx: TMatrix4); override;
    // Return actual center position
    function ActCenter(const Mtx: TMatrix4): TPoint3;
    // Return stored FBounds as a Pointer to it
    // Use only as a read-only or when you know what you're doing
    procedure GetBounds(Box: PBox);
  end;

  // 3DObject container for QuadPoints
  T3DQuadPointsObject = class(T3DObject)
  private
    FCenter: TPoint3;
    FVector: TVector4;
    FQuadPoints: TQuadPoints3;
    FSize: TPoint3;
    procedure SetQuadPoints(const Value: TQuadPoints3);
  public
    constructor Create;
    property Center: TPoint3 read FCenter;
    property Size: TPoint3 read FSize;
    property Vector: TVector4 read FVector;

    procedure Update(const Mtx: TMatrix4); override;

    property QuadPoints: TQuadPoints3 read FQuadPoints write SetQuadPoints;
    procedure GetQuadPoints(var Rct: PQuadPoints3);

    procedure CreateRect3(const aCenter: TPoint3; const aVector: TVector4); overload;
    procedure CreateRect3(const aCenter: TPoint3; const Size: TPoint2); overload;
  end;

  TAsphyrePuppet = class(TObject)
  private
    FName: string;
    FChildren: array of TAsphyrePuppet;
    FSubs: array of T3DObject;
    FLocMtx: TMatrix4;
    FPosition: TPoint3;
    FScale: TPoint3;
    FRotation: TPoint3;
    FIndex: integer;
    FOwner: TAsphyrePuppet;
    FAutoUpdate: Boolean;
    FModified: Boolean;
    FScaled: Boolean;
    FBasicPos: TPuppetState;
    FGloMtx: TMatrix4;
    FPivot: TPoint3;
    function PuppetsDraw(WorldMtx: TMatrix4; Camera: TAsphyreCamera): boolean;
    function GetCount: Integer;
    function GetItem(aName: string): TAsphyrePuppet;
    function GetPuppet(Num: Integer): TAsphyrePuppet;
    procedure SetPosition(const Value: TPoint3);
    procedure SetScale(const Value: TPoint3);
    procedure SetRotation(const Value: TPoint3);
    function GetModified: boolean;
    function GetPositionX: double;
    function GetPositionY: double;
    function GetPositionZ: double;
    function GetRotationX: double;
    function GetRotationY: double;
    function GetRotationZ: double;
    function GetScaleX: double;
    function GetScaleY: double;
    function GetScaleZ: double;
    procedure SetBasicPos(const Value: TPuppetState);
    procedure SetPositionX(const Value: double);
    procedure SetPositionY(const Value: double);
    procedure SetPositionZ(const Value: double);
    procedure SetRotationX(const Value: double);
    procedure SetRotationY(const Value: double);
    procedure SetRotationZ(const Value: double);
    procedure SetScaleX(const Value: double);
    procedure SetScaleY(const Value: double);
    procedure SetScaleZ(const Value: double);
    procedure SetPivot(const Value: TPoint3);
    function GetGlobalPivot: TPoint3;
    function GetGlobalPosition: TPoint3;
    function GetGlobalRotation: TPoint3;
    function GetGlobalScale: TPoint3;
    function GetObject(Num: Integer): T3DObject;
    function GetSubsCount: Integer;
    procedure SetAutoUpdate(const Value: boolean);
  protected
    function GPivot: TPoint3;
    function OwnerGlo: TMatrix4;
  public
    constructor Create(aOwner: TAsphyrePuppet); virtual;
    destructor Destroy; override;
    // Base states aka position, rotate and scale
    property BasicPos: TPuppetState read FBasicPos write SetBasicPos;

    // rotation and scale center in local coords(coords origin deviation)
    property Pivot: TPoint3 read FPivot write SetPivot;
    // model rotation around pivot
    property Rotation: TPoint3 read FRotation write SetRotation;
    property RotationX: double read GetRotationX write SetRotationX;
    property RotationY: double read GetRotationY write SetRotationY;
    property RotationZ: double read GetRotationZ write SetRotationZ;
    // model scale around pivot
    property Scale: TPoint3 read FScale write SetScale;
    property ScaleX: double read GetScaleX write SetScaleX;
    property ScaleY: double read GetScaleY write SetScaleY;
    property ScaleZ: double read GetScaleZ write SetScaleZ;
    // relative position to Pivot
    property Position: TPoint3 read FPosition write SetPosition;
    property PositionX: double read GetPositionX write SetPositionX;
    property PositionY: double read GetPositionY write SetPositionY;
    property PositionZ: double read GetPositionZ write SetPositionZ;
    // Global coords
    property PivotGlobal: TPoint3 read GetGlobalPivot;
    property RotationGlobal: TPoint3 read GetGlobalRotation;
    property ScaleGlobal: TPoint3 read GetGlobalScale;
    property PositionGlobal: TPoint3 read GetGlobalPosition;
    // Tansmormations around Pivot point
    procedure Resize(const sX, sY, sZ: double);
    procedure Translate(const dX, dY, dZ: double);
    procedure Rotate(const dX, dY, dZ: double);
    // Movement even with Point in current direction (based on rotation)
    procedure Move(const dX, dY, dZ: double);

    // Parent asphyre puppet
    property Owner: TAsphyrePuppet read FOwner write FOwner;
    // Name of AsphyrePuppet
    property Name: string read FName write FName;
    // Index in Parent.Children array
    property Index: integer read FIndex;
    // local matrix (basic model position)
    property LocMtx: TMatrix4 read FLocMtx write FLocMtx;
    // global matrix (world axis model position)
    property GloMtx: TMatrix4 read FGloMtx write FGloMtx;
    // Where automaticly update locals after any coord change
    // If set to false you need to call UpdateLocal before Update
    property AutoUpdate: boolean read FAutoUpdate write SetAutoUpdate;
    // Wheter is puppet changed and not Updated
    property Modified: boolean read GetModified write FModified;

    // Children Puppets
    function Add: TAsphyrePuppet; overload;
    procedure Add(Puppet: TAsphyrePuppet); overload;
    property ChildCount: Integer read GetCount;
    property Children[Num: Integer]: TAsphyrePuppet read GetPuppet;
    // recurent find Puppet by name
    property Items[Name: string]: TAsphyrePuppet read GetItem; default;
    function IndexOf(Model: TAsphyrePuppet): Integer;
    procedure Delete(Index: Integer);
    procedure Clear;
    // drops all children but don't free them
    // use only with care
    procedure DropChildren;

    // Subs 3DObject
    function AddSub(Sub: T3DObject): T3DObject;
    property SubsCount: Integer read GetSubsCount;
    property Subs[Num: Integer]: T3DObject read GetObject;
    function IndexOfSub(Sub: T3DObject): Integer;
    procedure DeleteSub(Index: Integer);
    procedure ClearSubs;

    // Update LocMtx and GloMtx properties but do no effect on Children
    procedure UpdateLocal; virtual;
    // Updates children position, rotation and scale based on GloMtx
    procedure Update; virtual;
    // Return Current Position, Rotation and Scale to its BasicPos position
    // If you used Move Pivot point is not returned!
    procedure Reset;

    // Init drawing of object
    function Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean; overload; virtual;
    function Draw(const Camera: TAsphyreCamera): Boolean; overload; virtual;
    function DrawVisibled(const Camera: TAsphyreCamera; CameraOrigin: PPoint3): Boolean; virtual;
  end;

  // Model containg Puppet
  TBasicPuppet = class(TAsphyrePuppet)
  private
    FModelObject: T3DModelObject;
    FVisible: Boolean;
    FLocGloMtx: TMatrix4;
    FModelLoaded: Boolean;
    FBoundsUpdated: Boolean;
    FTempPoint: TPoint3;
    FAsphyreModelsCache: TAsphyreModelsCache;
    function GetModel: TAsphyreModel;
    procedure SetModel(const Value: TAsphyreModel);
    procedure SetVisible(const Value: Boolean);
    function GetBounds: TBox;
    function GetPBounds: PBox;
    function GetCenter: TPoint3;
    function GetVector: TVector4;
    function GetDepth: Real;
    function GetHeight: Real;
    function GetSize: TPoint3;
    function GetWidth: Real;
    function GetModelObject: T3DModelObject;
  public
    // constructors override
    constructor Create(aOwner: TAsphyrePuppet); override;
    // update override
    procedure UpdateLocal; override;
    // Init drawing of model
    function Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean; overload; override;
    function DrawVisibled(const Camera: TAsphyreCamera; CameraOrigin: PPoint3): Boolean; override;
    property Model: TAsphyreModel read GetModel write SetModel;

    // BoundsBox
    property BoundBox: TBox read GetBounds;
    // Use this only when you need to read from Bounds
    // Or if you know what are you doing
    property PBoundsBox: PBox read GetPBounds;

    // Model's properties
    property Center: TPoint3 read GetCenter;
    property Vector: TVector4 read GetVector;
    property Width: Real read GetWidth;
    property Height: Real read GetHeight;
    property Depth: Real read GetDepth;
    property Size: TPoint3 read GetSize;
    property ModelObject: T3DModelObject read GetModelObject;

    // Wheter model should use TAsphyreModelsCache
    property AsphyreModelsCache: TAsphyreModelsCache read FAsphyreModelsCache write FAsphyreModelsCache;

    // Wheter model should be drawed
    property Visible: Boolean read FVisible write SetVisible;
    // Set True if model succesfuly loaded
    property ModelLoaded: Boolean read FModelLoaded;

    // really only temporary point (used by default by GetPuppetInCameraView function as a point where mouse step into BoundBox)
    property TempPoint: TPoint3 read FTempPoint write FTempPoint;
    // Wheter is Point in BoundBox
    function PointInBounds(const Pt: TPoint3): Boolean;

    // Distance from point to model current center position
    function DistanceFromPointToCenter(const Pt: TPoint3): Real;
    // Distance from point to model current center position + vector
    function DistanceFromPointToVector(const Pt: TPoint3): Real;
  end;
  TModelPuppet = class(TBasicPuppet);

  TFacingPuppet = class(TAsphyrePuppet)
  private
    FFacingObject: T3DQuadPointsObject;
    FVisible: Boolean;
    FLocGloMtx: TMatrix4;
    FRectLoaded: Boolean;
    FRectUpdated: Boolean;
    FImage: TAsphyreImage;
    FTexCoord: TTexCoord;
    FFacing: TAsphyreFacing;
    FBlendOp: Cardinal;
    FColor: TColor4;
    function GetQuadPoints: TQuadPoints3;
    function GetPQuadPoints: PQuadPoints3;
    procedure SetVisible(const Value: Boolean);
  public
    // constructors override
    constructor Create(aOwner: TAsphyrePuppet); override;
    // update override
    procedure UpdateLocal; override;

    // Facing rect
    property QuadPoints: TQuadPoints3 read GetQuadPoints;
    // Use this only when you need to read from QuadPoints
    // Or if you know what are you doing
    property PQuadPoints: PQuadPoints3 read GetPQuadPoints;

    // Init drawing of facing image
    function Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean; overload; override;

    // AsphyreImage used for drawing facing
    property Image: TAsphyreImage read FImage write FImage;
    // TexCoord - default tPattern(0)
    property TexCoord: TTexCoord read FTexCoord write FTexCoord;
    // Color used in Facing.Draw(...
    property Color: TColor4 read FColor write FColor;
    // Draw blend mode
    property BlendOp: Cardinal read FBlendOp write FBlendOp;
    // Assign Facing so it can be drawed
    property Facing: TAsphyreFacing read FFacing write FFacing;

    // Wheter facing should be drawed
    property Visible: Boolean read FVisible write SetVisible;

    procedure SetQuadPoints(const aCenter: TPoint3; const aVector: TVector4); overload;
    procedure SetQuadPoints(const aCenter: TPoint3; const aSize: TPoint2); overload;
    procedure SetQuadPoints(Puppet: TModelPuppet); overload;
  end;

  {TODO !!!}
  TCameraPuppet = class(TAsphyrePuppet)
  private
    FCamera: TAsphyreCamera;
    FRoof: TPoint3;
    FAutoUpdateCamera: Boolean;
  public
    // constructors override
    constructor Create(aOwner: TAsphyrePuppet); override;

    property Camera: TAsphyreCamera read FCamera write FCamera;
    property Roof: TPoint3 read FRoof write FRoof;
    property AutoUpdateCamera: Boolean read FAutoUpdateCamera write FAutoUpdateCamera;
    procedure UpdateCamera;

    procedure MouseLook(const x, y, z: Real);
  end;

  TAnimPuppet = class(TAsphyrePuppet)

  end;

// Lines component... 
var Lines: TAsphyreLine3D;

const
  Pi2 = Pi*2;
  StToRad = Pi/180;
  RadToSt = 180/Pi;
  Rad = Pi/180;
  Rad2 = Pi/360;
  Pi90 = Pi/90;
  Pi180 = Pi/180;
  Pi240 = Pi/240;
  Pi60 = Pi/60;
  Pi30 = Pi/30;

// Find topmost parent with name
function LastNamedParent(Puppet: TAsphyrePuppet): TAsphyrePUppet;

// Test wheter there is any puppet in the camera view with mouse on screen Coordinates
function GetPuppetInCameraView(const Camera: TAsphyreCamera; const ScreenWidthHeightFOV: TPoint3;
  const MouseScreenCoords, NearestFarestStep: TPoint3;
  const Parent: TAsphyrePuppet; bnOnlyParentPuppet: Boolean = True; StepsInto: Integer = 1; FloorY: Real = -99999): TBasicPuppet;

// Creates TCameraPuppet
function InitCameraPuppet(const Origin, Target: TPoint3; const Camera: TAsphyreCamera): TCameraPuppet;

// return point3 count as vector from puppet pivot based on it's rotation and position
function PointInDistanceFromPuppetDirection(const DistVector: TVector4; const Puppet: TAsphyrePuppet): TPoint3;

// set State to zero state P(0,0,0)R(0,0,0)S(1,1,1)
procedure BaseState(var State: TPuppetState);

// Return Real rect from 4 real
function RealRect(left, top, right, bottom: Real): TRealRect;

// Count Box (8 point3) from center and vector
procedure Box(Box: PBox; const Center: TPoint3; Vector: TVector4);

// Creation of TRect3
function Rect3(const center, vector: TPoint3): TRect3; overload;
procedure Rect3(Rct: PRect3; const center, vector: TPoint3); overload;
function Rect3(const left, top, right, bottom: TPoint3): TRect3; overload;

// Creation of QuadPoints3
procedure QPoint3(Rct: PQuadPoints3; const center, vector: TPoint3); overload;
procedure QPoint3(Rct: PQuadPoints3; const center: TPoint3; const vector: TVector4); overload;
function QPoint3(const center: TPoint3; const vector: TVector4): TQuadPoints3; overload;

// multiplying a point3 and a matrix
function MatPointMul(const Pt: TPoint3; const Mtx: TMatrix4): TPoint3;
// multiplying a rect3 and a matrix
function MatRecMul(const Rct3: TRect3; const Mtx: TMatrix4): TRect3;
function MatQuadMul(const Rct3: TQuadPoints3; const Mtx: TMatrix4): TRect3; overload;
procedure MatQuadMul(const Rct3: PQuadPoints3; const Mtx: TMatrix4); overload;

// multiplying a Box and a matrix
function MatBoxMul(const Cub: TBox; const Mtx: TMatrix4): TBox; overload;
// multiplying a pointed Box and a matrix
procedure MatBoxMul(Cub: PBox; const Mtx: TMatrix4); overload;

// sorting rect3 (TODO!!!)
procedure SortRect3(const SRect3: PRect3);

// check if val lieas in Amin to AMax
function ValInRange(const V, aRange1, aRange2: Single): Boolean;

// Work with 2D - only using x and z axes !
// angle around Y depth axes
function VecAngle2(const a, b: TPoint3): Real;

// Result = left <0, right >0, same =0
function PointLeftOrRightFromLine(const LineFrom, LineTo, Pt: TPoint3): Integer;
function PointLeftOrRightFromPuppet(Puppet: TAsphyrePuppet; const Pt: TPoint3; bnUseYAxis: Boolean = False): Integer; overload;
// same as above (withou y axis) but fills Dist with distance from aiming point to target if Dist >0 and Result=0 then target is on opposite direction
function PointLeftOrRightFromPuppet(Puppet: TAsphyrePuppet; const Pt: TPoint3; var AimDist: Real; var Dist: Real): Integer; overload;

// Nice call to recusrive functions TestChildren...
// Return nil or Puppet which has Pt Point3 within it's BoundBox
function PuppetOnPoint(const Pt: TPoint3; Parent: TAsphyrePuppet): TBasicPuppet;
function TestChildrenParentFirst(Child: TAsphyrePuppet; const Pt: TPoint3; var FoundChild: TBasicPuppet): Boolean;
function TestChildrenFirst(Child: TAsphyrePuppet; const Pt: TPoint3; var FoundChild: TBasicPuppet): Boolean;

// Draw lines using Lines (means you Initialize it and Flush after drawing
procedure DrawBoundBox(Box: PBox; const ColorARGB: Cardinal);
procedure DrawLine(PFrom, PTo: PPoint3; const ColorARGB: Cardinal);
procedure DrawQuadPoints(PQuad: PQuadPoints3; const ColorARGB: Cardinal);
procedure DrawRect3(PRct: PRect3; const ColorARGB: Cardinal);
procedure DrawCross(PPt: PPoint3; Size: Integer; const ColorARGB: Cardinal);

implementation

uses SysUtils, Math, FastGEO;

{ TAsphyrePuppet }

procedure DrawBoundBox(Box: PBox; const ColorARGB: Cardinal);
begin
  if Lines<>nil then
  begin
    DrawRect3(@Box.Top, ColorARGB);
    DrawRect3(@Box.Bottom, ColorARGB);

    DrawLine(@Box.Top.Left, @Box.Bottom.Left, ColorARGB);
    DrawLine(@Box.Top.Top, @Box.Bottom.Top, ColorARGB);
    DrawLine(@Box.Top.Right, @Box.Bottom.Right, ColorARGB);
    DrawLine(@Box.Top.Bottom, @Box.Bottom.Bottom, ColorARGB);
  end;
end;

procedure DrawQuadPoints(PQuad: PQuadPoints3; const ColorARGB: Cardinal);
begin
  if Lines<>nil then
  begin
    Lines.Add(PQuad[0], PQuad[1], ColorARGB);
    Lines.Add(PQuad[1], PQuad[2], ColorARGB);
    Lines.Add(PQuad[2], PQuad[3], ColorARGB);
    Lines.Add(PQuad[3], PQuad[0], ColorARGB);
  end;
end;

procedure DrawRect3(PRct: PRect3; const ColorARGB: Cardinal);
begin
  if Lines<>nil then
  begin
    Lines.Add(PRct.Left, PRct.Top, ColorARGB);
    Lines.Add(PRct.Top, PRct.Right, ColorARGB);
    Lines.Add(PRct.Right, PRct.Bottom, ColorARGB);
    Lines.Add(PRct.Bottom, PRct.Left, ColorARGB);
  end;
end;

procedure DrawLine(PFrom, PTo: PPoint3; const ColorARGB: Cardinal);
begin
  if Lines<>nil then
  begin
    Lines.Add(PFrom^, PTo^, ColorARGB);
  end;
end;

procedure DrawCross(PPt: PPoint3; Size: Integer; const ColorARGB: Cardinal);
var Pt, Pt2: TPoint3;
begin
  if Lines<>nil then
  begin
    Pt := PPt^;
    Pt2 := PPt^;
    Pt.y := Pt.y - Size;
    Pt2.y := Pt2.y + Size;
    Lines.Add(Pt, Pt2, ColorARGB);
    Pt := PPt^;
    Pt2 := PPt^;
    Pt.x := Pt.x - Size;
    Pt2.x := Pt2.x + Size;
    Lines.Add(Pt, Pt2, ColorARGB);
    Pt := PPt^;
    Pt2 := PPt^;
    Pt.z := Pt.z - Size;
    Pt2.z := Pt2.z + Size;
    Lines.Add(Pt, Pt2, ColorARGB);
  end;
end;

function PointLeftOrRightFromPuppet(Puppet: TAsphyrePuppet; const Pt: TPoint3; var AimDist: Real; var Dist: Real): Integer; overload;
var TestPoint, TempPoint, PtGlobal: TPoint3;
begin
  Result := 0;

  if Puppet<>nil then
  begin
    TestPoint := Pt;
    TestPoint.y := 0;

    PtGlobal := Puppet.PositionGlobal;
    PtGlobal.y := 0;

    // Distance to test vector
    AimDist := abs(VecDist3(TestPoint, PtGlobal));

    // Point in direction on circle with radius same as distance from target
    TempPoint := PointInDistanceFromPuppetDirection(Vector4(0, 0, AimDist, 1), Puppet);
    TempPoint.y := 0;

    Dist := abs(VecDist3(TempPoint, TestPoint));

    // <0 means to the left, >0 means to the right
    Result := PointLeftOrRightFromLine(PtGlobal, TempPoint, TestPoint);
  end;
end;

function PointLeftOrRightFromPuppet(Puppet: TAsphyrePuppet; const Pt: TPoint3; bnUseYAxis: Boolean = False): Integer;
var Dist: Real;
  TestPoint, TempPoint: TPoint3;
begin
  Result := 0;

  if Puppet<>nil then
  begin
    TestPoint := Pt;
    if not bnUseYAxis then TestPoint.y := 0;

    // Distance to test vector
    Dist := abs(VecDist3(TestPoint, Puppet.PivotGlobal));

    // Point in direction on circle with radius same as distance from target
    TempPoint := PointInDistanceFromPuppetDirection(Vector4(0, 0, Dist, 1), Puppet);

    if not bnUseYAxis then
      TempPoint.y := 0;

    // <0 means to the left, >0 means to the right
    Result := PointLeftOrRightFromLine(Puppet.PivotGlobal, TempPoint, TestPoint);
  end;
end;

function PointLeftOrRightFromLine(const LineFrom, LineTo, Pt: TPoint3): Integer;
var a,b,c: Real;
begin
  a := LineTo.z - LineFrom.z;
  b := LineFrom.x - LineTo.x;
  c := -a*LineFrom.x -b*LineFrom.z;

  Result := Round((a*Pt.x + b*Pt.z + c) / sqrt(a*a + b*b));
end;

function VecAngle2(const a, b: TPoint3): Real;
var i: Real;
begin
  i := (a.x * b.x) / ( Sqrt(Sqr(a.x)+Sqr(a.z)) * b.x );
  if i < -1 then i := -1;
  if i > 1 then i := 1;

  Result := ArcCos(i);
end;

function ValInRange(const V, aRange1, aRange2: Single): Boolean;
begin
  Result := (V > Min(aRange1, aRange2)) and (V < Max(aRange1, aRange2));
end;

function LastNamedParent(Puppet: TAsphyrePuppet): TAsphyrePUppet;
begin
  Result := Puppet;
  while (Result.Owner<>nil) and (Result.Owner.Name<>'') do
    Result := Result.Owner;
end;

function TestChildrenParentFirst(Child: TAsphyrePuppet; const Pt: TPoint3; var FoundChild: TBasicPuppet): Boolean;
var i, ch: integer;
begin
  Result := False;
  if Child is TBasicPuppet then
    Result := TBasicPuppet(Child).PointInBounds(Pt);

  if Result then
    FoundChild := TBasicPuppet(Child);

  if not Result then
  begin
    ch := Child.ChildCount;
    i  := 0;
    if ch > 0 then
    repeat
      if Child.Children[i] is TBasicPuppet then
        Result := TestChildrenParentFirst(TBasicPuppet(Child.Children[i]), Pt, FoundChild);

      if Result then
        break;
      inc(i);
    until (i >= ch);
  end;
end;

function TestChildrenFirst(Child: TAsphyrePuppet; const Pt: TPoint3; var FoundChild: TBasicPuppet): Boolean;
var ch, i: integer;
begin
  Result := False;

  ch := Child.ChildCount;
  i  := 0;
  if ch > 0 then
  repeat
    if Child.Children[i] is TBasicPuppet then
      Result := TestChildrenFirst(TBasicPuppet(Child.Children[i]), Pt, FoundChild);

    if Result then
      break;
    inc(i);
  until (i >= ch);

  if not Result then
  begin
    if Child is TBasicPuppet then
      Result := TBasicPuppet(Child).PointInBounds(Pt);
      
    if Result then
      FoundChild := TBasicPuppet(Child)
  end;
end;

function GetPuppetInCameraView(const Camera: TAsphyreCamera; const ScreenWidthHeightFOV: TPoint3;
  const MouseScreenCoords, NearestFarestStep: TPoint3;
  const Parent: TAsphyrePuppet; bnOnlyParentPuppet: Boolean = True; StepsInto: Integer = 1; FloorY: Real = -99999): TBasicPuppet;
var StepVector, Vector: TVector4;
  i, k, steps: integer;
  M: TMatrix4;
  RadX, RadY: Real;
  StepPoint3: TPoint3;
  bnFound: Boolean;
  CameraOrigin: TVector4;

begin
  Result := nil;
  bnFound := False;

  CameraOrigin := MatVecMul(Vector4(0,0,0,1), MatInverse(Camera.ViewMtx));

  // Compute mouse angels by screen center
  RadX := (ScreenWidthHeightFOV.z / ScreenWidthHeightFOV.x) * (MouseScreenCoords.x - (ScreenWidthHeightFOV.x / 2));
  RadY := (ScreenWidthHeightFOV.z / ScreenWidthHeightFOV.y) * (MouseScreenCoords.y - (ScreenWidthHeightFOV.y / 2));

  M := IdentityMatrix;
  M := MatMul(M, MatRotateX(-RadY));
  M := MatMul(M, MatRotateY(-RadX));
  //M := MatMul(M, MatRotate(Vector4(-RadY, 0, 0, 1), 0));
  //M := MatMul(M, MatTransl(Vector4(StToRad*(MouseScreenCoords.x - (ScreenWidthHeightFOV.x / 2)), -StToRad*(MouseScreenCoords.y - (ScreenWidthHeightFOV.y / 2)), 0, 1)));

  // Step vector from step size rotated by Matrix
  StepVector := MatVecMul(Vector4(0, 0, -NearestFarestStep.z, 0), MatInverse(M));
  Vector     := MatVecMul(Vector4(0, 0, -NearestFarestStep.x, 0), MatInverse(M));

  // Camera.ViewMtx rotated by Matrix (First move to 0,0,0 than Rotate than move back to it's Origin position)
  M := MatMul( MatMul( MatMul(Camera.ViewMtx, MatTransl(VecNeg4(CameraOrigin))), M), MatTransl(CameraOrigin));
  //M := MatMul( M, MatTransl(Vector4(0.22*-(MouseScreenCoords.x - (ScreenWidthHeightFOV.x / 2)), 0.16*(MouseScreenCoords.y - (ScreenWidthHeightFOV.y / 2)), 0, 1)) );
  //M := MatMul( M, MatTransl(MatVecMul(Vector4(-(MouseScreenCoords.x - (ScreenWidthHeightFOV.x / 2)), (MouseScreenCoords.y - (ScreenWidthHeightFOV.y / 2)), 0, 1), Camera.ProjMtx)) );

  // Count amount of steps
  steps := Round(abs(NearestFarestStep.y - NearestFarestStep.x) / NearestFarestStep.z);

  M := MatMul(M, MatTransl(Vector));

  k := 0;

  for i := 1 to steps do
  begin
    // Create Point3 on vector in distance
    StepPoint3 := Vec4To3(MatVecMul(Vector4(1, 1, 1, 1), MatInverse(M)));

    if bnOnlyParentPuppet then
      bnFound := TestChildrenParentFirst(Parent, StepPoint3, Result)
    else
      bnFound := TestChildrenFirst(Parent, StepPoint3, Result);

    if bnFound then
    begin
      inc(k);
      if (k >= StepsInto) then
        break
      else
      if (Result<>Parent) then
        break;
    end;

    if StepPoint3.y < FloorY then
      break;

    // move matrix by step vector
    M := MatMul(M, MatTransl(StepVector));
  end;
  if not bnFound then
    Result := nil
  else
  if (Result<>nil) and (Result is TBasicPuppet) then
  begin
    Result.TempPoint := StepPoint3;
  end;
end;

function PuppetOnPoint(const Pt: TPoint3; Parent: TAsphyrePuppet): TBasicPuppet;
begin
  if not TestChildrenFirst(Parent, Pt, Result) then
    Result := nil;
end;

function QPoint3(const center: TPoint3; const vector: TVector4): TQuadPoints3;
begin
  Result := QuadPoints3(ZeroPoint3, ZeroPoint3, ZeroPoint3, ZeroPoint3);
  QPoint3(@Result, center, vector);
end;

procedure QPoint3(Rct: PQuadPoints3; const center: TPoint3; const vector: TVector4);
begin
  if Vector.y > 0 then
  begin
    Rct[0] := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Rct[1] := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Rct[2] := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z - Vector.z);
    Rct[3] := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z - Vector.z);
    Exit;
  end;

  // Vector.y <= 0
  Rct[0] := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Rct[1] := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Rct[2] := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z - Vector.z);
  Rct[3] := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z - Vector.z);
end;

procedure QPoint3(Rct: PQuadPoints3; const center, vector: TPoint3);
begin
  QPoint3(Rct, center, vec3to4(vector));
end;

procedure Rect3(Rct: PRect3; const center, vector: TPoint3); overload;
begin
  if Vector.y > 0 then
  begin
    Rct.Left := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Rct.Top := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Rct.Right := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z - Vector.z);
    Rct.Bottom := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z - Vector.z);
    Exit;
  end;
  // Vector.y <= 0
  Rct.Left := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Rct.Top := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Rct.Right := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z - Vector.z);
  Rct.Bottom := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z - Vector.z);
end;

function Rect3(const center, vector: TPoint3): TRect3; overload;
begin
  Rect3(@Result, center, vector);
end;

function Rect3(const left, top, right, bottom: TPoint3): TRect3;
begin
  Result.left := left;
  Result.top  := top;
  Result.right := right;
  Result.Bottom := bottom;
end;

function MatPointMul(const Pt: TPoint3; const Mtx: TMatrix4): TPoint3;
begin
  Result := Vec4To3(MatVecMul(Vec3to4(Pt), Mtx));
end;

procedure MatQuadMul(const Rct3: PQuadPoints3; const Mtx: TMatrix4); overload;
begin
  Rct3[0] := MatPointMul(Rct3[0], Mtx);
  Rct3[1] := MatPointMul(Rct3[1], Mtx);
  Rct3[2] := MatPointMul(Rct3[2], Mtx);
  Rct3[3] := MatPointMul(Rct3[3], Mtx);
end;

function MatQuadMul(const Rct3: TQuadPoints3; const Mtx: TMatrix4): TRect3;
begin
  Result.Left := MatPointMul(Rct3[0], Mtx);
  Result.Top := MatPointMul(Rct3[1], Mtx);
  Result.Right := MatPointMul(Rct3[2], Mtx);
  Result.Bottom := MatPointMul(Rct3[3], Mtx);
end;

function MatRecMul(const Rct3: TRect3; const Mtx: TMatrix4): TRect3;
begin
  Result.Left := MatPointMul(Rct3.Left, Mtx);
  Result.Top := MatPointMul(Rct3.Top, Mtx);
  Result.Right := MatPointMul(Rct3.Right, Mtx);
  Result.Bottom := MatPointMul(Rct3.Bottom, Mtx);
end;

procedure MatBoxMul(Cub: PBox; const Mtx: TMatrix4);
begin
  Cub.TopLeft := MatPointMul(Cub.TopLeft, Mtx);
  Cub.TopTop := MatPointMul(Cub.TopTop, Mtx);
  Cub.TopRight := MatPointMul(Cub.TopRight, Mtx);
  Cub.TopBottom := MatPointMul(Cub.TopBottom, Mtx);
  Cub.BottomLeft := MatPointMul(Cub.BottomLeft, Mtx);
  Cub.BottomTop := MatPointMul(Cub.BottomTop, Mtx);
  Cub.BottomRight := MatPointMul(Cub.BottomRight, Mtx);
  Cub.BottomBottom := MatPointMul(Cub.BottomBottom, Mtx);
end;

function MatBoxMul(const Cub: TBox; const Mtx: TMatrix4): TBox;
begin
  Result.TopLeft := MatPointMul(Cub.TopLeft, Mtx);
  Result.TopTop := MatPointMul(Cub.TopTop, Mtx);
  Result.TopRight := MatPointMul(Cub.TopRight, Mtx);
  Result.TopBottom := MatPointMul(Cub.TopBottom, Mtx);
  Result.BottomLeft := MatPointMul(Cub.BottomLeft, Mtx);
  Result.BottomTop := MatPointMul(Cub.BottomTop, Mtx);
  Result.BottomRight := MatPointMul(Cub.BottomRight, Mtx);
  Result.BottomBottom := MatPointMul(Cub.BottomBottom, Mtx);
end;

function RealRect(left, top, right, bottom: Real): TRealRect;
begin
  Result.left := left;
  Result.top  := top;
  Result.right := right;
  Result.Bottom := bottom;
end;

procedure SortRect3(const SRect3: PRect3);
//var sLeft, sTop, sRight, sBottom: TPoint3;
begin
  with SRect3^ do
  begin
    Top.z := Max(Top.z, Max(Left.z, Max(Right.z, Bottom.z)) );
    Bottom.z := Min(Top.z, Min(Left.z, Min(Right.z, Bottom.z)) );
    Left.x := Max(Top.x, Max(Left.x, Max(Right.x, Bottom.x)) );
    Right.x := Min(Top.x, Min(Left.x, Min(Right.x, Bottom.x)) );{}
  end;
end;

procedure Box(Box: PBox; const Center: TPoint3; Vector: TVector4);
begin
  if Vector.y >= 0 then
  begin
    Box.Top.Left := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Box.Top.Top := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z + Vector.z);
    Box.Top.Right := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z - Vector.z);
    Box.Top.Bottom := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z - Vector.z);
    Box.Bottom.Left := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z + Vector.z);
    Box.Bottom.Top := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z + Vector.z);
    Box.Bottom.Right := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z - Vector.z);
    Box.Bottom.Bottom := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z - Vector.z);

    SortRect3(@Box.Top);
    SortRect3(@Box.Bottom);
    Exit;
  end;

  // Vector.y <= 0
  Box.Top.Left := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Box.Top.Top := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z + Vector.z);
  Box.Top.Right := Point3(Center.x - Vector.x, Center.y - Vector.y, Center.z - Vector.z);
  Box.Top.Bottom := Point3(Center.x + Vector.x, Center.y - Vector.y, Center.z - Vector.z);
  Box.Bottom.Left := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z + Vector.z);
  Box.Bottom.Top := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z + Vector.z);
  Box.Bottom.Right := Point3(Center.x - Vector.x, Center.y + Vector.y, Center.z - Vector.z);
  Box.Bottom.Bottom := Point3(Center.x + Vector.x, Center.y + Vector.y, Center.z - Vector.z);

  SortRect3(@Box.Top);
  SortRect3(@Box.Bottom);
end;

procedure TAsphyrePuppet.Add(Puppet: TAsphyrePuppet);
var Index: Integer;
begin
  Index:= Length(FChildren);
  SetLength(FChildren, Length(FChildren) + 1);

  FChildren[Index]:= Puppet;
  FChildren[Index].FIndex:= Index;
end;

function TAsphyrePuppet.Add: TAsphyrePuppet;
var Index: Integer;
begin
  Index:= Length(FChildren);
  SetLength(FChildren, Length(FChildren) + 1);

  FChildren[Index]:= TAsphyrePuppet.Create(Self);
  FChildren[Index].FIndex:= Index;

  Result:= FChildren[Index];
end;

function TAsphyrePuppet.PuppetsDraw(WorldMtx: TMatrix4; Camera: TAsphyreCamera): boolean;
var i, ch: integer;
begin
  Result := true;
  ch := ChildCount;
  i := 0;
  repeat
    Result := Result and FChildren[i].Draw(WorldMtx, Camera);
    inc(i);
  until i >= ch;
end;

procedure TAsphyrePuppet.Clear;
var i: integer;
begin
  for i:= 0 to Length(FChildren) - 1 do
    if (FChildren[i] <> nil) then
      begin
        FChildren[i].Free();
        FChildren[i]:= nil;
      end;
  SetLength(FChildren, 0);
end;

procedure TAsphyrePuppet.DropChildren;
begin
  SetLength(FChildren, 0);
end;

constructor TAsphyrePuppet.Create(aOwner: TAsphyrePuppet);
begin
  FAutoUpdate := true;
  FModified := true;
  FScaled   := false;

  LocMtx := IdentityMatrix;
  GloMtx := IdentityMatrix;
  FOwner := aOwner;

  FScale.x := 1;
  FScale.y := 1;
  FScale.z := 1;
end;

procedure TAsphyrePuppet.Delete(Index: Integer);
var i: integer;
begin
  if (Index < 0) or (Index >= Length(FChildren)) then
    Exit;

  if (FChildren[Index] <> nil) then FChildren[Index].Free;

  // shift model list
  for i:= Index to Length(FChildren) - 2 do
  begin
   // shift the model
   FChildren[i]:= FChildren[i + 1];
   // update the index
   FChildren[i].FIndex:= i;
  end;

  // resize the list
  SetLength(FChildren, Length(FChildren) - 1);
end;

function TAsphyrePuppet.Draw(const Camera: TAsphyreCamera): Boolean;
begin
  Result := Draw(IdentityMatrix, Camera);
end;

function TAsphyrePuppet.Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean;
begin
  Result := True;

  if ChildCount > 0 then
    Result := PuppetsDraw(WorldMtx, Camera);
end;

function TAsphyrePuppet.GetCount: Integer;
begin
  Result := Length(FChildren);
end;

function TAsphyrePuppet.GetItem(aName: string): TAsphyrePuppet;

  function FindByName(aPuppet: TAsphyrePuppet): TAsphyrePuppet;
  var i: integer;
  begin
    Result := nil;
    for i:= 0 to aPuppet.ChildCount - 1 do
      if (aName = LowerCase(aPuppet.Children[i].Name)) then begin
        Result := aPuppet.Children[i];
        Exit;
      end else
        Result := FindByName(aPuppet.Children[i]);
  end;

begin
  aName := LowerCase(aName);
  if aName = LowerCase(Name) then
  begin
    Result := Self;
    Exit;
  end;
  Result := FindByName(Self);
end;

function TAsphyrePuppet.GetPuppet(Num: Integer): TAsphyrePuppet;
begin
  Result:= nil;
  if (Num >= 0) and (Num < Length(FChildren)) then
    Result:= FChildren[Num];
end;

function TAsphyrePuppet.IndexOf(Model: TAsphyrePuppet): Integer;
var i, ch: integer;
begin
  Result := -1;

  ch := Length(FChildren);
  if ch > 0 then
  begin
    i := 0;
    repeat
      if (FChildren[i] = Model) then
      begin
        Result := i;
        Exit;
      end;
      inc(i);
    until i >= ch;
  end;
end;

destructor TAsphyrePuppet.Destroy;
begin
  ClearSubs;
  Clear;
  inherited;
end;

procedure TAsphyrePuppet.SetPosition(const Value: TPoint3);
begin
  FPosition := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetScale(const Value: TPoint3);
begin
  FScale := Value;
  FModified := true;
  FScaled := (Value.X<>1)or(Value.Y<>1)or(Value.Z<>1);
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetRotation(const Value: TPoint3);
begin
  FRotation := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.Update;
var i, ch: integer;
begin
  if Owner<>nil then
    //FGloMtx := MatMul(FGloMtx, Owner.FLocMtx);
    PMatMul(@FGLoMtx, @Owner.FLocMtx);

  ch := ChildCount;
  if ch > 0 then
  begin
    i := 0;
    repeat
      FChildren[i].UpdateLocal;
      FChildren[i].Update;
      inc(i);
    until i >= ch;
  end
end;

function TAsphyrePuppet.GetModified: boolean;
begin
  Result := FModified;
end;

function TAsphyrePuppet.GetPositionX: double;
begin
  Result := FPosition.X;
end;

function TAsphyrePuppet.GetPositionY: double;
begin
  Result := FPosition.Y;
end;

function TAsphyrePuppet.GetPositionZ: double;
begin
  Result := FPosition.Z;
end;

function TAsphyrePuppet.GetRotationX: double;
begin
  Result := FRotation.X;
end;

function TAsphyrePuppet.GetRotationY: double;
begin
  Result := FRotation.Y;
end;

function TAsphyrePuppet.GetRotationZ: double;
begin
  Result := FRotation.Z;
end;

function TAsphyrePuppet.GetScaleX: double;
begin
  Result := FScale.X;
  FScaled := (FScale.X<>1)or(FScale.Y<>1)or(FScale.Z<>1);
end;

function TAsphyrePuppet.GetScaleY: double;
begin
  Result := FScale.Y;
  FScaled := (FScale.X<>1)or(FScale.Y<>1)or(FScale.Z<>1);
end;

function TAsphyrePuppet.GetScaleZ: double;
begin
  Result := FScale.Z;
  FScaled := (FScale.X<>1)or(FScale.Y<>1)or(FScale.Z<>1);
end;

procedure TAsphyrePuppet.Reset;
const OnesVector3: TPoint3 = (x: 1.0; y: 1.0; z: 1.0);
begin
  FRotation := ZeroVector3;
  FScale := OnesVector3;
  FPosition := ZeroVector3;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetBasicPos(const Value: TPuppetState);
begin
  FBasicPos := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetPositionX(const Value: double);
begin
  FPosition.x := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetPositionY(const Value: double);
begin
  FPosition.y := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetPositionZ(const Value: double);
begin
  FPosition.z := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetRotationX(const Value: double);
begin
  FRotation.x := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetRotationY(const Value: double);
begin
  FRotation.y := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetRotationZ(const Value: double);
begin
  FRotation.z := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetScaleX(const Value: double);
begin
  FScale.x := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetScaleY(const Value: double);
begin
  FScale.y := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.SetScaleZ(const Value: double);
begin
  FScale.z := Value;
  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

var chM, chA, chB, chC, chT, chP: TMatrix4;

procedure TAsphyrePuppet.UpdateLocal;
var
   TempPoint, NegPivot, Pivot: TVector4;
const
   OnesVector4: TVector4 = (x: 0.0; y: 1.0; z: 0.0; w: 0.0);

begin
  try
    Pivot := Vec3to4(GPivot);
    PMatTransl(@chP, Pivot);                                         //MatTransl(P)
    NegPivot := VecNeg4(Pivot);

    //-------- Model basic orientation -------------
    SetIdentityMatrix(@chM);                                         //M := IdentityMatrix;
    //rotate
    if (BasicPos.Rotation.X<>0) then begin                           //M := MatMul(M, MatRotateX(BasicPos.Rotation.X));
      PBufMatRotateX(BasicPos.Rotation.X);                           //
      PBufMatMul(@chM);                                              //
    end;
    if (BasicPos.Rotation.Y<>0) then begin                           //M := MatMul(M, MatRotateY(BasicPos.Rotation.Y));
      PBufMatRotateY(BasicPos.Rotation.Y);                           //
      PBufMatMul(@chM);                                              //
    end;
    if (BasicPos.Rotation.Z<>0) then begin                           //M := MatMul(M, MatRotateZ(BasicPos.Rotation.Z));
      PBufMatRotateZ(BasicPos.Rotation.Z);                           //
      PBufMatMul(@chM);{}                                            //
    end;
    //move
    TempPoint := Vec3to4(BasicPos.Position);                         //M := MatMul(M, MatTransl(Vec3to4(BasicPos.Position)));
    PBufMatTransl(@TempPoint);                                       //
    PBufMatMul(@chM);                                                //

    if (BasicPos.Scale.X<>1) or (BasicPos.Scale.Y<>1) or (BasicPos.Scale.Z<>1) then
    begin
      // move to pivot
      PBufMatTransl(@NegPivot);                                      //T := MatMul(M, MatTransl(NP));
      PBufMatMul(@chM);                                              //
      //resize
      PBufMatScale(Vec3to4(BasicPos.Scale));                         //M := MatMul(T, MatScale(Vec3to4(BasicPos.Scale)));
      PBufMatMul(@chM);                                              //
      PMatMul(@chM, @chP);                                           //M := MatMul(M, MatTransl(P));
    end;

    PCopyMtx(@chM, @FLocMtx);                                        //FLocMtx := M;

    //--------- Model transformation --------------
    SetIdentityMatrix(@chM);                                         //M := IdentityMatrix;

    // move to pivot
    // using identity matrix actually stored in chM
    PCopyMtx(@chM, @chT);                                            //T := MatMul(M, MatTransl(NP));
    PBufMatTransl(@NegPivot);                                        //
    PBufMatMul(@chT);                                                //

    // rotate along X
    if Rotation.X<>0 then begin
      PCopyMtx(@chT, @chA);                                          //A := MatMul(T, MatRotateX(Rotation.X));
      PBufMatRotateX(Rotation.X);                                    //
      PBufMatMul(@chA);                                              //
      //move back from pivot
      PMatMul(@chA, @chP);                                           //A := MatMul(A, MatTransl(P));
    end else SetIdentityMatrix(@chA);
    // rotate along Y
    if Rotation.Y<>0 then begin
      PCopyMtx(@chT, @chB);                                          //B := MatMul(T, MatRotateY(Rotation.Y));
      PBufMatRotateY(Rotation.Y);                                    //
      PBufMatMul(@chB);                                              //
      //move back from pivot
      PMatMul(@chB, @chP);                                           //B := MatMul(B, MatTransl(P));
    end else SetIdentityMatrix(@chB);
    // rotate along Z
    if Rotation.Z<>0 then begin
      PCopyMtx(@chT, @chC);                                          //C := MatMul(T, MatRotateZ(Rotation.Z));
      PBufMatRotateZ(Rotation.Z);                                    //
      PBufMatMul(@chC);                                              //
      //move back from pivot
      PMatMul(@chC, @chP);                                           //C := MatMul(C, MatTransl(P));
    end else SetIdentityMatrix(@chC);
    // resize
    if FScaled then
    begin
      PBufMatScale(Vec3to4(Scale));                                  //M := MatMul(M, MatScale(Vec3to4(Scale)));
      PBufMatMul(@chM);                                              //
    end;
    // translate
    TempPoint := Vec3to4(Position);                                  //M := MatMul(M, MatTransl(Vec3to4(Position)));
    PBufMatTransl(@TempPoint);                                       //
    PBufMatMul(@chM);                                                //

    //SetIdentityMatrix(@chT);
    // SUM all transformations
    PMatMul(@chC, @chB);                                             //M := MatMul(M, MatMul(MatMul( C, B), A));
    PMatMul(@chC, @chA);                                             //
    PMatMul(@chM, @chC);                                             //

    if Owner<>nil then
      PRMatMul(@FGloMtx, @chM, @Owner.FGloMtx)                       //FGloMtx := MatMul(M, Owner.FGloMtx)
    else
      PCopyMtx(@chM, @FGloMtx);                                      //FGloMtx := M;
  except
    PCopyMtx(@IdentityMatrix, @chM);
  end;
(* *)
end;

procedure TAsphyrePuppet.SetPivot(const Value: TPoint3);
begin
  FPivot := Value;
end;

function TAsphyrePuppet.GPivot: TPoint3;
begin
  Result.x := BasicPos.Position.x + FPosition.x + FPivot.x;
  Result.y := BasicPos.Position.y + FPosition.y + FPivot.y;
  Result.z := BasicPos.Position.z + FPosition.z + FPivot.z;
end;

procedure TAsphyrePuppet.Resize(const sX, sY, sZ: double);
begin
  FScale.X := sX;
  FScale.Y := sY;
  FScale.Z := sZ;

  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.Rotate(const dX, dY, dZ: double);
begin
  FRotation.X := FRotation.X + dX;
  if FRotation.X > Pi2 then FRotation.X := FRotation.X - Pi2;
  if FRotation.X < -Pi2 then FRotation.X := Pi2 + FRotation.X;

  FRotation.Y := FRotation.Y + dY;
  if FRotation.Y > Pi2 then FRotation.Y := FRotation.Y - Pi2;
  if FRotation.Y < -Pi2 then FRotation.Y := Pi2 + FRotation.Y;

  FRotation.Z := FRotation.Z + dZ;
  if FRotation.Z > Pi2 then FRotation.Z := FRotation.Z - Pi2;
  if FRotation.Z < -Pi2 then FRotation.Z := Pi2 + FRotation.Z;

  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

procedure TAsphyrePuppet.Move(const dX, dY, dZ: double);
var P, Pos: TVector4;
  Rot: TPoint3; 
begin
  if (dZ<>0) or (dX<>0) or (dY<>0) then
  begin
    Rot := FRotation;

    SetIdentityMatrix(@chM);

    if Rot.X<>0 then
    begin
      PBufMatRotateX(Rot.X);
      PBufMatMul(@chM);
    end;
    if Rot.Y<>0 then
    begin
      PBufMatRotateY(Rot.Y);
      PBufMatMul(@chM);
    end;
    if Rot.Z<>0 then
    begin
      PBufMatRotateZ(Rot.Z);
      PBufMatMul(@chM);
    end;

    P.X := dX;
    P.Y := dY;
    P.Z := dZ;
    P.W := 1;

    PMatVecMul(@Pos, P, chM);

    FPosition := VecAdd3( FPosition,  Vec4to3(Pos) );

    FModified := true;
    if FAutoUpdate then
      UpdateLocal;
  end;
end;

procedure TAsphyrePuppet.Translate(const dX, dY, dZ: double);
begin
  FPosition.X := FPosition.X + dX;
  FPosition.Y := FPosition.Y + dY;
  FPosition.Z := FPosition.Z + dZ;

  FModified := true;
  if FAutoUpdate then
    UpdateLocal;
end;

function TAsphyrePuppet.GetGlobalPivot: TPoint3;
begin
  PMatVecMul(@Result, Vec3to4(GPivot), FGloMtx);
end;

function TAsphyrePuppet.GetGlobalPosition: TPoint3;
var P, Res: TVector4;
begin
  P.x := FBasicPos.Position.x + FPosition.x + FPivot.x;
  P.y := FBasicPos.Position.y + FPosition.y + FPivot.y;
  P.z := FBasicPos.Position.z + FPosition.z + FPivot.z;
  P.w := 1;
  //P := MatVecMul(P, OwnerGlo);//GloMtx);
  PMatVecMul(@Res, P, OwnerGLo);
  Result.x := Res.x;
  Result.y := Res.y;
  Result.z := Res.z;
end;

function TAsphyrePuppet.GetGlobalRotation: TPoint3;

  function OwnerRotation(Pup: TAsphyrePuppet): TPoint3;
  var R: TPoint3;
  begin
    Result := ZeroPoint3;
    if Pup.FOwner<>nil then
    begin
      R := OwnerRotation(Pup.FOwner);
      Result.X := Pup.FRotation.x + R.x;
      Result.Y := Pup.FRotation.y + R.y;
      Result.Z := Pup.FRotation.z + R.z;
    end;
  end;

var Rot: TPoint3;

begin
  Rot := OwnerRotation(Self);
  Result.X := Rot.x;
  Result.Y := Rot.y;
  Result.Z := Rot.z;

  if Result.X > Pi2 then Result.X := Result.X - Pi2;
  if Result.X < -Pi2 then Result.X := Pi2 + Result.X;

  if Result.Y > Pi2 then Result.Y := Result.Y - Pi2;
  if Result.Y < -Pi2 then Result.Y := Pi2 + Result.Y;

  if Result.Z > Pi2 then Result.Z := Result.Z - Pi2;
  if Result.Z < -Pi2 then Result.Z := Pi2 + Result.Z;
end;

function TAsphyrePuppet.GetGlobalScale: TPoint3;
var P: TVector4;
begin
  P.x := FBasicPos.Scale.x + FScale.x;
  P.y := FBasicPos.Scale.y + FScale.y;
  P.z := FBasicPos.Scale.z + FScale.z;
  P.w := 1;
  P := MatVecMul(P, GloMtx);
  Result.X := P.x;
  Result.Y := P.y;
  Result.Z := P.z;
end;

function PointInDistanceFromPuppetDirection(const DistVector: TVector4; const Puppet: TAsphyrePuppet): TPoint3;
var P: TVector4;
begin
  if (DistVector.z<>0) or (DistVector.x<>0) or (DistVector.y<>0) then
  begin
    PMatVecMul(@P, DistVector, Puppet.FGloMtx);
    Result := Vec4to3(P);
    Exit;
  end;
  Result := Puppet.PositionGlobal;
end;

procedure BaseState(var State: TPuppetState);
begin
  FillChar(State, SizeOf(State), #0);
  State.Scale.x := 1;
  State.Scale.y := 1;
  State.Scale.z := 1;
end;

procedure TAsphyrePuppet.ClearSubs;
var i, sb: integer;
begin
  sb := Length(FSubs);
  if sb > 0 then
  begin
    i := 0;
    repeat
      if (FSubs[i] <> nil) then
      begin
        FSubs[i].Free();
        FSubs[i]:= nil;
      end;
      inc(i);
    until i >= sb;
  end;
  SetLength(FSubs, 0);
end;

procedure TAsphyrePuppet.DeleteSub(Index: Integer);
var i: integer;
begin
  if (Index < 0) or (Index >= Length(FSubs)) then
    Exit;

  if (FSubs[Index] <> nil) then FreeAndNil(FSubs[Index]);

  // shift model list
  for i:= Index to Length(FSubs) - 2 do
  begin
   // shift the model
   FSubs[i]:=FSubs[i + 1];
  end;

  // resize the list
  SetLength(FSubs, Length(FSubs) - 1);
end;

function TAsphyrePuppet.GetObject(Num: Integer): T3DObject;
begin
  Result:= nil;
  if (Num >= 0) and (Num < Length(FSubs)) then
    Result:= FSubs[Num];
end;

function TAsphyrePuppet.IndexOfSub(Sub: T3DObject): Integer;
var i, sb: integer;
begin
  Result := -1;
  sb := Length(FSubs);
  if sb > 0 then
  begin
    i := 0;
    repeat
      if (FSubs[i] = Sub) then
      begin
        Result := i;
        Exit;
      end;
      inc(i);
    until i >= sb;
  end;
end;

function TAsphyrePuppet.GetSubsCount: Integer;
begin
  Result := Length(FSubs);
end;

function TAsphyrePuppet.AddSub(Sub: T3DObject): T3DObject;
var Index: Integer;
begin
  try
    Index:= Length(FSubs);
    SetLength(FSubs, Length(FSubs) + 1);

    FSubs[Index] := Sub;

    Result:= FSubs[Index];
  except
    Result := nil;
  end;
end;

function TAsphyrePuppet.OwnerGlo: TMatrix4;
begin
  if Owner<>nil then
  begin
    Result := Owner.FGloMtx;// MatMul(FGLoMtx, Owner.OwnerGlo)
    Exit;
  end;
  Result := FGloMtx;
end;

function TAsphyrePuppet.DrawVisibled(const Camera: TAsphyreCamera; CameraOrigin: PPoint3): Boolean;
var i, ch: integer;
begin
  Result := true;
  ch := ChildCount;
  if ch > 0 then
  begin
    i := 0;
    repeat
      Result := Result and FChildren[i].DrawVisibled(Camera, CameraOrigin);
      inc(i);
    until i >= ch;
  end;
end;

procedure TAsphyrePuppet.SetAutoUpdate(const Value: boolean);
begin
  FAutoUpdate := Value;
end;

{ TBasicPuppet }

constructor TBasicPuppet.Create(aOwner: TAsphyrePuppet);
begin
  FModelLoaded := False;
  FModelObject := T3DModelObject.Create;
  FBoundsUpdated := False;
  FAsphyreModelsCache := nil;

  inherited Create(aOwner);
  FVisible := true;

  AddSub(FModelObject);
end;

function TBasicPuppet.DistanceFromPointToCenter(const Pt: TPoint3): Real;
var NestedPoint: TVector4;
begin
  Result := 0;
  if (FModelLoaded) and (FModelObject<>nil) then
  begin
    //NestedPoint := MatVecMul(Vec3To4(Pt), MatInverse(FLocGloMtx));
    NestedPoint := VecAdd4(Vec3To4(FModelObject.FCenter), Vec3To4(PositionGlobal));

    Result := VecDist4(NestedPoint, Vec3To4(Pt));
  end;
end;

function TBasicPuppet.DistanceFromPointToVector(const Pt: TPoint3): Real;
var NestedPoint: TVector4;
begin
  Result := 0;
  if (FModelLoaded) and (FModelObject<>nil) then
  begin
    NestedPoint := VecSub4( MatVecMul(Vec3To4(Pt), MatInverse(FLocGloMtx)), FModelObject.Vector);

    Result := VecDist4(Vec3To4(FModelObject.FCenter), NestedPoint);
  end;
end;

function TBasicPuppet.DrawVisibled(const Camera: TAsphyreCamera; CameraOrigin: PPoint3): Boolean;
var TmpPoint, TPt: TPoint3;
begin
  // TODO !!!
  TmpPoint := MatPointMul(GPivot, MatInverse(Camera.ViewMtx));
  TPt      := VecSub3(CameraOrigin^, TmpPoint);
  if (TPt.y > CameraOrigin.z) and (TPt.x > CameraOrigin.x) and (TPt.z > CameraOrigin.z) then
  begin
    Draw(Camera);
    
    Result := inherited DrawVisibled(Camera, CameraOrigin);
  end else
    Result := True;
end;

function TBasicPuppet.Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean;
var lModel: TAsphyreModel;
begin
  Result := True;
  if Visible then
  begin
    if (FAsphyreModelsCache<>nil) then
      Result := FAsphyreModelsCache.Draw(Model, @FLocGloMtx)
    else
    begin
      lModel := Model;      
      Result := ( (lModel<>nil) and lModel.Draw(FLocGloMtx, Camera) );
    end;
  end;
  if length(FChildren) > 0 then
    PuppetsDraw(WorldMtx, Camera);{}
end;

function TBasicPuppet.GetBounds: TBox;
begin
  FillChar(Result, SizeOf(TBox), #0);

  if FModelLoaded then
  begin
    if not FBoundsUpdated then
    begin
      FModelObject.Update(FLocGloMtx);//MatMul(FGloMtx, IdentityMatrix)));
      FBoundsUpdated := True;
    end;
    FModelObject.GetBounds(@Result);
  end;
end;

function TBasicPuppet.GetCenter: TPoint3;
begin
  if FModelLoaded then
    Result := FModelObject.ActCenter(FLocGloMtx)
end;

function TBasicPuppet.GetDepth: Real;
begin
  Result := 0;
  if FModelLoaded then
    Result := FModelObject.Size.z;
end;

function TBasicPuppet.GetHeight: Real;
begin
  Result := 0;
  if FModelLoaded then
    Result := FModelObject.Size.y;
end;

function TBasicPuppet.GetModel: TAsphyreModel;
begin
  Result := nil;
  FModelLoaded := (FModelObject<>nil) and (FModelObject.Model<>nil);

  if FModelLoaded then
    Result := FModelObject.Model;
end;

function TBasicPuppet.GetModelObject: T3DModelObject;
begin
  Result := nil;
  if FModelLoaded then
    Result := FModelObject;
end;

function TBasicPuppet.GetPBounds: PBox;
begin
  Result := nil;

  if FModelLoaded then
  begin
    if not FBoundsUpdated then
    begin
      FModelObject.Update(FLocGloMtx);//MatMul(FGloMtx, IdentityMatrix)));
      FBoundsUpdated := True;
    end;
    Result := @FModelObject.FBounds;
  end;
end;

function TBasicPuppet.GetSize: TPoint3;
begin
  if FModelLoaded then
    Result := FModelObject.Size;
end;

function TBasicPuppet.GetVector: TVector4;
begin
  if FModelLoaded then
    Result := FModelObject.FVector;
end;

function TBasicPuppet.GetWidth: Real;
begin
  Result := 0;
  if FModelLoaded then
    Result := FModelObject.Size.x;
end;

function TBasicPuppet.PointInBounds(const Pt: TPoint3): Boolean;
var Bounds: TBox;
  NestedPoint: TPoint3;
  VecPtCenter: TVector4;
begin
  Result := False;
  if FModelLoaded then
    with FModelObject do
    begin
      NestedPoint := MatPointMul(Pt, MatInverse(FLocGloMtx) );

      // First test wheter is Pt near enough
      // menas that vector from center->Pt is smaller than vector
      VecPtCenter := VecToFrom4(Vec3To4(NestedPoint), Vec3To4(Center));

      Result := (abs(VecPtCenter.x) < abs(FVector.x)) and (abs(VecPtCenter.y) < abs(FVector.y)) and (abs(VecPtCenter.z) < abs(FVector.z));

      if Result then
      begin
        // Ok, Point is near enough to test wheter it is inside
        FillChar(Bounds, SizeOf(TBox), 0);
        Box(@Bounds, Center, Vector);

        Result := ValInRange(NestedPoint.x, Bounds.Bottom.Left.x, Bounds.Bottom.Right.x) and
                  ValInRange(NestedPoint.y, Bounds.Bottom.Bottom.y, Bounds.Top.Top.y) and
                  ValInRange(NestedPoint.z, Bounds.Bottom.Left.z, Bounds.Bottom.Right.z);
                  {(NestedPoint.x > Bounds.Bottom.Left.x) and (NestedPoint.x < Bounds.Bottom.Right.x) and
                  (NestedPoint.z > Bounds.Bottom.Bottom.z) and (NestedPoint.z < Bounds.Bottom.Top.z) and
                  (NestedPoint.y > Bounds.Bottom.Bottom.y) and (NestedPoint.y < Bounds.Top.Top.y);{}
      end;
    end;
end;

procedure TBasicPuppet.SetModel(const Value: TAsphyreModel);
begin
  FModelLoaded := False;
  if (FModelObject<>nil) then
  begin
    if (Value<>nil) and not Value.Loaded then
      FModelObject.Model := nil
    else
      FModelObject.Model := Value;

    FModelLoaded := (Value<>nil) and (FModelObject.Model<>nil);
  end;
end;

procedure TBasicPuppet.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  if FModelObject<>nil then
    FModelObject.Visible := Value;
end;

procedure TBasicPuppet.UpdateLocal;
begin
  inherited UpdateLocal;

  {if (M[0][0] <> FLocGloMtx[0][0]) or (M[1][1] <> FLocGloMtx[1][1]) or (M[2][2] <> FLocGloMtx[2][2]) or (M[3][3] <> FLocGloMtx[3][3])
  or (M[3][0] <> FLocGloMtx[3][0]) or (M[3][2] <> FLocGloMtx[3][2]) or (M[3][3] <> FLocGloMtx[3][3])
  then{}
  begin
    FBoundsUpdated := False;
    //M := MatMul(FLocMtx, MatMul(FGloMtx, IdentityMatrix));
    PRMatMul(@FLocGloMtx, @FLocMtx, @FGloMtx);
  end;
end;

{ T3DObject }

function T3DObject.Draw(const Mtx: TMatrix4; Camera: TAsphyreCamera): Boolean;
begin
  Result := False;
  //virtual...
end;

procedure T3DObject.Update(const Mtx: TMatrix4);
begin
  //virtual...
end;

{ T3DModelObject }

function T3DModelObject.Draw(const Mtx: TMatrix4; Camera: TAsphyreCamera): Boolean;
begin
  Result := not FVisible or
            ((FModel<>nil) and FModel.Draw(Mtx, Camera));
end;

function InitCameraPuppet(const Origin, Target: TPoint3; const Camera: TAsphyreCamera): TCameraPuppet;
begin
  Result := nil;
end;

procedure T3DModelObject.UpdateCenterBoundBox;
var Vertex: PTexturedMeshFVF;
  Index: INteger;
  Vertice: TD3DVector;
  Min, Max: TPoint3;
begin
  {FCenter := Point3(0, 0, 0);
  FSize   := POint3(0, 0, 0);
  FVector := Vector4(0, 0, 0, 1);{}
  if (FModel=nil) or not TDXMeshAccess(FModel.DXMesh).LockVBuffer(Pointer(Vertex)) then
    Exit;

  try
    Min := Point3(10000000, 10000000, 10000000);
    Max := Point3(-10000000, -10000000, -10000000);

    for Index:= 0 to TDXMeshAccess(FModel.DXMesh).VertexCount - 1 do
    begin
      Vertice := Vertex.Vertex;

      if (Vertice.x < Min.x) then Min.x := Vertice.x;
      if (Vertice.y < Min.y) then Min.y := Vertice.y;
      if (Vertice.z < Min.z) then Min.z := Vertice.z;

      if (Vertice.x > Max.x) then Max.x := Vertice.x;
      if (Vertice.y > Max.y) then Max.y := Vertice.y;
      if (Vertice.z > Max.z) then Max.z := Vertice.z;

      Inc(Integer(Vertex), TDXMeshAccess(FModel.DXMesh).VertexFVFSize);
    end;

    FCenter := Point3( (Max.x + Min.x) / 2, (Max.y + Min.y) / 2, (Max.z + Min.z) / 2);
    FSize   := Point3( abs(Max.x - Min.x), abs(Max.y - Min.y), abs(Max.z - Min.z) );
    FVector := Vector4( abs(Max.x - FCenter.x), abs(Max.y - FCenter.y), abs(Max.z - FCenter.z), 1);
  finally
    TDXMeshAccess(FModel.DXMesh).UnlockVBuffer;
  end;
end;

procedure T3DModelObject.SetModel(const Value: TAsphyreModel);
begin
  FModel := Value;

  UpdateCenterBoundBox;
end;

function T3DModelObject.GetBoundBox: TBox;
begin
  Result := FBounds;
end;

procedure T3DModelObject.Update(const Mtx: TMatrix4);
begin
  Box(@FBounds, FCenter, FVector);
  MatBoxMul(@FBounds, Mtx);
end;

constructor T3DModelObject.Create;
begin
  FCenter := Point3(0, 0, 0);
  FVector := Vector4(0, 0, 0, 1);

  FillChar(FBounds, SizeOf(TBox), 0);
  Box(@FBounds, FCenter, FVector);
end;

procedure T3DModelObject.GetBounds(Box: PBox);
begin
  Box.Top := FBounds.Top;
  Box.Bottom := FBounds.Bottom;
end;

function T3DModelObject.ActCenter(const Mtx: TMatrix4): TPoint3;
begin
  Result := MatPointMul(FCenter, Mtx);
end;

function T3DModelObject.DrawCache(Mtx: PMatrix4; AsphyreModelsCache: TAsphyreModelsCache): Boolean;
begin
  Result := AsphyreModelsCache.Draw(FModel, Mtx);
end;

{ TCameraPuppet }

constructor TCameraPuppet.Create(aOwner: TAsphyrePuppet);
begin
  inherited Create(aOwner);

  FRoof := Point3(0, 200, 0);
end;

procedure TCameraPuppet.MouseLook(const x, y, z: Real);
begin

end;

procedure TCameraPuppet.UpdateCamera;
begin
  //Camera.View.LookAt(,,FRoof);
end;

{ T3DQuadPointsObject }

constructor T3DQuadPointsObject.Create;
begin
  FCenter := ZeroPoint3;
  FVector := ZeroVector4;
  FQuadPoints := QuadPoints3(ZeroPoint3, ZeroPoint3, ZeroPoint3, ZeroPoint3);
end;

procedure T3DQuadPointsObject.CreateRect3(const aCenter: TPoint3; const aVector: TVector4);
begin
  FCenter := aCenter;
  FVector := aVector;
  QPoint3(@FQuadPoints, FCenter, Vector);
end;

procedure T3DQuadPointsObject.Update(const Mtx: TMatrix4);
begin
  QPoint3(@FQuadPoints, FCenter, FVector);
  MatQuadMul(@FQuadPoints, Mtx);
end;

procedure T3DQuadPointsObject.GetQuadPoints(var Rct: PQuadPoints3);
begin
  Rct := @FQuadPoints;
end;

procedure T3DQuadPointsObject.CreateRect3(const aCenter: TPoint3; const Size: TPoint2);
begin
  FCenter := aCenter;
  FVector := Vector4(Center.x + Size.x / 2, Center.y, Center.z + Size.y / 2, 1);
  QPoint3(@FQuadPoints, Center, Vector);
end;

procedure T3DQuadPointsObject.SetQuadPoints(const Value: TQuadPoints3);
var Min, Max: TPoint3;
  i: integer;
begin
  FCenter := ZeroPoint3;
  FVector := ZeroVector4;

  Min := Point3(10000000, 10000000, 10000000);
  Max := Point3(-10000000, -10000000, -10000000);

  i := 0;
  repeat
    if (Value[i].x < Min.x) then Min.x := Value[i].x;
    if (Value[i].y < Min.y) then Min.y := Value[i].y;
    if (Value[i].z < Min.z) then Min.z := Value[i].z;

    if (Value[i].x > Max.x) then Max.x := Value[i].x;
    if (Value[i].y > Max.y) then Max.y := Value[i].y;
    if (Value[i].z > Max.z) then Max.z := Value[i].z;

    inc(i);
  until i > 4;

  FCenter := Point3( (Max.x + Min.x) / 2, (Max.y + Min.y) / 2, (Max.z + Min.z) / 2);
  FSize   := Point3( abs(Max.x - Min.x), abs(Max.y - Min.y), abs(Max.z - Min.z) );
  FVector := Vector4( abs(Max.x - FCenter.x), abs(Max.y - FCenter.y), abs(Max.z - FCenter.z), 1);
end;

{ TFacingPuppet }

constructor TFacingPuppet.Create(aOwner: TAsphyrePuppet);
begin
  FRectLoaded := False;
  FFacingObject := T3DQuadPointsObject.Create;

  inherited;

  FVisible := True;
  AddSub(FFacingObject);
  FRectLoaded := (FFacingObject<>nil);
end;

function TFacingPuppet.Draw(const WorldMtx: TMatrix4; const Camera: TAsphyreCamera): Boolean;
begin
  Result := FVisible and ((FImage<>nil) and FRectLoaded);
            
  if Result then
    FFacing.Draw(GetQuadPoints, FImage, FColor, FTexCoord, FBlendOp);

  if length(FChildren) > 0 then
    PuppetsDraw(WorldMtx, Camera);
end;

function TFacingPuppet.GetQuadPoints: TQuadPoints3;
begin
  FillChar(Result, SizeOf(TRect3), #0);

  if FRectLoaded then
  begin
    if not FRectUpdated then
    begin
      FFacingObject.Update(FLocGloMtx);//MatMul(FGloMtx, IdentityMatrix)));
      FRectUpdated := True;
    end;
    Result := FFacingObject.QuadPoints;
    Exit;
  end;
  Result := QPoint3(ZeroPOint3, ZeroVector4);
end;

function TFacingPuppet.GetPQuadPoints: PQuadPoints3;
begin
  Result := nil;
  if FRectLoaded then
  begin
    if not FRectUpdated then
    begin
      FFacingObject.Update(FLocGloMtx);//MatMul(FGloMtx, IdentityMatrix)));
      FRectUpdated := True;
    end;
    Result := @FFacingObject.FQuadPoints;
  end;
end;

procedure TFacingPuppet.SetQuadPoints(const aCenter: TPoint3; const aVector: TVector4);
begin
  if FRectLoaded then
  begin
    FFacingObject.CreateRect3(aCenter, aVector);
    FRectUpdated := False;
  end;
end;

procedure TFacingPuppet.SetQuadPoints(const aCenter: TPoint3; const aSize: TPoint2);
begin
  if FRectLoaded then
  begin
    FFacingObject.CreateRect3(aCenter, aSize);
    FRectUpdated := False;
  end;
end;

procedure TFacingPuppet.SetQuadPoints(Puppet: TModelPuppet);
var ACenter: TPoint3;
  AVector: TVector4;
begin
  if FRectLoaded then
  begin
    ACenter := Puppet.FModelObject.FCenter;
    AVector := Puppet.FModelObject.FVector;

    ACenter.y := 0;
    AVector.y := 0;
    
    FFacingObject.CreateRect3(aCenter, aVector);
    FRectUpdated := False;
  end;
end;

procedure TFacingPuppet.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

procedure TFacingPuppet.UpdateLocal;
begin
  inherited UpdateLocal;

  FRectUpdated := False;
  //FLocGloMtx := MatMul(FLocMtx, MatMul(FGloMtx, IdentityMatrix));
  PRMatMul(@FLocGloMtx, @FLocMtx, @FGloMtx);
end;

end.

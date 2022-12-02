unit XObjects;

interface

uses Math, Types, AsphyreTypes, Vectors2;

//------------------------------------------------------------------------------
type
  TXObject = class
  private
  protected
    {A protected member is visible anywhere in the module where its class
    is declared and from any descendant class, regardless of the module where
    the descendant class appears. A protected method can be called,
    and a protected field or property read or written to, from the definition
    of any method belonging to a class that descends from the one where
    the protected member is declared. Members that are intended for use only
    in the implementation of derived classes are usually protected.}
    FName    : string;
    FPosition: TPoint2;
    FPrevPos : TPoint2;
    FAngle   : Single; // Direction

    //FParent: TXObject;
    //FChild : TXObject;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Update(DeltaTime: Single); virtual; abstract;

    procedure Translate(const Dist: TPoint2); inline;
    // returns object angle
    function LookAt(const x, y: Real): Real; virtual;

    property Name    : string read FName write FName;
    property Position: TPoint2 read FPosition write FPosition;
    property PrevPos : TPoint2 read FPrevPos write FPrevPos;
    property Angle   : Single read FAngle write FAngle;
  end;

//------------------------------------------------------------------------------
  PRenderSettings = ^TRenderSettings;
  TRenderSettings = record
    Pivot  : TPoint2;
    Angle  : Single;
    Scale  : TPoint2;
    Size   : TPoint2;
    Mirror : Boolean;
    Flip   : Boolean;
    Color4 : TColor4;
    Pattern: Integer;
    DrawFx : Cardinal;
  end;

//------------------------------------------------------------------------------
  TRenderable = class(TXObject)
  private
  protected
    FPivot  : TPoint2;
    FScale  : TPoint2;
    FPatSize: TPoint2;
    FMirror : Boolean;
    FFlip   : Boolean;
    FColor4 : TColor4;
    FPattern: Integer;
    FDrawFx : Cardinal;
    FVisible: Boolean;                 

    procedure SetRenderSettings(const RS: TRenderSettings);
    function GetRenderSettings(): TRenderSettings;
    function GetSize(): TPoint2; inline;
    procedure SetSize(const Value: TPoint2);
  public
    constructor Create();

    procedure Render(); virtual; abstract;

    procedure Show();
    procedure Hide();

    function GetRenderQuad(dX, dY: Integer): TPoint4; inline;
    function GetMapping(): TPoint4; inline;

    property Pivot  : TPoint2 read FPivot write FPivot;
    property Scale  : TPoint2 read FScale write FScale;
    property Size   : TPoint2 read GetSize write SetSize;
    property PatSize: TPoint2 read FPatSize write FPatSize;
    property Mirror : Boolean read FMirror write FMirror;
    property Flip   : Boolean read FFlip write FFlip;
    property Color4 : TColor4 read FColor4 write FColor4;
    property Pattern: Integer read FPattern write FPattern;
    property DrawFx : Cardinal read FDrawFx write FDrawFx;
    property Visible: boolean read FVisible write FVisible;

    property RenderSett: TRenderSettings read GetRenderSettings write SetRenderSettings;
  end;

//------------------------------------------------------------------------------
const
  DEFAULT_RENDER_SETTINGS: TRenderSettings = (
    Pivot  : (X: 0.5; Y: 0.5);
    Angle  : 0.0;
    Scale  : (X: 1.0; Y: 1.0);
    Size   : (X: 0.0; Y: 0.0);
    Mirror : false;
    Flip   : false;
    Color4 : ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF);
    Pattern: 0;
    DrawFx : 0;
    );

//------------------------------------------------------------------------------
implementation

//------------------------------------------------------------------------------
// TXObject CLASS
//------------------------------------------------------------------------------
constructor TXObject.Create();
begin
  inherited;
  
  FPosition := Point2(0.0, 0.0);
  FPrevPos  := Point2(0.0, 0.0);
end;

//------------------------------------------------------------------------------
destructor TXObject.Destroy();
begin
  inherited;
end;

//------------------------------------------------------------------------------
procedure TXObject.Translate(const Dist: TPoint2);
begin
  FPrevPos  := FPosition; 
  FPosition := FPosition + Dist;
end;

//------------------------------------------------------------------------------
// returns direction angle
function TXObject.LookAt(const x, y: Real): Real;
begin
  //FAngle := VecAngle4(FPosition, Point2(x, y));
  FAngle := Angle2(Point2(x, y) - FPosition);
  Result := FAngle;
end;

//------------------------------------------------------------------------------
// TRenderable CLASSs
//------------------------------------------------------------------------------
constructor TRenderable.Create();
begin
  inherited;

  FVisible := true;
  SetRenderSettings(DEFAULT_RENDER_SETTINGS);
end;

//------------------------------------------------------------------------------
procedure TRenderable.SetRenderSettings(const RS: TRenderSettings);
begin
  FPivot   := RS.Pivot;
  FAngle   := RS.Angle;
  FScale   := RS.Scale;
  FPatSize := RS.Size;
  FMirror  := RS.Mirror;
  FFlip    := RS.Flip;
  FColor4  := RS.Color4;
  FPattern := RS.Pattern;
  FDrawFx  := RS.DrawFx;
end;

//------------------------------------------------------------------------------
function TRenderable.GetRenderSettings(): TRenderSettings;
begin
  Result.Pivot   := FPivot;
  Result.Angle   := FAngle;
  Result.Scale   := FScale;
  Result.Size    := FPatSize;
  Result.Mirror  := FMirror;
  Result.Flip    := FFlip;
  Result.Color4  := FColor4;
  Result.Pattern := FPattern;
  Result.DrawFx  := FDrawFx;
end;

//------------------------------------------------------------------------------
procedure TRenderable.Show();
begin
  FVisible := true;
end;

//------------------------------------------------------------------------------
procedure TRenderable.Hide();
begin
  FVisible := false;
end;

//------------------------------------------------------------------------------
function TRenderable.GetRenderQuad(dX, dY: Integer): TPoint4;
var
  Pos_   : TPoint2;
  Size_  : TPoint2;
  Middle_: TPoint2;
begin
  Pos_    := Point2(FPosition.x + dX, FPosition.y + dY);
  Size_   := GetSize();
  Middle_ := Point2(Size_.x * FPivot.x, Size_.y * FPivot.y);

  Result  := pRotate4(Pos_, Size_, Middle_, FAngle, 1.0);
end;

//------------------------------------------------------------------------------
function TRenderable.GetMapping(): TPoint4;
begin
  //Result := tPatternEx(FPattern, FMirror, FFlip);
  pFlip4(pBounds4(0.0, 0.0, 1.0, 1.0))
end;

//------------------------------------------------------------------------------
function TRenderable.GetSize(): TPoint2;
begin
  Result := Point2(FPatSize.x * FScale.x, FPatSize.y * FScale.y);
end;

//------------------------------------------------------------------------------
procedure TRenderable.SetSize(const Value: TPoint2);
begin
  FScale := Value / FPatSize;
end;

//------------------------------------------------------------------------------
end.


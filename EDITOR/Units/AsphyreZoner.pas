unit AsphyreZoner;
interface
uses
  Windows, SysUtils, Classes;

const
  // stored as shift-left size
  zonesize32   = 5;
  zonesize64   = 6;
  zonesize128  = 7;
  zonesize256  = 8;
  zonesize512  = 9;
  zonesize1024 = 10;

type
  TZonePoint = record
    x, y, z: Integer;
  end;

  PZoneRec = ^TZoneRec;
  TZoneRec = record
    lX, lY, lZIndex: Byte; // Last known positions
    lLayerIndex: Byte;     // Last known layer
    Obj: TObject;          // Stored object
    ID: Word;              // ID
  end;

  TDynWordArray=array of Word;
  TDynPtrArray=array of TDynWordArray;
  TDynPtrPtrArray=array of TDynPtrArray;

  TAsphyreZoneLayer = class(TObject)
  private
    FHeight: Integer;
    FDepth: Integer;
    FWidth: Integer;
    FCellHeight: Integer;
    FCellWidth: Integer;

    XArray: TDynPtrPtrArray;//array of Pointer;
    FRows: Byte;
    FCols: Byte;
    procedure ClearXArray;
    procedure CreateXArray;
    procedure CleanSub(zX, zY: Byte);
  public
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Depth: Integer read FDepth write FDepth;

    // use zonesize powers of two
    property CellWidth: Integer read FCellWidth write FCellWidth;
    property CellHeight: Integer read FCellHeight write FCellHeight;

    property Rows: Byte read FRows;
    property Cols: Byte read FCols;

    constructor Create(const Size: TZonePoint; CellZoneWidth, CellZoneHeight: Integer; AXRows, AYCols: Byte);
    destructor Destroy; override;

    function GetSubsCoord(x, y: Integer; var arr: array of Word; var Index, Count: Byte): Boolean;
    function GetSubsCoordPerimeter(x, y, p: Integer; var arr: array of Word; var Index, Count: Byte): Boolean;
    function GetSubs(zX, zY: Byte; var arr: array of Word; var Index, Count: Byte): Boolean;

    function SetSubCoord(x, y: Integer; ID: Word):Integer; overload;
    function SetSub(zX, zY: Byte; ID: Word):Integer; overload;

    procedure RemSubIndex(zX, zY, Index: Integer);
    procedure RemSub(zX, zY: Byte; ID: Word);

    function LayerXY(X, Y: Integer; var zX, zY: Byte): Boolean;
  end;

  TAsphyreZoner = class(TComponent)
  private
    FHeight: Integer;
    FDepth: Integer;
    FWidth: Integer;
    FLeftTopBottom: TZonePoint;

    ZoneObjects: array of PZoneRec;
    Layers: array of TAsphyreZoneLayer;
    FInitialized: Boolean;

    FLayersCount: Integer;
    FZoneObjectsCount: Integer;
    procedure DropLayers;
    procedure DropZoneObjects;
    function ZtoLayer(Z: Integer): Integer;
    function ZeroBasedXY(var X, Y: integer): Boolean;
    procedure StartCache;
    function GetCacheObj(ID: Word): TObject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Depth: Integer read FDepth write FDepth;
    property Initialized: Boolean read FInitialized;

    property LeftTopBottom: TZonePoint read FLeftTopBottom write FLeftTopBottom;

    function Initialize(Width, Height, Depth: Integer): Boolean; overload;
    function Initialize(Size: TZonePoint): Boolean; overload;

    procedure Finalize;

    function ObjectEnterZone(Obj: TObject; X, Y, Z: Integer): Integer; overload;
    function ObjectEnterZone(Obj: TObject; X, Y, Z: Real; bnYTop: Boolean): Integer; overload;

    function ObjectLeaveZone(ID: Word): Boolean; overload;
    function ObjectLeaveZone(Obj: TObject): Boolean; overload;
    function ObjectLeaveZone(Zobj: PZoneRec): Boolean; overload;

    function ObjectMoveInZones(X, Y, Z: Integer; ID: Word): Boolean; overload;
    function ObjectMoveInZones(X, Y, Z: Integer; Obj: TObject): Boolean; overload;
    function ObjectMoveInZones(X, Y, Z: Integer; Zobj: PZoneRec): Boolean; overload;
    function ObjectMoveInZones(X, Y, Z: Real; bnYTop: Boolean; Obj: TObject): Boolean; overload;
    function ObjectMoveInZones(X, Y, Z: Real; bnYTop: Boolean; ID: Word): Boolean; overload;

    function AddLayer(Depth: Integer; CellZoneWidth, CellZoneHeight: Integer; aRows, aCols: Byte): integer;

    function FillCache(X, Y, Z, Perimeter: Real; bnYTop: Boolean): Boolean; overload;
    function FillCache(X, Y, Z, Perimeter: Integer): Boolean; overload;
    property CacheObj[ID: Word]: TObject read GetCacheObj;
  public
    Cache: array of Word;
    CacheCount: Byte;
    CacheIndex: Byte;
    procedure FlushCache;

    procedure CleanZones;
  published
    property Tag;
  end;

function ZonePoint(x, y, z: Integer): TZonePoint;
function ZoneRec(Obj: TObject): PZoneRec;

function NewArray(Size: Integer): TDynPtrArray;

implementation

function ZonePoint(x, y, z: Integer): TZonePoint;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function ZoneRec(Obj: TObject): PZoneRec;
begin
  Result := AllocMem(SizeOf(TZoneRec));
  Result.lX := $FF;
  Result.lY := $FF;
  Result.lZIndex := $FF;
  Result.lLayerIndex := $FF;
  Result.ID := $FFFF;
  Result.Obj := Obj;
end;

{ TAsphyreZoner }

constructor TAsphyreZoner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FInitialized := False;
  FLayersCount := 0;
  FZoneObjectsCount := 0;

  StartCache;
end;

destructor TAsphyreZoner.Destroy;
begin
  if FInitialized then
    Finalize;

  inherited Destroy;
end;

function TAsphyreZoner.Initialize(Width, Height, Depth: Integer): Boolean;
begin
  Result := False;
  if FInitialized then Exit;

  FWidth := Width;
  FHeight := Height;
  FDepth := Depth;

  DropLayers;
  FInitialized := True;
  Result := True;
end;

procedure TAsphyreZoner.Finalize;
begin
  if not FInitialized then Exit;

  DropLayers;
  DropZoneObjects;

  FInitialized := False;
end;

function TAsphyreZoner.Initialize(Size: TZonePoint): Boolean;
begin
  Result := False;
  if FInitialized then Exit;

  Result := Initialize(Round(Size.x), Round(Size.y), Round(Size.z));
end;

function TAsphyreZoner.ObjectEnterZone(Obj: TObject; X, Y, Z: Integer): Integer;
var ZObj: PZoneRec;
begin
  if not FInitialized then
  begin
    Result := -1;
    Exit;
  end;

  if FLayersCount < 1 then
  begin
    Result := -2;
    Exit;
  end;

  if not ZeroBasedXY(X, Y) then
  begin
    Result := -3;
    Exit;
  end;

  if FZoneObjectsCount > $FFFE then
  begin
    Result := -4;
    Exit;
  end;

  ZObj := ZoneRec(Obj);

  Result := FZoneObjectsCount;
  SetLength(ZoneObjects, Result+1);
  ZoneObjects[Result] := ZObj;

  inc(FZoneObjectsCount);

  ZObj.ID := Result;
  ZObj.lLayerIndex := ZtoLayer(Z);
  Layers[ZObj.lLayerIndex].LayerXY(X, Y, ZObj.lX, ZObj.lY);
  ZObj.lZIndex := Layers[ZObj.lLayerIndex].SetSub(ZObj.lX, ZObj.lY, Result);
end;

function TAsphyreZoner.ObjectLeaveZone(ID: Word): Boolean;
begin
  Result := False;
  if ID < FZoneObjectsCount then
    Result := ObjectLeaveZone(ZoneObjects[ID]);
end;

function TAsphyreZoner.ObjectLeaveZone(Obj: TObject): Boolean;
var i: integer;
begin
  Result := False;
  if FZoneObjectsCount > 0 then
    for i := 0 to FZoneObjectsCount-1 do
      if (ZoneObjects[i]<>nil) and (ZoneObjects[i].Obj = Obj) then
      begin
        Result := ObjectLeaveZone(ZoneObjects[i]);
        break;
      end;
end;

procedure TAsphyreZoner.DropLayers;
var len, i: integer;
  Layer: TAsphyreZoneLayer;
begin
  len := FLayersCount;
  if len > 0 then
    for i := 0 to len-1 do
    begin
      Layer := Layers[i];
      FreeAndNil(Layer);
    end;
  SetLength(Layers, 0);
  FLayersCount := 0;
end;

function TAsphyreZoner.AddLayer(Depth: Integer; CellZoneWidth, CellZoneHeight: Integer; aRows, aCols: Byte): Integer;
var Layer: TAsphyreZoneLayer;
begin
  Result := -1;
  if (aRows < 1) or (aCols < 1) then Exit;
  
  Layer := TAsphyreZoneLayer.Create(ZonePoint(FWidth, FHeight, Depth), CellZoneWidth, CellZoneHeight, aRows, aCols);
  
  Result := length(Layers);
  SetLength(Layers, Result+1);
  Layers[Result] := Layer;

  FLayersCount := length(Layers);
end;

function TAsphyreZoner.ObjectEnterZone(Obj: TObject; X, Y, Z: Real; bnYTop: Boolean): Integer;
begin
  if bnYTop then
    Result := ObjectEnterZone(Obj, Round(x), Round(z), Round(y))
  else
    Result := ObjectEnterZone(Obj, Round(x), Round(y), Round(z));
end;

function TAsphyreZoner.ZtoLayer(Z: Integer): Integer;
var i, lZ: integer;
  Layer: TAsphyreZoneLayer;
begin
  if FLayersCount < 0 then begin
    Result := -1;
    Exit;
  end;

  Result := 0;

  lZ := FLeftTopBottom.z;

  for i := 0 to FLayersCount-1 do
  begin
    Layer := Layers[i];

    if (z in [lZ..(lZ + Layer.FDepth)]) then
    begin
      Result := i;
      break;
    end;
    inc(lZ, Layer.FDepth);
  end;
end;

function TAsphyreZoner.ZeroBasedXY(var X, Y: integer): Boolean;
begin
  Result := False;
  if (X >= LeftTopBottom.X) and (X < LeftTopBottom.X+FWidth) and (Y >= LeftTopBottom.Y) and (Y < LeftTopBottom.Y+FHeight) then
  begin
    X := X - LeftTopBottom.X;
    Y := Y - LeftTopBottom.Y;
    Result := (X >= 0) and (Y >= 0);
  end;
end;

procedure TAsphyreZoner.DropZoneObjects;
begin
  SetLength(ZoneObjects, 0);
  FZoneObjectsCount := 0;
end;

procedure TAsphyreZoner.FlushCache;
begin
  StartCache;
end;

procedure TAsphyreZoner.StartCache;
begin
  SetLength(Cache, 0);
  CacheCount := 0;
  SetLength(Cache, 250);
  CacheIndex := 0;
end;

function TAsphyreZoner.FillCache(X, Y, Z, Perimeter: Real; bnYTop: Boolean): Boolean;
begin
  if bnYTop then
    Result := FillCache(Round(X), Round(Z), Round(Y), Round(Perimeter))
  else
    Result := FillCache(Round(X), Round(Y), Round(Z), Round(Perimeter));
end;

function TAsphyreZoner.FillCache(X, Y, Z, Perimeter: Integer): Boolean;
var Layer: TAsphyreZoneLayer;
  ind: Integer;
begin
  Result := False;
  CacheCount := 0;
  
  ind := ZtoLayer(Z);
  if (ind>=0) and ZeroBasedXY(X, Y) then
  begin
    Layer := Layers[ind];

    CacheCount := 249;
    Result := Layer.GetSubsCoordPerimeter(X, Y, Perimeter, Cache, CacheIndex, CacheCount);
  end;
end;

procedure TAsphyreZoner.CleanZones;
begin
  DropZoneObjects;
end;

function TAsphyreZoner.ObjectLeaveZone(Zobj: PZoneRec): Boolean;
begin
  if (ZObj.lX < $FF) then
    Layers[ZObj.lLayerIndex].RemSubIndex(ZObj.lX, ZObj.lY, ZObj.lZIndex);

  ZObj.lLayerIndex := $FF;
  ZObj.lX          := $FF;
  ZObj.lY          := $FF;
  ZObj.lZIndex     := $FF;

  Result := True;
end;

function TAsphyreZoner.ObjectMoveInZones(X, Y, Z: Integer; ID: Word): Boolean;
begin
  Result := False;
  if ID < FZoneObjectsCount then
    Result := ObjectMoveInZones(X, Y, Z, ZoneObjects[ID]);
end;

function TAsphyreZoner.ObjectMoveInZones(X, Y, Z: Integer; Obj: TObject): Boolean;
var i: integer;
begin
  Result := False;
  if FZoneObjectsCount > 0 then
    for i := 0 to FZoneObjectsCount-1 do
      if (ZoneObjects[i]<>nil) and (ZoneObjects[i].Obj = Obj) then
      begin
        Result := ObjectMoveInZones(X, Y, Z, ZoneObjects[i]);
        break;
      end;
end;

function TAsphyreZoner.ObjectMoveInZones(X, Y, Z: Integer; Zobj: PZoneRec): Boolean;
var Layer: TAsphyreZoneLayer;
  ind: integer;
  zX, zY: Byte;
begin
  Result := False;

  ind := ZtoLayer(Z);
  if (ind>=0) and ZeroBasedXY(X, Y) then
  begin
    Layer := Layers[ind];
    Layer.LayerXY(X, Y, zX, zY);
    
    if (ZObj.lX <> zX) or (ZObj.lY <> zY) or (ZObj.lLayerIndex<>ind) then
    begin
      if (ZObj.lX < $FF) then
      begin
        Layer.RemSubIndex(ZObj.lX, ZObj.lY, ZObj.lZIndex);
      end;

      Layer := Layers[ind];
      ZObj.lLayerIndex := ind;
      Layer.LayerXY(X, Y, ZObj.lX, ZObj.lY);
      ZObj.lZIndex := Layer.SetSub(ZObj.lX, ZObj.lY, ZObj.ID);
    end;
    Result := ZObj.lZIndex < $FF;
  end;
end;

function TAsphyreZoner.ObjectMoveInZones(X, Y, Z: Real; bnYTop: Boolean; ID: Word): Boolean;
begin
  if bnYTop then
    Result := ObjectMoveInZones(Round(x), Round(z), Round(y), ID)
  else
    Result := ObjectMoveInZones(Round(x), Round(y), Round(z), ID);
end;

function TAsphyreZoner.ObjectMoveInZones(X, Y, Z: Real; bnYTop: Boolean; Obj: TObject): Boolean;
begin
  if bnYTop then
    Result := ObjectMoveInZones(Round(x), Round(z), Round(y), Obj)
  else
    Result := ObjectMoveInZones(Round(x), Round(y), Round(z), Obj);
end;

function TAsphyreZoner.GetCacheObj(ID: Word): TObject;
begin
  Result := nil;
  if (ID < FZoneObjectsCount) and (ZoneObjects[ID]<>nil) then
    Result := ZoneObjects[ID].Obj;
end;

{ TAsphyreZoneLayer }

procedure TAsphyreZoneLayer.ClearXArray;
var i, len: integer;
  j, leny: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  len := length(XArray);
  if len = 0 then Exit;

  Yarr := nil;
  Oarr := nil;

  i := 0;
  repeat
    if XArray[i]<>nil then
    begin
      YArr := XArray[i];
      leny := Length(YArr);
      if leny > 0 then
      begin
        j := 0;
        repeat
          if Yarr[j]<>nil then
          begin
            Oarr := Yarr[j];
            SetLength(Oarr, 0);
          end;
          inc(j);
        until j = leny;
      end;
    end;
    inc(i);
  until i = len;

  SetLength(XArray, 0);
end;

constructor TAsphyreZoneLayer.Create(const Size: TZonePoint; CellZoneWidth, CellZoneHeight: Integer; AXRows, AYCols: Byte);
begin
  ClearXArray;

  FWidth := Round(Size.x);
  FHeight := Round(Size.y);
  FDepth := Round(Size.z);

  FCols := AYCols;
  FRows := AXRows;

  CreateXArray;

  FCellWidth := CellZoneWidth;
  FCellHeight := CellZoneHeight;
end;

function NewArray(Size: Integer): TDynPtrArray;
begin
  SetLength(Result, Size);
end;

procedure TAsphyreZoneLayer.CreateXArray;
var i: integer;
begin
  ClearXArray;

  SetLength(XArray, FCols);
  i := 0;
  repeat
    XArray[i] := NewArray(FRows);
    inc(i);
  until i = FCols;
end;

destructor TAsphyreZoneLayer.Destroy;
begin
  ClearXArray;

  inherited Destroy;
end;

function TAsphyreZoneLayer.GetSubsCoordPerimeter(x, y, p: Integer; var arr: array of Word; var Index, Count: Byte): Boolean;
var zX, zY, zPx, zPy: Integer;
  i, ind, len: integer;
  fcnt, cnt, max: integer;

  fX, fY, fSY, tX, tY: Byte;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  zX := x shr FCellWidth;
  zY := y shr FCellHeight;
  Result := False;

  Yarr := nil;
  Oarr := nil;

  max := Count;
  Count := 0;
  if (zX < FCols) and (zY < FRows) then
  begin

    zPx := p shr FCellWidth;
    zPy := p shr FCellHeight;

    fX := zX - zPx;
    fSY := zY - zPy;
    tX := zX + zPx;
    tY := zY + zPy;

    if fX > zX then fX := 0;
    if fSY > zY then fSY := 0;
    if (tX >= FCols) or (tX < zX) then tX := FCols-1;
    if (tY >= FRows) or (tY < zY) then tY := FRows-1;

    ind := Index;

    try
      cnt := 0;
      repeat
        if Xarray[fX]=nil then
        begin
          inc(fX);
          continue;
        end;
        Yarr := XArray[fx];

        fY := fSY;
        repeat
          if Yarr[fY]=nil then
          begin
            inc(fY);
            continue;
          end;
          
          Oarr := Yarr[fY];
          len := Length(Oarr);
          if len > 0 then
          begin
            i := len-1;
            fcnt := 0;
            repeat

              case Oarr[i] of
                $FFFF: inc(fcnt);
                else
                  begin
                    arr[ind] := Oarr[i];
                    inc(cnt);
                    inc(ind);

                    if ind >= max then
                      Exit;
                  end;
              end;
              dec(i);
            until i < 0;
            if fcnt > 4 then
              CleanSub(fX, fY);
          end;

          inc(fY);
        until fY > tY;

        inc(fX);
      until fX > tX;

      Count := cnt;
      Result := (cnt > 0);
    except
      Result := False;
    end;
  end;
end;

function TAsphyreZoneLayer.GetSubsCoord(x, y: Integer; var arr: array of Word; var Index, Count: Byte): Boolean;
var zX, zY: Integer;
  ind, i, len: integer;
  cnt: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  Result := False;
  Count := 0;

  zX := x shr FCellWidth;
  zY := y shr FCellHeight;

  if (zX >= FCols) or (zY >= FRows) then Exit;

  if Xarray[zX] = nil then Exit;

  Yarr := XArray[zX];
  if YArr[zY] = nil then Exit;

  Oarr := Yarr[zY];
  len := length(Yarr);
  if len = 0 then Exit;

  cnt := 0;
  if len >= Count then len := Count-1;
  if Index+len >= Count then
    Index := 0;

  ind := Index;
  i := 0;
  repeat
    arr[ind] := Oarr[i];
    inc(cnt);
    inc(ind);
  until i = len;
  Count := cnt;
  Result := Count > 0;

end;

function TAsphyreZoneLayer.GetSubs(zX, zY: Byte; var arr: array of Word; var Index, Count: Byte): Boolean;
var i, len, ind, cnt: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  Result := False;
  Count := 0;
  
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if Xarray[zX] = nil then Exit;

  Yarr := XArray[zX];
  if YArr[zY] = nil then Exit;

  Oarr := Yarr[zY];
  len := length(Yarr);
  if len = 0 then Exit;

  cnt := 0;
  if len >= Count then len := Count-1;
  if Index+len >= Count then
    Index := 0;

  ind := Index;
  i := 0;
  repeat
    arr[ind] := Oarr[i];
    inc(cnt);
    inc(ind);
  until i = len;
  Count := cnt;
  Result := Count > 0;
end;

function TAsphyreZoneLayer.SetSubCoord(x, y: Integer; ID: Word): Integer;
var zX, zY: Integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  zX := x shr FCellWidth;
  zY := y shr FCellHeight;

  Result := -1;
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if XArray[zX] = nil then Exit;
  YArr := XArray[zX];

  if YArr[zY] = nil then
  begin
    SetLength(OArr, 1);
    YArr[zY] := Oarr;
    Result := 0;
    Oarr[0] := ID;
    Exit;
  end;

  OArr := YArr[zY];
  
  Result := Length(OArr);
  SetLength(OArr, Result+1);
  OArr[Result] := ID;
end;

function TAsphyreZoneLayer.SetSub(zX, zY: Byte; ID: Word): Integer;
var p: pointer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  Result := -1;
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if XArray[zX] = nil then Exit;
  Yarr := XArray[zX];

  if YArr[zY] = nil then
  begin
    Result := 0;
    SetLength(OArr, 1);
    Oarr[0] := ID;
    YArr[zY] := Oarr;
    Exit;
  end;
  OArr := YArr[zY];

  Result := Length(OArr);
  SetLength(OArr, Result+1);
  OArr[Result] := ID;
end;

procedure TAsphyreZoneLayer.CleanSub(zX, zY: Byte);
var len, i, j: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if XArray[zX] = nil then Exit;
  YArr := XArray[zX];

  if YArr[zY] = nil then Exit;

  Oarr := YArr[zY];

  len := Length(Oarr);
  if len = 0 then Exit;

  i := 0;
  repeat
    case Oarr[i] of
      $FFFF:
      begin
        j := i;
        if j < len-1 then
          repeat
            Oarr[j] := Oarr[j+1];
            inc(j);
          until j = len;
      end;
      else
        inc(i);
    end;
  until i = len;
end;

procedure TAsphyreZoneLayer.RemSubIndex(zX, zY, Index: Integer);
var len: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if XArray[zX] = nil then Exit;
  YArr := XArray[zX];

  if YArr[zY] = nil then Exit;

  Oarr := YArr[zY];
  
  len := length(Oarr);
  if len = 0 then Exit;

  if Index < len then
    OArr[Index] := $FFFF;

  if len > 64 then
    CleanSub(zX, zY);
end;

procedure TAsphyreZoneLayer.RemSub(zX, zY: Byte; ID: Word);
var i, len: integer;
  Yarr: TDynPtrArray;
  Oarr: TDynWordArray;
begin
  if (zX >= FCols) or (zY >= FRows) then Exit;

  if XArray[zX] = nil then Exit;
  YArr := XArray[zX];

  if YArr[zY] = nil then Exit;

  Oarr := YArr[zY];
  len := length(Oarr);
  if len = 0 then Exit;
  i := 0;
  repeat
    if Oarr[i] = ID then
    begin
      OArr[i] := $FFFF;
      break;
    end;
  until i = len;

  if len > 64 then
    CleanSub(zX, zY);
end;

function TAsphyreZoneLayer.LayerXY(X, Y: Integer; var zX, zY: Byte): Boolean;
begin
  Result := False;
  if (X < FWidth) and (Y < FHeight) then
  begin
    zX := X shr FCellWidth;
    zY := Y shr FCellHeight;

    Result := True;
  end;
end;

end.

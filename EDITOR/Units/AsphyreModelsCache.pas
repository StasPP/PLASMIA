unit AsphyreModelsCache;
//---------------------------------------------------------------------------
// SinCosTables.pas                                     Modified:  9-Apr-2006
// Gurroa                                                        Version 0.50
//---------------------------------------------------------------------------
// Changes since v0.00:
//  + enable AsphyrePuppet to draw models throught this object
//    models are sorted in order of their INDEX and then draw packed
//    helps Direct30 slightly
//---------------------------------------------------------------------------
// This unit depends on AfterWarp asphyre package
// http://www.afterwarp.net
//---------------------------------------------------------------------------
interface
uses
  SysUtils, Classes, AsphyreModels, AsphyreMath, AsphyreCameras;

type
  PCacheModel = ^TCacheModel;
  TCacheModel = record
    Model: TAsphyreModel;
    Matrix: TMatrix4;
    Index: Integer;
  end;

  TAsphyreModelsCache = class(TComponent)
  private
    FMaxCount: Integer;
    FCamera: TAsphyreCamera;
    procedure SetMaxCount(const Value: Integer);
    procedure SetCamera(const Value: TAsphyreCamera);
  protected
    FCache: TList;
    FCacheCapacity: Integer;
    FCacheCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property MaxCount: Integer read FMaxCount write SetMaxCount;
    property Camera: TAsphyreCamera read FCamera write SetCamera;

    procedure Render(Camera: TAsphyreCamera);
    procedure Flush();
    function Draw(Model: TAsphyreModel; Mtx: PMatrix4): Boolean;
  end;

implementation

{ TAsphyreModelsCache }

constructor TAsphyreModelsCache.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCache := TList.Create;
  FCache.Capacity := 16;
  FCacheCapacity := 16;
  FCacheCount := 0;
end;

destructor TAsphyreModelsCache.Destroy;
begin
  

  inherited Destroy;
end;

function TAsphyreModelsCache.Draw(Model: TAsphyreModel; Mtx: PMatrix4): Boolean;
var CModel: PCacheModel;
begin
  Result := True;
  
  if FCacheCount >= FCacheCapacity-1 then
  begin
    FCacheCapacity := FCacheCapacity shl 2;
    FCache.Capacity := FCacheCapacity;
  end;

  CModel := AllocMem(SizeOf(TCacheModel));
  CModel.Model := Model;
  CModel.Matrix := Mtx^;
  CModel.Index := Model.Index;

  FCache.Add(CModel);
  inc(FCacheCount);

  Result := CModel.Index<>0;
end;

function CompareModels(Item1, Item2: Pointer): Integer;
begin
  Result := PCacheModel(Item1).Index - PCacheModel(Item2).Index;
end;

procedure TAsphyreModelsCache.Flush;
var i: integer;
  CModel: PCacheModel;
begin
  if (FCacheCount > 0) then
  begin
    for i := 0 to FCacheCount-1 do
    begin
      CModel := PCacheModel(FCache[i]);
      FreeMem(CModel);
    end;

    FCache.Clear;

    FCacheCount := 0;
  end;
end;

procedure TAsphyreModelsCache.Render(Camera: TAsphyreCamera);
var i: integer;
  CModel: PCacheModel;
begin
  if (FCacheCount > 0) then
  begin
    FCache.Sort(CompareModels);

    FCamera := Camera;

    if (FCamera<>nil) then
      for i := 0 to FCacheCount-1 do
      begin
        CModel := PCacheModel(FCache[i]);

        CModel.Model.Draw(CModel.Matrix, FCamera);
        FreeMem(CModel);
      end
    else
      for i := 0 to FCacheCount-1 do
      begin
        CModel := PCacheModel(FCache[i]);
        FreeMem(CModel);
      end;
      
    FCache.Clear;

    FCacheCount := 0;
  end;
end;

procedure TAsphyreModelsCache.SetCamera(const Value: TAsphyreCamera);
begin
  FCamera := Value;
end;

procedure TAsphyreModelsCache.SetMaxCount(const Value: Integer);
begin
  FMaxCount := Value;
end;

end.

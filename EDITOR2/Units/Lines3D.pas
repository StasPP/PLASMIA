unit Lines3D;

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, Classes, SysUtils, Direct3D9, DXBase, AsphyreDef,
 AsphyreMath, AsphyreMatrix, AsphyreDevices;

//---------------------------------------------------------------------------
type
 TAsphyreLine3D = class(TAsphyreDeviceSubscriber)
 private
  VertexBuffer : IDirect3DVertexBuffer9;
  FInitialized : Boolean;
  FMaxVertices : Integer;
  ShadowBuffer : Pointer;
  ShadowPtr    : Pointer;

  FVertices : Integer;
  FWireframe: Boolean;
  FWorldMtx : TAsphyreMatrix;
  FViewMtx  : TAsphyreMatrix;

  function QueryCaps(): Boolean;
  function CreateVertexBuffer(): Boolean;
  function Initialize(): Boolean;
  function Finalize(): Boolean;
  procedure SetupMatrices();
  function UploadVertices(): Boolean;
  procedure DrawVertices();
  procedure ResetCache();
 protected
  function HandleNotice(Msg: Cardinal): Boolean; override;
  public
  property MaxVertices: Integer read FMaxVertices;
  property Initialized: Boolean read FInitialized;
  property Vertices: Integer read FVertices;
  property Wireframe: Boolean read FWireframe write FWireframe;

  property WorldMtx: TAsphyreMatrix read FWorldMtx;
  property ViewMtx : TAsphyreMatrix read FViewMtx;

  procedure Add(const Src, Dest: TPoint3; Color: Cardinal);
  procedure Flush();

  constructor Create(AOwner: TComponent); override;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
const
 VertexFVF = D3DFVF_XYZ or D3DFVF_DIFFUSE;

//---------------------------------------------------------------------------
type
 PVertexRecord = ^TVertexRecord;
 TVertexRecord = record
  Vertex : TD3DVector;
  Diffuse: Longword;
 end;

//---------------------------------------------------------------------------
constructor TAsphyreLine3D.Create(AOwner: TComponent);
begin
 inherited;

 FWorldMtx:= TAsphyreMatrix.Create();
 FViewMtx := TAsphyreMatrix.Create();

 FInitialized:= False;
 FWireframe  := False;
end;

//---------------------------------------------------------------------------
destructor TAsphyreLine3D.Destroy();
begin
 FViewMtx.Free();
 FWorldMtx.Free();

 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.QueryCaps(): Boolean;
var
 Caps: TD3DCaps9;
begin
 Result:= Succeeded(Direct3DDevice.GetDeviceCaps(Caps));
 if (Result) then
  begin
   FMaxVertices := Caps.MaxVertexIndex;
   if (FMaxVertices > 8192) then FMaxVertices:= 8192;
  end;
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.CreateVertexBuffer(): Boolean;
var
 BufSize: Integer;
begin
 // how many bytes VertexBuffer occupies?
 BufSize:= FMaxVertices * SizeOf(TVertexRecord);

 // create a Direct3D-compatible vertex buffer
 Result:= Succeeded(Direct3DDevice.CreateVertexBuffer(BufSize,
  D3DUSAGE_WRITEONLY or D3DUSAGE_DYNAMIC, VertexFVF, D3DPOOL_DEFAULT,
  VertexBuffer, nil));

 // create shadow buffer
 if (Result) then ShadowBuffer:= AllocMem(BufSize);
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.HandleNotice(Msg: Cardinal): Boolean;
begin
 Result:= True;
 
 case Msg of
  msgDeviceInitialize, msgDeviceRecovered:
   Result:= Initialize();

  msgDeviceFinalize, msgDeviceLost:
   Result:= Finalize();

  msgEndScene:
   ResetCache();
 end;
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.Initialize(): Boolean;
begin
 if (FInitialized) then Finalize();

 Result:= QueryCaps();
 if (not Result) then Exit;

 Result:= CreateVertexBuffer();
 if (not Result) then Exit;

 FVertices:= 0;
 ShadowPtr:= ShadowBuffer;

 FInitialized:= True;
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.Finalize(): Boolean;
begin
 if (VertexBuffer <> nil) then VertexBuffer:= nil;
 if (ShadowBuffer <> nil) then
  begin
   FreeMem(ShadowBuffer);
   ShadowBuffer:= nil;
  end;

 FInitialized:= False;
 Result:= True;
end;

//--------------------------------------------------------------------------
procedure TAsphyreLine3D.SetupMatrices();
begin
 Direct3DDevice.SetTransform(D3DTS_VIEW, D3DMatrix(FViewMtx.RawMtx));
 Direct3DDevice.SetTransform(D3DTS_WORLD, D3DMatrix(FWorldMtx.RawMtx));
end;

//---------------------------------------------------------------------------
function TAsphyreLine3D.UploadVertices(): Boolean;
var
 MemAddr : Pointer;
 LockSize: Integer;
begin
 LockSize:= FVertices * SizeOf(TVertexRecord);

 Result:= Succeeded(VertexBuffer.Lock(0, LockSize, MemAddr, D3DLOCK_DISCARD));
 if (not Result) then Exit;

 Move(ShadowBuffer^, MemAddr^, LockSize);

 Result:= Succeeded(VertexBuffer.Unlock());
end;

//---------------------------------------------------------------------------
procedure TAsphyreLine3D.DrawVertices();
begin
 with Direct3DDevice do
  begin
   SetRenderState(D3DRS_LIGHTING, iFalse);
//   SetRenderState(D3DRS_DEPTHBIAS, 16);

   SetStreamSource(0, VertexBuffer, 0, SizeOf(TVertexRecord));
   SetVertexShader(nil);
   SetFVF(VertexFVF);
   DrawPrimitive(D3DPT_LINELIST, 0, FVertices div 2);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreLine3D.ResetCache();
begin
 if (FVertices > 0) then
  begin
   SetupMatrices();
   if (UploadVertices()) then DrawVertices();
  end;

 FVertices:= 0;
 ShadowPtr:= ShadowBuffer;
end;

//---------------------------------------------------------------------------
procedure TAsphyreLine3D.Add(const Src, Dest: TPoint3; Color: Cardinal);
var
 Aux: PVertexRecord;
begin
 if (FVertices >= FMaxVertices - 2) then ResetCache();

 Aux:= ShadowPtr;
 Aux.Vertex := TD3DVector(Src);
 Aux.Diffuse:= Color;

 Inc(Aux);
 Aux.Vertex := TD3DVector(Dest);
 Aux.Diffuse:= Color;

 Inc(Integer(ShadowPtr), SizeOf(TVertexRecord) * 2);
 Inc(FVertices, 2);
end;

//--------------------------------------------------------------------------
procedure TAsphyreLine3D.Flush();
begin
 ResetCache();
end;

//---------------------------------------------------------------------------
end.

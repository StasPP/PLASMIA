unit DX7Canvas;
//---------------------------------------------------------------------------
// DX7Canvas.pas                                        Modified: 30-Oct-2007
// 2D Canvas using DirectX 7.0                                    Version 1.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
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
//
// The Original Code is DX7Canvas.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------

{$ifdef fpc}{$mode delphi}{$endif}

interface

//---------------------------------------------------------------------------
uses
 Windows, DirectDraw7, Direct3D7, AbstractCanvas, Vectors2, Matrices3,
 AsphyreColors, AsphyreTypes, AbstractTextures, AsphyreImages;

//---------------------------------------------------------------------------
const
 // The following parameters roughly affect the rendering performance. The
 // higher values means that more primitives will fit in cache, but it will
 // also occupy more bandwidth, even when few primitives are rendered.
 //
 // These parameters can be fine-tuned in a finished product to improve the
 // overall performance.
 MaxCachedPrimitives = 3072;
 MaxCachedIndices    = 4096;
 MaxCachedVertices   = 4096;

//---------------------------------------------------------------------------
type
 TDrawingMode = (dmUnknown, dmPoints, dmLines, dmTriangles);

//---------------------------------------------------------------------------
 TDX7Canvas = class(TAsphyreCanvas)
 private
  VertexBuffer: IDirect3DVertexBuffer7;

  VertexArray : Pointer;
  IndexArray  : packed array[0..MaxCachedIndices - 1] of Word;

  DrawingMode: TDrawingMode;

  VertexCount: Integer;
  IndexCount : Integer;
  Primitives : Integer;
  ActiveTex  : TAsphyreTexture;

  CachedEffect: TDrawingEffect;
  CachedTex   : TAsphyreTexture;
  QuadMapping : TPoint4;

  HexLookup: array[0..5] of TPoint2;

  procedure InitHexLookup();

  procedure CreateStaticObjects();
  procedure DestroyStaticObjects();
  procedure PrepareVertexArray();

  function CreateDynamicBuffers(): Boolean;
  procedure DestroyDynamicBuffers();
  procedure ResetDeviceStates();

  function UploadVertexBuffer(): Boolean;
  procedure DrawBuffers();

  function NextVertexEntry(): Pointer;
  procedure AddIndexEntry(Index: Integer);
  procedure RequestCache(Mode: TDrawingMode; Vertices, Indices: Integer;
   Effect: TDrawingEffect; Texture: TAsphyreTexture);

  procedure SetEffectStates(Effect: TDrawingEffect);
 protected
  function HandleDeviceCreate(): Boolean; override;
  procedure HandleDeviceDestroy(); override;
  function HandleDeviceReset(): Boolean; override;
  procedure HandleDeviceLost(); override;

  procedure HandleBeginScene(); override;
  procedure HandleEndScene(); override;

  procedure GetViewport(out x, y, Width, Height: Integer); override;
  procedure SetViewport(x, y, Width, Height: Integer); override;

  function GetAntialias(): Boolean; override;
  procedure SetAntialias(const Value: Boolean); override;
  function GetMipMapping(): Boolean; override;
  procedure SetMipMapping(const Value: Boolean); override;
 public

  procedure PutPixel(const Point: TPoint2; Color: Cardinal); override;
  procedure Line(const Src, Dest: TPoint2; Color0, Color1: Cardinal); override;

  procedure FillTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
   Effect: TDrawingEffect = deNormal); override;

  procedure FillQuad(const Points: TPoint4; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); override;

  procedure WireQuad(const Points: TPoint4; const Colors: TColor4); override;

  procedure UseImage(Image: TAsphyreImage; const Mapping: TPoint4;
   TextureNo: Integer = 0); override;

  procedure TexMap(const Points: TPoint4; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); override;

  procedure FillHexagon(const Mtx: TMatrix3; c1, c2, c3, c4, c5, c6: Cardinal;
   Effect: TDrawingEffect = deNormal); override;

  procedure FillArc(const Pos, Radius: TPoint2; InitPhi, EndPhi: Single;
   Steps: Integer; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); override;

  procedure FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
   InitPhi, EndPhi: Single; Steps: Integer; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); overload; override;
  procedure FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
   InitPhi, EndPhi: Single; Steps: Integer; InColor1, InColor2, InColor3,
   OutColor1, OutColor2, OutColor3: Cardinal;
   Effect: TDrawingEffect = deNormal); overload; override;

  procedure Flush(); override;

  constructor Create(); override;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//--------------------------------------------------------------------------
uses
 DX7Types;

//--------------------------------------------------------------------------
const
 VertexFVFType = D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1;

//--------------------------------------------------------------------------
type
 PVertexRecord = ^TVertexRecord;
 TVertexRecord = record
  Vertex: TD3DVector;
  rhw   : Single;
  Color : Longword;
  u, v  : Single;
 end;

//--------------------------------------------------------------------------
constructor TDX7Canvas.Create();
begin
 inherited;

 InitHexLookup();

 VertexArray := nil;
 VertexBuffer:= nil;
end;

//---------------------------------------------------------------------------
destructor TDX7Canvas.Destroy();
begin
 DestroyDynamicBuffers();
 DestroyStaticObjects();

 inherited;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.InitHexLookup();
const
 HexDelta = 1.154700538;
 AngleInc = Pi / 6.0;
 AngleMul = 2.0 * Pi / 6.0;
var
 i: Integer;
 Angle: Single;
begin
 for i:= 0 to 5 do
  begin
   Angle:= i * AngleMul + AngleInc;

   HexLookup[i].x:=  Cos(Angle) * HexDelta;
   HexLookup[i].y:= -Sin(Angle) * HexDelta;
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.PrepareVertexArray();
var
 Entry: PVertexRecord;
 Index: Integer;
begin
 Entry:= VertexArray;
 for Index:= 0 to MaxCachedVertices - 1 do
  begin
   FillChar(Entry^, SizeOf(TVertexRecord), 0);

   Entry.Vertex.z:= 0.0;
   Entry.rhw     := 1.0;

   Inc(Entry);
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.CreateStaticObjects();
begin
 ReallocMem(VertexArray, MaxCachedVertices * SizeOf(TVertexRecord));
 FillChar(VertexArray^, MaxCachedVertices * SizeOf(TVertexRecord), 0);

 PrepareVertexArray();
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.DestroyStaticObjects();
begin
 if (VertexArray <> nil) then
  begin
   FreeMem(VertexArray);
   VertexArray:= nil;
  end;
end;

//--------------------------------------------------------------------------
function TDX7Canvas.CreateDynamicBuffers(): Boolean;
var
 Desc: TD3DVertexBufferDesc;
begin
 Result:= Direct3D <> nil;
 if (not Result) then Exit;

 FillChar(Desc, SizeOf(TD3DVertexBufferDesc), 0);

 Desc.dwSize:= SizeOf(TD3DVertexBufferDesc);
 Desc.dwCaps:= D3DVBCAPS_WRITEONLY or D3DVBCAPS_SYSTEMMEMORY;
 Desc.dwFVF := VertexFVFType;
 Desc.dwNumVertices:= MaxCachedVertices;

 Result:= Succeeded(Direct3D.CreateVertexBuffer(Desc, VertexBuffer, 0));
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.DestroyDynamicBuffers();
begin
 if (VertexBuffer <> nil) then VertexBuffer:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.ResetDeviceStates();
begin
 VertexCount := 0;
 IndexCount  := 0;
 Primitives  := 0;
 DrawingMode := dmUnknown;
 CachedEffect:= deUnknown;
 CachedTex   := nil;
 ActiveTex   := nil;

 with Device7 do
  begin
   // Disable 3D fancy stuff.
   SetRenderState(D3DRENDERSTATE_LIGHTING,  Cardinal(False));
   SetRenderState(D3DRENDERSTATE_CULLMODE,  Cardinal(D3DCULL_NONE));
   SetRenderState(D3DRENDERSTATE_ZENABLE,   Cardinal(D3DZB_FALSE));
   SetRenderState(D3DRENDERSTATE_FOGENABLE, Cardinal(False));

   // Enable Alpha-testing.
   SetRenderState(D3DRENDERSTATE_ALPHATESTENABLE, Cardinal(True));
   SetRenderState(D3DRENDERSTATE_ALPHAFUNC, Cardinal(D3DCMP_GREATEREQUAL));
   SetRenderState(D3DRENDERSTATE_ALPHAREF, $00000001);

   // Default alpha-blending behavior
   SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Cardinal(True));

   SetTextureStageState(0, D3DTSS_COLOROP, Cardinal(D3DTOP_MODULATE));
   SetTextureStageState(0, D3DTSS_ALPHAOP, Cardinal(D3DTOP_MODULATE));

   SetTextureStageState(0, D3DTSS_MAGFILTER, Cardinal(D3DTFG_LINEAR));
   SetTextureStageState(0, D3DTSS_MINFILTER, Cardinal(D3DTFG_LINEAR));
   SetTextureStageState(0, D3DTSS_MIPFILTER, Cardinal(D3DTFP_LINEAR));
  end;
end;

//--------------------------------------------------------------------------
function TDX7Canvas.HandleDeviceCreate(): Boolean;
begin
 CreateStaticObjects();

 Result:= True;
end;

//--------------------------------------------------------------------------
procedure TDX7Canvas.HandleDeviceDestroy();
begin
 DestroyStaticObjects();
end;

//--------------------------------------------------------------------------
function TDX7Canvas.HandleDeviceReset(): Boolean;
begin
 Result:= CreateDynamicBuffers();
end;

//--------------------------------------------------------------------------
procedure TDX7Canvas.HandleDeviceLost();
begin
 DestroyDynamicBuffers();
end;

//--------------------------------------------------------------------------
procedure TDX7Canvas.HandleBeginScene();
begin
 ResetDeviceStates();
end;

//--------------------------------------------------------------------------
procedure TDX7Canvas.HandleEndScene();
begin
 Flush();
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.GetViewport(out x, y, Width, Height: Integer);
var
 vp: TD3DViewport7;
begin
 if (Device7 = nil) then
  begin
   x:= 0; y:= 0; Width:= 0; Height:= 0;
   Exit;
  end;

 FillChar(vp, SizeOf(vp), 0);
 Device7.GetViewport(vp);

 x:= vp.dwX;
 y:= vp.dwY;

 Width := vp.dwWidth;
 Height:= vp.dwHeight;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.SetViewport(x, y, Width, Height: Integer);
var
 vp: TD3DViewport7;
begin
 if (Device7 = nil) then Exit;

 Flush();

 vp.dwX:= x;
 vp.dwY:= y;
 vp.dwWidth := Width;
 vp.dwHeight:= Height;
 vp.dvMinZ:= 0.0;
 vp.dvMaxZ:= 1.0;

 Device7.SetViewport(vp);
end;

//---------------------------------------------------------------------------
function TDX7Canvas.GetAntialias(): Boolean;
var
 MagFlt, MinFlt: Cardinal;
begin
 if (Device7 = nil) then
  begin
   Result:= False;
   Exit;
  end;

 Device7.GetTextureStageState(0, D3DTSS_MAGFILTER, MagFlt);
 Device7.GetTextureStageState(0, D3DTSS_MINFILTER, MinFlt);

 Result:= True;

 if (MagFlt = Cardinal(D3DTFG_POINT))or(MinFlt = Cardinal(D3DTFN_POINT)) then
  Result:= False;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.SetAntialias(const Value: Boolean);
begin
 if (Device7 = nil) then Exit;

 Flush();

 case Value of
  False:
   begin
    Device7.SetTextureStageState(0, D3DTSS_MAGFILTER, Cardinal(D3DTFG_POINT));
    Device7.SetTextureStageState(0, D3DTSS_MINFILTER, Cardinal(D3DTFN_POINT));
   end;

  True:
   begin
    Device7.SetTextureStageState(0, D3DTSS_MAGFILTER, Cardinal(D3DTFG_LINEAR));
    Device7.SetTextureStageState(0, D3DTSS_MINFILTER, Cardinal(D3DTFN_LINEAR));
   end; 
 end;
end;

//---------------------------------------------------------------------------
function TDX7Canvas.GetMipMapping(): Boolean;
var
 MipFlt: Cardinal;
begin
 if (Device7 = nil) then
  begin
   Result:= False;
   Exit;
  end;

 Device7.GetTextureStageState(0, D3DTSS_MIPFILTER, MipFlt);

 Result:= True;

 if (MipFlt = Cardinal(D3DTFP_NONE))or(MipFlt = Cardinal(D3DTFP_POINT)) then
  Result:= False;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.SetMipMapping(const Value: Boolean);
begin
 if (Device7 = nil) then Exit;

 Flush();

 case Value of
  False:
   Device7.SetTextureStageState(0, D3DTSS_MIPFILTER, Cardinal(D3DTFP_NONE));

  True:
   Device7.SetTextureStageState(0, D3DTSS_MIPFILTER, Cardinal(D3DTFP_LINEAR));
 end;
end;

//---------------------------------------------------------------------------
function TDX7Canvas.UploadVertexBuffer(): Boolean;
var
 MemAddr: Pointer;
 BufSize: Cardinal;
begin
 BufSize:= VertexCount * SizeOf(TVertexRecord);
 Result:= Succeeded(VertexBuffer.Lock(DDLOCK_DISCARDCONTENTS or
  DDLOCK_SURFACEMEMORYPTR or DDLOCK_WRITEONLY, MemAddr, BufSize));

 if (Result) then
  begin
   Move(VertexArray^, MemAddr^, BufSize);
   Result:= Succeeded(VertexBuffer.Unlock());
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.DrawBuffers();
begin
 with Device7 do
  begin
   case DrawingMode of
    dmPoints:
     DrawPrimitiveVB(D3DPT_POINTLIST, VertexBuffer, 0, VertexCount, 0);

    dmLines:
     DrawPrimitiveVB(D3DPT_LINELIST, VertexBuffer, 0, VertexCount, 0);

    dmTriangles:
     DrawIndexedPrimitiveVB(D3DPT_TRIANGLELIST, VertexBuffer, 0, VertexCount,
      IndexArray[0], IndexCount, 0);
   end;
  end;

 NextDrawCall();
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.Flush();
begin
 if (VertexCount > 0)and(Primitives > 0)and(UploadVertexBuffer()) then
  DrawBuffers();

 VertexCount:= 0;
 IndexCount := 0;
 Primitives := 0;
 DrawingMode := dmUnknown;
 CachedEffect:= deUnknown;

 Device7.SetTexture(0, nil);

 CachedTex:= nil;
 ActiveTex:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.SetEffectStates(Effect: TDrawingEffect);
begin
 case Effect of
  deNormal:
   with Device7 do
    begin
     SetRenderState(D3DRENDERSTATE_SRCBLEND,  Cardinal(D3DBLEND_SRCALPHA));
     SetRenderState(D3DRENDERSTATE_DESTBLEND, Cardinal(D3DBLEND_INVSRCALPHA));
    end;

  deShadow:
   with Device7 do
    begin
     SetRenderState(D3DRENDERSTATE_SRCBLEND,  Cardinal(D3DBLEND_ZERO));
     SetRenderState(D3DRENDERSTATE_DESTBLEND, Cardinal(D3DBLEND_INVSRCALPHA));
    end;

  deAdd:
   with Device7 do
    begin
     SetRenderState(D3DRENDERSTATE_SRCBLEND,  Cardinal(D3DBLEND_SRCALPHA));
     SetRenderState(D3DRENDERSTATE_DESTBLEND, Cardinal(D3DBLEND_ONE));
    end;

  deMultiply:
   with Device7 do
    begin
     SetRenderState(D3DRENDERSTATE_SRCBLEND,  Cardinal(D3DBLEND_ZERO));
     SetRenderState(D3DRENDERSTATE_DESTBLEND, Cardinal(D3DBLEND_SRCCOLOR));
    end;
 end;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.RequestCache(Mode: TDrawingMode; Vertices,
 Indices: Integer; Effect: TDrawingEffect; Texture: TAsphyreTexture);
var
 NeedReset: Boolean;
begin
 NeedReset:= (VertexCount + Vertices > MaxCachedVertices);
 NeedReset:= (NeedReset)or(IndexCount + Indices > MaxCachedIndices);
 NeedReset:= (NeedReset)or(DrawingMode = dmUnknown)or(DrawingMode <> Mode);
 NeedReset:= (NeedReset)or(CachedEffect = deUnknown)or(CachedEffect <> Effect);
 NeedReset:= (NeedReset)or(CachedTex <> Texture);

 if (NeedReset) then
  begin
   Flush();

   if (CachedEffect = deUnknown)or(CachedEffect <> Effect) then
    SetEffectStates(Effect);

   if (CachedEffect = deUnknown)or(CachedTex <> Texture) then
    begin
     if (Texture <> nil) then Texture.AssignToStage(0)
      else Device7.SetTexture(0, nil);
    end;

   DrawingMode := Mode;
   CachedEffect:= Effect;
   CachedTex   := Texture;
  end;
end;

//---------------------------------------------------------------------------
function TDX7Canvas.NextVertexEntry(): Pointer;
begin
 Result:= Pointer(Integer(VertexArray) +
  (VertexCount * SizeOf(TVertexRecord)));
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.AddIndexEntry(Index: Integer);
begin
 IndexArray[IndexCount]:= Index;
 Inc(IndexCount);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.PutPixel(const Point: TPoint2; Color: Cardinal);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmPoints, 1, 0, deNormal, nil);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Point.x;
 Entry.Vertex.y:= Point.y;
 Entry.Color   := Color;

 Inc(VertexCount);
 Inc(Primitives);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.Line(const Src, Dest: TPoint2; Color0, Color1: Cardinal);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmLines, 2, 0, deNormal, nil);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Src.x;
 Entry.Vertex.y:= Src.y;
 Entry.Color   := Color0;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Dest.x;
 Entry.Vertex.y:= Dest.y;
 Entry.Color   := Color1;
 Inc(VertexCount);

 Inc(Primitives);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
 Effect: TDrawingEffect);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmTriangles, 3, 3, Effect, nil);

 AddIndexEntry(VertexCount);
 AddIndexEntry(VertexCount + 1);
 AddIndexEntry(VertexCount + 2);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p1.x;
 Entry.Vertex.y:= p1.y;
 Entry.Color   := c1;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p2.x;
 Entry.Vertex.y:= p2.y;
 Entry.Color   := c2;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= p3.x;
 Entry.Vertex.y:= p3.y;
 Entry.Color   := c3;
 Inc(VertexCount);

 Inc(Primitives);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillQuad(const Points: TPoint4; const Colors: TColor4;
 Effect: TDrawingEffect);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmTriangles, 4, 6, Effect, nil);

 AddIndexEntry(VertexCount + 2);
 AddIndexEntry(VertexCount);
 AddIndexEntry(VertexCount + 1);
 AddIndexEntry(VertexCount + 3);
 AddIndexEntry(VertexCount + 2);
 AddIndexEntry(VertexCount + 1);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[0].x - 0.5;
 Entry.Vertex.y:= Points[0].y - 0.5;
 Entry.Color   := Colors[0];
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[1].x - 0.5;
 Entry.Vertex.y:= Points[1].y - 0.5;
 Entry.Color   := Colors[1];
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[3].x - 0.5;
 Entry.Vertex.y:= Points[3].y - 0.5;
 Entry.Color   := Colors[3];
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[2].x - 0.5;
 Entry.Vertex.y:= Points[2].y - 0.5;
 Entry.Color   := Colors[2];
 Inc(VertexCount);

 Inc(Primitives, 2);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.WireQuad(const Points: TPoint4; const Colors: TColor4);
var
 MyPts: TPoint4;
begin
 MyPts:= Points;

 // last pixel fix -> not very good implementation :(
 if (MyPts[0].y = MyPts[1].y)and(MyPts[2].y = MyPts[3].y)and
  (MyPts[0].x = MyPts[3].x)and(MyPts[1].x = MyPts[2].x) then
  begin
   MyPts[1].x:= MyPts[1].x - 1.0;
   MyPts[2].x:= MyPts[2].x - 1.0;
   MyPts[2].y:= MyPts[2].y - 1.0;
   MyPts[3].y:= MyPts[3].y - 1.0;
  end;

 Line(MyPts[0], MyPts[1], Colors[0], Colors[1]);
 Line(MyPts[1], MyPts[2], Colors[1], Colors[2]);
 Line(MyPts[2], MyPts[3], Colors[2], Colors[3]);
 Line(MyPts[3], MyPts[0], Colors[3], Colors[0]);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillHexagon(const Mtx: TMatrix3; c1, c2, c3, c4, c5,
 c6: Cardinal; Effect: TDrawingEffect);
var
 Colors: array[0..5] of TAsphyreColor;
 Vertex: TPoint2;
 MiddleColor: Cardinal;
 PreVtx, i: Integer;
 Entry: PVertexRecord;
begin
 Colors[0]:= c1; Colors[1]:= c2; Colors[2]:= c3;
 Colors[3]:= c4; Colors[4]:= c5; Colors[5]:= c6;

 MiddleColor:=
  (Colors[0] +
  Colors[1] +
  Colors[2] +
  Colors[3] +
  Colors[4] +
  Colors[5]) / 6;

 RequestCache(dmTriangles, 7, 18, Effect, nil);

 PreVtx:= VertexCount;

 Vertex:= ZeroVec2 * Mtx;

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Vertex.x;
 Entry.Vertex.y:= Vertex.y;
 Entry.Color   := MiddleColor;
 Inc(VertexCount);

 for i:= 0 to 5 do
  begin
   Vertex:= HexLookup[i] * Mtx;

   Entry:= NextVertexEntry();
   Entry.Vertex.x:= Vertex.x;
   Entry.Vertex.y:= Vertex.y;
   Entry.Color   := Colors[i];
   Inc(VertexCount);
  end;

 for i:= 0 to 4 do
  begin
   AddIndexEntry(PreVtx);
   AddIndexEntry(PreVtx + i + 1);
   AddIndexEntry(PreVtx + i + 2);
  end;

 AddIndexEntry(PreVtx);
 AddIndexEntry(PreVtx + 6);
 AddIndexEntry(PreVtx + 1);

 Inc(Primitives, 6);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillArc(const Pos, Radius: TPoint2; InitPhi,
 EndPhi: Single; Steps: Integer; const Colors: TColor4;
 Effect: TDrawingEffect);
var
 Pt1, Pt2: TPoint2;
 cs: TAsphyreColor4;
 i: Integer;
 Alpha: Single;
 xAlpha, yAlpha: Integer;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 VertexZero: Integer;
begin
 if (Steps < 1) then Exit;

 // (1) Convert 32-bit RGBA colors to fixed-point color set.
 cs:= ColorToFixed4(Colors);

 // (2) Find (x, y) margins for color interpolation.
 Pt1:= Pos - Radius;
 Pt2:= Pos + Radius;

 // (3) Before doing anything else, check cache availability.
 RequestCache(dmTriangles, Steps + 2, Steps * 3, Effect, nil);

 VertexZero:= VertexCount;

 // (4) Insert initial vertex placed at the arc's center
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Pos.x;
 Entry.Vertex.y:= Pos.y;
 Entry.Color   := (cs[0] + cs[1] + cs[2] + cs[3]) * 0.25;
 Inc(VertexCount);

 // (5) Insert the rest of vertices
 for i:= 0 to Steps - 1 do
  begin
   // initial and final angles for this vertex
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;

   // determine second and third points of the processed vertex
   CurPt.x:= Pos.x + Cos(Alpha) * Radius.x;
   CurPt.y:= Pos.y - Sin(Alpha) * Radius.y;

   // find color interpolation values
   xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
   yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));

   // insert new index buffer entry
   AddIndexEntry(VertexZero);
   AddIndexEntry(VertexCount);
   AddIndexEntry(VertexCount + 1);

   // insert the entry into vertex array
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
    xAlpha), yAlpha);
   Inc(VertexCount);
  end;

 // find the latest vertex to finish the arc
 CurPt.x:= Pos.x + Cos(EndPhi) * Radius.x;
 CurPt.y:= Pos.y - Sin(EndPhi) * Radius.y;

 // find color interpolation values
 xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
 yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));

 // insert the entry into vertex array
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color:= cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
  xAlpha), yAlpha);
 Inc(VertexCount);

 Inc(Primitives, Steps);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
 InitPhi, EndPhi: Single; Steps: Integer; const Colors: TColor4;
 Effect: TDrawingEffect);
var
 Pt1, Pt2: TPoint2;
 cs: TAsphyreColor4;
 i: Integer;
 Alpha: Single;
 xAlpha, yAlpha: Integer;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 PreVtx: Integer;
begin
 if (Steps < 1) then Exit;

 // (1) Convert 32-bit RGBA colors to fixed-point color set.
 cs:= ColorToFixed4(Colors);

 // (2) Find (x, y) margins for color interpolation.
 Pt1:= Pos - OutRadius;
 Pt2:= Pos + OutRadius;

 // (3) Check cache availability first.
 RequestCache(dmTriangles, (Steps * 2) + 2, Steps * 6, Effect, nil);

 PreVtx:= VertexCount;

 // (4) Create first inner vertex
 CurPt.x:= Pos.x + Cos(InitPhi) * InRadius.x;
 CurPt.y:= Pos.y - Sin(InitPhi) * InRadius.y;
 // -> color interpolation values
 xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
 yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
  xAlpha), yAlpha);
 Inc(VertexCount);

 // (5) Create first outer vertex
 CurPt.x:= Pos.x + Cos(InitPhi) * OutRadius.x;
 CurPt.y:= POs.y - Sin(InitPhi) * OutRadius.y;
 // -> color interpolation values
 xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
 yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
  xAlpha), yAlpha);
 Inc(VertexCount);

 // (6) Insert the rest of vertices
 for i:= 1 to Steps do
  begin
   // 6a. Insert inner vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= Pos.x + Cos(Alpha) * InRadius.x;
   CurPt.y:= Pos.y - Sin(Alpha) * InRadius.y;
   // -> color interpolation values
   xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
   yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
    xAlpha), yAlpha);
   Inc(VertexCount);

   // 6b. Insert outer vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= Pos.x + Cos(Alpha) * OutRadius.x;
   CurPt.y:= Pos.y - Sin(Alpha) * OutRadius.y;
   // -> color interpolation values
   xAlpha:= Round((CurPt.x - Pt1.x) * 255.0 / (Pt2.x - Pt1.x));
   yAlpha:= Round((CurPt.y - Pt1.y) * 255.0 / (Pt2.y - Pt1.y));
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= cBlend(cBlend(cs[0], cs[1], xAlpha), cBlend(cs[3], cs[2],
    xAlpha), yAlpha);
   Inc(VertexCount);
  end;

 // (7) Insert indexes
 for i:= 0 to Steps - 1 do
  begin
   AddIndexEntry(PreVtx);
   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 2);

   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 3);
   AddIndexEntry(PreVtx + 2);

   Inc(PreVtx, 2);
  end;

 Inc(Primitives, Steps * 2);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
 InitPhi, EndPhi: Single; Steps: Integer; InColor1, InColor2, InColor3,
 OutColor1, OutColor2, OutColor3: Cardinal; Effect: TDrawingEffect);
var
 ic1, ic2, ic3, oc1, oc2, oc3, ic, oc: TAsphyreColor;
 i: Integer;
 Alpha, Theta: Single;
 CurPt: TPoint2;
 Entry: PVertexRecord;
 PreVtx: Integer;
begin
 if (Steps < 1) then Exit;

 // (1) Convert 32-bit RGBA colors to fixed-point color set.
 ic1:= InColor1;
 ic2:= InColor2;
 ic3:= InColor3;
 oc1:= OutColor1;
 oc2:= OutColor2;
 oc3:= OutColor3;

 // (2) Check cache availability first.
 RequestCache(dmTriangles, (Steps * 2) + 2, Steps * 6, Effect, nil);

 PreVtx:= VertexCount;

 // (3) Create first inner vertex
 CurPt.x:= Pos.x + Cos(InitPhi) * InRadius.x;
 CurPt.y:= Pos.y - Sin(InitPhi) * InRadius.y;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := InColor1;
 Inc(VertexCount);

 // (5) Create first outer vertex
 CurPt.x:= Pos.x + Cos(InitPhi) * OutRadius.x;
 CurPt.y:= Pos.y - Sin(InitPhi) * OutRadius.y;
 // -> insert the vertex
 Entry:= NextVertexEntry();
 Entry.Vertex.x:= CurPt.x;
 Entry.Vertex.y:= CurPt.y;
 Entry.Color   := OutColor1;
 Inc(VertexCount);

 // (6) Insert the rest of vertices
 for i:= 1 to Steps do
  begin
   Theta:= i / Steps;
   if (Theta < 0.5) then
    begin
     Theta:= 2.0 * Theta;
     ic:= cLerp(ic1, ic2, Theta);
     oc:= cLerp(oc1, oc2, Theta);
    end else
    begin
     Theta:= (Theta - 0.5) * 2.0;
     ic:= cLerp(ic2, ic3, Theta);
     oc:= cLerp(oc2, oc3, Theta);
    end;

   // 6a. Insert inner vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= Pos.x + Cos(Alpha) * InRadius.x;
   CurPt.y:= Pos.y - Sin(Alpha) * InRadius.y;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= ic;
   Inc(VertexCount);

   // 6b. Insert outer vertex
   // -> angular position
   Alpha:= (i * (EndPhi - InitPhi) / Steps) + InitPhi;
   // -> vertex position
   CurPt.x:= Pos.x + Cos(Alpha) * OutRadius.x;
   CurPt.y:= Pos.y - Sin(Alpha) * OutRadius.y;
   // -> insert the vertex
   Entry:= NextVertexEntry();
   Entry.Vertex.x:= CurPt.x;
   Entry.Vertex.y:= CurPt.y;
   Entry.Color:= oc;

   Inc(VertexCount);
  end;

 // (7) Insert indexes
 for i:= 0 to Steps - 1 do
  begin
   AddIndexEntry(PreVtx);
   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 2);

   AddIndexEntry(PreVtx + 1);
   AddIndexEntry(PreVtx + 3);
   AddIndexEntry(PreVtx + 2);

   Inc(PreVtx, 2);
  end;

 Inc(Primitives, Steps * 2);
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.UseImage(Image: TAsphyreImage;
 const Mapping: TPoint4; TextureNo: Integer = 0);
begin
 if (Image <> nil) then ActiveTex:= Image.Texture[TextureNo]
  else ActiveTex:= nil;

 QuadMapping:= Mapping;
end;

//---------------------------------------------------------------------------
procedure TDX7Canvas.TexMap(const Points: TPoint4; const Colors: TColor4;
 Effect: TDrawingEffect);
var
 Entry: PVertexRecord;
begin
 RequestCache(dmTriangles, 4, 6, Effect, ActiveTex);

 AddIndexEntry(VertexCount + 2);
 AddIndexEntry(VertexCount);
 AddIndexEntry(VertexCount + 1);

 AddIndexEntry(VertexCount + 3);
 AddIndexEntry(VertexCount + 2);
 AddIndexEntry(VertexCount + 1);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[0].x - 0.5;
 Entry.Vertex.y:= Points[0].y - 0.5;
 Entry.Color   := Colors[0];
 Entry.u:= QuadMapping[0].x;
 Entry.v:= QuadMapping[0].y;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[1].x - 0.5;
 Entry.Vertex.y:= Points[1].y - 0.5;
 Entry.Color   := Colors[1];
 Entry.u:= QuadMapping[1].x;
 Entry.v:= QuadMapping[1].y;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[3].x - 0.5;
 Entry.Vertex.y:= Points[3].y - 0.5;
 Entry.Color   := Colors[3];
 Entry.u:= QuadMapping[3].x;
 Entry.v:= QuadMapping[3].y;
 Inc(VertexCount);

 Entry:= NextVertexEntry();
 Entry.Vertex.x:= Points[2].x - 0.5;
 Entry.Vertex.y:= Points[2].y - 0.5;
 Entry.Color   := Colors[2];
 Entry.u:= QuadMapping[2].x;
 Entry.v:= QuadMapping[2].y;
 Inc(VertexCount);

 Inc(Primitives, 2);
end;

//---------------------------------------------------------------------------
end.

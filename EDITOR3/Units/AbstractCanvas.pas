unit AbstractCanvas;
//---------------------------------------------------------------------------
// AbstractCanvas.pas                                   Modified: 01-Nov-2007
// Asphyre 2D Canvas Abstract declaration                         Version 1.0
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
// The Original Code is AbstractCanvas.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Types, Vectors2, Matrices3, AsphyreColors, AsphyreTypes, AsphyreImages;

//---------------------------------------------------------------------------
type
 TDrawingEffect = (deUnknown, deNormal, deShadow, deAdd, deMultiply);

//---------------------------------------------------------------------------
 TAsphyreCanvas = class
 private
  FDrawCalls: Integer;

  CreateHandle    : Cardinal;
  DestroyHandle   : Cardinal;
  ResetHandle     : Cardinal;
  LostHandle      : Cardinal;
  BeginSceneHandle: Cardinal;
  EndSceneHandle  : Cardinal;

  procedure OnDeviceCreate(Sender: TObject; Param: Pointer;
   var Handled: Boolean);
  procedure OnDeviceDestroy(Sender: TObject; Param: Pointer;
   var Handled: Boolean);
  procedure OnDeviceReset(Sender: TObject; Param: Pointer;
   var Handled: Boolean);
  procedure OnDeviceLost(Sender: TObject; Param: Pointer;
   var Handled: Boolean);

  procedure OnBeginScene(Sender: TObject; Param: Pointer;
   var Handled: Boolean);
  procedure OnEndScene(Sender: TObject; Param: Pointer;
   var Handled: Boolean);

  function GetClipRect(): TRect;
  procedure SetClipRect(const Value: TRect);
  procedure WuHoriz(x1, y1, x2, y2: Single;
   const Color0, Color1: TAsphyreColor);
  procedure WuVert(x1, y1, x2, y2: Single; const Color0,
   Color1: TAsphyreColor);
 protected
  function HandleDeviceCreate(): Boolean; virtual; abstract;
  procedure HandleDeviceDestroy(); virtual; abstract;
  function HandleDeviceReset(): Boolean; virtual; abstract;
  procedure HandleDeviceLost(); virtual; abstract;

  procedure HandleBeginScene(); virtual; abstract;
  procedure HandleEndScene(); virtual; abstract;

  procedure GetViewport(out x, y, Width, Height: Integer); virtual; abstract;
  procedure SetViewport(x, y, Width, Height: Integer); virtual; abstract;
  function GetAntialias(): Boolean; virtual; abstract;
  procedure SetAntialias(const Value: Boolean); virtual; abstract;
  function GetMipMapping(): Boolean; virtual; abstract;
  procedure SetMipMapping(const Value: Boolean); virtual; abstract;

  procedure NextDrawCall();
 public
  property DrawCalls: Integer read FDrawCalls;

  property ClipRect  : TRect read GetClipRect write SetClipRect;
  property Antialias : Boolean read GetAntialias write SetAntialias;
  property MipMapping: Boolean read GetMipMapping write SetMipMapping;

  procedure PutPixel(const Point: TPoint2;
   Color: Cardinal); virtual; abstract;
  procedure Line(const Src, Dest: TPoint2; Color0,
   Color1: Cardinal); virtual; abstract;

  procedure WuLine(Src, Dest: TPoint2; Color0, Color1: Cardinal);

  procedure Ellipse(const Pos, Radius: TPoint2; Steps: Integer;
   Color: Cardinal);
  procedure Circle(const Pos: TPoint2; Radius: Single; Steps: Integer;
   Color: Cardinal);

  procedure FillTri(const p1, p2, p3: TPoint2; c1, c2, c3: Cardinal;
   Effect: TDrawingEffect = deNormal); virtual; abstract;

  procedure FillQuad(const Points: TPoint4; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); virtual; abstract;
  procedure WireQuad(const Points: TPoint4;
   const Colors: TColor4); virtual; abstract;

  procedure FillRect(const Rect: TRect; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); overload;
  procedure FillRect(const Rect: TRect; Color: Cardinal;
   Effect: TDrawingEffect = deNormal); overload;
  procedure FillRect(Left, Top, Width, Height: Integer; Color: Cardinal;
   Effect: TDrawingEffect = deNormal); overload;
  procedure FrameRect(const Rect: TRect; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal);

  procedure FillHexagon(const Mtx: TMatrix3; c1, c2, c3, c4, c5, c6: Cardinal;
   Effect: TDrawingEffect = deNormal); virtual; abstract;

  procedure FrameHexagon(const Mtx: TMatrix3; Color: Cardinal);

  procedure FillArc(const Pos, Radius: TPoint2; InitPhi, EndPhi: Single;
   Steps: Integer; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); overload; virtual; abstract;
  procedure FillArc(x, y, Radius, InitPhi, EndPhi: Single; Steps: Integer;
   const Colors: TColor4; Effect: TDrawingEffect = deNormal); overload;

  procedure FillEllipse(const Pos, Radius: TPoint2;
   Steps: Integer; const Colors: TColor4; Effect: TDrawingEffect = deNormal);
  procedure FillCircle(x, y, Radius: Single; Steps: Integer;
   const Colors: TColor4; Effect: TDrawingEffect = deNormal);

  procedure FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
   InitPhi, EndPhi: Single; Steps: Integer; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); overload; virtual; abstract;
  procedure FillRibbon(const Pos, InRadius, OutRadius: TPoint2;
   InitPhi, EndPhi: Single; Steps: Integer; InColor1, InColor2, InColor3,
   OutColor1, OutColor2, OutColor3: Cardinal;
   Effect: TDrawingEffect = deNormal); overload; virtual; abstract;

  procedure UseImage(Image: TAsphyreImage; const Mapping: TPoint4;
   TextureNo: Integer = 0); overload; virtual; abstract;

  procedure UseImagePt(Image: TAsphyreImage; Pattern: Integer); overload;
  procedure UseImagePt(Image: TAsphyreImage; Pattern: Integer;
   const SrcRect: TRect; Mirror: Boolean = False;
   Flip: Boolean = False); overload;

  procedure UseImagePx(Image: TAsphyreImage; const Mapping: TPoint4px;
   TextureNo: Integer = 0);

  procedure TexMap(const Points: TPoint4; const Colors: TColor4;
   Effect: TDrawingEffect = deNormal); virtual; abstract;

  procedure Flush(); virtual; abstract;

  constructor Create(); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 AbstractDevices, AbstractTextures;

//---------------------------------------------------------------------------
constructor TAsphyreCanvas.Create();
begin
 inherited;

 FDrawCalls:= 0;

 {$ifdef fpc}
 CreateHandle := EventDeviceCreate.Subscribe(@OnDeviceCreate, -1);
 DestroyHandle:= EventDeviceDestroy.Subscribe(@OnDeviceDestroy, -1);

 ResetHandle:= EventDeviceReset.Subscribe(@OnDeviceReset, -1);
 LostHandle := EventDeviceLost.Subscribe(@OnDeviceLost, -1);

 BeginSceneHandle:= EventEndScene.Subscribe(@OnBeginScene, -1);
 EndSceneHandle  := EventEndScene.Subscribe(@OnEndScene, -1);
 {$else}
 CreateHandle := EventDeviceCreate.Subscribe(OnDeviceCreate, -1);
 DestroyHandle:= EventDeviceDestroy.Subscribe(OnDeviceDestroy, -1);

 ResetHandle:= EventDeviceReset.Subscribe(OnDeviceReset, -1);
 LostHandle := EventDeviceLost.Subscribe(OnDeviceLost, -1);

 BeginSceneHandle:= EventEndScene.Subscribe(OnBeginScene, -1);
 EndSceneHandle  := EventEndScene.Subscribe(OnEndScene, -1);
 {$endif}
end;

//---------------------------------------------------------------------------
destructor TAsphyreCanvas.Destroy();
begin
 EventEndScene.Unsubscribe(EndSceneHandle);
 EventDeviceLost.Unsubscribe(LostHandle);
 EventDeviceReset.Unsubscribe(ResetHandle);
 EventDeviceDestroy.Unsubscribe(DestroyHandle);
 EventDeviceCreate.Unsubscribe(CreateHandle);

 inherited;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnDeviceCreate(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
var
 Success: Boolean;
begin
 Success:= HandleDeviceCreate();

 if (Param <> nil) then PBoolean(Param)^:= Success;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnDeviceDestroy(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
begin
 HandleDeviceDestroy();
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnDeviceReset(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
var
 Success: Boolean;
begin
 Success:= HandleDeviceReset();

 if (Param <> nil) then PBoolean(Param)^:= Success;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnDeviceLost(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
begin
 HandleDeviceLost();
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnBeginScene(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
begin
 FDrawCalls:= 0;

 HandleBeginScene();
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.OnEndScene(Sender: TObject; Param: Pointer;
 var Handled: Boolean);
begin
 HandleEndScene();
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.GetClipRect(): TRect;
var
 x, y, Width, Height: Integer;
begin
 GetViewport(x, y, Width, Height);

 Result:= Bounds(x, y, Width, Height);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetClipRect(const Value: TRect);
begin
 SetViewport(Value.Left, Value.Top, Value.Right - Value.Left,
  Value.Bottom - Value.Top);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImagePx(Image: TAsphyreImage;
 const Mapping: TPoint4px; TextureNo: Integer);
var
 Texture: TAsphyreTexture;
 Points : TPoint4;
begin
 if (Image = nil) then Exit;

 Texture:= Image.Texture[TextureNo];
 if (Texture = nil) then Exit;

 Points:= Texture.CoordToLogical4(Mapping);

 UseImage(Image, Points, TextureNo);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImagePt(Image: TAsphyreImage; Pattern: Integer);
var
 Mapping  : TPoint4;
 TextureNo: Integer;
begin
 if (Image = nil) then Exit;

 TextureNo:= Image.RetreiveTex(Pattern, Mapping);
 if (TextureNo = -1) then Exit;

 UseImage(Image, Mapping, TextureNo);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.UseImagePt(Image: TAsphyreImage; Pattern: Integer;
 const SrcRect: TRect; Mirror, Flip: Boolean);
var
 Mapping  : TPoint4;
 TextureNo: Integer;
begin
 if (Image = nil) then Exit;

 TextureNo:= Image.RetreiveTex(Pattern, SrcRect, Mirror, Flip, Mapping);
 if (TextureNo = -1) then Exit;

 UseImage(Image, Mapping, TextureNo);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.NextDrawCall();
begin
 Inc(FDrawCalls);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillArc(x, y, Radius, InitPhi, EndPhi: Single;
 Steps: Integer; const Colors: TColor4; Effect: TDrawingEffect);
begin
 FillArc(Point2(x, y), Point2(Radius, Radius), InitPhi, EndPhi, Steps, Colors,
  Effect);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillEllipse(const Pos, Radius: TPoint2;
 Steps: Integer; const Colors: TColor4; Effect: TDrawingEffect);
begin
 FillArc(Pos, Radius, 0, Pi * 2.0, Steps, Colors, Effect);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillCircle(x, y, Radius: Single;
 Steps: Integer; const Colors: TColor4; Effect: TDrawingEffect);
begin
 FillArc(Point2(x, y), Point2(Radius, Radius), 0, Pi * 2.0, Steps, Colors,
  Effect);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; const Colors: TColor4;
 Effect: TDrawingEffect = deNormal);
begin
 FillQuad(pRect4(Rect), Colors, Effect);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; Color: Cardinal;
 Effect: TDrawingEffect = deNormal);
begin
 FillRect(Rect, cColor4(Color), Effect);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(Left, Top, Width, Height: Integer;
 Color: Cardinal; Effect: TDrawingEffect = deNormal);
begin
 FillRect(Bounds(Left, Top, Width, Height), Color, Effect);
end;

//---------------------------------------------------------------------------
procedure SwapSingle(var a, b: Single);
var
 Temp: Single;
begin
 Temp:= a;
 a:= b;
 b:= Temp;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuHoriz(x1, y1, x2, y2: Single;
 const Color0, Color1: TAsphyreColor);
var
 Color: TAsphyreColor;
 xd, yd, Grad, yf: Single;
 xEnd, x, ix1, ix2, iy1, iy2: Integer;
 yEnd, xGap, Alpha1, Alpha2, Alpha, AlphaInc: Single;
begin
 xd:= x2 - x1;
 yd:= y2 - y1;

 if (x1 > x2) then
  begin
   SwapSingle(x1, x2);
   SwapSingle(y1, y2);
   xd:= x2 - x1;
   yd:= y2 - y1;
  end;

 Grad:= yd / xd;

 // End Point 1
 xEnd:= Trunc(x1 + 0.5);
 yEnd:= y1 + Grad * (xEnd - x1);

 xGap:= 1.0 - Frac(x1 + 0.5);

 ix1:= xEnd;
 iy1:= Trunc(yEnd);

 Alpha1:= (1.0 - Frac(yEnd)) * xGap;
 Alpha2:= Frac(yEnd) * xGap;

 PutPixel(Point2(ix1, iy1), cModulateAlpha(Color0, Alpha1));
 PutPixel(Point2(ix1, iy1 + 1.0), cModulateAlpha(Color0, Alpha2));

 yf:= yEnd + Grad;

 // End Point 2
 xEnd:= Trunc(x2 + 0.5);
 yEnd:= y2 + Grad * (xEnd - x2);

 xGap:= 1.0 - Frac(x2 + 0.5);

 ix2:= xEnd;
 iy2:= Trunc(yEnd);

 Alpha1:= (1.0 - Frac(yEnd)) * xGap;
 Alpha2:= Frac(yEnd) * xGap;

 PutPixel(Point2(ix2, iy2), cModulateAlpha(Color1, Alpha1));
 PutPixel(Point2(ix2, iy2 + 1.0), cModulateAlpha(Color1, Alpha2));

 Alpha:= 0.0;
 AlphaInc:= 1.0 / xd;

 // Main Loop
 for x:= ix1 + 1 to ix2 - 1 do
  begin
   Alpha1:= 1.0 - Frac(yf);
   Alpha2:= Frac(yf);

   Color:= cLerp(Color0, Color1, Alpha);

   PutPixel(Point2(x, Int(yf)), cModulateAlpha(Color, Alpha1));
   PutPixel(Point2(x, Int(yf) + 1.0), cModulateAlpha(Color, Alpha2));

   yf:= yf + Grad;
   Alpha:= Alpha + AlphaInc;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuVert(x1, y1, x2, y2: Single;
 const Color0, Color1: TAsphyreColor);
var
 Color: TAsphyreColor;
 xd, yd, Grad, xf: Single;
 yEnd, y, ix1, ix2, iy1, iy2: Integer;
 xEnd, yGap, Alpha1, Alpha2, Alpha, AlphaInc: Single;
begin
 xd:= x2 - x1;
 yd:= y2 - y1;

 if (y1 > y2) then
  begin
   SwapSingle(x1, x2);
   SwapSingle(y1, y2);
   xd:= x2 - x1;
   yd:= y2 - y1;
  end;

 Grad:= xd / yd;

 // End Point 1
 yEnd:= Trunc(y1 + 0.5);
 xEnd:= x1 + Grad * (yEnd - y1);

 yGap:= 1.0 - Frac(y1 + 0.5);

 ix1:= Trunc(xEnd);
 iy1:= yEnd;

 Alpha1:= (1.0 - Frac(xEnd)) * yGap;
 Alpha2:= Frac(xEnd) * yGap;

 PutPixel(Point2(ix1, iy1), cModulateAlpha(Color0, Alpha1));
 PutPixel(Point2(ix1 + 1.0, iy1), cModulateAlpha(Color0, Alpha2));

 xf:= xEnd + Grad;

 // End Point 2
 yEnd:= Trunc(y2 + 0.5);
 xEnd:= x2 + Grad * (yEnd - y2);

 yGap:= 1.0 - Frac(y2 + 0.5);

 ix2:= Trunc(xEnd);
 iy2:= yEnd;

 Alpha1:= (1.0 - Frac(xEnd)) * yGap;
 Alpha2:= Frac(xEnd) * yGap;

 PutPixel(Point2(ix2, iy2), cModulateAlpha(Color1, Alpha1));
 PutPixel(Point2(ix2 + 1.0, iy2), cModulateAlpha(Color1, Alpha2));

 Alpha:= 0.0;
 AlphaInc:= 1.0 / yd;

 // Main Loop
 for y:= iy1 + 1 to iy2 - 1 do
  begin
   Alpha1:= 1.0 - Frac(xf);
   Alpha2:= Frac(xf);

   Color:= cLerp(Color0, Color1, Alpha);

   PutPixel(Point2(Int(xf), y), cModulateAlpha(Color, Alpha1));
   PutPixel(Point2(Int(xf) + 1.0, y), cModulateAlpha(Color, Alpha2));

   xf:= xf + Grad;
   Alpha:= Alpha + AlphaInc;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuLine(Src, Dest: TPoint2; Color0, Color1: Cardinal);
begin
 if (Abs(Dest.x - Src.x) > Abs(Dest.y - Src.y)) then
  WuHoriz(Src.x, Src.y, Dest.x, Dest.y, Color0, Color1)
   else WuVert(Src.x, Src.y, Dest.x, Dest.y, Color0, Color1)
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Ellipse(const Pos, Radius: TPoint2; Steps: Integer;
 Color: Cardinal);
const
 Pi2 = Pi * 2.0;
var
 i: Integer;
 Vertex, PreVertex: TPoint2;
 Alpha: Single;
begin
 Vertex:= ZeroVec2;

 for i:= 0 to Steps do
  begin
   Alpha:= i * Pi2 / Steps;

   PreVertex:= Vertex;
   Vertex.x:= Round(Pos.x + Cos(Alpha) * Radius.x);
   Vertex.y:= Round(Pos.y - Sin(Alpha) * Radius.y);

   if (i > 0) then
    WuLine(PreVertex, Vertex, Color, Color);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Circle(const Pos: TPoint2; Radius: Single;
 Steps: Integer; Color: Cardinal);
begin
 Ellipse(Pos, Point2(Radius, Radius), Steps, Color);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameHexagon(const Mtx: TMatrix3; Color: Cardinal);
var
 i: Integer;
 Vertex, PreVertex: TPoint2;
 Angle, Delta: Single;
begin
 Delta:= (1.0 / Cos(Pi / 6.0));

 Vertex:= ZeroVec2;

 for i:= 0 to 6 do
  begin
   Angle:= (i / 6.0) * 2.0 * Pi + (Pi / 6.0);

   PreVertex:= Vertex;
   Vertex:= Point2(Cos(Angle) * Delta, -Sin(Angle) * Delta) * Mtx;

   if (i > 0) then
    WuLine(PreVertex, Vertex, Color, Color);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(const Rect: TRect; const Colors: TColor4;
 Effect: TDrawingEffect);
begin
 Line(
  Point2(Rect.Left, Rect.Top),
  Point2(Rect.Right, Rect.Top),
  Colors[0], Colors[1]);

 Line(
  Point2(Rect.Right - 1, Rect.Top + 1),
  Point2(Rect.Right - 1, Rect.Bottom - 1),
  Colors[1], Colors[2]);

 Line(
  Point2(Rect.Left, Rect.Bottom - 1),
  Point2(Rect.Right, Rect.Bottom - 1),
  Colors[3], Colors[2]);

 Line(
  Point2(Rect.Left, Rect.Top + 1),
  Point2(Rect.Left, Rect.Bottom - 1),
  Colors[0], Colors[3]);
end;

//---------------------------------------------------------------------------
end.


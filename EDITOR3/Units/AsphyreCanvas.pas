unit AsphyreCanvas;
//---------------------------------------------------------------------------
// Add draw procedure,    By DraculaLin                 Modified: 12-Feb-2006
// SetGamma
// DrawAlpha1, DrawAlpha4, DrawColor1, DrawColor4, DrawEx, DrawPortion,
// DrawRectStretch, DrawRectTransForm,,DrawRotate, DrawRotateC, DrawRotateRect
// DrawRotateStretch, DrawRotateStretchC, DrawStetch, DrawTransForm,
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// AsphyreCanvas.pas                                    Modified: 03-Oct-2005
// Basic hardware-accelerated 2D routines                         Version 1.0
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
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, Classes, SysUtils, AsphyreDef, ImageFx, AsphyreImages,
 Asphyre2D, Direct3D9, DXBase, Math;

//---------------------------------------------------------------------------
type
 TAsphyreCanvas = class(TAsphyre2D)
 private
  procedure SetPixel(x, y: Real; const Value: Cardinal);
  function ModulateAlpha(Color: Cardinal; Beta: Real): Cardinal;
 public
  //-------------------------------------------------------------------------
  // Pixels Helper (uses PutPixel)
  //-------------------------------------------------------------------------
  property Pixels[x, y: Real]: Cardinal write SetPixel;

  //-------------------------------------------------------------------------
  // FrameRect / FillRect routines. Draw either filled or non-filled
  // rectangles with the specified coordinates, colors and draw operation.
  //-------------------------------------------------------------------------
  procedure FillRect(const Rect: TRect; Colors: TColor4;
   DrawFx: Cardinal); overload;
  procedure FillRect(const Rect: TRect; Color: Cardinal;
   DrawFx: Cardinal); overload;
  procedure FillRect(Left, Top, Width, Height: Integer; Color: Cardinal;
   DrawFx: Cardinal); overload;

  procedure FrameRect(const Rect: TRect; const Colors: TColor4;
   DrawFx: Cardinal); overload;
  procedure FrameRect(const Rect: TRect; Color: Cardinal;
   DrawFx: Cardinal); overload;
  procedure FrameRect(Left, Top, Width, Height: Integer; Color: Cardinal;
   DrawFx: Cardinal); overload;

  //-------------------------------------------------------------------------
  // Rectangle drawing routines (filled + outlined).
  // NOTE: These routines are NON-CACHED which means using them may reduce
  // the rendering performance.
  //-------------------------------------------------------------------------
  procedure Rectangle(Left, Top, Width, Height: Integer; ColorLine,
   ColorFill: Cardinal; DrawFx: Cardinal); overload;
  procedure Rectangle(const Rect: TRect; ColorLine, ColorFill: Cardinal;
   DrawFx: Cardinal); overload;

  //---------------------------------------------------------------------------
  // Ellipse drawing routine, uses Line primitive.
  //---------------------------------------------------------------------------
  procedure Ellipse(const Center: TPoint2; Radius0, Radius1: Real;
   Sections: Integer; Color: Cardinal; DrawFx: Cardinal);

  // Circle actually uses Ellipse routine with variable section number
  procedure Circle(Xpos, Ypos, Radius: Real; Color: Cardinal; DrawFx: Cardinal);

  //---------------------------------------------------------------------------
  // Anti-aliased "Wu Line" which uses PutPixel routine and thus is
  // considerably slower than Line routine. This method, however, can be useful
  // when no antialiased lines are supported in hardware.
  //---------------------------------------------------------------------------
  procedure WuLine(Src, Dest: TPoint2; Color0, Color1: Longword;
   DrawFx: Cardinal);

  //---------------------------------------------------------------------------
  // Anti-aliased Circle routine; uses PutPixel to draw the circle and is
  // much slower than regular "Circle" routine (which can be, by the way,
  // also anti-aliased, check "Line" anti-aliasing comment!)
  //---------------------------------------------------------------------------
  procedure SmoothCircle(Xpos, Ypos, Radius: Real; Color: Cardinal;
   DrawFx: Cardinal);

  //---------------------------------------------------------------------------
  procedure FillCircle(Xpos, Ypos, Radius: Integer; Color: Cardinal;
   DrawFx: Cardinal); overload;
  procedure FillCircle(Xpos, Ypos, Radius: Integer; const Colors: TColor4;
   DrawFx: Cardinal); overload;

  // image drawing routines (all use "TexMap" routine)
  procedure Draw(Image: TAsphyreImage; x, y: Real; Pattern: Integer;
   DrawFx: Cardinal); overload;
  procedure Draw(Image: TAsphyreImage; x, y, Scale: Real; Pattern: Integer;
   DrawFx: Cardinal); overload;
  procedure Draw(Image: TAsphyreImage; Rect: TRect; Pattern: Integer;
   DrawFx: Cardinal); overload;

  // image drawing routines w/diffuse color
  procedure DrawEx(Image: TAsphyreImage; x, y: Real; Color: Cardinal;
   Pattern: Integer; DrawFx: Cardinal); overload;
  procedure DrawEx(Image: TAsphyreImage; x, y, Scale: Real; Color: Cardinal;
   Pattern: Integer; DrawFx: Cardinal); overload;
  procedure DrawEx(Image: TAsphyreImage; Rect: TRect; Color: Cardinal;
   Pattern: Integer; DrawFx: Cardinal); overload;

  // image rotating routines
  procedure DrawRot(Image: TAsphyreImage; x, y, Angle, Scale: Real;
   Pattern: Integer; DrawFx: Cardinal); overload;
  procedure DrawRot(Image: TAsphyreImage; x, y, Angle, Scale: Real;
   Color: Cardinal; Pattern: Integer; DrawFx: Cardinal); overload;
  // set screen gamma
  procedure SetGamma(Red, Green, Blue, Brightness, Contrast: Byte);
  // extended draw  routines
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Red, Green, Blue, Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Alpha: Byte; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer); overload;
  procedure DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Color1, Color2, Color3, Color4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
    DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer); overload;
  procedure DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height,
    ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
    DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRectStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, y1, X2, Y2: Real;
    SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
    X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawRectTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
    X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle: Real;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
    Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
    Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
    Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
    CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  procedure DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
    CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
    MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer); overload;
  end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SetPixel(x, y: Real; const Value: Cardinal);
begin
 PutPixel(x, y, Value, fxNone);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; Colors: TColor4;
 DrawFx: Cardinal);
begin
 FillQuad(pRect4(Rect), Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(const Rect: TRect; Color: Cardinal;
 DrawFx: Cardinal);
begin
 FillRect(Rect, cColor4(Color), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillRect(Left, Top, Width, Height: Integer;
 Color: Cardinal; DrawFx: Cardinal);
begin
 FillRect(Bounds(Left, Top, Width, Height), Color, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(const Rect: TRect; const Colors: TColor4;
 DrawFx: Cardinal);
begin
 Quad(pRect4(Rect), Colors, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(const Rect: TRect; Color: Cardinal;
 DrawFx: Cardinal);
begin
 FrameRect(Rect, cColor4(Color), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FrameRect(Left, Top, Width, Height: Integer;
 Color: Cardinal; DrawFx: Cardinal);
begin
 FrameRect(Bounds(Left, Top, Width, Height), Color, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Rectangle(const Rect: TRect; ColorLine,
 ColorFill: Cardinal; DrawFx: Cardinal);
begin
 FillRect(Rect, ColorFill, DrawFx);
 FrameRect(Rect, ColorLine, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Rectangle(Left, Top, Width, Height: Integer; ColorLine,
  ColorFill: Cardinal; DrawFx: Cardinal);
begin
 FillRect(Left, Top, Width, Height, ColorFill, DrawFx);
 FrameRect(Left, Top, Width, Height, ColorLine, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Ellipse(const Center: TPoint2; Radius0, Radius1: Real;
 Sections: Integer; Color: Cardinal; DrawFx: Cardinal);
const
 Pi2 = Pi * 2.0;
var
 i: Integer;
 Pt0, Pt1: TPoint2;
 Alpha0, Alpha1: Real;
begin
 for i:= 0 to Sections - 1 do
  begin
   Alpha0:= i * Pi2 / Sections;
   Alpha1:= (i + 1) * Pi2 / Sections;

   Pt0.X:= Center.X + (Cos(Alpha0) * Radius0);
   Pt0.Y:= Center.Y + (Sin(Alpha0) * Radius1);
   Pt1.X:= Center.X + (Cos(Alpha1) * Radius0);
   Pt1.Y:= Center.Y + (Sin(Alpha1) * Radius1);

   Line(Pt0, Pt1, Color, Color, DrawFx);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Circle(Xpos, Ypos, Radius: Real; Color: Cardinal;
 DrawFx: Cardinal);
var
 Perimeter: Real;
 Sections : Integer;
begin
 Perimeter:= 2.0 * Pi * Radius;
 Sections:= Round(Perimeter / 4.0);
 if (Sections < 3) then Exit;

 Ellipse(Point2(Xpos, Ypos), Radius, Radius, Sections, Color, DrawFx);
end;

//---------------------------------------------------------------------------
function TAsphyreCanvas.ModulateAlpha(Color: Cardinal; Beta: Real): Cardinal;
begin
 Result:= (Color and $FFFFFF) or (Round((Color shr 24) * Beta) shl 24);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.WuLine(Src, Dest: TPoint2; Color0, Color1: Longword;
 DrawFx: Cardinal);
const
 Epsilon = 0.00001; // treshold to consider the line is straight
var
 DeltaX, DeltaY, Grad, xEnd, yEnd, xPos, yPos: Real;
 Alpha, AlphaInc: Real;
 Aux, Point0, Point1: TPoint2;
 Index: Integer;
 MyColor: Cardinal;
begin
 DeltaX:= Dest.x - Src.x;
 DeltaY:= Dest.y - Src.y;

 // straight lines?
{ comment: no straight lines!
 if (DeltaX < Epsilon)or(DeltaY < Epsilon) then
  begin
   Line(Src, Dest, Color0, Color1, Op);
   Exit;
  end;}

 if (Abs(DeltaX) > Abs(DeltaY)) then
  begin // horizontal line
   if (DeltaX < 0.0) then
    begin
     Aux := Src;
     Src := Dest;
     Dest:= Aux;
     DeltaX:= -DeltaX;
     DeltaY:= -DeltaY;
    end;

   Grad:= DeltaY / DeltaX;

   // 1st point
   xEnd:= Int(Src.x + 0.5);
   yEnd:= Src.y + (xEnd - Src.x) * Grad;
   yPos:= yEnd + Grad;

   Point0:= Point2(Int(xEnd), Int(yEnd));

   // 2nd point
   xEnd:= Int(Dest.x + 0.5);
   yEnd:= Dest.y + (xEnd - Dest.x) * Grad;

   Point1:= Point2(Int(xEnd), Int(yEnd));

   Alpha:= 0.0;
   AlphaInc:= 255.0 / Abs(Int(Point1.x) - Int(Point0.x));
   for Index:= Trunc(Point0.x) to Trunc(Point1.x) do
    begin
     MyColor:= BlendPixels(Color1, Color0, Round(Alpha));
     PutPixel(Index, Int(yPos), ModulateAlpha(MyColor, 1.0 - Frac(yPos)), DrawFx);
     PutPixel(Index, Int(yPos) + 1.0, ModulateAlpha(MyColor, Frac(yPos)), DrawFx);

     yPos:= yPos + Grad;
     Alpha:= Alpha + AlphaInc;
    end;
  end else
  begin // vertical line
   if (DeltaY < 0.0) then
    begin
     Aux := Src;
     Src := Dest;
     Dest:= Aux;
     DeltaX:= -DeltaX;
     DeltaY:= -DeltaY;
    end;

   Grad:= DeltaX / DeltaY;

   // 1st point
   yEnd:= Int(Src.y + 0.5);
   xEnd:= Src.x + (yEnd - Src.y) * Grad;
   xPos:= xEnd + Grad;

   Point0:= Point2(Int(xEnd), Int(yEnd));

   // 2nd point
   yEnd:= Int(Dest.y + 0.5);
   xEnd:= Dest.x + (yEnd - Dest.y) * Grad;

   Point1:= Point2(Int(xEnd), Int(yEnd));

   Alpha:= 0.0;
   AlphaInc:= 255.0 / Abs(Int(Point1.y) - Int(Point0.y));
   for Index:= Trunc(Point0.y) to Trunc(Point1.y) do
    begin
     MyColor:= BlendPixels(Color1, Color0, Round(Alpha));
     PutPixel(Int(xPos), Index, ModulateAlpha(MyColor, 1.0 - Frac(xPos)), DrawFx);
     PutPixel(Int(xPos) + 1.0, Index, ModulateAlpha(MyColor, Frac(xPos)), DrawFx);

     xPos := xPos + Grad;
     Alpha:= Alpha + AlphaInc;
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.SmoothCircle(Xpos, Ypos, Radius: Real;
 Color: Cardinal; DrawFx: Cardinal);
const
 Pi2 = Pi * 2;

var
 w: Word;
 S: Single;
 x, y: Integer;
 Alpha, AlphaCol: Cardinal;
 xFloat, yFloat: Single;
begin
 Radius:= Abs(Radius);
 AlphaCol:= Color shr 24;
 Color:= Color and $FFFFFF;

 S:= Pi2 * Radius;
 W:= 0;

// Op:= Op or opSrcAlpha;

 while (w <= S) do
  begin
   xFloat:= Xpos + Radius * Cos(Pi2 * w / s);
   x:= Round(xFloat);

   yFloat:= Ypos - Radius * Sin(Pi2 * w / s);
   y:= Round(yFloat);

   Alpha:= 255 - Round(Sqrt(Sqr(x - xFloat) + Sqr(y - yFloat)) * 255);
   PutPixel(x, y, Color or (((AlphaCol * Alpha) div 256) shl 24), DrawFx);

   // draw four neighbor pixels to improve the quality of circle
   // [x - 1, y]
   Alpha:= 255 - Round(Sqrt(Sqr((x - 1) - xFloat) + Sqr(y - yFloat)) * 255);
   if (Alpha > 0)and(Alpha <= 255) then
    PutPixel(x - 1, y, Color or (((AlphaCol * Alpha) div 256) shl 24), DrawFx);

   // [x + 1, y]
   Alpha:= 255 - Round(Sqrt(Sqr((x + 1) - xFloat) + Sqr(y - yFloat)) * 255);
   if (Alpha > 0)and(Alpha <= 255) then
    PutPixel(x + 1, y, Color or (((AlphaCol * Alpha) div 256) shl 24), DrawFx);

   // [x, y - 1]
   Alpha:= 255 - Round(Sqrt(Sqr(x - xFloat) + Sqr((y - 1) - yFloat)) * 255);
   if (Alpha > 0)and(Alpha <= 255) then
    PutPixel(x, y - 1, Color or (((AlphaCol * Alpha) div 256) shl 24), DrawFx);

   // [x, y + 1]
   Alpha:= 255 - Round(Sqrt(Sqr(x - xFloat) + Sqr((y + 1) - yFloat)) * 255);
   if (Alpha > 0)and(Alpha <= 255) then
    PutPixel(x, y + 1, Color or (((AlphaCol * Alpha) div 256) shl 24), DrawFx);

   Inc(w);
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Draw(Image: TAsphyreImage; x, y: Real;
 Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pBounds4(x, y, Image.VisibleSize.X, Image.VisibleSize.Y),
  clWhite4, tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Draw(Image: TAsphyreImage; x, y, Scale: Real;
 Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pBounds4s(x, y, Image.VisibleSize.X, Image.VisibleSize.Y,
  Scale), clWhite4, tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.Draw(Image: TAsphyreImage; Rect: TRect;
 Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pRect4(Rect), clWhite4, tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; x, y: Real;
 Color: Cardinal; Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pBounds4(x, y, Image.VisibleSize.X, Image.VisibleSize.Y),
  cColor4(Color), tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; x, y, Scale: Real;
  Color: Cardinal; Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pBounds4s(x, y, Image.VisibleSize.X, Image.VisibleSize.Y,
  Scale), cColor4(Color), tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; Rect: TRect;
 Color: Cardinal; Pattern: Integer; DrawFx: Cardinal);
begin
 TexMap(Image, pRect4(Rect), cColor4(Color), tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DrawRot(Image: TAsphyreImage; x, y, Angle,
 Scale: Real; Color: Cardinal; Pattern: Integer; DrawFx: Cardinal);
var
 Pos   : TPoint2;
 Size  : TPoint2;
 Middle: TPoint2;
begin
 Pos   := Point2(x, y);
 Size  := Point2(Image.VisibleSize.x, Image.VisibleSize.y);
 Middle:= Point2(Size.x * 0.5, Size.y * 0.5);

 TexMap(Image, pRotate4(Pos, Size, Middle, Angle, Scale), cColor4(Color),
  tPattern(Pattern), DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.DrawRot(Image: TAsphyreImage; x, y, Angle,
 Scale: Real; Pattern: Integer; DrawFx: Cardinal);
begin
 DrawRot(Image, x, y, Angle, Scale, $FFFFFFFF, Pattern, DrawFx);
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillCircle(Xpos, Ypos, Radius: Integer;
 Color: Cardinal; DrawFx: Cardinal);
var
 i, j, Left, Top: Integer;
 Delta, MaxDelta: Real;
begin
 Left:= Xpos - Radius;
 Top := Ypos - Radius;
 MaxDelta:= Sqr(Radius);

 for j:= Top to Top + (Radius * 2) do
  for i:= Left to Left + (Radius * 2) do
   begin
    Delta:= Sqr(i - xPos) + Sqr(j - yPos);
    if (Delta < MaxDelta) then PutPixel(i, j, Color, DrawFx);
   end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreCanvas.FillCircle(Xpos, Ypos, Radius: Integer;
 const Colors: TColor4; DrawFx: Cardinal);
var
 i, j, Left, Top: Integer;
 Delta, MaxDelta: Real;
 Color, Color1, Color2, MyAlpha: Cardinal;
begin
 Left:= Xpos - Radius;
 Top := Ypos - Radius;
 MaxDelta:= Sqr(Radius);

 for j:= Top to Top + (Radius * 2) do
  begin
   MyAlpha:= ((j - Top) * 255) div (Radius * 2);
   Color1:= BlendPixels(Colors[3], Colors[0], MyAlpha);
   Color2:= BlendPixels(Colors[2], Colors[1], MyAlpha);
   for i:= Left to Left + (Radius * 2) do
    begin
     Color:= BlendPixels(Color2, Color1, ((i - Left) * 255) div (Radius * 2));
     Delta:= Sqr(i - xPos) + Sqr(j - yPos);
     if (Delta < MaxDelta) then PutPixel(i, j, Color, DrawFx);
    end;
  end;
end;

procedure TAsphyreCanvas.SetGamma(Red, Green, Blue, Brightness, Contrast: Byte);
var
  FGammaRamp: TD3DGammaRamp;
  k: Single;
  k2, i: Integer;
begin
  for i := 0 to 255 do
  begin
    FGammaRamp.Red[i] := i * (Red + 1);
    FGammaRamp.Green[i] := i * (Green + 1);
    FGammaRamp.Blue[i] := i * (Blue + 1);
  end;

  with FGammaRamp do
  begin
    k := (Contrast / 128) - 1;
    if (k < 1) then
      for i := 0 to 255 do
      begin
        if (Red[i] > 32767.5) then
          Red[i] := Min(Round(Red[i] + (Red[i] - 32767.5) * k), 65535)
        else Red[i] := Max(Round(Red[i] - (32767.5 - Red[i]) * k), 0);
        if (Green[i] > 32767.5) then
          Green[i] := Min(Round(Green[i] + (Green[i] - 32767.5) * k), 65535)
        else Green[i] := Max(Round(Green[i] - (32767.5 - Green[i]) * k), 0);
        if (Blue[i] > 32767.5) then
          Blue[i] := Min(Round(Blue[i] + (Blue[i] - 32767.5) * k), 65535)
        else Blue[i] := Max(Round(Blue[i] - (32767.5 - Blue[i]) * k), 0);
      end else
      for i := 0 to 255 do
      begin
        if (Red[i] > 32767.5) then
          Red[i] := Max(Round(Red[i] - (Red[i] - 32767.5) * k), 32768)
        else Red[i] := Min(Round(Red[i] + (32767.5 - Red[i]) * k), 32768);
        if (Green[i] > 32767.5) then
          Green[i] := Max(Round(Green[i] - (Green[i] - 32767.5) * k), 32768)
        else Green[i] := Min(Round(Green[i] + (32767.5 - Green[i]) * k), 32768);
        if (Blue[i] > 32767.5) then
          Blue[i] := Max(Round(Blue[i] - (Blue[i] - 32767.5) * k), 32768)
        else Blue[i] := Min(Round(Blue[i] + (32767.5 - Blue[i]) * k), 32768);
      end;

    k2 := Round(((Brightness / 128) - 1) * 65535);
    if (k2 < 0) then
      for i := 0 to 255 do
      begin
        Red[i] := Max(Red[i] + k2, 0);
        Green[i] := Max(Green[i] + k2, 0);
        Blue[i] := Max(Blue[i] + k2, 0);
      end
    else
      for i := 0 to 255 do
      begin
        Red[i] := Min(Red[i] + k2, 65535);
        Green[i] := Min(Green[i] + k2, 65535);
        Blue[i] := Min(Blue[i] + k2, 65535);
      end;
  end;

  Direct3DDevice.SetGammaRamp(0, D3DSGR_CALIBRATE, FGammaRamp);
end;

procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;

begin
  TexCoord.Pattern := PatternIndex;
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.h := 0;
  TexCoord.w := 0;


  case DoCenter of
    True:
      begin
        TexMap(Image, pBounds4sc2(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y, ScaleX, ScaleY),
          Color, TexCoord, DrawFx);
      end;
    False:
      begin
        if image<>nil then
           TexMap(Image, pBounds4s2(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y, ScaleX, ScaleY),
             Color, TexCoord, DrawFx);
        
      end;
  end;
end;

procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color: TColor4; DrawFx: Integer);
begin
  case DoCenter of
    True:
      begin
        TexMap(Image, pBounds4sc(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y, Scale),
          Color, tPattern(PatternIndex), DrawFx);
      end;
    False:
      begin
        TexMap(Image, pBounds4s(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y, Scale),
          Color, tPattern(PatternIndex), DrawFx);
      end;
  end;
end;

procedure TAsphyreCanvas.DrawEx(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pBounds4(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter, cRGB4(Red, Green, Blue, Alpha), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Red, Green, Blue, Alpha: Byte; DrawFx: Integer);
begin
  TexMap(Image, pBounds4(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y),
    cRGB4(Red, Green, Blue, Alpha), tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY,
    DoCenter, MirrorX, MirrorY, cAlpha4(Alpha), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter, cAlpha4(Alpha), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha1(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Alpha: Byte; DrawFx: Integer);
begin
  TexMap(Image, pBounds4(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y),
    cAlpha4(Alpha), tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Color1, Color2, Color3, Color4: Cardinal; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter,
    cColor4(Color1, Color2, Color3, Color4), DrawFx);
end;

procedure TAsphyreCanvas.DrawColor4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Color1, Color2, Color3, Color4: Byte; DrawFx: Integer);
begin
  TexMap(Image, pBounds4(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y),
    cColor4(Color1, Color2, Color3, Color4), tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, ScaleX, ScaleY, DoCenter,
    MirrorX, MirrorY, cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Scale: Real;
  DoCenter: Boolean; Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  DrawEx(Image, PatternIndex, X, Y, Scale, DoCenter,
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), DrawFx);
end;

procedure TAsphyreCanvas.DrawAlpha4(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  Alpha1, Alpha2, Alpha3, Alpha4: Byte; DrawFx: Integer);
begin
  TexMap(Image, pBounds4(X, Y, Image.VisibleSize.X, Image.VisibleSize.Y),
    cAlpha4(Alpha1, Alpha2, Alpha3, Alpha4), tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Pattern := PatternIndex;
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.h := 0;
  TexCoord.w := 0;

  TexMap(Image, pRect4(Rect(X1, Y1, X2, Y2)), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height,
  ScaleX, ScaleY: Real; DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Pattern := PatternIndex;
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.h := 0;
  TexCoord.w := 0;

  case DoCenter of
    True: TexMap(Image, pBounds4sc2(X, Y, Width, Height, ScaleX, ScaleY), Color, TexCoord, DrawFx);
    False: TexMap(Image, pBounds4s2(X, Y, Width, Height, ScaleX, ScaleY), Color, TexCoord, DrawFx);
  end;
end;

procedure TAsphyreCanvas.DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; ScaleX, ScaleY: Real;
  DoCenter, MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;

  case DoCenter of
    True: TexMap(Image, pBounds4sc2(X, Y, TexCoord.w, TexCoord.h, ScaleX, ScaleY),
        Color, TexCoord, DrawFx);

    False: TexMap(Image, pBounds4s2(X, Y, TexCoord.w, TexCoord.h, ScaleX, ScaleY),
        Color, TexCoord, DrawFx);
  end;
end;

procedure TAsphyreCanvas.DrawPortion(Image: TAsphyreImage; PatternIndex: Integer; X, Y: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := False;
  TexCoord.Flip := False;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, pBounds4(X, Y, TexCoord.w, TexCoord.h ), Color, TexCoord, DrawFx);

end;

procedure TAsphyreCanvas.DrawRectStretch(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2: Real;
  SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, pBounds4(X1, Y1, X2, Y2), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.w := 0;
  TexCoord.h := 0;
  TexMap(Image, Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRectTransForm(Image: TAsphyreImage; PatternIndex: Integer; X1, Y1, X2, Y2,
  X3, Y3, X4, Y4: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, Point4(X1, Y1, X2, Y2, X3, Y3, X4, Y4), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle: Real;
  Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4c(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y), Angle),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4c2(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y), Angle, ScaleX, ScaleY),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateC(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.w := 0;
  TexCoord.h := 0;

  TexMap(Image, pRotate4c2(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y), Angle, ScaleX, ScaleY),
    Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y),
    Point2(CenterX, CenterY), Angle), Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate42(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotate(Image: TAsphyreImage; PatternIndex: Integer; X, Y, CenterX, CenterY,
  Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.w := 0;
  TexCoord.h := 0;

  TexMap(Image, pRotate42(Point2(X, Y), Point2(Image.VisibleSize.X, Image.VisibleSize.Y), Point2(CenterX, CenterY),
    Angle, ScaleX, ScaleY), Color, texCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4c(Point2(X, Y), Point2(Width, Height), Angle),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretchC(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.w := 0;
  TexCoord.h := 0;

  TexMap(Image, pRotate4c2(Point2(X, Y), Point2(Width, Height), Angle, ScaleX, ScaleY),
    Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate4(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle),
    Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; Color: TColor4; DrawFx: Integer);
begin
  TexMap(Image, pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color, tPattern(PatternIndex), DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateStretch(Image: TAsphyreImage; PatternIndex: Integer; X, Y,
  Width, Height, CenterX, CenterY, Angle, ScaleX, ScaleY: Real; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := 0;
  TexCoord.y := 0;
  TexCoord.w := 0;
  TexCoord.h := 0;
  TexMap(Image, pRotate42(Point2(X, Y), Point2(Width, Height), Point2(CenterX, CenterY), Angle,
    ScaleX, ScaleY), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer; MirrorX, MirrorY: Boolean;
  Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, pRotate4c2(Point2(X, Y), Point2(TexCoord.w, TexCoord.h), Angle,
    ScaleX, ScaleY), Color, TexCoord, DrawFx);
end;

procedure TAsphyreCanvas.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, pRotate42(Point2(X, Y), Point2(TexCoord.w, TexCoord.h),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, TexCoord, DrawFx);

end;

procedure TAsphyreCanvas.DrawRotateRect(Image: TAsphyreImage; PatternIndex: Integer; X, Y, Width, Height, Angle,
  CenterX, CenterY, ScaleX, ScaleY: Real; SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  MirrorX, MirrorY: Boolean; Color: TColor4; DrawFx: Integer);
var
  TexCoord: TTexCoord;
begin
  TexCoord.Mirror := MirrorX;
  TexCoord.Flip := MirrorY;
  TexCoord.Pattern := PatternIndex;
  TexCoord.x := SrcX1;
  TexCoord.y := SrcY1;
  TexCoord.w := SrcX2-SrcX1;
  TexCoord.h := SrcY2-SrcY1;
  TexMap(Image, pRotate42(Point2(X, Y), Point2(Width, Height),
    Point2(CenterX, CenterY), Angle, ScaleX, ScaleY), Color, TexCoord, DrawFx);
end;



//---------------------------------------------------------------------------
end.

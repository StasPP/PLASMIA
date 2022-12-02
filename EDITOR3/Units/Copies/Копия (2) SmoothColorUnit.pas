//------------------------------------------------------------------------------
// SmoothColorUnit.pas
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

unit SmoothColorUnit;

interface

uses AsphyreDef;

//------------------------------------------------------------------------------
type
  PSmoothColor = ^TSmoothColor;
  TSmoothColor = record
    A, R, G, B: Single;

    class operator Implicit(Value: Single): TSmoothColor; inline;
    class operator Add(const a, b: TSmoothColor): TSmoothColor; inline;
    class operator Subtract(const a, b: TSmoothColor): TSmoothColor; inline;
    class operator Multiply(const a, b: TSmoothColor): TSmoothColor; inline;
    class operator Equal(const a, b: TSmoothColor): Boolean; inline;
  end;

//------------------------------------------------------------------------------
  PSmoothColor4 = ^TSmoothColor4;
  TSmoothColor4 = array[0..3] of TSmoothColor;

//------------------------------------------------------------------------------
const
  MIN_SM_COLOR = 0.0;
  MAX_SM_COLOR = 255.0;

  smClear: TSmoothColor = (A: 0.0; R: 0.0; G: 0.0; B: 0.0);
  smBlack: TSmoothColor = (A: MAX_SM_COLOR; R: 0.0; G: 0.0; B: 0.0);
  smWhite: TSmoothColor = (A: MAX_SM_COLOR; R: MAX_SM_COLOR; G: MAX_SM_COLOR; B: MAX_SM_COLOR);

  // Smooth4
  smClear4: TSmoothColor4 = (
    (A: 0.0; R: 0.0; G: 0.0; B: 0.0),
    (A: 0.0; R: 0.0; G: 0.0; B: 0.0),
    (A: 0.0; R: 0.0; G: 0.0; B: 0.0),
    (A: 0.0; R: 0.0; G: 0.0; B: 0.0)
    );

//------------------------------------------------------------------------------
function ToSmoothColor(Color: Cardinal): TSmoothColor;
function FromSmoothColor(const Color: TSmoothColor): Cardinal;
function SmoothRGBA(A, R, G, B: Single; Norm: boolean): TSmoothColor;
function NormSmoothColor(const Color: TSmoothColor): TSmoothColor;
function SmoothColorDelta(const SmColor: TSmoothColor; Color: Cardinal; Time: Single): TSmoothColor;
function ColorDelta(ColorStart, ColorEnd: Cardinal; Time: Single): TSmoothColor;

// for Delphi 2005 and lower versions
{function MultSmColor(const a: TSmoothColor; const b: Real): TSmoothColor;
function AddSmColors(const a, b: TSmoothColor): TSmoothColor;
function MultSmColors(const a, b: TSmoothColor): TSmoothColor;
}

//------------------------------------------------------------------------------
// Smooth 4
function Smooth4(const SmColor: TSmoothColor): TSmoothColor4;
function Color4ToSmooth4(const Color4: TColor4): TSmoothColor4;
function Smooth4ToColor4(const Smooth4: TSmoothColor4): TColor4;

//------------------------------------------------------------------------------

implementation

//------------------------------------------------------------------------------
function NormSmoothColor(const Color: TSmoothColor): TSmoothColor;
begin
  Result := Color;

  if (Result.R < MIN_SM_COLOR) then
    Result.R := MIN_SM_COLOR
  else
    if (Result.R > MAX_SM_COLOR) then Result.R := MAX_SM_COLOR;

  if (Result.G < MIN_SM_COLOR) then
    Result.G := MIN_SM_COLOR
  else
    if (Result.G > MAX_SM_COLOR) then Result.G := MAX_SM_COLOR;

  if (Result.B < MIN_SM_COLOR) then
    Result.B := MIN_SM_COLOR
  else
    if (Result.B > MAX_SM_COLOR) then Result.B := MAX_SM_COLOR;

  if (Result.A < MIN_SM_COLOR) then
    Result.A := MIN_SM_COLOR
  else
    if (Result.A > MAX_SM_COLOR) then
      Result.A := MAX_SM_COLOR - 1; // Perfomance
end;

//------------------------------------------------------------------------------
function ToSmoothColor(Color: Cardinal): TSmoothColor;
begin
  Result.A := (Color shr 24) and $FF;
  Result.R := (Color shr 16) and $FF;
  Result.G := (Color shr 8) and $FF;
  Result.B := Color and $FF;
end;

//------------------------------------------------------------------------------
function FromSmoothColor(const Color: TSmoothColor): Cardinal;
begin
  Result :=
    ((Round(Color.A) and $FF) shl 24) or
    ((Round(Color.R) and $FF) shl 16) or
    ((Round(Color.G) and $FF) shl 8) or
    (Round(Color.B) and $FF);
  {Result :=
    ((Round(Color.A) and $FF) shl 24) or
    ((Round(Color.B) and $FF) shl 16) or  // <<---R
    ((Round(Color.G) and $FF) shl 8) or   //      |
    (Round(Color.R) and $FF);             // <<---B
  }
end;

//------------------------------------------------------------------------------
function SmoothRGBA(A, R, G, B: Single; Norm: boolean):
  TSmoothColor;
begin
  Result.A := A;
  Result.R := R;
  Result.G := G;
  Result.B := B;
  if (Norm) then Result := NormSmoothColor(Result);
end;

//------------------------------------------------------------------------------
// SmoothColor4
//------------------------------------------------------------------------------
function Smooth4(const SmColor: TSmoothColor): TSmoothColor4;
begin
  Result[0] := SmColor;
  Result[1] := SmColor;
  Result[2] := SmColor;
  Result[3] := SmColor;
end;

//------------------------------------------------------------------------------
function Color4ToSmooth4(const Color4: TColor4): TSmoothColor4;
begin
  Result[0] := ToSmoothColor(Color4[0]);
  Result[1] := ToSmoothColor(Color4[1]);
  Result[2] := ToSmoothColor(Color4[2]);
  Result[3] := ToSmoothColor(Color4[3]);
end;

//------------------------------------------------------------------------------
function Smooth4ToColor4(const Smooth4: TSmoothColor4): TColor4;
begin
  Result[0] := FromSmoothColor(Smooth4[0]);
  Result[1] := FromSmoothColor(Smooth4[1]);
  Result[2] := FromSmoothColor(Smooth4[2]);
  Result[3] := FromSmoothColor(Smooth4[3]);
end;

//------------------------------------------------------------------------------
function SmoothColorDelta(const SmColor: TSmoothColor; Color: Cardinal; Time: Single): TSmoothColor;
begin
  Result := SmoothRGBA(
    ((Color shr 24) and $FF - SmColor.A) / Time,
    ((Color shr 16) and $FF - SmColor.R) / Time,
    ((Color shr 8) and $FF - SmColor.G) / Time,
    (Color and $FF - SmColor.B) / Time,
    false);
end;

//------------------------------------------------------------------------------
function ColorDelta(ColorStart, ColorEnd: Cardinal; Time: Single): TSmoothColor;
var
  A, R, G, B: Integer;
begin
  A := ((ColorEnd shr 24) and $FF) - ((ColorStart shr 24) and $FF);
  R := ((ColorEnd shr 16) and $FF) - ((ColorStart shr 16) and $FF);
  G := ((ColorEnd shr 8) and $FF)  - ((ColorStart shr 8) and $FF);
  B := (ColorEnd and $FF) - (ColorStart and $FF);
  
  Result := SmoothRGBA(A / Time, R / Time, G / Time, B / Time, false);
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TSmoothColor operations
//------------------------------------------------------------------------------
{function MultSmColor(const a: TSmoothColor; const b: Real): TSmoothColor;
begin
  Result.R := a.R * b;
  Result.G := a.G * b;
  Result.B := a.B * b;
  Result.A := a.A * b;
end;

//------------------------------------------------------------------------------
function AddSmColors(const a, b: TSmoothColor): TSmoothColor;
begin
  Result.R := a.R + b.R;
  Result.G := a.G + b.G;
  Result.B := a.B + b.B;
  Result.A := a.A + b.A;
  //Result:= NormSmoothColor(Result);
end;

//------------------------------------------------------------------------------
function MultSmColors(const a, b: TSmoothColor): TSmoothColor;
begin
  Result.R := a.R * b.R;
  Result.G := a.G * b.G;
  Result.B := a.B * b.B;
  Result.A := a.A * b.A;
  //Result:= NormSmoothColor(Result);
end;
}
//------------------------------------------------------------------------------
class operator TSmoothColor.Implicit(Value: Single): TSmoothColor;
begin
  Result.A := Value;
  Result.R := Value;
  Result.G := Value;
  Result.B := Value;
end;

//------------------------------------------------------------------------------
class operator TSmoothColor.Add(const a, b: TSmoothColor): TSmoothColor;
begin
  Result.A := a.A + b.A;
  Result.R := a.R + b.R;
  Result.G := a.G + b.G;
  Result.B := a.B + b.B;
end;

//------------------------------------------------------------------------------
class operator TSmoothColor.Subtract(const a, b: TSmoothColor): TSmoothColor;
begin
  Result.A := a.A - b.A;
  Result.R := a.R - b.R;
  Result.G := a.G - b.G;
  Result.B := a.B - b.B;
end;

//------------------------------------------------------------------------------
class operator TSmoothColor.Multiply(const a, b: TSmoothColor): TSmoothColor;
begin
  Result.A := a.A * b.A;
  Result.R := a.R * b.R;
  Result.G := a.G * b.G;
  Result.B := a.B * b.B;
end;

//------------------------------------------------------------------------------
class operator TSmoothColor.Equal(const a, b: TSmoothColor): Boolean;
begin
  Result := (a.A = b.A)and(a.R = b.R)and(a.G = b.G)and(a.B = b.B);
end;
                                 
//------------------------------------------------------------------------------
end.


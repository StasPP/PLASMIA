unit SinCosFunctions;
//---------------------------------------------------------------------------
// SinCosFunctions.pas                                  Modified:  9-Apr-2006
// Gurroa                                                        Version 0.10
//---------------------------------------------------------------------------
// Changes since v0.00:
//  + overload to sin() and cos() system function to take data from array
//    created in SinCosTables.pas
//---------------------------------------------------------------------------
// This unit depends on AfterWarp asphyre package
// http://www.afterwarp.net
//---------------------------------------------------------------------------
interface
(* sin cos tables
//{$DEFINE SINCOS_INTPREC}
//{$DEFINE SINCOS_DECPREC}
//{$DEFINE SINCOS_KILPREC}
(* *)

{$IFDEF SINCOS_INTPREC}
function sin(angle: Real): Real;
function cos(angle: Real): Real;
{$ENDIF}

{$IFDEF SINCOS_DECPREC}
function sin(angle: Real): Real;
function cos(angle: Real): Real;
{$ENDIF}

{$IFDEF SINCOS_KILPREC}
function sin(angle: Real): Real;
function cos(angle: Real): Real;
{$ENDIF}

const
  rRad = 180/Pi;
  rRad10 = 1800/Pi;
  rRad100 = 18000/Pi;

implementation

uses
  SinCosTables;

{$IFDEF SINCOS_INTPREC}
function sin(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad);
  if i < 0 then
  begin
    while i < -360 do
      inc(i, 360);
    i := 360+i;
  end else
    while i > 360 do
      dec(i, 360);
  Result := SinInt[i];
end;

function cos(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad);
  if i < 0 then
  begin
    while i < -360 do
      inc(i, 360);
    i := 360+i;
  end else
    while i > 360 do
      dec(i, 360);
  Result := CosInt[i];
end;
{$ENDIF}

{$IFDEF SINCOS_DECPREC}
function sin(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad10);
  if i < 0 then
  begin
    while i < -3600 do
      inc(i, 3600);
    i := 3600+i;
  end else
    while i > 3600 do
      dec(i, 3600);
  Result := SinDec[i];
end;

function cos(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad10);
  if i < 0 then
  begin
    while i < -3600 do
      inc(i, 3600);
    i := 3600+i;
  end else
    while i > 3600 do
      dec(i, 3600);
  Result := CosDec[i];
end;
{$ENDIF}

{$IFDEF SINCOS_KILPREC}
function sin(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad100);
  if i < 0 then
  begin
    while i < -36000 do
      inc(i, 36000);
    i := 36000+i;
  end else
    while i > 36000 do
      dec(i, 36000);
  Result := SinKil[i];
end;

function cos(angle: Real): Real;
var i: integer;
begin
  i := Round(angle*rRad100);
  if i < 0 then
  begin
    while i < -36000 do
      inc(i, 36000);
    i := 36000+i;
  end else
    while i > 36000 do
      dec(i, 36000);
  Result := CosKil[i];
end;
{$ENDIF}

end.


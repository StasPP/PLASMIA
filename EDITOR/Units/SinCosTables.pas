unit SinCosTables;
//---------------------------------------------------------------------------
// SinCosTables.pas                                     Modified:  9-Apr-2006
// Gurroa                                                        Version 0.10
//---------------------------------------------------------------------------
// Changes since v0.00:
//  + creates sin and cos tables - depend on DEFINING one of possibilities
//---------------------------------------------------------------------------
interface
(*
//{$DEFINE SINCOS_INTPREC}
//{$DEFINE SINCOS_DECPREC}
//{$DEFINE SINCOS_KILPREC}
(* *)

{$IFDEF SINCOS_INTPREC}
var
  SinInt: array[0..359] of Real;
  CosInt: array[0..359] of Real;
{$ENDIF}

{$IFDEF SINCOS_DECPREC}
var
  SinDec: array[0..3599] of Real;
  CosDec: array[0..3599] of Real;
{$ENDIF}

{$IFDEF SINCOS_KILPREC}
var
  SinKil: array[0..35999] of Real;
  CosKil: array[0..35999] of Real;
{$ENDIF}

implementation

{$IFDEF SINCOS_INTPREC}
procedure InitSicCos_Int();
var i: integer;
  rad, rd: Real;
begin
  rad := Pi/180;
  for i := 0 to 359 do
  begin
    rd := rad * i;
    SinInt[i] := sin(rd);
    CosInt[i] := cos(rd);
  end;
end;
{$ENDIF}

{$IFDEF SINCOS_DECPREC}
procedure InitSicCos_Dec();
var i: integer;
  rad, rd: Real;
begin
  rad := Pi/1800;
  for i := 0 to 3599 do
  begin
    rd := rad * i;
    SinDec[i] := sin(rd);
    CosDec[i] := cos(rd);
  end;
end;
{$ENDIF}

{$IFDEF SINCOS_KILPREC}
procedure InitSicCos_Kil();
var i: integer;
  rad, rd: Real;
begin              
  rad := Pi/18000;
  for i := 0 to 35999 do
  begin
    rd := rad * i;
    SinKil[i] := sin(rd);
    CosKil[i] := cos(rd);
  end;
end;
{$ENDIF}

initialization

{$IFDEF SINCOS_INTPREC}
  InitSicCos_Int();
{$ENDIF}
{$IFDEF SINCOS_DECPREC}
  InitSicCos_Dec();
{$ENDIF}
{$IFDEF SINCOS_KILPREC}
  InitSicCos_Kil();
{$ENDIF}
end.

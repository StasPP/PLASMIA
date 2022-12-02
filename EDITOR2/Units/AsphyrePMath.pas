unit AsphyrePMath;
//---------------------------------------------------------------------------
// AsphyrePMath.pas                                     Modified:  9-Apr-2006
// Gurroa                                                        Version 0.50
//---------------------------------------------------------------------------
// Changes since v0.00:
//  + alternates most of AsphyreMath Matrix4 functions to pointers
//---------------------------------------------------------------------------
// This unit depends on AfterWarp asphyre package
// http://www.afterwarp.net
//---------------------------------------------------------------------------
interface
uses
 SinCosFunctions, {}Windows,{Types, {}Classes, SysUtils, Math, AsphyreDef, AsphyreMath;

type
 PPoint3  = ^TPoint3;

var
 BufMtx: TMatrix4 = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0),
  (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0));

// Move IdentityMatrix's data into PMtx
procedure SetIdentityMatrix(PMtx: PMatrix4);

// Move data from Source to Dest
procedure PCopyMtx(Source, Dest: PMatrix4);

// multiplying two matrices
procedure PMatMul(Result, b: PMatrix4);
// multiplying Result PMatrix with BufMatrix
procedure PBufMatMul(Result: PMatrix4);
procedure PRMatMul(Result: PMatrix4; a, b: PMatrix4);

// multiplying a vector and a matrix
procedure PMatVecMul(Result: PVector4; const v: TVector4; const m: TMatrix4);

// rotating about the x-axis in 3D
procedure PBufMatRotateX(Angle: Real);
procedure PMatRotateX(Result: PMatrix4;Angle: Real);

// rotating about the y-axis in 3D
procedure PBufMatRotateY(Angle: Real);
procedure PMatRotateY(Result: PMatrix4;Angle: Real);

// rotating about the z-axis in 3D
procedure PBufMatRotateZ(Angle: Real);
procedure PMatRotateZ(Result: PMatrix4;Angle: Real);

// translation matrix
procedure PBufMatTransl(const n: PVector4);
procedure PMatTransl(Result: PMatrix4; const n: TVector4);

// rotating about an arbitrary axis in 3D
procedure PMatMulRotate(Result: PMatrix4; const n: TVector4;const Theta: Real);
procedure PMatRotate(Result: PMatrix4; const n: TVector4;const Theta: Real);

// scaling along cardinal axes
procedure PBufMatScale(const k: TVector4);
procedure PMatScale(Result: PMatrix4; const k: TVector4);

// Magnitudes vector
function Vec3Magnitude(const v: TPoint3; mag: double): TPoint3;

implementation

var
 InnerBufMtx: TMatrix4 = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0),
  (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0));
 IdentityMatrixForPIdentity: TMatrix4 = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0),
  (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0));
const
 Pi2 = Pi*2;

procedure SetIdentityMatrix(PMtx: PMatrix4);
begin
  PMtx^ := IdentityMatrixForPIdentity;
end;

procedure PCopyMtx(Source, Dest: PMatrix4);
begin
  Dest^ := Source^;
  //Move(Source^, Dest^, 64);
end;

procedure PMatMul(Result, b: PMatrix4);
begin
  InnerBufMtx[0, 0] := (Result[0, 0] * b[0, 0]) + (Result[0, 1] * b[1, 0]) + (Result[0, 2] * b[2, 0]) + (Result[0, 3] * b[3, 0]);
  InnerBufMtx[0, 1] := (Result[0, 0] * b[0, 1]) + (Result[0, 1] * b[1, 1]) + (Result[0, 2] * b[2, 1]) + (Result[0, 3] * b[3, 1]);
  InnerBufMtx[0, 2] := (Result[0, 0] * b[0, 2]) + (Result[0, 1] * b[1, 2]) + (Result[0, 2] * b[2, 2]) + (Result[0, 3] * b[3, 2]);
  InnerBufMtx[0, 3] := (Result[0, 0] * b[0, 3]) + (Result[0, 1] * b[1, 3]) + (Result[0, 2] * b[2, 3]) + (Result[0, 3] * b[3, 3]);
  InnerBufMtx[1, 0] := (Result[1, 0] * b[0, 0]) + (Result[1, 1] * b[1, 0]) + (Result[1, 2] * b[2, 0]) + (Result[1, 3] * b[3, 0]);
  InnerBufMtx[1, 1] := (Result[1, 0] * b[0, 1]) + (Result[1, 1] * b[1, 1]) + (Result[1, 2] * b[2, 1]) + (Result[1, 3] * b[3, 1]);
  InnerBufMtx[1, 2] := (Result[1, 0] * b[0, 2]) + (Result[1, 1] * b[1, 2]) + (Result[1, 2] * b[2, 2]) + (Result[1, 3] * b[3, 2]);
  InnerBufMtx[1, 3] := (Result[1, 0] * b[0, 3]) + (Result[1, 1] * b[1, 3]) + (Result[1, 2] * b[2, 3]) + (Result[1, 3] * b[3, 3]);
  InnerBufMtx[2, 0] := (Result[2, 0] * b[0, 0]) + (Result[2, 1] * b[1, 0]) + (Result[2, 2] * b[2, 0]) + (Result[2, 3] * b[3, 0]);
  InnerBufMtx[2, 1] := (Result[2, 0] * b[0, 1]) + (Result[2, 1] * b[1, 1]) + (Result[2, 2] * b[2, 1]) + (Result[2, 3] * b[3, 1]);
  InnerBufMtx[2, 2] := (Result[2, 0] * b[0, 2]) + (Result[2, 1] * b[1, 2]) + (Result[2, 2] * b[2, 2]) + (Result[2, 3] * b[3, 2]);
  InnerBufMtx[2, 3] := (Result[2, 0] * b[0, 3]) + (Result[2, 1] * b[1, 3]) + (Result[2, 2] * b[2, 3]) + (Result[2, 3] * b[3, 3]);
  InnerBufMtx[3, 0] := (Result[3, 0] * b[0, 0]) + (Result[3, 1] * b[1, 0]) + (Result[3, 2] * b[2, 0]) + (Result[3, 3] * b[3, 0]);
  InnerBufMtx[3, 1] := (Result[3, 0] * b[0, 1]) + (Result[3, 1] * b[1, 1]) + (Result[3, 2] * b[2, 1]) + (Result[3, 3] * b[3, 1]);
  InnerBufMtx[3, 2] := (Result[3, 0] * b[0, 2]) + (Result[3, 1] * b[1, 2]) + (Result[3, 2] * b[2, 2]) + (Result[3, 3] * b[3, 2]);
  InnerBufMtx[3, 3] := (Result[3, 0] * b[0, 3]) + (Result[3, 1] * b[1, 3]) + (Result[3, 2] * b[2, 3]) + (Result[3, 3] * b[3, 3]);

  Result^ := InnerBufMtx;
end;

procedure PBufMatMul(Result: PMatrix4);
begin
  InnerBufMtx[0, 0] := (Result[0, 0] * BufMtx[0, 0]) + (Result[0, 1] * BufMtx[1, 0]) + (Result[0, 2] * BufMtx[2, 0]) + (Result[0, 3] * BufMtx[3, 0]);
  InnerBufMtx[0, 1] := (Result[0, 0] * BufMtx[0, 1]) + (Result[0, 1] * BufMtx[1, 1]) + (Result[0, 2] * BufMtx[2, 1]) + (Result[0, 3] * BufMtx[3, 1]);
  InnerBufMtx[0, 2] := (Result[0, 0] * BufMtx[0, 2]) + (Result[0, 1] * BufMtx[1, 2]) + (Result[0, 2] * BufMtx[2, 2]) + (Result[0, 3] * BufMtx[3, 2]);
  InnerBufMtx[0, 3] := (Result[0, 0] * BufMtx[0, 3]) + (Result[0, 1] * BufMtx[1, 3]) + (Result[0, 2] * BufMtx[2, 3]) + (Result[0, 3] * BufMtx[3, 3]);
  InnerBufMtx[1, 0] := (Result[1, 0] * BufMtx[0, 0]) + (Result[1, 1] * BufMtx[1, 0]) + (Result[1, 2] * BufMtx[2, 0]) + (Result[1, 3] * BufMtx[3, 0]);
  InnerBufMtx[1, 1] := (Result[1, 0] * BufMtx[0, 1]) + (Result[1, 1] * BufMtx[1, 1]) + (Result[1, 2] * BufMtx[2, 1]) + (Result[1, 3] * BufMtx[3, 1]);
  InnerBufMtx[1, 2] := (Result[1, 0] * BufMtx[0, 2]) + (Result[1, 1] * BufMtx[1, 2]) + (Result[1, 2] * BufMtx[2, 2]) + (Result[1, 3] * BufMtx[3, 2]);
  InnerBufMtx[1, 3] := (Result[1, 0] * BufMtx[0, 3]) + (Result[1, 1] * BufMtx[1, 3]) + (Result[1, 2] * BufMtx[2, 3]) + (Result[1, 3] * BufMtx[3, 3]);
  InnerBufMtx[2, 0] := (Result[2, 0] * BufMtx[0, 0]) + (Result[2, 1] * BufMtx[1, 0]) + (Result[2, 2] * BufMtx[2, 0]) + (Result[2, 3] * BufMtx[3, 0]);
  InnerBufMtx[2, 1] := (Result[2, 0] * BufMtx[0, 1]) + (Result[2, 1] * BufMtx[1, 1]) + (Result[2, 2] * BufMtx[2, 1]) + (Result[2, 3] * BufMtx[3, 1]);
  InnerBufMtx[2, 2] := (Result[2, 0] * BufMtx[0, 2]) + (Result[2, 1] * BufMtx[1, 2]) + (Result[2, 2] * BufMtx[2, 2]) + (Result[2, 3] * BufMtx[3, 2]);
  InnerBufMtx[2, 3] := (Result[2, 0] * BufMtx[0, 3]) + (Result[2, 1] * BufMtx[1, 3]) + (Result[2, 2] * BufMtx[2, 3]) + (Result[2, 3] * BufMtx[3, 3]);
  InnerBufMtx[3, 0] := (Result[3, 0] * BufMtx[0, 0]) + (Result[3, 1] * BufMtx[1, 0]) + (Result[3, 2] * BufMtx[2, 0]) + (Result[3, 3] * BufMtx[3, 0]);
  InnerBufMtx[3, 1] := (Result[3, 0] * BufMtx[0, 1]) + (Result[3, 1] * BufMtx[1, 1]) + (Result[3, 2] * BufMtx[2, 1]) + (Result[3, 3] * BufMtx[3, 1]);
  InnerBufMtx[3, 2] := (Result[3, 0] * BufMtx[0, 2]) + (Result[3, 1] * BufMtx[1, 2]) + (Result[3, 2] * BufMtx[2, 2]) + (Result[3, 3] * BufMtx[3, 2]);
  InnerBufMtx[3, 3] := (Result[3, 0] * BufMtx[0, 3]) + (Result[3, 1] * BufMtx[1, 3]) + (Result[3, 2] * BufMtx[2, 3]) + (Result[3, 3] * BufMtx[3, 3]);

  Result^ := InnerBufMtx;
end;


procedure PRMatMul(Result: PMatrix4; a, b: PMatrix4);
begin
  Result[0, 0] := (a[0, 0] * b[0, 0]) + (a[0, 1] * b[1, 0]) + (a[0, 2] * b[2, 0]) + (a[0, 3] * b[3, 0]);
  Result[0, 1] := (a[0, 0] * b[0, 1]) + (a[0, 1] * b[1, 1]) + (a[0, 2] * b[2, 1]) + (a[0, 3] * b[3, 1]);
  Result[0, 2] := (a[0, 0] * b[0, 2]) + (a[0, 1] * b[1, 2]) + (a[0, 2] * b[2, 2]) + (a[0, 3] * b[3, 2]);
  Result[0, 3] := (a[0, 0] * b[0, 3]) + (a[0, 1] * b[1, 3]) + (a[0, 2] * b[2, 3]) + (a[0, 3] * b[3, 3]);
  Result[1, 0] := (a[1, 0] * b[0, 0]) + (a[1, 1] * b[1, 0]) + (a[1, 2] * b[2, 0]) + (a[1, 3] * b[3, 0]);
  Result[1, 1] := (a[1, 0] * b[0, 1]) + (a[1, 1] * b[1, 1]) + (a[1, 2] * b[2, 1]) + (a[1, 3] * b[3, 1]);
  Result[1, 2] := (a[1, 0] * b[0, 2]) + (a[1, 1] * b[1, 2]) + (a[1, 2] * b[2, 2]) + (a[1, 3] * b[3, 2]);
  Result[1, 3] := (a[1, 0] * b[0, 3]) + (a[1, 1] * b[1, 3]) + (a[1, 2] * b[2, 3]) + (a[1, 3] * b[3, 3]);
  Result[2, 0] := (a[2, 0] * b[0, 0]) + (a[2, 1] * b[1, 0]) + (a[2, 2] * b[2, 0]) + (a[2, 3] * b[3, 0]);
  Result[2, 1] := (a[2, 0] * b[0, 1]) + (a[2, 1] * b[1, 1]) + (a[2, 2] * b[2, 1]) + (a[2, 3] * b[3, 1]);
  Result[2, 2] := (a[2, 0] * b[0, 2]) + (a[2, 1] * b[1, 2]) + (a[2, 2] * b[2, 2]) + (a[2, 3] * b[3, 2]);
  Result[2, 3] := (a[2, 0] * b[0, 3]) + (a[2, 1] * b[1, 3]) + (a[2, 2] * b[2, 3]) + (a[2, 3] * b[3, 3]);
  Result[3, 0] := (a[3, 0] * b[0, 0]) + (a[3, 1] * b[1, 0]) + (a[3, 2] * b[2, 0]) + (a[3, 3] * b[3, 0]);
  Result[3, 1] := (a[3, 0] * b[0, 1]) + (a[3, 1] * b[1, 1]) + (a[3, 2] * b[2, 1]) + (a[3, 3] * b[3, 1]);
  Result[3, 2] := (a[3, 0] * b[0, 2]) + (a[3, 1] * b[1, 2]) + (a[3, 2] * b[2, 2]) + (a[3, 3] * b[3, 2]);
  Result[3, 3] := (a[3, 0] * b[0, 3]) + (a[3, 1] * b[1, 3]) + (a[3, 2] * b[2, 3]) + (a[3, 3] * b[3, 3]);
end;

procedure PMatVecMul(Result: PVector4; const v: TVector4; const m: TMatrix4);
begin
 Result.x:= (v.x * m[0, 0]) + (v.y * m[1, 0]) + (v.z * m[2, 0]) + (v.w * m[3, 0]);
 Result.y:= (v.x * m[0, 1]) + (v.y * m[1, 1]) + (v.z * m[2, 1]) + (v.w * m[3, 1]);
 Result.z:= (v.x * m[0, 2]) + (v.y * m[1, 2]) + (v.z * m[2, 2]) + (v.w * m[3, 2]);
 Result.w:= (v.x * m[0, 3]) + (v.y * m[1, 3]) + (v.z * m[2, 3]) + (v.w * m[3, 3]);
end;

// rotating about the x-axis in 3D
procedure PMatRotateX(Result: PMatrix4;Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@InnerBufMtx);
  InnerBufMtx[1, 1]:= c;
  InnerBufMtx[1, 2]:= s;
  InnerBufMtx[2, 1]:= -s;
  InnerBufMtx[2, 2]:= c;

  Result^ := InnerBufMtx;
end;

procedure PBufMatRotateX(Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@BufMtx);
  BufMtx[1, 1]:= c;
  BufMtx[1, 2]:= s;
  BufMtx[2, 1]:= -s;
  BufMtx[2, 2]:= c;
end;

// rotating about the y-axis in 3D
procedure PMatRotateY(Result: PMatrix4;Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@InnerBufMtx);
  InnerBufMtx[0, 0]:= c;
  InnerBufMtx[0, 2]:= -s;
  InnerBufMtx[2, 0]:= s;
  InnerBufMtx[2, 2]:= c;

  Result^ := InnerBufMtx;
end;

procedure PBufMatRotateY(Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@BufMtx);
  BufMtx[0, 0]:= c;
  BufMtx[0, 2]:= -s;
  BufMtx[2, 0]:= s;
  BufMtx[2, 2]:= c;
end;

// rotating about the z-axis in 3D
procedure PMatRotateZ(Result: PMatrix4;Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@InnerBufMtx);
  InnerBufMtx[0, 0]:= c;
  InnerBufMtx[0, 1]:= s;
  InnerBufMtx[1, 0]:= -s;
  InnerBufMtx[1, 1]:= c;

  Result^ := InnerBufMtx;
end;

procedure PBufMatRotateZ(Angle: Real);
var c, s: Real;
begin
  s := sin(Angle);
  c := cos(Angle);
  SetIdentityMatrix(@BufMtx);
  BufMtx[0, 0]:= c;
  BufMtx[0, 1]:= s;
  BufMtx[1, 0]:= -s;
  BufMtx[1, 1]:= c;
end;

// translation matrix
procedure PMatTransl(Result: PMatrix4; const n: TVector4);
begin
  SetIdentityMatrix(@InnerBufMtx);
  InnerBufMtx[3, 0]:= n.x;
  InnerBufMtx[3, 1]:= n.y;
  InnerBufMtx[3, 2]:= n.z;

  Result^ := InnerBufMtx;
end;

procedure PBufMatTransl(const n: PVector4);
begin
  SetIdentityMatrix(@BufMtx);
  BufMtx[3, 0]:= n.x;
  BufMtx[3, 1]:= n.y;
  BufMtx[3, 2]:= n.z;
end;

// rotating about an arbitrary axis in 3D
procedure PMatMulRotate(Result: PMatrix4; const n: TVector4;const Theta: Real);
var
  CosTh, iCosTh, SinTh: Real;
  xy, xz, yz, xSin, ySin, zSin: Real;
begin
  CosTh := Cos(Theta);
  iCosTh:= 1.0 - CosTh;
  SinTh := Sin(Theta);
  xy    := n.x * n.y * iCosTh;
  xz    := n.x * n.z * iCosTh;
  yz    := n.y * n.z * iCosTh;
  xSin  := n.x * SinTh;
  ySin  := n.y * SinTh;
  zSin  := n.z * SinTh;

  InnerBufMtx[3, 0]:= 0;
  InnerBufMtx[3, 1]:= 0;
  InnerBufMtx[3, 2]:= 0;
  InnerBufMtx[3, 3]:= 1;
  InnerBufMtx[0, 0]:= (Sqr(n.x) * iCosTh) + CosTh;
  InnerBufMtx[0, 1]:= xy + zSin;
  InnerBufMtx[0, 2]:= xz - ySin;
  InnerBufMtx[0, 3]:= 0;
  InnerBufMtx[1, 0]:= xy - zSin;
  InnerBufMtx[1, 1]:= (Sqr(n.y) * iCosTh) + CosTh;
  InnerBufMtx[1, 2]:= yz + xSin;
  InnerBufMtx[1, 3]:= 0;
  InnerBufMtx[2, 0]:= xz + ySin;
  InnerBufMtx[2, 1]:= yz - xSin;
  InnerBufMtx[2, 2]:= (Sqr(n.z) * iCosTh) + CosTh;
  InnerBufMtx[2, 3]:= 0;

  PMatMul(Result, @InnerBufMtx);
end;

procedure PMatRotate(Result: PMatrix4; const n: TVector4;const Theta: Real);
var
  CosTh, iCosTh, SinTh: Real;
  xy, xz, yz, xSin, ySin, zSin: Real;
begin
  CosTh := Cos(Theta);
  iCosTh:= 1.0 - CosTh;
  SinTh := Sin(Theta);
  xy    := n.x * n.y * iCosTh;
  xz    := n.x * n.z * iCosTh;
  yz    := n.y * n.z * iCosTh;
  xSin  := n.x * SinTh;
  ySin  := n.y * SinTh;
  zSin  := n.z * SinTh;

  SetIdentityMatrix(Result);
  Result[0, 0]:= (Sqr(n.x) * iCosTh) + CosTh;
  Result[0, 1]:= xy + zSin;
  Result[0, 2]:= xz - ySin;
  Result[1, 0]:= xy - zSin;
  Result[1, 1]:= (Sqr(n.y) * iCosTh) + CosTh;
  Result[1, 2]:= yz + xSin;
  Result[2, 0]:= xz + ySin;
  Result[2, 1]:= yz - xSin;
  Result[2, 2]:= (Sqr(n.z) * iCosTh) + CosTh;
end;

// scaling along cardinal axes
procedure PMatScale(Result: PMatrix4; const k: TVector4);
begin
  SetIdentityMatrix(@InnerBufMtx);
  InnerBufMtx[0, 0]:= k.x;
  InnerBufMtx[1, 1]:= k.y;
  InnerBufMtx[2, 2]:= k.z;
  InnerBufMtx[3, 3]:= k.w;

  Result^ := InnerBufMtx;
end;

procedure PBufMatScale(const k: TVector4);
begin
 SetIdentityMatrix(@BufMtx);
 BufMtx[0, 0]:= k.x;
 BufMtx[1, 1]:= k.y;
 BufMtx[2, 2]:= k.z;
 BufMtx[3, 3]:= k.w;
end;

function Vec3Magnitude(const v: TPoint3; mag: double): TPoint3;
begin
  Result := VecScale3(VecNorm3(v), mag);
end;

end.


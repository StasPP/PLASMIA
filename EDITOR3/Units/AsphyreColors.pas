{
     The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

     The Original Code is AsphyreColors.pas, Colors.dpr.

     The Initial Developer of the Original Code is Robert Kosek.
     Portions created by Robert Kosek are Copyright (C) Sept 2006
     by Robert Kosek. All Rights Reserved.

     Contributors: Hilton Janfield.
-------------------------------------------------------------------------------------
  Version 1.0:
    * Initial Release

  Version 1.1:
    * Fixed the mixup of RGB bytes, which should have been ordered BGR.
    * Updated the color fade to no longer need multiple steps, just c.Fade(c2,100);
}

unit AsphyreColors;

interface

uses Sysutils, Math;

type
  AsphyreColor = packed record
    // operators and such
    class operator Add(a,b: AsphyreColor): AsphyreColor;
    class operator Subtract(a,b: AsphyreColor): AsphyreColor;
    class operator Multiply(a,b: AsphyreColor): AsphyreColor;
    class operator Multiply(a: AsphyreColor; b: real): AsphyreColor; overload;
    class operator Divide(a,b: AsphyreColor): AsphyreColor;
    // conversions w/o the usage of the parts
    class operator Implicit(a: AsphyreColor): Cardinal;
    class operator Implicit(a: Cardinal): AsphyreColor;
    // Color Fading
    function Fade(c: AsphyreColor; pos: byte): AsphyreColor;
    // Conversion to-from string form
    function ToString: string;
    procedure FromString(s: string);

    // This case statement allows the record to be referenced as either a
    // cardinal value or a set of 4 bytes.  To read the C property you really
    // get an integer of: aaarrrgggbbb, where each letter is the byte repre-
    // sentation of the color.  Automatic conversions made easy!
    case boolean of
      true: (a,b,g,r: byte);
      false: (c: cardinal);
  end;

implementation

{ AsphyreColor }

class operator AsphyreColor.Add(a, b: AsphyreColor): AsphyreColor;
begin
  result.a := min(a.a + b.a,255);
  result.r := min(a.r + b.r,255);
  result.g := min(a.g + b.g,255);
  result.b := min(a.b + b.b,255);
end;

class operator AsphyreColor.Divide(a, b: AsphyreColor): AsphyreColor;
begin
  result.a := round(a.a / b.a);
  result.r := round(a.r / b.r);
  result.g := round(a.g / b.g);
  result.b := round(a.b / b.b);
end;

class operator AsphyreColor.Implicit(a: AsphyreColor): Cardinal;
begin
  result := a.c;
end;

class operator AsphyreColor.Implicit(a: Cardinal): AsphyreColor;
begin
  result.c := a;
end;

class operator AsphyreColor.Multiply(a: AsphyreColor; b: real): AsphyreColor;
begin
  result.a := min(round(a.a * b),255);
  result.r := min(round(a.r * b),255);
  result.g := min(round(a.g * b),255);
  result.b := min(round(a.b * b),255);
end;

class operator AsphyreColor.Multiply(a, b: AsphyreColor): AsphyreColor;
begin
  result.a := min(a.a * b.a mod 255,255);
  result.r := min(a.r * b.r mod 255,255);
  result.g := min(a.g * b.g mod 255,255);
  result.b := min(a.b * b.b mod 255,255);
end;

class operator AsphyreColor.Subtract(a, b: AsphyreColor): AsphyreColor;
begin
  result.a := max(a.a - b.a,0);
  result.r := max(a.r - b.r,0);
  result.g := max(a.g - b.g,0);
  result.b := max(a.b - b.b,0);
end;

function AsphyreColor.ToString: string;
begin
  result := Format('%d,%d,%d,%d',[a,r,g,b]);
end;

function AsphyreColor.Fade(c: AsphyreColor; pos: byte): AsphyreColor;
begin
  result.a := Round(a+(((c.a - a) * pos) / 100));
  result.b := Round(b+(((c.b - b) * pos) / 100));
  result.g := Round(g+(((c.g - g) * pos) / 100));
  result.r := Round(r+(((c.r - r) * pos) / 100));
end;

procedure AsphyreColor.FromString(s: string);
  procedure ExplodeStr(const s: string; out a: array of integer);
  var i: integer;
      t: string;
  begin
    t := s;
    i := 0;
    while pos(',',t) > 0 do begin
      a[i] := StrToInt(copy(t,1,pos(',',t)-1));
      inc(i);
      Delete(t,1,pos(',',t));
    end;
    if t <> '' then
      a[i] := StrToInt(t);
  end;

var c: array[0..3] of integer;
begin
  ExplodeStr(s, c);

  a := min(c[0],255);
  r := min(c[1],255);
  g := min(c[2],255);
  b := min(c[3],255);
end;

end.
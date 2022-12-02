unit DX7Formats;
//---------------------------------------------------------------------------
// DX7Formats.pas                                       Modified: 10-Oct-2007
// Texture formats enumeration in DirectX 7.0                     Version 1.0
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
// The Original Code is DX7Formats.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Ixchel Studios. All Rights Reserved.
//---------------------------------------------------------------------------

{$ifdef fpc}{$mode delphi}{$endif}

interface

//---------------------------------------------------------------------------
uses
 DirectDraw7, Classes, SysUtils, AsphyreTypes;

//---------------------------------------------------------------------------
type
 TDXFormats = class
 private
  Formats: array of TColorFormat;

  procedure Reset();
  function IndexOf(Format: TColorFormat): Integer;
  function Insert(Format: TColorFormat): Integer;
  procedure Include(Format: TColorFormat);
 public
  procedure Enumerate();

  function MatchFormat(HighQuality, AlphaChannel: Boolean): TColorFormat;

  procedure FormatToDesc(Format: TColorFormat;
   PixelFormat: PDDPixelFormat);

  procedure ListFormats(Strings: TStrings);
 end;

//---------------------------------------------------------------------------
var
 DXFormats: TDXFormats = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 DX7Types, Windows;

//---------------------------------------------------------------------------
const
 HighAlphaSet: array[0..4] of TColorFormat = (COLOR_A8R8G8B8, COLOR_A4R4G4B4,
  COLOR_A2R2G2B2, COLOR_A1R5G5B5, COLOR_A8R3G3B2);
 LowAlphaSet: array[0..4] of TColorFormat = (COLOR_A4R4G4B4, COLOR_A2R2G2B2,
  COLOR_A8R8G8B8, COLOR_A1R5G5B5, COLOR_A8R3G3B2);

//---------------------------------------------------------------------------
 HighSolidSet: array[0..9] of TColorFormat = (COLOR_X8R8G8B8, COLOR_A8R8G8B8,
  COLOR_R5G6B5, COLOR_X1R5G5B5, COLOR_A1R5G5B5, COLOR_X4R4G4B4, COLOR_A4R4G4B4,
  COLOR_R3G3B2, COLOR_A8R3G3B2, COLOR_A2R2G2B2);
 LowSolidSet: array[0..9] of TColorFormat = (COLOR_R5G6B5, COLOR_X1R5G5B5,
  COLOR_A1R5G5B5, COLOR_X4R4G4B4, COLOR_A4R4G4B4, COLOR_R3G3B2, COLOR_X8R8G8B8,
  COLOR_A8R8G8B8, COLOR_A8R3G3B2, COLOR_A2R2G2B2);

{ 0 COLOR_R3G3B2,
  1 COLOR_R5G6B5,
  2 COLOR_X8R8G8B8,
  3 COLOR_X1R5G5B5,
  4 COLOR_X4R4G4B4,
  5 COLOR_A8R8G8B8,
  6 COLOR_A1R5G5B5,
  7 COLOR_A4R4G4B4,
  8 COLOR_A8R3G3B2,
  9 COLOR_A2R2G2B2,
  10 COLOR_A8,
  11 COLOR_UNKNOWN); }

//---------------------------------------------------------------------------
function EnumCallback(var PixelFmt: TDDPixelFormat;
 Context: Pointer): HResult; stdcall;
var
 Format: TColorFormat;
begin
 Format:= COLOR_UNKNOWN;

 case PixelFmt.dwRGBBitCount of
  8: // 8-bit formats
   begin
    // COLOR_R3G3B2
    if (PixelFmt.dwRBitMask = $000000E0)and
       (PixelFmt.dwGBitMask = $0000001C)and
       (PixelFmt.dwBBitMask = $00000003) then Format:= COLOR_R3G3B2;

    // COLOR_A2R2G2B2
    if (PixelFmt.dwRBitMask = $00000030)and
       (PixelFmt.dwGBitMask = $000000C0)and
       (PixelFmt.dwBBitMask = $00000003)and
       (PixelFmt.dwRGBAlphaBitMask = $000000C0) then Format:= COLOR_A2R2G2B2
   end;

  16: // 16-bit formats
   begin
    // COLOR_R5G6B5
    if (PixelFmt.dwRBitMask = $0000F800)and
       (PixelFmt.dwGBitMask = $000007E0)and
       (PixelFmt.dwBBitMask = $0000001F) then Format:= COLOR_R5G6B5;

    // COLOR_A1R5G5B5
    if (PixelFmt.dwRBitMask = $00007C00)and
       (PixelFmt.dwGBitMask = $000003E0)and
       (PixelFmt.dwBBitMask = $0000001F) then
     begin
      if (PixelFmt.dwRGBAlphaBitMask = $00008000) then Format:= COLOR_A1R5G5B5
       else Format:= COLOR_X1R5G5B5;
     end;

    // COLOR_A4R4G4B4
    if (PixelFmt.dwRBitMask = $00000F00)and
       (PixelFmt.dwGBitMask = $000000F0)and
       (PixelFmt.dwBBitMask = $0000000F) then
     begin
      if (PixelFmt.dwRGBAlphaBitMask = $0000F000) then Format:= COLOR_A4R4G4B4
       else Format:= COLOR_X4R4G4B4;
     end;

    // COLOR_A8R3G3B2
    if (PixelFmt.dwRBitMask = $000000E0)and
       (PixelFmt.dwGBitMask = $0000001C)and
       (PixelFmt.dwBBitMask = $00000003)and
       (PixelFmt.dwRGBAlphaBitMask = $0000FF00) then Format:= COLOR_A8R3G3B2;
   end;

  32: // 32-bit formats
   if (PixelFmt.dwRBitMask = $00FF0000)and
      (PixelFmt.dwGBitMask = $0000FF00)and
      (PixelFmt.dwBBitMask = $000000FF) then
    begin
     if (PixelFmt.dwRGBAlphaBitMask = $FF000000) then Format:= COLOR_A8R8G8B8
      else Format:= COLOR_X8R8G8B8;
    end;
 end;

 if (Format <> COLOR_UNKNOWN) then TDXFormats(Context).Include(Format);

 Result:= DDENUMRET_OK;
end;

//---------------------------------------------------------------------------
procedure TDXFormats.Reset();
begin
 SetLength(Formats, 0);
end;

//---------------------------------------------------------------------------
function TDXFormats.IndexOf(Format: TColorFormat): Integer;
var
 i: Integer;
begin
 Result:= -1;

 for i:= 0 to Length(Formats) - 1 do
  if (Formats[i] = Format) then
   begin
    Result:= i;
    Break;
   end;
end;

//---------------------------------------------------------------------------
function TDXFormats.Insert(Format: TColorFormat): Integer;
var
 Index: Integer;
begin
 Index:= Length(Formats);
 SetLength(Formats, Index + 1);

 Formats[Index]:= Format;
 Result:= Index;
end;

//---------------------------------------------------------------------------
procedure TDXFormats.Include(Format: TColorFormat);
begin
 if (IndexOf(Format) = -1) then Insert(Format);
end;

//---------------------------------------------------------------------------
procedure TDXFormats.Enumerate();
begin
 Reset();

 if (Device7 <> nil) then
  Device7.EnumTextureFormats(EnumCallback, Self);
end;

//---------------------------------------------------------------------------
function TDXFormats.MatchFormat(HighQuality,
 AlphaChannel: Boolean): TColorFormat;
var
 Format: PColorFormat;
 FormatNo, FormatMax: Integer;
begin
 if (AlphaChannel) then
  begin
   if (HighQuality) then
    begin
     Format:= @HighAlphaSet[0];
     FormatMax:= 4;
    end else
    begin
     Format:= @LowAlphaSet[0];
     FormatMax:= 4;
    end;
  end else
  begin
   if (HighQuality) then
    begin
     Format:= @HighSolidSet[0];
     FormatMax:= 9;
    end else
    begin
     Format:= @LowSolidSet[0];
     FormatMax:= 9;
    end;
  end;

 Result:= COLOR_UNKNOWN;

 for FormatNo:= 0 to FormatMax do
  begin
   if (IndexOf(Format^) <> -1) then
    begin
     Result:= Format^;
     Break;
    end;

   Inc(Format);
  end;
end;

//---------------------------------------------------------------------------
procedure TDXFormats.FormatToDesc(Format: TColorFormat;
 PixelFormat: PDDPixelFormat);
begin
 FillChar(PixelFormat^, SizeOf(TDDPixelFormat), 0);

 PixelFormat.dwSize:= SizeOf(TDDPixelFormat);

 case Format of
  COLOR_R3G3B2:
   begin
    PixelFormat.dwFlags:= DDPF_RGB;
    PixelFormat.dwRGBBitCount:= 8;

    PixelFormat.dwRBitMask:= $000000E0;
    PixelFormat.dwGBitMask:= $0000001C;
    PixelFormat.dwBBitMask:= $00000003;
   end;

  COLOR_R5G6B5:
   begin
    PixelFormat.dwFlags:= DDPF_RGB;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $0000F800;
    PixelFormat.dwGBitMask:= $000007E0;
    PixelFormat.dwBBitMask:= $0000001F;
   end;

  COLOR_X8R8G8B8:
   begin
    PixelFormat.dwFlags:= DDPF_RGB;
    PixelFormat.dwRGBBitCount:= 32;

    PixelFormat.dwRBitMask:= $00FF0000;
    PixelFormat.dwGBitMask:= $0000FF00;
    PixelFormat.dwBBitMask:= $000000FF;
   end;

  COLOR_X1R5G5B5:
   begin
    PixelFormat.dwFlags:= DDPF_RGB;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $00007C00;
    PixelFormat.dwGBitMask:= $000003E0;
    PixelFormat.dwBBitMask:= $0000001F;
   end;

  COLOR_X4R4G4B4:
   begin
    PixelFormat.dwFlags:= DDPF_RGB;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $00000F00;
    PixelFormat.dwGBitMask:= $000000F0;
    PixelFormat.dwBBitMask:= $0000000F;
   end;

  COLOR_A8R8G8B8:
   begin
    PixelFormat.dwFlags:= DDPF_RGB or DDPF_ALPHAPIXELS;
    PixelFormat.dwRGBBitCount:= 32;

    PixelFormat.dwRBitMask:= $00FF0000;
    PixelFormat.dwGBitMask:= $0000FF00;
    PixelFormat.dwBBitMask:= $000000FF;
    PixelFormat.dwRGBAlphaBitMask:= $FF000000;
   end;

  COLOR_A1R5G5B5:
   begin
    PixelFormat.dwFlags:= DDPF_RGB or DDPF_ALPHAPIXELS;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $00007C00;
    PixelFormat.dwGBitMask:= $000003E0;
    PixelFormat.dwBBitMask:= $0000001F;
    PixelFormat.dwRGBAlphaBitMask:= $00008000;
   end;

  COLOR_A4R4G4B4:
   begin
    PixelFormat.dwFlags:= DDPF_RGB or DDPF_ALPHAPIXELS;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $00000F00;
    PixelFormat.dwGBitMask:= $000000F0;
    PixelFormat.dwBBitMask:= $0000000F;
    PixelFormat.dwRGBAlphaBitMask:= $0000F000;
   end;

  COLOR_A8R3G3B2:
   begin
    PixelFormat.dwFlags:= DDPF_RGB or DDPF_ALPHAPIXELS;
    PixelFormat.dwRGBBitCount:= 16;

    PixelFormat.dwRBitMask:= $000000E0;
    PixelFormat.dwGBitMask:= $0000001C;
    PixelFormat.dwBBitMask:= $00000003;
    PixelFormat.dwRGBAlphaBitMask:= $0000FF00;
   end;

  COLOR_A2R2G2B2:
   begin
    PixelFormat.dwFlags:= DDPF_RGB or DDPF_ALPHAPIXELS;
    PixelFormat.dwRGBBitCount:= 8;

    PixelFormat.dwRBitMask:= $00000030;
    PixelFormat.dwGBitMask:= $000000C0;
    PixelFormat.dwBBitMask:= $00000003;
    PixelFormat.dwRGBAlphaBitMask:= $000000C0;
   end;
 end;
end;

//---------------------------------------------------------------------------
procedure TDXFormats.ListFormats(Strings: TStrings);
const
 FormatNames: array[TColorFormat] of string = ('COLOR_R3G3B2', 'COLOR_R5G6B5',
  'COLOR_X8R8G8B8', 'COLOR_X1R5G5B5', 'COLOR_X4R4G4B4', 'COLOR_A8R8G8B8',
  'COLOR_A1R5G5B5', 'COLOR_A4R4G4B4', 'COLOR_A8R3G3B2', 'COLOR_A2R2G2B2',
  'COLOR_A8', 'COLOR_UNKNOWN');
var
 i: Integer;
begin
 Strings.Clear();

 for i:= 0 to Length(Formats) - 1 do
  Strings.Add(FormatNames[Formats[i]]);
end;

//---------------------------------------------------------------------------
initialization
 DXFormats:= TDXFormats.Create();

//---------------------------------------------------------------------------
finalization
 FreeAndNil(DXFormats);

//---------------------------------------------------------------------------
end.

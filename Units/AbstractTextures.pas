unit AbstractTextures;
//---------------------------------------------------------------------------
// AbstractTextures.pas                                 Modified: 04-Nov-2007
// Asphyre Texture Abstract declaration                           Version 1.0
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
// The Original Code is AbstractTextures.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Types, Vectors2px, Vectors2, AsphyreTypes, AsphyreConv, SystemSurfaces;

//---------------------------------------------------------------------------
type
 TAsphyreTexture = class
 private
  FSize  : TPoint2px;
  FActive: Boolean;

  FHighQuality : Boolean;
  FAlphaChannel: Boolean;
  FMipMapping  : Boolean;
  FRenderTarget: Boolean;

  procedure SetSize(const Value: TPoint2px);
  procedure SetSetting(const Index: Integer; const Value: Boolean);
  function GetBytesPerPixel(): Integer;
  function GetPixel(x, y: Integer): Cardinal;
  procedure SetPixel(x, y: Integer; const Value: Cardinal);
 protected
  FFormat: TColorFormat;

  function CreateTexture(): Boolean; virtual; abstract;
  procedure DestroyTexture(); virtual; abstract;
 public
  // Indicates the pixel format currently used to store the pixels.
  property Format: TColorFormat read FFormat;

  // Determines the size of the texture. In most cases, this should be power
  // of two (e.g. 128, 256, 512, ..., 2048, etc.)
  property Size: TPoint2px read FSize write SetSize;

  // Determines whether the texture can be currently used in rendering.
  property Active: Boolean read FActive;

  // Indicates how many bytes each pixel occupies.
  property BytesPerPixel: Integer read GetBytesPerPixel;

  // Indicates whether the texture should use high-quality pixel format, such
  // as 32-bit A8R8G8B8 format. Setting this property to false
  property HighQuality: Boolean index 0 read FHighQuality write SetSetting;

  // Indicates whether the texture should contain alpha-channel. Notice that
  // this setting also affects pixel format. In addition, setting this to false
  // doesn't guarantee that no alpha-channel will be present in the texture.
  property AlphaChannel: Boolean index 1 read FAlphaChannel write SetSetting;

  // Determines whether the texture should contain additional mipmaps. This
  // will require more video memory, but can increase the rendering quality
  // when image is shrinked to smaller size (commonly in 3D scene).
  property MipMapping: Boolean index 2 read FMipMapping write SetSetting;

  // Determines whether the texture should be used as a render target.
  // The render targets have no mipmapping usually cannot be locked. That is,
  // their pixel data cannot be accessed using normal means.
  property RenderTarget: Boolean index 3 read FRenderTarget write SetSetting;

  // Direct access to surface pixels. This does pixel format conversion and
  // is usually a slow way of accessing image's pixels.
  property Pixels[x, y: Integer]: Cardinal read GetPixel write SetPixel;

  // This method writes raw 32-bit pixels from the source pointer to texture.
  function WriteScanline(Index: Integer;
   Source: Pointer): Boolean; virtual; abstract;

  // This method is used by DirectX providers to assign the texture to
  // specific blending stage.
  procedure AssignToStage(StageNo: Integer); virtual; abstract;

  // Converts pixel coordinates to logical coordinates [0..1].
  function CoordToLogical(const Coord: TPoint2px): TPoint2; overload; virtual;
  function CoordToLogical(const Coord: TPoint2): TPoint2; overload; virtual;

  // Converts logical coordinates [0..1] to pixel coordinates.
  function LogicalToCoord(const Coord: TPoint2): TPoint2px; virtual;
  // Converts an array of four texture coordinates in pixels to logical
  // values of [0..1].
  function CoordToLogical4(const Points: TPoint4px): TPoint4;

  // Obtain raw pixel access to surface's pixels.
  // -> Note that pixels are represented in texture's internal format.
  //    If you don't want to handle the conversion yourself, use other methods,
  //    such as WriteScanline(), GetPixelData() and SetPixelData().
  procedure Lock(out Bits: Pointer; out Pitch: Integer); virtual; abstract;
  // Release the raw pixel access to surface's pixels.
  procedure Unlock(); virtual; abstract;

  // Download the texture to 32-bit system-level surface.
  function GetPixelData(Level: Integer; Buffer: TSystemSurface): Boolean; virtual; abstract;
  // Upload 32-bit system-level surface to the texture.
  function SetPixelData(Level: Integer; Buffer: TSystemSurface): Boolean; virtual; abstract;

  // Update mipmaps, if such are present in texture.
  procedure UpdateMipmaps(); virtual; abstract;

  // This method will initialize the texture and populate public fields such
  // as Formats and BytesPerPixel.
  function Initialize(): Boolean;

  // This method will release the texture and its video memory.
  procedure Finalize();

  // This should be called after the device has been reset to restore all
  // texture resources to a working state.
  procedure HandleDeviceReset(); virtual;

  // This should be called after (or immediately before) the device has been
  // lost so that volatile texture resources can be released.
  procedure HandleDeviceLost(); virtual;

  // Begins rendering on this texture, if it is a valid render target.
  function BeginDrawTo(): Boolean; virtual; abstract;

  // Finishes rendering on this texture and restores previous render target.
  procedure EndDrawTo(); virtual; abstract;

  constructor Create(); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
constructor TAsphyreTexture.Create();
begin
 inherited;

 FActive:= False;
 FFormat:= COLOR_UNKNOWN;

 FHighQuality := True;
 FAlphaChannel:= True;
 FMipMapping  := False;
 FRenderTarget:= False;
end;

//---------------------------------------------------------------------------
destructor TAsphyreTexture.Destroy();
begin
 if (FActive) then Finalize();

 inherited;
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.SetSize(const Value: TPoint2px);
begin
 if (not FActive) then FSize:= Value;
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.SetSetting(const Index: Integer;
 const Value: Boolean);
begin
 if (FActive) then Exit;

 case Index of
  0: FHighQuality := Value;
  1: FAlphaChannel:= Value;
  2: FMipMapping  := Value;
  3: FRenderTarget:= Value;
 end;
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.Initialize(): Boolean;
begin
 Result:= not FActive;
 if (not Result) then Exit;

 FFormat:= COLOR_UNKNOWN;

 Result := CreateTexture();
 FActive:= Result;
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.Finalize();
begin
 if (FActive) then
  begin
   DestroyTexture();
   FActive:= False;
  end;

 FFormat:= COLOR_UNKNOWN;
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.GetBytesPerPixel(): Integer;
begin
 Result:= Format2Bytes[FFormat];
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.LogicalToCoord(const Coord: TPoint2): TPoint2px;
begin
 Result.X:= Round(Coord.x * FSize.X);
 Result.Y:= Round(Coord.y * FSize.Y);
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.CoordToLogical(const Coord: TPoint2px): TPoint2;
begin
 if (FSize.X > 0) then Result.x:= Coord.x / FSize.X else Result.x:= 0.0;
 if (FSize.Y > 0) then Result.y:= Coord.y / FSize.Y else Result.y:= 0.0;
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.CoordToLogical(const Coord: TPoint2): TPoint2;
begin
 if (FSize.X > 0) then Result.x:= Coord.x / FSize.X else Result.x:= 0.0;
 if (FSize.Y > 0) then Result.y:= Coord.y / FSize.Y else Result.y:= 0.0;
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.CoordToLogical4(
 const Points: TPoint4px): TPoint4;
var
 i: Integer;
begin
 for i:= 0 to 3 do
  Result[i]:= CoordToLogical(Points[i]);
end;

//---------------------------------------------------------------------------
function TAsphyreTexture.GetPixel(x, y: Integer): Cardinal;
var
 Bits : Pointer;
 Pitch: Integer;
 Pixel: PCardinal;
begin
 Result:= 0;

 if (x < 0)or(y < 0)or(x >= FSize.x)or(y >= FSize.y) then Exit;

 Lock(Bits, Pitch);
 if (Bits = nil)or(Pitch < 1) then Exit;

 Pixel := Pointer(Integer(Bits) + (y * Pitch) + (x * GetBytesPerPixel()));
 Result:= PixelXto32(Pixel, FFormat);

 Unlock();
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.SetPixel(x, y: Integer; const Value: Cardinal);
var
 Bits : Pointer;
 Pitch: Integer;
 Pixel: PCardinal;
begin
 if (x < 0)or(y < 0)or(x >= FSize.x)or(y >= FSize.y) then Exit;

 Lock(Bits, Pitch);
 if (Bits = nil)or(Pitch < 1) then Exit;

 Pixel:= Pointer(Integer(Bits) + (y * Pitch) + (x * GetBytesPerPixel()));

 Pixel32toX(Value, Pixel, FFormat);

 Unlock();
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.HandleDeviceReset();
begin
 // no code
end;

//---------------------------------------------------------------------------
procedure TAsphyreTexture.HandleDeviceLost();
begin
 // no code
end;

//---------------------------------------------------------------------------
end.

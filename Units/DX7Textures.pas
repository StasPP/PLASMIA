unit DX7Textures;
//---------------------------------------------------------------------------
// DX7Textures.pas                                      Modified: 04-Nov-2007
// Texture implementation using DirectX 7.0                      Version 1.01
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
// The Original Code is DX7Textures.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Use Delphi Compatibility mode in FreePascal
//---------------------------------------------------------------------------
{$ifdef fpc}{$mode delphi}{$endif}

//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Types, SysUtils, Vectors2px, AbstractTextures, DirectDraw7,
 SystemSurfaces;

//---------------------------------------------------------------------------
type
 TDX7Texture = class(TAsphyreTexture)
 private
  FSurface: IDirectDrawSurface7;
  FSurfaceDesc: TDDSurfaceDesc2;

  PrevTarget: IDirectDrawSurface7;

  function ComputeMipLevels(const Size: TPoint2px): Integer;
  function GetSurfaceLevel(Level: Integer): IDirectDrawSurface7;
  function GetSizeOfLevel(Level: Integer): TPoint2px;

  procedure LockRect(Rect: PRect; Level: Integer; out Bits: Pointer;
   out Pitch: Integer);
  procedure UnlockRect(Rect: PRect; Level: Integer);

  function MakeMipmap(DestNo, SrcNo: Integer): Boolean;

  procedure InitSurfaceDesc();
 protected
  function CreateTexture(): Boolean; override;
  procedure DestroyTexture(); override;
 public
  property Surface: IDirectDrawSurface7 read FSurface;
  property SurfaceDesc: TDDSurfaceDesc2 read FSurfaceDesc;

  procedure Lock(out Bits: Pointer; out Pitch: Integer); override;
  procedure Unlock(); override;

  function WriteScanline(Index: Integer; Source: Pointer): Boolean; override;

  procedure AssignToStage(StageNo: Integer); override;

  procedure UpdateMipmaps(); override;

  function GetPixelData(Level: Integer; Buffer: TSystemSurface): Boolean; override;
  function SetPixelData(Level: Integer; Buffer: TSystemSurface): Boolean; override;

  function BeginDrawTo(): Boolean; override;
  procedure EndDrawTo(); override;

  procedure HandleDeviceLost(); override;
  procedure HandleDeviceReset(); override;

  constructor Create(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 DX7Types, DX7Formats, AsphyreTypes, AsphyreUtils, AsphyreConv;

//---------------------------------------------------------------------------
constructor TDX7Texture.Create();
begin
 inherited;

 FSurface:= nil;
 FillChar(FSurfaceDesc, SizeOf(TDDSurfaceDesc), 0);
end;

//---------------------------------------------------------------------------
function TDX7Texture.ComputeMipLevels(const Size: TPoint2px): Integer;
var
 Width, Height: Integer;
begin
 Width := Size.x;
 Height:= Size.y;
 Result:= 1;

 while (Width > 1)and(Height > 1) do
  begin
   Width := Width div 2;
   Height:= Height div 2;
   Inc(Result);
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.InitSurfaceDesc();
begin
 FillChar(FSurfaceDesc, SizeOf(TDDSurfaceDesc2), 0);

 FSurfaceDesc.dwSize:= SizeOf(TDDSurfaceDesc2);

 FSurfaceDesc.dwFlags:= DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or
   DDSD_PIXELFORMAT or DDSD_TEXTURESTAGE;

 FSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_TEXTURE;
 FSurfaceDesc.ddsCaps.dwCaps2:= DDSCAPS2_TEXTUREMANAGE;

 if (RenderTarget) then
  with FSurfaceDesc.ddsCaps do
   begin
    dwCaps := dwCaps or DDSCAPS_3DDEVICE or DDSCAPS_VIDEOMEMORY;
    dwCaps2:= dwCaps2 xor DDSCAPS2_TEXTUREMANAGE;
   end;

 FSurfaceDesc.dwWidth := Size.x;
 FSurfaceDesc.dwHeight:= Size.y;

 if (MipMapping)and(not RenderTarget) then
  begin
   FSurfaceDesc.dwFlags:= FSurfaceDesc.dwFlags or DDSD_MIPMAPCOUNT;

   FSurfaceDesc.ddsCaps.dwCaps:= FSurfaceDesc.ddsCaps.dwCaps or
    DDSCAPS_MIPMAP or DDSCAPS_COMPLEX;

   FSurfaceDesc.dwMipMapCount:= ComputeMipLevels(Size);
  end;

 DXFormats.FormatToDesc(FFormat, @FSurfaceDesc.ddpfPixelFormat);
end;

//---------------------------------------------------------------------------
function TDX7Texture.CreateTexture(): Boolean;
begin
 FFormat:= DXFormats.MatchFormat(HighQuality, AlphaChannel);

 Result:= FFormat <> COLOR_UNKNOWN;
 if (not Result) then Exit;

 InitSurfaceDesc();

 Result:= Succeeded(DirectDraw.CreateSurface(FSurfaceDesc, FSurface, nil));

 if (Result) then
  Result:= Succeeded(FSurface.GetSurfaceDesc(FSurfaceDesc));

 PrevTarget:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.DestroyTexture();
begin
 if (PrevTarget <> nil) then PrevTarget:= nil;

 if (FSurface <> nil) then
  begin
   FSurface:= nil;
   FillChar(FSurfaceDesc, SizeOf(TDDSurfaceDesc), 0);
  end;
end;

//---------------------------------------------------------------------------
function TDX7Texture.GetSurfaceLevel(Level: Integer): IDirectDrawSurface7;
var
 Surface1, Surface2: IDirectDrawSurface7;
 Caps: TDDSCaps2;
begin
 // Case 1. No surface exists.
 if (FSurface = nil) then
  begin
   Result:= nil;
   Exit;
  end;

 // Case 2. Top-level surface.
 if (Level = 0) then
  begin
   Result:= FSurface;
   Exit;
  end;

 // Case 3. Sub-level surface.
 Surface1:= FSurface;
 Surface2:= nil;

 repeat
  FillChar(Caps, SizeOf(TDDSCaps2), 0);
  Caps.dwCaps:= DDSCAPS_MIPMAP;

  if (Failed(Surface1.GetAttachedSurface(Caps, Surface2))) then
   begin
    Surface1:= nil;
    Surface2:= nil;
    Exit;
   end;

  Surface1:= Surface2;
  Surface2:= nil;

  Dec(Level);
 until (Level <= 0);

 Result:= Surface1;

 Surface1:= nil;
 Surface2:= nil;
end;

//---------------------------------------------------------------------------
function TDX7Texture.GetSizeOfLevel(Level: Integer): TPoint2px;
var
 MipMap : IDirectDrawSurface7;
 MipDesc: TDDSurfaceDesc2;
begin
 Result:= ZeroPoint2px;

 MipMap:= GetSurfaceLevel(Level);
 if (MipMap = nil) then Exit;

 FillChar(MipDesc, SizeOf(TDDSurfaceDesc2), 0);
 MipDesc.dwSize:= SizeOf(TDDSurfaceDesc2);

 if (Succeeded(MipMap.GetSurfaceDesc(MipDesc))) then
  begin
   Result.x:= MipDesc.dwWidth;
   Result.y:= MipDesc.dwHeight;
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.LockRect(Rect: PRect; Level: Integer; out Bits: Pointer;
 out Pitch: Integer);
var
 MipMap : IDirectDrawSurface7;
 MipDesc: TDDSurfaceDesc2;
begin
 Bits := nil;
 Pitch:= 0;

 MipMap:= GetSurfaceLevel(Level);
 if (MipMap = nil) then Exit;

 FillChar(MipDesc, SizeOf(TDDSurfaceDesc2), 0);
 MipDesc.dwSize:= SizeOf(TDDSurfaceDesc2);

 if (Succeeded(MipMap.Lock(Rect, MipDesc, DDLOCK_SURFACEMEMORYPTR or
  DDLOCK_WAIT, 0))) then
  begin
   Bits := MipDesc.lpSurface;
   Pitch:= MipDesc.lPitch;
  end;

 MipMap:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.UnlockRect(Rect: PRect; Level: Integer);
var
 MipMap: IDirectDrawSurface7;
begin
 MipMap:= GetSurfaceLevel(Level);

 if (MipMap <> nil) then MipMap.Unlock(Rect);
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.Lock(out Bits: Pointer; out Pitch: Integer);
begin
 LockRect(nil, 0, Bits, Pitch);
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.Unlock();
begin
 UnlockRect(nil, 0);
end;

//---------------------------------------------------------------------------
function TDX7Texture.WriteScanline(Index: Integer; Source: Pointer): Boolean;
var
 Rect : TRect;
 Bits : Pointer;
 Pitch: Integer;
begin
 Rect:= Bounds(0, Index, Size.x, 1);

 LockRect(@Rect, 0, Bits, Pitch);
 if (Bits = nil)or(Pitch < 1) then
  begin
   Result:= False;
   Exit;
  end;

 Move(Source^, Bits^, Size.x * BytesPerPixel);

 UnlockRect(@Rect, 0);

 Result:= True;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.AssignToStage(StageNo: Integer);
begin
 if (FSurface <> nil) then
  Device7.SetTexture(StageNo, FSurface)
   else Device7.SetTexture(StageNo, nil);
end;

//---------------------------------------------------------------------------
function TDX7Texture.GetPixelData(Level: Integer;
 Buffer: TSystemSurface): Boolean;
var
 Size : TPoint2px;
 Bits : Pointer;
 Pitch: Integer;
 Index: Integer;
 Convert: Boolean;
 LinePtr: Pointer;
begin
 Result := False;
 Convert:= (Format <> COLOR_A8R8G8B8)and(Format <> COLOR_X8R8G8B8);

 Size:= GetSizeOfLevel(Level);
 if (Size = ZeroPoint2px) then Exit;

 LockRect(nil, Level, Bits, Pitch);
 if (Bits = nil)or(Pitch < 1) then Exit;

 Buffer.SetSize(Size.x, Size.y);

 for Index:= 0 to Size.y - 1 do
  begin
   LinePtr:= Pointer(Integer(Bits) + (Pitch * Index));

   if (not Convert) then
    begin
     Move(LinePtr^, Buffer.Scanline[Index]^, Buffer.Width * 4);
    end else
    begin
     LineConvXto32(LinePtr, Buffer.Scanline[Index], Buffer.Width, Format);
    end;
  end;

 UnlockRect(nil, Level);
 Result:= True;
end;

//---------------------------------------------------------------------------
function TDX7Texture.SetPixelData(Level: Integer;
 Buffer: TSystemSurface): Boolean;
var
 Size : TPoint2px;
 Bits : Pointer;
 Pitch: Integer;
 Index: Integer;
 Width: Integer;
 Convert : Boolean;
 LinePtr : Pointer;
 LineConv: TLineConvFunc;
begin
 Result:= False;

 Size:= GetSizeOfLevel(Level);
 if (Size = ZeroPoint2px) then Exit;

 LockRect(nil, Level, Bits, Pitch);
 if (Bits = nil)or(Pitch < 1) then Exit;

 Convert := (Format <> COLOR_A8R8G8B8)and(Format <> COLOR_X8R8G8B8);
 LineConv:= GetLineConv32toX(Format);

 Width:= Min2(Size.x, Buffer.Width);

 for Index:= 0 to Min2(Size.y, Buffer.Height) - 1 do
  begin
   LinePtr:= Pointer(Integer(Bits) + (Pitch * Index));

   if (not Convert) then
    begin
     Move(Buffer.Scanline[Index]^, LinePtr^, Width * 4);
    end else
    begin
     LineConv(Buffer.Scanline[Index], LinePtr, Width);
    end;
  end;

 UnlockRect(nil, Level);
 Result:= True;
end;

//---------------------------------------------------------------------------
function TDX7Texture.MakeMipmap(DestNo, SrcNo: Integer): Boolean;
var
 InBuf, OutBuf: TSystemSurface;
begin
 Result:= False;

 InBuf:= TSystemSurface.Create();

 if (not GetPixelData(SrcNo, InBuf)) then
  begin
   InBuf.Free();
   Exit;
  end;

 OutBuf:= TSystemSurface.Create();
 OutBuf.Shrink2x(InBuf);

 InBuf.Free();

 Result:= SetPixelData(DestNo, OutBuf);

 OutBuf.Free();
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.UpdateMipmaps();
var
 MipNo : Integer;
begin
 for MipNo:= 0 to FSurfaceDesc.dwMipMapCount - 2 do
  if (not MakeMipmap(MipNo + 1, MipNo)) then Break;
end;

//---------------------------------------------------------------------------
function TDX7Texture.BeginDrawTo(): Boolean;
var
 Res: Integer;
begin
 Result:= (FSurface <> nil)and(Device7 <> nil);
 if (not Result) then Exit;

 Result:= Succeeded(Device7.GetRenderTarget(PrevTarget));
 if (not Result) then Exit;

 Res:= Device7.SetRenderTarget(FSurface, 0);

{ if (Res = DDERR_INVALIDSURFACETYPE) then
  OutputDebugString(PChar('Invalid Surface Type'));

 if (Res = DDERR_INVALIDPARAMS) then
  OutputDebugString(PChar('Invalid Parameters'));

 OutputDebugString(PChar(DDErrorString(Res)));}

 Result:= Succeeded(Res);
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.EndDrawTo();
begin
 if (PrevTarget <> nil)and(Device7 <> nil) then
  begin
   Device7.SetRenderTarget(PrevTarget, 0);
   PrevTarget:= nil;
  end;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.HandleDeviceLost();
begin
 if (FSurfaceDesc.ddsCaps.dwCaps and DDSCAPS_3DDEVICE > 0)and
  (FSurface <> nil) then
  FSurface:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Texture.HandleDeviceReset();
begin
 if (FSurfaceDesc.ddsCaps.dwCaps and DDSCAPS_3DDEVICE > 0)and
  (FSurface = nil)and(DirectDraw <> nil) then
  begin
   if (Succeeded(DirectDraw.CreateSurface(FSurfaceDesc, FSurface, nil))) then
    FSurface.GetSurfaceDesc(FSurfaceDesc);
  end;
end;

//---------------------------------------------------------------------------
end.

unit DX7Devices;
//---------------------------------------------------------------------------
// DX7Devices.pas                                       Modified: 04-Nov-2007
// DirectDraw + Direct3D devices using DirectX 7.0               Version 1.01
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
// The Original Code is DX7Devices.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, DirectDraw7, Direct3D7, Classes, AbstractDevices, AsphyreImages;

//---------------------------------------------------------------------------

// Remove the dot to enable debug mode messages.
{.$define DebugMode}

// Remove the dot to prevent any window changes made by DirectDraw.
{.$define NoWindowChanges}

// Remove the dot to preserve FPU state.
{.$define PreserveFPU}

// Remove the dot to enable multi-threading mode.
{.$define EnableMultithread}

//---------------------------------------------------------------------------
type
 TCurrentDeviceState = (cdsOkay, cdsLost, cdsNeedReset);

//---------------------------------------------------------------------------
 TDX7Device = class(TAsphyreDevice)
 private
  FrontBuffer: IDirectDrawSurface7;
  BackBuffer : IDirectDrawSurface7;
  FrontDesc  : TDDSurfaceDesc2;

  LostState: Boolean;

  function SetCooperativeLevel(): Boolean;
  function SetDisplayMode(): Boolean;
  function CreateFrontBuffer(): Boolean;
  function CreateBackBuffer(): Boolean;
  function CreateClipper(): Boolean;
  function Create3DDevices(): Boolean;

  procedure FlipWindowed();
  procedure Flip();
 protected
  function InitDevice(): Boolean; override;
  procedure DoneDevice(); override;
  procedure ResetDevice(); override;

  procedure UpdateParams(); override;
  function MayRender(): Boolean; override;
  procedure RenderWith(Handler: TNotifyEvent; Background: Cardinal); override;
  procedure RenderToTarget(Handler: TNotifyEvent;
   Background: Cardinal; FillBk: Boolean); override;
 public
  constructor Create(); override;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
uses
 DX7Types, DX7Formats;

//---------------------------------------------------------------------------
// FPC/Lazarus has no "TWindowInfo", nor GetWindowInfo() methods declared.
//---------------------------------------------------------------------------
{$ifdef fpc}
type
 TWindowInfo = packed record
  cbSize: DWORD;
  rcWindow: TRect;
  rcClient: TRect;
  dwStyle: DWORD;
  dwExStyle: DWORD;
  dwOtherStuff: DWORD;
  cxWindowBorders: UINT;
  cyWindowBorders: UINT;
  atomWindowType: TAtom;
  wCreatorVersion: WORD;
 end;

//---------------------------------------------------------------------------
function GetWindowInfo(hwnd: HWND;
 var pwi: TWindowInfo): BOOL; stdcall; external 'user32.dll';
{$endif}

//---------------------------------------------------------------------------
constructor TDX7Device.Create();
begin
 inherited;

 FrontBuffer:= nil;
 BackBuffer := nil;

 FillChar(FrontDesc, SizeOf(TDDSurfaceDesc2), 0);
end;

//---------------------------------------------------------------------------
function TDX7Device.SetCooperativeLevel(): Boolean;
var
 Flags: Cardinal;
begin
 if (Windowed) then Flags:= DDSCL_NORMAL
  else Flags:= DDSCL_EXCLUSIVE or DDSCL_FULLSCREEN or DDSCL_ALLOWREBOOT;

 {$ifdef NoWindowChanges}
 Flags:= Flags or DDSCL_NOWINDOWCHANGES;
 {$endif}

 {$ifdef PreserveFPU}
 Flags:= Flags or DDSCL_FPUPRESERVE;
 {$endif}

 {$ifdef EnableMultithread}
 Flags:= Flags or DDSCL_MULTITHREADED;
 {$endif}

 Result:= Succeeded(DirectDraw.SetCooperativeLevel(WindowHandle, Flags));

 {$ifdef DebugMode}
 if (not Result) then
  OutputDebugString(PChar('DIRECTDRAW: Failed to set cooperative level.'));
 {$endif}
end;

//---------------------------------------------------------------------------
function TDX7Device.SetDisplayMode(): Boolean;
var
 BitCount: Integer;
begin
 if (not Windowed) then
  begin
   BitCount:= 32;
   if (not HighBitDepth) then BitCount:= 16;

   Result:= Succeeded(DirectDraw.SetDisplayMode(Size.x, Size.y, BitCount, 0, 0));

   // -> If failed setting 32-bit video mode, try 16-bit just in case.
   if (not Result)and(BitCount = 32) then
    Result:= Succeeded(DirectDraw.SetDisplayMode(Size.x, Size.y, 16, 0, 0));
  end else Result:= True;

 {$ifdef DebugMode}
 if (not Result) then
  OutputDebugString(PChar('DIRECTDRAW: Failed to set the new display mode.'));
 {$endif}
end;

//---------------------------------------------------------------------------
function TDX7Device.CreateFrontBuffer(): Boolean;
begin
 FillChar(FrontDesc, SizeOf(TDDSurfaceDesc2), 0);

 FrontDesc.dwSize:= SizeOf(TDDSurfaceDesc2);

 if (Windowed) then
  begin
   FrontDesc.dwFlags:= DDSD_CAPS;
   FrontDesc.ddsCaps.dwCaps:= DDSCAPS_PRIMARYSURFACE;
  end else
  begin
   FrontDesc.dwFlags:= DDSD_CAPS or DDSD_BACKBUFFERCOUNT;
   FrontDesc.ddsCaps.dwCaps:= DDSCAPS_PRIMARYSURFACE or DDSCAPS_FLIP or
    DDSCAPS_COMPLEX or DDSCAPS_3DDEVICE;
   FrontDesc.dwBackBufferCount:= 1;
  end;

 Result:= Succeeded(DirectDraw.CreateSurface(FrontDesc, FrontBuffer, nil));

 {$ifdef DebugMode}
 if (not Result) then
  OutputDebugString(PChar('DIRECTDRAW: Failed to create front buffer.'));
 {$endif}

 if (Result) then
  Result:= Succeeded(FrontBuffer.GetSurfaceDesc(FrontDesc));

 {$ifdef DebugMode}
 if (not Result) then
  OutputDebugString(PChar('DIRECTDRAW: Failed to retreive front buffer capabilities.'));
 {$endif}
end;

//---------------------------------------------------------------------------
function TDX7Device.CreateBackBuffer(): Boolean;
var
 BackDesc: TDDSurfaceDesc2;
 Caps: TDDSCaps2;
begin
 FillChar(BackDesc, SizeOf(TDDSurfaceDesc2), 0);

 BackDesc.dwSize:= SizeOf(TDDSurfaceDesc2);

 if (Windowed) then
  begin
   BackDesc.dwFlags:= DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH;
   BackDesc.ddsCaps.dwCaps:= DDSCAPS_OFFSCREENPLAIN or DDSCAPS_3DDEVICE;
   BackDesc.dwWidth := Size.x;
   BackDesc.dwHeight:= Size.y;

   Result:= Succeeded(DirectDraw.CreateSurface(BackDesc, BackBuffer, nil));
  end else
  begin
   FillChar(Caps, SizeOf(TDDSCaps2), 0);

   Caps.dwCaps:= DDSCAPS_BACKBUFFER;

   Result:= Succeeded(FrontBuffer.GetAttachedSurface(Caps, BackBuffer));
  end;

 {$ifdef DebugMode}
 if (not Result) then
  OutputDebugString(PChar('DIRECTDRAW: Failed to create back buffer.'));
 {$endif}
end;

//---------------------------------------------------------------------------
function TDX7Device.CreateClipper(): Boolean;
var
 Clipper: IDirectDrawClipper;
begin
 Result:= Succeeded(DirectDraw.CreateClipper(0, Clipper, nil));
 if (not Result) then Exit;

 Clipper.SetHWnd(0, WindowHandle);
 FrontBuffer.SetClipper(Clipper);

 Clipper:= nil;
end;

//---------------------------------------------------------------------------
function TDX7Device.Create3DDevices(): Boolean;
begin
 // Step 1. Create Direct3D7 interface.
 Result:= Succeeded(DirectDraw.QueryInterface(IID_IDirect3D7, Direct3D));
 if (not Result) then
  begin
   {$ifdef DebugMode}
    OutputDebugString(PChar('DIRECT3D7: Failed to create Direct3D7 interface.'));
   {$endif}
   Exit;
  end;

 // Step 2. Create a valid 3D HAL device.
 Result:= Succeeded(Direct3D.CreateDevice(IID_IDirect3DHALDevice, BackBuffer,
  Device7));
 if (not Result) then
  begin
   Direct3D:= nil;
   {$ifdef DebugMode}
    OutputDebugString(PChar('DIRECT3D7: No Direct3D7 devices are supported.'));
   {$endif}
   Exit;
  end;
end;

//---------------------------------------------------------------------------
function TDX7Device.InitDevice(): Boolean;
begin
 Result:= (DirectDraw = nil)and(Direct3D = nil)and(Device7 = nil);
 if (not Result) then Exit;
 
 // Step 1. Create DirectDraw interface.
 Result:= Succeeded(DirectDrawCreateEx(nil, DirectDraw, IID_IDirectDraw7, nil));
 if (not Result) then
  begin
   {$ifdef DebugMode}
   if (not Result) then
    OutputDebugString(PChar('DIRECTDRAW: Failed to create DirectDraw interface.'));
   {$endif}
   Exit;
  end;

 // Step 2. Set the particular cooperative mode.
 Result:= SetCooperativeLevel();
 if (not Result) then
  begin
   DirectDraw:= nil;
   Exit;
  end;

 // Step 3. Change the current display mode.
 Result:= SetDisplayMode();
 if (not Result) then
  begin
   DirectDraw:= nil;
   Exit;
  end;

 // Step 4. Create primary surface as a Front Buffer.
 Result:= CreateFrontBuffer();
 if (not Result) then
  begin
   DirectDraw:= nil;
   Exit;
  end;

 // Step 5. Create offscreen surface as a Back Buffer.
 Result:= CreateBackBuffer();
 if (not Result) then
  begin
   FrontBuffer:= nil;
   DirectDraw:= nil;
   Exit;
  end;

 // Step 7. Create Clipper object.
 Result:= CreateClipper();
 if (not Result) then
  begin
   BackBuffer := nil;
   FrontBuffer:= nil;
   DirectDraw := nil;
   Exit;
  end;

 // Step 6. Create other devices required for 3D rendering.
 Result:= Create3DDevices();
 if (not Result) then
  begin
   BackBuffer := nil;
   FrontBuffer:= nil;
   DirectDraw := nil;
   Exit;
  end;

 // Step 7. Enumerate texture formats. 
 DXFormats.Enumerate();

 LostState:= False;
end;

//---------------------------------------------------------------------------
procedure TDX7Device.DoneDevice();
begin
 Device7    := nil;
 Direct3D   := nil;
 BackBuffer := nil;
 FrontBuffer:= nil;

 if (DirectDraw <> nil)and(not Windowed) then DirectDraw.RestoreDisplayMode();

 DirectDraw:= nil;
end;

//---------------------------------------------------------------------------
procedure TDX7Device.ResetDevice();
begin
 FrontBuffer._Restore();
 BackBuffer._Restore();
end;

//---------------------------------------------------------------------------
function TDX7Device.MayRender(): Boolean;
var
 Res: HResult;
 IsLost, NeedReset: Boolean;
begin
 Res   := DirectDraw.TestCooperativeLevel();
 IsLost:= Failed(Res);

 NeedReset:= ((LostState)and(not IsLost))or((Windowed)and(Res = DDERR_WRONGMODE));

 // Case 1. The device has been lost.
 if (IsLost)and(not LostState) then
  begin
   OutputDebugString(PChar('DIRECT3D7: The device has been lost.'));
   LostState:= True;
   Result:= False;
   Exit;
  end;

 // Case 2. The device has been recovered.
 if (LostState)and(not IsLost) then
  begin
   OutputDebugString(PChar('DIRECT3D7: The device has been recovered.'));
   Reset();
   LostState:= False;
   Result:= True;
   Exit;
  end;

 // Case 3. The device is lost, but may be recovered (later on).
 if (IsLost)and(NeedReset) then
  begin
   OutputDebugString(PChar('DIRECT3D7: The device might be recovered.'));
   Reset();
   LostState:= False;
   Result:= False;
   Exit;
  end;

 // Case 4. The device is still lost.
 if (IsLost) then
  begin
   OutputDebugString(PChar('DIRECT3D7: The device is still lost.'));
   Result:= False;
   Exit;
  end;

 // Case 5. The device is operational.
 Result:= True;
end;

//---------------------------------------------------------------------------
procedure TDX7Device.UpdateParams();
begin
 Finalize();
 Initialize();
end;

//---------------------------------------------------------------------------
procedure TDX7Device.FlipWindowed();
var
 Info: TWindowInfo;
begin
 FillChar(Info, SizeOf(TWindowInfo), 0);
 Info.cbSize:= SizeOf(TWindowInfo);

 if (not GetWindowInfo(WindowHandle, Info)) then Exit;

 if (VSync) then DirectDraw.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0);

 FrontBuffer.Blt(@Info.rcClient, BackBuffer, nil, DDBLT_WAIT, nil);
end;

//---------------------------------------------------------------------------
procedure TDX7Device.Flip();
begin
 if (VSync) then FrontBuffer.Flip(nil, DDFLIP_WAIT)
  else FrontBuffer.Flip(nil, DDFLIP_WAIT or DDFLIP_NOVSYNC);
end;

//---------------------------------------------------------------------------
procedure TDX7Device.RenderWith(Handler: TNotifyEvent; Background: Cardinal);
begin
 Device7.Clear(0, nil, D3DCLEAR_TARGET, Background, 0.0, 0);

 if (Succeeded(Device7.BeginScene())) then
  begin
   EventBeginScene.Notify(Self, nil);

   Handler(Self);

   EventEndScene.Notify(Self, nil);
   Device7.EndScene();
  end;

 if (Windowed) then FlipWindowed() else Flip();
end;

//---------------------------------------------------------------------------
procedure TDX7Device.RenderToTarget(Handler: TNotifyEvent; Background: Cardinal;
 FillBk: Boolean);
begin
 if (FillBk) then
  Device7.Clear(0, nil, D3DCLEAR_TARGET, Background, 0.0, 0);

 if (Succeeded(Device7.BeginScene())) then
  begin
   EventBeginScene.Notify(Self, nil);

   Handler(Self);

   EventEndScene.Notify(Self, nil);
   Device7.EndScene();
  end;
end;

//---------------------------------------------------------------------------
end.

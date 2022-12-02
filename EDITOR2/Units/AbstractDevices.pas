unit AbstractDevices;
//---------------------------------------------------------------------------
// AbstractDevices.pas                                  Modified: 04-Nov-2007
// Asphyre Device Abstract declaration                           Version 1.01
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
// The Original Code is AbstractDevices.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// M. Sc. Yuriy Kotsarenko. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, Classes, SysUtils, EventProviders, Vectors2px, AbstractTextures,
 AsphyreImages;

//---------------------------------------------------------------------------
type
 TAsphyreDevice = class
 private
  FSize    : TPoint2px;
  FWindowed: Boolean;
  FVSync   : Boolean;
  FActive  : Boolean;

  FWindowHandle: THandle;
  FHighBitDepth: Boolean;

  procedure SetSize(const Value: TPoint2px);
  procedure SetVSync(const Value: Boolean);
  procedure SetWindowed(const Value: Boolean);
  procedure SetWindowHandle(const Value: THandle);
  procedure SetHighBitDepth(const Value: Boolean);
 protected
  function InitDevice(): Boolean; virtual; abstract;
  procedure DoneDevice(); virtual; abstract;
  procedure ResetDevice(); virtual; abstract;

  procedure UpdateParams(); virtual; abstract;
  function MayRender(): Boolean; virtual; abstract;
  procedure RenderWith(Handler: TNotifyEvent;
   Background: Cardinal); virtual; abstract;
  procedure RenderToTarget(Handler: TNotifyEvent;
   Background: Cardinal; FillBk: Boolean); virtual; abstract;
 public
  property Active: Boolean read FActive;

  property Size    : TPoint2px read FSize write SetSize;
  property Windowed: Boolean read FWindowed write SetWindowed;
  property VSync   : Boolean read FVSync write SetVSync;

  property WindowHandle: THandle read FWindowHandle write SetWindowHandle;
  property HighBitDepth: Boolean read FHighBitDepth write SetHighBitDepth;

  function Initialize(): Boolean;
  procedure Finalize();

  procedure Render(Handler: TNotifyEvent; Background: Cardinal);
  procedure RenderTo(Handler: TNotifyEvent; Background: Cardinal;
   FillBk: Boolean; Image: TAsphyreImage; TextureNo: Integer = 0);
  procedure Reset();

  constructor Create(); virtual;
  destructor Destroy(); override;
 end;

//---------------------------------------------------------------------------
// Events related to device function.
//---------------------------------------------------------------------------
var
 EventDeviceCreate : TEventProvider = nil;
 EventDeviceDestroy: TEventProvider = nil;

//---------------------------------------------------------------------------
 EventDeviceReset  : TEventProvider = nil;
 EventDeviceLost   : TEventProvider = nil;

//---------------------------------------------------------------------------
 EventBeginScene   : TEventProvider = nil;
 EventEndScene     : TEventProvider = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
constructor TAsphyreDevice.Create();
begin
 inherited;

 FSize    := Point2px(800, 600);
 FWindowed:= True;
 FVSync   := False;

 FWindowHandle:= 0;
 FHighBitDepth:= True;
end;

//---------------------------------------------------------------------------
destructor TAsphyreDevice.Destroy();
begin
 if (FActive) then Finalize();
 
 inherited;
end;

//---------------------------------------------------------------------------
function TAsphyreDevice.Initialize(): Boolean;
begin
 Result:= (not FActive)and(FWindowHandle <> 0);
 if (not Result) then Exit;

 Result:= InitDevice();
 if (not Result) then Exit;

 FActive:= True;

 EventDeviceCreate.Notify(Self, @Result);
 if (not Result) then
  begin
   Finalize();
   Exit;
  end;

 EventDeviceReset.Notify(Self, @Result);
 if (not Result) then
  begin
   Finalize();
   Exit;
  end;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Finalize();
begin
 if (not FActive) then Exit;

 EventDeviceLost.Notify(Self, nil);
 EventDeviceDestroy.Notify(Self, nil);

 DoneDevice();

 FActive:= False;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.SetSize(const Value: TPoint2px);
begin
 FSize:= Value;

 if (FActive) then UpdateParams();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.SetVSync(const Value: Boolean);
begin
 FVSync:= Value;

 if (FActive) then UpdateParams();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.SetWindowed(const Value: Boolean);
begin
 FWindowed:= Value;

 if (FActive) then UpdateParams();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.SetWindowHandle(const Value: THandle);
begin
 if (not FActive) then FWindowHandle:= Value;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.SetHighBitDepth(const Value: Boolean);
begin
 if (not FActive) then FHighBitDepth:= Value;
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Render(Handler: TNotifyEvent; Background: Cardinal);
begin
 if (FActive)and(MayRender()) then
  RenderWith(Handler, Background)
   else SleepEx(5, True);
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.RenderTo(Handler: TNotifyEvent; Background: Cardinal;
 FillBk: Boolean; Image: TAsphyreImage; TextureNo: Integer = 0);
var
 Texture: TAsphyreTexture;
begin
 if (not FActive)or(not MayRender())or(Image = nil) then Exit;

 Texture:= Image.Texture[TextureNo];
 if (Texture = nil) then Exit;

 if (not Texture.BeginDrawTo()) then Exit;

 RenderToTarget(Handler, Background, FillBk);

 Texture.EndDrawTo();
end;

//---------------------------------------------------------------------------
procedure TAsphyreDevice.Reset();
begin
 EventDeviceLost.Notify(Self, nil);

 ResetDevice();

 EventDeviceReset.Notify(Self, nil);
end;

//---------------------------------------------------------------------------
initialization
 EventDeviceCreate := TEventProvider.Create();
 EventDeviceDestroy:= TEventProvider.Create();
 EventDeviceReset  := TEventProvider.Create();
 EventDeviceLost   := TEventProvider.Create();
 EventBeginScene   := TEventProvider.Create();
 EventEndScene     := TEventProvider.Create();

//---------------------------------------------------------------------------
finalization
 FreeAndNil(EventEndScene);
 FreeAndNil(EventBeginScene);
 FreeAndNil(EventDeviceLost);
 FreeAndNil(EventDeviceReset);
 FreeAndNil(EventDeviceDestroy);
 FreeAndNil(EventDeviceCreate);

//---------------------------------------------------------------------------
end.

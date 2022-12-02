{******************************************************************************}
{*                                                                            *}
{*  Copyright (C) Microsoft Corporation.  All Rights Reserved.                *}
{*                                                                            *}
{*  Files:      XInput.h                                                      *}
{*  Content:    This module defines XBOX controller APIs                      *}
{*              and constansts for the Windows platform.                      *}
{*                                                                            *}
{*  DirectX 9.0 Delphi / FreePascal adaptation by Alexey Barkovoy             *}
{*  E-Mail: directx@clootie.ru                                                *}
{*                                                                            *}
{*  Latest version can be downloaded from:                                    *}
{*    http://www.clootie.ru                                                   *}
{*    http://sourceforge.net/projects/delphi-dx9sdk                           *}
{*                                                                            *}
{*----------------------------------------------------------------------------*}
{*  $Id: XInput.pas,v 1.1 2005/10/10 19:26:27 clootie Exp $ }
{******************************************************************************}
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
{******************************************************************************}

{$MINENUMSIZE 4}
{$ALIGN ON}

unit XInput;

interface

(*$HPPEMIT '#include "XInput.h"' *)

uses
  Windows;

const
  // Current name of the DLL shipped in the same SDK as this header.
  // The name reflects the current version
  XINPUT_DLL_A  = 'xinput9_1_0.dll';
  {$EXTERNALSYM XINPUT_DLL_A}
  XINPUT_DLL_W  = 'xinput9_1_0.dll';
  {$EXTERNALSYM XINPUT_DLL_W}
  XINPUT_DLL = XINPUT_DLL_A;
  {$EXTERNALSYM XINPUT_DLL}

  //
  // Device types available in XINPUT_CAPABILITIES
  //
  XINPUT_DEVTYPE_GAMEPAD          = $01;
  {$EXTERNALSYM XINPUT_DEVTYPE_GAMEPAD}

  //
  // Device subtypes available in XINPUT_CAPABILITIES
  //
  XINPUT_DEVSUBTYPE_GAMEPAD       = $01;
  {$EXTERNALSYM XINPUT_DEVSUBTYPE_GAMEPAD}

  //
  // Flags for XINPUT_CAPABILITIES
  //
  XINPUT_CAPS_VOICE_SUPPORTED     = $0004;
  {$EXTERNALSYM XINPUT_CAPS_VOICE_SUPPORTED}

  //
  // Constants for gamepad buttons
  //
  XINPUT_GAMEPAD_DPAD_UP          = $0001;
  {$EXTERNALSYM XINPUT_GAMEPAD_DPAD_UP}
  XINPUT_GAMEPAD_DPAD_DOWN        = $0002;
  {$EXTERNALSYM XINPUT_GAMEPAD_DPAD_DOWN}
  XINPUT_GAMEPAD_DPAD_LEFT        = $0004;
  {$EXTERNALSYM XINPUT_GAMEPAD_DPAD_LEFT}
  XINPUT_GAMEPAD_DPAD_RIGHT       = $0008;
  {$EXTERNALSYM XINPUT_GAMEPAD_DPAD_RIGHT}
  XINPUT_GAMEPAD_START            = $0010;
  {$EXTERNALSYM XINPUT_GAMEPAD_START}
  XINPUT_GAMEPAD_BACK             = $0020;
  {$EXTERNALSYM XINPUT_GAMEPAD_BACK}
  XINPUT_GAMEPAD_LEFT_THUMB       = $0040;
  {$EXTERNALSYM XINPUT_GAMEPAD_LEFT_THUMB}
  XINPUT_GAMEPAD_RIGHT_THUMB      = $0080;
  {$EXTERNALSYM XINPUT_GAMEPAD_RIGHT_THUMB}
  XINPUT_GAMEPAD_LEFT_SHOULDER    = $0100;
  {$EXTERNALSYM XINPUT_GAMEPAD_LEFT_SHOULDER}
  XINPUT_GAMEPAD_RIGHT_SHOULDER   = $0200;
  {$EXTERNALSYM XINPUT_GAMEPAD_RIGHT_SHOULDER}
  XINPUT_GAMEPAD_A                = $1000;
  {$EXTERNALSYM XINPUT_GAMEPAD_A}
  XINPUT_GAMEPAD_B                = $2000;
  {$EXTERNALSYM XINPUT_GAMEPAD_B}
  XINPUT_GAMEPAD_X                = $4000;
  {$EXTERNALSYM XINPUT_GAMEPAD_X}
  XINPUT_GAMEPAD_Y                = $8000;
  {$EXTERNALSYM XINPUT_GAMEPAD_Y}

  //
  // Gamepad thresholds
  //
  XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  = 7849;
  {$EXTERNALSYM XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE}
  XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE = 8689;
  {$EXTERNALSYM XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE}
  XINPUT_GAMEPAD_TRIGGER_THRESHOLD    = 30;
  {$EXTERNALSYM XINPUT_GAMEPAD_TRIGGER_THRESHOLD}

  //
  // Flags to pass to XInputGetCapabilities
  //
  XINPUT_FLAG_GAMEPAD             = $00000001;
  {$EXTERNALSYM XINPUT_FLAG_GAMEPAD}


type

  //
  // Structures used by XInput APIs
  //
  PXInputGamepad = ^TXInputGamepad;
  _XINPUT_GAMEPAD = record
    wButtons:         Word;
    bLeftTrigger:     Byte;
    bRightTrigger:    Byte;
    sThumbLX:         Smallint;
    sThumbLY:         Smallint;
    sThumbRX:         Smallint;
    sThumbRY:         Smallint;
  end;
  {$EXTERNALSYM _XINPUT_GAMEPAD}
  XINPUT_GAMEPAD = _XINPUT_GAMEPAD;
  {$EXTERNALSYM XINPUT_GAMEPAD}
  TXInputGamepad = XINPUT_GAMEPAD;

  PXInputState = ^TXInputState;
  _XINPUT_STATE = record
    dwPacketNumber:   DWORD;
    Gamepad:          TXInputGamepad;
  end;
  {$EXTERNALSYM _XINPUT_STATE}
  XINPUT_STATE = _XINPUT_STATE;
  {$EXTERNALSYM XINPUT_STATE}
  TXInputState = XINPUT_STATE;

  PXInputVibration = ^TXInputVibration;
  _XINPUT_VIBRATION = record
    wLeftMotorSpeed:  Word;
    wRightMotorSpeed: Word;
  end;
  {$EXTERNALSYM _XINPUT_VIBRATION}
  XINPUT_VIBRATION = _XINPUT_VIBRATION;
  {$EXTERNALSYM XINPUT_VIBRATION}
  TXInputVibration = _XINPUT_VIBRATION;

  PXInputCapabilities = ^TXInputCapabilities;
  _XINPUT_CAPABILITIES = record
    _Type:            Byte;
    SubType:          Byte;
    Flags:            Word;
    Gamepad:          TXInputGamepad;
    Vibration:        TXInputVibration;
  end;
  {$EXTERNALSYM _XINPUT_CAPABILITIES}
  XINPUT_CAPABILITIES = _XINPUT_CAPABILITIES;
  {$EXTERNALSYM XINPUT_CAPABILITIES}
  TXInputCapabilities = _XINPUT_CAPABILITIES;


//
// XInput APIs
//

function XInputGetState(
    dwUserIndex: DWORD;      // [in] Index of the gamer associated with the device
    out pState: TXInputState // [out] Receives the current state
 ): DWORD; stdcall; external XINPUT_DLL;
{$EXTERNALSYM XInputGetState}

function XInputSetState(
    dwUserIndex: DWORD;                 // [in] Index of the gamer associated with the device
    const pVibration: TXInputVibration  // [in, out] The vibration information to send to the controller
 ): DWORD; stdcall; external XINPUT_DLL;
{$EXTERNALSYM XInputSetState}

function XInputGetCapabilities(
    dwUserIndex: DWORD;                     // [in] Index of the gamer associated with the device
    dwFlags: DWORD;                         // [in] Input flags that identify the device type
    out pCapabilities: TXInputCapabilities  // [out] Receives the capabilities
 ): DWORD; stdcall; external XINPUT_DLL;
{$EXTERNALSYM XInputGetCapabilities}

function XInputGetDSoundAudioDeviceGuids(
    dwUserIndex: DWORD;           // [in] Index of the gamer associated with the device
    out pDSoundRenderGuid: TGUID; // [out] DSound device ID for render
    out pDSoundCaptureGuid: TGUID // [out] DSound device ID for capture
 ): DWORD; stdcall; external XINPUT_DLL;
{$EXTERNALSYM XInputGetDSoundAudioDeviceGuids}


implementation

end.

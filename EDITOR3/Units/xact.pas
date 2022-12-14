{******************************************************************************}
{*                                                                            *}
{*  Copyright (C) Microsoft Corporation.  All Rights Reserved.                *}
{*                                                                            *}
{*  Files:      xact.h, xact2wb.h, xact3D.h                                   *}
{*  Content:    XACT public interfaces, functions and data types;             *}
{*              XACT 2 wave bank definitions; XACT 3D support.                *}
{*                                                                            *}
{*  DirectX 9.0 Delphi / FreePascal adaptation by Alexey Barkovoy             *}
{*  E-Mail: directx@clootie.ru                                                *}
{*                                                                            *}
{*  Latest version can be downloaded from:                                    *}
{*    http://www.clootie.ru                                                   *}
{*    http://sourceforge.net/projects/delphi-dx9sdk                           *}
{*                                                                            *}
{*----------------------------------------------------------------------------*}
{*  $Id: xact.pas,v 1.6 2006/02/11 19:57:28 clootie Exp $ }
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

unit xact;

interface

(*$HPPEMIT '#include "xact.h"' *)
(*$HPPEMIT '#include "xact2wb.h"' *)
(*$HPPEMIT '#include "xact3D.h"' *)

uses
  Windows, ActiveX, X3DAudio;



//------------------------------------------------------------------------------
// XACT class and interface IDs
//------------------------------------------------------------------------------
 // XACT COM support only exists on Windows
const
  CLSID_XACTEngine         : TGUID = '{0AA000AA-F404-11D9-BD7A-0010DC4F8F81}';
  CLSID_XACTAuditionEngine : TGUID = '{0AA000AB-F404-11D9-BD7A-0010DC4F8F81}';
  CLSID_XACTDebugEngine    : TGUID = '{0AA000AC-F404-11D9-BD7A-0010DC4F8F81}';
  {$EXTERNALSYM CLSID_XACTEngine}
  {$EXTERNALSYM CLSID_XACTAuditionEngine}
  {$EXTERNALSYM CLSID_XACTDebugEngine}


//------------------------------------------------------------------------------
// Forward Declarations
//------------------------------------------------------------------------------

const
  XACT_RENDERER_ID_LENGTH    = $ff;   // Maximum number of characters allowed in the renderer ID
  XACT_RENDERER_NAME_LENGTH  = $ff;   // Maximum number of characters allowed in the renderer display name.

type
  IXACTSoundBank = class;
  IXACTWaveBank = class;
  IXACTCue = class;

  PXACT_Notification = ^TXACT_Notification;
  PIXACTCue = ^IXACTCue;


//------------------------------------------------------------------------------
// Typedefs
//------------------------------------------------------------------------------

  TXACTIndex = Word;            // All normal indices
  TXACTNotificationType = Byte; // Notification type
  TXACTVariableValue = Single;  // Variable value
  TXACTVariableIndex = Word;    // Variable index
  TXACTCategory = Word;         // Sound category
  TXACTChannel = Byte;          // Audio channel
  TXACTVolume = Single;         // Volume value

  PXACTIndex = ^TXACTIndex;
  PXACTNotificationType = ^TXACTNotificationType;
  PXACTVariableValue = ^TXACTVariableValue;
  PXACTVariableIndex = ^TXACTVariableIndex;
  PXACTCategory = ^TXACTCategory;
  PXACTChannel = ^TXACTChannel;
  PXACTVolume = ^TXACTVolume;

  XACTINDEX = TXACTIndex;
  XACTNOTIFICATIONTYPE = TXACTNotificationType;
  XACTVARIABLEVALUE = TXACTVariableValue;
  XACTVARIABLEINDEX = TXACTVariableIndex;
  XACTCATEGORY = TXACTCategory;
  XACTCHANNEL = TXACTChannel;
  XACTVOLUME = TXACTVolume;

  {$NODEFINE XACTINDEX}
  {$NODEFINE XACTNOTIFICATIONTYPE}
  {$NODEFINE XACTVARIABLEVALUE}
  {$NODEFINE XACTVARIABLEINDEX}
  {$NODEFINE XACTCATEGORY}
  {$NODEFINE XACTCHANNEL}
  {$NODEFINE XACTVOLUME}
  {$NODEFINE TXACTINDEX}
  {$NODEFINE TXACTNOTIFICATIONTYPE}
  {$NODEFINE TXACTVARIABLEVALUE}
  {$NODEFINE TXACTVARIABLEINDEX}
  {$NODEFINE TXACTCATEGORY}
  {$NODEFINE TXACTCHANNEL}
  {$NODEFINE TXACTVOLUME}
  {$HPPEMIT 'typedef XACTINDEX TXACTIndex}
  {$HPPEMIT 'typedef XACTNOTIFICATIONTYPE TXACTNotificationType}
  {$HPPEMIT 'typedef XACTVARIABLEVALUE TXACTVariableValue}
  {$HPPEMIT 'typedef XACTVARIABLEINDEX TXACTVariableIndex}
  {$HPPEMIT 'typedef XACTCATEGORY TXACTCategory}
  {$HPPEMIT 'typedef XACTCHANNEL TXACTChanel}
  {$HPPEMIT 'typedef XACTVOLUME TXACTVolume}



//------------------------------------------------------------------------------
// XACT Parameters
//------------------------------------------------------------------------------

  {$NODEFINE TXACT_ReadFile_Callback}
  TXACT_ReadFile_Callback = function (hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
      lpNumberOfBytesRead: PDWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  {$NODEFINE TXACT_GetOverlappedResult_Callback}
  TXACT_GetOverlappedResult_Callback = function (hFile: THandle; lpOverlapped: POverlapped;
      lpNumberOfBytesTransferred: PDWORD; bWait: BOOL): BOOL; stdcall;

  PXACT_FileIO_Callbacks = ^TXACT_FileIO_Callbacks;
  XACT_FILEIO_CALLBACKS = record
    readFileCallback: TXACT_ReadFile_Callback;
    getOverlappedResultCallback: TXACT_GetOverlappedResult_Callback;
  end;
  {$EXTERNALSYM XACT_FILEIO_CALLBACKS}
  TXACT_FileIO_Callbacks = XACT_FILEIO_CALLBACKS;

  // The callback that receives the notifications.
  TXACT_Notification_Callback = procedure (const pNotification: PXACT_Notification); stdcall;
  {$EXTERNALSYM TXACT_Notification_Callback}

  // Renderer details
  PXACT_Renderer_Details = ^TXACT_Renderer_Details;
  XACT_RENDERER_DETAILS = record
    rendererID: array[0..XACT_RENDERER_ID_LENGTH-1] of WideChar;       // The string ID for the rendering device.
    displayName: array[0..XACT_RENDERER_NAME_LENGTH-1] of WideChar;    // A friendly name suitable for display to a human.
    defaultDevice: BOOL;                                               // Set to TRUE if this device is the primary audio device on the system.
  end;
  {$EXTERNALSYM XACT_RENDERER_DETAILS}
  TXACT_Renderer_Details = XACT_RENDERER_DETAILS;
  TXACTRendererDetails = XACT_RENDERER_DETAILS;
  PXACTRendererDetails = PXACT_Renderer_Details;

  // Runtime (engine) parameters
  PXACT_Runtime_Parameters = ^TXACT_Runtime_Parameters;
  XACT_RUNTIME_PARAMETERS = record
    lookAheadTime:                 DWORD;   // Time in ms
    pGlobalSettingsBuffer:         Pointer; // Buffer containing the global settings file
    globalSettingsBufferSize:      DWORD;   // Size of global settings buffer
    globalSettingsFlags:           DWORD;   // Flags for global settings
    globalSettingsAllocAttributes: DWORD;   // Global settings buffer allocation attributes (see XMemAlloc)
    fileIOCallbacks:               TXACT_FileIO_Callbacks;      // File I/O callbacks
    fnNotificationCallback:        TXACT_Notification_Callback; // Callback that receives notifications.
    pRendererID:                   PWideChar;                   // Ptr to the ID for the audio renderer the engine should connect to.
  end;
  {$EXTERNALSYM XACT_RUNTIME_PARAMETERS}
  TXACT_Runtime_Parameters = XACT_RUNTIME_PARAMETERS;

//------------------------------------------------------------------------------
// Streaming Parameters
//------------------------------------------------------------------------------

  PXACT_Wavebank_Streaming_Parameters = ^TXACT_Wavebank_Streaming_Parameters;
  XACT_WAVEBANK_STREAMING_PARAMETERS = record
    file_: THandle;         // File handle associated with wavebank data
    offset: DWORD;          // Offset within file of wavebank header (must be sector aligned)
    flags: DWORD;           // Flags (none currently)
    packetSize: Word;       // Stream packet size (in sectors) to use for each stream (min = 2)
                            //   number of sectors (DVD = 2048 bytes: 2 = 4096, 3 = 6144, 4 = 8192 etc.)
                            //   optimal DVD size is a multiple of 16 (DVD block = 16 DVD sectors)
  end;
  {$EXTERNALSYM XACT_WAVEBANK_STREAMING_PARAMETERS}
  TXACT_Wavebank_Streaming_Parameters = XACT_WAVEBANK_STREAMING_PARAMETERS;

//------------------------------------------------------------------------------
// Cue Properties (Xbox Only)
//------------------------------------------------------------------------------
 // XBOX

//------------------------------------------------------------------------------
// Channel Mapping / Speaker Panning
//------------------------------------------------------------------------------

  PXACTChannelMapEntry = ^TXACTChannelMapEntry;
  XACTCHANNELMAPENTRY = record
    InputChannel: TXACTChannel;
    OutputChannel: TXACTChannel;
    Volume: TXACTVolume;
  end;
  {$EXTERNALSYM XACTCHANNELMAPENTRY}
  TXACTChannelMapEntry = XACTCHANNELMAPENTRY;


  PXACTChannelMap = ^TXACTChannelMap;
  XACTCHANNELMAP = record
    EntryCount: TXACTChannel;
    paEntries: PXACTChannelMapEntry;
  end;
  {$EXTERNALSYM XACTCHANNELMAP}
  TXACTChannelMap = XACTCHANNELMAP;

  PXACTChannelVolumeEntry = ^TXACTChannelVolumeEntry;
  XACTCHANNELVOLUMEENTRY = record
    EntryIndex: TXACTChannel;
    Volume: TXACTVolume;
  end;
  {$EXTERNALSYM XACTCHANNELVOLUMEENTRY}
  TXACTChannelVolumeEntry = XACTCHANNELVOLUMEENTRY;

  PXACTChannelVolume = ^TXACTChannelVolume;
  XACTCHANNELVOLUME = record
    EntryCount: TXACTChannel;
    paEntries: PXACTChannelVolumeEntry;
  end;
  {$EXTERNALSYM XACTCHANNELVOLUME}
  TXACTChannelVolume = XACTCHANNELVOLUME;


//------------------------------------------------------------------------------
// Notifications
//------------------------------------------------------------------------------

// Pack the notification structures
// Original C++ header: #pragma pack(push, 1)

  // Notification description used for registering, un-registering and flushing notifications
  PXACT_Notification_Description = ^TXACT_Notification_Description;
  XACT_NOTIFICATION_DESCRIPTION = packed record
    type_: TXACTNotificationType;          // Notification type
    flags: Byte;                           // Flags
    pSoundBank: IXACTSoundBank;            // SoundBank instance
    pWaveBank: IXACTWaveBank;              // WaveBank instance
    pCue: IXACTCue;                        // Cue instance
    cueIndex: TXACTIndex;                  // Cue index
    pvContext: Pointer;                    // User context (optional)
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_DESCRIPTION}
  TXACT_Notification_Description = XACT_NOTIFICATION_DESCRIPTION;

  // Notification structure for all XACTNOTIFICATIONTYPE_CUE* notifications
  PXACT_Notification_Cue = ^TXACT_Notification_Cue;
  XACT_NOTIFICATION_CUE = packed record
    cueIndex:   TXACTIndex;     // Cue index
    pSoundBank: IXACTSoundBank; // SoundBank instance
    pCue:       IXACTCue;       // Cue instance
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_CUE}
  TXACT_Notification_Cue = XACT_NOTIFICATION_CUE;


  // Notification structure for all XACTNOTIFICATIONTYPE_MARKER* notifications
  PXACT_Notification_Marker = ^TXACT_Notification_Marker;
  XACT_NOTIFICATION_MARKER = packed record
    cueIndex:   TXACTIndex;     // Cue index
    pSoundBank: IXACTSoundBank; // SoundBank instance
    pCue:       IXACTCue;       // Cue instance
    marker:     DWORD;          // Marker value
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_MARKER}
  TXACT_Notification_Marker = XACT_NOTIFICATION_MARKER;

  // Notification structure for all XACTNOTIFICATIONTYPE_SOUNDBANK* notifications
  PXACT_Notification_SoundBank = ^TXACT_Notification_SoundBank;
  XACT_NOTIFICATION_SOUNDBANK = packed record
    pSoundBank: IXACTSoundBank; // SoundBank instance
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_SOUNDBANK}
  TXACT_Notification_SoundBank = XACT_NOTIFICATION_SOUNDBANK;


  // Notification structure for all XACTNOTIFICATIONTYPE_WAVEBANK* notifications
  PXACT_Notification_WaveBank = ^TXACT_Notification_WaveBank;
  XACT_NOTIFICATION_WAVEBANK = packed record
    pWaveBank: IXACTWaveBank;  // WaveBank instance
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_WAVEBANK}
  TXACT_Notification_WaveBank = XACT_NOTIFICATION_WAVEBANK;


  // Notification structure for all XACTNOTIFICATIONTYPE_*VARIABLE* notifications
  PXACT_Notification_Variable = ^TXACT_Notification_Variable;
  XACT_NOTIFICATION_VARIABLE = packed record
    cueIndex:        TXACTIndex;         // Cue index
    pSoundBank:      IXACTSoundBank;     // SoundBank instance
    pCue:            IXACTCue;           // Cue instance
    variableIndex:   TXACTVariableIndex; // Variable index
    variableValue:   TXACTVariableValue; // Variable value
    local:           BOOL;               // TRUE if a local variable
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_VARIABLE}
  TXACT_Notification_Variable = XACT_NOTIFICATION_VARIABLE;

  // Notification structure for all XACTNOTIFICATIONTYPE_GUI* notifications
  PXACT_Notification_GUI = ^TXACT_Notification_GUI;
  XACT_NOTIFICATION_GUI = packed record
    reserved:   DWORD; // Reserved
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_GUI}
  TXACT_Notification_GUI = XACT_NOTIFICATION_GUI;


  // Notification structure for all XACTNOTIFICATIONTYPE_WAVE* notifications
  PXACT_Notification_Wave = ^TXACT_Notification_Wave;
  XACT_NOTIFICATION_WAVE = packed record
    pWaveBank:  IXACTWaveBank;  // WaveBank
    waveIndex:  TXACTIndex;     // Wave index
    cueIndex:   TXACTIndex;     // Cue index
    pSoundBank: IXACTSoundBank; // SoundBank instance
    pCue:       IXACTCue;       // Cue instance
  end;
  {$EXTERNALSYM XACT_NOTIFICATION_WAVE}
  TXACT_Notification_Wave = XACT_NOTIFICATION_WAVE;


  // General notification structure
  XACT_NOTIFICATION = packed record
    type_: TXACTNotificationType;        // Notification type
    timeStamp: Longint;                  // Timestamp of notification (milliseconds)
    pvContext: Pointer;                  // User context (optional)
    case Byte of
      1: (cue:       TXACT_Notification_Cue);        // XACTNOTIFICATIONTYPE_CUE*
      2: (marker:    TXACT_Notification_Marker);     // XACTNOTIFICATIONTYPE_MARKER*
      3: (soundBank: TXACT_Notification_SoundBank);  // XACTNOTIFICATIONTYPE_SOUNDBANK*
      4: (waveBank:  TXACT_Notification_WaveBank);   // XACTNOTIFICATIONTYPE_WAVEBANK*
      5: (variable:  TXACT_Notification_Variable);   // XACTNOTIFICATIONTYPE_VARIABLE*
      6: (gui:       TXACT_Notification_GUI);        // XACTNOTIFICATIONTYPE_GUI*
      7: (wave:      TXACT_Notification_Wave);       // XACTNOTIFICATIONTYPE_WAVE*
  end;
  {$EXTERNALSYM XACT_NOTIFICATION}
  TXACT_Notification = XACT_NOTIFICATION;

//Original C++ header: #pragma pack(pop)


//------------------------------------------------------------------------------
// IXACTSoundBank
//------------------------------------------------------------------------------

  {$EXTERNALSYM IXACTSoundBank}
  IXACTSoundBank = class
    function GetCueIndex(szFriendlyName: PAnsiChar): TXACTIndex; virtual; stdcall; abstract;
    function Prepare(nCueIndex: TXACTIndex; dwFlags: DWORD; out ppCue: IXACTCue): HResult; virtual; stdcall; abstract;
    function Play(nCueIndex: TXACTIndex; dwFlags: DWORD; ppCue: PIXACTCue): HResult; virtual; stdcall; abstract;
    function Stop(nCueIndex: TXACTIndex; dwFlags: DWORD): HResult; virtual; stdcall; abstract;
    {$WARNINGS OFF}
    function Destroy: HResult; virtual; stdcall; abstract; //Clootie: This method is not related to Delphi TObject.Destroy
    {$WARNINGS ON}
    function GetState(out pdwState: DWORD): HResult; virtual; stdcall; abstract;
  end;


//------------------------------------------------------------------------------
// IXACTWaveBank
//------------------------------------------------------------------------------

  {$EXTERNALSYM IXACTWaveBank}
  IXACTWaveBank = class
    {$WARNINGS OFF}
    function Destroy: HResult; virtual; stdcall; abstract; //Clootie: This method is not related to Delphi TObject.Destroy
    {$WARNINGS ON}
    function GetState(out pdwState: DWORD): HResult; virtual; stdcall; abstract;
  end;


//------------------------------------------------------------------------------
// IXACTCue
//------------------------------------------------------------------------------

  {$EXTERNALSYM IXACTCue}
  IXACTCue = class
    function Play: HResult; virtual; stdcall; abstract;
    function Stop(dwFlags: DWORD): HResult; virtual; stdcall; abstract;
    function GetState(out pdwState: DWORD): HResult; virtual; stdcall; abstract;
    {$WARNINGS OFF}
    function Destroy: HResult; virtual; stdcall; abstract; //Clootie: This method is not related to Delphi TObject.Destroy
    {$WARNINGS ON}
    function GetChannelMap(pChannelMap: PXACTChannelMap; BufferSize: DWORD; pRequiredSize: PDWORD): HResult; virtual; stdcall; abstract;
    function SetChannelMap(const pChannelMap: PXACTChannelMap): HResult; virtual; stdcall; abstract;
    function GetChannelVolume(const pVolume: PXACTChannelVolume): HResult; virtual; stdcall; abstract;
    function SetChannelVolume(const pVolume: PXACTChannelVolume): HResult; virtual; stdcall; abstract;
    function SetMatrixCoefficients(uSrcChannelCount: LongWord; uDstChannelCount: LongWord; pMatrixCoefficients: PSingle): HResult; virtual; stdcall; abstract;
    function GetVariableIndex(szFriendlyName: PAnsiChar): TXACTVariableIndex; virtual; stdcall; abstract;
    function SetVariable(nIndex: TXACTVariableIndex; nValue: TXACTVariableValue): HResult; virtual; stdcall; abstract;
    function GetVariable(nIndex: TXACTVariableIndex; out nValue: TXACTVariableValue): HResult; virtual; stdcall; abstract;
    function Pause(fPause: BOOL): HResult; virtual; stdcall; abstract;
   // _XBOX
  end;


//------------------------------------------------------------------------------
// IXACTEngine
//------------------------------------------------------------------------------

// Engine flags
const XACT_FLAG_ENGINE_CREATE_MANAGEDATA  = DWORD($00000001);
{$EXTERNALSYM XACT_FLAG_ENGINE_CREATE_MANAGEDATA}
const XACT_FLAG_ENGINE_STOP_IMMEDIATE     = DWORD($00000002);
{$EXTERNALSYM XACT_FLAG_ENGINE_STOP_IMMEDIATE}

type
  {$EXTERNALSYM IXACTEngine}
  IXACTEngine = interface(IUnknown)
    ['{0AA000A0-F404-11D9-BD7A-0010DC4F8F81}']
    function GetRendererCount(out pnRendererCount: TXACTIndex): HResult; stdcall;
    function GetRendererDetails(nRendererIndex: TXACTIndex; out pRendererDetails: TXACTRendererDetails): HResult; stdcall;

    function Initialize(const pParams: TXACT_Runtime_Parameters): HResult; stdcall;
    function ShutDown: HResult; stdcall;

    function DoWork: HResult; stdcall;

    function CreateSoundBank(const pvBuffer: Pointer; dwSize: DWORD; dwFlags: DWORD; dwAllocAttributes: DWORD; out ppSoundBank: IXACTSoundBank): HResult; stdcall;
    function CreateInMemoryWaveBank(const pvBuffer: Pointer; dwSize: DWORD; dwFlags: DWORD; dwAllocAttributes: DWORD; out ppWaveBank: IXACTWaveBank): HResult; stdcall;
    function CreateStreamingWaveBank(const pParms: TXACT_Wavebank_Streaming_Parameters; out ppWaveBank: IXACTWaveBank): HResult; stdcall;

    function RegisterNotification(const pNotificationDesc: TXACT_Notification_Description): HResult; stdcall;
    function UnRegisterNotification(const pNotificationDesc: TXACT_Notification_Description): HResult; stdcall;

    function GetCategory(szFriendlyName: PAnsiChar): TXACTCategory; stdcall;
    function Stop(nCategory: TXACTCategory; dwFlags: DWORD): HResult; stdcall;
    function SetVolume(nCategory: TXACTCategory; nVolume: TXACTVolume): HResult; stdcall;
    function Pause(nCategory: TXACTCategory; fPause: BOOL): HResult; stdcall;

    function GetGlobalVariableIndex(szFriendlyName: PAnsiChar): TXACTVariableIndex; stdcall;
    function SetGlobalVariable(nIndex: TXACTVariableIndex; nValue: TXACTVariableValue): HResult; stdcall;
    function GetGlobalVariable(nIndex: TXACTVariableIndex; out nValue: TXACTVariableValue): HResult; stdcall;
  end;
  IID_IXACTEngine = IXACTEngine;
  {$EXTERNALSYM IID_IXACTEngine}


//------------------------------------------------------------------------------
// XACT API's (these are deprecated and will be removed in a future release)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Create Engine
//------------------------------------------------------------------------------

// Flags used only in XACTCreateEngine below.  These flags are valid but ignored
// when building for Xbox 360; to enable auditioning on that platform you must
// link explicitly to an auditioning version of the XACT static library.
const
  XACT_FLAG_API_AUDITION_MODE = DWORD($00000001);
  {$EXTERNALSYM XACT_FLAG_API_AUDITION_MODE}
  XACT_FLAG_API_DEBUG_MODE    = DWORD($00000002);
  {$EXTERNALSYM XACT_FLAG_API_DEBUG_MODE}

function XACTCreateEngine(dwCreationFlags: DWORD; out ppEngine: IXACTEngine): HRESULT; stdcall; // inline
{$EXTERNALSYM XACTCreateEngine}

const
  XACT_DEBUGENGINE_REGISTRY_KEY   = 'Software\Microsoft\XACT';
  XACT_DEBUGENGINE_REGISTRY_VALUE = 'DebugEngine';

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------

const
  XACTINDEX_MIN = TXACTIndex($0);
  {$EXTERNALSYM XACTINDEX_MIN}
  XACTINDEX_MAX = TXACTIndex($fffe);
  {$EXTERNALSYM XACTINDEX_MAX}
  XACTINDEX_INVALID = TXACTIndex($ffff);
  {$EXTERNALSYM XACTINDEX_INVALID}

  XACTNOTIFICATIONTYPE_MIN = TXACTNotificationType($00);
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_MIN}
  XACTNOTIFICATIONTYPE_MAX = TXACTNotificationType($ff);
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_MAX}

  XACTVARIABLEVALUE_MIN: TXACTVariableValue = -3.402823466e+38; // -FLT_MAX;
  {$EXTERNALSYM XACTVARIABLEVALUE_MIN}
  XACTVARIABLEVALUE_MAX: TXACTVariableValue = 3.402823466e+38; // FLT_MAX;
  {$EXTERNALSYM XACTVARIABLEVALUE_MAX}

  XACTVARIABLEINDEX_MIN               = TXACTVariableIndex($0000);
  {$EXTERNALSYM XACTVARIABLEINDEX_MIN}
  XACTVARIABLEINDEX_MAX               = TXACTVariableIndex($fffe);
  {$EXTERNALSYM XACTVARIABLEINDEX_MAX}
  XACTVARIABLEINDEX_INVALID           = TXACTVariableIndex($ffff);
  {$EXTERNALSYM XACTVARIABLEINDEX_INVALID}

  XACTCATEGORY_MIN     = TXACTCategory($0);
  {$EXTERNALSYM XACTCATEGORY_MIN}
  XACTCATEGORY_MAX     = TXACTCategory($fffe);
  {$EXTERNALSYM XACTCATEGORY_MAX}
  XACTCATEGORY_INVALID = TXACTCategory($ffff);
  {$EXTERNALSYM XACTCATEGORY_INVALID}

  XACTCHANNEL_MIN = TXACTChannel(0);
  {$EXTERNALSYM XACTCHANNEL_MIN}
  XACTCHANNEL_MAX = TXACTChannel($FF);
  {$EXTERNALSYM XACTCHANNEL_MAX}

  XACTVOLUME_MIN = {TXACTVolume}(0.0);
  {$EXTERNALSYM XACTVOLUME_MIN}
  XACTVOLUME_MAX = {TXACTVolume}(3.402823466e+38); // FLT_MAX;
  {$EXTERNALSYM XACTVOLUME_MAX}

  XACTPARAMETERVALUE_MIN: TXACTVariableValue = -3.402823466e+38; // -FLT_MAX;
  {$EXTERNALSYM XACTPARAMETERVALUE_MIN}
  XACTPARAMETERVALUE_MAX: TXACTVariableValue = 3.402823466e+38; // FLT_MAX;
  {$EXTERNALSYM XACTPARAMETERVALUE_MAX}

 // XBOX

  XACT_CONTENT_VERSION    = 37;
  {$EXTERNALSYM XACT_CONTENT_VERSION}

//------------------------------------------------------------------------------
// XACT Parameters
//------------------------------------------------------------------------------

  XACT_FLAG_GLOBAL_SETTINGS_MANAGEDATA = DWORD($00000001);
  {$EXTERNALSYM XACT_FLAG_GLOBAL_SETTINGS_MANAGEDATA}

//------------------------------------------------------------------------------
// Notifications
//------------------------------------------------------------------------------

  XACTNOTIFICATIONTYPE_CUEPREPARED           = TXACTNotificationType(1);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_CUEPREPARED}
  XACTNOTIFICATIONTYPE_CUEPLAY               = TXACTNotificationType(2);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_CUEPLAY}
  XACTNOTIFICATIONTYPE_CUESTOP               = TXACTNotificationType(3);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_CUESTOP}
  XACTNOTIFICATIONTYPE_CUEDESTROYED          = TXACTNotificationType(4);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_CUEDESTROYED}
  XACTNOTIFICATIONTYPE_MARKER                = TXACTNotificationType(5);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_MARKER}
  XACTNOTIFICATIONTYPE_SOUNDBANKDESTROYED    = TXACTNotificationType(6);  // None, SoundBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_SOUNDBANKDESTROYED}
  XACTNOTIFICATIONTYPE_WAVEBANKDESTROYED     = TXACTNotificationType(7);  // None, WaveBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_WAVEBANKDESTROYED}
  XACTNOTIFICATIONTYPE_LOCALVARIABLECHANGED  = TXACTNotificationType(8);  // None, SoundBank, SoundBank & cue index, cue instance
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_LOCALVARIABLECHANGED}
  XACTNOTIFICATIONTYPE_GLOBALVARIABLECHANGED = TXACTNotificationType(9);  // None
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_GLOBALVARIABLECHANGED}
  XACTNOTIFICATIONTYPE_GUICONNECTED          = TXACTNotificationType(10); // None
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_GUICONNECTED}
  XACTNOTIFICATIONTYPE_GUIDISCONNECTED       = TXACTNotificationType(11); // None
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_GUIDISCONNECTED}
  XACTNOTIFICATIONTYPE_WAVEPLAY              = TXACTNotificationType(12); // None, SoundBank, SoundBank & cue index, cue instance, WaveBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_WAVEPLAY}
  XACTNOTIFICATIONTYPE_WAVESTOP              = TXACTNotificationType(13); // None, SoundBank, SoundBank & cue index, cue instance, WaveBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_WAVESTOP}
  XACTNOTIFICATIONTYPE_WAVEBANKPREPARED      = TXACTNotificationType(14); // None, WaveBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_WAVEBANKPREPARED}
  XACTNOTIFICATIONTYPE_WAVEBANKSTREAMING_INVALIDCONTENT = TXACTNotificationType(15); // None, WaveBank
  {$EXTERNALSYM XACTNOTIFICATIONTYPE_WAVEBANKSTREAMING_INVALIDCONTENT}

  XACT_FLAG_NOTIFICATION_PERSIST = $01;
  {$EXTERNALSYM XACT_FLAG_NOTIFICATION_PERSIST}

//------------------------------------------------------------------------------
// IXACTSoundBank
//------------------------------------------------------------------------------

  XACT_FLAG_SOUNDBANK_STOP_IMMEDIATE = DWORD($00000001);
  {$EXTERNALSYM XACT_FLAG_SOUNDBANK_STOP_IMMEDIATE}

  XACT_SOUNDBANKSTATE_INUSE = DWORD($00000001);  // Currently in-use
  {$EXTERNALSYM XACT_SOUNDBANKSTATE_INUSE}


//------------------------------------------------------------------------------
// IXACTWaveBank
//------------------------------------------------------------------------------

  XACT_WAVEBANKSTATE_INUSE    = DWORD($00000001);      // Currently in-use
  {$EXTERNALSYM XACT_WAVEBANKSTATE_INUSE}
  XACT_WAVEBANKSTATE_PREPARED = DWORD($00000002);      // Prepared
  {$EXTERNALSYM XACT_WAVEBANKSTATE_PREPARED}
  XACT_WAVEBANKSTATE_PREPAREFAILED = DWORD($00000004); // Prepare failed.
  {$EXTERNALSYM XACT_WAVEBANKSTATE_PREPAREFAILED}


//------------------------------------------------------------------------------
// IXACTCue
//------------------------------------------------------------------------------

  // Cue Flags
  XACT_FLAG_CUE_STOP_RELEASE           = DWORD($00000000);
  {$EXTERNALSYM XACT_FLAG_CUE_STOP_RELEASE}
  XACT_FLAG_CUE_STOP_IMMEDIATE         = DWORD($00000001);
  {$EXTERNALSYM XACT_FLAG_CUE_STOP_IMMEDIATE}

  // Mutually exclusive states
  XACT_CUESTATE_CREATED   = DWORD($00000001);  // Created, but nothing else
  {$EXTERNALSYM XACT_CUESTATE_CREATED}
  XACT_CUESTATE_PREPARING = DWORD($00000002);  // In the middle of preparing
  {$EXTERNALSYM XACT_CUESTATE_PREPARING}
  XACT_CUESTATE_PREPARED  = DWORD($00000004);  // Prepared, but not yet played
  {$EXTERNALSYM XACT_CUESTATE_PREPARED}
  XACT_CUESTATE_PLAYING   = DWORD($00000008);  // Playing (though could be paused)
  {$EXTERNALSYM XACT_CUESTATE_PLAYING}
  XACT_CUESTATE_STOPPING  = DWORD($00000010);  // Stopping
  {$EXTERNALSYM XACT_CUESTATE_STOPPING}
  XACT_CUESTATE_STOPPED   = DWORD($00000020);  // Stopped
  {$EXTERNALSYM XACT_CUESTATE_STOPPED}

  // Inclusive states
  XACT_CUESTATE_PAUSED    = DWORD($00000040);  // Paused (can be combinded with other states)
  {$EXTERNALSYM XACT_CUESTATE_PAUSED}


//------------------------------------------------------------------------------
// XACT specific error codes
//------------------------------------------------------------------------------

const
  FACILITY_XACTENGINE = $AC7;
  {$EXTERNALSYM FACILITY_XACTENGINE}

// #define XACTENGINEERROR(n) MAKE_HRESULT(SEVERITY_ERROR, FACILITY_XACTENGINE, n)
// XACTENGINEERROR(n) = DWord((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or n;

  XACTENGINE_E_OUTOFMEMORY               = E_OUTOFMEMORY;      // Out of memory
  {$EXTERNALSYM XACTENGINE_E_OUTOFMEMORY}
  XACTENGINE_E_INVALIDARG                = E_INVALIDARG;       // Invalid arg
  {$EXTERNALSYM XACTENGINE_E_INVALIDARG}
  XACTENGINE_E_NOTIMPL                   = E_NOTIMPL;          // Not implemented
  {$EXTERNALSYM XACTENGINE_E_NOTIMPL}
  XACTENGINE_E_FAIL                      = E_FAIL;             // Unknown error
  {$EXTERNALSYM XACTENGINE_E_FAIL}

  XACTENGINE_E_ALREADYINITIALIZED        = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $001);   // The engine is already initialized
  {$EXTERNALSYM XACTENGINE_E_ALREADYINITIALIZED}
  XACTENGINE_E_NOTINITIALIZED            = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $002);   // The engine has not been initialized
  {$EXTERNALSYM XACTENGINE_E_NOTINITIALIZED}
  XACTENGINE_E_EXPIRED                   = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $003);   // The engine has expired (demo or pre-release version)
  {$EXTERNALSYM XACTENGINE_E_EXPIRED}
  XACTENGINE_E_NONOTIFICATIONCALLBACK    = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $004);   // No notification callback
  {$EXTERNALSYM XACTENGINE_E_NONOTIFICATIONCALLBACK}
  XACTENGINE_E_NOTIFICATIONREGISTERED    = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $005);   // Notification already registered
  {$EXTERNALSYM XACTENGINE_E_NOTIFICATIONREGISTERED}
  XACTENGINE_E_INVALIDUSAGE              = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $006);   // Invalid usage
  {$EXTERNALSYM XACTENGINE_E_INVALIDUSAGE}
  XACTENGINE_E_INVALIDDATA               = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $007);   // Invalid data
  {$EXTERNALSYM XACTENGINE_E_INVALIDDATA}
  XACTENGINE_E_INSTANCELIMITFAILTOPLAY   = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $008);   // Fail to play due to instance limit
  {$EXTERNALSYM XACTENGINE_E_INSTANCELIMITFAILTOPLAY}
  XACTENGINE_E_NOGLOBALSETTINGS          = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $009);   // Global Settings not loaded
  {$EXTERNALSYM XACTENGINE_E_NOGLOBALSETTINGS}
  XACTENGINE_E_INVALIDVARIABLEINDEX      = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00a);   // Invalid variable index
  {$EXTERNALSYM XACTENGINE_E_INVALIDVARIABLEINDEX}
  XACTENGINE_E_INVALIDCATEGORY           = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00b);   // Invalid category
  {$EXTERNALSYM XACTENGINE_E_INVALIDCATEGORY}
  XACTENGINE_E_INVALIDCUEINDEX           = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00c);   // Invalid cue index
  {$EXTERNALSYM XACTENGINE_E_INVALIDCUEINDEX}
  XACTENGINE_E_INVALIDWAVEINDEX          = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00d);   // Invalid wave index
  {$EXTERNALSYM XACTENGINE_E_INVALIDWAVEINDEX}
  XACTENGINE_E_INVALIDTRACKINDEX         = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00e);   // Invalid track index
  {$EXTERNALSYM XACTENGINE_E_INVALIDTRACKINDEX}
  XACTENGINE_E_INVALIDSOUNDOFFSETORINDEX = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $00f);   // Invalid sound offset or index
  {$EXTERNALSYM XACTENGINE_E_INVALIDSOUNDOFFSETORINDEX}
  XACTENGINE_E_READFILE                  = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $010);   // Error reading a file
  {$EXTERNALSYM XACTENGINE_E_READFILE}
  XACTENGINE_E_UNKNOWNEVENT              = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $011);   // Unknown event type
  {$EXTERNALSYM XACTENGINE_E_UNKNOWNEVENT}
  XACTENGINE_E_INCALLBACK                = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $012);   // Invalid call of method of function from callback
  {$EXTERNALSYM XACTENGINE_E_INCALLBACK}
  XACTENGINE_E_NOWAVEBANK                = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $013);   // No wavebank exists for desired operation
  {$EXTERNALSYM XACTENGINE_E_NOWAVEBANK}
  XACTENGINE_E_SELECTVARIATION           = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $014);   // Unable to select a variation
  {$EXTERNALSYM XACTENGINE_E_SELECTVARIATION}
  XACTENGINE_E_MULTIPLEAUDITIONENGINES   = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $015);   // There can be only one audition engine
  {$EXTERNALSYM XACTENGINE_E_MULTIPLEAUDITIONENGINES}
  XACTENGINE_E_WAVEBANKNOTPREPARED       = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $016);   // The wavebank is not prepared
  {$EXTERNALSYM XACTENGINE_E_WAVEBANKNOTPREPARED}
  XACTENGINE_E_NORENDERER                = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $017);   // No audio device found on.
  {$EXTERNALSYM XACTENGINE_E_NORENDERER}
  XACTENGINE_E_INVALIDENTRYCOUNT         = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $018);   // Invalid entry count for channel maps
  {$EXTERNALSYM XACTENGINE_E_INVALIDENTRYCOUNT}

  XACTENGINE_E_AUDITION_WRITEFILE        = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $101);  // Error writing a file during auditioning
  {$EXTERNALSYM XACTENGINE_E_AUDITION_WRITEFILE}
  XACTENGINE_E_AUDITION_NOSOUNDBANK      = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $102);  // Missing a soundbank
  {$EXTERNALSYM XACTENGINE_E_AUDITION_NOSOUNDBANK}
  XACTENGINE_E_AUDITION_INVALIDRPCINDEX  = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $103);  // Missing an RPC curve
  {$EXTERNALSYM XACTENGINE_E_AUDITION_INVALIDRPCINDEX}
  XACTENGINE_E_AUDITION_MISSINGDATA      = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $104);  // Missing data for an audition command
  {$EXTERNALSYM XACTENGINE_E_AUDITION_MISSINGDATA}
  XACTENGINE_E_AUDITION_UNKNOWNCOMMAND   = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $105);  // Unknown command
  {$EXTERNALSYM XACTENGINE_E_AUDITION_UNKNOWNCOMMAND}
  XACTENGINE_E_AUDITION_INVALIDDSPINDEX  = DWord(((1 shl 31) or (FACILITY_XACTENGINE shl 16)) or  $106);  // Missing a DSP parameter
  {$EXTERNALSYM XACTENGINE_E_AUDITION_INVALIDDSPINDEX}




(***************************************************************************
 *
 *  Copyright (C) Microsoft Corporation.  All Rights Reserved.
 *
 *  File:       xact2wb.h
 *  Content:    XACT 2 wave bank definitions.
 *
 ****************************************************************************)

{$MINENUMSIZE 1}

const
  WAVEBANK_HEADER_SIGNATURE   = 'DNBW';
  {$EXTERNALSYM WAVEBANK_HEADER_SIGNATURE}

  WAVEBANK_HEADER_VERSION     = XACT_CONTENT_VERSION;          // Current tool version
  {$EXTERNALSYM WAVEBANK_HEADER_VERSION}

  WAVEBANK_BANKNAME_LENGTH    = 64;          // Wave bank friendly name length, in characters
  {$EXTERNALSYM WAVEBANK_BANKNAME_LENGTH}
  WAVEBANK_ENTRYNAME_LENGTH   = 64;          // Wave bank entry friendly name length, in characters
  {$EXTERNALSYM WAVEBANK_ENTRYNAME_LENGTH}

  WAVEBANK_MAX_DATA_SEGMENT_SIZE          = $FFFFFFFF;  // Maximum wave bank data segment size, in bytes
  {$EXTERNALSYM WAVEBANK_MAX_DATA_SEGMENT_SIZE}
  WAVEBANK_MAX_COMPACT_DATA_SEGMENT_SIZE  = $001FFFFF;  // Maximum compact wave bank data segment size, in bytes
  {$EXTERNALSYM WAVEBANK_MAX_COMPACT_DATA_SEGMENT_SIZE}

type
  WAVEBANKOFFSET = DWORD;
  {$EXTERNALSYM WAVEBANKOFFSET}
  TWavebankOffset = WAVEBANKOFFSET;

const
  //
  // Bank flags
  //

  WAVEBANK_TYPE_BUFFER         = $00000000;      // In-memory buffer
  {$EXTERNALSYM WAVEBANK_TYPE_BUFFER}
  WAVEBANK_TYPE_STREAMING      = $00000001;      // Streaming
  {$EXTERNALSYM WAVEBANK_TYPE_STREAMING}
  WAVEBANK_TYPE_MASK           = $00000001;
  {$EXTERNALSYM WAVEBANK_TYPE_MASK}

  WAVEBANK_FLAGS_ENTRYNAMES    = $00010000;      // Bank includes entry names
  {$EXTERNALSYM WAVEBANK_FLAGS_ENTRYNAMES}
  WAVEBANK_FLAGS_COMPACT       = $00020000;      // Bank uses compact format
  {$EXTERNALSYM WAVEBANK_FLAGS_COMPACT}
  WAVEBANK_FLAGS_SYNC_DISABLED = $00040000;      // Bank is disabled for audition sync
  {$EXTERNALSYM WAVEBANK_FLAGS_SYNC_DISABLED}
  WAVEBANK_FLAGS_MASK          = $00070000;
  {$EXTERNALSYM WAVEBANK_FLAGS_MASK}

  //
  // Entry flags
  //

  WAVEBANKENTRY_FLAGS_READAHEAD       = $00000001;  // Enable stream read-ahead
  {$EXTERNALSYM WAVEBANKENTRY_FLAGS_READAHEAD}
  WAVEBANKENTRY_FLAGS_LOOPCACHE       = $00000002;  // One or more looping sounds use this wave
  {$EXTERNALSYM WAVEBANKENTRY_FLAGS_LOOPCACHE}
  WAVEBANKENTRY_FLAGS_REMOVELOOPTAIL  = $00000004;  // Remove data after the end of the loop region
  {$EXTERNALSYM WAVEBANKENTRY_FLAGS_REMOVELOOPTAIL}
  WAVEBANKENTRY_FLAGS_IGNORELOOP      = $00000008;  // Used internally when the loop region can't be used
  {$EXTERNALSYM WAVEBANKENTRY_FLAGS_IGNORELOOP}
  WAVEBANKENTRY_FLAGS_MASK            = $00000008;
  {$EXTERNALSYM WAVEBANKENTRY_FLAGS_MASK}

  //
  // Entry wave format identifiers
  //

  WAVEBANKMINIFORMAT_TAG_PCM      = $0;     // PCM data
  {$EXTERNALSYM WAVEBANKMINIFORMAT_TAG_PCM}
  WAVEBANKMINIFORMAT_TAG_XMA      = $1;     // XMA data
  {$EXTERNALSYM WAVEBANKMINIFORMAT_TAG_XMA}
  WAVEBANKMINIFORMAT_TAG_ADPCM    = $2;     // ADPCM data
  {$EXTERNALSYM WAVEBANKMINIFORMAT_TAG_ADPCM}

  WAVEBANKMINIFORMAT_BITDEPTH_8   = $0;     // 8-bit data (PCM only)
  {$EXTERNALSYM WAVEBANKMINIFORMAT_BITDEPTH_8}
  WAVEBANKMINIFORMAT_BITDEPTH_16  = $1;     // 16-bit data (PCM only)
  {$EXTERNALSYM WAVEBANKMINIFORMAT_BITDEPTH_16}

  //
  // Arbitrary fixed sizes
  //
  WAVEBANKENTRY_XMASTREAMS_MAX          = 3;   // enough for 5.1 channel audio
  {$EXTERNALSYM WAVEBANKENTRY_XMASTREAMS_MAX}
  WAVEBANKENTRY_XMACHANNELS_MAX         = 6;   // enough for 5.1 channel audio (cf. XAUDIOCHANNEL_SOURCEMAX)
  {$EXTERNALSYM WAVEBANKENTRY_XMACHANNELS_MAX}

  //
  // DVD data sizes
  //

  WAVEBANK_DVD_SECTOR_SIZE    = 2048;
  {$EXTERNALSYM WAVEBANK_DVD_SECTOR_SIZE}
  WAVEBANK_DVD_BLOCK_SIZE     = (WAVEBANK_DVD_SECTOR_SIZE * 16);
  {$EXTERNALSYM WAVEBANK_DVD_BLOCK_SIZE}

  //
  // Bank alignment presets
  //

  WAVEBANK_ALIGNMENT_MIN  = 4;                           // Minimum alignment
  {$EXTERNALSYM WAVEBANK_ALIGNMENT_MIN}
  WAVEBANK_ALIGNMENT_DVD  = WAVEBANK_DVD_SECTOR_SIZE;    // DVD-optimized alignment
  {$EXTERNALSYM WAVEBANK_ALIGNMENT_DVD}

type
  //
  // Wave bank segment identifiers
  //

  //todo: What is size of this ENUM ???
  PWavebankSegIDX = ^TWavebankSegIDX;
  WAVEBANKSEGIDX =
  (
    WAVEBANK_SEGIDX_BANKDATA{= 0},       // Bank data
    WAVEBANK_SEGIDX_ENTRYMETADATA,      // Entry meta-data
    WAVEBANK_SEGIDX_ENTRYNAMES,         // Entry friendly names
    WAVEBANK_SEGIDX_EXTRA,              // Storage for extra metadata defined by the wave entry
    WAVEBANK_SEGIDX_ENTRYWAVEDATA      // Entry wave data
    // WAVEBANK_SEGIDX_COUNT
  );
  {$EXTERNALSYM WAVEBANKSEGIDX}
  TWavebankSegIDX = WAVEBANKSEGIDX;
  
const
  WAVEBANK_SEGIDX_COUNT = Ord(High(TWavebankSegIDX))+1;
  {$EXTERNALSYM WAVEBANK_SEGIDX_COUNT}


  //
  // Endianness
  //

procedure SwapBytes(_dw_: PDWORD); overload;
{$EXTERNALSYM SwapBytes}
procedure SwapBytes(w: PWORD); overload;
{$EXTERNALSYM SwapBytes}


//
// Wave bank region
//
type
  PWavebankRegion = ^TWavebankRegion;
  WAVEBANKREGION = record
    dwOffset:       DWORD;               // Region offset, in bytes
    dwLength:       DWORD;               // Region length, in bytes
  end;
  {$EXTERNALSYM WAVEBANKREGION}
  TWavebankRegion = WAVEBANKREGION;

//procedure TWavebankRegion_SwapBytes(var wbr: TWavebankRegion);


//
// Wave bank file header
//
type
  PWavebankHeader = ^TWavebankHeader;
  WAVEBANKHEADER = record
    dwSignature: DWORD;                         // File signature
    dwVersion: DWORD;                           // Version of the tool that created the file
    Segments: array[0..WAVEBANK_SEGIDX_COUNT-1] of TWavebankRegion; // Segment lookup table
  end;
  {$EXTERNALSYM WAVEBANKHEADER}
  TWavebankHeader = WAVEBANKHEADER;

//procedure TWavebankHeader_SwapBytes(var wbh: TWavebankHeader);


//
// Entry compressed data format
//
type
  PWavebankMiniWaveFormat = ^TWavebankMiniWaveFormat;
  WAVEBANKMINIWAVEFORMAT = record
    //struct
    {
        DWORD       wFormatTag      : 2;        // Format tag
        DWORD       nChannels       : 3;        // Channel count (1 - 6)
        DWORD       nSamplesPerSec  : 18;       // Sampling rate
        DWORD       wBlockAlign     : 8;        // Block alignment
        DWORD       wBitsPerSample  : 1;        // Bits per sample (8 vs. 16, PCM only)
    }
    dwValue:           DWORD;
  end;
  {$EXTERNALSYM WAVEBANKMINIWAVEFORMAT}
  TWavebankMiniWaveFormat = WAVEBANKMINIWAVEFORMAT;

//procedure TWavebankMiniWaveFormat_SwapBytes(var wbmwf: TWavebankMiniWaveFormat);
//function TWavebankMiniWaveFormat_BitsPerSample(): Word;
//function TWavebankMiniWaveFormat_BlockAlign(): DWPRD;


type
  TXMALoopRegion = record
    dwStartOffset:   DWORD;          // loop start offset (in bits)
    {
      DWORD   nSubframeSkip   : 2;    // needed by XMA decoder. Valid values for XMA are 1-4; XACT converts to 0-3 for storage. Add 1 to this value before passing to driver.
      DWORD   nSubframeEnd    : 2;    // needed by XMA decoder
      DWORD   dwEndOffset     : 28;   // loop end offset (in bits)
    }
    dwValue: DWORD;
  end;

//
// Entry meta-data
//

  PWavebankEntry = ^TWavebankEntry;
  WAVEBANKENTRY = record
    //union
        //struct
        {
            // Entry flags
            DWORD                   dwFlags  :  4;

            // Duration of the wave, in units of one sample.
            // For instance, a ten second long wave sampled
            // at 48KHz would have a duration of 480,000.
            // This value is not affected by the number of
            // channels, the number of bits per sample, or the
            // compression format of the wave.
            DWORD                   Duration : 28;
        }
        dwFlagsAndDuration: DWORD;
    //};

    Format: TWavebankMiniWaveFormat;  // Entry format
    PlayRegion: TWavebankRegion;      // Region within the wave data segment that contains this entry

    case Byte of
      0: (LoopRegion: TWavebankRegion); // Region within the wave data that should loop

      // XMA loop region
      // Note: this is not the same memory layout as the XMA loop region
      // passed to the XMA driver--it is more compact. The named values
      // map correctly and there are enough bits to store the entire
      // range of values that XMA considers valid, with one exception:
      // valid values for nSubframeSkip are 1, 2, 3, or 4. In order to
      // store this in two bits, XACT subtracts 1 from the value, then adds

      1: (XMALoopRegion: array [0..WAVEBANKENTRY_XMASTREAMS_MAX-1] of TXMALoopRegion);

      // The last element in the union is an array that aliases the
      // entire union so we can byte-reverse the whole thing.
      2: (LoopRegionAlias: array [0..WAVEBANKENTRY_XMASTREAMS_MAX-1] of TWavebankRegion);
  end;
  {$EXTERNALSYM WAVEBANKENTRY}
  TWavebankEntry = WAVEBANKENTRY;


//
// Compact entry meta-data
//

  PWavebankEntryCompact = ^TWavebankEntryCompact;
  WAVEBANKENTRYCOMPACT = record
    {DWORD       dwOffset            : 21;       // Data offset, in sectors
    DWORD       dwLengthDeviation   : 11;       // Data length deviation, in bytes}
    dwValue: DWORD;
  end;
  {$EXTERNALSYM WAVEBANKENTRYCOMPACT}
  TWavebankEntryCompact = WAVEBANKENTRYCOMPACT;


//
// Bank data segment
//

  PWavebankData = ^TWavebankData;
  WAVEBANKDATA = record
    dwFlags: DWORD;                                // Bank flags
    dwEntryCount: DWORD;                           // Number of entries in the bank
    szBankName: array [0..WAVEBANK_BANKNAME_LENGTH-1] of Char;   // Bank friendly name
    dwEntryMetaDataElementSize: DWORD;             // Size of each entry meta-data element, in bytes
    dwEntryNameElementSize: DWORD;                 // Size of each entry name element, in bytes
    dwAlignment: DWORD;                            // Entry alignment, in bytes
    CompactFormat: TWavebankMiniWaveFormat;        // Format data for compact bank
    BuildTime: FILETIME;                           // Build timestamp
  end;
  {$EXTERNALSYM WAVEBANKDATA}
  TWavebankData = WAVEBANKDATA;

{$MINENUMSIZE 4}




{*-========================================================================-_
 |                                - XACT3D -                                |
 |        Copyright (c) Microsoft Corporation.  All rights reserved.        |
 |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
 |VERSION:  0.1                         MODEL:   Unmanaged User-mode        |
 |CONTRACT: N / A                       EXCEPT:  No Exceptions              |
 |PARENT:   N / A                       MINREQ:  Win2000, Xbox360           |
 |PROJECT:  XACT3D                      DIALECT: MS Visual C++ 7.0          |
 |>------------------------------------------------------------------------<|
 | DUTY: XACT 3D support                                                    |
 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
  NOTES:
    1.  See X3DAudio.h for information regarding X3DAudio types.            *}


//--------------<D-E-F-I-N-I-T-I-O-N-S>-------------------------------------//
const
  // Supported speaker positions, represented as azimuth angles.
  //
  // Here's a picture of the azimuth angles for the 8 cardinal points,
  // seen from above.  The emitter's base position is at the origin 0.
  //
  //           FRONT
  //             | 0  <-- azimuth
  //             |
  //    7pi/4 \  |  / pi/4
  //           \ | /
  // LEFT       \|/      RIGHT
  // 3pi/2-------0-------pi/2
  //            /|\
  //           / | \
  //    5pi/4 /  |  \ 3pi/4
  //             |
  //             | pi
  //           BACK
  //
  LEFT_AZIMUTH                    = (3*X3DAUDIO_PI/2);
  {$EXTERNALSYM LEFT_AZIMUTH}
  RIGHT_AZIMUTH                   = (X3DAUDIO_PI/2);
  {$EXTERNALSYM RIGHT_AZIMUTH}
  FRONT_LEFT_AZIMUTH              = (7*X3DAUDIO_PI/4);
  {$EXTERNALSYM FRONT_LEFT_AZIMUTH}
  FRONT_RIGHT_AZIMUTH             = (X3DAUDIO_PI/4);
  {$EXTERNALSYM FRONT_RIGHT_AZIMUTH}
  FRONT_CENTER_AZIMUTH            = 0.0;
  {$EXTERNALSYM FRONT_CENTER_AZIMUTH}
  LOW_FREQUENCY_AZIMUTH           = X3DAUDIO_2PI;
  {$EXTERNALSYM LOW_FREQUENCY_AZIMUTH}
  BACK_LEFT_AZIMUTH               = (5*X3DAUDIO_PI/4);
  {$EXTERNALSYM BACK_LEFT_AZIMUTH}
  BACK_RIGHT_AZIMUTH              = (3*X3DAUDIO_PI/4);
  {$EXTERNALSYM BACK_RIGHT_AZIMUTH}
  BACK_CENTER_AZIMUTH             = X3DAUDIO_PI;
  {$EXTERNALSYM BACK_CENTER_AZIMUTH}
  FRONT_LEFT_OF_CENTER_AZIMUTH    = (15*X3DAUDIO_PI/8);
  {$EXTERNALSYM FRONT_LEFT_OF_CENTER_AZIMUTH}
  FRONT_RIGHT_OF_CENTER_AZIMUTH   = (X3DAUDIO_PI/8);
  {$EXTERNALSYM FRONT_RIGHT_OF_CENTER_AZIMUTH}


//--------------<D-A-T-A---T-Y-P-E-S>---------------------------------------//

  // Supported emitter channel layouts:
  aStereoLayout: array[0..1] of Single =
  (
    LEFT_AZIMUTH,
    RIGHT_AZIMUTH
  );
  {$EXTERNALSYM aStereoLayout}
  a2Point1Layout: array[0..2] of Single =
  (
    LEFT_AZIMUTH,
    RIGHT_AZIMUTH,
    LOW_FREQUENCY_AZIMUTH
  );
  {$EXTERNALSYM a2Point1Layout}
  aQuadLayout: array[0..3] of Single =
  (
    FRONT_LEFT_AZIMUTH,
    FRONT_RIGHT_AZIMUTH,
    BACK_LEFT_AZIMUTH,
    BACK_RIGHT_AZIMUTH
  );
  {$EXTERNALSYM aQuadLayout}
  a5Point1Layout: array[0..5] of Single =
  (
    FRONT_LEFT_AZIMUTH,
    FRONT_RIGHT_AZIMUTH,
    FRONT_CENTER_AZIMUTH,
    LOW_FREQUENCY_AZIMUTH,
    BACK_LEFT_AZIMUTH,
    BACK_RIGHT_AZIMUTH
  );
  {$EXTERNALSYM a5Point1Layout}
  a7Point1Layout: array[0..7] of Single =
  (
    FRONT_LEFT_AZIMUTH,
    FRONT_RIGHT_AZIMUTH,
    FRONT_CENTER_AZIMUTH,
    LOW_FREQUENCY_AZIMUTH,
    BACK_LEFT_AZIMUTH,
    BACK_RIGHT_AZIMUTH,
    LEFT_AZIMUTH,
    RIGHT_AZIMUTH
  );
  {$EXTERNALSYM a7Point1Layout}

const
  DefaultCurvePoints: array[0..1] of TX3DAudioDistanceCurvePoint =
    ((Distance: 0.0; DSPSetting: 1.0), (Distance: 1.0; DSPSetting: 1.0));
  DefaultCurve: TX3DAudioDistanceCurve = (pPoints: @DefaultCurvePoints; PointCount: 2);

//--------------<F-U-N-C-T-I-O-N-S>-----------------------------------------//

////
// DESCRIPTION:
//  Calculates DSP settings with respect to 3D parameters:
//
// REMARKS:
//  The number of bits set in SpeakerChannelMask should equal the number of
//  channels expected on the final mix.
//
// PARAMETERS:
//  SpeakerChannelMask - [in]  speaker geometry configuration on the final mix, specifies assignment of channels to speaker positions, defined as per WAVEFORMATEXTENSIBLE.dwChannelMask, must be != 0
//                             Currently only SPEAKER_STEREO and SPEAKER_5POINT1 is supported by X3DAudio.
//  pListener          - [in]  point of 3D audio reception
//  pEmitter           - [in]  3D audio source
//  pDSPSettings       - [out] receives calculation results, applied to an XACT cue via XACT3DApply
//  pEngine            - [in]  pointer to the XACT engine
//
// RETURN VALUE:
//  HResult error code
////
function XACT3DCalculate(SpeakerChannelMask: LongWord; const pListener: PX3DAudioListener;
  pEmitter: PX3DAudioEmitter; pDSPSettings: PX3DAudioDspSettings;
  const pEngine: IXACTEngine): HRESULT; cdecl; inline;
{$EXTERNALSYM XACT3DCalculate}


////
// DESCRIPTION:
//  Applies a 3D calculation returned by XACT3DCalculate to a cue:
//
// PARAMETERS:
//  pDSPSettings - [in] calculation results generated by XACT3DCalculate
//  pCue         - [in] cue to which to apply pDSPSettings
//
// RETURN VALUE:
//  HResult error code
////
function XACT3DApply(const pDSPSettings: TX3DAudioDspSettings; const pCue: IXACTCue;
  ChannelCount: LongWord): HRESULT; cdecl; inline;
{$EXTERNALSYM XACT3DApply}


implementation


{.$IFDEF XBOX}
function XACTCreateEngine(dwCreationFlags: DWORD; out ppEngine: IXACTEngine): HRESULT; stdcall; // inline
var
  key: HKEY;
  data: DWORD;
  type_: DWORD;
  dataSize: DWORD;
  debug: Boolean;
  audition: Boolean;
  guid: TGUID;
begin
  type_    := REG_DWORD;
  dataSize := SizeOf(DWORD);
  debug    := (dwCreationFlags and XACT_FLAG_API_DEBUG_MODE) <> 0;
  audition := (dwCreationFlags and XACT_FLAG_API_AUDITION_MODE) <> 0;

  // If neither the debug nor audition flags are set, see if the debug registry key is set
  if (not debug and not audition and
     (RegOpenKeyEx(HKEY_LOCAL_MACHINE, XACT_DEBUGENGINE_REGISTRY_KEY, 0, KEY_READ, key) = ERROR_SUCCESS)) then
  begin
    if RegQueryValueEx(key, XACT_DEBUGENGINE_REGISTRY_VALUE, nil, @type_, @data, @dataSize) = ERROR_SUCCESS
    then debug := (data <> 0);
    RegCloseKey(key);
  end;

  if audition then guid := CLSID_XACTAuditionEngine
  else if debug then guid := CLSID_XACTDebugEngine
  else guid := CLSID_XACTEngine;

  Result:= CoCreateInstance(guid, nil, CLSCTX_INPROC_SERVER, IXACTEngine, ppEngine);
end;
{.$ENDIF XBOX}


(***************************************************************************
 *  File:       xact2wb.h
 *  Content:    XACT 2 wave bank definitions.
 ****************************************************************************)
procedure SwapBytes(_dw_: PDWORD); overload;
asm
  mov edi, _dw_
  // mov edi, dw
  mov eax, [edi]
  bswap eax
  mov [edi], eax
end;
//        dw = _byteswap_ulong(dw); //todo: add inline in pure pascal case

procedure SwapBytes(w: PWORD); overload;
asm
  mov edi, w
  mov ax, [edi]
  xchg ah, al
  mov [edi], ax
end;
//        w = _byteswap_ushort(w); //todo: add inline in pure pascal case




(***************************************************************************
 *  File:       xact3d.h
 *  Content:    XACT 3D support.
 ****************************************************************************)

////
// DESCRIPTION:
//  Calculates DSP settings with respect to 3D parameters:
//
// REMARKS:
//  The number of bits set in SpeakerChannelMask should equal the number of
//  channels expected on the final mix.
//
// PARAMETERS:
//  SpeakerChannelMask - [in]  speaker geometry configuration on the final mix, specifies assignment of channels to speaker positions, defined as per WAVEFORMATEXTENSIBLE.dwChannelMask, must be != 0
//                             Currently only (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT) is supported by XACT.
//  pListener          - [in]  point of 3D audio reception
//  pEmitter           - [in]  3D audio source
//  pDSPSettings       - [out] receives calculation results, applied to an XACT cue via XACT3DApply
//  pEngine            - [in]  pointer to the XACT engine
//
// RETURN VALUE:
//  HResult error code
////
function XACT3DCalculate(SpeakerChannelMask: LongWord; const pListener: PX3DAudioListener;
  pEmitter: PX3DAudioEmitter; pDSPSettings: PX3DAudioDspSettings;
  const pEngine: IXACTEngine): HRESULT; cdecl; inline;
var
  xactSpeedOfSoundID: TXACTVariableIndex;
  nSpeedOfSound: TXACTVariableValue;
  X3DInstance: TX3DAudioHandle;
begin
  xactSpeedOfSoundID := pEngine.GetGlobalVariableIndex('SpeedOfSound');
  Result := pEngine.GetGlobalVariable(xactSpeedOfSoundID, nSpeedOfSound);

  if SUCCEEDED(Result) then
  begin
    X3DAudioInitialize(SpeakerChannelMask, nSpeedOfSound, X3DInstance);

    if (pEmitter.ChannelCount > 1) and (pEmitter.pChannelAzimuths = nil) then
    begin
      pEmitter.ChannelRadius := 1.0;

      case pEmitter.ChannelCount of
        2: pEmitter.pChannelAzimuths := @aStereoLayout[0];
        3: pEmitter.pChannelAzimuths := @a2Point1Layout[0];
        4: pEmitter.pChannelAzimuths := @aQuadLayout[0];
        6: pEmitter.pChannelAzimuths := @a5Point1Layout[0];
        8: pEmitter.pChannelAzimuths := @a7Point1Layout[0];
       else
        Result := E_FAIL;
      end;
    end;

    if (pEmitter.pVolumeCurve = nil) then pEmitter.pVolumeCurve := @DefaultCurve;
    if (pEmitter.pLFECurve = nil) then pEmitter.pLFECurve := @DefaultCurve;

    if SUCCEEDED(Result) then
      X3DAudioCalculate(X3DInstance, pListener, pEmitter, X3DAUDIO_CALCULATE_MATRIX or X3DAUDIO_CALCULATE_DOPPLER or X3DAUDIO_CALCULATE_EMITTER_ANGLE, pDSPSettings);
  end;
end;


////
// DESCRIPTION:
//  Applies a 3D calculation returned by XACT3DCalculate to a cue:
//
// PARAMETERS:
//  pDSPSettings - [in] calculation results generated by XACT3DCalculate
//  pCue         - [in] cue to which to apply pDSPSettings
//  ChannelCount - [in] should be set equal to pDSPSettings->SrcChannelCount.
//
// RETURN VALUE:
//  HResult error code
////
function XACT3DApply(const pDSPSettings: TX3DAudioDspSettings; const pCue: IXACTCue;
  ChannelCount: LongWord): HRESULT; cdecl; inline;
var
  xactDistanceID: TXACTVariableIndex;
  xactDopplerID: TXACTVariableIndex;
  xactOrientationID: TXACTVariableIndex;
begin
  Result := pCue.SetMatrixCoefficients(pDSPSettings.SrcChannelCount, pDSPSettings.DstChannelCount, pDSPSettings.pMatrixCoefficients);

  if SUCCEEDED(Result) then
  begin
    xactDistanceID := pCue.GetVariableIndex('Distance');
    Result := pCue.SetVariable(xactDistanceID, pDSPSettings.EmitterToListenerDistance);
  end;

  if SUCCEEDED(Result) then
  begin
    xactDopplerID := pCue.GetVariableIndex('DopplerPitchScalar');
    Result := pCue.SetVariable(xactDopplerID, pDSPSettings.DopplerFactor);
  end;

  if SUCCEEDED(Result) then   
  begin
    xactOrientationID := pCue.GetVariableIndex('OrientationAngle');
    Result := pCue.SetVariable(xactOrientationID, pDSPSettings.EmitterToListenerAngle * (180.0 / X3DAUDIO_PI));
  end;
end;

end.


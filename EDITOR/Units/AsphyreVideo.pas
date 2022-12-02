{ ---------------------------------------------------------------------------- }
{                                                                              }
{ Unit:     Video system for Asphyre eXtreme v3.1.0                            }
{ Version:  0.0.2                                                              }
{ Modified: 03-12-06 (DD-MM-YY)                                                }
{                                                                              }
{ Author:   Jaromir "Cervajz" Cervenka                                         }
{ Mail:     jara.cervenka@seznam.cz                                            }
{ WWW:      http://www.cervajz.profitux.cz/                                    }
{                                                                              }
{ Notice:                                                                      }
{   Sorry for my English                                                       }
{                                                                              }
{ License:                                                                     }
{   FREE FOR ALL (ALSO FOR COMMERCIAL USE)                                     }
{                                                                              }
{ Information:                                                                 }
{                                                                              }
{                                                                              }
{ Acknowledgments:                                                             }
{   Thanks to authors of DSPack (http://www.progdigy.com). Some functions in   }
{   this unit is their work.                                                   }
{                                                                              }
{ Changes:                                                                     }
{   v0.0.1b:                                                                   }
{     * First Release                                                          }
{                                                                              }
{   v0.0.2:                                                                    }
{     + TcErrorMode                                                            }
{     + property ErrorMode                                                     }
{     * Repaired handling with IVideoWindow                                    }
{     + FGraphBuilded                                                          }
{     * Repaired handling with errors                                          }
{     - FIsVideoWinInit                                                        }
{     + AddFromASDb                                                            }
{     * Repaired lots of small errors                                          }
{     + Redirect rendering to other window-based controls                      }
{       (Device.WindowHandle <> 0).                                            }
{     - Parameter "ParentHandle" in Create                                     }
{                                                                              }
{ TODO 2 -oCervajz:TVideoTexture                                               }
{                                                                              }
{ TODO 5 -oCervajz:More comments                                               }
{                                                                              }
{ ---------------------------------------------------------------------------- }


// AllocateHWnd and DeallocateHWnd
{$WARN SYMBOL_DEPRECATED OFF}

unit AsphyreVideo;

interface

uses
  DirectShow9, ActiveX, Classes, AsphyreDevices, AsphyreTimers, SysUtils,
  Messages, Windows, ExtCtrls, AsphyreDb, AsphyreTextures;

// From DSPack
const
  WM_GRAPHNOTIFY = WM_APP + 1;

type
  // From DSPack
  EDirectShowException = class(Exception)
    ErrorCode: Integer;
  end;

  TAsphyreIntroVideoState = (aivsPlaying, aivsPaused, aivsStopped);
  // cemException is only for debug (in Delphi)
  TcErrorMode = (cemNone, cemMessageBox, cemException, cemLog);

  // For playing intro videos (like EA Games, Ubisoft, ...)
  TAsphyreIntroVideo = class(TObject)
  private
    { private declarations }
    FASDb: TASDb;
    FLoop: Boolean;
    FCount: Integer;
    FTempDir: string;    
    FLogFile: string;
    FIsInit: Boolean;
    FVolume: Integer;
    FTAutoRun: Boolean;
    FDone: TNotifyEvent;
    FActualFile: string;
    FWinHandle: THandle;
    FBAudio: IBasicAudio;
    FPlayLst: TStringList;
    FActualIndex: Integer;
    FOwnerHandle: THandle;
    FRenderer: IBaseFilter;
    FGraphBuilded: Boolean;    
    FMEvents: IMediaEventEx;
    FErrorMode: TcErrorMode;
    FTempFiles: TStringList;    
    FMControl: IMediaControl;
    FVideoWindow: IVideoWindow;
    FGraphBuilder: IGraphBuilder;
    FAsphyreTimer: TAsphyreTimer;
    FAsphyreDevice: TAsphyreDevice;
    FState: TAsphyreIntroVideoState;

    procedure FSetVolume();
    procedure FHandleEvents();
    procedure FStartAsphyre();
    procedure FInitVideoWindow();
    procedure FDeleteTempFiles();    
    function FLoadFileToGraph(): Boolean;
    procedure FWndProc(var Msg: TMessage);
    procedure FSetTempDir(const Value: string);
    procedure FAddLOGMessage(const Text: string);
    procedure FcShowMessage(const Txt, Caption: string);
    procedure FClearGraph(const AddRenderer: Boolean = True);
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const Device: TAsphyreDevice;
      const Timer: TAsphyreTimer);
    destructor Destroy(); override;
  published
    { published declarations }
    // Init all internal variables. Call after Create.
    function Init(): Boolean;
    // Add a video file to the list
    function AddFile(const FileName: string): Boolean;
    function AddFromASDb(const Name: string): Boolean;

    // Play actual video
    function Play(): Boolean;
    // Play next video
    procedure Next();
    // Pause actual video
    procedure Pause();
    // Stop playing
    procedure Stop();

    // Count of videos in list
    property Count: Integer read FCount;
    // For AddFromASDb
    property ASDb: TASDb read FASDb write FASDb;
    //
    property ActualFile: string read FActualFile;
    // Loop
    property Loop: Boolean read FLoop write FLoop;
    // Index of actual playing video
    property ActualIndex: Integer read FActualIndex;
    //
    property State: TAsphyreIntroVideoState read FState;
    // Volume
    property Volume: Integer read FVolume write FVolume;
    // For AddFromASDb
    property TempDir: string read FTempDir write FSetTempDir;
    //
    property TimerAutorun: Boolean read FTAutoRun write FTAutorun;
    // 
    property ErrorMode: TcErrorMode read FErrorMode write FErrorMode;

    // When all videos in list has been rendered (or position is > count) 
    property OnAllRendered: TNotifyEvent read FDone write FDone;
  end;

  // For video in texture
  TVideoTexture = class(TDynamicTexture)
  private
    { private declarations }
    FFileName: TFileName;
    FSampleGrabber: ISampleGrabber;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(); override;
    destructor Destroy(); override;
  published
    { published declarations }
    property FileName: TFileName read FFileName write FFileName;
  end;

implementation

uses
  Forms, Math;

{ TAsphyreIntroVideo }

// From DSPack
function GetErrorString(HR: HRESULT): string;
var
  Buffer: array[0..254] of Char;
begin
  AMGetErrorText(HR, @Buffer, 255);
  Result := Buffer;
end;

// From DSPack
function CheckDSError(HR: HRESULT): HRESULT;
var
  Excep: EDirectShowException;
begin
  Result := HR;
  if (Failed(HR)) then begin
    Excep := EDirectShowException.Create(format(GetErrorString(HR) +
      ' ($%x).', [HR]));
    Excep.ErrorCode := HR;
    raise Excep;
  end;
end;

procedure TAsphyreIntroVideo.FcShowMessage(const Txt, Caption: string);
begin
  if (Txt = '') then
    Exit;

  MessageBox(FOwnerHandle, PChar(Txt), PChar(Caption), MB_OK);
end;

procedure TAsphyreIntroVideo.FDeleteTempFiles;
var
  X: Integer;
begin
  for X := 0 to FTempFiles.Count - 1 do
    DeleteFile(PChar(FTempFiles[X]));

  FTempFiles.Clear();
  FreeAndNil(FTempFiles);
end;

function TAsphyreIntroVideo.AddFile(const FileName: string): Boolean;
begin
  Result := False;

  if (not FileExists(FileName)) then
    Exit;

  FPlayLst.Add(FileName);

  if (FActualIndex = -1) or (FActualFile = '') then begin
    FActualIndex := 0;
    FActualFile := FileName;
  end;

  FCount := FPlayLst.Count;
  Result := True;
end;

function TAsphyreIntroVideo.AddFromASDb(const Name: string): Boolean;
var
  Res: Boolean;
  MS1: TMemoryStream;
begin
  Result := False;

  if (FASDb = nil) or (FTempDir = '') then
    Exit;

  MS1 := TMemoryStream.Create();
  Res := FASDb.ReadStream(Name, MS1);
  if (not Res) then begin
    FreeAndNil(MS1);

    case (ErrorMode) of
      cemMessageBox: FcShowMessage(Format('FASDb.ReadStream(%s)', [Name]),
        'AddFromASDb');
      cemLog: FAddLOGMessage('AddFromASDb - ' + Format('FASDb.ReadStream(%s)',
        [Name]));      
    end;

    Exit;
  end;

  MS1.Position := 0;

//  if (not DirectoryExists(FTempDir)) then
//    Result := ForceDirectories(FTempDir);
//  if (not Result) then begin
//    MS1.Clear();
//    FreeAndNil(MS1);
//
//    case (ErrorMode) of
//      cemMessageBox: FcShowMessage(Format('DirectoryExists(%s)', [FTempDir]),
//        'AddFromASDb');
//      cemLog: FAddLOGMessage('AddFromASDb - ' + Format('DirectoryExists(%s)',
//        [FTempDir]));
//    end;
//
//    Exit;
//  end;

  try
    MS1.SaveToFile(FTempDir + Name);
  except
    MS1.Clear();
    FreeAndNil(MS1);

    case (ErrorMode) of
      cemMessageBox: FcShowMessage(Format('MS1.SaveToFile(%s)', [FTempDir + Name]),
        'AddFromASDb');
      cemException: raise;
      cemLog: FAddLOGMessage('AddFromASDb - ' + Format('MS1.SaveToFile(%s)',
        [FTempDir + Name]));
    end;

    Exit;
  end;

  Result := AddFile(FTempDir + Name);
  if (not Result) then
    case (ErrorMode) of
      cemMessageBox: FcShowMessage(Format('AddFile(%s)', [FTempDir + Name]),
        'AddFromASDb');
      cemLog: FAddLOGMessage('AddFromASDb - ' + Format('AddFile(%s)',
        [FTempDir + Name]));
    end;

  if (Result) then begin
    if (FTempFiles = nil) then
      FTempFiles := TStringList.Create();

    FTempFiles.Add(FTempDir + Name);
  end; 

  MS1.Clear();
  FreeAndNil(MS1);
end;

constructor TAsphyreIntroVideo.Create(const Device: TAsphyreDevice;
  const Timer: TAsphyreTimer);
begin
  CoInitialize(nil);

  if (Device.WindowHandle <> 0) then
    FOwnerHandle := Device.WindowHandle
  else if (Device.WindowHandle = 0) then
    if (Assigned(Device.Owner) and (Device.Owner is TCustomForm)) then
      FOwnerHandle := TCustomForm(Device.Owner).Handle;

  FAsphyreDevice := Device;
  FAsphyreTimer := Timer;
  if (FAsphyreTimer.Enabled) then
    FAsphyreTimer.Enabled := False;

  FWinHandle := AllocateHWnd(FWndProc);

  FGraphBuilder := nil;
  FRenderer := nil;
  FVideoWindow := nil;
  FBAudio := nil;
  FMControl := nil;
  FMEvents := nil;

  FLoop := False;
  FCount := 0;
  FActualIndex := -1;
  FActualFile := '';
  FVolume := 100;
  FIsInit := False;
  FTAutoRun := True;
  FDone := nil;
  FState := aivsStopped;
  FErrorMode := cemNone;
  FGraphBuilded := False;
  FASDb := nil;
  FTempDir := '';
  FTempFiles := nil;

  FLogFile := ExtractFilePath(Application.ExeName) + 'AsphyreVideoLog.txt';
  if (FileExists(FLogFile)) then
    DeleteFile(PChar(FLogFile));

  FPlayLst := TStringList.Create();
end;

destructor TAsphyreIntroVideo.Destroy;
begin
  if (FState in [aivsPlaying, aivsPaused]) then
    Stop();  

  FPlayLst.Clear();
  FreeAndNil(FPlayLst);

  FClearGraph(False);

  FMEvents := nil;
  FMControl := nil;
  FBAudio := nil;
  FVideoWindow := nil;
  FRenderer := nil;
  FGraphBuilder := nil;

  if (FTempFiles <> nil) then
    FDeleteTempFiles();
  
  DeallocateHWnd(FWinHandle);

  CoUninitialize();

  inherited;
end;

procedure TAsphyreIntroVideo.FAddLOGMessage(const Text: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create();
  if (FileExists(FLogFile)) then
    SL.LoadFromFile(FLogFile)
  else
    SL.Add('[' + DateToStr(Date) + ' - ' + TimeToStr(Time) + ']');

  SL.Add(Text);
  SL.SaveToFile(FLogFile);
  
  FreeAndNil(SL);
end;

procedure TAsphyreIntroVideo.FClearGraph(const AddRenderer: Boolean = True);
var
  X: Integer;
  Res: HRESULT;
  Enum: IEnumFilters;
  IL: TInterfaceList;
  Filter: IBaseFilter;
  FilterInfo: _FilterInfo;
begin
  if (FGraphBuilded) then begin
    Res := FVideoWindow.put_Visible(False);
    if (not Succeeded(Res)) then
      case (FErrorMode) of
        cemMessageBox: FcShowMessage('FVideoWindow.put_Visible', 'FClearGraph');
        cemException: CheckDSError(Res);
        cemLog: FAddLOGMessage('FClearGraph - FVideoWindow.put_Visible');
      end;
  end;

  IL := TInterfaceList.Create();

  FGraphBuilder.EnumFilters(Enum);
  while (Enum.Next(1, Filter, nil) = S_OK) do
    IL.Add(Filter);

  for X := 0 to IL.Count - 1 do begin
    IBaseFilter(IL[X]).QueryFilterInfo(FilterInfo);
    Res := FGraphBuilder.RemoveFilter(IBaseFilter(IL[X]));
    if (not Succeeded(Res)) then
      case (FErrorMode) of
        cemMessageBox: FcShowMessage(Format('FGraphBuilder.RemoveFilter(%s)',
          [FilterInfo.achName]), 'FClearGraph');
        cemException: CheckDSError(Res);
        cemLog: FAddLOGMessage('FClearGraph - ' + Format('FGraphBuilder.RemoveFilter(%s)',
          [FilterInfo.achName]));
      end;
  end;

  IL.Clear();
  FreeAndNil(IL);
  FGraphBuilded := False;

  if (AddRenderer) then
    FGraphBuilder.AddFilter(FRenderer, 'Video Renderer');
end;

procedure TAsphyreIntroVideo.FInitVideoWindow;
var
  R: TRect;
  Res: HRESULT;
  Style: Integer;
begin
  if (not FIsInit) then
    Exit;

  Res := FVideoWindow.put_Owner(FOwnerHandle);
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FVideoWindow.put_Owner', 'FInitVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.put_Owner');
    end;

  Res := FVideoWindow.put_MessageDrain(FOwnerHandle);
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FVideoWindow.put_MessageDrain', 'FInitVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.put_MessageDrain');
    end;

  Res := FVideoWindow.get_WindowStyle(Style);
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FVideoWindow.get_WindowStyle', 'FInitVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.get_WindowStyle');
    end;

  Res := FVideoWindow.put_WindowStyle(Style and (not (WS_BORDER or WS_CAPTION
    or WS_THICKFRAME)));
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FVideoWindow.put_WindowStyle', 'FInitVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.put_WindowStyle');
    end;

  if (not GetClientRect(FOwnerHandle, R)) then begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('GetClientRect', 'FInitVideoWindow');
      cemLog: FAddLOGMessage('FInitVideoWindow - GetClientRect');
    end;

    R.Right := FAsphyreDevice.Width;
    R.Bottom := FAsphyreDevice.Height;
  end;

  Res := FVideoWindow.SetWindowPosition(0, 0, R.Right, R.Bottom);
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FVideoWindow.SetWindowPosition', 'FInitVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.SetWindowPosition');
    end;

// This is automatically
//  Res := FVideoWindow.put_Visible(True);
//  if (not Succeeded(Res)) then
//    case (FErrorMode) of
//      cemMessageBox: FcShowMessage('FVideoWindow.SetWindowPosition', 'FInitVideoWindow');
//      cemException: CheckDSError(Res);
//      cemLog: FAddLOGMessage('FInitVideoWindow - FVideoWindow.SetWindowPosition');
//    end;
end;

procedure TAsphyreIntroVideo.FSetTempDir(const Value: string);
begin
  if (Trim(Value) = '') then
    Exit
  else
    FTempDir := IncludeTrailingPathDelimiter(Value);
end;

procedure TAsphyreIntroVideo.FSetVolume();
var
  Res: HRESULT;
  oVolume: Integer;
begin
  if (not FIsInit) then
    Exit;

  oVolume := EnsureRange(FVolume, 0, 100);
  oVolume := oVolume * 100 - 10000;

  Res := FBAudio.put_Volume(oVolume);
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FBAudio.put_Volume', 'FSetVolume');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FSetVolume - FBAudio.put_Volume');
    end;
end;

procedure TAsphyreIntroVideo.FStartAsphyre;
begin
  Stop();

  FClearGraph();

  if (FTAutoRun) and (FAsphyreDevice.Initialized) then
    FAsphyreTimer.Enabled := True;

  if (FTempFiles <> nil) then
    FDeleteTempFiles();
  
  if (Assigned(FDone)) then
    FDone(Self);
end;

procedure TAsphyreIntroVideo.FWndProc(var Msg: TMessage);
begin
  case (Msg.Msg) of
    WM_GRAPHNOTIFY: begin
      try
        FHandleEvents();
      except
        Application.HandleException(Self);
      end;
    end;

  end;
end;

procedure TAsphyreIntroVideo.FHandleEvents;
var
  Res, Event, Param1, Param2: Integer;
begin
  Res := FMEvents.GetEvent(Event, Param1, Param2, 0);

  while (Res = S_OK) do begin

    case (Event) of
      EC_COMPLETE: begin
        Stop();
        Next();
      end;
    end;
    
    // Remove event from list
    FMEvents.FreeEventParams(Event, Param1, Param2);
    Res := FMEvents.GetEvent(Event, Param1, Param2, 0);
  end;
end;

function TAsphyreIntroVideo.FLoadFileToGraph(): Boolean;
var
  Res: Integer;
  FeName, mTxt: string;
begin
  Result := False;

  if (not FIsInit) or (FActualFile = '') then
    Exit;

  FeName := ExtractFileName(FActualFile);
    
  FClearGraph();

  Res := FGraphBuilder.RenderFile(PWideChar(WideString(FActualFile)), nil);
  Result := Succeeded(Res);
  if (Result) then begin
    case (Res) of
      S_OK: mTxt := '';
      VFW_S_AUDIO_NOT_RENDERED: mTxt := '';
      VFW_S_VIDEO_NOT_RENDERED: mTxt := 'VFW_S_VIDEO_NOT_RENDERED';
      VFW_S_DUPLICATE_NAME: mTxt := 'VFW_S_DUPLICATE_NAME';
      VFW_S_PARTIAL_RENDER: begin
        if (Succeeded(FBAudio.get_Volume(Res))) then
          mTxt := 'VFW_S_PARTIAL_RENDER'
        else
          mTxt := '';
      end;
      
      else mTxt := '';
    end;

    if (mTxt <> '') then begin
      case (FErrorMode) of
        cemMessageBox: FcShowMessage(mTxt, FeName);
        cemException: CheckDSError(Res);
        cemLog: FAddLOGMessage(FeName + ' - ' + mTxt);
      end;

      Result := False;
    end;
  end else if (not Result) then begin
    case (Res) of      
      E_ABORT: mTxt := 'E_ABORT';
      E_FAIL: mTxt := 'E_FAIL';
      E_INVALIDARG: mTxt := 'E_INVALIDARG';
      E_OUTOFMEMORY: mTxt := 'E_OUTOFMEMORY';
      E_POINTER: mTxt := 'E_POINTER';
      VFW_E_CANNOT_CONNECT: mTxt := 'VFW_E_CANNOT_CONNECT';
      VFW_E_CANNOT_LOAD_SOURCE_FILTER: mTxt := 'VFW_E_CANNOT_LOAD_SOURCE_FILTER';
      VFW_E_CANNOT_RENDER: mTxt := 'VFW_E_CANNOT_RENDER';
      VFW_E_INVALID_FILE_FORMAT: mTxt := 'VFW_E_INVALID_FILE_FORMAT';
      VFW_E_NOT_FOUND: mTxt := 'VFW_E_NOT_FOUND';
      VFW_E_UNSUPPORTED_STREAM: mTxt := 'VFW_E_UNSUPPORTED_STREAM';
      VFW_E_UNKNOWN_FILE_TYPE: mTxt := 'VFW_E_UNKNOWN_FILE_TYPE';
      VFW_E_NO_AUDIO_HARDWARE: mTxt := 'VFW_E_NO_AUDIO_HARDWARE';
      else mTxt := 'Unknown Error';
    end;

    case (FErrorMode) of
      cemMessageBox: FcShowMessage(mTxt, FeName);
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage(FeName + ' - ' + mTxt);
    end;
  end;
  
  FGraphBuilded := Result;
  if (Result) then
    FInitVideoWindow();
end;

function TAsphyreIntroVideo.Init(): Boolean;
var
  Res: HRESULT;
begin
  Result := False;

  if (FAsphyreDevice = nil) or (FAsphyreTimer = nil) then
    Exit;

  // Graph builder
  Res := CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
    IID_IGraphBuilder, FGraphBuilder);
  if (Res <> S_OK) then begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('CoCreateInstance', 'FGraphBuilder');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FGraphBuilder - CoCreateInstance');
    end;

    Exit;
  end;

  // Video renderer
  Res := CoCreateInstance(CLSID_VideoRenderer, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, FRenderer);
  if (Res <> S_OK) then begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('CoCreateInstance', 'FRenderer');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FRenderer - CoCreateInstance');
    end;

    Exit;
  end;

  // Video window
  Res := FRenderer.QueryInterface(IID_IVideoWindow, FVideoWindow);
  if (Res <> S_OK) then begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('QueryInterface', 'FVideoWindow');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FVideoWindow - QueryInterface');
    end;

    Exit;
  end;

  // Audio control
  Res := FGraphBuilder.QueryInterface(IID_IBasicAudio, FBAudio);
  if (Res <> S_OK) then  begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('QueryInterface', 'FBAudio');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FBAudio - QueryInterface');
    end;

    Exit;
  end;

  // Media control
  Res := FGraphBuilder.QueryInterface(IID_IMediaControl, FMControl);
  if (Res <> S_OK) then  begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('QueryInterface', 'FMControl');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FMControl - QueryInterface');
    end;

    Exit;
  end;

  // Events
  Res := FGraphBuilder.QueryInterface(IID_IMediaEventEx, FMEvents);
  if (Res <> S_OK) then  begin
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('QueryInterface', 'FMEvents');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('FMEvents - QueryInterface');
    end;

    Exit;
  end;

  // Set events
  FMEvents.SetNotifyFlags(0); // Enable
  FMEvents.SetNotifyWindow(FWinHandle, WM_GRAPHNOTIFY, ULONG(FMEvents));

  Result := True;
  FIsInit := True;
end;

procedure TAsphyreIntroVideo.Next;
begin
  if (not FIsInit) then
    Exit;

  Inc(FActualIndex);
  if (FActualIndex > FCount - 1) and (FLoop) then
    FActualIndex := 0
  else if (FActualIndex > FCount - 1) and (not FLoop) then begin
    FStartAsphyre();
    Exit;
  end;

  FActualFile := FPlayLst[FActualIndex];
  if (not Play()) then
    Next();
end;

procedure TAsphyreIntroVideo.Pause;
var
  Res: HRESULT;
begin
  if (not FIsInit) then
    Exit;

  Res := FMControl.Pause();
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FMControl.Pause', 'Pause');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('Pause - FMControl.Pause');
    end;

  if (Succeeded(Res)) then
    FState := aivsPaused;
end;

function TAsphyreIntroVideo.Play(): Boolean;
var
  Res: HRESULT;
begin
  Result := False;

  if (not FIsInit) then
    Exit;

  if (FLoadFileToGraph()) then begin
    FSetVolume();
    Res := FMControl.Run();
    if (not Succeeded(Res)) then
      case (FErrorMode) of
        cemMessageBox: FcShowMessage('FMControl.Run', 'Run');
        cemException: CheckDSError(Res);
        cemLog: FAddLOGMessage('Run - FMControl.Run');
      end;
    Result := Succeeded(FMControl.Run);
    if (Result) then
      FState := aivsPlaying;
  end else begin
    if (FActualIndex = 0) then
      Next();
  end;
end;

procedure TAsphyreIntroVideo.Stop;
var
  Res: HRESULT;
begin
  if (not FIsInit) then
    Exit;

  Res := FMControl.Stop();
  if (not Succeeded(Res)) then
    case (FErrorMode) of
      cemMessageBox: FcShowMessage('FMControl.Stop', 'Stop');
      cemException: CheckDSError(Res);
      cemLog: FAddLOGMessage('Stop - FMControl.Stop');
    end;

  if (Succeeded(Res)) then
    FState := aivsStopped;
end;

{ TVideoTexture }

constructor TVideoTexture.Create;
begin
  inherited;

  FSampleGrabber := nil;
  FFileName := '';
end;

destructor TVideoTexture.Destroy;
begin
  FSampleGrabber := nil;

  inherited;
end;

end.

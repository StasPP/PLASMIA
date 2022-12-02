unit SoundSystem;
interface

uses
  Windows,
  SysUtils,
  Forms,
  Math,
  Dialogs,
  Classes,
  ExtCtrls,
  AsphyreDb,
  Audiere;

type
  TSoundData = class;
  TNotifyEvent = procedure(Sender: TObject) of object;
  TASDbLoadEvent = procedure(Sender: TObject; Index: Integer; var Name: string) of Object;
  TErrorEvent = procedure(Sender: TObject; ErrorText: String) of Object;
  TFadeInitializeEvent = procedure(Sender: TObject; Index: Integer; Name: String) of Object;
  TFadeFinalizeEvent = procedure(Sender: TObject; Index: Integer; Name: String) of Object;
  TSoundType = (sntNotSupported, sntMOD, sntMP3, sntOGG, sntWAV, sntAIFF, sntFLAC, sntSPX);
  TFadeType = (ftFadeIn, ftFadeOut);

  TSoundSystem = class(TComponent)
  private
    FOnASDbLoad: TASDbLoadEvent;
    FOnError: TErrorEvent;
    FOnFadeInInitialize: TFadeInitializeEvent;
    FOnFadeInFinalize: TFadeFinalizeEvent;
    FOnFadeOutInitialize: TFadeInitializeEvent;
    FOnFadeOutFinalize: TFadeFinalizeEvent;
    FCount: Integer;
    LoadedSounds: Array of TSoundData;
    { change for start volume - 15/jul/2006 }
    FMaxVolume: Integer;
    procedure SetMaxVolume(const Value: Integer);
    { end changes }
  protected
    function GetSoundTypeFromFileName(FileName: String): TSoundType;
    procedure Error(ErrorText: String);
  public
    AudioDevice: TAudiereAudioDevice;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function LoadFromASDb(ASDb: TASDb): Boolean;
    procedure UnLoad;
    function AddFromASDb(Key: string; ASDb: TASDb): Boolean;
    function AddFromFile(FileName: String): Boolean;
    procedure Play(Idx: Integer; Looped: Boolean);  overload;
    procedure Play(Name: String; Looped: Boolean);  overload;
    procedure Stop(Idx: Integer);  overload;
    procedure Stop(Name: String);  overload;
    procedure StopAll;
    function IsPlaying(Idx: Integer): Boolean; overload;
    function IsPlaying(Name: String): Boolean; overload;
    function GetSoundPos(Name: String): Integer; overload;
    function GetSoundPos(Idx: Integer): Integer; overload;
    procedure SetSoundPos(Idx: Integer; Pos: Integer); overload;
    procedure SetSoundPos(Name: String; Pos: Integer); overload;
    procedure SetVolume(Idx, Volume: Integer); overload;
    procedure SetVolume(Name: String; Volume: Integer); overload;
    function GetVolume(Idx: Integer): Integer; overload;
    function GetVolume(Name: String): Integer; overload;
    procedure SetPan(Idx, Pan: Integer); overload;
    procedure SetPan(Name: String; Pan: Integer); overload;
    function GetPan(Idx: Integer): Integer; overload;
    function GetPan(Name: String): Integer; overload;
    procedure SetPitch(Idx, Pitch: Integer); overload;
    procedure SetPitch(Name: String; Pitch: Integer); overload;
    function GetPitch(Idx: Integer): Integer; overload;
    function GetPitch(Name: String): Integer; overload;
    procedure FadeIn(Idx, TimerInterval: Integer);  overload;
    procedure FadeOut(Idx, TimerInterval: Integer); overload;
    procedure FadeIn(Name: String; TimerInterval: Integer);  overload;
    procedure FadeOut(Name: String; TimerInterval: Integer); overload;
    function FileExist(FileName: String): Boolean;
    procedure SetRepeat(Idx: Integer; Looped: Boolean);  overload;
    procedure SetRepeat(Name: String; Looped: Boolean);  overload;
    procedure Reset(Idx: Integer);  overload;
    procedure Reset(Name: String);  overload;
    function GetDllVersion: String;
  published
    property Count: Integer read FCount;
    property OnLoad: TASDbLoadEvent read FOnASDbLoad write FOnASDbLoad;
    property MaxVolume: Integer read FMaxVolume write SetMaxVolume;
    property OnError: TErrorEvent read FOnError write FOnError;
    property OnFadeInInitialize: TFadeInitializeEvent read FOnFadeInInitialize write FOnFadeInInitialize;
    property OnFadeInFinalize: TFadeFinalizeEvent read FOnFadeInFinalize write FOnFadeInFinalize;
    property OnFadeOutInitialize: TFadeInitializeEvent read FOnFadeOutInitialize write FOnFadeOutInitialize;
    property OnFadeOutFinalize: TFadeFinalizeEvent read FOnFadeOutFinalize write FOnFadeOutFinalize;
  end;

  TSoundData = class
    Timer: TTimer;
    SfxStream: TMemoryStream;
    Name: String;
    Index: Integer;
    SoundType: TSoundType;
    FadeIn: Boolean;
    FadeFinalized: TFadeFinalizeEvent;
    MaxVolume: Integer;
    SampleFile: TAudiereFile;
    SampleSource: TAudiereSampleSource;
    OutputStream: TAudiereOutputStream;
    AudioDevice: TAudiereAudioDevice;
    constructor Create(AudioDevice: TAudiereAudioDevice; SfxStream: TMemoryStream; Index: Integer; Filename: String; SoundType: TSoundType);
    destructor Destroy; override;
    function GetVolume: Integer;
    procedure SetVolume(const Value: Integer);
    function GetPan: Integer;
    procedure SetPan(const Value: Integer);
    function GetPitch: Integer;
    procedure SetPitch(const Value: Integer);
    procedure StartFade(Interval: Integer; FadeType: TFadeType; FadeEndEvent: TFadeFinalizeEvent);
    procedure OnTimer(Sender: TObject);
    procedure KillTimer;
    procedure Play(Looped: Boolean);
    function IsPlaying: Boolean;
    procedure Stop;
    function GetSoundPos: Integer; overload;
    procedure SetSoundPos(Pos: Integer); overload;
    procedure SetRepeat(const Value: Boolean);
    procedure Reset;
  end;

procedure Register;

implementation

constructor TSoundSystem.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FCount := 0;
  if AudiereLoadDll then begin
    AudioDevice := AudiereOpenDevice('', '');
    if Assigned(AudioDevice) then
      AudioDevice.Ref
    else
      Error('Error initializing sound. Device Open failed !');
  end else
    Error('Error initializing sound. Audiere.dll was not loaded !');
end;

destructor TSoundSystem.Destroy;
begin
  AudioDevice.UnRef;
  AudiereUnloadDLL;
  Unload;
  inherited Destroy;
end;

function TSoundSystem.GetDllVersion: String;
begin
  Result := AudiereGetVersion;
end;

procedure TSoundSystem.Error(ErrorText:String);
begin
  if Assigned(OnError) then
    OnError(Self, ErrorText);
end;

function TSoundSystem.FileExist(FileName: String): Boolean;
var
  Loop: Integer;
  Sound: TSoundData;
begin
  Result := False;
  if Fcount > 0 then begin
    for Loop := 0 to FCount - 1 do begin
      Sound := LoadedSounds[Loop];
      if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) and (Sound.Name = FileName) then begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.AddFromFile(FileName: String): Boolean;
var TempStream: TMemoryStream;

  procedure LoadError;
  begin
    Error('Error while loading ' + FileName + ' !');
  end;

begin
  Result := True;
  if not FileExist(FileName) then begin
    Result := False;
    TempStream := TMemoryStream.Create;
    try
      if Assigned(TempStream) then begin
        TempStream.LoadFromFile(FileName);
        try
          Inc(FCount);
          SetLength(LoadedSounds, FCount);
          LoadedSounds[FCount - 1] := TSoundData.Create(AudioDevice, TempStream, FCount, FileName, GetSoundTypeFromFileName(FileName));
          Result := True;
          if Assigned(OnLoad) then
            OnLoad(Self, FCount - 1, FileName);
        except
         LoadError;
        end;
      end;
    except
      LoadError;
    end;
  end;
end;

function TSoundSystem.AddFromASDb(Key: string; ASDb: TASDb): Boolean;
var TempStream: TMemoryStream;
begin
  Result := True;
  if not FileExist(Key) then begin
    Result := False;
    TempStream := TMemoryStream.Create;
    try
      if Assigned(TempStream) then begin
        if ASDb.ReadStream(Key, TempStream) then begin
          Inc(FCount);
          SetLength(LoadedSounds, FCount);
          LoadedSounds[FCount - 1] := TSoundData.Create(AudioDevice, TempStream, FCount, Key, GetSoundTypeFromFileName(Key));
          Result := True;
          if Assigned(OnLoad) then
            OnLoad(Self, FCount - 1, Key);
        end;
      end else
        Error('Internal error. Memorystream not assigned !');
    except
      Error('Error while loading ' + Key + ' !');
    end;
  end;
end;

function TSoundSystem.LoadFromASDb(ASDb: TASDb): Boolean;
var
  Index  : Integer;
  Key: String;
begin
  Result:= ASDb.UpdateOnce;
  if (not Result) then
    Exit;
  Result := False;
  for Index:= 0 to ASDb.RecordCount - 1 do begin
    Key := ASDb.RecordKey[Index];
    if GetSoundTypefromFileName(Key) <> sntNotSupported then
      Result := AddFromASDb(Key, ASDb);
  end;
end;

procedure TSoundSystem.UnLoad;
var Idx: Integer;
    Sound: TSoundData;
begin
  if FCount > 0 then begin
    for Idx := 0 to FCount - 1 do begin
      Sound := LoadedSounds[Idx];
      if (Sound <> nil) then begin
        FreeAndNil(Sound);
        LoadedSounds[Idx] := nil;
        
      end;
    end;
  end;
  FCount := 0;
  SetLength(LoadedSounds, FCount);
end;

procedure TSoundSystem.Play(Idx: Integer; Looped: Boolean);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then begin
    Error('Unable to play sound no.:  ' + IntToStr(Idx));
    Exit;
  end;
  Sound := LoadedSounds[Idx];
  { change for start volume - 15/jul/2006 }
  Sound.MaxVolume := Self.MaxVolume;
  { end changes }
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
    Sound.Play(Looped);
  end else
    Error('Unable to play sound ' + Sound.Name);
end;

procedure TSoundSystem.Play(Name: String; Looped: Boolean);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Play(Loop, Looped);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.Stop(Idx: Integer);
var
  Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.Stop;
end;

procedure TSoundSystem.Stop(Name: String);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Stop(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.StopAll;
var
  Idx: Integer;
begin
  if FCount = 0 then
    Exit;
  for Idx := 0 to FCount - 1 do
    Stop(Idx);
end;

function TSoundSystem.IsPlaying(Idx: Integer): Boolean;
var Sound: TSoundData;
begin
  Result := False;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];

  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Result := Sound.IsPlaying;
end;

function TSoundSystem.IsPlaying(Name: String): Boolean;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := False;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Result := IsPlaying(Loop);
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.GetSoundPos(Idx: Integer): Integer;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Result := Sound.GetSoundPos;
end;

function TSoundSystem.GetSoundPos(Name: String): Integer;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Result := Sound.GetSoundPos;
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.SetSoundPos(Idx: Integer; Pos: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.SetSoundPos(Pos);
end;

procedure TSoundSystem.SetSoundPos(Name: String; Pos: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Sound.SetSoundPos(Pos);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.FadeIn(Idx, TimerInterval: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
    Sound.SetVolume(0);
    Sound.StartFade(TimerInterval, ftFadeIn, OnFadeInFinalize);
    if (Assigned(OnFadeInInitialize)) then
      OnFadeInInitialize(Self, Idx, Sound.Name);
  end;
end;

procedure TSoundSystem.FadeIn(Name: String; TimerInterval: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        FadeIn(Loop, TimerInterval);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.FadeOut(Idx, TimerInterval: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
    Sound.StartFade(TimerInterval, ftFadeOut, OnFadeOutFinalize);
    if (Assigned(OnFadeOutInitialize)) then
      OnFadeOutInitialize(Self, Idx, Sound.Name);
  end;
end;

procedure TSoundSystem.FadeOut(Name: String; TimerInterval: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        FadeOut(Loop, TimerInterval);
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.GetSoundTypeFromFilename(Filename: String): TSoundType;
var sExt: String;
begin
  sExt := UpperCase(ExtractFileExt(Filename));
  if (sExt = '.MOD') or (sExt = '.XM') or (sExt = '.S3M') or (sExt = '.IT') then
    Result := sntMOD
  else if (sExt = '.MP2') or (sExt = '.MP3') then
    Result := sntMP3
  else if(sExt = '.OGG') then
    Result := sntOGG
  else if(sExt = '.WAV') then
    Result := sntWAV
  else if(sExt = '.FLAC') then
    Result := sntFLAC
  else if(sExt = '.AIFF') then
    Result := sntAIFF
  else if(sExt = '.SPX') then
    Result := sntSPX
  else
    Result := sntNotSupported;
end;

procedure TSoundSystem.SetVolume(Idx, Volume: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.SetVolume(Volume);
end;

procedure TSoundSystem.SetVolume(Name: String; Volume: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        SetVolume(Loop, Volume);
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.GetVolume(Idx: Integer): Integer;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Result := Sound.GetVolume;
end;

function TSoundSystem.GetVolume(Name: String): Integer;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Result := GetVolume(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.SetPan(Idx, Pan: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.SetPan(Pan);
end;

{ change for start volume - 15/jul/2006 }
procedure TSoundSystem.SetMaxVolume(const Value: Integer);
begin
   FMaxVolume := Value;
end;
{ end changes }

procedure TSoundSystem.SetPan(Name: String; Pan: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        SetPan(Loop, Pan);
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.GetPan(Idx: Integer): Integer;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Result := Sound.GetPan;
end;

function TSoundSystem.GetPan(Name: String): Integer;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Result := GetPan(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.SetPitch(Idx, Pitch: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.SetPitch(Pitch);
end;

procedure TSoundSystem.SetPitch(Name: String; Pitch: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        SetPitch(Loop, Pitch);
        Break;
      end;
    end;
  end;
end;

function TSoundSystem.GetPitch(Idx: Integer): Integer;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Result := Sound.GetPitch;
end;

function TSoundSystem.GetPitch(Name: String): Integer;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Result := GetPitch(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.SetRepeat(Idx: Integer; Looped: Boolean);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.SetRepeat(Looped);
end;

procedure TSoundSystem.SetRepeat(Name: String; Looped: Boolean);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        SetRepeat(Loop, Looped);
        Break;
      end;
    end;
  end;
end;

procedure TSoundSystem.Reset(Idx: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then
    Sound.Reset;
end;

procedure TSoundSystem.Reset(Name: String);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Assigned(Sound)) and (Assigned(Sound.SfxStream)) then begin
      if Sound.Name = Name then begin
        Reset(Loop);
        Break;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

constructor TSoundData.Create(AudioDevice: TAudiereAudioDevice; SfxStream: TMemoryStream; Index: Integer; Filename: String; SoundType: TSoundType);
begin
  Self.AudioDevice := AudioDevice;
  Self.SfxStream := SfxStream;
  Self.Name := Filename;
  Self.SoundType := SoundType;
  Self.Index := Index;
  Self.MaxVolume := 100; 
  SetVolume(MaxVolume);
end;

destructor TSoundData.Destroy;
begin
  if Assigned(SfxStream) then
    SfxStream.Free;
end;

procedure TSoundData.Play(Looped: Boolean);
begin
  if Assigned(SfxStream){ and not IsPlaying }then begin
    SampleFile := AudiereCreateMemoryFile(SfxStream.Memory, SfxStream.Size);
    if Assigned(SampleFile) then begin
      SampleSource := AudiereOpenSampleSourceFromFile(SampleFile, FF_AUTODETECT);
      if Assigned(SampleSource) then begin
        OutputStream := AudiereOpenSound(AudioDevice, SampleSource, True);
        if Assigned(OutputStream) then begin
          { change for start volume - 15/jul/2006 }
          SetVolume(MaxVolume);
          { end changes }
          OutputStream.Ref;
          OutputStream.SetRepeat(Looped);
          OutputStream.Play;
        end;
      end;
    end;
  end;
end;

function TSoundData.IsPlaying: Boolean;
begin
  if Assigned(OutputStream) then
    Result := OutputStream.IsPlaying
  else
    Result := False;
end;

procedure TSoundData.Stop;
begin
  if Assigned(OutputStream) then
    if IsPlaying then begin
      OutputStream.Stop;
      OutputStream.UnRef;
      KillTimer;
      //OutputStream.Free;
      //Outputstream.Destroy;
      
      OutputStream := nil;
    end;
end;

procedure TSoundData.KillTimer;
begin
  if Assigned(Timer) then begin
    Timer.Enabled := False;
    Timer.OnTimer := nil;
    FreeAndNil(Timer);
  end;
end;

procedure TSoundData.OnTimer(Sender: TObject);
var AktVolume: Integer;
begin
  AktVolume := GetVolume;
  if FadeIn then begin
    Inc(AktVolume);
    if AktVolume > MaxVolume then begin
      KillTimer;
      if Assigned(FadeFinalized) then
        FadeFinalized(Self, Index, Name);
    end else
      SetVolume(AktVolume);
  end else begin
    Dec(AktVolume);
    if AktVolume <= 0 then begin
      KillTimer;
      Stop;
      if Assigned(FadeFinalized) then
        FadeFinalized(Self, Index, Name);
    end else
      SetVolume(AktVolume);
  end;
end;

procedure TSoundData.StartFade(Interval: Integer; FadeType: TFadeType; FadeEndEvent: TFadeFinalizeEvent);
begin
  KillTimer;
  case FadeType of
    ftFadeIn: FadeIn := True;
    ftFadeOut: FadeIn := False;
  end;
  FadeFinalized := FadeEndEvent;
  Timer := TTimer.Create(nil);
  Timer.Interval := Interval;
  Timer.OnTimer := OnTimer;
  Timer.Enabled := True;
end;

function TSoundData.GetVolume: Integer;
begin
  if Assigned(OutputStream) then
    Result := Round(OutputStream.GetVolume * 100)
  else
    Result := -1;
end;

procedure TSoundData.SetVolume(const Value: Integer);
begin
  if Assigned(OutputStream) then
    OutputStream.SetVolume(Max(0, Min(Value, 100)) / 100);
end;

function TSoundData.GetSoundPos: Integer;
begin
  Result := -1;
  if Assigned(OutputStream) then
    if OutputStream.IsPlaying and OutputStream.IsSeekable then
      Result := OutputStream.GetPosition;
end;

procedure TSoundData.SetSoundPos(Pos: Integer);
begin
  if Assigned(OutputStream) then
    if (OutPutStream.IsSeekable) then
      OutputStream.SetPosition(Pos);
end;

function TSoundData.GetPan: Integer;
begin
  if Assigned(OutputStream) then
    Result := Round(OutputStream.GetPan * 100)
  else
    Result := -1;
end;

procedure TSoundData.SetPan(const Value: Integer);
begin
  if Assigned(OutputStream) then
    OutputStream.SetPan(Max(-100, Min(Value, 100)) / 100);
end;
function TSoundData.GetPitch: Integer;
begin
  if Assigned(OutputStream) then
    Result := Round(OutputStream.GetPitchShift * 10)
  else
    Result := -1;
end;

procedure TSoundData.SetPitch(const Value: Integer);
begin
  if Assigned(OutputStream) then
    OutputStream.SetPitchShift(Max(5, Min(Value, 20)) / 10);
end;

procedure TSoundData.SetRepeat(const Value: Boolean);
begin
  if Assigned(OutputStream) then
    OutputStream.SetRepeat(Value);
end;

procedure TSoundData.Reset;
begin
  if Assigned(OutputStream) then
    OutputStream.Reset;
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('Asphyre', [TSoundSystem]);
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

end.

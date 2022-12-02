unit BassSoundSystem;
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
  Bass;

procedure LoopSyncProc(Handle: HSYNC; Channel, Data, User: DWORD); stdcall;

type
  TSoundData = class;
  TNotifyEvent = procedure(Sender: TObject) of object;
  TASDbLoadEvent = procedure(Sender: TObject; Index: Integer; var Name: string) of Object;
  TErrorEvent = procedure(Sender: TObject; ErrorText: String) of Object;
  TFadeInitializeEvent = procedure(Sender: TObject; Index: Integer; Name: String) of Object;
  TFadeFinalizeEvent = procedure(Sender: TObject; Index: Integer; Name: String) of Object;
  TSoundType = (sntNotSupported, sntMOD, sntMP3, sntOGG, sntWAV);
  TFadeType = (ftFadeIn, ftFadeOut);
  TWaveData = array [ 0..2048] of DWord;
  TFFTData  = array [0..512] of Single;

  TBassSoundSystem = class(TComponent)
  private
    FOnASDbLoad: TASDbLoadEvent;
    FOnError: TErrorEvent;
    FOnFadeInInitialize: TFadeInitializeEvent;
    FOnFadeInFinalize: TFadeFinalizeEvent;
    FOnFadeOutInitialize: TFadeInitializeEvent;
    FOnFadeOutFinalize: TFadeFinalizeEvent;
    FCount: Integer;
    LoadedSounds: Array of TSoundData;
  protected
    function GetSoundTypeFromFileName(FileName: String): TSoundType;
    procedure Error(ErrorText: String);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function LoadFromASDb(ASDb: TASDb): Boolean;
    procedure UnLoad;
    function AddFromASDb(const Key: string; ASDb: TASDb): Boolean;
    function AddFromFile(const FileName: String): Boolean;
    function GetGeneralVolume: Integer;
    procedure SetGeneralVolume(const Value: Integer);
    procedure Play(Idx: Integer; Looped: Boolean);  overload;
    procedure Play(Name: String; Looped: Boolean);  overload;
    procedure Stop(Idx: Integer);  overload;
    procedure Stop(Name: String);  overload;
    procedure StopAll;
    function IsPlaying(Idx: Integer): Boolean; overload;
    function IsPlaying(Name: String): Boolean; overload;
    function GetFFTData(Idx: Integer): TFFTData; overload;
    function GetFFTData(Name: String): TFFTData; overload;
    function GetSoundPos(Name: String): QWord; overload;
    function GetSoundPos(Idx: Integer): QWord; overload;
    procedure SetSoundPos(Idx: Integer; Pos: QWord); overload;
    procedure SetSoundPos(Name: String; Pos: QWord); overload;
    function GetCPUUsage: String;
    procedure SetVolume(Idx, Volume: Integer); overload;
    procedure SetVolume(Name: String; Volume: Integer); overload;
    function GetVolume(Idx: Integer): Integer; overload;
    function GetVolume(Name: String): Integer; overload;
    procedure FadeIn(Idx, TimerInterval: Integer);  overload;
    procedure FadeOut(Idx, TimerInterval: Integer); overload;
    procedure FadeIn(Name: String; TimerInterval: Integer);  overload;
    procedure FadeOut(Name: String; TimerInterval: Integer); overload;
    procedure SetPan(Idx, Pan: Integer);  overload;
    procedure SetPan(Name: String; Pan: Integer); overload;
  published
    property Count: Integer read FCount;
    property OnLoad: TASDbLoadEvent read FOnASDbLoad write FOnASDbLoad;
    property OnError: TErrorEvent read FOnError write FOnError;
    property OnFadeInInitialize: TFadeInitializeEvent read FOnFadeInInitialize write FOnFadeInInitialize;
    property OnFadeInFinalize: TFadeFinalizeEvent read FOnFadeInFinalize write FOnFadeInFinalize;
    property OnFadeOutInitialize: TFadeInitializeEvent read FOnFadeOutInitialize write FOnFadeOutInitialize;
    property OnFadeOutFinalize: TFadeFinalizeEvent read FOnFadeOutFinalize write FOnFadeOutFinalize;
  end;

  TSoundData = class
    Timer: TTimer;
    Handle: Cardinal;
    Name: String;
    Index: Integer;
    SoundType: TSoundType;
    FadeIn: Boolean;
    MaxVolume: Integer;
    FadeFinalized: TFadeFinalizeEvent;
    FSync: HSYNC;
   constructor Create(Handle: Cardinal; Index: Integer; Filename: String; SoundType: TSoundType; MaxVolume: Integer);
    destructor Destroy; override;
    function GetVolume: Integer;
    procedure SetVolume(const Value: Integer);
    procedure SetPan(const Value: Integer);
    procedure StartFade(Interval: Integer; FadeType: TFadeType; FadeEndEvent: TFadeFinalizeEvent);
    procedure OnTimer(Sender: TObject);
    procedure KillTimer;
    function Play(Looped: Boolean): Boolean;
    function IsPlaying: Boolean;
    procedure Stop;
  end;

procedure Register;

implementation

constructor TBassSoundSystem.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  if BASS_GetVersion() <> DWORD(MAKELONG(2,2)) then
    Error('Error initializing sound. BASS version 2.2 was not loaded!');
  if not BASS_Init(-1, 44100, 0, 0, nil) then
    Error('Error initializing sound');
end;

destructor TBassSoundSystem.Destroy;
begin
  BASS_Stop;
  Unload;
  inherited Destroy;
end;

procedure TBassSoundSystem.Error(ErrorText:String);
begin
  if Assigned(OnError) then
    OnError(Self, ErrorText);
end;

function TBassSoundSystem.AddFromFile(const FileName: String): Boolean;
var Handle: Cardinal;
    SoundType: TSoundType;
    Name: String;
begin
  Result := False;
  Handle := 0;
  SoundType := GetSoundTypeFromFilename(FileName);
  if SoundType <> sntNotSupported then begin
    case SoundType of
      sntMOD: Handle := BASS_MusicLoad(False, PChar(FileName), 0, 0, BASS_MUSIC_RAMP, 0);
      sntMP3,
      sntOGG: Handle := BASS_StreamCreateFile(False, PChar(FileName), 0, 0, 0);
      sntWAV: Handle := BASS_SampleLoad(False, PChar(FileName), 0, 0, 3, BASS_SAMPLE_OVER_POS);
      sntNotSupported: Error('Unable to load sound ' + FileName + ' - format is not supported');
    end;
    if Handle = 0 then
      Error('Unable to load sound ' + FileName + ' - BASS errocode ' + IntToStr(BASS_ErrorGetCode))
    else begin
      SetLength(LoadedSounds, FCount + 1);
      Name := ExtractFileName(FileName);
      LoadedSounds[FCount] := TSoundData.Create(Handle, FCount, Name, SoundType, 100);
      if (Assigned(OnLoad)) then
        OnLoad(Self, FCount, Name);
      Inc(FCount);
    end;
    Result := Handle <> 0;
  end;
end;

function TBassSoundSystem.AddFromASDb(const Key: string; ASDb: TASDb): Boolean;
var Handle: Cardinal;
    SoundType: TSoundType;
    Stream: TMemoryStream;
    Index: Integer;
    Name: String;
begin
  Result := ASDb.UpdateOnce;
  if (not Result) then
    Exit;
  Result := False;
  Handle := 0;
  Stream := TMemoryStream.Create;
  try
    Index := ASDb.RecordNum[Key];
    if (Index = -1) then begin
      Result:= False;
      Exit;
    end;
    ASDb.ReadStream(Key, Stream);
    SoundType := GetSoundTypeFromFilename(Key);
    if SoundType <> sntNotSupported then begin
      case SoundType of
        sntMOD: Handle := BASS_MusicLoad(True, Stream.Memory, 0, Stream.Size, BASS_MUSIC_RAMP, 0);
        sntMP3,
        sntOGG: Handle := BASS_StreamCreateFile(True, Stream.Memory, 0, Stream.Size, 0);
        sntWAV: Handle := BASS_SampleLoad(True, Stream.Memory, 0, Stream.Size, 3, BASS_SAMPLE_OVER_POS);
        sntNotSupported: Error('Unable to load sound ' + Key + ' - format is not supported');
      end;
      if Handle = 0 then
        Error('Unable to load sound ' + Key + ' - BASS errocode ' + IntToStr(BASS_ErrorGetCode))
      else begin
        SetLength(LoadedSounds, FCount + 1);
        LoadedSounds[FCount] := TSoundData.Create(Handle, FCount, Key, SoundType, 100);
        Name := Key;
        if (Assigned(OnLoad)) then
          OnLoad(Self, FCount, Name);
        Inc(FCount);
      end;
      Result := Handle <> 0;
    end;
  except
    on E: Exception do
      Error('Unable to load sound '+ Key +'. '+ E.Message);
  end;
end;

function TBassSoundSystem.LoadFromASDb(ASDb: TASDb): Boolean;
var
  Index  : Integer;
  Key: String;
begin
  Result:= ASDb.UpdateOnce;
  if (not Result) then
    Exit;
  Result := False;
  Unload;
  for Index:= 0 to ASDb.RecordCount - 1 do begin
    Key := ASDb.RecordKey[Index];
    if GetSoundTypefromFileName(Key) <> sntNotSupported then
      Result := AddFromASDb(Key, ASDb);
  end;
end;

procedure TBassSoundSystem.UnLoad;
var Idx: Integer;
    Sound: TSoundData;
begin
  if FCount = 0 then
    Exit;
  for Idx := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Idx];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      FreeAndNil(Sound);
      LoadedSounds[Idx] := nil;
    end;
  end;
  FCount := 0;
  SetLength(LoadedSounds, FCount);
end;

procedure TBassSoundSystem.Play(Idx: Integer; Looped: Boolean);
var Sound: TSoundData;

  procedure PlayError;
  begin
    Error('Unable to play sound ' + Sound.Name);
  end;

begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then begin
     if not Sound.Play(Looped) then
       PlayError;
  end else
    PlayError;
end;

procedure TBassSoundSystem.Play(Name: String; Looped: Boolean);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Play(Loop, Looped);
        Break;
      end;
    end;
  end;
end;

procedure TBassSoundSystem.Stop(Idx: Integer);
var
  Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Sound.Stop;
end;

procedure TBassSoundSystem.Stop(Name: String);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Stop(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TBassSoundSystem.StopAll;
var
  Idx: Integer;
begin
  if FCount = 0 then
    Exit;
  for Idx := 0 to FCount - 1 do
    Stop(Idx);
end;

function TBassSoundSystem.IsPlaying(Idx: Integer): Boolean;
var Sound: TSoundData;
begin
  Result := False;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Result := Sound.IsPlaying;
end;

function TBassSoundSystem.IsPlaying(Name: String): Boolean;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := False;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Result := IsPlaying(Loop);
        Break;
      end;
    end;
  end;
end;

function TBassSoundSystem.GetCPUUsage: String;
begin
  Result := FloatToStrF(BASS_GetCPU, ffFixed, 4, 2) + '%';
end;

function TBassSoundSystem.GetFFTData(Idx: Integer): TFFTData;
var FFTData: TFFTData;
    Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  FillChar(FFTData, SizeOf(FFTData), 0);
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    if BASS_ChannelGetData(Sound.Handle, @FFTData, BASS_DATA_FFT1024) > 0 then
      Result := FFTData;
end;

function TBassSoundSystem.GetFFTData(Name: String): TFFTData;
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Result := GetFFTData(Loop);
        Break;
      end;
    end;
  end;
end;

function TBassSoundSystem.GetSoundPos(Idx: Integer): QWord;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Result := BASS_ChannelGetPosition(Sound.Handle);
end;

function TBassSoundSystem.GetSoundPos(Name: String): QWord;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Result := GetSoundPos(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TBassSoundSystem.SetSoundPos(Idx: Integer; Pos: QWord);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    BASS_ChannelSetPosition(Sound.Handle, Pos);
end;

procedure TBassSoundSystem.SetSoundPos(Name: String; Pos: QWord);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        SetSoundPos(Loop, Pos);
        Break;
      end;
    end;
  end;
end;

function TBassSoundSystem.GetGeneralVolume: Integer;
begin
  Result := BASS_GetVolume;
end;

procedure TBassSoundSystem.SetGeneralVolume(const Value: Integer);
begin
  BASS_SetVolume(Value);
end;

procedure TBassSoundSystem.FadeIn(Idx, TimerInterval: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then begin
    Sound.StartFade(TimerInterval, ftFadeIn, OnFadeInFinalize);
    if (Assigned(OnFadeInInitialize)) then
      OnFadeInInitialize(Self, Idx, Sound.Name);
  end;
end;

procedure TBassSoundSystem.FadeIn(Name: String; TimerInterval: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        FadeIn(Loop, TimerInterval);
        Break;
      end;
    end;
  end;
end;

procedure TBassSoundSystem.FadeOut(Idx, TimerInterval: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then begin
    Sound.StartFade(TimerInterval, ftFadeOut, OnFadeOutFinalize);
    if (Assigned(OnFadeOutInitialize)) then
      OnFadeOutInitialize(Self, Idx, Sound.Name);
  end;
end;

procedure TBassSoundSystem.FadeOut(Name: String; TimerInterval: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        FadeOut(Loop, TimerInterval);
        Break;
      end;
    end;
  end;
end;

function TBassSoundSystem.GetSoundTypeFromFilename(Filename: String): TSoundType;
var sExt: String;
begin
  sExt := UpperCase(ExtractFileExt(Filename));
  if (sExt = '.MOD') or (sExt = '.XM') or (sExt = '.S3M') or (sExt = '.MTM') or (sExt = '.UMX')  or (sExt = '.MO3') or (sExt = '.IT') then
    Result := sntMOD
  else if (sExt = '.MP3') then
    Result := sntMP3
  else if(sExt = '.OGG') then
    Result := sntOGG
  else if(sExt = '.WAV') then
    Result := sntWAV
  else
    Result := sntNotSupported;
end;

procedure TBassSoundSystem.SetVolume(Idx, Volume: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Sound.SetVolume(Volume);
end;

procedure TBassSoundSystem.SetVolume(Name: String; Volume: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        SetVolume(Loop, Volume);
        Break;
      end;
    end;
  end;
end;

function TBassSoundSystem.GetVolume(Idx: Integer): Integer;
var Sound: TSoundData;
begin
  Result := 0;
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Result := Sound.GetVolume;
end;

function TBassSoundSystem.GetVolume(Name: String): Integer;
var Sound: TSoundData;
    Loop: Integer;
begin
  Result := 0;
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        Result := GetVolume(Loop);
        Break;
      end;
    end;
  end;
end;

procedure TBassSoundSystem.SetPan(Idx, Pan: Integer);
var Sound: TSoundData;
begin
  if (Idx > FCount - 1) or (FCount = 0)  then
    Exit;
  Sound := LoadedSounds[Idx];
  if (Sound <> nil) and (Sound.Handle <> 0) then
    Sound.SetPan(Pan);
end;

procedure TBassSoundSystem.SetPan(Name: String; Pan: Integer);
var Sound: TSoundData;
    Loop: Integer;
begin
  for Loop := 0 to FCount - 1 do begin
    Sound := LoadedSounds[Loop];
    if (Sound <> nil) and (Sound.Handle <> 0) then begin
      if Sound.Name = Name then begin
        SetPan(Loop, Pan);
        Break;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

constructor TSoundData.Create(Handle: Cardinal; Index: Integer; Filename: String; SoundType: TSoundType; MaxVolume: Integer);
begin
  Self.MaxVolume := 100;
  Self.Handle := Handle;
  Self.Name := Filename;
  Self.SoundType := SoundType;
  Self.Index := Index;
  SetVolume(MaxVolume);
end;

destructor TSoundData.Destroy;
begin
  if Handle <> 0 then begin
    case SoundType of
      sntMOD: BASS_StreamFree(Handle);
      sntMP3,
      sntOGG: BASS_MusicFree(Handle);
      sntWAV: BASS_SampleFree(Handle);
    end;
  end;
end;

function TSoundData.Play(Looped: Boolean): Boolean;
var Channel: HCHANNEL;
begin
  Result := False;
  BASS_ChannelRemoveSync(Handle, FSync);
  if Looped then
    FSync := BASS_ChannelSetSync(Handle, BASS_SYNC_END, 0, LoopSyncProc, 0);

  case SoundType of
    sntMOD,
    sntMP3,
    sntOGG: Result :=  BASS_ChannelPlay(Handle, False);
    sntWAV: begin
              Channel := BASS_SampleGetChannel(Handle, False);
              Result := BASS_ChannelPlay(Channel, False);
            end;
  end;
end;

function TSoundData.IsPlaying: Boolean;
begin
  Result := (BASS_ChannelIsActive(Handle) = BASS_ACTIVE_PLAYING);
end;

procedure TSoundData.Stop;
begin
  case SoundType of
    sntMOD,
    sntMP3,
    sntOGG: begin
              BASS_ChannelStop(Handle);
              BASS_ChannelSetPosition(Handle, 0);
            end;
    sntWAV: BASS_SampleStop(Handle);
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
    Inc(AktVolume, 1);
    if AktVolume >= MaxVolume then begin
      KillTimer;
      if Assigned(FadeFinalized) then
        FadeFinalized(nil, Index, Name);
    end else
      SetVolume(AktVolume);
  end else begin
    Dec(AktVolume, 1);
    if AktVolume <= 0 then begin
      KillTimer;
      Stop;
      if Assigned(FadeFinalized) then
        FadeFinalized(nil, Index, Name);
    end else
      SetVolume(AktVolume);
  end;
end;

procedure TSoundData.StartFade(Interval: Integer; FadeType: TFadeType; FadeEndEvent: TFadeFinalizeEvent);
begin
  KillTimer;
  case FadeType of
    ftFadeIn: begin
                FadeIn := True;
                SetVolume(0);
              end;
    ftFadeOut: FadeIn := False;
  end;
  FadeFinalized := FadeEndEvent;
  Timer := TTimer.Create(nil);
  Timer.Interval := Interval;
  Timer.OnTimer := OnTimer;
  Timer.Enabled := True;
end;

function TSoundData.GetVolume: Integer;
var
  Freq, Volume: Cardinal;
  Pan: Integer;
begin
  if Handle <> 0 then
    Bass_ChannelGetAttributes(Handle, Freq, Volume, Pan);
  Result := Volume;
end;

procedure TSoundData.SetVolume(const Value: Integer);
begin
  if Handle <> 0 then
    Bass_ChannelSetAttributes(Handle, 0, Max(0, Min(Value, 100)), 0);
end;

procedure TSoundData.SetPan(const Value: Integer);
begin
  if Handle <> 0 then
    Bass_ChannelSetAttributes(Handle, 0, GetVolume, Max(-100, Min(Value, 100)));
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

procedure LoopSyncProc(Handle: HSYNC; Channel, Data, User: DWORD); stdcall;
begin
  BASS_ChannelSetPosition(Channel, 0);
end;

// ------------------------------------------------------------------------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('Asphyre', [TBassSoundSystem]);
end;

end.

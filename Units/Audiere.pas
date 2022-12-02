unit Audiere;

{$A+}
{$Z4}

interface

const
  AudiereDllName = 'audiere.dll';

type

  { TAudiereSeekMode  }
  TAudiereSeekMode = (
    Audiere_Seek_Begin,
    Audiere_Seek_Current,
    Audiere_Seek_End
  );

  { TAudiereSoundEffectType }
  TAudiereSoundEffectType = (
    Audiere_SoundEffectType_Single,
    Audiere_SoundEffectType_Multiple
  );

  { TAudiereSampleFormat }
  TAudiereSampleFormat = (
    Audiere_SampleFormat_U8,
    Audiere_SampleFormat_S16
  );

  { TAudiereFileFormat }
  TAudiereFileFormat = (
    FF_AUTODETECT,
    FF_WAV,
    FF_OGG,
    FF_FLAC,
    FF_MP3,
    FF_MOD
  );

  { TAudiereRefCounted  }
  TAudiereRefCounted = class
  public
    procedure Ref;   virtual; stdcall; abstract;
    procedure UnRef; virtual; stdcall; abstract;
  end;

  { TAudiereFile }
  TAudiereFile = class(TAudiereRefCounted)
  public
    function Read(aBuffer: Pointer; aSize: Integer): Integer; virtual; stdcall; abstract;
    function Seek(aPosition: Integer; aSeekMode: TAudiereSeekMode): Boolean; virtual; stdcall; abstract;
    function Tell: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereSampleSource }
  TAudiereSampleSource = class(TAudiereRefCounted)
  public
    procedure GetFormat(var aChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAudiereSampleFormat); virtual; stdcall; abstract;
    function  Read(aFrameCount: Integer; aBuffer: Pointer): Integer;  virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(Position: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereOutputStream }
  TAudiereOutputStream = class(TAudiereRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    function  IsPlaying: Boolean; virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    procedure SetRepeat(aRepeat: Boolean); virtual; stdcall; abstract;
    function  GetRepeat: Boolean; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(aPosition: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereAudioDevice }
  TAudiereAudioDevice = class(TAudiereRefCounted)
  public
    procedure Update; virtual; stdcall; abstract;
    function  OpenStream(aSource: TAudiereSampleSource): TAudiereOutputStream; virtual; stdcall; abstract;
    function  OpenBuffer(aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampelFormat: TAudiereSampleFormat):  TAudiereOutputStream; virtual; stdcall; abstract;
  end;

  { TAudiereSampleBuffer }
  TAudiereSampleBuffer = class(TAudiereRefCounted)
  public
    procedure GetFormat(var ChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAudiereSampleFormat); virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    function  GetSamples: Pointer; virtual; stdcall; abstract;
    function  OpenStream: TAudiereSampleSource; virtual; stdcall; abstract;
  end;

  { TAudiereSoundEffect }
  TAudiereSoundEffect = class(TAudiereRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
  end;

{ --- Audiere Routines -------------------------------------------------- }
var
  AudiereGetVersion                  : function: PChar; stdcall = nil;
  AudiereGetSupportedFileFormats     : function: PChar; stdcall = nil;
  AudiereGetSupportedAudioDevices    : function : PChar; stdcall = nil;
  AudiereGetSampleSize               : function(aFormat: TAudiereSampleFormat): Integer; stdcall = nil;
  AudiereOpenDevice                  : function(const aName: PChar; const aParams: PChar): TAudiereAudioDevice; stdcall = nil;
  AudiereOpenSampleSource            : function(const aFilename: PChar; aFileFormat: TAudiereFileFormat): TAudiereSampleSource; stdcall = nil;
  AudiereOpenSampleSourceFromFile    : function(aFile: TAudiereFile; aFileFormat: TAudiereFileFormat): TAudiereSampleSource; stdcall = nil;
  AudiereCreateTone                  : function(aFrequency: Double): TAudiereSampleSource; stdcall = nil;
  AudiereCreateSquareWave            : function(aFrequency: Double): TAudiereSampleSource; stdcall = nil;
  AudiereCreateWhiteNoise            : function: TAudiereSampleSource; stdcall = nil;
  AudiereCreatePinkNoise             : function: TAudiereSampleSource; stdcall = nil;
  AudiereOpenSound                   : function(aDevice: TAudiereAudioDevice; aSource: TAudiereSampleSource; aStreaming: LongBool): TAudiereOutputStream; stdcall = nil;
  AudiereCreateSampleBuffer          : function(aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampleFormat: TAudiereSampleFormat): TAudiereSampleBuffer; stdcall = nil;
  AudiereCreateSampleBufferFromSource: function(aSource: TAudiereSampleSource): TAudiereSampleBuffer; stdcall = nil;
  AudiereOpenSoundEffect             : function(aDevice: TAudiereAudioDevice; aSource: TAudiereSampleSource; aType: TAudiereSoundEffectType): TAudiereSoundEffect; stdcall = nil;
  AudiereCreateMemoryFile            : function(aBuffer: Pointer; BufferSize: Integer): TAudiereFile; stdcall = nil;
function AudiereLoadDLL: Boolean; stdcall;
procedure AudiereUnloadDLL; stdcall;

implementation

uses
  Windows;

var
  AudiereDLL: HMODULE = 0;

function AudiereLoadDLL: Boolean;
begin
  Result := False;

  AudiereDLL := LoadLibrary(AudiereDllName);
  if(AudiereDLL = 0) then
  begin
    Exit;
  end;

  @AudiereGetVersion                   := GetProcAddress(AudiereDLL, '_AdrGetVersion@0');
  @AudiereGetSupportedFileFormats      := GetProcAddress(AudiereDLL, '_AdrGetSupportedFileFormats@0');
  @AudiereGetSupportedAudioDevices     := GetProcAddress(AudiereDLL, '_AdrGetSupportedAudioDevices@0');
  @AudiereGetSampleSize                := GetProcAddress(AudiereDLL, '_AdrGetSampleSize@4');
  @AudiereOpenDevice                   := GetProcAddress(AudiereDLL, '_AdrOpenDevice@8');
  @AudiereOpenSampleSource             := GetProcAddress(AudiereDLL, '_AdrOpenSampleSource@8');
  @AudiereOpenSampleSourceFromFile     := GetProcAddress(AudiereDLL, '_AdrOpenSampleSourceFromFile@8');
  @AudiereCreateTone                   := GetProcAddress(AudiereDLL, '_AdrCreateTone@8');
  @AudiereCreateSquareWave             := GetProcAddress(AudiereDLL, '_AdrCreateSquareWave@8');
  @AudiereCreateWhiteNoise             := GetProcAddress(AudiereDLL, '_AdrCreateWhiteNoise@0');
  @AudiereCreatePinkNoise              := GetProcAddress(AudiereDLL, '_AdrCreatePinkNoise@0');
  @AudiereOpenSound                    := GetProcAddress(AudiereDLL, '_AdrOpenSound@12');
  @AudiereCreateSampleBuffer           := GetProcAddress(AudiereDLL, '_AdrCreateSampleBuffer@20');
  @AudiereCreateSampleBufferFromSource := GetProcAddress(AudiereDLL, '_AdrCreateSampleBufferFromSource@4');
  @AudiereOpenSoundEffect              := GetProcAddress(AudiereDLL, '_AdrOpenSoundEffect@12');
  @AudiereCreateMemoryFile             := GetProcAddress(AudiereDLL, '_AdrCreateMemoryFile@8');

  if not Assigned(AudiereGetVersion) then Exit;
  if not Assigned(AudiereGetSupportedFileFormats) then Exit;
  if not Assigned(AudiereGetSupportedAudioDevices) then Exit;
  if not Assigned(AudiereGetSampleSize) then Exit;
  if not Assigned(AudiereOpenDevice) then Exit;
  if not Assigned(AudiereOpenSampleSource) then Exit;
  if not Assigned(AudiereOpenSampleSourceFromFile) then Exit;
  if not Assigned(AudiereCreateTone) then Exit;
  if not Assigned(AudiereCreateSquareWave) then Exit;
  if not Assigned(AudiereCreateWhiteNoise) then Exit;
  if not Assigned(AudiereCreatePinkNoise) then Exit;
  if not Assigned(AudiereOpenSound) then Exit;
  if not Assigned(AudiereCreateSampleBuffer) then Exit;
  if not Assigned(AudiereCreateSampleBufferFromSource) then Exit;
  if not Assigned(AudiereOpenSoundEffect) then Exit;

  Result := True;
end;

procedure AudiereUnloadDLL;
begin
  if AudiereDLL <> 0 then
  begin
    FreeLibrary(AudiereDLL);
    AudiereDLL := 0;
  end;
end;

end.

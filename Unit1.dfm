object MainForm: TMainForm
  Left = 207
  Top = 156
  Caption = 'PLASMIA'
  ClientHeight = 398
  ClientWidth = 500
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Fonts: TAsphyreFonts
    Publisher = Device
    Canvas = MyCanvas
    Left = 96
    Top = 40
  end
  object Images: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 128
    Top = 40
  end
  object Device: TAsphyreDevice
    Width = 1280
    Height = 1024
    BitDepth = bdHigh
    Refresh = 0
    Windowed = True
    VSync = False
    HardwareTL = False
    DepthBuffer = False
    WindowHandle = 0
    OnInitialize = DeviceInitialize
    OnRender = DeviceRender
    Left = 160
    Top = 40
  end
  object MyCanvas: TAsphyreCanvas
    Publisher = Device
    AlphaTesting = True
    VertexCache = 4096
    Antialias = True
    Dithering = True
    Left = 192
    Top = 40
  end
  object AGraphics: TASDb
    FileName = 'Data\Graphics\Main.asdb'
    OpenMode = opUpdate
    Left = 224
    Top = 40
  end
  object Timer: TAsphyreTimer
    Speed = 85.000000000000000000
    MaxFPS = 500
    Enabled = False
    OnTimer = TimerTimer
    Left = 64
    Top = 40
  end
  object Keyboard1: TAsphyreKeyboard
    Foreground = True
    Left = 256
    Top = 40
  end
  object Mouse: TAsphyreMouse
    Foreground = True
    BufferSize = 256
    Exclusive = True
    ClearOnUpdate = False
    Left = 320
    Top = 40
  end
  object EffImgs: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 384
    Top = 40
  end
  object ImageList1: TImageList
    BlendColor = clBlack
    BkColor = clBlack
    AllocBy = 40
    Height = 64
    Width = 64
    Left = 352
    Top = 40
  end
  object DXWave: TDXWaveList
    DXSound = DXSound
    Items = <>
    Left = 256
    Top = 72
  end
  object DXSound: TDXSound
    AutoInitialize = True
    Options = []
    Left = 288
    Top = 40
  end
  object Images2: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 96
    Top = 72
  end
  object mmImages: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 128
    Top = 72
  end
  object HudImages: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 160
    Top = 72
  end
  object MenuImages: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 192
    Top = 72
  end
  object ItemImages: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 224
    Top = 72
  end
  object SoundSystem: TSoundSystem
    MaxVolume = 100
    Left = 352
    Top = 72
  end
  object MenuSoundSystem: TSoundSystem
    MaxVolume = 100
    OnFadeOutFinalize = MenuSoundSystemFadeOutFinalize
    Left = 384
    Top = 72
  end
  object MapPreviews: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 288
    Top = 72
  end
  object AsphyreTextures1: TAsphyreTextures
    Publisher = Device
    Left = 320
    Top = 72
  end
end

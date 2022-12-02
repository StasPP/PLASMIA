object MainForm: TMainForm
  Left = 207
  Top = 156
  Caption = 'EDITOR for PLASMA'
  ClientHeight = 416
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheel = FormMouseWheel
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
    MaxFPS = 2000
    Enabled = False
    OnTimer = TimerTimer
    OnProcess = TimerProcess
    Left = 64
    Top = 40
  end
  object Keyboard: TAsphyreKeyboard
    Foreground = True
    Left = 256
    Top = 40
  end
  object SoundSystem1: TSoundSystem
    MaxVolume = 0
    Left = 288
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
  object AFonts: TASDb
    FileName = 'Data\Graphics\Fonts.asdb'
    OpenMode = opUpdate
    Left = 64
    Top = 72
  end
  object ALoader: TASDb
    OpenMode = opUpdate
    Left = 96
    Top = 72
  end
end

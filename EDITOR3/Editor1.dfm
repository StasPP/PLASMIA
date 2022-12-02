object MainForm: TMainForm
  Left = 2
  Top = 2
  BorderStyle = bsToolWindow
  Caption = 'EDITOR for PLASMA'
  ClientHeight = 516
  ClientWidth = 697
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
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
    Dithering = False
    Left = 192
    Top = 40
  end
  object AGraphics: TASDb
    FileName = '..\Data\Graphics\Main.asdb'
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
  object AFonts: TASDb
    FileName = 'Editor.asdb'
    OpenMode = opUpdate
    Left = 224
    Top = 72
  end
  object GuiBase: TGuiBase
    Publisher = Device
    Canvas = MyCanvas
    Images = Images
    Fonts = Fonts
    Left = 288
    Top = 40
  end
  object OpenDialog: TOpenDialog
    OnClose = OpenDialogClose
    OnShow = OpenDialogShow
    Filter = 'Maps for PLASMA|*.map'
    FilterIndex = 0
    OnCanClose = OpenDialogCanClose
    Left = 160
    Top = 72
  end
  object SaveDialog: TSaveDialog
    OnClose = SaveDialogClose
    OnShow = SaveDialogShow
    Filter = 'Maps for Plasma|*.map'
    OnCanClose = SaveDialogCanClose
    Left = 192
    Top = 72
  end
  object HD: TASDb
    FileName = '..\Data\Graphics\HD.asdb'
    OpenMode = opUpdate
    Left = 256
    Top = 72
  end
  object ASDb1: TASDb
    FileName = '..\Data\Graphics\Enm_HD.asdb'
    OpenMode = opUpdate
    Left = 256
    Top = 40
  end
  object FX: TASDb
    FileName = '..\Data\Graphics\FX.asdb'
    OpenMode = opUpdate
    Left = 288
    Top = 72
  end
  object Images2: TAsphyreImages
    Publisher = Device
    MipMappping = True
    Left = 128
    Top = 72
  end
end

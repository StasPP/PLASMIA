{ ------------------------------------------------------------------------ }
{                                                                          }
{ Project:  SpriteControls                                                 }
{ Version:  0.0.4                                                          }
{ Modified: 01-05-2006 (DD-MM-YY)                                          }
{                                                                          }
{ Author:   Cervajz - Jaromir Cervenka (North Team)                        }
{ E-Mail:   jara.cervenka@seznam.cz                                        }
{                                                                          }
{ Description:                                                             }
{   Some controls for Asphyre eXtreme. Based on DraculaLin's SpriteEngine. }
{                                                                          }
{ Requirement:                                                             }
{   Minimal version of Asphyre is 3.1.0. SpriteEngine for Asphyre 3.1.0.   }
{                                                                          }
{ Notice:                                                                  }
{   Please forgive me my terrible English.														     }
{   If have you any reminder (or idea) to code, send on my email address   }
{   or send message on afterwarp forum (nickname: Cervajz).                }
{                                                                          }
{ Acknowledgments:                                                         }
{   Eng. Yuriy Kotsarenko - for Asphyre suite                              }
{   DraculaLin - for his SpriteEngine                                      }
{                                                                          }
{ Changes:                                                                 }
{   0.0.1:                                                                 }
{     * First release                                                      }
{                                                                          }
{   0.0.2:                                                                 }
{     + OnMouseMove property                                               }
{                                                                          }
{   0.0.3:                                                                 }
{     + TSpriteLabel                                                       }
{     + TwoColors property                                                 }
{     * Changed "text colors"                                              }
{                                                                          }
{   0.0.4:                                                                 }
{     * Updated on new version of SpriteEngine                             }
{     + TSpriteScrollBar                                                   }
{     + scMsButton constant                                                }
{                                                                          }
{ ------------------------------------------------------------------------ }

unit SpriteControls;

interface

uses AsphyreSprite, AsphyreMouse, AsphyreFonts, AsphyreDef, Classes, Math,
      Controls, Windows;

// 
const
  scMsButton = 0;

type
  TChxPos = (cxLeft, cxRight);
  TBtxPos = (bxCenter, bxLeft, bxRight);
 
  { --- Base class --- }
  TSpriteControl = class(TSprite)
  private
    FTag: Integer;
    FMouse: TAsphyreMouse;
    FDrawCRect: Boolean;
    FCollColor: Cardinal;
    FEnabled: Boolean;
    procedure SetDrawCRect(const Value: Boolean); virtual;
  public
    constructor Create(const AParent: TSpriteEngine); override;
    procedure Draw(); override;

    property AMouse: TAsphyreMouse read FMouse write FMouse;

    property Enabled: Boolean read FEnabled write FEnabled;

    property DrawCollRect: Boolean read FDrawCRect write SetDrawCRect;
    property CollRectColor: Cardinal read FCollColor write FCollColor;
    property Tag: Integer read FTag write FTag;
  end;
  { --- --- }

  { --- TSpriteCheckBox --- }
  TSpriteCheckBox = class(TSpriteControl)
  private
    FChecked: Boolean;

    FNormalImg: Integer;
    FNormalOver: Integer;
    FCheckImg: Integer;
    FCheckOver: Integer;
    FDisImg: Integer;

    FLeft: Single;
    FTxt: String;
    FTxtFont: TAsphyreFont;

    FTwoColors: Boolean;
    FTxtColor1: Cardinal;
    FTxtColor2: Cardinal;
    FTxtColorOver1: Cardinal;
    FTxtColorOver2: Cardinal;
    FTxtColorDisabled1: Cardinal;
    FTxtColorDisabled2: Cardinal;

    FTxtPos: TChxPos;
    FTxtSpc: Single;
    FTxtSpcH: Single;

    FOnChange: TNotifyEvent;
    FMouseMove: TNotifyEvent;

    procedure SetChecked(const Value: Boolean);
  public
    constructor Create(const AParent: TSpriteEngine); override;

    procedure Draw(); override;
    procedure Move(const MoveCount: Single); override;
    procedure OnCollision(const Sprite: TSprite); override;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMouseMove: TNotifyEvent read FMouseMove write FMouseMove;

    property Checked: Boolean read FChecked write SetChecked;
    property Left: Single read FLeft write FLeft;

    property NormalImage: Integer read FNormalImg write FNormalImg;
    property NormalOver: Integer read FNormalOver write FNormalOver;
    property CheckedImage: Integer read FCheckImg write FCheckImg;
    property CheckedOver: Integer read FCheckOver write FCheckOver;
    property DisabledImage: Integer read FDisImg write FDisImg;

    property Text: String read FTxt write FTxt;
    property TxtPos: TChxPos read FTxtPos write FTxtPos;
    property TxtSpace: Single read FTxtSpc write FTxtSpc;
    property TxtSpaceH: Single read FTxtSpcH write FTxtSpcH;
    property TxtFont: TAsphyreFont read FTxtFont write FTxtFont;

    property TwoColors: Boolean read FTwoColors write FTwoColors;
    property TxtColor1: Cardinal read FTxtColor1 write FTxtColor1;
    property TxtColor2: Cardinal read FTxtColor2 write FTxtColor2;
    property TxtColorOver1: Cardinal read FTxtColorOver1 write FTxtColorOver1;
    property TxtColorOver2: Cardinal read FTxtColorOver2 write FTxtColorOver2;
    property TxtColorDisabled1: Cardinal read FTxtColorDisabled1 write FTxtColorDisabled1;
    property TxtColorDisabled2: Cardinal read FTxtColorDisabled2 write FTxtColorDisabled2;
  end;
  { --- --- }

  { --- TSpriteButton --- }
  TSpriteButton = class(TSpriteControl)
  private
    FNormalImg: Integer;
    FNormalOver: Integer;
    FClickImg: Integer;
    FDisabledImg: Integer;

    FTxt: String;
    FTxtFont: TAsphyreFont;

    FTwoColors: Boolean;
    FTxtColor1: Cardinal;
    FTxtColor2: Cardinal;
    FTxtColorOver1: Cardinal;
    FTxtColorOver2: Cardinal;
    FTxtColorDisabled1: Cardinal;
    FTxtColorDisabled2: Cardinal;

    FTxtPos: TBtxPos;
    FTxtSpc, FTxtSpcH: Single;

    FClc: Boolean;
    FMoving: Boolean;

    FClick: TNotifyEvent;
    FMouseMove: TNotifyEvent;
  public
    constructor Create(const AParent: TSpriteEngine); override;

    procedure Draw(); override;
    procedure Move(const MoveCount: Single); override;
    procedure OnCollision(const Sprite: TSprite); override;

    property OnClick: TNotifyEvent read FClick write FClick;
    property OnMouseMove: TNotifyEvent read FMouseMove write FMouseMove;

    property NormalImage: Integer read FNormalImg write FNormalImg;
    property NormalOver: Integer read FNormalOver write FNormalOver;
    property ClickedImage: Integer read FClickImg write FClickImg;
    property DisabledImage: Integer read FDisabledImg write FDisabledImg;

    property Text: String read FTxt write FTxt;
    property TxtPos: TBtxPos read FTxtPos write FTxtPos;
    property TxtSpace: Single read FTxtSpc write FTxtSpc;
    property TxtSpaceH: Single read FTxtSpcH write FTxtSpcH;
    property TxtFont: TAsphyreFont read FTxtFont write FTxtFont;

    property TwoColors: Boolean read FTwoColors write FTwoColors;
    property TxtColor1: Cardinal read FTxtColor1 write FTxtColor1;
    property TxtColor2: Cardinal read FTxtColor2 write FTxtColor2;
    property TxtColorOver1: Cardinal read FTxtColorOver1 write FTxtColorOver1;
    property TxtColorOver2: Cardinal read FTxtColorOver2 write FTxtColorOver2;
    property TxtColorDisabled1: Cardinal read FTxtColorDisabled1 write FTxtColorDisabled1;
    property TxtColorDisabled2: Cardinal read FTxtColorDisabled2 write FTxtColorDisabled2;
  end;
  { --- --- }

  { --- TSpriteLabel --- }
  TSpriteLabel = class(TSpriteControl)
  private
    FTxt: String;
    FTxtFont: TAsphyreFont;

    FTwoColors: Boolean;
    FTxtColor1: Cardinal;
    FTxtColor2: Cardinal;
    FTxtColorOver1: Cardinal;
    FTxtColorOver2: Cardinal;
    FTxtColorDisabled1: Cardinal;
    FTxtColorDisabled2: Cardinal;

    FOnClick: TNotifyEvent;
    FOnMouseMove: TNotifyEvent;
  public
    constructor Create(const AParent: TSpriteEngine); override;
    procedure Draw(); override;
    procedure Move(const MoveCount: Single); override;
    procedure OnCollision(const Sprite: TSprite); override;

    property Text: String read FTxt write FTxt;
    property TxtFont: TAsphyreFont read FTxtFont write FTxtFont;

    property TwoColors: Boolean read FTwoColors write FTwoColors;
    property TxtColor1: Cardinal read FTxtColor1 write FTxtColor1;
    property TxtColor2: Cardinal read FTxtColor2 write FTxtColor2;
    property TxtColorOver1: Cardinal read FTxtColorOver1 write FTxtColorOver1;
    property TxtColorOver2: Cardinal read FTxtColorOver2 write FTxtColorOver2;
    property TxtColorDisabled1: Cardinal read FTxtColorDisabled1 write FTxtColorDisabled1;
    property TxtColorDisabled2: Cardinal read FTxtColorDisabled2 write FTxtColorDisabled2;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseMove: TNotifyEvent read FOnMouseMove write FOnMouseMove;
  end;
  { --- --- }

  { --- TSpriteScrollBar --- }
  TSpriteScrollBar = class(TSpriteControl)
  private
    FHandle: THandle;
    FClc: Boolean;
    FLeft: Real;
    FWidth: Real;
    FEnabledAction: Boolean;

    FMsPos: TPoint;
    FMsOld: TPoint;
    FOldX: Real;

    FsPos: Integer;
    FOldPos: Integer;
    FChange: Integer;

    FaLeft: TSpriteControl;
    FaRight: TSpriteControl;

    FaLeftImg: String;
    FaRightImg: String;

    FBackImg: String;
    FBackImgMin: Real;
    FSclX: Real;

    FNormalImg: Integer;
    FNormalOver: Integer;
    FClickImg: Integer;
    FDisabledImg: Integer;

    FOnMouseMove: TNotifyEvent;
    FOnChange: TNotifyEvent;

    procedure SetWidth(const Value: Real);
    procedure SetPos(const Value: Integer);
    procedure SetBackImg(const Value: String);
    procedure SetLeftImg(const Value: String);
    procedure SetRightImg(const Value: String);
    procedure SetDrawCRect(const Value: Boolean); override;
  public
    constructor Create(const AParent: TSpriteEngine); override;
    destructor Destroy(); override;

    procedure Draw(); override;
    procedure Move(const MoveCount: Single); override;

    procedure Collision(const Other: TSprite); override;
    procedure OnCollision(const Sprite: TSprite); override;

    property LeftArrowImg: String read FaLeftImg write SetLeftImg;
    property RightArrowImg: String read FaRightImg write SetRightImg;
    property BackImg: String read FBackImg write SetBackImg;

    property FrmHandle: THandle read FHandle write FHandle;
    property Left: Real read FLeft write FLeft;
    property Width: Real read FWidth write SetWidth;
    property Position: Integer read FsPos write SetPos;
    property EnabledAction: Boolean read FEnabledAction write FEnabledAction;

    property Change: Integer read FChange write FChange;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnMouseMove: TNotifyEvent read FOnMouseMove write FOnMouseMove;
  end;
  { ---  --- }

implementation

{ ---------------------------- TSriteControl ---------------------------------- }
constructor TSpriteControl.Create(const AParent: TSpriteEngine);
begin
  inherited;

  FEnabled := True;
  FDrawCRect := False;
  FCollColor := $FF0000FF;
  FTag := 0;

  // Sprite settings
  DrawFx := fxBlend;
  CollideMethod := cmRect;
  DoCollision := True;
end;

procedure TSpriteControl.Draw();
begin
  inherited;

  // Drawing collision rect
  if (FDrawCRect) and (Visible) then
    Engine.Canvas.FrameRect(CollideRect, FCollColor, 1);
end;

procedure TSpriteControl.SetDrawCRect(const Value: Boolean);
begin
  FDrawCRect := Value;
end;
{ ----------------------------------- ----------------------------------------- }

{ --------------------------- TSpriteCheckBox --------------------------------- }
constructor TSpriteCheckBox.Create(const AParent: TSpriteEngine);
begin
  inherited;

  FTxt := '';
  FTxtPos := cxRight;
  FTxtSpc := 5.0;
  FTxtSpcH := 0.0;

  FTwoColors := False;
  FTxtColor1 := $FF0000FF;
  FTxtColor2 := FTxtColor1;
  FTxtColorOver1 := $FFFF0000;
  FTxtColorOver2 := FTxtColorOver1;
  FTxtColorDisabled1 := $FFA0A0A0;
  FTxtColorDisabled2 := $FFE0E0E0;

  FOnChange := nil;
  FMouseMove := nil;
  FDisImg := -1;
  FNormalImg := 0;
  FNormalOver := 1;
  FCheckImg := 2;
  FCheckOver := 3;
end;

procedure TSpriteCheckBox.SetChecked(const Value: Boolean);
var
  Changed: Boolean;
begin
  Changed := (FChecked <> Value);
  FChecked := Value;
  if (Changed) and (Assigned(FOnChange)) then
    FOnChange(Self);
end;

procedure TSpriteCheckBox.Draw();
var
  cClr1, cClr2: Cardinal;
  lLeft, tTop: Single;
begin
  inherited;

  if (not Visible) then
    Exit;

  // Default color
  cClr1 := FTxtColor1;
  cClr2 := FTxtColor2;

  { --- Images and text color --- }
  if (not Collisioned) then
    PatternIndex := FNormalImg
  else if (Collisioned) and (Assigned(FMouseMove)) then
    FMouseMove(Self);

  if (FChecked) then
    PatternIndex := FCheckImg;

  if (Collisioned) and (not FChecked) then begin
    PatternIndex := FNormalOver;
    cClr1 := FTxtColorOver1;
    cClr2 := FTxtColorOver2;
  end;

  if (Collisioned) and (FChecked) then begin
    PatternIndex := FCheckOver;
    cClr1 := FTxtColorOver1;
    cClr2 := FTxtColorOver2;
  end;

  if (not Enabled) then begin
    PatternIndex := FDisImg;
    cClr1 := FTxtColorDisabled1;
    cClr2 := FTxtColorDisabled2;
  end;
  { --- --- }

  { --- Text --- }
  if (FTxt <> '') then begin
    // cxRight
    lLeft := X + PatternWidth + FTxtSpc;

    if (FTxtPos = cxLeft) then begin
      lLeft := FLeft;
      X := FLeft + FTxtFont.TextWidth(FTxt) + FTxtSpc;
    end;

    tTop := Y + FTxtSpcH + PatternHeight / 2 - FTxtFont.TextHeight(FTxt) / 2;

    if (FTwoColors) then
      FTxtFont.TextOut(FTxt, lLeft, tTop, cClr1, cClr2, fxBlend)
    else
      FTxtFont.TextOut(FTxt, lLeft, tTop, cClr1);
  end;
  { --- --- }
end;

procedure TSpriteCheckBox.Move(const MoveCount: Single);
begin
  inherited;

  if (not Visible) then
    Exit;

  if (FTxt <> '') then begin

    case (FTxtPos) of
      cxRight:
        CollideRect := Rect(Ceil(X), Ceil(Y),
          Ceil(X + PatternWidth + FTxtFont.TextWidth(FTxt) + FTxtSpc),
          Ceil(Y + PatternHeight));

      cxLeft:
        CollideRect := Rect(Ceil(X - FTxtFont.TextWidth(FTxt) - FTxtSpc),
          Ceil(Y), Ceil(X + PatternWidth), Ceil(Y + PatternHeight));
    end;


  end else
    CollideRect := Rect(Ceil(X), Ceil(Y),
      Ceil(X + PatternWidth), Ceil(Y + PatternHeight));
end;

procedure TSpriteCheckBox.OnCollision(const Sprite: TSprite);
begin
  inherited;

  if (FEnabled) and (Visible) and (FMouse.Pressed[scMsButton]) then
    SetChecked(not FChecked);
end;
{ ----------------------------------- ----------------------------------------- }

{ ----------------------------- TSpriteButton --------------------------------- }
constructor TSpriteButton.Create(const AParent: TSpriteEngine);
begin
  inherited;

  FClick := nil;
  FMouseMove := nil;
  FClc := False;
  FDisabledImg := -1;
  FNormalImg := 0;
  FNormalOver := 1;
  FClickImg := 2;
  FDisabledImg := 3;
  FTxt := '';

  FTwoColors := False;
  FTxtColor1 := $FF0000FF;
  FTxtColor2 := FTxtColor1;
  FTxtColorOver1 := $FFFF0000;
  FTxtColorOver2 := FTxtColorOver1;
  FTxtColorDisabled1 := $FFA0A0A0;
  FTxtColorDisabled2 := $FFE0E0E0;

  FTxtPos := bxCenter;
  FTxtSpc := 10.0;
  FTxtSpcH := 0.0;
  FMoving := False;
end;

procedure TSpriteButton.Draw();
var
  cClr1, cClr2: Cardinal;
  lLeft, tTop: Single;
begin
  inherited;

  if (not Visible) then
    Exit;

  // Check if is clicked
  if (FMouse.Pressed[scMsButton]) then
    FClc := True;
  if (FMouse.Released[scMsButton]) then
    FClc := False;

  // Default color
  cClr1 := FTxtColor1;
  cClr2 := FTxtColor2;

  { --- Image and color ---}
  if (not Collisioned) then begin
    PatternIndex := FNormalImg;
  end else if (Collisioned) and (Assigned(FMouseMove)) then
    FMouseMove(Self);

  if (Collisioned) and (not FClc) then begin
    PatternIndex := FNormalOver;
    cClr1 := FTxtColorOver1;
    cClr2:= FTxtColorOver2;
  end;

  if (Collisioned) and (FClc) then begin
    PatternIndex := FClickImg;
    cClr1 := FTxtColorOver1;
    cClr2 := FTxtColorOver2;
  end;

  if (not Enabled) then begin
    PatternIndex := FDisabledImg;
    cClr1 := FTxtColorDisabled1;
    cClr2 := FTxtColorDisabled2;
  end;
  { --- --- }

  { --- Text (or caption :) --- }
  if (FTxt <> '') then begin
    // bxLeft
    lLeft := X + FTxtSpc;

    case (FTxtPos) of
      bxCenter:
        lLeft := X + PatternWidth / 2 - FTxtFont.TextWidth(FTxt) / 2;
      bxRight:
        lLeft := X + PatternWidth - FTxtFont.TextWidth(FTxt) - FTxtSpc;
    end;

    tTop := Y + FTxtSpcH + (PatternHeight / 2 - FTxtFont.TextHeight(FTxt) / 2);

    // Render text
    if (FTwoColors) then
      FTxtFont.TextOut(FTxt, lLeft, tTop, cClr1, cClr2, fxBlend)
    else
      FTxtFont.TextOut(FTxt, lLeft, tTop, cClr1);
  end;
  { --- --- }

  FMoving := False;
end;

procedure TSpriteButton.Move(const MoveCount: Single);
begin
  inherited;

  if (not Visible) then
    Exit;

  CollideRect := Rect(Ceil(X), Ceil(Y),
    Ceil(X + PatternWidth), Ceil(Y + PatternHeight));

  FMoving := True;
end;

procedure TSpriteButton.OnCollision(const Sprite: TSprite);
begin
  if (FEnabled) and (Visible) and (FMouse.Released[scMsButton]) and (Assigned(FClick)) then
    FClick(Self);
end;
{ ----------------------------------- ----------------------------------------- }

{ ----------------------------- TSpriteLabel ---------------------------------- }
constructor TSpriteLabel.Create(const AParent: TSpriteEngine);
begin
  inherited;

  FTxt := 'TSpriteLabel';

  FTwoColors := False;
  FTxtColor1 := $FF0000FF;
  FTxtColor2 := FTxtColor1;
  FTxtColorOver1 := $FFFF0000;
  FTxtColorOver2 := FTxtColorOver1;
  FTxtColorDisabled1 := $FFA0A0A0;
  FTxtColorDisabled2 := $FFE0E0E0;

  FOnClick := nil;
  FOnMouseMove := nil;
end;

procedure TSpriteLabel.Draw();
var
  cClr1, cClr2: Cardinal;
begin
  if (not Visible) then
    Exit;

  // Color
  cClr1 := FTxtColor1;
  cClr2 := FTxtColor2;

  if (not Collisioned) then begin
    cClr1 := FTxtColor1;
    cClr2 := FTxtColor2;
  end;

  if (Collisioned) then begin
    cClr1 := FTxtColorOver1;
    cClr2 := FTxtColorOver2;

    if (Assigned(FOnMouseMove)) then
      FOnMouseMove(Self);
  end;
  
  if (not FEnabled) then begin
    cClr1 := FTxtColorDisabled1;
    cClr2 := FTxtColorDisabled2;
  end;

  // Render text
  if (FTwoColors) then
    FTxtFont.TextOut(FTxt, X, Y, cClr1, cClr2, fxBlend)
  else
    FTxtFont.TextOut(FTxt, X, Y, cClr1);

  // Drawing collision rect
  if (FDrawCRect) and (Visible) then
    Engine.Canvas.FrameRect(CollideRect, FCollColor, 1);
end;

procedure TSpriteLabel.Move(const MoveCount: Single);
begin
  inherited;

  if (not Visible) then
    Exit;

  CollideRect := Rect(Ceil(X), Ceil(Y), Ceil(X + FTxtFont.TextWidth(FTxt)),
    Ceil(Y + FTxtFont.TextHeight(FTxt)));
end;

procedure TSpriteLabel.OnCollision(const Sprite: TSprite);
begin
  inherited;

  if (FEnabled) and (Visible) and (FMouse.Pressed[scMsButton]) and (Assigned(FOnClick)) then
    FOnClick(Self);
end;
{ ----------------------------------- ----------------------------------------- }

{ ---------------------------- TSriteScrollBar -------------------------------- }
constructor TSpriteScrollBar.Create(const AParent: TSpriteEngine);
begin
  inherited;

  FsPos := 0;
  FChange := 5;
  FaLeftImg := '';
  FaRightImg := '';
  FBackImg := '';
  FBackImgMin := 5.0;
  FSclX := 1.0;
  FClc := False;
  FEnabledAction := True;

  FNormalImg := 0;
  FNormalOver := 1;
  FClickImg := 2;
  FDisabledImg := 3;

  FOnMouseMove := nil;
  FOnChange := nil;

  FaLeft := TSpriteControl.Create(AParent);
  FaRight := TSpriteControl.Create(AParent);
end;

destructor TSpriteScrollBar.Destroy();
begin
  FaRight.Free();
  FaLeft.Free();

  inherited;
end;

procedure TSpriteScrollBar.SetLeftImg(const Value: String);
begin
  FaLeftImg := Value;
  FaLeft.ImageName := FaLeftImg;
end;

procedure TSpriteScrollBar.SetRightImg(const Value: String);
begin
  FaRightImg := Value;
  FaRight.ImageName := FaRightImg;
end;

procedure TSpriteScrollBar.Draw();
var
  tR: Real;
  sColl: Boolean;
begin
  // Background
  if (FBackImg <> '') then
    Engine.Canvas.DrawEx(Engine.Image.Image[FBackImg], 0, FLeft +
      FaLeft.PatternWidth - FBackImgMin, (Y + FaLeft.PatternWidth / 2) -
      Engine.Image.Image[FBackImg].PatternSize.Y / 2, FSclX, 1.0, False, False,
      False, clWhite4, fxBlend);

  inherited;

  // Get mouse position
  FMsPos := Mouse.CursorPos;
  ScreenToClient(FHandle, FMsPos);

  // Get mouse state
  if (FMouse.Pressed[scMsButton]) and (not FClc) and (FEnabled) then begin
    FClc := True;

    if (Collisioned) then begin
      FMsOld := FMsPos;
      FOldX := X;
      FOldPos := FsPos;
    end;

    if (FaLeft.Collisioned) then
      if (Position - FChange < 0) then
        Position := 0
      else
        Position := Position - FChange;

    if (FaRight.Collisioned) then
      if (Position + FChange > 100) then
        Position := 100
      else
        Position := Position + FChange;
  end;

  if (FMouse.Released[scMsButton]) then
    FClc := False;

  // Set position
  FaLeft.X := FLeft;
  FaLeft.Y := Y;
  FaRight.X := FLeft + FWidth - FaRight.PatternWidth;
  FaRight.Y := Y;

  // Mouse positioning
  if (Collisioned) and (FClc) and (FEnabled) and (FEnabledAction) then begin
    // Set position
    X := FOldX + FMsPos.X - FMsOld.X;

    // Test
    if (X >= FLeft + FWidth - FaRight.PatternWidth - PatternWidth) then
      X := FLeft + FWidth - FaRight.PatternWidth - PatternWidth;
    if (X <= FLeft + FaLeft.PatternWidth) then
      X := FLeft + FaLeft.PatternWidth;

    // Position
    tR := 100 / (FWidth - PatternWidth - FaLeft.PatternWidth - FaRight.PatternWidth);
    FsPos := Ceil((X - FLeft - FaLeft.PatternWidth) * tR);

    if (FsPos <> FOldPos) and (Assigned(FOnChange)) then
      FOnChange(Self);
  end;

  // OnMouseMove
  if (Collisioned) or (FaLeft.Collisioned) or (FaRight.Collisioned) then
    sColl := True
  else
    sColl := False;

  if (sColl) and (Assigned(FOnMouseMove)) then
    FOnMouseMove(Self);

  // "Action"
  if (not Collisioned) then
    PatternIndex := FNormalImg;
  if (Collisioned) and (FEnabledAction) then
    PatternIndex := FNormalOver;
  if (Collisioned) and (FClc) and (FEnabledAction) then
    PatternIndex := FClickImg;

  // Left arrow
  if (not FaLeft.Collisioned) then
    FaLeft.PatternIndex := FNormalImg;
  if (FaLeft.Collisioned) then
    FaLeft.PatternIndex := FNormalOver;
  if (FaLeft.Collisioned) and (FClc) then
    FaLeft.PatternIndex := FClickImg;

  // Right arrow
  if (not FaRight.Collisioned) then
    FaRight.PatternIndex := FNormalImg;
  if (FaRight.Collisioned) then
    FaRight.PatternIndex := FNormalOver;
  if (FaRight.Collisioned) and (FClc) then
    FaRight.PatternIndex := FClickImg;

  // Disabled
  if (not FEnabled) then begin
    PatternIndex := FDisabledImg;
    FaLeft.PatternIndex := FDisabledImg;
    FaRight.PatternIndex := FDisabledImg;
  end;

  // Draw arrow
  FaLeft.Draw();
  FaRight.Draw();
end;

procedure TSpriteScrollBar.Move(const MoveCount: Single);
begin
  inherited;

  if (not FEnabled) then
    Exit;

  CollideRect := Rect(Ceil(X), Ceil(Y), Ceil(X + PatternWidth),
    Ceil(Y + PatternHeight));

  FaLeft.CollideRect := Rect(Ceil(FaLeft.X), Ceil(Y), Ceil(FaLeft.X + FaLeft.PatternWidth),
    Ceil(Y + FaLeft.PatternHeight));

  FaRight.CollideRect := Rect(Ceil(FaRight.X), Ceil(Y), Ceil(FaRight.X + FaRight.PatternWidth),
    Ceil(Y + FaRight.PatternHeight));

  FaLeft.Move(MoveCount);
  FaRight.Move(MoveCount);
end;

procedure TSpriteScrollBar.OnCollision(const Sprite: TSprite);
begin

end;

procedure TSpriteScrollBar.Collision(const Other: TSprite);
begin
  inherited;

  FaLeft.Collision(Other);
  FaRight.Collision(Other);
end;

procedure TSpriteScrollBar.SetDrawCRect(const Value: Boolean);
begin
  inherited;

  FaLeft.DrawCollRect := Value;
  FaRight.DrawCollRect := Value;
end;

procedure TSpriteScrollBar.SetPos(const Value: Integer);
var
  B: Boolean;
  tR: Real;
begin
  B := False;
  if (Value <> FsPos) then
    B := True;
    
  FsPos := Value;
  tR := (FWidth - PatternWidth - FaLeft.PatternWidth -
    FaRight.PatternWidth) / 100.0;
  X := FLeft + FaLeft.PatternWidth + tR * FsPos;

  if (B) and (Assigned(FOnChange)) then
    FOnChange(Self);
end;

procedure TSpriteScrollBar.SetBackImg(const Value: String);
var
  pWidth: Integer;
begin
  // Check, if is existing
  if (Engine.Image.Find(Value) < 0) then begin
    FBackImg := '';
    Exit;
  end;

  pWidth := Engine.Image.Image[Value].PatternSize.X;

  // Get ScaleX
  FSclX := (FWidth - FaLeft.PatternWidth - FaRight.PatternWidth + 2 *
    FBackImgMin) / pWidth;

  // Set back image
  FBackImg := Value;
end;

procedure TSpriteScrollBar.SetWidth(const Value: Real);
begin
  FWidth := Value;
  if (FBackImg <> '') then
    SetBackImg(FBackImg);
end;
{ ----------------------------------- ----------------------------------------- }

end.

unit XMLUtils;

interface

uses AsphyreXML, XObjects, AsphyreDef, SysUtils, Vectors2, AsphyreEffects,
  MediaUtils;

//------------------------------------------------------------------------------
function ParseBool(Text: string; Default: Boolean = false): Boolean;

function ParsePoint2(Node: TXMLNode; const DefValue: TPoint2): TPoint2; overload;
function ParsePoint2(Node: TXMLNode): TPoint2; overload;

function StrToDrawFx(Text: string): Cardinal;
function DrawFxToStr(DrawFx: Cardinal): string;

//------------------------------------------------------------------------------
implementation

//------------------------------------------------------------------------------
function ParseBool(Text: string; Default: Boolean = false): Boolean;
begin
  Text := LowerCase(Text);
  Result := Default or (Text = 'true') or (Text = 'yes');
end;

//------------------------------------------------------------------------------
function ParsePoint2(Node: TXMLNode; const DefValue: TPoint2): TPoint2;
begin
  Result := DefValue;
  if (Node = nil) then Exit;
  Result.x := ParseFloat(Node.FieldValue['x'], DefValue.x);
  Result.y := ParseFloat(Node.FieldValue['y'], DefValue.y);
end;

//------------------------------------------------------------------------------
function ParsePoint2(Node: TXMLNode): TPoint2;
begin
  Result := ParsePoint2(Node, Point2(0.0, 0.0));
end;


//------------------------------------------------------------------------------
function StrToDrawFx(Text: string): Cardinal;
begin
  Text := LowerCase(Text);
  Result := fxuNoBlend;
  if (Text = 'fxuadd') then Result := fxuAdd
  else
    if (Text = 'fxuaddna') then Result := fxuAddNA
    else
      if (Text = 'fxublend') then Result := fxuBlend
      else
        if (Text = 'fxushadow') then Result := fxuShadow
        else
          if (Text = 'fxumultiply') then Result := fxuMultiply
          else
            if (Text = 'fxuinvmultiply') then Result := fxuInvMultiply
            else
              if (Text = 'fxublendna') then Result := fxuBlendNA
              else
                if (Text = 'fxusub') then Result := fxuSub
                else
                  if (Text = 'fxurevsub') then Result := fxuRevSub
                  else
                    if (Text = 'fxumax') then Result := fxuMax
                    else
                      if (Text = 'fxumin') then Result := fxuMin;  
end;

//------------------------------------------------------------------------------
function DrawFxToStr(DrawFx: Cardinal): string;
begin
  Result := 'fxuNoBlend';
  case DrawFx of
    fxuAdd        : Result := 'fxuAdd';
    fxuAddNA      : Result := 'fxuAddNA';
    fxuBlend      : Result := 'fxuBlend';
    fxuShadow     : Result := 'fxuShadow';
    fxuMultiply   : Result := 'fxuMultiply';
    fxuInvMultiply: Result := 'fxuInvMultiply';
    fxuBlendNA    : Result := 'fxuBlendNA';
    fxuSub        : Result := 'fxuSub';
    fxuRevSub     : Result := 'fxuRevSub';
    fxuMax        : Result := 'fxuMax';
    fxuMin        : Result := 'fxuMin';
  end;
end;

//------------------------------------------------------------------------------
end.

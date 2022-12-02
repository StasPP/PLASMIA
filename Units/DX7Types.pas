unit DX7Types;
//---------------------------------------------------------------------------
// DX7Types.pas                                         Modified: 10-Oct-2007
// Shared DirectX 7.0 types and variables                         Version 1.0
//---------------------------------------------------------------------------
// Important Notice:
//
// If you modify/use this code or one of its parts either in original or
// modified form, you must comply with Mozilla Public License v1.1,
// specifically section 3, "Distribution Obligations". Failure to do so will
// result in the license breach, which will be resolved in the court.
// Remember that violating author's rights is considered a serious crime in
// many countries. Thank you!
//
// !! Please *read* Mozilla Public License 1.1 document located at:
//  http://www.mozilla.org/MPL/
//---------------------------------------------------------------------------
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is DX7Types.pas.
//
// The Initial Developer of the Original Code is M. Sc. Yuriy Kotsarenko.
// Portions created by M. Sc. Yuriy Kotsarenko are Copyright (C) 2007,
// Ixchel Studios. All Rights Reserved.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 DirectDraw7, Direct3D7, DirectInput;

//---------------------------------------------------------------------------
var
 DirectDraw: IDirectDraw7     = nil;
 Direct3D  : IDirect3D7       = nil;
 Device7   : IDirect3DDevice7 = nil;
 DInput7   : IDirectInput7    = nil;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
initialization

//---------------------------------------------------------------------------
finalization
 if (DInput7 <> nil) then DInput7:= nil;

//---------------------------------------------------------------------------
end.

{ ---------------------------------------------------------------------------- }
{                                                                              }
{ Component: TAsphyreDevCaps                                                   }
{ Version:   0.0.1                                                             }
{ Modified:  04-12-06 (DD-MM-YY)                                               }
{                                                                              }
{ Author:    Jaromir "Cervajz" Cervenka                                        }
{ Mail:      jara.cervenka@seznam.cz                                           }
{ Web:       http://www.cervajz.profitux.cz/                                   }
{                                                                              }
{ License:                                                                     }
{    FREE FOR ALL (ALSO FOR COMMERCIAL USE)                                    }
{                                                                              }
{ Changes:                                                                     }
{   v0.0.1:                                                                    }
{     * First release                                                          }
{                                                                              }
{ ---------------------------------------------------------------------------- }

unit AsphyreDevCaps;

interface

uses
  Classes, Direct3D9, SysUtils, DXTypes;

const
  sCmpVer = 'v0.0.1';

type
  TaDevType = (dtHAL, dtNullRef, dtRef, dtSw);

  TAsphyreDevCaps = class(TComponent)
  private
    { private declarations }
    FDone: Boolean;
    FDeviceNum: Cardinal;
    FDeviceType: TaDevType;
    FDevTpe: _D3DDEVTYPE;

    // Caps
    FCapsReadScanLine: Boolean;

    // From Caps2 (D3DCAPS2)
    FCaps2CanAutoGenMipMap: Boolean;
    FCaps2CanCalibrateGamma: Boolean;
    FCaps2CanManageResource: Boolean;
    FCaps2DynamicTextures: Boolean;
    FCaps2FulscreenGamma: Boolean;

    // From Caps3 (D3DCAPS3)
    FCaps3AlphaFullScreenFlipOrDiscard: Boolean;
    FCaps3CopyToVidMem: Boolean;
    FCaps3CopyToSystemMem: Boolean;
    FCaps3LinearToSRGBPresentation: Boolean;

    // PresentationIntervals
    FPresentIntervalImmediate: Boolean;
    FPresentIntervalOne: Boolean;
    FPresentIntervalTwo: Boolean;
    FPresentIntervalThree: Boolean;
    FPresentIntervalFour: Boolean;

    // From CursorCaps
    FCursorColor: Boolean;
    FCursorLowRes: Boolean;

    // From DevCaps
    FDevCapsCanBltSysToNonLocal: Boolean;
    FDevCapsCanRenderAfterFlip: Boolean;
    FDevCapsDrawPrimitives2: Boolean;
    FDevCapsDrawPrimitives2Ex: Boolean;
    FDevCapsDrawPrimTLVertex: Boolean;
    FDevCapsExecuteSystemMemory: Boolean;
    FDevCapsExecuteVideoMemory: Boolean;
    FDevCapsHwRasterization: Boolean;
    FDevCapsHwTransformAndLight: Boolean;
    FDevCapsNPatches: Boolean;
    FDevCapsPureDevice: Boolean;
    FDevCapsQuinticRTPatches: Boolean;
    FDevCapsRTPatches: Boolean;
    FDevCapsRTPatchHandleZero: Boolean;
    FDevCapsSeparateTextureMemories: Boolean;
    FDevCapsTextureSystemMemory: Boolean;
    FDevCapsTextureVideoMemory: Boolean;
    FDevCapsTLVertexSystemMemory: Boolean;
    FDevCapsTLVertexVideoMemory: Boolean;

    // From PrimitiveMiscCaps (D3DPMISCCAPS)
    FPMiscMaskZ: Boolean;
    FPMiscCullNone: Boolean;
    FPMiscCullCW: Boolean;
    FPMiscCullCCW: Boolean;
    FPMiscColorWriteEnable: Boolean;
    FPMiscClipPlaneScalePoints: Boolean;
    FPMiscClipVerts: Boolean;
    FPMiscTSSArgTemp: Boolean;
    FPMiscMiscCapsBlendOp: Boolean;
    FPMiscNullReference: Boolean;
    FPMiscIndependentWriteMasks: Boolean;
    FPMiscPerStageConstant: Boolean;
    FPMiscFogAndSpecularAlpha: Boolean;
    FPMiscSeparateAlphaBlend: Boolean;
    FPMiscMRTIndependentBithDepths: Boolean;
    FPMiscMRTPostPixelShaderBlending: Boolean;
    FPMiscVertexClamped: Boolean;

    // From RasterCaps
    FRasterAnisotropy: Boolean;
    FRasterColorPerspective: Boolean;
    FRasterDither: Boolean;
    FRasterDepthBias: Boolean;
    FRasterFogRange: Boolean;
    FRasterFogTable: Boolean;
    FRasterFogVertex: Boolean;
    FRasterMipMapLODBias: Boolean;
    FRasterMultiSampleToggle: Boolean;
    FRasterScissorTest: Boolean;
    FRasterSlopeScaleDepthBias: Boolean;
    FRasterWBuffer: Boolean;
    FRasterWFog: Boolean;
    FRasterZBufferLessHSR: Boolean;
    FRasterZFog: Boolean;
    FRasterZTest: Boolean;

    // From ZCmpCaps
    FZCmpAlways: Boolean;
    FZCmpEqual: Boolean;
    FZCmpGreater: Boolean;
    FZCmpGreaterEqual: Boolean;
    FZCmpLess: Boolean;
    FZCmpLessEqual: Boolean;
    FZCmpNever: Boolean;
    FZCmpNotEqual: Boolean;

    // From SrcBlendCaps
    FSrcBlendFactor: Boolean;
    FSrcBlendBothInvSrcAlpha: Boolean;
    FSrcBlendBothSrcAlpha: Boolean;
    FSrcBlendDestAlpha: Boolean;
    FSrcBlendDestColor: Boolean;
    FSrcBlendInvDestAlpha: Boolean;
    FSrcBlendInvDestColor: Boolean;
    FSrcBlendInvSrcAlpha: Boolean;
    FSrcBlendInvSrcColor: Boolean;
    FSrcBlendOne: Boolean;
    FSrcBlendSrcAlpha: Boolean;
    FSrcBlendSrcAlphaSat: Boolean;
    FSrcBlendSrcColor: Boolean;
    FSrcBlendZero: Boolean;
   
    // From DestBlendCaps
    FDestBlendFactor: Boolean;
    FDestBlendBothInvSrcAlpha: Boolean;
    FDestBlendBothSrcAlpha: Boolean;
    FDestBlendDestAlpha: Boolean;
    FDestBlendDestColor: Boolean;
    FDestBlendInvDestAlpha: Boolean;
    FDestBlendInvDestColor: Boolean;
    FDestBlendInvSrcAlpha: Boolean;
    FDestBlendInvSrcColor: Boolean;
    FDestBlendOne: Boolean;
    FDestBlendSrcAlpha: Boolean;
    FDestBlendSrcAlphaSat: Boolean;
    FDestBlendSrcColor: Boolean;
    FDestBlendZero: Boolean;
    
    // From AlphaCmpCaps
    FACmpAlways: Boolean;
    FACmpEqual: Boolean;
    FACmpGreater: Boolean;
    FACmpGreaterEqual: Boolean;
    FACmpLess: Boolean;
    FACmpLessEqual: Boolean;
    FACmpNever: Boolean;
    FACmpNotEqual: Boolean;

    // From ShadeCaps
    FShadeAlphaGoraudBlend: Boolean;
    FShadeColorGoraudRGB: Boolean;
    FShadeFogGoraud: Boolean;
    FShadeSpecularGoraudRGB: Boolean;

    // From TextureCaps
    FTextureAlpha: Boolean;
    FTextureAlphaPallete: Boolean;
    FTextureCubeMap: Boolean;
    FTextureCubeMapPow2: Boolean;
    FTextureMipCubeMap: Boolean;
    FTextureMipMap: Boolean;
    FTextureMipVolumeMap: Boolean;
    FTextureNonPow2Conditional: Boolean;
    FTextureNoProjectedBumpEnv: Boolean;
    FTexturePerspective: Boolean;
    FTexturePow2: Boolean;
    FTextureProjected: Boolean;
    FTextureSquareOnly: Boolean;
    FTextureTexRepeatNotScaleBySize: Boolean;
    FTextureVolumeMap: Boolean;
    FTextureVolumeMapPow2: Boolean;

    // From TextureFilterCaps (D3DPTFILTERCAPS)
    FTexFilterMagFPoint: Boolean;
    FTexFilterMagFLinear: Boolean;
    FTexFilterMagFAnisotropic: Boolean;
    FTexFilterMagFPyramidalQuad: Boolean;
    FTexFilterMagFGaussianQuad: Boolean;
    FTexFilterMinFPoint: Boolean;
    FTexFilterMinFLinear: Boolean;
    FTexFilterMinFAnisotropic: Boolean;
    FTexFilterMinFPyramidalQuad: Boolean;
    FTexFilterMinFGaussianQuad: Boolean;
    FTexFilterMipFPoint: Boolean;
    FTexFilterMipFLinear: Boolean;

    // From CubeTextureFilterCaps (D3DPTFILTERCAPS)
    FCubeTexFilterMagFPoint: Boolean;
    FCubeTexFilterMagFLinear: Boolean;
    FCubeTexFilterMagFAnisotropic: Boolean;
    FCubeTexFilterMagFPyramidalQuad: Boolean;
    FCubeTexFilterMagFGaussianQuad: Boolean;
    FCubeTexFilterMinFPoint: Boolean;
    FCubeTexFilterMinFLinear: Boolean;
    FCubeTexFilterMinFAnisotropic: Boolean;
    FCubeTexFilterMinFPyramidalQuad: Boolean;
    FCubeTexFilterMinFGaussianQuad: Boolean;
    FCubeTexFilterMipFPoint: Boolean;
    FCubeTexFilterMipFLinear: Boolean;

    // From VolumeTextureFilterCaps (D3DPTFILTERCAPS)
    FVolumeTexFilterMagFPoint: Boolean;
    FVolumeTexFilterMagFLinear: Boolean;
    FVolumeTexFilterMagFAnisotropic: Boolean;
    FVolumeTexFilterMagFPyramidalQuad: Boolean;
    FVolumeTexFilterMagFGaussianQuad: Boolean;
    FVolumeTexFilterMinFPoint: Boolean;
    FVolumeTexFilterMinFLinear: Boolean;
    FVolumeTexFilterMinFAnisotropic: Boolean;
    FVolumeTexFilterMinFPyramidalQuad: Boolean;
    FVolumeTexFilterMinFGaussianQuad: Boolean;
    FVolumeTexFilterMipFPoint: Boolean;
    FVolumeTexFilterMipFLinear: Boolean;

    // From TextureAdressCaps
    FTexAdressBorder: Boolean;
    FTexAdressClamp: Boolean;
    FTexAdressIndependentUV: Boolean;
    FTexAdressMirror: Boolean;
    FTexAdressMirrorOnce: Boolean;
    FTexAdressWrap: Boolean;

    // From VolumeTextureAdressCaps
    FVolumeTexAdressBorder: Boolean;
    FVolumeTexAdressClamp: Boolean;
    FVolumeTexAdressIndependentUV: Boolean;
    FVolumeTexAdressMirror: Boolean;
    FVolumeTexAdressMirrorOnce: Boolean;
    FVolumeTexAdressWrap: Boolean;

    // From LineCaps
    FLineAlphaCmp: Boolean;
    FLineAntialias: Boolean;
    FLineBlend: Boolean;
    FLineFog: Boolean;
    FLineTexture: Boolean;
    FLineZTest: Boolean;

    FMaxTextureWidth: Cardinal;
    FMaxTextureHeight: Cardinal;
    FMaxVolumeExtent: Cardinal;
    FMaxTextureRepeat: Cardinal;
    FMaxTextureAspectRatio: Cardinal;
    FMaxAnisotropy: Cardinal;
    FMaxVertexW: Single;
    FGuardBandLeft: Single;
    FGuardBandTop: Single;
    FGuardBandRight: Single;
    FGuardBandBottom: Single;
    FExtentsAdjust: Single;

    // From StencilCaps (D3DSTENCILCAPS)
    FStencilKeep: Boolean;
    FStencilZero: Boolean;
    FStencilReplace: Boolean;
    FStencilIncrSat: Boolean;
    FStencilDecrSat: Boolean;
    FStencilInvert: Boolean;
    FStencilIncr: Boolean;
    FStencilDecr: Boolean;
    FStencilTwoSided: Boolean;

    // From FVFCaps
    FFVFDoNotStripeElements: Boolean;
    FFVFPSize: Boolean;
    FFVFTexCoordCountMask: Cardinal;

    // From TextureOpCaps
    FTexOpAdd: Boolean;
    FTexOpAddSigned: Boolean;
    FTexOpAddSigned2x: Boolean;
    FTexOpAddSmooth: Boolean;
    FTexOpBlendCurrentAlpha: Boolean;
    FTexOpBlendDiffuseAlpha: Boolean;
    FTexOpBlendFactorAlpha: Boolean;
    FTexOpBlendTextureAlpha: Boolean;
    FTexOpBlendTextureAlphaPm: Boolean;
    FTexOpBumpEnvMap: Boolean;
    FTexOpBumpEnvMapLuminance: Boolean;
    FTexOpDisable: Boolean;
    FTexOpDOTProduct3: Boolean;
    FTexOpLERP: Boolean;
    FTexOpModulate: Boolean;
    FTexOpModulate2x: Boolean;
    FTexOpModulate4x: Boolean;
    FTexOpModulateAlphaAddColor: Boolean;
    FTexOpModulateColorAddAlpha: Boolean;
    FTexOpModulateInvAlphaAddColor: Boolean;
    FTexOpModulateInvColorAddAlpha: Boolean;
    FTexOpMultiplyAdd: Boolean;
    FTexOpPreModulate: Boolean;
    FTexOpSelectARG1: Boolean;
    FTexOpSelectARG2: Boolean;
    FTexOpSubstract: Boolean;

    FMaxTextureBlendStages: Cardinal;
    FMaxSimultaneousTextures: Cardinal;

    // From VertexProcessingCaps (D3DVTXPCAPS)
    FVtxPDirectonalLights: Boolean;
    FVtxPLocalViewer: Boolean;
    FVtxPMaterialSoure7: Boolean;
    FVtxPNoTexGenNonLocalViewer: Boolean;
    FVtxPPositionalLights: Boolean;
    FVtxPTexGen: Boolean;
    FVtxPTexGenSphereMap: Boolean;
    FVtxPTweening: Boolean;

    FMaxActiveLights: Cardinal;
    FMaxUserClipPlanes: Cardinal;
    FMaxVertexBlendMatrices: Cardinal;
    FMaxVertexBlendMatrixIndex: Cardinal;
    FMaxPointSize: Single;
    FMaxPrimitiveCount: Cardinal;
    FMaxVertexIndex: Cardinal;
    FMaxStreams: Cardinal;
    FMaxStreamStride: Cardinal;
    FVertexShaderVersion: String;
    FMaxVertexShaderConst: Cardinal;
    FPixelShaderVersion: String;
    FPixelShader1xMaxValue: Single;

    // From DevCaps2 (D3DDEVCAPS2)
    FDevCaps2AdaptiveTessRTPatch: Boolean;
    FDevCaps2AdaptiveTessNPatch: Boolean;
    FDevCaps2CanStretchRectFromTextures: Boolean;
    FDevCaps2DMapNPatch: Boolean;
    FDevCaps2PresampledDMapNPatch: Boolean;
    FDevCaps2StreamOffset: Boolean;
    FDevCaps2VertexElemtsCanShareStreamOffset: Boolean;

    FMaxNPatchTessellationLevel: Single;
//    FMinAntialiasedLineWidth: Single;
//    FMaxAntialiasedLineWidth: Single;
    FMasterAdapterOrdinal: Cardinal;
    FAdapterOrdinalInGroup: Cardinal;
    FNumberOfAdaptersInGroup: Cardinal;

    // From DeclTypes (D3DDTCAPS)
    FDTUByte4: Boolean;
    FDTUByte4N: Boolean;
    FDTShort2N: Boolean;
    FDTShort4N: Boolean;
    FDTUShort2N: Boolean;
    FDTUShort4N: Boolean;
    FDTUDec3: Boolean;
    FDTDec3N: Boolean;
    FDT2DFloat16: Boolean;
    FDT4DFloat16: Boolean;

    FNumSimultaneousRTs: Cardinal;

    // From StretchRectFilterCaps
    FSRectMinFPoint: Boolean;
    FSRectMagFPoint: Boolean;
    FSRectMinFLinear: Boolean;
    FSRectMagFLinear: Boolean;

    // From VS20Caps (D3DVS20CAPS)
    FVS20Predication: Boolean;
    FVS20MaxDynamicFlowControlDepth: Cardinal;
    FVS20MinDynamicFlowControlDepth: Cardinal;
    FVS20MaxNumTemps: Cardinal;
    FVS20MinNumTemps: Cardinal;
    FVS20MaxStaticFlowControlDepth: Cardinal;
    FVS20MinStaticFlowControlDepth: Cardinal;
    // (D3DVSHADERCAPS2_0)
    FVS20DynamicFlowControlDepth: Integer;
    FVS20NumTemps: Integer;
    FVS20StaticFlowControlDepth: Integer;

    // From PS20Caps (D3DPS20CAPS)
    FPS20Predication: Boolean;
    FPS20MaxDynamicFlowControlDepth: Cardinal;
    FPS20MinDynamicFlowControlDepth: Cardinal;
    FPS20MaxNumTemps: Cardinal;
    FPS20MinNumTemps: Cardinal;
    FPS20MaxStaticFlowControlDepth: Cardinal;
    FPS20MinStaticFlowControlDepth: Cardinal;
    // (D3DPSHADERCAPS2_0)
    FPS20DynamicFlowControlDepth: Integer;
    FPS20NumTemps: Integer;
    FPS20StaticFlowControlDepth: Integer;
    FPS20ARBITRARYSWIZLLE: Boolean;
    FPS20GradientInstructions: Boolean;
    FPS20NoDependentReadLimit: Boolean;
    FPS20NoTexInstructionLimit: Boolean;
    FPS20NumInstructionSlots: Integer;

    // From VertexTextureFilterCaps (D3DPTFILTERCAPS)
    FVertexTexFilterMagFPoint: Boolean;
    FVertexTexFilterMagFLinear: Boolean;
    FVertexTexFilterMagFAnisotropic: Boolean;
    FVertexTexFilterMagFPyramidalQuad: Boolean;
    FVertexTexFilterMagFGaussianQuad: Boolean;
    FVertexTexFilterMinFPoint: Boolean;
    FVertexTexFilterMinFLinear: Boolean;
    FVertexTexFilterMinFAnisotropic: Boolean;
    FVertexTexFilterMinFPyramidalQuad: Boolean;
    FVertexTexFilterMinFGaussianQuad: Boolean;
    FVertexTexFilterMipFPoint: Boolean;
    FVertexTexFilterMipFLinear: Boolean;

    FMaxVShaderInstructionsExecuted: Cardinal;
    FMaxPShaderInstructionsExecuted: Cardinal;
    FMaxVertexShader30InstructionSlots: Cardinal;
    FMaxPixelShader30InstructionSlots: Cardinal;

    // From D3DADAPTER_IDENTIFIER9
    FAdapterDriver: string;
    FAdapterDescription: string;
    FAdapterDeviceName: string;
    FAdapterDriverVersion: Int64;
    FAdapterVendorId: Cardinal;
    FAdapterDeviceId: Cardinal;
    FAdapterSubSysId: Cardinal;
    FAdapterRevision: Cardinal;

    // MaxMultiSampleType
    FMaxFAA: Integer;

    function FMask(const Src, Value: Cardinal): Boolean;
    procedure FReset();
    procedure FSetDevNum(const Value: Cardinal);
    procedure FSetDevType(const Value: TaDevType);
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { published declarations }
    function Update(): Boolean;
    function SaveToHTML(const FileName: TFileName): Boolean;

    property Done: Boolean read FDone;
    property DeviceNum: Cardinal read FDeviceNum write FSetDevNum;
    property DeviceType: TaDevType read FDeviceType write FSetDevType;

    property CapsReadScanLine: Boolean read FCapsReadScanLine;

    property Caps2CanAutoGenMipMap: Boolean read FCaps2CanAutoGenMipMap;
    property Caps2CanCalibrateGamma: Boolean read FCaps2CanCalibrateGamma;
    property Caps2CanManageResource: Boolean read FCaps2CanManageResource;
    property Caps2DynamicTextures: Boolean read FCaps2DynamicTextures;
    property Caps2FulscreenGamma: Boolean read FCaps2FulscreenGamma;

    property Caps3AlphaFullScreenFliOrDiscard: Boolean read FCaps3AlphaFullScreenFlipOrDiscard;
    property Caps3CopyToVidMem: Boolean read FCaps3CopyToVidMem;
    property Caps3CopyToSystemMem: Boolean read FCaps3CopyToSystemMem;
    property Caps3LinearToSRGBPresentation: Boolean read FCaps3LinearToSRGBPresentation;

    property PresentIntervalImmediate: Boolean read FPresentIntervalImmediate;
    property PresentIntervalOne: Boolean read FPresentIntervalOne;
    property PresentIntervalTwo: Boolean read FPresentIntervalTwo;
    property PresentIntervalThree: Boolean read FPresentIntervalThree;
    property PresentIntervalFour: Boolean read FPresentIntervalFour;

    property CursorColor: Boolean read FCursorColor;
    property CursorLowRes: Boolean read FCursorLowRes;

    property DevCapsCanBltSysToNonLocal: Boolean read FDevCapsCanBltSysToNonLocal;
    property DevCapsCanRenderAfterFlip: Boolean read FDevCapsCanRenderAfterFlip;
    property DevCapsDrawPrimitives2: Boolean read FDevCapsDrawPrimitives2;
    property DevCapsDrawPrimitives2Ex: Boolean read FDevCapsDrawPrimitives2Ex;
    property DevCapsDrawPrimTLVertex: Boolean read FDevCapsDrawPrimTLVertex;
    property DevCapsExecuteSystemMemory: Boolean read FDevCapsExecuteSystemMemory;
    property DevCapsExecuteVideoMemory: Boolean read FDevCapsExecuteVideoMemory;
    property DevCapsHwRasterization: Boolean read FDevCapsHwRasterization;
    property DevCapsHwTransformAndLight: Boolean read FDevCapsHwTransformAndLight;
    property DevCapsNPatches: Boolean read FDevCapsNPatches;
    property DevCapsPureDevice: Boolean read FDevCapsPureDevice;
    property DevCapsQuinticRTPatches: Boolean read FDevCapsQuinticRTPatches;
    property DevCapsRTPatches: Boolean read FDevCapsRTPatches;
    property DevCapsRTPatchHandleZero: Boolean read FDevCapsRTPatchHandleZero;
    property DevCapsSeparateTextureMemories: Boolean read FDevCapsSeparateTextureMemories;
    property DevCapsTextureSystemMemory: Boolean read FDevCapsTextureSystemMemory;
    property DevCapsTextureVideoMemory: Boolean read FDevCapsTextureVideoMemory;
    property DevCapsTLVertexSystemMemory: Boolean read FDevCapsTLVertexSystemMemory;
    property DevCapsTLVertexVideoMemory: Boolean read FDevCapsTLVertexVideoMemory;

    property MiscMaskZ: Boolean read FPMiscMaskZ;
    property MiscCullNone: Boolean read FPMiscCullNone;
    property MiscCullCW: Boolean read FPMiscCullCW;
    property MiscCullCCW: Boolean read FPMiscCullCCW;
    property MiscColorWriteEnable: Boolean read FPMiscColorWriteEnable;
    property MiscClipPlaneScalePoints: Boolean read FPMiscClipPlaneScalePoints;
    property MiscClipVerts: Boolean read FPMiscClipVerts;
    property MiscTSSArgTemp: Boolean read FPMiscTSSArgTemp;
    property MiscBlendOp: Boolean read FPMiscMiscCapsBlendOp;
    property MiscNullReference: Boolean read FPMiscNullReference;
    property MiscIndependentWriteMasks: Boolean read FPMiscIndependentWriteMasks;
    property MiscPerStageConstant: Boolean read FPMiscPerStageConstant;
    property MiscFogAndSpecularAlpha: Boolean read FPMiscFogAndSpecularAlpha;
    property MiscSeparateAlphaBlend: Boolean read FPMiscSeparateAlphaBlend;
    property MiscMRTIndependentBithDepths: Boolean read FPMiscMRTIndependentBithDepths;
    property MiscMRTPostPixelShaderBlending: Boolean read FPMiscMRTPostPixelShaderBlending;
    property MiscFogVertexClamped: Boolean read FPMiscVertexClamped;

    property RasterAnisotropy: Boolean read FRasterAnisotropy;
    property RasterColorPerspective: Boolean read FRasterColorPerspective;
    property RasterDither: Boolean read FRasterDither;
    property RasterDepthBias: Boolean read FRasterDepthBias;
    property RasterFogRange: Boolean read FRasterFogRange;
    property RasterFogTable: Boolean read FRasterFogTable;
    property RasterFogVertex: Boolean read FRasterFogVertex;
    property RasterMipMapLODBias: Boolean read FRasterMipMapLODBias;
    property RasterMultiSampleToggle: Boolean read FRasterMultiSampleToggle;
    property RasterScissorTest: Boolean read FRasterScissorTest;
    property RasterSlopeScaleDepthBias: Boolean read FRasterSlopeScaleDepthBias;
    property RasterWBuffer: Boolean read FRasterWBuffer;
    property RasterWFog: Boolean read FRasterWFog;
    property RasterZBufferLessHSR: Boolean read FRasterZBufferLessHSR;
    property RasterZFog: Boolean read FRasterZFog;
    property RasterZTest: Boolean read FRasterZTest;

    property ZCmpAlways: Boolean read FZCmpAlways;
    property ZCmpEqual: Boolean read FZCmpEqual;
    property ZCmpGreater: Boolean read FZCmpGreater;
    property ZCmpGreaterEqual: Boolean read FZCmpGreaterEqual;
    property ZCmpLess: Boolean read FZCmpLess;
    property ZCmpLessEqual: Boolean read FZCmpLessEqual;
    property ZCmpNever: Boolean read FZCmpNever;
    property ZCmpNotEqual: Boolean read FZCmpNotEqual;

    property SrcBlendFactor: Boolean read FSrcBlendFactor;
    property SrcBlendBothInvSrcAlpha: Boolean read FSrcBlendBothInvSrcAlpha;
    property SrcBlendBothSrcAlpha: Boolean read FSrcBlendBothSrcAlpha;
    property SrcBlendDestAlpha: Boolean read FSrcBlendDestAlpha;
    property SrcBlendDestColor: Boolean read FSrcBlendDestColor;
    property SrcBlendInvDestAlpha: Boolean read FSrcBlendInvDestAlpha;
    property SrcBlendInvDestColor: Boolean read FSrcBlendInvDestColor;
    property SrcBlendInvSrcAlpha: Boolean read FSrcBlendInvSrcAlpha;
    property SrcBlendInvSrcColor: Boolean read FSrcBlendInvSrcColor;
    property SrcBlendOne: Boolean read FSrcBlendOne;
    property SrcBlendSrcAlpha: Boolean read FSrcBlendSrcAlpha;
    property SrcBlendSrcAlphaSat: Boolean read FSrcBlendSrcAlphaSat;
    property SrcBlendSrcColor: Boolean read FSrcBlendSrcColor;
    property SrcBlendZero: Boolean read FSrcBlendZero;

    property DestBlendFactor: Boolean read FDestBlendFactor;
    property DestBlendBothInvSrcAlpha: Boolean read FDestBlendBothInvSrcAlpha;
    property DestBlendBothSrcAlpha: Boolean read FDestBlendBothSrcAlpha;
    property DestBlendDestAlpha: Boolean read FDestBlendDestAlpha;
    property DestBlendDestColor: Boolean read FDestBlendDestColor;
    property DestBlendInvDestAlpha: Boolean read FDestBlendInvDestAlpha;
    property DestBlendInvDestColor: Boolean read FDestBlendInvDestColor;
    property DestBlendInvSrcAlpha: Boolean read FDestBlendInvSrcAlpha;
    property DestBlendInvSrcColor: Boolean read FDestBlendInvSrcColor;
    property DestBlendOne: Boolean read FDestBlendOne;
    property DestBlendSrcAlpha: Boolean read FDestBlendSrcAlpha;
    property DestBlendSrcAlphaSat: Boolean read FDestBlendSrcAlphaSat;
    property DestBlendSrcColor: Boolean read FDestBlendSrcColor;
    property DestBlendZero: Boolean read FDestBlendZero;

    property ACmpAlways: Boolean read FACmpAlways;
    property ACmpEqual: Boolean read FACmpEqual;
    property ACmpGreater: Boolean read FACmpGreater;
    property ACmpGreaterEqual: Boolean read FACmpGreaterEqual;
    property ACmpLess: Boolean read FACmpLess;
    property ACmpLessEqual: Boolean read FACmpLessEqual;
    property ACmpNever: Boolean read FACmpNever;
    property ACmpNotEqual: Boolean read FACmpNotEqual;

    property ShadeAlphaGoraudBlend: Boolean read FShadeAlphaGoraudBlend;
    property ShadeColorGoraudRGB: Boolean read FShadeColorGoraudRGB;
    property ShadeFogGoraud: Boolean read FShadeFogGoraud;
    property ShadeSpecularGoraudRGB: Boolean read FShadeSpecularGoraudRGB;

    property TextureAlpha: Boolean read FTextureAlpha;
    property TextureAlphaPallete: Boolean read FTextureAlphaPallete;
    property TextureCubeMap: Boolean read FTextureCubeMap;
    property TextureCubeMapPow2: Boolean read FTextureCubeMapPow2;
    property TextureMipCubeMap: Boolean read FTextureMipCubeMap;
    property TextureMipMap: Boolean read FTextureMipMap;
    property TextureMipVolumeMap: Boolean read FTextureMipVolumeMap;
    property TextureNonPow2Conditional: Boolean read FTextureNonPow2Conditional;
    property TextureNoProjectedBumpEnv: Boolean read FTextureNoProjectedBumpEnv;
    property TexturePerspective: Boolean read FTexturePerspective;
    property TexturePow2: Boolean read FTexturePow2;
    property TextureProjected: Boolean read FTextureProjected;
    property TextureSquareOnly: Boolean read FTextureSquareOnly;
    property TextureTexRepeatNotScaleBySize: Boolean read FTextureTexRepeatNotScaleBySize;
    property TextureVolumeMap: Boolean read FTextureVolumeMap;
    property TextureVolumeMapPow2: Boolean read FTextureVolumeMapPow2;

    property TexFilterMagFPoint: Boolean read FTexFilterMagFPoint;
    property TexFilterMagFLinear: Boolean read FTexFilterMagFLinear;
    property TexFilterMagFAnisotropic: Boolean read FTexFilterMagFAnisotropic;
    property TexFilterMagFPyramidalQuad: Boolean read FTexFilterMagFPyramidalQuad;
    property TexFilterMagFGaussianQuad: Boolean read FTexFilterMagFGaussianQuad;
    property TexFilterMinFPoint: Boolean read FTexFilterMinFPoint;
    property TexFilterMinFLinear: Boolean read FTexFilterMinFLinear;
    property TexFilterMinFAnisotropic: Boolean read FTexFilterMinFAnisotropic;
    property TexFilterMinFPyramidalQuad: Boolean read FTexFilterMinFPyramidalQuad;
    property TexFilterMinFGaussianQuad: Boolean read FTexFilterMinFGaussianQuad;
    property TexFilterMipFPoint: Boolean read FTexFilterMipFPoint;
    property TexFilterMipFLinear: Boolean read FTexFilterMipFLinear;

    property CubeTexFilterMagFPoint: Boolean read FCubeTexFilterMagFPoint;
    property CubeTexFilterMagFLinear: Boolean read FCubeTexFilterMagFLinear;
    property CubeTexFilterMagFAnisotropic: Boolean read FCubeTexFilterMagFAnisotropic;
    property CubeTexFilterMagFPyramidalQuad: Boolean read FCubeTexFilterMagFPyramidalQuad;
    property CubeTexFilterMagFGaussianQuad: Boolean read FCubeTexFilterMagFGaussianQuad;
    property CubeTexFilterMinFPoint: Boolean read FCubeTexFilterMinFPoint;
    property CubeTexFilterMinFLinear: Boolean read FCubeTexFilterMinFLinear;
    property CubeTexFilterMinFAnisotropic: Boolean read FCubeTexFilterMinFAnisotropic;
    property CubeTexFilterMinFPyramidalQuad: Boolean read FCubeTexFilterMinFPyramidalQuad;
    property CubeTexFilterMinFGaussianQuad: Boolean read FCubeTexFilterMinFGaussianQuad;
    property CubeTexFilterMipFPoint: Boolean read FCubeTexFilterMipFPoint;
    property CubeTexFilterMipFLinear: Boolean read FCubeTexFilterMipFLinear;
    
    property VolumeTexFilterMagFPoint: Boolean read FVolumeTexFilterMagFPoint;
    property VolumeTexFilterMagFLinear: Boolean read FVolumeTexFilterMagFLinear;
    property VolumeTexFilterMagFAnisotropic: Boolean read FVolumeTexFilterMagFAnisotropic;
    property VolumeTexFilterMagFPyramidalQuad: Boolean read FVolumeTexFilterMagFPyramidalQuad;
    property VolumeTexFilterMagFGaussianQuad: Boolean read FVolumeTexFilterMagFGaussianQuad;
    property VolumeTexFilterMinFPoint: Boolean read FVolumeTexFilterMinFPoint;
    property VolumeTexFilterMinFLinear: Boolean read FVolumeTexFilterMinFLinear;
    property VolumeTexFilterMinFAnisotropic: Boolean read FVolumeTexFilterMinFAnisotropic;
    property VolumeTexFilterMinFPyramidalQuad: Boolean read FVolumeTexFilterMinFPyramidalQuad;
    property VolumeTexFilterMinFGaussianQuad: Boolean read FVolumeTexFilterMinFGaussianQuad;
    property VolumeTexFilterMipFPoint: Boolean read FVolumeTexFilterMipFPoint;
    property VolumeTexFilterMipFLinear: Boolean read FVolumeTexFilterMipFLinear;

    property TexAdressCapsBorder: Boolean read FTexAdressBorder;
    property TexAdressCapsClamp: Boolean read FTexAdressClamp;
    property TexAdressCapsIndependentUV: Boolean read FTexAdressIndependentUV;
    property TexAdressCapsMirror: Boolean read FTexAdressMirror;
    property TexAdressCapsMirrorOnce: Boolean read FTexAdressMirrorOnce;
    property TexAdressCapsWrap: Boolean read FTexAdressWrap;

    property VolumeTexAdressCapsBorder: Boolean read FVolumeTexAdressBorder;
    property VolumeTexAdressCapsClamp: Boolean read FVolumeTexAdressClamp;
    property VolumeTexAdressCapsIndependentUV: Boolean read FVolumeTexAdressIndependentUV;
    property VolumeTexAdressCapsMirror: Boolean read FVolumeTexAdressMirror;
    property VolumeTexAdressCapsMirrorOnce: Boolean read FVolumeTexAdressMirrorOnce;
    property VolumeTexAdressCapsWrap: Boolean read FVolumeTexAdressWrap;

    property LineAlphaCmp: Boolean read FLineAlphaCmp;
    property LineAntialias: Boolean read FLineAntialias;
    property LineBlend: Boolean read FLineBlend;
    property LineFog: Boolean read FLineFog;
    property LineTexture: Boolean read FLineTexture;
    property LineZTest: Boolean read FLineZTest;

    property MaxTextureWidth: Cardinal read FMaxTextureWidth;
    property MaxTextureHeight: Cardinal read FMaxTextureHeight;
    property MaxVolumeExtent: Cardinal read FMaxVolumeExtent;
    property MaxTextureRepeat: Cardinal read FMaxTextureRepeat;
    property MaxTextureAspectRatio: Cardinal read FMaxTextureAspectRatio;
    property MaxAnisotropy: Cardinal read FMaxAnisotropy;
    property MaxVertexW: Single read FMaxVertexW;
    property GuardBandLeft: Single read FGuardBandLeft;
    property GuardBandTop: Single read FGuardBandTop;
    property GuardBandRight: Single read FGuardBandRight;
    property GuardBandBottom: Single read FGuardBandBottom;
    property ExtentAdjust: Single read FExtentsAdjust;

    property StencilKeep: Boolean read FStencilKeep;
    property StencilZero: Boolean read FStencilZero;
    property StencilReplace: Boolean read FStencilReplace;
    property StencilIncrSat: Boolean read FStencilIncrSat;
    property StencilDecrSat: Boolean read FStencilDecrSat;
    property StencilInvert: Boolean read FStencilInvert;
    property StencilIncr: Boolean read FStencilIncr;
    property StencilDecr: Boolean read FStencilDecr;
    property StencilTwoSided: Boolean read FStencilTwoSided;

    property FVFDoNotStripeElements: Boolean read FFVFDoNotStripeElements;
    property FVFPSize: Boolean read FFVFPSize;
    property FVFTexCoordCountMask: Cardinal read FFVFTexCoordCountMask;

    property TexOpAdd: Boolean read FTexOpAdd;
    property TexOpAddSigned: Boolean read FTexOpAddSigned;
    property TexOpAddSigned2x: Boolean read FTexOpAddSigned2x;
    property TexOpAddSmooth: Boolean read FTexOpAddSmooth;
    property TexOpBlendCurrentAlpha: Boolean read FTexOpBlendCurrentAlpha;
    property TexOpBlendDiffuseAlpha: Boolean read FTexOpBlendDiffuseAlpha;
    property TexOpBlendFactorAlpha: Boolean read FTexOpBlendFactorAlpha;
    property TexOpBlendTextureAlpha: Boolean read FTexOpBlendTextureAlpha;
    property TexOpBlendTextureAlphaPm: Boolean read FTexOpBlendTextureAlphaPm;
    property TexOpBumpEnvMap: Boolean read FTexOpBumpEnvMap;
    property TexOpBumpEnvMapLuminance: Boolean read FTexOpBumpEnvMapLuminance;
    property TexOpDisable: Boolean read FTexOpDisable;
    property TexOpDOTProduct3: Boolean read FTexOpDOTProduct3;
    property TexOpLERP: Boolean read FTexOpLERP;
    property TexOpModulate: Boolean read FTexOpModulate;
    property TexOpModulate2x: Boolean read FTexOpModulate2x;
    property TexOpModulate4x: Boolean read FTexOpModulate4x;
    property TexOpModulateAlphaAddColor: Boolean read FTexOpModulateAlphaAddColor;
    property TexOpModulateColorAddAlpha: Boolean read FTexOpModulateColorAddAlpha;
    property TexOpModulateInvAlphaAddColor: Boolean read FTexOpModulateInvAlphaAddColor;
    property TexOpModulateInvColorAddAlpha: Boolean read FTexOpModulateInvColorAddAlpha;
    property TexOpMultiplyAdd: Boolean read FTexOpMultiplyAdd;
    property TexOpPreModulate: Boolean read FTexOpPreModulate;
    property TexOpSelectARG1: Boolean read FTexOpSelectARG1;
    property TexOpSelectARG2: Boolean read FTexOpSelectARG2;
    property TexOpSubstract: Boolean read FTexOpSubstract;

    property MaxTextureBlendStages: Cardinal read FMaxTextureBlendStages;
    property MaxSimultaneousTextures: Cardinal read FMaxSimultaneousTextures;

    property VtxPDirectonalLights: Boolean read FVtxPDirectonalLights;
    property VtxPLocalViewer: Boolean read FVtxPLocalViewer;
    property VtxPMaterialSoure7: Boolean read FVtxPMaterialSoure7;
    property VtxPNoTexGenNonLocalViewer: Boolean read FVtxPNoTexGenNonLocalViewer;
    property VtxPPositionalLights: Boolean read FVtxPPositionalLights;
    property VtxPTexGen: Boolean read FVtxPTexGen;
    property VtxPTexGenSphereMap: Boolean read FVtxPTexGenSphereMap;
    property VtxPTweening: Boolean read FVtxPTweening;

    property MaxActiveLights: Cardinal read FMaxActiveLights;
    property MaxUserClipPlanes: Cardinal read FMaxUserClipPlanes;
    property MaxVertexBlendMatrices: Cardinal read FMaxVertexBlendMatrices;
    property MaxVertexBlendMatrixIndex: Cardinal read FMaxVertexBlendMatrixIndex;
    property MaxPointSize: Single read FMaxPointSize;
    property MaxPrimitiveCount: Cardinal read FMaxPrimitiveCount;
    property MaxVertexIndex: Cardinal read FMaxVertexIndex;
    property MaxStreams: Cardinal read FMaxStreams;
    property MaxStreamStride: Cardinal read FMaxStreamStride;

    property VertexShaderVersion: string read FVertexShaderVersion;
    property MaxVertexShaderConst: Cardinal read FMaxVertexShaderConst;
    property PixelShaderVersion: string read FPixelShaderVersion;
    property PixelShader1xMaxValue: Single read FPixelShader1xMaxValue;

    property DevCaps2AdaptiveTessRTPatch: Boolean read FDevCaps2AdaptiveTessRTPatch;
    property DevCaps2AdaptiveTessNPatch: Boolean read FDevCaps2AdaptiveTessNPatch;
    property DevCaps2CanStretchRectFromTextures: Boolean read FDevCaps2CanStretchRectFromTextures;
    property DevCaps2DMapNPatch: Boolean read FDevCaps2DMapNPatch;
    property DevCaps2PresampledDMapNPatch: Boolean read FDevCaps2PresampledDMapNPatch;
    property DevCaps2StreamOffset: Boolean read FDevCaps2StreamOffset;
    property DevCaps2VertexElemtsCanShareStreamOffset: Boolean read FDevCaps2VertexElemtsCanShareStreamOffset;

    property MaxNPatchTessellationLevel: Single read FMaxNPatchTessellationLevel;
//    property MinAntialiasedLineWidth: Single read FMinAntialiasedLineWidth;
//    property MaxAntialiasedLineWidth: Single read FMaxAntialiasedLineWidth;
    property MasterAdapterOrdinal: Cardinal read FMasterAdapterOrdinal;
    property AdapterOrdinalInGroup: Cardinal read FAdapterOrdinalInGroup;
    property NumberOfAdaptersInGroup: Cardinal read FNumberOfAdaptersInGroup;

    property DTUByte4: Boolean read FDTUByte4;
    property DTUByte4N: Boolean read FDTUByte4N;
    property DTShort2N: Boolean read FDTShort2N;
    property DTShort4N: Boolean read FDTShort4N;
    property DTUShort2N: Boolean read FDTUShort2N;
    property DTUShort4N: Boolean read FDTUShort4N;
    property DTUDec3: Boolean read FDTUDec3;
    property DTDec3N: Boolean read FDTDec3N;
    property DT2DFloat16: Boolean read FDT2DFloat16;
    property DT4DFloat16: Boolean read FDT4DFloat16;

    property NumSimultaneousRTs: Cardinal read FNumSimultaneousRTs;

    property SRectMinFPoint: Boolean read FSRectMinFPoint;
    property SRectMagFPoint: Boolean read FSRectMagFPoint;
    property SRectMinFLinear: Boolean read FSRectMinFLinear;
    property SRectMagFLinear: Boolean read FSRectMagFLinear;

    property VS20Predication: Boolean read FVS20Predication;
    property VS20MaxDynamicFlowControlDepth: Cardinal read FVS20MaxDynamicFlowControlDepth;
    property VS20MinDynamicFlowControlDepth: Cardinal read FVS20MinDynamicFlowControlDepth;
    property VS20MaxNumTemps: Cardinal read FVS20MaxNumTemps;
    property VS20MinNumTemps: Cardinal read FVS20MinNumTemps;
    property VS20MaxStaticFlowControlDepth: Cardinal read FVS20MaxStaticFlowControlDepth;
    property VS20MinStaticFlowControlDepth: Cardinal read FVS20MinStaticFlowControlDepth;
    property VS20DynamicFlowControlDepth: Integer read FVS20DynamicFlowControlDepth;
    property VS20NumTemps: Integer read FVS20NumTemps;
    property VS20StaticFlowControlDepth: Integer read FVS20StaticFlowControlDepth;

    property PS20Predication: Boolean read FPS20Predication;
    property PS20MaxDynamicFlowControlDepth: Cardinal read FPS20MaxDynamicFlowControlDepth;
    property PS20MinDynamicFlowControlDepth: Cardinal read FPS20MinDynamicFlowControlDepth;
    property PS20MaxNumTemps: Cardinal read FPS20MaxNumTemps;
    property PS20MinNumTemps: Cardinal read FPS20MinNumTemps;
    property PS20MaxStaticFlowControlDepth: Cardinal read FPS20MaxStaticFlowControlDepth;
    property PS20MinStaticFlowControlDepth: Cardinal read FPS20MinStaticFlowControlDepth;
    property PS20DynamicFlowControlDepth: Integer read FPS20DynamicFlowControlDepth;
    property PS20NumTemps: Integer read FPS20NumTemps;
    property PS20StaticFlowControlDepth: Integer read FPS20StaticFlowControlDepth;
    property PS20ARBITRARYSWIZLLE: Boolean read FPS20ARBITRARYSWIZLLE;
    property PS20GradientInstructions: Boolean read FPS20GradientInstructions;
    property PS20NoDependentReadLimit: Boolean read FPS20NoDependentReadLimit;
    property PS20NoTexInstructionLimit: Boolean read FPS20NoTexInstructionLimit;
    property PS20NumInstructionSlots: Integer read FPS20NumInstructionSlots;

    property VertexTexFilterMagFPoint: Boolean read FVertexTexFilterMagFPoint;
    property VertexTexFilterMagFLinear: Boolean read FVertexTexFilterMagFLinear;
    property VertexTexFilterMagFAnisotropic: Boolean read FVertexTexFilterMagFAnisotropic;
    property VertexTexFilterMagFPyramidalQuad: Boolean read FVertexTexFilterMagFPyramidalQuad;
    property VertexTexFilterMagFGaussianQuad: Boolean read FVertexTexFilterMagFGaussianQuad;
    property VertexTexFilterMinFPoint: Boolean read FVertexTexFilterMinFPoint;
    property VertexTexFilterMinFLinear: Boolean read FVertexTexFilterMinFLinear;
    property VertexTexFilterMinFAnisotropic: Boolean read FVertexTexFilterMinFAnisotropic;
    property VertexTexFilterMinFPyramidalQuad: Boolean read FVertexTexFilterMinFPyramidalQuad;
    property VertexTexFilterMinFGaussianQuad: Boolean read FVertexTexFilterMinFGaussianQuad;
    property VertexTexFilterMipFPoint: Boolean read FVertexTexFilterMipFPoint;
    property VertexTexFilterMipFLinear: Boolean read FVertexTexFilterMipFLinear;
    
    property MaxVShaderInstructionsExecuted: Cardinal read FMaxVShaderInstructionsExecuted;
    property MaxPShaderInstructionsExecuted: Cardinal read FMaxPShaderInstructionsExecuted;
    property MaxVertexShader30InstructionSlots: Cardinal read FMaxVertexShader30InstructionSlots;
    property MaxPixelShader30InstructionSlots: Cardinal read FMaxPixelShader30InstructionSlots;

    property AdapterDriver: string read FAdapterDriver;
    property AdapterDescription: string read FAdapterDescription;
    property AdapterDeviceName: string read FAdapterDeviceName;
    property AdapterDriverVersion: Int64 read FAdapterDriverVersion;
    property AdapterVendorId: Cardinal read FAdapterVendorId;
    property AdapterDeviceId: Cardinal read FAdapterDeviceId;
    property AdapterSubSysId: Cardinal read FAdapterSubSysId;
    property AdapterRevision: Cardinal read FAdapterRevision;

    property MaxFAA: Integer read FMaxFAA;
  end;

procedure Register;

implementation

{ TDeviceCaps }

constructor TAsphyreDevCaps.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDone := False;
  FDeviceNum := D3DADAPTER_DEFAULT;
  FDeviceType := dtHAL;
  FDevTpe := D3DDEVTYPE_HAL;

  FReset();
  Update();
end;

function TAsphyreDevCaps.FMask(const Src, Value: Cardinal): Boolean;
begin
  Result := ((Src and Value) = Value);
end;

procedure TAsphyreDevCaps.FReset;
begin
  FCapsReadScanLine := False;

  FCaps2CanAutoGenMipMap := False;
  FCaps2CanCalibrateGamma := False;
  FCaps2CanManageResource := False;
  FCaps2DynamicTextures := False;
  FCaps2FulscreenGamma := False;

  FCaps3AlphaFullScreenFlipOrDiscard := False;
  FCaps3CopyToVidMem := False;
  FCaps3CopyToSystemMem := False;
  FCaps3LinearToSRGBPresentation := False;

  FPresentIntervalImmediate := False;
  FPresentIntervalOne := False;
  FPresentIntervalTwo := False;
  FPresentIntervalThree := False;
  FPresentIntervalFour := False;

  FCursorColor := False;
  FCursorLowRes := False;

  FDevCapsCanBltSysToNonLocal := False;
  FDevCapsCanRenderAfterFlip := False;
  FDevCapsDrawPrimitives2 := False;
  FDevCapsDrawPrimitives2Ex := False;
  FDevCapsDrawPrimTLVertex := False;
  FDevCapsExecuteSystemMemory := False;
  FDevCapsExecuteVideoMemory := False;
  FDevCapsHwRasterization := False;
  FDevCapsHwTransformAndLight := False;
  FDevCapsNPatches := False;
  FDevCapsPureDevice := False;
  FDevCapsQuinticRTPatches := False;
  FDevCapsRTPatches := False;
  FDevCapsRTPatchHandleZero := False;
  FDevCapsSeparateTextureMemories := False;
  FDevCapsTextureSystemMemory := False;
  FDevCapsTextureVideoMemory := False;
  FDevCapsTLVertexSystemMemory := False;
  FDevCapsTLVertexVideoMemory := False;

  FPMiscMaskZ := False;
  FPMiscCullNone := False;
  FPMiscCullCW := False;
  FPMiscCullCCW := False;
  FPMiscColorWriteEnable := False;
  FPMiscClipPlaneScalePoints := False;
  FPMiscClipVerts := False;
  FPMiscTSSArgTemp := False;
  FPMiscMiscCapsBlendOp := False;
  FPMiscNullReference := False;
  FPMiscIndependentWriteMasks := False;
  FPMiscPerStageConstant := False;
  FPMiscFogAndSpecularAlpha := False;
  FPMiscSeparateAlphaBlend := False;
  FPMiscMRTIndependentBithDepths := False;
  FPMiscMRTPostPixelShaderBlending := False;
  FPMiscVertexClamped := False;

  FRasterAnisotropy := False;
  FRasterColorPerspective := False;
  FRasterDither := False;
  FRasterDepthBias := False;
  FRasterFogRange := False;
  FRasterFogTable := False;
  FRasterFogVertex := False;
  FRasterMipMapLODBias := False;
  FRasterMultiSampleToggle := False;
  FRasterScissorTest := False;
  FRasterSlopeScaleDepthBias := False;
  FRasterWBuffer := False;
  FRasterWFog := False;
  FRasterZBufferLessHSR := False;
  FRasterZFog := False;
  FRasterZTest := False;

  FZCmpAlways := False;
  FZCmpEqual := False;
  FZCmpGreater := False;
  FZCmpGreaterEqual := False;
  FZCmpLess := False;
  FZCmpLessEqual := False;
  FZCmpNever := False;
  FZCmpNotEqual := False;

  FSrcBlendFactor := False;
  FSrcBlendBothInvSrcAlpha := False;
  FSrcBlendBothSrcAlpha := False;
  FSrcBlendDestAlpha := False;
  FSrcBlendDestColor := False;
  FSrcBlendInvDestAlpha := False;
  FSrcBlendInvDestColor := False;
  FSrcBlendInvSrcAlpha := False;
  FSrcBlendInvSrcColor := False;
  FSrcBlendOne := False;
  FSrcBlendSrcAlpha := False;
  FSrcBlendSrcAlphaSat := False;
  FSrcBlendSrcColor := False;
  FSrcBlendZero := False;

  FDestBlendFactor := False;
  FDestBlendBothInvSrcAlpha := False;
  FDestBlendBothSrcAlpha := False;
  FDestBlendDestAlpha := False;
  FDestBlendDestColor := False;
  FDestBlendInvDestAlpha := False;
  FDestBlendInvDestColor := False;
  FDestBlendInvSrcAlpha := False;
  FDestBlendInvSrcColor := False;
  FDestBlendOne := False;
  FDestBlendSrcAlpha := False;
  FDestBlendSrcAlphaSat := False;
  FDestBlendSrcColor := False;
  FDestBlendZero := False;

  FACmpAlways := False;
  FACmpEqual := False;
  FACmpGreater := False;
  FACmpGreaterEqual := False;
  FACmpLess := False;
  FACmpLessEqual := False;
  FACmpNever := False;
  FACmpNotEqual := False;

  FShadeAlphaGoraudBlend := False;
  FShadeColorGoraudRGB := False;
  FShadeFogGoraud := False;
  FShadeSpecularGoraudRGB := False;

  FTextureAlpha := False;
  FTextureAlphaPallete := False;
  FTextureCubeMap := False;
  FTextureCubeMapPow2 := False;
  FTextureMipCubeMap := False;
  FTextureMipMap := False;
  FTextureMipVolumeMap := False;
  FTextureNonPow2Conditional := False;
  FTextureNoProjectedBumpEnv := False;
  FTexturePerspective := False;
  FTexturePow2 := False;
  FTextureProjected := False;
  FTextureSquareOnly := False;
  FTextureTexRepeatNotScaleBySize := False;
  FTextureVolumeMap := False;
  FTextureVolumeMapPow2 := False;

  FTexFilterMagFPoint := False;
  FTexFilterMagFLinear := False;
  FTexFilterMagFAnisotropic := False;
  FTexFilterMagFPyramidalQuad := False;
  FTexFilterMagFGaussianQuad := False;
  FTexFilterMinFPoint := False;
  FTexFilterMinFLinear := False;
  FTexFilterMinFAnisotropic := False;
  FTexFilterMinFPyramidalQuad := False;
  FTexFilterMinFGaussianQuad := False;
  FTexFilterMipFPoint := False;
  FTexFilterMipFLinear := False;

  FCubeTexFilterMagFPoint := False;
  FCubeTexFilterMagFLinear := False;
  FCubeTexFilterMagFAnisotropic := False;
  FCubeTexFilterMagFPyramidalQuad := False;
  FCubeTexFilterMagFGaussianQuad := False;
  FCubeTexFilterMinFPoint := False;
  FCubeTexFilterMinFLinear := False;
  FCubeTexFilterMinFAnisotropic := False;
  FCubeTexFilterMinFPyramidalQuad := False;
  FCubeTexFilterMinFGaussianQuad := False;
  FCubeTexFilterMipFPoint := False;
  FCubeTexFilterMipFLinear := False;

  FVolumeTexFilterMagFPoint := False;
  FVolumeTexFilterMagFLinear := False;
  FVolumeTexFilterMagFAnisotropic := False;
  FVolumeTexFilterMagFPyramidalQuad := False;
  FVolumeTexFilterMagFGaussianQuad := False;
  FVolumeTexFilterMinFPoint := False;
  FVolumeTexFilterMinFLinear := False;
  FVolumeTexFilterMinFAnisotropic := False;
  FVolumeTexFilterMinFPyramidalQuad := False;
  FVolumeTexFilterMinFGaussianQuad := False;
  FVolumeTexFilterMipFPoint := False;
  FVolumeTexFilterMipFLinear := False;

  FTexAdressBorder := False;
  FTexAdressClamp := False;
  FTexAdressIndependentUV := False;
  FTexAdressMirror := False;
  FTexAdressMirrorOnce := False;
  FTexAdressWrap := False;

  FVolumeTexAdressBorder := False;
  FVolumeTexAdressClamp := False;
  FVolumeTexAdressIndependentUV := False;
  FVolumeTexAdressMirror := False;
  FVolumeTexAdressMirrorOnce := False;
  FVolumeTexAdressWrap := False;

  FLineAlphaCmp := False;
  FLineAntialias := False;
  FLineBlend := False;
  FLineFog := False;
  FLineTexture := False;
  FLineZTest := False;

  FMaxTextureWidth := 0;
  FMaxTextureHeight := 0;
  FMaxVolumeExtent := 0;
  FMaxTextureRepeat := 0;
  FMaxTextureAspectRatio := 0;
  FMaxAnisotropy := 0;
  FMaxVertexW := 0.0;
  FGuardBandLeft := 0.0;
  FGuardBandTop := 0.0;
  FGuardBandRight := 0.0;
  FGuardBandBottom := 0.0;
  FExtentsAdjust := 0.0;

  FStencilKeep := False;
  FStencilZero := False;
  FStencilReplace := False;
  FStencilIncrSat := False;
  FStencilDecrSat := False;
  FStencilInvert := False;
  FStencilIncr := False;
  FStencilDecr := False;
  FStencilTwoSided := False;

  FFVFDoNotStripeElements := False;
  FFVFPSize := False;
  FFVFTexCoordCountMask := 0;

  FTexOpAdd := False;
  FTexOpAddSigned := False;
  FTexOpAddSigned2x := False;
  FTexOpAddSmooth := False;
  FTexOpBlendCurrentAlpha := False;
  FTexOpBlendDiffuseAlpha := False;
  FTexOpBlendFactorAlpha := False;
  FTexOpBlendTextureAlpha := False;
  FTexOpBlendTextureAlphaPm := False;
  FTexOpBumpEnvMap := False;
  FTexOpBumpEnvMapLuminance := False;
  FTexOpDisable := False;
  FTexOpDOTProduct3 := False;
  FTexOpLERP := False;
  FTexOpModulate := False;
  FTexOpModulate2x := False;
  FTexOpModulate4x := False;
  FTexOpModulateAlphaAddColor := False;
  FTexOpModulateColorAddAlpha := False;
  FTexOpModulateInvAlphaAddColor := False;
  FTexOpModulateInvColorAddAlpha := False;
  FTexOpMultiplyAdd := False;
  FTexOpPreModulate := False;
  FTexOpSelectARG1 := False;
  FTexOpSelectARG2 := False;
  FTexOpSubstract := False;

  FMaxTextureBlendStages := 0;
  FMaxSimultaneousTextures := 0;

  FVtxPDirectonalLights := False;
  FVtxPLocalViewer := False;
  FVtxPMaterialSoure7 := False;
  FVtxPNoTexGenNonLocalViewer := False;
  FVtxPPositionalLights := False;
  FVtxPTexGen := False;
  FVtxPTexGenSphereMap := False;
  FVtxPTweening := False;

  FMaxActiveLights := 0;
  FMaxUserClipPlanes := 0;
  FMaxVertexBlendMatrices := 0;
  FMaxVertexBlendMatrixIndex := 0;
  FMaxPointSize := 0.0;
  FMaxPrimitiveCount := 0;
  FMaxVertexIndex := 0;
  FMaxStreams := 0;
  FMaxStreamStride := 0;

  FVertexShaderVersion := '0.0';
  FMaxVertexShaderConst := 0;
  FPixelShaderVersion := '0.0';
  FPixelShader1xMaxValue := 0.0;

  FDevCaps2AdaptiveTessRTPatch := False;
  FDevCaps2AdaptiveTessNPatch := False;
  FDevCaps2CanStretchRectFromTextures := False;
  FDevCaps2DMapNPatch := False;
  FDevCaps2PresampledDMapNPatch := False;
  FDevCaps2StreamOffset := False;
  FDevCaps2VertexElemtsCanShareStreamOffset := False;

  FMaxNPatchTessellationLevel := 0.0;
//  FMinAntialiasedLineWidth := 0.0;
//  FMaxAntialiasedLineWidth := 1.0;
  FMasterAdapterOrdinal := 0;
  FAdapterOrdinalInGroup := 0;
  FNumberOfAdaptersInGroup := 0;

  FDTUByte4 := False;
  FDTUByte4N := False;
  FDTShort2N := False;
  FDTShort4N := False;
  FDTUShort2N := False;
  FDTUShort4N := False;
  FDTUDec3 := False;
  FDTDec3N := False;
  FDT2DFloat16 := False;
  FDT4DFloat16 := False;

  FNumSimultaneousRTs := 0;

  FSRectMinFPoint := False;
  FSRectMagFPoint := False;
  FSRectMinFLinear := False;
  FSRectMagFLinear := False;

  FVS20Predication := False;
  FVS20MaxDynamicFlowControlDepth := 0;
  FVS20MinDynamicFlowControlDepth := 0;
  FVS20MaxNumTemps := 0;
  FVS20MinNumTemps := 0;
  FVS20MaxStaticFlowControlDepth := 0;
  FVS20MinStaticFlowControlDepth := 0;
  FVS20DynamicFlowControlDepth := 0;
  FVS20NumTemps := 0;
  FVS20StaticFlowControlDepth := 0;

  FPS20Predication := False;
  FPS20MaxDynamicFlowControlDepth := 0;
  FPS20MinDynamicFlowControlDepth := 0;
  FPS20MaxNumTemps := 0;
  FPS20MinNumTemps := 0;
  FPS20MaxStaticFlowControlDepth := 0;
  FPS20MinStaticFlowControlDepth := 0;
  FPS20DynamicFlowControlDepth := 0;
  FPS20NumTemps := 0;
  FPS20StaticFlowControlDepth := 0;
  FPS20ARBITRARYSWIZLLE := False;
  FPS20GradientInstructions := False;
  FPS20NoDependentReadLimit := False;
  FPS20NoTexInstructionLimit := False;
  FPS20NumInstructionSlots := 0;

  FVertexTexFilterMagFPoint := False;
  FVertexTexFilterMagFLinear := False;
  FVertexTexFilterMagFAnisotropic := False;
  FVertexTexFilterMagFPyramidalQuad := False;
  FVertexTexFilterMagFGaussianQuad := False;
  FVertexTexFilterMinFPoint := False;
  FVertexTexFilterMinFLinear := False;
  FVertexTexFilterMinFAnisotropic := False;
  FVertexTexFilterMinFPyramidalQuad := False;
  FVertexTexFilterMinFGaussianQuad := False;
  FVertexTexFilterMipFPoint := False;
  FVertexTexFilterMipFLinear := False;
  
  FMaxVShaderInstructionsExecuted := 0;
  FMaxPShaderInstructionsExecuted := 0;
  FMaxVertexShader30InstructionSlots := 0;
  FMaxPixelShader30InstructionSlots := 0;

  FAdapterDriver := '';
  FAdapterDescription := '';
  FAdapterDeviceName := '';
  FAdapterDriverVersion := 0;
  FAdapterVendorId := 0;
  FAdapterDeviceId := 0;
  FAdapterSubSysId := 0;
  FAdapterRevision := 0;

  FMaxFAA := -1;
end;

procedure TAsphyreDevCaps.FSetDevNum(const Value: Cardinal);
begin
  FDeviceNum := Value;
  FReset();
  Update();
end;

procedure TAsphyreDevCaps.FSetDevType(const Value: TaDevType);
begin
  FDeviceType := Value;

  case (FDeviceType) of
    dtHAL: FDevTpe := D3DDEVTYPE_HAL;
    dtNullRef: FDevTpe := D3DDEVTYPE_NULLREF;
    dtRef: FDevTpe := D3DDEVTYPE_REF;
    dtSw: FDevTpe := D3DDEVTYPE_SW;
  end;

  FReset();
  Update();
end;

function TAsphyreDevCaps.SaveToHTML(const FileName: TFileName): Boolean;
var
  Cnt: Integer;
  SL: TStringList;

  procedure AddRow(const C1, C2: string); overload;
  begin
    SL.Add(Format('<tr><td>%s</td><td>%s</td></tr>', [C1, C2]));
    Inc(Cnt);
  end;

  procedure AddRow(const C1: string; const C2: Integer); overload;
  begin
    SL.Add(Format('<tr><td>%s</td><td>%d</td></tr>', [C1, C2]));
    Inc(Cnt);
  end;

  procedure AddRow(const C1: string; const C2: Cardinal); overload;
  begin
    SL.Add(Format('<tr><td>%s</td><td>%d</td></tr>', [C1, C2]));
    Inc(Cnt);
  end;

  procedure AddRow(const C1: string; const C2: Single); overload;
  begin
    SL.Add(Format('<tr><td>%s</td><td>%f</td></tr>', [C1, C2]));
    Inc(Cnt);
  end;

  procedure AddRow(const C1: string; const C2: Boolean); overload;
  var
    tC2: string;
  begin
    if (C2) then
      tC2 := 'True'
    else
      tC2 := 'False';

    SL.Add(Format('<tr><td>%s</td><td>%s</td></tr>', [C1, tC2]));
    Inc(Cnt);
  end;

begin
  Cnt := -3;
  Result := False;
  
  SL := TStringList.Create();


  SL.Add('<html>');
  SL.Add('<head>');
  SL.Add('<title>' + FAdapterDescription + '</title>');
  SL.Add('<style type="text/css">');

  SL.Add('td {width: 250px; text-align: left; font-family: tahoma; font-size: 12px}');
  SL.Add('th {width: 250px; text-align: left; font-family: tahoma; font-size: 12px}');
  SL.Add('.d {font-size: 11px}');
  SL.Add('body {font-family: tahoma; font-size: 12px}');

  SL.Add('</style>');
  SL.Add('</head>');
  SL.Add('<body>');

  SL.Add('<h2><u>' + FAdapterDescription + ' capabilities</u></h2>');

  SL.Add('<table border="1">');

  SL.Add('<tr><th>Name</th><th>Value</th></tr>');

  AddRow('Done', FDone);
  AddRow('DeviceNum', FDeviceNum);
  case (FDeviceType) of
    dtHAL: AddRow('DeviceType', 'HAL');
    dtNullRef: AddRow('DeviceType', 'NullRef');
    dtRef: AddRow('DeviceType', 'Ref');
    dtSw: AddRow('DeviceType', 'Sw');
  end;

  SL.Add('<tr><td>&nbsp;</td><td>&nbsp;</td></tr>');

  AddRow('CapsReadScanLine', FCapsReadScanLine);

  AddRow('Caps2CanAutoGenMipMap', FCaps2CanAutoGenMipMap);
  AddRow('Caps2CanCalibrateGamma', FCaps2CanCalibrateGamma);
  AddRow('Caps2CanManageResource', FCaps2CanManageResource);
  AddRow('Caps2DynamicTextures', FCaps2DynamicTextures);
  AddRow('Caps2FulscreenGamma', FCaps2FulscreenGamma);

  AddRow('Caps3AlphaFullScreenFliOrDiscard', FCaps3AlphaFullScreenFlipOrDiscard);
  AddRow('Caps3CopyToVidMem', FCaps3CopyToVidMem);
  AddRow('Caps3CopyToSystemMem', FCaps3CopyToSystemMem);
  AddRow('Caps3LinearToSRGBPresentation', FCaps3LinearToSRGBPresentation);

  AddRow('PresentIntervalImmediate', FPresentIntervalImmediate);
  AddRow('PresentIntervalOne', FPresentIntervalOne);
  AddRow('PresentIntervalTwo', FPresentIntervalTwo);
  AddRow('PresentIntervalThree', FPresentIntervalThree);
  AddRow('PresentIntervalFour', FPresentIntervalFour);

  AddRow('CursorColor', FCursorColor);
  AddRow('CursorLowRes', FCursorLowRes);

  AddRow('DevCapsCanBltSysToNonLocal', FDevCapsCanBltSysToNonLocal);
  AddRow('DevCapsCanRenderAfterFlip', FDevCapsCanRenderAfterFlip);
  AddRow('DevCapsDrawPrimitives2', FDevCapsDrawPrimitives2);
  AddRow('DevCapsDrawPrimitives2Ex', FDevCapsDrawPrimitives2Ex);
  AddRow('DevCapsDrawPrimTLVertex', FDevCapsDrawPrimTLVertex);
  AddRow('DevCapsExecuteSystemMemory', FDevCapsExecuteSystemMemory);
  AddRow('DevCapsExecuteVideoMemory', FDevCapsExecuteVideoMemory);
  AddRow('DevCapsHwRasterization', FDevCapsHwRasterization);
  AddRow('DevCapsHwTransformAndLight', FDevCapsHwTransformAndLight);
  AddRow('DevCapsNPatches', FDevCapsNPatches);
  AddRow('DevCapsPureDevice', FDevCapsPureDevice);
  AddRow('DevCapsQuinticRTPatches', FDevCapsQuinticRTPatches);
  AddRow('DevCapsRTPatches', FDevCapsRTPatches);
  AddRow('DevCapsRTPatchHandleZero', FDevCapsRTPatchHandleZero);
  AddRow('DevCapsSeparateTextureMemories', FDevCapsSeparateTextureMemories);
  AddRow('DevCapsTextureSystemMemory', FDevCapsTextureSystemMemory);
  AddRow('DevCapsTextureVideoMemory', FDevCapsTextureVideoMemory);
  AddRow('DevCapsTLVertexSystemMemory', FDevCapsTLVertexSystemMemory);
  AddRow('DevCapsTLVertexVideoMemory', FDevCapsTLVertexVideoMemory);

  AddRow('MiscMaskZ', FPMiscMaskZ);
  AddRow('MiscCullNone', FPMiscCullNone);
  AddRow('MiscCullCW', FPMiscCullCW);
  AddRow('MiscCullCCW', FPMiscCullCCW);
  AddRow('MiscColorWriteEnable', FPMiscColorWriteEnable);
  AddRow('MiscClipPlaneScalePoints', FPMiscClipPlaneScalePoints);
  AddRow('MiscClipVerts', FPMiscClipVerts);
  AddRow('MiscTSSArgTemp', FPMiscTSSArgTemp);
  AddRow('MiscBlendOp', FPMiscMiscCapsBlendOp);
  AddRow('MiscNullReference', FPMiscNullReference);
  AddRow('MiscIndependentWriteMasks', FPMiscIndependentWriteMasks);
  AddRow('MiscPerStageConstant', FPMiscPerStageConstant);
  AddRow('MiscFogAndSpecularAlpha', FPMiscFogAndSpecularAlpha);
  AddRow('MiscSeparateAlphaBlend', FPMiscSeparateAlphaBlend);
  AddRow('MiscMRTIndependentBithDepths', FPMiscMRTIndependentBithDepths);
  AddRow('MiscMRTPostPixelShaderBlending', FPMiscMRTPostPixelShaderBlending);
  AddRow('MiscFogVertexClamped', FPMiscVertexClamped);

  AddRow('RasterAnisotropy', FRasterAnisotropy);
  AddRow('RasterColorPerspective', FRasterColorPerspective);
  AddRow('RasterDither', FRasterDither);
  AddRow('RasterDepthBias', FRasterDepthBias);
  AddRow('RasterFogRange', FRasterFogRange);
  AddRow('RasterFogTable', FRasterFogTable);
  AddRow('RasterFogVertex', FRasterFogVertex);
  AddRow('RasterMipMapLODBias', FRasterMipMapLODBias);
  AddRow('RasterMultiSampleToggle', FRasterMultiSampleToggle);
  AddRow('RasterScissorTest', FRasterScissorTest);
  AddRow('RasterSlopeScaleDepthBias', FRasterSlopeScaleDepthBias);
  AddRow('RasterWBuffer', FRasterWBuffer);
  AddRow('RasterWFog', FRasterWFog);
  AddRow('RasterZBufferLessHSR', FRasterZBufferLessHSR);
  AddRow('RasterZFog', FRasterZFog);
  AddRow('RasterZTest', FRasterZTest);

  AddRow('ZCmpAlways', FZCmpAlways);
  AddRow('ZCmpEqual', FZCmpEqual);
  AddRow('ZCmpGreater', FZCmpGreater);
  AddRow('ZCmpGreaterEqual', FZCmpGreaterEqual);
  AddRow('ZCmpLess', FZCmpLess);
  AddRow('ZCmpLessEqual', FZCmpLessEqual);
  AddRow('ZCmpNever', FZCmpNever);
  AddRow('ZCmpNotEqual', FZCmpNotEqual);

  AddRow('SrcBlendFactor', FSrcBlendFactor);
  AddRow('SrcBlendBothInvSrcAlpha', FSrcBlendBothInvSrcAlpha);
  AddRow('SrcBlendBothSrcAlpha', FSrcBlendBothSrcAlpha);
  AddRow('SrcBlendDestAlpha', FSrcBlendDestAlpha);
  AddRow('SrcBlendDestColor', FSrcBlendDestColor);
  AddRow('SrcBlendInvDestAlpha', FSrcBlendInvDestAlpha);
  AddRow('SrcBlendInvDestColor', FSrcBlendInvDestColor);
  AddRow('SrcBlendInvSrcAlpha', FSrcBlendInvSrcAlpha);
  AddRow('SrcBlendInvSrcColor', FSrcBlendInvSrcColor);
  AddRow('SrcBlendOne', FSrcBlendOne);
  AddRow('SrcBlendSrcAlpha', FSrcBlendSrcAlpha);
  AddRow('SrcBlendSrcAlphaSat', FSrcBlendSrcAlphaSat);
  AddRow('SrcBlendSrcColor', FSrcBlendSrcColor);
  AddRow('SrcBlendZero', FSrcBlendZero);

  AddRow('DestBlendFactor', FDestBlendFactor);
  AddRow('DestBlendBothInvSrcAlpha', FDestBlendBothInvSrcAlpha);
  AddRow('DestBlendBothSrcAlpha', FDestBlendBothSrcAlpha);
  AddRow('DestBlendDestAlpha', FDestBlendDestAlpha);
  AddRow('DestBlendDestColor', FDestBlendDestColor);
  AddRow('DestBlendInvDestAlpha', FDestBlendInvDestAlpha);
  AddRow('DestBlendInvDestColor', FDestBlendInvDestColor);
  AddRow('DestBlendInvSrcAlpha', FDestBlendInvSrcAlpha);
  AddRow('DestBlendInvSrcColor', FDestBlendInvSrcColor);
  AddRow('DestBlendOne', FDestBlendOne);
  AddRow('DestBlendSrcAlpha', FDestBlendSrcAlpha);
  AddRow('DestBlendSrcAlphaSat', FDestBlendSrcAlphaSat);
  AddRow('DestBlendSrcColor', FDestBlendSrcColor);
  AddRow('DestBlendZero', FDestBlendZero);

  AddRow('ACmpAlways', FACmpAlways);
  AddRow('ACmpEqual', FACmpEqual);
  AddRow('ACmpGreater', FACmpGreater);
  AddRow('ACmpGreaterEqual', FACmpGreaterEqual);
  AddRow('ACmpLess', FACmpLess);
  AddRow('ACmpLessEqual', FACmpLessEqual);
  AddRow('ACmpNever', FACmpNever);
  AddRow('ACmpNotEqual', FACmpNotEqual);

  AddRow('ShadeAlphaGoraudBlend', FShadeAlphaGoraudBlend);
  AddRow('ShadeColorGoraudRGB', FShadeColorGoraudRGB);
  AddRow('ShadeFogGoraud', FShadeFogGoraud);
  AddRow('ShadeSpecularGoraudRGB', FShadeSpecularGoraudRGB);

  AddRow('TextureAlpha', FTextureAlpha);
  AddRow('TextureAlphaPallete', FTextureAlphaPallete);
  AddRow('TextureCubeMap', FTextureCubeMap);
  AddRow('TextureCubeMapPow2', FTextureCubeMapPow2);
  AddRow('TextureMipCubeMap', FTextureMipCubeMap);
  AddRow('TextureMipMap', FTextureMipMap);
  AddRow('TextureMipVolumeMap', FTextureMipVolumeMap);
  AddRow('TextureNonPow2Conditional', FTextureNonPow2Conditional);
  AddRow('TextureNoProjectedBumpEnv', FTextureNoProjectedBumpEnv);
  AddRow('TexturePerspective', FTexturePerspective);
  AddRow('TexturePow2', FTexturePow2);
  AddRow('TextureProjected', FTextureProjected);
  AddRow('TextureSquareOnly', FTextureSquareOnly);
  AddRow('TextureTexRepeatNotScaleBySize', FTextureTexRepeatNotScaleBySize);
  AddRow('TextureVolumeMap', FTextureVolumeMap);
  AddRow('TextureVolumeMapPow2', FTextureVolumeMapPow2);

  AddRow('TexFilterMagFPoint', FTexFilterMagFPoint);
  AddRow('TexFilterMagFLinear', FTexFilterMagFLinear);
  AddRow('TexFilterMagFAnisotropic', FTexFilterMagFAnisotropic);
  AddRow('TexFilterMagFPyramidalQuad', FTexFilterMagFPyramidalQuad);
  AddRow('TexFilterMagFGaussianQuad', FTexFilterMagFGaussianQuad);
  AddRow('TexFilterMinFPoint', FTexFilterMinFPoint);
  AddRow('TexFilterMinFLinear', FTexFilterMinFLinear);
  AddRow('TexFilterMinFAnisotropic', FTexFilterMinFAnisotropic);
  AddRow('TexFilterMinFPyramidalQuad', FTexFilterMinFPyramidalQuad);
  AddRow('TexFilterMinFGaussianQuad', FTexFilterMinFGaussianQuad);
  AddRow('TexFilterMipFPoint', FTexFilterMipFPoint);
  AddRow('TexFilterMipFLinear', FTexFilterMipFLinear);

  AddRow('CubeTexFilterMagFPoint', FCubeTexFilterMagFPoint);
  AddRow('CubeTexFilterMagFLinear', FCubeTexFilterMagFLinear);
  AddRow('CubeTexFilterMagFAnisotropic', FCubeTexFilterMagFAnisotropic);
  AddRow('CubeTexFilterMagFPyramidalQuad', FCubeTexFilterMagFPyramidalQuad);
  AddRow('CubeTexFilterMagFGaussianQuad', FCubeTexFilterMagFGaussianQuad);
  AddRow('CubeTexFilterMinFPoint', FCubeTexFilterMinFPoint);
  AddRow('CubeTexFilterMinFLinear', FCubeTexFilterMinFLinear);
  AddRow('CubeTexFilterMinFAnisotropic', FCubeTexFilterMinFAnisotropic);
  AddRow('CubeTexFilterMinFPyramidalQuad', FCubeTexFilterMinFPyramidalQuad);
  AddRow('CubeTexFilterMinFGaussianQuad', FCubeTexFilterMinFGaussianQuad);
  AddRow('CubeTexFilterMipFPoint', FCubeTexFilterMipFPoint);
  AddRow('CubeTexFilterMipFLinear', FCubeTexFilterMipFLinear);

  AddRow('VolumeTexFilterMagFPoint', FVolumeTexFilterMagFPoint);
  AddRow('VolumeTexFilterMagFLinear', FVolumeTexFilterMagFLinear);
  AddRow('VolumeTexFilterMagFAnisotropic', FVolumeTexFilterMagFAnisotropic);
  AddRow('VolumeTexFilterMagFPyramidalQuad', FVolumeTexFilterMagFPyramidalQuad);
  AddRow('VolumeTexFilterMagFGaussianQuad', FVolumeTexFilterMagFGaussianQuad);
  AddRow('VolumeTexFilterMinFPoint', FVolumeTexFilterMinFPoint);
  AddRow('VolumeTexFilterMinFLinear', FVolumeTexFilterMinFLinear);
  AddRow('VolumeTexFilterMinFAnisotropic', FVolumeTexFilterMinFAnisotropic);
  AddRow('VolumeTexFilterMinFPyramidalQuad', FVolumeTexFilterMinFPyramidalQuad);
  AddRow('VolumeTexFilterMinFGaussianQuad', FVolumeTexFilterMinFGaussianQuad);
  AddRow('VolumeTexFilterMipFPoint', FVolumeTexFilterMipFPoint);
  AddRow('VolumeTexFilterMipFLinear', FVolumeTexFilterMipFLinear);

  AddRow('TexAdressCapsBorder', FTexAdressBorder);
  AddRow('TexAdressCapsClamp', FTexAdressClamp);
  AddRow('TexAdressCapsIndependentUV', FTexAdressIndependentUV);
  AddRow('TexAdressCapsMirror', FTexAdressMirror);
  AddRow('TexAdressCapsMirrorOnce', FTexAdressMirrorOnce);
  AddRow('TexAdressCapsWrap', FTexAdressWrap);

  AddRow('VolumeTexAdressCapsBorder', FVolumeTexAdressBorder);
  AddRow('VolumeTexAdressCapsClamp', FVolumeTexAdressClamp);
  AddRow('VolumeTexAdressCapsIndependentUV', FVolumeTexAdressIndependentUV);
  AddRow('VolumeTexAdressCapsMirror', FVolumeTexAdressMirror);
  AddRow('VolumeTexAdressCapsMirrorOnce', FVolumeTexAdressMirrorOnce);
  AddRow('VolumeTexAdressCapsWrap', FVolumeTexAdressWrap);

  AddRow('LineAlphaCmp', FLineAlphaCmp);
  AddRow('LineAntialias', FLineAntialias);
  AddRow('LineBlend', FLineBlend);
  AddRow('LineFog', FLineFog);
  AddRow('LineTexture', FLineTexture);
  AddRow('LineZTest', FLineZTest);

  AddRow('MaxTextureWidth', FMaxTextureWidth);
  AddRow('MaxTextureHeight', FMaxTextureHeight);
  AddRow('MaxVolumeExtent', FMaxVolumeExtent);
  AddRow('MaxTextureRepeat', FMaxTextureRepeat);
  AddRow('MaxTextureAspectRatio', FMaxTextureAspectRatio);
  AddRow('MaxAnisotropy', FMaxAnisotropy);
  AddRow('MaxVertexW', FMaxVertexW);
  AddRow('GuardBandLeft', FGuardBandLeft);
  AddRow('GuardBandTop', FGuardBandTop);
  AddRow('GuardBandRight', FGuardBandRight);
  AddRow('GuardBandBottom', FGuardBandBottom);
  AddRow('ExtentAdjust', FExtentsAdjust);

  AddRow('StencilKeep', FStencilKeep);
  AddRow('StencilZero', FStencilZero);
  AddRow('StencilReplace', FStencilReplace);
  AddRow('StencilIncrSat', FStencilIncrSat);
  AddRow('StencilDecrSat', FStencilDecrSat);
  AddRow('StencilInvert', FStencilInvert);
  AddRow('StencilIncr', FStencilIncr);
  AddRow('StencilDecr', FStencilDecr);
  AddRow('StencilTwoSided', FStencilTwoSided);

  AddRow('FVFDoNotStripeElements', FFVFDoNotStripeElements);
  AddRow('FVFPSize', FFVFPSize);
  AddRow('FVFTexCoordCountMask', FFVFTexCoordCountMask);

  AddRow('TexOpAdd', FTexOpAdd);
  AddRow('TexOpAddSigned', FTexOpAddSigned);
  AddRow('TexOpAddSigned2x', FTexOpAddSigned2x);
  AddRow('TexOpAddSmooth', FTexOpAddSmooth);
  AddRow('TexOpBlendCurrentAlpha', FTexOpBlendCurrentAlpha);
  AddRow('TexOpBlendDiffuseAlpha', FTexOpBlendDiffuseAlpha);
  AddRow('TexOpBlendFactorAlpha', FTexOpBlendFactorAlpha);
  AddRow('TexOpBlendTextureAlpha', FTexOpBlendTextureAlpha);
  AddRow('TexOpBlendTextureAlphaPm', FTexOpBlendTextureAlphaPm);
  AddRow('TexOpBumpEnvMap', FTexOpBumpEnvMap);
  AddRow('TexOpBumpEnvMapLuminance', FTexOpBumpEnvMapLuminance);
  AddRow('TexOpDisable', FTexOpDisable);
  AddRow('TexOpDOTProduct3', FTexOpDOTProduct3);
  AddRow('TexOpLERP', FTexOpLERP);
  AddRow('TexOpModulate', FTexOpModulate);
  AddRow('TexOpModulate2x', FTexOpModulate2x);
  AddRow('TexOpModulate4x', FTexOpModulate4x);
  AddRow('TexOpModulateAlphaAddColor', FTexOpModulateAlphaAddColor);
  AddRow('TexOpModulateColorAddAlpha', FTexOpModulateColorAddAlpha);
  AddRow('TexOpModulateInvAlphaAddColor', FTexOpModulateInvAlphaAddColor);
  AddRow('TexOpModulateInvColorAddAlpha', FTexOpModulateInvColorAddAlpha);
  AddRow('TexOpMultiplyAdd', FTexOpMultiplyAdd);
  AddRow('TexOpPreModulate', FTexOpPreModulate);
  AddRow('TexOpSelectARG1', FTexOpSelectARG1);
  AddRow('TexOpSelectARG2', FTexOpSelectARG2);
  AddRow('TexOpSubstract', FTexOpSubstract);

  AddRow('MaxTextureBlendStages', FMaxTextureBlendStages);
  AddRow('MaxSimultaneousTextures', FMaxSimultaneousTextures);

  AddRow('VtxPDirectonalLights', FVtxPDirectonalLights);
  AddRow('VtxPLocalViewer', FVtxPLocalViewer);
  AddRow('VtxPMaterialSoure7', FVtxPMaterialSoure7);
  AddRow('VtxPNoTexGenNonLocalViewer', FVtxPNoTexGenNonLocalViewer);
  AddRow('VtxPPositionalLights', FVtxPPositionalLights);
  AddRow('VtxPTexGen', FVtxPTexGen);
  AddRow('VtxPTexGenSphereMap', FVtxPTexGenSphereMap);
  AddRow('VtxPTweening', FVtxPTweening);

  AddRow('MaxActiveLights', FMaxActiveLights);
  AddRow('MaxUserClipPlanes', FMaxUserClipPlanes);
  AddRow('MaxVertexBlendMatrices', FMaxVertexBlendMatrices);
  AddRow('MaxVertexBlendMatrixIndex', FMaxVertexBlendMatrixIndex);
  AddRow('MaxPointSize', FMaxPointSize);
  AddRow('MaxPrimitiveCount', FMaxPrimitiveCount);
  AddRow('MaxVertexIndex', FMaxVertexIndex);
  AddRow('MaxStreams', FMaxStreams);
  AddRow('MaxStreamStride', FMaxStreamStride);

  AddRow('VertexShaderVersion', FVertexShaderVersion);
  AddRow('MaxVertexShaderConst', FMaxVertexShaderConst);
  AddRow('PixelShaderVersion', FPixelShaderVersion);
  AddRow('PixelShader1xMaxValue', FPixelShader1xMaxValue);

  AddRow('DevCaps2AdaptiveTessRTPatch', FDevCaps2AdaptiveTessRTPatch);
  AddRow('DevCaps2AdaptiveTessNPatch', FDevCaps2AdaptiveTessNPatch);
  AddRow('DevCaps2CanStretchRectFromTextures', FDevCaps2CanStretchRectFromTextures);
  AddRow('DevCaps2DMapNPatch', FDevCaps2DMapNPatch);
  AddRow('DevCaps2PresampledDMapNPatch', FDevCaps2PresampledDMapNPatch);
  AddRow('DevCaps2StreamOffset', FDevCaps2StreamOffset);
  AddRow('DevCaps2VertexElemtsCanShareStreamOffset', FDevCaps2VertexElemtsCanShareStreamOffset);

  AddRow('MaxNPatchTessellationLevel', FMaxNPatchTessellationLevel);
  AddRow('MasterAdapterOrdinal', FMasterAdapterOrdinal);
  AddRow('AdapterOrdinalInGroup', FAdapterOrdinalInGroup);
  AddRow('NumberOfAdaptersInGroup', FNumberOfAdaptersInGroup);

  AddRow('DTUByte4', FDTUByte4);
  AddRow('DTUByte4N', FDTUByte4N);
  AddRow('DTShort2N', FDTShort2N);
  AddRow('DTShort4N', FDTShort4N);
  AddRow('DTUShort2N', FDTUShort2N);
  AddRow('DTUShort4N', FDTUShort4N);
  AddRow('DTUDec3', FDTUDec3);
  AddRow('DTDec3N', FDTDec3N);
  AddRow('DT2DFloat16', FDT2DFloat16);
  AddRow('DT4DFloat16', FDT4DFloat16);

  AddRow('NumSimultaneousRTs', FNumSimultaneousRTs);

  AddRow('SRectMinFPoint', FSRectMinFPoint);
  AddRow('SRectMagFPoint', FSRectMagFPoint);
  AddRow('SRectMinFLinear', FSRectMinFLinear);
  AddRow('SRectMagFLinear', FSRectMagFLinear);

  AddRow('VS20Predication', FVS20Predication);
  AddRow('VS20MaxDynamicFlowControlDepth', FVS20MaxDynamicFlowControlDepth);
  AddRow('VS20MinDynamicFlowControlDepth', FVS20MinDynamicFlowControlDepth);
  AddRow('VS20MaxNumTemps', FVS20MaxNumTemps);
  AddRow('VS20MinNumTemps', FVS20MinNumTemps);
  AddRow('VS20MaxStaticFlowControlDepth', FVS20MaxStaticFlowControlDepth);
  AddRow('VS20MinStaticFlowControlDepth', FVS20MinStaticFlowControlDepth);
  AddRow('VS20DynamicFlowControlDepth', FVS20DynamicFlowControlDepth);
  AddRow('VS20NumTemps', FVS20NumTemps);
  AddRow('VS20StaticFlowControlDepth', FVS20StaticFlowControlDepth);

  AddRow('PS20Predication', FPS20Predication);
  AddRow('PS20MaxDynamicFlowControlDepth', FPS20MaxDynamicFlowControlDepth);
  AddRow('PS20MinDynamicFlowControlDepth', FPS20MinDynamicFlowControlDepth);
  AddRow('PS20MaxNumTemps', FPS20MaxNumTemps);
  AddRow('PS20MinNumTemps', FPS20MinNumTemps);
  AddRow('PS20MaxStaticFlowControlDepth', FPS20MaxStaticFlowControlDepth);
  AddRow('PS20MinStaticFlowControlDepth', FPS20MinStaticFlowControlDepth);
  AddRow('PS20DynamicFlowControlDepth', FPS20DynamicFlowControlDepth);
  AddRow('PS20NumTemps', FPS20NumTemps);
  AddRow('PS20StaticFlowControlDepth', FPS20StaticFlowControlDepth);
  AddRow('PS20ARBITRARYSWIZLLE', FPS20ARBITRARYSWIZLLE);
  AddRow('PS20GradientInstructions', FPS20GradientInstructions);
  AddRow('PS20NoDependentReadLimit', FPS20NoDependentReadLimit);
  AddRow('PS20NoTexInstructionLimit', FPS20NoTexInstructionLimit);
  AddRow('PS20NumInstructionSlots', FPS20NumInstructionSlots);

  AddRow('VertexTexFilterMagFPoint', FVertexTexFilterMagFPoint);
  AddRow('VertexTexFilterMagFLinear', FVertexTexFilterMagFLinear);
  AddRow('VertexTexFilterMagFAnisotropic', FVertexTexFilterMagFAnisotropic);
  AddRow('VertexTexFilterMagFPyramidalQuad', FVertexTexFilterMagFPyramidalQuad);
  AddRow('VertexTexFilterMagFGaussianQuad', FVertexTexFilterMagFGaussianQuad);
  AddRow('VertexTexFilterMinFPoint', FVertexTexFilterMinFPoint);
  AddRow('VertexTexFilterMinFLinear', FVertexTexFilterMinFLinear);
  AddRow('VertexTexFilterMinFAnisotropic', FVertexTexFilterMinFAnisotropic);
  AddRow('VertexTexFilterMinFPyramidalQuad', FVertexTexFilterMinFPyramidalQuad);
  AddRow('VertexTexFilterMinFGaussianQuad', FVertexTexFilterMinFGaussianQuad);
  AddRow('VertexTexFilterMipFPoint', FVertexTexFilterMipFPoint);
  AddRow('VertexTexFilterMipFLinear', FVertexTexFilterMipFLinear);

  AddRow('MaxVShaderInstructionsExecuted', FMaxVShaderInstructionsExecuted);
  AddRow('MaxPShaderInstructionsExecuted', FMaxPShaderInstructionsExecuted);
  AddRow('MaxVertexShader30InstructionSlots', FMaxVertexShader30InstructionSlots);
  AddRow('MaxPixelShader30InstructionSlots', FMaxPixelShader30InstructionSlots);

  AddRow('AdapterDriver', FAdapterDriver);
  AddRow('AdapterDescription', FAdapterDescription);
  AddRow('AdapterDeviceName', FAdapterDeviceName);
  AddRow('AdapterDriverVersion', FAdapterDriverVersion);
  AddRow('AdapterVendorId', FAdapterVendorId);
  AddRow('AdapterDeviceId', FAdapterDeviceId);
  AddRow('AdapterSubSysId', FAdapterSubSysId);
  AddRow('AdapterRevision', FAdapterRevision);

  AddRow('MaxFAA', FMaxFAA);

  SL.Add('</table><br />');

  SL.Add(Format('<b>%d</b> count of capabilities', [Cnt]));

  SL.Add('<hr>');
  SL.Add('<center>');
  SL.Add(Format('<div class="d">TAsphyreDevCaps %s by Cervajz</div>',
    [sCmpVer]));
  SL.Add('<div class="d"><a href="http://www.cervajz.profitux.cz">http://www.cervajz.profitux.cz</a></div>');
  SL.Add('<div class="d"><a href="mailto:jara.cervenka@seznam.cz">jara.cervenka@seznam.cz</a></div>');
  SL.Add('<div class="d"><a href="http://www.afterwarp.net">http://www.afterwarp.net</a></div>');
  SL.Add('</center>');

  SL.Add('</body>');
  SL.Add('</html>');

  try
    SL.SaveToFile(FileName);
  except
    SL.Clear();
    FreeAndNil(SL);
    Exit;
  end;

  SL.Clear();
  FreeAndNil(SL);

  Result := True;
end;

function TAsphyreDevCaps.Update(): Boolean;
var
  X: Integer;
  Res: HRESULT;
  Caps: _D3DCAPS9;
  D3D9: IDirect3D9;
  SFormat: _D3DFORMAT;
  DMode: _D3DDISPLAYMODE;
  AdapterIdent: _D3DADAPTER_IDENTIFIER9;
begin
  Result := False;
  FDone := False;

  D3D9 := Direct3DCreate9(D3D_SDK_VERSION);
  if (D3D9 = nil) then
    Exit;

  Res := D3D9.GetDeviceCaps(FDeviceNum, FDevTpe, Caps);
  if (Res <> D3D_OK) then begin
    D3D9 := nil;
    Exit;
  end;

  FCapsReadScanLine := FMask(Caps.Caps, D3DCAPS_READ_SCANLINE);

  FCaps2CanAutoGenMipMap := FMask(Caps.Caps2, D3DCAPS2_CANAUTOGENMIPMAP);
  FCaps2CanCalibrateGamma := FMask(Caps.Caps2, D3DCAPS2_CANCALIBRATEGAMMA);
  FCaps2CanManageResource := FMask(Caps.Caps2, D3DCAPS2_CANMANAGERESOURCE);
  FCaps2DynamicTextures := FMask(Caps.Caps2, D3DCAPS2_DYNAMICTEXTURES);
  FCaps2FulscreenGamma := FMask(Caps.Caps2, D3DCAPS2_FULLSCREENGAMMA);

  FCaps3AlphaFullScreenFlipOrDiscard := FMask(Caps.Caps3, D3DCAPS3_ALPHA_FULLSCREEN_FLIP_OR_DISCARD);
  FCaps3CopyToVidMem := FMask(Caps.Caps3, D3DCAPS3_COPY_TO_VIDMEM);
  FCaps3CopyToSystemMem := FMask(Caps.Caps3, D3DCAPS3_COPY_TO_SYSTEMMEM);
  FCaps3LinearToSRGBPresentation := FMask(Caps.Caps3, D3DCAPS3_LINEAR_TO_SRGB_PRESENTATION);

  FPresentIntervalImmediate := FMask(Caps.PresentationIntervals, D3DPRESENT_INTERVAL_IMMEDIATE);
  FPresentIntervalOne := FMask(Caps.PresentationIntervals, D3DPRESENT_INTERVAL_ONE);;
  FPresentIntervalTwo := FMask(Caps.PresentationIntervals, D3DPRESENT_INTERVAL_TWO);
  FPresentIntervalThree := FMask(Caps.PresentationIntervals, D3DPRESENT_INTERVAL_THREE);
  FPresentIntervalFour := FMask(Caps.PresentationIntervals, D3DPRESENT_INTERVAL_FOUR);

  FCursorColor := FMask(Caps.CursorCaps, D3DCURSORCAPS_COLOR);
  FCursorLowRes := FMask(Caps.CursorCaps, D3DCURSORCAPS_LOWRES);

  FDevCapsCanBltSysToNonLocal := FMask(Caps.DevCaps, D3DDEVCAPS_CANBLTSYSTONONLOCAL);
  FDevCapsCanRenderAfterFlip := FMask(Caps.DevCaps, D3DDEVCAPS_CANRENDERAFTERFLIP);
  FDevCapsDrawPrimitives2 := FMask(Caps.DevCaps, D3DDEVCAPS_DRAWPRIMITIVES2);
  FDevCapsDrawPrimitives2Ex := FMask(Caps.DevCaps, D3DDEVCAPS_DRAWPRIMITIVES2EX);
  FDevCapsDrawPrimTLVertex := FMask(Caps.DevCaps, D3DDEVCAPS_DRAWPRIMTLVERTEX);
  FDevCapsExecuteSystemMemory := FMask(Caps.DevCaps, D3DDEVCAPS_EXECUTESYSTEMMEMORY);
  FDevCapsExecuteVideoMemory := FMask(Caps.DevCaps, D3DDEVCAPS_EXECUTEVIDEOMEMORY);
  FDevCapsHwRasterization := FMask(Caps.DevCaps, D3DDEVCAPS_HWRASTERIZATION);
  FDevCapsHwTransformAndLight := FMask(Caps.DevCaps, D3DDEVCAPS_HWTRANSFORMANDLIGHT);
  FDevCapsNPatches := FMask(Caps.DevCaps, D3DDEVCAPS_NPATCHES);
  FDevCapsPureDevice := FMask(Caps.DevCaps, D3DDEVCAPS_PUREDEVICE);
  FDevCapsQuinticRTPatches := FMask(Caps.DevCaps, D3DDEVCAPS_QUINTICRTPATCHES);
  FDevCapsRTPatches := FMask(Caps.DevCaps, D3DDEVCAPS_RTPATCHES);
  FDevCapsRTPatchHandleZero := FMask(Caps.DevCaps, D3DDEVCAPS_RTPATCHHANDLEZERO);
  FDevCapsSeparateTextureMemories := FMask(Caps.DevCaps, D3DDEVCAPS_SEPARATETEXTUREMEMORIES);
  FDevCapsTextureSystemMemory := FMask(Caps.DevCaps, D3DDEVCAPS_TEXTURESYSTEMMEMORY);
  FDevCapsTextureVideoMemory := FMask(Caps.DevCaps, D3DDEVCAPS_TEXTUREVIDEOMEMORY);
  FDevCapsTLVertexSystemMemory := FMask(Caps.DevCaps, D3DDEVCAPS_TLVERTEXSYSTEMMEMORY);
  FDevCapsTLVertexVideoMemory := FMask(Caps.DevCaps, D3DDEVCAPS_TLVERTEXVIDEOMEMORY);

  FPMiscMaskZ := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_MASKZ);
  FPMiscCullNone := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_CULLNONE);
  FPMiscCullCW := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_CULLCW);
  FPMiscCullCCW := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_CULLCCW);
  FPMiscColorWriteEnable := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_COLORWRITEENABLE);
  FPMiscClipPlaneScalePoints := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_CLIPPLANESCALEDPOINTS);
  FPMiscClipVerts := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_CLIPTLVERTS);
  FPMiscTSSArgTemp := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_TSSARGTEMP);
  FPMiscMiscCapsBlendOp := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_BLENDOP);
  FPMiscNullReference := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_NULLREFERENCE);
  FPMiscIndependentWriteMasks := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_INDEPENDENTWRITEMASKS);
  FPMiscPerStageConstant := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_PERSTAGECONSTANT);
  FPMiscFogAndSpecularAlpha := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_FOGANDSPECULARALPHA);
  FPMiscSeparateAlphaBlend := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_SEPARATEALPHABLEND);
  FPMiscMRTIndependentBithDepths := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_MRTINDEPENDENTBITDEPTHS);
  FPMiscMRTPostPixelShaderBlending := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_MRTPOSTPIXELSHADERBLENDING);
  FPMiscVertexClamped := FMask(Caps.PrimitiveMiscCaps, D3DPMISCCAPS_FOGVERTEXCLAMPED);

  FRasterAnisotropy := FMask(Caps.RasterCaps, D3DPRASTERCAPS_ANISOTROPY);
  FRasterColorPerspective := FMask(Caps.RasterCaps, D3DPRASTERCAPS_COLORPERSPECTIVE);
  FRasterDither := FMask(Caps.RasterCaps, D3DPRASTERCAPS_DITHER);
  FRasterDepthBias := FMask(Caps.RasterCaps, D3DPRASTERCAPS_DEPTHBIAS);
  FRasterFogRange := FMask(Caps.RasterCaps, D3DPRASTERCAPS_FOGRANGE);
  FRasterFogTable := FMask(Caps.RasterCaps, D3DPRASTERCAPS_FOGTABLE);
  FRasterFogVertex := FMask(Caps.RasterCaps, D3DPRASTERCAPS_FOGVERTEX);
  FRasterMipMapLODBias := FMask(Caps.RasterCaps, D3DPRASTERCAPS_MIPMAPLODBIAS);
  FRasterMultiSampleToggle := FMask(Caps.RasterCaps, D3DPRASTERCAPS_MULTISAMPLE_TOGGLE);
  FRasterScissorTest := FMask(Caps.RasterCaps, D3DPRASTERCAPS_SCISSORTEST);
  FRasterSlopeScaleDepthBias := FMask(Caps.RasterCaps, D3DPRASTERCAPS_SLOPESCALEDEPTHBIAS);
  FRasterWBuffer := FMask(Caps.RasterCaps, D3DPRASTERCAPS_WBUFFER);
  FRasterWFog := FMask(Caps.RasterCaps, D3DPRASTERCAPS_WFOG);
  FRasterZBufferLessHSR := FMask(Caps.RasterCaps, D3DPRASTERCAPS_ZBUFFERLESSHSR);
  FRasterZFog := FMask(Caps.RasterCaps, D3DPRASTERCAPS_ZFOG);
  FRasterZTest := FMask(Caps.RasterCaps, D3DPRASTERCAPS_ZTEST);

  FZCmpAlways := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_ALWAYS);
  FZCmpEqual := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_EQUAL);
  FZCmpGreater := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_GREATER);
  FZCmpGreaterEqual := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_GREATEREQUAL);
  FZCmpLess := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_LESS);
  FZCmpLessEqual := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_LESSEQUAL);
  FZCmpNever := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_NEVER);
  FZCmpNotEqual := FMask(Caps.ZCmpCaps, D3DPCMPCAPS_NOTEQUAL);

  FSrcBlendFactor := FMask(Caps.SrcBlendCaps, D3DBLEND_BLENDFACTOR);
  FSrcBlendBothInvSrcAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_BOTHINVSRCALPHA);
  FSrcBlendBothSrcAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_BOTHSRCALPHA);
  FSrcBlendDestAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_DESTALPHA);
  FSrcBlendDestColor := FMask(Caps.SrcBlendCaps, D3DBLEND_DESTCOLOR);
  FSrcBlendInvDestAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_INVDESTALPHA);
  FSrcBlendInvDestColor := FMask(Caps.SrcBlendCaps, D3DBLEND_INVDESTCOLOR);
  FSrcBlendInvSrcAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_INVSRCALPHA);
  FSrcBlendInvSrcColor := FMask(Caps.SrcBlendCaps, D3DBLEND_INVSRCCOLOR);
  FSrcBlendOne := FMask(Caps.SrcBlendCaps, D3DBLEND_ONE);
  FSrcBlendSrcAlpha := FMask(Caps.SrcBlendCaps, D3DBLEND_SRCALPHA);
  FSrcBlendSrcAlphaSat := FMask(Caps.SrcBlendCaps, D3DBLEND_SRCALPHASAT);
  FSrcBlendSrcColor := FMask(Caps.SrcBlendCaps, D3DBLEND_SRCCOLOR);
  FSrcBlendZero := FMask(Caps.SrcBlendCaps, D3DBLEND_ZERO);

  FDestBlendFactor := FMask(Caps.DestBlendCaps, D3DBLEND_BLENDFACTOR);
  FDestBlendBothInvSrcAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_BOTHINVSRCALPHA);
  FDestBlendBothSrcAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_BOTHSRCALPHA);
  FDestBlendDestAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_DESTALPHA);
  FDestBlendDestColor := FMask(Caps.DestBlendCaps, D3DBLEND_DESTCOLOR);
  FDestBlendInvDestAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_INVDESTALPHA);
  FDestBlendInvDestColor := FMask(Caps.DestBlendCaps, D3DBLEND_INVDESTCOLOR);
  FDestBlendInvSrcAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_INVSRCALPHA);
  FDestBlendInvSrcColor := FMask(Caps.DestBlendCaps, D3DBLEND_INVSRCCOLOR);
  FDestBlendOne := FMask(Caps.DestBlendCaps, D3DBLEND_ONE);
  FDestBlendSrcAlpha := FMask(Caps.DestBlendCaps, D3DBLEND_SRCALPHA);
  FDestBlendSrcAlphaSat := FMask(Caps.DestBlendCaps, D3DBLEND_SRCALPHASAT);
  FDestBlendSrcColor := FMask(Caps.DestBlendCaps, D3DBLEND_SRCCOLOR);
  FDestBlendZero := FMask(Caps.DestBlendCaps, D3DBLEND_ZERO);

  FACmpAlways := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_ALWAYS);
  FACmpEqual := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_EQUAL);
  FACmpGreater := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_GREATER);
  FACmpGreaterEqual := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_GREATEREQUAL);
  FACmpLess := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_LESS);
  FACmpLessEqual := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_LESSEQUAL);
  FACmpNever := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_NEVER);
  FACmpNotEqual := FMask(Caps.AlphaCmpCaps, D3DPCMPCAPS_NOTEQUAL);

  FShadeAlphaGoraudBlend := FMask(Caps.ShadeCaps, D3DPSHADECAPS_ALPHAGOURAUDBLEND);
  FShadeColorGoraudRGB := FMask(Caps.ShadeCaps, D3DPSHADECAPS_COLORGOURAUDRGB);
  FShadeFogGoraud := FMask(Caps.ShadeCaps, D3DPSHADECAPS_FOGGOURAUD);
  FShadeSpecularGoraudRGB := FMask(Caps.ShadeCaps, D3DPSHADECAPS_SPECULARGOURAUDRGB);

  FTextureAlpha := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_ALPHA);
  FTextureAlphaPallete := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_ALPHAPALETTE);
  FTextureCubeMap := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_CUBEMAP);
  FTextureCubeMapPow2 := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_CUBEMAP_POW2);
  FTextureMipCubeMap := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_MIPCUBEMAP);
  FTextureMipMap := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_MIPMAP);
  FTextureMipVolumeMap := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_MIPVOLUMEMAP);
  FTextureNonPow2Conditional := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_NONPOW2CONDITIONAL);
  FTextureNoProjectedBumpEnv := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_NOPROJECTEDBUMPENV);
  FTexturePerspective := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_PERSPECTIVE);
  FTexturePow2 := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_POW2);
  FTextureProjected := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_PROJECTED);
  FTextureSquareOnly := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_SQUAREONLY);
  FTextureTexRepeatNotScaleBySize := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_TEXREPEATNOTSCALEDBYSIZE);
  FTextureVolumeMap := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_VOLUMEMAP);
  FTextureVolumeMapPow2 := FMask(Caps.TextureCaps, D3DPTEXTURECAPS_VOLUMEMAP_POW2);

  FTexFilterMagFPoint := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MAGFPOINT);
  FTexFilterMagFLinear := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MAGFLINEAR);
  FTexFilterMagFAnisotropic := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MAGFANISOTROPIC);
  FTexFilterMagFPyramidalQuad := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MAGFPYRAMIDALQUAD);
  FTexFilterMagFGaussianQuad := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MAGFGAUSSIANQUAD);
  FTexFilterMinFPoint := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MINFPOINT);
  FTexFilterMinFLinear := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MINFLINEAR);
  FTexFilterMinFAnisotropic := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MINFANISOTROPIC);
  FTexFilterMinFPyramidalQuad := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MINFPYRAMIDALQUAD);
  FTexFilterMinFGaussianQuad := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MINFGAUSSIANQUAD);
  FTexFilterMipFPoint := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MIPFPOINT);
  FTexFilterMipFLinear := FMask(Caps.TextureFilterCaps, D3DPTFILTERCAPS_MIPFLINEAR);

  FCubeTexFilterMagFPoint := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MAGFPOINT);
  FCubeTexFilterMagFLinear := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MAGFLINEAR);
  FCubeTexFilterMagFAnisotropic := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MAGFANISOTROPIC);
  FCubeTexFilterMagFPyramidalQuad := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MAGFPYRAMIDALQUAD);
  FCubeTexFilterMagFGaussianQuad := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MAGFGAUSSIANQUAD);
  FCubeTexFilterMinFPoint := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MINFPOINT);
  FCubeTexFilterMinFLinear := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MINFLINEAR);
  FCubeTexFilterMinFAnisotropic := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MINFANISOTROPIC);
  FCubeTexFilterMinFPyramidalQuad := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MINFPYRAMIDALQUAD);
  FCubeTexFilterMinFGaussianQuad := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MINFGAUSSIANQUAD);
  FCubeTexFilterMipFPoint := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MIPFPOINT);
  FCubeTexFilterMipFLinear := FMask(Caps.CubeTextureFilterCaps, D3DPTFILTERCAPS_MIPFLINEAR);

  FVolumeTexFilterMagFPoint := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MAGFPOINT);
  FVolumeTexFilterMagFLinear := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MAGFLINEAR);
  FVolumeTexFilterMagFAnisotropic := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MAGFANISOTROPIC);
  FVolumeTexFilterMagFPyramidalQuad := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MAGFPYRAMIDALQUAD);
  FVolumeTexFilterMagFGaussianQuad := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MAGFGAUSSIANQUAD);
  FVolumeTexFilterMinFPoint := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MINFPOINT);
  FVolumeTexFilterMinFLinear := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MINFLINEAR);
  FVolumeTexFilterMinFAnisotropic := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MINFANISOTROPIC);
  FVolumeTexFilterMinFPyramidalQuad := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MINFPYRAMIDALQUAD);
  FVolumeTexFilterMinFGaussianQuad := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MINFGAUSSIANQUAD);
  FVolumeTexFilterMipFPoint := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MIPFPOINT);
  FVolumeTexFilterMipFLinear := FMask(Caps.VolumeTextureFilterCaps, D3DPTFILTERCAPS_MIPFLINEAR);

  FTexAdressBorder := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_BORDER);
  FTexAdressClamp := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_CLAMP);
  FTexAdressIndependentUV := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_INDEPENDENTUV);
  FTexAdressMirror := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_MIRROR);
  FTexAdressMirrorOnce := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_MIRRORONCE);
  FTexAdressWrap := FMask(Caps.TextureAddressCaps, D3DPTADDRESSCAPS_WRAP);

  FVolumeTexAdressBorder := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_BORDER);
  FVolumeTexAdressClamp := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_CLAMP);
  FVolumeTexAdressIndependentUV := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_INDEPENDENTUV);
  FVolumeTexAdressMirror := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_MIRROR);
  FVolumeTexAdressMirrorOnce := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_MIRRORONCE);
  FVolumeTexAdressWrap := FMask(Caps.VolumeTextureAddressCaps, D3DPTADDRESSCAPS_WRAP);

  FLineAlphaCmp := FMask(Caps.LineCaps, D3DLINECAPS_ALPHACMP);
  FLineAntialias := FMask(Caps.LineCaps, D3DLINECAPS_ANTIALIAS);
  FLineBlend := FMask(Caps.LineCaps, D3DLINECAPS_BLEND);
  FLineFog := FMask(Caps.LineCaps, D3DLINECAPS_FOG);
  FLineTexture := FMask(Caps.LineCaps, D3DLINECAPS_TEXTURE);
  FLineZTest := FMask(Caps.LineCaps, D3DLINECAPS_ZTEST);

  FMaxTextureWidth := Caps.MaxTextureWidth;
  FMaxTextureHeight := Caps.MaxTextureHeight;
  FMaxVolumeExtent := Caps.MaxVolumeExtent;
  FMaxTextureRepeat := Caps.MaxTextureRepeat;
  FMaxTextureAspectRatio := Caps.MaxTextureAspectRatio;
  FMaxAnisotropy := Caps.MaxAnisotropy;
  FMaxVertexW := Caps.MaxVertexW;
  FGuardBandLeft := Caps.GuardBandLeft;
  FGuardBandTop := Caps.GuardBandTop;
  FGuardBandRight := Caps.GuardBandRight;
  FGuardBandBottom := Caps.GuardBandBottom;
  FExtentsAdjust := Caps.ExtentsAdjust;

  FStencilKeep := FMask(Caps.StencilCaps, D3DSTENCILCAPS_KEEP);
  FStencilZero := FMask(Caps.StencilCaps, D3DSTENCILCAPS_ZERO);
  FStencilReplace := FMask(Caps.StencilCaps, D3DSTENCILCAPS_REPLACE);
  FStencilIncrSat := FMask(Caps.StencilCaps, D3DSTENCILCAPS_INCRSAT);
  FStencilDecrSat := FMask(Caps.StencilCaps, D3DSTENCILCAPS_DECRSAT);
  FStencilInvert := FMask(Caps.StencilCaps, D3DSTENCILCAPS_INVERT);
  FStencilIncr := FMask(Caps.StencilCaps, D3DSTENCILCAPS_INCR);
  FStencilDecr := FMask(Caps.StencilCaps, D3DSTENCILCAPS_DECR);
  FStencilTwoSided := FMask(Caps.StencilCaps, D3DSTENCILCAPS_TWOSIDED);

  FFVFDoNotStripeElements := FMask(Caps.FVFCaps, D3DFVFCAPS_DONOTSTRIPELEMENTS);
  FFVFPSize := FMask(Caps.FVFCaps, D3DFVFCAPS_PSIZE);
  FFVFTexCoordCountMask := Lo(Caps.FVFCaps);

  FTexOpAdd := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_ADD);
  FTexOpAddSigned := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_ADDSIGNED);
  FTexOpAddSigned2x := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_ADDSIGNED2X);
  FTexOpAddSmooth := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_ADDSMOOTH);
  FTexOpBlendCurrentAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BLENDCURRENTALPHA);
  FTexOpBlendDiffuseAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BLENDDIFFUSEALPHA);
  FTexOpBlendFactorAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BLENDFACTORALPHA);
  FTexOpBlendTextureAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BLENDTEXTUREALPHA);
  FTexOpBlendTextureAlphaPm := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BLENDTEXTUREALPHAPM);
  FTexOpBumpEnvMap := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BUMPENVMAP);
  FTexOpBumpEnvMapLuminance := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_BUMPENVMAPLUMINANCE);
  FTexOpDisable := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_DISABLE);
  FTexOpDOTProduct3 := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_DOTPRODUCT3);
  FTexOpLERP := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_LERP);
  FTexOpModulate := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATE);
  FTexOpModulate2x := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATE2X);
  FTexOpModulate4x := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATE4X);
  FTexOpModulateAlphaAddColor := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATEALPHA_ADDCOLOR);
  FTexOpModulateColorAddAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATECOLOR_ADDALPHA);
  FTexOpModulateInvAlphaAddColor := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATEINVALPHA_ADDCOLOR);
  FTexOpModulateInvColorAddAlpha := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MODULATEINVCOLOR_ADDALPHA);
  FTexOpMultiplyAdd := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_MULTIPLYADD);
  FTexOpPreModulate := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_PREMODULATE);
  FTexOpSelectARG1 := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_SELECTARG1);
  FTexOpSelectARG2 := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_SELECTARG2);
  FTexOpSubstract := FMask(Caps.TextureOpCaps, D3DTEXOPCAPS_SUBTRACT);

  FMaxTextureBlendStages := Caps.MaxTextureBlendStages;
  FMaxSimultaneousTextures := Caps.MaxSimultaneousTextures;

  FVtxPDirectonalLights := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_DIRECTIONALLIGHTS);
  FVtxPLocalViewer := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_LOCALVIEWER);
  FVtxPMaterialSoure7 := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_MATERIALSOURCE7);
  FVtxPNoTexGenNonLocalViewer := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_NO_TEXGEN_NONLOCALVIEWER);
  FVtxPPositionalLights := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_POSITIONALLIGHTS);
  FVtxPTexGen := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_TEXGEN);
  FVtxPTexGenSphereMap := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_TEXGEN_SPHEREMAP);
  FVtxPTweening := FMask(Caps.VertexProcessingCaps, D3DVTXPCAPS_TWEENING);

  FMaxActiveLights := Caps.MaxActiveLights;
  FMaxUserClipPlanes := Caps.MaxUserClipPlanes;
  FMaxVertexBlendMatrices := Caps.MaxVertexBlendMatrices;
  FMaxVertexBlendMatrixIndex := Caps.MaxVertexBlendMatrixIndex;
  FMaxPointSize := Caps.MaxPointSize;
  FMaxPrimitiveCount := Caps.MaxPrimitiveCount;
  FMaxVertexIndex := Caps.MaxVertexIndex;
  FMaxStreams := Caps.MaxStreams;
  FMaxStreamStride := Caps.MaxStreamStride;
  FVertexShaderVersion := Format('%d.%d', [Hi(Caps.VertexShaderVersion),
    Lo(Caps.VertexShaderVersion)]);
  FMaxVertexShaderConst := Caps.MaxVertexShaderConst;
  FPixelShaderVersion := Format('%d.%d', [Hi(Caps.PixelShaderVersion),
    Lo(Caps.PixelShaderVersion)]);
  FPixelShader1xMaxValue := Caps.PixelShader1xMaxValue;

  FDevCaps2AdaptiveTessRTPatch := FMask(Caps.DevCaps2, D3DDEVCAPS2_ADAPTIVETESSRTPATCH);
  FDevCaps2AdaptiveTessNPatch := FMask(Caps.DevCaps2, D3DDEVCAPS2_ADAPTIVETESSNPATCH);
  FDevCaps2CanStretchRectFromTextures := FMask(Caps.DevCaps2, D3DDEVCAPS2_CAN_STRETCHRECT_FROM_TEXTURES);
  FDevCaps2DMapNPatch := FMask(Caps.DevCaps2, D3DDEVCAPS2_DMAPNPATCH);
  FDevCaps2PresampledDMapNPatch := FMask(Caps.DevCaps2, D3DDEVCAPS2_PRESAMPLEDDMAPNPATCH);
  FDevCaps2StreamOffset := FMask(Caps.DevCaps2, D3DDEVCAPS2_STREAMOFFSET);
  FDevCaps2VertexElemtsCanShareStreamOffset := FMask(Caps.DevCaps2, D3DDEVCAPS2_VERTEXELEMENTSCANSHARESTREAMOFFSET);

  FMaxNPatchTessellationLevel := Caps.MaxNpatchTessellationLevel;
  //FMinAntialiasedLineWidth := Caps.MinAntialiasedLineWidth;
  //FMaxAntialiasedLineWidth := Caps.MaxAntialiasedLineWidth;
  FMasterAdapterOrdinal := Caps.MasterAdapterOrdinal;
  FAdapterOrdinalInGroup := Caps.AdapterOrdinalInGroup;
  FNumberOfAdaptersInGroup := Caps.NumberOfAdaptersInGroup;

  FDTUByte4 := FMask(Caps.DeclTypes, D3DDTCAPS_UBYTE4);
  FDTUByte4N := FMask(Caps.DeclTypes, D3DDTCAPS_UBYTE4N);
  FDTShort2N := FMask(Caps.DeclTypes, D3DDTCAPS_SHORT2N);
  FDTShort4N := FMask(Caps.DeclTypes, D3DDTCAPS_SHORT4N);
  FDTUShort2N := FMask(Caps.DeclTypes, D3DDTCAPS_USHORT2N);
  FDTUShort4N := FMask(Caps.DeclTypes, D3DDTCAPS_USHORT4N);
  FDTUDec3 := FMask(Caps.DeclTypes, D3DDTCAPS_UDEC3);
  FDTDec3N := FMask(Caps.DeclTypes, D3DDTCAPS_DEC3N);
  FDT2DFloat16 := FMask(Caps.DeclTypes, D3DDTCAPS_FLOAT16_2);
  FDT4DFloat16 := FMask(Caps.DeclTypes, D3DDTCAPS_FLOAT16_4);

  FNumSimultaneousRTs := Caps.NumSimultaneousRTs;

  FSRectMinFPoint := FMask(Caps.StretchRectFilterCaps,D3DPTFILTERCAPS_MINFPOINT);
  FSRectMagFPoint := FMask(Caps.StretchRectFilterCaps, D3DPTFILTERCAPS_MAGFPOINT);
  FSRectMinFLinear := FMask(Caps.StretchRectFilterCaps, D3DPTFILTERCAPS_MINFLINEAR);
  FSRectMagFLinear := FMask(Caps.StretchRectFilterCaps, D3DPTFILTERCAPS_MAGFLINEAR);

  FVS20Predication := FMask(Caps.VS20Caps.Caps, D3DVS20CAPS_PREDICATION);
  FVS20MaxDynamicFlowControlDepth := D3DVS20_MAX_DYNAMICFLOWCONTROLDEPTH;
  FVS20MinDynamicFlowControlDepth := D3DVS20_MIN_DYNAMICFLOWCONTROLDEPTH;
  FVS20MaxNumTemps := D3DVS20_MAX_NUMTEMPS;
  FVS20MinNumTemps := D3DVS20_MIN_NUMTEMPS;
  FVS20MaxStaticFlowControlDepth := D3DVS20_MAX_STATICFLOWCONTROLDEPTH;
  FVS20MinStaticFlowControlDepth := D3DVS20_MIN_STATICFLOWCONTROLDEPTH;
  FVS20DynamicFlowControlDepth := Caps.VS20Caps.DynamicFlowControlDepth;
  FVS20NumTemps := Caps.VS20Caps.NumTemps;
  FVS20StaticFlowControlDepth := Caps.VS20Caps.StaticFlowControlDepth;

  FPS20Predication := FMask(Caps.PS20Caps.Caps, D3DPS20CAPS_PREDICATION);
  FPS20MaxDynamicFlowControlDepth := D3DPS20_MAX_DYNAMICFLOWCONTROLDEPTH;
  FPS20MinDynamicFlowControlDepth := D3DPS20_MIN_DYNAMICFLOWCONTROLDEPTH;
  FPS20MaxNumTemps := D3DPS20_MAX_NUMTEMPS;
  FPS20MinNumTemps := D3DPS20_MIN_NUMTEMPS;
  FPS20MaxStaticFlowControlDepth := D3DPS20_MAX_STATICFLOWCONTROLDEPTH;
  FPS20MinStaticFlowControlDepth := D3DPS20_MIN_STATICFLOWCONTROLDEPTH;
  FPS20DynamicFlowControlDepth := Caps.PS20Caps.DynamicFlowControlDepth;
  FPS20NumTemps := Caps.PS20Caps.NumTemps;
  FPS20StaticFlowControlDepth := Caps.PS20Caps.StaticFlowControlDepth;
  FPS20ARBITRARYSWIZLLE := FMask(Caps.PS20Caps.Caps, D3DPS20CAPS_ARBITRARYSWIZZLE);
  FPS20GradientInstructions := FMask(Caps.PS20Caps.Caps, D3DPS20CAPS_GRADIENTINSTRUCTIONS);
  FPS20NoDependentReadLimit := FMask(Caps.PS20Caps.Caps, D3DPS20CAPS_NODEPENDENTREADLIMIT);
  FPS20NoTexInstructionLimit := FMask(Caps.PS20Caps.Caps, D3DPS20CAPS_NOTEXINSTRUCTIONLIMIT);
  FPS20NumInstructionSlots := Caps.PS20Caps.NumInstructionSlots;

  FVertexTexFilterMagFPoint := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MAGFPOINT);
  FVertexTexFilterMagFLinear := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MAGFLINEAR);
  FVertexTexFilterMagFAnisotropic := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MAGFANISOTROPIC);
  FVertexTexFilterMagFPyramidalQuad := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MAGFPYRAMIDALQUAD);
  FVertexTexFilterMagFGaussianQuad := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MAGFGAUSSIANQUAD);
  FVertexTexFilterMinFPoint := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MINFPOINT);
  FVertexTexFilterMinFLinear := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MINFLINEAR);
  FVertexTexFilterMinFAnisotropic := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MINFANISOTROPIC);
  FVertexTexFilterMinFPyramidalQuad := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MINFPYRAMIDALQUAD);
  FVertexTexFilterMinFGaussianQuad := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MINFGAUSSIANQUAD);
  FVertexTexFilterMipFPoint := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MIPFPOINT);
  FVertexTexFilterMipFLinear := FMask(Caps.VertexTextureFilterCaps, D3DPTFILTERCAPS_MIPFLINEAR);

  FMaxVShaderInstructionsExecuted := Caps.MaxVShaderInstructionsExecuted;
  FMaxPShaderInstructionsExecuted := Caps.MaxPShaderInstructionsExecuted;
  FMaxVertexShader30InstructionSlots := Caps.MaxVertexShader30InstructionSlots;
  FMaxPixelShader30InstructionSlots := Caps.MaxPixelShader30InstructionSlots;

  D3D9.GetAdapterIdentifier(FDeviceNum, 0, AdapterIdent);
  FAdapterDriver := AdapterIdent.Driver;
  FAdapterDescription := AdapterIdent.Description;
  FAdapterDeviceName := AdapterIdent.DeviceName;
  FAdapterDriverVersion := AdapterIdent.DriverVersion;
  FAdapterVendorId := AdapterIdent.VendorId;
  FAdapterDeviceId := AdapterIdent.DeviceId;
  FAdapterSubSysId := AdapterIdent.SubSysId;
  FAdapterRevision := AdapterIdent.Revision;

  // Maximal fullscreen antialiasing
  Res := D3D9.GetAdapterDisplayMode(DeviceNum, DMode);
  if (Res = D3D_OK) then begin
    SFormat := DMode.Format;
    for X := 2 to 16 do begin
      Res := D3D9.CheckDeviceMultiSampleType(FDeviceNum, FDevTpe, SFormat, False,
        TD3DMULTISAMPLE_TYPE(X), nil);
      if (Res = D3D_OK) then
        FMaxFAA := X;
    end;
  end;

  D3D9 := nil;
  Result := True;
  FDone := True;
end;

procedure Register;
begin
  RegisterComponents('Asphyre', [TAsphyreDevCaps]);
end;

end.

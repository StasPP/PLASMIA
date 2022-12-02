/// This game is powred by ASPHYRE EXTRERME by AfterWrap
/// Code by: ШЕВЧУК СТАНСЛАВ
unit Unit1;

interface

uses
     Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, Asphyre2D, AsphyreCanvas, AsphyreSubsc, AsphyreDevices,
     AsphyreTimers, AsphyreDb, AsphyreImages, AsphyreFonts, AsphyreDef, AsphyreSprite,
     AsphyreKeyboard, AsphyreMouse, Xparticles, Jpeg, StdCtrls, psAPI,
     ImgList, DXSounds, SoundSystem, AsphyreTextures;

type

      TMyPoint=record
        x,y:extended;
      end;

      TMapZone=record   /// 06.11.2015
        ZoneRect: Trect;
      end;

      LevelHint=record
        name:string;
        number:integer;
      end;

      TChooseBound=record
        x,y,h,w:single;
        active:boolean;
        tip:integer;
      end;

      THintIcon=record
        img:string;
        x,st,h,w:integer;
      end;

      TMapStat=record
         MDone, MSurvival:Boolean;
         MScore,Menemies,Mplasmids,Msecrets,Maccuracy,MMax:integer;
         MBest,MTime:string;
      end;

      TMapLookObjs=record
        ObjTip:integer;
        ObjColor:Byte;
        ObjEnabled:Boolean;
        ObjX,ObjY:single;
      end;

      TMagzObj=record
        name,info,objname,img:string;
        color,cost:integer;
      end;

      TScore=record
        plasmids,shotsluck,enms,secrets,total,
        plasmidscount,enmscount,
        secretscount,shootscount:integer;
      end;

      TMyScroll=record
        minx,miny,maxy,width,height:Integer;
        pos,pcount:real;
      end;

      TMyLine=record
        lineId:byte;   //// 1 сверху 2 слева 3 снизу 4 справа
        ///  5 слева+снизу 6 справа+снизу 7 сверху+справа 8 снизу+слева
        x0_1,y0_1,x0_2,y0_2:integer;
        x1,y1,x2,y2:real;
      end;

      TMyCircle=record
        x0,y0,radius:integer;
        x,y:real;
      end;

     { TChoosingBar=record
        x1,y1,x2,y2,tip:integer;
        phase:real;
      end;   }

      TMyButton=record
        x,y,name:integer;
        onclick:integer;
      end;

      TMyMenu=record
        x,y,h,bcount:integer;
        buttons:array of TMyButton;
        wx,wy:integer;
        wscale:real;
      end;

      TGun=record
        x,y,r,a:real;
      end;

      TFlashLight=record
        x,y,r:real;
        ready:Boolean; 
      end;

      TImpulse=record
        ImpX,ImpY,ImpPower:real;
      end;

      TMyBox=record
        Posx0,Posy0:Integer;
        ANG,RAD:real;
        x0,y0:array[1..2] of integer;
        x,y:array[1..2] of real;
        POsX,PosY:real;
      end;

      TMyHud=record
       xmin,ymin,xmax,ymax:integer;
       minscale,maxscale:real;
       cscale,cx,cy,dopr:real;
       isBottom,isRight:boolean;
       hudtype:Byte;
      end;

      THudHotzone=record
       x,y,h,w,no:integer;
      end;

      TLoadThread= class(TThread)
      private
        kadr:real;
        k1,k2,k3,k4,k5: integer;
      public
        i1,i2,i3,i4,i5:boolean;
      protected
        procedure Execute;  override;
        procedure Draw1;
      end;

     TAIState = (AIHunt, AIGoto, AIStop,AIRunaway, AIWait);
     TParType = (pFire, plaserpoint,pPlasmid2, pWarer,pShield, psun,
                psun2, pcircle, pTrasser, pExplode, pExplode2, pCol, pCol2, pCol3,
                pPlasmid, pHelix, pElectro, pLasEff);
     TArmoType = (aSin, aTrasser, aTrasser2,aTrasser3, aSimple, aNone, aBall,aTrasser4);
     TEffectType=(eShine,eFlame, eSphere,eLamp,eLamp2,eLamp3,eBuse,eScreen,
                  eLamp4,elamp5,eLampCol,eSprite,eEnmCrack,ePart,eMeat,eAster,
                  eGlass,eMina,eScanLine,eCharger);
     TCamMode=(cmMove,cmCenter);


     TObj= record
         Img,Name:string;
         LineFiles:array of string;
         Index,R,G,B,anim,Tip,sizeX,sizeY,linefilescount,FreeCell:integer;
         parns:array[1..6] of string;
         DopList:TStringList;
     end;

     TMapRec = record
          X, Y: Integer;
          ImageName: string;
     end;

     TWeapons = record
          Count: Integer;
          CurrentTime:real;
     end;

     TMyHint = record
        hinttext:string;
        hintfontsize,x,y:real;
        hintcolor:byte;
        hinttime:real;
     end;

     TItem = class(TObject)
     private
        ItemInUse:boolean;
        ItemTimeUse,ItemCurrenttime:real;
        ItemTip:integer;
        ///1
        ///2
        ItemName,ItemInfo,ItemFileName:String;
        ItemColor:ShortInt;
        ItemImageName:String;
     public
        constructor Create;
        procedure UseItem(const MoveCount: Single);
        procedure CopyItem(const Source:TItem);
        procedure LoadItem(const FileName:string);
     end;

     TBonus = class(TObject)
     private
        BonusTip:integer;
        ///1
        ///2
        BonusName,BonusInfo,BonusFileName:String;
        BonusColor:ShortInt;
        BonusImageName:String;
     public
        constructor Create;
        procedure UseBonus(const MCount: Single);
        procedure CopyBonus(const Source:TBonus);
        procedure LoadBonus(const FileName:string);
     end;

     TTile = class(TAnimatedSprite)
     private
          //par:integer;
          pars:array[1..6]of integer;
          mylinecount:byte;
          objname:string;
          tip,etap:integer;
          sizexd2,sizeyd2,MyObjN:integer;
          kdr,clr:real;
          lines:array of TMyLine;
          childs:Tlist;
          subrect:Trect;
          horz,activ:boolean;
          procedure SetLines;
          procedure LoadEffs;
          procedure Push;
     public
          ID: Integer;
          procedure Move(const MoveCount: Single); override;
          constructor Create(const AParent: TSpriteEngine); override;
          procedure OnCollision(const Sprite: TSprite); override;
          procedure Draw; override;
     end;

     TEnemy=class(TAnimatedSprite)
     private
          EnmName:String;

          AITip,EnmMyObjN:integer;   /// 1 - Смертник 2 - Обычный 3 - Осторожный+ стрельба на опережение
          AIState:TAIState;

          EnmSeePlayer,EnmCanShoot:Boolean;

          EnmShootTime:real;  {время с предыдущего выстрела}
          EnmShootWait:integer; {интервал между выстрелами}
          EnmMaxHealth:integer;
          EnmLowAnim:boolean;
          EnmHealth:real; {"здоровье"}

          EnmGunCount,EnmWeap,enmweap2:integer;
          //EnmGuns:array[1..2] of TGun;

          OldX,OldY:Single;
          StartX,StartY:integer;

          EnmBody:TMyCircle;
          enmSubbodies:array[1..3] of TMyCircle;
          enmSubRA:array[1..2,1..4] of real;
          EnmSubCount:integer;
          EnmHBSize:integer;
          EnmTicks,EnmTicks2,EnmTicks3,EnmHbVis,Hbk:real;
          EnmStatic,EnmInMouse,EnmLooking:Boolean;
         // EnmChilds:TList;
          EnmCracks:Integer;
          EnmCrackList:array[1..5]of TSprite;
          EnmFlame:array[1..2,0..5]of real;   /// (1) - Radius (2) - angle [1-5] = №

          EnmImpulse:TImpulse;
          EnmMainImpulse:TImpulse;

          InWall,Bigger,EnmRockets,Crazy:boolean;
                   //// CRAZY для ракет
          EnmTurnSpeed,EnmMaxSpeed:Single;
          flamecount,EnmSpower:integer;

          SizeXdiv2,SizeYdiv2,EnmDopInt:integer;
          zx1,zx2,zy1,zy2:integer;
          palf,nextalf,AIWaitT:single;
          TargetDest:longint;
          TargetX,TargetY:integer;

          //Shield:TSieldSprite;
          guns:array[1..4] of TGun;
          GunsCount,ShotCount:Byte;
          DopSprites:array[1..4] of TSprite;

          procedure DopAction;
          procedure DrawHB;
          procedure SetGuns;
          procedure SetFlame(MoveCount: Single);
          procedure SetEnmBox;
          procedure Shoot;
          procedure Explode;
          procedure Turn;
          procedure AI;
          procedure findtarget;
          function testway():Boolean;

          procedure Creator;
     public
          procedure Move(const MoveCount: Single); override;
          procedure Draw; override;
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;

     TArmoSprite=class(TAnimatedSprite)
     private
          ArmoType:TarmoType;
          VeloX,VeloY,L,x0,y0,t,a,colt:real;
          MaxL,num,col,armopower,rad:integer;
          enm:boolean;
          launcher:Tsprite;
          procedure SetCBox;
          procedure reflect(sprite:Tsprite);
     public
          procedure Move(const MoveCount: Single); override;
          procedure Dead; override;
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;

     TParticle=class(TParticleSprite)
     private
        x0,y0:integer;
        AllLife,nu:single;
        ParType:TParType;
     public
          procedure Move(const MoveCount: Single); override;
     end;

     TDopEff=class(TAnimatedSprite)
     private
        x0,y0,MyObjN,max,cnt:integer;
        ticks,oldx,oldy:single;
        Impulse1:TImpulse;
        used:boolean;
     public
          constructor Create(const AParent: TSpriteEngine); override;
          procedure OnCollision(const Sprite: TSprite); override;
          procedure Move(const MoveCount: Single); override;
     end;


     TCapsule=class(TAnimatedSprite)
     private
        x0,y0,tip,col:integer;
        MyObjN:integer;
        Oldx,oldY,ETicks:real;
        InPlayer,noob,noob2,live,statics,keeping,keep2,prekeep:Boolean;
        InCapsule:array[1..6] of TObject;
        Capsuleshape:TMyBOx;
        Keeper:TTile;
        IsDone:boolean; mcount:byte;
        Impulse1:TImpulse;
        SizeXd2,SizeYd2:integer;
        dropme,drop:boolean;
        procedure explode;
     public
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
          procedure Move(const MoveCount: Single); override;
     end;

     TMina=class(TAnimatedSprite)
     private
        x0,y0:integer;
        MyObjN:integer;
        Oldx,oldY,TimeToExplode:real;
        Minashape:TMyBOx;
        noob2,exp,statics,wall,playersmina:boolean;
        Impulse1:TImpulse;
     public
          procedure OnCollision(const Sprite: TSprite); override;
          constructor Create(const AParent: TSpriteEngine); override;
          procedure Move(const MoveCount: Single); override;
     end;

     TLaser=class(TSprite)
     private
        x0,y0:integer;
        LaserTicks:single;
        endonwall:boolean;
        direction,lascolor:byte;
     public
          procedure Dead; override;
          procedure Move(const MoveCount: Single); override;
     end;

     TEffectSprite=class(TAnimatedSprite)
     private
          EffectType:TEffectType;
          MyObjN:integer;
          x0,y0,_r,x1,y1,t,alf0,alf1,alf2,Eticks:real;
          Cred,CGreen,CBlue,CAlpha:real;
          act,col:integer;
          Owner:TSprite;
          EffName:string;
          procedure PlayerData;
          procedure CRGB(_R,_G,_B,_A:Integer; Spd,MCount: Single);
     public
          procedure Move(const MoveCount: Single); override;
     end;


      TActor=class(TAnimatedSprite)
     private
          myobjN,ex,ey,phase,x0,y0:integer;
          xx:single;
          mustdie:boolean;
          procedure TakeIt;
     public
          procedure Move(const MoveCount: Single); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;


     TPlayer=class(TSprite)
     private
       PAlf:double;
       GunPos:array[1..2] of TPoint;
       RAGunPos:array[1..2,1..2] of Real;  ///// alf0 и R для гнёзд пушек
       VeloX,VeloY,Pticks,ddx,ddy:real;

       OldX,OldY:Single;
       Childs:TList;

       /// ФИЗИКА
       Wing1,Wing2,keepbox,kb1,kb2:TMyBox;
       Body:TMyCircle;
       Impulse,Force,Velo:TImpulse;

          procedure SetBox;    //// ВЫСЧИТЫВАЮ КРЫЛЬЯ И BODY
          procedure Turn(MCount: Single);
          procedure Explode;
          procedure KeepImpulse;
          procedure CollideBox; //// ПЕРЕМЕЩАЮ COLLIDEBOX
          function GetA0(dx,dy:integer):real;
     public
          procedure OnCollision(const Sprite: TSprite); override;
          procedure Move(const MoveCount: Single); override;
          constructor Create(const AParent: TSpriteEngine); override;
     end;

          TMainForm = class(TForm)
          Fonts: TAsphyreFonts;
          Images: TAsphyreImages;
          Device: TAsphyreDevice;
          MyCanvas: TAsphyreCanvas;
          AGraphics: TASDb;
          Timer: TAsphyreTimer;
          Keyboard1: TAsphyreKeyboard;
          Mouse: TAsphyreMouse;
          EffImgs: TAsphyreImages;
    ImageList1: TImageList;
    DXWave: TDXWaveList;
    DXSound: TDXSound;
    Images2: TAsphyreImages;
    mmImages: TAsphyreImages;
    HudImages: TAsphyreImages;
    MenuImages: TAsphyreImages;
    ItemImages: TAsphyreImages;
    SoundSystem: TSoundSystem;
    MenuSoundSystem: TSoundSystem;
    MapPreviews: TAsphyreImages;
    AsphyreTextures1: TAsphyreTextures;

          procedure DeviceInitialize(Sender: TObject; var Success: boolean);
          procedure GetNormW;
          procedure DeviceRender(Sender: TObject);
          procedure ShowDevConsole;

          function GetProcMem:real;
          function Uncoding(var s:Tstringlist):Tstringlist;
          function coding(var s:Tstringlist):Tstringlist;
          function SecToHMS(str:integer;needhour:boolean):string;

          procedure BackGround;
          procedure DrawHud;
          procedure DrawHud2;
          procedure DrawHud3;
          procedure DrawMapLookMenu;
          procedure DrawMess;
          procedure DrawMenu;
          procedure GetHintIcons;
          procedure ShowHintIcons;
          procedure MapBorder;
          procedure DopHudDraw;
          procedure HudCRGB(_R,_G,_B, I:Integer; Spd,MCount: Single);
          procedure Sline(Alfa:integer);
          procedure FadeIn(Alfa1:integer);

          procedure LoadHints;
          procedure LoadPreviews;
          procedure UnLoadPreviews;
          procedure ReadMapHeader;

          procedure PostFilter;
          procedure PostFilter2;
          procedure PostFilter3;
          procedure PostFilter3Draw(Sender:TObject);

          procedure BoomEff;
          procedure BoomPhys(BoomX,BoomY,Power,Radius,tipp:integer);

          procedure ZoomIn;
          procedure ZoomOut;
          procedure ZoomMiddle;

          procedure TimerTimer(Sender: TObject);
          procedure MouseUpdate;
          procedure MouseInventory;
          procedure MouseInventory2;
          procedure MouseInventory3;
          procedure MouseHint;
          procedure MouseMapLookMenu;
          procedure MouseMenu;
          procedure KeysUpdate;

          procedure UnpackExtras;

          procedure CloseInv;
          procedure CloseInv2;
          procedure CloseInv3;
          procedure TakeCapsule;
          procedure TakeColor;
          procedure AddDialToLog(num:integer);

          procedure NextWeap;
          procedure PrevWeap;
          procedure ChangeWeap;

          procedure GameProcess(Mdelta:real);
          procedure GameInit;
          procedure SayLoading;
          procedure DrawPhysLines;

          procedure Addhint(hinttext:string;hintsize,hx,hy:real;hcolor:byte);
          procedure ShowMyhint;

          procedure BuildLasers;
          procedure ReBuildLasers;
          procedure BornEnms;

          procedure ClearDop;
          procedure LoadDop(filename:string);

          procedure LookHint(Itmname:string);

          procedure GenerateMapObjs;

          function Superpos(Imp1,Imp2:TImpulse): TImpulse;

          procedure ConCommands;

          procedure NewMenu;

          procedure FormCreate(Sender: TObject);
          procedure FormDestroy(Sender: TObject);
          procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
          procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MenuSoundSystemFadeOutFinalize(Sender: TObject; Index: Integer;
      Name: string);


      private
          Fs: TFileStream;
          FileSize: Integer;
          MapData: array of TMapRec;
          Engine: TSpriteEngine;

          function GetFiles(var Dir, Filter: shortstring): TStringList;
          procedure LoadPic;
          procedure LoadMenu;
          procedure LoadGame;
          procedure LoadEffects;
          procedure LoadSettings;
          procedure LoadProfile;
          procedure LoadProfNames;
          procedure SaveProfNames;
          procedure LoadObjs;
          procedure LoadKeys;
          procedure LoadDefKeys;
          procedure SaveKeys;
          procedure LoadHud;
          procedure LoadLang;
          procedure LoadMagz;
          procedure LoadScenarioText;
          procedure LoadMapData(FileName:string);
          procedure SetVolumes;
          procedure SetMusVolumes;
          procedure TestVolume(vol:integer);
          procedure SaveSettings;

          procedure LoadIntro;
          procedure UnLoadIntro;

          procedure NextLevel;
          procedure DoneMapLevel;
          procedure LoadStage(stagename:string);
          procedure LoadMapLevel(stagename:string);

          procedure LoadCheckPoint;
          procedure SaveCheckPoint;

          procedure LoadProfileProgress;
          procedure SaveProfileProgress;
          procedure SaveStatistic;
          procedure NewProfileProgress;
     public
          function znak(i:real):integer;

          { Public declarations }
     end;



const
  minWScale=0.65;
  maxWScale=1.55;
  objarraylenghth=256;

  MapZonesMax = 512; /// 08.12.2015

  maxlevtime=300;

  hintmax=30;

  playerMaxSpd=10;

  //// ЦВЕТА
  RedW:array[0..9] of Integer=  (100,255,255,255, 15, 25, 25,155,255,255);
  GreenW:array[0..9] of Integer=(100, 25,125,255,255,225, 75, 25,255, 25);
  BlueW:array[0..9] of Integer= (100, 25, 25, 25, 25,255,255,255,255, 25);
  AlphaW:array[0..9] of Integer=(0,255,255,255,255,255,255,255,255,255);

  /// ПУШКИ, ТИПЫ ТРАЕКТОРИЙ ПУЛЬ, СКОРОСТИ ПУЛЬ, ДАЛЬНОСТИ ПУЛЬ
  WReloadTimes:array[1..10] of Integer=(20,20,20,20,20,20,20,40,40,40);
  WSpeed:array[1..10] of real=(20,20,20,20,20,20,20,10,10,10);
  WLMax:array[1..10] of Integer=(1500,1500,1500,1500,1500,1500,1500,1000,1000,1000);
  WArmoTypes:array[1..10] of Tarmotype=(aTrasser, aTrasser, aTrasser, aTrasser,
                                        aTrasser, aTrasser, aTrasser, aSimple,
                                        aNone, aNone);
  EnmArmoTypes:array[1..10] of Tarmotype=(aTrasser, aTrasser, aTrasser, aTrasser,
                                        aTrasser, aTrasser, aTrasser, aSimple,
                                        aNone, aNone);

  SurvivalT:array[0..12] of Integer=(0, 30, 70, 105, 135, 165, 190,
                                              225, 250, 285, 310, 320, 380);

  SurvivalEnms1:array[0..12] of Integer=(5, 44,44,3,3,8, 8,9,44, 7,2,2, 5);
  SurvivalEnms2:array[0..12] of Integer=(5, 5, 5, 3,5,9, 5,8, 5, 8,6,5, 5);
  SurvivalEnms3:array[0..12] of Integer=(5, 44,5,44,8,44,5,8,44, 9,5,6, 5);

  {SurvivalEnms1:array[0..12] of Integer=(5, 44,44,3,3,8,8,9,8,7,2,1, 5);
  SurvivalEnms2:array[0..12] of Integer=(5, 5, 5, 3,5,9,5,8,7,8,7,2, 5);
  SurvivalEnms3:array[0..12] of Integer=(5, 44,5,44,8,44,9,8,44,9,6,6, 5);}
  Diff:array[0..3] of Single = (1, 0.8, 1, 1.3);
var

     MainForm: TMainForm;

     ColEffHUD:TColor4;
     ColCharge:boolean;

     BossCol:cardinal;   
     BossCharge:boolean;

     Fonar, CutScreen:Boolean;
     Fonarsize:integer;
     FonarColor:TColor;

     MapZones :array[1..MapZonesMax] of TMapZone;  /// 06.11.2015
     MapZonesCount :integer;              /// 06.11.2015
//     MGx,MGy:integer;
//     CamScale:real;

     Hud_Bounds:array[1..2]of TRect;
     shint,shint2:LevelHint;

     PostFilter3TexCoords:TTexCoord;
     PostFilter3FlashLights:array[1..32] of TFlashLight;

     MapStat:TMapStat;
     _MapName,_MapAuthor,_MapAbout,_MapSize:String;

     ConCom:String;
     MenuTheme,IntroTheme,OutroTheme:string;
     CurrentTrack, TrackVol:integer;
     Page:byte;
     HudXShift:integer;

     IntroX,IntroY:array[1..10] of Integer;
     IntroStrBegin,IntroCount,IntroNumber:integer;

     /// MUS
     spos:integer;
     SoundVolume,MusVolume,_SV,_MV:integer;
     tracknames:array[0..20]of string;

     Pnames:array[1..10]of string;

     ///LOAD
     GameLoaded:Boolean;
     dopparlist:Tstringlist;
     CheckPointEnabled:Boolean;
     Ultralow:Boolean;
     Campaign:Boolean;

     HintIconsCount:Byte;
     HintIcons:array[1..8] of THintIcon;

     // сложность
     Difficulty,diffi:byte;

     NeedLight:byte;
     levcolor:boolean;
     levcol:array[1..3] of word;

     Slot:byte=1;
     Profnames:array[1..3] of string[20];
     Stats:array[0..30,0..5] of integer;

    //// Speed
     LagCount:real;


    /// Shield
     ShieldTime,Shieldshow:real;
     ShieldColor:byte;
     inshield:boolean;

     Portals:real;
    // Survival:Boolean;
     Scaning,schoosing:real;
     scanzone:Trect;
     scann:integer;
     ScanOk,Scannow,ShowChoosed:boolean;
     ChooseBound:TChooseBound;

     Myhints:array[1..10] of TMyHint;
     hintN:integer;
     hintmenu, HintsOn:boolean; 

     LevDials,AllDials:TStringList;
     DialPage:integer;
     DialMode,ScrollChoosed,AllDialMode:Boolean;
     DialHudT:real;
     DialScroll:TMyScroll;

     mb1,mb2,mb3,mb4,ScenarioTextBegin,ScenarioTextEnd,Hispeed:integer;

     Loadthread:TLoadThread;
     
     /// ТЕКСТ!
     lang,smessage:string;
     miseff1:boolean;
     smessagetime,dialtime,met:single;
     Language,Scenario,ItemsList,BonusList,
     DopImages,Bout,LevelCodes,Levels,Hints,MapsList{,MapZoneStrings}:TStringList;
     Curhint:array[0..7] of string;
     Dialog: TStringList;
     Edit1:String[12];
     SymbN: Single;
     dialnew:boolean;
     StringN, Dial, LogoY, MenuDopY, DialDopY, MapsPage, MapN, DialPicN,MisShift: Integer;
     DialTray:array[1..32]of integer;
     StringArr:array[1..4] of string;

    /// ССЫЛКА НА ИГРОКА
     _Player:TSprite;

    //// БОНУСЫ
    DopMaxSpeed,DopArmoPower,RBO:Integer;
    Radar,Lakmus,Droid,unltd,dopslots,plasmup,rainbow,godmode,Detect:boolean;
    detcol:array[1..3] of shortint;

    ////...
    Curetime,allcrazy1,allcrazy2:single;
    PlusClr,PlusHealth:real;
    PlusClrN:integer;
    SMmap:array of array of Byte;
//    FogOfWar:array of array of Boolean;

    Mmap:array[1..512,0..4]of integer;//MiniBitMap:TBitmap;
    MiniMapObjCount:integer;
    Showmicro,canmicro:boolean;
    microX,microY:integer;

    larcount:integer;
    larr:array of array of shortint;
    //// Init
     InitSuccess, OnlyLoaded: boolean;

    ///Меню, пауза
     paused,stopgame,minimap,menuready,MapLookMenu:Boolean;
     goBlack:boolean;//,mess:boolean;
     mapshow1,mapshow2,mapshow3:boolean;
   //  messTip:byte;
   //  messt:real;
     lastbutton,pfbutton,pfH:integer;
     Waittofade,resdop,Globalticks,Gticks,maplookdopy,NewTicks:real;
     MapLookX,MapLookY,MapLookT,microT:real;
     KeyNames:array[0..220] of string[10];

    ///  Капсула+курсор
     cursoroncapsule,cursorOnBox:boolean;
     TakenCapsule:TCapsule;
     TakenCol:TSprite;
     PushTile:TTile;
     TakeBox:TActor;

    /// УРОВЕНЬ, Очки
     LevelMission,LevelMissionTip:Byte;
     Level,CheckedLevel,playtime:Integer;
     Levelscore:TScore;
     Globalscore,AllScore:Integer;
     percento,medals:array[1..6] of integer;
     showmedal:array[1..6] of Boolean;
     showtime:string;
     itogo,leveltime,levelmissionshow:single;
     Cheater:boolean;

     GOTicks:single;
     GoWait:Integer;
     GoTip:byte;

     Lasers:array[1..64] of TTile;
     Mirrors:array[1..128] of TTile;

     lasercount,mirrorcount:integer;

     MapLookObjs:array[1..1024] of TMapLookObjs;
     MapLookObjsCount:integer;
    ///HUD
     mapsizex,mapsizey,mss,micsx,micsy:integer;
     hud_hotzones:array [1..40] of THudHotzone;
     hud_currentzone:integer;
     newcolor,newcolorcount,inmousecol,inmousecolcount,needcolor:integer;
     HudcRed,HudCgreen,HudCBlue:Array[1..6] of real;
     inventory,inventory2,inventory3:boolean;
     hudt,hudt2,hudt3:real;
     Hud, Hud2, Hud3:Array[1..20] of TMyHud;
     CameraMode: TCamMode;
     ShowDLG, HaveNewDLG:Boolean;


     Gamcurx,gamcury:real;

    /// Paths
     Dir0:string;

    //// MApData
     Objs: array [1..objarraylenghth] of Tobj;
     ObjCount:integer;

    //// MODE
     Console,LightMode,leveldone:Boolean;
     Developer,DrawDop:Boolean;
     InGame:Boolean;
     HiDet,HiEffs:Boolean;

    /// AI
    AIMap,AIDynMAP,AIDynSubMap:array of array of Boolean;

    ///Console
     cony:real;

    /// Store
     MagzObjs:array[1..15]of TMagzObj;
     MagzLev:integer;
     MagzInit1,magzinit2:boolean;

    /// DOORS
     DoorCols:array[0..10] of integer;
     DoorElectro:array[0..10] of boolean;

    /// POST-FILTER
     GoLight:boolean;
     LightTime:real;
     LightMax:Integer = 255;
     Fade1:real;  ///Затемнение экрана.


     //// Игрок
     Health:real;
     EngineOn, Droping:Boolean;
     CurrentWeapon,AltWeapon,AltWeaponsCount:integer;
     AltWeapons:array[0..8]of integer;
     CanChangeWeapon:Boolean;
     Weapons:array[0..10] of Tweapons;
     WaitShoot,canshoot,GameOver:boolean;
     ChoosedItem:byte;
     keepitm:boolean;
     keepsprite:Tsprite;
     keepitmweight:integer;
     gokeep:boolean;

     ////Inventory
     Items:array[1..4]of TItem;
     InSpace:array[1..6]of TObject;
     Bonuses:array[1..3]of TBonus;
     InMouse:TObject;

     MCount:Single;

     //// Keys
     KeyCodes:Array[0..20] of integer;
     KeyDown:Array[0..20] of Boolean;
     KeyWait:Array[0..20] of Single;

     //// Мышь
     mx,my,omx,omy,alf,RV:single;
     canwu,canwd:Boolean;
     mdown,mup:array[0..3] of boolean;
     Pressed:array[0..3] of Boolean;
     mspd,_mspd:integer;

     //Эффекты
     BoomTicks,BoomTime:single;
     BoomX,BoomY:integer;

     /// ИСКРЫ
     Sparks:array[0..25,1..2] of Integer;


     //// Масштаб
     ResolutionScaleX, ResolutionScaleY, GameScaleX,GameScaleY:real;
     ResolutionScaleY2,NormWScale:real;
     virtualH,virtualW,deltaY,DeltaX:integer;

     ///Фон
     layerX,layery:real;

     ///Меню
     InMenu,StopMenu,WaitForKey:Boolean;
     Menuticks:single;
     MenuN,NextMenu,CurButton,CurCButton,NewKey,CurrentScreenN,MSN:integer;
     MenuT:real;
     Menus:array[0..128] of TMyMenu;
     _wx,_wy:integer; _wscale:real;

     Extras:array[1..3]of boolean;
     ExtrM:array[1..3]of string;

     //// DeBug
     Dop1,Dop2:real;
     Dop3:string;
     TestAi:Boolean;

implementation
{$R *.dfm}

function GetAlf0(dx, dy: integer): real;
begin
  if (dx)<>0 then
  Begin
    if (dx)>0 then
    Begin
      result:=-arctan((dy)/(dx));
    End
    else
      Begin
        result:=-pi + arctan((-dy)/(dx));
      End;
  End
  else
    Begin
      result:=0;
    End;

    while result<0 do
      result:=result+2*pi;
    while result>2*pi do
      result:=result-2*pi;
end;

function GetObjNumber(Objname: string):integer;
var i,j:integer;
begin
j:=-1;
  for i:=1 to objcount do
  Begin
    if Objs[i].Name=objname then
      j:=i;
  End;
  Result:=j;
end;

{procedure MenuFireEff(Posx,PosY:real; PType:TParType; Tip:integer);
var i:integer;
Begin
      with  TParticle.Create(Mainform.MenuEngine) do
           begin
               ImageName := 'particles.image';
                ScaleX := 1.0;
                ScaleY := 1.0;
                AnimCount:=10;
                AnimPos:=10;
                Decay := 1.5;
                //Z:=0;
               if tip=2 then
               Begin
                ScaleX :=random(3)+ 2.0;
                ScaleY :=ScaleX;
                Decay := 1.0;
                Z:=random(5)-2;
               end;

               LifeTime := 150;

               Red:=25;
               Green:=150;
               Blue:=250;
               DrawFx := fxAdd;

               if tip=3 then
               Begin
                Red:=250;
                Green:=50;
                Blue:=50;
                DrawFx := fxSub;
               End;

               X := PosX -imageWidth*ScaleX/2;
               Y := PosY -imageHeight*ScaleY/2;

               DrawFx := fxAdd;
               UpdateSpeed := 0.5;
               VelocityX := 0;
               VelocityY := 0;
               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;     }

procedure FireEff(Posx,PosY:real; PType:TParType; Tip:integer);
var i:integer;
Begin
     for i := 1 to 10 do

      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               if Tip=1 then Begin
                ScaleX := 1.0;
                ScaleY := 1.0;
               End else
               if Tip=2 then Begin
                ScaleX := 0.7;
                ScaleY := 0.7;
               End;


               LifeTime := 15;

               if Tip=3 then
               Begin
                  LifeTime := 255;
                  ScaleX := 0.4+0.6*random;
                  ScaleY :=  ScaleX;
               End;


               X := PosX + Random(20)-10-imageWidth*ScaleX/2;
               Y := PosY + Random(20)-10-imageHeight*ScaleY/2;
               Z:=random(5)-2;

               Decay := 1.5;

               Red:=255;
               Green:=50;
               Blue:=0;

               DrawFx := fxAdd;
               UpdateSpeed := 0.5;
               VelocityX := 0;
               VelocityY := 0;
               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure BarierEff(Posx,PosY:real; Ang,col:integer);
var i:byte;
Begin
   for i:=1 to 4 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               //if Tip=1 then Begin
                ScaleX := 1.0;
                ScaleY := 1.0;
               // AnimCount:=PatternCount;
               // AnimPos:=3;
               //End;

               case Ang of
                1:Begin
                  X := PosX-imageWidth/2;
                  Y := PosY-imageHeight/2+15*random(5);
                  VelocityX := 2+0.5*random(3);
                  VelocityY := 0;
                  ScaleY := 0.4;
                End;
                2:Begin
                  X := PosX-imageWidth/2;
                  Y := PosY-imageHeight/2+15*random(5);
                  VelocityX := -2-0.5*random(3);
                  VelocityY := 0;
                  ScaleY := 0.4;
                End;
                3:Begin
                  X := PosX-imageWidth/2+15*random(5);
                  Y := PosY-imageHeight/2;
                  VelocityY := 2+0.5*random(3);
                  VelocityX := 0;
                  ScaleX := 0.4;
                End;
                4:Begin
                  X := PosX-imageWidth/2+15*random(5);
                  Y := PosY-imageHeight/2;
                  VelocityY := -2-0.5*random(3);
                  VelocityX := 0;
                  ScaleX := 0.4;
                End;
               end;
              { X := PosX + Random(20)-10-imageWidth*ScaleX/2;
               Y := PosY + Random(20)-10-imageHeight*ScaleY/2;}
               Z:=random(5)-2;

               LifeTime := 155;
               Decay := 1.5;

               Red:=255;
               Green:=50;
               Blue:=0;

               DrawFx := fxAdd;
               UpdateSpeed := 0.5;

               ParType:=PSun;

               Red:=RedW[col];
               Green:=GreenW[col];
               Blue:=BlueW[col];

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure BarierEff2(Posx,PosY:real; Ang,col,rst:integer);
var i:byte;
Begin
if  ((abs(_Player.X+128-PosX)<820/GameScaleX)
     and(abs(_Player.Y+128-PosY)<620/GameScaleX)) then
   for i:=1 to 5 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               //if Tip=1 then Begin
                ScaleX := 2.0;
                ScaleY := 2.0;
               // AnimCount:=PatternCount;
               // AnimPos:=3;
               //End;

               case Ang of
                1:Begin
                  X := PosX-imageWidth/2;
                  Y := PosY-imageHeight/2+random(15);
                  VelocityX := 3+0.5*random(3);
                  VelocityY := 0;
                  ScaleY := 0.2;
                End;
                2:Begin
                  X := PosX-imageWidth/2;
                  Y := PosY-imageHeight/2+random(15);
                  VelocityX := -3-0.5*random(3);
                  VelocityY := 0;
                  ScaleY := 0.2;
                End;
                3:Begin
                  X := PosX-imageWidth/2+random(15);
                  Y := PosY-imageHeight/2;
                  VelocityY := 3+0.5*random(3);
                  VelocityX := 0;
                  ScaleX := 0.2;
                End;
                4:Begin
                  X := PosX-imageWidth/2+random(15);
                  Y := PosY-imageHeight/2;
                  VelocityY := -3-0.5*random(3);
                  VelocityX := 0;
                  ScaleX := 0.2;
                End;
               end;
              { X := PosX + Random(20)-10-imageWidth*ScaleX/2;
               Y := PosY + Random(20)-10-imageHeight*ScaleY/2;}
               Z:=random(5)-2;

               LifeTime := rst*0.8;
               Decay := 1.5;

               Red:=255;
               Green:=50;
               Blue:=0;

              // DrawFx := fxAdd;
               UpdateSpeed := 0.5;

              // ParType:=PSun;
               ParType:=PLasEff;

               Red:=RedW[col];
               Green:=GreenW[col];
               Blue:=BlueW[col];

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;


procedure FireEff2(Posx,PosY:real; Count:integer; PType:TParType);
var i:integer;
Begin
     for i := 1 to count do

      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 0.7;
               ScaleY := 0.7;

               X := PosX + Random(20)-10-imageWidth/2;
               Y := PosY + Random(20)-10-imageHeight/2;
               Z:=random(5)-2;

               LifeTime := 70;
               Decay := 1.5;

               Red:=255;
               Green:=50;
               Blue:=0;

               DrawFx := fxAdd;
               UpdateSpeed := 0.5;
               VelocityX := 0;
               VelocityY := 0;
               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff(Posx,PosY:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to 15 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles2.image';
               ScaleX := 0.7;
               ScaleY := 0.7;

               X := PosX-imageWidth/2;
               Y := PosY-imageWidth/2;
               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=150;
               Blue:=0;

               LifeTime := 25;
               VelocityX := (random- 0.5)*5;
               VelocityY := (random- 0.5)*5;

               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               if Ptype=Pelectro then
               Begin
                ParType:=PFire;
                Z:=1;
                {ScaleX := 1;
                ScaleY := 1;
                Red:=155;
                Green:=155;
                Blue:=200;
                Z:=1;
                VelocityX := VelocityX*0.1;
                VelocityY := VelocityY*0.1;  }
               End;   

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff2(Posx,PosY:real; PType:TParType; fnar:boolean);
var i:integer;
Begin
     if fnar then
     if fonar then
     for I := 1 to 32 do
      Begin
        if PostFilter3flashLights[I].r<=0 then
        Begin
         PostFilter3flashLights[I].x:=PosX;
         PostFilter3flashLights[I].y:=PosY;
         PostFilter3flashLights[I].r:=200;
         PostFilter3flashLights[I].ready:=true;
         break;
        End;
      End;

     for i := 1 to 25 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles2.image';
               ScaleX := 1.5;
               ScaleY := 1.5;

               X := PosX-imageWidth/2;
               Y := PosY-imageWidth/2;
               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=150;
               Blue:=0;

               LifeTime := 50;
               VelocityX := (random- 0.5)*5;
               VelocityY := (random- 0.5)*5;

               AccelX := 0.05*VelocityX;
               AccelY := 0.05*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff4(Posx,PosY:real; color:integer);
var i:integer;
Begin
     for i := 1 to 15 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 0.5+0.5*random;
               ScaleY := ScaleX;
              // ScaleY := 1.5;

               X := PosX-imageWidth*scalex/2;
               Y := PosY-imageWidth*scalex/2;
               X0:=trunc(x);
               y0:=trunc(y);

               Z:=5;
               Decay := 0.5+random;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=Redw[color];
               Green:=Greenw[color];
               Blue:=Bluew[color];
               nu:=2*pi*random;
               LifeTime := 20+random(30);
               alllife:=lifetime;
               ParType:=PPlasmid;

              { VelocityX := (random- 0.5)*5;
               VelocityY := (random- 0.5)*5;

               AccelX := 0.05*VelocityX;
               AccelY := 0.05*VelocityY;   }

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff5(Posx,PosY:real; n,color:integer);
var i:integer;
Begin
     for i := 1 to n do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 0.1+random;
               ScaleY := ScaleX;
              // ScaleY := 1.5;

               X := PosX-imageWidth*scalex/2-20+random(40);
               Y := PosY-imageWidth*scalex/2-20+random(40);
               X0:=trunc(x);
               y0:=trunc(y);

               Z:=5;
               Decay := 1;//0.5+random;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=Redw[color];
               Green:=Greenw[color];
               Blue:=Bluew[color];
               nu:=2*pi*random;
               LifeTime := 50+random(20);
               alllife:=lifetime;
               ParType:=PPlasmid2;
               //ParType:=Pfire;

               VelocityX := (random- 0.5)*2;
               VelocityY := (random- 0.5)*2;

               {AccelX := 0.05*VelocityX;
               AccelY := 0.05*VelocityY;   }

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff6(Posx,PosY:real; Angl:Single);
var i,j,k:integer;
Begin
    j:=2+random(10);
    k:=random(3);
     for i := 1 to 20 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
              // PatternIndex:=10;
               ScaleX := 0.6+0.2*random;
               ScaleY := ScaleX;

               X := PosX-imageWidth/2*ScaleX+(i-10)*4*Sin(angl);
               Y := PosY-imageWidth/2*ScaleY-(i-10)*4*Cos(angl);

               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               LifeTime := 75;
               VelocityX := 0.02*j*Cos(angl)*Cos(i*k*pi/7.5*2);
               VelocityY := 0.02*j*Sin(angl)*Sin(i*k*pi/7.5*2);

               AccelX := 0;      
               AccelY := 0;

               ParType:=Pelectro;

                ScaleX := 0.5;
                ScaleY := 0.5;
                Red:=125;
                Green:=125;
                Blue:=255;
                Z:=1;


               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff3(Posx,PosY:real; col,spd:integer; PType:TParType);
var i:integer;
  j:single;
Begin
     for i := 1 to 28 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';

               X := PosX-imageWidth/2;
               Y := PosY-imageWidth/2;
               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=RedW[col];
               Green:=GreenW[col];
               Blue:=BlueW[col];

               LifeTime := 30*spd;
                J:=0.5*random+1;
               VelocityX := cos(i*pi/180*14)*5/spd*j;
               VelocityY := sin(i*pi/180*14)*5/spd*j;

               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               alllife:=lifetime;
               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure SparkEff7(Posx,PosY:real; col,ang0:integer);
Begin
    // for i := 1 to 28 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';

               ScaleX:=random+0.1;
               ScaleY:=ScaleX;

               X0 := trunc(PosX-imageWidth/2);
               Y0 := trunc(PosY-imageWidth/2);
               Z:=5;
               Decay := 0.1+random*5;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=RedW[col];
               Green:=GreenW[col];
               Blue:=BlueW[col];

               nu:=ang0*pi/180;

               LifeTime := 90;
                  
               X:=cos(ang0)*lifetime+X0;
               Y:=sin(ang0)*lifetime+Y0;

                {J:=0.5*random+1;
               VelocityX := cos(i*pi/180*14)*5/spd*j;
               VelocityY := sin(i*pi/180*14)*5/spd*j;

               AccelX := 0;
               AccelY := 0;}

               ParType:=PHelix;

               alllife:=lifetime;
               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;

               X0 := trunc(PosX-SpriteWidth/2);
               Y0 := trunc(PosY-SpriteHeight/2);
           end;
End;

procedure Shieldeff(Posx,PosY:real; col,radius:integer);
var i:integer;
    j:single;
Begin
     for i := 1 to 28 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';

              // Animcount:=PatternCount;
              // AnimPos:=0;

               //X0 := PosX;
               //Y0 := PosY;

               ScaleX:=0.5*random+0.1;
               ScaleY:=ScaleX;//0.5*random+0.1;

               Z:=5;
               Decay := 1.0;

               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=RedW[col];
               Green:=GreenW[col];
               Blue:=BlueW[col];

               LifeTime := 30;//30*spd;
                J:=20*random-10;
               X0 :=trunc( radius*cos(i*pi/180*28+j/10)-imageWidth*ScaleX/2 );
               Y0 :=trunc(  radius*sin(i*pi/180*28+j/10)-imageWidth*ScaleY/2 );


               VelocityX:=0;
               VelocityY:=0;
               AccelX := j/5;
               AccelY := j/5;

               ParType:=Pshield;

                x:=x0+_Player.X+VelocityX+128;
                y:=y0+_Player.Y+VelocityY+128;

               if abs(j)>7 then
               Begin
                 ParType:=Pfire;
                 AccelX :=0;
                 AccelY :=0;
               End;
               

               alllife:=lifetime;
               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure ExplodeEff(Posx,PosY,k:real; PType:TParType);
var i:integer;
Begin

if fonar then
  Begin
    for I := 1 to 32 do
      Begin
        if PostFilter3flashLights[I].r<=0 then
        Begin
         PostFilter3flashLights[I].x:=PosX;
         PostFilter3flashLights[I].y:=PosY;
         PostFilter3flashLights[I].r:=256;
         PostFilter3flashLights[I].ready:=false;
         break;
        End;
      End;

  End;



     for i := 1 to trunc(25*k) do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 2;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 1.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=50;
               Blue:=10;

               LifeTime := (20+random(5)+5*k);
               VelocityX := cos(i/12*pi)*(random(5)+7)/k;
               VelocityY := sin(i/12*pi)*(random(5)+7)/k;

               X := PosX-imageWidth*scaleX/2;
               Y := PosY-imageWidth*scaley/2;

               AccelX :=0.05*VelocityX;
               AccelY :=0.05*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;

procedure ExplodeEffBon(Posx,PosY,k:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to trunc(25*k) do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := random*2+1;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 3.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=25;
               Green:=50;
               Blue:=210;

               LifeTime := (20+random(5)+5*k);
               VelocityX := cos(i/12*pi+random*0.5)*(random*50+140)/k;
               VelocityY := sin(i/12*pi+random*0.5)*(random*50+140)/k;

               X := PosX-imageWidth*scaleX/2+VelocityX*50 ;
               Y := PosY-imageWidth*scaley/2+VelocityY*50 ;

               AccelX :=0.05*VelocityX;
               AccelY :=0.05*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;

procedure ExplodeEffBon2(Posx,PosY,k:real; PType:TParType);
var i:integer;
Begin
     for i := 1 to trunc(25*k) do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 2.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=25;
               Green:=50;
               Blue:=210;

               LifeTime := (20+random(5)+5*k);
               VelocityX := cos(i/12*pi+random*0.5)*(random*10+20)/k;
               VelocityY := sin(i/12*pi+random*0.5)*(random*10+20)/k;

               X := PosX-imageWidth*scaleX/2+VelocityX*150+cos(i/12*pi+0.2)*120 ;
               Y := PosY-imageWidth*scaley/2+VelocityY*150+sin(i/12*pi+0.2)*120 ;

               AccelX :=0.05*VelocityX;
               AccelY :=0.05*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;

procedure ExplodeEffBon3(Posx,PosY,k:real; PType:TParType);
var i,j:integer;
Begin
    for j := 1 to 3 do
     for i := 1 to 12*j do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particle3';

               Z:=random(5);
               Decay :=5;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;
               DrawMode:=1;

               Red:=250;
               Green:=250;
               Blue:=210;

               LifeTime := 120+random(30);//(10+random(10)+5*k);
               VelocityX := cos(i/j/6*pi)*5;
               VelocityY := sin(i/j/6*pi)*5;

               if VelocityX<>0 then
                Angle:=pi/2+arctan(VelocityY/VelocityX);

               X := PosX+VelocityX*20*j+cos(i/j/6*pi+0.2) ;
               Y := PosY+VelocityY*20*j+sin(i/j/6*pi+0.2) ;

               AccelX :=0.1*VelocityX;
               AccelY :=0.1*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;

procedure ExplodeDopEff(Posx,PosY:real; Radius,Count,Tip,Energy:integer; Big:Boolean);
var i:integer;
    s:String;
Begin

// Tip = 1 - обычн. 2 - живые 3- живые2 4- астероидные осколки

     for i := 0 to Count do
      with  TEffectSprite.Create(Mainform.Engine) do
           begin
               case tip of
                 1: Begin
                   EffectType:=ePart;
                   s:='d_'+inttostr(1+random(8))
                 End;
                 2:Begin
                   EffectType:=eMeat;
                   s:='m_'+inttostr(1+random(3))
                 End;
                 3:Begin
                   EffectType:=eMeat;
                   s:='m_'+inttostr(4+random(3))
                 End;
                 5:Begin
                   EffectType:=eMeat;
                   s:='m_'+inttostr(7+random(2))
                 End;
                 4:Begin
                   EffectType:=eMeat;
                   s:='m_0';
                 End;
                 6..14:Begin
                   EffectType:=eGlass;
                   Red:=redw[tip-6];
                   Green:=Greenw[tip-6];
                   Blue:=Bluew[tip-6];
                   s:='g_'+inttostr(1+random(4))
                 End;
                 15:Begin
                   EffectType:=eMeat;
                   s:='m_'+inttostr(9+random(2))
                 End;
                 {16:Begin
                   EffectType:=eAster;
                   s:='a_'+inttostr(1+random(3))
                 End;}
               end;



               if Mainform.Images.Find(s)<>-1 then
                 ImageName := s
               Else ImageName := 'Box1';

               ScaleX := 0.7;
               if Big then
                  ScaleX := 1+random/3;

               ScaleY := ScaleX;

               AnimCount:=PatternCount;
               AnimPos:=Random(AnimCount);

               alf2:=random/2;

               Z:=random(5);
               //UpdateSpeed := 0.5;


              // LifeTime := 25+random(5);
               X1 := cos(i/count*2*pi)*(random(5)+10);  // VELOCITIES
               Y1 := sin(i/count*2*pi)*(random(5)+10);

               alf1:=0;

               X := PosX-imageWidth/2*scaleX+x1*(1+Random(Radius div 2));
               Y := PosY-imageWidth/2*scaley+y1*(1+Random(Radius div 2));

               t:=random(Energy);
               Visible:=true;

               if (Ultralow=false)and(EffectType<>eGlass) then
                if levcolor then
                Begin
                  Red:=levcol[1];
                  Green:=levcol[2];
                  Blue:=levcol[3];
                End;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;


procedure MiniExplodeEff(Posx,PosY:real; PType:TParType);
var i:integer;
Begin
if fonar then
  Begin
    for I := 1 to 32 do
      Begin
        if PostFilter3flashLights[I].r<=0 then
        Begin
         PostFilter3flashLights[I].x:=PosX;
         PostFilter3flashLights[I].y:=PosY;
         PostFilter3flashLights[I].r:=250;
         PostFilter3flashLights[I].ready:=true;
         break;
        End;
      End;

  End;


     for i := 1 to 90 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1.5;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 1.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=50;
               Blue:=10;

               LifeTime := 15+random(5);

               if PType=PExplode2 then
               Begin
                ScaleX := 0.7;
                ScaleY := ScaleX;
                LifeTime := LifeTime/2;
               End;
               VelocityX := cos(i/12*pi)*(random(5)+10);
               VelocityY := sin(i/12*pi)*(random(5)+10);

               X := PosX-imageWidth/2*scaleX;
               Y := PosY-imageWidth/2*scaley;

               AccelX :=-0.1*cos(i/180*pi);
               AccelY :=-0.1*sin(i/180*pi);

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;

End;

procedure MiniExplodeEff2(Posx,PosY:real; PType:TParType);
var i:integer;
Begin


if fonar then
  Begin
    for I := 1 to 32 do
      Begin
        if PostFilter3flashLights[I].r<=0 then
        Begin
         PostFilter3flashLights[I].x:=PosX;
         PostFilter3flashLights[I].y:=PosY;
         PostFilter3flashLights[I].r:=256;
         PostFilter3flashLights[I].ready:=true;
         break;
        End;
      End;

  End;

     for i := 1 to 40 do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1.5;///random(2)+4;
               ScaleY := ScaleX;

               AnimStart:=12;

               Z:=5;
               Decay := 1.0;
               UpdateSpeed := 0.5;
               DrawFx := fxAdd;

               Red:=255;
               Green:=50;
               Blue:=10;

               LifeTime := 85+random(15);
               VelocityX := cos(i/12*pi)*(random*5);
               VelocityY := sin(i/12*pi)*(random*5);

               X := PosX-imageWidth/2*scaleX;
               Y := PosY-imageWidth/2*scaley;

               AccelX :=-0.01*VelocityX;
               AccelY :=-0.01*VelocityY;

               ParType:=PType;

               alllife:=lifetime;

               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure TrasserEff(Posx,PosY:real;_r,_g,_b,kind,n:integer; PType:TParType);
var i,j:integer;
Begin
   j:=n;
   if (kind>=4)and(kind<20) then
     j:=1;
   if (kind=6) then
         j:=3;

     for i := 1 to j do
      with  TParticle.Create(Mainform.Engine) do
           begin
               ImageName := 'particles.image';
               ScaleX := 1.0;
               ScaleY := 1.0;

               X := PosX + Random(20)-10-imageWidth/2;
               Y := PosY + Random(20)-10-imageHeight/2;
               Z:=7;
               if (kind=10) then
                 Z:=random(5);

               Decay := 1.0;

               UpdateSpeed := 0.5;
               //if ptype<>psun2 then
               DrawFx := fxAdd;
               Red:=_r;
               Green:=_g;
               Blue:=_b;
               case kind of
                  1,10: Begin
                  LifeTime := 50;
                  VelocityX := random- 0.15;
                  VelocityY := random- 0.15;
                  End;
                   2: Begin
                    LifeTime := 150;
                    VelocityX := random- 0.15;
                    VelocityY := random- 0.15;
                    AnimStart:=0;
                    z:=random(5);
                   End;
                   3:Begin
                    VelocityX := random- 0.15;
                    VelocityY := random- 0.15;
                   End;
                   4: Begin
                    LifeTime := 20;
                    ImageName := 'shooteff';
                    AnimCount:=PatternCount;
                    AnimPos:=AnimCount-1;
                    Angle:=n/100;
                    DrawMode:=1;
                    X := PosX;
                    Y := PosY;
                    ScaleX := 2;
                    ScaleY := 2;

                    //VelocityX := random- 0.15;
                    //VelocityY := random- 0.15;
                   End;
                   5: Begin
                    LifeTime := 30+random(30);
                    ImageName := 'particle4';
                    AnimCount:=PatternCount;
                    AnimPos:=AnimCount-1;
                    Angle:=n/100;
                    DrawMode:=1;
                    X := PosX;
                    Y := PosY;
                    ScaleX := 2;
                    ScaleY := 2;
                   End;
                   6: Begin
                    Angle:=n/100+(random-0.5)*pi/4+pi/2;
                    VelocityX :=random-0.5; //-Sin(Angle*pi/180);
                    VelocityY :=random-0.5; //-Cos(Angle*pi/180);
                    ImageName :='particles5';
                    ScaleX := 0.5+random ;
                    ScaleY := ScaleX;
                    LifeTime := 30+random(30);
                    DrawMode:=1;
                    X := PosX + VelocityX;
                    Y := PosY + VelocityY;
                   End;
                   7: Begin
                    Angle:=n/100+(random-0.5)*pi/4+pi/2;
                    ImageName :='bolt';
                    ScaleX := 0.2+random ;
                    ScaleY := ScaleX;
                    LifeTime := 30+random(30);
                    DrawMode:=1;
                    if random>0.5 then
                     MirrorX:=true;
                    X := PosX + VelocityX;
                    Y := PosY + VelocityY;
                   End;
                   20: Begin
                    LifeTime := 30+random(30);
                    ImageName := 'particles.image';
                   // AnimCount:=PatternCount;
                   // AnimPos:=2;
                   // Angle:=n/100;
                    DrawMode:=1;
                    
                    VelocityX := random- 0.15;
                    VelocityY := random- 0.15;

                    X := PosX+VelocityX*5;
                    Y := PosY+VelocityY*5;
                                          
                    ScaleX := (LifeTime)/30;
                    ScaleY := ScaleX;
                   End
                     else Begin
                        LifeTime := 150;
                        VelocityX := 0;
                        VelocityY := 0;
                        AnimStart:=0;
                      End;
               end;

               if (PType=pCol)or(PType=pCol2) then
               Begin
                X:=_Player.X+128-imageWidth/2;//X+Random*10-5;
                Y:=_Player.Y+128-imageWidth/2;//Y+Random*10-5;
                VelocityX :=random-0.5;
                VelocityY :=random-0.5;
                Angle:=2*pi*random;
                ScaleX := 0.5;
                ScaleY := 0.5;
               // spd:=3+random(7);
               /// DrawFx := fxBlend;
               End;

                if (PType=pCol3) then
               Begin
                X:=X-imageWidth/2;//X+Random*10-5;
                Y:=Y-imageWidth/2;//Y+Random*10-5;
                X0:=trunc(x);
                Y0:=trunc(y);
                LifeTime :=LifeTime-30+random(30);
                VelocityX :=random-0.5;
                VelocityY :=random-0.5;
                Angle:=2*pi*random;
                ScaleX := 0.75;
                ScaleY := 0.75;
               // spd:=3+random(7);
               /// DrawFx := fxBlend;
               End;



               AccelX := 0;
               AccelY := 0;

               ParType:=PType;

               alllife:=lifetime;
               SpriteHeight:=ImageHeight*ScaleY;
               SpriteWidth:=ImageWidth*ScaleX;
           end;
End;

procedure TMainForm.GenerateMapObjs;
var i,j:integer;
begin
  MapLookObjsCount:=0;
  MapZonesCount :=0; /// 08.12.15

  for i:=0 to engine.count - 1 do
  if Engine[i] is TTile then
  Begin
  if MapLookObjsCount< 1024 then
  with TTile(Engine[i]) do
  Begin
   case tip of
     16: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=1;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     73: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=35;         //01-06-14
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      if pars[4]=1 then
         MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;


     62: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=21;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      if pars[3]=0 then
         MapLookObjs[MapLookObjsCount].ObjEnabled:=false
          else MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     18: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=1;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     5: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=2;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      case pars[2]-DoorCols[pars[1]] of
        1: MapLookObjs[MapLookObjsCount].ObjTip:=2;
        2: MapLookObjs[MapLookObjsCount].ObjTip:=15;
        3: MapLookObjs[MapLookObjsCount].ObjTip:=16;
        4: MapLookObjs[MapLookObjsCount].ObjTip:=17
        else
         MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      end;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;

      if pars[1]=8 then
         dec(MapLookObjsCount);
     End;

     17: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=3;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      if DoorElectro[pars[1]]=true then
         MapLookObjs[MapLookObjsCount].ObjEnabled:=false
          else MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;
     End;

     6: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=4;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     30: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=5;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      if pars[3]=2 then
      MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      MapLookObjs[MapLookObjsCount].ObjX:=trunc(X+Sizexd2)div 100;
      MapLookObjs[MapLookObjsCount].ObjY:=trunc(Y+Sizeyd2)div 100;
    // fggfgfg
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=6;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[2];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      if pars[3]=1 then
        MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      MapLookObjs[MapLookObjsCount].ObjX:=trunc(X+Sizexd2)div 100;
      MapLookObjs[MapLookObjsCount].ObjY:=trunc(Y+Sizeyd2)div 100;
     End;

     19: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=7;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      //if pars[2]=1 then
      //  MapLookObjs[MapLookObjsCount].ObjEnabled:=true
      //  else
        MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     20: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=7;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
     // if pars[2]=1 then
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      // else  MapLookObjs[MapLookObjsCount].ObjEnabled:=false;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;


     22: if pars[2]=0 then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=8;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;
     End;

     33: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=9; //
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=activ; {СЕГОДНЯ}
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     50..53: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=10;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[2];
      if kdr=0 then
        MapLookObjs[MapLookObjsCount].ObjEnabled:=false else
          MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;

     28: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=11; //
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/1.5)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/1.5)/ 100;
     End;

     34: Begin
       inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=13;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;

     35: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=12;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;

     39: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=23;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;

     40: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=22;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;

     1: Begin
     if (ObjName='tconv3')or(ObjName='tconv2') then
     Begin
      inc(MapLookObjsCount);
      if ObjName='tconv3' then
        MapLookObjs[MapLookObjsCount].ObjTip:=26;
      if ObjName='tconv2' then
        MapLookObjs[MapLookObjsCount].ObjTip:=25;

      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;
     End;


     72: Begin
      if pars[2]=0 then
      Begin
        inc(MapLookObjsCount);
        MapLookObjs[MapLookObjsCount].ObjTip:=31;
        MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
        MapLookObjs[MapLookObjsCount].ObjX:=(X+55)/ 100;
        MapLookObjs[MapLookObjsCount].ObjY:=(Y+105)/ 100;
      End;

     End;
     26: Begin
     if (ObjName='tconv1') then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=27;
      if mirrorY then
         MapLookObjs[MapLookObjsCount].ObjTip:=28;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;
       if (ObjName='tconv4') then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=29;
      if mirrorX then
         MapLookObjs[MapLookObjsCount].ObjTip:=30;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y)/ 100;
     End;
     End;

     31,32: Begin
        inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=14;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      if tip=32 then
         MapLookObjs[MapLookObjsCount].ObjEnabled:=false
          else MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;
     End;


     81: Begin   /// DOOR9
        inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=33;
      MapLookObjs[MapLookObjsCount].ObjColor:=8;//pars[1];
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
     End;



     27: Begin
       inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=18;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2)/ 100;
     End;

     7: Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=19;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjColor:=pars[1];
      MapLookObjs[MapLookObjsCount].ObjX:=(X+Sizexd2/2)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(Y+Sizeyd2/2)/ 100;
     End;
   end;
  End;
  End else
  if Engine[i] is TDopEff then
  Begin
     if Objs[TDopEff(Engine[i]).MyObjN].Name='end'then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=0;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(TDopEff(Engine[i]).X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(TDopEff(Engine[i]).Y)/ 100;
     End;

     if Objs[TDopEff(Engine[i]).MyObjN].Name='closed' then
     Begin
        if MapZonesCount<MapZonesMax then
          inc(MapZonesCount);
        Mapzones[MapZonesCount].ZoneRect.Left := TDopEff(Engine[i]).colliderect.Left;
        Mapzones[MapZonesCount].ZoneRect.Top := TDopEff(Engine[i]).colliderect.Top;
        Mapzones[MapZonesCount].ZoneRect.Right := TDopEff(Engine[i]).colliderect.Right;
        Mapzones[MapZonesCount].ZoneRect.Bottom := TDopEff(Engine[i]).colliderect.Bottom;
     End;

  End
 else
  if Engine[i] is TCapsule then
  Begin
     if TCapsule(Engine[i]).tip=3 then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=24;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(TDopEff(Engine[i]).X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(TDopEff(Engine[i]).Y)/ 100;
     End;
     if TCapsule(Engine[i]).tip=8 then
     Begin
      inc(MapLookObjsCount);
      MapLookObjs[MapLookObjsCount].ObjTip:=32;
      MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
      MapLookObjs[MapLookObjsCount].ObjX:=(TDopEff(Engine[i]).X)/ 100;
      MapLookObjs[MapLookObjsCount].ObjY:=(TDopEff(Engine[i]).Y)/ 100;
     End;

  End;



 inc(MapLookObjsCount);
 MapLookObjs[MapLookObjsCount].ObjTip:=20;
 MapLookObjs[MapLookObjsCount].ObjEnabled:=true;
 MapLookObjs[MapLookObjsCount].ObjX:=(_Player.X)/ 100;
 MapLookObjs[MapLookObjsCount].ObjY:=(_Player.Y)/ 100;

 /// УБИТЬ СКРЫТЫЕ ОБЪЕКТЫ!
 if MapZonesCount>0 then
   for I := 1 to MapZonesCount do
   begin                              // wert
     for j := 1 to MapLookObjsCount do
         if (MapLookObjs[j].ObjX*100 > MapZones[i].ZoneRect.Left) and
            (MapLookObjs[j].ObjX*100 < MapZones[i].ZoneRect.Right) and
            (MapLookObjs[j].ObjY*100 < MapZones[i].ZoneRect.Bottom) and
            (MapLookObjs[j].ObjY*100 > MapZones[i].ZoneRect.Top) then
            begin
              MapLookObjs[j].ObjColor := 8;
              MapLookObjs[j].ObjEnabled := True;
              case MapLookObjs[j].ObjTip of
                1,5,7,10,21,35: MapLookObjs[j].ObjTip:=-1;
                2,3,8,14..17,33: MapLookObjs[j].ObjTip:=-2;
                4,11,19,9: MapLookObjs[j].ObjTip:=-3;
                else MapLookObjs[j].ObjTip:=-4;
              end
               
            end;
   end;
end;

function TMainform.GetFiles(var Dir,Filter:shortstring):TStringList;
var
  OldDir:string;
  W:cardinal;
  sSr:TSearchRec;
begin
  Result:=TStringList.Create;
  OldDir:=GetCurrentDir;
  SetCurrentDir(Dir);
  W:=FindFirst(Filter,faAnyFile,sSR);
  While W=0 do begin
    Result.Add(sSR.Name);
    W:=FindNext(sSR);
  end;
  SetCurrentDir(OldDir);
end;

procedure TMainForm.GetHintIcons;
var i,j,k,t:integer;
    dc:char;
    dc2:string;
    HI:THintIcon;
begin
  HintIconsCount:=0;
  for i:= 0 to 6 do
  Begin
    Curhint[i]:=hints[HintN*7+i-7];
    t:=length(curhint[i])-2;
    k:=1;

    if t>0 then
    repeat
    if curhint[i][k]='#' then
    Begin

      if copy(curhint[i],k,2)='#m' then
      begin
        dc:=curhint[i][k+2];

        copy(curhint[i],k,2);
        delete(curhint[i],k,3);
        insert('   ',curhint[i],k);

        Inc(HintIconsCount);

        if dc='1' then
          HintIcons[HintIconsCount].img:='mb'+inttostr(mb1+1)+'_'
           else
             if dc='2' then
               HintIcons[HintIconsCount].img:='mb'+inttostr(mb2+1)+'_'
                else
                  if dc='3' then
                    HintIcons[HintIconsCount].img:='mb'+inttostr(mb3+1)+'_'
                      else
                      if dc='4' then
                        HintIcons[HintIconsCount].img:='mb'+inttostr(mb4+1)+'_'
                        else
                          if dc='5' then
                            HintIcons[HintIconsCount].img:='mb1_';

        HintIcons[HintIconsCount].st:=i;
        Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;    /// new060115
        HintIcons[HintIconsCount].x:=trunc(Fonts[1].TextWidth( copy(curhint[i],1,k-1) ));
        HintIcons[HintIconsCount].h:=trunc(Fonts[1].TextHeight('!')*2.0);
        HintIcons[HintIconsCount].w:=HintIcons[HintIconsCount].h;

       // xzx
      end;

      if copy(curhint[i],k,2)='#k' then
      begin
        dc:=curhint[i][k+2];

        if dc='s' then
          j:=10
        else
        if dc='b' then
          j:=21
        else

        if dc='a' then
          j:=23
        else
        if dc='e' then
          j:=22
        else
        if dc='f' then
          j:=24
        else
        if dc='h' then
          j:=25
        else
        if dc='x' then
          j:=26
        else

        try
          j:=strtoint(dc);
        except
          j:=0;
          exit;
        end;

        if j>20 then
        begin
         if j=21 then
            dc2:=Keynames[14];
         if j=22 then
            dc2:=Keynames[28];
         if j=23 then
            dc2:='Alt';
         if j=24 then
            dc2:='F2';
         if j=25 then
            dc2:='F3';
         if j=26 then
            dc2:='F12';
        end else
          dc2:=Keynames[Keycodes[j]];

        

        copy(curhint[i],k,2);
        delete(curhint[i],k,3);
        insert(' '+dc2+' ',curhint[i],k);


        Inc(HintIconsCount);                                    
        HintIcons[HintIconsCount].img:='k_';


        HintIcons[HintIconsCount].st:=i;
        Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;       /// /// new060115
        HintIcons[HintIconsCount].x:=trunc(Fonts[1].TextWidth( copy(curhint[i],1,k-1) ));
        HintIcons[HintIconsCount].h:=trunc(Fonts[1].TextHeight('!')*2.5);
        HintIcons[HintIconsCount].w:=trunc(Fonts[1].TextWidth(dc2+'  '));
        if length(dc2)>1 then
         begin
          HintIcons[HintIconsCount].img:='k2_';
         // HintIcons[HintIconsCount].x:=HintIcons[HintIconsCount].x-trunc(10*ResolutionScaleX);
         // HintIcons[HintIconsCount].w:=HintIcons[HintIconsCount].w+trunc(20*ResolutionScaleX);
          t:=t+length(dc2)-1;
         end;

       // xzx
      end;
    End;
    inc(k);
  until k>t;
  End;

end;

procedure TMainForm.GetNormW;
var k:real;
begin
  k:=0.82;
  if CameraMode=cmMove then
    k:=0.85;

 // normWScale:=0.84;//1.0;

  normWScale:=k*(ResolutionScaleY2/ResolutionScaleY+1)/2;
end;

function TMainForm.GetProcMem: real;
 var
   pmc: PPROCESS_MEMORY_COUNTERS;
   cb: Integer;
 begin
   cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
   GetMem(pmc, cb);
   pmc^.cb := cb;
   if GetProcessMemoryInfo(GetCurrentProcess(), pmc, cb) then
   Begin
     result:= pmc^.WorkingSetSize / 1048576;
   End;
    FreeMem(pmc);


end;

procedure TMainForm.HudCRGB(_R, _G, _B, I: Integer; Spd, MCount: Single);
var Step:real;
begin

  Step:=Mcount*4*spd;

  if HudCred[i]<_R-Step then
    HudCred[i]:=HudCred[i]+Step
      else
         if HudCred[i]>_R+Step then
          HudCred[i]:=HudCred[i]-Step
           else
            HudCred[i]:=_R;

  if HudCGreen[i]<_G-Step then
    HudCGreen[i]:=HudCGreen[i]+Step
      else
         if HudCGreen[i]>_G+Step then
          HudCGreen[i]:=HudCGreen[i]-Step
           else
            HudCGreen[i]:=_G;

  if HudCBlue[i]<_B-Step then
    HudCBlue[i]:=HudCBlue[i]+Step
      else
         if HudCBlue[i]>_B+Step then
          HudCBlue[i]:=HudCBlue[i]-Step
           else
            HudCBlue[i]:=_B;


 if HudCRed[i]>255 then HudCRed[i]:=255;
  if HudCRed[i]<0then HudCRed[i]:=0;

 if HudCGreen[i]>255 then HudCGreen[i]:=255;
  if HudCGreen[i]<0then HudCGreen[i]:=0;

 if HudCBlue[i]>255 then HudCBlue[i]:=255;
  if HudCBlue[i]<0then HudCBlue[i]:=0;
end;

procedure TMainForm.LoadKeys;
var s,ka:TstringList;
 i,j,k:integer;
begin
  ///Инициализирую Управление
  /// Имена клавиш
  S:=TstringList.Create;
  KA:=TstringList.Create;

  ka.LoadFromFile('Data\Locs\KeyActions.loc');

  S.LoadFromFile('Data\Locs\KeyNames.loc');
  for I := 0 to S.Count - 1 do
    if I<120 then KeyNames[i]:=S[i];
  KeyNames[200]:='Up';
  KeyNames[208]:='Down';
  KeyNames[203]:='Left';
  KeyNames[205]:='Right';

   for I := 0 to 20 do
   keyWait[i]:=0;


  s.LoadFromFile('Data\Keys.cfg');
  for i := 0 to (s.Count-1) div 2 do
   for j := 0 to ka.Count-1 do
   Begin
     if s[i*2]=ka[j]  then
        for k := 0 to 210 do
          if s[i*2+1]=keynames[k] then
              KeyCodes[j]:=k;

   End;

  S.Destroy;
  ka.Destroy;
end;

procedure TMainForm.LoadLang;
const LangStringsCount=310;
      ScenarioStringsCount=200;
      BonusStringsCount=32;
      itemStringsCount=32;
var   i:integer;
begin
   // MapZoneStrings:=TStringlist.Create; /// 06.11.15
    LevDials:=TStringlist.Create;
    AllDials:=TStringlist.Create;
    DialPage:=0;
    DialMode:=false;
    ScrollChoosed:=false;

  //  if fileexists('Data\Languages\'+lang+'\MapZones.txt') then      /// 06.11.15
      // MapZoneStrings.LoadFromFile('Data\Languages\'+lang+'\MapZones.txt');


    Levels:=TStringlist.Create;
     if fileexists('Data\Locs\Levnames.loc') then
      Levels.LoadFromFile('Data\Locs\Levnames.loc')
       else Begin
         i:=MessageDlg('Файл "Data\Locs\Levnames.loc" не найден', mtError, [mbOk] , 0) ;
       End;

    Scenario:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Scenario.txt') then
      Scenario.LoadFromFile('Data\Languages\'+lang+'\Scenario.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Scenario.txt" не найден', mtError, [mbOk] , 0) ;
       End;


    Hints:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Hints.txt') then
      Hints.LoadFromFile('Data\Languages\'+lang+'\Hints.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Hints.txt" не найден', mtError, [mbOk] , 0) ;
       End;

    LevelCodes:=TStringlist.Create;
     if fileexists('Data\Locs\Levels.loc') then
      LevelCodes.LoadFromFile('Data\Locs\Levels.loc')
       else Begin
         i:=MessageDlg('Файл "Data\Locs\Levels.loc" не найден', mtError, [mbOk] , 0) ;
       End;
    LevelCodes:=uncoding(LevelCodes);

    MapsList:=TStringlist.Create;

    Language:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Main.txt') then
      Language.LoadFromFile('Data\Languages\'+lang+'\Main.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Main.txt" не найден', mtError, [mbOk] , 0) ;
       End;

     Bout:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\About.txt') then
      Bout.LoadFromFile('Data\Languages\'+lang+'\About.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\About.txt" не найден', mtError, [mbOk] , 0) ;
       End;

      Bout:=uncoding(Bout);

     // Диалоги
     Dialog:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Dial.txt') then
      Dialog.LoadFromFile('Data\Languages\'+lang+'\Dial.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Dial.txt" не найден', mtError, [mbOk] , 0) ;
       End;

    //BonusList...
     BonusList:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Bonus.txt') then
      BonusList.LoadFromFile('Data\Languages\'+lang+'\Bonus.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Bonus.txt" не найден', mtError, [mbOk] , 0) ;
       End;

    //ItemList...
     ItemsList:=TStringlist.Create;
     if fileexists('Data\Languages\'+lang+'\Items.txt') then
      ItemsList.LoadFromFile('Data\Languages\'+lang+'\Items.txt')
       else Begin
         i:=MessageDlg('Файл "Data\Languages\'+lang+'\Items.txt" не найден', mtError, [mbOk] , 0) ;
       End;


      {  for i:=MapZoneStrings.Count to 32 do     /// 06.11.15
        Begin
          MapZoneStrings.Add('Error ['+inttostr(i)+']');
        End; }

        for i:=Language.Count to LangStringsCount do
        Begin
          Language.Add('Error ['+inttostr(i)+']');
        End;

        for i:=Hints.Count to 220 do
        Begin
          Hints.Add('Error ['+inttostr(i)+']');
        End;

        for i:=Dialog.Count to LangStringsCount do
        Begin
          Dialog.Add('Error ['+inttostr(i)+']');
        End;

        for i:=ItemsList.Count to ItemStringsCount do
        Begin
          ItemsList.Add('Error ['+inttostr(i)+']');
        End;

        for i:=BonusList.Count to BonusStringsCount do
        Begin
          BonusList.Add('Error ['+inttostr(i)+']');
        End;

        for i:=Scenario.Count to ScenarioStringsCount do
        Begin
          Scenario.Add('Error ['+inttostr(i)+']');
        End;

        for I := 1 to 10 do
         Pnames[i]:=Language[183+i];

end;

procedure TMainForm.KeysUpdate;
var i:integer;
begin
///
KeyBoard1.Update;

  if developer then  Begin
    for I := 0 to 250 do
      if Keyboard1.KeyPressed[i] then
      Begin
          dop2:=i;
          if (i>=0)and(i<220) then
          dop3:=KeyNames[i];
      End;
  End;

 if waitforkey then
 for I := 0 to 250 do
  if Keyboard1.KeyPressed[i] then
    if KeyNames[i]<>'' then
    Begin
      Waitforkey:=false;
      KeyCodes[NewKey-1]:=i;
      break;
    End;

   if MapLookMenu then
   Begin
      if Keyboard1.Key[200] then
      Begin
         MapLookY:=MapLookY-lagCount*50;
      End;
      if Keyboard1.Key[208] then
      Begin
         MapLookY:=MapLookY+lagCount*50;
      End;
      if Keyboard1.Key[203] then
      Begin
         MapLookX:=MapLookX-lagCount*50;
      End;
      if Keyboard1.Key[205] then
      Begin
         MapLookX:=MapLookX+lagCount*50;
      End;
   End;

   if DialMode then
   Begin
      if (Keyboard1.Key[203])or(Keyboard1.Key[205])  then
         Begin
           AllDialMode:=not(AllDialMode);

           if LevDials.Count=0 then
              AllDialMode:=true;

           if AllDialMode then
                 DialPage:=AllDials.Count div 5-5
                   else
                      DialPage:=LevDials.Count div 5-5;
           if DialPage<0 then
              DialPage:=0;
         End;



      if AllDialMode then
      Begin
        if Keyboard1.Key[208]  then
          if DialPage<AllDials.Count div 5-5 then
            inc(dialPage);

        if Keyboard1.Key[200]  then
          if DialPage>0 then
            dec(dialPage);

        if DialPage>AllDials.Count div 5-5 then
          DialPage:=AllDials.Count div 5-5;

        if DialPage<0 then
          DialPage:=0;
      End
      else Begin
        if Keyboard1.Key[208]  then
          if DialPage<LevDials.Count div 5-5 then
            inc(dialPage);

        if Keyboard1.Key[200]  then
          if DialPage>0 then
            dec(dialPage);

        if DialPage>LevDials.Count div 5-5 then
          DialPage:=LevDials.Count div 5-5;

        if DialPage<0 then
          DialPage:=0;

      End;
   End;

   if menun=2 then
   Begin
      if Keyboard1.Key[208]  then
      if MapsPage<MapsList.Count - 10 then
       inc(MapsPage);

       if Keyboard1.Key[200]  then
      if MapsPage>0 then
       dec(MapsPage);
   End;

 if health>0 then
 for I := 0 to 20 do
 if Keyboard1.KeyPressed[KeyCodes[i]] then
 Begin
    case i of
    0: Begin
      {if not(Paused) then
      if not(StopMenu) then
      if not(inventory2) then}
      if inGame then
      Begin
        if KeyCodes[i]<>28 then
            inventory:=true;
      End;
    End;
    1: Nextweap;
    2: Prevweap;
    10: Changeweap;
    3: if Items[1]<>nil then
        Items[1].ItemInUse:=not(Items[1].ItemInUse);
    4: if Items[2]<>nil then
        Items[2].ItemInUse:=not(Items[2].ItemInUse);
    5: if Items[3]<>nil then
        Items[3].ItemInUse:=not(Items[3].ItemInUse);
    6: if Items[4]<>nil then
        Items[4].ItemInUse:=not(Items[4].ItemInUse);
    11: Paused:=not(Paused);
    End;
 End;

end;


procedure TMainForm.LoadCheckPoint;
var mapfile:Tstringlist;
  i,j:integer;
  Filename:string;
begin
 if (Campaign) then
  filename:= 'Saves\Slot'+inttostr(slot)+'\CheckPoint.loc'
   else
     filename:= 'Saves\Slot'+inttostr(slot)+'\'+MapsList[MapN]+'.loc';

  if fileexists(filename) then
  Begin
    SayLoading;
    Timer.Enabled:=false;
    Engine.Clear;

    for i:=1 to 4 do
    Begin
      if Items[i]<>nil then
        Items[i]:=nil;
      if i<=3 then
        Bonuses[i]:=nil;
    End;

    GameInit;

    mapfile:=Tstringlist.Create;
    mapfile.LoadfromFile(filename);
    health:=strtoint(mapfile[0]);

    CurrentWeapon:=strtoint(mapfile[1]);
    for i:=1 to 6 do
    Begin
        Altweapons[i]:=strtoint(mapfile[i+1]);
    End;

    for i:=1 to 8 do
    Begin
        weapons[i].count:=strtoint(mapfile[i+7]);
    End;

    for i:=0 to 3 do
    Begin
      if mapfile[i*2+16]<>'' then
      Begin
        items[i+1]:=TItem.Create;
        items[i+1].LoadItem(mapfile[i*2+16]);
        items[i+1].ItemCurrenttime:=strtoint(mapfile[i*2+17]);
      End;
    End;

    for i:=1 to 3 do
    Begin
      if mapfile[i+23]<>'' then
      Begin
        Bonuses[i]:=TBonus.Create;
        Bonuses[i].LoadBonus(mapfile[i+23]);
      End;
    End;
    Altweapon:=Altweapons[1];

    shieldtime:=strtoint(mapfile[27]);
    shieldcolor:=strtoint(mapfile[28]);

    i:=0;
    for j := 1 to 7 do
      if altweapons[j]>0 then
       inc(I);
    altweaponscount:=i;

    if Campaign then
      LoadMapData('Saves\Slot'+inttostr(slot)+'\CheckPoint.map')     {CURRENTMAP!!!!!!!!!!!!}
       else
          LoadMapData('Saves\Slot'+inttostr(slot)+'\'+MapsList[MapN]);

    levelscore.total:=strtoint(mapfile[29])-9876;
    globalscore:=levelscore.total;

    levelscore.ENMS:=strtoint(mapfile[30]);
    levelscore.ENMSCount:=strtoint(mapfile[31]);

    levelscore.plasmids:=strtoint(mapfile[32]);
    levelscore.plasmidscount:=strtoint(mapfile[33]);

    levelscore.secrets:=strtoint(mapfile[34]);
    levelscore.secretscount:=strtoint(mapfile[35]);

    levelscore.shotsluck:=strtoint(mapfile[36]);
    levelscore.shootscount:=strtoint(mapfile[37]);

    leveltime:=strtoint(mapfile[38]);

    mapfile.destroy;

    Timer.Enabled:=true;
    nextmenu:=0;
  End;

  if Campaign then
  Begin
     try
       alldials.LoadfromFile('Saves\Slot'+inttostr(slot)+'\CheckAllDials.loc');
       levdials.LoadfromFile('Saves\Slot'+inttostr(slot)+'\CheckDials.loc');
     except

     end;

  End;

end;


procedure TMainForm.LoadDefKeys;
var s,ka:TstringList;
 i,j,k:integer;
begin
  ///Инициализирую Управление
  /// Имена клавиш
  S:=TstringList.Create;
  KA:=TstringList.Create;

  ka.LoadFromFile('Data\Locs\KeyActions.loc');

  S.LoadFromFile('Data\Locs\KeyNames.loc');
  for I := 0 to S.Count - 1 do
    if I<120 then KeyNames[i]:=S[i];
  KeyNames[200]:='Up';
  KeyNames[208]:='Down';
  KeyNames[203]:='Left';
  KeyNames[205]:='Right';

   for I := 0 to 20 do
   keyWait[i]:=0;


  s.LoadFromFile('Data\KeysDefault.cfg');
  for i := 0 to (s.Count-1) div 2 do
   for j := 0 to ka.Count-1 do
   Begin
     if s[i*2]=ka[j]  then
        for k := 0 to 210 do
          if s[i*2+1]=keynames[k] then
              KeyCodes[j]:=k;

   End;

  mb1:=0;
  mb2:=1;
  mb3:=2;
  mb4:=0;
   
  S.Destroy;
  ka.Destroy;
end;

procedure TMainForm.LoadDop(filename: string);
var i,j:integer;
det:string;
begin
  SetCurrentDir(Dir0);
  det:='_LD';
  if Hidet then det:='_HD';
  //if Ultralow then det:=det+'_ULD';

  if (filename='Hints')or(filename='hints') then
  AGraphics.FileName:='Data\Graphics\'+filename+'_hd.asdb'
   else
    AGraphics.FileName:='Data\Graphics\'+filename+det+'.asdb';

  j:=images.Count;
  images.LoadFromASDb(AGraphics);

  if (images.Count)-j>0 then
  for i:=j to images.Count-1 do Begin
    DopImages.Add(images[i].Name);
   // showmessage(images[i].Name)
  End;
end;

procedure TMainForm.LoadEffects;
var st:TStringList;
    m:integer;

begin

 st:=TStringList.Create;

 if fileexists('Data\Locs\Sparks.pts') then
  Begin
    st.LoadFromFile('Data\Locs\Sparks.pts');
  

    for m := 0 to st.Count div 2 -1 do
    Begin
       Sparks[m,1]:=StrToInt(st[m*2]);
       Sparks[m,2]:=StrToInt(st[m*2+1]);
    end;
  End;

  st.Destroy;


end;


procedure TMainForm.LoadGame;
var init1:Boolean;
    img:TBitmap;
    SoundList,CurUser:TStringList;
    s1,s2:shortstring;
    i:integer;
begin

     init1:=InitSuccess;

     img:=TBitMap.Create;
     if fileexists('Data\Graphics\load.asdb') then
     Begin
      img.LoadFromFile('Data\Graphics\load.asdb');
      Imagelist1:=TImagelist.CreateSize(64,64);
      imagelist1.AddMasked(img,clblack)
     End;
      img.Free;

     Gameloaded:=true;

     Loadthread:=TLoadThread.Create(False);

     InitSuccess := Images.LoadFromASDb(AGraphics);

     LoadLang;

  {  if ItsRelease=false then
    Begin
      Canvas.Brush.Color:=clBlack;
      Canvas.Font.Color:=clAqua;
      Canvas.Font.Size:=24;
      Canvas.TextOut(Mainform.width div 2 - Canvas.TextWidth('[BETA v. 0.99c]') div 2,
                     Mainform.height div 2-200, '[BETA v. 0.99c]');

    End;    }

     AGraphics.FileName:='Data\Graphics\Menu.asdb';
     InitSuccess := MenuImages.LoadFromASDb(AGraphics);

    if (Hieffs)and(Hidet) then
    Begin
       AGraphics.FileName:='Data\Graphics\new.asdb';
       InitSuccess := MenuImages.LoadFromASDb(AGraphics);
    End;

    if Fileexists('Data\Languages\'+lang+'\Fonts.asdb') then
    Begin
     for i := 0 to Fonts.Count - 1 do
     Fonts[i].Unload;

     AGraphics.FileName:='Data\Languages\'+lang+'\Fonts.asdb';
     if (InitSuccess) then
          InitSuccess := Fonts.LoadFromASDb(AGraphics);
    End else
    Begin

     AGraphics.FileName:='Data\Graphics\Fonts.asdb';
     if (InitSuccess) then
          InitSuccess := Fonts.LoadFromASDb(AGraphics);
    End;

     Loadthread.i1:=true;

     AGraphics.FileName:='Data\Graphics\Items.asdb';
     InitSuccess := ItemImages.LoadFromASDb(AGraphics);

     AGraphics.FileName:='Data\Graphics\HUD.asdb';
     InitSuccess := HudImages.LoadFromASDb(AGraphics);

     Loadthread.i2:=true;

     if HiDet=true then
       AGraphics.FileName:='Data\Graphics\HD.asdb'
      else
        AGraphics.FileName:='Data\Graphics\LD.asdb';
     InitSuccess := Images.LoadFromASDb(AGraphics);

     Loadthread.i3:=true;

     if Ultralow=true then
     Begin
      if HiDet=true then
        AGraphics.FileName:='Data\Graphics\Player_HD_ULD.asdb'
        else
          AGraphics.FileName:='Data\Graphics\Player_LD_ULD.asdb';
     End else
     Begin
      if HiDet=true then
        AGraphics.FileName:='Data\Graphics\Player_HD.asdb'
        else
          AGraphics.FileName:='Data\Graphics\Player_LD.asdb';
     End;
     InitSuccess := Images.LoadFromASDb(AGraphics);
     {if Ultralow=true then
     Begin
      if HiDet=true then
        AGraphics.FileName:='Data\Graphics\Enm_HD_ULD.asdb'
        else
          AGraphics.FileName:='Data\Graphics\Enm_LD_ULD.asdb';
     End else
     Begin }
      if HiDet=true then
        AGraphics.FileName:='Data\Graphics\Enm_HD.asdb'
        else
          AGraphics.FileName:='Data\Graphics\Enm_LD.asdb';
   //  End;
     InitSuccess := Images.LoadFromASDb(AGraphics);

      if Ultralow=false then
      Begin
       AGraphics.FileName:='Data\Graphics\FX.asdb';
       InitSuccess := Images.LoadFromASDb(AGraphics);
      End;

     Loadthread.i4:=true;

     AGraphics.FileName:='Data\Graphics\Minimap.asdb';
     InitSuccess := MMImages.LoadFromASDb(AGraphics);

     AGraphics.FileName:='Data\Graphics\AddEff.asdb';
     if HiEffs=true then
     InitSuccess := Images.LoadFromASDb(AGraphics);

     AGraphics.FileName:='Data\Graphics\Effects_hi.asdb';
     if HiEffs=false then
        AGraphics.FileName:='Data\Graphics\Effects_low.asdb';
     InitSuccess := Images.LoadFromASDb(AGraphics);

     if HiEffs then
       fonarsize:=1024
         else
           fonarsize:=64;
    // Begin

      AsphyreTextures1.AddRenderTargets(1, fonarsize, fonarsize, false, aqHigh, alNone, false);

      PostFilter3TexCoords:=TCNull;
      PostFilter3TexCoords.x:= 0;
      PostFilter3TexCoords.y:= 0;
      PostFilter3TexCoords.w:= fonarsize;// Device.Width;
      PostFilter3TexCoords.h:= fonarsize; //Device.Height;

    // End;

     Engine := TSpriteEngine.Create;
     Engine.Image := Images;
     Engine.Canvas := MyCanvas;

     DopImages:=TStringList.Create;

     LoadObjs;

     LoadKeys;



     if (InitSuccess) then
     Begin
      Fonts[1].Interleave:=2.0;
      Fonts[2].Interleave:=3.0;
     End;

     LoadMagz;

    // Asound.FileName:='Data\Music\Music.asdb';
    // Soundsystem.LoadFromASDb(ASound);

     s1:='Data\sound\';
     s2:='*.wav';
     SoundList:=TStringList.Create;
     SoundList:=GetFiles(S1,S2);

     for I := 0 to SoundList.Count - 1 do
     Begin
      //showmessage(s1+SoundList[i]);
      DXWave.Items.Add;
      DXWave.Items[i].Wave.LoadFromFile(s1+SoundList[i]);
      //showmessage(soundList[i]);
      DXWave.Items[i].Name:=SoundList[i];
      DXWave.Items[i].MaxPlayingCount:=1;//5
     End;
      DXWave.Items.Restore;
      Mainform.DXWave.Items.Find('ray.wav').MaxPlayingCount:=1;
      Mainform.DXWave.Items.Find('test.wav').MaxPlayingCount:=1;
      Mainform.DXWave.Items.Find('laser.wav').MaxPlayingCount:=1;
      Mainform.DXWave.Items.Find('electro.wav').MaxPlayingCount:=2;

     Soundlist.Clear;
     Soundlist.LoadFromFile('Data\Locs\Music.loc');
     MenuTheme:=Soundlist[0];
     IntroTheme:=Soundlist[1];
     OutroTheme:=Soundlist[2];

     // Asound.FileName:='Data\Music\Menu.asdb';
     MenuSoundsystem.AddFromFile('Data\Music\'+MenuTheme+'.mp3');

    { if(fileexists('Data\Music\'+MenuTheme+'.wav')) then
     Begin

      DXMenuMusic.Items.Add;
      DXMenuMusic.Items[0].Wave.LoadFromFile('Data\Music\'+MenuTheme+'.wav');
      DXMenuMusic.Items[0].Name:='menu';//trackname;
      DXMenuMusic.Items[0].MaxPlayingCount:=1;
      if MusVolume<>0 then
        DXMenuMusic.Items[0].Volume:=-3000+MusVolume*30
          else DXMenuMusic.Items[0].Volume:=-10000;

      DXMenuMusic.Items.Restore;
     End;}


     Soundlist.Clear;
     Soundlist.LoadFromFile('Data\Locs\levmusic.loc');

     Loadthread.i5:=true;

     MapsPage:=0;
     MapN:=0;

     for I := 0 to SoundList.Count - 1 do
      tracknames[i]:= SoundList[i];

     Soundlist.Destroy;

     GameScaleX:=1;
     GameScaleY:=1;

     //fonts[1].ShadowDistance:=2*resolutionscaleY;
     //fonts[1].ShadowColor:=clblack;

     LoadHud;
     GameInit;

     checkpointenabled:=false;

     LoadMapData('Data\Maps\empty.map');

    // cameraMode:=cmCenter;

    if (InitSuccess=false)or(init1=false) then
    Begin
      MessageDlg('Критическая ошибка при загрузке. Программа будет закрыта', mtError, [mbAbort] , 0);
      Close;
    End;
   // img.destroy;

    // Loadthread.Terminate;
     LoadMenu;

     LoadEffects;

     SetVolumes;
     SetMusVolumes;

     _MV:=MusVolume;
     _SV:=SoundVolume;
     _MSPD:=MSPD;

     GTicks:=-1;
     MSN:=1;
     
     InMenu:=true;
     LoadProfNames;
     MenuN:=12;


     MenuT:=0;
     MenuReady:=true;

     i:=0;
     CurUser:=TStringList.Create;
     try
      CurUser.LoadFromFile('Data\Locs\CurrentUser.loc');
      i:=strToInt(CurUser[0]);
     except

     end;
     CurUser.Destroy;

     if (i>0)and(i<=3) then
        if ProfNames[i]<>'' then
        Begin
           slot:=i;
           loadProfileProgress;
           menun:=1;
        End;


end;

procedure TMainForm.LoadHints;
begin
     AGraphics.FileName:='Data\Graphics\Hints_HD.asdb';
     MapPreviews.LoadFromASDb(AGraphics);

end;

procedure TMainForm.LoadHud;
var i:integer;
    sl:Tstringlist;
begin
//
  HudXShift:=0;

  sl:=Tstringlist.Create;
  for i := 1 to 8 do
  Begin
    sl.LoadFromFile(Dir0+'\DATA\Menus\HUD\Hud'+inttostr(i)+'.loc');
    Hud[i].hudtype:=strtoint(sl[0]);
    Hud[i].xmin:=strtoint(sl[1]);
    Hud[i].ymin:=strtoint(sl[2]);
    Hud[i].xmax:=strtoint(sl[3]);
    Hud[i].ymax:=strtoint(sl[4]);
    Hud[i].minscale:=strtoint(sl[5])/100;
    Hud[i].maxscale:=strtoint(sl[6])/100;
    Hud[i].isBottom:=false;
     if sl[7]='1' then
       Hud[i].isBottom:=true;
    Hud[i].isRight:=false;
     if sl[8]='1' then
       Hud[i].isRight:=true;
  End;

    resdop:=1;
    LogoY:=50;
    MenuDopY:=50;
    maplookdopy:=0;
    DialDopY:=120;
    MisShift:=0;

    for i := 1 to 2 do
    Begin
      Hud_Bounds[i].Left:=0;
      Hud_Bounds[i].Top:=0;
      Hud_Bounds[i].Right:=0;
      Hud_Bounds[i].Bottom:=0;
    End;



   if (VirtualH>=1280) then
   Begin
    resdop:=1.2;
    LogoY:=65;
    MenuDopY:=65;
    DialDopY:=120;//150;
     Hud_Bounds[1].Right:=round(VirtualW*ResolutionScaleX);
     Hud_Bounds[1].Bottom:=round(65*ResolutionScaleY);
     Hud_Bounds[2].Top:=round((VirtualH-60)*ResolutionScaleY);
     Hud_Bounds[2].Right:=round(VirtualW*ResolutionScaleX);
     Hud_Bounds[2].Bottom:=round(VirtualH*ResolutionScaleY)+1;

   End else
   if (VirtualH<=1000)and(VirtualH>900) then
   Begin
    Hud[1].ymax:=Hud[1].ymax-25;
    Hud[2].ymax:=Hud[2].ymax-25;
    Hud[3].ymax:=Hud[3].ymax+25;
    Hud[4].ymax:=Hud[4].ymax+25;
    Hud[3].ymin:=Hud[3].ymin-10;
    resdop:=0.2;
    LogoY:=25;
    MenuDopY:=10;
    DialDopY:=0;
    MisShift:=260;


    {!!!}
   { Hud[1].xmax:=Hud[1].xmax+85;
    Hud[2].xmax:=Hud[2].xmax-25;
    Hud[3].xmax:=Hud[3].xmax+25;
    Hud[4].xmax:=Hud[4].xmax+25; }
   if CutScreen then
   Begin
    HudXShift:=110;
    Hud[1].xmin:=Hud[1].xmin+(HudXShift-10);
    Hud[3].xmin:=Hud[3].xmin+(HudXShift-10);
    Hud[2].xmin:=Hud[2].xmin-(HudXShift-10);          // cxc
    Hud[4].xmin:=Hud[4].xmin-(HudXShift-10);


                                        // xzx
     Hud_Bounds[1].Right:=round(HudXShift*ResolutionScaleX);
     Hud_Bounds[1].Bottom:=round(VirtualH*ResolutionScaleY)+1;
     Hud_Bounds[2].Left:=round((VirtualW-HudXShift)*ResolutionScaleX);
     Hud_Bounds[2].Right:=round(VirtualW*ResolutionScaleX)+1;
     Hud_Bounds[2].Bottom:=round(VirtualH*ResolutionScaleY)+1;
  end;

  End else
  if VirtualH<=900 then Begin
    Hud[1].ymax:=Hud[1].ymax-15;
    Hud[2].ymax:=Hud[2].ymax-25;
    Hud[3].ymax:=Hud[3].ymax+10;
    Hud[4].ymax:=Hud[4].ymax+10;
    Hud[3].ymin:=Hud[3].ymin-10;
    resdop:=-0.5;
    maplookdopy:=-100;
    LogoY:=5;
    MenuDopY:=-15;
    DialDopY:=0;
    MisShift:=270;

    //cxzc

    if CutScreen then
    Begin
      HudXShift:=160;
      Hud[1].xmin:=Hud[1].xmin+(HudXShift-10);
      Hud[3].xmin:=Hud[3].xmin+(HudXShift-10);
      Hud[2].xmin:=Hud[2].xmin-(HudXShift-10);          // cxc
      Hud[4].xmin:=Hud[4].xmin-(HudXShift-10);


                                        // xzx
      Hud_Bounds[1].Right:=round(HudXShift*ResolutionScaleX);
      Hud_Bounds[1].Bottom:=round(VirtualH*ResolutionScaleY)+1;
      Hud_Bounds[2].Left:=round((VirtualW-HudXShift)*ResolutionScaleX);
      Hud_Bounds[2].Right:=round(VirtualW*ResolutionScaleX)+1;
      Hud_Bounds[2].Bottom:=round(VirtualH*ResolutionScaleY)+1;
    end;
     {Hud_Bounds[1].Right:=round(150*ResolutionScaleX);
     Hud_Bounds[1].Bottom:=round(VirtualH*ResolutionScaleY)+1;
     Hud_Bounds[2].Left:=round((VirtualW-150)*ResolutionScaleX);
     Hud_Bounds[2].Right:=round(VirtualW*ResolutionScaleX)+1;
     Hud_Bounds[2].Bottom:=round(VirtualH*ResolutionScaleY)+1; }
  End else
  Begin
     Hud_Bounds[1].Right:=round(VirtualW*ResolutionScaleX);
     Hud_Bounds[1].Bottom:=round(50*ResolutionScaleY);
     Hud_Bounds[2].Top:=round((VirtualH-50)*ResolutionScaleY);
     Hud_Bounds[2].Right:=round(VirtualW*ResolutionScaleX);
     Hud_Bounds[2].Bottom:=round(VirtualH*ResolutionScaleY)+1;
  End;

  sl.LoadFromFile('Data\Menus\HUD\HotZones.loc');
 // hud_hotzones_count:=(sl.Count - 1)div 6;
  //SetLength(hud_hotzones,hud_hotzones_count);
  for I := 0 to (sl.Count - 1)div 6 do
  Begin
    hud_hotzones[I].x:=StrToInt(sl[I*6]);
    hud_hotzones[I].y:=StrToInt(sl[I*6+1]);
    hud_hotzones[I].h:=StrToInt(sl[I*6+2]);
    hud_hotzones[I].w:=StrToInt(sl[I*6+3]);
    hud_hotzones[I].no:=StrToInt(sl[I*6+4]);
  End;


  for i := 1 to 8 do
  Begin
    sl.LoadFromFile(Dir0+'\DATA\Menus\HUD2\Hud'+inttostr(i)+'.loc');
    Hud2[i].hudtype:=strtoint(sl[0]);
    Hud2[i].xmin:=strtoint(sl[1]);
    Hud2[i].ymin:=strtoint(sl[2]);
    Hud2[i].xmax:=strtoint(sl[3]);
    Hud2[i].ymax:=strtoint(sl[4]);
    Hud2[i].minscale:=strtoint(sl[5])/100;
    Hud2[i].maxscale:=strtoint(sl[6])/100;
    Hud2[i].isBottom:=false;
     if sl[7]='1' then
       Hud2[i].isBottom:=true;
    Hud2[i].isRight:=false;
     if sl[8]='1' then
       Hud2[i].isRight:=true;
  End;

  for i := 1 to 7 do
  Begin
    sl.LoadFromFile(Dir0+'\DATA\Menus\HUD3\Hud'+inttostr(i)+'.loc');
    Hud3[i].hudtype:=strtoint(sl[0]);
    Hud3[i].xmin:=strtoint(sl[1]);
    Hud3[i].ymin:=strtoint(sl[2]);
    Hud3[i].xmax:=strtoint(sl[3]);
    Hud3[i].ymax:=strtoint(sl[4]);
    Hud3[i].minscale:=strtoint(sl[5])/100;
    Hud3[i].maxscale:=strtoint(sl[6])/100;
    Hud3[i].isBottom:=false;
     if sl[7]='1' then
       Hud3[i].isBottom:=true;
    Hud3[i].isRight:=false;
     if sl[8]='1' then
       Hud3[i].isRight:=true;
  End;



  MapShow1:=true;
  MapShow2:=true;
  MapShow3:=true;

  maplookdopy:=maplookdopy*resolutionscaley;

  sl.Destroy;
end;

procedure TMainForm.LoadIntro;
var S:TStringList;
    i:integer;
begin
//SayLoading;

{ DXMusic.Items.Clear;
     if (MusVolume>0) then
     if(fileexists('Data\Music\'+IntroTheme+'.wav')) then
     Begin

      DXMusic.Items.Add;
      DXMusic.Items[0].Wave.LoadFromFile('Data\Music\'+introtheme+'.wav');
      DXMusic.Items[0].Name:='intro';//trackname;
      DXMusic.Items[0].MaxPlayingCount:=1;
      //DXMusic.Items[0].Volume:=-10000+MusVolume*100;

      if MusVolume<>0 then
        DXMusic.Items[0].Volume:=-3000+MusVolume*30
          else DXMusic.Items[0].Volume:=-10000;

      DXMusic.Items.Restore;
     End;    }

 S:=TStringList.Create;
 S.LoadFromFile('Data\Locs\Intro'+IntToStr(IntroNumber)+'.loc');
 try
  IntroStrBegin:=StrToInt(s[0]);
  IntroCount:=StrToInt(s[1]);
  IntroTheme:=s[2];
  for i:=0 to (s.Count-4) div 2 do
  begin
    IntroX[i+1]:=StrToInt(s[i*2+3]);
    IntroY[i+1]:=StrToInt(s[i*2+4]);
      if  IntroY[i+1]<150-DeltaY/ResolutionScaleY2 then
            IntroY[i+1]:=trunc(150-DeltaY/ResolutionScaleY2);

      if  IntroY[i+1]>940+DeltaY/ResolutionScaleY2 then
            IntroY[i+1]:=trunc(940+DeltaY/ResolutionScaleY2);

  end;

 except

 end;

 S.Destroy;

MSN:=1;
CurrentScreenN:=1;
 if Hidet=true then
    AGraphics.FileName:='Data\Graphics\Intro_HD'+IntToStr(IntroNumber)+'.asdb'
     else
      AGraphics.FileName:='Data\Graphics\Intro_Ld'+IntToStr(IntroNumber)+'.asdb';

   Images2.LoadFromASDb(AGraphics);

   

   if (MusVolume>0) then
   Begin
    MenuSoundsystem.AddFromFile('Data\Music\'+IntroTheme+'.mp3');
    MenuSoundSystem.StopAll;
    MenuSoundSystem.Play(1, false);
    MenuSoundSystem.SetVolume(1,MusVolume);
   End;
  // DXMusic.Items[0].Play(false);
end;

procedure TMainForm.LoadMagz;
var
  i:integer;
  Bon:TBonus;
  Itm:Titem;
  MagzList:TstringList;
begin
    MagzList:=TstringList.Create;

    MagzList.LoadFromFile('Data\Locs\Magz.loc');

    Itm:=TItem.Create;
    for I := 1 to 9 do
    Begin
      MagzObjs[i].objname:=MagzList[(i-1)*2];
      MagzObjs[i].cost:=StrToInt(MagzList[(i-1)*2+1]);
      Itm.LoadItem(MagzList[(i-1)*2]);
      MagzObjs[i].img:=Itm.ItemImageName;
      MagzObjs[i].color:=Itm.ItemColor;
      MagzObjs[i].name:=Itm.ItemName;
      MagzObjs[i].info:=Itm.ItemInfo;
    End;
    Itm.Destroy;

    Bon:=TBonus.Create;
    for I := 10 to 15 do
    Begin
      MagzObjs[i].objname:=MagzList[(i-1)*2];
      MagzObjs[i].cost:=StrToInt(MagzList[(i-1)*2+1]);
      Bon.LoadBonus(MagzList[(i-1)*2]);
      MagzObjs[i].img:=Bon.BonusImageName;
      MagzObjs[i].color:=Bon.BonusColor;
      MagzObjs[i].name:=Bon.BonusName;
      MagzObjs[i].info:=Bon.BonusInfo;
    End;
    Bon.Destroy;

    MagzList.Destroy;

    MagzInit1:=false;
    MagzInit2:=false;
end;

procedure TMainForm.LoadMapData(FileName: string);
var i,j,mapobjcount,numb,k,l,m,n,o,p:integer;
 ppp:array[1..6] of integer;
  loadmap,loadline,s,loadcol:TStringList;
  MyTile:TSprite;
  badobj:boolean;
  par:string;
begin
  LevDials.Clear;
  AllDials.Clear;

  MapZonesCount := 0;    // 06.11.15

  if Campaign then
  Begin
    try
    if fileexists('Saves\Slot'+inttostr(slot)+'\AllDials.loc') then
      alldials.LoadfromFile('Saves\Slot'+inttostr(slot)+'\AllDials.loc');
    finally
    end;
  End;

  DialPage:=0;
  DialMode:=false;
  ScrollChoosed:=false;

  SoundSystem.StopAll;

  loadmap:=TStringList.Create;


  loadmap.LoadFromFile(filename);
  OnlyLoaded:=true;

  badobj:=false;
  mapobjcount:=0;

  LevelMission:=0;
 // Survival:=false;
  LevelMissionTip:=0;
  mapsizex:=50;
  mapsizey:=50;

  CanMicro:=false;
  if campaign then
   if HudImages.Find('level'+inttostr(level+1))>-1 then
      CanMicro:=true;

  NeedLight:=0;
  LevColor:=false;

  if Campaign then
   diffi:=difficulty
    else
     diffi:=2;

  if ultralow=false then
  if Campaign then
    Begin
    if fileexists('Data\Locs\LevColor'+inttostr(level+1)+'.loc') then
     try
      loadcol:=TStringList.Create;
      loadcol.LoadFromFile('Data\Locs\LevColor'+inttostr(level+1)+'.loc');
      levcol[1]:= strtoint(loadcol[0]);
      levcol[2]:= strtoint(loadcol[1]);
      levcol[3]:= strtoint(loadcol[2]);
      loadcol.Destroy;
      LevColor:=true;
     except
      levcol[1]:=240;
      levcol[2]:=240;
      levcol[3]:=240;
     end;
    End else
    Begin
      levcol[1]:=250;
      levcol[2]:=250;
      levcol[3]:=250;
    End;



  MapLookMenu:=false;
  MapLookT:=0;
  ShowMicro:=false;
  MicroT:=0;

  _Player:=nil;

  cleardop;

  dopparlist.Clear;

  lasercount:=0;
  mirrorcount:=0;

  i:=0;
  while (i<LoadMap.Count - 1)and(Loadmap[i]<>'//') do
   Begin

      if Pos('SizeX: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        mapsizex:=strtoint(par);


      End;

      if Pos('SizeY: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        mapsizey:=strtoint(par);
      End;

      if Pos('Load: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Load: '));
         
        if Pos('Labels',par)>1 then
        Begin
          Par:='..\Languages\'+LANG+'\Labels';
        End;
        loaddop(par); 
        dopparlist.Add(par);
        
      End;

      inc(i);
   End;

  SetLength(AIMap,mapsizeX+1,mapSizeY+1);
  SetLength(SMMap,mapsizeX+1,mapSizeY+1);
  SetLength(Larr,mapsizeX+1,mapSizeY+1);
  SetLength(AIDynMap,mapsizeX+1,mapSizeY+1);
  SetLength(AIDynSubMap,mapsizeX+1,mapSizeY+1);
//  SetLength(FogofWar,mapsizeX div 10 +1,mapSizeY div 10 +1);

  for i := 0 to mapsizeX do
    for j := 0 to mapsizeY do
    Begin
     AIMAP[i,j]:=false;
     SMMAP[i,j]:=0;
     Larr[i,j]:=0;
     AIDynMAP[i,j]:=false;
     AIDynSubMAP[i,j]:=false;
    End;

 {  for i := 0 to mapsizeX div 10 do
    for j := 0 to mapsizeY div 10 do
     FogOfWar[i,j]:=false;}


  for I :=0 to LoadMap.Count - 3 do
  Begin
    if Loadmap[i]='//' then
    Begin
      inc(mapobjcount);

      par:=Loadmap[i+1] ;
      delete(par,1,length('Name: '));
      numb:=GetObjNumber(par);



      if numb<>-1 then
         Begin

          //if (Objs[numb].Tip=1)or((Objs[numb].Tip>4)and(Objs[numb].Tip<10)) then

         case Objs[numb].Tip of

         //end;
         2: Begin
           MyTile:=TTile.Create(Engine);

            with TTile(MyTile)  do
               begin
                  MyObjN:=numb;
                  ImageName := 'Box1';
                    // if Objs[numb].Tip=1 then Begin

                      if Images.Find(Objs[numb].Img)<>-1 then
                       Begin
                        ImageName :=Objs[numb].Img;
                        Patternindex:=Objs[numb].Index;
                        Imageindex:=Objs[numb].Index;
                       End;

                      if HiDet=false then
                        if Images.Find(Objs[numb].Img+'_ld')<>-1 then
                        Begin
                         ImageName :=Objs[numb].Img+'_ld';
                         if (Objs[numb].Img<>'fon1')and(Objs[numb].Img<>'fon2')
                            and(Objs[numb].Img<>'fon3')and(Objs[numb].Img<>'fon1_2')then
                             Begin
                               ScaleX:=1.501;
                               ScaleY:=1.501
                             End else
                             Begin
                               ScaleX:=2;
                               ScaleY:=2
                             End
                        End;

                        
                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);

                    par:=Loadmap[i+4] ;
                    delete(par,1,length('Z: '));
                    Z:=strtoint(par)-3;

                    DoCollision := False;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                    Setlines;

                    
                     DrawMode:=-1;

                     {for j := 1 to 6 do Begin
                     // pars[j]:=Objs[numb].parns[j];
                      pars[j]:=0;
                    End;}

                   // Tip:=Objs[numb].Tip;

                    l:=0;
                    j:=5;
                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                      for k := 1 to 6 do
                         if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);
                                 pars[k]:=strtoint(par);

                                 if pars[1]=1 then
                                  MirrorX:=true;
                                 if pars[2]=1 then
                                  MirrorY:=true;
                              End;
                      inc(j);
                    End;


               end;


         End;

         1,5..7,16,17,18,19,20,22,26,27,28,30,31..36,39,40,50..54,55..73,81,82,95: Begin
           MyTile:=TTile.Create(Engine);

            with TTile(MyTile)  do
               begin
                    MyObjN:=numb;
                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);

                    par:=Loadmap[i+4] ;
                    delete(par,1,length('Z: '));
                    Z:=strtoint(par);

                    ObjName:=Objs[numb].Name;

                     if Objs[numb].LineFilesCount>0 then
                     Begin
                       TTile(Mytile).myLinecount:=Objs[numb].LineFilesCount;
                       SetLength(TTile(Mytile).Lines,TTile(Mytile).myLinecount);

                       for j := 0 to TTile(Mytile).MyLineCount - 1 do Begin
                         loadline:=TStringList.Create;
                         loadline.LoadFromFile(Dir0+'\Data\Physics\'+ Objs[numb].LineFiles[j]);
                         TTile(Mytile).lines[j].lineId:=strtoint(loadline[0]);
                         TTile(Mytile).lines[j].x0_1:=strtoint(loadline[1]);
                         TTile(Mytile).lines[j].y0_1:=strtoint(loadline[2]);
                         TTile(Mytile).lines[j].x0_2:=strtoint(loadline[3]);
                         TTile(Mytile).lines[j].y0_2:=strtoint(loadline[4]);
                         loadline.Destroy;
                       End;


                        ///
                     End;


                     ImageName := 'Box1';
                    // if Objs[numb].Tip=1 then Begin
                      if Images.Find(Objs[numb].Img)<>-1 then
                       Begin
                        ImageName :=Objs[numb].Img;
                       End;

                      if (HiDet=false)and(tip<>70) then
                        if Images.Find(Objs[numb].Img+'_ld')<>-1 then
                        Begin
                         ImageName :=Objs[numb].Img+'_ld';
                         ScaleX:=1.5;
                         ScaleY:=1.5;
                         if (Pos('dec',Objs[numb].Img)=1)or
                          (Pos('x_usa',Objs[numb].Img)=1) then
                          Begin
                           ScaleX:=2;
                           ScaleY:=2;
                          End;

                         if (Pos('conv1',Objs[numb].Img)>=1)or
                          (Pos('conv4',Objs[numb].Img)>=1) then
                          Begin
                           ScaleX:=1.504;
                           ScaleY:=1.504;
                          End;
                         
                        End;

                    // End;

                        AnimCount:=PatternCount;
                        AnimPos:=Objs[numb].Index;
                        Patternindex:=Objs[numb].Index;
                        Imageindex:=Objs[numb].Index;

                     z:=z-3;

                     CollideMethod:= cmRect;
                     DoCollision := True;


                    if ImageName='Box1' then
                    Begin
                     ScaleX:=Objs[numb].sizeX/50;
                     ScaleY:=Objs[numb].sizeY/50;

                    End;

                    for j := 1 to 6 do Begin
                     // pars[j]:=Objs[numb].parns[j];
                      pars[j]:=0;
                    End;

                    Tip:=Objs[numb].Tip;

                    l:=0;
                    j:=5;
                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                      for k := 1 to 6 do
                         if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);
                                 try
                                 pars[k]:=strtoint(par)
                                 except;

                                 end;

                                 if Objs[MyobjN].parns[k]='Angle' then
                                 Begin
                                  OffsetX:=ImageWidth*ScaleX/2;
                                  OffsetY:=ImageHeight*ScaleY/2;
                                  DrawMode:=1;
                                  ANGLE:=pars[k]/180*pi;
                                End;

                                if (Objs[MyobjN].Parns[1]='MirrorY')and(Pars[1]=1) then
                                  MirrorY:=true;
                                if (Objs[MyobjN].Parns[1]='MirrorX')and(Pars[1]=1) then
                                  MirrorX:=true;


                              End;
                      inc(j);
                    End;

                    loadeffs;
                    SpriteHeight:=PatternHeight*ScaleY;
                    SpriteWidth:=PatternWidth*ScaleX;
                    Setlines;
                                if angle<>0 then
                                  Begin
                                    if SpriteWidth>SpriteHeight then
                                      SpriteHeight:=SpriteWidth
                                      else
                                        SpriteWidth:=SpriteHeight;
                                  End;

                    sizexd2:=trunc(Objs[numb].SizeX/2);
                    sizeyd2:=trunc(Objs[numb].SizeY/2);

                   { if ((angle>0.7)and(angle<2.3))or((angle>3.9)and(angle<5.5)) then
                    Begin
                     sizeyd2:=trunc(Objs[numb].SizeX/2);
                     sizexd2:=trunc(Objs[numb].SizeY/2);
                    End;}


                    m:=trunc(x) div 100;
                    n:=trunc(x+SizeXd2*2-5) div 100;
                    o:=trunc(y) div 100;
                    p:=trunc(y+SizeYd2*2-5) div 100;

                    if (tip=34)or(tip=35)or(tip=39)or(tip=40) then
                    Begin
                      n:=m;
                      p:=o;
                    End;

                    if tip=73 then
                    Begin
                      Levelmissiontip:=1;
                      if pars[4]=0 then
                         inc(Levelmission);
                    End;

                    if (tip<>26)and(tip<>28)and(tip<70) then
                    for k:=m to n do
                      for l:=o to p do
                        if (k>=0)and(l>=0)and(k<=mapsizex)and(l<=mapsizey) then
                        Begin
                          case Objs[numb].freecell of
                            0: Begin
                                  AIMAP[k,l]:=true;
                                  SMMap[k,l]:=1;
                                End;

                            1: if not((k=m)and(l=o)) then
                               Begin
                                  AIMAP[k,l]:=true;
                                  SMMap[k,l]:=1;
                               End else  SMMap[k,l]:=3;

                            2: if not((k=n)and(l=o)) then
                               Begin
                                  AIMAP[k,l]:=true;
                                  SMMap[k,l]:=1;
                               End else  SMMap[k,l]:=2;

                            3: if not((k=m)and(l=p)) then
                               Begin
                                  AIMAP[k,l]:=true;
                                  SMMap[k,l]:=1;
                               End else  SMMap[k,l]:=5;

                            4: if not((k=n)and(l=p)) then
                               Begin
                                  AIMAP[k,l]:=true;
                                  SMMap[k,l]:=1;
                               End else  SMMap[k,l]:=4;

                          end;
                        End;

               end;

          End;
              4: Begin

                with  TPlayer.Create(Engine) do
               begin
                    if Mainform.Images.Find('Player')<>-1 then
                    ImageName := 'Player'
                     Else ImageName := 'Box1';

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);
                    if hidet=false then
                    Begin
                      scaleX:=1.5;
                      Scaley:=1.5;
                    End;

                    if Ultralow then
                    Begin
                      DrawMode:=1;
                      offsetx:=128;//imagewidth div 2;
                      offsety:=128; //imageheight div 2;
                    End;

                    Z:=1;
                    CollideMethod:= cmRect;
                    DoCollision := True;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
               end;

             End;
              3:
              Begin
                 with TEnemy.Create(Engine) do
                 Begin


                     EnmMyObjN:=numb;
                     ImageName := 'Box1';
                    // if Objs[numb].Tip=1 then Begin
                      if Images.Find(Objs[numb].Img)<>-1 then
                       Begin
                        ImageName :=Objs[numb].Img;
                        Patternindex:=Objs[numb].Index;
                        Imageindex:=Objs[numb].Index;
                       End;

                      if HiDet=false then
                        if Images.Find(Objs[numb].Img+'_ld')<>-1 then
                        Begin
                         ImageName :=Objs[numb].Img+'_ld';
                         ScaleX:=1.5;
                         ScaleY:=1.5;
                        End;

                      { if Ultralow then
                        //if Images.Find(Objs[numb].Img+'_uld')<>-1 then
                        Begin
                         //ImageName :=Objs[numb].Img+'_uld';
                         //ScaleX:=1.5;
                         //ScaleY:=1.5;
                         DrawMode:=1;
                        End;  }

                        DrawMode:=1;

                    EnmName:=Objs[numb].Img;

                   // MyObjN:=numb;
                    enmweap2:=0;
                   
                    EnmWeap:=Objs[numb].index;

                    if EnmName<> 'enm10' then
                      inc(Levelscore.enmscount);

                    if (EnmName='enm1')or(EnmName='enm2'){or(EnmName='Boss2')} then
                    Begin
                      ScaleX:=ScaleX*1.2;
                      Bigger:=true;
                    End;
                    ScaleY:=scaleX;

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);

                    par:=Loadmap[i+4] ;
                    delete(par,1,length('Z: '));
                    Z:=strtoint(par);

                    StartX:=trunc(X+SpriteWidth/2);
                    StartY:=trunc(Y+SpriteHeight/2);

                    l:=0;
                    j:=5;
                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                      for k := 1 to 6 do
                         if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);
                                 ppp[k]:=strtoint(par);
                      End;
                      inc(j);
                    End;

                   if (EnmName='enm3')or(EnmName='enm6')or(EnmName='enm8')
                    or(EnmName='enm9')or(EnmName='enm10')or(EnmName='Boss2')  then
                    Begin
                      if (ppp[1]<>0) then
                      Begin
                        enmweap:=ppp[1];
                      End;
                    End;

                    if (EnmName='enm1') then
                    Begin
                      if (ppp[1]<>0) then
                      Begin
                        enmweap:=ppp[1];
                      End;
                      if (ppp[2]<>0) then
                      Begin
                        enmweap2:=ppp[2];
                      End;
                    End;

                    if Pos('tur',EnmName)>=1 then
                    Begin
                        EnmWeap:=3;
                        EnmStatic:=true;
                        for j:=1 to l do
                        Begin
                         if Objs[numb].parns[j]='Color' then
                          if ppp[j]<>0 then
                            EnmWeap:=ppp[j];

                        End;


                    End;

                    SizeXdiv2:=round(ImageWidth div 2*ScaleX);
                    SizeYDiv2:=round(ImageHeight div 2*ScaleY);

                    animcount:=72;

                    Creator;

                    CollideMethod:= cmRect;
                    DoCollision := True;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                    if enmweap2=0 then
                      enmweap2:=enmweap;

                 End;
              End;
              23:
              Begin
               with  TActor.Create(Engine) do
                  begin
                    MyObjN:=numb;

                    mustdie:=false;

                    AnimSpeed:=0.3;

                    ImageName := 'Box1';

                      if Images.Find(Objs[numb].Img)<>-1 then
                       Begin
                        ImageName :=Objs[numb].Img;
                       End;

                     if HiDet=false then
                        if Images.Find(Objs[numb].Img+'_ld')<>-1 then
                        Begin
                         ImageName :=Objs[numb].Img+'_ld';
                         ScaleX:=1.5;
                         ScaleY:=1.5;
                        End;

                    AnimCount:=PatternCount;

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X0:=strtoint(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y0:=strtoint(par);

                    x:=x0;
                    y:=y0;

                    z:=6;

                    j:=5;
                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                    for k := 1 to 6 do
                      if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);
                                 case k of
                                  1:Begin
                                    ey:=strtoint(par);
                                  End;
                                  2:Begin
                                    ex:=strtoint(par);
                                  End;
                                  3:Begin
                                    if strtoint(par) = 1 then
                                    mustdie:=true;
                                  End;

                                 end;

                              End;
                      inc(j);
                    End;

                    phase:=0;

                    //ex:=800;ey:=800;
                    DrawMode:=1;
                    {SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;}
                  end;

              End;

              8:
              Begin
                with  TDopEff.Create(Engine) do
                  begin
                    MyObjN:=numb;
                    ImageName := 'Box1';
                    if Images.Find(Objs[numb].Img)<>-1 then
                        ImageName :=Objs[numb].Img;


                    AnimCount:=PatternCount;
                    AnimSpeed:=0.1*(random(2)+2);

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);
                    z:=0;

                    used:=false;
                    l:=0;
                    j:=5;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + SpriteWidth),
                    Round(Y + SpriteHeight));

                    max:=30;

                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                    for k := 1 to 6 do
                      if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);

                                 if Objs[numb].name='darkness' then
                                 Begin
                                  case k of
                                  1:Begin
                                    cnt:=strtoint(par);
                                  End;
                                  2:Begin
                                    Red:=strtoint(par);
                                  End;
                                  3:Begin
                                    Green:=strtoint(par);
                                  End;
                                  4:Begin
                                    Blue:=strtoint(par);
                                  End;
                                  end;
                                 End else

                                 case k of
                                  1:Begin
                                    x0:=strtoint(par);
                                    cnt:=strtoint(par);
                                  End;
                                  2:Begin
                                    y0:=strtoint(par);
                                  End;
                                  3:Begin
                                    max:=strtoint(par);
                                  End;
                                  4:Begin
                                    cnt:=strtoint(par)-1;
                                    if cnt<0 then cnt:=0;
                                  End;
                                  end;

                              End;
                      inc(j);
                    End;


                    if l>=2 then  Begin
                     CollideRect := Rect(Round(X+32 - x0),
                      Round(Y+32  - y0),
                      Round(X+32  + x0),
                      Round(Y+32  + y0));
                      Visible:=false;
                      drawfx:=fxadd;
                    End;

                    if Objs[numb].name='sacred' then
                    inc(Levelscore.secretscount);

                    if Objs[numb].name='levlight' then
                    Begin
                      if Ultralow=false then
                        inc(needlight);
                      visible:=false;
                    End;
                   if Objs[numb].Name='closed' then
                   Begin
                      Visible:=false;
                      CollideRect := Rect(Round(X+32 - x0),
                      Round(Y+32  - y0),
                      Round(X+32  + x0),
                      Round(Y+32  + y0));
                   End;

                   if Objs[numb].Name='scanzone' then
                   Begin
                      l:=colliderect.Left;
                      m:=colliderect.Top;
                      o:=colliderect.Right;
                      p:=colliderect.Bottom;
                      n:=max;
                      for k := 1 to 4 do
                        with  TEffectSprite.Create(Mainform.Engine) do
                        Begin
                          EffectType:=eScanLine;
                          Visible:=true;
                          Alpha:=0;
                          Z:=-10;
                          col:=n;
                         // blue:=0;
                          red:=50;
                          drawfx:=fxadd;
                          case k of
                            1: Begin
                              // LEFT
                              ImageName:='las';
                              x0:=l;
                              y0:=m;
                              x1:=o-l;
                              y1:=0;
                              ScaleX:=14;
                              ScaleY:=(p-m)/4;
                            End;
                            2:Begin
                              // RIGTH
                              ImageName:='las';
                              x0:=o;
                              y0:=m;
                              x1:=l-o;
                              y1:=0;
                              ScaleX:=14;
                              ScaleY:=(p-m)/4;
                            End;
                            3:Begin
                              // UP
                              ImageName:='las2';
                              x0:=l;
                              y0:=m;
                              x1:=0;
                              y1:=p-m;
                              ScaleX:=(o-l)/4;
                              ScaleY:=14;
                            End;
                            4:Begin
                              // DOWN
                              ImageName:='las2';
                              x0:=l;
                              y0:=p;
                              x1:=0;
                              y1:=m-p;
                              ScaleX:=(o-l)/4;
                              ScaleY:=14;
                            End;
                          end;
                          SpriteWidth:=8*ScaleX;
                          SpriteHeight:=8*ScaleY;
                      end;
                    End;



                    if Objs[numb].name='bombin' then
                    Begin
                      LevelMission:=cnt;
                      //LMMax:=LevelMission;
                      LevelMissionTip:=1;
                      visible:=false;
                      CollideRect := Rect(Round(X-100),
                      Round(Y-10),
                      Round(X+100),
                      Round(Y+10));
                    End;

                    if Objs[numb].name='bombin2' then
                    Begin
                      visible:=false;
                      CollideRect := Rect(Round(X-100),
                      Round(Y-10),
                      Round(X+100),
                      Round(Y+10));
                    End;

                    if Objs[numb].name='arcade' then
                    Begin
                      LevelMissionTip:=2;
                      LevelMission:=1;
                      visible:=false;
                      if cnt=0 then
                      Begin
                        if altweaponscount<4 then
                        Begin
                          inc(altweaponscount);
                          altweapons[altweaponscount]:=3;
                          inc(altweaponscount);
                          altweapons[altweaponscount]:=4;
                          inc(altweaponscount);
                          altweapons[altweaponscount]:=6;

                          for j := 1 to 7 do
                            weapons[j].Count:=35;
                        End;
                        altweapon:=altweapons[1];
                        cnt:=1;
                      End
                       else
                       Begin
                           if (cnt=2)or(cnt=5) then
                           begin
                              LevelMissionTip:=5;
                              LevelMission:=1;
                           end;
                       End;
                    End;

                    if Objs[numb].name='darkness' then
                    Begin
                      if cnt<>0 then
                       //if Hieffs then
                        fonar:=true;

                        fonarcolor:=crgb1(Red,Green,Blue);

                      visible:=false;
                    End;


                    if Objs[numb].name='bl1' then
                    Begin
                      levelMissionTip:=4;
                      LevelMission:=0;
                      Doorcols[8]:=12;
                      visible:=false;
                    End;


                    if Objs[numb].name='noway' then
                    Begin
                      visible:=false;

                      CollideRect := Rect(Round(X+32 - x0),
                      Round(Y+32  - y0),
                      Round(X+32  + x0),
                      Round(Y+32  + y0));

                      SpriteHeight:=y0*2;
                      SpriteWidth:=x0*2;

                      cnt:=0;
                      if X0<y0 then cnt:=1;

                    End;

                    if Objs[numb].name='plasmid' then
                    Begin
                      if cnt=0 then cnt:=8;
                      Red:=Redw[cnt];
                      Green:=Greenw[cnt];
                      Blue:=Bluew[cnt];
                      inc(Levelscore.plasmidscount);
                    End;

                    CollideMethod:= cmRect;
                    DoCollision := True;

                    if Objs[numb].name='end' then
                    {Pos(Objs[MyObjN].Name,'end')=1} 
                    Visible:=false;

                    AnimPos:=random(AnimCount);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;


                    if Objs[numb].name='noway' then
                    Begin
                      SpriteHeight:=y0*2;
                      SpriteWidth:=x0*2;
                    End;

                  end;

              End;

              12,15:
              Begin
                with  TMina.Create(Engine) do
                  begin
                    MyObjN:=numb;
                    ImageName := 'Box1';
                    if Images.Find(Objs[numb].Img)<>-1 then
                        ImageName :=Objs[numb].Img;

                    AnimCount:=PatternCount;
                    AnimSpeed:=0.1*(random(2)+2);
                    AnimPos:=random(AnimCount);

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);
                    z:=0;
                    AnimPos:=random(AnimCount);

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                    playersmina:=false;

                    if Objs[numb].Tip=15 then
                      wall:=true;

                    CollideRect := Rect(Round(X),Round(Y),Round(X )+ 100,Round(Y )+ 100);

                    Minashape.POsX:=x+50;
                    Minashape.posY:=y+50;

                    if wall then
                    Begin
                     Minashape.POsX:=x+SpriteWidth/2;
                     Minashape.posY:=y+SpriteHeight/2;
                     statics:=true;
                     OldX:=x;
                     OldY:=y;
                    End;

                    for j:=1 to 2 do
                    Begin
                      Minashape.x[j]:=Minashape.x0[j]+Minashape.PosX;
                      Minashape.y[j]:=Minashape.y0[j]+Minashape.PosY;
                    End;

                    
                  end;

              End;

              10,11,13,9: Begin
                 if not((diffi>1)and(Objs[numb].Tip=11)) then
                  with  TCapsule.Create(Engine) do
                  begin
                    MyObjN:=numb;
                    ImageName := 'Box1';
                    if Images.Find(Objs[numb].Img)<>-1 then
                        ImageName :=Objs[numb].Img;

                    AnimCount:=PatternCount;
                    AnimSpeed:=0.1*(random(2)+2);

                    par:=Loadmap[i+2] ;
                    delete(par,1,length('X: '));
                    X:=strtofloat(par);

                    par:=Loadmap[i+3] ;
                    delete(par,1,length('Y: '));
                    Y:=strtofloat(par);

                    AnimPos:=random(AnimCount);

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                    SizeYd2:=ImageHeight div 2;
                    SizeXd2:=ImageWidth div 2;

                    if Objs[numb].Tip=9 then
                          tip:=5;

                    IsDone:=false;

                    l:=0;
                    j:=5;
                    if (Objs[numb].Tip<>13)and(Tip<>5) then
                    Begin
                    while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                    Begin
                    for k := 1 to 6 do
                      if Objs[numb].parns[k]<>'' then
                          if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                              Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);

                                 if (par<>'')and(par<>'0') then
                                  if FileExists('Data\Objects\Items\'+par+'.loc') then
                                  Begin
                                    InCapsule[l]:=TItem.Create;
                                    TItem(InCapsule[l]).LoadItem(par);
                                  End else
                                  if FileExists('Data\Objects\Bonus\'+par+'.loc') then
                                  Begin
                                    InCapsule[l]:=TBonus.Create;
                                    TBonus(InCapsule[l]).LoadBonus(par);
                                  End
                                 { if Objs[numb].Tip=10 then
                                  Begin
                                    InCapsule[l]:=TItem.Create;
                                    TItem(InCapsule[l]).LoadItem(par);
                                  End else
                                  if Objs[numb].Tip=11 then
                                  Begin
                                    InCapsule[l]:=TBonus.Create;
                                    TBonus(InCapsule[l]).LoadBonus(par);
                                  End else
                                  if Objs[numb].Tip=21 then
                                  Begin
                                    !!!!InCapsule[l]:=TBonus.Create;
                                    TBonus(InCapsule[l]).LoadBonus(par);
                                  End }

                              End;
                      inc(j);
                    End;
                    End else
                      Begin
                        tip:=4;
                        if pos('attery',Objs[MyObjN].Name)>0 then
                          tip:=3;
                        if Objs[numb].Tip=9 then
                          tip:=5;

                        if pos('bomba',Objs[MyObjN].Name)>0 then
                          tip:=8;

                        if (tip=4)or(tip=5) then
                        Begin



                          l:=0;
                          j:=5;
                          while (i+j<=LoadMap.Count - 1)and(Loadmap[i+j]<>'//') do
                          Begin
                            for k := 1 to 6 do
                              if Objs[numb].parns[k]<>'' then
                                if Pos(Objs[numb].parns[k],loadmap[i+j])=1 then
                                Begin
                                 inc(l);
                                 par:=loadmap[i+j];
                                 delete(par,1,length(Objs[numb].parns[k])+2);

                                  if (Objs[MyobjN].parns[k]='Color')then
                                  Begin
                                     col:=strtoint(par);
                                     if col>0 then
                                      Levelscore.plasmidscount:=Levelscore.plasmidscount+3;
                                  End;
                                  if (Objs[MyobjN].parns[k]='Message') then
                                  Begin
                                     col:=strtoint(par);
                                  End;
                                  if (Objs[MyobjN].parns[k]='Done') then
                                  Begin
                                     if par<>'0' then
                                      IsDone:=true;
                                  End;
                                  if (Objs[MyobjN].parns[k]='Count') then
                                  Begin
                                    mcount:=strtoint(par);
                                  End;
                                End;
                            inc(j);
                            End;
                        End;
                      End;

                    if (IsDone)and(tip=5) then
                    ImageName:= 'mayak_off';

                    if tip=5 then
                    Begin
                      ScaleX:=Scalex*0.8;
                      ScaleY:=scaleX;
                      Capsuleshape.RAD:=40;
                    End;

                    Impulse1.ImpPower:=0;
                    SizeYd2:=trunc(ImageHeight*ScaleX/2);
                    SizeXd2:=trunc(ImageWidth*ScaleY/2);
                    //SizeYd2:=ImageHeight div 2;
                    //SizeXd2:=ImageWidth div 2;
                    Z:=0;
                    CollideMethod:= cmRect;
                    DoCollision := True;
                  end;
              End

         end;

         End else
         Begin
         badobj:=true;
          Showmessage('ERROR in line: '+inttostr(i));
         End;
    End;

   End;


  /// DELETING MINIMAP ARTEFACTS
  for i := 1 to mapsizeX-1 do
   for j := 1 to mapsizeY-1 do
    Begin
     if SMMAP[i,j]>1 then
      if (SMMAP[i-1,j]>0)and(SMMAP[i,j-1]>0)and
        (SMMAP[i+1,j]>0)and(SMMAP[i,j+1]>0) then
          SMMAP[i,j]:=1;

     if SMMAP[i,j]=1 then
      if (SMMAP[i-1,j]=0)and(SMMAP[i,j-1]=0)and
        (SMMAP[i+1,j]=0)and(SMMAP[i,j+1]=0) then
        Begin
          SMMAP[i,j]:=6;
          AIMAP[i,j]:=false;
        End;

    End;


   loadmap.Destroy;

   RebuildLasers;

  if mapobjcount=0 then
    Showmessage('ERROR! MapFile corruped!')
  else
    if badobj=true then
      Showmessage('ERROR! Some errors in objects of map');


   mss:=mapsizex;
   micsx:=0;
   micsy:=0;
   if mapsizex<mapsizey then
   begin
      mss:=mapsizey;
      micsx:=trunc((-mapsizeX+mapSizey)*100*ResolutionScaleX/mapsizeY);
   end
    else 
      micsy:=trunc((mapsizeX-mapSizey)*100*ResolutionScaleY/mapsizeX);

  /// Inventory Hints

  shint.name:='';
  shint2.name:='';

 if Campaign then
 Begin
  if fileexists('Data\Locs\LHint'+inttostr(level+1)+'.loc') then
  Begin
    s:=Tstringlist.Create;
    s.LoadfromFile('Data\Locs\LHint'+inttostr(level+1)+'.loc');

    if s.Count>1 then
    Begin
      shint.name:=s[0];
      shint.number:=StrToInt(s[1]);
    End;
    if s.Count>3 then
    Begin
      shint2.name:=s[2];
      shint2.number:=StrToInt(s[3]);
    End;

  End;
 End
  else
  Begin
    if mapslist<>nil then
    if mapslist.Count>MapN then
    if fileexists('Data\Locs\'+mapsList[MapN]+'.loc') then
    Begin
      s:=Tstringlist.Create;
      s.LoadfromFile('Data\Locs\'+mapsList[MapN]+'.loc');
      if s.Count>1 then
      Begin
        shint.name:=s[0];
        shint.number:=StrToInt(s[1]);
      End;
      if s.Count>3 then
      Begin
        shint2.name:=s[2];
        shint2.number:=StrToInt(s[3]);
      End;
    End;
  End;


end;

procedure TMainForm.LoadMapLevel(stagename: string);
var i:integer;
begin
  CheckPointenabled:=false;
  SayLoading;
  Timer.Enabled:=false;
  Engine.Clear;
  GameInit;
  GoBlack:=false;
  Campaign:=false;
  Globalscore:=1500;
  levelscore.total:=globalscore;

  MapZonesCount := 0;

  for i:=1 to 4 do
  Begin
    if I<=3 then
      Bonuses[i]:=nil;
    Items[i]:=nil;
  End;


  if fileexists('UserMaps\'+stagename) then
     LoadMapData('UserMaps\'+stagename)
      else Begin
        inmenu:=true;
        menun:=1;
        MessageDlg('Файл "UserMaps\'+stagename+'" не найден', mtError, [mbOk] , 0) ;
      End;

  Timer.Enabled:=true;
end;

procedure TMainForm.LoadMenu;
var i,j:integer;
    str:TStringList;
begin

          str:=TStringList.Create;
           for i:=0  to 90 do
           Begin
             if fileexists('Data\Menus\Main\'+inttostr(i)+'.loc') then
             Begin
                str.LoadFromFile('Data\Menus\Main\'+inttostr(i)+'.loc');
                with Menus[i] do
                Begin
                  x:=strtoInt(str[0]);
                  h:=strtoInt(str[1]);
                  bcount:=(str.Count)div 4-1;
                  if bcount>0 then
                  Begin
                   Setlength(buttons,bcount);
                    for J := 1 to bcount do
                    Begin
                      buttons[j-1].x:=strtoint(str[(j)*4]);
                      buttons[j-1].y:=strtoint(str[(j)*4+1]);
                      buttons[j-1].name:=strtoint(str[(j)*4+2]);
                      buttons[j-1].onclick:=strtoint(str[(j)*4+3]);

                      if (i=18)and(j>0) then
                        buttons[j-1].y:=buttons[j-1].y-MenuDopY+65;
                    End;
                  End;
                End;

             End;
           End;
           str.Destroy;
end;

procedure TMainForm.LoadObjs;
  const
  n=12;
  Param:array[1..n] of String=('Img: ','Index: ','R: ','G: ','B: ','Type: ',
                              'Anim: ','SizeX: ','SizeY: ','Line: ','*','Free: ');

  var s,files:TstringList;
  i,j,k,l:integer;
  s1,s2:ShortString;
  LinesFil:TStringlist;
  par,name,filename:String;
begin
  s:=TstringList.Create;
  files:=TstringList.Create;

  Setcurrentdir(Dir0);
  s1:='Data\Objects\';
  s2:='*.obj';
  files:=Getfiles(s1,s2);

  ObjCount:=files.Count+1;
 // SetLength(Objs,ObjCount);

  LinesFil:=TStringList.Create;


  for k:=0 to files.Count-1 do
  Begin
    filename:=files[k];
    s.LoadFromFile(Dir0+'\'+s1+filename);
    name:=filename;
    delete(name,length(name)-3,4);
    Objs[k+1].Name:=name;
    Objs[k+1].FreeCell:=0;
    Objs[k+1].linefilescount:=0;
    LinesFil.Clear;
    for I := 1 to 6 do
        Objs[k+1].parns[i]:='';

    l:=0;
    //showmessage(name);
    for I := 0 to s.Count - 1 do
        for j := 1 to n do
            if Pos(Param[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(param[j]));
               case j of
                  1: {Img} Objs[k+1].Img:=par;
                  2: {Index} Objs[k+1].Index:=StrToInt(par);
                  3: {R} Objs[k+1].R:=StrToInt(par);
                  4: {G} Objs[k+1].G:=StrToInt(par);
                  5: {B} Objs[k+1].B:=StrToInt(par);
                  6: {Type} Objs[k+1].Tip:=StrToInt(par);
                  7: {Anim} Objs[k+1].anim:=StrToInt(par);
                  8: {SizeX} Objs[k+1].sizeX:=StrToInt(par);
                  9: {SizeY} Objs[k+1].sizeY:=StrToInt(par);
                  10: {Line} Begin
                    Linesfil.Add(par);
                  End;
                  12: Objs[k+1].FreeCell:=StrToInt(par);
                  11: {*parns} Begin
                    if l<6 then inc(l);
                    Objs[k+1].parns[l]:=par;
                  End;
               end;
             End;

      Objs[k+1].Linefilescount:=Linesfil.Count;

     // if objs[k].Index<>0 then
     //showmessage(Objs[k].Img);

      if Objs[k+1].Linefilescount>0 then
      Begin
         Setlength(Objs[k+1].Linefiles,Objs[k+1].Linefilescount);
         for I := 0 to Linesfil.Count - 1 do
           Objs[k+1].LineFiles[i]:=Linesfil[i];
      End;

     if Objs[k+1].Tip=3 then
     Begin
       Objs[k+1].DopList:=TStringList.Create;
       if fileexists('Data\Locs\'+Objs[k+1].Img+'.pts')=true then
          Objs[k+1].DopList.LoadFromFile('Data\Locs\'+Objs[k+1].Img+'.pts');
     End;


  end;
  s.Destroy;
  LinesFil.Destroy;
  files.Destroy;
end;

procedure TMainForm.LoadPic;
var
 Bitmap: TBitmap;
 Jpg:TJpegImage;
begin
 Bitmap:=TBitmap.Create;
 Jpg:=TJpegImage.Create;
 try
  Canvas.Brush.Color:=clBlack;
  Canvas.Rectangle(0,0,Width,Height);

  if fileexists('DATA\Languages\'+lang+'\loading.jpg') then
  Begin
    Jpg.LoadFromFile('DATA\Languages\'+lang+'\loading.jpg');
    Bitmap.Assign(Jpg);

     Canvas.Draw(width div 2 - 200, height div 2 - 70, Bitmap);
    //Canvas.Brush.Bitmap:=Bitmap;
    //Canvas.FillRect(Rect(0,0,Bitmap.Width,Bitmap.Height));
  End;
 finally
  Canvas.Brush.Bitmap:=nil;
  Jpg.Free;
  Bitmap.Free;
 end;
end;

procedure TMainForm.LoadPreviews;
var PrewList:TStringList;
    s1,s2:ShortString;
    i:integer;
    size1,size2:TPoint;
begin

  {список карт}
    
  try

    MapsList.Clear;
    s1:='UserMaps\';
    s2:='*.map';
    SetCurrentDir(Dir0);
    MapsList:=Mainform.GetFiles(s1,s2);

  finally

  end;



  {картинки к картам}
  try
    PrewList:=TStringList.Create;
    PrewList.Clear;
    s1:='UserMaps\Previews\';
    s2:='*.bmp';
    SetCurrentDir(Dir0);
    PrewList:=Mainform.GetFiles(s1,s2);
    size1.X:=200;
    size1.Y:=200;
    size2.X:=256;
    size2.Y:=256;

    for I := 0 to PrewList.Count - 1 do
    Begin
      MapPreviews.AddFromFile(s1+PrewList[i],
      size1,size1,size2,aqHigh,alNone,false,0,0);
      MapPreviews.Item[MapPreviews.Count-1].Name:=PrewList[i];
     // Showmessage(PrewList[i]);
    End;
    PrewList.Destroy;
  finally

  end;

    
end;

procedure TMainForm.LoadProfile;
begin


end;

procedure TMainForm.LoadProfileProgress;
var mapfile:Tstringlist;
  i,j:integer;
begin


   for i:=1 to 4 do
   Begin
    if Items[i]<>nil then
      Items[i]:=nil;
     if i<=3 then
      Bonuses[i]:=nil;
   End;

   hintsOn:=true;

  level:=0;
  mapfile:=Tstringlist.Create;

  if fileexists('Saves\Slot'+inttostr(slot)+'\Hints.loc') then
  Begin
     mapfile.LoadfromFile('Saves\Slot'+inttostr(slot)+'\Hints.loc');
     if mapfile[0]='0' then
      hintsOn:=false;
  End;

  if fileexists('Saves\Slot'+inttostr(slot)+'\Global.loc') then
  Begin

    mapfile.LoadfromFile('Saves\Slot'+inttostr(slot)+'\Global.loc');

    j:=0;

    for i := 0 to LevelCodes.Count - 1 do
     if mapfile[0]=levelcodes[i] then
      Begin
        j:=i;
        Break;
      End;

    level:=j;

 /// ITEMS

  for i:=0 to 3 do
  Begin
    if mapfile[i*2+1]<>'' then Begin
      items[i+1]:=TItem.Create;
      items[i+1].LoadItem(mapfile[i*2+1]);
      items[i+1].ItemCurrenttime:=strtoint(mapfile[i*2+2]);
    End;
  End;

  /// BONUSES

  for i:=1 to 3 do
  Begin
    if mapfile[i+8]<>'' then
    Begin
     Bonuses[i]:=TBonus.Create;
     Bonuses[i].LoadBonus(mapfile[i+8]);
    End;
  End;


  //// SCORE
  allscore:=0;
  playtime:=0;
  globalscore:=strtoint(mapfile[12])-9876;
  allscore:=strtoint(mapfile[14])-9876;
  Levelscore.total:=globalscore;

  ////
  //Медали
  for I := 1 to 5 do
  Begin
   medals[i]:=0;
   medals[i]:=strtoint(mapfile[14+i]);
  End;

  // dhtvz
  playtime:=strtoint(mapfile[21]);
  showtime:=SecToHMS(playtime,true);

  Cheater:=false;
  if mapfile[13]='1' then Cheater:=true;

  difficulty:=strtoint(mapfile[20]);
  diffi:=difficulty;
  End;

  checkedlevel:=-1;
  if fileexists('Saves\Slot'+inttostr(slot)+'\CheckLevel.loc') then
  Begin
    mapfile.LoadfromFile('Saves\Slot'+inttostr(slot)+'\CheckLevel.loc');
    if mapfile.Count>0 then
     checkedlevel:=strtoint(mapfile[0]);
  End;

  /// Статистика


  if fileexists('Saves\Slot'+inttostr(slot)+'\Stat.loc') then
  Begin
    mapfile.LoadFromFile('Saves\Slot'+inttostr(slot)+'\Stat.loc');
    mapfile:=Uncoding(mapfile);

    for I := 0 to (mapfile.Count-1)div 6  do
      for J := 0 to 5 do
        stats[i,j]:=strtoint(mapfile[i*5+j]);

  End else
   for I := 0 to levels.Count-1  do
    for J := 0 to 5 do
      stats[i,j]:=-1;

    mapfile.Clear;
  mapfile.Add(inttostr(slot));
  mapfile.SaveToFile('Data\Locs\CurrentUser.loc');

  mapfile.destroy;
             // xcxc
end;

procedure TMainForm.LoadProfNames;
var s:TStringList;
 i:byte;
begin
  if fileexists('SAVES\Profnames.loc') then
  Begin
    s:=TStringList.Create;
    s.loadfromfile('SAVES\Profnames.loc');
    for i:=1 to 3  do
    if s.count>=i then
     Begin
       profnames[i]:=s[i-1];
     End;
     s.Destroy;
  End;
end;

procedure TMainForm.LoadScenarioText;
var i,j:integer;
begin
//
ScenarioTextBegin:=0;
ScenarioTextEnd:=0;
j:=0;
for I := 0 to Scenario.Count - 1 do
  Begin
    if scenario[i]='//' then
    Begin
      inc(j);

      if j=level then
      Begin
        ScenarioTextBegin:=i+1;
        ScenarioTextEnd:=i;
      End;
      if j=level+1 then
        ScenarioTextEnd:=i-1;
      End;

  End;
end;

procedure TMainForm.LoadSettings;
  const
  n=21;
  Commands:array[1..n] of String=('ResolutionX: ','ResolutionY: ','BitCount: ',
  'Windowed: ','AA: ','MouseSpeed: ','VSync: ','Console: ','BigWindow: ',
  'HighDetail: ','HighEffects: ','MusVolume: ','SndVolume: ','Cheater: ',
  'Language: ','MaxFPS: ','LowAnim: ','FXLight: ','Camera: ','CutScreen: ','ShowDialogs: ');// НАСТРОЙКИ!!!

  var s:TstringList;
  i,j:integer;
  par:String;
begin

    s:=TstringList.Create;
    dopparlist:=Tstringlist.Create;

    //// ПО УМОЛЧАНИЮ
       Device.Width:=1024;
       Device.Height:=768;
       Device.BitDepth:=bdHigh;
       Developer:=false;
       HiEffs:=false;
       CutScreen:=false;
       Device.Vsync:=false;
       mspd:=2;
       Device.Windowed:=false;
       Hidet:=false;
       Ultralow:=false;
       LightMode:=false;
       CameraMode:=cmCenter;
       showDLG:=true;
       mb1:=0;
       mb2:=1;
       mb3:=2;
       mb4:=0;

    s.LoadFromFile('Data\Mouse.cfg');
    if s[0]='Reverse' then
    Begin
      mb1:=1;
      mb2:=0;
    End;

    if s.Count>1 then
      if s[1]='Mb2' then
        mb4:=1
      else
        if s[1]='Mb3' then
          mb4:=2;

    s.LoadFromFile('Data\Config.cfg');

    ///// ЗАГРУЗКА
    for I := 0 to s.Count - 1 do
      Begin
        for j := 1 to n do
          Begin
            if Pos(commands[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(commands[j]));
               case j of

                  1:{ResolutionX:} Begin
                     Device.Width:=Strtoint(par);
                  End;
                  2:{ResolutionY:} Begin
                     Device.Height:=Strtoint(par);
                  End;
                  3:{BitCount:} Begin
                     if par='32' then
                       Device.BitDepth:=bdHigh
                         else  Device.BitDepth:=bdLow;
                  End;
                  4:{Windowed:} Begin
                    if par='y' then
                      Device.Windowed:=true
                       else Begin
                        Device.Windowed:=false;
                        BorderStyle:=bsnone;
                       End;
                  End;
                  5:{AA:} Begin
                     if par='y' then
                      MyCanvas.Antialias:=true
                       else MyCanvas.Antialias:=false;
                  End;
                  6:{MouseSpeed:} Begin
                    mspd:=StrToInt(par);
                  End;
                  7:{VSync:} Begin
                     if par='y' then
                      Device.VSync:=true
                       else Device.Vsync:=false;
                  End;
                  8:{Console:} Begin
                     if par='y' then
                      Developer:=true
                       else Developer:=false;
                  End;
                  9:{BigWindow:} Begin
                     if par='y' then Begin
                       {ClientWidth:=1024;
                       ClientHeight:=768; }
                       ClientWidth:=Device.Width;//1024;
                       ClientHeight:=Device.Height;//trunc(1024*Device.Height/Device.Width);
                     End
                       else
                       Begin
                          ClientWidth:=800;
                          ClientHeight:=600;
                       End;
                  End;
                  10:{HighDetail:} Begin
                    if par='y' then
                      Hidet:=true;
                  End;
                  11:{HighEffects:} Begin
                    if par='y' then
                      Hieffs:=true;
                  End;
                  12:{MusVolume:} Begin
                     Musvolume:=StrToInt(par);
                  End;
                  13:{SndVolume:} Begin
                   ///
                     SoundVolume:=StrToInt(par);
                  End;
                  14:{Cheater:} Begin
                   { if par='y' then
                      Cheats:=true;}
                  End;
                  15:{Language:} Begin
                    lang:=par;
                  End;
                  16:{MaxFPS:} Begin
                    Timer.MaxFPS:=strtoint(par);
                  End;
                  17:{LowAnim:} Begin
                    if par='y' then
                      Ultralow:=true;
                  End;
                  18:{FXLight:} Begin
                    if par='y' then
                      LightMode:=true;
                  End;
                  19:{Camera:} Begin
                    if par='2' then
                      CameraMode:=cmMove;
                  End;
                  20:{CutScreen:} Begin
                    if par='y' then
                      CutScreen:=true;
                  End;
                  21:{DLG:} Begin
                    if par='y' then
                      ShowDLG:=true
                       else
                        ShowDLG:=false;
                  End;
               end;
             End;
          End;
      End;



    s.destroy;
end;

procedure TMainForm.LoadStage(stagename:string);
begin
//
  CheckPointenabled:=false;
  SayLoading;
  Timer.Enabled:=false;
  Engine.Clear;
  GameInit;
  GoBlack:=false;

  if fileexists('Data\Maps\'+stagename) then
     LoadMapData('Data\Maps\'+stagename)
      else Begin
        inmenu:=true;
        menun:=1;
        MessageDlg('Файл "Data\Maps\'+stagename+'" не найден', mtError, [mbOk] , 0) ;
      End;

  Timer.Enabled:=true;
end;

procedure TMainForm.LookHint(Itmname: string);
begin

  if shint.name<>'' then
    if shint.name=Itmname then
    Begin
       hintN:=shint.number;
       gethinticons;
       hintmenu:=true;
       omx:=mx;
       omy:=my;
       pressed[0]:=true;
       mdown[0]:=false;
       shint.name:='';
    End;

  if shint2.name<>'' then
    if shint2.name=Itmname then
    Begin
       hintN:=shint2.number;
       gethinticons;
       hintmenu:=true;
       omx:=mx;
       omy:=my;
       pressed[0]:=true;
       mdown[0]:=false;
       shint2.name:='';
    End;

end;

procedure TMainForm.MapBorder;
var xmin,ymin,xmax,ymax:integer;
begin

 /// Лево
 xmin:=trunc(((-Engine.WorldX)*Engine.WorldScaleX));
 xmax:=xmin+trunc(200*Engine.WorldScaleX);

 if (xmin>0) then
  MyCanvas.Rectangle(0,0,xmin+1,Device.Height,clBlack,ClBlack,FxNone);
 if (xmax>0) then
  MyCanvas.DrawStretch(Images.Image['Border1'],0,xmin,0,xmax,Device.Height,false,false,clBlack4,FxBlend);

  // Верх
 ymin:=trunc(((-Engine.WorldY)*Engine.WorldScaleY));
 ymax:=ymin+trunc(200*Engine.WorldScaleY);

 if (ymin>0) then
  MyCanvas.Rectangle(0,0,Device.Width,ymin+1,clBlack,ClBlack,FxNone);
 if (ymax>0) then
  MyCanvas.DrawStretch(Images.Image['Border2'],0,0,ymin,Device.Width,ymax,false,false,clBlack4,FxBlend);


 /// Право
 xmin:=trunc((((mapsizex+1)*100-Engine.WorldX)*Engine.WorldScaleX));
 xmax:=xmin-trunc(200*Engine.WorldScaleX);

 if (xmin>0) then
  MyCanvas.Rectangle(xmin-1,0,Device.Width,Device.Height,clBlack,ClBlack,FxNone);
 if (xmax>0) then
  MyCanvas.DrawStretch(Images.Image['Border1'],0,xmax,0,xmin,Device.Height,true,false,clBlack4,FxBlend);


 if Levelmissiontip<>2 then
 begin
  // Низ
   ymin:=trunc((((mapsizey+1)*100-Engine.WorldY)*Engine.WorldScaleY));
   ymax:=ymin-trunc(200*Engine.WorldScaleY);


   if (ymin>0) then
      MyCanvas.Rectangle(0,ymin-1,Device.Width,Device.Height,clBlack,ClBlack,FxNone);
   if (ymax>0) then
      MyCanvas.DrawStretch(Images.Image['Border2'],0,0,ymax,Device.Width,ymin,false,true,clBlack4,FxBlend);
 end
   else
     Begin
        ymin:=trunc((((mapsizey+1)*100-100-Engine.WorldY)*Engine.WorldScaleY));
        ymax:=ymin-trunc(1000*Engine.WorldScaleY);


      if (ymin>0) then
        MyCanvas.Rectangle(0,ymin-10,Device.Width,Device.Height,clWhite,ClWhite,FxNone);
         if (ymax>-500) then
          MyCanvas.DrawStretch(Images.Image['Border2_'],0,0,ymax,Device.Width,ymin,false,true,clWhite4,FxBlend);

     End;
  ///

end;

procedure TMainForm.MenuSoundSystemFadeOutFinalize(Sender: TObject;
  Index: Integer; Name: string);
begin
inherited;
SoundSystem.FadeIn(Index,10);
SoundSystem.Stop(Index);
end;

procedure TMainForm.MouseHint;
var hintfile:TstringList;
begin
 if mdown[0] then
  Begin

    if (hud_currentzone=100) then
    Begin
      hintmenu:=false;
      DXWave.Items.Find('mousein.wav').Play(false);  ///1308
      if inventory=false then
      begin
        mx:=omx;
        my:=omy;
      end;
      canshoot:=false;
    End;



    if (hud_currentzone=101) then   {!!! Newnewnew }
    Begin
      HintsOn:=not(HintsOn);
      canshoot:=false;
      hintfile:=Tstringlist.Create;
      if hintson then
        hintfile.Add('1')
          else
            hintfile.Add('0');
      hintfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Hints.loc');
    End;

  End;
end;

procedure TMainForm.MouseInventory;
var i:integer;
    _x,_y,_h,_w,_scale:real;
    str1W,Str2W,strH,stt:integer;
    str1,str2,str3:string;
    clone:boolean;
    Choosing:TObject;
begin
///
  hud_currentzone:=0;

  for i := 0 to 25 do
    if Hud_Hotzones[i].no<>0 then
    begin
      _scale:=Hud[hud_hotzones[i].no].cscale;
      _w:=hud_hotzones[i].w*_scale*ResolutionScaleX;
      _h:=hud_hotzones[i].h*_scale*ResolutionScaleY;
      _x:=(Hud[hud_hotzones[i].no].cx)+hud_hotzones[i].x*_scale*ResolutionScaleX;
      _y:=(Hud[hud_hotzones[i].no].cy)+hud_hotzones[i].y*_scale*ResolutionScaleY;

       if DrawDop then
        MyCanvas.Circle(trunc(_x),trunc(_y),
        trunc(_w/2),clBlue,fxNone);

     { if (mx>_x-_w/2) and (mx<_x+_w/2) and
         (my>_y-_h/2) and (my<_y+_h/2) then}
       if (sqrt(sqr(mx-_x)+sqr(my-_y))<_w/2) then
          hud_currentzone:=i;

       if (DialMode)or(DialHudT>0) then
       Begin
        if hud_currentzone<>15 then
          hud_currentzone:=0;
       End;

       ////////// ITEMS
       if (Hud_Currentzone>10)and(Hud_currentZone<15) then
       Begin
         if Items[Hud_Currentzone-10]<>nil then
         Begin
          str1:=Items[Hud_Currentzone-10].ItemName;
          str2:=Items[Hud_Currentzone-10].ItemInfo;
          str3:=ItemsList[1]+' '+inttostr(trunc(Items[Hud_Currentzone-10].ItemCurrenttime));
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));
          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),trunc(strH*2.9),crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
         Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;
      End;

      //// BONUSes
      if (Hud_Currentzone>7)and(Hud_currentZone<11) then
       Begin
         if Bonuses[Hud_Currentzone-7]<>nil then
         Begin
          str1:=Bonuses[Hud_Currentzone-7].BonusName;
          str2:=Bonuses[Hud_Currentzone-7].BonusInfo;
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));
          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),strH*2,crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;
      End;


       if (Hud_Currentzone>=17)and(Hud_currentZone<=22) then
       Begin
       if InSpace[Hud_Currentzone-16]<>nil then
       Begin
         //// ITEMS


         if InSpace[Hud_Currentzone-16]is TItem then
         Begin
          str1:=TItem(InSpace[Hud_Currentzone-16]).ItemName;
          str2:=TItem(InSpace[Hud_Currentzone-16]).ItemInfo;//+' '+inttostr(trunc(TItem(InSpace[Hud_Currentzone-16]).ItemCurrenttime));
          str3:=ItemsList[1]+' '+inttostr(trunc(TItem(InSpace[Hud_Currentzone-16]).ItemCurrenttime));
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));

          if str1w>str2w then
          str2w:=str1w;


          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),trunc(strH*2.9),crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
         Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;

       //////Bonuses
        if InSpace[Hud_Currentzone-16]is TBonus then
         Begin
          str1:=TBonus(InSpace[Hud_Currentzone-16]).BonusName;
          str2:=TBonus(InSpace[Hud_Currentzone-16]).BonusInfo;
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));
          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),strH*2,crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;


      End;
       End;


    end;


   if DialMode then
    Begin

      i:=16;
      _scale:=Hud[hud_hotzones[i].no].cscale;
      _w:=hud_hotzones[i].w*_scale*ResolutionScaleX;
      _h:=hud_hotzones[i].h*_scale*ResolutionScaleY;
      _x:=(Hud[hud_hotzones[i].no].cx)+hud_hotzones[i].x*_scale*ResolutionScaleX;
      _y:=(Hud[hud_hotzones[i].no].cy)+hud_hotzones[i].y*_scale*ResolutionScaleY;

       if (sqrt(sqr(mx-_x)+sqr(my-_y))<_w/2) then
          hud_currentzone:=i;

     if ((mx>DialScroll.minx)and(mx<DialScroll.minx+DialScroll.width))or(scrollchoosed) then
     Begin
       if (my<DialScroll.miny)and(my>DialScroll.miny-50*resolutionScaleY) then
        hud_currentzone:=26;

       if (my>DialScroll.maxy)and(my<DialScroll.maxy+50*resolutionScaleY) then
        hud_currentzone:=25;

       if AllDialMode then
       Begin
         if (my>DialScroll.miny)and(my<DialScroll.maxy) then
          if (pressed[0])and(AllDials.Count>25) then
          begin
            scrollChoosed:=true;
            Dialpage:=trunc((my-DialScroll.miny-DialScroll.height/2)/(DialScroll.maxy
                -DialScroll.miny-DialScroll.height)*(AllDials.Count/5-5));
          end else
            scrollchoosed:=false;
       End else
       begin
        if (my>DialScroll.miny)and(my<DialScroll.maxy) then
          if (pressed[0])and(LevDials.Count>25) then
          begin
            scrollChoosed:=true;
            Dialpage:=trunc((my-DialScroll.miny-DialScroll.height/2)/(DialScroll.maxy
                -DialScroll.miny-DialScroll.height)*(LevDials.Count/5-5));
          end else
            scrollchoosed:=false;
       end;

     End;

     if (mx>_x+_h/2+75*ResolutionscaleX)and (mx<_x+_h/2+325*ResolutionscaleX)and
           (my>_y-trunc(80*ResolutionscaleY2))and(my<_y-trunc(40*ResolutionscaleY2)) then
                hud_currentzone:=75;
                
     if AllDialMode then
     Begin
      if (Mouse.MouseWheel<0) then
        if DialPage<AllDials.Count div 5-5 then
          inc(dialPage);
     End else
     Begin
      if (Mouse.MouseWheel<0) then
        if DialPage<LevDials.Count div 5-5 then
          inc(dialPage);
     End;

     if (Mouse.MouseWheel>0) then
      if DialPage>0 then
       dec(dialPage);
     if AllDialMode then
     Begin
       if DialPage>AllDials.Count div 5-5 then
          DialPage:=AllDials.Count div 5-5;
     End else
     begin
        if DialPage>LevDials.Count div 5-5 then
          DialPage:=LevDials.Count div 5-5;
     end;

      if DialPage<0 then
       DialPage:=0;
  End;




  if mdown[0] then Begin

    if DialMode then
     if hud_currentzone=75 then
     Begin
         Begin
           AllDialMode:=not(AllDialMode);

           if LevDials.Count=0 then
              AllDialMode:=true;

           if AllDialMode then
                 DialPage:=AllDials.Count div 5-5
                   else
                      DialPage:=LevDials.Count div 5-5;
           if DialPage<0 then
              DialPage:=0;
         End;

          DXWave.Items.Find('mousein.wav').Play(false);  ///1308
     End;

    
     if hud_currentzone=15 then
     Begin
       DialMode:=true;

       HaveNewDLG:=false;
       if showDlg=false then
          DialTime:=0;

       ScrollChoosed:=false;
       if LevDials.Count>0 then
          AllDialMode:=false
           else
             AllDialMode:=true;
        DXWave.Items.Find('mousein.wav').Play(false);  ///1308
     End;

    if hud_currentzone=16 then
     Begin
       DialMode:=false;
       DXWave.Items.Find('mousein.wav').Play(false);  ///1308
     End;


     if AllDialMode then
     Begin
       if hud_currentzone=25  then
          if DialPage<AllDials.Count div 5-5 then
          begin
            inc(dialPage);
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          end
           else
              DXWave.Items.Find('click0.wav').Play(false);  ///1308
     End else
     begin
        if hud_currentzone=25  then
          if DialPage<LevDials.Count div 5-5 then
          begin
            inc(dialPage);
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          end
           else
              DXWave.Items.Find('click0.wav').Play(false);  ///1308
     end;

     if hud_currentzone=26 then
      if DialPage>0 then
      begin
       dec(dialPage);
       DXWave.Items.Find('mousein.wav').Play(false);  ///1308
      end
           else
              DXWave.Items.Find('click0.wav').Play(false);  ///1308

    if hud_currentzone=7 then
    begin
      CloseInv;
    end;

    //// ITEMS
    if hud_currentzone=0 then
      if InMouse<>nil then
      Begin
        for I := 1 to 6 do
          if InSpace[i]=nil then
            Begin
              //// ВЫБРОСИТЬ

              //// ITEM
              if InMouse is TItem then
              Begin
                InSpace[i]:=TItem.Create;
                TItem(InSpace[i]).CopyItem(TItem(InMouse));
                InMouse:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                Break;
              End;


              //// BONUS
              if InMouse is TBonus then
                if TBonus(InMouse).BonusFileName='dopslots' then
                Begin
                   if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                      InSpace[i]:=TBonus.Create;
                      TBonus(InSpace[i]).CopyBonus(TBonus(InMouse));
                      altweapons[5]:=-1;
                      altweapons[4]:=-1;
                      InMouse:=nil;
                      DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                      Break;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      Break;
                    End;
                End
                else
                Begin
                  InSpace[i]:=TBonus.Create;
                  TBonus(InSpace[i]).CopyBonus(TBonus(InMouse));
                  DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                  InMouse:=nil;
                  Break;
                End;
            End;
      End;

    if (Hud_Currentzone>10)and(Hud_currentZone<15) then
    Begin
      if InMouse=nil then
      Begin
          if Items[Hud_Currentzone-10]<>nil then
          Begin
            //// ВЗЯТЬ
            InMouse:=TItem.Create;
            TItem(InMouse).CopyItem(Items[Hud_Currentzone-10]);
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
            Items[Hud_Currentzone-10]:=nil;
          End;
      End else
      if InMouse is TItem then
        if Items[Hud_Currentzone-10]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ
            Items[Hud_Currentzone-10]:=TItem.Create;
            Items[Hud_Currentzone-10].CopyItem(TItem(InMouse));
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
            if hintson then
                lookhint(TItem(InMouse).ItemFileName);
            InMouse:=nil;

          End else
            Begin
            //// ОБМЕН
              Choosing:=TItem.Create;
              if hintson then
                lookhint(TItem(InMouse).ItemFileName);
              TItem(Choosing).CopyItem(TItem(InMouse));
              TItem(InMouse).CopyItem(Items[Hud_Currentzone-10]);
              Items[Hud_Currentzone-10].CopyItem(TItem(Choosing));
              DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              Choosing:=nil;
            End;
    End;

    if (Hud_Currentzone>7)and(Hud_currentZone<11) then
    Begin
      if InMouse=nil then
      Begin
          if Bonuses[Hud_Currentzone-7]<>nil then
          Begin
            //// ВЗЯТЬ
            InMouse:=TBonus.Create;
            TBonus(InMouse).CopyBonus(Bonuses[Hud_Currentzone-7]);
            Bonuses[Hud_Currentzone-7]:=nil;
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End;
      End else
      if InMouse is TBonus then
        if Bonuses[Hud_Currentzone-7]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ
            Bonuses[Hud_Currentzone-7]:=TBonus.Create;
            Bonuses[Hud_Currentzone-7].CopyBonus(TBonus(InMouse));
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
            if hintson then
              lookhint(TBonus(InMouse).BonusFileName);
            InMouse:=nil;
          End else
            Begin
            //// ОБМЕН
              Choosing:=TBonus.Create;
              if hintson then
                lookhint(TBonus(InMouse).BonusFileName);
              TBonus(Choosing).CopyBonus(TBonus(InMouse));
              TBonus(InMouse).CopyBonus(Bonuses[Hud_Currentzone-7]);
              Bonuses[Hud_Currentzone-7].CopyBonus(TBonus(Choosing));
              DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              Choosing:=nil;
            End;
    End;

    if (Hud_Currentzone>=17)and(Hud_currentZone<=22) then
    Begin
      if InMouse=nil then
      Begin
          if InSpace[Hud_Currentzone-16]<>nil then
          Begin
            //// ВЗЯТЬ

            ///TItem
              if InSpace[Hud_Currentzone-16] is TItem then
              Begin
                InMouse:=TItem.Create;
                TItem(InMouse).CopyItem(TItem(InSpace[Hud_Currentzone-16]));
                InSpace[Hud_Currentzone-16]:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              End;

            ///TBonus
              if InSpace[Hud_Currentzone-16] is TBonus then
              Begin
                  clone:=false;

                  for I := 1 to 3 do
                  if Bonuses[i]<>nil then
                    if Bonuses[i].BonusFileName=TBonus(InSpace[Hud_Currentzone-16]).BonusFileName then
                    Begin
                      AddHint(language[44],resolutionscaleY,mx,my,1);
                      clone:=true;
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      break;
                    End;

                if clone=false then
                Begin
                  InMouse:=TBonus.Create;
                  TBonus(InMouse).CopyBonus(TBonus(InSpace[Hud_Currentzone-16]));
                  DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                  InSpace[Hud_Currentzone-16]:=nil;
                End;

              End;

          End;
      End else
        if InSpace[Hud_Currentzone-16]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ

            ///TItem
            if InMouse is TItem then
            Begin
                InSpace[Hud_Currentzone-16]:=TItem.Create;
                TItem(InSpace[Hud_Currentzone-16]).CopyItem(TItem(InMouse));
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                InMouse:=nil;
            End;

            ///TBonus
            if InMouse is TBonus then
            if TBonus(InMouse).BonusFileName='dopslots' then
              Begin
                 if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                      InSpace[Hud_Currentzone-16]:=TBonus.Create;
                      TBonus(InSpace[Hud_Currentzone-16]).CopyBonus(TBonus(InMouse));
                      altweapons[5]:=-1;
                      altweapons[4]:=-1;
                      DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                      InMouse:=nil;
                      //Break;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                    End;
              end else
              Begin
                InSpace[Hud_Currentzone-16]:=TBonus.Create;
                TBonus(InSpace[Hud_Currentzone-16]).CopyBonus(TBonus(InMouse));
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                InMouse:=nil;
              End;

            

          End else
            Begin
            //// ОБМЕН
            ///  Бонус на Предмет
            ///  Бонус на Бонус
            ///  Предмет на предмет
            ///  Предмет на бонус
              clone:=false;

              if InMouse is TBonus then
              Begin

                /// DOPSLOTS
                if TBonus(InMouse).BonusFileName='dopslots' then
                Begin
                 if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                     clone:=false;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      clone:=true;
                    End;
                End;

                /// CLONES

                 for I := 1 to 3 do
                  if Bonuses[i]<>nil then
                    if Bonuses[i].BonusFileName=TBonus(InSpace[Hud_Currentzone-16]).BonusFileName then
                    Begin
                      AddHint(language[44],resolutionscaleY,mx,my,1);
                      clone:=true;
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      break;
                    End;

              End;



              if clone=faLSE then
              Begin
                Choosing:=InMouse;
                InMouse:=InSpace[Hud_Currentzone-16];
                InSpace[Hud_Currentzone-16]:=Choosing;
                Choosing:=nil;
              End;
            End;
    End;

  End;

end;

procedure TMainForm.MouseInventory2;
var i,j:integer;
begin
Hud_currentzone:=0;
 for i := 1 to 8 do
 Begin
   if (abs(mx-hud2[i].cx)<hud2[i].dopr/2)
   and (abs(my-hud2[i].cy)<Hud2[i].dopr/2)
   then
   Hud_currentzone:=i;
 End;

    if MDown[0] then
    Begin

     if hud2[Hud_currentzone].hudtype=8 then
       Begin

          if (Hud_currentzone>1)and(altweapons[Hud_currentzone-1]<>-1) then
          Begin
             {обмен цветами}
             j:=altweapons[Hud_currentzone-1];
             altweapons[Hud_currentzone-1]:=InMousecol;
             InMouseCol:=j;

             {обмен Count-ами}
             i:=weapons[j].Count;
             weapons[altweapons[Hud_currentzone-1]].Count:=InMouseColCount;
             InMouseColCount:=i;
             DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End;

          if Hud_currentzone=1 then
          Begin
             j:=currentweapon;
             i:=weapons[j].Count;

             currentweapon:=InMousecol;
             weapons[InMouseCol].Count:=InMouseColCount;

             InMouseColCount:=i;
             InMouseCol:=j;
             DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End;

       End;
        if hud2[Hud_currentzone].hudtype=7 then
       Begin
            if TakenCol is TTile then
            Begin
              if InMousecol=needcolor then
              Begin
                j:=newcolor;
                i:=newcolorCount;

                newcolor:=InMousecol;
                NewcolorCount:=InMouseColCount;

                InMouseColCount:=i;
                InMouseCol:=j;
                DXWave.Items.Find('door0.wav').Play(false);  ///1308

                Closeinv2;
              End else
                DXWave.Items.Find('click0.wav').Play(false);  ///1308
                //// звук отката
            End else
              Begin
                j:=newcolor;
                i:=newcolorCount;

                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                newcolor:=InMousecol;
                NewcolorCount:=InMouseColCount;

                InMouseColCount:=i;
                InMouseCol:=j;
              End;

       End;


        if hud2[Hud_currentzone].hudtype=5 then
         CloseInv2;
    End;
///
end;

procedure TMainForm.MouseInventory3;
var i,j:integer;
    _x,_y,_h,_w,_scale:real;
    str1W,Str2W,strH,stt,slotfree:integer;
    str1,str2,str3:string;
    Choosing:TObject;
    clone:boolean;
begin
 hud_currentzone:=0;
 for i := 0 to 40 do
    if Hud_Hotzones[i].no<>0 then
    begin
      _scale:=Hud3[hud_hotzones[i].no].cscale;
      _w:=hud_hotzones[i].w*_scale*ResolutionScaleX;
      _h:=hud_hotzones[i].h*_scale*ResolutionScaleY;
      _x:=(Hud3[hud_hotzones[i].no].cx)+hud_hotzones[i].x*_scale*ResolutionScaleX;
      _y:=(Hud3[hud_hotzones[i].no].cy)+hud_hotzones[i].y*_scale*ResolutionScaleY;

       if DrawDop then
        MyCanvas.Circle(trunc(_x),trunc(_y),
        trunc(_w/2),clBlue,fxNone);


       if (sqrt(sqr(mx-_x)+sqr(my-_y))<_w/2) then
          hud_currentzone:=i;

 
       ////STORE
       if (Hud_Currentzone>24)and(Hud_currentZone<40) then
       Begin
         if ((hud_currentzone<=33) and (MagzLev/2>=trunc((hud_currentzone-25)/ 3) ))or
            ((hud_currentzone>33) and ((MagzLev-1)/2>=trunc((hud_currentzone-34)/ 2) ))

             then
            Begin
             str1:=MagzObjs[hud_currentzone-24].name;
             str2:=MagzObjs[hud_currentzone-24].info;
             str3:=Language[40]+' '+inttostr(MagzObjs[hud_currentzone-24].cost);

              Fonts[1].Scale:=ResolutionScaleY;
              str1w:=round(Fonts[1].TextWidth(str1));
              strH:=round(Fonts[1].TextHeight(str1));
              Fonts[1].Scale:=ResolutionScaleY*0.7;

              str2w:=round(Fonts[1].TextWidth(str2));

              if str1w>str2w then
                str2w:=str1w;

              stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
              if stt<0 then
                stt:=0;

              MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),trunc(strH*2.9),crgb1(90,90,90,30),fxBlend);

              Fonts[1].Scale:=ResolutionScaleY;

              Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
              Fonts[1].Scale:=ResolutionScaleY*0.7;
              Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
              if levelscore.total<MagzObjs[hud_currentzone-24].cost then
               Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 25, 25, 255))
                else
                  Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
            End;


       End;

       ////////// ITEMS
       if (Hud_Currentzone>10)and(Hud_currentZone<15) then
       Begin
         if Items[Hud_Currentzone-10]<>nil then
         Begin
          str1:=Items[Hud_Currentzone-10].ItemName;
          str2:=Items[Hud_Currentzone-10].ItemInfo;
          str3:=ItemsList[1]+' '+inttostr(trunc(Items[Hud_Currentzone-10].ItemCurrenttime));

          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;

          str2w:=round(Fonts[1].TextWidth(str2));

          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),trunc(strH*2.9),crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
         Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;
      End;

      //// BONUSes
      if (Hud_Currentzone>7)and(Hud_currentZone<11) then
       Begin
         if Bonuses[Hud_Currentzone-7]<>nil then
         Begin
          str1:=Bonuses[Hud_Currentzone-7].BonusName;
          str2:=Bonuses[Hud_Currentzone-7].BonusInfo;

          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));
          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),strH*2,crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;
      End;


       if (Hud_Currentzone>=17)and(Hud_currentZone<=22) then
       Begin
       if InSpace[Hud_Currentzone-16]<>nil then
       Begin
         //// ITEMS


         if InSpace[Hud_Currentzone-16]is TItem then
         Begin
          str1:=TItem(InSpace[Hud_Currentzone-16]).ItemName;
          str2:=TItem(InSpace[Hud_Currentzone-16]).ItemInfo;//+' '+inttostr(trunc(TItem(InSpace[Hud_Currentzone-16]).ItemCurrenttime));
          str3:=ItemsList[1]+' '+inttostr(trunc(TItem(InSpace[Hud_Currentzone-16]).ItemCurrenttime));
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));

          if str1w>str2w then
          str2w:=str1w;


          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),trunc(strH*2.9),crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
         Fonts[1].TextOut(str3,mx-stt+55*resolutionscaleX,my+strH*1.8+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;

       //////Bonuses
        if InSpace[Hud_Currentzone-16]is TBonus then
         Begin
          str1:=TBonus(InSpace[Hud_Currentzone-16]).BonusName;
          str2:=TBonus(InSpace[Hud_Currentzone-16]).BonusInfo;
          Fonts[1].Scale:=ResolutionScaleY;
          str1w:=round(Fonts[1].TextWidth(str1));
          strH:=round(Fonts[1].TextHeight(str1));
          Fonts[1].Scale:=ResolutionScaleY*0.7;
          str2w:=round(Fonts[1].TextWidth(str2));

          if str1w>str2w then
          str2w:=str1w;

          stt:=trunc(-Device.Width+50*resolutionscaleX+mx+str2w);
          if stt<0 then
          stt:=0;

         MyCanvas.FillRect(round(mx-stt+50*resolutionscaleX),round(my+50*resolutionscaleY)
                           ,round(str2w+15*resolutionscaleX),strH*2,crgb1(90,90,90,30),fxBlend);
         Fonts[1].Scale:=ResolutionScaleY;
         Fonts[1].TextOut(str1,mx-stt+55*resolutionscaleX,my+55*resolutionscaleY, cRGB1(255, 255, 255, 255));
         Fonts[1].Scale:=ResolutionScaleY*0.7;
         Fonts[1].TextOut(str2,mx-stt+55*resolutionscaleX,my+strH+55*resolutionscaleY,cRGB1(255, 255, 255, 255));
       End;


      End;
       End;


    end;


  if mdown[0] then Begin

    if hud_currentzone=7 then
    CloseInv3;

      if (Hud_Currentzone>24)and(Hud_currentZone<=33) then
       Begin
        if (MagzLev/2>=trunc((hud_currentzone-25)/ 3))  then
        Begin
          if MagzObjs[hud_currentzone-24].cost>globalscore then
          begin
            AddHint(language[42],resolutionscaleY,mx,my,1);
            Mainform.DXWave.Items.Find('click0.wav').Play(false);  ///1308
          end
            else Begin
             slotfree:=-1;
             for I := 1 to 4 do
              if Items[i]=nil then
               Begin
                slotfree:=i;
                break;
               End;
             if slotfree<>-1 then
             Begin
              Items[slotfree]:=Titem.Create;
              Items[slotfree].LoadItem(MagzObjs[hud_currentzone-24].objname);
              globalscore:=globalscore-MagzObjs[hud_currentzone-24].cost;
              levelscore.total:=globalscore;
              Mainform.DXWave.Items.Find('mousein.wav').Play(false);  ///1308
             End else
                begin
                  AddHint(language[43],resolutionscaleY,mx,my,1);
                  Mainform.DXWave.Items.Find('click0.wav').Play(false);  ///1308
                end;
            End;
        End;
       End;

       if (Hud_Currentzone>33)and(Hud_currentZone<40) then
       Begin
        if ((MagzLev-1)/2>=trunc((hud_currentzone-34) / 2))  then
        Begin
          if MagzObjs[hud_currentzone-24].cost>globalscore then
          begin
            Mainform.DXWave.Items.Find('click0.wav').Play(false);  ///1308
            AddHint(language[42],resolutionscaleY,mx,my,1)
          end
            else
            Begin
              slotfree:=-1;
              for I := 1 to 3 do
              if Bonuses[i]=nil then
               Begin
                slotfree:=i;
                break;
               End;

              for I := 1 to 3 do
              if Bonuses[i]<>nil then
              if Bonuses[i].BonusFileName=MagzObjs[hud_currentzone-24].objname then
               Begin
                slotfree:=-2;
                AddHint(language[44],resolutionscaleY,mx,my,1);
                DXWave.Items.Find('click0.wav').Play(false);  ///1308
                break;
               End;

             if slotfree>0 then
             Begin
              Bonuses[slotfree]:=TBonus.Create;
              Bonuses[slotfree].LoadBonus(MagzObjs[hud_currentzone-24].objname);
              globalscore:=globalscore-MagzObjs[hud_currentzone-24].cost;
              levelscore.total:=globalscore;
             End;
             if slotfree=-1 then
             begin
              AddHint(language[43],resolutionscaleY,mx,my,1);
              DXWave.Items.Find('click0.wav').Play(false);  ///1308
             end;

            End;
        End;
       End;

   //// ITEMS
    if hud_currentzone=0 then
      if InMouse<>nil then
      Begin
        for I := 1 to 6 do
          if InSpace[i]=nil then
            Begin
              //// ВЫБРОСИТЬ

              //// ITEM
              if InMouse is TItem then
              Begin
                InSpace[i]:=TItem.Create;
                TItem(InSpace[i]).CopyItem(TItem(InMouse));
                InMouse:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                Break;
              End;


              //// BONUS
              if InMouse is TBonus then
                if TBonus(InMouse).BonusFileName='dopslots' then
                Begin
                   if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                      InSpace[i]:=TBonus.Create;
                      TBonus(InSpace[i]).CopyBonus(TBonus(InMouse));
                      altweapons[5]:=-1;
                      altweapons[4]:=-1;
                      InMouse:=nil;
                      DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                      Break;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      Break;
                    End;
                End
                else
                Begin
                  InSpace[i]:=TBonus.Create;
                  TBonus(InSpace[i]).CopyBonus(TBonus(InMouse));
                  DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                  InMouse:=nil;
                  Break;
                End;
            End;
      End;

    if (Hud_Currentzone>10)and(Hud_currentZone<15) then
    Begin
      if InMouse=nil then
      Begin
          if Items[Hud_Currentzone-10]<>nil then
          Begin
            //// ВЗЯТЬ
            InMouse:=TItem.Create;
            TItem(InMouse).CopyItem(Items[Hud_Currentzone-10]);
            Items[Hud_Currentzone-10]:=nil;
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End;
      End else
      if InMouse is TItem then
        if Items[Hud_Currentzone-10]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ
            Items[Hud_Currentzone-10]:=TItem.Create;
            Items[Hud_Currentzone-10].CopyItem(TItem(InMouse));
            InMouse:=nil;
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End else
            Begin
            //// ОБМЕН
              Choosing:=TItem.Create;
              TItem(Choosing).CopyItem(TItem(InMouse));
              TItem(InMouse).CopyItem(Items[Hud_Currentzone-10]);
              Items[Hud_Currentzone-10].CopyItem(TItem(Choosing));
              DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              Choosing:=nil;
            End;
    End;

    if (Hud_Currentzone>7)and(Hud_currentZone<11) then
    Begin
      if InMouse=nil then
      Begin
          if Bonuses[Hud_Currentzone-7]<>nil then
          Begin
            //// ВЗЯТЬ
            InMouse:=TBonus.Create;
            TBonus(InMouse).CopyBonus(Bonuses[Hud_Currentzone-7]);
            Bonuses[Hud_Currentzone-7]:=nil;
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End;
      End else
      if InMouse is TBonus then
        if Bonuses[Hud_Currentzone-7]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ
            Bonuses[Hud_Currentzone-7]:=TBonus.Create;
            Bonuses[Hud_Currentzone-7].CopyBonus(TBonus(InMouse));
            InMouse:=nil;
            DXWave.Items.Find('mousein.wav').Play(false);  ///1308
          End else
            Begin
            //// ОБМЕН
              Choosing:=TBonus.Create;
              TBonus(Choosing).CopyBonus(TBonus(InMouse));
              TBonus(InMouse).CopyBonus(Bonuses[Hud_Currentzone-7]);
              Bonuses[Hud_Currentzone-7].CopyBonus(TBonus(Choosing));
              Choosing:=nil;
              DXWave.Items.Find('mousein.wav').Play(false);  ///1308
            End;
    End;

    if (Hud_Currentzone>=17)and(Hud_currentZone<=22) then
    Begin
      if InMouse=nil then
      Begin
          if InSpace[Hud_Currentzone-16]<>nil then
          Begin
            //// ВЗЯТЬ

            ///TItem
              if InSpace[Hud_Currentzone-16] is TItem then
              Begin
                InMouse:=TItem.Create;
                TItem(InMouse).CopyItem(TItem(InSpace[Hud_Currentzone-16]));
                InSpace[Hud_Currentzone-16]:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              End;

            ///TBonus
              if InSpace[Hud_Currentzone-16] is TBonus then
              Begin
                  clone:=false;

                  for I := 1 to 3 do
                  if Bonuses[i]<>nil then
                    if Bonuses[i].BonusFileName=TBonus(InSpace[Hud_Currentzone-16]).BonusFileName then
                    Begin
                      AddHint(language[44],resolutionscaleY,mx,my,1);
                      clone:=true;
                      break;
                    End;

                if clone=false then
                Begin
                  InMouse:=TBonus.Create;
                  TBonus(InMouse).CopyBonus(TBonus(InSpace[Hud_Currentzone-16]));
                  InSpace[Hud_Currentzone-16]:=nil;
                  DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                End else
                  DXWave.Items.Find('click0.wav').Play(false);  ///1308

              End;

          End;
      End else
        if InSpace[Hud_Currentzone-16]=nil then
          Begin
            //// ПОЛОЖИТЬ В ПУСТОЙ СЛОТ

            ///TItem
            if InMouse is TItem then
            Begin
                InSpace[Hud_Currentzone-16]:=TItem.Create;
                TItem(InSpace[Hud_Currentzone-16]).CopyItem(TItem(InMouse));
                InMouse:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
            End;

            ///TBonus
            if InMouse is TBonus then
            if TBonus(InMouse).BonusFileName='dopslots' then
              Begin
                 if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                      InSpace[Hud_Currentzone-16]:=TBonus.Create;
                      TBonus(InSpace[Hud_Currentzone-16]).CopyBonus(TBonus(InMouse));
                      altweapons[5]:=-1;
                      altweapons[4]:=-1;
                      InMouse:=nil;
                      DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                      //Break;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                    End;
              end else
              Begin
                InSpace[Hud_Currentzone-16]:=TBonus.Create;
                TBonus(InSpace[Hud_Currentzone-16]).CopyBonus(TBonus(InMouse));
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
                InMouse:=nil;
              End;

            

          End else
            Begin
            //// ОБМЕН
            ///  Бонус на Предмет
            ///  Бонус на Бонус
            ///  Предмет на предмет
            ///  Предмет на бонус
              clone:=false;

              if InMouse is TBonus then
              Begin

                /// DOPSLOTS
                if TBonus(InMouse).BonusFileName='dopslots' then
                Begin
                 if (altweapons[5]<=0)and(altweapons[4]<=0) then
                   Begin
                     clone:=false;
                   End
                    else
                    Begin
                      AddHint(language[45],resolutionscaleY,mx,my-20*resolutionscaleY,8);
                      AddHint(language[46],resolutionscaleY,mx,my,8);
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      clone:=true;
                    End;
                End;

                /// CLONES

                 for I := 1 to 3 do
                  if Bonuses[i]<>nil then
                    if Bonuses[i].BonusFileName=TBonus(InSpace[Hud_Currentzone-16]).BonusFileName then
                    Begin
                      AddHint(language[44],resolutionscaleY,mx,my,1);
                      clone:=true;
                      DXWave.Items.Find('click0.wav').Play(false);  ///1308
                      break;
                    End;

              End;



              if clone=faLSE then
              Begin
                Choosing:=InMouse;
                InMouse:=InSpace[Hud_Currentzone-16];
                InSpace[Hud_Currentzone-16]:=Choosing;
                Choosing:=nil;
                DXWave.Items.Find('mousein.wav').Play(false);  ///1308
              End;
            End;
    End;

  End;

end;

procedure TMainForm.MouseMapLookMenu;
begin
 if mup[0] then
  Begin
    if hud_currentzone=105 then
    Begin
     ShowMicro:= not(showMicro);
     hud_currentzone:=0;
    End;

    if hud_currentzone=100 then
    Begin
      MapLookMenu:=false;
      MapLookT:=0;
      mx:=omx;
      my:=omy;
      canshoot:=false;
      hud_currentzone:=0;
    End;

     if hud_currentzone=101 then
       mapShow1:=not(mapShow1);
     if hud_currentzone=102 then
       mapShow2:=not(mapShow2);
     if hud_currentzone=103 then
       mapShow3:=not(mapShow3);
  End;

  if (pressed[0])and(hud_currentzone=104) then
  Begin
    MaplookX:=MaplookX-Mouse.Displace.X*mspd*6.67/ResolutionScaleX;
    MaplookY:=MaplookY-Mouse.Displace.Y*mspd*6.67/ResolutionScaleY;
  End;

   if (pressed[0])and(hud_currentzone=106) then
  Begin
    MaplookX:=(mx-microX-micSx)*mss/(2*ResolutionScaleX);
    MaplookY:=(my-microY-micSy)*mss/(2*ResolutionScaleY);
  End;


end;

procedure TMainForm.MouseMenu;
var i,j,_w,xmax,xmin:integer;
    hintfile:TStringlist;
begin
///
///
{  if Device.Height/MenuEngine.WorldScaleY<1200 then
  Begin

    if my>Device.Height-5 then
    Begin

      if MenuEngine.WorldY<1200-Device.Height/MenuEngine.WorldScaleY then
      Begin
        MenuEngine.WorldY:=MenuEngine.WorldY+timer.Delta*5;
      End;
      if MenuEngine.WorldY>1200-Device.Height/MenuEngine.WorldScaleY then
        MenuEngine.WorldY:=1200-Device.Height/MenuEngine.WorldScaleY;
    End;

    if my<5 then
    Begin
      if MenuEngine.WorldY*MenuEngine.WorldScaleY>0 then
      Begin
        MenuEngine.WorldY:=MenuEngine.WorldY-timer.Delta*5;
      End;
      if MenuEngine.WorldY*MenuEngine.WorldScaleY<0 then
        MenuEngine.WorldY:=0;
    End;

  End;
          }
///

  j:=-1;
  curcbutton:=-1;
     for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        Fonts[1].Scale:=ResolutionScaleY;
        if (menun=4)or(menun=8)or(menun=7)or(menun=15) then
        _w:=trunc(60*resolutionscaleX)//trunc(Fonts[1].TextWidth(Language[Menus[MenuN].buttons[i].name])/ 2)
         else _w:=trunc(200*resolutionscaleX);


        if ((mx>(Menus[MenuN].x+Menus[MenuN].buttons[i].x)*resolutionscaleX-_w)and
        (mx<(Menus[MenuN].x+Menus[MenuN].buttons[i].x)*resolutionscaleX+_w)) then
           if ((my>(570+Menus[MenuN].buttons[i].y)*resolutionscaleY2)and
            (my<(620+Menus[MenuN].buttons[i].y)*resolutionscaleY2)) then
            j:=i;

      End;

  if menun=10 then
    if (level=0)and(j=2) then
        j:=-1;

  if menun=1 then
  Begin
      if (abs(800*resolutionscaleX-mx)<pfbutton/2) then
           if (my>trunc((1080)*resolutionscaleY2))
             and(my<trunc((1120)*resolutionscaleY2)+pfh) then
                j:=105;
  End;

  if menun=2 then
  Begin

      if (mx>140*ResolutionScaleX)and(mx<640*ResolutionScaleX) then
          for i:=-1 to 10 do
           if (my>(350+i*50)*resolutionscaleY2)and(my<(400+i*50)*resolutionscaleY2) then
              if i<MapsList.Count-MapsPage then
                j:=100+i;

    if (j<>99)and(j<>110) then
      if (j-100>MapsList.Count-MapsPage) then
        j:=-1;

    if ((j=99)and(MapsPage<=0))or((j=110)and(MapsPage>=MapsList.Count-1)) then
      j:=-1;


    if j>=100 then
    Begin
      if (Mouse.MouseWheel<0) then
      if MapsPage<MapsList.Count -10 then
       inc(MapsPage);

      if (Mouse.MouseWheel>0) then
      if MapsPage>0 then
       dec(MapsPage);
    End;
    
  End;



  if menun=18 then
  Begin
    if ((my>310*resolutionscaleY2)and
     (my<340*resolutionscaleY2)) then
      Begin
        if (mx>600*resolutionscaleX)and
           (mx<650*resolutionscaleX) then
            if page>0 then j:=11;

        if (mx>950*resolutionscaleX) and
           (mx<1000*resolutionscaleX) then
            if page<2 then j:=12;
      End;
  End;


  if menun=90 then
  Begin
    if ((my>780*resolutionscaleY2)and
     (my<830*resolutionscaleY2)) then
      Begin
        if (mx>650*resolutionscaleX)and
           (mx<700*resolutionscaleX) then
            if hintn>1 then j:=11;

        if (mx>900*resolutionscaleX) and
           (mx<950*resolutionscaleX) then
            if hintn<hintmax then j:=12;
      End;

      if ((my>790*resolutionscaleY2)and
        (my<860*resolutionscaleY2)) then
          if (mx>990*resolutionscaleX)and
           (mx<1600*resolutionscaleX) then
             j:=101;      // newnewnew3


  End;

  if (menun=18) then
   if (j>0)and(j<10) then
     if (((j<Menus[18].bcount-1)and(j-1>level/5))or((j=Menus[18].bcount-1)and(level<levels.Count))) then
        j:=-1;


  if (menun=6)or(menun=19) then
  Begin
    if j<3 then
    j:=-1;
  End;
  if (menun=9)or(menun=20) then
  Begin
    if (waitforkey) then
    j:=-1;
  End;

  curbutton:=j;
  if (curbutton<>lastbutton)and(j<>-1) then
  DXWave.Items.Find('MouseIn.wav').Play(false);
  lastbutton:=curbutton;

 { if mup[0] then
  begin
     if (menun=6)or(menun=19) then
     Begin
      // \ sdcsd
     End;
  end;}

  if pressed[0] then
  Begin
    curcbutton:=j;


     if (menun=6)or(menun=19) then
     Begin
       _w:=trunc(200*resolutionscaleX);
       xmin:=trunc((Menus[MenuN].x+Menus[MenuN].buttons[1].x+20)*resolutionscaleX-_w);
       xmax:=trunc((Menus[MenuN].x+Menus[MenuN].buttons[1].x-20)*resolutionscaleX+_w);

       for I := 0 to 2 do
       Begin
        if ((my>(590+Menus[MenuN].buttons[i].y)*resolutionscaleY2)and
            (my<(620+Menus[MenuN].buttons[i].y)*resolutionscaleY2)) then
            if ((mx>xmin)and (mx<xmax)) then
            Begin
             case i of
              0:Begin
                  _SV:=trunc(((mx-xmin)/(xmax-xmin))*10+0.5)*10;
                End;
              1:Begin
                  _MV:=trunc(((mx-xmin)/(xmax-xmin))*10+0.5)*10;
                End;
              2:_mSpd:=trunc(((mx-xmin)/(xmax-xmin))*4+1.5);
             end;
             if _SV>100 then
                _SV:=100;
             if _MV>100 then
                _MV:=100;
             if _SV<0 then
                _SV:=0;
             if _MV<0 then
                _MV:=0;
             if _MSPD<1 then
                _MSPD:=1;
             if _MSPD>5 then
                _MSPD:=5;
            End;
       End;
     End;
  End;

 

  if mup[0] then
  Begin
     {БЕГУНКИ}
     if (menun=6)or(menun=19) then
     Begin
  {     if (menun=6)or(menun=19) then
     Begin}
       _w:=trunc(200*resolutionscaleX);
       xmin:=trunc((Menus[MenuN].x+Menus[MenuN].buttons[1].x+20)*resolutionscaleX-_w);
       xmax:=trunc((Menus[MenuN].x+Menus[MenuN].buttons[1].x-20)*resolutionscaleX+_w);

       for I := 0 to 2 do
       Begin
        if ((my>(590+Menus[MenuN].buttons[i].y)*resolutionscaleY2)and
            (my<(620+Menus[MenuN].buttons[i].y)*resolutionscaleY2)) then
            if ((mx>xmin)and (mx<xmax)) then
            Begin
             case i of
              0:Begin
                _SV:=trunc(((mx-xmin{-20})/(xmax-xmin{+20}))*10+0.5)*10;
                if _SV>100 then
                  _SV:=100;
                if _SV<0 then
                  _SV:=0;
                SoundVolume:=_SV;
                TestVolume(SoundVolume);
              End;
              1:Begin
                _MV:=trunc(((mx-xmin{-20})/(xmax-xmin{+20}))*10+0.5)*10;
                if _MV>100 then
                  _MV:=100;
                if _MV<0 then
                  _MV:=0;
                MusVolume:=_MV;
                TestVolume(MusVolume);
                SetMusVolumes;
              End;
              2:begin
                _mSpd:=trunc(((mx-xmin)/(xmax-xmin))*4+1.5);
                if _MSPD<1 then
                  _MSPD:=1;
                if _MSPD>5 then
                  _MSPD:=5;
                MSPD:=_MSPD;
              end;
             end;
             {if SoundVolume>100 then
                SoundVolume:=100;
             if MusVolume>100 then
                MusVolume:=100;
             if SoundVolume<0 then
                SoundVolume:=0;
             if MusVolume<0 then
                MusVolume:=0;
             if MSPD<1 then
                MSPD:=1;
             if MSPD>5 then
                MSPD:=5;}
            End
       End;
            if _SV<>SoundVolume then
            begin
              SoundVolume:=_SV;
              TestVolume(SoundVolume);
            end;
            if _MV<>MusVolume then
            begin
              MusVolume:=_MV;
              TestVolume(MusVolume);
              SetMusVolumes;
            end;
            if _MSPD<>MSPD then
            begin
              MSPD:=_MSPD;
            end;
            SoundVolume:=_SV;
            MusVolume:=_MV;
            MSPD:=_MSPD
     End;

     dop1:=menun;
     {КНОПКИ}
     if curbutton<>-1 then
     Begin
        DXWave.Items.Find('click1.wav').Play(false);




        if menun=18 then
        Begin

          if curbutton=11 then
          Begin
            dec(page);
            exit;
          End;
          if curbutton=12 then
          Begin
            inc(page);
            exit;
          End;
        End;

        if menun=90 then
        Begin

          if curbutton=11 then
          Begin
            dec(hintn);
            gethinticons;
            exit;
          End;
          if curbutton=12 then
          Begin
            inc(hintn);
            gethinticons;
            exit;
          End;
          if (curbutton=101) then   {!!! Newnewnew 2}
          Begin
             HintsOn:=not(HintsOn);

              hintfile:=Tstringlist.Create;
              if hintson then
                hintfile.Add('1')
              else
                 hintfile.Add('0');
             hintfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Hints.loc');
             exit;
          End;

        End;

        menuready:=not(menuready);
        Globalticks:=0;
        if curbutton>=99 then
          nextmenu:=12
            else
              nextmenu:=Menus[MenuN].buttons[curbutton].onclick;

         if (nextmenu>60)and(nextmenu<65) then
         Begin
          IntroNumber:=nextmenu-60;
          nextmenu:=16;
                  // asa
          loadIntro;
          inmenu:=true;
         End;

         if menun=90 then
          if nextmenu=1 then
            UnloadPreviews;

        if menun=2 then
        Begin
           if (curbutton>=100)and(curbutton<=109) then
           Begin
             menuready:=true;
             nextmenu:=2;
             mapN:=mapsPage+curbutton-100;
             ////  Данные карты
             ReadMapHeader;
           End;

           if curbutton=99 then
           Begin
             menuready:=true;
             nextmenu:=2;
             if MapsPage>0 then
                dec(MapsPage);
           End;

           if curbutton=110 then
           Begin
             menuready:=true;
             nextmenu:=2;
             if MapsPage<MapsList.Count - 10 then
                inc(MapsPage);
           End;

          if nextmenu=90 then
            LoadHints;

          if nextmenu=1 then
            UnloadPreviews;

          if nextmenu=-7 then
          Begin
            if fileexists('Saves\Slot'+inttostr(slot)+'\'+MapsList[MapN]+'.loc') then
             nextmenu:=15 else
                nextmenu:=-8;
          End;


          if nextmenu=-8 then
          Begin
            UnloadPreviews;
            for i:=1 to 4 do
            Begin
              if Items[i]<>nil then
                Items[i]:=nil;
              if i<=3 then
                Bonuses[i]:=nil;
            End;
            LoadMapLevel(mapsList[MapN]);   /////////////!!!!!!!!
            menuready:=true;
            menun:=0;
            nextmenu:=0;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;
          End;
        End;

        if nextmenu=10 then
          Begin
            Loadprofileprogress;
            Loadscenariotext;
            if level>=levels.Count then
            Begin
             nextmenu:=11;
             UnpackExtras;
            End;

            if (level=0)and(checkedlevel<>level) then
               Begin
                  nextmenu:=16; {РОЛИК}
                  IntroNumber:=1;
                  loadIntro;
                  inmenu:=true;
               End;

          End;

        if nextmenu=-5 then
        Begin
          if (menun=15)and(campaign=false) then
          Begin
            {ЗАГРУЗКА КАРТЫ (см. nextmenu=-8)}
            UnloadPreviews;
            for i:=1 to 4 do
            Begin
              if Items[i]<>nil then
                Items[i]:=nil;
              if i<=3 then
                Bonuses[i]:=nil;
            End;
            LoadMapLevel(mapsList[MapN]);   /////////////!!!!!!!!
            menuready:=true;
            menun:=0;
            nextmenu:=0;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;
          End
             else
          Begin
            if (checkedlevel<level)or(menun=15) then
            Begin
              SayLoading;
              Loadstage(levels[level]);  /////////////!!!!!!!!
              menuready:=true;
              menut:=0;
              StopMenu:=false;
              InMenu:=false;
            End else
            Begin
             nextmenu:=15;
            End;
          End;

        End;

          if nextmenu=-6 then
          Begin
            SayLoading;
            CheckPointenabled:=true;
            if campaign=false then
                UnloadPreviews;
            LoadCheckPoint;  /////////////!!!!!!!!
            menuready:=true;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;
          End;

         if (nextmenu=1)and((menun=6)or(menun=19)) then
          Begin
           SetVolumes;
          // SetMusVolumes;
           SaveSettings;
          End;

          if (nextmenu<>19)and((menun=19)) then
          Begin
           SetVolumes;
          // SetMusVolumes;
           SaveSettings;
          End;

         if (nextmenu>20)and(nextmenu<24) then
          Begin
            slot:=nextmenu-20;
            if profnames[slot]<>'' then
            Begin
              nextmenu:=14;
              loadProfileProgress;
            End
               else
                 nextmenu:=13;
          End;

           if nextmenu=25 then
          Begin
             profnames[slot]:='';
             SaveProfNames;
            // NewProfileProgress;
             LoadProfNames;
             nextmenu:=12;
          End;

          if nextmenu=27 then
          Begin
             NewKey:=Menus[MenuN].buttons[j].name-60;
             //showmessage(InttoStr(Menus[MenuN].buttons[j].name))-60;
             waitforkey:=true;
             menuready:=true;
             nextmenu:=9;
         End;

         if nextmenu=28 then
          Begin
             if mb4<2 then
               inc(mb4)
                else
                 mb4:=0;
             menuready:=true;
             nextmenu:=9;
         End;

         if nextmenu=38 then
          Begin
             if mb4<2 then
               inc(mb4)
                else
                 mb4:=0;
             menuready:=true;
             nextmenu:=20;
         End;

         if nextmenu=37 then
          Begin
             NewKey:=Menus[MenuN].buttons[j].name-60;
             //showmessage(InttoStr(Menus[MenuN].buttons[j].name))-60;
             waitforkey:=true;
             menuready:=true;
             nextmenu:=20;
         End;

          if (nextmenu=41)or(nextmenu=42)or(nextmenu=43) then
          Begin
            if Edit1<>'' then
            Begin
             difficulty:=nextmenu-40;
             diffi:=difficulty;
             profnames[slot]:=Edit1;
             SaveProfNames;
             NewProfileProgress;
             nextmenu:=1;
            End else
            Begin
                menuready:=true;
                nextmenu:=13
            End;
          End;

          if nextmenu=31 then
          Begin
            LoadDefKeys;
            menuready:=true;
            nextmenu:=9;
          End;

          if nextmenu=30 then
          Begin
             nextmenu:=6;
             SaveKeys;
          End;

         if nextmenu=32 then
          Begin
             nextmenu:=6;
             LoadKeys;
          End;

          if nextmenu=51 then
          Begin
            LoadDefKeys;
            menuready:=true;
            nextmenu:=20;
          End;

          if nextmenu=50 then
          Begin
             nextmenu:=19;
             SaveKeys;
          End;

         if nextmenu=52 then
          Begin
             nextmenu:=19;
             LoadKeys;
          End;

          if nextmenu=39 then
          Begin
             nextmenu:=20;//6;
             menuready:=true;  // dasd
             if mb1=0 then
              Begin
                mb1:=1;
                mb2:=0;
              End else
              Begin
                mb1:=0;
                mb2:=1;
              End;
          End;


          if nextmenu=33 then
          Begin
             nextmenu:=9;//6;
             menuready:=true;  // dasd
             if mb1=0 then
              Begin
                mb1:=1;
                mb2:=0;
              End else
              Begin
                mb1:=0;
                mb2:=1;
              End;
          End;

          if nextmenu=34 then
          Begin
             nextmenu:=6;
             menuready:=true;
             if cameramode = cmcenter then
               cameramode := cmmove
                else
                  cameramode := cmcenter;
             GetNormW;
          End;

         if nextmenu=134 then
          Begin
             nextmenu:=6;
             menuready:=true;
             showDlg:=not(ShowDlg)
          End;

         if nextmenu=13 then
          Begin
            Edit1:=Language[56];
          End;

        if (Menun=19) then
        Begin
         if nextmenu=0 then
          Begin
            StopMenu:=true;
           // menuready:=true;
          End;

        End;

        if (Menun=7) then
        Begin
          if nextmenu=1 then
          Begin
            InMenu:=true;
            StopMenu:=false;
          End;
        End;

        if (StopMenu) then
        Begin
          if nextmenu=1 then
          Begin
            InMenu:=true;
            StopMenu:=false;
          End;

          if nextmenu=-2 then
          Begin
            if campaign then
            Begin
              Loadprofileprogress;
              Loadstage(levels[level]);   /////////////!!!!!!!!
              StopMenu:=true;
              nextmenu:=0;
            End
            else
            begin
               for i:=1 to 4 do
            Begin
              if Items[i]<>nil then
                Items[i]:=nil;
              if i<=3 then
                Bonuses[i]:=nil;
            End;
            LoadMapLevel(mapsList[MapN]);   /////////////!!!!!!!!

              StopMenu:=true;
              nextmenu:=0;
            end;
          End;

          if nextmenu=-3 then
          Begin
            nextmenu:=0;
            if checkpointenabled=true then
            Begin
             Loadcheckpoint;
            End;
            StopMenu:=true;
          End;

          if nextmenu=7 then
          Begin
            menun:=7;
            StopMenu:=false;
            menuready:=true;
          End;

          if nextmenu=19 then
          Begin
            menun:=5;
            StopMenu:=false;
            InGame:=false;
            InMenu:=true;
           // menuready:=true;
          End;
        End;

     End;

  End;
end;

procedure TMainForm.MouseUpdate;
var h,w,i,j:integer;
begin
  Mouse.Update;

  //// X,Y
  Mx:=mx+Mouse.Displace.X*mspd;
  My:=my+Mouse.Displace.y*mspd;
  if inmenu=false then
  Begin
  if mx<HudXShift*ResolutionScaleX then mx:=HudXShift*ResolutionScaleX;
  if mx>Device.Width-HudXShift*ResolutionScaleX then mx:=Device.Width-HudXShift*ResolutionScaleX;
  End;
  if mx<0 then mx:=0;
  if mx>Device.Width then mx:=Device.Width;
  if my<0 then my:=0;
  if my>Device.Height then my:=Device.Height;


  gamcurx:=mx/Engine.worldScaleX+Engine.WorldX;
  gamcury:=my/Engine.worldScaley+Engine.Worldy;


  /// GETMOUSEDOWN


  for I := 0 to 3 do
  Begin

    mup[i]:=false;

    if (Mouse.Pressed[i]=FALSE)and(pressed[i]=true) then
    //if (Mouse.Released[i]=true)and(pressed[i]=true) then
    Begin
      mup[i]:=true;
    End;

    mdown[i]:=false;

     if (Mouse.Pressed[i]=TRUE)and(pressed[i]=false) then
    Begin
      mdown[i]:=true;
    End;

    pressed[i]:=Mouse.Pressed[i];
  end;


 { for I := 0 to 3 do
  Begin
    mdown[i]:=false;

    if Mouse.Pressed[i] then
    Begin
      if pressed[i]=false then
       mdown[i]:=true
        else
          mdown[i]:=false;
          pressed[i]:=true;
    End else pressed[i]:=false;

  end;   }



  {НОВОЕ УПРАВЛЕНИЕ!}
   EngineOn:=false;
   if Mouse.Pressed[mb2] then Begin
      EngineOn:=true;
   End;

   Droping:=false;
   if mb4<>mb3 then
   begin
   if Mouse.Pressed[mb3] then
   Begin
      Droping:=true;
      //if ((CursorOnCapsule)and(TakenCapsule<>nil)) then
      //Droping:=false;
   End end
    else
      if Mdown[mb3] then
          Droping:=true;
  /// ALF
  h:=Mainform.Device.Height div 2;
  w:=Mainform.Device.Width div 2;
  if (MX-w)<>0 then
  if (MX-w)>0 then Begin
      alf:=arctan((-MY+h)/(MX-w));
  End
    else  Begin
       alf:=pi - arctan((MY-h)/(MX-w));
    End;
  if alf<0 then alf:=alf+2*pi;

     //// RV
  RV:=SQRT(SQR(MX-w)+SQR(MY-h));
  RV:=RV/Engine.WorldScaleX;

  if InGame then
  Begin


   if not(Mouse.MouseWheel<0) then canwd:=true;
   if not(Mouse.MouseWheel>0) then canwu:=true;

     //////// ALTWEAPON
   if (AltWeaponsCount>=1) then Begin

    if (Mouse.MouseWheel>0)and(canWU) then
    Begin
       NextWeap;
       canwu:=false;
   end else
          if (Mouse.MouseWheel<0)and(canWD) then
            Begin
              PrevWeap;
              canwd:=false;
            End;
   End;


    if canshoot=false then
  if mdown[mb1] then
   canshoot:=true;

     //////// SHOT

   if Mouse.Pressed[mb1] then
   Begin
   if (hudt<=0)and(health>0) then
    if (CursorOnCapsule)and(takencapsule<>nil) then
    Begin
       if (mdown[mb1])and(mb1=mb4){or(Mouse.Pressed[mb3])} then
       Begin
         TakeCapsule;

         Droping:=false;
       End;
      canshoot:=false;
    End  else
     if (CursorOnCapsule)and(takencol<>nil) then
     Begin
       if (mdown[mb1])and(mb1=mb4) then
         TakeColor;
        canshoot:=false;
      End
         else
     if (CursorOnCapsule)and(pushtile<>nil) then
     Begin
       if (mdown[mb1])and(mb1=mb4) then
         pushtile.Push;
        canshoot:=false;
      End
         else
          if (CursorOnBox)and(takeBox<>nil) then
          Begin
            if (mdown[mb1])and(mb1=mb4) then
              TakeBox.TakeIt;
              canshoot:=false;
          End else
            if canshoot then WaitShoot:=true;
   //End;
  End;
if mb4<>mb1 then
Begin
 if Mouse.Pressed[mb4] then
   Begin
   if (hudt<=0)and(health>0) then
    if (CursorOnCapsule)and(takencapsule<>nil) then
    Begin
       if (mdown[mb4]){or(Mouse.Pressed[mb3])} then
       Begin
         TakeCapsule;

         Droping:=false;
       End;
    //  canshoot:=false;
    End  else
     if (CursorOnCapsule)and(takencol<>nil) then
     Begin
       if mdown[mb4] then
         TakeColor;
      //  canshoot:=false;
      End
         else
     if (CursorOnCapsule)and(pushtile<>nil) then
     Begin
       if mdown[mb4] then
         pushtile.Push;
       // canshoot:=false;
      End
         else
          if (CursorOnBox)and(takeBox<>nil) then
          Begin
            if mdown[mb4] then
              TakeBox.TakeIt;
         //     canshoot:=false;
          End;
   End;
End;
  End;



     //////// МЕНЯЕМ ПУШКУ

   if Mouse.Released[2] then
     CanChangeWeapon:=true;

  { if Mouse.Pressed[2] then
     if CanChangeWeapon=True then
           Begin
            ChangeWeap;
            CanChangeWeapon:=false;
              if CurrentWeapon>9 then CurrentWeapon:=1;
              if CurrentWeapon<=0 then CurrentWeapon:=9;
           End;    }

   if (inventory=true) and(Hudt=100)and (HintMenu=false)
   then Begin
     MouseInventory;
   End;

   if (Maplookmenu=true)
   then Begin
     mouseMaplookmenu;
   End;

   if (inventory2=true) and(Hudt2=100)
   then Begin
     MouseInventory2;
   End;

   if (inventory3=true) and(Hudt3=100)
   then Begin
     MouseInventory3;
   End;

   if ((stopmenu=true)or(inmenu=true)or(menun=7))and (Menut=100)
   then Begin
     MouseMenu;
     Waitshoot:=false;
   End;

end;

procedure TMainForm.NewMenu;
var i,i2:integer;
    _alf2:real;
    _Dx:integer;
begin


     Gticks:=GTicks+(0.005)*lagcount;
     if Gticks>5 then
     Begin
       GTicks:=0;
       inc(msn);
       if msn=7 then
          msn:=1;
     End;

       case msn of
          1,2,3,4,5:_DX:=DeltaX;
          6:_DX:=0;
       end;


     with MyCanvas do
     Begin
            if (nextmenu>0)and(nextmenu<5)or(nextmenu=6) then
                i:=255
            else
            Begin
              i:=round(menut)*5;
              if i>255 then
                i:=255;
            End;
             if (Gticks<pi)and(Gticks>0) then
             Begin
                _alf2:=sin(Gticks)*i;
                  
                i:=round(sin(Gticks/2)*trunc(200*resolutionscaleX));
                i2:=round(sin(Gticks/2)*trunc(150*resolutionscaleY2));
             End
               else _alf2:=0;


     if (msN>0)and(msN<7) then
     Begin
     DrawStretch(MenuImages.Image[inttostr(MSN+1)],0,
      -_DX-i,
      -i2,
      Device.Width+i*2+_DX*2,
      trunc(1200*resolutionscaleY2)+i2*2,1,1,false,false,false,
      cRGB4(255,255,255,trunc(_alf2)),
      fxBlend);
  End;
  End;

end;

procedure TMainForm.NewProfileProgress;
var i,j:integer;
 mapfile:TStringList;
begin
  playtime:=0;
  mapfile:=TStringList.Create;
  hintson:=true;
  mapfile.Add('');

  for i:=1 to 4 do
  Begin
      mapfile.Add('');
      mapfile.Add('');
  End;

  for i:=1 to 3 do
  Begin
      mapfile.Add('');
  End;
   mapfile.Add(inttostr(9876));
   mapfile.Add('0');
   mapfile.Add(inttostr(9876));

  for I := 1 to 5 do
    mapfile.Add('0');

  if difficulty=0 then
      difficulty:=2;

  diffi:=difficulty;

  mapfile.Add(inttostr(difficulty));
  mapfile.Add('0');
  
  mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Global.loc');
     mapfile.Clear;
     mapfile.Add('-1');
     mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckLevel.loc');


   mapfile.Clear;
   while mapfile.Count<levels.Count*6+5 do
     mapfile.Add('-1');
   mapfile:=coding(mapfile);
   mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Stat.loc');


   mapfile.Clear;
   if hintson then
     mapfile.Add('1')
      else
        mapfile.Add('0');

   mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Hints.loc');
   alldials.Clear;
   alldials.SaveToFile('Saves\Slot'+inttostr(slot)+'\AllDials.loc');

  mapfile.Destroy;
end;

procedure TMainForm.NextLevel;
begin
 if level<levels.Count-1 then
               Begin
                leveldone:=false;
                inc(level);
                saveprofileprogress;
                loadprofileprogress;
                loadscenariotext;
                gameover:=false;
                menun:=10;
                nextmenu:=10;
                inmenu:=true;
                GoBlack:=false;

                if (level) mod 5=0 then
                Begin
                 IntroNumber:= (level) div 5+1;
                 nextmenu:=16;
                // menuready:=false;
                 menun:=16;      //    bfdghfghfgh
                 loadIntro;
                End;
                

               End else
                Begin
                  leveldone:=false;
                  inc(level);
                  saveprofileprogress;
                  loadprofileprogress;
                  loadscenariotext;
                  gameover:=false;
                 // menun:=11; {ИГРА ПРОЙДЕНА}
                 // nextmenu:=11;
                  inmenu:=true;

                  IntroNumber:= 4; //(level-2) div 5+1;
                  nextmenu:=16;
                  menun:=16;      //  hfhfghfghgf
                  loadIntro;


                End;
end;

procedure TMainForm.NextWeap;
var i,j:integer;
begin
if inventory2=false then
Begin
 Changeweap;
 j:=AltWeapons[AltWeaponsCount];
              for i :=AltWeaponsCount  Downto 2  do
              Begin
                AltWeapons[i]:=AltWeapons[i-1];
              End;
              AltWeapons[1]:=j;

              AltWeapon:=AltWeapons[1];

End;
end;

procedure TMainForm.PostFilter;
begin
//////
    BoomEff;

    if golight then
    Begin
      if LightTime<LightMax then
       LightTime:=LightTime+lagcount*10;
      if LightTime>=LightMax then
      Begin
         LightTime:=LightMax;
         golight:=false;
      End;
    End
    else
     if LightTime>0 then
     Begin
       LightTime:=LightTime-lagcount*5;
     End;

   if LightTime>0 then
    MyCanvas.FillRect(rect(0,0,Device.Width,Device.Height),cRGB4(255,255,255,trunc(Lighttime)),fxadd);

   if Needlight>0 then
    MyCanvas.FillRect(rect(0,0,Device.Width,Device.Height),cRGB4(255,255,255,trunc(needlight*50)),fxlight);

  if Fonar then
   //if HiEffs then
      MyCanvas.TexMap(AsphyreTextures1[0], pBounds4(0, 0, Device.Width, Device.Height),
    clWhite4, PostFilter3TexCoords, fxMultiply);

end;

procedure TMainForm.PostFilter2;
begin
  if GoBlack then
  Begin
    if Fade1<255 then
    Fade1:=Fade1+abs(Timer.Delta);
    if Fade1>255 then fade1:=255;
    FadeIn(round(Fade1));
  End else
  if Fade1>0 then
  Begin
     Fade1:=Fade1-abs(Timer.Delta)*2;
     if fade1<0 then fade1:=0;
     FadeIn(round(Fade1));
  End;
end;

procedure TMainForm.PostFilter3;
begin
if Fonar then
//if Hieffs then
Begin
 AsphyreTextures1.RenderOn(0, PostFilter3Draw, clBlack, false);
// MyCanvas.Publisher:=Device;
End;

end;

procedure TMainForm.PostFilter3Draw(Sender: TObject);
var I,bx,by,ba,br:integer;
    ind,indy:real;
begin
////
  MyCanvas.FillRect(0,0,fonarsize,fonarsize,Fonarcolor{cRGB1(40,40,100)},fxNone);

  ind:=fonarsize/Device.Width;
  indy:=fonarsize/Device.Height/ind;

  ba:=trunc(GameScaleX*400*ResolutionScaleX*ind);

  MyCanvas.DrawStretch(Images.Image['fonar'],0,trunc(fonarsize/2-ba)
            ,trunc(fonarsize/2-ba*indy),trunc(fonarsize/2+ba)
            ,trunc(fonarsize/2+ba*indy),false,false,clWhite4,fxAdd);

 ba:=trunc(GameScaleX*200*ResolutionScaleX*Ind);

 MyCanvas.DrawStretch(Images.Image['fonar'],0,trunc(mx*fonarsize/Device.Width-ba)
            ,trunc(my*fonarsize/Device.Height-ba*indy),trunc(mx*fonarsize/Device.Width+ba)
            ,trunc(my*fonarsize/Device.Height+ba*indy),false,false,clWhite4,fxAdd);
  

    for I := 1 to 32 do
      Begin
        if PostFilter3flashLights[I].r>=0 then
        Begin

         if not(PostFilter3flashLights[I].ready) then
         Begin
          if PostFilter3flashLights[I].r<512 then
            PostFilter3flashLights[I].r:=PostFilter3flashLights[I].r+Timer.Delta*12;
           if PostFilter3flashLights[I].r>512 then
           Begin
            PostFilter3flashLights[I].r:=512;
            PostFilter3flashLights[I].ready:=true;
           End;
         End else
             PostFilter3flashLights[I].r:=PostFilter3flashLights[I].r-Timer.Delta*10;
         if PostFilter3flashLights[I].r>0 then
         Begin
            bx:=trunc(((PostFilter3flashLights[I].x)-Engine.WorldX)*Engine.worldScaleX{/Device.Width*1600});
            by:=trunc(((PostFilter3flashLights[I].y)-Engine.WorldY)*Engine.worldScaley{/Device.height*1200});
            ba:=255;
            if (PostFilter3flashLights[I].ready)and(PostFilter3flashLights[I].r<256) then
               ba:=trunc(PostFilter3flashLights[I].r);

            br:=trunc(PostFilter3flashLights[I].r*ind*GameScaleX*ResolutionScaleX);

           MyCanvas.DrawStretch(Images.Image['fonar'],0,trunc(bx*fonarsize/Device.Width-br)
            ,trunc(by*fonarsize/Device.Height-br*indy),
            trunc(bx*fonarsize/Device.Width+br)
            ,trunc(by*fonarsize/Device.Height+br*indy),false,false,crgb4(255,255,255,ba),fxAdd)

         End
          else
            PostFilter3flashLights[I].r:=0
        End;
      End;


end;

procedure TMainForm.PrevWeap;
var i,j:integer;
begin
  if inventory2=false then
    Begin
              Changeweap;

              j:=AltWeapons[1];
              for i :=1  to  AltWeaponsCount-1 do
              Begin
                AltWeapons[i]:=AltWeapons[i+1];
              End;
              AltWeapons[AltWeaponsCount]:=j;

              AltWeapon:=AltWeapons[1];

    End;

end;


procedure TMainForm.ReadMapHeader;
var LoadMap:TStringList;
    i,sssx,sssy:integer;
    par:string;
begin

  MapStat.MScore:=0;
  MapStat.MMax:=400;
  MapStat.Menemies:=0;
  MapStat.Mplasmids:=0;
  MapStat.Msecrets:=0;
  MapStat.Maccuracy:=0;
  MapStat.MBest:='';

  MapStat.MDone:=false;

  _MapAuthor:='';
  _MapAbout:='';
  _MapName:='';
  MapStat.MSurvival:=false;
  sssx:=0;
  sssy:=0;
  try
    LoadMap:=TStringList.Create;
    LoadMap.LoadFromFile('UserMaps\'+MapsList[MapN]);
    i:=0;
    while (i<LoadMap.Count - 1)and(Loadmap[i]<>'//') do
    Begin

      if Pos('SizeX: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        sssx:=strtoint(par);
      End;

      if Pos('SizeY: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Size: '));
        sssy:=strtoint(par);
      End;

      if Pos('Name: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Name: '));
        _MapName:=(par);
      End;
      if Pos('Author: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('Author: '));
        _MapAuthor:=(par);
      End;
      if Pos('About: ',loadmap[i])=1 then
      Begin
        par:=loadmap[i];
        delete(par,1,length('About: '));
        _MapAbout:=(par);
      End;
      if Pos('Survival',loadmap[i])=1 then
      Begin
        MapStat.MSurvival:=true;
      End;
      inc(i);
   End;
   sssx:=sssx*sssy;
     case sssx of
        900..9999:_mapSize:=Language[199];
        10000..22499:_mapSize:=Language[200];
        22500..39999:_mapSize:=Language[201];
        40000..100000:_mapSize:=Language[202]
     else                                          
       _mapSize:='?';
     end;

     if _MapName='' then
        _MapName:=Language[205];
     if _MapAbout='' then
        _MapAbout:=Language[206];
     if _MapAuthor='' then
        _MapAuthor:='???';

   if fileexists('Saves\Stats\'+MapsList[MapN]+'.sta') then
   Begin
    MapStat.MDone:=true;
    LoadMap.LoadFromFile('Saves\Stats\'+MapsList[MapN]+'.sta');
    LoadMap:=Uncoding(LoadMap);

    MapStat.MMax:=400;
    MapStat.MBest:=LoadMap[0];
    MapStat.MScore:=StrToInt(LoadMap[1]);
    MapStat.Menemies:=StrToInt(LoadMap[2]);
    MapStat.Mplasmids:=StrToInt(LoadMap[3]);
    MapStat.Msecrets:=StrToInt(LoadMap[4]);
    MapStat.Maccuracy:=StrToInt(LoadMap[5]);
    MapStat.MTime:=LoadMap[6];

    if MapStat.Menemies=-1 then
    Begin
     MapStat.MMax:=MapStat.MMax-100;
     //MapStat.Mplasmids:=0;
    End;
    if MapStat.Mplasmids=-1 then
    Begin
     MapStat.MMax:=MapStat.MMax-100;
     //MapStat.Mplasmids:=0;
    End;
    if MapStat.Msecrets=-1 then
    Begin
     MapStat.MMax:=MapStat.MMax-100;
     //MapStat.Msecrets:=0;
    End;
    if MapStat.Maccuracy=-1 then
    Begin
     MapStat.MMax:=MapStat.MMax-100;
     //MapStat.Mplasmids:=0;
    End;
   End;

   LoadMap.Destroy;

  finally
     
  end;

////
end;

procedure TMainForm.ReBuildLasers;
var i,j,_x1,_y1,_x2,_y2,napr,ii,jj,nextnapr,col,k:integer;
    mirrortype:integer;
    gonext:boolean;
begin

{ОЧИСТКА}
  for I := 0 to Engine.Count - 1 do
    if Engine[i] is TLaser then
      Engine[i].Dead
        else
         if Engine[i] is TParticle then
           if TParticle(Engine[i]).ParType=plasEff then
                Engine[i].Dead;

  for I := 1 to MirrorCount do
   if Mirrors[i]<>nil then
   Begin
     (Mirrors[i]).kdr:=0;
     if TTile(Mirrors[i]).tip>=39 then
     Begin
       TTile(Mirrors[i]).Push;
     End;
   End;
     /// kdr здесь = активность!

{СОЗДАЮ ЛАЗЕРЫ}
  for I := 1 to LaserCount do
  if Lasers[i]<>nil then
  if Lasers[i].activ=true then
  BEGIN
    {НАСТРОЙКА ПЕРВОГО ЛУЧА СИСТЕМЫ}

    /// Определить направление
     
     napr:=0;
     if pos('1',TTile(Lasers[i]).objname)>0 then
        napr:=1 else
        if pos('2',TTile(Lasers[i]).objname)>0 then
          napr:=2 else
          if pos('3',TTile(Lasers[i]).objname)>0 then
            napr:=3 else
            if pos('4',TTile(Lasers[i]).objname)>0 then
              napr:=4;
   //// цвет
    col:=TTile(Lasers[i]).pars[1];


    nextnapr:=napr;

   ///// x1,y1
    case napr of
     1:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).SpriteWidth)-3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).SpriteHeight/2)+3;
      End;
     2:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).SpriteWidth/2)+3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).SpriteHeight)-5;
      End;
     3:Begin
       _x1:=trunc(TTile(Lasers[i]).x)+3;
       _y1:=trunc(TTile(Lasers[i]).y+TTile(Lasers[i]).SpriteHeight/2)+3;
     End;
     4:Begin
       _x1:=trunc(TTile(Lasers[i]).x+TTile(Lasers[i]).SpriteWidth/2)+3;
       _y1:=trunc(TTile(Lasers[i]).y)+3;
      End;
   end;

   gonext:=true;
   {ЗАПУСКАЮ ЦИКЛ ПОСТРОЕНИЯ СИСТЕМЫ ОТРАЖЕНИЙ ЛУЧА}
   while Gonext do
   Begin

     for J := 1 to 50 do
     begin
       {ЦИКЛ ПОИСКА ЗЕРКАЛ}

       /// КООРДИНАТА ПРОВЕРКИ
       case napr  of
         1:Begin
           _x2:=_x1+J*100;
           _y2:=_y1;
          End;
         2:Begin
           _x2:=_x1;
           _y2:=_y1+J*100;
          End;
         3:Begin
           _x2:=_x1-J*100;
           _y2:=_y1;
          End;
         4:Begin
           _x2:=_x1;
           _y2:=_y1-J*100;
          End;
       end;
         ii:=_x2 div 100;
         jj:=_y2 div 100;

       /// ПРОВЕРЯЮ ВХОД В СЕТЬ
       if (ii>0)and(ii<mapsizeX)and(jj>0)and(jj<mapsizeY) then
       BEGIN
          /// Занята ли ячейка
          if SMMap[ii,jj]<>0{=true} then     {AIMAP[i,j]=true}
          begin
            /// Занята
            gonext:=false;

            if napr mod 2 <>0 then
              _x2:=ii*100+50
                else
                  _y2:=jj*100+50;

            for k := 1 to mirrorcount do
             if Mirrors[k]<>nil then
               if (abs(TSprite(Mirrors[k]).x+TSprite(Mirrors[k]).SpriteWidth/2-_x2)<TSprite(Mirrors[k]).SpriteWidth/2)
               and(abs(TSprite(Mirrors[k]).y+TSprite(Mirrors[k]).SpriteHeight/2-_y2)<TSprite(Mirrors[k]).SpriteHeight/2) then
                 //if (TTile(Mirrors[k]).tip=35)or(TTile(Mirrors[k]).tip=34) then
                   Begin
                     mirrortype:=TTile(Mirrors[k]).tip-33;

                     if mirrortype>4 then
                          mirrortype:=mirrortype-5;


                     if napr mod 2 <>0 then
                      _x2:=trunc(TSprite(Mirrors[k]).x+58)
                      else
                        _y2:=trunc(TSprite(Mirrors[k]).y+58);

                      gonext:=true;
                      nextnapr:=0;
                      if mirrortype<3 then
                      Begin
                          TTile(Mirrors[k]).kdr:=1;


                      case napr of
                       1:if mirrortype=1 then
                           nextnapr:=2
                           else
                             nextnapr:=4;
                       2:if mirrortype=1 then
                           nextnapr:=1
                           else
                             nextnapr:=3;
                       3:if mirrortype=1 then
                           nextnapr:=4
                           else
                             nextnapr:=2;
                       4:if mirrortype=1 then
                           nextnapr:=3
                           else
                             nextnapr:=1;
                      end;


                      End;

                      if nextnapr=0 then
                        gonext:=false;

                      if mirrortype>=12 then
                      Begin
                        case  mirrortype of
                          12:_x2:=trunc(TSprite(Mirrors[k]).x+236);
                          13:_x2:=trunc(TSprite(Mirrors[k]).x+65);
                          14:_y2:=trunc(TSprite(Mirrors[k]).y+236);
                          15:_y2:=trunc(TSprite(Mirrors[k]).y+65);
                        end;
                        
                        (Mirrors[k]).pars[2]:=col;
                        (Mirrors[k]).kdr:=1;
                        (Mirrors[k]).Push;
                      End else
                      if (Mirrors[k].tip=39)or(Mirrors[k].tip=40) then
                      Begin
                         Mirrors[k].kdr:=1;
                         Mirrors[k].Push;
                      End;



                      break;
                   End;
            break;
          end;
       END else
          BEGIN
           /// Ячейка ВНЕ сети
           gonext:=false;
           break;
          END;
     {КОНЕЦ ЦИКЛА ПОИСКА ЗЕРКАЛ}
     end;

         //// СОЗДАЮ СПРАЙТ
           if napr>0 then
           
             with TLaser.Create(Engine)  do
               BEGIN
                   ImageName := 'box1';

                    if _x1<_x2 then
                      x:=_x1
                        else
                          x:=_x2;
                    if _y1<_y2 then
                      y:=_y1
                        else
                          y:=_y2;

                    ScaleX:=2;
                    ScaleY:=2;

                    if napr mod 2=0 then
                    begin
                      ImageName := 'las';
                      ScaleY:=abs(_y1-_y2)/PatternHeight;
                    end
                     else
                      begin
                        ImageName := 'las2';
                        ScaleX:=abs(_x1-_x2)/PatternWidth;
                      end;
                    lascolor:=col;

                    Red:=RedW[lascolor];
                    Green:=GreenW[lascolor];
                    Blue:=BlueW[lascolor];

                    SpriteHeight:=PatternHeight*ScaleY;
                    SpriteWidth:=PatternWidth*ScaleX;

                    CollideRect := Rect(Round(X),Round(Y),
                          Round(X + SpriteWidth), Round(Y + SpriteHeight));

                    DoCollision := True;
                    CollideMethod:=cmRect;
                    direction:=napr;
                    z:=4;

                    endonwall:=not(gonext);
                   { if (direction=1)or(direction=3) then
                        for k := Trunc(x) div 100+1 to Trunc(x+SpriteWidth) div 100-1 do
                          AIMaP[k,trunc(y) div 100]:=true
                            else
                            for k := Trunc(y) div 100+1 to Trunc(y+SpriteHeight) div 100-1 do
                              AIMaP[trunc(x) div 100,k]:=true;  }
                    
               END;

               if gonext then
               Begin
                 _x1:=_x2;
                 _y1:=_y2;

                 napr:=nextnapr;
                 
               End;
    {КОНЕЦ ЦИКЛА ПОСТРОЕНИЯ СИСТЕМЫ ОТРАЖЕНИЙ ЛУЧА}
   End;

  END;

  {ЗЕРКАЛА}
  for I := 1 to MirrorCount do
    if Mirrors[i]<>nil then
    with Mirrors[i] do
      if (tip=34)or(tip=35) then
      Begin
        if childs[0]<>nil then
        Begin
           if kdr=1 then
            TSprite(childs[0]).visible:=true
              else
                TSprite(childs[0]).visible:=false;
        End
      End;

end;

procedure TMainForm.SaveCheckPoint;
var i,j:integer;
 _mapobject:Tsprite;
 mapfile:TStringList;
begin
/// Player properties

///

/// Map

  mapfile:=TStringList.Create;

//if Campaign then
//Begin
  if diffi<=2 then
   Begin

    mapfile.Add(inttostr(100));
    if health<100 then
    Begin
      Health:=100;
      Curetime:=0;
    End;

   End else
   begin
     if health<30 then
     Begin
      Health:=30;
      Curetime:=0;
     End;
     mapfile.Add(inttostr(trunc(health)));
   end;
  mapfile.Add(inttostr(CurrentWeapon));

  for i:=1 to 6 do
  Begin
    mapfile.Add(inttostr(Altweapons[i]));
  End;

  for i:=1 to 8 do
  Begin
    mapfile.Add(inttostr(weapons[i].count));
  End;

  for i:=1 to 4 do
  Begin
    if items[i]<>nil then Begin
      mapfile.Add(items[i].ItemFileName);

      mapfile.Add(inttostr(trunc(items[i].ItemCurrenttime)));
    End else
    Begin
      mapfile.Add('');
      mapfile.Add('');
    End;
  End;

  for i:=1 to 3 do
  Begin
    if Bonuses[i]<>nil then
    mapfile.Add(Bonuses[i].BonusFileName)
    else
      mapfile.Add('');
  End;

    mapfile.Add(inttostr(trunc(shieldtime)));
    mapfile.Add(inttostr(shieldcolor));
    mapfile.Add(inttostr(globalscore+9876));

    mapfile.Add(inttostr(levelscore.enms));
    mapfile.Add(inttostr(levelscore.enmscount));

    mapfile.Add(inttostr(levelscore.plasmids));
    mapfile.Add(inttostr(levelscore.plasmidscount));

    mapfile.Add(inttostr(levelscore.secrets));
    mapfile.Add(inttostr(levelscore.secretscount));

    mapfile.Add(inttostr(levelscore.shotsluck));
    mapfile.Add(inttostr(levelscore.shootscount));

    mapfile.Add(inttostr(trunc(leveltime)));

    if Campaign then
      mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckPoint.loc')
       else
          mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\'+MapsList[MapN]+'.loc');

    mapfile.Clear;
    CheckPointenabled:=true;

   mapfile.Add('SizeX: '+inttostr(mapsizex));
   mapfile.Add('SizeY: '+inttostr(mapsizey));

    for i:=0 to dopparlist.Count-1  do
       mapfile.Add('Load: '+(dopparlist[i]));

  for i := 0 to Engine.Count - 1 do
    Begin
     if Engine[i]<>nil then
     Begin
      _mapObject:=TTile(Engine[i]);

      //// TTILE
      if Engine[i] is TTile then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TTile(_mapObject).MyObjN].Name);

      //  if TTile(_mapObject).MyObjN=0 then showmessage('!!!1');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z+3)));


       for j := 1 to 6 do
         if (Objs[TTile(_mapObject).MyObjN].parns[j]<>'') then
          mapfile.Add(Objs[TTile(_mapObject).MyObjN].parns[j]+': '+inttostr(TTile(_mapObject).pars[j]) );
      End;

      ///// TENEMY
      if Engine[i] is TEnemy then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TEnemy(_mapObject).enmMyObjN].Name);

      //  if TEnemy(_mapObject).EnmMyObjN=0 then showmessage('!!!2');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z)));

        for j := 1 to 2 do
         if (Objs[TEnemy(_mapObject).enmMyObjN].parns[j]<>'') then
          Begin
              mapfile.Add(Objs[TEnemy(_mapObject).enmMyObjN].parns[j]+': '+inttostr(TEnemy(_mapObject).EnmWeap) );
             if j=2 then
               mapfile.Add(Objs[TEnemy(_mapObject).enmMyObjN].parns[j]+': '+inttostr(TEnemy(_mapObject).EnmWeap2) );
          End;

      End;

      /// Tactor
      if Engine[i] is TActor then
      if TActor(_mapObject).mustdie=false then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TActor(_mapObject).MyObjN].Name);

      //  if TEnemy(_mapObject).EnmMyObjN=0 then showmessage('!!!2');

        mapfile.Add('X: '+inttostr(round(TActor(_mapObject).x0)));
        mapfile.Add('Y: '+inttostr(round(TActor(_mapObject).y0)));
        mapfile.Add('Z: '+inttostr(round(TActor(_mapObject).z)));

        for j := 1 to 2 do
         if (Objs[TActor(_mapObject).MyObjN].parns[j]<>'') then
          Begin
              case j  of
                1: mapfile.Add(Objs[TActor(_mapObject).MyObjN].parns[j]+': '+inttostr(TActor(_mapObject).ey) );
                2: mapfile.Add(Objs[TActor(_mapObject).MyObjN].parns[j]+': '+inttostr(TActor(_mapObject).ex) );
               // 3: if TActor(_mapObject).mustdie then
                //    mapfile.Add(Objs[TActor(_mapObject).MyObjN].parns[j]+': 1' );
              end;
          End;

      End;

      /// TCapsule
      if Engine[i] is TCapsule then
      if (TCapsule(Engine[i]).tip<>1)and(TCapsule(Engine[i]).MyObjN<>0) then
      Begin                                                  

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TCapsule(_mapObject).MyObjN].Name);

      //  if TCapsule(_mapObject).MyObjN=0 then showmessage('!!!3');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z)));

      if TCapsule(Engine[i]).tip=4 then
        if TCapsule(Engine[i]).col<>0 then
          mapfile.Add('Color: '+inttostr(TCapsule(Engine[i]).col));

      if TCapsule(Engine[i]).tip=5 then
      Begin
        if TCapsule(Engine[i]).col<>0 then
          mapfile.Add('Message: '+inttostr(TCapsule(Engine[i]).col));
        if TCapsule(Engine[i]).mcount<>0 then
          mapfile.Add('Count: '+inttostr(TCapsule(Engine[i]).mcount));
        if TCapsule(Engine[i]).IsDone then
          mapfile.Add('Done: 1');
      End;

       for j := 1 to 6 do
          if (Objs[TCapsule(_mapObject).MyObjN].parns[j]<>'') then

            if (TCapsule(_mapObject).InCapsule[j]<>nil) then
            Begin
              if (TCapsule(_mapObject).InCapsule[j] is TItem) then
                  mapfile.Add(Objs[TCapsule(_mapObject).MyObjN].parns[j]+': '+
                   TItem(TCapsule(_mapObject).InCapsule[j]).ItemFileName)
                   else
              if (TCapsule(_mapObject).InCapsule[j] is TBonus) then
                  mapfile.Add(Objs[TCapsule(_mapObject).MyObjN].parns[j]+': '+
                   TBonus(TCapsule(_mapObject).InCapsule[j]).BonusFileName);
            End;
      End;

      /// TMina
      if Engine[i] is TMina then
      if  TMina(_mapObject).MyObjN>-1 then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TMina(_mapObject).MyObjN].Name);

       // if TMina(_mapObject).MyObjN=0 then showmessage('!!!4');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z)));


      End;

      /// Dopeff
      if Engine[i] is TDopEff then
      if TDopEff(Engine[i]).used=false then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: '+Objs[TDopEff(_mapObject).MyObjN].Name);

     //   if TDopeff(_mapObject).MyObjN=0 then showmessage('!!!5');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z)));

       for j := 1 to 6 do
         if (Objs[TDopEff(_mapObject).MyObjN].parns[j]<>'') then
         Begin
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Width') then
              mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(round(_mapobject.x-_mapobject.CollideRect.Left+32)))
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='FlashLightOn') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(TDopEff(_mapObject).cnt))
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Red') then
              mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(TDopEff(_mapObject).Red))
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Green') then
              mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(TDopEff(_mapObject).Green))
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Blue') then
              mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(TDopEff(_mapObject).Blue))   // zxzx
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Height') then
              mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '
                +inttostr(round(_mapobject.y-_mapobject.CollideRect.top+32)))
            else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Event') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).max))
                else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Hint') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).max))
                else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Color') then
                 mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).cnt))
               else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='ReplaceY') then
                 mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).y0))
               else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Number') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).max))
               else
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Count') then
            Begin
               if (Objs[TDopEff(_mapObject).MyObjN].Name='bombin') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).cnt))
                else
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).cnt+1))
            End;
            if (Objs[TDopEff(_mapObject).MyObjN].parns[j]='Mode') then
            Begin
              // if (Objs[TDopEff(_mapObject).MyObjN].Name='arcade') then
                mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).cnt))
              //  else             
              //  mapfile.Add(Objs[TDopEff(_mapObject).MyObjN].parns[j]+': '+inttostr(TDopEff(_mapObject).cnt))
            End;
         End;
      End;

      /// Player
      if Engine[i] is TPlayer then
      Begin

        mapfile.Add('//');
        mapfile.Add('Name: Playerstart');

        mapfile.Add('X: '+inttostr(round(_mapObject.x)));
        mapfile.Add('Y: '+inttostr(round(_mapObject.y)));
        mapfile.Add('Z: '+inttostr(round(_mapObject.z)));

     {  for j := 1 to 6 do
         if (_mapobject.parnames[j]<>'') then
            if (_mapobject.pars[j]<>'') then
                mapfile.Add(_mapobject.parnames[j]+': '+_mapobject.pars[j]);}
      End;


     End;

    End;

    if Campaign then
    Begin

     mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckPoint.map');

     mapfile.Clear;
     mapfile.Add(inttostr(level));
     mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckLevel.loc');
     Checkedlevel:=level;

     levdials.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckDials.loc');
     Alldials.SaveToFile('Saves\Slot'+inttostr(slot)+'\CheckAllDials.loc');
    End else
    Begin
     mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\'+MapsList[MapN]);

    End;

     mapfile.Destroy;

     

end;

procedure TMainForm.SaveKeys;
var s,ka:TstringList;
 i,j,k:integer;
begin
  ///Инициализирую Управление
  /// Имена клавиш
  S:=TstringList.Create;
  KA:=TstringList.Create;

  ka.LoadFromFile('Data\Locs\KeyActions.loc');

  S.LoadFromFile('Data\Locs\KeyNames.loc');
  for I := 0 to S.Count - 1 do
    if I<120 then KeyNames[i]:=S[i];
  KeyNames[200]:='Up';
  KeyNames[208]:='Down';
  KeyNames[203]:='Left';
  KeyNames[205]:='Right';

   for I := 0 to 20 do
   keyWait[i]:=0;


  {s.LoadFromFile('Data\KeysDefault.cfg');
  for i := 0 to (s.Count-1) div 2 do
   for j := 0 to ka.Count-1 do
   Begin
     if s[i*2]=ka[j]  then
        for k := 0 to 210 do
          if s[i*2+1]=keynames[k] then
              KeyCodes[j]:=k;
   End;          }

   s.Clear;

   for i := 0 to ka.Count-1 do
   Begin
     s.Add(ka[i]);
     s.Add(KeyNames[KeyCodes[i]]);
   End;
     s.SaveToFile('Data\Keys.cfg');

  S.Destroy;
  ka.Destroy;
end;

procedure TMainForm.SaveProfileProgress;
var i,j:integer;
 mapfile:TStringList;
begin
/// Player properties
 if level<levelcodes.Count-1 then

  mapfile:=TStringList.Create;

  mapfile.Add(levelcodes[level]);

  for i:=1 to 4 do
  Begin
    if items[i]<>nil then Begin
      mapfile.Add(items[i].ItemFileName);

      mapfile.Add(inttostr(trunc(items[i].ItemCurrenttime)));
    End else
    Begin
      mapfile.Add('');
      mapfile.Add('');
    End;
  End;

  for i:=1 to 3 do
  Begin
    if Bonuses[i]<>nil then
    mapfile.Add(Bonuses[i].BonusFileName)
    else
      mapfile.Add('');
  End;
  // globalscore:=Levelscore.total;
   mapfile.Add(inttostr(globalscore+9876));
   if cheater then
      mapfile.Add('1')
       else
         mapfile.Add('0');
   mapfile.Add(inttostr(allscore+9876));

   for I := 1 to 5 do
   Begin
     /// МЕДАЛИ!
      mapfile.Add(inttostr(medals[i]));
   End;

    mapfile.Add(inttostr(difficulty));
    mapfile.Add(inttostr(trunc(playtime)));

  mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Global.loc');


  mapfile.Clear;


  /// СТАТИСТИКА
   if fileexists('Saves\Slot'+inttostr(slot)+'\Stat.loc') then
  Begin
    mapfile.LoadFromFile('Saves\Slot'+inttostr(slot)+'\Stat.loc');
    mapfile:=uncoding(mapfile);
    for I := 0 to (mapfile.Count-1)div 6  do
      for J := 0 to 5 do
        stats[i,j]:=strtoint(mapfile[i*5+j]);

     while mapfile.Count<levels.Count*5+5 do
        mapfile.Add('-1');

  End else
  Begin

    while mapfile.Count<levels.Count*5+5 do
      mapfile.Add('-1');

   for I := 0 to levels.Count-1  do
    for J := 0 to 5 do
    Begin
      stats[i,j]:=-1;
      mapfile[i*5+j]:='-1';
    End;

  End;

   if Levelscore.enmscount>0 then
   mapfile[(level-1)*5]:=inttostr(percento[1])
     else mapfile[(level-1)*5+1]:='-1';

   if Levelscore.plasmidscount>0 then
   mapfile[(level-1)*5+1]:=inttostr(percento[2])
     else mapfile[(level-1)*5+1]:='-1';

   if Levelscore.secretscount>0 then
   mapfile[(level-1)*5+2]:=inttostr(percento[3])
     else mapfile[(level-1)*5+2]:='-1';

   if Levelscore.shootscount>0 then
   mapfile[(level-1)*5+3]:=inttostr(percento[4])
     else mapfile[(level-1)*5+2]:='-1';

   mapfile[(level-1)*5+4]:=inttostr(percento[5]);

   mapfile[(level-1)*5+5]:=inttostr(playtime);
   mapfile:=coding(mapfile);
   mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Stat.loc');

   mapfile.Clear;
   if hintson then
     mapfile.Add('1')
      else
        mapfile.Add('0');

   mapfile.SaveToFile('Saves\Slot'+inttostr(slot)+'\Hints.loc');

   try
     alldials.SaveToFile('Saves\Slot'+inttostr(slot)+'\AllDials.loc');
   except
   end;
   mapfile.Destroy;
end;

procedure TMainForm.SaveProfNames;
var s:TStringList;
 i:byte;
begin
     s:=TStringList.Create;
     for i:=1 to 3  do
       s.Add(profnames[i]);
     s.SaveTofile('SAVES\Profnames.loc');
     s.Destroy;
end;

procedure TMainForm.SaveSettings;
  const
  n=19;
  Commands:array[1..n] of String=('ResolutionX: ','ResolutionY: ','BitCount: ',
  'Windowed: ','AA: ','MouseSpeed: ','VSync: ','Console: ','BigWindow: ',
  'HighDetail: ','HighEffects: ','MusVolume: ','SndVolume: ','Cheater: ',
  'Language: ','MaxFPS: ','LowAnim: ','Camera: ','ShowDialogs: ');// НАСТРОЙКИ!!!

  var s:TstringList;
  i,j:integer;
  camsaved, dialsaved:boolean;
begin
    camsaved:=false;
    dialsaved:=false;
    s:=TstringList.Create;

    
    if mb1=1 then
    Begin
      s.add('Reverse')
    End else
      s.Add(' ');
    if mb4=1 then
    Begin
      s.add('Mb2')
    End
    else if mb4=2 then
    Begin
      s.add('Mb3')
      End else
      s.Add(' ');

    s.SaveToFile('Data\Mouse.cfg');


    s.LoadFromFile('Data\Config.cfg');

    ///// ЗАГРУЗКА
    for I := 0 to s.Count - 1 do
        for j := 1 to n do
          Begin
            if Pos(commands[j],s[i])=1 then
             Begin
               case j of
                  6:{MouseSpeed:}
                    s[i]:=commands[j]+IntToStr(mspd);
                  12:{MusVolume:}
                     s[i]:=commands[j]+IntToStr(MusVolume);
                  13:{SndVolume:}
                     s[i]:=commands[j]+IntToStr(SoundVolume);
                  18: {camera}
                    begin
                      camsaved:=true;
                      if cameramode = cmCenter then
                        s[i]:= commands[j]+ '1'
                        else  s[i]:= commands[j]+ '2';
                    end;
                  19: {Dialogs}
                    begin
                      dialsaved:=true;
                      if showDLG = true then
                        s[i]:= commands[j]+ 'y'
                        else  s[i]:= commands[j]+ 'n';
                    end;

               end;
          End;
      End;

    if camsaved=false then
    begin
        if cameramode = cmCenter then
          s.Add(commands[18]+ '1')
          else  s.Add(commands[18]+ '2') ;
    end;

    if dialsaved=false then
    begin
        if showDLG = true then
          s.Add(commands[19]+ 'y')
              else  s.Add(commands[19]+ 'n');
    end;
    s.SaveToFile('Data\Config.cfg');
    s.destroy;
end;

procedure TMainForm.SaveStatistic;
var loadMap:TStringList;
begin
   LoadMap:=TStringList.Create;
   if cheater then
       LoadMap.Add(ProfNames[slot]+Language[180])
        else
    LoadMap.Add(ProfNames[slot]);

   LoadMap.Add(IntToStr(percento[5]));

   if LevelScore.enmscount=0 then
     LoadMap.Add('-1')
   else
    LoadMap.Add(IntToStr(percento[1]));

   if LevelScore.plasmidscount=0 then
     LoadMap.Add('-1')
   else
    LoadMap.Add(IntToStr(percento[2]));

   if LevelScore.secretscount=0 then
     LoadMap.Add('-1')
   else
     LoadMap.Add(IntToStr(percento[3]));

   if LevelScore.shootscount=0 then
     LoadMap.Add('-1')
   else
    LoadMap.Add(IntToStr(percento[4]));

   LoadMap.Add(showtime);
   if LevelMissionTip=5 then
      LoadMap.Add('1');

   forceDirectories('Saves\Stats\');
   LoadMap:=Coding(LoadMap);
   LoadMap.SaveToFile('Saves\Stats\'+MapsList[MapN]+'.sta');


   LoadMap.Destroy;

   ReadMapHeader;
end;

procedure TMainForm.SayLoading;
begin

  Device.Clear(clBlack);

  Fonts[1].Scale:=ResolutionScaleY2*2;

  Fonts[1].TextOut(Language[14],
      (VirtualW*ResolutionScaleX-Fonts[1].TextWidth(Language[14]))/2,
      420 *ResolutionScaleY2,
      cRGB1(255, 255, 255,200));
  MyCanvas.Circle(0,0,10,clBlack,Fxnone);
 
  Device.Flip;
end;



function TMainForm.SecToHMS(str: integer;needhour:boolean): string;
var h,m,s:integer;
    sec:real;
begin
    try
      sec:=(str);
      h:=trunc(sec/3600);
      sec:=sec-h*3600;
      m:=trunc(sec/60);
      sec:=sec-m*60;
      s:=trunc(sec);
      if needhour then
        result:=IntToStr(h)+':'+format('%.2d',[m])+':'+format('%.2d',[s])
         else
           result:=format('%.2d',[m])+':'+format('%.2d',[s]);
    except
      result:=inttostr(str);
    end;
end;

procedure TMainForm.SetMusVolumes;
var i:integer;
begin
{ if DXMenuMusic.Items.Count>0 then
 Begin
  // DXMenuMusic.Items[0].Volume:=-10000+MusVolume*100;
   if MusVolume<>0 then
      DXMenuMusic.Items[0].Volume:=-3000+MusVolume*30
        else DXMenuMusic.Items[0].Volume:=-10000;
   DXMenuMusic.Items.Restore;
   DXMenuMusic.Items[0].Stop;
 End;}

 for i := 0 to MenuSoundSystem.Count-1 do
  MenuSoundSystem.SetVolume(i,MusVolume);

 for i := 0 to SoundSystem.Count-1 do
  SoundSystem.SetVolume(i,MusVolume);
end;

procedure TMainForm.SetVolumes;
var i:integer;
begin
 for i := 0 to DXWave.Items.Count - 1 do
   //DXWave.Items[i].Volume:=-10000+SoundVolume*100;
   if SoundVolume<>0 then
        DXWave.Items[i].Volume:=-3000+SoundVolume*30
          else DXWave.Items[i].Volume:=-10000;
   DXWave.items.restore;
end;

procedure TMainForm.ShowDevConsole;
var i:integer; s:string;
    Mycolor:cardinal;
begin
     if console then
     Begin
      if cony<250 then
        cony:=cony+lagcount*5
      else
        cony:=250
     end else
       Begin
          if cony>0 then
            cony:=cony-lagcount*5
          else
            cony:=0;
       End;

     if cony<0 then cony:=0;
     if cony>250 then cony:=250;

     MyColor:=crgb1(0,0,0,155);
     if cony<>0 then
     Begin
      MyCanvas.Rectangle(0, 0, trunc(VirtualW*ResolutionScaleX),trunc(cony*ResolutionScaleY),
                Mycolor,MyColor,FxBlend);

     Fonts[1].Scale:=ResolutionScaleY;
     s:=format('%.4f',[timer.Delta]);

     Fonts[1].TextOut('FPS: '+IntToStr(Timer.FrameRate)+' // DELTA: '+s,
        50 *ResolutionScaleX,(10-250+cony )*ResolutionScaleY, cRGB1(255, 255, 255));
     s:=format('%.3f',[GameScaleX]);

     Fonts[1].TextOut('WORLD X: '+IntToStr(trunc(Engine.WorldX))+' Y: '+IntToStr(trunc(Engine.WorldY))
        +' Scale: '+s+' // LTime: '+inttostr(trunc(leveltime)),50 *ResolutionScaleX, (50-250+cony )*ResolutionScaleY, cRGB1(250, 250, 55));


    // Fonts[1].TextOut('scan: '+IntToStr(round(scaning)),
    //    50 *ResolutionScaleX,(300-250+cony )*ResolutionScaleY, cRGB1(255, 255, 255));

      if cheater then
       s:=' // Cheater! '
       else s:='';

     Fonts[1].TextOut('Player_Angle: '+IntToStr(trunc(alf*180/pi)) ,
        50 *ResolutionScaleX, (90-250+cony )*ResolutionScaleY, cRGB1(200, 200, 255));

     Fonts[1].TextOut('VisibleArea: '+IntToStr(Engine.VisibleArea.Left)+','+
     IntToStr(Engine.VisibleArea.top)+','+ IntToStr(Engine.VisibleArea.Right)+','+
     IntToStr(Engine.VisibleArea.Bottom)+s,
     50 *ResolutionScaleX,(130-250+cony )*ResolutionScaleY, cRGB1(100, 200, 255));

      Fonts[1].TextOut('Sprites: ' + IntToStr(Engine.Count) ,
        50 *ResolutionScaleX, (170-250+cony )*ResolutionScaleY, cRGB1(200, 100, 155));

     s:=format('%f',[GetProcMem]);//IntToStr(trunc(GetProcMem));

     Fonts[1].TextOut('MEMORY USING: ' + s + ' Mb // dop: ' + IntToStr(round(dop1))+'//  KEY: ' + IntToStr(round(dop2))+' ('+ dop3+')' ,
        350 *ResolutionScaleX,(170-250+cony )*ResolutionScaleY, cRGB1(200, 100, 155));

      s:='';
      if inmenu=false then
      Begin
       globalticks:=globalticks+lagcount*0.1;
       if globalticks>2*pi then
        globalticks:=0;
       if globalticks>pi then
        s:='_';
      End;

      Fonts[1].TextOut('> ' + concom+s,
        50 *ResolutionScaleX, (210-250+cony )*ResolutionScaleY, cRGB1(255, 255, 255));
     End;
end;

procedure TMainForm.ShowHintIcons;
var i,k,l:integer;
begin
/////
if HintIconsCount>0 then
begin
  if hintmenu then
    l:=255
     else
      l:=trunc(2.55*(menut));

  Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;  /// new060115
  k:=trunc(Fonts[1].TextHeight('!')*0.6);
  for I := 1 to HintIconsCount do
  begin

     if hinticons[i].img[1]='k' then
      MyCanvas.DrawStretch(HUDImages.Image[hinticons[i].img],0,
      trunc((700*resolutionScaleX+hinticons[i].X)),
      trunc((400+hinticons[i].st*50)*resolutionScaleY2-0.4*hinticons[i].h+k),
      trunc((700*resolutionScaleX+hinticons[i].X+hinticons[i].w)),
      trunc((400+hinticons[i].st*50)*resolutionScaleY2+0.4*hinticons[i].h+k),false,false,
      cRGB4(255,255,255,l),
      fxBlend)
       else
         MyCanvas.DrawStretch(HUDImages.Image[hinticons[i].img],0,
      trunc((700*resolutionScaleX+hinticons[i].X)),
      trunc((400+hinticons[i].st*50)*resolutionScaleY2-0.5*hinticons[i].h+k),
      trunc((700*resolutionScaleX+hinticons[i].X+hinticons[i].w)),
      trunc((400+hinticons[i].st*50)*resolutionScaleY2+0.5*hinticons[i].h+k),false,false,
      cRGB4(255,255,255,l),
      fxBlend)
 end;
end;
end;

procedure TMainForm.ShowMyhint;
var i,n:integer;  c:cardinal;
begin
  for I := 1 to 10 do
  if myhints[i].hinttime>0 then
  Begin
    fonts[1].Scale:=myhints[i].hintfontsize;

    n:=trunc(fonts[1].textwidth(myhints[i].hinttext));

    c:=crgb1(redw[myhints[i].hintcolor],
      greenw[myhints[i].hintcolor],
      bluew[myhints[i].hintcolor],trunc(2.5*myhints[i].hinttime));

    //fonts[1].ShadowIntensity:=1;
    fonts[1].TextOut(myhints[i].hinttext,
      myhints[i].x-n/2+2*resolutionscaleX, myhints[i].y-23*resolutionscaleX,
      crgb1(0,0,0,trunc(2.5*myhints[i].hinttime)));

    fonts[1].TextOut(myhints[i].hinttext,
      myhints[i].x-n/2, myhints[i].y-25*resolutionscaleY,
      c);

    //fonts[1].ShadowIntensity:=0;
     // mycanvas.Circle( myhints[i].x, myhints[i].y-25*resolutionscaleY,10,clred,fxnone);

    myhints[i].hinttime:=myhints[i].hinttime-lagcount*0.5;
  End;
end;

procedure TMainForm.Sline(Alfa:Integer);
var j:integer;
begin
 for j:= 0 to round(Device.Height /(64*ResolutionScaleY))+1 do
   MyCanvas.DrawStretch(Images.Image['lines'],0,0,
   round(j*64*ResolutionScaleY),Device.Width,
   round((j+1)*64*ResolutionScaleY),false,false, cRGB4(255,255,255,Alfa), fxSub);
end;

function TMainForm.Superpos(Imp1, Imp2: TImpulse): TImpulse;
begin
////
  if Imp1.ImpPower+Imp2.ImpPower>0 then
  Begin
    Result.ImpX:=(Imp1.ImpX*Imp1.ImpPower+Imp2.ImpX*Imp2.ImpPower);
    Result.ImpY:=(Imp1.ImpY*Imp1.ImpPower+Imp2.ImpY*Imp2.ImpPower);
    Result.ImpPower:=sqrt(sqr(Result.ImpX)+sqr(Result.ImpY));
    Result.ImpX:=Result.ImpX/(Imp1.ImpPower+Imp2.ImpPower);
    Result.ImpY:=Result.ImpY/(Imp1.ImpPower+Imp2.ImpPower);
  End else
  Begin
    Result.ImpX:=0;
    Result.ImpY:=0;
    Result.ImpPower:=0;
  End;
end;

procedure TMainForm.AddDialToLog(num: integer);
var i:integer;
begin
for I := 0 to 4 do
  if Dialog.Count>num*5+i then
  Begin
    LevDials.Add(Dialog[num*5+i]);
    AllDials.Add(Dialog[num*5+i]);
  End;
end;

procedure TMainForm.Addhint(hinttext:string;hintsize,hx,hy:real;hcolor:byte);
var i,n:integer;
begin
 n:=-1;
 for I := 1 to 10 do
  if myhints[i].hinttime<=0 then
  Begin
   n:=i;
   Break;
  End;

  if n=-1 then
  Begin
    for I := 1 to 9 do
     myhints[i]:=myhints[i+1];

    n:=10;
  End;

  myhints[n].hinttime:=100;
  myhints[n].hinttext:=hinttext;
  myhints[n].hintcolor:=hcolor;
  myhints[n].hintfontsize:=hintsize;
  myhints[n].x:=hx;
  myhints[n].y:=hy;
end;

procedure TMainForm.BackGround;
var i,j:integer;
  x0,y0:double;
begin

     x0:=-layerX*0.8*0.1*ResolutionScaleX+BoomX*ResolutionScaleX;
     y0:=-layerY*0.8*0.1*ResolutionScaleY+BoomY*ResolutionScaleY;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['back'], 0, (i-1)*(Device.Width )+round(x0),
      round(y0)+(j-1)*(Device.Height+1),round(x0)+(i)*Device.Width+1,
      round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxNone);


     x0:=-layerX*0.8*0.25*ResolutionScaleX+BoomX*ResolutionScaleX;
     y0:=-layerY*0.8*0.25*ResolutionScaleY+BoomY*ResolutionScaleY;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -2 to 2 do
       for j:= -2 to 2 do
     MyCanvas.DrawStretch(Images.Image['fon_3'], 0, (i-1)*(Device.Width div 2)+round(x0),
      round(y0)+(j-1)*(Device.Height div 2),round(x0)+(i)*Device.Width div 2,
      round(y0)+(j)*Device.Height div 2,
      false,false, clWhite4, fxAdd);

     x0:=-layerX*0.8*0.35*ResolutionScaleX+BoomX/1.5*ResolutionScaleX;
     y0:=-layerY*0.8*0.35*ResolutionScaleY+BoomY/1.5*ResolutionScaleY;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_2'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);

     x0:=-layerX*0.8*0.5*ResolutionScaleX+BoomX/2*ResolutionScaleX;
     y0:=-layerY*0.8*0.5*ResolutionScaleY+BoomY/2*ResolutionScaleY;
     while x0>Device.Width do x0:=x0-Device.Width;
     while x0<0 do x0:=x0+Device.Width;
     while y0>Device.Height do y0:=y0-Device.Height;
     while y0<0 do y0:=y0+Device.Height;

     for i:= -1 to 1 do
       for j:= -1 to 1 do
     MyCanvas.DrawStretch(Images.Image['fon_3'], 0, (i-1)*(Device.Width)+round(x0),
      round(y0)+(j-1)*(Device.Height),round(x0)+(i)*Device.Width, round(y0)+(j)*Device.Height,
      false,false, clWhite4, fxAdd);

end;

procedure TMainForm.BoomEff;
begin
 if BoomTime>0 then
  Begin
  BoomTime:=BoomTime-lagcount;
  BoomTicks:=BoomTicks+lagcount;
  if BoomTicks>10 then
   Begin
    BoomTicks:=10;
    BoomX:=random(10);
    BoomY:=random(10);
   End;
  End else Begin
   BoomTicks:=0;
   BoomX:=0;
   BoomY:=0;
  End;
end;

procedure TMainForm.BoomPhys(BoomX,BoomY,Power, Radius,tipp: integer);
var I,ii:integer;
    jj:real;
    NewImp:TImpulse;
begin


 for i:=0 to Engine.Count-1 do
 Begin


  if Engine[i] is TPlayer then
   Begin
      ii:=trunc(sqrt(sqr(BoomX-TPlayer(Engine[i]).Body.x)+sqr(BoomY-TPlayer(Engine[i]).Body.Y)));

      if (ii<Radius+TPlayer(Engine[i]).Body.radius)and ((ii)>1) then
      Begin

        NewImp.ImpX:=-(BoomX-TPlayer(Engine[i]).Body.x)/ii;
        NewImp.ImpY:=-(BoomY-TPlayer(Engine[i]).Body.Y)/ii;

        jj:=(Radius+TPlayer(Engine[i]).Body.RAdius-ii)/
            (Radius+TPlayer(Engine[i]).Body.RAdius);
       if tipp<>5 then
        NewImp.ImpPower:=10*Power*jj;


        TPlayer(Engine[i]).Impulse:=NewImp;
        if tipp=1 then
        Health:=Health-round(2.4*jj*Power*diff[diffi])
         else if tipp<>5 then Health:=Health-round(0.5*jj*Power);

     End
   End else

    if Engine[i] is TEnemy then
   Begin
      ii:=trunc(sqrt(sqr(BoomX-TEnemy(Engine[i]).EnmBody.x)+
                sqr(BoomY-TEnemy(Engine[i]).EnmBody.Y)));

      if (ii<Radius+TEnemy(Engine[i]).EnmBody.radius)and ((ii)>1) then
      Begin
        jj:=((Radius+TEnemy(Engine[i]).EnmBody.Radius)-ii)/
            (Radius+TEnemy(Engine[i]).EnmBody.Radius);

        if Power>5 then Power:=5;

        { smessagetime:=300;
         smessage:=(inttostr(round(12*jj*Power))+' '+inttostr(round(jj*100))
              +' '+inttostr(round(Power)));     }

        NewImp.ImpX:=-(BoomX-TEnemy(Engine[i]).EnmBody.X)/ii;
        NewImp.ImpY:=-(BoomY-TEnemy(Engine[i]).EnmBody.Y)/ii;
        NewImp.ImpPower:=Power*jj;//(Radius+70-ii)/(Radius+70);

        TEnemy(Engine[i]).EnmImpulse:=NewImp;
        if (tipp=2)then
         TEnemy(Engine[i]).EnmHealth:=TEnemy(Engine[i]).EnmHealth-round(12*jj*Power)
          else
          if(tipp=5) then
          TEnemy(Engine[i]).EnmHealth:=TEnemy(Engine[i]).EnmHealth-round(50*jj*Power)
          else
           if not((TEnemy(Engine[i]).EnmName='Boss2')and(TEnemy(Engine[i]).EnmWeap=1)) then
              TEnemy(Engine[i]).EnmHealth:=TEnemy(Engine[i]).EnmHealth-round(4*jj*Power);
     End
   End else

  if Engine[i] is TCapsule then
   Begin
      ii:=trunc(sqrt (sqr(BoomX-TCapsule(Engine[i]).Capsuleshape.POsX)+sqr(BoomY-TCapsule(Engine[i]).Capsuleshape.PosY)));
      if (ii<Radius+70)and(ii>1) then
      Begin
        if Power>5 then Power:=5;

        NewImp.ImpX:=-(BoomX-TCapsule(Engine[i]).Capsuleshape.POsX)/ii;
        NewImp.ImpY:=-(BoomY-TCapsule(Engine[i]).Capsuleshape.POsY)/ii;
        NewImp.ImpPower:=Power*(Radius+70-ii)/(Radius+70);

        if TCapsule(Engine[i]).tip=1 then
          NewImp.ImpPower:=NewImp.ImpPower/2;

        TCapsule(Engine[i]).Impulse1:=NewImp;//Superpos(TCapsule(Engine[i]).Impulse1,NewImp);

        if (TCapsule(Engine[i]).tip=4)and(tipp=5) then
        Begin
           TCapsule(Engine[i]).explode;
           DXWave.items.Find('boom2.wav').Play(false);   //////////// EXPL
        End;

      End;
   End else


  if Engine[i] is TMina then
   Begin
      ii:=trunc(sqrt (sqr(BoomX-TMina(Engine[i]).minaShape.POsX)+sqr(BoomY-TMina(Engine[i]).minaShape.PosY)));
      if (ii<Radius+70)and(ii>1)  then
      Begin
         if Power>5 then Power:=5;
        NewImp.ImpX:=-(BoomX-TMina(Engine[i]).minaShape.POsX)/ii;
        NewImp.ImpY:=-(BoomY-TMina(Engine[i]).minaShape.POsY)/ii;
        NewImp.ImpPower:=Power*(Radius+70-ii)/(Radius+70);
        TMina(Engine[i]).Impulse1:=NewImp;//Superpos(TCapsule(Engine[i]).Impulse1,NewImp);
        if (ii<120) then TMina(Engine[i]).exp:=true;

        if (tipp=5)and(ii<420) then
        Begin
            TMina(Engine[i]).exp:=true;
            TMina(Engine[i]).TimeToExplode:=40+random(40);
        End;
      End;
   End   else

   if Engine[i] is TActor then
   Begin
      ii:=trunc(sqrt (sqr(BoomX-Engine[i].X)+sqr(BoomY-Engine[i].Y)));
      if (ii<Radius+70)and(ii>1)  then
      Begin
        if (tipp=5) then
        Begin
         Engine[i].Dead;
         Mainform.BoomPhys(trunc(Engine[i].X),trunc(Engine[i].Y),4,200,1);
         MiniExplodeEff2(Engine[i].x,Engine[i].y,PExplode);
         ExplodeEff(Engine[i].x,Engine[i].y,2,PExplode);
         if Hieffs then
           ExplodeDopEff(Engine[i].x,Engine[i].y,10,10,1,4,false);
        End;
      End;
   End   else

  if Engine[i] is TDopEff then
  if Objs[TDopEff(Engine[i]).MyObjN].Name='plasmid' then
   Begin
      ii:=trunc(sqrt (sqr(BoomX-(Engine[i].X+32))+sqr(BoomY-(Engine[i].Y+32))));
      if (ii<32+Radius)and(ii>1)  then
      Begin
        if Power>5 then Power:=5;
        NewImp.ImpX:=-(BoomX-(Engine[i].X+32))/ii;
        NewImp.ImpY:=-(BoomY-(Engine[i].Y+32))/ii;
        NewImp.ImpPower:=Power*(Radius-ii)/(32+Radius);

        TDopEff(Engine[i]).Impulse1:=NewImp;//Superpos(TCapsule(Engine[i]).Impulse1,NewImp);
      End;
   End;
 End;

end;

procedure TMainForm.BornEnms;
var i,XX,YY,B:integer;
    alfashift:boolean;
begin
       /// STAS!
       ///
       ///
       ///
if LevelMissionTip<>5 then
BEGIN
  for I := 0 to Engine.Count - 1 do
    if Engine[i] is TTile then
    Begin
       if TTile(Engine[i]).tip=71 then
       if TTile(Engine[i]).pars[1]=1 then
       Begin

          XX:=trunc(TTile(Engine[i]).X+50);
          alfashift:= true;

          if  TTile(Engine[i]).objname='portal2' then
          Begin
             XX:=trunc(TTile(Engine[i]).X+250);
             alfashift:= false;
          End;

          YY:=trunc(TTile(Engine[i]).Y+120);

         // Sparkeff3(xx,yy,1,3,pfire);
          TrasserEff(xx+16,yy+16,redw[1],Greenw[1],Bluew[1],1, 30,pCol3);

        with  TEnemy.Create(Engine) do
        begin
            EnmmyobjN:=GetObjNumber('Bossturrel1');

            ImageName := 'Box1';

            if Mainform.Images.Find('enm44')<>-1 then
            Begin
              ImageName :='enm44';
            End;

            if HiDet=false then
              if Mainform.Images.Find('enm44_ld')<>-1 then
                Begin
                  ImageName :='enm44_ld';
                  ScaleX:=1.5;
                  ScaleY:=1.5;
                End;

            DrawMode:=1;

            EnmName:='enm44';

            enmweap2:=1;

            inc(Levelscore.enmscount);

            ScaleY:=scaleX;

            X:=XX;
            Y:=YY;
            Z:=3;

            EnmStatic:=false;

            EnmWeap:=1;
            EnmWeap2:=1;

            SizeXdiv2:=round(ImageWidth div 2*ScaleX);
            SizeYDiv2:=round(ImageHeight div 2*ScaleY);

            Creator;

            if alfashift then
               palf:=pi
                else
                   palf:=0;

            nextalf:=palf;

            EnmMainImpulse.ImpPower:=EnmMaxSpeed/2;

            CollideMethod:= cmRect;
            DoCollision := True;

            SpriteHeight:=ImageHeight*ScaleY;
            SpriteWidth:=ImageWidth*ScaleX;

            AITip:=1;
       End
       end
        else
       Begin
          XX:=trunc(TTile(Engine[i]).X+50);
          alfashift:= true;

          if  TTile(Engine[i]).objname='portal2' then
          Begin
             XX:=trunc(TTile(Engine[i]).X+250);
             alfashift:= false;
          End;

          YY:=trunc(TTile(Engine[i]).Y+120);

         // Sparkeff3(xx,yy,1,3,pfire);
          TrasserEff(xx+16,yy+16,redw[1],Greenw[1],Bluew[1],1, 30,pCol3);

        with  TEnemy.Create(Engine) do
        begin
            EnmmyobjN:=GetObjNumber('Bossturrel1');

            ImageName := 'Box1';

            if Mainform.Images.Find('enm5')<>-1 then
            Begin
              ImageName :='enm5';
            End;

            if HiDet=false then
              if Mainform.Images.Find('enm5_ld')<>-1 then
                Begin
                  ImageName :='enm5_ld';
                  ScaleX:=1.5;
                  ScaleY:=1.5;
                End;

            DrawMode:=1;

            EnmName:='enm5';

            enmweap2:=0;
            
            inc(Levelscore.enmscount);

            ScaleY:=scaleX;

            X:=XX;
            Y:=YY;
            Z:=3;

            EnmStatic:=false;

            EnmWeap:=1;
            EnmWeap2:=1;

            SizeXdiv2:=round(ImageWidth div 2*ScaleX);
            SizeYDiv2:=round(ImageHeight div 2*ScaleY);

            Creator;

            if alfashift then
               palf:=pi
                else
                   palf:=0;

            nextalf:=palf;

            EnmMainImpulse.ImpPower:=EnmMaxSpeed/2;

            CollideMethod:= cmRect;
            DoCollision := True;

            SpriteHeight:=ImageHeight*ScaleY;
            SpriteWidth:=ImageWidth*ScaleX;

            AITip:=3;
        end;

       End;
    End;
END
  ELSE
  BEGIN


  ///// SURVIVAL ENMS

    for I := 0 to Engine.Count - 1 do
    if Engine[i] is TTile then
    Begin
       if TTile(Engine[i]).tip=71 then
       Begin

          XX:=trunc(TTile(Engine[i]).X+50);
          YY:=trunc(TTile(Engine[i]).Y+120);
          alfashift:= true;
          if  TTile(Engine[i]).objname='portal2' then
          Begin
             XX:=trunc(TTile(Engine[i]).X+250);
             alfashift:= false;
          End;
          TrasserEff(xx+16,yy+16,redw[1],Greenw[1],Bluew[1],1, 30,pCol3);

          B:=SurvivalEnms1[LevelMission];
          if TTile(Engine[i]).pars[1]=1 then
            B:=SurvivalEnms2[LevelMission];
          if TTile(Engine[i]).pars[1]=2 then
            B:=SurvivalEnms3[LevelMission];

          with  TEnemy.Create(Engine) do
          begin
            EnmmyobjN:=GetObjNumber('enm'+intToStr(B));
            //xzx
            ImageName := 'Box1';

            if Mainform.Images.Find('enm'+intToStr(B))<>-1 then
            Begin
              ImageName :='enm'+intToStr(B);
            End;

            if B<>44 then
             enmMyObjN:=GetObjNumber('Enemy'+intToStr(B))
               else
                 enmMyObjN:=GetObjNumber('Enemy4_4');

           // showmessage(inttostr(enmMyObjN));
            if HiDet=false then
              if Mainform.Images.Find('enm'+intToStr(B)+'_ld')<>-1 then
                Begin
                  ImageName :='enm'+intToStr(B)+'_ld';
                  ScaleX:=1.5;
                  ScaleY:=1.5;
                End;

            if B<2 then
            Begin
              ScaleX:=ScaleX*1.2;
              ScaleY:=ScaleY*1.2;
              Bigger:=true;
            End;

           // xcxc

            DrawMode:=1;
            EnmName:='enm'+intToStr(B);
                     // czxczx
            inc(Levelscore.enmscount);
            X:=XX;
            Y:=YY;
            Z:=1;

            EnmStatic:=false;

            EnmWeap:=1;
            EnmWeap2:=1;

            SizeXdiv2:=round(ImageWidth div 2*ScaleX);
            SizeYDiv2:=round(ImageHeight div 2*ScaleY);

            Creator;

            if alfashift then
             X:=X-SizeXdiv2
               else
                  X:=X+SizeXdiv2;
                  
            if alfashift then
               palf:=pi
                else
                   palf:=0;

            nextalf:=palf;

            EnmMainImpulse.ImpPower:=EnmMaxSpeed*0.5;

            CollideMethod:= cmRect;
            DoCollision := True;

            SpriteHeight:=ImageHeight*ScaleY;
            SpriteWidth:=ImageWidth*ScaleX;

            AITip:=1;

            case b of
               1: AITip:=8;
               2,7,9: AITip:=2;
               5,10:AITip:=3;
            end;
       end;
    End;
  End;

END;

  Mainform.DXWave.items.Find('shield.wav').Play(false);
end;

procedure TMainForm.BuildLasers;
begin
//
end;

procedure TMainForm.ChangeWeap;
var i:integer;
begin
if (inventory2=false)and(AltWeapon<>0) then
Begin
  i:=CurrentWeapon;
  CurrentWeapon:=AltWeapon;
  AltWeapon:=i;
  AltWeapons[1]:=AltWeapon;
End;
end;

procedure TMainForm.ClearDop;
var i,j:integer;
begin
 if DopImages.Count>0 then
  for I := 0 to DopImages.Count - 1 do
  Begin
   j:=images.Find(DopImages[i]);
   images.Remove(j);
   //showmessage(DopImages[i]+' is Deleted');
  End;
  DopImages.Clear;
end;

procedure TMainForm.CloseInv;
var i,j:integer;
    need_capsule:boolean;
    cAPSULE:tcAPSULE;
begin
   if InMouse=nil then
      Begin
        DXWave.Items.Find('mousein.wav').Play(false);  ///1308

        need_capsule:=false;
        for i := 1 to 6 do
          if InSpace[i]<>nil then
          Begin
           need_capsule:=true;
          End;

        if need_capsule then
         Begin
           Capsule:=TCapsule.Create(Engine);
           with Capsule Do
           Begin
               MyObjN:=GetObjNumber('Capsule1');
               //showmessage(inttostr(MyObjN));
                /// Координаты игрока
                      if _Player<>nil then
                      Begin
                        x:=TPlayer(_Player).X+128;
                        y:=TPlayer(_Player).Y+128;
                      End;
                //// Содержимое капсулы
                j:=1;
                for i := 1 to 6 do
                 if InSpace[i]<>nil then
                  Begin
                   Capsule.InCapsule[j]:=InSpace[i];
                   InSpace[i]:=nil;
                   inc(j);
                  End;
                 Oldx:=x;
                 OldY:=y;

                  ImageName := 'Box1';
                    if Images.Find('Capsule')<>-1 then
                        ImageName :='Capsule';
                AnimCount:=PatternCount;
                AnimSpeed:=0.3;

                SizeYd2:=ImageHeight div 2;
                    SizeXd2:=ImageWidth div 2;

                SpriteHeight:=PatternHeight;
                SpriteWidth:=PatternWidth;
            End;
         End;
        
      for i:= 1 to 10 do
        myhints[i].hinttime:=0;

        inventory:=false;
      End else
          DXWave.Items.Find('click0.wav').Play(false);  ///1308

      if ShowDLG=false then
         if HaveNewDLG then
            DialTime:=255;
end;

procedure TMainForm.CloseInv2;
var i,j:integer;
begin
////
if InMouseCol=0 then
Begin
  if TakenCol<>nil then
  Begin
    inventory2:=true;
    if Takencol is TeffectSprite then
    Begin
      TeffectSprite(TakenCol).act:=newcolorcount;
      TeffectSprite(TakenCol).col:=newcolor;
      if TeffectSprite(TakenCol).Owner<>nil then
      Begin
        TTile(TeffectSprite(TakenCol).Owner).pars[1]:=newcolor;
        TTile(TeffectSprite(TakenCol).Owner).pars[2]:=newcolorcount;
      End;
      TakenCol.Red:=redW[TeffectSprite(TakenCol).col];
      TakenCol.Green:=greenW[TeffectSprite(TakenCol).col];
      TakenCol.Blue:=blueW[TeffectSprite(TakenCol).col];
      TakenCol.Alpha:=alphaW[TeffectSprite(TakenCol).col];
    End
    else
      if Takencol is TTile then
      Begin
        if TTile(Takencol).pars[1]=newcolor then
           TTile(Takencol).pars[2]:=1;

      End;


    i:=0;
    for j := 1 to 7 do
      if altweapons[j]>0 then
       inc(I);
    altweaponscount:=i;

    for j := 1 to 7 do
      for I := 1 to 6 do
         if (altweapons[i]=0)and(altweapons[i+1]<>-1) then
          Begin
            altweapons[i]:=altweapons[i+1];
            altweapons[i+1]:=0;
          End;

    if (currentweapon=0)and(altweaponscount>0) then
    Begin
      altweaponscount:=altweaponscount-1;
      currentweapon:=altweapons[1];
      altweapons[1]:=0;

        for I := 1 to 6 do
         if (altweapons[i]=0)and(altweapons[i+1]<>-1) then
          Begin
            altweapons[i]:=altweapons[i+1];
            altweapons[i+1]:=0;
          End;
    End;     

    AltWeapon:=AltWeapons[1];
  End;
   inventory2:=false;
   DXWave.Items.Find('mousein.wav').Play(false);  ///1308
End else
  DXWave.Items.Find('click0.wav').Play(false);  ///1308

end;

procedure TMainForm.CloseInv3;
var i,j:integer;
    need_capsule:boolean;
    cAPSULE:tcAPSULE;
begin
 if InMouse=nil then
      Begin
        need_capsule:=false;
        for i := 1 to 6 do
          if InSpace[i]<>nil then
          Begin
           need_capsule:=true;
          End;

        if need_capsule then
         Begin
           Capsule:=TCapsule.Create(Engine);
           with Capsule Do
           Begin
               MyObjN:=GetObjNumber('Capsule1');
               //showmessage(inttostr(MyObjN));
                /// Координаты игрока
                      if _Player<>nil then
                      Begin
                        x:=TPlayer(_Player).X+128;
                        y:=TPlayer(_Player).Y+128;
                      End;
                //// Содержимое капсулы
                j:=1;
                for i := 1 to 6 do
                 if InSpace[i]<>nil then
                  Begin
                   Capsule.InCapsule[j]:=InSpace[i];
                   InSpace[i]:=nil;
                   inc(j);
                  End;
                 Oldx:=x;
                 OldY:=y;

                  ImageName := 'Box1';
                    if Images.Find('Capsule')<>-1 then
                        ImageName :='Capsule';
                AnimCount:=PatternCount;
                AnimSpeed:=0.3;

                SizeYd2:=ImageHeight div 2;
                SizeXd2:=ImageWidth div 2;
            End;
         End;

        inventory3:=false;
        CanShoot:=false;

        for i:= 1 to 10 do
          myhints[i].hinttime:=0;

        DXWave.Items.Find('mousein.wav').Play(false);  ///1308

      End else
  DXWave.Items.Find('click0.wav').Play(false);  ///1308

 
///
end;

function TMainForm.coding(var s: Tstringlist): Tstringlist;
var
    i,j,k,n:integer;
    a,c:char;
begin
 Result:=TstringList.Create;

 for i:=0 to s.Count-1 do Begin
   result.Add('');
   n:=0;
    for j:=1 to length(s[i]) do begin
      inc(n);
      if n>=5 then n:=0;
      c:=s[i][j];
      k:=ord(c)-n;
      a:=chr(k);
      result[i]:=result[i]+a;
    end;
 end;
end;

procedure TMainForm.ConCommands;
var i:integer;
begin

  smessage:='Unknown command';

  if concom='drawlines' then
  Begin
     DrawDop:=not(DrawDop);
     smessage:='ShowPhysLines';
     if drawdop then
       smessage:=smessage+' enabled'
       else  smessage:=smessage+' disabled';
  End;

  if concom='opendoors' then
  Begin
      for i:=1 to 10 do
         Begin
          DoorCols[i]:=10;
          DoorElectro[i]:=true;
         End;
      smessage:='Cheat Enabled!';
  End;

  if Pos('loadmap ',concom)=1 then
  Begin
    level:=0;
    if fileexists('Data\Maps\'+copy(concom,9,length(concom)))= true then
    Begin
      CheckPointenabled:=false;
      SayLoading;
      Timer.Enabled:=false;
      Engine.Clear;
      GameInit;
      GoBlack:=false;

     loadmapdata('Data\Maps\'+copy(concom,9,length(concom)));
     Timer.Enabled:=true;
     smessage:='';
    End else
      smessage:='file "'+copy(concom,9,length(concom))+'" not found';
  End;

  if concom='drawai' then
  Begin
     TestAI:=not(TestAI);
     smessage:='ShowAIWayPoints';
     if testAi then
       smessage:=smessage+' enabled'
       else  smessage:=smessage+' disabled';
  End;

  if concom='boom' then
  Begin
      Health:=0;
      smessage:='Cheat Enabled!';
  End;

  if Pos('shield',concom)=1 then
   if length(concom)>6 then
    Begin
     i:=1;
     if copy(concom,7,1)='2' then
       i:=2;
     if copy(concom,7,1)='3' then
       i:=3;
     if copy(concom,7,1)='4' then
       i:=4;
     if copy(concom,7,1)='5' then
       i:=5;
     if copy(concom,7,1)='6' then
       i:=6;
     if copy(concom,7,1)='7' then
       i:=7;

     ShieldColor:=i;
     ShieldTime:=100;

     smessage:='Cheat Enabled!';
    End;

   if Pos('addcolor',concom)=1 then
   if altweaponscount<5 then
   Begin
    if length(concom)>8 then
     Begin
       i:=1;
      if copy(concom,9,1)='2' then
       i:=2;
      if copy(concom,9,1)='3' then
       i:=3;
      if copy(concom,9,1)='4' then
       i:=4;
      if copy(concom,9,1)='5' then
       i:=5;
      if copy(concom,9,1)='6' then
       i:=6;
      if copy(concom,9,1)='7' then
       i:=7;

      inc(altweaponscount);
      altweapons[altweaponscount]:=i;
      smessage:='Cheat Enabled!';
    End;
   End;

  if concom='camera1' then
  Begin
    cameraMode:=cmCenter;
    smessage:='Set cam standard mode';
    GetNormW;
  End;

  if concom='camera2' then
  Begin
    cameraMode:=cmMove;
    smessage:='Set cam additional mode';
    GetNormW;
  End;

  if concom='saveme' then
  Begin
    SaveCheckPoint;
    smessage:='QuickSave';
  End;

  if concom='loadme' then
  Begin
    checkpointenabled:=true;
    smessage:='Loaded last CheckPoint';
    LoadCheckPoint;
  End;

 if concom='profilesave' then
 Begin
    SaveProfileProgress;
 End;

 if concom='store' then
 Begin
    Inventory3:=true;
    smessage:='Cheat Enabled!';
 End;

 if (concom='quit')or(concom='exit')or(concom='halt') then
    close;

 if concom='heal' then
 Begin
    health:=100;
    smessage:='Cheat Enabled!';
 End;

  if concom='godmode' then
 Begin
    godmode:=true;
    smessage:='Cheat Enabled! GODMODE ON!';
 End;

 if concom='moremoney' then
 Begin
    levelscore.total:=levelscore.total+1000;
    globalscore:= levelscore.total;
    smessage:='Cheat Enabled!';
 End;

  if concom='showmap' then
 Begin
    MapLookMenu:=true;
    MapShow1:=true;
    MapShow2:=true;
    MapShow3:=true;
    MapLookX:=_Player.X;
    MapLookY:=_Player.Y;
    mainform.GenerateMapObjs;
    omx:=mx;
    omy:=my;
    MapLookT:=0;
    smessage:='Cheat Enabled!';
 End;

 if concom='noclip' then
    Begin
    smessage:='Cheat Enabled!';
      for i := 0 to Engine.Count - 1 do
      if Engine[i] is TTile then
        TTile(Engine[i]).mylinecount:=0;
    End;

  if concom='fillcolors' then
  Begin
      for i := 1 to 7 do
       weapons[i].Count:=35;
      smessage:='Cheat Enabled!';
  End;


  smessagetime:=300;
  if Pos('Cheat Enabled',smessage)=1 then
   cheater:=true;

  console:=false;
end;

constructor TTile.Create(const AParent: TSpriteEngine);
Begin
inherited;
  if Ultralow=false then
  Begin
    if levcolor then
    Begin
      Red:=trunc(levcol[1]*0.7);
      Green:=trunc(levcol[2]*0.7);
      Blue:=trunc(levcol[3]*0.7);
    End else
      Begin
        Red:=180;
        Green:=180;
        Blue:=180;
      End;
  End;

end;

procedure TTile.Draw;
begin
  inherited;
///
end;

procedure TTile.LoadEffs;
var PointList:Tstringlist;
  Eff:TEffectSprite;
  myself:TTile;
  str:String;
  sx,sy:Single;
  b:boolean;
  l,m:byte;
  i,j,xx,yy:integer;
begin
  Childs:=TList.Create;

 if (tip=95) then        
  Begin
    xx:=round(x);
    yy:=round(y);
    j:=z;
    if mirrorx then
      kdr:=1
       else
        kdr:=0;

        if Mainform.Images.Find('bcharge_d')>-1 then
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName :='bcharge_d';
                    X:= XX;
                    Y:= YY;
                    if kdr=1 then
                      mirrorX:=true;
                    j:=7;
                    Red:=RedW[j];
                    Green:=GreenW[j];
                    Blue:=BlueW[j];
                    Alpha:=200;
                    EffectType:=eCharger;
                    z:=j+1;
                    
                    if Hidet=false then Begin
                      Scalex:=1.5;
                      sCALEy:=1.5;
                    end;

                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
                    DrawFX:=fxadd;
              end;
          End;
    End;




  if tip=70 then
  Begin
    if Ultralow=true then
     Dead;
     DrawFx:=FxAdd;
      if LightMode then
        DrawFx:=FxLight;//Add;
     ScaleX:=4;
     ScaleY:=4;
     if pars[1]<>0 then
     Begin
      Red:=RedW[pars[1]];
      Green:= GreenW[pars[1]];
      Blue:=BlueW[pars[1]];
     End;
     Alpha:=64;
           if LightMode then
              Alpha:=200;
     for i := 4 to 7 do
        if imagename='fxlight'+inttostr(i) then
           Alpha:=100;     {LIGHT FROM LAMPS}
     //DoCenter:=true;
  End;


  if tip=72 then
  Begin
    xx:=trunc(x);
    yy:=trunc(y);
    sx:=angle;
    b:=false;
    if pars[2]=1 then
      b:=true; {открытое}
    Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'ceff';
                    dOaNIMATE:=FALSE;
                    Animspeed:=0.45; //0.05*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimLooped:=false;

                    if sx<>0 then
                    Begin
                     OffsetX:=ImageWidth*ScaleX/2;
                     OffsetY:=ImageHeight*ScaleY/2;
                     DrawMode:=1;
                     Angle:=sx;
                    End;

                    AnimPos:=0;
                    if b then
                       PatternIndex:=PatternCount;

                    X:= XX;
                    Y:= YY;
                    EffectType:=eSprite;

                     if Ultralow=false then
                     Begin
                      if levcolor then
                      Begin
                        Red:=trunc(levcol[1]{*0.9});
                        Green:=trunc(levcol[2]{*0.9});
                        Blue:=trunc(levcol[3]{*0.9});
                      End else
                        Begin
                          {Red:=180;
                          Green:=180;
                          Blue:=180;}
                        End;
                      End;

                    z:=1;
                    Childs.Add(Eff);
                    Alpha:=255;
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;
  End;

 if tip=73 then
  Begin
    kdr:=random(10);
    xx:=trunc(x);
    yy:=trunc(y);
    if angle<0.25*pi then
      CollideRect := Rect(Round(X),
          Round(Y),
          Round(X + ImageWidth*ScaleX)+50,
          Round(Y + ImageHeight*ScaleY))
       else
         if angle<0.75*pi then
              CollideRect := Rect(Round(X),
              Round(Y)-50,
              Round(X + ImageWidth*ScaleX),
              Round(Y + ImageHeight*ScaleY))
            else
               if angle<1.25*pi then
                    CollideRect := Rect(Round(X)-50,
                    Round(Y),
                    Round(X + ImageWidth*ScaleX),
                    Round(Y + ImageHeight*ScaleY))
                    else
                     if angle<1.75*pi then
                        CollideRect := Rect(Round(X),
                        Round(Y),
                        Round(X + ImageWidth*ScaleX),
                        Round(Y + ImageHeight*ScaleY)+50)
                          else
                               CollideRect := Rect(Round(X),
                               Round(Y),
                               Round(X + ImageWidth*ScaleX)+50,
                               Round(Y + ImageHeight*ScaleY));
    sx:=angle;
    b:=false;
    if pars[3]=0 then
      b:=true; {защищено}
      Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'slot_up';
                    Alpha:=200;

                    {if b=false then
                    Begin
                      ImageName := 'slot_up2';
                       Alpha:=150;
                    End;}

                    Visible:=b;

                    if Hieffs=false then
                    Begin
                      ScaleX:=2;
                      Scaley:=2;
                    End;

                    if sx<>0 then
                    Begin
                     OffsetX:=ImageWidth*ScaleX/2;
                     OffsetY:=ImageHeight*ScaleY/2;
                     DrawMode:=1;
                     Angle:=sx;
                    End;

                    

                    AnimPos:=0;

                    X:= XX;
                    Y:= YY;
                    EffectType:=eSprite;

                    Red:=trunc(redw[pars[1]]);
                    Green:=trunc(greenw[pars[1]]);
                    Blue:=trunc(bluew[pars[1]]);
                    

                    z:=2;
                    Childs.Add(Eff);
                    //Alpha:=255;
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;

              b:=false;
              if pars[4]=1 then
                 b:=true; {заминированно}
                   Eff:=TEffectSprite.Create(Mainform.Engine);
                with  Eff do
               begin
                    ImageName := 'bomba';

                    if b=false then
                      Visible:=false;

                    if sx<>0 then
                    Begin
                     OffsetX:=ImageWidth*ScaleX/2;
                     OffsetY:=ImageHeight*ScaleY/2;
                     DrawMode:=1;
                     Angle:=sx;
                    End;

                    AnimPos:=0;
                    DoAnimate:=false;

                    X:= XX+50;
                    Y:= YY+50;
                    EffectType:=eSprite;

                    if levcolor then
                      Begin
                        Red:=trunc(levcol[1]*0.7);
                        Green:=trunc(levcol[2]*0.7);
                        Blue:=trunc(levcol[3]*0.7);
                      End;

                    z:=2;
                    Childs.Add(Eff);
                    Alpha:=255;
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;
  End;



  if tip=59 then
     visible:=false;

  if (tip=57) then
  Begin
    if pars[1]>0 then
     Begin
       Red:=RedW[pars[1]];
       Green:= GreenW[pars[1]];
       Blue:=BlueW[pars[1]];
     End;
  End;

  if (tip=58) then
  Begin
    clr:=1+random(7);

  End;

  if (tip=26) then
  Begin
     if pos('conv',objname)>=1 then
     Begin
        DrawMode:=-1;
        if pars[2]<>1 then
        Begin
          animcount:=patternCount;
          if animcount>1 then
            animSpeed:=0.35;
        End;
     End else
     Begin
      if pars[2]<>0 then
      Begin
        Red:=RedW[pars[2]];
        Green:= GreenW[pars[2]];
        Blue:=BlueW[pars[2]];
      End;
      if pos('lamp',objname)>=1 then
        if UltraLow then Alpha:=180;

     End;
  End;

  if (tip=33) then
  Begin
   z:=4;
   inc(lasercount); 
   Lasers[lasercount]:=(self);
   if pars[2]=1 then
   Begin
     activ:=false;
   End
   else activ:=true;
   //Lasers.Objects[Lasers.Count-1]:=self;
  End;



  if (tip=50)or(tip=51)or(tip=52)or(tip=53) then
  Begin
   inc(mirrorcount);              {ЛАЗЕРОПРИЁМНИК!}
   Mirrors[mirrorcount]:=(self);


    xx:=round(x);
    yy:=round(y);
    kdr:=0;

     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             myself:=self;
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find('nn_1lamp')<>-1 then
                      ImageName := 'nn_1lamp'
                      Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    //scalex:=0.9;
                    //scaley:=0.9;
                    //act:=pars[2];
                   // col:=pars[1];
                    Red:=255;
                    Green:=255;
                    Blue:=255;
                      if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;
                   // Alpha:=Alphaw[pars[1]];
                    EffectType:=eLamp5;
                    EffName:=PointList[I*3];
                    z:=-1;
                    Childs.Add(Eff);
                    Owner:=myself;
                   // DrawMode:=fxadd;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
              end;
          End;
    End;
     PointList.Destroy;

  End;

  if (tip=34)or(tip=39) then
  Begin
   inc(mirrorcount);
   Mirrors[mirrorcount]:=(self);

    xx:=trunc(x);
    yy:=trunc(y);
    Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'mireff1';
                    Animspeed:=0.05*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X:= XX;
                    Y:= YY;
                    EffectType:=eSprite;
                    z:=5;
                    Childs.Add(Eff);
                      if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;
  End;


  if (tip=62) then  // Выключатель лазера
  Begin
    xx:=trunc(x);
    yy:=trunc(y);
    Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'lgbutton2';
                    Animspeed:=0.05*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X:= XX;
                    Y:= YY;
                    EffectType:=eSprite;
                    z:=5;
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    Alpha:=150;                    
                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;

      if (pars[3]=1) then
      Begin
         Push;
      End;
  End;



  if (tip=35)or(tip=40) then
  Begin
   inc(mirrorcount);
   Mirrors[mirrorcount]:=(self);

   AnimCount:= PatternCount;
   AnimPos:= AnimCount;
    xx:=trunc(x);
    yy:=trunc(y);

    Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'mireff2';
                    Animspeed:=0.05*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X:= XX;
                    Y:= YY;
                    EffectType:=eSprite;
                      if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;
                    z:=5;
                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight;
                    SpriteWidth:=ImageWidth;
              end;

  End;


  if ((objname='tconv2')or(objname='tconv3'))and(hieffs=true) then
  Begin
    xx:=round(x);
    yy:=round(y);
    kdr:=0;

    {if pars[1]=0 then
           pars[1]:=8;}

   PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.loc')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.loc');
      for I := 0 to (PointList.Count - 1)div 5  do
        if Mainform.Images.Find(PointList[I*5])>-1 then
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName :=PointList[I*5];// 'eff1';//particles.image';
                    Animspeed:=0.1;//1*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X0 := strtoint( PointList[I*5+1] );
                    Y0 := strtoint( PointList[I*5+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    j:=1;
                    if objname='tconv2' then
                      j:=4;
                    Red:=RedW[j];
                    Green:=GreenW[j];
                    Blue:=BlueW[j];
                    Alpha:=200;
                    if PointList[I*5+3]='1' then
                       MirrorX:=true;
                    if PointList[I*5+3]='1' then
                       MirrorY:=true;


                    EffectType:=eLamp2;
                    EffName:=PointList[I*3];
                    z:=2;
                    if Pos('screen',PointList[I*3])>0 then
                    Begin
                      EffectType:=eScreen;
                      Animspeed:=0;
                      Red:=255;
                      Green:=255;
                      Blue:=255;
                      t:=1;
                    End;
                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    DrawMode:=1;
                    DrawFX:=fxadd;
              end;
          End;
      Pointlist.Destroy;
    End;

  End;



  if (tip=5) then
  Begin
    ///
    xx:=round(x);
    yy:=round(y);
    kdr:=0;

    if pars[1]=0 then
           pars[1]:=8;

     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'eff2';//particles.image';
                    Animspeed:=0.05*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    EffectType:=eLamp2;
                    EffName:=PointList[I*3];
                    z:=2;
                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
              end;
          End;
      Pointlist.Destroy;
    End;
  End;


  if (tip=27)or(TIP=55) then
  Begin
    ///
    xx:=round(x);
    yy:=round(y);
    kdr:=0;

                                                                          // xvxcv
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
        if Mainform.Images.Find(PointList[I*3])>-1 then
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName :=PointList[I*3];// 'eff1';//particles.image';
                    Animspeed:=0.1*(1+random(3));
                    AnimCount:=PatternCount;
                    AnimPos:=random(AnimCount);
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    Red:=RedW[4];
                    Green:=GreenW[4];
                    Blue:=BlueW[4];
                    Alpha:=200;
                    EffectType:=eLamp2;
                    EffName:=PointList[I*3];
                    z:=2;
                    if Pos('screen',PointList[I*3])>0 then
                    Begin
                      EffectType:=eScreen;
                      Animspeed:=0;
                      Red:=255;
                      Green:=255;
                      Blue:=255;
                      t:=1;
                    End;
                    Childs.Add(Eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    DrawMode:=1;
                    DrawFX:=fxadd;
              end;
          End;
      Pointlist.Destroy;
    End;
  End;




  if (tip=17) then
  Begin
    ///
    xx:=round(x);
    yy:=round(y);

    if pars[1]=0 then
      pars[1]:=8;

    if Objname='door3' then
    b:=true;
    kdr:=0;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*3])<>-1 then
                      ImageName := PointList[I*3]
                       Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    if (i<>2)and(i<>4) then
                    Begin
                      Red:=RedW[pars[1]];
                      Green:=GreenW[pars[1]];
                      Blue:=BlueW[pars[1]];
                      //DrawFX:=FxAdd2X;
                    End else
                    if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;

                    EffectType:=eLamp4;
                    alf1:=0;
                    EffName:=PointList[I*3];
                    z:=2;
                    Childs.Add(Eff);

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
              end;
          End;
      Pointlist.Destroy;
    End;
  End;

  if (tip=22) then
  Begin
    ///
    xx:=round(x);
    yy:=round(y);
    kdr:=0;
    sx:=ScaleX;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;

    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      Eff:=TEffectSprite.Create(Mainform.Engine);
      horz:=false;
      if pars[2]=1 then
      Begin
       horz:=true;
      End else
      Begin
        Childs.Add(Eff);
             with  Eff do
               begin
                    if Mainform.Images.Find(PointList[0])<>-1 then
                      ImageName := PointList[0]
                        Else ImageName := 'Box1';
                    X0 := strtoint( PointList[1] );
                    Y0 := strtoint( PointList[2] );
                    X:= XX + X0;
                    Y:= YY + Y0;

                    ScaleX:=sx;
                    ScaleY:=sx;

                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];

                    EffectType:=eLamp4;
                    alf1:=100;
                    alpha:=255;
                    EffName:=PointList[0];
                    z:=2;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
              end;
      End;
    End;

    Pointlist.Destroy;
  End;

  if (tip=19) then
  Begin
    ///
    xx:=round(x);
    yy:=round(y);
    kdr:=0;

    if pars[2]=1 then
    Begin
      tip:=20;
      DoorElectro[pars[1]]:=true;
    End;

    if (objname='es_2')or(objname='es_4') then
     b:=true;

     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*3])<>-1 then
                      ImageName := PointList[I*3]
                        Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    if (i<>2)and(i<>4) then
                    Begin
                      Red:=RedW[pars[1]];
                      Green:=GreenW[pars[1]];
                      Blue:=BlueW[pars[1]];
                      //DrawFX:=FxAdd2X;
                    End;

                    EffectType:=eLamp4;
                    if i=2 then
                    Begin
                     EffectType:=eBuse;
                      animspeed:=0.5;
                      col:=pars[1];
                      animcount:=patterncount;
                      if Ultralow=false then
                        if levcolor then
                        Begin
                          Red:=levcol[1];
                          Green:=levcol[2];
                          Blue:=levcol[3];
                        End;

                      if b=true then angle:=pi/2;
                    End else
                     if i=0 then
                      DrawFx:=Fxadd;
                     
                    /// if b then angle:=90; 

                    alf1:=0;
                    EffName:=PointList[I*3];
                    z:=2;
                    Childs.Add(Eff);

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
              end;
          End;
      Pointlist.Destroy;
    End;
  End;


  {if (tip=31) then
  Begin
    SpriteHeight:=PatternHeight*ScaleY;
    SpriteWidth:=PatternWidth*ScaleX;


      l:=0;
      m:=0;

         if ObjName='door7' then
          l:=1
           else
            m:=1;

          kdr:=0;
          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=true;
                SMMap[i,j]:=1;
              End;


  End; }

  if (tip=31) then
  Begin
    xx:=round(x+PatternWidth*ScaleX/2);
    yy:=round(y+PatternHeight*ScaleY/2);
    kdr:=0;
    
    if ObjName='door8' then
      kdr:=pi/2;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             myself:=self;
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*3])<>-1 then
                      ImageName := PointList[I*3]
                      Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1]);
                    Y0 := strtoint( PointList[I*3+2]);
                    X:= XX + X0;
                    Y:= YY + Y0;
                    angle:=kdr;
                    act:=pars[2];
                    col:=pars[1];
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    Alpha:=Alphaw[pars[1]];
                    EffectType:=eLamp2;
                    EffName:=PointList[I*3];
                    z:=-1;
                    Childs.Add(Eff);
                    Owner:=myself;
                    DrawMode:=1;

              end;
          End;
      Pointlist.Destroy;
    End
  end;


  if (tip=6) then
  Begin
    xx:=round(x);
    yy:=round(y);
    kdr:=0;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             myself:=self;
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find('f_ul')<>-1 then
                      ImageName := 'f_ul'
                      Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    scalex:=0.9;
                    scaley:=0.9;
                    act:=pars[2];
                    col:=pars[1];
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    Alpha:=Alphaw[pars[1]];
                    EffectType:=eLampCol;
                    EffName:=PointList[I*3];
                    z:=-1;
                    Childs.Add(Eff);
                    Owner:=myself;
                    DrawMode:=1;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
              end;
          End;
      Pointlist.Destroy;
    End
  end;

  if (tip=28) then
  Begin
     horz:=true;
    if Pos('1',Objname)>0 then
      horz:=false;
    PointList:=TStringList.Create;

    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
       PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
       subrect.Left:=strtoint(PointList[0]);
       subrect.Top:=strtoint(PointList[1]);
       subrect.Right:=strtoint(PointList[2]);
       subrect.Bottom:=strtoint(PointList[3]);
    End;

  End;

  if (tip=7) then
  Begin
    PointList:=TStringList.Create;
    xx:=round(x);
    yy:=round(y);
    clr:=35;
    kdr:=0;
    str:=ImageName;
    sx:=ImageWidth*ScaleX;
    sy:=ImageHeight*ScaleY;
     //// ЗАГРУЗКА CHILDов:
    Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName :='Box1';

                    if pos('_ld',str)>0 then
                     delete(str,length(str)-2,length(str));
                    {if pos('_uld',str)>0 then
                     delete(str,length(str)-3,length(str));}
                  //  showmessage(str);

                    if MainForm.Images.Find(str+'_light')<>-1 then
                        ImageName := str+'_light';
                    X0 := 0;
                    Y0 := 0;
                    X:= XX + X0;
                    Y:= YY + Y0;
                    scalex:=sx/ImageWidth;
                    scaley:=sy/ImageHeight;
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    EffectType:=eLamp3;
                    EffName:='Lampa';
                    z:=-1;
                    Childs.Add(Eff);
                    DrawMode:=0;
                    DrawFx:=fxBlend ;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
              end;

    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
       PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
       subrect.Left:=strtoint(PointList[0]);
       subrect.Top:=strtoint(PointList[1]);
       subrect.Right:=strtoint(PointList[2]);
       subrect.Bottom:=strtoint(PointList[3]);
    End;


    horz:=true;
    
    if fileexists('Data\Locs\'+Objname+'.loc')=true then
    Begin
      Pointlist.LoadFromFile('Data\Locs\'+Objname+'.loc');
      for I := 0 to (PointList.Count - 1)div 5  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*5])<>-1 then
                      ImageName := PointList[I*5]
                         Else ImageName := 'Box1';

                    X0 := strtoint( PointList[I*5+1] );
                    Y0 := strtoint( PointList[I*5+2] );

                    if PointList[I*5+3]='1' then
                      MirrorX:=true;
                    if PointList[I*5+4]='1' then
                      MirrorY:=true;

                      if imagename='uhandle1' then
                      horz:=false;

                    X:= XX + X0;
                    Y:= YY + Y0;

                    if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;

                    EffectType:=eSprite;
                    EffName:=ImageName;//PointList[I*3];
                    z:=3;
                    //Childs.Add(Eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    //DrawMode:=1;
              end;
          End;
    End;
    Pointlist.Destroy;
  End;

  if (tip=16) then
  Begin
    xx:=round(x);
    yy:=round(y);
    kdr:=0;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*3])<>-1 then
                       imageName := PointList[I*3]
                      Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;
                    Red:=RedW[pars[1]];
                    Green:=GreenW[pars[1]];
                    Blue:=BlueW[pars[1]];
                    Alpha:=Alphaw[pars[1]];
                    EffectType:=eLamp4;        // cx
                    //EffName:=PointList[I*3];
                    z:=0;
                    if i=0 then
                      Alf1:=250
                       else alf1:=0;
                    drawfx:=fxadd;   
                    Childs.Add(Eff);
                    DrawMode:=1;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
              end;
          End;
      Pointlist.Destroy;
    End;
    if pars[2]=1 then
     Begin
      tip:=18;
      DoorCols[pars[1]]:=DoorCols[pars[1]]+1;
      PatternIndex:=1;
      AnimCount:=PatternCount;
      AnimPos:=1;
      pars[2]:=1;
       if Ultralow=false then
       if levcolor then
       Begin
        {Red:=levcol[1];     // sfsf
        Green:=levcol[2];
        Blue:=levcol[3];}
        Red:=trunc(levcol[1]*0.7);
        Green:=trunc(levcol[2]*0.7);
        Blue:=trunc(levcol[3]*0.7);
       End;

      if Childs[1]<>nil then
          TEffectSprite(Childs[1]).dead;
     End;
  end;

  if (tip=30) then
  Begin
    xx:=round(x);
    yy:=round(y);
    kdr:=0;
     //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    if fileexists('Data\Locs\'+Objname+'.pts')=true then
    Begin
      PointList.LoadFromFile('Data\Locs\'+Objname+'.pts');
      for I := 0 to (PointList.Count - 1)div 3  do
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    if Mainform.Images.Find(PointList[I*3])<>-1 then
                       imageName := PointList[I*3]
                      Else ImageName := 'Box1';
                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    X:= XX + X0;
                    Y:= YY + Y0;

                    if i=2 then
                    Begin
                      Red:=RedW[pars[1]];
                      Green:=GreenW[pars[1]];
                      Blue:=BlueW[pars[1]];
                      Alpha:=Alphaw[pars[1]]
                    End else
                    Begin
                      Red:=RedW[pars[2]];
                      Green:=GreenW[pars[2]];
                      Blue:=BlueW[pars[2]];
                      Alpha:=Alphaw[pars[2]]
                    End;

                    EffectType:=eLamp2;
                    z:=1;

                    if i=0 then
                      alpha:=0;

                    drawfx:=fxadd;
                    Childs.Add(Eff);
                    DrawMode:=1;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
              end;
          End;
      Pointlist.Destroy;
    End;
    if (pars[3]=1)or(pars[3]=2) then
    begin
      if TSprite(Childs[pars[3]])<>nil then
        TSprite(Childs[pars[3]]).visible:=false;
      PatternIndex:=pars[3];
      AnimPos:=pars[3];
         if (pars[3]=1) then
         inc(DoorCols[pars[2]])
         else
           inc(DoorCols[pars[1]]);
         if pars[3]=1 then
          i:=pars[2]
            else if pars[3]=2 then
              i:=pars[1];
      TeffectSprite(Childs[0]).red:=redw[i];
      TeffectSprite(Childs[0]).green:=greenw[i];
      TeffectSprite(Childs[0]).blue:=bluew[i];
      TeffectSprite(Childs[0]).Alpha:=225;
    end;
  end;


end;

procedure TTile.Move;
var i,j,l,m,nmb,rv2:integer;
 spr:Tobject;
begin
     inherited;
    
    if tip=59 then // ghgh
     Begin
        kdr:=kdr+movecount;
        if kdr>50*pars[3] then
        Begin
          kdr:=0;
          i:=trunc(x);
          j:=trunc(y);

          l:=pars[1];
          m:=pars[2];

          nmb:=GetObjNumber(copy(ObjName,2,length(Objname)));

          with  TActor.Create(Engine) do
                  begin
                    MyObjN:=nmb;

                    mustdie:=true;

                   // AnimSpeed:=0.3;

                    ImageName := 'Box1';

                      if Mainform.Images.Find(Objs[nmb].Img)<>-1 then
                       Begin
                        ImageName :=Objs[nmb].Img;
                       End;

                     if HiDet=false then
                        if Mainform.Images.Find(Objs[nmb].Img+'_ld')<>-1 then
                        Begin
                         ImageName :=Objs[nmb].Img+'_ld';
                         ScaleX:=1.5;
                         ScaleY:=1.5;
                        End;

                    AnimCount:=PatternCount;

                    X0:=i;
                    Y0:=j;

                    x:=x0;
                    y:=y0;

                    z:=6;

                    ex:=m;
                    ey:=l;

                    phase:=0;

                    DrawMode:=1;

                  end
          End;
     End;

    if tip=95 then
    Begin
      if bossCharge then
      begin
        kdr:=kdr+MoveCount;
              if kdr>5 then
              Begin
              
                if mirrorx=false then
                Begin
                  i:=round(X+235);
                  j:=round(Y+200);
                End else
                 Begin
                  j:=round(Y+200);
                  i:=round(X+15);
                 End;
                TrasserEff(i,j,GetRValue(bosscol),GetGValue(bosscol),
                            GetBValue(bosscol), 1, 1,pFire);
               if hieffs then
                TrasserEff(i,j,GetRValue(bosscol),GetGValue(bosscol),
                            GetBValue(bosscol), 1, 2,pFire);

              End;
      end;
     End;

     if tip=72 then
     if (pars[2]=0) then
     Begin
       {Определяем, попадает ли курсор}
      if (abs(x+PatternWidth*ScaleX/2-gamcurx)<sizexd2)and
         (abs(y+PatternHeight*ScaleY/2-gamcury)<sizexd2)then
      Begin
        cursoroncapsule:=true;

        ShowChoosed:=true;
        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;

         if ((angle>0.7)and(angle<2.3))or((angle>3.9)and(angle<5.5)) then
         begin
           ChooseBound.x:=x-50;
           ChooseBound.y:=y+50;
           ChooseBound.w:=SizeYd2*2;
           ChooseBound.h:=SizeXd2*2;
         end;


        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);
        if (RV2<550) then
          PushTile:=self;
      End;
     End; 

    if tip=62 then
     if (activ=false)or(pars[2]=1) then
     Begin

       {Определяем, попадает ли курсор}
      if (abs(x+PatternWidth*ScaleX/2-gamcurx)<sizexd2)and
         (abs(y+PatternHeight*ScaleY/2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ShowChoosed:=true;  
        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2+5;
        ChooseBound.h:=SizeYd2*2+5;

        if (RV2<550) then
          PushTile:=self;
      End;

     End
     else Begin
      // if pars[2]=0 then
     //  Begin
        kdr:=kdr+movecount;
        if kdr>100 then
        Begin
          activ:=false;
          pars[3]:=0;
          if TSprite(Childs[0])<>nil then
              TSprite(Childs[0]).alpha:=150;


           for i:= 1 to LaserCount do
            if Lasers[i]<>nil then
              if (Lasers[i].pars[2]=1)and(Lasers[i].pars[1]=pars[1]) then
                  Lasers[i].activ:=false;


          Mainform.RebuildLasers;
        End;
      // End;
     End;

    if tip=31 then
     Begin

       {Определяем, попадает ли курсор}
      if (abs(x+PatternWidth*ScaleX/2-gamcurx)<sizexd2)and
         (abs(y+PatternHeight*ScaleY/2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;
        if Objs[MyObjN].Name='door7' then
        Begin
          ChooseBound.x:=x+110;
          ChooseBound.y:=y-5;
          ChooseBound.w:=SizeXd2
        End
          else
          begin
           ChooseBound.y:=y+110;
           ChooseBound.h:=SizeYd2;
          end;

        ShowChoosed:=true;
        
        if (RV2<550){and()} then
          PushTile:=self;
      End;

       if pars[2]=1 then
       Begin
         tip:=32;
         SizeXd2:=PatternWidth div 2;
         SizeYd2:=PatternHeight div 2;

         if Childs[0]<>nil then
           TSprite(Childs[0]).imagename:='dooreff2';

       End;

     End;

     if (tip=34)or(tip=35) then
     Begin
      if (abs(x+PatternWidth*ScaleX/2-gamcurx)<sizexd2)and
         (abs(y+PatternHeight*ScaleY/2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;
        ShowChoosed:=true;
        
        if (RV2<550) then
          PushTile:=self;
      End;
     End;


     if tip=55 then
     Begin
        {Определяем, попадает ли курсор}
      if (abs(x+PatternWidth*ScaleX/2-gamcurx)<sizexd2)and
         (abs(y+PatternHeight*ScaleY/2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x-10;
        ChooseBound.y:=y-10;
        ChooseBound.w:=SizeXd2*2+20;
        ChooseBound.h:=SizeYd2*2+20;

        if Objs[MyObjN].Name='maplook2' then
        begin
          ChooseBound.x:=x-60;
          //ChooseBound.y:=y-20;
        end
          else
          begin
           ChooseBound.y:=y-60;
           //ChooseBound.x:=x-20;
          end;

        
        ShowChoosed:=true;

        if (RV2<550){and()} then
          PushTile:=self;
      End;
     End;

     if (tip=36) then
     if AnimPos<1 then
      Begin
        tip:=34;
        Mainform.RebuildLasers;
        MyObjN:=GetObjNumber('mir1');
        if childs[0]<>nil then
        Begin
          if kdr=1 then
            TSprite(childs[0]).visible:=true;
          TSprite(childs[0]).imagename:='mireff1';
        End;

        AnimSpeed:=0;
     End;

     if (tip=37) then
     if AnimPos>=PatternCount-1 then
     Begin
        tip:=35;
        Mainform.RebuildLasers;
        MyObjN:=GetObjNumber('mir2');
        if childs[0]<>nil then
        Begin
          if kdr=1 then
           TSprite(childs[0]).visible:=true;
          TSprite(childs[0]).imagename:='mireff2';
        End;
        AnimSpeed:=0;
     End;


    if (tip=58) then
    if pars[2]<>0 then
     if (AnimPos>=etap*5) then
     Begin
        animspeed:=0;

        kdr:=kdr+movecount;
        if kdr>20 then
        Begin
          kdr:=0;
          animspeed:=0.20+0.03*clr;
          if mirrorX=false then
              sparkeff(sparks[etap,1]+X,sparks[etap,2]+Y,pFire)
               else
                sparkeff(-sparks[etap,1]+X+SpriteWidth,sparks[etap,2]+Y,pFire);

          if fonar then
          Begin
            for I := 1 to 32 do
            Begin
            if PostFilter3flashLights[I].r<=0 then
            Begin
              PostFilter3flashLights[I].x:=sparks[etap,1]+X;
              PostFilter3flashLights[I].y:=sparks[etap,2]+Y;
              PostFilter3flashLights[I].r:=150;
              PostFilter3flashLights[I].ready:=true;
              break;
            End;
            End;

          End;

          inc(etap);
        End;
     End
      else
      Begin
        if (etap=4)and(animpos<etap*3) then
        Begin
           // sparkeff(sparks[etap,1]+X,sparks[etap,2]+Y,pFire);
            etap:=0;
        End;
      End;

    if (tip=73) then
    if DoorElectro[8] then
     Begin
        kdr:=kdr+movecount;
        if kdr>20 then
        Begin
          kdr:=0;
          sparkeff6(X+SpriteWidth/2,Y+SpriteHeight/2,angle);
          if Hieffs then
          Begin
            sparkeff6(X+SpriteWidth/2,Y+SpriteHeight/2,angle);


            sparkeff(X+SpriteWidth/2-sin(angle)*40,Y+SpriteHeight/2-cos(angle)*40,pElectro);
            sparkeff(X+SpriteWidth/2+sin(angle)*40,Y+SpriteHeight/2+cos(angle)*40,pElectro);
          End;
        End;

        if pars[4]=1 then
        Begin
          if Childs[1]<>nil then
          Begin
            TSprite(Childs[1]).Green:=60+trunc(50*Sin(kdr/10*pi));
            TSprite(Childs[1]).Blue:=Green;
          End;
        End;

     End;


     if tip=32 then
     Begin
       {Открываем/закрываем}

      if (abs(_Player.X+128-x-Sizexd2)<450)and(abs(_Player.Y+128-y-sizeyd2)<400) then
      Begin

       if kdr<20 then
          kdr:=kdr+movecount/3;

      if kdr>20 then
      Begin
        kdr:=20;

          l:=0;
          m:=0;

          if ObjName='door7' then
          l:=1
           else
            m:=1;

          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=false;
                SMMap[i,j]:=0;
              End;
      End;

      End else
      Begin
        if kdr>0 then
          kdr:=kdr-movecount/3;
        if kdr<0 then
        Begin
          l:=0;
          m:=0;

          if ObjName='door7' then
          l:=1
           else
            m:=1;

          kdr:=0;
          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=true;
                SMMap[i,j]:=1;
              End;
        End;
      End;

      PatternIndex:=round(kdr);

      if Childs[0]<>nil then
      Begin
        if PatternIndex<10 then
           TSprite(Childs[0]).alpha:=round(250-250*PatternIndex/10)
            else  TSprite(Childs[0]).alpha:=0;
      End;

      if ObjName='door7' then
      Begin
        lines[1].x0_1:=round(320*PatternIndex/20);
        lines[0].x0_2:=320-round(320*PatternIndex/20);
      End else
      Begin
        lines[0].y0_1:=round(320*PatternIndex/20);
        lines[1].y0_2:=320-round(320*PatternIndex/20);
      End;
         Setlines;
     End;

     { --------}

     if tip=81 then
     Begin


      if (abs(_Player.X+128-x-Sizexd2)<450)and(abs(_Player.Y+128-y-sizeyd2)<400)and
        (SCANOK) {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1} then
      Begin

       if kdr<20 then
          kdr:=kdr+movecount/3;

      if kdr>20 then
      Begin
        kdr:=20;

        l:=0;
        m:=0;
        if ObjName='door10' then
        begin
            l:=1;
            m:=1;
        end;

        for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
          for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=false;
                SMMap[i,j]:=0;
              End;
      End;
      End else
      Begin
        if kdr>0 then
          kdr:=kdr-movecount/3;
        if kdr<0 then
        Begin
          l:=0;
          m:=0;

          if ObjName='door10' then
          begin
            l:=1;
            m:=1;
          end;

          kdr:=0;
          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=true;
                SMMap[i,j]:=1;
              End;
        End;
      End;

      PatternIndex:=round(kdr);

      if ObjName='door10' then
      Begin
        lines[1].x0_1:=round(320*PatternIndex/20);
        lines[0].x0_2:=320-round(320*PatternIndex/20);
      End else
      Begin
        lines[0].y0_1:=round(320*PatternIndex/20);
        lines[1].y0_2:=320-round(320*PatternIndex/20);
      End;
         Setlines;
     End;

     {--------}

     if tip=1 then
     //if (abs(_Player.X+128-x-Sizexd2)<450)and(abs(_Player.Y+128-y-sizeyd2)<400)and(DoorCols[pars[1]]>=pars[2]) then
     if (objname='tconv2')or(objname='tconv3') then
      Begin
       if Hieffs=true then
          if (Childs[1]<>nil) and (childs[0]<>nil) then
              TAnimatedSprite(Childs[0]).animPos:=TAnimatedSprite(Childs[1]).animPos

      End;

     if tip=5 then
     Begin

      if (abs(_Player.X+128-x-Sizexd2)<450)and(abs(_Player.Y+128-y-sizeyd2)<400)and(DoorCols[pars[1]]>=pars[2]) then
      Begin

      if DoorCols[pars[1]]>=pars[2] then
       if pars[1]=8 then
             pars[2]:=0;

       if kdr<20 then
          kdr:=kdr+movecount/2;

      if kdr>20 then
      Begin
        kdr:=20;

          l:=0;
          m:=0;

          if ObjName='door1' then
          l:=1
           else
            m:=1;

          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=false;
                SMMap[i,j]:=0;
              End;
      End;

      End else
      Begin
        if kdr>0 then
          kdr:=kdr-movecount/2;
        if kdr<0 then
        Begin
          l:=0;
          m:=0;

          if ObjName='door1' then
          l:=1
           else
            m:=1;

          kdr:=0;
          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=true;
                SMMap[i,j]:=1;
              End;
        End;
      End;

      PatternIndex:=round(kdr);

      if ObjName='door1' then
      Begin
        lines[1].x0_1:=round(320*PatternIndex/20);
        lines[0].x0_2:=320-round(320*PatternIndex/20);
      End;
      if ObjName='door2' then
      Begin
        lines[0].y0_1:=round(320*PatternIndex/20);
        lines[1].y0_2:=320-round(320*PatternIndex/20);
      End;

      Setlines;

      if childs<>nil then
         for I := 0 to Childs.Count - 1 do
          if (Childs[i]<>nil) then
          Begin
            Spr:=Childs[i];
              if spr is TeffectSprite then
              Begin
                  for j := 1 to 8 do
                  Begin

                   if j<=4 then
                    if TeffectSprite(spr).EffName='point'+inttostr(j) then
                       if strtoint(copy(TeffectSprite(spr).EffName,6,1))>pars[2]-DoorCols[pars[1]] then
                        Begin
                            TeffectSprite(spr).Visible:=false;
                        End else
                          if kdr=0 then TeffectSprite(spr).Visible:=true;

                   if j>4 then
                    if TeffectSprite(spr).EffName='point'+inttostr(j) then
                        if strtoint(copy(TeffectSprite(spr).EffName,6,1))-4>pars[2]-DoorCols[pars[1]] then
                        Begin
                            TeffectSprite(spr).Visible:=false;
                        End
                           else
                            if kdr=0 then TeffectSprite(spr).Visible:=true;
                  End;

              End;
          End;

     End
     else

     if tip=17 then
     Begin

      if (abs(_Player.X+128-x-Sizexd2)<450)and(abs(_Player.Y+128-y-sizeyd2)<400)and(DoorElectro[pars[1]]=true) then
      Begin

      //if DoorElectro[pars[1]]=true then
       if kdr<20 then
          kdr:=kdr+movecount/2;

      if kdr>20 then
      Begin
        kdr:=20;

          l:=0;
          m:=0;

          if ObjName='door3' then
          l:=1
           else
            m:=1;

          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=false;
                SMMap[i,j]:=0;
              End;
      End;

      End else
      Begin
        if kdr>0 then
          kdr:=kdr-movecount/2;
        if kdr<0 then
        Begin
          l:=0;
          m:=0;

          if ObjName='door3' then
          l:=1
           else
            m:=1;

          kdr:=0;
          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=true;
                SMMap[i,j]:=1;
              End;
        End;
      End;

      PatternIndex:=round(kdr);

      if ObjName='door3' then
      Begin
        lines[1].x0_1:=round(320*PatternIndex/20);
        lines[0].x0_2:=320-round(320*PatternIndex/20);
      End;
      if ObjName='door4' then
      Begin
        lines[0].y0_1:=round(320*PatternIndex/20);
        lines[1].y0_2:=320-round(320*PatternIndex/20);
      End;

      Setlines;

      if childs<>nil then
         for I := 0 to Childs.Count - 1 do
          if (Childs[i]<>nil) then
          Begin
            Spr:=Childs[i];

            if spr is TeffectSprite then
            Begin

                if (DoorElectro[pars[1]]=false) then
                Begin

                  if (i=3)or(i=1) then
                    Begin
                      if TeffectSprite(spr).Alf1<250 then
                        TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1+movecount*3;
                      if TeffectSprite(spr).Alf1>250 then
                        TeffectSprite(spr).Alf1:=250;
                    End else
                    if (i=0) then
                    Begin
                      if TeffectSprite(spr).Alf1>50 then
                        TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1-movecount;
                      if TeffectSprite(spr).Alf1<50 then
                        TeffectSprite(spr).Alf1:=50;
                    End;

                End else

                if (DoorElectro[pars[1]]=true) then
                Begin

                  if (i=3)or(i=1) then
                  Begin
                      if TeffectSprite(spr).Alf1>50 then
                        TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1-movecount;
                      if TeffectSprite(spr).Alf1<50 then
                        TeffectSprite(spr).Alf1:=50;
                  End  else
                  if (i=0) then
                  Begin
                      if TeffectSprite(spr).Alf1<250 then
                        TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1+movecount*5;
                      if TeffectSprite(spr).Alf1>250 then
                        TeffectSprite(spr).Alf1:=250;
                  End;

                End;

            End;
          End;

     End
     else
     
     {if (tip=6) then
     Begin
      if pars[2]=1 then
      if childs<>nil then
         for I := 0 to Childs.Count - 1 do
          if (Childs[i]<>nil) then
          Begin
            Spr:=Childs[i];
              if spr is TeffectSprite then
              Begin
                TeffectSprite(spr).Act:=100;
                SparkEff3(TeffectSprite(spr).x,TeffectSprite(spr).y,pars[1],1, pFire);
              End;
              childs.Clear;

          End;

     End
     else}

     if (tip=7) then
     Begin

     if (_player.X+128>X+subrect.Left)and(_player.X+128<X+subrect.Right)
     and (_player.Y+128>Y+subrect.top)and(_player.Y+128<Y+subrect.Bottom)then
        activ:=true;

     if activ then
        Begin

         if (Currentweapon=pars[1])and(Weapons[currentweapon].Count+PlusClr<35)and(Clr>MoveCount*0.1) then
         Begin
          clr:=clr-movecount*0.2;
          PlusClr:=PlusClr+MoveCount*0.2;
          PlusClrN:=Currentweapon;
          ColCharge:=true;
          //if Mainform.SoundSystem2.IsPlaying('ray.wav')=false then
           //  Mainform.SoundSystem2.Play('ray.wav',false);
          //=false then
          if  Mainform.DXWave.items.Find('ray.wav').PlayCount<1 then
          Mainform.DXWave.items.Find('ray.wav').Play(false);

              kdr:=kdr+MoveCount;
              if kdr>5 then
              Begin

                if horz then
                Begin
                  i:=round(X+(subrect.Left+subrect.Right)div 2);
                  j:=round(Y+subrect.top+60);
                End else
                 Begin
                  j:=round(Y+(subrect.top+subrect.bottom)div 2);
                  i:=round(X+subrect.left+60);
                 End;

               if hieffs then
                TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 3,pCol);
                TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 5,pFire);


                if horz then
                 j:=round(Y+subrect.bottom-60)
                  else
                    i:=round(X+subrect.right-60);

                if hieffs then
                  TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 3,pCol)
                   else TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 1,pCol);
                  TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 5,pFire);

                kdr:=0;
              End

          End
        End;
      //  else
                         // МОЖНО ВЕРНУТЬ!!!
     //   Begin
          if clr<35 then
            clr:=clr+0.01*movecount;
          if clr>35 then clr:=35
            else
              if clr<0 then clr:=0;
   //     End;


         for I := 0 to Childs.Count - 1 do
          if (Childs[i]<>nil) then
          Begin
            Spr:=Childs[i];
              if spr is TeffectSprite then
              Begin
                TeffectSprite(spr).Act:=trunc(200*clr/35);
               // SparkEff3(TeffectSprite(spr).x,TeffectSprite(spr).y,pars[1], pFire);
              End;
          End;
       activ:=false;
     End;

    if (tip=16)or(tip=30) then
    Begin
      if (abs(x+sizexd2-gamcurx)<sizexd2)and (abs(y+sizeyd2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;
        ShowChoosed:=true;
        
        if (RV2<550){and()} then
          PushTile:=self;
      End;
    End;

    {if tip=30 then
    Begin
      if pars[3]>0 then
        if Childs[0]<>nil then
        Begin
            TeffectSprite(Childs[0]).CRGB(redw[pars[pars[3]]],greenw[pars[pars[3]]],bluew[pars[pars[3]]],200,2,Lagcount);
            TeffectSprite(Childs[0]).Alpha:=255;
        End;
    End;}

    if (tip=27) then
    Begin
      if (abs(x+sizexd2-gamcurx)<sizexd2)and (abs(y+sizeyd2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x-10;
        ChooseBound.y:=y-10;
        ChooseBound.w:=SizeXd2*2+20;
        ChooseBound.h:=SizeYd2*2+20;
        ShowChoosed:=true;
        
        if (RV2<550){and()} then
          PushTile:=self;
      End;
    End;

    if (tip=28) then
    if (abs(x-_Player.X)<Mainform.Device.Width/Engine.WorldScaleX)and
       (abs(y-_Player.Y)<Mainform.Device.Height/Engine.WorldScaleY) then
    Begin

      kdr:=kdr+MoveCount;
      if hieffs then
        i:=5
          else i:=15;

      if kdr>i then
      Begin
       kdr:=0;
       if horz then
       Begin
          i:=round(X+(subrect.Left+subrect.Right)div 2);
          j:=round(Y+subrect.top+105);
       End else
       Begin
          j:=round(Y+(subrect.top+subrect.bottom)div 2);
          i:=round(X+subrect.left+105);
       End;

       TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 5,pFire);


   
       if horz then
        j:=round(Y+subrect.bottom-105)
          else
            i:=round(X+subrect.right-105);

       TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 5,pFire);

       if horz then
       Begin
        SparkEff7(X+SizeXd2,Y+SizeYd2,pars[1],90);
        SparkEff7(X+SizeXd2,Y+SizeYd2,pars[1],270);
       End else
        Begin
          SparkEff7(X+SizeXd2,Y+SizeYd2,pars[1],0);
          SparkEff7(X+SizeXd2,Y+SizeYd2,pars[1],180);
        End;


      End;

         if (_player.X+128>X+subrect.Left)and(_player.X+128<X+subrect.Right)
           and (_player.Y+128>Y+subrect.top)and(_player.Y+128<Y+subrect.Bottom)then
        Begin
          inshield:=true;

          if Shieldtime<100 then
          Begin
            Shieldtime:=Shieldtime+lagcount/3;

            if Mainform.DXWave.items.Find('ray.wav').PlayCount<1 then
                Mainform.DXWave.items.Find('ray.wav').Play(false);
            if hieffs then
                if kdr=0 then
                    TrasserEff(i,j,redw[pars[1]],Greenw[pars[1]],Bluew[pars[1]],1, 3,pCol2);
          End
              else Shieldtime:=100.9;

          if Shieldtime>100.9 then
            Shieldtime:=100.9;

          Shieldcolor:=pars[1];
        End;

       
        
    End;


    if (tip=71) then
    if (abs(x-_Player.X)<Mainform.Device.Width/Engine.WorldScaleX)and
       (abs(y-_Player.Y)<Mainform.Device.Height/Engine.WorldScaleY) then
    Begin

      kdr:=kdr+MoveCount;
      if hieffs then
        i:=5
          else i:=15;

      if kdr>i then
      Begin
       kdr:=0;
           j:=round(Sizexd2)+60;
         if objname='portal' then
         j:=round(Sizexd2)-100;


         SparkEff7(X+j,Y+170,1,0);
         SparkEff7(X+j,Y+170,1,180);
         SparkEff7(X+j,Y+170,1,90);
         SparkEff7(X+j,Y+170,1,270);

         if portals>0 then
         Begin
          Sparkeff3(x+j,y+170,1,1,pfire);

         End;

      End;
    End;

    if ((tip=7)or(tip=22)or((tip=73)and(pars[3]=0)))and(lakmus) then
    Begin
      if (abs(x+sizexd2-gamcurx)<sizexd2)and (abs(y+sizeyd2-gamcury)<sizeyd2)then
      Begin
        if currentweapon<>pars[1] then
         Begin
           for i:=1 to altweaponscount do
            if altweapons[i]=pars[1] then
            Begin
              j:=currentweapon;
              currentweapon:=altweapons[i];
              altweapons[i]:=j;
              if i=1 then
                AltWeapon:=AltWeapons[1];
              Break;
            End;
         End;
        //cursoroncapsule:=true;
        ///if (RV<500){and()} then
         /// PushTile:=self;
      End;
    End;

    if (tip=20) then
    Begin
      if (abs(x+sizexd2-gamcurx)<sizexd2)and (abs(y+sizeyd2-gamcury)<sizeyd2)then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x-SizeXd2)+SQR(_Player.y+128-y-Sizeyd2)));
        if drawdop then
          FireEff(x+SizeXd2,y+Sizeyd2,pfire,1);

        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;
        ShowChoosed:=true;
        
        if (RV2<550)and(keepitm=false) then
        // if not((pars[1]=8)and(LevelMission<=0)) then
           PushTile:=self;
      End;
    End;

    if tip=18 then
    Begin
     if (Childs.Count>0) then
      if (Childs[0]<>nil) then
      Begin
        Spr:=Childs[0];
        if spr is TeffectSprite then
        Begin
          if TeffectSprite(spr).alf1>50 then
            TeffectSprite(spr).alf1:=TeffectSprite(spr).Alf1-movecount*4;
          if TeffectSprite(spr).alf1<50 then
          Begin
            TeffectSprite(spr).alf1:=50;
            Childs.Clear;
          End;
        End;
      End;
    End;

    if tip=19 then
    Begin

     for i := 1 to Childs.Count - 1 do
       if Childs[i]<>nil then
       Begin
         Spr:=Childs[i];
         if (i=1) then
         Begin
          if TeffectSprite(spr).Alf1<250 then
            TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1+movecount*3;
          if TeffectSprite(spr).Alf1>250 then
            TeffectSprite(spr).Alf1:=250;
         End;
          if (i=2) then TeffectSprite(spr).Visible:=false;
       End;
    End;

    if tip=20 then
    Begin
      for i := 1 to Childs.Count - 1 do
       if Childs[i]<>nil then
       Begin
         Spr:=Childs[i];
         if (i=1) then
         Begin
          if TeffectSprite(spr).Alf1>0 then
            TeffectSprite(spr).Alf1:=TeffectSprite(spr).Alf1-movecount*3;
          if TeffectSprite(spr).Alf1<0 then
            TeffectSprite(spr).Alf1:=0;
         End;
          if (i=2) then TeffectSprite(spr).Visible:=true;
       End;
    End;

    if (tip=19)or(tip=20) then
    Begin
    if Pars[1]=8 then
       Begin

         if DoorElectro[pars[1]]=false then
          if clr<100 then
            clr:=clr+movecount;

         if DoorElectro[pars[1]]=true then
          if clr>0 then
            clr:=clr-movecount;



         if clr>100 then
            clr:=100;
         if clr<0 then
            clr:=0;

         if clr>0 then
         Begin
           fonar:=true;
           fonarcolor:=crgb1(trunc(255-2.15*clr),trunc(255-2.15*clr),trunc(255-1.55*clr))
         End;

       End;
    End;
    

    if tip=22 then
    Begin
    // !!!!!!!!!!!!!!!!!!!!!!!!!!! DOOR5 6
       // if hieffs then
       // Begin

          if clr<25 then
            clr:=clr+movecount;
          if clr>25 then
          Begin
            clr:=0;
            if ObjName='door5' then
            Begin
              BarierEff(x+25,y+32,1,pars[1]);
              BarierEff(x+280,y+32,2,pars[1]);
            End else
            Begin
              BarierEff(x+35,y+25,3,pars[1]);
              BarierEff(x+35,y+280,4,pars[1]);
            End;


          End;
       
     //   End;



     if horz then
     Begin
     if kdr<20 then
      kdr:=kdr+movecount
      else
       Begin
          l:=0;
          m:=0;
          pars[2]:=1;

          if ObjName='door5' then
          l:=1
           else
            m:=1;

          for i:=trunc(x+90*l) div 100 to trunc(x-90*l+SpriteWidth-5) div 100 do
            for j:=trunc(y+90*m) div 100 to trunc(y-90*m+SpriteHeight-5) div 100 do
              if (i>=0)and(j>=0)and(i<=mapsizex)and(j<=mapsizey) then
              Begin
                AIMAP[i,j]:=false;
                SMMap[i,j]:=0;
              End;


        for j := 0 to 1 do
        Begin
          lines[j].x1:= lines[j].x2;
          lines[j].y1:= lines[j].y2;
          tip:=1;
        End;
       End;

     End;


     
    End;
   // Setlines;
end;


procedure TEnemy.AI;
var findway:Boolean;
 i:Byte;
begin
 {ПРЯМОЙ ПУТЬ}
 if AIState<>AIHunt then
 Begin
   EnmLooking:=false;
   EnmShootTime:=0;
 End;

  case aitip of
    1:Begin
        if AIstate=AIHunt then
        Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if Testway then
          Begin
             if TargetDest>EnmBody.radius*4+EnmDopInt+256 then
             Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;
             End else
              Begin


                if EnmLooking then
                Begin
                  Shoot;
                  //AIState:=AIRunAway;
                End else
                Begin
                  {if EnmMainImpulse.ImpPower>0 then
                    EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
                  if EnmMainImpulse.ImpPower<0 then
                    EnmMainImpulse.ImpPower:=0;}
                End;

                if TargetDest<EnmBody.radius+256 then
                 AIState:=AIRunAway;

              End;
          End else
          Begin
            if EnmMainImpulse.ImpPower>0 then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
              if EnmMainImpulse.ImpPower<0 then
                EnmMainImpulse.ImpPower:=0;
          End;



        End else
        if (AIstate=AIGoto) then
        Begin
         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
        if Testway then
          Begin
             if (TargetX=0)and(targetY=0) then
              AIstate:=AIHunt;
             if TargetDest<50 then
             Begin
                AIState:=AIHunt;
             End else
              Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed;

              End;
          End else AIstate:=AIHunt;

        End else
        if AIstate=AIRunaway then
        Begin
           targetX:=trunc(X-Sin(palf+(random-0.5)*pi+pi/2)*1000);
           targetY:=trunc(Y+Cos(palf+(random-0.5)*pi+pi/2)*1000);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
           if Testway then
             AIstate:=AIGoto;
        End;

      End;
    2:  {Большие враги}
      Begin
        if AIstate=AIHunt then
        Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if Testway then
          Begin
             if TargetDest>EnmBody.radius*6+EnmDopInt+256 then
             Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;
             End else
              Begin


                if EnmLooking then
                Begin
                  Shoot;
                  //AIState:=AIRunAway;
                End else
                Begin
                  if EnmMainImpulse.ImpPower>0 then
                    EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
                  if EnmMainImpulse.ImpPower<0 then
                    EnmMainImpulse.ImpPower:=0;
                End;

                if (TargetDest<EnmBody.radius+200)and(inwall=false) then
                 AIState:=AIRunAway;

              End;
          End else
          Begin
            if EnmMainImpulse.ImpPower>0 then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
              if EnmMainImpulse.ImpPower<0 then
                EnmMainImpulse.ImpPower:=0;
          End;



        End else
        if AIstate=AIGoto then
        Begin
        if (TargetX=0)and(targetY=0) then
          AIstate:=AIHunt;

         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
        if Testway then
          Begin
             if (TargetDest<50) then
             Begin
                AIState:=AIHunt;
             End else
              Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed;

              End;
          End else AIstate:=AIHunt;


        End else
        if AIstate=AIRunaway then
        Begin
           targetX:=trunc(X-Sin(palf+(random-0.5)*pi/2+pi/2)*400);
           targetY:=trunc(Y+Cos(palf+(random-0.5)*pi/2+pi/2)*400);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
           if Testway then
             AIstate:=AIGoto
               else AIState:=AIHunt;
        End

      End;

     8:  {Оч. Большие враги}
      Begin
        if AIstate=AIHunt then
        Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if Testway then
          Begin
             if TargetDest>EnmBody.radius*8+EnmDopInt+256 then
             Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;
             End else
              Begin


                if EnmLooking then
                Begin
                  Shoot;
                  //AIState:=AIRunAway;
                End else
                Begin
                  if EnmMainImpulse.ImpPower>0 then
                    EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
                  if EnmMainImpulse.ImpPower<0 then
                    EnmMainImpulse.ImpPower:=0;
                End;

               { if TargetDest<EnmBody.radius+200 then
                 AIState:=AIRunAway;}

              End;
          End else
          Begin
            if EnmMainImpulse.ImpPower>0 then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
              if EnmMainImpulse.ImpPower<0 then
                EnmMainImpulse.ImpPower:=0;
          End;



        End else
        if AIstate=AIGoto then
        Begin
        if (TargetX=0)and(targetY=0) then
          AIstate:=AIHunt;

         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
        if Testway then
          Begin
             if (TargetDest<50) then
             Begin
                AIState:=AIHunt;
             End else
              Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed;

              End;
          End else AIstate:=AIHunt;


        End else
        if AIstate=AIRunaway then
        Begin
           targetX:=trunc(X-Sin(palf+(random-0.5)*pi/2+pi/2)*400);
           targetY:=trunc(Y+Cos(palf+(random-0.5)*pi/2+pi/2)*400);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
           if Testway then
             AIstate:=AIGoto
               else AIState:=AIHunt;
        End

      End;

      9:  {Босс1}
      Begin
        if AIstate=AIHunt then
        Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if Testway then
          Begin
             if TargetDest>EnmBody.radius*3+256{8+EnmDopInt+256} then
             Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;

               if EnmLooking then
                Begin
                  Shoot;
                End;

             End else
              Begin


                if EnmLooking then
                Begin
                  Shoot;
                  //AIState:=AIRunAway;
                End else
                Begin
                  if EnmMainImpulse.ImpPower>0 then
                    EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
                  if EnmMainImpulse.ImpPower<0 then
                    EnmMainImpulse.ImpPower:=0;
                End;

               { if TargetDest<EnmBody.radius+200 then
                 AIState:=AIRunAway;}
                       // тимт
              End;
          End else
          Begin
            if EnmMainImpulse.ImpPower>0 then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
              if EnmMainImpulse.ImpPower<0 then
                EnmMainImpulse.ImpPower:=0;
          End;



        End else
        if AIstate=AIGoto then
        Begin
        if (TargetX=0)and(targetY=0) then
          AIstate:=AIHunt;

         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
        if Testway then
          Begin
             if (TargetDest<50) then
             Begin
                AIState:=AIHunt;
             End else
              Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed;

              End;
          End else AIstate:=AIHunt;


        End else
        if AIstate=AIRunaway then
        Begin
           targetX:=trunc(X-Sin(palf+(random-0.5)*pi/2+pi/2)*400);
           targetY:=trunc(Y+Cos(palf+(random-0.5)*pi/2+pi/2)*400);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
           if Testway then
             AIstate:=AIGoto
               else AIState:=AIHunt;
        End

      End;
     10:  {Босс2}
      Begin
        BossCharge:=false;

        if EnmTicks3<1 then
            Enmticks3:=Enmticks3+0.01*MCount;


        if AIstate=AIHunt then
        Begin

          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));

          if ShotCount<=0 then
          Begin
            AIState:=AIGoTo;
            TargetX:=StartX;
            TargetY:=StartY;
            targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          End;

          if Testway then
          Begin
             if TargetDest>EnmBody.radius*3+368{8+EnmDopInt+256} then
             Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;

               if (EnmLooking)and(TestWay) then
                Begin
                  Shoot;
                End;

             End else
              Begin
                 if EnmMainImpulse.ImpPower>0 then
                    EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
                  if EnmMainImpulse.ImpPower<0 then
                    EnmMainImpulse.ImpPower:=0;

                if (EnmLooking)and(TestWay) then
                Begin
                  Shoot;
                  //AIState:=AIRunAway;
                End;


          if ShotCount<=0 then
          Begin
            AIState:=AIGoTo;
            TargetX:=StartX;
            TargetY:=StartY;
            targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          End;


              End;
          End else
          Begin
            if EnmMainImpulse.ImpPower>0 then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
              if EnmMainImpulse.ImpPower<0 then
                EnmMainImpulse.ImpPower:=0;
          End;

          if ShotCount<=0 then
          Begin
            AIState:=AIGoTo;
            TargetX:=StartX;
            TargetY:=StartY;
            targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          End;


        End else
        if AIstate=AIWait then
        Begin

          BossCharge:=true;

          if enmTicks3>=1 then
          Begin
             TrasserEff(EnmBody.X,EnmBody.Y,redw[enmweap],Greenw[enmweap],Bluew[enmweap],1, 30,pCol3);
             enmTicks3:=0;
          End;

          AIWaitT:=AIWaitT-lagCount*0.7;
          ShotCount:=trunc((100-AIWaitT)/100*3.5);

           if  Mainform.DXWave.items.Find('shield.wav').PlayCount<1 then
          Mainform.DXWave.items.Find('shield.wav').Play(false);



          EnmLooking:=false;
          TargetX:=trunc(_Player.X);
          TargetY:=trunc(_Player.Y);

          if ShotCount>3 then
            ShotCount:=3;

          if AIWaitT<=0 then
          Begin
           AIState:=AIHunt;
           ShotCount:=3;
           Turn;
           EnmShootTime:=0;
           Portals:=10;
          End;

           if EnmMainImpulse.ImpPower>0 then
            EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
           if EnmMainImpulse.ImpPower<0 then
            EnmMainImpulse.ImpPower:=0;

        End else
        if AIstate=AIGoto then
        Begin

      {  if (TargetX=0)and(targetY=0) then
          AIstate:=AIHunt;      }

         TargetX:=StartX;
         TargetY:=StartY;
         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
         EnmLooking:=false;
        // Turn;
         testway;
       // if Testway then
       //   Begin
             if (TargetDest<150) then
             Begin
                AIState:=AIWait;
                AIWaitT:=100;
             End else
              Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed;

              End;
         { End else  Begin
                if EnmMainImpulse.ImpPower<EnmMaxSpeed/2-MCount then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
                if EnmMainImpulse.ImpPower>EnmMaxSpeed/2+MCount then
                  EnmMainImpulse.ImpPower:=EnmMainImpulse.ImpPower-MCount;

              End; }

            { targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
             if (TargetDest<150) then
             Begin
                AIState:=AIWait;
                AIWaitT:=100;
             End   }

        End else
        if AIstate=AIRunaway then
        Begin
           targetX:=trunc(X-Sin(palf+(random-0.5)*pi/2+pi/2)*400);
           targetY:=trunc(Y+Cos(palf+(random-0.5)*pi/2+pi/2)*400);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
           if Testway then
             AIstate:=AIGoto
               else AIState:=AIHunt;
        End

      End;

    3:  {Камикадзе}
      Begin
      if Aistate=AiHunt then
        Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if Testway then
          Begin
              if EnmMainImpulse.ImpPower<EnmMaxSpeed then
                EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
              if EnmMainImpulse.ImpPower>EnmMaxSpeed then
                EnmMainImpulse.ImpPower:=EnmMaxSpeed;
          End
          else if targetDest<900 then  
           AIState:=AIRunaway;
        End else


        if AIstate=AIGoto then
        Begin
          if (TargetX=0)and(targetY=0) then
              AIstate:=AIHunt;
         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
        if Testway then
          Begin

             if EnmMainImpulse.ImpPower<EnmMaxSpeed/2 then
                  EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower+MCount;
             if EnmMainImpulse.ImpPower>EnmMaxSpeed/2 then
                  EnmMainImpulse.ImpPower:=EnmMaxSpeed/2;

             if TargetDest<20*enmmaxspeed then
             Begin
                AIState:=AIRunaway;
             End;

          End else
          Begin
            AIState:=aIRunAway;
          End;
        End else

        if AIstate=AIRunaway then
        Begin
           i:=random(8);
           targetX:=trunc(X-Sin(i*pi/4)*100);
           targetY:=trunc(Y+Cos(i*pi/4)*100);
           targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));

           if (Testway) then
             AIstate:=AIGoto
              else  AIstate:=AIHunt;

           if EnmMainImpulse.ImpPower>0 then
            EnmMainImpulse.ImpPower:= EnmMainImpulse.ImpPower-MCount;
           if EnmMainImpulse.ImpPower<0 then
            EnmMainImpulse.ImpPower:=0;

        End
      End;
    4:  {Туррели}
      Begin
          targetX:=trunc(_Player.X+128);
          targetY:=trunc(_Player.Y+128);
          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
          if (Testway)and(targetdest<900) then
            shoot;

      End;
    5:  {Ракеты}
      Begin
         targetX:=trunc(_Player.X+128);
         targetY:=trunc(_Player.Y+128);
         targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));
         EnmMainImpulse.ImpPower:=EnmMaxSpeed;
         if Testway then
          Begin
          End;
      End;
     6:  {Ракеты игрока}
      Begin

        EnmMainImpulse.ImpPower:=EnmMaxSpeed;

         if dopsprites[1]=nil then
           findtarget
         else
         Begin

          targetX:=trunc(dopsprites[1].X+TEnemy(dopsprites[1]).SizeXdiv2);
          targetY:=trunc(dopsprites[1].Y+TEnemy(dopsprites[1]).SizeYdiv2);

          targetDest:=trunc(sqrt(sqr(targetX-EnmBody.X)+sqr(targety-EnmBody.y)));

         if Testway then
          Begin
          End;

         End;
      End;
      7:
      begin
         targetX:=trunc(_Player.X+128);
         targetY:=trunc(_Player.Y+128);
         if (enmname='turrel2') then
         Begin
            if abs(targetX-enmbody.X)<800 then
              if ((-targetY+enmbody.Y)<1400)and(targetY<enmbody.Y) then
               Shoot;
         End else
         if (enmname='turrel3') then
         Begin
           if abs(targetY-enmbody.Y)<800 then
              if ((targetX-enmbody.X)<1400)and(targetX>enmbody.X) then
               Shoot
         End
          else
         if (enmname='turrel4') then
         Begin
            if abs(targetX-enmbody.X)<800 then
              if ((targetY-enmbody.Y)<1400)and(targetY>enmbody.Y) then
               Shoot;
         End
          else
          if (enmname='turrel5') then
         Begin
            if abs(targetY-enmbody.Y)<800 then
              if ((-targetX+enmbody.X)<1400)and(targetX<enmbody.X) then
               Shoot
         End else
          Shoot;

      end;
  end;

 EnmLooking:=false;
end;

constructor TEnemy.Create(const AParent: TSpriteEngine);
Begin
inherited;
  EnmImpulse.ImpPower:=0;

  if Ultralow=false then
  Begin
  if levcolor then
    Begin
      Red:=levcol[1];
      Green:=levcol[2];
      Blue:=levcol[3];
    End else
      Begin
        Red:=240;
        Green:=240;
        Blue:=240;
      End;
  End;

end;

procedure TEnemy.Creator;
  const
  n=13;
  Commands:array[1..n] of String=('BodyX: ','BodyY: ','Radius: ',
  'TurnSpeed: ','MaxSpeed: ','MaxHealth: ','AIType: ','ShootTime: ','Cracks: ',
  'EnmDopInt: ','Power: ','LowAnim: ','Rockets: ');
  // НАСТРОЙКИ!!!

  var s:TstringList;
  i,j,xx2,yy2:integer;
  par:String;
  Eff:TeffectSprite;
  SubEnm:TEnemy;
begin

  s:=TstringList.Create;

    //// ПО УМОЛЧАНИЮ
  hbk:=1.3;
  AIState:=AIHunt;
  EnmBody.x0:=0;
  EnmLowanim:=false;
  EnmBody.y0:=0;
  EnmBody.radius:=50;
  EnmHealth:=50;
  EnmTurnSpeed:=5;
  EnmShootTime:=0;
  EnmCanShoot:=true;
  EnmShootWait:=100;
  EnmCracks:=0;
  EnmMaxHealth:=50;
  EnmMainImpulse.ImpPower:=0;
  EnmImpulse.ImpPower:=0;
  EnmDopInt:=0;
  EnmSpower:=10;
  SetCurrentDir(Dir0);
  if fileexists('Data\Objects\Enemies\'+EnmName+'.enm') then
  Begin
    s.LoadFromFile('Data\Objects\Enemies\'+EnmName+'.enm');

    ///// ЗАГРУЗКА  ПАРАМЕТРОВ
    for I := 0 to s.Count - 1 do
      Begin
        for j := 1 to n do
          Begin
            if Pos(commands[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(commands[j]));
               case j of

                  1:{BodyX:} Begin
                    EnmBody.x0:=Strtoint(par);
                  End;
                  2:{BodyY:} Begin
                    EnmBody.y0:=Strtoint(par);
                  End;
                  3:{Radius:} Begin
                    EnmBody.radius:=Strtoint(par);
                  End;
                  4:{TurnSpeed:} Begin
                    EnmTurnSpeed:=Strtoint(par);
                  End;
                  5:{MaxSpeed:} Begin
                    EnmMaxSpeed:=Strtoint(par)/2;
                  End;
                  6:{MaxHealth:} Begin
                    EnmHealth:=Strtoint(par);
                    EnmMaxHealth:=Strtoint(par);
                  End;
                  7:{AIType:} Begin
                    AITip:=Strtoint(par);
                  End;
                  8:{ShootTime:} Begin
                    EnmShootWait:=Strtoint(par);
                  End;
                  9:{Cracks:} Begin
                    EnmCracks:=Strtoint(par);
                  End;
                  10:{EnmDopInt:} Begin
                    EnmDopInt:=Strtoint(par);
                  End;
                  11:{power:} Begin
                    EnmSpower:=Strtoint(par);
                  End;
                  12:{lowanim:} Begin
                    if par='y' then
                     EnmLowanim:=true;
                  End;
                  13:{Rockets:} Begin
                    if par='y' then
                     EnmRockets:=true;
                  End;
               end;
             End;
          End;
      End;
  End;

  if (ultralow)or(enmLowanim) then
   Begin
     offsetX:=SizeXdiv2;
     offsetY:=SizeYdiv2;
   End;


  //// SUB-BODIES LOAD

  EnmSubCount:=0;
  for i := 1 to 3 do
    if fileexists('Data\Physics\'+EnmName+'_'+inttostr(i)+'.loc') then
    Begin
     EnmSubCount:=i;
     s.LoadFromFile('Data\Physics\'+EnmName+'_'+inttostr(i)+'.loc');
     EnmSubBodies[i].x0:=strtoint(s[0]);
     EnmSubBodies[i].y0:=strtoint(s[1]);
     EnmSubBodies[i].radius:=strtoint(s[2]);

      EnmSubRA[1,i]:=SQRT(SQR(EnmSubBodies[i].x0)+SQR(EnmSubBodies[i].y0));
      EnmSubRA[2,i]:=getalf0(round(EnmSubBodies[i].x0),round(EnmSubBodies[i].y0));
    End;

  SetEnmBox;

   /// СОПЛА

  flamecount:=0;
  if fileexists('Data\Locs\'+enmname+'_fire.pts') then
  Begin
    s.LoadFromFile('Data\Locs\'+enmname+'_fire.pts');
    flamecount:=(s.Count)div 2 ;
    for j := 0 to flamecount-1 do
    Begin
       xx2:=StrToInt(s[j*2]);   // sd
       yy2:=StrToInt(s[j*2+1]);
       EnmFlame[1,j]:=SQRT(SQR(xx2)+SQR(yy2));  /// RAD
       EnmFlame[2,j]:=GetAlf0(xx2,yy2);  /// ALF
    end;
  End;

  /// !!!

  /// ЗАГРУЗКА МОДЕЛИ ПОВРЕЖЕНИЙ

  if EnmCracks>0 then
   for i := 1 to EnmCracks do
    Begin
        Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find(Enmname+'_c'+inttostr(i))<>-1 then
            Imagename:=Enmname+'_c'+inttostr(i);

          if (enmname='enm42')or(enmname='enm43')or(enmname='enm44') then
          if Mainform.Images.Find('enm4'+'_c'+inttostr(i))<>-1 then
            Imagename:='enm4'+'_c'+inttostr(i);

          if Bigger then
          Begin
            ScaleX:=1.2;
            ScaleY:=1.2;
          End;
          X0 := 0;
          Y0 := 0;
          Visible:=false;
          EffectType:=eEnmCrack;
          z:=2;
          DrawMode:=1;
          
                     if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;

          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
        end;
        EnmCrackList[i]:=Eff;
    End;

  ///  ЗАГРУЗКА ГНЁЗД ПУШЕК

   gunscount:=0;
  if fileexists('Data\Locs\'+enmname+'_guns.pts') then
  Begin
    s.LoadFromFile('Data\Locs\'+enmname+'_guns.pts');
    gunscount:=(s.Count)div 2 ;
    for j := 0 to gunscount-1 do
    Begin
       xx2:=StrToInt(s[j*2]);
       yy2:=StrToInt(s[j*2+1]);
       Guns[j+1].r:=SQRT(SQR(xx2)+SQR(yy2));  /// RAD
       Guns[j+1].a:=GetAlf0(xx2,yy2);  /// ALF
    end;
  End;

  ///Начальные параметры

  ///Доп.
  xx2:=trunc(x);
  yy2:=trunc(y);
  if enmName='enm5' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('Mina')<>-1 then
            Imagename:='Mina';

            ScaleX:=0.65;
            ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;
          EffectType:=eMina;
          z:=2;
          DrawMode:=1;
          AnimSpeed:=0.3;
          AnimCount:=PatternCount;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=50;
     enmSubRa[2,1]:=0;
  End;



  //БОСС!!!!
  if enmName='boss1' then
  Begin
    levelmissiontip:=7;
    EnmTurnSpeed:=0.7;
    for I := 1 to 4 do
    Begin
        SubEnm:=TEnemy.Create(Mainform.Engine);


        with  SubEnm do
        begin
            EnmmyobjN:=GetObjNumber('Bossturrel1');

            ImageName := 'Box1';

            if Mainform.Images.Find('Bossturrel1')<>-1 then
            Begin
              ImageName :='Bossturrel1';
              //Patternindex:=Objs[numb].Index;
              //Imageindex:=Objs[numb].Index;
            End;

            if HiDet=false then
              if Mainform.Images.Find('Bossturrel1_ld')<>-1 then
                Begin
                  ImageName :='Bossturrel1_ld';
                  ScaleX:=1.5;
                  ScaleY:=1.5;
                End;

            DrawMode:=1;

            EnmName:='bossturrel1';

            enmweap2:=0;

            inc(Levelscore.enmscount);

            ScaleY:=scaleX;

            X:=XX2;
            Y:=YY2;
            Z:=3;

            EnmWeap:=3;
            EnmStatic:=true;

            EnmWeap:=round(I*1.6-0.6);

            SizeXdiv2:=round(ImageWidth div 2*ScaleX);
            SizeYDiv2:=round(ImageHeight div 2*ScaleY);

            Creator;

            CollideMethod:= cmRect;
            DoCollision := True;

            SpriteHeight:=ImageHeight*ScaleY;
            SpriteWidth:=ImageWidth*ScaleX;

            enmweap2:=enmweap;
            
        end;

        DopSprites[i]:=SubEnm;
        enmSubRa[1,i]:=50;
        enmSubRa[2,i]:=0;
     end;

    if fileexists('Data\Locs\'+enmname+'_turrels.pts') then
    Begin
      s.LoadFromFile('Data\Locs\'+enmname+'_turrels.pts');
      for j := 0 to s.Count div 2-1 do
      Begin
       xx2:=StrToInt(s[j*2]);
       yy2:=StrToInt(s[j*2+1]);
       enmSubRa[1,j+1]:=SQRT(SQR(xx2)+SQR(yy2));  /// RAD
       enmSubRa[2,j+1]:=GetAlf0(xx2,yy2);  /// ALF
      end;
    End;

  End;

  if enmName='enm1' then
  Begin
    if levelmissiontip=4 then
    Begin
      inc(levelmission);
      DoorCols[8]:=DoorCols[8]-4;
    End;
  End;

  if enmName='enm6' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('Sphere')<>-1 then
            Imagename:='Sphere';

            ScaleX:=1;//0.8;
            ScaleY:=1;//0.8;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          alpha:=0;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;
          EffectType:=eSphere;
          z:=2;
          DrawMode:=1;
          AnimSpeed:=0.3;
          AnimCount:=PatternCount;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
          //DrawFx:=fxAdd;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=80;
     enmSubRa[2,1]:=0;

      Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('e6color')<>-1 then
            Imagename:='e6color';

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[2]:=Eff;
     enmSubRa[1,2]:=0;
     enmSubRa[2,2]:=0;

  End;

  if enmName='enm3' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('e3color')<>-1 then
            Imagename:='e3color';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=0;
     enmSubRa[2,1]:=0;
  End;

  if enmName='Boss2' then
  Begin
  levelmissiontip:=6;
  ShotCount:=3;
  for I := 1 to 4 do
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('boss2_'+inttostr(i))<>-1 then
            Imagename:='boss2_'+inttostr(i);

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];
          CRed:=redw[enmweap];
          CGreen:=Greenw[enmweap];
          CBlue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=250;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;

     DopSprites[i]:=Eff;
     enmSubRa[1,i]:=0;
     enmSubRa[2,i]:=0;
  End;

  End;
  if enmName='enm8' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('e8color')<>-1 then
            Imagename:='e8color';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=0;
     enmSubRa[2,1]:=0;
  End;

  if enmName='enm9' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('e9color')<>-1 then
            Imagename:='e9color';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=0;
     enmSubRa[2,1]:=0;
  End;

  if enmName='enm10' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('e10color')<>-1 then
            Imagename:='e10color';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=4;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
     enmSubRa[1,1]:=0;
     enmSubRa[2,1]:=0;
  End;

  if enmName='enm1' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('enm1lamp1')<>-1 then
            Imagename:='enm1lamp1';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          ScaleX:=1.2;
          ScaleY:=1.2;

          Red:=redw[enmweap2];
          Green:=Greenw[enmweap2];
          Blue:=Bluew[enmweap2];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[1]:=Eff;
    

     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('enm1lamp2')<>-1 then
            Imagename:='enm1lamp2';

            //ScaleX:=0.65;
            //ScaleY:=0.65;

          X0 := 0;
          Y0 := 0;
          x:=xx2;
          y:=yy2;

          ScaleX:=1.2;
          ScaleY:=1.2;

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          DrawFx:=fxBlend;

          EffectType:=eShine;
          z:=2;
          Alpha:=220;
          DrawMode:=1;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          Owner:=self;
        end;
     DopSprites[2]:=Eff;


     enmSubRa[1,1]:=0;
     enmSubRa[2,1]:=0;         // cbcxb
  End;


  /// Доп. для туррели
  xx2:=trunc(x)+SizeXdiv2;
  yy2:=trunc(y)+SizeYdiv2;
  if enmName='turrel' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('Tur')<>-1 then
            Imagename:='Tur';


          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          x:=xx2;
          y:=yy2;

          EffectType:=eShine;
          Owner:=self;
          z:=2;
          DrawMode:=1;
          AnimCount:=PatternCount;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
        end;
     DopSprites[1]:=Eff;
  End;


  if enmName='bossturrel1' then
  Begin
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';

          if Mainform.Images.Find('bossturrel1col')<>-1 then
            Imagename:='bossturrel1col';


          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          x:=xx2;
          y:=yy2;

          EffectType:=eShine;
          Owner:=self;
          z:=5;
          DrawMode:=1;
          AnimCount:=PatternCount;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
        end;
     DopSprites[1]:=Eff;
  End;

  if (enmName='turrel2')or(enmName='turrel3')or
  (enmName='turrel4')or(enmName='turrel5') then
  Begin
     z:=5;
     Eff:=TEffectSprite.Create(Mainform.Engine);
        with  Eff do
        begin
          ImageName := 'Box1';



          if Mainform.Images.Find('Tur'+copy(enmname,7,1))<>-1 then
            Imagename:='Tur'+copy(enmname,7,1);

          Red:=redw[enmweap];
          Green:=Greenw[enmweap];
          Blue:=Bluew[enmweap];

          x:=xx2;
          y:=yy2;

          z:=6;

          hbk:=1.7;

          EffectType:=eShine;
          Owner:=self;
          DrawMode:=1;
          AnimCount:=PatternCount;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
        end;
     DopSprites[1]:=Eff;
  End;
  ///

  EnmHbSize:=SizeXdiv2*2;
  EnmTicks2:=0;

  if EnmLowAnim then
    DrawMode:=1;

  s.Destroy;
  palf:=pi;
  nextalf:=pi;
end;

procedure TEnemy.DopAction;
begin
 
 if (EnmName= 'enm2')or(AITip=10)or(EnmName= 'boss1') then
  if EnmTicks3>=1 then
  Begin
    allcrazy2:=10;
    Mainform.DXWave.Items.Find('shield.wav').Play(false);
    ExplodeeffBon3(trunc(x+sizexdiv2),trunc(y+sizeydiv2),20,psun2);
  End;
///
///
///
end;

procedure TEnemy.Draw;
var s:string;
begin

 if EnmHbVis>0 then
      DrawHB
    else
      EnmHbVis:=0;

  if TestAI then
  Begin
    s:='???';
    if AIState=Aihunt then
      s:='hunt';
    if AIState=Airunaway then
      s:='run_away';
    if AIState=AiWait then
      s:='wait';
    if AIState=AiGoto then
      s:='goto';

      s:=s+'  '+inttostr(targetdest);

    MainForm.Fonts[1].Textout(s,trunc((x-Engine.Worldx)*Engine.WorldScaleX),
        trunc((y-Engine.Worldy)*Engine.WorldScaleY),clwhite,clred,fxnone)
  End;

 inherited;
end;

procedure TEnemy.DrawHB;
var bx,by,cx,cy:real; sect:shortint;
begin
 with MainForm.MyCanvas do
 Begin
   cx:=SizeXdiv2*Engine.WorldScaleX*hbk;
   cy:=SizeYdiv2*Engine.WorldScaleY*hbk;
   bx:=(x+SizeXdiv2-Engine.Worldx)*Engine.WorldScaleX;
   by:=(y+SizeXdiv2-Engine.Worldy)*Engine.WorldScaleY;
   sect:=round(12*(EnmMaxhealth-EnmHealth)/EnmMaxhealth);

   Enmticks2:=Enmticks2+0.01*MCount;
   if EnmTicks2>=2*pi then
    EnmTicks2:=EnmTicks2-2*pi;


   DrawRotateStretchC(MainForm.Images.Image['Hb1'],0,bx,by,cx*2,cy*2,
        EnmTicks2{УГОЛ!},crgb4(RedW[enmWeap],GreenW[enmWeap],BlueW[enmWeap],trunc(EnmHBVis)),FxBlend);
   DrawRotateStretchC(MainForm.Images.Image['health'],sect,bx,by,cx*2,cy*2,
        0{УГОЛ!},crgb4(RedW[enmWeap],GreenW[enmWeap],BlueW[enmWeap],trunc(EnmHBVis*1.2)),FxBlend);
   DrawRotateStretchC(MainForm.Images.Image['Hb3'],0,bx,by,cx*2,cy*2,
        EnmTicks2{УГОЛ!},crgb4(RedW[enmWeap],GreenW[enmWeap],BlueW[enmWeap],trunc(EnmHBVis)),FxBlend);
   DrawRotateStretchC(MainForm.Images.Image['Hb4'],0,bx,by,cx*2,cy*2,
        -EnmTicks2{УГОЛ!},crgb4(RedW[enmWeap],GreenW[enmWeap],BlueW[enmWeap],trunc(EnmHBVis)),FxBlend);
   DrawRotateStretchC(MainForm.Images.Image['Hb5'],0,bx,by,cx*2,cy*2,
        EnmTicks2*2{УГОЛ!},crgb4(RedW[enmWeap],GreenW[enmWeap],BlueW[enmWeap],trunc(EnmHBVis)),FxBlend);
 End;

end;

procedure TEnemy.Explode;
var i,xx,yy,r,sz:integer;
    alf,scal:real;
    lif:Boolean;
   // str:Tstringlist;
begin

  if (AItip<>5)and(AItip<>6) then
  for I := 1 to 4 do
  if DopSprites[i]<>nil then
          DopSprites[i].Dead;


  if EnmCracks>0 then
      for I := 1 to EnmCracks do
          if EnmCrackList[i]<>nil then
                TEffectSprite(EnmCrackList[i]).Dead;

  xx:=trunc(x);
  yy:=trunc(y);
  lif:=false;
  alf:=palf;
  r:=enmweap;
  sz:=sizexdiv2;
   if (enmName='boss1') then
    Begin
        levelmission:=0;
       // Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);
         
        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),6,SizeYdiv2+200,1);
        MiniExplodeEff2(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);

        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,4,PExplode);

        ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,20,5,11,3,true);

        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2/2,4,PExplode);
        ExplodeEff(x+SizeXdiv2*3/2,y+SizeYdiv2*3/2,4,PExplode);
        ExplodeEff(x+SizeXdiv2/2,y+SizeYdiv2*3/2,4,PExplode);

        if hieffs then
           ExplodeeffBon(trunc(x+SizeXdiv2),trunc(Y+SizeYdiv2),20,psun);

        GoLight:=true;
        LightMax:=225;

        smessage:=language[172];
        smessagetime:=300;
        DoorCols[8]:=DoorCols[8]+4;

        inc(Levelscore.enms);
        if Hieffs then
        Begin
          ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,34,20,1,6,true);
          ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,20,5,11,6,true);
          ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,45,20,1,10,true);
        End;
    End
    else
    if (enmName='Boss2') then
    Begin
       BossCharge:=false;
       levelmission:=0;
       // Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),7,SizeYdiv2+300,1);
        MiniExplodeEff2(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);

        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,4,PExplode);

        if hieffs then
           ExplodeeffBon(trunc(x+SizeXdiv2),trunc(Y+SizeYdiv2),20,psun);

        GoLight:=true;
        LightMax:=125;

        smessage:=language[172];
        smessagetime:=300;
        DoorCols[8]:=DoorCols[8]+4;

        inc(Levelscore.enms);
        if Hieffs then
        Begin
          ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,50,20,1,5,true);
          ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,50,25,15,10,true);
        End;

    End
    else
    if EnmName= 'enm1' then
    Begin
       // Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL

        if LevelMissionTip =4 then
        Begin
          DoorCols[8]:=DoorCols[8]+4;
          dec(levelmission);
          miseff1:=true;
          smessage:=language[298+levelmission];

          smessagetime:=300;
        End;

        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),5,SizeYdiv2+200,1);
        MiniExplodeEff2(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,3,PExplode);
        lif:=true;
        inc(Levelscore.enms);
        if Hieffs then
        Begin
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,34,15,1,7,True);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,25,12,2,6,true);
        End;
    End
    else
    if (EnmName= 'enm2')or(EnmName= 'enm6') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),4,SizeYdiv2+200,1);
        MiniExplodeEff2(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);
        inc(Levelscore.enms);
        if Hieffs then
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,20,1,6,true);
    End
     else
    if (EnmName= 'enm3')or(EnmName= 'enm7')or(EnmName='enm8') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),3,SizeYdiv2+150,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);
        inc(Levelscore.enms);
        if Hieffs then
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,10,10,1,4,false);
    End
    else
    if (EnmName= 'enm9') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),3,SizeYdiv2+150,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);
        inc(Levelscore.enms);
        if Hieffs then
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,10,10,1,4,false);


        with TEnemy.Create(Engine) do
        Begin
          EnmmyobjN:=GetObjNumber('enm10');
          if HiDet=false then
          Begin
            ImageName := 'enm10_ld';
            ScaleX:=1.5;
            ScaleY:=1.5;
          End else
             ImageName := 'enm10';
          EnmName:='enm10';

          palf:=alf;
          nextalf:=palf;

          AItip:=3;
          aistate:=aihunt;
          enmlowanim:=true;
          //DopSprites[1]:=lc;
          SizeXdiv2:=round(ImageWidth div 2*ScaleX);
          SizeYDiv2:=round(ImageHeight div 2*ScaleY);

          X:=xx+sz- SizeXdiv2+80*Cos(-palf); {101010101010101}
          y:=yy+sz- SizeYdiv2-80*Sin(-palf);

          enmweap:=r;

          Creator;
          z:=3;
        //  enmmaxspeed:=0;
          CollideMethod:= cmRect;
          DoCollision := True;
          enmmaxspeed:=enmmaxspeed+0.5;
          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          AI;

          palf:=nextalf;

        End;
      {1010101010}
    End
    else
    if (EnmName= 'enm4') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),2,SizeYdiv2+100,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,1,PExplode);
        lif:=true;
        inc(Levelscore.enms);
        if Hieffs then
        Begin
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,5,1,4,false);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,4,3,3,false);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,15,4,2,6,false);
        End;
    End
    else
    if (EnmName= 'enm42')or(EnmName= 'enm43') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),2,SizeYdiv2+100,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,1,PExplode);
        lif:=true;
        inc(Levelscore.enms);
        if Hieffs then
        Begin
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,5,1,4,false);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,4,2,3,false);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,15,4,2,6,false);
        End;
    End
    else
    if (EnmName= 'rock1')or(EnmName= 'rock2') then
    Begin
        //Mainform.SoundSystem2.Play('boom.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom.wav').Play(false);

        if aitip=5 then
        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),10,SizeYdiv2*2+20,1)
         else  Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),8,SizeYdiv2*2+20,2);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode2);
        // ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,1,PExplode);
        SparkEff2(x+SizeXdiv2,y+SizeYdiv2, pFire,true);
        lif:=true;
    End
    else
    if (EnmName= 'enm5')or(EnmName= 'enm44') then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);
       if (EnmName= 'enm5') then
        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),10,SizeYdiv2+150,1)
          else
           Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),2,SizeYdiv2+100,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,1,PExplode);
        lif:=true;
        inc(Levelscore.enms);
        if Hieffs then
        Begin
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,5,1,4,false);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,9,5,3,false);
        End;
    End
    else
    if EnmName= 'enm11' then
    Begin
        //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),10,SizeYdiv2+150,1);
        MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
        ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,1,PExplode);
        lif:=true;
        inc(Levelscore.enms);
        if Hieffs then
        Begin
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,20,12,1,5,true);
         ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,15,15,4,4,true);
        End;
    End
    else
    Begin
      //Mainform.SoundSystem2.Play('boom2.wav',false);   //////////// EXPL
      Mainform.DXWave.items.Find('boom2.wav').Play(false);

      MiniExplodeEff(x+SizeXdiv2,y+SizeYdiv2,PExplode);
      ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);
      if EnmName<> 'enm10' then
      inc(Levelscore.enms);
      Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),5,SizeXDiv2,1);
      if Hieffs then
        ExplodeDopEff(x+SizeXdiv2,y+SizeYdiv2,14,10,1,4,false);
    End;

    if EnmName= 'enm10' then
    Mainform.BoomPhys(trunc(X+SizeXdiv2),trunc(Y+SizeYdiv2),10,SizeYdiv2+150,1);


    if (abs(EnmBody.x-_player.X-128)<EnmBody.radius+170)and(abs(EnmBody.Y-_player.y-128)<EnmBody.radius+170)
            then BoomTime:=20;

  if Objs[EnmMyObjN].DopList<>nil then
  Begin
   scal:=1;
   if Bigger then
     scal:=1.2;
  for i:=0 to (Objs[EnmMyObjN].DopList.Count)div 3-1 do
     with  TCapsule.Create(Mainform.Engine) do
                  begin
                    //showmessage(inttostr(enmMyObjN));
                    //showmessage(Objs[enmMyObjN].DopList[i*3]);

                    Imagename:='Box1';
                    if Mainform.Images.Find(Objs[enmMyObjN].DopList[i*3])<>-1 then
                      Imagename:=Objs[enmMyObjN].DopList[i*3];

                    AnimCount:=PatternCount;
                    AnimSpeed:=0.3;

                    if i>=3 then MirrorY:=true;

                    alf:=getalf0(round(strtoint(Objs[enmMyObjN].DopList[i*3+1])),round(strtoint(Objs[enmMyObjN].DopList[i*3+2])));
                    r:=trunc(SQRT(SQR(strtoint(Objs[enmMyObjN].DopList[i*3+1]))+SQR(strtoint(Objs[enmMyObjN].DopList[i*3+2]))));

                    Angle:=-palf;

                    ScaleX:=scal;
                    ScaleY:=ScaleX;

                    live:=lif;

                    impulse1.ImpX:=cos(alf-Angle);
                    impulse1.ImpY:=-sin(alf-Angle);
                    impulse1.ImpPower:=1;

                    x:=XX+128+R*impulse1.ImpX-imageWidth/2;    /////////!!!!
                    y:=YY+128+R*impulse1.ImpY-imageHeight/2;

                   // DrawMode:=1;

                    z:=0;
                    tip:=1;

                    if (hieffs=false)or(animcount=1) then
                    Begin
                     DrawMode:=1;
                     Offsetx:=imageWidth/2;    /////////!!!!
                     Offsety:=imageHeight/2;

                    End;

                    SizeYd2:=ImageHeight div 2;
                    SizeXd2:=ImageWidth div 2;

                    CollideMethod:= cmRect;
                    DoCollision := true;

                    SizeYd2:=ImageHeight div 2;
                    SizeXd2:=ImageWidth div 2;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                  end;
  End;
   // if pos('Boss',EnmName)>=1 then
   //  DoorCols[8]:=4;

dead;
end;

procedure TEnemy.findtarget;
var i:integer;
 Sprite:TEnemy;
begin
for i := 0 to Engine.Count - 1 do
 if Engine[i] is TEnemy then
 Begin
   sprite:=TEnemy(Engine[i]);
   if sprite.AITip<>6 then
   if (abs(sprite.X+sprite.SizeXdiv2-X-300*Sin(palf+pi/2))<600)and
      (abs(sprite.Y+sprite.SizeYdiv2-Y+300*Cos(palf+pi/2))<600) then
   Begin
    dopsprites[1]:=Sprite;
    targetX:=trunc(sprite.X+sprite.SizeXdiv2);
    targetY:=trunc(sprite.Y+sprite.SizeYdiv2);

    //if TEnemy(sprite).EnmName='enm2' then
     TEnemy(sprite).DopAction;
    //showmessage(inttostr(trunc(X))+' '+inttostr(trunc(y)));
    //showmessage(inttostr(trunc(targetX))+' '+inttostr(trunc(targety)));
    break;
   End;

 End;

end;

procedure TEnemy.Move(const MoveCount: Single);
var i,k,l,m,oanim,cc:integer;
begin
 inherited;

 if Detect=true then
 Begin
   if (abs(_player.X+128-EnmBody.x)<1600)and(abs(_player.y+128-EnmBody.Y)<1200)then
   Begin

    for I := 1 to 3 do
    Begin
      if (detcol[i]=enmweap) then
        break
      else
      if (detcol[i]=0) then
      Begin
       detcol[i]:=enmweap;
       break;
      End;
    End;

   End;
 End;

 if Radar then
 Begin
   if (abs(_player.X-x)<1600)and(abs(_player.y-Y)<1600)then
   Begin

     k:=round((_player.X+128-x)/20);
     l:=round((_player.Y+128-y)/20);
     i:=sizexdiv2 div 10;

     if sqrt(sqr(k-i)+sqr(l-i))<80 then
     Begin
       if MiniMapObjCount<512 then
          inc(MiniMapObjCount);
       MMap[MiniMapObjCount,0]:=11;
       MMap[MiniMapObjCount,1]:=k;
       MMap[MiniMapObjCount,2]:=l;
       MMap[MiniMapObjCount,3]:=i+2;
       MMap[MiniMapObjCount,4]:=i+2;
     End;
     // mainform.ImageList1.Draw(miniBitmap.Canvas,100-k-16-i,100-l-16-i,m);
     //ellipse(k-i,l-i,k+i,l+i);
   End;
 End;

 if (abs(_Player.X-x)<2400)and(abs(_Player.Y-y)<1800) then
 Begin

  SetEnmBox;
  if AITip>=9 then
     Enmimpulse.ImpPower:=0;

  if (Enmimpulse.ImpPower>EnmMaxSpeed) then
   Enmimpulse.ImpPower:=EnmMaxSpeed;
  if Enmimpulse.ImpPower>0 then
   Enmimpulse.ImpPower:=Enmimpulse.ImpPower-abs(lagcount)/50;
  if (Enmimpulse.ImpPower<0) then
   Enmimpulse.ImpPower:=0;

   oanim:=trunc(animpos);

   zx1:=trunc(EnmBody.x-EnmBody.radius+5) div 100;
   zx2:=trunc(EnmBody.x+EnmBody.radius-5) div 100;
   zy1:=trunc(EnmBody.y-EnmBody.radius+5) div 100;
   zy2:=trunc(EnmBody.y+EnmBody.radius-5) div 100;

  if aitip<>6 then ////// <5 !!!!!!!!!
   for k:=zx1 to zx2 do
    for l:=zy1 to zy2 do
      if (k>=0)and(l>=0)and(k<=mapsizex)and(l<=mapsizey) then
        AIDynSubMAP[k,l]:=true;

   if GunsCount>0 then
   Begin
     if EnmShootTime<EnmShootwait then
     Begin
      EnmShootTime:=EnmShootTime+Movecount;
      if EnmShootTime>EnmShootwait then
         EnmShootTime:=EnmShootwait;
     End;
   End;

   if Enmname='enm1' then oanim:=animcount-trunc(animpos);

   if (Enmname='turrel') then
   Begin
        i:=trunc(palf*72);
        if DopSprites[1]<>nil then
        Begin
          if (ultralow)or(EnmLowAnim) then
           DopSprites[1].angle:=angle
            else
              DopSprites[1].angle:=i/72;
        End;
   End;

   if EnmTicks3<1 then
    Enmticks3:=Enmticks3+0.01*MCount;

   {МИНА}
  { if (Enmname='enm5') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2+EnmSubRA[1,1]*Cos(Enmsubra[2,1]-palf);
        EnmSubBodies[1].y:=y+SizeYdiv2-EnmSubRA[1,1]*Sin(Enmsubra[2,1]-palf);
        i:=trunc(palf*72);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
          if (ultralow=false) then
            DopSprites[1].angle:=i/72
             else DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;

   if (Enmname='enm3') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
         if ultralow=false then
          DopSprites[1].angle:=i*2*pi/72
           else DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;

   {if (Enmname='enm8')or(Enmname='enm9')
      or(Enmname='enm10')then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
       // i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
         //if ultralow=false then
         // DopSprites[1].angle:=i*2*pi/72
           //else
           DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;    

   if (Enmname='enm1') then
   Begin

        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
      for k:=1 to 2 do
      Begin
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[k]<>nil then
        Begin
          DopSprites[k].X:=EnmSubBodies[1].x;
          DopSprites[k].y:=EnmSubBodies[1].y;
          DopSprites[k].angle:=angle;
          DopSprites[k].Move(0);
        End;
      End;
   End;   }

   Turn;
   {NEW!!! 4-1-2015}                 {1600}                                            {1200}
   if (abs(_Player.X+128-X+Sizexdiv2)<2100+EnmDopInt)and(abs(_Player.Y+128-Y+Sizeydiv2)<1700+EnmDopInt) then
        AI
         else
         if AITip<10 then
         Begin
            AIstate:=aihunt;
            EnmImpulse.ImpPower:=0;
         End else
            AI;
   inWall:=true;


    if (abs(x+SizeXdiv2-gamcurx)<SizeXdiv2)and(abs(y+Sizeydiv2-gamcury)<Sizeydiv2)then
      Begin
       if lakmus then
       Begin
         if currentweapon<>enmweap then
         Begin
           for i:=1 to altweaponscount do
            if altweapons[i]=enmweap then
            Begin
              k:=currentweapon;
              currentweapon:=altweapons[i];
              altweapons[i]:=k;
              if i=1 then
                AltWeapon:=AltWeapons[1];
              Break;
            End;


         End;
       End;

       if EnmHBvis<155 then
        EnmHBvis:=EnmHBvis+Movecount*7;
       if EnmHBvis>155 then
        EnmHBvis:=155;
      End
      else
       if EnmHBvis>0 then
        EnmHBvis:=EnmHbvis-Movecount*10;

   

    if enmstatic=false then
    Begin
      EnmMainImpulse.ImpX:=Sin(palf+pi/2);
      EnmMainImpulse.ImpY:=-Cos(palf+pi/2);
      if EnmMainimpulse.ImpPower>EnmMaxSpeed then
        EnmMainimpulse.ImpPower:=EnmMaxSpeed;

      if EnmImpulse.ImpPower<>0 then
     EnmMainImpulse:=Mainform.Superpos(EnmMainImpulse,EnmImpulse);
      x:=X+EnmMainimpulse.ImpX*Movecount*3*EnmMainimpulse.ImpPower;
      Y:=Y+EnmMainimpulse.ImpY*Movecount*3*EnmMainimpulse.ImpPower;

      InWall:=false;
      Collision;
   End;

  // Turn;

   if (Enmname='turrel2') then
   Begin
        palf:=0;
        angle:=0;
        nextalf:=palf;
        i:=trunc(palf);
        DopSprites[1].angle:=i;
   End;

      if (Enmname='turrel3') then
   Begin
        palf:=0;
        angle:=0;
        nextalf:=palf;
        i:=trunc(palf);
        DopSprites[1].angle:=i;
   End;

      if (Enmname='turrel4') then
   Begin
        palf:=0;
        angle:=0;
        nextalf:=palf;
        i:=trunc(palf);
        DopSprites[1].angle:=i;
   End;

      if (Enmname='turrel5') then
   Begin
        palf:=0;
        angle:=0;
        nextalf:=palf;
        i:=trunc(palf);
        DopSprites[1].angle:=i;
   End;

   if (x+SpriteWidth/Engine.WorldScaleX>Engine.WorldX+Engine.VisibleArea.Left) then
     if (x<Engine.WorldX+Engine.VisibleArea.Right) then
        if (y+SpriteHeight/Engine.WorldScaleY>Engine.Worldy+Engine.VisibleArea.Top) then
           if (y<Engine.Worldy+Engine.VisibleArea.Bottom) then
           Begin
              SetFlame(MoveCount);


      End;

      //// ОТОБРАЖАЮ ПОВРЕЖДЕНИЯ.
              if EnmCracks>0 then
                for I := 1 to EnmCracks do
                Begin
                    if EnmHealth<i*EnmMaxHealth/(EnmCracks+1) then
                    begin
                      if EnmCrackList[i]<>nil then
                        if EnmCrackList[i] is TEffectSprite then
                        Begin
                          if (ultralow)or(enmlowanim) then
                             TEffectSprite(EnmCrackList[i]).Angle:=angle
                             else
                             TEffectSprite(EnmCrackList[i]).Angle:=oanim/animcount*2*pi;
                          TEffectSprite(EnmCrackList[i]).X:=X+SizeXdiv2;
                          TEffectSprite(EnmCrackList[i]).Y:=Y+SizeYdiv2;
                          TEffectSprite(EnmCrackList[i]).Visible:=true;
                          TEffectSprite(EnmCrackList[i]).Move(0);
                        End;
                    end else
                      begin
                         if (enmName='boss1')or(enmName='boss2') then
                            if EnmCrackList[i]<>nil then
                               TEffectSprite(EnmCrackList[i]).Visible:=false;
                      end;
                End;
    OldX:=X;
    OldY:=Y;
 End;



   if EnmName='boss1' then

   Begin
     cc:=0;
     for i := 1 to 4 do
      if  (DopSprites[i]<>nil)and(DopSprites[i] is TEnemy) then
      if (TEnemy(DopSprites[i]).AITip<5) then
      Begin
        DopSprites[i].y:=y-TEnemy(DopSprites[i]).SizeXdiv2+SizeXdiv2-EnmSubRA[1,i]*Sin(Enmsubra[2,i]-palf);
        DopSprites[i].x:=x-TEnemy(DopSprites[i]).SizeXdiv2+SizeYdiv2+EnmSubRA[1,i]*Cos(Enmsubra[2,i]-palf);
        //DopSprites[i].Move(0);   hghg
       if TEnemy(DopSprites[i]).EnmHealth>0 then
       inc(cc);

      End;

    if cc>0 then
         enmhealth:=enmmaxhealth;


      levelmission:=trunc((enmhealth/enmmaxhealth)*100);
   End;



   if (Enmname='enm1') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
      for k:=1 to 2 do
      Begin
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[k]<>nil then
        Begin
          DopSprites[k].X:=EnmSubBodies[1].x;
          DopSprites[k].y:=EnmSubBodies[1].y;
          DopSprites[k].angle:=angle;
          DopSprites[k].Move(0);
        End;
      End;
   End;

   if (Enmname='Boss2') then
   Begin
    for k:=1 to 4 do
      Begin
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[k]<>nil then
        Begin
          DopSprites[k].X:=EnmSubBodies[1].x;
          DopSprites[k].y:=EnmSubBodies[1].y;
          DopSprites[k].angle:=angle;
          DopSprites[k].Move(0);

          //if i=4 then
           if k<4 then
           Begin

            if (ShotCount>=k) then
            Begin
              with TEffectSprite(DopSprites[k]) do
               Begin
               CRGB(redw[enmWeap],Greenw[enmWeap],Bluew[enmWeap],
                    255,1,MoveCount);
                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
               End;
             End else
             Begin
               with TEffectSprite(DopSprites[k]) do
               Begin
                CRGB(redw[enmWeap],Greenw[enmWeap],Bluew[enmWeap],
                    0,1,MoveCount);
                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
               End;
             End;

           End else
           begin

              with TEffectSprite(DopSprites[k]) do
               Begin
                CRGB(redw[enmWeap],Greenw[enmWeap],Bluew[enmWeap],
                    255,1,MoveCount);
                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
               End;
           end;
        End;
      End;
      levelmission:=trunc((enmhealth/enmmaxhealth)*100);
      bosscol:=cRgb1(redw[enmWeap],greenw[enmWeap],bluew[enmWeap],255);
   End;


    if (Enmname='enm8')or(Enmname='enm9')
      or(Enmname='enm10'){or(Enmname='enm11')}then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
       // i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
         //if ultralow=false then
         // DopSprites[1].angle:=i*2*pi/72
           //else
           DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;

    if (Enmname='enm5') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2+EnmSubRA[1,1]*Cos(Enmsubra[2,1]-palf);
        EnmSubBodies[1].y:=y+SizeYdiv2-EnmSubRA[1,1]*Sin(Enmsubra[2,1]-palf);
        i:=trunc(palf*72);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
          {if (ultralow=false) then
            DopSprites[1].angle:=i/72
             else }
             DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;

   if (Enmname='enm6') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2+EnmSubRA[1,1]*Cos(Enmsubra[2,1]-palf);
        EnmSubBodies[1].y:=y+SizeYdiv2-EnmSubRA[1,1]*Sin(Enmsubra[2,1]-palf);
        i:=trunc(palf*72);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
          DopSprites[1].Alpha:=trunc(255*EnmShootTime/EnmShootwait);
          {if (ultralow=false) then
            DopSprites[1].angle:=i/72
             else }
          DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
        EnmSubBodies[2].x:=x+SizeXdiv2;
        EnmSubBodies[2].y:=y+SizeYdiv2;
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[2]<>nil then
        Begin
          DopSprites[2].X:=EnmSubBodies[1].x;
          DopSprites[2].y:=EnmSubBodies[1].y;
         {if ultralow=false then
          DopSprites[1].angle:=i*2*pi/72
           else}
            DopSprites[2].angle:=angle;
          DopSprites[2].Move(0);
        End;
   End;

   if (Enmname='enm3') then
   Begin
        EnmSubBodies[1].x:=x+SizeXdiv2;
        EnmSubBodies[1].y:=y+SizeYdiv2;
        i:=trunc(animpos);//i:=round(palf*180);
        if DopSprites[1]<>nil then
        Begin
          DopSprites[1].X:=EnmSubBodies[1].x;
          DopSprites[1].y:=EnmSubBodies[1].y;
         {if ultralow=false then
          DopSprites[1].angle:=i*2*pi/72
           else}
            DopSprites[1].angle:=angle;
          DopSprites[1].Move(0);
        End;
   End;

    if   (AITip=10) then
    Begin
     if EnmWeap>1 then
       EnmHealth:=EnmMaxHealth*(Enmweap/7+1);
    End;


    if EnmHealth<=0 then
    Explode;


    if (AITip=5) then
     if allcrazy1>0 then
       crazy:=true;
    if (AITip=6) then
     if allcrazy2>0 then
       AItip:=5;

    if InWall then
    if (AITip=5)or(AITip=6) then
      EnmHealth:=0;
end;

procedure TEnemy.OnCollision(const Sprite: TSprite);
var VeloX,VeloY,xp,yp,ii,jj:real;
  i,j,cols:integer;
  DopImp:Timpulse;
  gethurt,oldwall,touch:boolean;
begin
  inherited;
  //

  if sprite is TLaser then
  Begin
   Touch:=false;
   if (Tlaser(Sprite).direction=1)or(Tlaser(Sprite).direction=3) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=EnmBody.X;
     if (abs(EnmBody.y-yp)<EnmBody.radius)and(xp>Sprite.x-16)and(xp<Sprite.x+Sprite.SpriteWidth+16) then
     Begin
        touch:=true;
        EnmImpulse:=EnmMainImpulse;

          if ((EnmBody.y>yp){and(Force.ImpY<0)}) then
            EnmImpulse.ImpY:=1
              else
            if ((EnmBody.y<yp){and(Force.ImpY>0)}) then
              EnmImpulse.ImpY:=-1;

            EnmMainImpulse.ImpPower:=0;

            EnmImpulse.ImpPower:=5;


       // xx:=sqrt(sqr(Body.radius)-sqr(sprite.Y+sprite.SpriteHeight/2));
       // xp:=-sqrt(sqr(Body.radius)-sqr(sprite.Y+sprite.SpriteHeight/2));
     End
     else {NEW!!!!!!!!!}
     Begin
        if EnmSubCount>0 then
            for i := 1 to EnmSubCount do
             if(abs(EnmSubbodies[i].y-yp)<EnmSubbodies[i].radius)and
             (EnmSubbodies[i].x>Sprite.x-16)and
             (EnmSubbodies[i].x<Sprite.x+Sprite.SpriteWidth+16) then
             Begin
                touch:=true;
                EnmImpulse:=EnmMainImpulse;
                if ((EnmBody.y>yp){and(Force.ImpY<0)}) then
                    EnmImpulse.ImpY:=1
                      else
                          if ((EnmBody.y<yp){and(Force.ImpY>0)}) then
                              EnmImpulse.ImpY:=-1;
                EnmMainImpulse.ImpPower:=0;
                EnmImpulse.ImpPower:=5;
             End;
     End;   {NEW end}
   End else
   Begin
     /// Вертикально
      xp:=Sprite.x+Sprite.SpriteWidth/2;
      yp:=EnmBody.Y;
     if (abs(EnmBody.x-xp)<EnmBody.radius)and(yp>Sprite.y-16)and(yp<Sprite.y+Sprite.Spriteheight+16) then
     Begin
        touch:=true;
        EnmImpulse:=EnmMainImpulse;

          if ((EnmBody.x>xp){and(Force.ImpY<0)}) then
            EnmImpulse.ImpX:=1
              else
            if ((EnmBody.x<xp){and(Force.ImpY>0)}) then
              EnmImpulse.ImpX:=-1;


            EnmMainImpulse.ImpPower:=0;

            EnmImpulse.ImpPower:=5;
     End else
     Begin   {NEW!!!!!!!!!!!!!!!!!}
          if EnmSubCount>0 then
            for i := 1 to EnmSubCount do
              if (abs(EnmSubbodies[i].x-xp)<EnmSubbodies[i].radius)and
              (EnmSubbodies[i].y>Sprite.y-16)and
              (EnmSubbodies[i].y<Sprite.y+Sprite.Spriteheight+16) then
              Begin
                touch:=true;
                EnmImpulse:=EnmMainImpulse;
                if ((EnmBody.x>xp){and(Force.ImpY<0)}) then
                  EnmImpulse.ImpX:=1
                    else
                      if ((EnmBody.x<xp){and(Force.ImpY>0)}) then
                        EnmImpulse.ImpX:=-1;
                EnmMainImpulse.ImpPower:=0;
                EnmImpulse.ImpPower:=5;
              End;
     End;        {NEW END}

   End;





   if touch then
     Begin
       //health:=health-lagcount;
       IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<2 then
       Begin
          Mainform.DXWave.items.Find('electro.wav').Play(false);
          if (enmweap=Tlaser(Sprite).lascolor)or(enmweap=0) then
             Enmhealth:= Enmhealth-20
              else  Enmhealth:= Enmhealth-1;
          Sparkeff2(xp,yp,Pfire,true);
          Sparkeff(xp,yp,Pfire);


          if AIstate=AIGoto then AIState:=AiHunt;


          if (AITip=10)and(enmweap=Tlaser(Sprite).lascolor) then
          Begin
            dec(enmweap);
            ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,4,PExplode);
            ExplodeEff(x+SizeXdiv2,y+SizeYdiv2,2,PExplode);

            miniExplodeEff2(x+SizeXdiv2,y+SizeYdiv2,PExplode);
                                         
            GoLight:=true;
            LightMax:=100;
            Mainform.DXWave.items.Find('boom2.wav').Play(false);
          End;

       End;
     End;
  End;

      oldwall:=inwall;

  if (sprite is TEnemy)and(sprite<>self) then
      if (enmname<>'bossturrel1') and (TEnemy(Sprite).enmname<>'bossturrel1') then
      Begin
        SetEnmBox;
        TEnemy(sprite).SetEnmBox;

        ii:=sqrt(sqr(EnmBody.X-TEnemy(sprite).EnmBody.x)
              +sqr(EnmBody.Y-TEnemy(sprite).EnmBody.Y));  ////////////////!!!! ENEMY COL!

         if (ii<EnmBody.radius+TEnemy(sprite).EnmBody.radius)and(ii>1) then
         Begin
            TEnemy(sprite).OldX:=TEnemy(sprite).X;
            TEnemy(sprite).OldY:=TEnemy(sprite).Y;

            ii:=(EnmBody.radius+TEnemy(sprite).EnmBody.radius-ii)/(EnmBody.radius+TEnemy(sprite).EnmBody.radius);

            xp:=((EnmBody.X-TEnemy(sprite).EnmBody.x)*ii);//(Body.radius+TEnemy(sprite).EnmBody.radius));
            yp:=((EnmBody.Y-TEnemy(sprite).EnmBody.y)*ii);//(Body.radius+TEnemy(sprite).EnmBody.radius));

            if (AItip=5) then
              if (sprite<>DopSprites[1])and(Tenemy(Sprite).AITip<>5) then
                EnmHealth:=0;

             if (AItip=6) then
              if (Tenemy(Sprite).AITip<>6) then
                EnmHealth:=0;

               if inwall=false then
               Begin
                X:=x+xp/2;
                y:=y+yp/2;
               End;

           if TEnemy(Sprite).InWall=true then
           Begin

           End
            else
              Begin
                TEnemy(sprite).X:=TEnemy(sprite).X-xp/2;
                TEnemy(sprite).y:=TEnemy(sprite).y-yp/2;
              End;
           //   Mainform.SoundSystem2.Play('metal.wav',false);
      End

      End;

    if sprite is TCapsule then Begin
    if (TCapsule(sprite).noob=false)and(TCapsule(sprite).keeping=false) then
      Begin
         ii:=sqrt(sqr(EnmBody.X-TCapsule(sprite).Capsuleshape.POsX)+
         sqr(EnmBody.y-TCapsule(sprite).Capsuleshape.POsY));

         if (ii<EnmBody.radius+TCapsule(sprite).Capsuleshape.RAD) and(ii>1)  then
         Begin

           if TCapsule(sprite).tip=4 then
            if (TCapsule(sprite).Impulse1.ImpPower>3)or(AITip=5)or(AITip=6) then
            Begin
              TCapsule(sprite).explode;

            End;


           jj:=(EnmBody.radius+50-ii);
           ii:=jj/(EnmBody.radius+50);
           xp:=(EnmBody.X-TCapsule(sprite).Capsuleshape.POsX)*ii;
           yp:=(EnmBody.Y-TCapsule(sprite).Capsuleshape.POsY)*ii;

         //  if TCapsule(Sprite).impulse1.imppower>1 then
         //  Mainform.SoundSystem2.Play('metal.wav',false);

           if TCapsule(sprite).statics=false then
           Begin
            TCapsule(sprite).X:=TCapsule(sprite).X-xp;
            TCapsule(sprite).y:=TCapsule(sprite).y-yp;
           End;

            if (AItip=5)or(AITip=6) then
             EnmHealth:=0;

           if TCapsule(sprite).noob2=false then
           Begin
            DopImp.ImpX:=-xp/jj;//(EnmBody.X-TCapsule(sprite).Capsuleshape.POsX)/(EnmBody.radius+50);
            DopImp.ImpY:=-yp/jj;//(EnmBody.Y-TCapsule(sprite).Capsuleshape.POsY)/(EnmBody.radius+50);
            DopImp.ImpPower:=1;
            xp:=EnmImpulse.ImpPower;
            EnmImpulse.ImpPower:=0.1;
            DopImp:=Mainform.Superpos(EnmImpulse,DopImp);
            EnmImpulse.ImpPower:=xp;
            TCapsule(sprite).Impulse1:=Mainform.Superpos(TCapsule(sprite).Impulse1,DopImp);
            TCapsule(sprite).noob2:=true;
           End;
         End else
         Begin
           TCapsule(sprite).noob2:=false;
         End;

      End;
  End;


  if sprite is Tmina then
  Begin
      Begin
         ii:=sqrt(sqr(EnmBody.X-Tmina(sprite).minaShape.POsX)+
         sqr(EnmBody.y-Tmina(sprite).minaShape.POsY));
         if (ii<EnmBody.radius+50) then
         Begin

           jj:=(EnmBody.radius+50-ii);
           ii:=jj/(EnmBody.radius+50);

           xp:=(EnmBody.X-TMina(sprite).Minashape.POsX)*ii;
           yp:=(EnmBody.Y-TMina(sprite).Minashape.POsY)*ii;

           Tmina(sprite).exp:=true;

           if (AItip=5)or(AITip=6)  then
             EnmHealth:=0;

            if Tmina(Sprite).playersmina then
             Tmina(Sprite).TimeToExplode:=80;


       //     Mainform.SoundSystem2.Play('metal.wav',false);

           if Tmina(sprite).statics=false then
           Begin
            Tmina(sprite).X:=Tmina(sprite).X-xp;//(Body.X-Tmina(sprite).minaShape.POsX)/(Body.radius+50);
            Tmina(sprite).y:=Tmina(sprite).y-yp;//(Body.Y-Tmina(sprite).minaShape.POsY)/(Body.radius+50);
           End;

          if Tmina(sprite).noob2=false then
           Begin
            DopImp.ImpX:=-xp/jj;//-(Body.X-Tmina(sprite).minaShape.POsX)/(Body.radius+50);
            DopImp.ImpY:=-yp/jj;//-(Body.Y-Tmina(sprite).minaShape.POsY)/(Body.radius+50);
            DopImp.ImpPower:=2;
            xp:=EnmImpulse.ImpPower;
            EnmImpulse.ImpPower:=1;
            DopImp:=Mainform.Superpos(EnmImpulse,DopImp);
            EnmImpulse.ImpPower:=xp;
            Tmina(sprite).Impulse1:=Mainform.Superpos(Tmina(sprite).Impulse1,DopImp);
            Tmina(sprite).noob2:=true;
           End;
         End else
         Begin
           Tmina(sprite).noob2:=false;
         End;

      End;
  End;


  if Sprite is TArmoSprite then
  if TArmoSprite(Sprite).launcher<>self then
  begin
    gethurt:=false;
     ii:=sqrt(sqr(EnmBody.X-TArmosprite(sprite).X)+
         sqr(EnmBody.y-TArmosprite(sprite).Y));
    if (ii<EnmBody.radius+10)and(ii>1) then
    gethurt:=true
    else
      if EnmSubCount>0 then
        for j:=1 to EnmSubCount do
        Begin
          ii:=sqrt(sqr(EnmSubBodies[j].X-TArmosprite(sprite).X)+
              sqr(EnmSubBodies[j].y-TArmosprite(sprite).Y));
          if (ii<EnmSubBodies[j].radius+10)and(ii>1) then
          Begin
            gethurt:=true;
            break;
          End;
        End;

       if Gethurt then
       Begin
         if TArmosprite(sprite).enm=false then
         Begin
           inc(Levelscore.shotsluck);
           if Levelscore.shotsluck>Levelscore.shootscount then
              Levelscore.shotsluck:=Levelscore.shootscount;
         End;
        if (TArmosprite(sprite).col=enmweap)or(AITip=5)or(AITip=6)or(TArmosprite(sprite).col=8) then
         if not((TArmosprite(sprite).ArmoType<>aball)and(AITip=10)and(enmWeap>1)) then
            enmhealth:=enmhealth-TArmosprite(sprite).armopower;
       ///  else enmhealth:=enmhealth-1;
        if hieffs then
        Begin
          SparkEff2(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire,true);
          SparkEff(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire);
          FireEff(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire, 1);
        End;

        if AItip=5 then
             EnmHealth:=0;

        TArmosprite(sprite).Dead;
        gethurt:=false;

        //Mainform.SoundSystem2.Play('metal.wav',false);
        Mainform.DXWave.items.Find('metal.wav').Play(false);
       End;
  end;

  VeloX:=X-OldX;
  VeloY:=Y-OldY;

   if Sprite is TTile then
   begin
      SetEnmBox;

   if (AITip=10)and(AIState=aiWait) then
   if TTile(Sprite).tip=7 then
   Begin
     TTile(Sprite).activ:=true;   
   End;


   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
    Begin
      cols:=0;
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
          if VeloY<0 then
          Begin
            {СЧИТАЮ X пересечения с Y}

            if EnmBody.y-EnmBody.radius<TTile(Sprite).lines[i].y1 then
            if (EnmBody.X+EnmBody.radius-velox>TTile(Sprite).lines[i].x1)and(EnmBody.x-EnmBody.radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].y1-EnmBody.y+EnmBody.radius)<abs(Veloy*5)+10{*Mcount} then
              y:=y+(TTile(Sprite).lines[i].y1-EnmBody.y+EnmBody.radius);
              SetEnmBox;
            End;
          End;
        End;
        2: Begin /// Left
          if VeloX<0 then
          Begin

            if EnmBody.x-EnmBody.radius<TTile(Sprite).lines[i].x1 then
            if (EnmBody.y+EnmBody.radius-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y-EnmBody.radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].x1-EnmBody.x+EnmBody.radius)<abs(VeloX*5)+10{*Mcount} then
              x:=x+(TTile(Sprite).lines[i].x1-EnmBody.x+EnmBody.radius);
              SetEnmBox
            End;
          End;
        End;
        3: Begin /// Down
          if VeloY>0 then
          Begin
            if EnmBody.y+EnmBody.radius>TTile(Sprite).lines[i].y2 then
            if (EnmBody.X+EnmBody.radius-velox>TTile(Sprite).lines[i].x1)and(EnmBody.x-EnmBody.radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius)<abs(Veloy*5)+10{*Mcount} then
              y:=y+(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius);
              SetEnmBox
            End;
          End;
        End;
         4: Begin /// Right
          if VeloX>0 then
          Begin
            if EnmBody.x+EnmBody.radius>TTile(Sprite).lines[i].x2 then
            if (EnmBody.y+EnmBody.radius-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y-EnmBody.radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].x2-EnmBody.x-EnmBody.radius)<abs(VeloX*5)+10{*Mcount} then
              x:=x+(TTile(Sprite).lines[i].x2-EnmBody.x-EnmBody.radius);
              // else showmessage(floattostr(10*Mcount));
              SetEnmBox
            End;
          End;
        End;

         5: Begin /// Down+Left

         {Лево}
         if VeloX<0 then
          Begin
            xp:=TTile(Sprite).lines[i].x1+(EnmBody.y+EnmBody.radius/1.4142-TTile(Sprite).lines[i].y1);
            if EnmBody.x-EnmBody.radius/1.4142<xp then
            if (EnmBody.y+EnmBody.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y+EnmBody.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
                InWall:=true;
                yp:=TTile(Sprite).lines[i].y1+(EnmBody.x-EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
                y:=y+(yp-EnmBody.y-EnmBody.radius/1.142);
              if abs(EnmBody.x-EnmBody.radius/1.4142-xp)<abs(VeloX*5)+10{*Mcount} then Begin
               x:=X+(xp-EnmBody.x+EnmBody.radius/1.4142);//+(TTile(Sprite).lines[i].x1-EnmBody.x+EnmBody.radius);
              End;
              SetEnmBox
            End;
          End;

         {Низ}

         if VeloY>0 then
          Begin
            yp:=TTile(Sprite).lines[i].y1+(EnmBody.x-EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
            if EnmBody.y+EnmBody.radius/1.142>yp then
            if (EnmBody.X-EnmBody.radius/1.142-velox>TTile(Sprite).lines[i].x1)and(EnmBody.x-EnmBody.radius/1.142-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(yp-EnmBody.y-EnmBody.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-EnmBody.y-EnmBody.radius/1.142);//+(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius);
              SetEnmBox
            End;
          End;

        End;

        6: Begin /// Down+Right

         {Право}
         if VeloX>0 then
          Begin
            
            xp:=TTile(Sprite).lines[i].x1-(EnmBody.y+EnmBody.radius/1.4142-TTile(Sprite).lines[i].y1);
            if EnmBody.x+EnmBody.radius/1.4142>xp then
            if (EnmBody.y+EnmBody.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y+EnmBody.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              InWall:=true;
              yp:=TTile(Sprite).lines[i].y1-(EnmBody.x+EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-EnmBody.y-EnmBody.radius/1.142);
              if abs(EnmBody.x+EnmBody.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-EnmBody.x-EnmBody.radius/1.4142);
              SetEnmBox
            End;
          End;

         {Низ}

         if VeloY>0 then
          Begin
            
            yp:=TTile(Sprite).lines[i].y1-(EnmBody.x+EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
            if EnmBody.y+EnmBody.radius/1.142>yp then
            if (EnmBody.X+EnmBody.radius/1.142-velox>TTile(Sprite).lines[i].x2)and(EnmBody.x+EnmBody.radius/1.142-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              InWall:=true;
              if abs(yp-EnmBody.y-EnmBody.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-EnmBody.y-EnmBody.radius/1.142);//+(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius);
              SetEnmBox
            End;
          End;
        End;
         7: Begin /// Top+Right

         {Право}
         if VeloX>0 then
          Begin
            
            xp:=TTile(Sprite).lines[i].x1+(EnmBody.y-EnmBody.radius/1.4142-TTile(Sprite).lines[i].y1);
            if EnmBody.x+EnmBody.radius/1.4142>xp then
            if (EnmBody.y-EnmBody.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y-EnmBody.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              yp:=TTile(Sprite).lines[i].y1+(EnmBody.x+EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-EnmBody.y+EnmBody.radius/1.142);
               InWall:=true;
              if abs(EnmBody.x+EnmBody.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-EnmBody.x-EnmBody.radius/1.4142);
              SetEnmBox
            End;
          End;

         {Верх}

         if VeloY<0 then
          Begin
            
            yp:=TTile(Sprite).lines[i].y1+(EnmBody.x+EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
            if EnmBody.y-EnmBody.radius/1.142<yp then
            if (EnmBody.X+EnmBody.radius/1.142-velox>TTile(Sprite).lines[i].x1)and(EnmBody.x+EnmBody.radius/1.142-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(yp-EnmBody.y+EnmBody.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-EnmBody.y+EnmBody.radius/1.142);//+(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius);
              SetEnmBox
            End;
          End;
        End;
         8: Begin /// Left+Top

         {Лево}
         if VeloX<0 then
          Begin
            
            xp:=TTile(Sprite).lines[i].x1-(EnmBody.y-EnmBody.radius/1.4142-TTile(Sprite).lines[i].y1);
            if EnmBody.x-EnmBody.radius/1.4142<xp then
            if (EnmBody.y-EnmBody.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(EnmBody.y-EnmBody.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
               InWall:=true;
               yp:=TTile(Sprite).lines[i].y1-(EnmBody.x-EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-EnmBody.y+EnmBody.radius/1.142);
              if abs(EnmBody.x-EnmBody.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-EnmBody.x+EnmBody.radius/1.4142);
              SetEnmBox
            End;
          End;
         
         {Верх}

         if VeloY<0 then
          Begin
            
            yp:=TTile(Sprite).lines[i].y1-(EnmBody.x-EnmBody.radius/1.4142-TTile(Sprite).lines[i].x1);
            if EnmBody.y-EnmBody.radius/1.142<yp then
            if (EnmBody.X-EnmBody.radius/1.142-velox>TTile(Sprite).lines[i].x2)and(EnmBody.x-EnmBody.radius/1.142-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              InWall:=true;
              if abs(yp-EnmBody.y+EnmBody.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-EnmBody.y+EnmBody.radius/1.142);//+(TTile(Sprite).lines[i].y2-EnmBody.y-EnmBody.radius);
              SetEnmBox
            End;
          End;
        End;


      end;
      if cols=1 then break;

     { if (inwall=false)and(enmsubcount>0) then
      for j := 1 to EnmSubcount do
      case TTile(Sprite).lines[i].lineId of
      1: Begin /// Top
          if VeloY<0 then
          Begin


            if EnmSubbodies[j].y-EnmSubbodies[j].radius<TTile(Sprite).lines[i].y1 then
            if (EnmSubbodies[j].X+EnmSubbodies[j].radius-velox>TTile(Sprite).lines[i].x1)and
            (EnmSubbodies[j].x-EnmSubbodies[j].radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].y1-EnmSubbodies[j].y+EnmSubbodies[j].radius)<abs(Veloy*5)+10 then
            {  y:=y+(TTile(Sprite).lines[i].y1-EnmSubbodies[j].y+EnmSubbodies[j].radius);
              SetEnmBox;
            End;
          End;
        End;
        2: Begin /// Left
          if VeloX<0 then
          Begin

            if EnmSubbodies[j].x-EnmSubbodies[j].radius<TTile(Sprite).lines[i].x1 then
            if (EnmSubbodies[j].y+EnmSubbodies[j].radius-veloy>TTile(Sprite).lines[i].y1)
            and(EnmSubbodies[j].y-EnmSubbodies[j].radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].x1-EnmSubbodies[j].x+EnmSubbodies[j].radius)<abs(VeloX*5)+10 then
       {       x:=x+(TTile(Sprite).lines[i].x1-EnmSubbodies[j].x+EnmSubbodies[j].radius);
              SetEnmBox
            End;
          End;
        End;

        3: Begin /// Down
          if VeloY>0 then
          Begin
            if EnmSubbodies[j].y+EnmSubbodies[j].radius>TTile(Sprite).lines[i].y2 then
            if (EnmSubbodies[j].X+EnmSubbodies[j].radius-velox>TTile(Sprite).lines[i].x1)
            and(EnmSubbodies[j].x-EnmSubbodies[j].radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].y2-EnmSubbodies[j].y-EnmSubbodies[j].radius)<abs(Veloy*5)+10 then
  {            y:=y+(TTile(Sprite).lines[i].y2-EnmSubbodies[j].y-EnmSubbodies[j].radius);
              SetEnmBox
            End;
          End;
        End;
         4: Begin /// Right
          if VeloX>0 then
          Begin
            if EnmSubbodies[j].x+EnmSubbodies[j].radius>TTile(Sprite).lines[i].x2 then
            if (EnmSubbodies[j].y+EnmSubbodies[j].radius-veloy>TTile(Sprite).lines[i].y1)
            and(EnmSubbodies[j].y-EnmSubbodies[j].radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              InWall:=true;
              if abs(TTile(Sprite).lines[i].x2-EnmSubbodies[j].x-EnmSubbodies[j].radius)<abs(VeloX*5)+10 then
   {           x:=x+(TTile(Sprite).lines[i].x2-EnmSubbodies[j].x-EnmSubbodies[j].radius);
              // else showmessage(floattostr(10*Mcount));
              SetEnmBox
            End;
          End;
        End;



      End;   }

    end;


      
   end;

   if (InWall=true)and(AItip<10) then
      AIState:=AIHunt;

end;

procedure TEnemy.SetEnmBox;
var i:byte;
begin
///
     CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + SizeXdiv2*2),
                    Round(Y + SizeXdiv2*2));

  ///   EnmBody.radius:=SizeXdiv2-10;     ///////!!!

     EnmBody.x:=EnmBody.x0+x+SizeXdiv2;
     EnmBody.y:=EnmBody.y0+y+SizeYdiv2;

     if EnmSubCount>0 then
      for I := 1 to EnmSubCount do
      Begin
        EnmSubBodies[i].x:=x+SizeXdiv2+EnmSubRA[1,i]*Cos(Enmsubra[2,i]-palf);
        EnmSubBodies[i].y:=y+SizeYdiv2-EnmSubRA[1,i]*Sin(Enmsubra[2,i]-palf);
      End;
end;

procedure TEnemy.SetFlame(MoveCount:Single);
var tt:integer;
      ppalf,xx11,yy11:real;
begin
 //
 if (Enmhealth>0) then
 Enmticks:=Enmticks+MoveCount;

 if Enmticks>2 then
  if flamecount<>0 then
  for tt := 0 to flamecount-1 do
  Begin
      ppalf:=-palf;
     // if Enmname='enm1' then ppalf:=-ppalf;

      xx11:=(X+SizeXDiv2+EnmFlame[1,tt]*Cos(-EnmFlame[2,tt]+ppalf));
      yy11:=(Y+SizeYDiv2-EnmFlame[1,tt]*Sin(-EnmFlame[2,tt]+ppalf));
      if (Enmname='enm3')or(Enmname='enm4')or(Enmname='enm5')
         or(Enmname='enm42')or(Enmname='enm43')or(Enmname='enm44') then
          FireEff(xx11,yy11, pFire,2)
           else  FireEff(xx11,yy11, pFire,1);

      if hieffs then
      if (Imagename='rock1')then
        FireEff(xx11,yy11, pPlasmid2,3);   {(pFire, plaserpoint,pPlasmid2, pWarer,pShield, psun,
                psun2, pcircle, pTrasser, pExplode, pExplode2, pCol,
                pPlasmid, pHelix);}


      Enmticks:=0;
  End
end;

procedure TEnemy.SetGuns;
var i:byte;
begin
  if GunsCount>0 then
      for I := 1 to Gunscount do
      Begin
        Guns[i].x:=x+SizeXdiv2+Guns[i].r*Cos(Guns[i].a-palf);
        Guns[i].y:=y+SizeYdiv2-Guns[i].r*Sin(Guns[i].a-palf);
      End;
end;

procedure TEnemy.Shoot;
var i,xx,yy:integer; _palf:single;
 needto,superrock:boolean;
 lc:TSprite;
begin


if GunsCount>0 then
 if EnmShootTime>=EnmShootwait then
 Begin
  SetGuns;
  for I := 1 to Gunscount do
  Begin
    _palf:=palf;
    lc:=self;
    needto:=false;


    /////////////////////!!!!!!!!!
    ///
    ///


 XX := trunc(Guns[i].X);
 YY := trunc(Guns[i].Y);
 if (EnmRockets=true)and(i<3)and(AITip<10) then
 Begin
  if pos('Boss',EnmName)>=1 then
      superrock:=true;

  with TEnemy.Create(Engine) do
                 Begin
                     EnmmyobjN:=GetObjNumber('rock2');
                     ImageName := 'rock2';
                     EnmName:='rock2';

                     if superrock then
                       ImageName := 'rock1';

                     palf:=_palf;

                     AItip:=5;
                     enmlowanim:=true;
                     DopSprites[1]:=lc;
                     SizeXdiv2:=round(ImageWidth div 2*ScaleX);
                     SizeYDiv2:=round(ImageHeight div 2*ScaleY);

                     X:=xx- SizeXdiv2;
                     y:=yy- SizeYdiv2;

                     Creator;

                    CollideMethod:= cmRect;
                    DoCollision := True;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    AI;
                    palf:=nextalf;

                    //Mainform.SoundSystem2.Play('shot.wav',false);   //////////// SHOOT
                    Mainform.DXWave.items.Find('shot.wav').Play(false);
                 End;

 End else
   if AITip=10 then
   Begin
    if ShotCount>0 then
       with  TArmoSprite.Create(Engine) do
       begin
         ImageName := 'Shot1';
         needto:=true;
         X := Guns[i].X;
         Y := Guns[i].Y;
         x0:=x;
         y0:=y;
         enm:=true;
         CollideMethod := cmRect;
         DoCollision := True;
         Launcher:=lc;
         rad:=0;
         ArmoType:=aTrasser3;
         Angle:=_palf;

          // cbcbcb
        if i=3 then
        Begin
          Dec(ShotCount)
        End
           else
            Begin
             ArmoType:=aBall;
             ImageName := 'sphere';
             num:=10;
             animcount:=patterncount;
             animspeed:=0.3;
             rad:=10;
             MaxL:=WLMax[1]*3;
             scaleX:=0.5; scaleY:=0.5;
             //scaleX:=1; scaleY:=1;
             //enmweap2:=1+random(7);
          End;

        VeloX:=Wspeed[1]*Cos(-angle);
        VeloY:=-Wspeed[1]*Sin(-angle);
        DrawMode:=1;
        L:=0;
        MaxL:=WLMax[1];

        col:=enmweap;//currentweapon;
        Red:=redw[enmweap];
        Green:=Greenw[enmweap];
        Blue:=Bluew[enmweap];

        ArmoPower:=round(EnmSpower*diff[diffi]);
        if i<3 then
         ArmoPower:=ArmoPower div 3;

        Mainform.DXWave.items.Find('shot.wav').Play(false);
       end;
       if ShotCount<=0 then
       Begin
         AIState:=AIGoTo;
         TargetX:=StartX;
         TargetY:=StartY;
          // cbcbcb
       End;


   End else
    with  TArmoSprite.Create(Engine) do
    begin

      ImageName := 'Shot1';
      needto:=true;
    //  ImageName := 'Box1';
      X := Guns[i].X;
      Y := Guns[i].Y;
      x0:=x;
      y0:=y;
      enm:=true;
      CollideMethod := cmRect;
      DoCollision := True;
      Launcher:=lc;
      rad:=0;

      if (gunscount=2)and(enmstatic=false) then
      Begin
        if i=1 then
          _palf:=_palf-pi/70
            else if i=2 then
              _palf:=_palf+pi/70
             else if i=3 then
                _palf:=_palf-pi/50
                  else if i=4 then
                    _palf:=_palf+pi/50;
          if i=1 then num:=-1;
          if i=2 then num:=1;

          if enmname='enm2' then
          Begin
           _palf:=_palf+num*pi/250;
           MaxL:=WLMax[1]div 2;
          End;

      end;


        Angle:=_palf;

        if (enmname='turrel2') then
         Begin
           angle:=-pi/2;
           Y := Y-100;
         End;

         if (enmname='turrel3') then
         Begin
           angle:=0;
           X := X+100;
         End;

         if (enmname='turrel4') then
         Begin
           angle:=pi/2;
           Y := Y+100;
         End;

          if (enmname='turrel5') then
         Begin
           angle:=pi;
           X := X-100;
         End;

        VeloX:=Wspeed[1]*Cos(-angle);
        VeloY:=-Wspeed[1]*Sin(-angle);
        DrawMode:=1;
        L:=0;
        MaxL:=WLMax[1];

        ArmoPower:=round(EnmSpower*diff[diffi]);
        DrawFx:=fxAdd;

        ArmoType:=aTrasser;
         if (Pos('turrel',enmname)>=1) then
         Begin
             ArmoType:=aTrasser2;
             needto:=false;
         End;

         if enmname='enm1' then
             ArmoType:=aTrasser3;


       { if ArmoType=aTrasser3 then
          rad:=50;}

        col:=enmweap2;//currentweapon;
        Red:=redw[enmweap2];
        Green:=Greenw[enmweap2];
        Blue:=Bluew[enmweap2];
                    //Drawfx:=fxOneColor;
        if ArmoType=aTrasser2 then
        Begin
          ImageName := 'Shotline';
          AnimCount:=patternCount;
          Animspeed:=0.7;
          Animlooped:=false;
          scaleX:=2; scaleY:=2;
          if enmname='turrel' then
           //Mainform.SoundSystem2.Play('laser.wav',false)
           Mainform.DXWave.items.Find('laser.wav').Play(false)
            else
              Mainform.DXWave.items.Find('shot.wav').Play(false);
           // if  Mainform.SoundSystem2.IsPlaying('shot.wav')=false   then
             // Mainform.SoundSystem2.Play('shot.wav',false);   //////////// SHOOT
        End else
          Begin
           scaleX:=0.5; scaleY:=0.5;
             //Mainform.SoundSystem2.Play('laser2.wav',false);
             Mainform.DXWave.items.Find('laser2.wav').Play(false);
          End;


          if enmname='enm6' then
         Begin
             ArmoType:=aBall;
             ImageName := 'sphere';
             num:=5;
             animcount:=patterncount;
             animspeed:=0.3;
             rad:=20;
             MaxL:=WLMax[1]*3;
            // scaleX:=0.8; scaleY:=0.8;
             scaleX:=1; scaleY:=1;
             enmweap2:=1+random(7);

             if DopSprites[1]<>nil then
             Begin
              DopSprites[1].Red:=RedW[enmweap2];
              DopSprites[1].Green:=GreenW[enmweap2];
              DopSprites[1].Blue:=BlueW[enmweap2];
             End;
         End;

         if enmname='enm2' then
          Begin
             //ArmoType:=aBall;
             ArmoType:=aTrasser4;
             rad:=10;
             ImageName := 'sphere';
             scaleX:=0.4; scaleY:=0.4;
            {  animcount:=patterncount;
             animspeed:=0.3;
             rad:=15;
            // MaxL:=WLMax[1]*3;
               }

          End;

        SpriteHeight:=ImageHeight*ScaleY;
        SpriteWidth:=ImageWidth*ScaleX;
      end;
  End;

  if needto then
  
  for I := 1 to Gunscount do
     if hieffs then
     Begin
       trassereff(Guns[i].X,Guns[i].Y,redw[enmweap2],greenw[enmweap2],bluew[enmweap2],
        1, 1,pfire);
     End;


  EnmShootTime:=0;
 End;
end;

function TEnemy.testway: Boolean;
var x2,y2,i:integer;
xx,yy,a1:real;
begin

    result:=false;

    if (targetdest>EnmBody.radius)and(health>0) then
    if (targetDest<1600)or(AITip=10) then
    
    Begin

      a1:=0;

      result:=true;

      if abs(targety-EnmBody.y)>=0.5 then
        a1:=pi+arctan((targetX-EnmBody.X)/(targety-EnmBody.y));

         if (targety-EnmBody.y)>0 then
            nextalf:=-pi/2-a1
             else  nextalf:=pi/2-a1;

         if crazy then
              nextalf:=-nextalf;

      for I :=1 to (TargetDest) div 100 do
      Begin
        xx:=EnmBody.X+ i/TargetDest*(targetX-EnmBody.x)*100;
        yy:=EnmBody.Y+ i/TargetDest*(targetY-EnmBody.Y)*100;
        x2:=trunc(xx/100);
        y2:=trunc(yy/100);

        if x2>mapsizex then
          x2:=mapsizex;
        if y2>mapsizex then
          y2:=mapsizey;
        if x2<0 then
          x2:=0;
        if y2<0 then
          y2:=0;

        if (AIMap[x2,y2]=true)or
           ((AIDynMap[x2,y2]=true) and
              ((x2<zx1)or(x2>zx2)
                or(y2>zy2)or(y2<zy1))) then
        Begin
          If TESTAI then TrasserEff(x2*100+50,y2*100+50,0,200,0,2,1,pTrasser);
          result:=false;
          break;
        End; {else
          if (AIDynMap[x2,y2]=true)then
          if  then
           Begin
            result:=false;
            If TESTAI then TrasserEff(x2*100+50,y2*100+50,0,200,0,2,1,pTrasser);
            break;
           End;}
          If TESTAI then FireEff(x2*100+50,y2*100+50,pfire,1);
      End;
    end;

end;

procedure TEnemy.Turn;
var step:real;
begin

  if nextalf<0 then
      nextalf:=nextalf+2*pi
       else
        if nextalf>2*pi then
          nextalf:=nextalf-2*pi;

 if abs(palf-nextalf)>abs(palf-nextalf-2*pi) then
    nextalf:=nextalf+2*pi;
  if abs(palf-nextalf)>abs(palf-nextalf+2*pi) then
    nextalf:=nextalf-2*pi;

   step:=0.01*enmTurnSpeed*MCount;
  // if health<=0 then   step:=step/2;


   if palf<nextalf-step then
    palf:=palf+step
     else
       if palf>nextalf+step then
        palf:=palf-step
         else Begin
            palf:=nextalf;
           //  nextalf:=random*2*pi; ////!!!!! Убрать
         End;

    EnmLooking:=false;
        if (abs(palf-nextalf)<pi/8)and(Aistate=Aihunt) then
            EnmLooking:=true;


    if palf<0 then
      palf:=palf+2*pi;
    if palf>2*pi then
      palf:=palf-2*pi;

   if (ultralow)or(EnmLowAnim) then
   Begin
      angle:=palf;

     { if Enmname='enm1' then
       angle:=palf;}
     //angle:=pi*palf/180;
   End
   else
   Begin
      animpos:=palf/pi*Animcount/2;
      if Enmname='enm1' then
        animpos:=Animcount-palf/pi*Animcount/2;
   End;
end;

procedure TMainForm.DeviceInitialize(Sender: TObject; var Success: boolean);
begin
     // load all images from ASDb

      VirtualW:=1600;
      VirtualH:=round(1600*Device.Height/Device.Width);

      normWScale:=0.84;//1.0;

      ResolutionScaleX:=Device.Width/VirtualW;
      ResolutionScaleY:=Device.Height/VirtualH;
      ResolutionScaleY2:=Device.Height/1200;              // vcv

      DeltaX:=round((Device.Height/ResolutionScaleY-900)/2);
     // MGx:=trunc(Device.Width*0.2);
     // MGy:=trunc(Device.Height*0.1);

     // normWScale:=0.84*(ResolutionScaleY2/ResolutionScaleY+1)/2;

     GetNormW;

      deltaY:=trunc(VirtualH*(resolutionScaleY-resolutionScaleY2)/2);

   InitSuccess:=Success;
end;



procedure TMainForm.TakeCapsule;
var i,j:integer;
begin

if TakenCapsule<>nil then
 if TCapsule(TakenCapsule).tip<3 then
  Begin
   j:=1;
    for I := 1 to 6 do
    if TakenCapsule.InCapsule[i]<>nil then
     Begin
      InSpace[j]:=TakenCapsule.InCapsule[i];
      inc(j);
     End;
   TakenCapsule.Dead;
   inventory:=true;
   DXWave.Items.Find('plasmid.wav').Play(false); ///  1308
  End else

  if TCapsule(TakenCapsule).tip=5 then
  Begin
    if TCapsule(TakenCapsule).IsDone=false then
    Begin
      TCapsule(TakenCapsule).IsDone:=true;
      Mainform.DXWave.items.Find('message.wav').Play(false);
      TCapsule(TakenCapsule).ImageName:= 'mayak_off';
      havenewDLG:=true;
      if showDlg=false then
        if DialTime>64 then DialTime:=64;
      for j:=0 to TCapsule(TakenCapsule).mcount do
      for i:=1 to 31 do
        if dialtray[i]=0 then
        Begin
          dialtray[i]:=TCapsule(TakenCapsule).col+1+j;
          Mainform.AddDialToLog(TCapsule(TakenCapsule).col+j);
          Break;
        End;
    end
  End else
    ///!!!
    if TCapsule(TakenCapsule).keeping=false then
    Begin
       if keepitm=false then
       Begin
        TCapsule(TakenCapsule).keeping:=true;
        TCapsule(TakenCapsule).keep2:=false;
        TCapsule(TakenCapsule).prekeep:=true;
        TCapsule(TakenCapsule).DrawMode:=1;
        TCapsule(TakenCapsule).z:=-1;
        keepsprite:=TCapsule(TakenCapsule);
        keepitm:=true;
        mdown[mb1]:=false;
        mdown[mb4]:=false;
        DXWave.Items.Find('plasmid.wav').Play(false);   //1308

        if (TCapsule(TakenCapsule).tip=3)or(TCapsule(TakenCapsule).tip=8) then
        Begin
          TPlayer(_player).keepbox:=TPlayer(_player).kb1;
        End
         else
           Begin
            TPlayer(_player).keepbox:=TPlayer(_player).kb2;
           End;

       End;
    End else
    Begin
      DXWave.Items.Find('use.wav').Play(false);  //1308
      keepsprite:=nil;
      keepitm:=false;
      TCapsule(TakenCapsule).keeping:=false;
      TCapsule(TakenCapsule).DrawMode:=0;
      TCapsule(TakenCapsule).CollideRect := Rect(Round(TCapsule(TakenCapsule).X),
           Round(TCapsule(TakenCapsule).Y),Round(TCapsule(TakenCapsule).X )+ 100,
           Round(TCapsule(TakenCapsule).Y )+ 100);
      TakenCapsule.X:=TakenCapsule.X-TCapsule(TakenCapsule).SizeXd2;
      TakenCapsule.Y:=TakenCapsule.Y-TCapsule(TakenCapsule).Sizeyd2;
      TCapsule(TakenCapsule).Impulse1.ImpPower:=3;
      if TCapsule(TakenCapsule).tip=4 then
        TCapsule(TakenCapsule).Impulse1.ImpPower:=6;
      TCapsule(TakenCapsule).Impulse1.ImpX:=Cos(TPlayer(_player).PAlf);
      TCapsule(TakenCapsule).Impulse1.Impy:=-Sin(TPlayer(_player).PAlf);
      canshoot:=false;
    End;


end;

procedure TMainForm.TakeColor;
begin
  if TakenCol<>nil then
  Begin
    inventory2:=true;
    DXWave.Items.Find('plasmid.wav').Play(false);  ///1308
    needcolor:=0;
    newcolorcount:=TEffectSprite(TakenCol).act;
    newcolor:=TEffectSprite(TakenCol).col;
    InMouseCol:=0;
    Hud2[7].xmin:=trunc(((TakenCol.x)-Engine.WorldX)*Engine.worldScaleX/Device.Width*1600);
    Hud2[7].ymin:=trunc(((TakenCol.y)-Engine.WorldY)*Engine.worldScaley/Device.height*1200);
    //showmessage(inttostr(Hud2[7].xmin)+' '+inttostr(Hud2[7].ymin));
  End;
end;

procedure TMainForm.TestVolume(vol: integer);
begin


   //DXWave.Items.Find('test.wav').Volume:=-10000+Vol*100;
   if Vol<>0 then
        DXWave.Items.Find('test.wav').Volume:=-3000+Vol*30
          else DXWave.Items.Find('test.wav').Volume:=-10000;

   if SoundVolume<>0 then
        DXWave.Items.Find('mousein.wav').Volume:=-3000+SoundVolume*30
          else DXWave.Items.Find('mousein.wav').Volume:=-10000;

   //DXWave.Items.Find('mousein.wav').Volume:=-10000+SoundVolume*100;
   DXWave.items.restore;
   DXWave.Items.Find('test.wav').Play(false);

end;


procedure TMainForm.TimerTimer(Sender: TObject);
begin
     // render the scene
     {Device.Render(RGB(55, 140, 210), True);}
     MCount:=Timer.Delta;
     ingame:=true;

     // MenuEngine.VisibleArea:= Rect(0,0,
       //      round((Device.Width)/MenuEngine.WorldScaleX), round((Device.Height)/MenuEngine.WorldScaleY));



     if (inventory)or(inventory2)or(inventory3)or(Inmenu)
     or(StopMenu)or(HintMenu)or(MenuN=7)or(MapLookmenu) then
      InGame:=false;

     ///// МАСШТАБЫ
      Engine.WorldScaleX:=GameScaleX*ResolutionScaleX;//*CamScale;
      Engine.WorldScaleY:=GameScaleY*ResolutionScaleY;//*CamScale;
      Engine.VisibleArea:= Rect({round(-512/Engine.WorldScaleX), round(-512/Engine.WorldScaleY)}0,0,
      //round((Device.Width)/resolutionScaleX), round((Device.Height)/resolutionScaleY));
      round((Device.Width)/Engine.WorldScaleX), round((Device.Height)/Engine.WorldScaleY));

      stopgame:=false;
        if (inventory)or(inventory2)or(inventory3)or (hintmenu)or(MapLookmenu) then
         stopgame:=true;

        if (inmenu) then paused:=false;
        

      if (stopgame)and((Hudt<100)or(Hudt2<100)or(Hudt3<100))
          and(hintmenu=false)and(MapLookMenu=false)then
      Begin
       ZoomIn;
      End else
      Begin
         if stopgame=false then
          if minimap then
          Begin
            Zoomout;
          End
            else
            if (GamescaleX<>normWScale) then
              ZoomMiddle;
      End;

      if (Timer.Delta>0) then
      Begin

      PostFilter3;
      Device.Render(RGB(0,0,0), True);

       if (Paused=false)and(Hudt3<100)and(Hudt<100)and
          (Hudt2<100)and(stopmenu=false)and(ingame)and(menun<>7)
          and(MapLookMenu=false) then

            GameProcess(Timer.Delta);
      // do calculations while Direct3D is still rendering
      Timer.Process();

     { Fonts[1].Scale:=resolutionscaleX*0.7;
      if developer then
      Fonts[1].TextOut('Developer mode' ,
        700 *ResolutionScaleX,(10)*ResolutionScaleY, cRGB1(250, 250, 255));
      Fonts[1].TextOut('Alpha version' ,
        1150 *ResolutionScaleX,(10)*ResolutionScaleY, cRGB1(250, 250, 255));}


      Device.Flip();
      End;
      // flip back buffers



        if nextmenu=-1 then
          close;


   
/// MUSIC
///
if (MusVolume>0) then
Begin

 if (inmenu=false) then
 Begin

  {if  DXMusic.Items.Count>0 then
  if DXMusic.Items[0].PlayCount<1 then
  Begin
     DXMusic.Items[0].Play(false);
      //DXMusic.Items[0].Looped:=true;
  End; }
   if (SoundSystem.IsPlaying(Currenttrack)=false)and(GameOver=false) then
   Begin
    SoundSystem.Play(currenttrack,false);
    SoundSystem.SetVolume(currenttrack,(MusVolume*TrackVol div 100));
   End;

  //if MenuSoundsystem.IsPlaying(0) then
    MenuSoundSystem.StopAll;

    {if  DXMenuMusic.Items.Count>0 then
        DXMenuMusic.Items[0].Stop;}

 End
  else Begin
      //if DXMusic.Items[0].PlayCount>0  then
      //Begin
        //spos:=DXMusic.Items[0]. //SoundSystem1.GetSoundPos(0);

  //   if  DXMenuMusic.Items.Count>0 then
      if (menun<>4)and(menun<>15)and(menun<>10)and(menun<>16)and(menun<>18) then
      Begin
         
         if(MenuSoundSystem.IsPlaying(0)=false) then
         Begin
          MenuSoundSystem.Play(0,true);
          MenuSoundSystem.SetVolume(0,MusVolume);
         End;
        {if DXMenuMusic.Items[0].PlayCount<1 then
         Begin
          DXMenuMusic.Items[0].Play(false);
         End; }
      End else
       {if  DXMenuMusic.Items.Count>0 then
        DXMenuMusic.Items[0].Stop;}
        if (menun<>16)and(menun<>18) then
        MenuSoundSystem.Stopall
         else
           MenuSoundSystem.Stop(0);

      if (nextmenu<>16)and(menun<>18) then
       {if  DXMusic.Items.Count>0 then
        DXMusic.Items[0].Stop;}
         SoundSystem.Stopall;

      //End;
  End;
End;

end;

function TMainForm.Uncoding(var s: Tstringlist): Tstringlist;
var
    i,j,k,n:integer;
    a,c:char;
begin
// s:=TstringList.Create;
 Result:=TstringList.Create;
// n:=5;

 for i:=0 to s.Count-1 do Begin
   result.Add('');
   n:=0;
    for j:=1 to length(s[i]) do begin
      inc(n);
      if n>=5 then n:=0;
      c:=s[i][j];
      k:=ord(c)+n;
      a:=chr(k);
      result[i]:=result[i]+a;
    end;
   // showmessage(result[i])
 end;

end;

procedure TMainForm.UnLoadIntro;
begin
 Images2.RemoveAll;
 MenuSoundsystem.StopAll;
 if MenuSoundsystem.Count>1 then
 Begin
  MenuSoundsystem.UnLoad;
  MenuSoundsystem.AddFromFile('Data\Music\'+MenuTheme+'.mp3');
  //SetMusVolumes;
 End;

// DXMusic.Items.Clear;
end;

procedure TMainForm.UnLoadPreviews;
begin
  //MapsList.Clear;
  MapPreviews.RemoveAll;
end;

procedure TMainForm.UnpackExtras;
var i:integer;
    S:TstringList;
begin
if cheater=false then
Begin

  for i:=1 to 3 do
    extras[i]:=false;

try
  S:=TStringlist.Create;
  S.LoadFromFile('Data\Locs\Smaps.loc');

  for i:=0 to 2 do
    ExtrM[i+1]:=S[i];
                                 // bcvbcb
  if level>=levels.Count then
  Begin
   extras[1]:=true;
   CopyFile('Data\Locs\Smap1.loc',Pchar(Dir0+'\Usermaps\'+s[0]),false);
   CopyFile('Data\Locs\1.bm_',Pchar(Dir0+'\Usermaps\Previews\'+s[0]+'.bmp'),false);
  // Showmessage(Pchar(Dir0+'\'+s[0]));
  End;

  if Allscore>=4500  then
  Begin
   extras[2]:=true;
   CopyFile('Data\Locs\Smap2.loc',Pchar(Dir0+'\Usermaps\'+s[1]),false);
   CopyFile('Data\Locs\2.bm_',Pchar(Dir0+'\Usermaps\Previews\'+s[1]+'.bmp'),false);
  End;

  if medals[5]>=1 then
  Begin
   extras[3]:=true;
   CopyFile('Data\Locs\Smap3.loc',Pchar(Dir0+'\Usermaps\'+s[2]),false);
   CopyFile('Data\Locs\3.bm_',Pchar(Dir0+'\Usermaps\Previews\'+s[2]+'.bmp'),false);
  End;

  S.Destroy;
except
end;


End;
  
end;

function TMainForm.znak(i: real): integer;
begin
  if i=0 then Result:=0;
  if i>0 then Result:=1;
  if i<0 then Result:=-1;
end;

procedure TMainForm.ZoomIn;
begin
  GameScaleX:=GameScaleX+0.05*Lagcount;
  if GameScaleX>maxWscale then
    GameScaleX:=maxWScale;
  GameScaleY:=GameScaleX;
end;

procedure TMainForm.ZoomMiddle;
var step:real;
begin
  step:=0.035*Lagcount;
  if (GameScaleX<normWscale-step) then
    GameScaleX:=GameScaleX+Step
      else
        if (GameScaleX>normWscale+step) then
          GameScaleX:=GameScaleX-Step
          else
            GameScaleX:=normWScale;

  GameScaleY:=GameScaleX;
end;

procedure TMainForm.ZoomOut;
begin
  GameScaleX:=GameScaleX-0.02*Lagcount;
  if GameScaleX<minWscale*normWscale then
    GameScaleX:=minWScale*normWscale;
  GameScaleY:=GameScaleX;
end;

procedure TMainForm.FadeIn(Alfa1: integer);
var c:TColor;
begin
////
// c:=cRGB1(color,color,color,Alfa);
 c:=cRGB1(0,0,0,Alfa1);
 //c:=cRGB1(0,0,0,255);
 if alfa1>0 then
 MyCanvas.FillRect(0,0,Device.Width,Device.Height,c,fxBlend);
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if Gameloaded=false then
   Begin
     LoadPic;
   End;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   MonitorFrequency, I: Integer;
   DC: THandle;
   Img1:TAsphyreImage;
   point:Tpoint;
begin
  GameLoaded:=false;

  Caption:='PLASMIA v. 1.1';

  if fileexists('Data\firststart.log') then
  Begin

     level:=0;

     Screen.Cursor := crNone;

     Dir0:=GetCurrentDir;

     InitSuccess:=true;

     LoadSettings;

     // initialize Asphyre device
     if (not Device.Initialize()) then
     begin
          MessageDlg('Unable to initialize Asphyre device!', mtError, [mbOk], 0);
          Close();
          Exit;
     end;
  End
  else
  Begin
    ///// ПЕРВЫЙ ЗАПУСК!!!!!!!!!!!!

   // setcurrentdir(getcurrentdir+'\Loader\');
    winexec('Config.exe',sw_restore);

    halt;
  End;



   
end;

procedure TMainForm.DeviceRender(Sender: TObject);
var I,j,x1,y1:Integer;
    dlt:real;
begin
     Keyboard1.Update;
     LagCount:=Timer.Delta;


if (inMenu=false) then
Begin

  BackGround;

  TakenCapsule:=nil;
  PushTile:=nil;

  if inventory2=false then
    TakenCol:=nil;
  
  CursorOnCapsule:=false;
  CursorOnBox:=false;
  TakeBox:=nil;

  //if (minimap=false) then
    dlt:=abs(Timer.Delta);
    //  else dlt:=0;

  if MapLookMenu=false then
  for I := 0 to mapsizeX do
     for J := 0 to mapsizeY do
     Begin
        AIDynMap[i,j]:=AIDynSubMap[i,j];
        AIDynSubMap[I,J]:=false;
        Larr[i,j]:=0;
     End;

  if OnlyLoaded then
  Begin
    dlt:=0;
    OnlyLoaded:=false;
  End;

  if Radar then
  Begin
    MiniMapObjCount:=0;
  End;

   Scannow:=false;
 //  DrawPhysLines; {!!!}
   ShowChoosed:=false;

  if (Paused=false)and(Hudt<100)and(Hudt2<100)
     and(Hudt3<100)and(stopmenu=false)and(leveldone=false)
     and(hintmenu=false)and(MenuN<>7)and(MapLookMenu=false)then
    Engine.Move(dlt);


 { for I := trunc(_Player.X-500)div 100 to trunc(_Player.X+700)div 100 do
     for J := trunc(_Player.Y-400)div 100  to trunc(_Player.Y+500)div 10 do
       if (i>0)and(i<mapsizeX)and(j>0)and(j<mapsizeY) then }


  
  Engine.Dead;

  if MapLookT<100 then
  Engine.Draw;
  PostFilter;

  DrawHud;

  PostFilter2;
End else
Begin
    Background;
    {MenuEngine.Move(Timer.Delta);
    MenuEngine.Dead;
    MenuEngine.Draw;}
End;

if not(paused) then
  MouseUpdate;
  
  DrawMenu;

  if (Developer) then
   if (cony>0)or(console) then
    ShowDevConsole;

  if (Developer) then
   if DrawDop then
      DrawPhysLines;

end;

procedure TMainForm.DoneMapLevel;
begin
                leveldone:=false;
               { saveprofileprogress;
                loadprofileprogress;}
                if (percento[5]>MapStat.MScore) then
                  saveStatistic;

                gameover:=false;
                menun:=2;
                nextmenu:=2;
                LoadPreviews;
                inmenu:=true;
                GoBlack:=false;
end;

procedure TMainForm.DopHudDraw;
var _x,_y,_scale,_dop2,_sc,_dop,_h,_w:real;
    imgname,imgname2,tx:string;
    _color:TColor4;
    i,j,k,l:integer;
begin

    /////// Выбранный цвет
    if (hud_hotzones[1].no<0)or(hud_hotzones[1].no>5) then
    showmessage(inttostr(hud_hotzones[1].no)+' - Error in hotZones array');

    imgname:='Hud2_6';
    if (inventory=true) then
      if (Hud_CurrentZone=1) then
       imgname:='Hud2_9';

    _scale:=Hud[hud_hotzones[1].no].cscale;
    _w:=(HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=(HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);
    _x:=(Hud[hud_hotzones[1].no].cx+hud_hotzones[1].x*_scale*ResolutionScaleX);
    _y:=(Hud[hud_hotzones[1].no].cy+hud_hotzones[1].y*_scale*ResolutionScaleY);
    _dop2:=(35-weapons[currentweapon].Count)/35;
    _sc:=_scale;

    _w:=round(HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=round(HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

    if Hudt=0 then Begin
      _sc:=_scale*(HudImages.Image[imgname].VisibleSize.x)/(HudImages.Image[imgname+'small'].VisibleSize.x);
      imgname:=imgname+'small';
    End;

    HudCrgb(Redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],1,2,Timer.Delta);

    _dop:=((_dop2)*HudImages.Image[imgname].VisibleSize.y*_sc*resolutionscaleY);
    _color:=cRGB4(round(hudCred[1]),round(HudCGreen[1]),round(HudCBlue[1]),55);

    MyCanvas.DrawStretch(HudImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    _color,fxBlend);


    _color:=cRGB4(round(hudCred[1]),round(HudCGreen[1]),round(HudCBlue[1]),205);
    MyCanvas.DrawPortion(HudImages.Image[imgname],0, _x-_w / 2,
      _y-(_h / 2)+_dop,
      0, 0,HudImages.Image[imgname].VisibleSize.x,
      HudImages.Image[imgname].VisibleSize.y-round((_dop2)*HudImages.Image[imgname].VisibleSize.y),
      _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
      _color,fxBlend);

   if hieffs then
   Begin
    if colcharge then
    begin
     if (hudt2<=0)and(hudt3<=0)and(hudt<=0) then
         MyCanvas.DrawPortion(HudImages.Image[imgname],0, _x-_w / 2,
      _y-(_h / 2)+_dop,
      0, 0,HudImages.Image[imgname].VisibleSize.x,
      HudImages.Image[imgname].VisibleSize.y-round((_dop2)*HudImages.Image[imgname].VisibleSize.y),
      _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
       crgb4(255,255,255,20+trunc(20*Sin(leveltime*10))),fxAdd);

      colcharge:=false;
    end;

     if rainbow then
       MyCanvas.DrawStretch(HudImages.Image[imgname],0, round(_x-_w/2),
        round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
         colEffHud,fxBlend);

   End;



   if (inventory=true) then
      if (Hud_CurrentZone=1) then
         Begin
        tx:=IntToStr(weapons[currentweapon].Count);
        Fonts[2].Scale:=ResolutionScaleY*1.1;
        Fonts[2].TextOut(tx, round(_x- Fonts[2].Textwidth(tx)/2),
             round(_y-Fonts[2].TextHeight(tx)/2),cRGB1(255,255,255,200));
      End;

   ///// Альтернативные цвета
   ///  0..4

   case altweaponscount of
    1,2:k:=2;
    3,4:k:=1;
    5:k:=0;
   end;

   if altweaponscount mod 2=0 then l:=1
    else l:=0;


   for I :=2-altweaponscount div 2+l  to 2+altweaponscount div 2 do
   Begin
    imgname:='Hud2_7';
    _scale:=Hud[hud_hotzones[2+i].no].cscale;
    _w:=({hud_hotzones[1].w}HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=({hud_hotzones[1].h}HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);
    _x:=(Hud[hud_hotzones[2+i].no].cx+hud_hotzones[2+i].x*_scale*ResolutionScaleX);
    _y:=(Hud[hud_hotzones[2+i].no].cy+hud_hotzones[2+i].y*_scale*ResolutionScaleY);

    _sc:=_scale;

    _w:=round(HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=round(HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

    if Hudt=0 then Begin
      _sc:=_scale*(HudImages.Image[imgname].VisibleSize.x)/(HudImages.Image[imgname+'small'].VisibleSize.x);
      imgname:=imgname+'small';
    End;



    j:=i-1;
    if j<=0 then
      j:=AltWeaponsCount+j;

    _dop2:=(35-weapons[AltWeapons[j]].Count)/35;
    _dop:=((_dop2)*HudImages.Image[imgname].VisibleSize.y*_sc*resolutionscaleY);

    _color:=cRGB4(redw[AltWeapons[j]],Greenw[AltWeapons[j]],Bluew[AltWeapons[j]],75);

    if (inventory=true) then
      if (Hud_CurrentZone=i+2) then
    _color:=cRGB4(redw[AltWeapons[j]],Greenw[AltWeapons[j]],Bluew[AltWeapons[j]],175);

    MyCanvas.DrawStretch(HudImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    _color,fxBlend);

    _color:=cRGB4(redw[AltWeapons[j]],Greenw[AltWeapons[j]],Bluew[AltWeapons[j]],255);

    if (inventory=true) then
      if (Hud_CurrentZone=i+2) then
       imgname:='Hud2_8';

    MyCanvas.DrawPortion(HudImages.Image[imgname],0, _x-_w / 2,
      _y-(_h / 2)+_dop,
      0, 0,HudImages.Image[imgname].VisibleSize.x,
      HudImages.Image[imgname].VisibleSize.y-round((_dop2)*HudImages.Image[imgname].VisibleSize.y),
      _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
      _color,fxBlend);

    if (inventory=true) then
      if (Hud_CurrentZone=i+2) then
      Begin
        tx:=inttostr(weapons[AltWeapons[j]].Count);
        Fonts[1].Scale:=ResolutionScaleY;
        Fonts[1].TextOut(tx, round(_x- Fonts[1].Textwidth(tx)/2),
             round(_y-Fonts[1].TextHeight(tx)/2),cRGB1(255,255,255,200));
      End;

   End;


   /// Здесь: предметы Inventory

   for i:=1 to 4 do
   if items[i]<>nil then
   Begin

    imgname:='Box1';

    imgname2:=items[i].ItemImageName;

    if hudt<=0 then
      imgname2:=imgname2+'sm';

    if ItemImages.Find(imgname2)>-1 then
      imgname:=imgname2;

    imgname2:='Hud3_2';
      if ((inventory=true)and(Hud_CurrentZone=10+i))or(items[i].ItemInUse=true) then
       imgname2:='Hud3_3';

    _scale:=Hud[hud_hotzones[10+i].no].cscale;
    _x:=(Hud[hud_hotzones[10+i].no].cx+hud_hotzones[10+i].x*_scale*ResolutionScaleX);
    _y:=(Hud[hud_hotzones[10+i].no].cy+hud_hotzones[10+i].y*_scale*ResolutionScaleY);
    _sc:=_scale;


    if Hudt<=0 then Begin
      _sc:=_scale*(HudImages.Image[imgname2].VisibleSize.x)/(HudImages.Image[imgname2+'small'].VisibleSize.x);
      imgname2:=imgname2+'small';
    End;

    _w:=(HudImages.Image[imgname2].VisibleSize.x*ResolutionScaleX*_sc);
    _h:=(HudImages.Image[imgname2].VisibleSize.y*ResolutionScaleY*_sc);

    _dop2:=((items[i].ItemTimeUse-items[i].ItemCurrentTime)/items[i].ItemTimeUse);
    _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*resolutionscaleY*_sc);

    j:=215;
    if Items[i].ItemInUse then
      j:=245;

    _color:=cRGB4(RedW[items[i].ItemColor],GreenW[items[i].ItemColor],BlueW[items[i].ItemColor],j);

    MyCanvas.DrawPortion(HudImages.Image[imgname2],0, (_x-_w / 2),
      (_y-(_h / 2)+_dop), 0, 0, HudImages.Image[imgname2].VisibleSize.x,

      round((1-_dop2)*HudImages.Image[imgname2].VisibleSize.y),
      (_sc*resolutionscaleX),(_sc*resolutionscaleY),false,false,true,
      _color,fxBlend);
                                          
    if hieffs then
    if (j=245)and (hudt<=0)and (hudt2<=0)and (hudt3<=0) then
      MyCanvas.DrawPortion(HudImages.Image[imgname2],0, (_x-_w / 2),
      (_y-(_h / 2)+_dop), 0, 0, HudImages.Image[imgname2].VisibleSize.x,
      round((1-_dop2)*HudImages.Image[imgname2].VisibleSize.y),
      (_sc*resolutionscaleX),(_sc*resolutionscaleY),false,false,true,
      crgb4(255,255,255,20+trunc(20*Sin(leveltime*10))),fxAdd);
                                                               
   // _w:=round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
   // _h:=round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);
    _w:=_w*0.7;
    _h:=_h*0.7;

    MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    clWhite4,fxBlend);

   End;

   //// Bonuses
    for i:=1 to 3 do
   if Bonuses[i]<>nil then
   Begin

    imgname:='Box1';
    imgname2:=Bonuses[i].BonusImageName;
     if hudt<=0 then
        imgname2:=imgname2+'sm';
    if ItemImages.Find(imgname2)<>-1 then
      imgname:=imgname2;//Bonuses[i].BonusImageName;

    imgname2:='Hud4_2';
    if (inventory=true) then
      if (Hud_CurrentZone=7+i) then
       imgname2:='Hud4_3';

    _scale:=Hud[hud_hotzones[7+i].no].cscale;
    _x:=(Hud[hud_hotzones[7+i].no].cx+hud_hotzones[7+i].x*_scale*ResolutionScaleX);
    _y:=(Hud[hud_hotzones[7+i].no].cy+hud_hotzones[7+i].y*_scale*ResolutionScaleY);
    _sc:=_scale;

    {if Hudt=0 then Begin
      _sc:=_scale*(Images.Image[imgname].VisibleSize.x)/(Images.Image[imgname+'small'].VisibleSize.x);
      imgname:=imgname+'small';
    End;}

    _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

    _dop2:=1;
    _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

    j:=200;
    _color:=cRGB4(RedW[Bonuses[i].BonusColor],GreenW[Bonuses[i].BonusColor],BlueW[Bonuses[i].BonusColor],j);


    MyCanvas.DrawStretch(HudImages.Image[imgname2],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    _color,fxBlend);

    _w:=_w*0.7;//round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=_h*0.7;//round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

    MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    clWhite4,fxBlend);
   End;

   //// Items вне инвентаря
   for i:=1 to 6 do
   if inSpace[i]<>nil then

    if InSpace[i] is TItem then
      Begin
        imgname:='Box1';

        if ItemImages.Find(TItem(inSpace[i]).ItemImageName)<>-1 then
          imgname:=TItem(inSpace[i]).ItemImageName;

        imgname2:='Hud3_2';
        if (inventory=true) then
          if (Hud_CurrentZone=16+i) then
            imgname2:='Hud3_3';

        _scale:=Hud[hud_hotzones[16+i].no].cscale;
        _x:=(Hud[hud_hotzones[16+i].no].cx+hud_hotzones[16+i].x*_scale*ResolutionScaleX);
        _y:=(Hud[hud_hotzones[16+i].no].cy+hud_hotzones[16+i].y*_scale*ResolutionScaleY);
        _sc:=_scale;

        _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

        _dop2:=(Titem(inspace[i]).ItemTimeUse-Titem(InSpace[i]).ItemCurrentTime)/Titem(inSpace[i]).ItemTimeUse;
        _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

        _color:=cRGB4(RedW[Titem(inSpace[i]).ItemColor],
        GreenW[Titem(inSpace[i]).ItemColor],BlueW[Titem(inSpace[i]).ItemColor],205);

        MyCanvas.DrawPortion(HudImages.Image[imgname2],0, _x-_w / 2,
            _y-(_h / 2)+_dop, 0, 0, HudImages.Image[imgname2].VisibleSize.x,
            HudImages.Image[imgname2].VisibleSize.y-round((_dop2)*HudImages.Image[imgname2].VisibleSize.y),
            _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
            _color,fxBlend);

        _w:=0.7*_w;///round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=0.7*_h;///round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

        MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
          round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
          clWhite4,fxBlend);
      end
      else
      if InSpace[i] is TBonus then
      Begin
        imgname:='Box1';
        if ItemImages.Find(TBonus(inSpace[i]).BonusImageName)<>-1 then
          imgname:=TBonus(inSpace[i]).BonusImageName;

        imgname2:='Hud4_2';
        if (inventory=true) then
          if (Hud_CurrentZone=16+i) then
            imgname2:='Hud4_3';

        _scale:=Hud[hud_hotzones[16+i].no].cscale;
        _x:=(Hud[hud_hotzones[16+i].no].cx+hud_hotzones[16+i].x*_scale*ResolutionScaleX);
        _y:=(Hud[hud_hotzones[16+i].no].cy+hud_hotzones[16+i].y*_scale*ResolutionScaleY);
        _sc:=_scale;

        _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

        //_dop2:=100;
        _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

        _color:=cRGB4(RedW[TBonus(inSpace[i]).BonusColor],
        GreenW[TBonus(inSpace[i]).BonusColor],BlueW[TBonus(inSpace[i]).BonusColor],205);

        {MyCanvas.DrawPortion(Images.Image[imgname2],0, _x-_w / 2,
            _y-(_h / 2)+_dop, 0, 0, Images.Image[imgname2].VisibleSize.x,
            Images.Image[imgname2].VisibleSize.y-round((_dop2)*Images.Image[imgname2].VisibleSize.y),
            _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
            _color,fxBlend);}
         MyCanvas.DrawStretch(HudImages.Image[imgname2],0, round(_x-_w/2),
            round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
            _color,fxBlend);

        _w:=0.7*_w;//round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=0.7*_h;//round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

        MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
          round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
          clWhite4,fxBlend);

    End;


end;

procedure TMainForm.DrawPhysLines;
var
 i,j:integer;
 x1,y1,x2,y2: integer;
 angle:real;
 obj:TObject;
Begin


 for I :=0 to mapsizex do
  for J :=0 to mapsizey do
  Begin
    With MyCanvas Do
    Begin
       x1:=trunc((i*100-Engine.WorldX)*Engine.WorldScaleX);
       x2:=trunc(100*Engine.WorldScaleX);
       y1:=trunc((j*100-Engine.WorldY)*Engine.WorldScaleY)+1;
       y2:=trunc(100*Engine.WorldScaleY)+1;

       if (x1>-x2)and(x2<Device.Width)and(y1>-y2)and(y2<Device.Height)then
       Begin
        if AIMAP[i,j]=true then
          MyCanvas.FrameRect(x1,y1,x2,y2,crgb1(0,200,200,50),fxNone);
        if AIDynMAP[i,j]=true then
          MyCanvas.FrameRect(x1+10,y1+10,x2-20,y2-20,crgb1(200,0,0,150),fxNone);  
       End;

    End;
  End;



 for i := 0 to Engine.Count - 1 do
  Begin
    Obj:=Engine.Items[i];

    if Obj<>nil then
     Begin

       if (Obj is TCapsule) then
       Begin
         With MyCanvas Do
         Begin

          x1:=round((TCapsule(Obj).Capsuleshape.PosX-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TCapsule(Obj).Capsuleshape.PosY-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          //x2:=round((TCapsule(Obj).Capsuleshape.X[2]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          //y2:=round((TCapsule(Obj).capsuleshape.Y[2]-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=trunc(70*Engine.WorldScaleX/2);
          //Rectangle(x1,y1,x2-x1,y2-y1,Clred,Clnone,FxNone);
          Circle(x1,y1,x2,clred,fxNone);
        End;
       End;

       if (Obj is TMina) then
       Begin
         With MyCanvas Do
         Begin
          x1:=round((TMina(Obj).Minashape.PosX-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TMina(Obj).Minashape.PosY-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=trunc(70*Engine.WorldScaleX/2);
          Circle(x1,y1,x2,clred,fxNone);
        End;
       End;

       if (Obj is TEnemy) then
       Begin
         With MyCanvas Do
         Begin
          x1:=round((TEnemy(Obj).EnmBody.X-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TEnemy(Obj).EnmBody.Y-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=trunc(TEnemy(Obj).EnmBody.Radius*Engine.WorldScaleX);
          Circle(x1,y1,x2,clred,fxNone);

         // x1:=round((TEnemy(Obj).guns[1].x-Mainform.Engine.WorldX)*Engine.WorldScaleX);
         // y1:=round((TEnemy(Obj).guns[1].y-Mainform.Engine.WorldY)*Engine.WorldScaleY);
         // Circle(x1,y1,10,clred,fxNone);

          if TEnemy(Obj).EnmSubCount>0 then
            for j := 1 to TEnemy(Obj).EnmSubCount do
            Begin
              x1:=round((TEnemy(Obj).EnmSubBodies[j].X-Mainform.Engine.WorldX)*Engine.WorldScaleX);
              y1:=round((TEnemy(Obj).EnmSubBodies[j].Y-Mainform.Engine.WorldY)*Engine.WorldScaleY);
              x2:=trunc(TEnemy(Obj).EnmSubBodies[j].Radius*Engine.WorldScaleX);
              Circle(x1,y1,x2,clred,fxNone);
            End;
        End;
       End;

       if (Obj is Tplayer) then
       Begin
         With MyCanvas Do
         Begin
          x1:=round((TPlayer(Obj).Body.X-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TPlayer(Obj).Body.Y-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TPlayer(Obj).Body.radius)*Engine.WorldScaleX);
          Circle(x1,y1,x2,clred,fxNone);

          x1:=round((TPlayer(Obj).Wing1.X[1]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TPlayer(Obj).Wing1.Y[1]-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TPlayer(Obj).Wing1.X[2]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y2:=round((TPlayer(Obj).Wing1.Y[2]-Mainform.Engine.WorldY)*Engine.WorldScaleY);

          FrameRect(x1,y1,x2-x1,y2-y1,Clred,FxNone);

          x1:=round((TPlayer(Obj).Wing2.X[1]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TPlayer(Obj).Wing2.Y[1]-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TPlayer(Obj).Wing2.X[2]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y2:=round((TPlayer(Obj).Wing2.Y[2]-Mainform.Engine.WorldY)*Engine.WorldScaleY);

          FrameRect(x1,y1,x2-x1,y2-y1,Clred,FxNone);

          x1:=round((TPlayer(Obj).KeepBox.X[1]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TPlayer(Obj).KeepBox.Y[1]-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TPlayer(Obj).KeepBox.X[2]-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y2:=round((TPlayer(Obj).KeepBox.Y[2]-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          if keepitm then
          FrameRect(x1,y1,x2-x1,y2-y1,Clred,FxNone);


          x1:=round((TPlayer(Obj).CollideRect.Left-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TPlayer(Obj).CollideRect.Top-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TPlayer(Obj).CollideRect.Right-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y2:=round((TPlayer(Obj).CollideRect.Bottom-Mainform.Engine.WorldY)*Engine.WorldScaleY);

          FrameRect(x1,y1,x2-x1,y2-y1,Cllime,FxNone);
        End;

       end;

       if (Obj is TDopEff) then
       Begin
          x1:=round((TDopEff(Obj).CollideRect.Left-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y1:=round((TDopEff(Obj).CollideRect.Top-Mainform.Engine.WorldY)*Engine.WorldScaleY);
          x2:=round((TDopEff(Obj).CollideRect.Right-Mainform.Engine.WorldX)*Engine.WorldScaleX);
          y2:=round((TDopEff(Obj).CollideRect.Bottom-Mainform.Engine.WorldY)*Engine.WorldScaleY);

          MyCanvas.FrameRect(x1,y1,x2-x1,y2-y1,Cllime,FxNone);
       End;


       if (Obj is TTile) then
       Begin

        With MyCanvas Do
         Begin
          if TTile(Obj).mylinecount>0 then
            for j := 0 to TTile(Obj).mylinecount - 1 do
            Begin
              x1:=round((TTile(Obj).Lines[j].X1-Mainform.Engine.WorldX)*Engine.WorldScaleX);
              y1:=round((TTile(Obj).Lines[j].Y1-Mainform.Engine.WorldY)*Engine.WorldScaleY);
              x2:=round((TTile(Obj).Lines[j].X2-Mainform.Engine.WorldX)*Engine.WorldScaleX);
              y2:=round((TTile(Obj).Lines[j].Y2-Mainform.Engine.WorldY)*Engine.WorldScaleY);
              Line(x1,y1,x2,y2,ClRed,ClRed,FxNone);

              if (TTile(Obj).tip=7)or(TTile(Obj).tip=28) then
              Begin
                x1:=round((TTile(Obj).X+TTile(Obj).subrect.Left -Mainform.Engine.WorldX)*Engine.WorldScaleX);
                y1:=round((TTile(Obj).Y+TTile(Obj).subrect.top -Mainform.Engine.WorldY)*Engine.WorldScaleY);
                x2:=round((TTile(Obj).subrect.Right-TTile(Obj).subrect.left)*Engine.WorldScaleX);
                y2:=round((TTile(Obj).subrect.Bottom-TTile(Obj).subrect.top )*Engine.WorldScaleY);
                Framerect(x1,y1,x2,y2,ClLime,FxNone);
              End;

            End;
        End
      End;

     End;

  End;///
///
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     // finalize Asphyre device
     if language<>nil then
      language.Destroy;
     Device.Finalize();
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState);
var
  Index,I: Integer;
begin

     KeysUpdate;

     if (Key = VK_BACK) then
      if ingame then
      begin
        dialnew:=false;
        dialtime:=0;
        HaveNewDLG:=false;
      end;

     if (Key = VK_ESCAPE) then Begin
       if paused then Begin
         paused:=false;
        End else
        if hintMenu then Begin
         hintmenu:=false;
         DXWave.Items.Find('mousein.wav').Play(false);  ///1308
        End else
        if Inventory then Begin
         CLOSEINV;
        End else
        if Inventory2 then Begin
         CLOSEINV2;
        End else
        if Inventory3 then Begin
         CLOSEINV3;
        End else
        if MapLookMenu then Begin
         MapLookMenu:=false;
         MapLookT:=0;
        End else
          if gameover then
          Begin

           try
            Mainform.SoundSystem.StopAll;
           except
           end;

           if leveldone then
           Begin
              if campaign then
                Nextlevel;
              if campaign=false then
                Donemaplevel;

           End
             else
             Begin
                if (campaign=false)and(LevelMissionTip=5) then
                Begin
                  percento[1]:=(Levelscore.enms);
                  percento[5]:=percento[1];
                  if (percento[5]>MapStat.MScore) then
                    saveStatistic;
                End;
                if (campaign=false) then
                  Donemaplevel
                  else
                  begin
                    menun:=1;
                    inmenu:=true;
                    gameover:=false;
                  end;
             End;
          End
          else
          if inmenu=true  then
          Begin
              if (menuN=10)or(menuN=11)  then
              Begin
                  menuready:=false;
                  nextmenu:=1;
              End
                else
                if (menuN=18)  then
                Begin
                  menuready:=false;
                  if level<levels.Count then
                    nextmenu:=10
                      else   Begin
                        nextmenu:=11;
                        UnpackExtras;
                      End;
                End
                  else

              if menuN=1  then
               menun:=4
                else
               if menuN=90  then
               Begin
                  menuready:=false;
                  nextmenu:=1;
                  UnloadPreviews;
               End
                else
               if menuN=2  then
               Begin
                  menuready:=false;
                  nextmenu:=1;
                  UnloadPreviews;
               End
                else
                 if (menun=12)  then
                   close
                else
                  if (menun=15)  then
                   begin
                     menuready:=false;
                     if campaign=false then
                         nextmenu:=2
                          else
                            nextmenu:=10;
                   end;
                 {if (menun=15)  then
                   begin

                    if campaign=false then
                    Begin
                        ///ЗАГРУЗКА КАРТЫ (см. nextmenu=-8)
                        UnloadPreviews;
                        for i:=1 to 4 do
                        Begin
                          if Items[i]<>nil then
                              Items[i]:=nil;
                              if i<=3 then
                                 Bonuses[i]:=nil;
                        End;
                          LoadMapLevel(mapsList[MapN]);   /////////////!!!!!!!!
                          menuready:=true;
                          menun:=0;
                          nextmenu:=0;
                          menut:=0;
                          StopMenu:=false;
                          InMenu:=false;
                    End
                       else
                          Begin
                            if (checkedlevel<level) then
                            Begin
                              SayLoading;
                              Loadstage(levels[level]);  /////////////!!!!!!!!
                              menuready:=true;
                              menut:=0;
                              StopMenu:=false;
                              InMenu:=false;
                            End
                             else
                              nextmenu:=15;
                          End;

                   end
                else         }
                  if menun=16 then
                    Begin
                      menuready:=false;
                      CurrentScreenN:=IntroCount+1;
                      UnloadIntro;
                       if level<levels.Count then
                        nextmenu:=10
                         else
                            Begin
                              nextmenu:=11;
                              UnpackExtras;
                            End;
                    End else
                       if menuN=3  then
                       Begin
                        menuready:=false;
                        nextmenu:=1;
                       End
          End else
          Begin
            if stopmenu=false then
              stopmenu:=true
             else
             Begin
              menuready:=false;
              nextmenu:=0;
             End;
            //////// Меню паузы
          End;

     End;
     //if (Key = VK_RETURN) then

      if (ssAlt in Shift) then Begin
        Paused:=true;
      End;


     // switch between full-screen and windowed mode on Alt + Enter
     if (Key = VK_RETURN) and (ssAlt in Shift) then
     begin
          // switch windowed mode
          Device.Windowed := not Device.Windowed;
          if Device.Windowed then
          Begin
           Mainform.BorderStyle:=bsSizeable;
           ClientWidth:=1024;
           ClientHeight:=trunc(1024*Device.Height/Device.Width);
         //  showmessage(inttostr(ClientHeight));
           Top:=(Screen.Height-ClientHeight)div 2;
           Left:=(Screen.Width-ClientWidth)div 2;
          End
           else Mainform.BorderStyle:=bsNone;
     end;


     if (Key = VK_F2) then Begin
       if windowstate=wsnormal then
        windowstate:=wsMaximized
       else  windowstate:=wsnormal

     End;

     if (Key = VK_F3) then Begin
       if windowstate=wsnormal then
        windowstate:=wsMinimized
       else  windowstate:=wsnormal

     End;

      if (Key = VK_F12) then Begin
       close;

     End;


    // EnterPressed:=false;

     if key=vk_Back then
     Begin

     if console then
      Begin

        concom:=copy(concom,1,length(concom)-1);
      End else
      if Menun=13 then
      Begin
        edit1:=copy(edit1,1,length(edit1)-1);
      End;
     End;

     if key=vk_Return then
     if console then
      Begin
        ConCOMMANDS;
        concom:='';
      End else
     Begin
      if hintMenu then
      Begin
        hintmenu:=false;
        DXWave.Items.Find('mousein.wav').Play(false);  ///1308
      End else
        if MapLookMenu then
        Begin
         MapLookMenu:=false;
         MapLookT:=0;
        End;


     if health>0 then
     goblack:=false;
     // EnterPressed:=true;

    //  if EnterKeep=false  then
    //  Begin


       if paused=true then
        paused:=false
        else
        if inmenu then
        Begin

          if menun=16 then
          Begin
            menuready:=false;
            CurrentScreenN:=IntroCount+1;
            UnloadIntro;
            if level<levels.Count then
              nextmenu:=10
              else
            Begin
              nextmenu:=11;
              UnpackExtras;
            End;
          End;

          if menun=15 then
          Begin
            SayLoading;
            CheckPointenabled:=true;
            LoadCheckPoint;  /////////////!!!!!!!!
            if campaign=false then
                Unloadpreviews;
            menuready:=true;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;
          End;

          if menun=10 then
          Begin
           { SayLoading;
            Loadstage(levels[level]);  /////////////!!!!!!!!
            menuready:=true;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;}

           if (checkedlevel<level)or(menun=15) then
           Begin
            SayLoading;
            Loadstage(levels[level]);  /////////////!!!!!!!!
            menuready:=true;
            menut:=0;
            StopMenu:=false;
            InMenu:=false;
           End else
           Begin
             menuready:=false;
             nextmenu:=15;
           End;

          End;

          if menun=14 then
          Begin
            menuready:=false;
            nextmenu:=1;
          End;

          if menun=4 then
          Begin
            close;
          End;

          if menun=13 then
          Begin
            if Edit1<>'' then
            Begin
             //profnames[slot]:=Edit1;
             //SaveProfNames;
             //NewProfileProgress;
             nextmenu:=17;
             menuready:=false;
            End else
            Begin
                menuready:=true;
                nextmenu:=13
            End;
          End;


        End else
        if (gameover=true) then
        Begin

           try
            Mainform.SoundSystem.StopAll;
           except
           end;


             if leveldone then
             Begin
               if campaign then
                 NEXTLEVEL
                  else DoneMapLevel;
              { gameover:=false;
               //menuready:=false;
               menun:=1;
               inmenu:=true;
               gameover:=false; }
             End else
             Begin
               if (campaign=false)and(LevelMissionTip=5) then
                Begin
                  percento[1]:=(Levelscore.enms);
                  percento[5]:=percento[1];
                  if (percento[5]>MapStat.MScore) then
                    saveStatistic;
                End;

              if checkpointenabled=false then
              Begin
               if campaign then
               Begin
                Loadprofileprogress;
                Loadstage(levels[level]);
               End else
                Begin
                // dfgdfgdg
                 LoadMapLevel(mapsList[MapN]);
                End;

              end
               else Loadcheckpoint;
             End;
        End else
        if (inGame)and(health>0) then
        Begin
          if KeyCodes[0]=28 then
          Begin
            inventory:=true;
           // enterpressed:=false;
          End;
        End;

    // End;
     End;

      if menun=18 then
        Begin

          if key=vk_left then
            if page>=1 then
             dec(page);

          if key=vk_right then     
            if page<2{levels.Count/5} then
             inc(page);

        End;

        if menun=90 then
        Begin

          if key=vk_left then
            if hintn>1 then
             begin
              dec(hintn);
              gethinticons;
             end;

          if key=vk_right then
            if hintn<hintmax then
            begin
             inc(hintn);
             gethinticons;
            end;

        End;

   //  EnterKeep:=(enterpressed);


end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if (Ord(key)=96)or(Ord(key)=126) then
 Begin
 if Developer then
        console:=not(console)
 End
 else
 if (Ord(key)>=32)then
 if console then
        concom:=concom+key;

 if (MenuN=13)then
 if (Ord(key)>=32)then
        Edit1:=Edit1+key;
  KeysUpdate;      

 if inmenu then
  if key=' ' then
   if menun=16 then
    Begin
    menuready:=false;
    CurrentScreenN:=IntroCount+1;
    UnloadIntro;
    if level<levels.Count then
      nextmenu:=10
      else  Begin
             nextmenu:=11;
             UnpackExtras;
            End;
   // nextmenu:=10;
    End

end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  if Gameloaded=false then
   Begin
     LoadPic;
     LoadGame;
     //Gameloaded:=true;
     //Timer.Enabled := InitSuccess;
   End;
end;

procedure TMainForm.GameInit;
var i,j:integer;
    trackname:string;
    s:TStringlist;
begin
/// Pre-load карты

/// MUSIC
     //trackname:='Mysterious Galaxy.';
     smessagetime:=0;
     HaveNewDLG:=false;
    // CamScale:=1;

     MapZonesCount := 0;

     fonar:=false;
     fonarcolor:=crgb1(40,40,100);
     for I := 1 to 32 do
      Begin
         PostFilter3flashLights[I].x:=0;
         PostFilter3flashLights[I].y:=0;
         PostFilter3flashLights[I].r:=0;
         PostFilter3flashLights[I].ready:=true;
      End;

      if Campaign then
       i:=level
        else
        Begin
         
         ////////////// NEW!
         for i:=1 to 4 do
         Begin
          if Items[i]<>nil then
            Items[i]:=nil;
          if i<=3 then
            Bonuses[i]:=nil;
          End;
          ////////////// NEW! - end
          if MapStat.MSurvival=true then
          i:=9
           else
             i:=1+random(3);
        End;

     trackname:='Data\Music\'+tracknames[i]+'.mp3'; //inttostr(1+random(4));  {TEST! TEST! TEST!}

     trackVol:=100;
     if Fileexists(('Data\Music\'+tracknames[i]+'.vol')) then
     Begin
      s:=TStringlist.Create;
      s.LoadFromFile('Data\Music\'+tracknames[i]+'.vol');
      trackVol:=strtoint(s[0]);
      s.Destroy;
     End;

    // DXMusic.Items.Clear;

                                        //
   {  if (MusVolume>0) then
     if(fileexists('Data\Music\'+trackname+'.wav')) then
     Begin
      i:=0; {№ ТРЕКА ИЛИ ИМЯ ФАЙЛА!}
   {
      DXMusic.Items.Add;
      DXMusic.Items[i].Wave.LoadFromFile('Data\Music\'+trackname+'.wav');
      DXMusic.Items[i].Name:=trackname;
      DXMusic.Items[i].MaxPlayingCount:=1;

      if MusVolume<>0 then
        DXMusic.Items[i].Volume:=-3000+MusVolume*30
          else DXMusic.Items[i].Volume:=-10000;

     // DXMusic.Items[i].Volume:=-10000+MusVolume*100;

      DXMusic.Items.Restore;
     End;     }

   SoundSystem.StopAll;
   SoundSystem.UnLoad;
   SoundSystem.AddFromFile(trackname);
   SoundSystem.StopAll;

  { currenttrack:=ASound.RecordNum[trackname];
   if currenttrack=-1 then }
      currenttrack:=0;

   leveldone:=false;

   for i := 1 to 32 do
    dialtray[i]:=0;

   dialnew:=false;
   dialtime:=0;
   MapLookMenu:=false;
   MapLookT:=0;

   for i := 1 to 10 do
   Begin
    DoorCols[i]:=0;
    DoorElectro[i]:=false;
    Weapons[i].Count:=0;
    AltWeapons[i]:=0;

    if i<=4 then
     StringArr[i]:=''
   End;

  GodMode:=false;

  Levelscore.plasmids:=0;
  Levelscore.enms:=0;
  Levelscore.secrets:=0;
  Levelscore.plasmidscount:=0;
  Levelscore.enmscount:=0;
  Levelscore.secretscount:=0;
  Levelscore.shotsluck:=0;
  levelscore.shootscount:=0;
  Levelscore.total:=globalscore;
  LevelTime:=0;

   for i:= 1 to 10 do
   myhints[i].hinttime:=0;

  CanChangeWeapon:=true;
  Altweapon:=0;
  Health:=100;
  Curetime:=21;
  GameOver:=false;
  keepitm:=false;
  inventory:=false;
  inventory2:=false;
  inventory3:=false;
  hintmenu:=false;
  maplookmenu:=false;
  MapLookT:=0;
  hintN:=1;
  gethinticons;
  MagzLev:=5;
  allcrazy1:=0;
  allcrazy2:=0;
  portals:=0;
  miseff1:=false;
  met:=0;
  Scanok:=false;
  Scaning:=0;
  
  Shieldtime:=0;
  ShieldColor:=1;
  spos:=0;

  AltWeapons[4]:=-1;
  AltWeapons[5]:=-1;

  WaitShoot:=false;
  Hudt:=0;
  Fade1:=250;
  Golight:=false;
  LightMax:=255;

   mx:=Device.Width/2;
   my:=Device.Height/2;
   RV:=0;

    for I := 1 to 10 do
      Begin
         PostFilter3flashLights[I].x:=0;
         PostFilter3flashLights[I].y:=0;
         PostFilter3flashLights[I].r:=0;
         PostFilter3flashLights[I].ready:=true;
      End;


   mx:=Device.Width/2;
   my:=Device.Height/2;

  {ЗАГРУЗКА НАЧАЛЬНЫХ ПАРАМЕТРОВ (.lev)}
  Currentweapon:=1;

   i:=0;
    for j := 1 to 7 do
      if altweapons[j]>0 then
       inc(I);
    altweaponscount:=i;


    GoTicks:=0;
    GoWait:=50;
    Gotip:=0;
end;

procedure TMainForm.GameProcess(Mdelta: real);
var i,_x,_y:integer;
begin

if (inventory=false)and(inventory2=false)and(inventory3=false)
   and(hintmenu=false)and(maplookmenu=false)  then
Begin
   KeysUpdate;

   if leveltime<360000 then                       // a\\d
     LevelTime:=leveltime+lagCount/100;

    // if levelmissiontip=2 then
      //         LevelTime:=leveltime+lagCount/10;        {DУБРАТЬ}


   if levelmissiontip=2 then
   Begin

    if (leveltime>=maxlevtime)and(health<=0)and(fade1<255) then
    Begin


      if GoTicks>=Gowait then
      Begin

       for I := 1 to 3 do
       begin
        GoTip:=random(18);
        _x:=trunc(_player.X)+random(2000)-1000;
        _y:=trunc(_Player.Y)+random(2000)-1000;

        case gotip of
          0..3: begin
               MiniExplodeEff2(_x,_y,PExplode);
               ExplodeEff(_x,_y,10,PExplode);
             end;
          4,5: begin
               MiniExplodeEff2(_x,_y,PExplode);
               ExplodeEff(_x,_y,10,PExplode);
               GoLight:=true;
               LightMax:=155;
             end;
          6..8:   ExplodeEff(_x,_y,5,PExplode);
          9..11:   ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
          12..14:   ExplodeeffBon(trunc(_x),trunc(_Y),20,psun);
          15,16:   Begin
                ExplodeEff(_x,_y,5,PExplode);
                ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
                if hieffs then
                  ExplodeeffBon(trunc(_x),trunc(_Y),20,psun);
               End;
           17,18:
               Begin
                ExplodeEff(_x,_y,5,PExplode);
                ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
                if hieffs then
                  ExplodeeffBon(trunc(_x),trunc(_Y),20,psun);
                GoLight:=true;
                LightMax:=155;
               End;
        end;
       end;

        if gotip>2 then
        Mainform.DXWave.items.Find('boom2.wav').Play(false)
          else
           Mainform.DXWave.items.Find('boom2.wav').Play(false);

        GoWait:=5+random(20);
        GoTicks:=0;

      End
        else
          GoTicks:=Goticks+lagCount;

      
    End;

    if (leveltime>=maxlevtime)and(health>0) then
      begin    // leveltime:=300;
        //levelmission:=0;
        health:=-100;
        BoomTime:=100;
        GoLight:=true;
        LightMax:=255;
        Mainform.DXWave.items.Find('boom2.wav').Play(false);

        if _player<>nil then
        Begin
          for I := 1 to 5 do
          Begin
            _x:=trunc(_player.X)+random(2000)-1000;
            _y:=trunc(_Player.Y)+random(2000)-1000;
           // Mainform.BoomPhys(trunc(_X),trunc(_Y),5,500,1);
            MiniExplodeEff2(_x,_y,PExplode);
            ExplodeEff(_x,_y,10,PExplode);
         //   ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
          End;

          Mainform.BoomPhys(trunc(_Player.x+128),trunc(_Player.Y+128),150,1000,5);

          if Hieffs then
          Begin
            for I := 1 to 3 do
            Begin
              _x:=trunc(_player.X)+random(2000)-1000;
              _y:=trunc(_Player.Y)+random(2000)-1000;
              ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
              ExplodeeffBon(trunc(_x),trunc(_Y),20,psun);
            End;
            for I := 1 to 5 do
            Begin
              _x:=trunc(_player.X)+random(2000)-1000;
              _y:=trunc(_Player.Y)+random(2000)-1000;
             // Mainform.BoomPhys(trunc(_X),trunc(_Y),5,500,1);
              MiniExplodeEff2(_x,_y,PExplode);
              ExplodeEff(_x,_y,10,PExplode);
             // ExplodeeffBon2(trunc(_x),trunc(_Y),20,pfire);
            End;
          End;


        End;
      end;
   End;

   DialMode:=false;

 /// SCAN
 if Scannow then
 Begin
    if scaning<100 then
      Begin
        scaning:=scaning+lagcount*0.7;
      End
       else
       begin

         /// SCAAAAN!

         scanok:=true;

          for i:=0 to Engine.Count-1 do
            if Engine[i] is TCapsule then
             if (TCapsule(Engine[i]).tip>=3)and(TCapsule(Engine[i]).tip<=8) then
              if OverlapRect(scanzone, Tsprite(Engine[i]).CollideRect) then
              Begin
                /// EFFECT
                 Mainform.DXWave.Items.Find('shield.wav').Play(false);
                  if TCapsule(Engine[i]).keeping then
                    ExplodeeffBon3(trunc(Engine[i].X),trunc(Engine[i].Y),20,psun2)
                    else
                      ExplodeeffBon3(trunc(Engine[i].X+50),trunc(Engine[i].Y+50),20,psun2);
                 scaning:=0.1;
                 scanok:=false;
              End;

         if scanok=false then
         begin
            smessagetime:=355;
            smessage:=language[176];
         end else
           begin
            smessagetime:=355;
            smessage:=language[232];
           end;
       end;
 End else
  if scaning>0 then
      Begin
        if scaning>=100 then
            Mainform.DXWave.Items.Find('off.wav').Play(false);
        scaning:=scaning-lagcount*1.4;
        if scaning<=0 then
            scanok:=false;

      End;


 /// ПУШКИ
    if Weapons[currentweapon].CurrentTime<WReloadTimes[currentweapon] then
        Weapons[currentweapon].CurrentTime:= Weapons[currentweapon].CurrentTime+ MDelta;

 /// ЭНЕРГИЯ
    if PlusHealth>=1 then
    Begin
      Health:=Health+trunc(PlusHealth);
      PlusHealth:=PlusHealth-trunc(PlusHealth);
    End;

    if portals>0 then
    Begin
      portals:=portals-mdelta/10;
      if portals<=0 then
       bornEnms;
    End;


    if droid then
    if health>0 then
     if health<100 then
       Health:=Health+0.03*Lagcount;

    if Health>100 then
      Health:=100;

    if health= 100 then
       PlusHealth:=0;

    if godmode then health:=100;
      

    if Health<0 then Health:=0;

    if allcrazy1>0 then allcrazy1:=allcrazy1-lagcount*0.2;
    if allcrazy2>0 then allcrazy2:=allcrazy2-lagcount*0.2;

 {   if allcrazy1>0 then dop3:='!!!' else dop3:='&&&'; }
 //// ЦВЕТ
  if PlusClr>1 then
  Begin
   Weapons[PlusClrN].Count:=Weapons[PlusClrN].Count+trunc(PlusClr);
   PlusClr:=PlusClr-trunc(PlusClr)
  End;
  if Weapons[PlusClrN].Count>35 then
   Weapons[PlusClrN].Count:=35;
  if Weapons[PlusClrN].Count=35 then
   PlusClr:=0;

 //// ПРЕДМЕТЫ

    minimap:=false;
    HiSpeed:=0;
    Rainbow:=false;

    if (shieldtime>0)and(inshield=false) then
    shieldtime:=shieldtime-lagcount*0.03;

    InShield:=false;

    for i:=1 to 4 do
      if items[i]<>nil then
      Begin
        if items[i].ItemCurrenttime<=0 then
          items[i]:=nil
          else
            if items[i].itemInUse then
              Items[i].UseItem(lagcount);
        
      End;


 //// БОНУСЫ
 Radar:=false;
 Droid:=false;
 Lakmus:=false;
 Unltd:=false;
 Detect:=false;
 

 dopslots:=false;
 plasmup:=false;

    for i:=1 to 3 do
    Begin
      if Bonuses[i]<>nil then
      Begin
         Bonuses[i].UseBonus(lagcount);
      End;
    End;
End;

//// GameOver
 if {(health<=0)or}(Gameover) then
 Begin
  GoBlack:=false;
  if Waittofade>0 then
   Waittofade:=WaitTofade-abs(Lagcount)
   else
    if Waittofade<=0 then
      GoBlack:=true;
 End else  GoBlack:=false;


end;

procedure TMainForm.DrawHud;
var mycolor:Cardinal;
 _x,_y,_h,_w,i,j,k,X1,Y1,dop4:integer;
 __x,__y,__w,__h,_dop,_dop2,_dop3,_dop5:real;
 _scale,_sc:real;
 _col:TColor4;
 imgname,st,_str:string;
begin
  MapBorder;

  With MyCanvas do Begin

    /// рамка
    MyColor:=crgb1(0,0,0,215);
    Rectangle(Hud_Bounds[1],Mycolor,MyColor,FxBlend);

    Rectangle(Hud_Bounds[2],Mycolor,MyColor,FxBlend);

    if smessagetime>0 then
    Begin
       Fonts[1].Scale:=ResolutionScaleY*1.2;
       if smessagetime<255 then
       Fonts[1].TextOut(smessage ,
        (1600*ResolutionScaleX-Fonts[1].textwidth(smessage))/2,(50)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(smessagetime)))
         else
           Fonts[1].TextOut(smessage ,
        (1600*ResolutionScaleX-Fonts[1].textwidth(smessage))/2,(50)*ResolutionScaleY, cRGB1(250, 250, 255, 255));
       smessagetime:=smessagetime-lagcount*0.5;
    End;


    if ShowChoosed then
     Begin
       imgname:='chobj';
      if ChooseBound.h<ChooseBound.w then
        imgname:='chobj2'
         else
      if ChooseBound.h>ChooseBound.w then
        imgname:='chobj3'
         else
            if ChooseBound.w<=150 then
              imgname:='chobj1';

          if schoosing<100 then
               schoosing:= schoosing+lagcount*5;
          i:=trunc(schoosing);///(30*Sin(leveltime*10));

          if (pushtile<>nil)or(TakenCapsule<>nil)or(TakenCol<>nil) then
             _col:=cRGB4(10,100,220,70+i)
               else
                 _col:=cRGB4(200,0,20,70+i);


          DrawStretch(MenuImages.Image[imgname],0,
            trunc((ChooseBound.x-Engine.Worldx)*Engine.WorldScaleX),
            trunc((ChooseBound.y-Engine.Worldy)*Engine.WorldScaleY),
            trunc((ChooseBound.x+ChooseBound.w-Engine.Worldx)*Engine.WorldScaleX),
            trunc((ChooseBound.y+ChooseBound.h-Engine.Worldy)*Engine.WorldScaleY),
            false,false,
            _col,
            fxadd);

     // MainForm.Fonts[1].Textout(s,trunc((x-Engine.Worldx)*Engine.WorldScaleX),
      //  trunc((y-Engine.Worldy)*Engine.WorldScaleY),clwhite,clred,fxnone)

     End else
       schoosing:=0;

    
    if shieldtime>0 then
    Begin
      if shieldshow<255 then
        shieldshow:= shieldshow + lagcount*5;
      if shieldshow>255 then
        shieldshow:=255;
    End else
    Begin
      if shieldshow>0 then
        shieldshow:= shieldshow - lagcount*5;
      if shieldshow<0 then
        shieldshow:=0;
    End;

    if shieldshow>0 then
    Begin
      Fonts[1].Scale:=ResolutionScaleY*0.6;
      __h:= Fonts[1].TextHeight('100');

      DrawStretch(HudImages.Image['mishud'],0,
            trunc((5-256+hudXShift+shieldshow)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((5+hudXShift+shieldshow-56)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+128*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(shieldshow)),fxBlend);

      dop4:=trunc(Shieldtime/10);

       DrawStretch(HudImages.Image['shieldfon'],0,
            trunc((6-256+hudXShift+shieldshow)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+hudXShift+128+shieldshow)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            cRGB4(redw[shieldcolor],greenw[shieldcolor],bluew[shieldcolor],
                  trunc(shieldshow)),fxBlend);

      if (dop4>=0)and(dop4<10) then
      Begin
       // UPPER
       DrawStretch(HudImages.Image['shield_'+inttostr(dop4+2)],0,
            trunc((6-256+shieldshow+hudXShift)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+128+shieldshow+hudXShift)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            cRGB4(redw[shieldcolor],greenw[shieldcolor],bluew[shieldcolor],
                  trunc(shieldshow*(Shieldtime-dop4*10)/10)),fxBlend);

       // CURRENT
       DrawStretch(HudImages.Image['shield_'+inttostr(dop4+1)],0,
            trunc((6-256+shieldshow+hudXShift)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+128+shieldshow+hudXShift)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            cRGB4(redw[shieldcolor],greenw[shieldcolor],bluew[shieldcolor],
                  trunc(shieldshow){*(1-(Shieldtime-dop4*10)/10))}),fxBlend);


      End else
      if dop4>=10 then
         DrawStretch(HudImages.Image['shield_11'],0,
            trunc((6-256+shieldshow+hudXShift)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+128+shieldshow+hudXShift)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            cRGB4(redw[shieldcolor],greenw[shieldcolor],bluew[shieldcolor],
                  trunc(shieldshow)),fxBlend);

      DrawStretch(HudImages.Image['shieldicon'],0,
            trunc((6-256+shieldshow+hudXShift)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+128+shieldshow+hudXShift)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            cRGB4(redw[shieldcolor],greenw[shieldcolor],bluew[shieldcolor],
                  trunc(shieldshow)),fxBlend);

     if hieffs then
         if (inshield)and(shieldtime<100) then
           DrawStretch(HudImages.Image['shieldicon'],0,
            trunc((6-256+shieldshow+hudXShift)*ResolutionScaleX),
            trunc((370)*ResolutionScaleY2),
            trunc((6-256+128+shieldshow+hudXShift)*ResolutionScaleX),
            trunc(370*ResolutionScaleY2+{64}(128)*ResolutionScaleY),false,false,
            crgb4(255,255,255,40+trunc(40*Sin(leveltime*10))),fxAdd);

      st:=language[231];//inttostr(trunc(Shieldtime));
      while length(St)<3 do
       st:='0'+st;

      __w:=Fonts[1].TextWidth(st);
      Fonts[1].TextOut(st,
      (160-256+shieldshow+hudXShift)*ResolutionScaleX-__w/2,
      (370)*ResolutionScaleY2+(33)*ResolutionScaleY-__h/2,
      cRGB1(255, 255, 255,trunc(shieldshow)));
    End;

    if levelmission>0 then
    Begin
      if levelmissionshow<255 then
        levelmissionshow:= levelmissionshow + lagcount*5;
      if levelmissionshow>255 then
        levelmissionshow:=255;
    End else
    Begin
      if levelmissionshow>0 then
        levelmissionshow:= levelmissionshow - lagcount*5;
      if levelmissionshow<0 then
        levelmissionshow:=0;
    End;

    if levelmissionshow>0 then
    Begin
      Fonts[1].Scale:=ResolutionScaleY*0.7;

      if levelmissiontip>=6 then
        Fonts[1].Scale:=ResolutionScaleY*0.55;

      __h:= Fonts[1].TextHeight('100');

      DrawStretch(HudImages.Image['mishud'],0,
            trunc((5-256+hudXShift+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((5+hudXShift+levelmissionshow-56)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow)),fxBlend);

      if levelmissiontip=2 then
      begin

       dop4:=trunc((maxlevtime-Leveltime)/(0.1*maxlevtime));

       DrawStretch(HudImages.Image['shieldfon'],0,
             trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[2],greenw[2],bluew[2],
                  trunc(levelmissionshow)),fxBlend);
        if leveltime<maxlevtime then
        begin
        if (dop4>=0)and(dop4<10) then
        Begin
        // UPPER
        DrawStretch(HudImages.Image['shield_'+inttostr(dop4+2)],0,
             trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[2],greenw[2],bluew[2],
                  trunc(levelmissionshow*(((maxlevtime-leveltime)-dop4*0.1*maxlevtime))/(0.1*maxlevtime))),fxBlend);

        // CURRENT
        DrawStretch(HudImages.Image['shield_'+inttostr(dop4+1)],0,
              trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[2],greenw[2],bluew[2],
                  trunc(levelmissionshow)),fxBlend);


      End else
      if dop4>=10 then
         DrawStretch(HudImages.Image['shield_11'],0,
            trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[2],greenw[2],bluew[2],
                  trunc(levelmissionshow)),fxBlend);

      end;
      end;


      ////////////////////////////////////////////////// 5555
        if (levelmissiontip>=5) then
      begin

       if (levelmissiontip=5) then
       begin
          dop4:=trunc(10*(survivalT[LevelMission]-leveltime)/(survivalT[LevelMission]-survivalT[LevelMission-1]));
          _dop5:=(10*(survivalT[LevelMission]-leveltime)/(survivalT[LevelMission]-survivalT[LevelMission-1]))-dop4;
       end
        else
           begin
             dop4:=0;
             _dop5:=0;
            if levelmission<100 then
            begin
             dop4:=9-trunc(levelmission/10);
             _dop5:=10-((levelmission/10)-trunc(levelmission/10));
            end;
           end;


       DrawStretch(HudImages.Image['shieldfon'],0,
             trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[1],greenw[1],bluew[1],
                  trunc(levelmissionshow)),fxBlend);
     //   if dop4>0 then
     //   begin
        if (dop4>=0)and(_dop5>=0)and(dop4<10) then
        Begin
        // UPPER

        DrawStretch(HudImages.Image['shield_'+inttostr(10-dop4+1)],0,
             trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[1],greenw[1],bluew[1],
                  trunc(255-_dop5*255)),fxBlend);

           //Fonts[1].TextOut(inttostr(trunc(_dop5*100)),
           //10,10,cRGB1(255, 255, 255,255));

        // CURRENT
        DrawStretch(HudImages.Image['shield_'+inttostr(10-dop4)],0,
              trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[1],greenw[1],bluew[1],
                  trunc(levelmissionshow)),fxBlend);


      End else
      if dop4>=10 then
         DrawStretch(HudImages.Image['shield_11'],0,
            trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(redw[1],greenw[1],bluew[1],
                  trunc(levelmissionshow)),fxBlend);

      end;
   //   end;

      ///////////////////////////// 55555 end

      if (levelmissiontip=1) then
      DrawStretch(HudImages.Image['mission'+inttostr(levelmissiontip)
            +'_'+inttostr(5-levelmission)],0,
            trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow)),fxBlend)
        else
         if (levelmissiontip=4) then
          DrawStretch(HudImages.Image['mission'+inttostr(levelmissiontip)
            +'_'+inttostr(levelmission)],0,
            trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow)),fxBlend)
        else
       DrawStretch(HudImages.Image['mission'+inttostr(levelmissiontip)],0,
            trunc((6+hudXShift-256+levelmissionshow)*ResolutionScaleX),
            trunc((250+misshift)*ResolutionScaleY2),
            trunc((6+hudXShift-256+128+levelmissionshow)*ResolutionScaleX),
            trunc((misshift+250)*ResolutionScaleY2+(128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow)),fxBlend);

       if miseff1 then
       Begin
        met:=312;
        miseff1:=false;
       End;

       if met>0 then
       Begin
        if (levelmissiontip=4) then
         DrawStretch(HudImages.Image['mission4_0'],0,
            trunc((6+hudXShift-224+levelmissionshow-(512-met)/5)*ResolutionScaleX),
            trunc((294+misshift-(512-met)/5)*ResolutionScaleY2),
            trunc((6+hudXShift-192+32+levelmissionshow+(512-met)/5)*ResolutionScaleX),
            trunc((misshift+294+(512-met)/5)*ResolutionScaleY2+(64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow*cos((314-met)/200))),fxBlend)
        else
        DrawStretch(HudImages.Image['mission_'+inttostr(levelmissiontip)],0,
            trunc((6+hudXShift-224+levelmissionshow-(312-met)/10)*ResolutionScaleX),
            trunc((294+misshift-(312-met)/10)*ResolutionScaleY2),
            trunc((6+hudXShift-192+32+levelmissionshow+(312-met)/10)*ResolutionScaleX),
            trunc((misshift+294+(312-met)/10)*ResolutionScaleY2+(64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(levelmissionshow*cos((314-met)/200))),fxBlend);

            met:=met-lagcount*10;// cxzc
       End;

      dop4:=0;
      if levelmissiontip=1 then
        st:=inttostr(5-levelmission)+'/5'//+inttostr(lmmax)
          else
       if levelmissiontip=4 then
        st:=inttostr(3-levelmission)+'/3'
          else
            if levelmissiontip=2 then
            begin
              Fonts[1].Scale:=ResolutionScaleY*0.6;
              if leveltime<maxlevtime then
              Begin
                st:='';
                dop4:=trunc((maxlevtime-leveltime)/60);
                st:= inttostr(dop4)+':';

                dop4:=trunc((maxlevtime-leveltime)-60*trunc((maxlevtime-leveltime)/60));
                if dop4<10 then
                   st:= st+'0';
                st:= st+inttostr(dop4);
              End
                  else
                    st:= '0:00';
               __h:= Fonts[1].TextHeight('100');
              // dop4:=7;
            end
             else
              if levelmissiontip=5 then
              if (gameover=false) then {NEW!!!! УБЕРИ, если будут глюки}
              begin
                 /// УСКОРИМ ДЛЯ ТЕСТА
                 // leveltime:= leveltime+lagcount/10;
                 //          zxzx
                 //if not(gameover) then
                    dop4:=trunc((survivalT[LevelMission]-leveltime));

                 if dop4<0 then
                 Begin
                   if levelmission<12 then
                   Begin
                     Inc(Levelmission);
                     portals:=5;

                    if levelmission<12 then
                     smessage:=language[233]+Inttostr(Levelmission-1)
                      else
                          smessage:=language[234];
                      miseff1:=true;
                      smessagetime:=300;
                   End
                   else
                   Begin
                       gameover:=true;
                       leveldone:=true;
                       percento[1]:=Levelscore.enms;//count;
                       percento[5]:=Levelscore.enms;//count;
                   End;
                 End;



                Fonts[1].Scale:=ResolutionScaleY*0.6;
                if ((levelmissiontip=5)and(leveltime<survivalT[12]))or (leveltime<maxlevtime) then
                Begin
                  st:='';
                  dop4:=trunc((survivalT[LevelMission]-leveltime)/60);

                  st:= inttostr(dop4)+':';

                  dop4:=trunc((survivalT[LevelMission]-leveltime)-60*trunc((survivalT[LevelMission]-leveltime)/60));
                if dop4<10 then
                   st:= st+'0';
                st:= st+inttostr(dop4);
              End
                  else
                    st:= '0:00';
               __h:= Fonts[1].TextHeight('100');
              // dop4:=7;   }
            end;

       if levelmissiontip=6 then
        st:=language[189]
          else
       if levelmissiontip=7 then
        st:=language[301];

      __w:=Fonts[1].TextWidth(st);
      Fonts[1].TextOut(st,
      (160+hudXShift-256+levelmissionshow)*ResolutionScaleX-__w/2,
      (250+misshift)*ResolutionScaleY2+(33)*ResolutionScaleY-__h/2,
      cRGB1(255, 255, 255,trunc(levelmissionshow)));

      if levelmissiontip=2 then
        if leveltime > maxlevtime-30 then
          if cos(leveltime*10)>0 then
            Fonts[1].TextOut(st,
      (160+hudXShift-256+levelmissionshow)*ResolutionScaleX-__w/2,
      (250+misshift)*ResolutionScaleY2+(33)*ResolutionScaleY-__h/2,
      cRGB1(255, 0, 0,trunc(levelmissionshow)));

    End;



{    if dialnew then
    Begin

    if dialtime<256 then
            dialtime:=dialtime+lagcount*4
             else
             Begin
              dialtime:=1000;
              Dialnew:=false;
             End;
    End;

    if dialtime>0 then
    Begin
       Fonts[1].Scale:=ResolutionScaleY*0.67;

       if SymbN<Length(Dialog[StringN+Dial*5]) then
        Begin
          SymbN:=SymbN+Lagcount;
          if SymbN>Length(Dialog[StringN+Dial*5]) then
              SymbN:=Length(Dialog[StringN+Dial*5]);
          StringArr[StringN]:=Copy(Dialog[StringN+Dial*5],1,trunc(SymbN));
        End else
        if StringN<4 then
        Begin
          inc(StringN);
          StringArr[StringN]:='';
          symbN:=0;
        End else
          Begin
            if (dialnew=false)and(ingame) then
            Begin
               if dialtime>255 then
               Begin
                dialtime:=dialtime-lagcount*2;      {держим диалог}
        {        if dialtime<255 then dialtime:=255;
               End
                else
                Begin
                  dialtime:=dialtime-lagcount*4;

                  if dialtray[1]<>0 then     /////////////!!!!!!!!!!!!!!!!!
                  Begin
                    dialnew:=true;
                    dial:=dialtray[1]-1;
                    SymbN:=0;
                    StringN:=1;
                    DialPicN:=StrToInt(Dialog[Dial*5]);
                    for i:=1 to 31 do
                      dialtray[i]:=dialtray[i+1];
                  End; 

                End;
              End;
          End;


        if dialtime<0 then dialtime:=0;


       if dialtime>255 then
        Begin
          DrawStretch(HudImages.Image['d_'+inttostr(dialpicN)],0,  trunc((800-328)*ResolutionScaleX),
            trunc((60)*ResolutionScaleY),trunc((800-128)*ResolutionScaleX),
            trunc((60+200)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend);

          DrawStretch(HudImages.Image['dial2'],0,  trunc((800-510)*ResolutionScaleX),
            trunc((50)*ResolutionScaleY),trunc((800-310)*ResolutionScaleX),
            trunc((50+64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend);

          DrawStretch(HudImages.Image['dial'],0,  trunc((1600-312)*ResolutionScaleX/2),
            trunc((50)*ResolutionScaleY),trunc((1600+1112)*ResolutionScaleX/2),
            trunc((50+128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend)
        End
          else
          Begin
             //dialtime:=dialtime-lagcount*3;

             DrawStretch(HudImages.Image['d_'+inttostr(dialpicN)],0,  trunc((800-328)*ResolutionScaleX),
              trunc((60+dialtime/2-127)*ResolutionScaleY),trunc((800-128)*ResolutionScaleX),
              trunc((60+200+dialtime/2-127)*ResolutionScaleY),false,false,
              cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);

             DrawStretch(HudImages.Image['dial2'],0,  trunc((800-510)*ResolutionScaleX),
              trunc((50+dialtime/2-127)*ResolutionScaleY),trunc((800-310)*ResolutionScaleX),
              trunc((50+64+dialtime/2-127)*ResolutionScaleY),false,false,
              cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);


              DrawStretch(HudImages.Image['dial'],0,  trunc((1600-312)*ResolutionScaleX/2),
                trunc((50+dialtime/2-127)*ResolutionScaleY),trunc((1600+1112)*ResolutionScaleX/2),
                trunc((50+128+dialtime/2-127)*ResolutionScaleY),false,false,
                cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);
          End;

      if dialtime<=255 then
       Fonts[1].TextOut(Pnames[dialpicN],
                (310*ResolutionScaleX),(69+dialtime/2-127)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(dialtime*(100-Hudt)/100)))
        else
          Fonts[1].TextOut(Pnames[dialpicN],
                (310*ResolutionScaleX),(69)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(255*(100-Hudt)/100)));

       for i := 1 to StringN do
         if dialtime<=255 then
          Fonts[1].TextOut(Stringarr[i],
            (759*ResolutionScaleX),(53+20*i+dialtime/2-127)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(dialtime*(100-Hudt)/100)))
            else
              Fonts[1].TextOut(Stringarr[i],
                (759*ResolutionScaleX),(53+20*i)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(255*(100-Hudt)/100)));

    End else
      if (dialtray[1]<>0)and(dialnew=false) then
      Begin
         dialnew:=true;
         Dial:=dialtray[1]-1;
         DialPicN:=StrToInt(Dialog[Dial*5]);
         SymbN:=0;
         StringN:=1;
         dialtime:=0;
         for i:=1 to 31 do
          dialtray[i]:=dialtray[i+1];
      End;              }


    if (inventory=true) then
    Begin
      if Hudt<100 then
        Hudt:=hudt+lagcount*5;
    End else
      if Hudt>0 then
        Hudt:=hudt-lagcount*5;

    if hudt<0 then Hudt:=0;
    if hudt>100 then Hudt:=100;

 
    if DialMode then
    Begin
      if DialHudt<100 then
        DialHudt:=DialHudt+lagcount*5;
    End else
      if DialHudt>0 then
        DialHudt:=DialHudt-lagcount*5;

    if DialHudt<0 then DialHudt:=0;
    if DialHudt>100 then DialHudt:=100;


    if (inventory2=true) then
    Begin
      if Hudt2<100 then
        Hudt2:=hudt2+lagcount*4;
    End else
      if Hudt2>0 then
        Hudt2:=hudt2-lagcount*5;

    if hudt2<0 then Hudt2:=0;
    if hudt2>100 then Hudt2:=100;


    if (inventory3=true) then
    Begin
      if Hudt3<100 then
        Hudt3:=hudt3+lagcount*5;
    End else
      if Hudt3>0 then
        Hudt3:=hudt3-lagcount*5;

    if hudt3<0 then Hudt3:=0;
    if hudt3>100 then Hudt3:=100;

    //// HUD begin

  if (inventory3=false) then
  Begin
    if hudt>0 then
    SLine(round(Hudt));

    for I := 1 to 20 do
    Begin
      with Hud[i] do
      Begin
        if isRight then
         __x:=((virtualW+xmin+round(Hudt/100*(xmax-xmin)))*ResolutionscaleX)
            else
              __x:=((xmin+round(Hudt/100*(xmax-xmin)))*ResolutionscaleX);
        if isBottom then
          __y:=((1200+ymin+round(Hudt/100*(ymax-ymin)))*ResolutionscaleY2)
             else
              __y:=((ymin+round(Hudt/100*(ymax-ymin)))*ResolutionscaleY2);
        _scale:=(minscale+(Hudt/100*(maxscale-minscale)));

        cx:=__x;
        cy:=__y;
        cscale:=_scale;
        _x:=round(__x);
        _Y:=round(__y);
      End;
      if Hud[i].hudtype=1 then Begin
         imgname:='Hud1_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         if Hudt=0 then
         Begin
            if Radar then
            Begin

              _h:=round(_h*1.5);
              _w:=round(_w*1.5);
              _x:=_x+_h div 4;
              _y:=_y+_w div 4;

              DrawStretch(HudImages.Image['Hud1_1small'],0, _x-_w div 2,
                _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
                cRGB4(255,255,255,205),fxBlend);

               x1:=_x-_w div 2;
               y1:=_y-_h div 2;
               _dop:=_w/200;
               _dop2:=_h/200;
              ///hudImages.Image['minimap'].LoadFromBitmap(MiniBitMap,true,clBlack,0);

              for  j:=trunc(_player.x/100-16) to trunc(_player.x/100+16) do
                for  k:=trunc(_player.y/100-16) to trunc(_player.y/100+16) do
                Begin
                  x1:=round((_player.X+128-j*100)/20)-1;
                  y1:=round((_player.y+128-k*100)/20)-1;
                  if sqrt(sqr(x1+1.25)+sqr(y1+1.25))<80 then
                    Begin
                     if (j>=0)and(k>=0)and(j<=mapsizex)and(k<=mapsizey) then
                     Begin
                      if larr[j,k]>0 then
                           DrawStretch(mmImages.Image['mm12'],0,_x-x1*_dop ,_y-y1*_dop2,
                            5*_dop+1,5*_dop+1,1,1,false,false,false,
                            cRGB4(RedW[larr[j,k]],GreenW[larr[j,k]],Bluew[larr[j,k]],255),fxBlend);

                      if SMMap[j,k]>1 then
                          DrawStretch(mmImages.Image['mm'+inttostr(SMMap[j,k])],0,_x-x1*_dop ,_y-y1*_dop2,
                            5*_dop+1,5*_dop+1,1,1,false,false,false,
                            cRGB4(255,255,255,255),fxBlend);

                      if SMMap[j,k]=1 then
                          DrawStretch(mmImages.Image['mm1_'],0,_x-x1*_dop ,_y-y1*_dop2,
                            5*_dop+1,5*_dop+1,1,1,false,false,false,
                            cRGB4(255,255,255,255),fxBlend);

                     End else
                       Begin
                         DrawStretch(mmImages.Image['mmend'],0,_x-x1*_dop ,_y-y1*_dop2,
                            5*_dop+1,5*_dop2+1,1,1,false,false,false,
                            cRGB4(200,200,200,255),fxBlend);
                         {Mycanvas.Fillrect(Bounds(_x-trunc(x1*_dop)+1 ,_y-trunc(y1*_dop2)+1,
                            trunc(5*_dop)+1,trunc(5*_dop2)+1),cRGB4(50,50,60,100),fxNone);
                         DrawStretch(Images.Image['mmend'],0,_x-x1*_dop ,_y-y1*_dop2,
                            5*_dop+1,5*_dop2+1,1,1,false,false,false,
                            cRGB4(255,255,255,205),fxNone);}

                       End;
                    End;
                End;


              Brush.Style:=bsSolid;

              for  j:=1 to MiniMapObjCount do
              Begin

               DrawStretch(mmImages.Image['mm'+inttostr(mmap[j,0])],0,_x-mmap[j,1]*_dop ,_y-mmap[j,2]*_dop2,
                mmap[j,3]*_dop,mmap[j,4]*_dop2,1,1,false,false,false,
                 cRGB4(255,255,255,205),fxBlend);
              End;

              DrawStretch(HudImages.Image['radar'],0, _x-_w div 2,
                _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
                cRGB4(255,255,255,225),fxBlend);

              _x:=_x-_h div 4;
              _y:=_y-_w div 4;
              _h:=round(_h/1.5);
              _w:=round(_w/1.5);

              _h:=round(_h/1.5);
              _W:=round(_w/1.5);
              _x:=_x-_h div 3;
              _y:=_y-_w div 3;
            End;

            imgname:=imgname+'small';
         End;


            DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

         if health>0 then
         Begin
            imgname:='Hud1_2';
            _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
            _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
            _dop:=(0.01*(100-health)*HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionscaleY);
            _sc:=_scale;


         if Hudt=0 then Begin
          _sc:=_scale*(HudImages.Image[imgname].VisibleSize.x)/(HudImages.Image[imgname+'small'].VisibleSize.x);
          imgname:=imgname+'small';

              if Radar then
              Begin
                _h:=round(_h/1.5);
                _W:=round(_w/1.5);
                _sc:=_sc/1.5;
                _dop:=_dop/1.5;
              End;
         End;

         DrawPortion(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2+_dop,0,0,HudImages.Image[imgname].VisibleSize.x,
              HudImages.Image[imgname].VisibleSize.y-round(0.01*(100-health)*HudImages.Image[imgname].VisibleSize.y),
//              round(HudImages.Image[imgname].VisibleSize.y*(1-0.01*(100-health))),

              _sc*resolutionscaleX,_sc*resolutionscaleY,
              false,false,true,
              cRGB4(255,255,255,205),fxBlend);
         End else Health:=0;

         imgname:='Hud1_3';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         if Hudt=0 then
         Begin
            imgname:=imgname+'small';
             if Radar then
              Begin
                _h:=round(_h/1.5);
                _W:=round(_w/1.5);
              End;
         End;
         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,255),fxBlend);
      End;
      if Hud[i].hudtype=2 then Begin
         imgname:='Hud2_'+inttostr(6-altweaponscount);

         if altweaponscount=0 then
           imgname:='Hud2_5';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         if Hudt=0 then
         imgname:=imgname+'small';

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);

      End;
      if (Hud[i].hudtype=3)and(hudt3<=0) then Begin
         imgname:='Hud3_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         if Hudt=0 then
         imgname:=imgname+'small'
         else
            if (InMouse<>nil) then
              if (InMouse is TItem) then
                imgname:='Hud3_1_1';

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);

      End;
        if (Hud[i].hudtype=4)and(hudt3<=0) then Begin
          imgname:='Hud4_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         if Hudt=0 then
         imgname:=imgname+'small'
         else
            if (InMouse<>nil) then
              if (InMouse is TBonus) then
                imgname:='Hud4_1_1';


         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);

      End;
       if Hud[i].hudtype=5 then
        if hudt>0 then Begin
         if Hud_currentzone=7 then
           imgname:='Hud5_2'
            else
             imgname:='Hud5_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);
      End;

      if Hud[i].hudtype=15 then
      if (DialMode=false)and(DialHudT<=0)and((LevDials.Count>0)or(AllDials.Count>0)) then Begin
        if (hudt>0) then Begin
         if Hud_currentzone=15 then
           imgname:='Hud10_2'
            else
             imgname:='Hud10_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

         if ShowDLG=false then
          if HaveNewDLG then
           if Hud_currentzone<>15 then
            begin
              k:=trunc(200 - 100*(sin(dialtime*pi/32)+1)*(round(Hudt/100)));
              DrawStretch(HudImages.Image['Hud10_2'],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,k),fxBlend);
            end;
        End;
      End;


     { if Hud[i].hudtype=6 then
        if hudt>0 then Begin
         if Hud_currentzone=15 then
           imgname:='Hud6_2'
            else
             imgname:='Hud6_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);
      End;

      if Hud[i].hudtype=7 then
        if hudt>0 then Begin
         if Hud_currentzone=16 then
           imgname:='Hud7_2'
            else
             imgname:='Hud7_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);
      End;   }

    End;
  End;
    //// HUD end

  if hudt2<=0 then
       IF not(inventory3)and(hudt3<=0) then
        DopHudDraw;
  if ShowDLG then
  BEGIN
    if dialnew then
    Begin

    if dialtime<256 then
            dialtime:=dialtime+lagcount*4
             else
             Begin
              dialtime:=1000;
              Dialnew:=false;
             End;
    End;

    if dialtime>0 then
    Begin
       Fonts[1].Scale:=ResolutionScaleY*0.67;

       if SymbN<Length(Dialog[StringN+Dial*5]) then
        Begin
          SymbN:=SymbN+Lagcount;
          if SymbN>Length(Dialog[StringN+Dial*5]) then
              SymbN:=Length(Dialog[StringN+Dial*5]);
          StringArr[StringN]:=Copy(Dialog[StringN+Dial*5],1,trunc(SymbN));
        End else
        if StringN<4 then
        Begin
          inc(StringN);
          StringArr[StringN]:='';
          symbN:=0;
        End else
          Begin
            if (dialnew=false)and(ingame) then
            Begin
               if dialtime>255 then
               Begin
                dialtime:=dialtime-lagcount*2;      {держим диалог}
                if dialtime<255 then dialtime:=255;
               End
                else
                Begin
                  dialtime:=dialtime-lagcount*4;

                 {} if dialtray[1]<>0 then     /////////////!!!!!!!!!!!!!!!!!
                  Begin
                    dialnew:=true;
                    dial:=dialtray[1]-1;
                    SymbN:=0;
                    StringN:=1;
                    DialPicN:=StrToInt(Dialog[Dial*5]);
                    for i:=1 to 31 do
                      dialtray[i]:=dialtray[i+1];
                  End; {}

                End;
              End;
          End;


        if dialtime<0 then dialtime:=0;


       if dialtime>255 then
        Begin
          DrawStretch(HudImages.Image['d_'+inttostr(dialpicN)],0,  trunc((800-328)*ResolutionScaleX),
            trunc((60)*ResolutionScaleY),trunc((800-128)*ResolutionScaleX),
            trunc((60+200)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend);

          DrawStretch(HudImages.Image['dial2'],0,  trunc((800-510)*ResolutionScaleX),
            trunc((50)*ResolutionScaleY),trunc((800-310)*ResolutionScaleX),
            trunc((50+64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend);

          DrawStretch(HudImages.Image['dial'],0,  trunc((1600-312)*ResolutionScaleX/2),
            trunc((50)*ResolutionScaleY),trunc((1600+1112)*ResolutionScaleX/2),
            trunc((50+128)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,trunc(255*(100-Hudt)/100)),fxBlend)
        End
          else
          Begin
             //dialtime:=dialtime-lagcount*3;

             DrawStretch(HudImages.Image['d_'+inttostr(dialpicN)],0,  trunc((800-328)*ResolutionScaleX),
              trunc((60+dialtime/2-127)*ResolutionScaleY),trunc((800-128)*ResolutionScaleX),
              trunc((60+200+dialtime/2-127)*ResolutionScaleY),false,false,
              cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);

             DrawStretch(HudImages.Image['dial2'],0,  trunc((800-510)*ResolutionScaleX),
              trunc((50+dialtime/2-127)*ResolutionScaleY),trunc((800-310)*ResolutionScaleX),
              trunc((50+64+dialtime/2-127)*ResolutionScaleY),false,false,
              cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);


              DrawStretch(HudImages.Image['dial'],0,  trunc((1600-312)*ResolutionScaleX/2),
                trunc((50+dialtime/2-127)*ResolutionScaleY),trunc((1600+1112)*ResolutionScaleX/2),
                trunc((50+128+dialtime/2-127)*ResolutionScaleY),false,false,
                cRGB4(255,255,255,trunc(dialtime*(100-Hudt)/100)),fxBlend);
          End;

      if dialtime<=255 then
       Fonts[1].TextOut(Pnames[dialpicN],
                (310*ResolutionScaleX),(69+dialtime/2-127)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(dialtime*(100-Hudt)/100)))
        else
          Fonts[1].TextOut(Pnames[dialpicN],
                (310*ResolutionScaleX),(69)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(255*(100-Hudt)/100)));

       for i := 1 to StringN do
         if dialtime<=255 then
          Fonts[1].TextOut(Stringarr[i],
            (759*ResolutionScaleX),(53+20*i+dialtime/2-127)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(dialtime*(100-Hudt)/100)))
            else
              Fonts[1].TextOut(Stringarr[i],
                (759*ResolutionScaleX),(53+20*i)*ResolutionScaleY, cRGB1(250, 250, 255, trunc(255*(100-Hudt)/100)));

    End else
      if (dialtray[1]<>0)and(dialnew=false) then
      Begin
         dialnew:=true;
         Dial:=dialtray[1]-1;
         DialPicN:=StrToInt(Dialog[Dial*5]);
         SymbN:=0;
         StringN:=1;
         dialtime:=0;
         for i:=1 to 31 do
          dialtray[i]:=dialtray[i+1];
      End;

  END ELSE
   begin
     if HaveNewDLG then
     begin
        Fonts[1].Scale:=ResolutionScaleY*0.8;
        i:=0;
        if Radar then
         begin
          i:=110;
          if misshift=0 then
             i:=65;
         end;

        if dialtime<255 then
         dialtime:=dialtime+lagcount;

        j:=trunc(dialtime);
        if j>32 then
                 j:=32;

        if dialtime>255 then
                 dialtime:=255;

        DrawStretch(HudImages.Image['mishud2'],0,
            trunc((-50+j*2+hudXShift)*ResolutionScaleX),
            trunc((138+i)*ResolutionScaleY2),//+10*resdop*ResolutionScaleY),
            trunc((j*2+hudXShift+14)*ResolutionScaleX),
            trunc((138+i)*ResolutionScaleY2+(64)*ResolutionScaleY) {+10*resdop)*ResolutionScaleY)},false,false,
            cRGB4(255,255,255,255-round(Hudt*255/100)),fxBlend);

        if inventory=false then
        if dialtime>40 then
        if dialtime<230 then
        Begin
          k:=trunc(255 - 127*(sin(dialtime*pi/16)+1)*(1-round(Hudt/100)));

          Fonts[1].TextOut(Language[308],
          (80+hudXShift)*ResolutionScaleX,
          (138+i)*ResolutionScaleY2+(32)*ResolutionScaleY-(Fonts[1].TextHeight('!')/2),
          cRGB1(255, 255, 255, k));
          Fonts[1].Scale:=ResolutionScaleY*0.9;

        // k:=trunc(255 - 127*(sin(dialtime*pi/16)+1)*(1-round(Hudt/100)));

          DrawStretch(HudImages.Image['mishud3'],0,
            trunc((-50+j*2+hudXShift)*ResolutionScaleX),
            trunc((138+i)*ResolutionScaleY2),//+10*resdop*ResolutionScaleY),
            trunc((j*2+hudXShift+14)*ResolutionScaleX),
            trunc((138+i)*ResolutionScaleY2+(64)*ResolutionScaleY) {+10*resdop)*ResolutionScaleY)},false,false,
            cRGB4(255,255,255,k),fxBlend);
        End;
     end;
   end;



    if hudt3>0 then
      DrawHud3;

    if hudt2>0 then
    Begin
      DrawHud2;
      TPlayer(_Player).Force.ImpPower:=0;
      {if (inventory2=false) then
        if (takencol<>nil)and(TakenCol is TTile) then
        Begin
          Hud2[7].xmin:=trunc(((takencol.x+takencol.PatternWidth*takencol.ScaleX/2)
              -Engine.WorldX)*Engine.worldScaleX/Mainform.Device.Width*1600);
          Hud2[7].ymin:=trunc(((takencol.y+takencol.PatternHeight*takencol.ScaleY/2)
              -Engine.WorldY)*Engine.worldScaley/Mainform.Device.height*1200);
        End;}
    End;


   if (DialMode)or(DialHudT>0) then
    for I := 1 to 20 do
     if Hud[i].hudtype=15 then
      Begin

      with Hud[i] do
      Begin
        if isRight then
         __x:=((virtualW+xmin+round(Hudt/100*(xmax-xmin)))*ResolutionscaleX)
            else
              __x:=((xmin+round(Hudt/100*(xmax-xmin)))*ResolutionscaleX);
        if isBottom then
          __y:=((1200+ymin+round(Hudt/100*(ymax+DialDopY-ymin)))*ResolutionscaleY2)
             else
              __y:=((ymin+round(Hudt/100*(ymax+DialDopY-ymin)))*ResolutionscaleY2);
        _scale:=(minscale+(Hudt/100*(maxscale-minscale)));

        cx:=__x;
        cy:=__y;
        cscale:=_scale;
        _x:=round(__x);
        _Y:=round(__y);

        _dop:=DialHudT*9*ResolutionscaleY;
        _Y:=_Y+trunc(_dop);
      End;


        Sline(trunc(DialHudT));

         if Hud_currentzone=16 then
           imgname:='Hud10_2'
            else
             imgname:='Hud10_1';



         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);


         _dop2:=500*ResolutionscaleX;

         _dop3:= 900*ResolutionscaleY;

         MyCanvas.FillRect(_x-trunc(_dop2),0,trunc(_dop2*2),_y, crgb1(10,100,200,155),fxBlend);

         { MSG}
         Fonts[1].Scale:=ResolutionScaleY*0.75;

        if AllDialMode then
        Begin
 ///// A

 for j := 0 to 4 do
         Begin

            // xcxc
           if AllDials.Count>25 then
              MyCanvas.FillRect(_x-trunc(_dop2*0.9),trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY),
                            trunc(_dop2*1.7),trunc(_dop3/6.5), crgb1(10,100,200,75),fxBlend)
           else
            if allDials.Count>j*5 then
            Begin
             MyCanvas.FillRect(_x-trunc(_dop2*0.9),trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY),
                            trunc(_dop2*1.8),trunc(_dop3/6.5), crgb1(10,100,200,75),fxBlend);

            End;

          // pic
            _dop:=  trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY);

           if allDials.Count>j*5+Dialpage*5 then
            DrawStretch(HudImages.Image['d_'+AllDials[(j)*5+Dialpage*5]+'_'],0, trunc(_x-_dop2*0.85),
                  trunc(_dop), trunc(_x-_dop2*0.85+_dop3/6.5),
                  trunc(_dop3/6.5+_dop),
                  false,false,cRGB4(255,255,255,250),fxBlend);

          //txt

          if allDials.Count>j*5+Dialpage*5 then
                Fonts[1].TextOut(Pnames[strtoint(allDials[(j)*5+Dialpage*5])]+':',_x-trunc(_dop2*0.5),
                          trunc(_dop3*(j/6-1)+_y+(65)*ResolutionscaleY),cRGB1(255, 255, 255, 255));


          for k := 1 to 4 do
           if allDials.Count>k+j*5+Dialpage*5 then
              Fonts[1].TextOut(allDials[k+(j)*5+Dialpage*5],_x-trunc(_dop2*0.5),
                          trunc(_dop3*(j/6-1)+_y+(k*24+70)*ResolutionscaleY),cRGB1(255, 255, 255, 255));


         End;

         

          if allDials.Count>j*5 then
          Begin
             ///scroll

             DialScroll.minx:=_x+trunc(_dop2*0.85);
             DialScroll.width:=trunc(_dop2*0.1);
             DialScroll.miny:=trunc(_y+60*ResolutionscaleY-_dop3);
             DialScroll.maxy:=trunc(_y+60*ResolutionscaleY-_dop3*0.179);

             DialScroll.height:=trunc((DialScroll.maxy-DialScroll.miny)*25/AllDials.Count);

             DialScroll.Pos:=trunc(DialScroll.miny+(Dialpage/(AllDials.Count/5-5))*
                  (DialScroll.maxy-DialScroll.miny-DialScroll.height));


             MyCanvas.FillRect(DialScroll.minx,DialScroll.miny,
                            DialScroll.width,DialScroll.maxy-DialScroll.miny, crgb1(10,100,200,75),fxBlend);

             MyCanvas.FillRect(DialScroll.minx,trunc(DialScroll.pos),
                            DialScroll.width,DialScroll.height, crgb1(10,100,200,175),fxBlend);

             if scrollchoosed then
              MyCanvas.FillRect(DialScroll.minx,trunc(DialScroll.pos),
                            DialScroll.width,DialScroll.height, crgb1(10,100,200,205),fxBlend);


             if Hud_currentzone=26 then
              DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.miny-DialScroll.width,
                  DialScroll.minx+DialScroll.width,DialScroll.miny,
                  false,false,cRGB4(255,255,255,250),fxBlend)
                else
                  DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.miny-DialScroll.width,
                      DialScroll.minx+DialScroll.width,DialScroll.miny,
                      false,false,cRGB4(255,255,255,150),fxBlend);

             if Hud_currentzone=25 then
              DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.maxy,
                  DialScroll.minx+DialScroll.width,DialScroll.maxy+DialScroll.width,
                  false,true,cRGB4(255,255,255,250),fxBlend)
                else
                  DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.maxy,
                  DialScroll.minx+DialScroll.width,DialScroll.maxy+DialScroll.width,
                  false,true,cRGB4(255,255,255,150),fxBlend)

          End;





 //////-A end
        End
        else
        Begin

         for j := 0 to 4 do
         Begin

            // xcxc
           if LevDials.Count>25 then
              MyCanvas.FillRect(_x-trunc(_dop2*0.9),trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY),
                            trunc(_dop2*1.7),trunc(_dop3/6.5), crgb1(10,100,200,75),fxBlend)
           else
            if LevDials.Count>j*5 then
            Begin
             MyCanvas.FillRect(_x-trunc(_dop2*0.9),trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY),
                            trunc(_dop2*1.8),trunc(_dop3/6.5), crgb1(10,100,200,75),fxBlend);

            End;

          // pic
            _dop:=  trunc(_dop3*(j/6-1)+_y+60*ResolutionscaleY);

           if LevDials.Count>j*5+Dialpage*5 then
            DrawStretch(HudImages.Image['d_'+LevDials[(j)*5+Dialpage*5]+'_'],0, trunc(_x-_dop2*0.85),
                  trunc(_dop), trunc(_x-_dop2*0.85+_dop3/6.5),
                  trunc(_dop3/6.5+_dop),
                  false,false,cRGB4(255,255,255,250),fxBlend);

          //txt

          if LevDials.Count>j*5+Dialpage*5 then
                Fonts[1].TextOut(Pnames[strtoint(LevDials[(j)*5+Dialpage*5])]+':',_x-trunc(_dop2*0.5),
                          trunc(_dop3*(j/6-1)+_y+(65)*ResolutionscaleY),cRGB1(255, 255, 255, 255));


          for k := 1 to 4 do
           if LevDials.Count>k+j*5+Dialpage*5 then
              Fonts[1].TextOut(LevDials[k+(j)*5+Dialpage*5],_x-trunc(_dop2*0.5),
                          trunc(_dop3*(j/6-1)+_y+(k*24+70)*ResolutionscaleY),cRGB1(255, 255, 255, 255));


         End;

         

          if LevDials.Count>j*5 then
          Begin
             ///scroll

             DialScroll.minx:=_x+trunc(_dop2*0.85);
             DialScroll.width:=trunc(_dop2*0.1);
             DialScroll.miny:=trunc(_y+60*ResolutionscaleY-_dop3);
             DialScroll.maxy:=trunc(_y+60*ResolutionscaleY-_dop3*0.179);

             DialScroll.height:=trunc((DialScroll.maxy-DialScroll.miny)*25/LevDials.Count);

             DialScroll.Pos:=trunc(DialScroll.miny+(Dialpage/(LevDials.Count/5-5))*
                  (DialScroll.maxy-DialScroll.miny-DialScroll.height));


             MyCanvas.FillRect(DialScroll.minx,DialScroll.miny,
                            DialScroll.width,DialScroll.maxy-DialScroll.miny, crgb1(10,100,200,75),fxBlend);

             MyCanvas.FillRect(DialScroll.minx,trunc(DialScroll.pos),
                            DialScroll.width,DialScroll.height, crgb1(10,100,200,175),fxBlend);

             if scrollchoosed then
              MyCanvas.FillRect(DialScroll.minx,trunc(DialScroll.pos),
                            DialScroll.width,DialScroll.height, crgb1(10,100,200,205),fxBlend);


             if Hud_currentzone=26 then
              DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.miny-DialScroll.width,
                  DialScroll.minx+DialScroll.width,DialScroll.miny,
                  false,false,cRGB4(255,255,255,250),fxBlend)
                else
                  DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.miny-DialScroll.width,
                      DialScroll.minx+DialScroll.width,DialScroll.miny,
                      false,false,cRGB4(255,255,255,150),fxBlend);

             if Hud_currentzone=25 then
              DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.maxy,
                  DialScroll.minx+DialScroll.width,DialScroll.maxy+DialScroll.width,
                  false,true,cRGB4(255,255,255,250),fxBlend)
                else
                  DrawStretch(MenuImages.Image['mnu_arrow'],0, DialScroll.minx,DialScroll.maxy,
                  DialScroll.minx+DialScroll.width,DialScroll.maxy+DialScroll.width,
                  false,true,cRGB4(255,255,255,150),fxBlend)

          End;
        End;


       //  if HiDet then
       //  Begin
           { DrawStretch(MenuImages.Image['kletk'],0, _x+trunc(_dop3/10),
              _y-trunc(_dop3/5),_x+trunc(_dop2-_h/20),_y,false,false,
              cRGB4(200,200,255,200),fxblend); }

      //   End;

        if LevDials.Count>0 then
        Begin

             if hud_currentzone=75 then
                MyCanvas.FillRect(_x+trunc(_h/2+70*ResolutionscaleX),_y-trunc(85*ResolutionscaleY2),
                  trunc(265*ResolutionscaleX),trunc(50*ResolutionscaleY2),
                  crgb1(10,100,200,75),fxBlend);

          if AllDialMode then
          Begin
           MyCanvas.FillRect(_x+trunc(_h/2+75*ResolutionscaleX),_y-trunc(80*ResolutionscaleY2),
              trunc(150*ResolutionscaleX),trunc(40*ResolutionscaleY2),
              crgb1(10,100,200,75),fxBlend);


           MyCanvas.FillRect(_x+trunc(_h/2+230*ResolutionscaleX),_y-trunc(80*ResolutionscaleY2),
              trunc(100*ResolutionscaleX),trunc(40*ResolutionscaleY2),
              crgb1(10,100,200,205),fxBlend);
          End else
          Begin
           MyCanvas.FillRect(_x+trunc(_h/2+75*ResolutionscaleX),_y-trunc(80*ResolutionscaleY2),
              trunc(150*ResolutionscaleX),trunc(40*ResolutionscaleY2),
              crgb1(10,100,200,205),fxBlend);

           MyCanvas.FillRect(_x+trunc(_h/2+230*ResolutionscaleX),_y-trunc(80*ResolutionscaleY2),
              trunc(100*ResolutionscaleX),trunc(40*ResolutionscaleY2),
              crgb1(10,100,200,75),fxBlend);
          End;

           { DrawStretch(MenuImages.Image['kletk'],0, _x+trunc(_dop3/10),
              _y-trunc(_dop3/5),_x+trunc(_dop2-_h/20),_y,false,false,
              cRGB4(200,200,255,200),fxblend); }
            Fonts[1].Scale:=ResolutionScaleY2*0.72;
            st:=Language[241];                                           // x
            Fonts[1].TextOut(st,_x+trunc(_h/2+150*ResolutionscaleX)-Fonts[1].textwidth(st)/2, _Y-trunc(70*ResolutionscaleY2),
              cRGB1(255, 255, 255, 255));
            st:=Language[242];
            Fonts[1].TextOut(st,_x+trunc(_h/2+280*ResolutionscaleX)-Fonts[1].textwidth(st)/2, _Y-trunc(70*ResolutionscaleY2),
              cRGB1(255, 255, 255, 255))
        End
          else
           begin
             MyCanvas.FillRect(_x+trunc(_h/2+230*ResolutionscaleX),_y-trunc(80*ResolutionscaleY2),
              trunc(100*ResolutionscaleX),trunc(40*ResolutionscaleY2),
              crgb1(10,100,200,205),fxBlend);

             Fonts[1].Scale:=ResolutionScaleY*0.7;

             st:=Language[242];
             Fonts[1].TextOut(st,_x+trunc(_h/2+280*ResolutionscaleX)-Fonts[1].textwidth(st)/2, _Y-trunc(70*ResolutionscaleY2),
                cRGB1(255, 255, 255, 255))
           end;

         DrawStretch(HudImages.Image['Hud10_3'],0, _x,
              _y-trunc(_dop3/18){_h div 4},_x{+_w div 2}+trunc(_dop2+_h/20),_y,false,false,
              cRGB4(255,255,255,255),fxBlend);

         DrawStretch(HudImages.Image['Hud10_3'],0, _x-trunc(_dop2+_h/20),
              _y-trunc(_dop3/18){_h div 4},_x{+_w div 2},_y,true,false,
              cRGB4(255,255,255,255),fxBlend);

         if DialDopY>70 then
           Begin
              Fonts[1].Scale:=ResolutionScaleY*1.25;
              st:=Language[181];                                           // x
              Fonts[1].TextOut(st,_x-Fonts[1].textwidth(st)/2, _Y-_dop3-DialDopY*ResolutionScaleY*0.4,
              cRGB1(255, 255, 255, 255));

           End;
             

         DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

      End;


   if inventory then
   Begin
    if ShowDLG=false then
     if HaveNewDLG then
     begin

      //  if dialtime<255 then
      //   dialtime:=dialtime+lagcount;

       if dialtime>=255 then
                 dialtime:=64;

        DrawStretch(HudImages.Image['mishud2'],0,
            trunc((830)*ResolutionScaleX),
            trunc((8)*ResolutionScaleY2),
            trunc((894)*ResolutionScaleX),
            trunc((8)*ResolutionScaleY2+(64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,round(Hudt*255/100)),fxBlend);

        if dialtime<255 then
        Begin
          k:=trunc(200 - 100*(sin(dialtime*pi/32)+1)*(round(Hudt/100)));

          DrawStretch(HudImages.Image['mishud3'],0,
            trunc((830)*ResolutionScaleX),
            trunc((8)*ResolutionScaleY2),
            trunc((894)*ResolutionScaleX),
            trunc((8)*ResolutionScaleY2+(64)*ResolutionScaleY),false,false,
            cRGB4(255,255,255,k),fxBlend);
        End;
     end;



     ShowMyHint;
   End;
      

   if (inventory2=false)and(inventory3=false) then
   Begin
    Fonts[1].Scale:=ResolutionScaleY*0.9;

    if Radar then
    Begin
     Fonts[1].Scale:=ResolutionScaleY*0.75;
     Fonts[1].TextOut(IntToStr(round(Health))+'%',
      (100+hudXShift)*ResolutionScaleX, 10*resdop *ResolutionScaleY2,
      cRGB1(255, 255, 255,255-round(Hudt*255/100)));
      Fonts[1].Scale:=ResolutionScaleY*0.9;
    End
    else
    Fonts[1].TextOut(IntToStr(round(Health))+'%',
      (150+hudXShift)*ResolutionScaleX, 25 *ResolutionScaleY2,
      cRGB1(255, 255, 255,255-round(Hudt*255/100)));

    _h:=round(Fonts[1].TextWidth(IntToStr(Weapons[currentweapon].Count)));
    Fonts[1].TextOut(IntToStr(Weapons[currentweapon].Count),
      (1600-150-_h-hudXShift)*ResolutionScaleX, 25 *ResolutionScaleY2,
      cRGB1(255, 255, 255,255-round(Hudt*255/100)));

   

   End;
    // КУРСОР
    if cursoroncapsule=true then Begin


      if (TakeBox<>nil)or(TakenCapsule<>nil)or(takencol<>nil)or(Pushtile<>nil) then
       DrawStretch(HudImages.Image['Cursor_take'],0, trunc(Mx-27*ResolutionScaleX*normwscale),
      trunc(My-27*ResolutionScaleY*normwscale), trunc(Mx+27*ResolutionScaleX*normwscale),
      trunc(My+27*ResolutionScaleY*normwscale),false,false,
      clWhite4,fxBlend)
       else
          DrawStretch(HudImages.Image['Cursor_nottake'],0, trunc(Mx-27*ResolutionScaleX*normwscale),
      trunc(My-27*ResolutionScaleY*normwscale), trunc(Mx+27*ResolutionScaleX*normwscale),
      trunc(My+27*ResolutionScaleY*normwscale),false,false,
      clWhite4,fxBlend)
    End else
     if (inventory2=false)and(stopmenu=false)and(inventory3=false)and(hintmenu=false)and(maplookmenu=false) then
    DrawStretch(HudImages.Image['Cursor'],0, trunc(Mx-17*ResolutionScaleX*normwscale),
      trunc(My-17*ResolutionScaleY*normwscale), trunc(Mx+17*ResolutionScaleX*normwscale),
      trunc(My+17*ResolutionScaleY*normwscale),false,false,
      cRGB4(round(hudCred[1]),round(HudCGreen[1]),round(HudCBlue[1]),250-round(Hudt*248/100)),
      fxBlend);


    if inmouse<>nil then
    Begin
     if InMouse is Titem then
      DrawStretch(ItemImages.Image[TItem(InMouse).ItemImageName],0, trunc(Mx-40*ResolutionScaleY),
        trunc(My-40*ResolutionScaleY), trunc(Mx+40*ResolutionScaleX),
        trunc(My+40*ResolutionScaleY),false,false,
        cRGB4(255,255,255,round(Hudt*248/100)),
        fxBlend);

     if InMouse is TBonus then
      DrawStretch(ItemImages.Image[TBonus(InMouse).BonusImageName],0, trunc(Mx-40*ResolutionScaleY),
        trunc(My-40*ResolutionScaleY), trunc(Mx+40*ResolutionScaleX),
        trunc(My+40*ResolutionScaleY),false,false,
        cRGB4(255,255,255,round(Hudt*248/100)),
        fxBlend);
    End else
    DrawStretch(HudImages.Image['Cursor2'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,round(Hudt*248/100)),
      fxBlend);
  End;

  if HudXShift>0 then
  Begin
    MyCanvas.Rectangle(Hud_Bounds[1],clBlack,clBlack,fxNone );
    MyCanvas.Rectangle(Hud_Bounds[2],clBlack,clBlack,fxNone );
  End;

  if MapLookMenu then
  Begin
    Sline(trunc(MapLookT*2.5));
    DrawMapLookMenu;
    MouseUpdate;
    hud_currentzone:=0;
  End;

  if HintMenu then
  Begin
     Sline(170);
      hud_currentzone:=0;

     with MyCanvas do
     Begin
     
      FillRect(0,trunc(360*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc(400*resolutionscaleY2),
       crgb1(10,100,200,105),fxBlend);


      DrawStretch(Images.Image['hint'+inttostr(hintn)],0,
      trunc(40*resolutionscaleX),
      trunc(340*resolutionscaleY2),
      trunc((480)*ResolutionScaleY2),
      trunc((780)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,255),
      fxBlend);

      DrawStretch(MenuImages.Image['ramka'],0,
      trunc(20*resolutionscaleX),
      trunc(320*resolutionscaleY2),
      trunc((500)*ResolutionScaleY2),
      trunc((800)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,220),
      fxBlend);

      __h:=round(Fonts[1].TextWidth(Language[24]));
      _dop2:=(Fonts[1].TextHeight(Language[24]));

      showhinticons;

      if (abs(VirtualW*ResolutionScaleX/2-mx)<(__h/2))and
      (my>900 *ResolutionScaleY2-dop2)and(my<900 *ResolutionScaleY2+_dop2*2) then
      Begin
        Fonts[1].TextOut(Language[24],
        (VirtualW*ResolutionScaleX-__h)/2, 900 *ResolutionScaleY2,
          cRGB1(255, 255, 255,255));
       hud_currentzone:=100;
      End else
       Fonts[1].TextOut(Language[24],
      (VirtualW*ResolutionScaleX-__h)/2, 900 *ResolutionScaleY2,
      cRGB1(255, 255, 255,185));


      if ((my>790*resolutionscaleY2)and
        (my<860*resolutionscaleY2)) then
          if (mx>990*resolutionscaleX)and
           (mx<1600*resolutionscaleX) then
             hud_currentzone:=101;
     ////
       _str:=language[239];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);


       if hud_currentzone=101 then
       FillRect(trunc(990*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(810*ResolutionScaleX),
        trunc(50*ResolutionScaleY2),
        crgb1(10,100,200,225),fxBlend)
          else
      FillRect(trunc(990*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(810*ResolutionScaleX),
        trunc(50*ResolutionScaleY2),
        crgb1(10,100,200,120),fxBlend);

      FillRect(trunc(1000*ResolutionScaleX),
        trunc(800*resolutionscaleY2),
        trunc(30*ResolutionScaleX),
        trunc(30*ResolutionScaleY2),
        crgb1(10,100,200,180),fxBlend);

      if hintson then
           DrawStretch(MenuImages.Image['galka'],0,
      trunc(1000*resolutionscaleX),
      trunc(800*resolutionscaleY2),
      trunc((1030)*ResolutionScaleX),
      trunc((830)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,255),
      fxBlend);

      Fonts[1].Scale:=(ResolutionScaleY2)*0.85;

      Fonts[1].TextOut(_str,1050*resolutionscaleX,
          802*resolutionscaleY2,
          cRGB1(255, 255, 255, 255));

    /////////////////


   Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale; /// new060115

   for I := 0 to 6 do
   Begin
      //GlobalTicks:=GlobalTicks+Lagcount;

      st:=curhint[i];///hints[HintN*7+i-7];

      Fonts[1].TextOut(st,700*resolutionscaleX,
          (400+50*(i))*resolutionscaleY2,
          cRGB1(255, 255, 255, 255));
   End;

    DrawStretch(HudImages.Image['Cursor2'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,255),
      fxBlend);
              
       MouseHint;
     End;
     ///
  End;

 // End;

end;

procedure TMainForm.DrawHud2;
var mycolor:Cardinal;
 _x,_y,_h,_w,i,j,k:integer;
 __x,__y,_dop,_dop2:real;
 _scale,_sc:real;
 _color:Tcolor4;
 imgname,tx:string;
begin

 Sline(round(Hudt2));

 for I := 1 to 20 do
 Begin

      with Hud2[i] do
      Begin                                          //
        if isRight then
         __x:=((virtualW-HUDXShift+xmin+round(Hudt2/100*((xmax+HUDXShift)-xmin)))*ResolutionscaleX)
            else
              __x:=((xmin+round(Hudt2/100*(xmax-xmin)))*ResolutionscaleX);
        if isBottom then
          __y:=((1200+ymin+round(Hudt2/100*(ymax-ymin)))*ResolutionscaleY2)
             else
              __y:=((ymin+round(Hudt2/100*(ymax-ymin)))*ResolutionscaleY2);
        _scale:=(minscale+(Hudt2/100*(maxscale-minscale)));

        cx:=__x;
        cy:=__y;
        cscale:=_scale;
        _x:=round(__x);
        _Y:=round(__y);
      End;

      if Hud2[i].hudtype=8 then
      Begin
         imgname:='Hud8_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud2[i].dopr:=_w;

         if i=1 then
          j:=currentweapon
         else
             j:=altweapons[i-1];


        if j>0 then
        Begin
        MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);
        
        MyCanvas.DrawStretch(HudImages.Image['hud8_2'],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(RedW[j],GreenW[j],BlueW[j],100),fxBlend);


        imgname:='hud8_2';

        _sc:=_scale;
        _dop2:=(35-weapons[j].Count)/35;
        _dop:=((_dop2)*HudImages.Image[imgname].VisibleSize.y*_sc*resolutionscaleY);


        _color:=cRGB4(redw[j],Greenw[j],Bluew[j],225);

       if (Hud_CurrentZone=i) then
         _color:=cRGB4(redw[j],Greenw[j],Bluew[j],255);


       MyCanvas.DrawPortion(HudImages.Image[imgname],0, _x-_w / 2,
          _y-(_h / 2)+_dop,
          0, 0,HudImages.Image[imgname].VisibleSize.x,
          HudImages.Image[imgname].VisibleSize.y-round((_dop2)*HudImages.Image[imgname].VisibleSize.y),
          _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
          _color,fxBlend);


      if (Hud_CurrentZone=i) then
      Begin
        tx:=IntToStr(weapons[j].Count);
        Fonts[1].Scale:=ResolutionScaleY*1.5;
        Fonts[1].TextOut(tx, round(_x- Fonts[1].Textwidth(tx)/2),
             round(_y-Fonts[1].TextHeight(tx)/2),cRGB1(255,255,255,200));
      End;

        //fonts.Items[1].TextOut(inttostr(weapons[j].count),_x-_w div 2,_y-_h div 2,crgb1(255,255,255,255),crgb1(255,255,255,255),FxBlend);
      End else
        if j=0 then
        Begin
          MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,round(225*Hudt2/100)),fxBlend);
        End else
          if j=-1 then
          Begin
            MyCanvas.DrawStretch(HudImages.Image['Hud8_4'],0, _x-_w div 2,
                _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
                cRGB4(255,255,255,round(225*Hudt2/100)),fxBlend);
          End;


      End;

      if Hud2[i].hudtype=5 then Begin
          if Hud_currentzone=i then
           imgname:='Hud5_2'
            else
             imgname:='Hud5_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud2[i].dopr:=_w;

        MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

      End;

      if Hud2[i].hudtype=7 then Begin
         imgname:='Hud8_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud2[i].dopr:=_w;
         j:=newcolor;
         k:=newcolorcount;
        MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

        if needcolor<>0 then
           MyCanvas.DrawStretch(HudImages.Image['hud8_9'],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(RedW[needcolor],GreenW[needcolor],BlueW[needcolor],255),fxBlend);


        MyCanvas.DrawStretch(HudImages.Image['hud8_2'],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(RedW[j],GreenW[j],BlueW[j],100),fxBlend);


        imgname:='hud8_2';
        _sc:=_scale;
        _dop2:=(35-k)/35;
        _dop:=((_dop2)*HudImages.Image[imgname].VisibleSize.y*_sc*resolutionscaleY);
        

        _color:=cRGB4(redw[j],Greenw[j],Bluew[j],225);

       if (Hud_CurrentZone=i) then
         _color:=cRGB4(redw[j],Greenw[j],Bluew[j],255);


       MyCanvas.DrawPortion(HudImages.Image[imgname],0, _x-_w / 2,
          _y-(_h / 2)+_dop,
          0, 0,HudImages.Image[imgname].VisibleSize.x,
          HudImages.Image[imgname].VisibleSize.y-round((_dop2)*HudImages.Image[imgname].VisibleSize.y),
          _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
          _color,fxBlend);

      if (Hud_CurrentZone=i)and(j<>0 )and(Hudt2>99) then
      Begin
        tx:=IntToStr(k);
        Fonts[2].Scale:=ResolutionScaleY*1.2;
        Fonts[2].TextOut(tx, round(_x- Fonts[2].Textwidth(tx)/2),
             round(_y-Fonts[2].TextHeight(tx)/2),cRGB1(255,255,255,200));
      End;


      End;

    End;

    if InMouseCol<>0 then
    Begin
      j:=InMouseCol;

      MyCanvas.DrawStretch(HudImages.Image['Hud8_3'],0, trunc(Mx-40*ResolutionScaleX),
      trunc(My-40*ResolutionScaleX), trunc(Mx+40*ResolutionScaleX),
      trunc(My+40*ResolutionScaleY),false,false,
      cRGB4(RedW[j],GreenW[j],BlueW[j],255),
      fxBlend);
    End;

    MyCanvas.DrawStretch(HudImages.Image['Cursor2'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,round(Hudt2*248/100)),
      fxBlend);


end;

procedure TMainForm.DrawHud3;
var
_x,_y,_h,_w,i,j,ii,dist:integer;
__x,__y,cx,cy,_scale,_sc,_dop,_dop2:real;
imgname,imgname2,str:string;
_color:TColor4;
begin
///
 Sline(round(Hudt3*2));


for I := 1 to 10 do
 Begin

      with Hud3[i] do
      Begin
        if isRight then
         __x:=((virtualW-HudXShift+xmin+round(Hudt3/100*(xmax+HudXShift-xmin)))*ResolutionscaleX)
            else
              __x:=((xmin+HudXShift+round(Hudt3/100*(xmax-HudXShift-xmin)))*ResolutionscaleX);
        if isBottom then
          __y:=((1200+ymin+round(Hudt3/100*(ymax-ymin)))*ResolutionscaleY2)
             else
              __y:=((ymin+round(Hudt3/100*(ymax-ymin)))*ResolutionscaleY2);
        _scale:=(minscale+(Hudt3/100*(maxscale-minscale)));

        cx:=__x;
        cy:=__y;
        cscale:=_scale;
        _x:=round(__x);
        _Y:=round(__y);
      End;

      if Hud3[i].hudtype=3 then Begin
         imgname:='Hud3_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);

            if (InMouse<>nil) then
              if (InMouse is TItem) then
                imgname:='Hud3_1_1';

         MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);

      End;
        if Hud3[i].hudtype=4 then Begin
          imgname:='Hud4_1';

         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);


            if (InMouse<>nil) then
              if (InMouse is TBonus) then
                imgname:='Hud4_1_1';

         MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,205),fxBlend);

      End;

      if Hud3[i].hudtype=1 then Begin
      /// Предметы
          imgname:='Hud8_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud3[i].dopr:=_w;
         dist:=trunc(_w/1.75*1.1);

            if magzinit1=false then
              if hudt3=100 then
              Begin
                 for Ii := 1 to 3 do
                  for j := 1 to 3 do
                    Begin
                      hud_hotzones[24+(j-1)*3+ii].x:=trunc(dist*(ii-2)/ResolutionscaleX);
                      hud_hotzones[24+(j-1)*3+ii].y:=trunc(dist*(j-2)/ResolutionscaleX);
                      hud_hotzones[24+(j-1)*3+ii].h:=trunc(dist/ResolutionscaleX);
                      hud_hotzones[24+(j-1)*3+ii].w:=trunc(dist/ResolutionscaleX);
                      hud_hotzones[24+(j-1)*3+ii].no:=1;
                    End;
                magzinit1:=true;
              End;


          for Ii := 1 to 3 do
           for j := 1 to 3 do
           Begin

           if MagzLev>=j*2-2 then
            Begin
              MyCanvas.DrawStretch(HudImages.Image[imgname],0,
              trunc(_x-_w/3.5+dist*(ii-2)),
              trunc(_y-_h/3.5+dist*(j-2)),
              trunc(_x+_w/3.5+dist*(ii-2)),
              trunc(_y+_h/3.5+dist*(j-2)),false,false,
              cRGB4(255,255,255,225),fxBlend);
              _color:=Crgb4( redw[MagzObjs[(j-1)*3+ii].color],
                          greenw[MagzObjs[(j-1)*3+ii].color],
                          bluew[MagzObjs[(j-1)*3+ii].color],200);
              if Hud_currentzone=24+(j-1)*3+ii then
                _color:=Crgb4( redw[MagzObjs[(j-1)*3+ii].color],
                          greenw[MagzObjs[(j-1)*3+ii].color],
                          bluew[MagzObjs[(j-1)*3+ii].color],255);
              MyCanvas.DrawStretch(HudImages.Image['Hud8_2'],0,
              trunc(_x-_w/3.5+dist*(ii-2)),
              trunc(_y-_h/3.5+dist*(j-2)),
              trunc(_x+_w/3.5+dist*(ii-2)),
              trunc(_y+_h/3.5+dist*(j-2)),false,false,
              _color,fxBlend);
              MyCanvas.DrawStretch(ItemImages.Image[MagzObjs[(j-1)*3+ii].img],0,
              _x-_w div 6+dist*(ii-2),
              _y-_h div 6+dist*(j-2),
              _x+_w div 6+dist*(ii-2),
              _y+_h div 6+dist*(j-2),false,false,
              cRGB4(255,255,255,255),fxBlend);
            End else
            MyCanvas.DrawStretch(HudImages.Image['Hud8_4'],0,
              trunc(_x-_w/3.5+dist*(ii-2)),
              trunc(_y-_h/3.5+dist*(j-2)),
              trunc(_x+_w/3.5+dist*(ii-2)),
              trunc(_y+_h/3.5+dist*(j-2)),false,false,
              cRGB4(255,255,255,225),fxBlend);
           End;
      End;
      if Hud3[i].hudtype=2 then Begin
      /// Бонусы
          imgname:='Hud8_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud3[i].dopr:=_w;
         dist:=trunc(_w/1.75*1.1);

             if magzinit2=false then
              if hudt3=100 then
              Begin
                 for Ii := 1 to 2 do
                  for j := 1 to 3 do
                    Begin
                      hud_hotzones[33+(j-1)*2+ii].x:=trunc(dist*(ii-2)/ResolutionscaleX);
                      hud_hotzones[33+(j-1)*2+ii].y:=trunc(dist*(j-2)/ResolutionscaleX);
                      hud_hotzones[33+(j-1)*2+ii].h:=trunc(dist/ResolutionscaleX);
                      hud_hotzones[33+(j-1)*2+ii].w:=trunc(dist/ResolutionscaleX);
                      hud_hotzones[33+(j-1)*2+ii].no:=2;
                    End;
                magzinit2:=true;
              End;

          for Ii := 1 to 2 do
           for j := 1 to 3 do
           Begin
                   // zxzx
            if MagzLev>=j*2-1 then
            Begin
              MyCanvas.DrawStretch(HudImages.Image[imgname],0,
                trunc(_x-_w/3.5+dist*(ii-2)),
                trunc(_y-_h/3.5+dist*(j-2)),
                trunc(_x+_w/3.5+dist*(ii-2)),
                trunc(_y+_h/3.5+dist*(j-2)),false,false,
                cRGB4(255,255,255,225),fxBlend);

              _color:=Crgb4( redw[MagzObjs[(j-1)*2+ii+9].color],
                          greenw[MagzObjs[(j-1)*2+ii+9].color],
                          bluew[MagzObjs[(j-1)*2+ii+9].color],200);

              if Hud_currentzone=33+(j-1)*2+ii then
                _color:=Crgb4( redw[MagzObjs[(j-1)*2+ii+9].color],
                          greenw[MagzObjs[(j-1)*2+ii+9].color],
                          bluew[MagzObjs[(j-1)*2+ii+9].color],255);


              MyCanvas.DrawStretch(HudImages.Image['Hud8_2'],0,
              trunc(_x-_w/3.5+dist*(ii-2)),
              trunc(_y-_h/3.5+dist*(j-2)),
              trunc(_x+_w/3.5+dist*(ii-2)),
              trunc(_y+_h/3.5+dist*(j-2)),false,false,
              _color,fxBlend);
              MyCanvas.DrawStretch(itemImages.Image[MagzObjs[(j-1)*2+ii+9].img],0,
              _x-_w div 6+dist*(ii-2),
              _y-_h div 6+dist*(j-2),
              _x+_w div 6+dist*(ii-2),
              _y+_h div 6+dist*(j-2),false,false,
              cRGB4(255,255,255,255),fxBlend);
            End else
            Begin
              MyCanvas.DrawStretch(HudImages.Image['Hud8_4'],0,
                trunc(_x-_w/3.5+dist*(ii-2)),
                trunc(_y-_h/3.5+dist*(j-2)),
                trunc(_x+_w/3.5+dist*(ii-2)),
                trunc(_y+_h/3.5+dist*(j-2)),false,false,
                cRGB4(255,255,255,225),fxBlend);
            End;
           End;

      End;

      if Hud3[i].hudtype=5 then Begin
          if Hud_currentzone=7 then
           imgname:='Hud5_2'
            else
             imgname:='Hud5_1';
         _h:=round(HudImages.Image[imgname].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image[imgname].VisibleSize.x*ResolutionscaleX*_scale);
         Hud3[i].dopr:=_w;

            MyCanvas.DrawStretch(HudImages.Image[imgname],0, _x-_w div 2,
              _y-_h div 2,_x+_w div 2,_y+_h div 2,false,false,
              cRGB4(255,255,255,225),fxBlend);

        _h:=round(HudImages.Image['hudscore'].VisibleSize.y*ResolutionscaleY*_scale);
         _w:=round(HudImages.Image['hudscore'].VisibleSize.x*ResolutionscaleX*_scale);
        MyCanvas.DrawStretch(HudImages.Image['hudscore'],0, _x-_w div 2,
              _y-_h div 2+round(75*resolutionscaleY),
              _x+_w div 2,
              _y+_h div 2+round(75*resolutionscaleY)
              ,false,false,
              cRGB4(255,255,255,225),fxBlend);
         /// CREDs
        str:=inttostr(Levelscore.total)+' '+Language[41];
        Fonts[1].Scale:=ResolutionScaleY;
        if hudt3>75 then
        Fonts[1].TextOut(str,_x-(Fonts[1].textwidth(str)/2),
        _y+73*resolutionscaleY-(Fonts[1].textheight(str)/2), cRGB1(255, 255, 255, round(10*(hudt3-75)) ));


      End;
 End;



 {ПРЕДМЕТЫ, БОНУСЫ}

 for i:=1 to 4 do
   if items[i]<>nil then
   Begin

    imgname:='Box1';

    imgname2:=items[i].ItemImageName;

    if hudt3<=0 then
      imgname2:=imgname2+'sm';

    if itemImages.Find(imgname2)>-1 then
      imgname:=imgname2;

    imgname2:='Hud3_2';
      if (Hud_CurrentZone=10+i)or(items[i].ItemInUse=true) then
       imgname2:='Hud3_3';

    _scale:=Hud3[hud_hotzones[10+i].no].cscale;
    _x:=trunc(Hud3[hud_hotzones[10+i].no].cx+hud_hotzones[10+i].x*_scale*ResolutionScaleX);
    _y:=trunc(Hud3[hud_hotzones[10+i].no].cy+hud_hotzones[10+i].y*_scale*ResolutionScaleY);
    _sc:=_scale;


    if Hudt3<=0 then Begin
      _sc:=_scale*(HudImages.Image[imgname2].VisibleSize.x)/(HudImages.Image[imgname2+'small'].VisibleSize.x);
      imgname2:=imgname2+'small';
    End;

    _w:=trunc(HudImages.Image[imgname2].VisibleSize.x*ResolutionScaleX*_sc);
    _h:=trunc(HudImages.Image[imgname2].VisibleSize.y*ResolutionScaleY*_sc);

    _dop2:=((items[i].ItemTimeUse-items[i].ItemCurrentTime)/items[i].ItemTimeUse);
    _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*resolutionscaleY*_sc);

    j:=225;
    if Items[i].ItemInUse then
      j:=255;

    _color:=cRGB4(RedW[items[i].ItemColor],GreenW[items[i].ItemColor],BlueW[items[i].ItemColor],j);

    MyCanvas.DrawPortion(HudImages.Image[imgname2],0, (_x-_w / 2),
      (_y-(_h / 2)+_dop), 0, 0, HudImages.Image[imgname2].VisibleSize.x,

      round((1-_dop2)*HudImages.Image[imgname2].VisibleSize.y),
      (_sc*resolutionscaleX),(_sc*resolutionscaleY),false,false,true,
      _color,fxBlend);

   // _w:=round(HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
   // _h:=round(HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);
    _w:=trunc(_w*0.7);
    _h:=trunc(_h*0.7);

    MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    clWhite4,fxBlend);

   End;

   //// Bonuses
    for i:=1 to 3 do
   if Bonuses[i]<>nil then
   Begin

    imgname:='Box1';
    imgname2:=Bonuses[i].BonusImageName;
     if hudt3<=0 then
        imgname2:=imgname2+'sm';
    if itemImages.Find(imgname2)<>-1 then
      imgname:=imgname2;//Bonuses[i].BonusImageName;

    imgname2:='Hud4_2';
      if (Hud_CurrentZone=7+i) then
       imgname2:='Hud4_3';

    _scale:=Hud3[hud_hotzones[7+i].no].cscale;
    _x:=trunc(Hud3[hud_hotzones[7+i].no].cx+hud_hotzones[7+i].x*_scale*ResolutionScaleX);
    _y:=trunc(Hud3[hud_hotzones[7+i].no].cy+hud_hotzones[7+i].y*_scale*ResolutionScaleY);
    _sc:=_scale;

    {if Hudt=0 then Begin
      _sc:=_scale*(HudImages.Image[imgname].VisibleSize.x)/(HudImages.Image[imgname+'small'].VisibleSize.x);
      imgname:=imgname+'small';
    End;}

    _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

    _dop2:=1;
    _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

    j:=200;
    _color:=cRGB4(RedW[Bonuses[i].BonusColor],GreenW[Bonuses[i].BonusColor],BlueW[Bonuses[i].BonusColor],j);


    MyCanvas.DrawStretch(HudImages.Image[imgname2],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    _color,fxBlend);

    _w:=trunc(_w*0.7);//round(HudImages.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
    _h:=trunc(_h*0.7);//round(HudImages.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

    MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
    round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
    clWhite4,fxBlend);
   End;

   //// Items вне инвентаря
   for i:=1 to 6 do
   if inSpace[i]<>nil then

    if InSpace[i] is TItem then
      Begin
        imgname:='Box1';

        if ItemImages.Find(TItem(inSpace[i]).ItemImageName)<>-1 then
          imgname:=TItem(inSpace[i]).ItemImageName;

        imgname2:='Hud3_2';
          if (Hud_CurrentZone=16+i) then
            imgname2:='Hud3_3';

        _scale:=Hud3[hud_hotzones[16+i].no].cscale;
        _x:=trunc(Hud3[hud_hotzones[16+i].no].cx+hud_hotzones[16+i].x*_scale*ResolutionScaleX);
        _y:=trunc(Hud3[hud_hotzones[16+i].no].cy+hud_hotzones[16+i].y*_scale*ResolutionScaleY);
        _sc:=_scale;

        _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

        _dop2:=(Titem(inspace[i]).ItemTimeUse-Titem(InSpace[i]).ItemCurrentTime)/Titem(inSpace[i]).ItemTimeUse;
        _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

        _color:=cRGB4(RedW[Titem(inSpace[i]).ItemColor],
        GreenW[Titem(inSpace[i]).ItemColor],BlueW[Titem(inSpace[i]).ItemColor],205);

        MyCanvas.DrawPortion(HudImages.Image[imgname2],0, _x-_w / 2,
            _y-(_h / 2)+_dop, 0, 0, HudImages.Image[imgname2].VisibleSize.x,
            HudImages.Image[imgname2].VisibleSize.y-round((_dop2)*HudImages.Image[imgname2].VisibleSize.y),
            _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
            _color,fxBlend);

        _w:=trunc(0.7*_w);///round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=trunc(0.7*_h);///round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

        MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
          round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
          clWhite4,fxBlend);
      end
      else
      if InSpace[i] is TBonus then
      Begin
        imgname:='Box1';
        if ItemImages.Find(TBonus(inSpace[i]).BonusImageName)<>-1 then
          imgname:=TBonus(inSpace[i]).BonusImageName;

        imgname2:='Hud4_2';
          if (Hud_CurrentZone=16+i) then
            imgname2:='Hud4_3';

        _scale:=Hud3[hud_hotzones[16+i].no].cscale;
        _x:=trunc(Hud3[hud_hotzones[16+i].no].cx+hud_hotzones[16+i].x*_scale*ResolutionScaleX);
        _y:=trunc(Hud3[hud_hotzones[16+i].no].cy+hud_hotzones[16+i].y*_scale*ResolutionScaleY);
        _sc:=_scale;

        _w:=round(HudImages.Image[imgname2].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=round(HudImages.Image[imgname2].VisibleSize.y*_scale*ResolutionScaleY);

        //_dop2:=100;
        _dop:=((_dop2)*HudImages.Image[imgname2].VisibleSize.y*_sc*resolutionscaleY);

        _color:=cRGB4(RedW[TBonus(inSpace[i]).BonusColor],
        GreenW[TBonus(inSpace[i]).BonusColor],BlueW[TBonus(inSpace[i]).BonusColor],205);

        {MyCanvas.DrawPortion(HudImages.Image[imgname2],0, _x-_w / 2,
            _y-(_h / 2)+_dop, 0, 0, HudImages.Image[imgname2].VisibleSize.x,
            HudImages.Image[imgname2].VisibleSize.y-round((_dop2)*HudImages.Image[imgname2].VisibleSize.y),
            _sc*resolutionscaleX,_sc*resolutionscaleY,false,false,true,
            _color,fxBlend);}
         MyCanvas.DrawStretch(HudImages.Image[imgname2],0, round(_x-_w/2),
            round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
            _color,fxBlend);

        _w:=trunc(0.7*_w);//round(Images.Image[imgname].VisibleSize.x*_scale*ResolutionScaleX);
        _h:=trunc(0.7*_h);//round(Images.Image[imgname].VisibleSize.y*_scale*ResolutionScaleY);

        MyCanvas.DrawStretch(ItemImages.Image[imgname],0, round(_x-_w/2),
          round(_y-_h/2),round(_x+_w/2),round(_y+_h/2),false,false,
          clWhite4,fxBlend);

    End;



 with MyCanvas Do
 Begin
  if inmouse<>nil then
    Begin
     if InMouse is Titem then
      DrawStretch(ItemImages.Image[TItem(InMouse).ItemImageName],0, trunc(Mx-40*ResolutionScaleY),
        trunc(My-40*ResolutionScaleY), trunc(Mx+40*ResolutionScaleX),
        trunc(My+40*ResolutionScaleY),false,false,
        cRGB4(255,255,255,round(Hudt3*248/100)),
        fxBlend);

     if InMouse is TBonus then
      DrawStretch(ItemImages.Image[TBonus(InMouse).BonusImageName],0, trunc(Mx-40*ResolutionScaleY),
        trunc(My-40*ResolutionScaleY), trunc(Mx+40*ResolutionScaleX),
        trunc(My+40*ResolutionScaleY),false,false,
        cRGB4(255,255,255,round(Hudt3*248/100)),
        fxBlend);
    End else
    DrawStretch(HudImages.Image['Cursor2'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,round(Hudt3*248/100)),
      fxBlend);

    /// Хинты
    ShowMyHint;
 End;
end;

procedure TMainForm.DrawMapLookMenu;
var i,j,k,x1,y1,x2,y2,_x,_y,bx,by,bx2,by2,al,i1,i2,j1,j2,fx1,fx2,fy1,fy2:integer;
    _dop,_dop2,sx,sy:real;
    needdraw:boolean;
    hcount,sdv:byte;
    hstr:array[1..4]of string;
    col,col2:tcolor4;
    litera:string[1];
begin
///
///
   if MapLookT<100 then
     MapLookT:=MapLookT+Lagcount*2;
   if MapLookT>100 then
     MapLookT:=100;


   if ShowMicro then
   Begin
     if MicroT<100 then
       MicroT:=MicroT+Lagcount*2;
        if MicroT>100 then
          MicroT:=100;
   End
    else
     begin
        if MicroT>0 then
        MicroT:=MicroT-Lagcount*4;
         if MicroT<0 then
            MicroT:=0;
     end;

  KeysUpdate;
  _dop:=3*resolutionscaleX;
  _dop2:=3*resolutionscaleY;
  _x:=device.Width div 2;
  _y:=device.Height div 2;
  sx:=5*_dop+1;
  sy:=5*_dop2+1;
  bx:=trunc(_x-525*resolutionscaleX);
  by:=trunc(_y-375*resolutionscaleY);
  bx2:=trunc((1050)*resolutionscaleX);
  by2:=trunc((750)*resolutionscaleY);
  hcount:=0;

  if MapLookX<2500 then
     MapLookX:=2500;
  if MapLookY<2000 then
     MapLookY:=2000;
  if MapLookX>MapSizeX*100-2500 then
     MapLookX:=MapSizeX*100-2500;
  if MapLookY>MapSizeY*100-2000 then
     MapLookY:=MapSizeY*100-2000;

  col2:=cRGB4(150,150,255,255);
  col:=cRGB4(155,205,255,255);



  with Mycanvas do
  Begin
      FillRect(bx,by,bx2,by2
                ,crgb1(70,70,255,50),fxBlend);

        // 06.11.15 begin
      if MapLookT=100 then
        if MapZonesCount>0 then

         for I := 1 to MapZonesCount do
         Begin
              /// Обозначаю границы
              i1:= trunc(MapZones[i].ZoneRect.Left);
              i2:= trunc(MapZones[i].ZoneRect.Right);
              j1:= trunc(MapZones[i].ZoneRect.Top);
              j2:= trunc(MapZones[i].ZoneRect.Bottom);

              x1 := trunc(_x-(MapLookX-i1)/20*_dop);
              y1 := trunc(_y-(MapLookY-j1)/20*_dop);
              x2 := trunc(_x-(MapLookX-i2)/20*_dop);
              y2 := trunc(_y-(MapLookY-j2)/20*_dop);
              /// Проверяю границы

              if (x2>bx)and(x1<bx+bx2)and(y2>by)and(y1<by+by2) then
               Begin
                
                /// корректирую
                if x1<bx then
                    x1:=bx;
                if y1<by then
                    y1:=by;
                if x2>bx+bx2 then
                    x2:=bx+bx2;
                if y2>by+by2 then
                    y2:=by+by2;
                               //  sfs
                /// рисую
                 FillRect(x1,y1,x2-x1,y2-y1,crgb1(19,57,100,250),fxBlend);
            End;
         End;    // vcxvcxv

         // 06.11.15 end

        i1:=trunc(MapLookx/100-35);
        i2:=trunc(MapLookx/100+35);
        j1:=trunc(MapLooky/100-25);
        j2:=trunc(MapLooky/100+25);

        if MapLookT>=100 then
              for  j:=i1 to i2 do
                for  k:=j1 to j2 do
                Begin
                   x1:=round((MapLookX-j*100)/20*_dop);
                   y1:=round((MapLooky-k*100)/20*_dop2);

                     if (j>=0)and(k>=0)and(j<=mapsizex)and(k<=mapsizey) then
                     Begin
                      if larr[j,k]>0 then
                           DrawStretch(MMImages.Image['mm12'],0,_x-x1 ,_y-y1,
                            sx,sy,1,1,false,false,false,
                             cRGB4(RedW[larr[j,k]],GreenW[larr[j,k]],Bluew[larr[j,k]],250),fxBlend);

                      if SMMap[j,k]<>0 then
                          DrawStretch(MMImages.Image['mm'+inttostr(SMMap[j,k])],0,
                           _x-x1,_y-y1,sx,sy,1,1,false,false,false,
                            col,fxBlend);


                     End else
                       Begin
                         DrawStretch(MMImages.Image['mmend'],0,_x-x1,_y-y1,
                            sx,sy,1,1,false,false,false,
                            col,fxBlend);
                       End;
              End;

            /// FOW    FOW

             { i1:=trunc(MapLookx/1000-35);
              i2:=trunc(MapLookx/1000+35);
              j1:=trunc(MapLooky/1000-25);
              j2:=trunc(MapLooky/1000+25);

              for  j:=i1  to i2  do
                for  k:=j1  to j2  do
                Begin
                   x1:=round((MapLookX-j*1000)/20*_dop);
                   y1:=round((MapLooky-k*1000)/20*_dop2);
                   if (j>=0)and(k>=0)and(j<=mapsizex div 10)and(k<=mapsizey div 10) then
                      if FogOfWar[j ,k ]=false then
                      Begin
                         fx1:=trunc((j-1)*10-x1+_x);
                         fy1:=trunc((k-1)*10-y1+_y);

                         fx2:=trunc(sx*10);
                         fy2:=trunc(sy*10);

                         if fx1<bx then
                         begin
                          fx2:=fx1-bx;
                          fx1:=bx;
                          if fx2<0 then fx2:=0;

                         end;

                         if fy1<by then
                         begin
                          fy2:=fy1-by;
                          fy1:=by;
                          if fy2<0 then fy2:=0;
                         end;

                         if fx2+fx1>bx2+bx then
                           fx2:=bx2+bx-fx1;
                          if fy2+fy1>by2+by then
                           fy2:=by2+by-fy1;

                         FillRect(fx1,fy1,fx2,fy2,crgb1(70,70,255,150),fxBlend);
                      End;
                End;
              }
       if MapLookT>=100 then
         for I := 1 to MapLookObjsCount do
            if (abs(MapLookObjs[i].ObjX-MapLookx/100)<35)
              and(abs(MapLookObjs[i].ObjY-MapLooky/100)<25) then
               Begin
                     needdraw:=true;

                     case MapLookObjs[i].ObjTip of
                        1,5..7,10,21,35,-1: needdraw:=mapshow1;
                        2,3,8,14..17,33,-2: needdraw:=mapshow2;
                        4,11,19,9,-3: needdraw:=mapshow3;
                        -4: needdraw:=false;
                     end;


                 if needdraw then
                 Begin
                  x1:=round((MapLookX-MapLookObjs[i].ObjX*100)/20*_dop);
                  y1:=round((MapLooky-MapLookObjs[i].ObjY*100)/20*_dop2);

                  al:=0;
                  if (abs(mx-_x+x1-sx*0.5)<sx*1.5)and(abs(my-_y+y1-sy*0.5)<sy*1.5) then
                  Begin
                   if hcount<3 then
                   Begin
                     al:=55;
                     inc(hcount);
                     hstr[hcount]:=hstr[hcount]+Language[129+MapLookObjs[i].ObjTip];
                     case MapLookObjs[i].ObjTip of
                        -3..-1: Begin
                          hstr[hcount]:=Language[310];
                        End;
                        1,5,6: Begin
                        hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor];
                        if MapLookObjs[i].Objenabled then
                         hstr[hcount]:=hstr[hcount]+Language[161]
                          else hstr[hcount]:=hstr[hcount]+Language[162];
                         End;
                        2,3,14:Begin
                        hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor];
                        if MapLookObjs[i].Objenabled then
                         hstr[hcount]:=hstr[hcount]+Language[159]
                          else hstr[hcount]:=hstr[hcount]+Language[160];
                        End;
                        4,8,11,19:Begin
                          hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor];
                        End;
                        15..17: Begin
                          hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor];
                          hstr[hcount]:=hstr[hcount]+Language[159]+' *'
                            +inttostr(MapLookObjs[i].ObjTip-13);
                         End;
                        7,9:Begin
                        hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor];
                        if MapLookObjs[i].Objenabled then
                         hstr[hcount]:=hstr[hcount]+Language[164]
                          else hstr[hcount]:=hstr[hcount]+Language[163];
                         End;
                        10:Begin
                         if MapLookObjs[i].Objenabled then
                         hstr[hcount]:=hstr[hcount]+Language[150+MapLookObjs[i].ObjColor]+Language[164]
                          else hstr[hcount]:=hstr[hcount]+Language[163];
                        End;
                        21: Begin
                        hstr[hcount]:=Language[165]+Language[150+MapLookObjs[i].ObjColor];
                        if MapLookObjs[i].Objenabled then
                         hstr[hcount]:=hstr[hcount]+Language[164]
                          else hstr[hcount]:=hstr[hcount]+Language[163];
                         End;
                        22,23: Begin
                          hstr[hcount]:=Language[166];
                        End;
                        24..26: Begin
                          hstr[hcount]:=Language[167+MapLookObjs[i].ObjTip-24];
                        End;
                        35: Begin
                          hstr[hcount]:=Language[237]+Language[150+MapLookObjs[i].ObjColor];
                          if MapLookObjs[i].Objenabled then
                            hstr[hcount]:=hstr[hcount]+Language[238]
                        End;
                        27,28,29,30: Begin
                          hstr[hcount]:='';
                          dec(hcount);
                        End;
                        31: Begin
                          hstr[hcount]:=Language[190];
                        End;
                        32: Begin
                          hstr[hcount]:=Language[191];
                        End;
                        33: Begin
                          hstr[hcount]:=Language[192];
                        End;
                     end;
                   End;
                  End;


                   litera:='';
                    col:=CRgb4(RedW[MapLookObjs[i].ObjColor],
                              GreenW[MapLookObjs[i].ObjColor],
                              BlueW[MapLookObjs[i].ObjColor],200+al);

                   if MapLookObjs[i].ObjTip<0 then
                     col:=CRgb4(RedW[5] div 2,
                              GreenW[5] div 2,
                              BlueW[5] div 2,200+al);

                   if MapLookObjs[i].ObjEnabled then
                      litera:='a'
                       else
                         litera:='b';

                    case MapLookObjs[i].ObjTip of
                     1,5,6: Begin
                       if litera='a' then
                         litera:='b'
                           else
                            litera:='a'
                          End;
                     End;

                  //col:=clWhite4;
                {  if MapLookObjs[i].ObjEnabled then
                   col:=CRgb4(RedW[MapLookObjs[i].ObjColor],
                              GreenW[MapLookObjs[i].ObjColor],
                              BlueW[MapLookObjs[i].ObjColor],200+al)
                   else
                   col:=CRgb4(RedW[MapLookObjs[i].ObjColor]div 2,
                              GreenW[MapLookObjs[i].ObjColor]div 2,
                              BlueW[MapLookObjs[i].ObjColor]div 2,200+al); }


                  case MapLookObjs[i].ObjTip of
                        1,7,10,35,-1: DrawStretch(MMImages.Image['mmfon'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,col,fxBlend);
                        5: DrawStretch(MMImages.Image['mmfon2'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,col,fxBlend);
                        6: DrawStretch(MMImages.Image['mmfon2'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,true,false,col,fxBlend);
                        2,3,8,14..17,33,-2: DrawStretch(MMImages.Image['mmfon3'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,col,fxBlend);
                        20: DrawStretch(MMImages.Image['mmfon'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,clwhite4,fxBlend);
                        4,11,19,9,-3: DrawStretch(MMImages.Image['mmfon4'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,col,fxBlend);

                      //  9: DrawStretch(MMImages.Image['obj9'],0,_x-x1-sx ,_y-y1-sy,
                      //      sx*3,sx*3,1,1,false,false,false,col,fxBlend);

                        21: DrawStretch(MMImages.Image['mmfon5'+litera],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,col,fxBlend);
                  end;
                    k:=MapLookObjs[i].ObjTip;
                    if (k=33)or(k=35) then k:=32;
                    if (k<-1) then k:=-1;
                    //if MapLookObjs[i].ObjTip<>9 then
                    DrawStretch(MMImages.Image['Obj'+inttostr(k)],0,_x-x1-sx ,_y-y1-sy,
                            sx*3,sx*3,1,1,false,false,false,clwhite4,fxBlend);

               end;
            End;


         DrawStretch(Images.Image['border2'],0,bx ,by,
                            bx2,sx*2,1,1,false,false,false,
                            cRGB4(150,150,255,255),fxBlend);
         DrawStretch(Images.Image['border2'],0,bx ,by+by2-sy*2,
                            bx2,sx*2,1,1,false,false,true,
                            cRGB4(150,150,255,255),fxBlend);
         DrawStretch(Images.Image['border1'],0,bx ,by,
                            sx*2,by2,1,1,false,false,false,
                            cRGB4(150,150,255,255),fxBlend);
         DrawStretch(Images.Image['border1'],0,bx+bx2-sx*2 ,by,
                            sx*2,by2,1,1,false,true,false,
                            cRGB4(150,150,255,255),fxBlend);


         DrawStretch(HudImages.Image['border3'],0,bx ,by-sy*2,
                            bx2,sy*2,1,1,false,false,false,
                            clwhite4,fxBlend);
         DrawStretch(HudImages.Image['border3'],0,bx ,by+by2,
                            bx2,sy*2,1,1,false,false,false,
                            clwhite4,fxBlend);
         DrawStretch(HudImages.Image['border4'],0,bx-sx*2 ,by,
                            sx*2,by2,1,1,false,false,false,
                            clwhite4,fxBlend);
         DrawStretch(HudImages.Image['border4'],0,bx+bx2 ,by,
                            sx*2,by2,1,1,false,false,false,
                            clwhite4,fxBlend);

         if canmicro then
         Begin
            if (mx>bx+bx2-sx)and(mx<bx+bx2+3*sx)and(my>by-sy*3)and(my<by+sy) then
              hud_currentzone:=105;

           if Showmicro then
           Begin
              if Hud_currentZone=105 then
                  DrawStretch(HudImages.Image['border8_1'],0,bx+bx2-sx ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend)
                             else
                   DrawStretch(HudImages.Image['border7_1'],0,bx+bx2-sx ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend)

           End else
             begin
               if Hud_currentZone=105 then
                  DrawStretch(HudImages.Image['border8_2'],0,bx+bx2-sx ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend)
                             else
                   DrawStretch(HudImages.Image['border7_2'],0,bx+bx2-sx ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend)

             end;


           if MicroT>0 then
           Begin
           microx:=trunc(bx+bx2-sx-200*ResolutionScaleX);
           microy:=trunc(by+sy);

           Rectangle(trunc(bx+bx2-sx-205*ResolutionScaleX*microt*0.01),
                     trunc(by+sy-5*ResolutionScaleY*microt*0.01),
                     trunc(210*ResolutionScaleX*microt*0.01),
                     trunc(210*ResolutionScaleY*microt*0.01),
                     crgb1(0,50,200,220),crgb1(0,0,0,220),fxblend);

           DrawStretch(HudImages.Image['level'+inttostr(level+1)],0,
                        bx+bx2-sx-200*ResolutionScaleX*microt*0.01 ,by+sy,
                        200*ResolutionScaleX*microt*0.01,200*ResolutionScaleY*microt*0.01
                        ,1,1,false,false,false,
                        clwhite4,fxBlend);
           
           DrawStretch(MenuImages.Image['ramka2'],0,
                        bx+bx2-sx-200*ResolutionScaleX*microt*0.01 ,by+sy,
                        200*ResolutionScaleX*microt*0.01,200*ResolutionScaleY*microt*0.01
                        ,1,1,false,false,false,
                        crgb4(255,255,255,220),fxBlend);

          { DrawStretch(MenuImages.Image['ramka'],0,
                        bx+bx2-sx-210*ResolutionScaleX*microt*0.01,
                        by+sy-10*ResolutionScaleX*microt*0.01,
                        220*ResolutionScaleX*microt*0.01,
                        220*ResolutionScaleY*microt*0.01,
                        1,1,false,false,false,
                        crgb4(255,255,255,220),fxBlend);  }

             if microT>95 then
             begin
                  Rectangle(trunc(microX+micsX+(i1+10)/mss*200*ResolutionScaleX),
                        trunc(microy+micsY+(j1+6)/mss*200*ResolutionScaleY),
                        trunc((i2-i1-18)/mss*200*ResolutionScaleX),
                        trunc((j2-j1-10)/mss*200*ResolutionScaleY)
                        ,crgb1(255,255,255,200),crgb1(255,255,255,50),fxblend);

             end;

           End;

         End else
         DrawStretch(HudImages.Image['border5'],0,bx+bx2-sx ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend);



         DrawStretch(HudImages.Image['border5'],0,bx-sx*3 ,by-sy*3,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend);

         DrawStretch(HudImages.Image['border5'],0,bx-sx*3 ,by+by2-sy,
                            sx*4,sy*4,1,1,false,false,false,
                            clwhite4,fxBlend);
         



         
  /////


         if (abs(mx-(bx+bx2+sx*1.5))<sx*4)and(abs(my-(by+by2/2))<sy*4) then
         Begin
         if Mouse.Pressed[0] then
         Begin
          MapLookX:=MapLookX+lagCount*50;
          DrawStretch(HudImages.Image['scroll_1_3'],0,bx+bx2-sx*2.5 ,by+by2/2-sy*4,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
         End else
         DrawStretch(HudImages.Image['scroll_1_2'],0,bx+bx2-sx*2.5 ,by+by2/2-sy*4,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
         End
            else
            DrawStretch(HudImages.Image['scroll_1_1'],0,bx+bx2-sx*2.5 ,by+by2/2-sy*4,
                sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend);


         if (abs(mx-(bx+bx2/2))<sx*4)and(abs(my-(by-sy))<sy*4) then
         Begin
          if Mouse.Pressed[0] then
          Begin
           MapLookY:=MapLookY-lagCount*50;
           DrawStretch(HudImages.Image['scroll_2_3'],0,bx+bx2/2-sx*4 ,by-sy*5,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
          End else
         DrawStretch(HudImages.Image['scroll_2_2'],0,bx+bx2/2-sx*4 ,by-sy*5,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
         End
            else
             DrawStretch(HudImages.Image['scroll_2_1'],0,bx+bx2/2-sx*4 ,by-sy*5,
               sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend);

         if (abs(mx-(bx-sx))<sx*4)and(abs(my-(by+by2/2))<sy*4) then
         Begin
          if Mouse.Pressed[0] then
          Begin
            MapLookX:=MapLookX-lagCount*50;
            DrawStretch(HudImages.Image['scroll_3_3'],0,bx-sx*5 ,by+by2/2-sy*4,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend);
          End else
         DrawStretch(HudImages.Image['scroll_3_2'],0,bx-sx*5 ,by+by2/2-sy*4,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
         End
            else
            DrawStretch(HudImages.Image['scroll_3_1'],0,bx-sx*5 ,by+by2/2-sy*4,
              sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend);


         if (abs(mx-(bx+bx2/2))<sx*4)and(abs(my-(by+by2+sy))<sy*4) then
         Begin
          if Mouse.Pressed[0] then
          Begin
            MapLookY:=MapLookY+lagCount*50;
            DrawStretch(HudImages.Image['scroll_4_3'],0,bx+bx2/2-sx*4 ,by+by2-sy*3,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
          End else
         DrawStretch(HudImages.Image['scroll_4_2'],0,bx+bx2/2-sx*4 ,by+by2-sy*3,
            sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend)
         End
             else
              DrawStretch(HudImages.Image['scroll_4_1'],0,bx+bx2/2-sx*4 ,by+by2-sy*3,
                sx*8,sy*8,1,1,false,false,false,clwhite4,fxBlend);

         
         
         if (mx>bx)and(mx<bx+bx2)and(my>by)and(my<by+by2) then
           // if not((mouse.pressed[0])and(hud_currentzone=106)) then
                hud_currentzone:=104;

         if (mx>bx+bx2-sx*2)and(mx<bx+bx2+sx*4)
            and(my>by+by2-sx*2)and(my<by+by2+sx*4) then
            hud_currentzone:=100;

         if (my>by+by2+sy*2+12*resolutionscaleY+maplookdopy)
            and(my<by+by2+sy*2+44*resolutionscaleY+maplookdopy) then
            if (mx>bx+bx2*0.8+32*resolutionscaleX)and(mx<bx+bx2*0.8+64*resolutionscaleX) then
               hud_currentzone:=101
               else if (mx>bx+bx2*0.8+80*resolutionscaleX)and(mx<bx+bx2*0.8+112*resolutionscaleX) then
                   hud_currentzone:=102
                   else if (mx>bx+bx2*0.8+129*resolutionscaleX)and(mx<bx+bx2*0.8+161*resolutionscaleX) then
                   hud_currentzone:=103;

         if CanMicro then
         Begin
           if (mx>bx+bx2-sx)and(mx<bx+bx2+3*sx)
            and(my>by-sy*3)and(my<by+sy) then
              hud_currentzone:=105;
            {bx+bx2-sx ,by-sy*3,sx*4,sy*4 }

            if showmicro then
          //  if not((mouse.pressed[0]) and (hud_currentzone=104)) then
              if (mx>microX)and(mx<microX+200*ResolutionScaleX)
                and(my>microY)and(my<microY+200*ResolutionScaleY) then
                  hud_currentzone:=106;
         End;

                     


         DrawStretch(HudImages.Image['scroll_5'],0,bx+bx2*0.8 ,by+by2+sy*2+maplookdopy,
                256*resolutionscaleX,64*resolutionscaleY,
                1,1,false,false,false,clwhite4,fxBlend);

         if mapshow1 then
            DrawStretch(mmImages.Image['mmfon'],0,bx+bx2*0.8+32*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clwhite4,fxBlend)
              else
              DrawStretch(mmImages.Image['mmfon'],0,bx+bx2*0.8+32*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clGray4,fxBlend);


         if mapshow2 then
            DrawStretch(mmImages.Image['mmfon3'],0,bx+bx2*0.8+80*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clwhite4,fxBlend)
                else
                DrawStretch(mmImages.Image['mmfon3'],0,bx+bx2*0.8+80*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clgray4,fxBlend);


         if mapshow3 then
         DrawStretch(mmImages.Image['mmfon4'],0,bx+bx2*0.8+129*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clwhite4,fxBlend)
                else
                DrawStretch(mmImages.Image['mmfon4'],0,bx+bx2*0.8+129*resolutionscaleX
                ,by+by2+sy*2+12*resolutionscaleY+maplookdopy,
                32*resolutionscaleX,32*resolutionscaleY,
                1,1,false,false,false,clgray4,fxBlend);

         if hud_currentzone=100 then
          DrawStretch(HudImages.Image['hud5_2'],0,bx+bx2-sx*2 ,by+by2-sx*2,
                            sx*6,sy*6,1,1,false,false,false,
                            clwhite4,fxBlend)
          else
         DrawStretch(HudImages.Image['hud5_1'],0,bx+bx2-sx*2 ,by+by2-sx*2,
                            sx*6,sy*6,1,1,false,false,false,
                            clwhite4,fxBlend);

          sdv:=0;
          if (hud_currentzone>100)and(hud_currentzone<104) then
          Begin
              inc(hcount);
              sdv:=5;
              hstr[hcount]:=hstr[hcount]+Language[hud_currentzone+72];
          End;

          DrawStretch(HudImages.Image['Cursor3'],0, trunc(Mx),
            trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
            trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
            cRGB4(255,255,255,round(maplookt*248/100)),fxBlend);

         Fonts[1].Scale:=ResolutionScaleY*0.6;

          if hcount<3 then
           sdv:=5;

          if (hcount>0)and(hud_currentzone<>106) then
           for i := 1 to hcount do
           Begin
              
             if hstr[i]<>'' then
             Begin

              MyCanvas.FillRect(round(mx+50*resolutionscaleX),round(my+sdv*4*resolutionscaleY+i*20*resolutionscaleY)
                           ,round(Fonts[1].TextWidth(hstr[i])),trunc(Fonts[1].TextHeight(hstr[i]))
                           ,crgb1(90,90,90,190),fxBlend);

              Fonts[1].TextOut(hstr[i],mx+51*resolutionscaleX,my+sdv*4*resolutionscaleY+20*i*resolutionscaleY, cRGB1(255, 255, 255, 255));

             End;
           End;

  End;

end;

procedure TMainForm.DrawMenu;
var _h,_h2,_w,_x,_y,_alf2,_th:single;
    _alf,i,j,k,_red:integer;
    l,kn:byte;
    _str:string;
begin
if inmenu then
Begin
    Fonts[1].Scale:=ResolutionScaleY2;

   if menuready=true then
    Begin
      if Menut<100 then
        Menut:=Menut+lagcount*2;
      if Menut>100 then
        Menut:=100;
    End;

    if menuready=false then
      Begin
        if Menut>0 then
          Menut:=Menut-lagcount*5;
          if Menut<0 then
          Begin
            Menut:=0;
            menuN:=nextmenu;

            if nextmenu=18 then
              page:=(level-1) div 5;

            if nextmenu=90 then
            Begin
              LoadHints;
            End;

            if nextmenu=2 then
            Begin
             LoadPreviews;
             ReadMapHeader;
             Campaign:=false;
            End;

            if nextmenu=10 then
            Begin
             Campaign:=true;
            End;

            if nextmenu=0 then
            Begin
             StopMenu:=false;
             InMenu:=false;
            End;
             menuready:=true;
          End;
      End;

    _alf:=round(menut)*5;
    if _alf>255 then
      _alf:=255;

    _alf2:=(menut-70)/30;
     if _alf2<0 then _alf2:=0;
 if (Hieffs)and(Hidet) then
   if (menuN=6)or(menun<5)and(menun>0) then
     NewMenu;

 if menuN=1 then
 Begin
   with MyCanvas do
     Begin

      menuticks:=menuticks+lagcount*0.2;
       if menuticks>=35 then
        menuticks:=0;

       if (Hieffs)and(Hidet) then
        Begin
          Fonts[1].Scale:=ResolutionScaleY*1.3;

          Fonts[1].TextOut(language[47],-Fonts[1].TextWidth(language[47])/2+803*resolutionscaleX,
          (LogoY+33)*resolutionscaleY,
          cRGB1(0, 0, 0, trunc(_alf)));

          Fonts[1].Scale:=ResolutionScaleY;

          Fonts[1].TextOut(language[48],-Fonts[1].TextWidth(language[48])/2+803*resolutionscaleX,
          (LogoY+73)*resolutionscaleY,
          cRGB1(0, 0, 0, trunc(_alf)));
        End;


        DrawStretch(Images.Image['shield'],trunc(menuticks),
        trunc(736*ResolutionScaleX),
      trunc(logoy*ResolutionScaleY), trunc(864*ResolutionScaleX),
      trunc((logoy+128)*ResolutionScaleY),false,false,
      cRGB4(255,25,25,(_alf)),
      fxBlend);


       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY*1.3;

      Fonts[1].TextOut(language[47],-Fonts[1].TextWidth(language[47])/2+800*resolutionscaleX,
          (LogoY+30)*resolutionscaleY,
          cRGB1(255, 255, 255, trunc(_alf)));

      Fonts[1].Scale:=ResolutionScaleY;

      Fonts[1].TextOut(language[48],-Fonts[1].TextWidth(language[48])/2+800*resolutionscaleX,
          (LogoY+70)*resolutionscaleY,
          cRGB1(255, 255, 255, trunc(_alf)));


      Fonts[1].Scale:=ResolutionScaleY*0.8;

      l:=trunc(Fonts[1].TextWidth(profnames[slot]));
      k:=trunc(Fonts[1].TextWidth(language[58]));
     

      pfbutton:=k+l;
      pfH:=trunc(Fonts[1].TextHeight('Q'));

      if curbutton=105 then
      Begin
        i:=trunc(10*resolutionscaleX);
        FillRect(trunc(800*resolutionscaleX-(k+l)/2)-i,trunc((1100)*resolutionscaleY2)-i,
          l+k+i*2,pfH+i*2,crgb1(10,100,200,100),fxBlend);

        FillRect(trunc(800*resolutionscaleX-(k+l)/2)+k-i,trunc((1100)*resolutionscaleY2)-i,
          l+i*2,pfH+i*2,crgb1(10,100,200,100),fxBlend);
      End;

      

      Fonts[1].TextOut(language[58]+profnames[slot],800*resolutionscaleX-(k+l)/2,
          (1100)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf)));


      Fonts[1].TextOut(language[118],-Fonts[1].TextWidth(language[118])/2+800*resolutionscaleX,
          (1150)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf)));

     { Fonts[1].TextOut(language[177]+showtime ,-Fonts[1].TextWidth(language[177]+showtime)/2+800*resolutionscaleX,
          (1200)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf)));
}
       {         DrawStretch(Images.Image['shield'],trunc(menuticks),
        trunc(736*ResolutionScaleX),
      trunc(logoy*ResolutionScaleY), trunc(864*ResolutionScaleX),
      trunc((logoy+128)*ResolutionScaleY),false,false,
      cRGB4(255,25,25,(_alf)),
      fxBlend);}

      Fonts[1].Scale:=ResolutionScaleY2;

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
       
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;


      
     End;
 End;

 if menuN=12 then
 Begin
   with MyCanvas do
     Begin

       Fonts[1].Scale:=resolutionscaley2*0.85;

       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);   

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        if profnames[i+1]<>'' then
          _str:=profnames[i+1]
         else
          _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (583+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;
     End;
 End;

 if menuN=17 then
 Begin
   with MyCanvas do
     Begin

       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);   

      Fonts[1].Scale:=ResolutionScaleY2*0.8;
      _w:=trunc(Fonts[1].TextWidth(Language[120])/ 2);
      Fonts[1].TextOut(language[120],_x-_w+Menus[MenuN].buttons[1].x*resolutionscaleX,
          (410-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].Scale:=resolutionscaley2;

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
          _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;
     End;
 End;

 if menuN=13 then
 Begin
   with MyCanvas do
     Begin
       menuticks:=menuticks+lagcount*0.08;
       if menuticks>=2*pi then
         menuticks:=0;

       Fonts[1].Scale:=resolutionscaley*0.85;

       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.8;

      _w:=trunc(Fonts[1].TextWidth(language[55])/ 2);

       Fonts[1].TextOut(language[55],_x-_w+Menus[MenuN].buttons[1].x*resolutionscaleX,
          (503-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2;

       _w:=trunc(Fonts[1].TextWidth(Edit1)/ 2);

       if Sin(menuTicks)>0 then
       Fonts[1].TextOut(Edit1,_x-_w+Menus[MenuN].buttons[0].x*resolutionscaleX,
          (503-Menus[MenuN].buttons[0].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)))
           else
          Fonts[1].TextOut(Edit1+'_',_x-_w+Menus[MenuN].buttons[0].x*resolutionscaleX,
            (503-Menus[MenuN].buttons[0].y)*resolutionscaleY2,
              cRGB1(255, 255, 255, trunc(_alf2*255)));

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin

        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;



     End;
 End;

 if menuN=14 then
 Begin
   with MyCanvas do
     Begin

       Fonts[1].Scale:=resolutionscaley*0.85;

       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;

      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.7;

      _w:=trunc(Fonts[1].TextWidth(language[58])/ 2);

       Fonts[1].TextOut(language[58],_x-_w+Menus[MenuN].buttons[2].x*resolutionscaleX,
          (413-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2;

       _w:=trunc(Fonts[1].TextWidth(Profnames[slot])/ 2);

       Fonts[1].TextOut(Profnames[slot],_x-_w+Menus[MenuN].buttons[1].x*resolutionscaleX,
          (443-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2*0.7;

       _str:= language[124]+inttostr(trunc(100*level/levels.Count))+'%';

       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

       Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[2].x*resolutionscaleX,
          (493-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       _str:=language[125]+language[120+difficulty];

       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

       Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[2].x*resolutionscaleX,
          (518-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       _str:= language[126]+inttostr(allscore);

       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

       Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[2].x*resolutionscaleX,
          (543-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       _str:= language[177]+showtime;

       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

       Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[2].x*resolutionscaleX,
          (568-Menus[MenuN].buttons[1].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      Fonts[1].Scale:=ResolutionScaleY2;

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin

        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;

     End;
 End;
 
  if (menun=5)and(nextmenu=19) then
      Engine.Draw;

  if (menuN=6)or(menun=19) then
 Begin
   if menun=19 then
   Begin
      Engine.Draw;
      sline(round(menut*2));
   End;
   
   with MyCanvas do
     Begin

       _x:=(Menus[MenuN].x+64)*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       FillRect(trunc(_x+492*ResolutionScaleX),
       trunc((600)*ResolutionScaleY2),
       trunc(440*ResolutionScaleX),trunc(Menus[MenuN].h*ResolutionScaleY2),
       crgb1(200,10,10,trunc(_alf*0.6)),fxBlend);

       k:= trunc(_x+(512+200)*ResolutionScaleX);
       for I := 0 to 6 do
       Begin
         
         Fonts[1].Scale:=ResolutionScaleY2*0.7;
        _str:=Language[30+i];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        Fonts[1].TextOut(_str,k-_w,
          round((640+32*i)*ResolutionScaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));
       End;



       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;


      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        if i>=Menus[MenuN].bcount-4  then
        Begin

            Fonts[1].Scale:=ResolutionScaleY2;

        _str:=Language[Menus[MenuN].buttons[i].name];

     //   if i=3 then
         //   if mb1=1 then
       //       _str:=Language[Menus[MenuN].buttons[i].name+1];
        if i=4 then
            if cameramode = cmmove then
              _str:=Language[Menus[MenuN].buttons[i].name+1];
        if i=3 then
            if showDLG=false then
              _str:=Language[Menus[MenuN].buttons[i].name+1];

        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
        End else
        Begin

          Fonts[1].Scale:=ResolutionScaleY2*0.7;
          _str:=Language[Menus[MenuN].buttons[i].name];
          _w:=trunc(Fonts[1].TextWidth(_str)/ 2);


           FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((590+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(30*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*70)),fxBlend);

           j:=0;
          case i of
           1: j:=_MV;
           0: j:=_SV;
           2: j:=trunc(_mspd-1)*25;
          end;

          FillRect(trunc(_x+(74)*resolutionscaleX),
          trunc((590+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
          trunc(360*ResolutionScaleX*j/100),trunc(30*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*170)),fxBlend);

          Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (560+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

        End;

      End;



     End;
 End;

 if menuN=3 then
 Begin
   with MyCanvas do
     Begin

       _x:=(Menus[MenuN].x+56{64})*ResolutionScaleX;

       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       j:=trunc((Menus[MenuN].h)*ResolutionScaleY2*2);

       FillRect(trunc(_x),trunc(_y),
       trunc(396*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= Menus[MenuN].x*ResolutionScaleX;

       _y:=(Menus[MenuN].h*menut*0.01+620-64)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      _y:=(-Menus[MenuN].h*menut*0.01+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      _y:=(-Menus[MenuN].h+580-64)*ResolutionScaleY2;

      if menut>=100 then
      Globalticks:=globalticks+lagcount*0.7;
      Fonts[1].Scale:=resolutionscaley*0.75;
      _th:=Fonts[1].TextHeight('A!!');

      for I := 1 to bout.Count - 1 do
        Begin
         
          _str:=bout[i];
          Fonts[1].Scale:=resolutionscaley;

          if bout[i-1]='' then
            Fonts[1].Scale:=resolutionscaley*0.7;

          
          k:=trunc(_y+j-(Globalticks-i*50)*resolutionscaleY2+_th);

          if (k<_y+j+_th)and(k>_y+_th*3) then
          Begin
            if ((_y+_th+j-k)<127) then
              Fonts[1].TextOut(_str,_x+256*ResolutionScaleX-Fonts[1].TextWidth(_str)/2,
              _y+j-(Globalticks-i*50)*resolutionscaleY2+_th,
              cRGB1(255, 255, 255, trunc(_alf2*(_y+_th+j-k)*2)))
            else
            if ((k-_y-_th*3)<127) then
              Fonts[1].TextOut(_str,_x+256*ResolutionScaleX-Fonts[1].TextWidth(_str)/2,
              _y+j-(Globalticks-i*50)*resolutionscaleY2+_th,
              cRGB1(255, 255, 255, trunc(_alf2*(k-_y-_th*3)*2)))
            else
            Fonts[1].TextOut(_str,_x+256*ResolutionScaleX-Fonts[1].TextWidth(_str)/2,
            _y+j-(Globalticks-i*50)*resolutionscaleY2+_th,
              cRGB1(255, 255, 255, trunc(_alf2*255)));
          End;

        End;

      if k<_y then
        Begin
           nextmenu:=1;
           menuready:=false;
        End;


     End;
 End;

  if (menuN=9)or(menun=20) then
 Begin
   if menun=20 then
   Begin
      Engine.Draw;
      sline(round(menut*2));
   End;

     with MyCanvas do
     Begin
     menuticks:=menuticks+lagcount*0.08;
       if menuticks>=2*pi then
         menuticks:=0;

      // Sline(trunc(_alf/2.5));

  FillRect(0,trunc(80*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((140)*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);


  FillRect(0,trunc(320*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((500)*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

  FillRect(0,trunc(1000*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((90)*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

  {FillRect(trunc(20*resolutionscaleX),trunc(380*resolutionscaleY2),
       trunc(720*ResolutionScaleX),
       trunc((400)*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend); }

  DrawStretch(MenuImages.Image['keys1'],0, trunc(70*ResolutionScaleX),
      trunc(490*ResolutionScaleY2), trunc(326*ResolutionScaleX),
      trunc(746*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,trunc(_alf2*255)),
      fxBlend);

  DrawStretch(MenuImages.Image['keys2'],0, trunc(970*ResolutionScaleX),
      trunc(440*ResolutionScaleY2), trunc(1226*ResolutionScaleX),
      trunc(696*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,trunc(_alf2*255)),
      fxBlend);

   Fonts[1].Scale:=ResolutionScaleY2*1.5;
       _str:=language[60];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
   Fonts[1].TextOut(_str, 800*ResolutionScaleX-_w,
          (128*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=0;//(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

   for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        if i<9 then
        Fonts[1].Scale:=ResolutionScaleY2*0.7
         else    Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-140)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(280*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        if i<9 then
        Begin
          Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
            (575+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
              cRGB1(255, 255, 255, trunc(_alf2*255)));

          if (NewKey=Menus[MenuN].buttons[i].name-60)and(waitforkey) then
          Begin
           if Sin(menuTicks)>0 then _str:=''
              else  _str:='_';
           if Sin(menuTicks*4)<0 then
            FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-140)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
              trunc(280*ResolutionScaleX),trunc(50*resolutionscaleY2),
              crgb1(10,100,200,70),fxBlend);
          End else
          _str:='['+KeyNames[Keycodes[Menus[MenuN].buttons[i].name-61]]+']';
             
          _w:=trunc(Fonts[1].TextWidth(_str)/ 2);   ///

          Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (595+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
              cRGB1(255, 255, 255, trunc(_alf2*255)));



        End else
        Begin
          Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
            (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
              cRGB1(255, 255, 255, trunc(_alf2*255)));

           if i=Menus[MenuN].bcount-1 then
           begin

           {  FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-40)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y+50)*resolutionscaleY2),
              trunc(80*ResolutionScaleX),trunc(100*resolutionscaleY2),
              crgb1(10,100,200,trunc(_alf2*j)),fxBlend);}

             MyCanvas.DrawStretch(HUDImages.Image['mb'+inttostr(mb4+1)+'_'],0,
              trunc(_x+(Menus[MenuN].buttons[i].x+90)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y-20)*resolutionscaleY2),
              trunc(_x+(Menus[MenuN].buttons[i].x+160)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y+65)*resolutionscaleY2),false,false,
              cRGB4(255,255,255,trunc(_alf2*255)),
              fxBlend);

           end;
           if i=Menus[MenuN].bcount-2 then
           begin

             MyCanvas.DrawStretch(HUDImages.Image['mb'+inttostr(mb1+1)+'_'],0,
              trunc(_x+(Menus[MenuN].buttons[i].x+90)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y-20)*resolutionscaleY2),
              trunc(_x+(Menus[MenuN].buttons[i].x+160)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y+65)*resolutionscaleY2),false,false,
              cRGB4(255,255,255,trunc(_alf2*255)),
              fxBlend);

           end;
           if i=Menus[MenuN].bcount-3 then
           begin

             MyCanvas.DrawStretch(HUDImages.Image['mb'+inttostr(mb2+1)+'_'],0,
              trunc(_x+(Menus[MenuN].buttons[i].x+90)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y-20)*resolutionscaleY2),
              trunc(_x+(Menus[MenuN].buttons[i].x+160)*resolutionscaleX),
              trunc((570+Menus[MenuN].buttons[i].y+65)*resolutionscaleY2),false,false,
              cRGB4(255,255,255,trunc(_alf2*255)),
              fxBlend);

           end;


        End;

      End;
 End;
 End;


 if menuN=10 then
 Begin
     with MyCanvas do
     Begin

       Sline(trunc(_alf/2.5));

   FillRect(0,trunc(75*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((70*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);


   FillRect(0,trunc(450*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((200+50*(ScenarioTextEnd-ScenarioTextBegin-4))*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);
   _x:=800*ResolutionScaleX;


   Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale; /// new060115

   for I := ScenarioTextBegin+2 to ScenarioTextEnd do
   Begin
      //GlobalTicks:=GlobalTicks+Lagcount;

      _str:=scenario[i];

      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

      Fonts[1].TextOut(_str,_x-_w,
          (485+50*(i-ScenarioTextBegin-2))*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

   End;

    //// НОМЕР ГЛАВЫ

       Fonts[1].Scale:=ResolutionScaleY2*1.2;
       _str:=scenario[ScenarioTextBegin];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str, _x-_w,
          (90*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      //// НАЗВАНИЕ
//       Fonts[1].Scale:=ResolutionScaleY2*1ю2;
       _str:=scenario[ScenarioTextBegin+1];
       _w:=trunc(Fonts[1].TextWidth(_str));

       FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(225*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((58*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (235*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));


       Fonts[1].Scale:=ResolutionScaleY2*0.8;
       if level=0 then
         _str:=language[128]
          else
          _str:=language[39]+inttostr(Globalscore)+' // '+ language[178] +inttostr(Allscore);
       _w:=trunc(Fonts[1].TextWidth(_str));

       FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(350*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((45*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (360*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

     // _w:=35*resolutionscaleY-35*resolutionscaleY2;


      DrawStretch(MenuImages.Image['lev'+inttostr(level+1)],0,
      trunc(40*resolutionscaleX),
      trunc(30*resolutionscaleY2),
      trunc((410)*ResolutionScaleY2),
      trunc((400)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);
                                    
      DrawStretch(MenuImages.Image['ramka'],0,
      trunc(20*resolutionscaleX),
      trunc(10*resolutionscaleY2),
      trunc((430)*ResolutionScaleY2),
      trunc((420)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=0;//(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;

       k:=0;
       if level=0 then k:=1;

   for I := 0 to Menus[MenuN].bcount-1-k do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;
 End;
 End;




 if menun=90 then
  Begin
     Sline(trunc(_alf/2.5));
      hud_currentzone:=0;

     with MyCanvas do
     Begin
     
      FillRect(0,trunc(360*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc(400*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf2*100)),fxBlend);

      DrawStretch(MapPreviews.Image['hint'+inttostr(hintn)],0,
      trunc(40*resolutionscaleX),
      trunc(340*resolutionscaleY2),
      trunc((480)*ResolutionScaleY2),
      trunc((780)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,trunc(_alf2*255)),
      fxBlend);
                      // ff
      DrawStretch(MenuImages.Image['ramka'],0,
      trunc(20*resolutionscaleX),
      trunc(320*resolutionscaleY2),
      trunc((500)*ResolutionScaleY2),
      trunc((800)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,trunc(_alf2*255)),
      fxBlend);

      showhinticons;

     // __h:=round(Fonts[1].TextWidth(Language[24]));
     // _dop2:=(Fonts[1].TextHeight(Language[24]));

     {
      if (abs(VirtualW*ResolutionScaleX/2-mx)<(__h/2))and
      (my>850 *ResolutionScaleY2-dop2)and(my<850 *ResolutionScaleY2+_dop2*2) then
      Begin
        Fonts[1].TextOut(Language[24],
        (VirtualW*ResolutionScaleX-__h)/2, 850 *ResolutionScaleY2,
          cRGB1(255, 255, 255,255));
       hud_currentzone:=100;
      End else
       Fonts[1].TextOut(Language[24],
      (VirtualW*ResolutionScaleX-__h)/2, 850 *ResolutionScaleY2,
      cRGB1(255, 255, 255,185)); }

   Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;   /// new060115

   for I := 0 to 6 do
   Begin

      _str:=curhint[i];//hints[HintN*7+i-7];

      Fonts[1].TextOut(_str,700*resolutionscaleX,
          (400+50*(i))*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
   End;

    {DrawStretch(HudImages.Image['Cursor2'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2),
      trunc(My+70*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,255),
      fxBlend);  }

       //MouseHint;


      kn:=2;
      if curbutton=11 then
        kn:=4;

      FillRect(trunc(650*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(50*ResolutionScaleX),
        trunc((50)*resolutionscaleY2),
        crgb1(10,100,200,trunc(_alf2*50*kn)),fxBlend);

     { _str:='<';
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str,675*resolutionscaleX-_w,
          799*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));}
      kn:=1;
      if hintn>1 then
        kn:=5;

     DrawStretch(MenuImages.Image['mnu_arrow2'],0,
        trunc(660*ResolutionScaleX), trunc(795*resolutionscaleY2),
        trunc(690*ResolutionScaleX), trunc((835)*resolutionscaleY2),
        true,false, crgb4(255,255,255,trunc(_alf2*50*kn)), fxBlend);


      kn:=2;
      if curbutton=12 then
        kn:=4;

      FillRect(trunc(900*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(50*ResolutionScaleX),
        trunc((50)*resolutionscaleY2),
        crgb1(10,100,200,trunc(_alf2*50*kn)),fxBlend);

      {_str:='>';
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str,925*resolutionscaleX-_w,
          799*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255))); }

      kn:=2;
      if hintn<hintmax then
        kn:=5;

      DrawStretch(MenuImages.Image['mnu_arrow2'],0,
        trunc(910*ResolutionScaleX), trunc(795*resolutionscaleY2),
        trunc(940*ResolutionScaleX), trunc((835)*resolutionscaleY2),
        false,false, crgb4(255,255,255,trunc(_alf2*50*kn)), fxBlend);

      _str:=inttostr(hintn)+' / '+inttostr(hintmax);
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str,800*resolutionscaleX-_w,
          795*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

     ////
       _str:=language[239];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);


       if curbutton=101 then
       FillRect(trunc(990*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(810*ResolutionScaleX),
        trunc(50*ResolutionScaleY2),
        crgb1(10,100,200,trunc(_alf2*200)),fxBlend)
          else
      FillRect(trunc(990*ResolutionScaleX),
        trunc(790*resolutionscaleY2),
        trunc(810*ResolutionScaleX),
        trunc(50*ResolutionScaleY2),
        crgb1(10,100,200,trunc(_alf2*100)),fxBlend);

      FillRect(trunc(1000*ResolutionScaleX),
        trunc(800*resolutionscaleY2),
        trunc(30*ResolutionScaleX),
        trunc(30*ResolutionScaleY2),
        crgb1(10,100,200,trunc(_alf2*100)),fxBlend);

      if hintson then
           DrawStretch(MenuImages.Image['galka'],0,
      trunc(1000*resolutionscaleX),
      trunc(800*resolutionscaleY2),
      trunc((1030)*ResolutionScaleX),
      trunc((830)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,trunc(_alf2*255)),
      fxBlend);

      Fonts[1].TextOut(_str,1050*resolutionscaleX,
          802*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


    ////

      _x:= Menus[MenuN].x*ResolutionScaleX;
      for I := 0 to Menus[MenuN].bcount-1-k do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;



     End;


  End;





  if menuN=11 then
 Begin
     with MyCanvas do
     Begin


       Sline(trunc(_alf/2.5));

   FillRect(0,trunc(75*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((70*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);


   FillRect(0,trunc(250*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((200+50*(ScenarioTextEnd-ScenarioTextBegin-3))*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);
   _x:=800*ResolutionScaleX;


   Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;   /// new060115

   for I := ScenarioTextBegin+1 to ScenarioTextEnd do
   Begin
      //GlobalTicks:=GlobalTicks+Lagcount;

      _str:=scenario[i];

      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

      Fonts[1].TextOut(_str,_x-_w,
          (285+50*(i-ScenarioTextBegin-1))*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

   End;

       Fonts[1].Scale:=ResolutionScaleY2*1.2;
       _str:=scenario[ScenarioTextBegin];
       if Cheater then
         _str:=_str+language[180];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str, _x-_w,
          (90*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2*0.7;
       _str:=language[178]+IntToStr(Allscore)+language[179];
       _w:=trunc(Fonts[1].TextWidth(_str));

       FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(200*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((45*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (210*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

     // _w:=35*resolutionscaleY-35*resolutionscaleY2;
     { DrawStretch(MenuImages.Image['ramka'],0,
      trunc(30*resolutionscaleX),
      trunc(20*resolutionscaleY2),
      trunc((212)*ResolutionScaleY2),
      trunc((212)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      DrawStretch(MenuImages.Image['lev'+inttostr(level+1)],0,
      trunc(40*resolutionscaleX),
      trunc(30*resolutionscaleY2),
      trunc((200)*ResolutionScaleY2),
      trunc((200)*ResolutionScaleY2),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);  }

      Fonts[1].Scale:=ResolutionScaleY2*1.5;
      for I := 1 to 5 do
      Begin
        DrawStretch(MenuImages.Image['Big_Medal'+inttostr(i)],0,
      trunc((50+300*(i-1))*resolutionscaleX),
      trunc(700*resolutionscaleY2),
      trunc(200*ResolutionScaleX),
      trunc(200*ResolutionScaleY),1,1,false,false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       Fonts[1].Scale:=ResolutionScaleY2*1.5;
      _str:='x'+inttostr(medals[i]);

       Fonts[1].TextOut(_str,(300*i-75)*resolutionscaleX,
          (800)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2;
       _str:=Language[78+i];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str,(150+300*(i-1))*resolutionscaleX-_w,
          (650)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;


       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=0;//(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;


       {ЗДЕСЬ: НАГРАДЫ, ИТОГИ}

      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

      {  FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);}

             FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

        if extras[1] then
        Begin
            Fonts[1].Scale:=ResolutionScaleY2*0.7;
            _str:=language[224]+ExtrM[1]+language[225];
            _w:=trunc(Fonts[1].TextWidth(_str));

          FillRect(trunc(1500*ResolutionScaleX-_w),
            trunc(990*resolutionscaleY2),
            trunc(100*ResolutionScaleX+_w),
            trunc((45*resolutionscaleY2)),
            crgb1(10,100,200,trunc(_alf/4.5)),fxBlend);

          Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
            (1000*resolutionscaleY2),
            cRGB1(255, 255, 255, trunc(_alf2*255)));
        End;
       if extras[2] then
        Begin
            Fonts[1].Scale:=ResolutionScaleY2*0.7;
            _str:=language[224]+ExtrM[2]+language[226];
            _w:=trunc(Fonts[1].TextWidth(_str));

          FillRect(trunc(1500*ResolutionScaleX-_w),
            trunc(940*resolutionscaleY2),
            trunc(100*ResolutionScaleX+_w),
            trunc((45*resolutionscaleY2)),
            crgb1(10,100,200,trunc(_alf/4.5)),fxBlend);

          Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
            (950*resolutionscaleY2),
            cRGB1(255, 255, 255, trunc(_alf2*255)));
        End else
       if extras[3] then
        Begin
            Fonts[1].Scale:=ResolutionScaleY2*0.7;
            _str:=language[224]+ExtrM[3]+language[227];
            _w:=trunc(Fonts[1].TextWidth(_str));

          FillRect(trunc(1500*ResolutionScaleX-_w),
            trunc(940*resolutionscaleY2),
            trunc(100*ResolutionScaleX+_w),
            trunc((45*resolutionscaleY2)),
            crgb1(10,100,200,trunc(_alf/4.5)),fxBlend);

          Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
            (950*resolutionscaleY2),
            cRGB1(255, 255, 255, trunc(_alf2*255)));
        End
       { else
        Begin
          Fonts[1].Scale:=ResolutionScaleY2*0.7;
            _str:=language[223];
            _w:=trunc(Fonts[1].TextWidth(_str));

          FillRect(trunc(1500*ResolutionScaleX-_w),
            trunc(990*resolutionscaleY2),
            trunc(100*ResolutionScaleX+_w),
            trunc((45*resolutionscaleY2)),
            crgb1(250,50,50,trunc(_alf/4.5)),fxBlend);

          Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
            (1000*resolutionscaleY2),
            cRGB1(255, 255, 255, trunc(_alf2*255)));
        End;  }
        


      End;

     End;
 End;

 if menuN=2 then
 Begin
     with MyCanvas do
     Begin

       Sline(trunc(_alf/2.5));

       FillRect(0,trunc(75*resolutionscaleY2),
        trunc(1600*ResolutionScaleX),
        trunc((70*resolutionscaleY2)),
        crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

     {  FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(225*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((58*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (235*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));


       FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(350*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((45*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (360*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));    }

//               mapspage:=20;


      FillRect(trunc(0*ResolutionScaleX),
       trunc(200*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((800*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/5)),fxBlend);

      FillRect(trunc(140*ResolutionScaleX),
       trunc(350*resolutionscaleY2),
       trunc(500*ResolutionScaleX),
       trunc((500*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

     {список карт}

      Fonts[1].Scale:=(ResolutionScaleY2)*0.75/normwscale;    /// new060115
      for I := 0 to 9 do
      Begin
       if MapsList.Count>=I+Mapspage+1 then
       Begin
         _str:=MapsList[I+Mapspage];
         if length(_str)>20 then
          _str:=copy(_str,1,20)+'...';

         if curbutton=i+100 then
            FillRect(trunc(140*ResolutionScaleX),
              trunc((350+i*50)*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc(((50)*resolutionscaleY2)),
              crgb1(10,100,200,trunc(_alf/4)),fxBlend);

         if MapN=i+MapsPage then
            FillRect(trunc(140*ResolutionScaleX),
              trunc((350+i*50)*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc(((50)*resolutionscaleY2)),
              crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

         Fonts[1].TextOut(_str, 155*ResolutionscaleX-_w,
          ((360+i*50)*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));
       End;
      End;

      {кнопки прокрутки списка}

      if MapsList.Count>10 then
      Begin

       if curbutton=99 then
       Begin
          FillRect(trunc(140*ResolutionScaleX),
              trunc(300*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc((50)*resolutionscaleY2),
              crgb1(10,100,200,trunc(_alf/2)),fxBlend);

           DrawStretch(MenuImages.Image['mnu_arrow'],0, trunc(355*ResolutionScaleX),
                  trunc(305*resolutionscaleY2),
                  trunc(425*ResolutionScaleX),trunc(345*resolutionscaleY2),
                  false,false,cRGB4(255,255,255,250),fxBlend)

       End else
       Begin
          if MapsPage>0 then
            i:=trunc(_alf/3)
              else
                i:=trunc(_alf/4);

          FillRect(trunc(140*ResolutionScaleX),
              trunc((300)*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc((50)*resolutionscaleY2),
              crgb1(10,100,200,i),fxBlend);

          DrawStretch(MenuImages.Image['mnu_arrow'],0, trunc(355*ResolutionScaleX),
                  trunc(305*resolutionscaleY2),
                  trunc(425*ResolutionScaleX),trunc(345*resolutionscaleY2),
                  false,false,cRGB4(255,255,255,150),fxBlend);

       End;

       if curbutton=110 then
       Begin
          FillRect(trunc(140*ResolutionScaleX),
              trunc((850)*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc((50)*resolutionscaleY2),
              crgb1(10,100,200,trunc(_alf/2)),fxBlend);

          DrawStretch(MenuImages.Image['mnu_arrow'],0, trunc(355*ResolutionScaleX),
                  trunc(855*resolutionscaleY2),
                  trunc(425*ResolutionScaleX),trunc(895*resolutionscaleY2),
                  false,true,cRGB4(255,255,255,250),fxBlend)

       End else
       Begin
          if MapsPage<MapsList.Count-10 then
            i:=trunc(_alf/3)
              else
                i:=trunc(_alf/4);

          FillRect(trunc(140*ResolutionScaleX),
              trunc((850)*resolutionscaleY2),
              trunc(500*ResolutionScaleX),
              trunc((50)*resolutionscaleY2),
              crgb1(10,100,200,i),fxBlend);

          DrawStretch(MenuImages.Image['mnu_arrow'],0, trunc(355*ResolutionScaleX),
                  trunc(855*resolutionscaleY2),
                  trunc(425*ResolutionScaleX),trunc(895*resolutionscaleY2),
                  false,true,cRGB4(255,255,255,150),fxBlend)
       End;
      End;

       _red:=10;
       if MapStat.MSurvival=true then
          _red:=255;

      
       FillRect(trunc(700*ResolutionScaleX),
       trunc(250*resolutionscaleY2),
       trunc(900*ResolutionScaleX),
       trunc((450*resolutionscaleY2)),
       crgb1(_red,105-(_red div 3),205-(_red div 2),trunc(_alf/3)),fxBlend);

       FillRect(trunc(700*ResolutionScaleX),
       trunc(710*resolutionscaleY2),
       trunc(860*ResolutionScaleX-350*resolutionscaleY2),
       trunc((250*resolutionscaleY2)),
       crgb1(_red,105-(_red div 3),205-(_red div 2),trunc(_alf/3)),fxBlend);

       FillRect(trunc(1580*resolutionscaleX-350*resolutionscaleY2),
      trunc(710*resolutionscaleY2),
      trunc(350*resolutionscaleY2+20*resolutionscaleX),
      trunc(250*ResolutionScaleY2),
       crgb1(_red,105-(_red div 3),205-(_red div 2),trunc(_alf/3)),fxBlend);

      {Preview}

      i:=MapPreviews.Find(MapsList[MapN]+'.bmp');

      if i<>-1 then
      DrawStretch(MapPreviews.Item[i],0,
      trunc(1580*resolutionscaleX-350*resolutionscaleY2),
      trunc(300*resolutionscaleY2),
      trunc(1580*ResolutionScaleX),
      trunc(650*ResolutionScaleY2),false,false,
      cRGB4(225,225,255,_alf),
      fxBlend);

      DrawStretch(MenuImages.Image['ramka2'],0,
      trunc(1580*resolutionscaleX-350*resolutionscaleY2),
      trunc(300*resolutionscaleY2),
      trunc(1580*ResolutionScaleX),
      trunc(650*ResolutionScaleY2),false,false,
      cRGB4(225,225,255,_alf),
      fxBlend);

      DrawStretch(MenuImages.Image['ramka'],0,
      trunc(1580*resolutionscaleX-370*resolutionscaleY2),
      trunc(280*resolutionscaleY2),
      trunc(1600*ResolutionScaleX),
      trunc(670*ResolutionScaleY2),false,false,
      cRGB4(225,225,255,_alf),
      fxBlend);

     
      _x:= 800*ResolutionScaleX;
      {Информация о карте}

      Fonts[1].Scale:=ResolutionScaleY2*1.2;
      _str:=language[5];
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str, _x-_w,
          (90*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      _x:= 750*ResolutionScaleX;
      Fonts[1].Scale:=ResolutionScaleY2;

      Fonts[1].TextOut(Language[197], trunc(_x),
          (730*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].Scale:=ResolutionScaleY2*0.85;

      Fonts[1].TextOut(_MapName, trunc(_x),
          (790*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].TextOut(Language[204]+_MapAuthor,trunc(_x),
          (870*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].TextOut(Language[198]+_MapSize, trunc(_x),
          (910*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].TextOut(_MapAbout, trunc(_x),
          (830*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].TextOut(MapsList[MapN], trunc(_x),
          (280*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].Scale:=ResolutionScaleY2*0.75;
      for I := 0 to 7 do
      Begin
       _str:=language[I+208];

       Fonts[1].TextOut(_str, 1600*resolutionscaleX-175*resolutionscaleY2
        -Fonts[1].TextWidth(_str)/2, ((720+i*29)*resolutionscaleY2),
        cRGB1(255, 255, 255, trunc(_alf2*255)));

      End;


      if MapStat.MDone then
      Begin

        

        if MapStat.MSurvival then
        Begin
              // zx
          Fonts[1].TextOut(Language[196], trunc(_x),
          (400*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

          Fonts[1].TextOut(Language[236], trunc(_x),
            (335*resolutionscaleY2),
            cRGB1(255, 0, 0, trunc(_alf2*255)));


          Fonts[1].Scale:=ResolutionScaleY2;

          k:=0;
          if MapStat.Menemies>=100 then
            k:=200;

          Fonts[1].TextOut(Language[19]+IntToStr(MapStat.MEnemies), trunc(_x),
              (570*resolutionscaleY2),
              cRGB1(255, 255, 255-k, trunc(_alf2*255)));

          Fonts[1].TextOut(MapStat.MBest, trunc(_x),
            (440*resolutionscaleY2),
            cRGB1(255, 255, 255-k, trunc(_alf2*255)));
                                                       // xzxz
          if k=200 then
            DrawStretch(MenuImages.Image['Big_Medal1'],0,
              trunc(1000*resolutionscaleX),
              trunc(415*resolutionscaleY2)+logoY*ResolutionScaleY,
              trunc(200*ResolutionScaleX),
              trunc(200*ResolutionScaleY),1,1,false,false,false,
              cRGB4(255,255,255,trunc(_alf2*255)), fxBlend);



        end else
        Begin
          k:=0;
          if MapStat.MScore>=MapStat.MMax then
          Begin
            DrawStretch(MenuImages.Image['Big_Medal1'],0,
              trunc(1000*resolutionscaleX),
              trunc(415*resolutionscaleY2)+LogoY*ResolutionScaleY,
              trunc(200*ResolutionScaleX),
              trunc(200*ResolutionScaleY),1,1,false,false,false,
              cRGB4(255,255,255,trunc(_alf2*255)), fxBlend);

            k:=200;
          End;
          
          Fonts[1].TextOut(Language[196], trunc(_x),
          (370*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

          Fonts[1].TextOut(MapStat.MBest, trunc(_x),
            (400*resolutionscaleY2),
            cRGB1(255, 255, 255-k, trunc(_alf2*255)));

          Fonts[1].TextOut('['+IntToStr(MapStat.MScore)+']', trunc(_x),
            (430*resolutionscaleY2),
            cRGB1(255, 255, 255-k, trunc(_alf2*255)));

          Fonts[1].Scale:=ResolutionScaleY2*0.75;

          k:=0;
          if MapStat.Menemies>=100 then
            k:=200;
          if MapStat.Menemies<>-1 then
          Fonts[1].TextOut(Language[19]+IntToStr(MapStat.MEnemies)+'%', trunc(_x),
              (500*resolutionscaleY2),
              cRGB1(255, 255, 255-k, trunc(_alf2*255)))
              else
               Fonts[1].TextOut(Language[19]+'-', trunc(_x),
                  (500*resolutionscaleY2),
                  cRGB1(255, 255, 255-k, trunc(_alf2*255)));

          k:=0;
          if MapStat.Mplasmids>=100 then
            k:=200;

          if MapStat.Mplasmids<>-1 then
            Fonts[1].TextOut(Language[20]+IntToStr(MapStat.Mplasmids)+'%', trunc(_x),
              (535*resolutionscaleY2),
              cRGB1(255, 255, 255-k, trunc(_alf2*255)))
           else
           Fonts[1].TextOut(Language[20]+'-', trunc(_x),
              (535*resolutionscaleY2),
              cRGB1(255, 255, 255, trunc(_alf2*255)));

          k:=0;
          if MapStat.Msecrets>=100 then
            k:=200;


          if MapStat.Msecrets<>-1 then
            Fonts[1].TextOut(Language[21]+IntToStr(MapStat.Msecrets)+'%', trunc(_x),
              (570*resolutionscaleY2),
              cRGB1(255, 255, 255-k, trunc(_alf2*255)))
            else
            Fonts[1].TextOut(Language[21]+'-', trunc(_x),
              (570*resolutionscaleY2),
              cRGB1(255, 255, 255, trunc(_alf2*255)));

          k:=0;
          if MapStat.Maccuracy>=100 then
            k:=200;


          if MapStat.Maccuracy<>-1 then
          Fonts[1].TextOut(Language[22]+IntToStr(MapStat.Maccuracy)+'%', trunc(_x),
              (605*resolutionscaleY2),
              cRGB1(255, 255, 255-k, trunc(_alf2*255)))
               else
                 Fonts[1].TextOut(Language[22]+'-', trunc(_x),
                    (605*resolutionscaleY2),cRGB1(255, 255, 255-k, trunc(_alf2*255)));


          Fonts[1].TextOut(Language[194]+(MapStat.MTime), trunc(_x),
            (640*resolutionscaleY2),
            cRGB1(255, 255, 255, trunc(_alf2*255)));
          k:=0;
        end;
      end
      else
      Begin
       Fonts[1].Scale:=ResolutionScaleY2;
        if MapStat.MSurvival then
        Begin
          Fonts[1].TextOut(Language[236], trunc(_x),
            (350*resolutionscaleY2),
            cRGB1(255, 0, 0, trunc(_alf2*255)));

          Fonts[1].TextOut(Language[195], trunc(_x),
          (500*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));
        End else
          Fonts[1].TextOut(Language[195], trunc(_x),
              (470*resolutionscaleY2),
              cRGB1(255, 255, 255, trunc(_alf2*255)));
      end;
    //end;
       {Кнопки меню}
       k:=0;
      _x:= Menus[MenuN].x*ResolutionScaleX;
      _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
      _h:=0;//(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;
                                       // fhh
       for I := 0 to Menus[MenuN].bcount-1-k do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
     End;
 End;

 End;


 if menuN=18 then
 Begin
     with MyCanvas do
     Begin

       Sline(trunc(_alf/2.5));

   FillRect(0,trunc(75*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((70*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

   FillRect(0,trunc((875+65-MenuDopY)*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((85*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

   FillRect(0,trunc(300*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((50)*resolutionscaleY2),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);


   FillRect(0,trunc(370*resolutionscaleY2),
       trunc(1600*ResolutionScaleX),
       trunc((300)*resolutionscaleY2+200*resolutionscaleY),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

   _x:=800*ResolutionScaleX;


   {Fonts[1].Scale:=(ResolutionScaleY2)*0.9/normwscale;

   for I := ScenarioTextBegin+1 to ScenarioTextEnd do
   Begin
      //GlobalTicks:=GlobalTicks+Lagcount;

      _str:=scenario[i];

      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

      Fonts[1].TextOut(_str,_x-_w,
          (285+50*(i-ScenarioTextBegin-1))*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

   End;  }

       Fonts[1].Scale:=ResolutionScaleY2*1.3;
       _str:=Language[84];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str, _x-_w,
          (90*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2*1;
       _str:=Language[127]+inttostr(page+1);
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str, _x-_w,
          (310*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));

  {     Fonts[1].Scale:=ResolutionScaleY2*0.7;
       _str:=language[39];
       _w:=trunc(Fonts[1].TextWidth(_str));

       FillRect(trunc(1500*ResolutionScaleX-_w),
       trunc(200*resolutionscaleY2),
       trunc(100*ResolutionScaleX+_w),
       trunc((45*resolutionscaleY2)),
       crgb1(10,100,200,trunc(_alf/2.5)),fxBlend);

       Fonts[1].TextOut(_str, 1550*ResolutionscaleX-_w,
          (210*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2*255)));     }

     // _w:=35*resolutionscaleY-35*resolutionscaleY2;


      {if page=2 then
       l :=2
         else}
          l:=5;

      for I := 1 to l do
      Begin

       Fonts[1].Scale:=ResolutionScaleY*0.7;

      if level>=(page*5+i) then
      Begin
        DrawStretch(MenuImages.Image['lev'+inttostr(i+page*5)],0,
          trunc((100+300*(i-1))*resolutionscaleX),
          trunc(440*resolutionscaleY2),
          trunc(200*ResolutionScaleX),
          trunc(200*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,_alf),
          fxBlend);


        for j := 0 to 4 do
        Begin
        _str:=language[19+j];

        Fonts[1].TextOut(_str,trunc((100+300*(i-1))*resolutionscaleX),
          trunc((475+j*35)*resolutionscaleY2)+200*resolutionscaleY,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

         k:=0;

         if stats[page*5+I-1,J]<>-1 then
         Begin
           _str:=inttostr(stats[page*5+I-1,J]);

           if stats[page*5+I-1,J]=100 then
            k:=100;

           if j<4 then
             _str:=_str+'%'
         End
            else
                _str:='-';


         _w:=trunc(Fonts[1].TextWidth(_str));

         Fonts[1].TextOut(_str,trunc((300+300*(i-1))*resolutionscaleX-_w),
          trunc((475+j*35)*resolutionscaleY2)+200*resolutionscaleY,
          cRGB1(255, 255, 255-k, trunc(_alf2*255)));

        End;

      End else
      Begin


      End;

        Fonts[1].Scale:=ResolutionScaleY*0.85;

        _str:=language[119]+inttostr(i);
        _w:=trunc(Fonts[1].TextWidth(_str)/2);

        Fonts[1].TextOut(_str,trunc((200+300*(i-1))*resolutionscaleX-_w),
          trunc((390)*resolutionscaleY2),
          cRGB1(255, 255, 255-k, trunc(_alf2*255)));

      DrawStretch(MenuImages.Image['ramka'],0,
        trunc((90+300*(i-1))*resolutionscaleX),
        trunc(430*resolutionscaleY2),
        trunc(220*ResolutionScaleX),
        trunc(220*ResolutionScaleY),1,1,false,false,false,
        cRGB4(255,255,255,_alf),
        fxBlend);

      { Fonts[1].Scale:=ResolutionScaleY2*1.5;
      _str:='x'+inttostr(medals[i]);

       Fonts[1].TextOut(_str,(300*i-75)*resolutionscaleX,
          (800)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

       Fonts[1].Scale:=ResolutionScaleY2;
       _str:=Language[78+i];
       _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
       Fonts[1].TextOut(_str,(150+300*(i-1))*resolutionscaleX-_w,
          (650)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));  }
      End;


       _x:= Menus[MenuN].x*ResolutionScaleX;
       _y:=(-Menus[MenuN].h*menut*0.01+630-64)*ResolutionScaleY2;
       _h:=0;//(Menus[MenuN].h*menut*0.01)*ResolutionScaleY2*2;



      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        if i>0 then
        Begin
         if ((i<Menus[MenuN].bcount-1)and(i-1>level/5))or((i=Menus[MenuN].bcount-1)and(level<levels.Count)) then
         FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(200,10,10,trunc(_alf2*150)),fxBlend)
           else
           
         FillRect(trunc(_x+(Menus[MenuN].buttons[i].x-128)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(256*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        End
          else

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);

        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;

      

      kn:=0;
      if curbutton=11 then
         kn:=2;

       FillRect(trunc(600*ResolutionScaleX),
        trunc(310*resolutionscaleY2),
        trunc(50*ResolutionScaleX),
        trunc((30)*resolutionscaleY2),
        crgb1(10,100,200,trunc(_alf/(2.5-kn))),fxBlend);



      {_str:='<';
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str,525*resolutionscaleX-_w,
          310*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));  }

       kn:=0;
        if page>0 then
         kn:=2;

       DrawStretch(MenuImages.Image['mnu_arrow2'],0,
        trunc(610*ResolutionScaleX),
        trunc(312*resolutionscaleY2),
        trunc(640*ResolutionScaleX),
        trunc((338)*resolutionscaleY2),
        true,false, crgb4(255,255,255,trunc(_alf/(5-kn*2))), fxBlend);



      kn:=0;
      if curbutton=12 then
        kn:=2;

      FillRect(trunc(950*ResolutionScaleX),
        trunc(310*resolutionscaleY2),
        trunc(50*ResolutionScaleX),
        trunc((30)*resolutionscaleY2),
        crgb1(10,100,200,trunc(_alf/(2.5-kn))),fxBlend);

      kn:=0;
       if page<2 then
         kn:=2;

       DrawStretch(MenuImages.Image['mnu_arrow2'],0,
        trunc(960*ResolutionScaleX),
        trunc(312*resolutionscaleY2),
        trunc(990*ResolutionScaleX),
        trunc((338)*resolutionscaleY2),
        false,false, crgb4(255,255,255,trunc(_alf/(5-kn*2))), fxBlend);
     { _str:='>';
      _w:=trunc(Fonts[1].TextWidth(_str)/ 2);
      Fonts[1].TextOut(_str,1075*resolutionscaleX-_w,
          310*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));   }

     End;
 End;


            // mm
  if menuN=16 then
 Begin
     Sline(trunc(_alf));

     if IntroNumber<>4 then i:=78
      else i:=85;

   if not(paused) then
     Globalticks:=GlobalTicks+(0.078)*lagcount;
     if Globalticks>i then
     Begin
       GlobalTicks:=0;
       inc(CurrentScreenN)
     End;

     with MyCanvas do
     Begin
        if Globalticks<10 then
          _alf2:=Globalticks*25
          else
            _alf2:=255;

     Fonts[1].Scale:=ResolutionScaleY2*0.95;


     if (CurrentScreenN>1)and(Globalticks<10)and(CurrentScreenN<IntroCount+1) then
     Begin
     DrawStretch(Images2.Image[inttostr(CurrentScreenN-1)],0,
      trunc((0)*resolutionscaleX), -deltaY+
      trunc(150*resolutionscaleY2),
      trunc(1600*ResolutionScaleX),
      trunc(900*ResolutionScaleY),1,1,false,false,false,
      cRGB4(255,255,255,trunc(255-_alf2)),
      fxBlend);

      for i:=1 to 4 do
      Begin
                       // cxc
       _str:=language[IntroStrBegin+i+(CurrentScreenN-1)*4];

        Fonts[1].TextOut(_str, (introx[CurrentScreenN-1]+2)*ResolutionscaleX,
          ((introy[CurrentScreenN-1]+25*i+2)*resolutionscaleY2),
          cRGB1(0, 0, 0, trunc(255-_alf2)));

        Fonts[1].TextOut(_str, introx[CurrentScreenN-1]*ResolutionscaleX,
          ((introy[CurrentScreenN-1]+25*i)*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(255-_alf2)));
      End;
     End;


     if (CurrentScreenN<IntroCount) then
     Begin
      DrawStretch(Images2.Image[inttostr(CurrentScreenN)],0,
      trunc(0), -deltaY+
      trunc(150*resolutionscaleY2),
      trunc(1600*ResolutionScaleX),
      trunc(900*ResolutionScaleY),1,1,false,false,false,
      cRGB4(255,255,255,trunc(_alf2)),
      fxBlend);

      for i:=1 to 4 do
      Begin
      _th:=(Globalticks-10*i)/10;
       if _th>1 then _th:=1;
       if _th<0 then _th:=0;

       _str:=copy(language[IntroStrBegin+(CurrentScreenN)*4+i],1,trunc(length(language[IntroStrBegin+i+(CurrentScreenN)*4])*_th));

        Fonts[1].TextOut(_str, (introx[CurrentScreenN]+2)*ResolutionscaleX,
          ((introy[CurrentScreenN]+25*i+2)*resolutionscaleY2),
          cRGB1(0, 0, 0, trunc(_alf2)));

        Fonts[1].TextOut(_str, introx[CurrentScreenN]*ResolutionscaleX,
          ((introy[CurrentScreenN]+25*i)*resolutionscaleY2),
          cRGB1(255, 255, 255, trunc(_alf2)));
      End;
     End;

      if (CurrentScreenN>=IntroCount)and(Globalticks>10) then
       Begin
         menuready:=false;
         UnloadIntro;
         if level<levels.Count then
            nextmenu:=10
            else
            Begin
             nextmenu:=11;
             UnpackExtras;
            End;
         End;
     End;
 End;


 if menuN=4 then
 Begin
   sline(round(menut*2));
   with MyCanvas do
     Begin

        _x:= 608*ResolutionScaleX;

       _y:=(-menut+630-64)*ResolutionScaleY2;
       _h:=(menut)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= 544*ResolutionScaleX;
       _y:=(menut+620-64)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-menut+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.9;
      _w:=trunc(Fonts[1].TextWidth(Language[13])/ 2);
      Fonts[1].TextOut(Language[13],800*resolutionscaleX-_w,
          500*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

         FillRect(trunc(_x-_w+(Menus[MenuN].buttons[i].x-20)*resolutionscaleX),
          trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
          trunc(_w*2+40*resolutionscaleX),
          trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;


     End;
 End;

 if menuN=15 then
 Begin
   sline(round(menut*2));
   with MyCanvas do
     Begin

        _x:= 608*ResolutionScaleX;

       _y:=(-menut+630-64)*ResolutionScaleY2;
       _h:=(menut)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= 544*ResolutionScaleX;
       _y:=(menut+620-64)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-menut+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.8;
      _w:=trunc(Fonts[1].TextWidth(Language[78])/ 2);

      Fonts[1].TextOut(Language[78],800*resolutionscaleX-_w,
          500*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));

      Fonts[1].Scale:=ResolutionScaleY2;
      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

         FillRect(trunc(_x-_w+(Menus[MenuN].buttons[i].x-20)*resolutionscaleX),
          trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
          trunc(_w*2+40*resolutionscaleX),
          trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;


     End;
 End;

 if menuN=8 then
 Begin
   sline(round(menut*2));
   with MyCanvas do
     Begin

        _x:= 608*ResolutionScaleX;

       _y:=(-menut+630-64)*ResolutionScaleY2;
       _h:=(menut)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= 544*ResolutionScaleX;
       _y:=(menut+620-64)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-menut+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.8;
      _w:=trunc(Fonts[1].TextWidth(Language[57])/ 2);
      Fonts[1].TextOut(Language[57],800*resolutionscaleX-_w,
          500*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

         FillRect(trunc(_x-_w+(Menus[MenuN].buttons[i].x-20)*resolutionscaleX),
          trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
          trunc(_w*2+40*resolutionscaleX),
          trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;


     End;
 End;

 if menun<>16 then
 MyCanvas.DrawStretch(HudImages.Image['Cursor3'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,255),
      fxBlend);


End;


if Paused then
    Begin
      SLine(100);
      Fonts[1].Scale:=ResolutionScaleY2*3;
      _h:=round(Fonts[1].TextWidth(Language[0]));
      Fonts[1].TextOut(Language[0],
      (VirtualW*ResolutionScaleX-_h)/2, 420 *ResolutionScaleY2,
      cRGB1(255, 255, 255,255));
      Fonts[1].Scale:=ResolutionScaleY;
      _h:=round(Fonts[1].TextWidth(Language[1]));
      Fonts[1].TextOut(Language[1],
      (VirtualW*ResolutionScaleX-_h)/2, 820 *ResolutionScaleY2,
      cRGB1(255, 255, 255,255));
    End else
 if Gameover then
    if LevelmissionTip=5 then
    Begin
    //SURVIVAL
      if leveldone then
      begin
       Fonts[1].Scale:=ResolutionScaleY2*1.5;
       _h:=round(Fonts[1].TextWidth(Language[18]));
        Fonts[1].TextOut(Language[18],
          (VirtualW*ResolutionScaleX-_h)/2, 300 *ResolutionScaleY2,
           cRGB1(255, 255, 255,round(fade1)));

        
        _str:=Language[19]+' '+inttostr(levelscore.enms);
        _h:=round(Fonts[1].TextWidth(_str));

        if levelscore.enms<100 then
          Fonts[1].TextOut(_str,
            (VirtualW*ResolutionScaleX-_h)/2, 400 *ResolutionScaleY2,
            cRGB1(255, 20, 20,round(fade1)))
          else
          Begin
             Fonts[1].TextOut(_str,
              (VirtualW*ResolutionScaleX-_h)/2, 400 *ResolutionScaleY2,
              cRGB1(255, 255, 20,round(fade1)));
                                             // .. ячя
              _h2:=round(Fonts[1].TextWidth(_str));

              MyCanvas.DrawStretch(MenuImages.Image['big_medal1'],0,
                trunc((VirtualW-320)*ResolutionScaleX)/2,
                trunc(480*ResolutionScaleY2), trunc(320*ResolutionScaleX),
                trunc(320*ResolutionScaleY),1,1,false,false,false,
                cRGB4(255,255,255,round(fade1)),
                fxBlend);
          End;
      end
       else
        begin

         Fonts[1].Scale:=ResolutionScaleY2*2.5;
         _h:=round(Fonts[1].TextWidth(Language[2]));
         Fonts[1].TextOut(Language[2],
              (VirtualW*ResolutionScaleX-_h)/2, 420 *ResolutionScaleY2,
                cRGB1(255, 255, 255,round(fade1)));
         Fonts[1].Scale:=ResolutionScaleY2;
         _h:=round(Fonts[1].TextWidth(Language[3]));
         Fonts[1].TextOut(Language[3],
              (VirtualW*ResolutionScaleX-_h)/2, 820 *ResolutionScaleY2,
              cRGB1(255, 255, 255,round(fade1)));
         _h:=round(Fonts[1].TextWidth(Language[4]));
              Fonts[1].TextOut(Language[4],
              (VirtualW*ResolutionScaleX-_h)/2, 880 *ResolutionScaleY2,
              cRGB1(255, 255, 255,round(fade1)));

          Fonts[1].Scale:=ResolutionScaleY2*1.5;

          _str:=Language[19]+' '+inttostr(levelscore.enms);

          _h:=round(Fonts[1].TextWidth(_str));

          Fonts[1].TextOut(_str,
            (VirtualW*ResolutionScaleX-_h)/2, 600 *ResolutionScaleY2,
            cRGB1(255, 20, 20,round(fade1)));
        end;
    End else
 Begin
   //SLine(100);
    if leveldone then
    begin
      Fonts[1].Scale:=ResolutionScaleY2*1.5;

      globalticks:=globalticks+lagcount*0.04;
       if globalticks>2*pi then
        globalticks:=0;


      _h:=round(Fonts[1].TextWidth(Language[18]));

      if fade1>100 then
      Begin
          i:=0;
          if percento[6]+trunc(itogo)>=1000 then
           i:=trunc(20*ResolutionScaleX);

          MyCanvas.FillRect(trunc(((VirtualW-100)*ResolutionScaleX-_h-i)/2),
            trunc(290*ResolutionScaleY2),
            trunc(_h+i+100*ResolutionScaleX),
            trunc(80*ResolutionScaleY2),
            crgb1(10,100,200,trunc(1.5*(fade1-100))),fxBlend);

          MyCanvas.FillRect(trunc(((VirtualW-100)*ResolutionScaleX-i-_h)/2),
            trunc(380*ResolutionScaleY2),
            trunc(_h+i+100*ResolutionScaleX),
            trunc(260*ResolutionScaleY2),
            crgb1(10,100,200,trunc((fade1-100))),fxBlend);


         MyCanvas.FillRect(trunc(((VirtualW-100)*ResolutionScaleX-i-_h)/2),
            trunc(650*ResolutionScaleY2),
            trunc(_h+i+100*ResolutionScaleX),
            trunc(70*ResolutionScaleY2),
            crgb1(10,100,200,trunc(1.5*(fade1-100))),fxBlend);

         if hidet then
            SLine(trunc(0.5*(fade1-100)));
      End;


      Fonts[1].TextOut(Language[18],
      (VirtualW*ResolutionScaleX-_h)/2, 300 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));

      Fonts[1].Scale:=ResolutionScaleY2;
      Fonts[2].Scale:=ResolutionScaleY2;
      Fonts[3].Scale:=ResolutionScaleY2;

      _h:=round(Fonts[1].TextWidth(Language[19]))*4;


      _str:=Language[19]+' '+inttostr(levelscore.enms)+'/'
          +inttostr(levelscore.enmscount)+' = '+inttostr(percento[1])+'%';
      Fonts[1].TextOut(_str,
      (VirtualW*ResolutionScaleX-_h)/2, 400 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));

      if percento[1]>=100 then
      Begin
         _h2:=round(Fonts[1].TextWidth(_str));
        MyCanvas.DrawStretch(MenuImages.Image['medal1'],0, trunc(VirtualW*ResolutionScaleX+_h2)/2,
          trunc(380*ResolutionScaleY2), trunc(64*ResolutionScaleX),
          trunc(64*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,round(fade1)),
          fxBlend);
      End;

      if percento[1]=0 then
      Begin
         _h2:=round(Fonts[1].TextWidth(_str));
         MyCanvas.DrawStretch(MenuImages.Image['medal5'],0, trunc(VirtualW*ResolutionScaleX+_h2)/2,
          trunc(380*ResolutionScaleY2), trunc(64*ResolutionScaleX),
          trunc(64*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,round(fade1)),
          fxBlend);
      End;

      _str:=Language[20]+' '+inttostr(levelscore.plasmids)+'/'
          +inttostr(levelscore.plasmidscount)+' = '+inttostr(percento[2])+'%';
      Fonts[1].TextOut(_str,
      (VirtualW*ResolutionScaleX-_h)/2, 450 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));

       if percento[2]>=100 then
       Begin
        _h2:=round(Fonts[1].TextWidth(_str));
        MyCanvas.DrawStretch(MenuImages.Image['medal2'],0,trunc(VirtualW*ResolutionScaleX+_h2)/2,
          trunc(430*ResolutionScaleY2), trunc(64*ResolutionScaleX),
          trunc(64*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,round(fade1)),
          fxBlend);
       End;

      _str:=Language[21]+' '+inttostr(levelscore.secrets)+'/'
          +inttostr(levelscore.secretscount)+' = '+inttostr(percento[3])+'%';
       Fonts[1].TextOut(_str,
      (VirtualW*ResolutionScaleX-_h)/2, 500 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));

       if percento[3]>=100 then
       Begin

         _h2:=round(Fonts[1].TextWidth(_str));
        MyCanvas.DrawStretch(MenuImages.Image['medal3'],0,trunc(VirtualW*ResolutionScaleX+_h2)/2,
          trunc(480*ResolutionScaleY2), trunc(64*ResolutionScaleX),
          trunc(64*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,round(fade1)),
          fxBlend);
       End;

      _str:=Language[22]+' '+inttostr(levelscore.shotsluck)+'/'
          +inttostr(levelscore.shootscount div 2)+' = '+inttostr(percento[4])+'%';
      Fonts[1].TextOut(_str,
      (VirtualW*ResolutionScaleX-_h)/2, 550 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));

        if percento[4]>=100 then
        Begin
          percento[4]:=100;
          _h2:=round(Fonts[1].TextWidth(_str));
        MyCanvas.DrawStretch(MenuImages.Image['medal4'],0, trunc(VirtualW*ResolutionScaleX+_h2)/2,
          trunc(530*ResolutionScaleY2), trunc(64*ResolutionScaleX),
          trunc(64*ResolutionScaleY),1,1,false,false,false,
          cRGB4(255,255,255,round(fade1)),
          fxBlend);
        End;

      if fade1>200 then
      if itogo<percento[5] then
        itogo:=itogo+lagcount;

      if itogo>percento[5] then
         itogo:=percento[5];

      _str:=Language[177]+' '+showtime;

      Fonts[1].TextOut(_str,
        (VirtualW*ResolutionScaleX-_h)/2, 600 *ResolutionScaleY2,
        cRGB1(255, 255, 255,round(fade1)));


      if Campaign then
      Begin
       _str:=Language[23]+' '+inttostr(percento[6])+' ';


        Fonts[1].TextOut(_str,
        (VirtualW*ResolutionScaleX-_h)/2, 670 *ResolutionScaleY2,
        cRGB1(255, 255, 255,round(fade1)));

       _h2:=round(Fonts[1].TextWidth(_str));

        Fonts[3].TextOut('+',
        (VirtualW*ResolutionScaleX-_h)/2+_h2, 677 *ResolutionScaleY2,
        cRGB1(255, 255, 255,round(fade1)));

       _h2:=_h2+round(Fonts[3].TextWidth('+'));

       _str:=' '+inttostr(trunc(itogo))+' = '+inttostr(percento[6]+trunc(itogo))
          +' '+language[41];

       Fonts[1].TextOut(_str,
        (VirtualW*ResolutionScaleX-_h)/2+_h2, 670 *ResolutionScaleY2,
        cRGB1(255, 255, 255,round(fade1)));


           _h:=round(Fonts[1].TextWidth(Language[305]));
      if itogo>=percento[5] then
      Fonts[1].TextOut(Language[305],
      (VirtualW*ResolutionScaleX-_h)/2, 850 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1*(1+sin(globalTicks))*0.5)));
      End
      else
      Begin
        _str:=Language[23]+' '+inttostr(round(itogo));

        Fonts[1].TextOut(_str,
        (VirtualW*ResolutionScaleX-_h)/2, 670 *ResolutionScaleY2,
        cRGB1(255, 255, 255,round(fade1)));

      if (percento[5]>MapStat.MScore) then
      Begin
         _h:=round(Fonts[1].TextWidth(Language[182]));
        Fonts[1].TextOut(Language[182],
        (VirtualW*ResolutionScaleX-_h)/2, 820 *ResolutionScaleY2,
        cRGB1(255, 255, 55,round(fade1)));
      End;

        _h:=round(Fonts[1].TextWidth(Language[305]));
      if itogo>=percento[5] then
      Fonts[1].TextOut(Language[305],
      (VirtualW*ResolutionScaleX-_h)/2, 900 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1*(1+sin(globalTicks))*0.5)));

      End;

    end else
    Begin
      Fonts[1].Scale:=ResolutionScaleY2*2.5;
      _h:=round(Fonts[1].TextWidth(Language[2]));
      Fonts[1].TextOut(Language[2],
      (VirtualW*ResolutionScaleX-_h)/2, 420 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));
      Fonts[1].Scale:=ResolutionScaleY2;
      _h:=round(Fonts[1].TextWidth(Language[3]));
      Fonts[1].TextOut(Language[3],
      (VirtualW*ResolutionScaleX-_h)/2, 820 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));
      _h:=round(Fonts[1].TextWidth(Language[4]));
      Fonts[1].TextOut(Language[4],
      (VirtualW*ResolutionScaleX-_h)/2, 880 *ResolutionScaleY2,
      cRGB1(255, 255, 255,round(fade1)));
    End;
 End else

 if stopmenu then
 Begin

    if checkpointenabled then
     k:=0 else k:=5;

     menun:=k;

       if menuready=true then
    Begin
      if Menut<100 then
        Menut:=Menut+lagcount*2;
      if Menut>100 then
        Menut:=100;
    End;

    if menuready=false then
      Begin
        if Menut>0 then
          Menut:=Menut-lagcount*5;
          if Menut<0 then
          Begin
            Menut:=0;
            menuN:=nextmenu;
            if nextmenu=0 then
            Begin
             StopMenu:=false;
             InMenu:=false;
            End;
            menuready:=true;
          End;
      End;

    _alf:=round(menut)*5;
    if _alf>255 then
      _alf:=255;

   _alf2:=(menut-70)/30;
     if _alf2<0 then _alf2:=0;

   sline(_alf div 2);

  with MyCanvas do
     Begin

        _x:= 608*ResolutionScaleX;

       _y:=(-2*menut+630-32)*ResolutionScaleY2;
       _h:=(2*menut)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= 544*ResolutionScaleX;
       _y:=(2*menut+620-32)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-2*menut+580-32)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

     for I := 0 to Menus[k].bcount-1 do
      Begin
        Fonts[1].Scale:=ResolutionScaleY2;
        _str:=Language[Menus[k].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

        FillRect(trunc(_x+(74)*resolutionscaleX),
         trunc((570+Menus[k].buttons[i].y)*resolutionscaleY2),
         trunc(360*ResolutionScaleX),trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[k].buttons[i].x*resolutionscaleX,
          (580+Menus[k].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      End;
     End;


    MyCanvas.DrawStretch(HudImages.Image['Cursor3'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,255),
      fxBlend);

 End;

 if menun=7 then
 Begin
  
   if menuready=true then
    Begin
      if Menut<100 then
        Menut:=Menut+lagcount*2;
      if Menut>100 then
        Menut:=100;
    End;

    if menuready=false then
      Begin
        if Menut>0 then
          Menut:=Menut-lagcount*5;
          if Menut<0 then
          Begin
            Menut:=0;
            menuN:=nextmenu;
            if nextmenu=0 then
            Begin
             StopMenu:=false;
             InMenu:=false;
            End;
             menuready:=true;
          End;
      End;

    _alf:=round(menut)*5;
    if _alf>255 then
      _alf:=255;

    _alf2:=(menut-70)/30;
     if _alf2<0 then _alf2:=0;



  sline(round(menut*2));
   with MyCanvas do
     Begin

        _x:= 608*ResolutionScaleX;

       _y:=(-menut+630-64)*ResolutionScaleY2;
       _h:=(menut)*ResolutionScaleY2*2;

       FillRect(trunc(_x),trunc(_y),
       trunc(380*ResolutionScaleX),trunc(_h),
       crgb1(10,100,200,150),fxBlend);

       _x:= 544*ResolutionScaleX;
       _y:=(menut+620-64)*ResolutionScaleY2;
      DrawStretch(MenuImages.Image['mnu_down'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

       _y:=(-menut+580-64)*ResolutionScaleY2;

       DrawStretch(MenuImages.Image['mnu_up'],0, trunc(_x),
      trunc(_y), trunc(_x+512*ResolutionScaleX),
      trunc(_y+64*ResolutionScaleY),false,false,
      cRGB4(255,255,255,_alf),
      fxBlend);

      Fonts[1].Scale:=ResolutionScaleY2*0.9;
      _w:=trunc(Fonts[1].TextWidth(Language[59])/ 2);
      Fonts[1].TextOut(Language[59],800*resolutionscaleX-_w,
          510*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));


      for I := 0 to Menus[MenuN].bcount-1 do
      Begin
        _str:=Language[Menus[MenuN].buttons[i].name];
        _w:=trunc(Fonts[1].TextWidth(_str)/ 2);

        j:=70;
        if CurCButton=i then
          j:=200
          else
            if CurButton=i then
             j:=150;

         FillRect(trunc(_x-_w+(Menus[MenuN].buttons[i].x-20)*resolutionscaleX),
          trunc((570+Menus[MenuN].buttons[i].y)*resolutionscaleY2),
          trunc(_w*2+40*resolutionscaleX),
          trunc(50*resolutionscaleY2),
          crgb1(10,100,200,trunc(_alf2*j)),fxBlend);


        Fonts[1].TextOut(_str,_x-_w+Menus[MenuN].buttons[i].x*resolutionscaleX,
          (580+Menus[MenuN].buttons[i].y)*resolutionscaleY2,
          cRGB1(255, 255, 255, trunc(_alf2*255)));
      End;
     End;

     MyCanvas.DrawStretch(HudImages.Image['Cursor3'],0, trunc(Mx),
      trunc(My), trunc(Mx+70*ResolutionScaleY2{X*normwscale}),
      trunc(My+70*ResolutionScaleY2{*normwscale}),false,false,
      cRGB4(255,255,255,255),
      fxBlend);
 End;


end;

procedure TMainForm.DrawMess;
//var _w,_h:integer;
begin
 { sline(trunc(messt));

  if messt<100 then
   messt:=messt+lagcount*3;
  if messt>100 then
   messt:=100;

  _w:=trunc(200*resolutionscaleX*messt/100);
  _h:=trunc(100*resolutionscaleY*messt/100);

  Mycanvas.FillRect(trunc(messx-w/2),trunc(messy-_h/2),
          trunc(_w),trunc(_h),
          crgb1(10,100,200,150),fxBlend);

  case messtip of
    1:Begin

      End;
    2: Begin

      End;


  end;  }

////
end;

{ TPlayer }

procedure TPlayer.CollideBox;
begin
   if keepitm=false then
       CollideRect := Rect(Round(X+30),           {40!}
                    Round(Y+30),
                    Round(X + ImageWidth*ScaleX-30),
                    Round(Y + ImageHeight*ScaleY-30))
       else
         CollideRect := Rect(Round(X)-30,
                    Round(Y)-30,
                    Round(X + ImageWidth*ScaleX)+30,
                    Round(Y + ImageHeight*ScaleY)+30);

end;

constructor TPlayer.Create(const AParent: TSpriteEngine);
  const
   n=33;
   PlayerPoints:array [1..n] of String =('l1','l2','l3','l4','l5','l6','l7',
   'r1','r2','hands','r3','r4','r5','r6','r7','a1','a2','a3','sphere','cure','plasmup','dop',
   'crash_1','crash_2','crash_3','crash_4','crash_5','shield','droid','dc1','dc2','dc3','detector');
   GunPoints:array [1..2] of String =('gun1','gun2');
  var
   PointList:TStringList;
   i,j:integer;

   Eff:TeffectSprite;
begin
  inherited;
    /////
    ddx:=0;
    ddy:=0;

  if Ultralow=false then
  Begin
  if levcolor then
    Begin
      Red:=levcol[1];
      Green:=levcol[2];
      Blue:=levcol[3];
    End else
      Begin
        Red:=240;
        Green:=240;
        Blue:=240;
      End;
  End;

    Childs:=TList.Create;
    _Player:=self;
    //// ЗАГРУЗКА CHILDов:
    PointList:=TStringList.Create;
    PointList.LoadFromFile('Data\Locs\Points.pts');
    for I := 0 to (PointList.Count - 1)div 3  do
      for j := 1 to n do
       if PointList[I*3]=PlayerPoints[j] then
          Begin
             Eff:=TEffectSprite.Create(Mainform.Engine);
              with  Eff do
               begin
                    ImageName := 'Box1';

                    X0 := strtoint( PointList[I*3+1] );
                    Y0 := strtoint( PointList[I*3+2] );
                    _R:=SQRT(SQR(x0)+SQR(y0));
                    Visible:=false;
                    EffectType:=eLamp;
                    EffName:=PlayerPoints[j];

                    if Ultralow=false then
                      if levcolor then
                      Begin
                        Red:=levcol[1];
                        Green:=levcol[2];
                        Blue:=levcol[3];
                      End;


                    if Mainform.Images.Find(effname)<>-1 then
                      ImageName := effname;

                    if pos('dc',playerpoints[j])=1 then
                    Begin
                      if Mainform.Images.Find('eff2')<>-1 then
                        ImageName := 'eff2';
                    End;

                    z:=2;
                    if (playerpoints[j]='hands')or
                      (playerpoints[j]='plasmup')or
                      (playerpoints[j]='detector') then
                     z:=0;

                    if playerpoints[j]='cure' then
                       if Hieffs=false then z:=1;


                    if playerpoints[j]='droid' then
                    Begin
                      z:=-2;
                      animcount:=30;
                      alf2:=0;
                      Eticks:=0;
                      scaleX:=1.5;
                      scaleY:=1.5;
                    End;

                   if playerpoints[j]='sphere' then
                    Begin
                      AnimSpeed:=0.2;
                      AnimCount:=36;

                      Visible:=true;

                      scaleX:=0.8;
                      scaleY:=0.8;
                    End;

                     if playerpoints[j]='shield' then
                     Begin
                      ImageName :='shield';
                        scaleX:=4.0;
                        scaleY:=4.0;

                      drawfx:=fxadd;

                      if hidet then
                      Begin
                        scaleX:=2.0;
                        scaleY:=2.0;
                      End;
                      AnimSpeed:=0.2;
                      AnimCount:=36;
                     End;

                    DrawMode:=1;
                    alf0:=geta0(round(x0),round(y0));
                    Childs.add(eff);
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                    // showmessage(inttostr(round(alf0*180/pi)));
                   { if y0<>0 then
                    alf0:=arctan(x0/y0)*180/pi
                     else alf0:=0;}
               end;

          End;




    /// ГНЁЗДА ПУШЕК

    PointList.LoadFromFile('Data\Locs\Points2.pts');

    for I := 0 to (PointList.Count - 1)div 3  do
      for j := 1 to 2 do
       if PointList[I*3]=GunPoints[j] then
          Begin
             GunPos[j].X:= strtoint( PointList[I*3+1] );
             GunPos[j].Y:= strtoint( PointList[I*3+2] );
             RAGunPos[j,1]:=SQRT(SQR(GunPos[j].X)+SQR(GunPos[j].Y));
             RAGunPos[j,2]:=geta0(round(GunPos[j].X),round(GunPos[j].Y));
          End;


    //// ФИЗИКА

    ///  тело

    PointList.LoadFromFile('Data\Physics\Body.loc');
    Body.x0:=strtoint(Pointlist[0]);
    Body.y0:=strtoint(Pointlist[1]);
    Body.radius:=strtoint(Pointlist[2]);

    /// крылья
    PointList.LoadFromFile('Data\Physics\Wing1.loc');
    Wing1.Posx0:=strtoint(Pointlist[0]);
    Wing1.Posy0:=strtoint(Pointlist[1]);
    Wing1.x0[1]:=strtoint(Pointlist[2]);
    Wing1.y0[1]:=strtoint(Pointlist[3]);
    Wing1.x0[2]:=strtoint(Pointlist[4]);
    Wing1.y0[2]:=strtoint(Pointlist[5]);

    Wing1.RAD:=SQRT(SQR(wing1.Posx0)+SQR(wing1.Posy0));
    Wing1.ANG:=GetA0(wing1.Posx0,wing1.Posy0);

    PointList.LoadFromFile('Data\Physics\Wing2.loc');
    Wing2.Posx0:=strtoint(Pointlist[0]);
    Wing2.Posy0:=strtoint(Pointlist[1]);
    Wing2.x0[1]:=strtoint(Pointlist[2]);
    Wing2.y0[1]:=strtoint(Pointlist[3]);
    Wing2.x0[2]:=strtoint(Pointlist[4]);
    Wing2.y0[2]:=strtoint(Pointlist[5]);

    Wing2.RAD:=SQRT(SQR(wing2.Posx0)+SQR(wing2.Posy0));
    Wing2.ANG:=GetA0(wing2.Posx0,wing2.Posy0);

    PointList.LoadFromFile('Data\Physics\keepBox.loc');
    kb1.Posx0:=strtoint(Pointlist[0]);
    kb1.Posy0:=strtoint(Pointlist[1]);
    kb1.x0[1]:=strtoint(Pointlist[2]);
    kb1.y0[1]:=strtoint(Pointlist[3]);
    kb1.x0[2]:=strtoint(Pointlist[4]);
    kb1.y0[2]:=strtoint(Pointlist[5]);

    kb1.RAD:=SQRT(SQR(kb1.Posx0)+SQR(kb1.Posy0));
    kb1.ANG:=GetA0(kb1.Posx0,kb1.Posy0);

    PointList.LoadFromFile('Data\Physics\keepBox2.loc');
    kb2.Posx0:=strtoint(Pointlist[0]);
    kb2.Posy0:=strtoint(Pointlist[1]);
    kb2.x0[1]:=strtoint(Pointlist[2]);
    kb2.y0[1]:=strtoint(Pointlist[3]);
    kb2.x0[2]:=strtoint(Pointlist[4]);
    kb2.y0[2]:=strtoint(Pointlist[5]);

    kb2.RAD:=SQRT(SQR(kb2.Posx0)+SQR(kb2.Posy0));
    kB2.ANG:=GetA0(kb2.Posx0,kb2.Posy0);


    Impulse.ImpPower:=0;

    PointList.Destroy;
end;

procedure TPlayer.Explode;
var i,xx,yy,r:integer;
    alf:real;
    str:Tstringlist;
begin
  ExplodeEff(x+128,y+128,1.5,PExplode);
  MiniExplodeEff2(x+128,y+128,PExplode);
  Mainform.BoomPhys(trunc(X+128),trunc(Y+128),6,200,2);

  //Mainform.SoundSystem2.Play('boom2.wav',false);
  Mainform.DXWave.items.Find('boom2.wav').Play(false);

  if Hieffs then
  ExplodeDopEff(x+128,y+128,24,10,1,4,false);

 // Gameover:=true;

  xx:=trunc(x);
  yy:=trunc(y);

  Waittofade:=150;

   str:=Tstringlist.Create;
   Str.LoadFromFile('Data\Locs\Points3.pts');

    {  for j := 1 to 2 do
       if PointList[I*3]=GunPoints[j] then
          Begin
             GunPos[j].X:= strtoint( PointList[I*3+1] );
             GunPos[j].Y:= strtoint( PointList[I*3+2] );
             RAGunPos[j,1]:=SQRT(SQR(GunPos[j].X)+SQR(GunPos[j].Y));
             RAGunPos[j,2]:=geta0(round(GunPos[j].X),round(GunPos[j].Y));
          End;}


  for i:=0 to 4 do
     with  TCapsule.Create(Mainform.Engine) do
                  begin
                    imagename:='Box1';
                    if mainform.Images.Find(str[i*3])<>-1 then
                      Imagename:=str[i*3];
                    AnimCount:=PatternCount;
                    AnimSpeed:=0.3;

                    if i=1 then MirrorY:=true;

                    alf:=geta0(round(strtoint(str[i*3+1])),round(strtoint(str[i*3+2])));
                    r:=trunc(SQRT(SQR(strtoint(str[i*3+1]))+SQR(strtoint(str[i*3+2]))));

                    Angle:=-Palf;

                    impulse1.ImpX:=cos(alf-Angle);
                    impulse1.ImpY:=-sin(alf-Angle);
                    impulse1.ImpPower:=1.1;

                    x:=XX+128+R*Cos(-Angle+alf)-imageWidth/2;    /////////!!!!
                    y:=YY+128+R*Sin(-Angle+alf)-imageHeight/2;

                    sizeXd2:=imageWidth div 2;
                    sizeYd2:=imageHeight div 2;
                    ///DrawMode:=1;

                    z:=0;
                    tip:=1;

                    if hieffs=false then
                    Begin
                     DrawMode:=1;
                     Offsetx:=imageWidth/2;    /////////!!!!
                     Offsety:=imageHeight/2;
                    End;

                    CollideMethod:= cmRect;
                    DoCollision := true;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
                  end;
   str.Destroy;
end;

function TPlayer.GetA0(dx, dy: integer): real;
begin
  if (dx)<>0 then
  Begin
    if (dx)>0 then
    Begin
      result:=-arctan((dy)/(dx));
    End
    else
      Begin
        result:=-pi + arctan((-dy)/(dx));
      End;
  End
  else
    Begin
      result:=0;
    End;

    while result<0 do
      result:=result+2*pi;
    while result>2*pi do
      result:=result-2*pi;
end;

procedure TPlayer.KeepImpulse;
begin
///
if (impulse.ImpPower>10) then
   impulse.ImpPower:=10;
if impulse.ImpPower>0 then
   impulse.ImpPower:=impulse.ImpPower-lagcount/10;
if impulse.ImpPower<0 then
   impulse.ImpPower:=0;

end;

procedure TPlayer.Move(const MoveCount: Single);
const maxR=800;
      minR=50;
var i,j:integer;
    curR,_alf,_palf,ang:real;
    spr:TSprite;
begin
  inherited;

  x:=x+ddx;
  y:=y+ddy;

   VeloX:=0;
   Veloy:=0;
   SetBox;


  if health>0 then
  Begin
    /// ПЛАВНЫЙ ПОВОРОТ
    Turn(MoveCount);

   { /// FOG OF WAR
    if Fogofwar[trunc(x/1000), trunc(y/1000)]=false then
      Fogofwar[trunc(x/1000), trunc(y/1000)]:=true;}

    if Radar then
    Begin
      if Minimapobjcount<512 then inc(Minimapobjcount);
       MMap[MiniMapObjCount,0]:=10;
       MMap[MiniMapObjCount,1]:=5;
       MMap[MiniMapObjCount,2]:=5;
       MMap[MiniMapObjCount,3]:=10;
       MMap[MiniMapObjCount,4]:=10;
    End;

    CurR:=RV;
    if CurR>maxR then curR:=MaxR
      else
        if CurR<minR then curR:=0.1;

    ///// ПЕРЕМЕЩЕНИЕ
    ///
    KeepImpulse;
    if EngineOn then
    Begin
      if Force.ImpPower<playerMaxSpd+Hispeed then
        Force.ImpPower:=Force.ImpPower+0.3*MoveCount;
      if Force.ImpPower>PlayerMaxSpd+Hispeed then
        Force.ImpPower:=PlayerMaxSpd+Hispeed;
      Force.ImpX:=Cos(Palf);
      Force.ImpY:=-Sin(Palf);
    End else
    Begin

      if Force.ImpPower>0.0 then
        Force.ImpPower:=Force.ImpPower-0.09*MoveCount
         else
         Begin
           Force.ImpX:=Cos(Palf);
           Force.ImpY:=-Sin(Palf);
         End;

      if Force.ImpPower<0.0 then
        Force.ImpPower:=0.0;

    End;


    velo:=force;

    if Impulse.ImpPower>0 then
    Velo:=Mainform.SuperPos(Force,Impulse);

    VeloX:=Velo.ImpX*MoveCount*Velo.ImpPower;
    VeloY:=Velo.ImpY*MoveCount*Velo.ImpPower;

   { VeloX:=Cos(Palf)*MoveCount*CurR/100;
    Veloy:=-Sin(Palf)*MoveCount*CurR/100;}
     
    x:=x+VeloX;
    y:=y+VeloY;


      // СТОЛКНОВЕНИЯ


       CollideBox;

        VeloX:=-OldX+X;//+VeloX;
        VeloY:=-OldY+Y;//+VeloY;

       Collision;

       OldX:=X;
       OldY:=y;

    //// СОПЛО
              Pticks:=Pticks+MoveCount;
              if Pticks>2 then
              Begin
                i:=round(x+128-cos(palf)*85);
                j:=round(y+128+sin(palf)*85);
                if hispeed>0 then
                Begin
                   FireEff(i,j, pFire,1);
                    if EngineOn=true then
                       SparkEff5(i,j,2,5);

                End
                    else
                  Begin
                    FireEff(i,j, pFire,1);
                    if EngineOn=true then
                      FireEff(i,j, pFire,2);
                  End;

                Pticks:=0;
              End;

    //// КАДР
    if ultralow=false then
     patternIndex:=round((Palf*180/pi)/5)
     else
      Angle:=-palf;//(pi*palf/36)


    //imageindex:=animstart;
    //animpos:=animstart;
  End
   else
    BEGIN
      Visible:=false;
      if not(GameOver) then
      Begin
        GameOver:=true;
        if MusVolume>0 then
          Mainform.SoundSystem.FadeOut(CurrentTrack,70);
        ///// Биг Бада-Бум
        Explode;
        BoomTime:=50;
      End;
    END;

  if health>0 then
  /// СТРЕЛЬБА
  if CurrentWeapon<>0 then
  if WaitShoot then
    if ((Weapons[currentweapon].Count>0)or(rainbow))  ////////////////// !!!!!!!!!!
      and (Weapons[currentweapon].CurrentTime>=WReloadTimes[currentweapon]) then
      Begin
          if unltd=false then
            if rainbow=false then
              dec(Weapons[currentweapon].Count);
          Weapons[currentweapon].CurrentTime:=0;
          
          if rainbow then
            inc(RBO);
          //Mainform.SoundSystem2.Play('laser2.wav',false);   //////////// SHOOT
          Mainform.DXWave.items.Find('laser2.wav').Play(false);

        for I := 1 to 2 do Begin
           inc(Levelscore.shootscount);
          /// ВЫЧИСЛЯЕМ ПОЛОЖЕНИЕ "ГНЁЗД"
          GunPos[i].X:=128+round(X+RAGunPos[i,1]*Cos(RAGunPos[i,2]+palf));
          GunPos[i].Y:=128+round(Y-RAGunPos[i,1]*Sin(RAGunPos[i,2]+palf));
          /// ВЫПУСК TARMOSPRITE
           _alf:=round((palf*180/pi)/5)*5;
           _palf:=palf;
           if plasmup then
             sparkeff5(GunPos[i].X,GunPos[i].Y,10,currentweapon);


              with  TArmoSprite.Create(Engine) do
               begin
                    ImageName := 'Shot1';
                    X := GunPos[i].X {- ImageWidth div 2};
                    Y := GunPos[i].Y {- ImageHeight div 2};
                    x0:=x;
                    y0:=y;
                    CollideMethod := cmRect;
                    DoCollision := True;
                    Angle:=-_alf*pi/180;
                    if rv<220 then
                    Begin
                      ang:=pi/15;
                      MaxL:=trunc(WLMax[CurrentWeapon]/ 4);
                    End
                       else
                        if rv<500 then
                        Begin
                          ang:=pi/30;
                          MaxL:=trunc(WLMax[CurrentWeapon]*0.6);
                        End
                          else
                          Begin
                            ang:=pi/50;
                            MaxL:=WLMax[CurrentWeapon];
                          End;

                    if i=1 then
                      _palf:=_palf-ang
                       else if i=2 then
                          _palf:=_palf+ang;

                    VeloX:=Wspeed[CurrentWeapon]*Cos(_palf);
                    VeloY:=-Wspeed[CurrentWeapon]*Sin(_palf);
                    DrawMode:=1;
                    L:=0;

                    if i=1 then num:=-1;
                    if i=2 then num:=1;
                    ArmoType:=aTrasser;///WArmoTypes[currentweapon];
                    col:=currentweapon;

                    if rainbow then
                      col:=8;

                    armopower:=round(10*(2-diff[diffi]));
                    if plasmup then
                    Begin
                      armopower:=round(24*(2-diff[diffi]));    {УСИЛЕННЫЕ ПУЛИ}
                      //ArmoType:=aTrasser2;
                    End;
                    //// if then armopower:=20;
                    Red:=redw[currentWeapon];
                    Green:=Greenw[currentWeapon];
                    Blue:=Bluew[currentWeapon];
                    //Drawfx:=fxOneColor;
                    scaleX:=0.5; scaleY:=0.5;
                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;
               end;
       End;
  end else Waitshoot:=false;


  /// ОКРУГЛЕНИЕ

    ddx:=x-round(x);
    ddy:=y-round(y);
    x:=round(x);
    y:=round(y);



  /// ПЕРЕДАЧА ГЛОБАЛЬНЫХ ДАННЫХ

 // _alf:=round((palf*180/pi)/5)*5;
  for I := 0 to Childs.Count - 1 do
    if (Childs[i]<>nil) then
    Begin
     Spr:=Childs[i];
     if spr is TeffectSprite then
     Begin
      TeffectSprite(spr).Move(0);
  //    TeffectSprite(spr).x1:=x;
  //    TeffectSprite(spr).y1:=y;
   //   TeffectSprite(spr).alf1:=_alf;
     End;
    End;

  if keepitm then
     if keepsprite<>nil then
      TSprite(KeepSprite).Move(0);

  if cameramode=cmMove then
  Begin
    //// КАМЕРА
    Engine.WorldX:=((X + BoomX+128 + cos(alf)*Rv/6)-(Mainform.Device.Width)/WorldScaleX/2);
    if Engine.WorldY<> (Y-128/WorldScaleY) then
      Engine.Worldy := ((Y+128 + BoomY - sin(alf)*Rv/6)-(Mainform.Device.Height)/WorldScaleY/2) ;

    /// КООРДИНАТЫ СЛОЁВ ФОНА
    layerX:=x+ cos(alf)*Rv/6;
    layerY:=y- sin(alf)*Rv/6;
  End else
    if cameramode=cmCenter then
  Begin
    //// КАМЕРА
    Engine.WorldX:=((round(X) + BoomX+128)-(Mainform.Device.Width)/WorldScaleX/2);
    if Engine.WorldY<> (Y-128/WorldScaleY) then
      Engine.Worldy := ((round(Y)+128 + BoomY)-(Mainform.Device.Height)/WorldScaleY/2) ;

   // CamScale:=1;
   { if mx<mgx then
      CamScale:=CamScale-((mgx-mx)/mgx)*0.2;
                                                               // .. ячя
    if mx>Mainform.Device.width-mgx then
      CamScale:=CamScale+((Mainform.Device.width-mgx-mx)/mgx)*0.2;  }
   // mGx
   // mGy
    

    /// КООРДИНАТЫ СЛОЁВ ФОНА
    layerX:=x*normwscale;
    layerY:=y*normwscale;
  End;

  if detect then
  Begin
    detcol[1]:=0;
    detcol[2]:=0;
    detcol[3]:=0;
  End;

end;

procedure TPlayer.OnCollision(const Sprite: TSprite);
var i:integer;
 xp,yp,ii,jj,_alf,xx,yy,MMCount:real;
 Spr:TeffectSprite; /// DEL!
 touch:boolean;
 DopImp:TImpulse;
begin
  inherited;
if health>0 then
Begin



 if (sprite is TDopEff)then
 if (Objs[TDopEff(Sprite).MyObjN].Name='noway')and(Levelmission>0) then
 Begin
   Touch:=false;
   if (TDopEff(Sprite).cnt=0) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=Body.X;
     if ((abs(Body.y-yp)<Body.radius)and(xp>Sprite.x-Sprite.SpriteWidth-16)and(xp<Sprite.x+Sprite.SpriteWidth+16)) then
     Begin
        touch:=true;
        EngineOn:=false;
        Impulse:=force;

          if ((Body.y>yp){and(Force.ImpY<0)}) then
            Impulse.ImpY:=1
              else
            if ((Body.y<yp){and(Force.ImpY>0)}) then
              Impulse.ImpY:=-1;

            force.ImpPower:=0;

            Impulse.ImpPower:=5;
     end
      End else

     Begin
     /// Вертикально
      xp:=Sprite.x+Sprite.SpriteWidth/2;
      yp:=Body.Y;
     if (abs(Body.x-xp)<Body.radius)and(yp>Sprite.y-Sprite.SpriteHeight-16)and(yp<Sprite.y+Sprite.SpriteHeight+16) then
     Begin
        touch:=true;
        EngineOn:=false;
        Impulse:=force;

          if ((Body.x>xp){and(Force.ImpY<0)}) then
            Impulse.ImpX:=1
              else
            if ((Body.x<xp){and(Force.ImpY>0)}) then
              Impulse.ImpX:=-1;

            force.ImpPower:=0;

            Impulse.ImpPower:=5;
        End;
 End;
 if touch then
 Begin
  smessage:=language[183];
  smessagetime:=200;
 End;

 End;








  if sprite is TLaser then
  Begin
   Touch:=false;
   if (Tlaser(Sprite).direction=1)or(Tlaser(Sprite).direction=3) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=Body.X;
     if ((abs(Body.y-yp)<Body.radius)and(xp>Sprite.x-16)and(xp<Sprite.x+Sprite.SpriteWidth+16))
     or ((abs(Wing1.posy-yp)<20)and(Wing1.PosX>Sprite.x-10)and(Wing1.PosX<Sprite.x+Sprite.SpriteWidth+10))
     or ((abs(Wing2.posy-yp)<20)and(Wing2.PosX>Sprite.x-10)and(Wing2.PosX<Sprite.x+Sprite.SpriteWidth+10)) then
     Begin
        touch:=true;
        EngineOn:=false;
        Impulse:=force;
        if not((Shieldtime>0)and(shieldcolor=Tlaser(Sprite).lascolor)) then
        Begin
          if ((Body.y>yp){and(Force.ImpY<0)}) then
            Impulse.ImpY:=1
              else
            if ((Body.y<yp){and(Force.ImpY>0)}) then
              Impulse.ImpY:=-1;

            force.ImpPower:=0;

            Impulse.ImpPower:=5;
        End;

       // xx:=sqrt(sqr(Body.radius)-sqr(sprite.Y+sprite.SpriteHeight/2));
       // xp:=-sqrt(sqr(Body.radius)-sqr(sprite.Y+sprite.SpriteHeight/2));
     End;
   End else
   Begin
     /// Вертикально
      xp:=Sprite.x+Sprite.SpriteWidth/2;
      yp:=Body.Y;
     if (abs(Body.x-xp)<Body.radius)and(yp>Sprite.y-16)and(yp<Sprite.y+Sprite.SpriteHeight+16)
     or ((abs(Wing1.posX-xp)<20)and(Wing1.PosY>Sprite.Y-10)and(Wing1.PosY<Sprite.y+Sprite.SpriteHeight+10))
     or ((abs(Wing2.posX-xp)<20)and(Wing2.PosY>Sprite.Y-10)and(Wing2.PosY<Sprite.y+Sprite.SpriteHeight+10)) then

     Begin
        touch:=true;
        EngineOn:=false;
        Impulse:=force;
        if not((Shieldtime>0)and(shieldcolor=Tlaser(Sprite).lascolor)) then
        Begin
          if ((Body.x>xp){and(Force.ImpY<0)}) then
            Impulse.ImpX:=1
              else
            if ((Body.x<xp){and(Force.ImpY>0)}) then
              Impulse.ImpX:=-1;

            force.ImpPower:=0;

            Impulse.ImpPower:=5;
        End;
     End;
   End;

   if touch then
     Begin
       //health:=health-lagcount;
       IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<2 then
       Begin
          Mainform.DXWave.items.Find('electro.wav').Play(false);
          if not((Shieldtime>0)and(shieldcolor=Tlaser(Sprite).lascolor)) then
            health:=health-5;
          Sparkeff2(xp,yp,Pfire,true);
          Sparkeff(xp,yp,Pfire);

       End;
     End;
  End;

  if sprite is TCapsule then Begin
    if (TCapsule(sprite).noob=false) then
      Begin
         ii:=sqrt(sqr(Body.X-TCapsule(sprite).Capsuleshape.POsX)+
         sqr(Body.y-TCapsule(sprite).Capsuleshape.POsY));

         if (ii<Body.radius+TCapsule(sprite).Capsuleshape.RAD{50 = радиус капсулы})and(TCapsule(sprite).noob=false)and(ii>1)  then
         Begin
           jj:=(Body.radius+TCapsule(sprite).Capsuleshape.RAD-ii);
           ii:=jj/(Body.radius+TCapsule(sprite).Capsuleshape.RAD);
           xp:=(Body.X-TCapsule(sprite).Capsuleshape.POsX)*ii;
           yp:=(Body.Y-TCapsule(sprite).Capsuleshape.POsY)*ii;

           if TCapsule(sprite).InPlayer=false then
           Begin
            //Mainform.SoundSystem2.Play('metal.wav',false);
            Mainform.DXWave.items.Find('metal.wav').Play(false);
            TCapsule(sprite).InPlayer:=true;
           End;

           if TCapsule(sprite).Statics=true then
           Begin
             // X:=X+xp;
             //y:=y+yp;
             TCapsule(sprite).noob:=true;
           End else
            Begin
               TCapsule(sprite).X:=TCapsule(sprite).X-xp;
               TCapsule(sprite).y:=TCapsule(sprite).y-yp;
            End;

           if TCapsule(sprite).noob2=false then
           Begin
            DopImp.ImpX:=-xp/jj;//-(Body.X-TCapsule(sprite).Capsuleshape.POsX)/(Body.radius+50);
            DopImp.ImpY:=-yp/jj;//-(Body.Y-TCapsule(sprite).Capsuleshape.POsY)/(Body.radius+50);
            DopImp.ImpPower:=1;
            xp:=Velo.ImpPower;
            Velo.ImpPower:=0.1;
            DopImp:=Mainform.Superpos(velo,DopImp);
            Velo.ImpPower:=xp;
            TCapsule(sprite).Impulse1:=Mainform.Superpos(TCapsule(sprite).Impulse1,DopImp);
            TCapsule(sprite).noob2:=true;
           End;
         End else
         Begin
           TCapsule(sprite).noob2:=false;
         End;

      End;
  End;

   if sprite is TArmoSprite then
  if TarmoSprite(Sprite).enm=true then
  Begin
      Begin
         ii:=sqrt(sqr(Body.X-Sprite.X)+
         sqr(Body.y-Sprite.Y));


         if (shieldtime>0) and(shieldcolor=TarmoSprite(Sprite).col) then
         Begin
           if ii<256+TarmoSprite(Sprite).rad then
           Begin
             SparkEff3(TArmosprite(sprite).x,TArmosprite(sprite).y,shieldcolor,1,pFire);
             Sprite.Dead;
           End;
         End else

         if (ii<Body.radius+TArmosprite(sprite).rad) then
         Begin
          Health:=health-TarmoSprite(Sprite).armoPower;

          //Mainform.SoundSystem2.Play('metal.wav',false);
          Mainform.DXWave.items.Find('metal.wav').Play(false);

          Sprite.Dead;

          if TarmoSprite(Sprite).ArmoType=aBall then
             MainForm.BoomPhys(trunc(Sprite.X),trunc(Sprite.Y),5,100,6);

          if hieffs then
            SparkEff(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire);
          SparkEff2(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire,false);

          if TarmoSprite(Sprite).ArmoType=aTrasser3 then
            Sparkeff3(TArmosprite(sprite).x,TArmosprite(sprite).y,TArmosprite(sprite).col,1,pexplode2);

          //FireEff(TArmosprite(sprite).x,TArmosprite(sprite).y, pFire, 1);
          if hidet then
          FireEff2(TArmosprite(sprite).x,TArmosprite(sprite).y, 10, pFire);
         End;
      End;
  End;

  if sprite is Tmina then
  Begin
      Begin
         ii:=sqrt(sqr(Body.X-Tmina(sprite).minaShape.POsX)+
         sqr(Body.y-Tmina(sprite).minaShape.POsY));
         if (ii<Body.radius+50) then
         Begin

           jj:=(Body.radius+50-ii);
           ii:=jj/(Body.radius+50);

           xp:=(Body.X-TMina(sprite).Minashape.POsX)*ii;
           yp:=(Body.Y-TMina(sprite).Minashape.POsY)*ii;

           Tmina(sprite).exp:=true;

           if Tmina(sprite).statics=false then
           Begin
            Tmina(sprite).X:=Tmina(sprite).X-xp;//(Body.X-Tmina(sprite).minaShape.POsX)/(Body.radius+50);
            Tmina(sprite).y:=Tmina(sprite).y-yp;//(Body.Y-Tmina(sprite).minaShape.POsY)/(Body.radius+50);
           End;

          if Tmina(sprite).noob2=false then
           Begin
            DopImp.ImpX:=-xp/jj;//-(Body.X-Tmina(sprite).minaShape.POsX)/(Body.radius+50);
            DopImp.ImpY:=-yp/jj;//-(Body.Y-Tmina(sprite).minaShape.POsY)/(Body.radius+50);
            DopImp.ImpPower:=2;
            xp:=Velo.ImpPower;
            Velo.ImpPower:=1;
            DopImp:=Mainform.Superpos(velo,DopImp);
            Velo.ImpPower:=xp;

            //Mainform.SoundSystem2.Play('metal.wav',false);
            Mainform.DXWave.items.Find('metal.wav').Play(false);

            Tmina(sprite).Impulse1:=Mainform.Superpos(Tmina(sprite).Impulse1,DopImp);
            Tmina(sprite).noob2:=true;
           End;
         End else
         Begin
           Tmina(sprite).noob2:=false;
         End;

      End;
  End;

  if sprite is TEnemy then
  Begin
      SetBox;
      TEnemy(sprite).SetEnmBox;

      ii:=sqrt(sqr(Body.X-TEnemy(sprite).EnmBody.x)
              +sqr(Body.Y-TEnemy(sprite).EnmBody.Y));  ////////////////!!!! ENEMY COL!

        // Mainform.SoundSystem2.Play('metal.wav',false);

         if (ii<Body.radius+TEnemy(sprite).EnmBody.radius)and(ii>1) then
         Begin
            TEnemy(sprite).OldX:=TEnemy(sprite).X;
            TEnemy(sprite).OldY:=TEnemy(sprite).Y;

            if (TEnemy(sprite).EnmName='enm5')
                or(TEnemy(sprite).EnmName='enm10') then
               TEnemy(sprite).EnmHealth:=0;
                                                          // cvxc
            ii:=(Body.radius+TEnemy(sprite).EnmBody.radius-ii)/(Body.radius+TEnemy(sprite).EnmBody.radius);

            xp:=((Body.X-TEnemy(sprite).EnmBody.x)*ii);//(Body.radius+TEnemy(sprite).EnmBody.radius));
            yp:=((Body.Y-TEnemy(sprite).EnmBody.y)*ii);//(Body.radius+TEnemy(sprite).EnmBody.radius));

                X:=x+xp/2;
                y:=y+yp/2;

            if TEnemy(sprite).AITip=5 then
              TEnemy(sprite).EnmHealth:=0;

           if (TEnemy(Sprite).InWall=true)or(TEnemy(Sprite).AITip>=9) then
           Begin
           { X:=x+xp;
            y:=y+yp;
            Impulse.ImpX:=xp/abs(xp+yp);
            Impulse.ImpY:=yp/abs(xp+yp);
            Impulse.ImpPower:=1;}
           End
            else
              Begin
                TEnemy(sprite).X:=TEnemy(sprite).X-xp/2;
                TEnemy(sprite).y:=TEnemy(sprite).y-yp/2;
                //X:=x+xp/2;
                //y:=y+yp/2;
              End;
      End
      else
        if TEnemy(Sprite).EnmSubCount>0 then
        for i := 1 to TEnemy(Sprite).EnmSubCount do

        Begin
            ii:=sqrt(sqr(Body.X-TEnemy(sprite).enmSubbodies[i].x)
              +sqr(Body.Y-TEnemy(sprite).enmSubbodies[i].Y));  ////////////////!!!! ENEMY COL!

            if (ii<Body.radius+TEnemy(sprite).enmSubbodies[i].radius)and(ii>1) then
            Begin
              TEnemy(sprite).OldX:=TEnemy(sprite).X;
              TEnemy(sprite).OldY:=TEnemy(sprite).Y;
                                                          // cvxc
              ii:=(Body.radius+TEnemy(sprite).enmSubbodies[i].radius-ii)/
                      (Body.radius+TEnemy(sprite).enmSubbodies[i].radius);

              xp:=((Body.X-TEnemy(sprite).enmSubbodies[i].x)*ii);
              yp:=((Body.Y-TEnemy(sprite).enmSubbodies[i].y)*ii);

                X:=x+xp/2;
                y:=y+yp/2;

              if TEnemy(Sprite).InWall=false then
              Begin
                TEnemy(sprite).X:=TEnemy(sprite).X-xp/2;
                TEnemy(sprite).y:=TEnemy(sprite).y-yp/2;
              End;

            End;
        End;

   SetBox;
  End;

 if sprite is TTile then Begin
   SetBox;
   xx:=x;
   yy:=y;

   MMCount:=2*Lagcount;
   if (TTile(Sprite).tip>1) then
    MMCount:=1;


   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
    Begin
     // cols:=0;
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
          
            {СЧИТАЮ X пересечения с Y}
            //if VeloX<>0 then
             // xp:=

           if keepitm then
           if VeloY<0 then
            if keepbox.y[1]<=TTile(Sprite).lines[i].y1 then
            if (keepbox.x[2]-velox>TTile(Sprite).lines[i].x1)
                and(keepbox.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y1-keepbox.y[1]))<abs(Veloy*5)+30{*MMcount} then
              Begin
              y:=y+(TTile(Sprite).lines[i].y1-keepbox.y[1]);
              SetBox;
              if (EngineOn=false) then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=-0.01;
              End;
            End;


            if Wing1.y[1]<TTile(Sprite).lines[i].y1 then

            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y1-Wing1.y[1]))<10*MMcount then
              Begin
              y:=y+(TTile(Sprite).lines[i].y1-Wing1.y[1]);
              SetBox;
              if (EngineOn=false) then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=-0.01;
              End;
            End;


            if Wing2.y[1]<TTile(Sprite).lines[i].y1 then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y1-Wing2.y[1]))<10*MMcount then
              Begin
              y:=y+(TTile(Sprite).lines[i].y1-Wing2.y[1]);
              SetBox;
              if (EngineOn=false) then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=-0.01;
              End;
            End;
          if VeloY<0 then
          Begin
            if Body.y-Body.radius<TTile(Sprite).lines[i].y1 then
            if (Body.X+Body.radius-velox>TTile(Sprite).lines[i].x1)and(Body.x-Body.radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(TTile(Sprite).lines[i].y1-Body.y+Body.radius)<abs(Veloy*5)+10{*Mcount} then
              Begin
              y:=y+(TTile(Sprite).lines[i].y1-Body.y+Body.radius);
              SetBox;
              if (EngineOn=false) then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=-0.01;
              End;
            End;
          End;
        End;
        2: Begin /// Left
            if keepitm then
            if VeloX<0 then
            if keepbox.x[1]<TTile(Sprite).lines[i].x1 then
            if (keepbox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(keepbox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x1-keepbox.x[1])<abs(VeloX*5)+30{*Mcount} then
              Begin
              x:=x+(TTile(Sprite).lines[i].x1-keepbox.x[1])
              ;//  else showmessage(floattostr(10*Mcount)+' < '+floattostr(TTile(Sprite).lines[i].x1-Wing1.x[1]));;;
              SetBox;
              if EngineOn=false then
              Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=-0.01;
              End;
            End;

            if Wing1.x[1]<TTile(Sprite).lines[i].x1 then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x1-Wing1.x[1])<10*MMcount then
              Begin
              x:=x+(TTile(Sprite).lines[i].x1-Wing1.x[1])
              ;//  else showmessage(floattostr(10*Mcount)+' < '+floattostr(TTile(Sprite).lines[i].x1-Wing1.x[1]));;;
              SetBox;
              if EngineOn=false then
              Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=-0.01;
              End;
            End;
            if Wing2.x[1]<TTile(Sprite).lines[i].x1 then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x1-Wing2.x[1])<10*MMcount then
              Begin
              x:=x+(TTile(Sprite).lines[i].x1-Wing2.x[1]);
              SetBox;
              if EngineOn=false then
              Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=-0.01;
              End;
            End;
          if VeloX<0 then
          Begin
            if Body.x-Body.radius<TTile(Sprite).lines[i].x1 then
            if (Body.y+Body.radius-veloy>TTile(Sprite).lines[i].y1)and(Body.y-Body.radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x1-Body.x+Body.radius)<abs(VeloX*5)+10{*Mcount} then
              Begin
              x:=x+(TTile(Sprite).lines[i].x1-Body.x+Body.radius);
              SetBox;
               if EngineOn=false then
                Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=-0.01;
              End;
            End;
          End;
        End;
        3: Begin /// Down
            if keepitm then
            if VeloY>0 then
            if keepbox.y[2]>TTile(Sprite).lines[i].y2 then
            if (keepbox.x[2]-velox>TTile(Sprite).lines[i].x1)and(keepbox.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y2-keepbox.y[2]))<abs(Veloy*5)+30{*Mcount} then
              Begin
              y:=y+(TTile(Sprite).lines[i].y2-keepbox.y[2]);
              SetBox;
              if EngineOn=false then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=0.01;
              End;
            End;

            if Wing1.y[2]>TTile(Sprite).lines[i].y2 then
            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y2-Wing1.y[2]))<10*MMcount then
              Begin
              y:=y+(TTile(Sprite).lines[i].y2-Wing1.y[2]);
              SetBox;
              if EngineOn=false then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=0.01;
              End;
            End;
            if Wing2.y[2]>TTile(Sprite).lines[i].y2 then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs((TTile(Sprite).lines[i].y2-Wing2.y[2]))<10*MMcount then
              Begin
              y:=y+(TTile(Sprite).lines[i].y2-Wing2.y[2]);
              SetBox;
              if EngineOn=false then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=0.01;
              End;
            End;
          if VeloY>0 then
          Begin
            if Body.y+Body.radius>TTile(Sprite).lines[i].y2 then
            if (Body.X+Body.radius-velox>TTile(Sprite).lines[i].x1)and(Body.x-Body.radius-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(TTile(Sprite).lines[i].y2-Body.y-Body.radius)<abs(Veloy*5)+10{*Mcount} then
              Begin
              y:=y+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetBox;
              if EngineOn=false then
                Force.ImpY:=-Force.ImpY/2
                else Force.ImpY:=0.01;
              End;
            End;
          End;
        End;
         4: Begin /// Right
            if keepitm then
            if VeloX>0 then
            if keepbox.x[2]>TTile(Sprite).lines[i].x2 then
            if (keepbox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(keepbox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x2-keepbox.x[2])<abs(VeloX*5)+30{*Mcount}then
              Begin
              x:=x+(TTile(Sprite).lines[i].x2-keepbox.x[2]);
              SetBox;
              if EngineOn=false then
                Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=0.01;
              //Force.ImpPower:=Force.ImpPower-Force.ImpPower*abs(Force.ImpX)/2;
              End;
            End;

            if Wing1.x[2]>TTile(Sprite).lines[i].x2 then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x2-Wing1.x[2])<10*MMcount then
              Begin
              x:=x+(TTile(Sprite).lines[i].x2-Wing1.x[2]);
              SetBox;
              if EngineOn=false then
                Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=0.01;
              End;
              //Force.ImpPower:=Force.ImpPower-Force.ImpPower*abs(Force.ImpX)/2;
            End;
            if Wing2.x[2]>TTile(Sprite).lines[i].x2 then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x2-Wing2.x[2])<10*MMcount then
              Begin
              x:=x+(TTile(Sprite).lines[i].x2-Wing2.x[2]);
              // else showmessage(floattostr(10*Mcount));;
              SetBox;
              if EngineOn=false then
                Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=0.01;
              End;
              //Force.ImpPower:=Force.ImpPower-Force.ImpPower*abs(Force.ImpX)/2;
            End;
          if VeloX>0 then
          Begin
            if Body.x+Body.radius>TTile(Sprite).lines[i].x2 then
            {ЗАМЕНИТЬ НА ПРОВЕРКУ С ПЕРЕСЕЧЕНИЕМ ВЕКТОРА СКОРОСТИ!!!!!!}
            if (Body.y+Body.radius-veloy>TTile(Sprite).lines[i].y1)and(Body.y-Body.radius-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(TTile(Sprite).lines[i].x2-Body.x-Body.radius)<abs(VeloX*5)+10{*Mcount} then
              Begin
              x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              // else showmessage(floattostr(10*Mcount));
              SetBox;
              if EngineOn=false then
                Force.ImpX:=-Force.ImpX/2
                else Force.ImpX:=0.01;
              End;
              //Force.ImpPower:=Force.ImpPower-Force.ImpPower*abs(Force.ImpX)/2;
            End;
          End;
        End;

         5: Begin /// Down+Left
         {Лево}
         if KeepItm then
          Begin
            xp:=TTile(Sprite).lines[i].x1+(KeepBox.y[2]-TTile(Sprite).lines[i].y1);
            if KeepBox.x[1]<xp then
            if (KeepBox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(KeepBox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-KeepBox.x[1])<abs(VeloX*5)+10 then
              x:=x+xp-KeepBox.x[1];
              SetBox
            End;
          end;

            xp:=TTile(Sprite).lines[i].x1+(Wing1.y[2]-TTile(Sprite).lines[i].y1);
            if Wing1.x[1]<xp then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing1.x[1])<10 then
              x:=x+xp-Wing1.x[1];//+(TTile(Sprite).lines[i].x1-Wing1.x[1])

              //  else showmessage(floattostr(10*Mcount)+' < '+floattostr(TTile(Sprite).lines[i].x1-Wing1.x[1]));;;
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1+(Wing2.y[2]-TTile(Sprite).lines[i].y1);
            if Wing2.x[1]<xp then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing2.x[1])<10 then
              x:=x+xp-Wing2.x[1];//+(TTile(Sprite).lines[i].x1-Wing1.x[1])
              //  else showmessage(floattostr(10*Mcount)+' < '+floattostr(TTile(Sprite).lines[i].x1-Wing1.x[1]));;;
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1+(Body.y+Body.radius/1.4142-TTile(Sprite).lines[i].y1);
            if Body.x-Body.radius/1.4142<xp then
            if (Body.y+Body.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(Body.y+Body.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
                yp:=TTile(Sprite).lines[i].y1+(Body.x-Body.radius/1.4142-TTile(Sprite).lines[i].x1);
                y:=y+(yp-Body.y-Body.radius/1.142);
              if abs(Body.x-Body.radius/1.4142-xp)<abs(VeloX*5)+10{*Mcount} then Begin
               x:=X+(xp-Body.x+Body.radius/1.4142);//+(TTile(Sprite).lines[i].x1-Body.x+Body.radius);
              End;
              SetBox
            End;

         // End;

         {Низ}
         if keepitm then
          Begin
            yp:=TTile(Sprite).lines[i].y1+(KeepBox.x[1]-TTile(Sprite).lines[i].x1);
            if KeepBox.y[2]>yp then
            if (KeepBox.x[2]-velox>TTile(Sprite).lines[i].x1)and(KeepBox.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-KeepBox.y[2])<abs(Veloy*5)+10 then
              y:=y+(yp-KeepBox.y[2]);
              SetBox
            End;
          End;

         if VeloY>0 then
          Begin
            yp:=TTile(Sprite).lines[i].y1+(wing1.x[1]-TTile(Sprite).lines[i].x1);
            if Wing1.y[2]>yp then
            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Wing1.y[2])<10 then
              y:=y+(yp-Wing1.y[2]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1+(wing2.x[1]-TTile(Sprite).lines[i].x1);
            if Wing2.y[2]>yp then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Wing2.y[2])<10 then
              y:=y+(yp-Wing2.y[2]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1+(Body.x-Body.radius/1.4142-TTile(Sprite).lines[i].x1);
            if Body.y+Body.radius/1.142>yp then
            if (Body.X-Body.radius/1.142-velox>TTile(Sprite).lines[i].x1)and(Body.x-Body.radius/1.142-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Body.y-Body.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-Body.y-Body.radius/1.142);//+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetBox
            End;
          End;

        End;

        6: Begin /// Down+Right

         {Право}

         if keepitm then
          Begin
            xp:=TTile(Sprite).lines[i].x1-(KeepBox.y[2]-TTile(Sprite).lines[i].y1);
            if KeepBox.x[2]>xp then
            if (KeepBox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(KeepBox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-KeepBox.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-KeepBox.x[2];
              SetBox
            End;
          End;

         if VeloX>0 then
          Begin

            xp:=TTile(Sprite).lines[i].x1-(Wing1.y[2]-TTile(Sprite).lines[i].y1);
            if Wing1.x[2]>xp then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing1.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-Wing1.x[2];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1-(Wing2.y[2]-TTile(Sprite).lines[i].y1);
            if Wing2.x[2]>xp then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing2.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-Wing2.x[2];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1-(Body.y+Body.radius/1.4142-TTile(Sprite).lines[i].y1);
            if Body.x+Body.radius/1.4142>xp then
            if (Body.y+Body.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(Body.y+Body.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              yp:=TTile(Sprite).lines[i].y1-(Body.x+Body.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-Body.y-Body.radius/1.142);
              if abs(Body.x+Body.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-Body.x-Body.radius/1.4142);
              SetBox
            End;
          End;

         {Низ}
         if keepitm then
          Begin
            yp:=TTile(Sprite).lines[i].y1-(KeepBox.x[2]-TTile(Sprite).lines[i].x1);
            if KeepBox.y[2]>yp then
            if (KeepBox.x[2]-velox>TTile(Sprite).lines[i].x2)and(KeepBox.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-KeepBox.y[2])<abs(Veloy*5)+10 then
              y:=y+(yp-KeepBox.y[2]);
              SetBox
            End;
          End;

         if VeloY>0 then
          Begin
            yp:=TTile(Sprite).lines[i].y1-(wing1.x[2]-TTile(Sprite).lines[i].x1);
            if Wing1.y[2]>yp then
            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x2)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Wing1.y[2])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing1.y[2]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1-(wing2.x[2]-TTile(Sprite).lines[i].x1);
            if Wing2.y[2]>yp then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x2)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Wing2.y[2])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing2.y[2]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1-(Body.x+Body.radius/1.4142-TTile(Sprite).lines[i].x1);
            if Body.y+Body.radius/1.142>yp then
            if (Body.X+Body.radius/1.142-velox>TTile(Sprite).lines[i].x2)and(Body.x+Body.radius/1.142-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Body.y-Body.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-Body.y-Body.radius/1.142);//+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetBox
            End;
          End;
        End;
         7: Begin /// Top+Right

         {Право}

         if keepitm then
          Begin
             xp:=TTile(Sprite).lines[i].x1+(KeepBox.y[1]-TTile(Sprite).lines[i].y1);
            //xp:=TTile(Sprite).lines[i].x1+(Wing1.y[2]-TTile(Sprite).lines[i].y1);
            if KeepBox.x[2]>xp then
            if (KeepBox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(KeepBox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-KeepBox.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-KeepBox.x[2];
              SetBox
            End;
          End;

         if VeloX>0 then
          Begin

             xp:=TTile(Sprite).lines[i].x1+(Wing1.y[1]-TTile(Sprite).lines[i].y1);
            //xp:=TTile(Sprite).lines[i].x1+(Wing1.y[2]-TTile(Sprite).lines[i].y1);
            if Wing1.x[2]>xp then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing1.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-Wing1.x[2];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1+(Wing2.y[1]-TTile(Sprite).lines[i].y1);
            if Wing2.x[2]>xp then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing2.x[2])<abs(VeloX*5)+10 then
              x:=x+xp-Wing2.x[2];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1+(Body.y-Body.radius/1.4142-TTile(Sprite).lines[i].y1);
            if Body.x+Body.radius/1.4142>xp then
            if (Body.y-Body.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(Body.y-Body.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              yp:=TTile(Sprite).lines[i].y1+(Body.x+Body.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-Body.y+Body.radius/1.142);
              if abs(Body.x+Body.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-Body.x-Body.radius/1.4142);
              SetBox
            End;
          End;

         {Верх}

          if keepitm then
          Begin
            yp:=TTile(Sprite).lines[i].y1+(KeepBox.x[2]-TTile(Sprite).lines[i].x1);
            if KeepBox.y[1]<yp then
            if (KeepBox.x[2]-velox>TTile(Sprite).lines[i].x1)and(KeepBox.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-KeepBox.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-KeepBox.y[1]);
              SetBox
            End;
          End;

         if VeloY<0 then
          Begin
            yp:=TTile(Sprite).lines[i].y1+(wing1.x[2]-TTile(Sprite).lines[i].x1);
            if Wing1.y[1]<yp then
            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Wing1.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing1.y[1]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1+(wing2.x[2]-TTile(Sprite).lines[i].x1);
            if Wing2.y[1]<yp then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x1)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Wing2.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing2.y[1]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1+(Body.x+Body.radius/1.4142-TTile(Sprite).lines[i].x1);
            if Body.y-Body.radius/1.142<yp then
            if (Body.X+Body.radius/1.142-velox>TTile(Sprite).lines[i].x1)and(Body.x+Body.radius/1.142-velox<TTile(Sprite).lines[i].x2)  then
            Begin
              if abs(yp-Body.y+Body.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-Body.y+Body.radius/1.142);//+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetBox
            End;
          End;
        End;
         8: Begin /// Left+Top

         {Лево}

         if keepitm then
          Begin

            xp:=TTile(Sprite).lines[i].x1-(KeepBox.y[1]-TTile(Sprite).lines[i].y1);
            if KeepBox.x[1]<xp then
            if (KeepBox.y[2]-veloy>TTile(Sprite).lines[i].y1)and(KeepBox.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-KeepBox.x[1])<abs(VeloX*5)+10 then
              x:=x+xp-KeepBox.x[1];
              SetBox
            End;
          End;

         if VeloX<0 then
          Begin

            xp:=TTile(Sprite).lines[i].x1-(Wing1.y[1]-TTile(Sprite).lines[i].y1);
            if Wing1.x[1]<xp then
            if (Wing1.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing1.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing1.x[1])<abs(VeloX*5)+10 then
              x:=x+xp-Wing1.x[1];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1-(Wing2.y[1]-TTile(Sprite).lines[i].y1);
            if Wing2.x[1]<xp then
            if (Wing2.y[2]-veloy>TTile(Sprite).lines[i].y1)and(Wing2.y[1]-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
              if abs(xp-Wing2.x[1])<abs(VeloX*5)+10 then
              x:=x+xp-Wing2.x[1];
              SetBox
            End;

            xp:=TTile(Sprite).lines[i].x1-(Body.y-Body.radius/1.4142-TTile(Sprite).lines[i].y1);
            if Body.x-Body.radius/1.4142<xp then
            if (Body.y-Body.radius/1.4142-veloy>TTile(Sprite).lines[i].y1)and(Body.y-Body.radius/1.4142-veloy<TTile(Sprite).lines[i].y2)  then
            Begin
               yp:=TTile(Sprite).lines[i].y1-(Body.x-Body.radius/1.4142-TTile(Sprite).lines[i].x1);
               y:=y+(yp-Body.y+Body.radius/1.142);
              if abs(Body.x-Body.radius/1.4142-xp)<abs(VeloX*5)+10 then
              x:=X+(xp-Body.x+Body.radius/1.4142);
              SetBox
            End;
          End;

         {Верх}
         if keepitm then
          Begin
            yp:=TTile(Sprite).lines[i].y1-(KeepBox.x[1]-TTile(Sprite).lines[i].x1);
            if KeepBox.y[1]<yp then
            if (KeepBox.x[2]-velox>TTile(Sprite).lines[i].x2)and(KeepBox.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-KeepBox.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-KeepBox.y[1]);
              SetBox
            End;
          End;

         if VeloY<0 then
          Begin
            yp:=TTile(Sprite).lines[i].y1-(wing1.x[1]-TTile(Sprite).lines[i].x1);
            if Wing1.y[1]<yp then
            if (Wing1.x[2]-velox>TTile(Sprite).lines[i].x2)and(Wing1.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Wing1.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing1.y[1]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1-(wing2.x[1]-TTile(Sprite).lines[i].x1);
            if Wing2.y[1]<yp then
            if (Wing2.x[2]-velox>TTile(Sprite).lines[i].x2)and(Wing2.x[1]-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Wing2.y[1])<abs(Veloy*5)+10 then
              y:=y+(yp-Wing2.y[1]);
              SetBox
            End;

            yp:=TTile(Sprite).lines[i].y1-(Body.x-Body.radius/1.4142-TTile(Sprite).lines[i].x1);
            if Body.y-Body.radius/1.142<yp then
            if (Body.X-Body.radius/1.142-velox>TTile(Sprite).lines[i].x2)and(Body.x-Body.radius/1.142-velox<TTile(Sprite).lines[i].x1)  then
            Begin
              if abs(yp-Body.y+Body.radius/1.142)<abs(Veloy*5)+10 then
              y:=y+(yp-Body.y+Body.radius/1.142);//+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetBox
            End;
          End;
        End;


      end;


    end;
 End;

    for I := 0 to Childs.Count - 1 do
    if (Childs[i]<>nil) then
    Begin
     Spr:=Childs[i];
     Spr.Move(0);
    End;
End;
end;

procedure TPlayer.SetBox;
var i:integer;
begin

  /// Body
  Body.x:=Body.x0+x+128;
  Body.y:=Body.y0+y+128;

  /// крылья
  Wing1.PosX:=X+128+Wing1.RAD*Cos(-Wing1.ANG+palf);
  Wing1.PosY:=Y+128-Wing1.RAD*Sin(-Wing1.ANG+palf);

  Wing2.PosX:=X+128+Wing2.RAD*Cos(-Wing2.ANG+palf);
  Wing2.PosY:=Y+128-Wing2.RAD*Sin(-Wing2.ANG+palf);

  keepbox.PosX:=X+128+keepbox.RAD*Cos(-keepbox.ANG+palf);
  keepbox.PosY:=Y+128-keepbox.RAD*Sin(-keepbox.ANG+palf);

  for I := 1 to 2 do
  Begin
    Wing1.x[I]:=Wing1.x0[I]+Wing1.PosX;
    Wing1.y[I]:=Wing1.y0[I]+Wing1.PosY;
    Wing2.x[I]:=Wing2.x0[I]+Wing2.PosX;
    Wing2.y[I]:=Wing2.y0[I]+Wing2.PosY;
    keepbox.x[I]:=keepbox.x0[I]+keepbox.PosX;
    keepbox.y[I]:=keepbox.y0[I]+keepbox.PosY;
  End;

end;

procedure TPlayer.Turn(MCount: Single);
var nextalf,step:real;
begin

 

  nextalf:=alf;

  if abs(palf-nextalf)>abs(palf-nextalf-2*pi) then
    nextalf:=nextalf+2*pi;
  if abs(palf-nextalf)>abs(palf-nextalf+2*pi) then
    nextalf:=nextalf-2*pi;

   step:=MCount/10;
   if KEEPitm then
   Begin
    //step:=MCount/20;
   End;

   if palf<nextalf-step then
    palf:=palf+step
     else
       if palf>nextalf+step then
        palf:=palf-step
         else palf:=nextalf;

    if palf<0 then
      palf:=palf+2*pi;
    if palf>2*pi then
      palf:=palf-2*pi;

end;

{ TEffect }

procedure TEffectSprite.CRGB(_R, _G, _B,_A: Integer; Spd,MCount:Single);
var Step:real;
begin

  Step:=Mcount*4*spd;

  if Cred<_R-Step then
    Cred:=Cred+Step
      else
         if Cred>_R+Step then
          Cred:=Cred-Step
           else
            Cred:=_R;

  if CGreen<_G-Step then
    CGreen:=CGreen+Step
      else
         if CGreen>_G+Step then
          CGreen:=CGreen-Step
           else
            CGreen:=_G;

  if CBlue<_B-Step then
    CBlue:=CBlue+Step
      else
         if CBlue>_B+Step then
          CBlue:=CBlue-Step
           else
            CBlue:=_B;

   if CAlpha<_A-Step then
    CAlpha:=CAlpha+Step
      else
         if CAlpha>_A+Step then
          CAlpha:=CAlpha-Step
           else
            CAlpha:=_A;


if CRed>255 then CRed:=255;
  if CRed<0 then CRed:=0;

 if CGreen>255 then CGreen:=255;
  if CGreen<0 then CGreen:=0;

 if CBlue>255 then CBlue:=255;
  if CBlue<0 then CBlue:=0;

 if CAlpha>255 then CAlpha:=255;
  if CAlpha<0 then CAlpha:=0;
end;

procedure TEffectSprite.Move(const MoveCount: Single);
var S:string;
 b:boolean;
 Index,coltt,RV2:integer;
begin
//  b:=Moved;                  /// 8.08.13

  if MoveCount>0 then
  inherited Move(Movecount);


   if EffectType=eScanLine then Begin
      if (Scaning>0)and(Scaning<100)and(col=scann) then
      Begin
        eticks:=eticks+Mcount*0.1;
        if eticks>6.28 then
           eticks:=eticks-6.28;
        if CAlpha<200 then
           cAlpha:=cAlpha+2*MCount;
        if CAlpha>200 then
           cAlpha:=200;
        Alpha:=round(calpha+20*(1+Sin(eticks)));
      End else
      Begin                                  // sdsad
        if scaning<20 then
        Begin
          if CAlpha>0 then            // zx
            cAlpha:=cAlpha-3*MCount;
          if CAlpha<0 then
            cAlpha:=0;
          Alpha:=round(calpha);
        End;
      End;
            
      if (scaning>0)and(col=scann) then
      Begin
          x:=x0+scaning*0.01*x1;
          y:=y0+scaning*0.01*y1;
      End else
          eticks:=0;

   End;
   
//  if movecount=0 then      /// 8.08.13
//    moved:=b;               /// 8.08.13

   ///// Вражьи поврежедния
    if EffectType=eEnmCrack then Begin
      if Visible= true then
      Begin
          Alpha:=round(cAlpha);
          CRGB(255,255,255,255,1,MoveCount)
      End
        else  Alpha:=0;
    End;

   if EffectType=eCharger then
  Begin
           if levelmission>0 then
            Begin
              Alpha:=225;
              Red:=GetRValue(bosscol);
              Green:=GetGValue(bosscol);
              Blue:=GetBValue(bosscol);

              cRed:=Red;
              cGreen:=Green;
              cBlue:=Blue;
              cAlpha:=225;
            End
            else
            Begin
                CRGB(0,0,0,0,0.1,Movecount);
                Alpha:=round(CAlpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
            End;
  End;



   //////// МИНА У КАМИКАЗЫ
    if EffectType=eMina then
    Begin

        if owner<>nil then
        Begin
          x:=Owner.x+TEnemy(Owner).SizeXdiv2+TEnemy(Owner).EnmSubRA[1,1]*Cos(TEnemy(Owner).Enmsubra[2,1]-TEnemy(Owner).palf);
          y:=Owner.y+TEnemy(Owner).SizeYdiv2-TEnemy(Owner).EnmSubRA[1,1]*Sin(TEnemy(Owner).Enmsubra[2,1]-TEnemy(Owner).palf);
        End else dead;

        if Eticks<6.2 then
          Eticks:= Eticks+0.1*Movecount;
        if Eticks>=6.2 then
        Begin
          Eticks:=0;
        End;
       Green:=120+trunc(100*Sin(Eticks));
       Blue:=Green;
    End;

    if EffectType=eScreen then
    Begin
     if eticks<2*pi then
      eticks:=eticks+movecount*0.1*t
       else begin
          eticks:=eticks-2*pi;
          t:=1+random(5);
       end;

     alpha:=200-trunc(55*sin(eticks));
    End;


    if EffectType=eSphere then
    Begin

        if owner<>nil then
        Begin
          x:=Owner.x+TEnemy(Owner).SizeXdiv2+TEnemy(Owner).EnmSubRA[1,1]*Cos(TEnemy(Owner).Enmsubra[2,1]-TEnemy(Owner).palf);
          y:=Owner.y+TEnemy(Owner).SizeYdiv2-TEnemy(Owner).EnmSubRA[1,1]*Sin(TEnemy(Owner).Enmsubra[2,1]-TEnemy(Owner).palf);
        End else dead;

    End;


    if EffectType=eShine then
    Begin

      if Owner<>nil then
      Begin
        x:=Owner.X+Tenemy(Owner).SizeXdiv2;
        y:=Owner.y+Tenemy(Owner).SizeYdiv2;

       // Angle:=trunc(Tenemy(Owner).palf*72)/72
      End else dead;
    End;
   ////////ОГОНЬКИ ДВЕРЕЙ

    if EffectType=eLamp3 then Begin

        Alpha:=55+round(Act);
    End;

    if EffectType=eLamp5 then Begin
       if calpha<act then
       if calpha<act-movecount*2 then
          cAlpha:=cAlpha+movecount*2
           else cAlpha:=act;

        if calpha>act then
        if calpha>act+movecount*2 then
         cAlpha:=cAlpha-movecount*2
          else cAlpha:=act;

         Alpha:=trunc(cAlpha);
    End;


    if EffectType=eLamp4 then Begin

        Alpha:=255-round(alf1);
    End;

    if EffectType=eBuse then
     if visible=true then
      Begin
        t:=t+movecount*0.1;
        if t>2*pi then
          t:=t-2*pi;

        OffsetY:=Cos(angle)*Sin(t)*10;
        OffsetX:=Sin(angle)*Sin(t)*10;
        if hieffs then
        Begin
        Eticks:=Eticks+MoveCount;
        if Eticks>20 then
        Begin
          Eticks:=0;

          if angle=0 then
          Begin
            sparkeff(X+ImageWidth div 2,Y+OffsetY,pfire);
            sparkeff(X+ImageWidth div 2,Y+OffsetY+Imageheight,pfire);
            fireeff2(X+ImageWidth div 2,Y+OffsetY-5,1,pfire);
            fireeff2(X+ImageWidth div 2,Y+OffsetY+Imageheight+10,1,pfire);
          End else
          Begin
            sparkeff(X+OffsetX,Y+Imageheight div 2,pfire);
            sparkeff(X+OffsetX+ImageWidth,Y+Imageheight div 2,pfire);
            fireeff2(X+OffsetX-5,Y+Imageheight div 2,1,pfire);
            fireeff2(X+OffsetX+ImageWidth+10,Y+Imageheight div 2,1,pfire);
          End;
        End;
        End;
        //// выпускать эффекты
    End;

    if EffectType=eLampCol then Begin

      if (x-52<gamcurx)and
          (x+52>gamcurx) and
          (y-52<gamcury)and
          (y+52>gamcury)
      then
      Begin
        cursoroncapsule:=true;
        RV2:=trunc(SQRT(SQR(_Player.X+128-x{-SizeXd2})+SQR(_Player.y+128-y{-Sizeyd2})));
        if drawdop then
          FireEff(x,y,pfire,1);

        ChooseBound.x:=x-55;
        ChooseBound.y:=y-55;
        ChooseBound.w:=115;
        ChooseBound.h:=115;
        ShowChoosed:=true;

        if RV2<550 then
        Begin
          b:=true;
          if col<>0 then
          Begin
            if CurrentWeapon=col then
              b:=false;
            for index:= 1 to 6 do
              if altweapons[index]=col then
                b:=false;
          End;

          if b then
            TakenCol:=self;
        End;
      End;
    End;

  ////////ОГОНЬКИ ИГРОКА
    if EffectType=eLamp then Begin
     // Visible:=false;
      PlayerData;
      //alf1:=round((alf*180/pi)/5)*5;
      Angle:=-alf1*pi/180;

      x:=X1+128+_R*Cos(-Angle+alf0);    /////////!!!!
      y:=Y1+128-_R*Sin(-Angle+alf0);


      if effName = 'shield' then
      Begin
         Visible:=false;
         if alpha>0 then
          Visible:=true;

         angle:=0;
          //Drawfx:=fxLightAdd;
          //Drawfx:=fxOneColor;
          //Drawfx:=fxBright;


         if (hieffs) then
         if (health>0) then
        // if Calpha>=Alphaw[shieldcolor]div 2-1 then
         if shieldtime>0 then
         Begin
            Eticks:=Eticks+MoveCount;
            if Eticks>2 then
              Begin
                shieldeff(X,Y, shieldcolor,120);
                Eticks:=0;
              End
         End;

            if shieldtime>0 then
            Begin
              CRGB(redw[shieldcolor],Greenw[shieldcolor],
                  Bluew[shieldcolor],Alphaw[shieldcolor]div 2,1,MoveCount);
            End
            else
              if Calpha>0 then
              CRGB(redw[shieldcolor],Greenw[shieldcolor],
                  Bluew[shieldcolor],0,1,MoveCount);

            Alpha:=round(Calpha);
            Red:=round(CRed);
            Green:=round(CGreen);
            Blue:=round(CBlue);

      End
        else
      if effName = 'sphere' then
      Begin
        if rainbow then
        Begin

           coltt:=trunc(animpos/4.5);

           red:=trunc( redw[coltt+1]-(redw[coltt+1]-redw[coltt+2])*(animpos/4.5-coltt));
           green:=trunc( greenw[coltt+1]-(greenw[coltt+1]-greenw[coltt+2])*(animpos/4.5-coltt));
           blue:=trunc( bluew[coltt+1]-(bluew[coltt+1]-bluew[coltt+2])*(animpos/4.5-coltt));

           ColEffHUD:=crgb4(red,green,blue,255);
           // if weapons[currentWeapon].Count>0 then
             Alpha:=250
             // else  Alpha:=125;

           //CRGB(redw[currentWeapon],Greenw[currentWeapon],
           //       Bluew[currentWeapon],Alphaw[currentWeapon]div 2,1,MoveCount);

        end else
            if currentWeapon>-1 then
            Begin
              if weapons[currentWeapon].Count>0 then
                 CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],1,MoveCount)
              else
              CRGB(redw[currentWeapon],Greenw[currentWeapon],
                  Bluew[currentWeapon],Alphaw[currentWeapon]div 2,1,MoveCount);

              Alpha:=round(Calpha);
              Red:=round(CRed);
              Green:=round(CGreen);
              Blue:=round(CBlue)

            End;
      End
        else
        if (effName = 'cure') then
          Begin
            
            if curetime<20 then Begin
               Visible:=true;
               drawfx:=fxadd;
               if hieffs=false then
                 alpha:=trunc(255*sin(curetime*pi/20));
              // ImageName :=effname;
               curetime:=Curetime+0.5*MoveCount;
               AnimCount:=20;
               AnimPos:=Curetime;
            End else
               Visible:=false;
          End
        else
        if (effName = 'droid') then
          Begin

              if droid=false then
              Visible:=false
              else
              Begin
                if Visible=false then
                 if ((health)<100) then
                 begin
                   Visible:=true;

                  // x:=_Player.X+128+128*(sin(eticks))*(sin(-alf2));
                  // y:=_Player.y+128+128*(sin(eticks))*(cos(-alf2));

                 end;

                 if ((health)>=100) then
                 Begin

                   if (Eticks>pi*2-MoveCount*0.1)or(Eticks<MoveCount*0.1)or(Eticks=0) then
                   Begin
                    Eticks:=0;
                    Visible:=false;
                   End;
                 End;
               end;
              // if (Movecount>0) then
               //or((Movecount=0)and(Moved=false)) 
               //  if Moved then
                // Moved:=true;
               if Visible=true then
               Begin

                Eticks:=Eticks+MCount*0.05*0.2;         /// 8.08.13

                if Eticks>2*pi then
                Begin
                  act:=0;
                  Eticks:=Eticks-2*pi;
                End;

                 z:=0;
                if (Eticks>=pi/2)and(Eticks<3*pi/2) then
                 z:=3;

               // if MoveCount>0 then
                alf2:=alf2+MCount*0.015*0.2;        /// 8.08.13
                if alf2>2*pi then
                Begin
                  alf2:=alf2-2*pi;
                End;

               // if (eticks<pi/2)or(eticks>=3*pi/2) then

               //  else  Angle:=0;//3*pi/2-alf2;
                Angle:=pi/2+alf2;

                if z>2 then Begin
                 animpos:=sin(Eticks)*7.5+6.5
                End
                else
                  Begin
                    animpos:=sin(-Eticks)*7.5+21.5;
                  End;

                x:=_Player.X+128+128*(sin(eticks))*(sin(-alf2));
                y:=_Player.y+128+128*(sin(eticks))*(cos(-alf2));

                if (act=0)and(Eticks>=5*pi/6)then
                Begin
                  if hieffs then
                  sparkeff(x+20,y+20,pfire);
                  sparkeff2(x+20,y+20,pfire,false);
                  inc(act)
                End else
                if (act=1)and(Eticks>=pi)then
                Begin
                  if hieffs then
                  sparkeff(x+20,y+20,pfire);
                  sparkeff2(x+20,y+20,pfire,false);
                  inc(act)
                End;


               End;
          End
         else
          if (effName = 'a1') then
          Begin
            //ImageName :=effname;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              // if currenentWeap=N then Begin
              if altWeapon>-1 then Begin
                if weapons[altWeapon].Count>0 then
                CRGB(redw[AltWeapon],Greenw[AltWeapon],Bluew[AltWeapon],
                  Alphaw[AltWeapon],1.5,MoveCount)
                   else CRGB(redw[AltWeapon]div 2,Greenw[AltWeapon] div 2,
                   Bluew[AltWeapon]div 2,Alphaw[AltWeapon]div 2,1.5,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;
          End
          else
          if (effName = 'hands') then
          Begin
             // ImageName :=effname;
              if animpos>0 then
                  Visible:=true;

              if keepitm then
              Begin
                if animpos<20 then
                  animpos:=animpos+movecount;
                if animpos>20 then
                  animpos:=20;
                animcount:=patterncount;
              End
              else
              Begin

                if animpos>0 then
                  animpos:=animpos-movecount;
                if animpos<0 then
                 animpos:=0;

              End;

          End
        else
          if (effName = 'l1') or (effName = 'r1') then
          Begin
             // imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                if Weapons[currentWeapon].Count>=30 then
                  CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],1,MoveCount)
                      else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l2') or (effName = 'r2') then
          Begin
             // imagename:=effName;
              Visible:=true;

              if (health<15)and(health>0) then
                if effname='l2' then Begin
                 visible:=false;
                    // Выпускаю искры
                    Eticks:=Eticks+MoveCount;
                    if Eticks>150 then Begin
                      SparkEff(x,y, pFire);
                      Eticks:=0;
                    End;
                end;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
               if Weapons[currentWeapon].Count>=25 then
                CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],1,MoveCount)
                      else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l3') or (effName = 'r3') then
          Begin
             // imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                 if Weapons[currentWeapon].Count>=20 then
                  CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                    Alphaw[currentWeapon],1,MoveCount)
                      else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l4') or (effName = 'r4') then
          Begin
             // imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                 if Weapons[currentWeapon].Count>=15 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],1,MoveCount)
                        else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l5') or (effName = 'r5') then
          Begin
             // imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                 if Weapons[currentWeapon].Count>=10 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],1,MoveCount)
                        else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l6') or (effName = 'r6') then
          Begin
            //  imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                if Weapons[currentWeapon].Count>=5 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],1,MoveCount)
                        else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'l7') or (effName = 'r7') then
          Begin
            //  imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if currentWeapon>-1 then Begin
                if Weapons[currentWeapon].Count>=1 then
                    CRGB(redw[currentWeapon],Greenw[currentWeapon],Bluew[currentWeapon],
                      Alphaw[currentWeapon],1,MoveCount)
                        else  CRGB(0,0,0,0,1,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
          if (effName = 'a2') or (effName = 'a3') then
          Begin
            //  imagename:=effName;
              Visible:=true;

              {ЗДЕСЬ - ЦВЕТ}
              if AltWeapon>-1 then Begin
                if weapons[altWeapon].Count>0 then
                CRGB(redw[AltWeapon],Greenw[AltWeapon],Bluew[AltWeapon],
                  Alphaw[AltWeapon],1.5,MoveCount)
                   else CRGB(redw[AltWeapon]div 2,Greenw[AltWeapon] div 2,
                   Bluew[AltWeapon]div 2,Alphaw[AltWeapon]div 2,1.5,MoveCount);

                Alpha:=round(Calpha);
                Red:=round(CRed);
                Green:=round(CGreen);
                Blue:=round(CBlue);
              End;

          End
        else
         if (effName = 'plasmup') then
          Begin
              Visible:=false;
              if plasmup then
                Visible:=true;
          End
        else
          if (effName = 'detector') then
            Visible:=detect
        else

       if (effName = 'dc2') or (effName = 'dc3') or (effName = 'dc1') then
       Begin
       if Movecount>0 then
       Begin
        Visible:=detect;

        if visible=true then
        Begin

        if (effName ='dc1') then
         if detcol[1]<>0 then
         Begin
           Red:=redw[detcol[1]];
           Green:=greenw[detcol[1]];
           Blue:=bluew[detcol[1]];
         End else visible:=false;

        if (effName ='dc2') then
         if detcol[2]<>0 then
         Begin
           Red:=redw[detcol[2]];
           Green:=greenw[detcol[2]];
           Blue:=bluew[detcol[2]];
         End else visible:=false;

        if (effName ='dc3') then
         if detcol[3]<>0 then
         Begin
           Red:=redw[detcol[3]];
           Green:=greenw[detcol[3]];
           Blue:=bluew[detcol[3]];
         End else visible:=false;

        End;

        End
      End else


          {  if (effName = 'soplo') then
          Begin
              // Выпускаю огонь
             visible:=false;
              if (health>0) then
              Eticks:=Eticks+MoveCount;
              if Eticks>20 then
              Begin
                FireEff(x,y, pFire,1);
                 if hispeed>0 then
                    TrasserEff(x,y,20,80,255,1,10,pfire);
                {if EngineOn=true then
                Begin
                  FireEff(x,y, pFire,2);
                  if hispeed>0 then
                    TrasserEff(x,y,20,80,255,2,10,pfire)
                   // SparkEff4(x,y,6); xvcxcvxc
                End; 
                Eticks:=0; }
             { End
            end    
          else     }
        if (effName = 'crash_1')then
          Begin
             // imagename:=effname;
              Visible:=true;
               if health<20 then
                CRGB(0,0,0,255,1,MoveCount)
                 else  CRGB(0,0,0,0,1,MoveCount);
              Alpha:=Round(cAlpha);
          End else
        if (effName = 'crash_2')then
          Begin
             // imagename:=effname;
              Visible:=true;
               if health<30 then
                CRGB(0,0,0,255,1,MoveCount)
                 else  CRGB(0,0,0,0,1,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_4')then
          Begin
             // imagename:=effname;
              Visible:=true;
               if health<40 then
                CRGB(0,0,0,255,1,MoveCount)
                 else  CRGB(0,0,0,0,1,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_5')then
          Begin
             // imagename:=effname;
              Visible:=true;
               if health<15 then
                CRGB(0,0,0,255,1,MoveCount)
                 else  CRGB(0,0,0,0,1,MoveCount);
              Alpha:=Round(cAlpha)
          End else
        if (effName = 'crash_3') then
          Begin
              visible:=false;

              // Выпускаю искры
              if (health<20)and(health>0) then
              Eticks:=Eticks+MoveCount;
              if Eticks>15 then
              Begin
                SparkEff(x,y, pFire);
                Eticks:=0;
              End;
      End;

      if health<=0 then  Visible:=false;
    End;



    /////////// ВЗРЫВЫ

   if (effecttype=ePart)or(effecttype=eAster) then
   Begin

     t:=t-MoveCount*0.02;
      Visible:=true;
     if t<0 then Begin
      alf1:=alf1+MoveCount*0.1;
      Alpha:=Alpha-round(alf1);

      if Alpha<0 then
      Begin
        alpha:=0;
        dead;
      End;
     End
     else Begin
      x:=x+x1*t*MoveCount*0.05;
      y:=y+y1*t*MoveCount*0.05;
       Eticks:=Eticks+MoveCount;
        if Eticks>3 then Begin
         FireEff2(x-10+random(20)+20,y-10+random(20)+20,trunc(t), pFire);
         Eticks:=0;
        End;
     End;
     animspeed:=t/100+0.2+alf2;

   End;

    if (effecttype=eMeat) then
   Begin

     t:=t-MoveCount*0.02;
      Visible:=true;
     if t<0 then Begin
      alf1:=alf1+MoveCount*0.1;
      Alpha:=Alpha-round(alf1);

      if Alpha<0 then
      Begin
        alpha:=0;
        dead;
      End;
     End
     else Begin
      x:=x+x1*t*MoveCount*0.05;
      y:=y+y1*t*MoveCount*0.05;
       Eticks:=Eticks+MoveCount;
        if Eticks>5 then Begin
         TrasserEff(x+10+random(20),y+10+random(20),0,200,0,2,1, pTrasser);
         Eticks:=0;
        End;
     End;
     animspeed:=t/100+0.2+alf2;

   End;
   ///// ДРУГИЕ ЭФФЕКТЫ


   if (effecttype=eGlass) then
   Begin

     t:=t-MoveCount*0.02;
      Visible:=true;
     if t<0 then Begin
      alf1:=alf1+MoveCount*0.1;
      Alpha:=Alpha-round(alf1);

      if Alpha<0 then
      Begin
        alpha:=0;
        dead;
      End;
     End
     else Begin
      x:=x+x1*t*MoveCount*0.05;
      y:=y+y1*t*MoveCount*0.05;
       Eticks:=Eticks+MoveCount;
        if Eticks>10 then Begin
         TrasserEff(x+10+random(20),y+10+random(20),red,green,Blue,2,1, pTrasser);
         Eticks:=0;
        End;
     End;
     animspeed:=t/100+0.2+alf2;

   End;


   ///!!!!
  { if DrawMode=1 then
    Begin
     { X1:=X-ImageWidth div 2*ScaleX;
      Y1:=Y-ImageHeight div 2*ScaleY;
      X4:=X+ImageWidth div 2*ScaleX;
      Y4:=Y+ImageHeight div 2*ScaleY;}{
    End; }

end;

procedure TEffectSprite.PlayerData;
//var i:integer;
begin
  //  for I := 0 to Engine.Count - 1 do
    //  if Engine[i]<>nil then
      //   if Engine[i] is TPlayer then
       if (_player<>nil)and (_player is TPlayer) then
         Begin
           if ultralow then
            alf1:=-_Player.angle*180/pi
            else
              alf1:=round((TPlayer(_Player).PAlf*36/pi))*5;//round((TPlayer(Engine[i]).PAlf*180/pi)/5)*5;
           x1:=TPlayer(_Player).X;//TPlayer(Engine[i]).X;
           y1:=TPlayer(_Player).Y;//TPlayer(Engine[i]).Y;
         End;
end;

{ TParticle }

procedure TParticle.Move(const MoveCount: Single);
var i,j:integer;
begin
  inherited;

  visible:=true;

  if ParType=pplasmid then
  Begin
    x:=x0+(alllife-lifetime)*cos(lifetime/20+nu);
    y:=y0+(alllife-lifetime)*sin(lifetime/20+nu);
    if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*200)
          else  alpha:=round((lifetime/alllife)*200)
  End;

  if ParType=pplasmid2 then
  Begin
    //x:=x0+(alllife-lifetime)*cos(lifetime/20+nu);
    //y:=y0+(alllife-lifetime)*sin(lifetime/20+nu);

    red:=50+round((lifetime/alllife)*200);
    green:=50+round((lifetime/alllife)*200);
    blue:=250-round((lifetime/alllife)*200);

    if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*200)
          else  alpha:=round((lifetime/alllife)*200)
  End;

  if ParType=pShield then
  Begin          
    alpha:=round((lifetime/alllife)*100);
    if _player<>nil then
    Begin
      x:=x0+_Player.X+VelocityX+128;
      y:=y0+_Player.Y+VelocityY+128;
    End;
  End;


  if ParType=pHelix then
  Begin          

    alpha:=round((lifetime/alllife)*255);
    nu:=nu-lagcount*0.05;

    if _player<>nil then
    Begin
      X:=cos(nu)*lifetime+X0;
      Y:=sin(nu)*lifetime+Y0;
    End;
  End;



  if (ParType=pFire)or(ParType=pLasEff) then
    alpha:=round((lifetime/alllife)*100);



  if ParType=pTrasser then
    alpha:=round((lifetime/alllife)*100);


  if ParType=pExplode then
    if Lifetime<=alllife*0.7 then
    Begin
         Alpha:=round(255*((Lifetime)/(0.7*alllife)));
      if Lifetime<0 then  Alpha:=0;
    End;

  if ParType=pElectro then
  Begin
  {  if Lifetime<=alllife*0.7 then
    Begin
         Alpha:=round(255*((Lifetime)/(0.7*alllife)));
      if Lifetime<0 then  Alpha:=0;
    End;}
    if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*200)
          else  alpha:=round((lifetime/alllife)*200);


  End;

  if ParType=pExplode2 then
    alpha:=round((lifetime/alllife)*100);

   if (ParType=pSun)or(ParType=pSun2) then
    Begin
        if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*200)
          else  alpha:=round((lifetime/alllife)*200);

      if (ParType=pSun2) then
      Begin
          scaleX:=round(((alllife-lifetime)/alllife)*5);
          scaleY:=scaleX;
      End;

    End;


    if ParType=pCircle then
    Begin
        if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*200)
          else  alpha:=round((lifetime/alllife)*200);

          scalex:=2*sin(alpha*pi/200);
          scaley:=scaleX;
    End;


    if ParType=pCol then
    Begin
       x:=_Player.X+120+lifetime/alllife*150*Cos(angle);
       y:=_Player.Y+120+lifetime/alllife*150*sin(angle);
       if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*500)
          else  alpha:=round((lifetime/alllife)*200);
          if alpha>255 then
                 alpha:=255;
    End;

    if ParType=pCol2 then
    Begin
       x:=_Player.X+120+(lifetime+40)/alllife*150*Cos(angle);
       y:=_Player.Y+120+(lifetime+40)/alllife*150*sin(angle);
       if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*500)
          else  alpha:=round((lifetime/alllife)*200);
          if alpha>255 then
                 alpha:=255;
    End;

    if ParType=pCol3 then
    Begin
       x:=X0{+150}+(lifetime+40)/alllife*250*Cos(angle);
       y:=Y0{+150}+(lifetime+40)/alllife*250*sin(angle);
       if lifetime/alllife>0.5 then
         alpha:=round(((alllife-lifetime)/alllife)*500)
          else  alpha:=round((lifetime/alllife)*200);
          if alpha>255 then
                 alpha:=255;
    End;

  {  if ParType=pCol then
    Begin
       i:=trunc(_Player.X+128-ImageWidth/2);
       j:=trunc(_Player.Y+128-ImageHeight/2);
       if abs(x-i)>movecount*spd then
        x:=x-mainform.znak(x-i)*movecount*spd;
       if abs(y-j)>movecount*spd then
        y:=y-mainform.znak(y-j)*movecount*spd;

       alpha:=round((lifetime/alllife)*100);

       if (abs(y-j)<movecount*spd)and(abs(x-i)<movecount*spd) then
       Begin
        X:=i;//-ImageHeight/4;
        Y:=j;//-ImageHeight/4;
        LifeTime:=AllLife;
        ParType:=Pfire;
        Velocityx:=random-0.5;
        VelocityY:=random-0.5;
        AccelX:=VelocityX/10;
        AccelY:=VelocityY/10;
        X:=X+VelocityX*5;
        Y:=y+VelocityY*5;

       End;

    End;   }
    

end;

{ TArmoSprite }

constructor TArmoSprite.Create(const AParent: TSpriteEngine);
begin
  inherited;
  enm:=false;
  t:=0;
  if ArmoType=aSin then
  Begin
    x0:=x;
    y0:=y;
  End;
  CollideMethod:=cmRect;
end;

procedure TArmoSprite.Move(const MoveCount: Single);
const
  TrasserTime=1;
var
  VeloXi,VeloYi,sina:real;
  coltt:integer;
begin
  inherited;

  if ArmoType=aSimple then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
     Begin
       Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
     End;
    if L>=maxL then Dead;
  End;

  if ArmoType=aTrasser then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;

    t:=t+MoveCount;
    if t>TrasserTime then
    Begin
      t:=0;
      {СОЗДАНИЕ ЧАСТИЦ}
      TrasserEff(x+VeloXi/2,y+Veloyi/2,Red,Green,Blue,1,4, pTrasser);
    End;

    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>=maxL then Dead;
  End;

  if ArmoType=aTrasser4 then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;

    t:=t+MoveCount;
    if t>TrasserTime then
    Begin
      t:=0;
      {СОЗДАНИЕ ЧАСТИЦ}
      TrasserEff(x+VeloXi/2,y+Veloyi/2,Red,Green,Blue,6,trunc(angle*100), pSun);
     // TrasserEff(x+VeloXi/2,y+Veloyi/2,Red,Green,Blue,4,trunc(angle*100), pTrasser);
      if hieffs then
          trassereff(X,Y,red,green,blue, 7, trunc(angle*100),pfire);
    End;

    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>=maxL then Dead;
  End;

  if ArmoType=aBall then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;

    t:=t+MoveCount;
    if t>TrasserTime then
    Begin
      t:=0;
      {СОЗДАНИЕ ЧАСТИЦ}
      TrasserEff(x+VeloXi/2,y+Veloyi/2,Red,Green,Blue,20,3, pfire);//pTrasser);
     // trassereff(X,Y,red,green,blue, 5, trunc(angle*100),pcircle);
    End;
    if L<maxL then
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));

    if L>maxL*0.2 then
      launcher:=nil;

    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>maxL then L:=maxL;
    if num<=0 then dead;

  End;

  if ArmoType=aTrasser2 then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;

    t:=t+MoveCount;
    if t>TrasserTime*2 then
    Begin
      t:=0;
      {СОЗДАНИЕ ЧАСТИЦ}
      trassereff(X,Y,red,green,blue,
        4, trunc(angle*100),pfire);
    End;

    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>=maxL then Dead;
  End;

   if ArmoType=aTrasser3 then
  Begin
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X:=x+VeloXi;
    y:=y+VeloYi;

    t:=t+MoveCount;
    if t>TrasserTime*2 then
    Begin
      t:=0;
      {СОЗДАНИЕ ЧАСТИЦ}
      trassereff(X,Y,red,green,blue,
        5, trunc(angle*100),pcircle);

      //TrasserEff(x,y,Red,Green,Blue,1,4, pTrasser);
        trassereff(X,Y,red,green,blue,
        4, trunc(angle*100),pfire);
    End;

   { if t>TrasserTime*3 then
    Begin
      t:=0;
      trassereff(X,Y,red,green,blue,
        4, trunc(angle*100),pfire);
    End;}

    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));
    if L>=maxL*0.7 then
    Begin
      Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
    End;
    if L>=maxL then Dead;
  End;



  if ArmoType=aSin then
 Begin
    t:=t+MoveCount;
    Visible:=true;
    VeloXi:=VeloX*MoveCount;
    VeloYi:=VeloY*MoveCount;
    X0:=x0+VeloXi;
    y0:=y0+VeloYi;
    sina:=Sin(L/maxL*pi/2)*num*a;
    x:=x0+VeloYi*Sina;
    y:=y0-VeloXi*Sina;
    l:=l+sqrt(Sqr(VeloXi)+Sqr(VeloYi));

     if t>TrasserTime then Begin
      t:=0;
      TrasserEff(x,y,Red,Green,Blue,2,5, pTrasser);
     End;

    if L>=maxL*0.7 then
     Begin
       Alpha:=round(255*((maxL*0.7-L)/(0.3*maxL)));
     End;
     a:=20*(maxL-L)/maxL;
    if L>=maxL then Dead;
 End;
    SetCBox;
 if col=8 then
 Begin
   colt:=colt+lagcount*15;
   if colt>700 then
    colt:=0;

   coltt:=trunc(colt) div 100;

   red:=trunc( redw[coltt+1]+(redw[coltt+2]-redw[coltt+1])*(colt/100-coltt));
   green:=trunc( greenw[coltt+1]+(greenw[coltt+2]-greenw[coltt+1])*(colt/100-coltt));
   blue:=trunc( bluew[coltt+1]+(bluew[coltt+2]-bluew[coltt+1])*(colt/100-coltt));
 End;

    Collision;
end;

procedure TArmoSprite.OnCollision(const Sprite: TSprite);
var i,j:integer;
 bam:boolean;
 xp,yp:real;
 point1:Tpoint;
begin
  inherited;

  if sprite is TCapsule then
  if Tcapsule(Sprite).keeping=false then
  Begin
    xp:=sqrt(sqr(VeloX)+sqr(VeloY));
    if xp<>0 then
    Begin
      TCapsule(sprite).Impulse1.ImpPower:=3;
      TCapsule(sprite).Impulse1.ImpX:=VeloX/xp;
      TCapsule(sprite).Impulse1.ImpY:=VeloY/xp;
    End;
    Dead;
    //Mainform.SoundSystem2.Play('metal.wav',false);
    Mainform.DXWave.items.Find('metal.wav').Play(false);

    if hieffs then
      SparkEff2(x,y, pFire,true);
    SparkEff(x,y, pFire);

              if ArmoType=aTrasser3 then
          Sparkeff3(x,y,col,2,pfire);

    if TCapsule(sprite).tip=4 then
    Begin
      TCapsule(sprite).Explode;
    End;

  End;

  if sprite is TMina then Begin

    inc(Levelscore.shotsluck);
    if Levelscore.shotsluck>Levelscore.shootscount then
      Levelscore.shotsluck:=Levelscore.shootscount;

    xp:=sqrt(sqr(VeloX)+sqr(VeloY));
    if xp<>0 then
    Begin
      TMina(sprite).exp:=true;
      TMina(sprite).Impulse1.ImpPower:=3;
      TMina(sprite).Impulse1.ImpX:=VeloX/xp;
      TMina(sprite).Impulse1.ImpY:=VeloY/xp;
    End;
    Dead;
    //Mainform.SoundSystem2.Play('metal.wav',false);
    Mainform.DXWave.items.Find('metal.wav').Play(false);

    if hieffs then
      SparkEff2(x,y, pFire,true);
    SparkEff(x,y, pFire);

     if ArmoType=aTrasser3 then
           Sparkeff3(x,y,col,2,pfire);
  End;


  if sprite is TLaser then
//  if Tcapsule(Sprite).keeping=false then
  Begin

    if armoType=aball then
    Begin
     if (TLaser(Sprite).direction=1)or(TLaser(Sprite).direction=3) then
        VeloY:=-VeloY
        else
          VeloX:=-VeloX;

          X:=x+VeloX*LagCount;
          y:=y+VeloY*LagCount;
    End
    else
      Dead;

      IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<1 then
          Mainform.DXWave.items.Find('electro.wav').Play(false);

    if hieffs then
      SparkEff2(x,y, pFire,true);
    SparkEff(x,y, pFire);

  End;

 if sprite is TTile then
  if armoType=aball then
  Begin
    reflect(sprite)
  End
  else
 Begin

    if (TTile(Sprite).tip=73)and(TTile(Sprite).pars[3]=0)and((TTile(Sprite).pars[1]=col)or(col=8)) then
            Begin
              inc(Levelscore.shotsluck);
              if Levelscore.shotsluck>Levelscore.shootscount then
                Levelscore.shotsluck:=Levelscore.shootscount;

              //Mainform.SoundSystem2.Play('boom.wav',false);
              Mainform.DXWave.items.Find('boom.wav').Play(false);

              if TSprite(TTile(Sprite).childs[0])<>nil then
              Begin
                  //TSprite(TTile(Sprite).childs[0]).ImageName:='slot_up2'; ///
                  //TSprite(TTile(Sprite).childs[0]).Alpha:=150;
                  TSprite(TTile(Sprite).childs[0]).visible:=false;
              End;

                  TTile(Sprite).horz:=true;
                  TTile(Sprite).pars[3]:=1;
             if Hieffs then
             Begin
                  ExplodeDopEff(TTile(Sprite).x+16+TTile(Sprite).SizeXd2/1.5+16,
                  TTile(Sprite).y+TTile(Sprite).SizeYd2,10,25,6+TTile(Sprite).pars[1],3,true)
             End; 
            End;


   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
    Begin
      Setcbox;
      bam:=false;
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
          if VeloY<0 then
          Begin
            if Colliderect.Top<TTile(Sprite).lines[i].y1 then
            if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              Bam:=true;
              //y:=y+(TTile(Sprite).lines[i].y1-Body.y+Body.radius);
              SetcBox
            End;
           End;
          End;
        2: Begin /// Left
           if VeloX<0 then
            if Colliderect.Left<TTile(Sprite).lines[i].x1 then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x1-Body.x+Body.radius);
              SetcBox
            End;
          End;
        3: Begin /// Down
          if VeloY>0 then
            if Colliderect.Bottom>TTile(Sprite).lines[i].y2 then
            if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
               Bam:=true;
              //y:=y+(TTile(Sprite).lines[i].y2-Body.y-Body.radius);
              SetcBox
            End;
          End;

        4: Begin /// Right
          if VeloX>0 then
            if Colliderect.Right>TTile(Sprite).lines[i].x2 then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              SetcBox
            End;
          End;

        5: Begin /// Left+Down
          if (VeloX<0)or(VeloY>0) then Begin
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);

            if (Colliderect.Right<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and(Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              SetcBox
            End;
          End;
        End;
       6: Begin /// Left+Down
          if (VeloX>0)or(VeloY>0) then Begin
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);

            if (Colliderect.Left<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              SetcBox
            End;
          End;
        End;
       7: Begin /// Right+top
          if (VeloX>0)or(VeloY<0) then Begin
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);

            if (Colliderect.Right>xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              SetcBox
            End;
          End;
        End;
       8: Begin /// Left+Top
          if (VeloX<0)or(VeloY<0) then Begin
            xp:=TTile(Sprite).lines[i].x1-(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);

            if (Colliderect.Left<xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              Bam:=true;
              //x:=x+(TTile(Sprite).lines[i].x2-Body.x-Body.radius);
              SetcBox
            End;
          End;
        End;

      End;
      if bam then
      Begin
         {if TTile(Sprite).tip=7 then
        Begin
            point1.X:=round(x);
            point1.Y:=round(y);
            if (TTile(Sprite).pars[2]=0)and(TTile(Sprite).pars[1]=col) then
              Begin
                TTile(Sprite).pars[2]:=1;
                DoorCols[TTile(Sprite).pars[1]]:=DoorCols[TTile(Sprite).pars[1]]+1;
                 SparkEff3(x,y,TTile(Sprite).pars[1], pFire);
               // SparkEff3(TTile(Sprite).childs[0],TTile(Sprite).y+70,TTile(Sprite).pars[1], pFire);
              End;
        End; }

       { if TTile(Sprite).tip=6 then
        Begin
           point1.X:=round(x);//+imageWidth div 2;
           point1.Y:=round(y);//+imageHeight div 2;
         //  if PointInRect(point1,Bounds(trunc(TTile(Sprite).lines[0].x1),trunc(TTile(Sprite).lines[0].y1),
        //    trunc(TTile(Sprite).lines[2].x2),trunc(TTile(Sprite).lines[2].y2)))=true then
           if (X>TTile(Sprite).lines[0].x1)and(X<TTile(Sprite).lines[2].x2)
             and(Y>TTile(Sprite).lines[0].y1)and(Y<TTile(Sprite).lines[2].y2) then
            Begin
              Dead;
              SparkEff2(x,y, pFire);
              SparkEff(x,y, pFire);
              if (TTile(Sprite).pars[2]=0)and(TTile(Sprite).pars[1]=col) then
              Begin
                TTile(Sprite).pars[2]:=1;
                DoorCols[TTile(Sprite).pars[1]]:=DoorCols[TTile(Sprite).pars[1]]+1;
               // SparkEff3(TTile(Sprite).childs[0],TTile(Sprite).y+70,TTile(Sprite).pars[1], pFire);
              End;
            End else
            Begin
             bam:=false;
            // SparkEff2(x,y, pFire);
            End;
        End else
        Begin }
          Dead;

          if Sprite is TTile then
          if (TTile(Sprite).tip=22)and((TTile(Sprite).pars[1]=col)or(col=8)) then
            Begin
              inc(Levelscore.shotsluck);
              if Levelscore.shotsluck>Levelscore.shootscount then
                Levelscore.shotsluck:=Levelscore.shootscount;

              //Mainform.SoundSystem2.Play('boom.wav',false);
              Mainform.DXWave.items.Find('boom.wav').Play(false);

              if TSprite(TTile(Sprite).childs[0])<>nil then
                  TSprite(TTile(Sprite).childs[0]).Dead;
                  TTile(Sprite).horz:=true;
                  TTile(Sprite).pars[2]:=1;
             if Hieffs then
             Begin
                if TTile(Sprite).SizeXd2>TTile(Sprite).SizeYd2 then
                  for j := 1 to 3 do
                  ExplodeDopEff(TTile(Sprite).x+TTile(Sprite).SizeXd2/1.5*j+32,TTile(Sprite).y+TTile(Sprite).SizeYd2-16,5,5,6+TTile(Sprite).pars[1],3,true)
                  else for j := 1 to 3 do
                    ExplodeDopEff(TTile(Sprite).x+TTile(Sprite).SizeXd2-16,TTile(Sprite).y+TTile(Sprite).SizeYd2/1.5*j+32,5,5,6+TTile(Sprite).pars[1],3,true)
             End;
            End
            else
            Begin
              if Armotype<>aTrasser2 then
               // Mainform.SoundSystem2.Play('pop.wav',false);
               Mainform.DXWave.items.Find('pop.wav').Play(false);
            End;


          if hieffs then
            SparkEff2(x,y, pFire,true);
          SparkEff(x,y, pFire);

           if ArmoType=aTrasser3 then
            Sparkeff3(x,y,col,2,pfire);
        {End;}
      end;

      end;
 End;
 
end;

procedure TArmoSprite.Dead;
begin
  if (armotype=aBall)and(L<maxL) then
  Begin
    Mainform.BoomPhys(trunc(X+50),trunc(Y+50),7,150,1);
        if ((X>Engine.WorldX)and(X<Engine.WorldX+(Mainform.Device.Width)/WorldScaleX))
          and((Y>Engine.WorldY)and(Y<Engine.WorldY+(Mainform.Device.height)/WorldScaleY))
            then BoomTime:=10;

    Sparkeff3(x,y,col,2,pfire);

    mainform.DXWave.items.Find('boom.wav').Play(false);
  End;

  inherited;
end;

procedure TArmoSprite.reflect(sprite: Tsprite);
var i,oldx,oldy:integer;
    xp,yp:real;
begin
OldX:=trunc(x);
Oldy:=Trunc(y);

 if sprite is TTile then
  //if impulse.ImpPower>0 then
  Begin
  //if not((TTile(Sprite).tip=19)) then
   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
        if VeloY<0 then
          if Colliderect.Top<TTile(Sprite).lines[i].y1 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
          Begin
             VeloY:=-VeloY;
             Mainform.DXWave.items.Find('pop.wav').Play(false);
             if Armotype=ABall then
                 dec(num);
             //Impulse1.ImpPower:=Impulse1.ImpPower-0.1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
                if OldY+100<TTile(Sprite).lines[i].y1+52 then
                Begin
                   VeloY:=-VeloY;
                   //y:=TTile(Sprite).lines[i].y1-100;
                End;


          End;
        End;
 2: Begin /// Left
         if VeloX<0 then
           if Colliderect.Left<TTile(Sprite).lines[i].x1 then
           if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
           Begin
            VeloX:=-VeloX;
            Mainform.DXWave.items.Find('pop.wav').Play(false);
            if Armotype=ABall then
                 dec(num);
           // Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
             //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then Begin
                if OldX+100<TTile(Sprite).lines[i].X1+52 then
                Begin
                   VeloX:=-VeloX;
                End;
            End;

          End;
        End;
        3: Begin /// Down
         if VeloY>0 then
          if Colliderect.Bottom>TTile(Sprite).lines[i].y2 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
           Begin
            VeloY:=-VeloY;
              Mainform.DXWave.items.Find('pop.wav').Play(false);
              if Armotype=ABall then
                 dec(num);
            //Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
               or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldY>TTile(Sprite).lines[i].y1+52 then
              Begin

                   VeloY:=-VeloY;
                  // y:=TTile(Sprite).lines[i].y2-100;
              End;
          End;
        End;

        4: Begin /// Right
         if VeloX>0 then
          if Colliderect.Right>TTile(Sprite).lines[i].x2 then
          if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
          Begin
            VeloX:=-VeloX;
              Mainform.DXWave.items.Find('pop.wav').Play(false);
              if Armotype=ABall then
                 dec(num);
           // Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldX>TTile(Sprite).lines[i].X1+52 then
              Begin
                   VeloX:=-VeloX;
              End;



          End;
          End;
        5: Begin /// Left+Down
          if (VeloX<0)or(VeloY>0) then Begin

            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);

           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and(Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              if (VeloX<0) then VeloX:=-VeloX;
              if (VeloY>0) then VeloY:=-VeloY;
                Mainform.DXWave.items.Find('pop.wav').Play(false);
                if Armotype=ABall then
                 dec(num);
            End;
          End;
        End;
       6: Begin /// Left+Down
          if (VeloX>0)or(VeloY>0) then Begin

           xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (VeloX>0) then VeloX:=-VeloX;
              if (VeloY>0) then VeloY:=-VeloY;
                Mainform.DXWave.items.Find('pop.wav').Play(false);
                if Armotype=ABall then
                 dec(num);
            End;

          End;
        End;
       7: Begin /// Right+top
          if (VeloX>0)or(VeloY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right>xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              if (VeloX>0) then VeloX:=-VeloX;
              if (VeloY<0) then VeloY:=-VeloY;
                Mainform.DXWave.items.Find('pop.wav').Play(false);
                if Armotype=ABall then
                 dec(num);
            End;

          End;
        End;
       8: Begin /// Left+Top
          if (VeloX<0)or(VeloY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1-(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (VeloX<0) then VeloX:=-VeloX;
              if (VeloY<0) then VeloY:=-VeloY;
                Mainform.DXWave.items.Find('pop.wav').Play(false);
                if Armotype=ABall then
                 dec(num);
            End;

          End;
        End;

      End;
  End;
end;

procedure TArmoSprite.SetCBox;
begin
     CollideRect := Rect(Round(X - 10{ImageWidth/2}),
                    Round(Y - 10{ImageHeight/2}),
                    Round(X + 10{ImageWidth/2}),
                    Round(Y + 10{ImageHeight/2}));
end;

procedure TTile.OnCollision(const Sprite: TSprite);
begin
  inherited;
 // Setlines;
end;

procedure TTile.Push;
var xx,yy:Single;
    i,j:integer;
    a:real;
begin
///
  if tip=62 then
  if activ=false then
  Begin
    activ:=true;

    for i:= 1 to LaserCount do
      if Lasers[i]<>nil then
       if (Lasers[i].pars[2]=1)and(Lasers[i].pars[1]=pars[1]) then
          Lasers[i].activ:=true;

    MainForm.RebuildLasers;

    if OnlyLoaded=false then
    begin
     // Mainform.DXWave.Items.Find('key2.wav').Play(false);

      Mainform.DXWave.Items.Find('mirr.wav').Play(false);
    end;

    kdr:=0;
    if TSprite(Childs[0])<>nil then
       TSprite(Childs[0]).alpha:=255;
       
    pars[3]:=1;

  End else
  if pars[2]=1 then
  Begin
    activ:=false;

   
    if TSprite(Childs[0])<>nil then
      TSprite(Childs[0]).alpha:=150;


    for i:= 1 to LaserCount do
    if Lasers[i]<>nil then
      if (Lasers[i].pars[2]=1)and(Lasers[i].pars[1]=pars[1]) then
        Lasers[i].activ:=false;

    if OnlyLoaded=false then
       Mainform.DXWave.Items.Find('key2.wav').Play(false);

    Mainform.RebuildLasers;

    pars[3]:=0;
  End;


 if tip=72 then            // asas
 Begin
   pars[2]:=1;
  if TEffectSprite(Childs[0])<>nil then
       TEffectSprite(Childs[0]).doanimate:=true;

   Mainform.DXWave.Items.Find('opn.wav').Play(false);

   xx:=x+OffsetX;
   yy:=y+OffsetY;
   i:=pars[3];
   j:=pars[4];
   a:=angle;
   if i>0 then
   Begin

      with TCapsule.Create(Engine) Do
      Begin

         case i of
          1: Begin
              MyObjN:=GetObjNumber('Battery');
              tip:=3;
            End;
          2: Begin
            MyObjN:=GetObjNumber('plasmidbox');
            tip:=4;
            // плазмиды
            col:=j;
            if col<>0 then
             levelscore.plasmidscount:=levelscore.plasmidscount+3;
          End;
          3: Begin
            MyObjN:=GetObjNumber('Mayak');
            tip:=5;
            /// сообщение
            col:=j;
          End;
          5:Begin
              MyObjN:=GetObjNumber('bomba');
              tip:=8;
          End;
          4: Begin
           MyObjN:=GetObjNumber('Capsule1');
            //// Содержимое капсулы



                                 if (j>0) then
                                  if FileExists('Data\Objects\Items\'+MagzObjs[j].objname+'.loc') then
                                  Begin
                                    InCapsule[1]:=TItem.Create;
                                    TItem(InCapsule[1]).LoadItem(MagzObjs[j].objname);
                                  End else
                                  if FileExists('Data\Objects\Bonus\'+MagzObjs[j].objname+'.loc') then
                                  Begin
                                    InCapsule[1]:=TBonus.Create;
                                    TBonus(InCapsule[1]).LoadBonus(MagzObjs[j].objname);
                                  End






          End;


         end;

                 X:=xx;
                 Y:=yy;

                 Oldx:=x;
                 OldY:=y;

                 IsDone:=false;
                // DrawMode:=1;

                 Z:=0;
                 Impulse1.ImpX:=cos(a);
                 Impulse1.ImpY:=sin(a);
                 Impulse1.ImpPower:=2;

                  ImageName := 'Box1';
                    if Mainform.Images.Find(Objs[MyObjN].Img)<>-1 then
                        ImageName :=Objs[MyObjN].Img;

                AnimCount:=PatternCount;
                AnimSpeed:=0.3;

                if tip=5 then
                 Begin
                   ScaleX:=Scalex*0.8;
                   ScaleY:=scaleX;
                  Capsuleshape.RAD:=40;
                 End;

                SpriteHeight:=ImageHeight*ScaleY;
                SpriteWidth:=ImageWidth*ScaleX;
                SizeYd2:=trunc(ImageHeight*ScaleX/2);
                SizeXd2:=trunc(ImageWidth*ScaleY/2);

                X:=xx- SizeXd2;
                Y:=yy- SizeYd2;

                CollideMethod:= cmRect;
                DoCollision := True;
               
            End;
         //End;

   End;
      
 End;


  if tip=55 then
 Begin
    MapLookMenu:=true;
    MapLookX:=_Player.X;
    MapLookY:=_Player.Y;
    mainform.GenerateMapObjs;
    omx:=mx;
    omy:=my;
    MapLookT:=0;
 End;

 if (tip=50)or(tip=51)or(tip=52)or(tip=53)then
 Begin
   if kdr=0 then
    Begin
       TEffectSprite(Childs[0]).act:=0;
       DoorElectro[pars[2]]:=false;
    End
     else Begin
       TEffectSprite(Childs[0]).act:=255;

       TSprite(Childs[0]).red:=Redw[pars[2]];
       TSprite(Childs[0]).green:=greenw[pars[2]];
       TSprite(Childs[0]).blue:=bluew[pars[2]];

       DoorElectro[pars[2]]:=true;
     End;
 End;

 if (tip=39)or(tip=40) then
 Begin
   if childs[0]<>nil then
    if kdr=1 then
     TSprite(childs[0]).visible:=true
      else
      TSprite(childs[0]).visible:=false;
 End;

 if tip=16 then
 Begin
   tip:=18;
   DoorCols[pars[1]]:=DoorCols[pars[1]]+1;
   PatternIndex:=1;
   AnimCount:=PatternCount;
   AnimPos:=1;
   pars[2]:=1;
   if Childs[1]<>nil then
    TEffectSprite(Childs[1]).dead;
   Mainform.DXWave.Items.Find('key2.wav').Play(false);
 End;

 if tip=34 then
 Begin
   Mainform.DXWave.Items.Find('door0.wav').Play(false);
   tip:=37;
   AnimLooped:=false;
   AnimPlayMode:=pmForward;
   AnimSpeed:=0.25;
   AnimCount:=patterncount;
   AnimPos:=0;
   AnimStart:=0;
   Mainform.RebuildLasers;
   if childs[0]<>nil then
   Begin
      TSprite(childs[0]).visible:=false;
   End;
 End;

 if tip=35 then
 Begin
   Mainform.DXWave.Items.Find('door0.wav').Play(false);
   tip:=36;
   AnimLooped:=false;
   AnimCount:=patterncount;
   AnimPlayMode:=pmBackward;
   AnimSpeed:=0.25;
   AnimPos:=patterncount;
   AnimStart:=0;
   Mainform.RebuildLasers;
   if childs[0]<>nil then
   Begin
      TSprite(childs[0]).visible:=false;
   End;
 End;

  if tip=31 then
 Begin
    inventory2:=true;
    Mainform.DXWave.Items.Find('mousein.wav').Play(false); //1308
    needcolor:=pars[1];
    newcolorcount:=0;
    newcolor:=0;
    InMouseCol:=0;
    Takencol:=self;
    Hud2[7].xmin:=trunc(((x+PatternWidth*ScaleX/2)-Engine.WorldX)*Engine.worldScaleX/Mainform.Device.Width*1600);
    Hud2[7].ymin:=trunc(((y+PatternHeight*ScaleY/2)-Engine.WorldY)*Engine.worldScaley/Mainform.Device.height*1200);
 End;

 if tip=30 then
 Begin
   Mainform.DXWave.Items.Find('key2.wav').Play(false);
   if pars[3]=0 then
   Begin


    i:=1;
    if (ObjName='key_5') then
       if ((y+PatternHeight*ScaleY/2-gamcury)>0{sizeyd2})then
           i:=2;
    if (ObjName='key_6')then
       if ((x+PatternWidth*ScaleX/2-gamcurx)<{sizexd2}0)then
           i:=2;
    if (ObjName='key_7') then
       if ((y+PatternHeight*ScaleY/2-gamcury)<0{sizeyd2})then
           i:=2;
    if (ObjName='key_8') then
       if ((x+PatternWidth*ScaleX/2-gamcurx)>{sizexd2}0)then
           i:=2;


    {pars[3]:=1;
    DoorCols[pars[2]]:=DoorCols[pars[2]]+1;
    PatternIndex:=1;
    AnimPos:=1;
    if Childs[1]<>nil then
    TEffectSprite(Childs[1]).visible:=false;     }

    if i=1 then
    Begin
        pars[3]:=2;
      //DoorCols[pars[2]]:=DoorCols[pars[2]]-1;
        DoorCols[pars[1]]:=DoorCols[pars[1]]+1;
        PatternIndex:=2;
        AnimPos:=2;
        if Childs[2]<>nil then
          TEffectSprite(Childs[2]).visible:=false;
        if Childs[1]<>nil then
          TEffectSprite(Childs[1]).visible:=true;
   End else
   if i=2 then
   Begin
      pars[3]:=1;
   //   DoorCols[pars[1]]:=DoorCols[pars[1]]-1;
      DoorCols[pars[2]]:=DoorCols[pars[2]]+1;
      PatternIndex:=1;
      AnimPos:=1;
      if Childs[1]<>nil then
        TEffectSprite(Childs[1]).visible:=false;
      if Childs[2]<>nil then
        TEffectSprite(Childs[2]).visible:=true;
   End;

   End else
   if pars[3]=1 then
   Begin
    pars[3]:=2;
    DoorCols[pars[2]]:=DoorCols[pars[2]]-1;
    DoorCols[pars[1]]:=DoorCols[pars[1]]+1;
    PatternIndex:=2;
    AnimPos:=2;
    if Childs[2]<>nil then
    TEffectSprite(Childs[2]).visible:=false;
    if Childs[1]<>nil then
    TEffectSprite(Childs[1]).visible:=true;
   End else
   if pars[3]=2 then
   Begin
    pars[3]:=1;
    DoorCols[pars[1]]:=DoorCols[pars[1]]-1;
    DoorCols[pars[2]]:=DoorCols[pars[2]]+1;
    PatternIndex:=1;
    AnimPos:=1;
    if Childs[1]<>nil then
    TEffectSprite(Childs[1]).visible:=false;
    if Childs[2]<>nil then
    TEffectSprite(Childs[2]).visible:=true;
   End;

   if pars[3]=1 then
   i:=pars[2]
    else if pars[3]=2 then
      i:=pars[1];
   TeffectSprite(Childs[0]).red:=redw[i];
   TeffectSprite(Childs[0]).green:=greenw[i];
   TeffectSprite(Childs[0]).blue:=bluew[i];
   TeffectSprite(Childs[0]).Alpha:=225;

 End;


 if tip=27 then
 Begin
   Inventory3:=true;
   Mainform.DXWave.Items.Find('mousein.wav').Play(false);  //1308
   MagzLev:=0;
   //if pars[1]>1 then
    MagzLev:=pars[1];
 End;

 if tip=20 then
 Begin
   tip:=19;
   Mainform.DXWave.Items.Find('off.wav').Play(false);
  // Mainform.DXWave.Items.Find('use.wav').Play(false);
   DoorElectro[pars[1]]:=false;
   Xx:=TSprite(Childs[2]).x;
   yy:=TSprite(Childs[2]).y;
   pars[2]:=0;

    with  TCapsule.Create(Engine) do
    begin
      MyObjN:=GetObjNumber('Battery');
     /// showmessage(inttostr(MyObjN));
      ImageName := 'Box1';
      if Mainform.Images.Find('Battery')<>-1 then
        ImageName :='Battery';

      AnimCount:=PatternCount;
      AnimSpeed:=0.1*(random(2)+2);

      X:=xx;
      y:=yy;

      AnimPos:=random(AnimCount);


      SpriteHeight:=ImageHeight*ScaleY;
      SpriteWidth:=ImageWidth*ScaleX;

      SizeYd2:=ImageHeight div 2;
      SizeXd2:=ImageWidth div 2;

      keeping:=true;
      keep2:=false;
      prekeep:=true;
      DrawMode:=1;
      z:=-1;
      keepitm:=true;
      TPlayer(_player).keepbox:=TPlayer(_player).kb1;
      tip:=3;

      
      CollideMethod:= cmRect;
      DoCollision := True;
      end;
    End

end;

procedure TTile.SetLines;
var i:integer;
begin
/////
  if mylineCount>0 then
  Begin
    for i := 0 to mylineCount - 1 do
    Begin
      lines[i].x1:=lines[i].x0_1+x;
      lines[i].y1:=lines[i].y0_1+y;
      lines[i].x2:=lines[i].x0_2+x;
      lines[i].y2:=lines[i].y0_2+y;
    End;
  End;

       CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + ImageWidth*ScaleX),
                    Round(Y + ImageHeight*ScaleY));


end;

{ TItem }

procedure TItem.CopyItem(const Source: TItem);
begin
  if Source<>nil then
  Begin
      Source.ItemInUse:=false;
      ItemFileName:=Source.ItemFilename;
      ItemTip:=Source.ItemTip;
      ItemImageName:=Source.ItemImageName;
      ItemColor:=Source.ItemColor;
      ItemName:=Source.ItemName;
      ItemInfo:=Source.ItemInfo;
      ItemTimeUse:=Source.ItemTimeUse;
      ItemCurrentTime:=Source.ItemCurrentTime;
  End;

end;

constructor TItem.Create;
begin
///
Itemtip:=0;
ItemImageName:='Box1';
end;

procedure TItem.LoadItem(const FileName: string);
const
  n=6;
  Commands:array[1..n] of String=('Tip: ','Img: ','Col: ','Name: ','Info: ','Time: ');
var s:TstringList;
  i,j:integer;
  par:String;
begin

    ItemFileName:=Filename;
    s:=TstringList.Create;
  if FileExists('Data\Objects\Items\'+FileName+'.loc') then
  Begin
    s.LoadFromFile('Data\Objects\Items\'+FileName+'.loc');

       ///// ЗАГРУЗКА
    for I := 0 to s.Count - 1 do
        for j := 1 to n do
            if Pos(commands[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(commands[j]));
               case j of
                  1:{Tip:} Begin
                     ItemTip:=Strtoint(par);
                  End;
                  2:{Img:} Begin
                     ItemImageName:='Box1';
                        if Mainform.ItemImages.Find(par)<>-1 then
                     ItemImageName:=par;
                  End;
                  3:{Col:} Begin
                     ItemColor:=Strtoint(par);
                  End;
                  4:{Name:} Begin
                    ItemName:=itemsList[strtoint(par)];
                  End;
                  5:{Info:} Begin
                    ItemInfo:=itemsList[strtoint(par)];
                  End;
                  6:{Time:} Begin
                    ItemTimeUse:=Strtoint(par);
                    ItemCurrenttime:=ItemTimeUse;
                  End;


               end;
      End;
  End;
  s.Destroy;
end;

procedure TItem.UseItem(const MoveCount: Single);
var i:real; j:integer;
begin

if health>0 then
case Itemtip of
  1: Begin /// cure:

      if health+PlusHealth<100 then
      Begin
         if Curetime>=20 then
            Curetime:=0;
         ItemCurrentTime:=ItemCurrentTime-MoveCount;
         PlusHealth:=PlusHealth+MoveCount;
      End else
        ItemInUse:=false;

  End;
 2: Begin /// телескоп:
        minimap:=true;
         if ItemCurrentTime>0 then
         ItemCurrentTime:=ItemCurrentTime-MoveCount*0.02;
         if ItemCurrentTime<0  then
        ItemCurrentTime:=0;
  End;
  3: Begin /// ракеты: ///
  ///
      if ItemCurrentTime>0 then
        ItemCurrentTime:=ItemCurrentTime-1;
      if ItemCurrentTime<0  then
        ItemCurrentTime:=0;
      ItemInUse:=false;

      Mainform.DXWave.Items.Find('use.wav').Play(false);
      
       for j:=1 to 2 do
        with TEnemy.Create(Mainform.Engine) do
        Begin
        EnmmyobjN:=GetObjNumber('rock2');
          ImageName := 'rock2';
          EnmName:='rock2';

          enmlowanim:=true;

          SizeXdiv2:=round(ImageWidth div 2*ScaleX);
          SizeYDiv2:=round(ImageHeight div 2*ScaleY);

          with TPlayer(_player) do
          Begin
            GunPos[j].X:=128+round(X+RAGunPos[j,1]*Cos(RAGunPos[j,2]+palf));
            GunPos[j].Y:=128+round(Y-RAGunPos[j,1]*Sin(RAGunPos[j,2]+palf));
          End;

          X:=TPlayer(_Player).GunPos[j].X- SizeXdiv2;
          y:=TPlayer(_Player).GunPos[j].Y- SizeYdiv2;

          Creator;
          EnmMaxSpeed:=EnmMaxSpeed+0.5;
          palf:=-TPlayer(_Player).palf;
          nextalf:=palf;

          AItip:=6;

          CollideMethod:= cmRect;
          DoCollision := True;


          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
          AI;
        End;
  End;
  4: Begin /// ускорялка
        if ItemCurrentTime>0 then
         if EngineOn then
         ItemCurrentTime:=ItemCurrentTime-MoveCount*0.05;
        if ItemCurrentTime<0  then
          ItemCurrentTime:=0;
        hispeed:=5;
  End;
  5: Begin /// мины:
      if ItemCurrentTime>0 then
        ItemCurrentTime:=ItemCurrentTime-1;
      if ItemCurrentTime<0  then
        ItemCurrentTime:=0;
      ItemInUse:=false;
      with TMina.Create(Mainform.Engine) do
        Begin
          myobjN:=-1;
          ImageName := 'mina2';

          Mainform.DXWave.Items.Find('use.wav').Play(false);

          //SizeXd2:=round(ImageWidth div 2*ScaleX);
          //SizeYD2:=round(ImageHeight div 2*ScaleY);

          scaleX:=1.2;
          ScaleY:=1.2;

          animspeed:=0.3;
          animcount:=30;

          offsetx:=16;
          offsety:=16;

          playersmina:=true;
          exp:=true;

          X:=(_Player).X+128-110*Cos(TPlayer(_Player).PAlf)-50;//- SizeXdiv2;
          y:=(_Player).Y+128+110*Sin(TPlayer(_Player).PAlf)-50;//- SizeYdiv2;

          impulse1.impX:=-Cos(TPlayer(_Player).PAlf);
          impulse1.ImpY:=Sin(TPlayer(_Player).PAlf);
          impulse1.ImpPower:=1;

          CollideMethod:= cmRect;
          DoCollision := True;

          SpriteHeight:=ImageHeight*ScaleY;
          SpriteWidth:=ImageWidth*ScaleX;
         // AI;
        End;
  End;
  8: Begin /// BOOM
      if ItemCurrentTime>0 then
        ItemCurrentTime:=ItemCurrentTime-1;
      if ItemCurrentTime<0  then
        ItemCurrentTime:=0;
      ItemInUse:=false;

      ExplodeeffBon2(trunc(_Player.x+128),trunc(_Player.Y+128),20,pfire);
      if hieffs then
      ExplodeeffBon(trunc(_Player.x+128),trunc(_Player.Y+128),20,psun);

      Mainform.DXWave.Items.Find('boom2.wav').Play(false);

      GoLight:=true;
      LightMax:=255;
      BoomTime:=50;

      Mainform.BoomPhys(trunc(_Player.x+128),trunc(_Player.Y+128),150,1000,5);
  End;

  7: Begin /// rainbow
        if ItemCurrentTime>0 then
         ItemCurrentTime:=ItemCurrentTime-RBO;

        if ItemCurrentTime<0  then
          ItemCurrentTime:=0;

        RBO:=0;
        rainbow:=true;
  End;

  6: Begin /// ???
    if ItemCurrentTime>0 then
         ItemCurrentTime:=ItemCurrentTime-1;
    ItemInUse:=false;
    allcrazy1:=10;
    Mainform.DXWave.Items.Find('shield.wav').Play(false);
    ExplodeeffBon3(trunc(_Player.x+128),trunc(_Player.Y+128),20,psun2);
  End;
  {0: Begin  /// По кол-ву:
      if ItemCurrentTime>0 then
        ItemCurrentTime:=ItemCurrentTime-1;
      if ItemCurrentTime<0  then
        ItemCurrentTime:=0;
      ItemInUse:=false;
  End; }
end;

end;

{ TCapsule }

constructor TCapsule.Create(const AParent: TSpriteEngine);
begin
  inherited;
  tip:=0;

  Capsuleshape.Posx0:=0;
  Capsuleshape.Posy0:=0;
  Capsuleshape.x0[1]:=-50;
  Capsuleshape.y0[1]:=-50;
  Capsuleshape.x0[2]:=50;
  Capsuleshape.y0[2]:=50;

  Capsuleshape.RAD:=50;
   if tip=5 then
         Capsuleshape.RAD:=40;

  Impulse1.ImpPower:=1+random;
  Impulse1.ImpX:=random*2-1;
  Impulse1.ImpY:=random*2-1;
  Oldx:=x;
  Oldy:=y;

  CollideMethod:=cmRect;
  DoCollision := True;
  noob:=true;
  noob2:=true;
  InPlayer:=true;

  if Ultralow=false then
  Begin
  if levcolor then
    Begin
      Red:=levcol[1];
      Green:=levcol[2];
      Blue:=levcol[3];
    End else
      Begin
        Red:=240;
        Green:=240;
        Blue:=240;
      End;
  End;

end;

procedure TCapsule.explode;
var i,j,xx,yy:integer;
begin
   ExplodeEff(x+50,y+50,1,PExplode);

  // Mainform.SoundSystem2.Play('boom.wav',false);   //////////// EXPL
   Mainform.DXWave.items.Find('boom.wav').Play(false);

   if hieffs then
     ExplodeDopEff(x+SizeXd2,y+SizeYd2,14,5,1,3,false);
      
         Mainform.BoomPhys(trunc(X+50),trunc(Y+50),5,250,1);
         Mainform.BoomPhys(trunc(X+50),trunc(Y+50),5,250,2);

        if ((X>Engine.WorldX)and(X<Engine.WorldX+(Mainform.Device.Width)/WorldScaleX))
          and((Y>Engine.WorldY)and(Y<Engine.WorldY+(Mainform.Device.height)/WorldScaleY))
            then BoomTime:=10;

        if col>0 then
        Begin
         j:=col;
         xx:=trunc(x);
         yy:=trunc(y);

         for i:=1 to 3 do

          with  TDopEff.Create(Engine) do
                  begin

                    MyObjN:=GetObjNumber('plasmid');

                    ImageName := 'Box1';
                    if Mainform.Images.Find(Objs[MyObjN].Img)<>-1 then
                        ImageName :=Objs[MyObjN].Img;

                    impulse1.ImpX:=cos(i*pi*2/3);
                    impulse1.ImpY:=-sin(i*pi*2/3);

                    impulse1.imppower:=random*2+0.5;
                    x:=xx+10*impulse1.ImpX;
                    y:=yy+10*impulse1.ImpY;

                    z:=0;
                    used:=false;

                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;

                    CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + SpriteWidth),
                    Round(Y + SpriteHeight));

                    max:=30;

                    cnt:=j;

                    Red:=Redw[cnt];
                    Green:=Greenw[cnt];
                    Blue:=Bluew[cnt];

                    CollideMethod:= cmRect;
                    DoCollision := True;


                    SpriteHeight:=ImageHeight*ScaleY;
                    SpriteWidth:=ImageWidth*ScaleX;


                  end;
                 
        End else
        if col=0 then
        if hieffs then
          ExplodeDopEff(x+SizeXd2,y+SizeYd2,14,5,1,3,true);

        if (Keepitm)and(keeping) then
          keepitm:=false;


        DoCollision:=false;
        col:=-1;
        dead;
end;

procedure TCapsule.Move(const MoveCount: Single);
  var i,j:integer;
begin
  inherited;

 if Radar then
 if tip<>1 then
 Begin
   if (abs(_player.X-x)<1600)and(abs(_player.y-Y)<1600)then
   Begin
     i:=round( (_player.X+128-x)/20 );
     j:=round( (_player.Y+128-y)/20 );
     if sqrt(sqr(i)+sqr(j))<80 then
     Begin
      if MiniMapObjCount<512 then
          inc(MiniMapObjCount);
       MMap[MiniMapObjCount,0]:=8;
       MMap[MiniMapObjCount,1]:=i;
       MMap[MiniMapObjCount,2]:=j;
       MMap[MiniMapObjCount,3]:=8;
       MMap[MiniMapObjCount,4]:=8;
     End;
   End;
 End;

if keeping=false then
Begin
  if (impulse1.ImpPower>10) then
   impulse1.ImpPower:=10;

  if impulse1.ImpPower>0 then
  if tip<>1 then
  Begin
   impulse1.ImpPower:=impulse1.ImpPower-abs(lagcount)/50;
  End else impulse1.ImpPower:=impulse1.ImpPower-abs(lagcount)/100;

  if (impulse1.ImpPower<0) then
   impulse1.ImpPower:=0;


 {if (noob2=false)or(tip=1) then
 Begin
  OldX:=x;
  OldY:=y;
 End; }

 x:=x+impulse1.ImpX*impulse1.ImpPower*Movecount*5;
 y:=y+impulse1.Impy*impulse1.ImpPower*Movecount*5;



 if noob then
  InPlayer:=false;


 if tip=1 then
  CollideRect := Rect(Round(X),Round(Y),Round(X )+ imageWidth,Round(Y )+imageHeight)
   else
    CollideRect := Rect(Round(X),Round(Y),Round(X + SpriteWidth),Round(Y+ SpriteHeight ));

 Statics:=false;

 drop:=dropme;
 dropme:=false;
 if (impulse1.ImpPower>0)or(noob2=true)or(oldY<>y)or(oldx<>x) then
  Collision;

 if InPlayer=false then
  noob:=false;
 if InPlayer=false then
  noob2:=false;

 Capsuleshape.POsX:=x+sizexd2;
 Capsuleshape.posY:=y+sizeyd2;
 for i:=1 to 2 do
   Begin
    Capsuleshape.x[I]:=Capsuleshape.x0[I]+Capsuleshape.PosX;
    Capsuleshape.y[I]:=Capsuleshape.y0[I]+Capsuleshape.PosY;
   End;

End;

 if tip=1 then
 Begin
    animspeed:=impulse1.ImpPower/3;

    if {hieffs=false}DrawMode=1 then
      angle:=angle+impulse1.ImpPower/5*movecount; ////// 10-07-2011

    Eticks:=Eticks+MoveCount;
    if Eticks>2 then Begin
      Eticks:=0;
      if live then
      Begin
        TrasserEff(x+10+random(20)+SizeXd2,y+10+random(20)+SizeYd2,0,200,0,2,3, pTrasser);
        Eticks:=-2;
      end else
      FireEff2(x-10+random(20)+SizeXd2,y-10+random(20)+SizeYd2,trunc(impulse1.ImpPower*5+7), pFire);

    End;

   if impulse1.ImpPower<=0.1 then
   Begin
     Dead;
     Mainform.DXWave.Items.Find('boom.wav').Play(false);
     MiniExplodeEff(X+SizeXd2,Y+SizeYd2,pfire);
     sparkeff2(x+SizeXd2,y+SizeYd2,pfire,false);
     sparkeff2(x+SizeXd2,y+SizeYd2,pfire,false);
     Mainform.BoomPhys(trunc(X),trunc(Y),2,180,3);
   End;
 End;


 if keep2 then
  Begin
     CollideRect := Rect(0,0,0,0);
     impulse1.ImpPower:=0;
     if keeper.tip=19 then
     Begin
      i:=trunc(TSprite(keeper.childs[2]).x);
      j:=trunc(TSprite(keeper.childs[2]).Y);
       if abs(x-i)>movecount*15 then
        x:=x-mainform.znak(x-i)*movecount*15;
       if abs(y-j)>movecount*15 then
        y:=y-mainform.znak(y-j)*movecount*15;

      if (abs(y-j)<movecount*15)and(abs(x-i)<movecount*15) then
      Begin
        keeper.tip:=20;
        keeper.pars[2]:=1;
        DoorElectro[keeper.pars[1]]:=true;
      End

     End else

    if keeper.tip=73 then
     Begin
       if keeper.childs[1]<>nil then
       Begin
          i:=trunc(TSprite(keeper.childs[1]).x);
          j:=trunc(TSprite(keeper.childs[1]).Y);
       End;

       if abs(x-i)>movecount*15 then
        x:=x-mainform.znak(x-i)*movecount*15;
       if abs(y-j)>movecount*15 then
        y:=y-mainform.znak(y-j)*movecount*15;

      if (abs(y-j)<movecount*15)and(abs(x-i)<movecount*15) then
      Begin
       // keeper.tip:=20;
        keeper.pars[4]:=1;
        if (levelmission>0)and(levelmissiontip=1) then
        Begin
          dec(levelmission);
           Mainform.DXWave.items.Find('save.wav').Play(false);
          if levelmission=0 then
          begin
            smessage:=language[193];
            smessageTime:=300
          end else
            miseff1:=true;
        End;
        dead;
       if keeper.childs[1]<>nil then
       Begin
         TSprite(keeper.childs[1]).Visible:=true;
       End;
       // DoorElectro[keeper.pars[1]]:=true;
      End

     End else
     Begin
       dead;
     End;
  End;

 if keeping then
  Begin
    animpos:=0;

    impulse1:=TPlayer(_Player).Impulse;
    keep2:=false;
    Collision;

    if prekeep then
    Begin
       CollideRect := Rect(0,0,0,0);
       if ultralow  then
        angle:=-TPlayer(_Player).palf
         else
          Begin
            i:=round((TPlayer(_Player).PAlf*36/pi));
            angle:=-i*pi/36;
          End;

       if tip=3 then
       Begin
        i:=trunc(_Player.X+128+105*cos(-angle));
        j:=trunc(_Player.Y+128-105*sin(-angle));
       end else
       if tip=8 then
       Begin
        i:=trunc(_Player.X+128+105*cos(-angle));
        j:=trunc(_Player.Y+128-105*sin(-angle));
       end else
        Begin
          i:=trunc(_Player.X+128+125*cos(-angle));
          j:=trunc(_Player.Y+128-125*sin(-angle));
        end;

       if abs(x-i)>movecount*15 then
        x:=x-mainform.znak(x-i)*movecount*15;
       if abs(y-j)>movecount*15 then
        y:=y-mainform.znak(y-j)*movecount*15;

       if (abs(y-j)<movecount*15)and(abs(x-i)<movecount*15) then
       prekeep:=false;

    End else
    Begin
      {i:=round((TPlayer(_Player).PAlf*36/pi));
      angle:=-i*pi/36;}

      if ultralow  then
        angle:=-TPlayer(_Player).palf
         else
          Begin
            i:=round((TPlayer(_Player).PAlf*36/pi));
            angle:=-i*pi/36;
          End;

     if tip=3 then
       Begin
          x:=_Player.X+128+105*cos(-angle);
          y:=_Player.Y+128-105*sin(-angle);
       End else
       if tip=8 then
       Begin
          x:=_Player.X+128+105*cos(-angle);
          y:=_Player.Y+128-105*sin(-angle);
       End else
       Begin
          x:=_Player.X+128+125*cos(-angle);
          y:=_Player.Y+128-125*sin(-angle);
       End;


      animpos:=0;


      CollideRect := Rect(Round(X)-sizexd2,Round(Y)-sizeyd2,
                    Round(X )+sizexd2,Round(Y)+sizeyd2);
      Capsuleshape.POsX:=x;
      Capsuleshape.posY:=y;
      for i:=1 to 2 do
      Begin
        Capsuleshape.x[I]:=Capsuleshape.x0[I]+Capsuleshape.PosX;
        Capsuleshape.y[I]:=Capsuleshape.y0[I]+Capsuleshape.PosY;
      End;
      Collision;
    End;
    if health<=0  then
    Begin
     dead;
     KeepSprite:=nil;
     keepitm:=false;
    End;

  End;

  OldX:=x;
  OldY:=y;

 if (keeping)and(droping) then
 Begin
      keepsprite:=nil;
      mainform.DXWave.Items.Find('use.wav').Play(false); // 1308
      keepitm:=false;
      keeping:=false;
      DrawMode:=0;
      CollideRect := Rect(Round(X),
           Round(Y),Round(X )+ 100,
           Round(Y )+ 100);
      X:=X-SizeXd2;
      Y:=Y-Sizeyd2;
      Impulse1.ImpPower:=3;
      if tip=4 then
        Impulse1.ImpPower:=6;
      Impulse1.ImpX:=Cos(TPlayer(_player).PAlf);
      Impulse1.Impy:=-Sin(TPlayer(_player).PAlf);
      canshoot:=false;

      droping:=false;
 End;
 


 if tip<>1 then
 if (Capsuleshape.x[1]<gamcurx)and
   (Capsuleshape.x[2]>gamcurx) and
   (Capsuleshape.y[1]<gamcury)and
   (Capsuleshape.y[2]>gamcury)
    then
 Begin
   cursoroncapsule:=true;

        ShowChoosed:=true;
        ChooseBound.x:=x;
        ChooseBound.y:=y;
        ChooseBound.w:=SizeXd2*2;
        ChooseBound.h:=SizeYd2*2;

        if keeping then
        Begin
          ChooseBound.x:=x-50;
          ChooseBound.y:=y-50;
          ChooseBound.w:=100;
          ChooseBound.h:=100;
        End;

   i:=trunc(SQRT(SQR(_Player.X+128-x-40)+SQR(_Player.y+128-y-40)));    {RV2}
   if (i<500)and(isDone=false) then TakenCapsule:=self;
 End;

end;

procedure TCapsule.OnCollision(const Sprite: TSprite);
var i:integer;
  xp,yp,ii:real;
  dopImp:Timpulse;
  itwas,itwas2,touch,willkeep:boolean;
begin
  inherited;

   if sprite is TLaser then
  Begin
   Touch:=false;
   if (Tlaser(Sprite).direction=1)or(Tlaser(Sprite).direction=3) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=trunc(X)+SizeXd2;
     if (abs(trunc(Y)+SizeYd2-yp)<Capsuleshape.rad)and(xp>Sprite.x-16)and(xp<Sprite.x+Sprite.SpriteWidth+16) then
     Begin
        touch:=true;

          if ((trunc(Y)+SizeYd2>yp){and(Force.ImpY<0)}) then
            Impulse1.ImpY:=1
              else
            if ((trunc(Y)+SizeYd2<yp){and(Force.ImpY>0)}) then
              Impulse1.ImpY:=-1;

            if tip<>1 then
            if Impulse1.ImpPower<2 then
              Impulse1.ImpPower:=2;

     End;
   End else
   Begin
     /// Вертикально
      xp:=Sprite.x+Sprite.SpriteWidth/2;
      yp:=trunc(Y)+SizeYd2;
     if (abs(trunc(X)+SizeXd2-xp)<Capsuleshape.rad)and(yp>Sprite.y-16)and(yp<Sprite.y+Sprite.Spriteheight+16) then
     Begin
        touch:=true;

          if ((trunc(X)+SizeXd2>xp){and(Force.ImpY<0)}) then
            Impulse1.ImpX:=1
              else
            if ((trunc(X)+SizeXd2<xp){and(Force.ImpY>0)}) then
              Impulse1.ImpX:=-1;

            if tip<>1 then
            if Impulse1.ImpPower<2 then
             Impulse1.ImpPower:=2;
     End;
   End;

   if touch then
     Begin
       IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<2 then
       Begin
          Mainform.DXWave.items.Find('electro.wav').Play(false);
          Sparkeff2(xp,yp,Pfire,true);
          Sparkeff(xp,yp,Pfire);
       End;
     End;
  End;


itwas:=false;

if sprite is TPlayer then
  InPlayer:=true;

if (sprite is TCapsule)and(sprite<>self) then
if TCapsule(Sprite).tip<>1 then

Begin
ii:=sqrt(sqr(Capsuleshape.POsX-TCapsule(sprite).Capsuleshape.POsX)+
         sqr(Capsuleshape.POsY-TCapsule(sprite).Capsuleshape.POsY));
   if ii<Capsuleshape.RAD+TCapsule(sprite).Capsuleshape.RAD then
         Begin

             if tip=4 then
              if impulse1.imppower>3 then
               Begin
                 explode;
               End;

           DopImp.ImpX:=-(Capsuleshape.POsX-TCapsule(sprite).Capsuleshape.POsX)/(70);
           DopImp.ImpY:=-(Capsuleshape.POsY-TCapsule(sprite).Capsuleshape.POsY)/(70);

           if (TCapsule(sprite).keeping=false)and(TCapsule(sprite).statics=false) then
           Begin
            TCapsule(sprite).X:=TCapsule(sprite).X-(Capsuleshape.POsX-TCapsule(sprite).Capsuleshape.POsX)/(70);
            TCapsule(sprite).y:=TCapsule(sprite).y-(Capsuleshape.POsY-TCapsule(sprite).Capsuleshape.POsY)/(70);
            DopImp.ImpPower:=Impulse1.ImpPower/2;//0.5*(TCapsule(sprite).Impulse1.ImpPower+Impulse1.ImpPower);{0.5}
            TCapsule(sprite).Impulse1.ImpPower:=TCapsule(sprite).Impulse1.ImpPower/2;
            TCapsule(sprite).Impulse1:= Mainform.Superpos(TCapsule(sprite).Impulse1,DopImp);
           end;

           DopImp.ImpX:=-DopImp.ImpX;
           DopImp.ImpY:=-DopImp.ImpY;
           Impulse1.ImpPower:=Impulse1.ImpPower/2;
           DopImp.ImpPower:=TCapsule(sprite).Impulse1.ImpPower/2;
           Impulse1:=Mainform.Superpos(Impulse1,DopImp);

             if (impulse1.imppower>1)and(tip<>1) then
           //Mainform.SoundSystem2.Play('metal.wav',false);
           Mainform.DXWave.items.Find('metal.wav').Play(false);
           itwas:=true;
         End;
End;

if (sprite is TMina)and(sprite<>self) then
Begin
ii:=sqrt(sqr(Capsuleshape.POsX-TMina(sprite).Minashape.POsX)+
         sqr(Capsuleshape.POsY-TMina(sprite).Minashape.POsY));
   if ii<70 then
         Begin
           TMina(sprite).X:=TMina(sprite).X-(Capsuleshape.POsX-TMina(sprite).Minashape.POsX)/(70);
           TMina(sprite).y:=TMina(sprite).y-(Capsuleshape.POsY-TMina(sprite).Minashape.POsY)/(70);

            TMina(sprite).exp:=true;

           DopImp.ImpX:=-(Capsuleshape.POsX-TMina(sprite).Minashape.POsX)/(70);
           DopImp.ImpY:=-(Capsuleshape.POsY-TMina(sprite).Minashape.POsY)/(70);
           DopImp.ImpPower:=0.5*(TMina(sprite).Impulse1.ImpPower+Impulse1.ImpPower);{0.5}
          // TMina(sprite).Impulse1.ImpPower:=TMina(sprite).Impulse1.ImpPower/2;
           TMina(sprite).Impulse1:=Mainform.Superpos(TMina(sprite).Impulse1,DopImp);

           DopImp.ImpX:=-DopImp.ImpX;
           DopImp.ImpY:=-DopImp.ImpY;
           //Impulse1.ImpPower:=Impulse1.ImpPower/2;
           Impulse1:=Mainform.Superpos(Impulse1,DopImp);
             if (impulse1.imppower>1)and(tip<>1) then
              // Mainform.SoundSystem2.Play('metal.wav',false);
              Mainform.DXWave.items.Find('metal.wav').Play(false);
           itwas:=true;
         End;
End;


statics:=false;
if (sprite is TTile)and(keep2=false) then
Begin
   willkeep:=false;
   itwas2:=false;

   if (TTile(Sprite).tip=19) then
    if(tip=3)and(keeping=false) then
      willkeep:=true;

    if (TTile(Sprite).tip=73) then
      if (TTile(Sprite).pars[4]=0)and(TTile(Sprite).pars[3]<>0)and(tip=8)
          and(DoorElectro[8]=false)and(keeping=false)then
           willkeep:=true;

   if willkeep=false then
   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
        if Impulse1.ImpY<0 then
          if Colliderect.Top<TTile(Sprite).lines[i].y1 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
          Begin
             Impulse1.ImpY:=-Impulse1.ImpY;
             statics:=true;
             
             Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
             //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
                if OldY+100<TTile(Sprite).lines[i].y1+52 then
                Begin
                   Impulse1.ImpY:=-Impulse1.ImpY;   itwas2:=true;
                   //y:=TTile(Sprite).lines[i].y1-100;
                End;


          End;
        End;
        2: Begin /// Left
         if Impulse1.ImpX<0 then
           if Colliderect.Left<TTile(Sprite).lines[i].x1 then
           if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
           Begin
            Impulse1.ImpX:=-Impulse1.ImpX;
            statics:=true;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
             //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5) or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then Begin
                if OldX+100<TTile(Sprite).lines[i].X1+52 then
                Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;  itwas2:=true;
                End;
            End;

          End;
        End;
        3: Begin /// Down
         if Impulse1.ImpY>0 then
          if Colliderect.Bottom>TTile(Sprite).lines[i].y2 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
           Begin
            Impulse1.ImpY:=-Impulse1.ImpY;
            statics:=true;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldY>TTile(Sprite).lines[i].y1+52 then
              Begin

                   Impulse1.ImpY:=-Impulse1.ImpY;   itwas2:=true;
                  // y:=TTile(Sprite).lines[i].y2-100;
              End;
          End;
        End;

        4: Begin /// Right
         if Impulse1.ImpX>0 then
          if Colliderect.Right>TTile(Sprite).lines[i].x2 then
          if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
          Begin
            Impulse1.ImpX:=-Impulse1.ImpX;
            statics:=true;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldX>TTile(Sprite).lines[i].X1+52 then
              Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;     itwas2:=true;
              End;



          End;
          End;
        5: Begin /// Left+Down
          if (Impulse1.ImpX<0)or(Impulse1.ImpY>0) then Begin
            
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and(Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              statics:=true;       itwas2:=true;
              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;
       6: Begin /// Left+Down
          if (Impulse1.ImpX>0)or(Impulse1.ImpY>0) then Begin
           
           xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              statics:=true;      itwas2:=true;
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;
       7: Begin /// Right+top
          if (Impulse1.ImpX>0)or(Impulse1.ImpY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right>xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              statics:=true;     itwas2:=true;
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;
       8: Begin /// Left+Top
          if (Impulse1.ImpX<0)or(Impulse1.ImpY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1-(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              statics:=true;     itwas2:=true;
              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;

      End;

      if (TTile(Sprite).tip=19){and((tip=3)and(keeping=false)) then}
        and (willkeep) then
      Begin
        if keep2=false then
        Begin
          keeper:=TTile(Sprite);                  // 1308
          keep2:=true;
             Mainform.DXWave.Items.Find('key2.wav').Play(false);
             Mainform.DXWave.Items.Find('mirr.wav').Play(false);
            // Mainform.DXWave.Items.Find('laser.wav').Play(false)
        End;
      End;

      if (TTile(Sprite).tip=73)and(willkeep) then
      Begin
        if keep2=false then
        Begin
          keeper:=TTile(Sprite);
          keep2:=true;
          TTile(Sprite).pars[4]:=2;
        End;
      End;

     if (willkeep=false) then
      if (TTile(Sprite).tip=73)and(DoorElectro[8]=true)
      and(TTile(Sprite).pars[3]<>0)and(keeping=false){and(itwas2)}then
      Begin
       IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<2 then
       Begin
         Mainform.DXWave.items.Find('electro.wav').Play(false);
          if TTile(Sprite).angle<0.25*pi then
             sparkeff2(X,Y+SpriteHeight/2,pfire,true)
              else
              if TTile(Sprite).angle<0.75*pi then
                   sparkeff2(X+SpriteWidth/2,Y,pfire,true)
                  else
                  if TTile(Sprite).angle<1.25*pi then
                      sparkeff2(X+SpriteWidth,Y+SpriteHeight/2,pfire,true)
                      else
                      if TTile(Sprite).angle<1.75*pi then
                          sparkeff2(X+SpriteWidth/2,Y+SpriteHeight,pfire,true)
                          else
                            sparkeff2(X+SpriteWidth,Y+SpriteHeight/2,pfire,true);
       End;
      End;


 if (drop=false)and(dropme=false) then
 if (TTile(Sprite).objname='tconv1')then
 if (TTile(Sprite).pars[2]<>1)and(TTile(Sprite).z<3){and(tip>3)}and(keeping=false) then
 Begin
  Impulse1.ImpPower:=0.35;
  Impulse1.ImpX:=0;
  if TTile(Sprite).pars[1]=1 then
  Impulse1.ImpY:=1
   else
      Impulse1.ImpY:=-1;

  AnimPos:=0;

  i:=trunc(TTile(Sprite).X+102-SpriteWidth / 2);
  if abs(x-i)>lagcount*10 then
        x:=x-mainform.znak(x-i)*lagcount*10;
 End;

 if (TTile(Sprite).objname='tconv2') then
 Begin
  Impulse1.ImpPower:=2;
  Impulse1.ImpY:=0;

  Impulse1.ImpX:=1;



  i:=trunc(TTile(Sprite).Y+101);
  if abs(y-i)>lagcount*5 then
        y:=y-mainform.znak(y-i)*lagcount*5;
 End;

 if (TTile(Sprite).objname='tconv3') then
 Begin
  i:=trunc(TTile(Sprite).Y+101);
  if abs(y-i)<lagcount*5 then
  Begin
   dropme:=true;
   Impulse1.ImpPower:=2;
   Impulse1.ImpY:=0;
   dropme:=true;
   Impulse1.ImpX:=-1;
  End;

  if abs(y-i)>lagcount then
        y:=y-mainform.znak(y-i)*lagcount

 End;



End;

  if tip=4 then
  Begin
   if (itwas)or(statics) then
    if impulse1.imppower>3 then
    Begin
       explode;
    End;
  End;

end;

{ TBonus }

procedure TBonus.CopyBonus(const Source: TBonus);
begin
  if Source<>nil then
  Begin
      BonusTip:=Source.BonusTip;
      BonusImageName:=Source.BonusImageName;
      BonusColor:=Source.BonusColor;
      BonusName:=Source.BonusName;
      BonusFileName:=Source.BonusFileName;
      BonusInfo:=Source.BonusInfo;
  End;
end;

constructor TBonus.Create;
begin
 BonusTip:=0;
 BonusImageName:='Box1';
end;

procedure TBonus.LoadBonus(const FileName: string);
const
  n=6;
  Commands:array[1..n] of String=('Tip: ','Img: ','Col: ','Name: ','Info: ','Time: ');
var s:TstringList;
  i,j:integer;
  par:String;
begin

    BonusFileName:=Filename;
    s:=TstringList.Create;
  if FileExists('Data\Objects\Bonus\'+FileName+'.loc') then
  Begin
    s.LoadFromFile('Data\Objects\Bonus\'+FileName+'.loc');

       ///// ЗАГРУЗКА
    for I := 0 to s.Count - 1 do
        for j := 1 to n do
            if Pos(commands[j],s[i])=1 then
             Begin
               par:=s[i];
               delete(par,1,length(commands[j]));
               case j of
                  1:{Tip:} Begin
                     BonusTip:=Strtoint(par);
                  End;
                  2:{Img:} Begin
                     BonusImageName:='Box1';
                     if Mainform.ItemImages.Find(par)<>-1 then
                       BonusImageName:=par;
                  End;
                  3:{Col:} Begin
                     BonusColor:=Strtoint(par);
                  End;
                  4:{Name:} Begin
                    BonusName:=BonusList[strtoint(par)];
                  End;
                  5:{Info:} Begin
                    BonusInfo:=BonusList[strtoint(par)];
                  End;
                  6:{Time:} Begin
                   // BonusTimeUse:=Strtoint(par);
                   // BonusCurrenttime:=BonusTimeUse;
                  End;


               end;
        End;
  End;
  s.Destroy;
end;


procedure TBonus.UseBonus(const MCount: Single);
begin

/// По времени (бонусы только так)

    case Bonustip of
      1: Radar:=true;
      2: Lakmus:=true;
      3: Droid:=true;
      4: Unltd:=true;
      5: Plasmup:=true;
      6: Begin
        if altweapons[4]=-1 then
           altweapons[4]:=0;
        if altweapons[5]=-1 then
           altweapons[5]:=0;
      End;
      7: Begin
        Detect:=true;
      End;
    End;
end;

{ TMina }

constructor TMina.Create(const AParent: TSpriteEngine);
var i:integer;
begin
  inherited;
  CollideMethod:=cmRect;
  DoCollision := True;
  exp:=false;
  TimeToExplode:=0;

    if Ultralow=false then
  Begin
     if levcolor then
    Begin
      Red:=levcol[1];
      Green:=levcol[2];
      Blue:=levcol[3];
    End else
      Begin
        Red:=240;
        Green:=240;
        Blue:=240;
      End;
  End;

end;

procedure TMina.Move(const MoveCount: Single);
var i,j:integer;
begin
  inherited;

if Radar then
 Begin
   if (abs(_player.X-x)<1600)and(abs(_player.y-Y)<1200)then
   Begin

     i:=round((_player.X+128-x)/20);
     j:=round((_player.Y+128-y)/20);

     if sqrt(sqr(i-16)+sqr(j-16))<90 then
     Begin
      if MiniMapObjCount<512 then
          inc(MiniMapObjCount);
       MMap[MiniMapObjCount,0]:=7;
       MMap[MiniMapObjCount,1]:=i;
       MMap[MiniMapObjCount,2]:=j;
       MMap[MiniMapObjCount,3]:=8;
       MMap[MiniMapObjCount,4]:=8;
     End;
   End;
 End;

if wall=false then
Begin

  if (impulse1.ImpPower>10) then
   impulse1.ImpPower:=10;
  if impulse1.ImpPower>0 then
   impulse1.ImpPower:=impulse1.ImpPower-abs(lagcount)/50;
  if (impulse1.ImpPower<0) then
   impulse1.ImpPower:=0;

  i:=trunc(x+50)div 100;
  j:=trunc(y+50)div 100;
 if (i>0)and(i<mapsizex)and(j>0)and(j<mapsizey) then
   AIDynSubMap[i,j]:=true;


 x:=x+impulse1.ImpX*impulse1.ImpPower*Movecount*5;
 y:=y+impulse1.Impy*impulse1.ImpPower*Movecount*5;

 statics:=false;

 CollideRect := Rect(Round(X),Round(Y),Round(X )+ imageWidth,Round(Y )+ ImageHeight);

 if (Impulse1.ImpPower>0)or(OldX<>x)or(OldY<>y) then
  Collision;

 OldX:=x;
 OldY:=y;

 Minashape.POsX:=x+50;
 Minashape.posY:=y+50;
 for i:=1 to 2 do
   Begin
    Minashape.x[I]:=Minashape.x0[I]+Minashape.PosX;
    Minashape.y[I]:=Minashape.y0[I]+Minashape.PosY;
   End;

End else
  Begin

    x:=OldX;
    y:=OldY;

  End;


  if Exp=true then
  Begin

    TimeToExplode:=TimeToExplode+MoveCount;
    Green:=120+trunc(100*Cos(TimeToExplode/10));
    Blue:=Green;
    if TimeToExplode>80 then
      Begin
        ExplodeEff(x+50,y+50,1,PExplode);

        if playersmina then
         Mainform.BoomPhys(trunc(X+50),trunc(Y+50),7,250,2)
          else
            Mainform.BoomPhys(trunc(X+50),trunc(Y+50),10,250,1);

        if ((X>Engine.WorldX)and(X<Engine.WorldX+(Mainform.Device.Width)/WorldScaleX))
          and((Y>Engine.WorldY)and(Y<Engine.WorldY+(Mainform.Device.height)/WorldScaleY))
            then BoomTime:=10;

        DoCollision:=false;
        
        //Mainform.SoundSystem2.Play('boom.wav',false);   //////////// EXPL
        Mainform.DXWave.items.Find('boom.wav').Play(false);
        dead;
      End;
  End;

end;

procedure TMina.OnCollision(const Sprite: TSprite);
var i:integer;
  xp,yp,ii:real;
  dopImp:Timpulse;
  touch:boolean;
begin
  inherited;

{if sprite is TPlayer then
 Begin
  // с
   exp:=true;
 End;  }


 // InPlayer:=true;
{if playersmina then
  if (sprite is TEnemy) then
    TimeToExplode:=0;}


   if sprite is TLaser then
  Begin
   Touch:=false;
   if (Tlaser(Sprite).direction=1)or(Tlaser(Sprite).direction=3) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=trunc(X)+35;
     if (abs(trunc(Y)+35-yp)<70)and(xp>Sprite.x-16)and(xp<Sprite.x+Sprite.SpriteWidth+16) then
     Begin
        touch:=true;

          if ((trunc(Y)+35>yp){and(Force.ImpY<0)}) then
            Impulse1.ImpY:=1
              else
            if ((trunc(Y)+35<yp){and(Force.ImpY>0)}) then
              Impulse1.ImpY:=-1;

            Impulse1.ImpPower:=5;

     End;
   End else
   Begin
     /// Вертикально
      xp:=Sprite.x+Sprite.SpriteWidth/2;
      yp:=trunc(Y)+35;
     if (abs(trunc(X)+35-xp)<70)and(yp>Sprite.y-16)and(yp<Sprite.y+Sprite.Spriteheight+16) then
     Begin
        touch:=true;

          if ((trunc(X)+35>xp){and(Force.ImpY<0)}) then
            Impulse1.ImpX:=1
              else
            if ((trunc(X)+35<xp){and(Force.ImpY>0)}) then
              Impulse1.ImpX:=-1;

            Impulse1.ImpPower:=5;
     End;
   End;

   if touch then
     Begin
       IF  Mainform.DXWave.items.Find('electro.wav').PlayCount<2 then
       Begin
          Mainform.DXWave.items.Find('electro.wav').Play(false);
          Sparkeff2(xp,yp,Pfire,true);
          Sparkeff(xp,yp,Pfire);
          exp:=true;
       End;
     End;
  End;

if (sprite is TMina)and(sprite<>self) then
Begin
ii:=sqrt(sqr(Minashape.POsX-TMina(sprite).Minashape.POsX)+
         sqr(Minashape.POsY-TMina(sprite).Minashape.POsY));
   if (ii<70)and(ii<>0) then
         Begin
           TMina(sprite).X:=TMina(sprite).X-(Minashape.POsX-TMina(sprite).Minashape.POsX)/(70);
           TMina(sprite).y:=TMina(sprite).y-(Minashape.POsY-TMina(sprite).Minashape.POsY)/(70);
           TMina(sprite).exp:=true;
           exp:=true;
           DopImp.ImpX:=-(Minashape.POsX-TMina(sprite).Minashape.POsX)/(70);
           DopImp.ImpY:=-(Minashape.POsY-TMina(sprite).Minashape.POsY)/(70);
           DopImp.ImpPower:=0.25*(TMina(sprite).Impulse1.ImpPower+Impulse1.ImpPower);{0.5}
           TMina(sprite).Impulse1:= Mainform.Superpos(TMina(sprite).Impulse1,DopImp);

           DopImp.ImpX:=-DopImp.ImpX;
           DopImp.ImpY:=-DopImp.ImpY;
           Impulse1:=Mainform.Superpos(Impulse1,DopImp);
             if impulse1.imppower>1 then
               //Mainform.SoundSystem2.Play('metal.wav',false);
               Mainform.DXWave.items.Find('metal.wav').Play(false);
         End;
End;

if (sprite is TCapsule) then
Begin
ii:=sqrt(sqr(Minashape.POsX-TCapsule(sprite).Capsuleshape.POsX)+
         sqr(Minashape.POsY-TCapsule(sprite).Capsuleshape.POsY));
   if (ii<40+TCapsule(sprite).Capsuleshape.RAD)and(ii<>0) then
         Begin
           TCapsule(sprite).X:=TCapsule(sprite).X-(Minashape.POsX-TCapsule(sprite).Capsuleshape.POsX)/(70);
           TCapsule(sprite).y:=TCapsule(sprite).y-(Minashape.POsY-TCapsule(sprite).Capsuleshape.POsY)/(70);
           exp:=true;
           DopImp.ImpX:=-(Minashape.POsX-TCapsule(sprite).Capsuleshape.POsX)/(70);
           DopImp.ImpY:=-(Minashape.POsY-TCapsule(sprite).Capsuleshape.POsY)/(70);
           DopImp.ImpPower:=0.25*(TCapsule(sprite).Impulse1.ImpPower+Impulse1.ImpPower);{0.5}
           TCapsule(sprite).Impulse1:= Mainform.Superpos(TCapsule(sprite).Impulse1,DopImp);

           DopImp.ImpX:=-DopImp.ImpX;
           DopImp.ImpY:=-DopImp.ImpY;
           Impulse1:=Mainform.Superpos(Impulse1,DopImp);
            if TCapsule(sprite).tip<>1 then
             // Mainform.SoundSystem2.Play('metal.wav',false);
             Mainform.DXWave.items.Find('metal.wav').Play(false);
         End;
End;

if sprite is TTile then
Begin

   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
        if Impulse1.ImpY<0 then
          if Colliderect.Top<TTile(Sprite).lines[i].y1 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
          Begin
             Impulse1.ImpY:=-Impulse1.ImpY;
             statics:=true;
             Impulse1.ImpPower:=Impulse1.ImpPower-0.5;
             if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
                if OldY+100<TTile(Sprite).lines[i].y1+52 then
                Begin
                   Impulse1.ImpY:=-Impulse1.ImpY;
                   //y:=TTile(Sprite).lines[i].y1-100;
                End;


          End;
        End;
        2: Begin /// Left
         if Impulse1.ImpX<0 then
           if Colliderect.Left<TTile(Sprite).lines[i].x1 then
           if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
           Begin
            statics:=true;
            Impulse1.ImpX:=-Impulse1.ImpX;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.5;
             if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then Begin
                if OldX+100<TTile(Sprite).lines[i].X1+52 then
                Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;
                End;
            End;

          End;
        End;
        3: Begin /// Down
         if Impulse1.ImpY>0 then
          if Colliderect.Bottom>TTile(Sprite).lines[i].y2 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
           Begin
            Impulse1.ImpY:=-Impulse1.ImpY;
            statics:=true;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.5;
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldY>TTile(Sprite).lines[i].y1+52 then
              Begin

                   Impulse1.ImpY:=-Impulse1.ImpY;
                  // y:=TTile(Sprite).lines[i].y2-100;
              End;
          End;
        End;

        4: Begin /// Right
         if Impulse1.ImpX>0 then
          if Colliderect.Right>TTile(Sprite).lines[i].x2 then
          if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
          Begin
            Impulse1.ImpX:=-Impulse1.ImpX;
            statics:=true;
            Impulse1.ImpPower:=Impulse1.ImpPower-0.5;
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldX>TTile(Sprite).lines[i].X1+52 then
              Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;
              End;



          End;
          End;
        5: Begin /// Left+Down
          if (Impulse1.ImpX<0)or(Impulse1.ImpY>0) then Begin
            statics:=true;
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and(Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin

              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;
       6: Begin /// Left+Down
          if (Impulse1.ImpX>0)or(Impulse1.ImpY>0) then Begin
           statics:=true;
           xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;
       7: Begin /// Right+top
          if (Impulse1.ImpX>0)or(Impulse1.ImpY<0) then Begin
            statics:=true;
            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right>xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;
       8: Begin /// Left+Top
          if (Impulse1.ImpX<0)or(Impulse1.ImpY<0) then Begin
           statics:=true;
           xp:=TTile(Sprite).lines[i].x1-(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;

      End;

End;

end;

{ TDopEff }

constructor TDopEff.Create(const AParent: TSpriteEngine);
begin
  inherited;
  impulse1.ImpX:=0;
  impulse1.ImpY:=0;
  impulse1.ImpPower:=0;
end;

procedure TDopEff.Move(const MoveCount: Single);
begin
  inherited;
///


      if impulse1.ImpPower>0 then
      Begin
          impulse1.ImpPower:=impulse1.ImpPower-abs(lagcount)/50;

          if (impulse1.ImpPower<0) then
            impulse1.ImpPower:=0;

          OldX:=x;
          OldY:=y;

        x:=x+impulse1.ImpX*impulse1.ImpPower*Movecount*5;
        y:=y+impulse1.Impy*impulse1.ImpPower*Movecount*5;

         CollideRect := Rect(Round(X),
                    Round(Y),
                    Round(X + SpriteWidth),
                    Round(Y + SpriteHeight));

        Collision;
      End;

if (x+SpriteWidth/Engine.WorldScaleX>Engine.WorldX+Engine.VisibleArea.Left) then
     if (x<Engine.WorldX+Engine.VisibleArea.Right) then
        if (y+SpriteHeight/Engine.WorldScaleY>Engine.Worldy+Engine.VisibleArea.Top) then
           if (y<Engine.Worldy+Engine.VisibleArea.Bottom) then
 Begin

    if Objs[MyObjN].Name='plasmid' then
    Begin
     ticks:=ticks+MoveCount;
      if Ticks>=max then
      bEGIN
        Ticks:=0;
        Sparkeff4(x+32,y+32,cnt);
        max:=10+random(30);
      end;
    End;

    if Objs[MyObjN].Name='save' then
    Begin
      ticks:=ticks+MoveCount;
      if Ticks>=max then
      bEGIN
        Ticks:=0;
        Sparkeff3(x+32,y+32,1+random(8),3,pfire);
      end;
    End;

    if ((abs(X+32-_Player.X-128)<128)and(abs(Y+32-_Player.Y-128)<128))or(impulse1.ImpPower>0) then
    Begin
      Collision;
    End;
 End;
end;

procedure TDopEff.OnCollision(const Sprite: TSprite);
var i,j:integer;
 xp,yp:single;
 touch:boolean;
begin
  inherited;


 if Objs[MyObjN].Name='bombin' then
 begin

 if sprite is TCapsule then
  Begin
                                 // xxzz\
   if TCapsule(Sprite).tip=8 then
   Begin
    (Sprite).Dead;
    if cnt>0 then
      cnt:=cnt-1;
    LevelMission:=cnt;
    Mainform.DXWave.items.Find('save.wav').Play(false);
    if cnt=0 then
    begin
      smessage:=language[193];
      smessageTime:=300
    end else
     miseff1:=true;
   End;
    if TCapsule(Sprite).tip<>8 then
    Begin
     TCapsule(Sprite).Y:=y0;
    End;

  End;

 end;

  if Objs[MyObjN].Name='bombin2' then
 begin

 if sprite is TCapsule then
  Begin
     TCapsule(Sprite).Y:=y0;
  End;

 end;

 if Objs[MyObjN].Name='closed' then
   if sprite is TPlayer then
     Dead;

 if Objs[MyObjN].Name='save' then
 if sprite is TPlayer then
  Begin
    Dead;
    used:=true;
    Sparkeff3(x+32,y+32,8,5,pfire);
    Mainform.SaveCheckPoint;
    smessagetime:=355;
    smessage:=language[15];

    //Mainform.SoundSystem2.Play('save.wav',false);
    Mainform.DXWave.items.Find('save.wav').Play(false);
  End;


 if Pos(Objs[MyObjN].Name,'end')=1 then
  if used=false then

 if sprite is TPlayer then
  Begin
    used:=true;
    gameover:=true;
    leveldone:=true;

     if MusVolume>0 then
          Mainform.SoundSystem.FadeOut(CurrentTrack,70);

    percento[6]:=levelscore.total;

    /// СЧИТАЮ ИТОГО
    percento[1]:=0;
    if Levelscore.enmscount>0 then
       percento[1]:=round(100*Levelscore.enms/Levelscore.enmscount);

      if LevelMissionTip=5 then
          percento[1]:=(Levelscore.enms);

    percento[2]:=0;
    if Levelscore.plasmidscount>0 then
       percento[2]:=round(100*Levelscore.plasmids/Levelscore.plasmidscount);
    percento[3]:=0;
    if Levelscore.secretscount>0 then
       percento[3]:=round(100*Levelscore.secrets/Levelscore.secretscount);
    percento[4]:=0;
    if Levelscore.shotsluck>Levelscore.shootscount/2 then
      Levelscore.shotsluck:=Levelscore.shootscount div 2;
    if Levelscore.shootscount>0 then
       percento[4]:=round(200*Levelscore.shotsluck/Levelscore.shootscount);

    percento[5]:=percento[1]+ percento[2]+ percento[3]+ percento[4];

    showtime:=Mainform.SecToHMS(trunc(Leveltime),true);

    playtime:=playtime+trunc(leveltime);
    globalscore:=levelscore.total+percento[5];

    allscore:=allscore+percento[5];

   // for I := 1 to 5 do
     // showmedal[i]:=false;

    //// Медали
     if percento[1]>=100 then inc(medals[1]);
     if percento[2]>=100 then inc(medals[2]);
     if percento[3]>=100 then inc(medals[3]);
     if percento[4]>=100 then inc(medals[4]);
     if percento[1]=0 then inc(medals[5]);

    itogo:=0;
  End;

 if Objs[MyObjN].Name='plasmid' then
 Begin
  if sprite is TLaser then
  Begin
   Touch:=false;
   if (Tlaser(Sprite).direction=1)or(Tlaser(Sprite).direction=3) then
   Begin
     /// Горизонтально
     yp:=Sprite.y+Sprite.SpriteHeight/2;
     xp:=trunc(X)+35;
     if (abs(trunc(Y)+35-yp)<70)and(xp>Sprite.x-16)and(xp<Sprite.x+Sprite.SpriteWidth+16) then
     Begin
        touch:=true;

          if ((trunc(Y)+35>yp){and(Force.ImpY<0)}) then
            Impulse1.ImpY:=1
              else
            if ((trunc(Y)+35<yp){and(Force.ImpY>0)}) then
              Impulse1.ImpY:=-1;

            Impulse1.ImpPower:=2;

     End;
   End;
  End;

  if sprite is TTile then
  if impulse1.ImpPower>0 then
  Begin
  //if not((TTile(Sprite).tip=19)) then
   if TTile(Sprite).mylinecount>0 then
    for I := 0 to TTile(Sprite).mylineCount - 1 do
      case TTile(Sprite).lines[i].lineId of

        1: Begin /// Top
        if Impulse1.ImpY<0 then
          if Colliderect.Top<TTile(Sprite).lines[i].y1 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
          Begin
             Impulse1.ImpY:=-Impulse1.ImpY;
             Impulse1.ImpPower:=Impulse1.ImpPower-0.1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
                if OldY+100<TTile(Sprite).lines[i].y1+52 then
                Begin
                   Impulse1.ImpY:=-Impulse1.ImpY;
                   //y:=TTile(Sprite).lines[i].y1-100;
                End;


          End;
        End;
        2: Begin /// Left
         if Impulse1.ImpX<0 then
           if Colliderect.Left<TTile(Sprite).lines[i].x1 then
           if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
           Begin
            Impulse1.ImpX:=-Impulse1.ImpX;

            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
             //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then Begin
                if OldX+100<TTile(Sprite).lines[i].X1+52 then
                Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;
                End;
            End;

          End;
        End;
        3: Begin /// Down
         if Impulse1.ImpY>0 then
          if Colliderect.Bottom>TTile(Sprite).lines[i].y2 then
          if (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
           Begin
            Impulse1.ImpY:=-Impulse1.ImpY;

            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

            if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
            or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldY>TTile(Sprite).lines[i].y1+52 then
              Begin

                   Impulse1.ImpY:=-Impulse1.ImpY;
                  // y:=TTile(Sprite).lines[i].y2-100;
              End;
          End;
        End;

        4: Begin /// Right
         if Impulse1.ImpX>0 then
          if Colliderect.Right>TTile(Sprite).lines[i].x2 then
          if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)  then
          Begin
            Impulse1.ImpX:=-Impulse1.ImpX;

            Impulse1.ImpPower:=Impulse1.ImpPower-0.1;
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;

             if (TTile(Sprite).tip=5)or(TTile(Sprite).tip=31)or(TTile(Sprite).tip=81)
             or(TTile(Sprite).tip=17)or(TTile(Sprite).tip=22) then
              if OldX>TTile(Sprite).lines[i].X1+52 then
              Begin
                   Impulse1.ImpX:=-Impulse1.ImpX;
              End;

          End;
          End;
        5: Begin /// Left+Down
          if (Impulse1.ImpX<0)or(Impulse1.ImpY>0) then Begin

            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);

            if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and(Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;
          End;
        End;
       6: Begin /// Left+Down
          if (Impulse1.ImpX>0)or(Impulse1.ImpY>0) then Begin

           xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
            //if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Bottom>yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY>0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;
       7: Begin /// Right+top
          if (Impulse1.ImpX>0)or(Impulse1.ImpY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1+(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1+(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Right>xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x1)and(Colliderect.Left<TTile(Sprite).lines[i].x2)  then
            Begin
              if (Impulse1.ImpX>0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;
       8: Begin /// Left+Top
          if (Impulse1.ImpX<0)or(Impulse1.ImpY<0) then Begin

            xp:=TTile(Sprite).lines[i].x1-(Colliderect.Bottom-TTile(Sprite).lines[i].y1);
            yp:=TTile(Sprite).lines[i].y1-(Colliderect.Left-TTile(Sprite).lines[i].x1);
           // if Impulse1.ImpPower<1 then Impulse1.ImpPower:=1;
            if (Colliderect.Left<xp)and(Colliderect.Top<yp) then
            if (Colliderect.Bottom>TTile(Sprite).lines[i].y1)and(Colliderect.Top<TTile(Sprite).lines[i].y2)
             and (Colliderect.Right>TTile(Sprite).lines[i].x2)and(Colliderect.Left<TTile(Sprite).lines[i].x1)  then
            Begin
              if (Impulse1.ImpX<0) then Impulse1.ImpX:=-Impulse1.ImpX;
              if (Impulse1.ImpY<0) then Impulse1.ImpY:=-Impulse1.ImpY;
            End;

          End;
        End;

      End;

  End;


  if sprite is TPlayer then
  Begin
    Dead;
    used:=true;
    if weapons[cnt].count<35 then
     inc(weapons[cnt].count);
     inc(levelscore.plasmids);
    Sparkeff3(x+32,y+32,cnt,2,pfire);
    //Mainform.SoundSystem2.Play('plasmid.wav',false);
    Mainform.DXWave.items.Find('plasmid.wav').Play(false);
  End;
 End;

 if Objs[MyObjN].Name='event' then
 if sprite is TPlayer then
  Begin
   for j:=0 to cnt do
    for i:=1 to 31 do
      if dialtray[i]=0 then
      Begin
         dialtray[i]:=max+1+j;
         Mainform.AddDialToLog(max+j);
         Break;
      End;
    havenewDLG:=true;
    if showDlg=false then
       if DialTime>64 then DialTime:=64;
    dead;    /////////!!!!!!!!
    Mainform.DXWave.items.Find('message.wav').Play(false);
  End;

  if Objs[MyObjN].Name='hint' then
 if sprite is TPlayer then
  Begin
     ///// HINT!!!
  if hintson then
  begin
    if max>0 then
      hintN:=max;
    mainform.gethinticons;
    hintmenu:=true;
    omx:=mx;
    omy:=my;
    Mainform.DXWave.Items.Find('click1.wav').Play(false);
  end;
    dead;
  End;

 if Objs[MyObjN].Name='scanzone' then
 if sprite is TPlayer then
  Begin                                         // asas
   if (scaning<=0) then
      Mainform.DXWave.Items.Find('mirr.wav').Play(false);
   scannow:=true;
   scann:=max; //20-05
   scanzone:=Colliderect;
   if scaning<=0 then
   begin
     smessagetime:=355;
     smessage:=language[170];
   end;
  End;

  if Objs[MyObjN].Name='sacred' then
 if sprite is TPlayer then
  Begin
    smessagetime:=355;
    Levelscore.secrets:=Levelscore.secrets+1;
    dead;
    smessage:=language[16];

    //Mainform.SoundSystem2.Play('message.wav',false);
    Mainform.DXWave.items.Find('message.wav').Play(false);
  End;
end;

{ TLoadThread }

procedure TLoadThread.Draw1;
begin
  with Mainform do
  if Timer.Enabled=false then
  Begin
  try
   // Mainform.Canvas.lock;

    if kadr<20 then
    imagelist1.Draw(Mainform.Canvas,Mainform.width div 2 +92, Mainform.height div 2-33,trunc(kadr{(k1+k2+k3+k4+k5)*20/25)}));

    if k1>1 then
    imagelist1.Draw(Mainform.Canvas,Mainform.width div 2 +131, Mainform.height div 2-10,k1+k2+34);

    if k3>1 then
    imagelist1.Draw(Mainform.Canvas,Mainform.width div 2 +123, Mainform.height div 2-67,k3+k4+18);


    if (k5>1) then
    imagelist1.Draw(Mainform.Canvas,Mainform.width div 2 +90, Mainform.height div 2-83,k5+29);

    //
  except
    MessageDlg(Language[171], mtError, [mbOk] , 0) ;
    //Mainform.Canvas.unlock;

   // imagelist1.Draw(Mainform.Canvas,Mainform.width div 2 +120, Mainform.height div 2-8,k5+60);
  End;
  End;
end;

procedure TLoadThread.Execute;
var ii:integer;
begin
///

FreeOnTerminate := True;
sleep(25);

if kadr<=(k1+k2+k3+k4+k5-5)*20/25 then
  kadr:=kadr+0.5;

{if kadr>=36 then kadr:=0;}

if i1 then
 if k1<6 then inc(k1);
if i2 then
 if k2<6 then inc(k2);
if i3 then
 if k3<6 then inc(k3);
if i4 then
 if k4<6 then inc(k4);
if i5 then
 if k5<6 then inc(k5);

if kadr<21 then
 Draw1;

    if menuready=true then
     Begin
      if kadr>20 then
      Begin
        Gameloaded:=true;
        Mainform.Timer.Enabled := InitSuccess;
        Mainform.Imagelist1.free;
        Terminate;
      End;
     End;

 if Terminated=false then
  Execute;
  
 
end;

{ TActor }

constructor TActor.Create(const AParent: TSpriteEngine);
begin
  inherited;
end;

procedure TActor.Move(const MoveCount: Single);
var step,dx,dy,rv2:real;
begin
  inherited;
////
 step:=1.7*MCount;
 dy:=step*Cos(Angle);
 dx:=-step*Sin(Angle);
 y:=y+dy;
 x:=x+dx;

 case phase of
   1,3:Begin
    xx:=xx+(abs(dx));
    if xx>=ex then
    Begin
      inc(phase);
      xx:=0;
    End;

   End;
   0,2,4:Begin
    xx:=xx+(abs(dy));
    if xx>ey then
    Begin
      xx:=0;
      inc(phase);
      if phase=4 then
       if mustdie then dead;
    End;
   End;
 end;

 step:=0.01*MCount;
 if angle<pi/2*phase then
  angle:=angle+step;
 if angle>pi/2*phase then
  angle:=pi/2*phase;

 if phase>=4 then
 if angle>=2*pi then
 Begin
  angle:=angle-2*pi;
  phase:=0;
  if mustdie then dead;

 // xx:=0;
 End;

                   // xcxc
 if ImageName='pbox2' then
 Begin
    if (abs(x-gamcurx)<50)and (abs(y-gamcury)<50)then
      Begin
        cursoronbox:=true;
        cursoroncapsule:=true;
        RV2:=SQRT(SQR(_Player.X+128-x)+SQR(_Player.y+128-y));
        if drawdop then
          FireEff(x,y,pfire,1);

        ChooseBound.x:=x-50;
        ChooseBound.y:=y-50;
        ChooseBound.w:=100;
        ChooseBound.h:=100;
        ShowChoosed:=true;

        if (RV2<550)and(keepitm=false) then
          TakeBox:=self;
      End;
 
 End;

end;


procedure TActor.TakeIt;
var xx,yy:integer;
begin

  xx:=trunc(x);
  yy:=trunc(y);
      with  TCapsule.Create(Engine) do
    begin
      MyObjN:=GetObjNumber('plasmidbox');
    //  showmessage(inttostr(MyObjN));

      ImageName := 'Box1';
      if Mainform.Images.Find('pBox')<>-1 then
        ImageName :='pBox';

      AnimCount:=PatternCount;
      AnimSpeed:=0.1*(random(2)+2);

      X:=xx;
      y:=yy;

      AnimPos:=random(AnimCount);


      SpriteHeight:=ImageHeight*ScaleY;
      SpriteWidth:=ImageWidth*ScaleX;

      SizeYd2:=ImageHeight div 2;
      SizeXd2:=ImageWidth div 2;

      keeping:=true;
      keep2:=false;
      prekeep:=true;
      DrawMode:=1;
      z:=-1;
      keepitm:=true;
      TPlayer(_player).keepbox:=TPlayer(_player).kb1;
      tip:=4;

      
      CollideMethod:= cmRect;
      DoCollision := True;
      end;

    dead;
    Visible:=false;
end;

{ TLaser }

procedure TLaser.Dead;
var i:integer;
begin
  inherited;
 {if (direction=1)or(direction=3) then
    for I := Trunc(x) div 100+1 to Trunc(x+SpriteWidth) div 100-1 do
     AIMaP[i,trunc(y) div 100]:=false
    else
      for I := Trunc(y) div 100+1 to Trunc(y+SpriteHeight) div 100-1 do
        AIMaP[trunc(x) div 100,i]:=false;}
end;

procedure TLaser.Move(const MoveCount: Single);
var xx1,yy1,xx2,yy2,i:integer;
begin
  inherited;
//  if  ((abs(_Player.X+128-X)<1600)or(abs(_Player.X+128-X+SpriteWidth)<1600))
  //   and((abs(_Player.Y+128-Y)<1200)or(abs(_Player.Y+128-Y+Spriteheight)<1200)) then

  LaserTicks:=Laserticks+lagcount/10;
  if Laserticks>2 then
  Begin
    LaserTicks:=0;
    case direction of
     1:Begin
       xx1:=trunc(x);
       xx2:=trunc(x+SpriteWidth);
       yy1:=trunc(y);
       yy2:=trunc(y+SpriteHeight/2);

       if Hieffs then
         BarierEff2(xx1,yy2+5,1,lascolor,trunc(SpriteWidth));
     End;
     2:Begin
       xx1:=trunc(x);
       xx2:=trunc(x+SpriteWidth/2);
       yy1:=trunc(y);
       yy2:=trunc(y+SpriteHeight);

       if Hieffs then
         BarierEff2(xx1+14,yy1,3,lascolor,trunc(SpriteHeight));

     End;
     3:Begin
       xx2:=trunc(x);
       xx1:=trunc(x+SpriteWidth);
       yy2:=trunc(y);
       yy1:=trunc(y+SpriteHeight/2);

       if Hieffs then
         BarierEff2(xx1-20,yy1+6,2,lascolor,trunc(SpriteWidth));

     End;
     4:Begin
       xx2:=trunc(x);
       xx1:=trunc(x+SpriteWidth/2);
       yy2:=trunc(y);
       yy1:=trunc(y+SpriteHeight);

       if Hieffs then
         BarierEff2(xx1+7,yy1-20,4,lascolor,trunc(SpriteHeight));
     End;
    end;

    /// Концы луча
                
    if  ((abs(_Player.X+128-Xx1)<820/GameScaleX)
     and(abs(_Player.Y+128-Yy1)<620/GameScaleX)) then
     Begin
       TrasserEff(xx1+4,yy1+4,Red,Green,Blue,1,5,psun);
     End;

    if  ((abs(_Player.X+128-Xx2)<820/GameScaleX)
     and(abs(_Player.Y+128-Yy2)<620/GameScaleX)) then
        if Hieffs then
        Begin
          TrasserEff(xx2,yy2,Red,Green,Blue,1,10,psun);
          if endonwall then
            SparkEff2(xx2,yy2, pFire,false);
        End;
  End;
    alpha:=180+trunc(30*sin(LaserTicks*pi/2));


    if (direction=1)or(direction=3) then
        for i := Trunc(x) div 100+1 to Trunc(x+SpriteWidth) div 100-1 do
        Begin
          AIDynSubMaP[i,trunc(y) div 100]:=true;
          larr[i,trunc(y) div 100]:=lascolor;
        End
          else
        for i := Trunc(y) div 100+1 to Trunc(y+SpriteHeight) div 100-1 do
        Begin
          AIDynSubMaP[trunc(x) div 100,i]:=true;
          larr[trunc(x) div 100,i]:=lascolor;
        End;

end;


end.

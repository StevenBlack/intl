*  Program...........: INTL.PRG
#DEFINE ccProgramName   "Steven Black's INTL Toolkit for Visual FoxPro"
*  Version...........:
#DEFINE ccMajorVersion "5-6-7-8-9"
#DEFINE ccRevision     "00"
#DEFINE ccBuild        "185"
#DEFINE ccDate         "July 18 2015"
*  Author............: Steven M. Black
*} Project...........: INTL for Visual FoxPro
*  Created...........: 04/30/93
*  Copyright.........: (c) Steven Black Consulting /UP! 1993-2004
*
*                 All World Rights Reserved.
*
*      By using this software, you agree to use INTL and
*      related tools for your personal use only, after having
*      paid for a license to use INTL, and not to duplicate
*      or distribute INTL and related tools to anyone or anyw
*      other party without the consent of Steven Black.
*
*              ===>  Single developer version  <====
*
*      You must purchase one copy of INTL for each developer
*      in your development group.
*
*) Description.......: Multilingual Visual FoxPro tools and classes
*)
*)  Visual FoxPro WIN MAC
*)  =====================
*)     INTL class hierarchy
*)     Menu driver for GENMENUX
*
*  Calling Samples...:
*
*    Visual FoxPro
*    =============
*      *  Forms:
*
*               SET PROC TO INTL ADDITIVE
*
*               _SCREEN.ADDOBJECT( "oINTL", "INTL", "German")
*               _SCREEN.oINTL.Localize( ThisFORM)
*               ...
*               _SCREEN.oINTL.SetLanguage( "Spanish")
*               _SCREEN.oINTL.Localize( ThisFORM)
*               ...
*               _SCREEN.oINTL.Localize( ThisFORM, "French")
*               ....
*
*      *  Menus: Called by GENMENUX as follows:
*               1. _GENMENU=<path>\GENMENUX.PRG
*               2. "*:MNXDRV2 INTL" in menu setup snippet
*                   or with "_MNXDRV2=INTL" in CONFIG.FPx
*
*  Parameter List....:
*  Returns...........: Nothing
*  Major change list.: See "INTL Revision Notes" below
*  Disabilities......: None
*  Notes.............:
*-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*******************************************************************************
*-- Default language behavior
*******************************************************************************
*-- cMylang must be PROPER()!
*-- Change this #DEFINE as appropriate
#DEFINE ccDefaultLanguage       "Original"
#DEFINE ccDefaultLanguageField  "c"+ ccDefaultLanguage
#DEFINE ccDefaultLocale         "Default"
#DEFINE ccDefaultStringsTable   "STRINGS.DBF"
#DEFINE ccMyLang                "English"
#DEFINE ccMyLocale              "Default"
#DEFINE clDefaultRightToLeft    .F.

*******************************************************************************
*-- Timing behavior
*******************************************************************************
*?  Note: Visual INTL is Run=Time only for now
#DEFINE cLocalize       "Run"
* #DEFINE cLocalize     "Generate"

*******************************************************************************
*-- String resource limit
*******************************************************************************
*-- Width of the localized string fields in STRINGS -- used when INTL needs
*-- to create thr STRINGS.DBF table
#DEFINE cnStringWidth   "120"

*******************************************************************************
*-- Mapping properties to classes
*******************************************************************************
*?  When VFP gets better at array-member speed, encoding
*?  the following into structures may be best.  However, for now...
*?  Note: No changes for 5.0 from 3.0
#DEFINE ccBoundColumns     "COMBOBOX LISTBOX "
#DEFINE ccCaptions         "CHECKBOX COMMANDBUTTON FORM HEADER LABEL "+ ;
                             "OPTIONBUTTON PAGE TOOLBAR "

#DEFINE ccContainers       "COLUMN COMMANDGROUP CONTAINER CUSTOM FORM "+;
                             "FORMSET GRID OPTIONGROUP PAGE PAGEFRAME TOOLBAR "

#DEFINE ccControlSources   "COLUMN COMBOBOX EDITBOX SPINNER TEXTBOX "
#DEFINE ccCurrencies       "EDITBOX SPINNER TEXTBOX "
#DEFINE ccDisabledPictures "CHECKBOX COMMANDBUTTON OPTIONBUTTON "
#DEFINE ccDownPictures     "COMMANDBUTTON OPTIONBUTTON "
#DEFINE ccDragIcons        "CHECKBOX COMBOBOX COMMANDBUTTON COMMANDGROUP "+ ;
                             "CONTAINER CONTROL EDITBOX GRID IMAGE "+ ;
                             "LABEL LISTBOX OPTIONBUTTON OPTIONGROUP " + ;
                             "PAGE SHAPE SPINNER TEXTBOX "

#DEFINE ccDynamicFonts     "COLUMN "
#DEFINE ccFonts            "CHECKBOX COLUMN COMBOBOX COMMANDBUTTON EDITBOX "+ ;
                             "FORM GRID HEADER LABEL LISTBOX OPTIONBUTTON "+ ;
                             "PAGE SPINNER TEXTBOX "

#DEFINE ccHelp             "CHECKBOX COMBOBOX COMMANDBUTTON COMMANDGROUP "+ ;
                             "EDITBOX FORM GRID IMAGE LABEL LINE LISTBOX "+ ;
                             "OLEBOUNDCONTROL OLECONTAINER OPTIONBUTTON "+ ;
                             "OPTIONGROUP PAGE SHAPE SPINNER TEXTBOX TOOLBAR "

#DEFINE ccIcons            "FORM "

*?///////////////////////////////////////////////////////////////////////////
*? Performance note: For slightly better performance, Comment the line below
*? if your application isn't destined for Hebrew or Arabic localizations
#DEFINE ccHebrewArabic "<<=== COMMENT ME FOR BETTER PREFORMANCE"

#IFDEF ccHebrewArabic
#DEFINE ccIgnoreables      "DATAENVIRONMENT " + ;
                             "FORMSET "
#DEFINE ccNoRightToLeft    "FORM FORMSET PAGE CUSTOM TOOLBAR "
#ELSE
#DEFINE ccIgnoreables      "COMMANDGROUP DATAENVIRONMENT OPTIONGROUP " + ;
                             "FORMSET LINE PAGEFRAME "
#ENDIF
*?////////////////////////////////////////////////////////////////////////////

#DEFINE ccInputMasks       "SPINNER TEXTBOX "

#DEFINE ccPictures         "CHECKBOX COMBOBOX COMMANDBUTTON CONTROL "+ ;
                             "FORM IMAGE LISTBOX OPTIONBUTTON PAGE "

#DEFINE ccRecordSources    "GRID "
#DEFINE ccRowSources       "COMBOBOX LISTBOX "
#DEFINE ccStatusBarTexts   "CHECKBOX COMBOBOX COMMANDBUTTON EDITBOX GRID "+ ;
                              "LISTBOX OPTIONBUTTON SPINNER TEXTBOX "

#DEFINE ccToolTips         "CHECKBOX COMBOBOX COMMANDBUTTON EDITBOX GRID "+ ;
                              "LISTBOX OPTIONBUTTON SHAPE SPINNER TEXTBOX "

*******************************************************************************
*-- Mapping classes to broad categories
*******************************************************************************
#DEFINE ccCaptionObjects   ccCaptions+ ccToolTips+ ccStatusBarTexts
#DEFINE ccDataObjects      ccBoundColumns+ ccControlSources+ ccInputMasks+ ;
                             ccRowSources+ ccRecordSources
#DEFINE ccPictureObjects   ccDisabledPictures+ ccDownPictures+ ccDragIcons+ ;
                             ccIcons+ ccPictures

*******************************************************************************
*-- Mapping default strategies to generic engines
*******************************************************************************
#DEFINE INTERFACE_UNKNOWN     "Unknown"
#DEFINE IID_ABSTRACT          "cINTLAbstract"
#DEFINE IID_MEMENTO           "cINTLMemento"
#DEFINE IID_DECORATOR         "cINTLDecorator"
#DEFINE IID_INTL              "Intl"
#DEFINE IID_STRING_STRATEGY   "cINTLString"
#DEFINE IID_CURRENCY_STRATEGY "cINTLCurrency"
#DEFINE IID_PICTURE_STRATEGY  "cINTLPicture"
#DEFINE IID_DATA_STRATEGY     "cINTLData"
#DEFINE IID_RIGHTTOLEFT_STRATEGY "cINTLRightToLeft"
#DEFINE MEMENTO_ELEMENTS       5

*******************************************************************************
*-- Operational helpers
*******************************************************************************
#DEFINE INTL_HOOK_TEST        ! ISNULL( this.oHook) AND ;
                                TYPE ("this.oHook.INTL_Abstract_ID") <> "U"

*******************************************************************************
*-- Parameters
*******************************************************************************
*-- Three parameters max, primarily to resolve any conflicts arising from
*-- parametric GENMENUX procedure calls.
PARAMETERS txParam1, txParam2, txParam3

*******************************************************************************
*-- Link resolution
*******************************************************************************
*-- These following functions exist in GENMENUX, which is
*-- in the calling stack when these are invoked.
EXTERNAL ARRAY ConfigFp, WordSearch, laObj

*******************************************************************************
*-- GENMENUX hook-out
*******************************************************************************
*-- Are we under GENMENUX?  If so, invoke the GENMENUX menu
*-- localization procedure.
IF TYPE( "m.lMprDrv2")<> "U"
  =IntlMenu()
  RETURN
ENDIF

RETURN


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L A b s t r a c t
* Purpose..: This class serves to define the interface for the whole INTL class
*            hierarchy.  Not designed to be instantiated directly.
* Version..: March 25 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLAbstract AS Line
*-- Abstract Properties
oLogicalParent  = NULL
oHook           = NULL

*-- Exposed Properties
INTL_Abstract_ID = "Visual INTL"      && Class signature, don't change.
Name            = "cINTLAbstract"    && Identifyer, don't change.

*-- Protected Properties
PROTECTED Visible, cMajorVersion, cRevision, cBuild, cDate
cMajorVersion = ccMajorversion
cRevision     = ccRevision
cBuild        = ccBuild
cDate         = ccDate
cType         = "Abstract"
Visible       = .F.

*-- Concrete methods
*====================================
*-- cINTLAbstract::GetLogicalParent()
*====================================
* Returns the logical parent.
* Not Hooked
*
FUNCTION GetLogicalParent()
   RETURN this.oLogicalParent

*====================================
*-- cINTLAbstract::GetHook()
*====================================
* Returns an object reference to the hook member.
* Not Hooked
*
FUNCTION GetHook()
   RETURN this.oHook

*====================================
*-- cINTLAbstract::GetType()
*====================================
* Returns the object's type
* Not Hooked
*
FUNCTION GetType()
   RETURN this.cType

*====================================
*-- cINTLAbstract::IsINTLClass( o)
*====================================
* Returns logical true if the passed parameter
* is an object of the INTL Class.
* Not hookable.
*
FUNCTION IsINTLClass( toPassed)
   RETURN TYPE( "toPassed.INTL_Abstract_ID" )<> "U"

*====================================
*-- cINTLAbstract::SetLogicalParent( o)
*====================================
*  Sets the logical parent property of a
*  given INTL object.
*  Not hookable.
*
FUNCTION SetLogicalParent( toParent)
   LOCAL llRetval
   llRetVal = .F.

   IF ISNULL( toParent)
     this.oLogicalparent = NULL
     llRetVal = .T.
   ENDIF
   IF !llRetVal AND TYPE( "toParent" )= "O"
     this.oLogicalparent = toParent
     llRetVal = .T.
   ENDIF
   RETURN llRetVal

*-- Abstract methods
*====================================
*-- cINTLAbstract::AdornMemento( o)
*====================================
* Puts an INTL memento in oMementoHolder
* Not Hookable
*
FUNCTION AdornMemento( oMementoHolder)
   RETURN NULL

*====================================
*-- cINTLAbstract::alang( a)
*====================================
* Fills an array with the currently supported languages.
* Hookable.
*
FUNCTION aLang( taArray)
   IF INTL_HOOK_TEST
     RETURN this.oHook.alang( @taArray)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::aStrat( an)
*====================================
* Fills an array with the names of the loaded strategies
* in their execution order.
* Hookable.
*
FUNCTION aStrat( taArray, tnType)
   IF INTL_HOOK_TEST
     RETURN this.oHook.aStrat( @taArray, @tnType)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::CreateStrategyCDX
*====================================
* Rebuild the strategy's resource index.
* Hookable.
*
FUNCTION CreateStrategyCDX()
   IF INTL_HOOK_TEST
     RETURN this.oHook.CreateStrategyCDX()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::CreateStrategyTable( c)
*====================================
FUNCTION CreateStrategyTable( tcPassed)
* Creates the strategy's resource table
* Hookable.
*
   IF INTL_HOOK_TEST
     RETURN this.oHook.CreateStrategyTable( @tcPassed)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetAlias()
*====================================
* Return the resource alias, if applicable
* Hookable.
*
FUNCTION GetAlias()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetAlias()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::Execute( xx)
*====================================
* Execute this object's primitive assignment
* Hookable.
*
FUNCTION Execute( lxPassedn, txPassed2)
   IF INTL_HOOK_TEST
     RETURN this.oHook.Execute( @lxPassed, @txPassed2)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetConfig()
*====================================
FUNCTION GetConfig()
* Return configuration integer
* Hookable.
*
 IF INTL_HOOK_TEST
   RETURN this.oHook.GetConfig()
 ELSE
   RETURN NULL
 ENDIF

*====================================
*-- cINTLAbstract::GetConversion( cxx)
*====================================
* Return a conversion factor
* Hookable.
*
FUNCTION GetConversion( tcLocale, txOther1, txOther2)
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetConversion( @tcLocale, @txOther1, @txOther2)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetExplicit()
*====================================
* Return the current explicit mode setting.
* Hookable.
*
FUNCTION GetExplicit()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetExplicit()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetLanguage()
*====================================
* Return the current localization language
* Hookable.
*
FUNCTION GetLanguage()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetLanguage()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetLocale()
*====================================
  * Return the current localization locale
* Hookable.
*
FUNCTION GetLocale()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetLocale()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetRightToLeft()
*====================================
* Return the current Right To Left localization setting
* Hookable.
*
FUNCTION GetRightToLeft()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetRightToLeft()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetStrategy( cx)
*====================================
* Return a strategy object for a given strategy alias
* Hookable.
*
FUNCTION GetStrategy( tcService, txOther)
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetStrategy( @tcService, @txOther)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetStrategyClass( c)
*====================================
* Return the strategy class of a given strategy alias
* Hookable.
*
FUNCTION GetStrategyClass( tcService)
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetStrategyClass( @tcService)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetTable()
*====================================
* Return the table for this object
* Hookable.
*
FUNCTION GetTable()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetTable()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetUpdateMode()
*====================================
* Return the current update mode setting
* Hookable.
*
FUNCTION GetUpdateMode()
   IF INTL_HOOK_TEST
     RETURN this.oHook.GetUpdateMode()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::I()
*====================================
* Localize the passed object
* Hookable.
*
FUNCTION I( txpara1, tcSpecialProc)
   IF INTL_HOOK_TEST
     RETURN this.oHook.I( @txpara1, @tcSpecialProc)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::Init()
*====================================
*
FUNCTION Init( txPara1, txPara2, txPara3)
   RETURN

*====================================
*-- cINTLAbstract::IsValidLanguage()
*====================================
* Hookable.
*
FUNCTION IsValidLanguage( tcLanguage)
   IF INTL_HOOK_TEST
     RETURN this.oHook.IsValidLanguage( @tcLanguage)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::IsInResource(x)
*====================================
* Hookable.
*
FUNCTION IsInResource( txElement)
   IF INTL_HOOK_TEST
     RETURN this.oHook.IsInResource( txElement)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::LoadStrategies()
*====================================
* Not Hooked
*
FUNCTION LoadStrategies()
   RETURN NULL

*====================================
*-- cINTLAbstract::Localize( xx)
*====================================
FUNCTION Localize( txPara1, txPara2)
   IF INTL_HOOK_TEST
     RETURN this.oHook.Localize( @txPara1, @txPara2)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::LoopOut( o)
*====================================
*
FUNCTION LoopOut( toPara1)
   IF INTL_HOOK_TEST
     RETURN this.oHook.LoopOut( @toPara1)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::Mov( on)
*====================================
* Not Hooked
*
FUNCTION Mov( toPassed, tnStackLevel)
   RETURN NULL

*====================================
*-- cINTLAbstract::objArray( oa)
*====================================
* Not Hooked: Traverses an object hierarchy
*   and fills a passed array with object references.
*
FUNCTION objArray( toPassedObject, taPassedArray)
   RETURN NULL

*====================================
*-- cINTLAbstract::OpenStrategy( cc)
*====================================
* Open a particular strategy
* Hookable.
*
FUNCTION OpenStrategy( tcFile, tcOptions)
   IF INTL_HOOK_TEST
     RETURN this.oHook.OpenStrategy( @tcFile, @tcOptions)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::Pitch()
*====================================
* Not Hooked
*
FUNCTION Pitch()
   RETURN NULL

*====================================
*-- cINTLAbstract::Pop()
*====================================
* Not Hooked
*
FUNCTION Pop( toPassed)
   RETURN NULL

*====================================
*-- cINTLAbstract::Push()
*====================================
* Not Hooked
*
FUNCTION Push( toPassed)
   RETURN NULL

*====================================
*-- cINTLAbstract::QueryInterface()
*====================================
* Not Hooked
*
FUNCTION QueryInterface( IID, oInterface)
   RETURN NULL

*====================================
*-- cINTLAbstract::Release()
*====================================
* Not Hooked
*
FUNCTION Release()
   IF INTL_HOOK_TEST
     this.oHook.Release()
   ENDIF
   RELEASE This

*====================================
*-- cINTLAbstract::ResourceInsert( x)
*====================================
* Hookable.
*
FUNCTION ResourceInsert( txPassed)
   IF INTL_HOOK_TEST
     RETURN this.oHook.ResourceInsert( @txPassed)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetAlias( c)
*====================================
* Hookable.
*
FUNCTION SetAlias( tcAlias)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetAlias( @tcAlias)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetConfig( x)
*====================================
* Hookable.
*
FUNCTION SetConfig( txPara1)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetConfig( @txPara1)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetConversion( cnx)
*====================================
* Hookable.
*
FUNCTION SetConversion( tcLocale, tnFactor, txOther)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetConversion( @tcLocale, @tnFactor, @txOther)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetDefaults()
*====================================
* Hookable.
*
FUNCTION SetDefaults()
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetDefaults()
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetExplicit( l)
*====================================
* Hookable.
*
FUNCTION SetExplicit( tlSetting)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetExplicit( @tlSetting)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetLanguage( cc)
*====================================
* Hookable.
*
FUNCTION SetLanguage( tcLanguage, txPassed1)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetLanguage( @tcLanguage, @txPassed1)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetLocale( c)
*====================================
* Hookable.
*
FUNCTION SetLocale( tcLocale)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetLocale( @tcLocale)
   ELSE
     RETURN NULL
   ENDIF


*====================================
*-- cINTLAbstract::SetHook( x)
*====================================
* Hookable.
*
FUNCTION SetHook( txPassed)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetHook( @txPassed)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetRightToLeft( l)
*====================================
* Hookable.
*
FUNCTION SetRightToLeft( tlSetting)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetRightToLeft( @tlSetting)
   ELSE
     RETURN NULL
   ENDIF


*====================================
*-- cINTLAbstract::SetStrategy( cx)
*====================================
* Hookable.
*
FUNCTION SetStrategy( tcService, txClass)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetStrategy( @tcService, @txClass)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetStrategyClass( cc)
*====================================
* Hookable.
*
FUNCTION SetStrategy( tcService, tcClass)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetStrategyClass( @tcService, @tcClass)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetTable( c)
*====================================
* Hookable.
*
FUNCTION SetTable( tcFile)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetTable( @tcFile)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::SetUpdateMode( l)
*====================================
* Hookable.
*
FUNCTION SetUpdateMode( tlTurnOn)
   IF INTL_HOOK_TEST
     RETURN this.oHook.SetUpdateMode( @tlTurnOn)
   ELSE
     RETURN NULL
   ENDIF

*====================================
*-- cINTLAbstract::GetVersion( x)
*====================================
* NotHookable.
*
FUNCTION GetVersion( txPassed)
    * RETURN ccProgramName+ CHR(13)+ CHR(10)+ this.cMajorVersion+"."+ this.cRevision+"."+ this.cBuild+ " "+ this.cDate
    RETURN ccProgramName+ " "+this.cMajorVersion+"."+ this.cRevision+"."+ this.cBuild+ " "+ this.cDate

*====================================
*-- cINTLAbstract::UpdateResource( xx)
*====================================
* Hookable.
*
FUNCTION UpdateResource( txPassed, txLocation)
   IF INTL_HOOK_TEST
     RETURN this.oHook.UpdateResource( @txPassed, @txLocation)
   ELSE
     RETURN NULL
   ENDIF

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L M e m e n t o
* Purpose..: This class serves as the parent class for most INTL classes and,
*            among other things, accesses protected properties.
* Version..: March 25 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLMemento AS cINTLAbstract

*-- Exposed Properties
 Name                 = "cINTLMemento"
 cLang                = NULL
 cLocale              = NULL
 oCurrencyStrategy    = NULL
 oDataStrategy        = NULL
 oFontStrategy        = NULL
 oHook                = NULL
 oPictureStrategy     = NULL
 oStringStrategy      = NULL
 oRightToLeftStrategy = NULL

 DIMENSION Languages[1]
 languages[1] = NULL

 DIMENSION aStrategies[ 1, 2]
 aStrategies[ 1] = NULL

*-- Protected Properties
* PROTECTED ARRAY a_Stack[ 1, MEMENTO_ELEMENTS]
 DIMENSION a_Stack[ 1, MEMENTO_ELEMENTS]
 a_Stack[ 1] = NULL

 PROTECTED ;
           cCurrencyStrategy   , ;
           cDataStrategy       , ;
           cFontStrategy       , ;
           cLang               , ;
           cLocale             , ;
           cStringStrategy     , ;
           cRightToLeftStrategy, ;
           cType               , ;
           lExplicit           , ;
           lRightToLeft        , ;
           nDefaultConfig

 cType            = "Memento"
 nConfig          = NULL

*-- Connaisance alert: In this problem domain, there
*-- are many elements that one can reasonably expect.
*-- Here they are, references stored in domain-specific
*-- properties, there for the asking.
 cCurrencyStrategy   = NULL
 cDataStrategy       = NULL
 cFontStrategy       = NULL
 cLang               = NULL
 cLocale             = NULL
 cStringStrategy     = NULL
 cRightToLeftStrategy = NULL
 lExplicit           = NULL
 lRightToLeft        = NULL
 nDefaultConfig      = NULL


*====================================
*-- cINTLMemento::Init( [ o])
*====================================
*
FUNCTION Init( toPrototype, txPassed2, txPassed3)
   IF this.IsINTLClass( toPrototype)
     *-- Grab properties from the prototype
     toPrototype.Mov( This)
   ELSE
     *-- Configure properties to default values
     this.SetDefaults()
   ENDIF

   RETURN

*====================================
*-- cINTLMemento::aStrat( an)
*====================================
* This function, like all VFP "a" finctions,
* loads an array, in this case an array of
* supported localization strategies.
*
*  n=0: Standard 1- D array of strategy names
*  n=1: 2- D array, strategy names and pointers
*  n=2: 2- D array, strategy names and config integers
*
FUNCTION aStrat( taArray, tnArrayType)
   *-- Reject null parameters
   IF ISNULL( taArray) OR ISNULL( tnArrayType)
     RETURN NULL
   ENDIF

   LOCAL lnRetVal, lnI
   lnRetVal = 0

   IF TYPE( "taArray[ 1]" )= "U"
     RETURN lnRetVal
   ENDIF

   IF EMPTY( tnArrayType) OR ;
      TYPE( "tnArrayType" )<> "N"

     tnArrayType = 0
   ENDIF

   DO CASE
   *-- Standard 1- D array of strategy names
   CASE tnArrayType = 0
     FOR lnI = 1 TO ALEN( this.aStrategies, 1)
       IF this.IsINTLClass( this.aStrategies[ lnI, 2])
         lnRetVal = lnRetVal+ 1
         DIMENSION taArray[ lnRetVal]
         taArray[ lnRetval] = this.aStrategies[ lnI, 1]
       ENDIF
     ENDFOR

   *-- 2- D array, strategy names and pointers
   CASE tnArrayType = 1
     FOR lnI = 1 TO ALEN( this.aStrategies, 1)
       IF this.IsINTLClass( this.aStrategies[ lnI, 2])
         lnRetVal = lnRetVal+ 1
         DIMENSION taArray[ lnRetVal, 2]
         taArray[ lnRetval, 1] = this.aStrategies[ lnI, 1]
         taArray[ lnRetval, 2] = this.aStrategies[ lnI, 2]
       ENDIF
     ENDFOR

   *-- 2- D array, strategy names and config integers
   CASE tnArrayType = 2
     FOR lnI = 1 TO ALEN( this.aStrategies, 1)
       lnRetVal = lnRetVal+ 1
       DIMENSION taArray[ lnRetVal, 2]
       taArray[ lnRetval, 1] = this.aStrategies[ lnI, 1]
       IF this.IsINTLClass( this.aStrategies[ lnI, 2])
         taArray[ lnRetval, 2] = this.aStrategies[ lnI, 2].GetConfig()
       ELSE
         taArray[ lnRetval, 2] = this.aStrategies[ lnI, 2]
       ENDIF
     ENDFOR

   ENDCASE

   RETURN lnRetVal

*====================================
*-- cINTLMemento::AdornMemento( [ o])
*====================================
* Puts an INTL cookie into the passed object...
*
FUNCTION AdornMemento( oMementoHolder)

   * ... if it can hold one.
   IF TYPE( "oMementoHolder.BaseClass" )<>"U" AND ;
      ( oMementoHolder.Baseclass == "Form" OR ;
        oMementoHolder.Baseclass == "Page" OR ;
        oMementoHolder.Baseclass == "Toolbar" )


     IF TYPE( "oMementoHolder.oINTLMemento" )<> "O"
       oMementoHolder.AddObject( "oINTLMemento", "cINTLMemento" )
     ELSE
       *-- Make SURE it is of class INTL
       IF ! this.IsINTLClass( oMementoHolder.oINTLMemento)
         oMementoHolder.oINTLMemento = CREATE( "cINTLMemento" )
       ENDIF
     ENDIF

   ELSE

     RETURN NULL
   ENDIF

   this.Mov( oMementoHolder.oINTLMemento)

 RETURN oMementoHolder.oINTLMemento

*====================================
*-- cINTLMemento::GetConfig()
*====================================
* Return the configuration integer
*
FUNCTION GetConfig()
   RETURN this.nConfig

*====================================
*-- cINTLMemento::GetExplicit()
*====================================
* Returns: The true if explicit localization mode
* is set.
*
FUNCTION GetExplicit()
   RETURN this.lExplicit

*====================================
*-- cINTLMemento::GetLanguage()
*====================================
* Returns: String, the current language.
*
FUNCTION GetLanguage()
   RETURN this.cLang

*====================================
*-- cINTLMemento::GetLocale()
*====================================
* Returns: String, the current locale.
*
FUNCTION GetLocale()
   RETURN this.cLocale

*====================================
*-- cINTLMemento::GetRightToLeft()
*====================================
* Returns: The true if Right-To-Left writing is used
*
FUNCTION GetRightToLeft()
   RETURN this.lRightToLeft

*====================================
*-- cINTLMemento::GetStrategy( c,n])
*====================================
* tcLocale: The Strategy- ID
* Returns:  Handle of the strategy
*           Handle or attribute (tnSpecial>0)
*
FUNCTION GetStrategy( tcStrategy, tnSpecial)
   LOCAL lcStrategy

   IF EMPTY( tnSpecial)
     tnSpecial = 0
   ENDIF

   *-- By default, return the string strategy
   IF EMPTY( tcStrategy)
     lcStrategy = "String"
   ELSE
     lcStrategy = PROPER( STRTRAN( UPPER( tcStrategy), "CINTL" ))
   ENDIF

   *-- Assert.  Reject null parameters...
   IF ISNULL( lcStrategy) OR ;
      TYPE( "lcStrategy" )<> "C"

     RETURN NULL
   ENDIF

   tcStrategy = PROPER( lcStrategy)

   LOCAL loRetVal, ;
         lnIndex

   loRetVal = NULL

   lnIndex = ASCAN( this.aStrategies, lcStrategy)

   *-- If the INTL Oject doesn't exist. See if it can't be created
   *-- and try again.
   IF lnIndex = 0
      this.SetStrategy( lcStrategy, this.QueryInterface( lcStrategy ))
      lnIndex = ASCAN( this.aStrategies, lcStrategy)
   ENDIF

   IF lnIndex<> 0 AND ;
      (this.IsINTLClass( this.aStrategies[ lnIndex+ 1]) OR ;
       tnSpecial>0)

     loRetVal = this.aStrategies[ lnIndex+ 1]
   ENDIF

   RETURN loRetVal

*====================================
*-- cINTLMemento::GetStrategyClass( cx)
*====================================
* Returns the name of the strategy class to
* be used for subsequent strategy object
* instantiations
*
FUNCTION GetStrategyClass( tcAlias )
   *-- Reject null parameter
   IF ISNULL( tcAlias)
     RETURN NULL
   ENDIF

   *--
   IF EMPTY( tcAlias) OR ;
      TYPE( "tcAlias" )<>"C"
     RETURN ""
   ENDIF

   LOCAL llRetVal, lcAlias
   lcRetVal = ""

   lcAlias = PROPER( tcAlias)


   IF lcAlias = "String"   OR ;
      lcAlias = "Font"     OR ;
      lcAlias = "Data"     OR ;
      lcAlias = "Picture"  OR ;
      lcAlias = "Currency" OR ;
      lcAlias = "Righttoleft"

     lcRetVal = this.c&lcAlias.Strategy

   ENDIF

   RETURN lcRetval

*====================================
*-- cINTLMemento::Mov( [ o], n)
*====================================
* Move the operational properties of This object
* to the parameterized object.
*
FUNCTION Mov( toPassTo, tnStackLevel)
   *-- Reject null parameters
   IF ISNULL( toPassTo) OR ISNULL( tnStackLevel)
     RETURN NULL
   ENDIF

   IF ! this.IsINTLClass( toPassTo)
     toPassTo = This
   ENDIF

   IF EMPTY( tnStacklevel)
     tnStacklevel = 0
   ENDIF

   WITH toPassTo
     IF tnStackLevel<> 0
       LOCAL lnIndex
       lnIndex = MIN( tnStackLevel, ALEN( this.a_Stack, 1 ))
       .SetLanguage(    this.a_Stack[ lnIndex, 1])
       .SetConfig(      this.a_Stack[ lnIndex, 2])
       .SetExplicit(    this.a_Stack[ lnIndex, 3])
       .SetLocale(      this.a_Stack[ lnIndex, 4])
       .SetRightToLeft( this.a_Stack[ lnIndex, 5])
     ELSE
       .SetLanguage(    this.GetLanguage())
       .SetConfig(      this.GetConfig())
       .SetExplicit(    this.GetExplicit())
       .SetLocale(      this.GetLocale())
       .SetRightToLeft( this.GetRightToLeft())
       *-- recurse engines!
       DIMENSION laThis[1], laThat[1]
       LOCAL lnThis, lnThat
       lnThis = this.aStrat( @laThis, 2)
       lnThat = .aStrat(     @laThat, 1)
       LOCAL lnI, lnMatchnum
       FOR lnI = 1 TO lnThis
         lnMatchNum =ASCAN( laThat, laThis[ lnI, 1])
         IF lnMatchNum>0 AND ALEN(laThat)>1
           laThat[ lnMatchNum+1].SetConfig(laThis[ lnI, 2])
         ELSE
           .SetStrategy(laThis[ lnI, 1], laThis[ lnI, 2])
         ENDIF
       ENDFOR
     ENDIF
   ENDWITH

   RETURN .T.

*====================================
*-- cINTLMemento::Push( [ o])
*====================================
*
FUNCTION Push( toPassed)

   *-- Reject a null parameter
   IF ISNULL( toPassed)
     RETURN NULL
   ENDIF

   LOCAL lnPropsIndex
   lnPropsIndex = 1

   IF TYPE( "toPassed" )<> "O"
     toPassed = This
   ENDIF

   IF ! ISNULL[ this.a_Stack[ 1]]
     DIMENSION this.a_Stack[ ALEN( this.a_Stack, 1)+ 1, MEMENTO_ELEMENTS]
     lnPropsIndex = ALEN( this.a_Stack, 1)
   ENDIF

   WITH toPassed
     this.a_Stack[ lnPropsIndex, 1] = .GetLanguage()
     this.a_Stack[ lnPropsIndex, 2] = .GetConfig()
     this.a_Stack[ lnPropsIndex, 3] = .GetExplicit()
     this.a_Stack[ lnPropsIndex, 4] = .GetLocale()
     this.a_Stack[ lnPropsIndex, 5] = .GetRightToLeft()
   ENDWITH

   RETURN lnPropsIndex

*====================================
*-- cINTLMemento::Pop( [ o])
*====================================
*
FUNCTION Pop( toPassed)

   *-- Reject a null parameter
   IF ISNULL( toPassed)
     RETURN NULL
   ENDIF

   LOCAL llRetVal, lNumPara
   lNumPara = PARAMETERS()

   DO CASE
   CASE lNumPara = 0
     toPassed = This
     llRetVal = .T.
   CASE TYPE( "toPassed" ) = "O"
     llRetVal = .T.
   ENDCASE

   IF llRetVal
     this.Mov( toPassed, ALEN( this.a_Stack, 1 ))
     this.Pitch()
   ENDIF

   RETURN llRetVal

*====================================
*-- cINTLMemento::Pitch()
*====================================
*
FUNCTION Pitch()
   *-- Clear the last element in the stack
   LOCAL lxRetVal
   DO CASE
   CASE ALEN( this.a_Stack, 1) > 1
     DIMENSION this.a_Stack[ ALEN( this.a_Stack, 1)- 1, MEMENTO_ELEMENTS]
     lxRetVal = .T.
   CASE !ISNULL( this.a_Stack[ 1])
     lxRetVal = .T.
     this.a_Stack[ 1] = NULL
   ENDCASE
   RETURN lxRetVal

*====================================
*-- cINTLMemento::Release()
*====================================
* Not Hooked
*
FUNCTION Release()
   *-- Tickle the logical parent
   LOCAL loTemp
   loTemp = this.GetLogicalParent()

   IF this.IsINTLClass( loTemp)
     loTemp.SetStrategy( this.GetType(), NULL )
   ENDIF

   * cINTLAbstract::Release()
   DODEFAULT()
   RETURN

*====================================
*-- cINTLMemento::QueryInterface( xo)
*====================================
* IID: Interface Id expected
* PInterface: Reference to an object
* Returns: Nothing
*
FUNCTION QueryInterface( IID, oInt)

   *-- Reject a null parameter
   IF ISNULL( IID)
     RETURN NULL
   ENDIF

   IF PARAMETERS() < 2
     RETURN NULL
   ENDIF

   IID = PROPER( IID)
   oInt = NULL

   DO CASE
   CASE IID = INTERFACE_UNKNOWN
     oInt = This

   CASE IID = IID_MEMENTO
     oInt = CREATEOBJECT( "cINTLMemento", oInt)

   CASE IID = IID_INTL
     oInt = CREATEOBJECT( "Intl", oInt)

   CASE IID = IID_STRING_STRATEGY
     oInt = CREATEOBJECT( "cINTLString", oInt)

   CASE IID = IID_Font
     oInt = CREATEOBJECT( "cINTLFont", oInt)

   CASE IID = IID_CURRENCY_STRATEGY
     oInt = CREATEOBJECT( "cINTLCurrency", oInt)

   CASE IID = IID_PICTURE_STRATEGY
     oInt = CREATEOBJECT( "cINTLPicture", oInt)

   CASE IID = IID_DATA_STRATEGY
     oInt = CREATEOBJECT( "cINTLData", oInt)

   CASE IID = IID_RIGHTTOLEFT_STRATEGY
     oInt = CREATEOBJECT( "cINTLRightToLeft", oInt)

   ENDCASE

   RETURN

*====================================
*-- INTLMemento::SetConfig( [ n])
*====================================
* Set the configuration integer.
*
FUNCTION SetConfig( txPara1)

   LOCAL lxRetVal
   lxRetVal = .F.

   *-- Reject a null parameter
   IF ISNULL( txPara1)
     RETURN NULL
   ENDIF

   *-- Numeric only
   IF ATC( TYPE( "txPara1" ), "NYL" ) = 0
     RETURN lxRetVal
   ENDIF

   DO CASE
   CASE EMPTY( txPara1)
     this.nConfig = 0
     this.LoadStrategies()
     lxRetVal = .T.

   *-- Just accept the configuration
   CASE TYPE( "TxPara1" )= "N" AND txPara1 > 0
     this.nConfig = txPara1
     this.LoadStrategies()
     lxRetVal = .T.
   ENDCASE

   RETURN lxRetVal

*====================================
*-- cINTLMemento::SetDefaults()
*====================================
* Sets INTL memento properties to default values
*
FUNCTION SetDefaults()

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.SetDefaults()
   ENDIF

   LOCAL llRetVal, llAllPass
   llRetVal = .F.
   this.Push()
   llAllPass = .F.

   LOCAL ARRAY laScratch[ MEMENTO_ELEMENTS]

   laScratch[ 1] = this.SetLocale( ccDefaultLocale)
   laScratch[ 2] = this.SetLanguage( ccDefaultLanguage)
   laScratch[ 3] = this.SetConfig( this.nDefaultConfig)
   laScratch[ 4] = this.SetExplicit( .F.)
   laScratch[ 5] = this.SetRightToLeft( clDefaultRightToLeft)

   IF laScratch[ 1] AND laScratch[ 2] AND laScratch[ 3] AND laScratch[ 4] AND laScratch[ 5]
     llRetVal = .T.
     this.Pitch()
   ELSE
     this.POP()
   ENDIF
   RETURN llRetVal

*====================================
*-- cINTLMemento::SetStrategy( cx)
*====================================
* Activate Put a strategy in the array of loaded
*   Strategies.
* tcAlias:    A character strategy name
* txStrategy: Strategy Class name, or
*             existing engine reference, or
*             config integer
*
FUNCTION SetStrategy( tcAlias, txStrategy)

   *-- Reject a null parameter
   IF ISNULL( tcAlias)
     RETURN NULL
   ENDIF

   *-- Bail if tcAlias is emty
   IF EMPTY( tcAlias) OR ;
     ( ! TYPE( "tcAlias" )= "C" )
     RETURN .F.
   ENDIF

   LOCAL llRetVal, lnIndex, lnElementIndex, loElement2, llRemoveStrategy
   llRetVal = .T.

   tcAlias = PROPER( tcAlias)
   llRemoveStrategy = ISNULL( txStrategy)

   *-- Convert a class name to an object
   IF TYPE( "txStrategy" )= "C"
     loElement2 = CREATEOBJECT( txStrategy)
   ELSE
     loElement2 = txStrategy
   ENDIF

   *-- Is this strategy in the stack already?
   lnElementIndex = ASCAN( this.aStrategies, tcAlias)

   IF !llRemoveStrategy
     IF ! INLIST( TYPE( "txStrategy" ), "C", "O", "N" )
       RETURN .F.
     ENDIF

     IF lnElementIndex = 0
       *-- Strategy does not exist.  Add it
       *-- Artefact alert: aStrategies is born with aStrategies[ 1, 1] = NULL
       IF ISNULL( this.aStrategies[ 1]) OR TYPE( "this.aStrategies[ 1]" )= "L"
         lnIndex = 1
       ELSE
         DIMENSION this.aStrategies[ ALEN( this.aStrategies, 1)+ 1, 2]
         lnIndex =ALEN( this.aStrategies, 1)
       ENDIF

       this.aStrategies[ lnIndex, 1] = tcAlias

       *-- Do we already have an object of the
       *-- correct class in the permanent pointers?
       IF this.IsINTLClass( this.o&tcAlias.Strategy) AND ;
          this.o&tcAlias.Strategy.Class = loElement2.Class

         this.aStrategies[ lnIndex, 2] = this.o&tcAlias.Strategy
       ELSE
         this.aStrategies[ lnIndex, 2] = loElement2
       ENDIF

     ELSE
       *-- Strategy exists already.
       lnIndex = ( lnElementIndex+ 1) /2
       *!*         IF ! this.IsINTLClass( this.aStrategies[ lnIndex+ 1]) OR ;
       *!*            loElement2.Class <> this.aStrategies[ lnIndex+ 1].Class
       IF ! this.IsINTLClass( this.aStrategies[ lnIndex, 2]) OR ;
          loElement2.Class <> this.aStrategies[ lnIndex, 2].Class

         this.aStrategies[ lnIndex, 2] = loElement2
       ENDIF
     ENDIF

     IF TYPE( "this.o&tcAlias.Strategy" )<>"U"
       this.o&tcAlias.Strategy = this.aStrategies[ lnIndex, 2]
     ENDIF

   ELSE
     IF lnElementIndex > 0
       =ADEL( this.aStrategies, ( lnElementIndex+ 1)/ 2)
       DIMENSION this.aStrategies[ MAX( 1, ALEN( this.aStrategies, 1)- 1), 2]
       this.o&tcAlias.Strategy = NULL
     ENDIF
   ENDIF

   *-- Now adjust the nConfig integer so that SetStrategy()
   *-- does an automatic SetConfig() if Possible
   LOCAL lnFinalconfig, lnI
   lnFinalConfig = 0
   FOR lni = 1 TO ALEN( this.aStrategies, 1)
     DO CASE
     CASE TYPE( "this.aStrategies[ lni,1]" ) <> "C" && Nothing loaded
     CASE this.aStrategies[ lni,1] = "String"
       lnFinalConfig = BITSET( lnFinalConfig, 0)
     CASE this.aStrategies[ lni,1] = "Font"
       lnFinalConfig = BITSET( lnFinalConfig, 1)
     CASE this.aStrategies[ lni,1] = "Data"
       lnFinalConfig = BITSET( lnFinalConfig, 2)
     CASE this.aStrategies[ lni,1] = "Picture"
       lnFinalConfig = BITSET( lnFinalConfig, 3)
     CASE this.aStrategies[ lni,1] = "Currency"
       lnFinalConfig = BITSET( lnFinalConfig, 4)
     CASE this.aStrategies[ lni,1] = "Righttoleft"
       lnFinalConfig = BITSET( lnFinalConfig, 5)

     ENDCASE
   ENDFOR
   this.nConfig = lnFinalConfig


   RETURN llRetval

*====================================
*-- cINTLMemento::SetStrategyClass( cx)
*====================================
* Change the strategy class for subsequent
* automatic loading
* tcClassType:  A character strategy name
* tcClassName:  Strategy Class name, or
*             existing engine reference, or
*             config integer
*
FUNCTION SetStrategyClass( tcAlias, tcStrategy)
   *-- Reject null parameters
   IF ISNULL( tcAlias) OR ;
      ISNULL( tcStrategy)
     RETURN NULL
   ENDIF

   *--
   IF EMPTY( tcAlias) OR EMPTY( tcStrategy)
     RETURN .F.
   ENDIF

   LOCAL llRetVal, lcAlias
   llRetVal = .T.

   lcAlias = PROPER( tcAlias)

   DO CASE
   CASE TYPE( "lcAlias" ) <> "C" AND ;
        TYPE( "tcStrategy" ) <> "C"
        llRetVal = .F.

   CASE lcAlias = "String" OR ;
        lcAlias = "Font" OR ;
        lcAlias = "Data" OR ;
        lcAlias = "Picture" OR ;
        lcAlias = "Currency" OR ;
        lcAlias = "Righttoleft"

     this.c&lcAlias.Strategy = tcStrategy

   OTHERWISE
     llRetVal = .F.
   ENDCASE

   RETURN llRetval

*====================================
*-- cINTLMemento::SetExplicit( l)
*====================================
* Set the Explicit mode.
*
FUNCTION SetExplicit( tlSetting)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.SetExplicit( @tlSetting)
   ENDIF

   *-- Broadcast next to all strategies
   LOCAL lnI
   FOR lnI = 1 TO ALEN( this.aStrategies, 1)
     IF this.IsINTLClass( this.aStrategies[ lnI, 2])
       this.aStrategies[ lnI, 2].SetExplicit( tlsetting)
     ENDIF
   ENDFOR

   IF TYPE( "tlSetting" )<> "L"
     RETURN .F.
   ENDIF
   this.lExplicit = tlSetting
   RETURN .T.

*====================================
*-- cINTLMemento::SetLanguage( cc)
*====================================
*
FUNCTION SetLanguage( tcLanguage, txPassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.SetLanguage( @tcLanguage, @txPassed2)
   ENDIF

   *-- Broadcast the new language to all
   *-- strategy engines.
   LOCAL lnI
   FOR lnI = 1 TO ALEN( this.aStrategies, 1)
     IF this.IsINTLClass( this.aStrategies[ lnI, 2])
       this.aStrategies[ lnI, 2].SetLanguage( tcLanguage)
     ENDIF
   ENDFOR

   *-- Reject a null parameter
   IF ISNULL( tcLanguage)
     RETURN NULL
   ENDIF

   IF ! TYPE( "tcLanguage" )= "C" OR ;
      EMPTY( tcLanguage)
     RETURN .F.
   ENDIF

   IF ! this.IsValidLanguage( tcLanguage)
     RETURN .F.
   ENDIF

   tcLanguage = PROPER( tcLanguage)
   IF tcLanguage = PROPER( ccMyLang)
     this.cLang = ccDefaultLanguage
   ELSE
     this.cLang = PROPER( tcLanguage)
   ENDIF

   Local lcAlias
   lcAlias = this.GetAlias()
   IF !ISNULL( lcAlias) AND TYPE( "txPassed2" )= "C" AND USED( lcAlias)
     PRIVATE jcOrder
     jcOrder  = "c"+ txPassed2
     *-- Halt, make sure the tag exists
     IF IsTag( jcOrder, lcAlias )
       SET ORDER TO TAG ( jcorder) IN ( lcAlias)
     ENDIF
   ENDIF

   RETURN .T.

*====================================
*-- cINTLMemento::SetLocale( c)
*====================================
* tcLocale: String, the locale.
* Returns:  True if successful.
*
FUNCTION SetLocale( tcLocale)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.SetLocale( @tcLocale)
   ENDIF

   *-- Broadcast next to all strategies
   LOCAL lnI
   FOR lnI = 1 TO ALEN( this.aStrategies, 1)
     IF this.IsINTLClass( this.aStrategies[ lnI, 2])
       this.aStrategies[ lnI, 2].SetLocale( tcLocale)
     ENDIF
   ENDFOR

   *-- Reject a null parameter
   IF ISNULL( tcLocale)
     RETURN NULL
   ENDIF

   IF EMPTY( tcLocale) OR ;
      TYPE( "tcLocale" )<> "C"
     RETURN .F.
   ENDIF

   tcLocale = PROPER( tcLocale)
   IF tcLocale = PROPER( ccMyLocale)
     this.cLocale = ccDefaultLocale
   ELSE
     this.cLocale = PROPER( tcLocale)
   ENDIF

   RETURN .T.

*====================================
*-- cINTLMemento::SetHook( o)
*====================================
*-- Mementos hook mementos
*
FUNCTION SetHook( txPassed1)
   *-- Defer first to hooks so the
   *-- new hook can be chained.
   LOCAL llRetVal, ;
         lcOldError, ;
         lnErrorCode, ;
         lxOldRef

   *-- Resolve parameters
   lxOldRef = this.oHook
   llRetVal = .T.

   this.oHook = NULL
   lcOldError = ON( "Error" )
   lnErrorCode = 0

   ON ERROR lnErrorCode = ERROR()
   DO CASE
   CASE ISNULL( txPassed1)
     llRetVal = NULL

   CASE TYPE( "txPassed1" ) = "O" AND ;
        TYPE( "txPassed1.oHook" )<> "U"
     this.oHook = txPassed1

   CASE TYPE( "txPassed1" ) = "C"
     this.oHook = CREATEOBJECT( txPassed1)

   OTHERWISE
     llRetVal = .F.
   ENDCASE

   IF this.IsINTLClass( this.oHook)
     WITH this.oHook
       .SetLogicalParent( This)
       .SetLocale(      this.GetLocale())
       .SetLanguage(    this.GetLanguage())
       .SetExplicit(    this.GetExplicit())
       .SetRightToLeft( this.GetRightToLeft())
     ENDWITH
   ENDIF

   IF lnErrorCode<> 0
     llRetVal = .F.
     this.oHook = lxOldRef
   ENDIF

   ON ERROR &lcOldError

   RETURN llRetVal

*====================================
*-- cINTLMemento::SetRightToLeft( l)
*====================================
* Set the right-to-left writing mode.
*
FUNCTION SetRightToLeft( tlSetting)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.SetRightToLeft( @tlSetting)
   ENDIF

   *-- Broadcast next to all strategies
   LOCAL lnI
   FOR lnI = 1 TO ALEN( this.aStrategies, 1)
     IF this.IsINTLClass( this.aStrategies[ lnI, 2])
       this.aStrategies[ lnI, 2].SetRightToLeft( tlsetting)
     ENDIF
   ENDFOR

   IF TYPE( "tlSetting" )<> "L"
     RETURN .F.
   ENDIF
   this.lRightToLeft = tlSetting
   RETURN .T.

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: I N T L
* Purpose..: This class is the template method for localization
* Version..: March 25 1996
* Notes....: Configuration integers:
*                [ 1] Strings  (Default)
*                [ 2] Fonts
*                [ 4] Data
*                [ 8] Images
*                [16] Currency
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS Intl AS cINTLMemento

*-- Exposed properties
 Name = "INTL"
 cCurrencyStrategy    = "cINTLCurrency"
 cDataStrategy        = "cINTLData"
 cFontStrategy        = "cINTLFont"
 cPictureStrategy     = "cINTLPicture"
 cStringStrategy      = "cINTLString"
 cRightToLeftStrategy = "cINTLRightToLeft"
 cType                = "INTL"
 nDefaultConfig       = 1
 DIMENSION Languages[1]
 languages[1] = NULL


*====================================
*-- INTL::Execute( ax)
*====================================
*
FUNCTION Execute( lxPassed, txpassed2)

   *-- Null!  Yech.
   IF ISNULL( lxPassed)
     RETURN NULL
   ENDIF

   LOCAL lcTypePassed, lxRetVal
   lcTypePassed = TYPE( "lxPassed" )
   lxRetVal = NULL

   DO CASE
   *-- lxPassed is an array of objects
   CASE lcTypePassed = "O" AND TYPE( "lxPassed[ 1]" )= "O"
     *-- Call on each active strategy and execute it.
     LOCAL lnI
     FOR lnI = 1 TO ALEN( this.aStrategies, 1)
       IF this.IsINTLClass( this.aStrategies[ lnI, 2])
         this.aStrategies[ lnI, 2].Execute( @lxPassed, txPassed2)
       ENDIF
     ENDFOR

   *-- lxPassed is a single object:
   CASE lcTypePassed = "O"
     *-- Note: txPassed could be a container of
     *-- objects.
     LOCAL ARRAY laScratch[ 1024]
     this.ObjArray( lcTypePassed, @laScratch)
     IF TYPE( "laScratch[ 1]" )= "O"
       *-- Call on each active Strategy...
       LOCAL lnI
       FOR lnI = 1 TO ALEN( this.aStrategies, 1)
         IF this.IsINTLClass( this.aStrategies[ lnI, 2])
           this.aStrategies[ lnI, 2].Execute( @laScratch, txPassed2)
         ENDIF
       ENDFOR
     ENDIF

   *-- Character:
   CASE TYPE( "lxPassed" )= "C"
     this.I( lxPassed)

   *-- Currency:
   CASE TYPE( "lxPassed" )= "Y"
     LOCAL loCStrat
     loCStrat = GetStrategy( "Currency" )
     IF this.IsINTLClass( loCStrat)
       loCStrat.I( lxPassed)
     ENDIF
   ENDCASE

   RETURN lxRetVal

*====================================
*-- INTL::I( x1, [x2])
*====================================
*
FUNCTION I( txPassed1, txPassed2)

   *-- Nulls.  Yech.
   IF ISNULL( txPassed1) OR ISNULL( txPassed2)
     RETURN NULL
   ENDIF

   LOCAL lcType, llIsArray, lxRetVal
   lcType = TYPE( "TxPassed1" )
   llIsArray = TYPE( "txPassed[ 1]" )<> "U"
   lxRetVal = ''

   *-- Branch based on the type of the first
   *-- parameter passed.
   DO CASE
   *-- Case character, defer to the hook engines
   CASE lcType = "C" AND this.IsINTLClass( this.oHook)
     lxRetVal = this.oHook.I( @txPassed1, @txPassed2)

   *-- Case object, localize the object
   CASE TYPE( "txPassed1" ) = "O"
     lxRetVal = this.Localize( txPassed1, txPassed2)

   *-- Case numeric, invoke the currency engine.
   CASE ( !ISNULL( this.GetStrategy( "Currency" ))) AND ;
        TYPE( "txPassed1" ) = "N"

     LOCAL loCStrat
     loCStrat = this.GetStrategy( "Currency" )
     lxRetVal = IIF( ISNULL( loCStrat), ;
               txPassed1, ;
               loCStrat.I( txPassed1, txPassed2 ))

   OTHERWISE
     lxRetVal = txPassed1
   ENDCASE
   RETURN lxRetVal


*====================================
*-- INTL::Init( [ c|n|o], [ c|n|o], [ c|n|o])
*-- You can pass a ( C)- Language, a ( N)
*-- Config, and/or an ( O)- Object, in any
*-- sequence
*====================================
FUNCTION Init( txPara1, txPara2, txPara3)
   SET TALK OFF
   LOCAL ;
         llConfigDone, ;
         llLangDone, ;
         llObjectDone, ;
         tcLanguage, ;
         tnConfig, ;
         toLocalize

   cINTLMemento::INIT( txPara1, txPara2, txPara3)

   STORE .F. TO llLangDone, ;
                llConfigDone, ;
                llObjectDone

   tcLanguage = ""
   tnConfig  = 1
   toLocalize = NULL

   *-- Resolve the parameters
   LOCAL lcPara1Type, lcPara3Type, lcPara3Type
   lcPara1Type = TYPE( "txPara1" )
   lcPara2Type = TYPE( "txPara2" )
   lcPara3Type = TYPE( "txPara3" )

   DO CASE
   CASE lcPara1Type = "C"
     tclanguage = PROPER( txpara1)
     llLangDone = .T.
   CASE lcPara1Type = "N"
     tnConfig = txPara1
     llConfigDone = .T.
   CASE lcPara1Type = "O"
     toLocalize = txPara1
     llObjectDone = .T.
   ENDCASE

   DO CASE
   CASE lcPara2Type = "C" AND ! llLangDone
     tclanguage = PROPER( txpara2)
     llLangDone = .T.

   CASE lcPara2Type = "N" AND ! llConfigDone
     tnConfig = txPara2
     llConfigDone = .T.

   CASE lcPara2Type = "O" AND ! llObjectDone
     toLocalize = txPara2
     llObjectDone = .T.

   ENDCASE

   DO CASE
   CASE lcPara3Type = "C" AND ! llLangDone
     tclanguage = PROPER( txpara3)

   CASE lcPara3Type = "N" AND ! llConfigDone
     tnConfig = txPara3

   CASE lcPara3Type = "O" AND ! llObjectDone
     toLocalize = txPara3

   ENDCASE

   *-- Set the language member
   IF ! this.SetLanguage( IIF( EMPTY( tcLanguage), ;
                               ccDefaultLanguage, ;
                               tcLanguage ))
     *-- This is legit.  When all fails, default.
     this.SetLanguage( ccDefaultLanguage)
   ENDIF

   *-- Load a string strategy object reference into this
   *-- special property to handle some default behavior
   this.oStringStrategy = this.GetStrategy( "String" )

   *-- Configure this object.
   this.SetConfig( tnConfig)
   this.SetHook( this.oStringStrategy)

   *-- Localize upon instantiation?
   LOCAL lcLanguage, lcLocale
   lcLanguage = this.GetLanguage()
   lcLocale = this.GetLocale()
   IF PROPER( lcLanguage)<> ccDefaultLanguage OR ;
      PROPER( lcLocale) <> ccDefaultLocale

     IF ISNULL( toLocalize)
       this.Localize( lcLanguage)
     ELSE
       this.Localize( lcLanguage, toLocalize)
     ENDIF

   ENDIF
   RETURN

*====================================
*-- INTL::GetConversion(xxx)
*====================================
*
FUNCTION GetConversion( tcLocale, txOther1, txOther2)
*-- A hook call, basically
 LOCAL lxtest
 lxtest = cINTLMemento::GetConversion( @tcLocale, @txOther1, @txOther2)
 IF !ISNULL( lxTest)
   RETURN lxTest
 ELSE
   *-- See if there is a currency strategy
   lxTest = this.GetStrategy( "Currency" )
   IF this.IsINTLClass( lxTest)
     RETURN lxTest.GetConversion( @tcLocale, @txOther1, @txOther2)
   ELSE
     RETURN NULL
   ENDIF
 ENDIF

*====================================
*-- INTL::LoadLanguageCollection()
*====================================
*
FUNCTION LoadLanguageCollection( toPassed)
 LOCAL ARRAY laLanguages[ 1]
 LOCAL lnLangs, lnI
 IF ! this.IsINTLClass( toPassed)
   toPassed = This
 ENDIF
 lnlangs = toPassed.aLang( @laLanguages)
 IF lnLangs>0
   DIMENSION toPassed.Languages[ lnLangs]
   FOR lnI = 1 TO lnlangs
     toPassed.Languages[ lnI] = laLanguages[ lnI]
   ENDFOR
 ELSE
   DIMENSION toPassed.Languages[ 1]
   toPassed.Languages[ 1] = NULL
 ENDIF
 RETURN lnlangs

*====================================
*-- INTL::LoadStrategies()
*====================================
*
FUNCTION LoadStrategies()

   *-- Broadcast first to any hook
   IF INTL_HOOK_TEST
     this.oHook.LoadStrategies()
   ENDIF

   LOCAL lnThisConfig
   lnThisConfig = this.GetConfig()
   IF ISNULL( lnThisConfig)
     RETURN .F.
   ENDIF

   this.oStringStrategy = CREATE( this.cStringStrategy)

   IF BITTEST( lnThisConfig, 0)
     this.SetStrategy( "String",  this.oStringStrategy)
     LOCAL oX
     oX = this.GetStrategy( "String" )
     IF this.IsINTLClass( oX)
       oX.SetLocale( this.GetLocale())
       oX.SetLanguage( this.GetLanguage())
       oX.SetExplicit( this.GetExplicit())
       oX.SetRightToLeft( this.GetRightToLeft())

     ENDIF

     *-- Config the hook also
     this.SetHook( NULL)
     this.SetHook( oX)

   ELSE
     this.SetStrategy( "String", NULL)
     *-- kill the hook also
     IF this.IsINTLClass( this.GetHook())
       this.SetHook( NULL)
     ENDIF
   ENDIF

   IF BITTEST( lnThisConfig, 1)
     this.SetStrategy( "Font", this.cFontStrategy )
   ELSE
     this.SetStrategy( "Font", NULL)
   ENDIF

   IF BITTEST( lnThisConfig, 2)
     this.SetStrategy( "Data", this.cDataStrategy )
   ELSE
     this.SetStrategy( "Data", NULL)
   ENDIF

   IF BITTEST( lnThisConfig, 3)
     this.SetStrategy( "Picture", this.cPictureStrategy )
   ELSE
     this.SetStrategy( "Picture", NULL)
   ENDIF

   IF BITTEST( lnThisConfig, 4)
     this.SetStrategy( "Currency", this.cCurrencyStrategy )
     LOCAL oX
     oX = this.GetStrategy( "Currency" )
     oX.SetLocale( this.GetLocale())
   ELSE
     this.SetStrategy( "Currency", NULL)
   ENDIF

   IF BITTEST( lnThisConfig, 5)
     this.SetStrategy( "RightToLeft", this.cRightToLeftStrategy )
   ELSE
     this.SetStrategy( "RightToLeft", NULL)
   ENDIF

   RETURN .T.

*====================================
*-- INTL::Localize( [ c|o[ o|c]])
*====================================
*-- You can pas a ( C)- language/locale and
*-- an ( O)- Object in any sequence.
*? ER: Accept an array of objects
*-- Returns: The previous locale identifier
FUNCTION Localize( txPara1, txPara2)

   *-- Nulls.  Done.
   IF ISNULL( txPara1) OR ISNULL( txPara2)
     RETURN NULL
   ENDIF

   LOCAL lcRetVal, ;
         llOldLockScreen, ;
         loBasis, ;
         loScreenLockedObj, ;
         tcLanguage, ;
         toParent

   loScreenLockedObj = NULL
   lcRetVal = this.GetLanguage()

   *-- Resolve passed objects
   *-- If the first parameter is an object...
   IF TYPE( "txPara1" )= "O"
     *-- ...assume, for now, that the object passed is the
     *-- parent of a collection of objects to be localized.
     toParent = txPara1

     *-- Resolve the language which may, in this case, be
     *-- passed as the second parameter.
     IF TYPE( "txpara2" )= "C"
       tcLanguage = PROPER( txPara2)
     ELSE
       tcLanguage = this.GetLanguage()
     ENDIF
   ENDIF

   *-- If we don't have a collection of objects to localize yet...
   IF TYPE( "toParent" )<> "O"
     *-- ...is this INTL object a member of a container?  If
     *-- so then we'll take that container as the basis for
     *-- the collection of objects to localize...
     IF TYPE( "this.Parent" )= "O"
       loBasis = this.Parent
     ELSE
       loBasis = This
     ENDIF
   ELSE
     *-- ... otherwise the basis for the localization is the
     *-- collection we've previously identified.
     loBasis = toParent
   ENDIF

   *-- Resolve Passed Languages
   DO CASE
   *-- 1) No language thus far.
   CASE EMPTY( tcLanguage)
     tcLanguage = this.GetLanguage()
   *-- 2) Language matches the original language.
   CASE UPPER( tcLanguage) == UPPER( ccMyLang)
     tcLanguage = ccDefaultLanguage
   ENDCASE

   *-- What locale are we in?
   tcLocale = this.GetLocale()

   *-- Step 1.  Freeze the display
   *-- Not all objects are in forms, and
   *-- Toolbars don't have a Lockscreen property...
   DO CASE
   CASE loBasis.BaseClass == "Form"
     loScreenLockedObj = loBasis
     llOldLockScreen  = loScreenLockedObj.Lockscreen
     loScreenLockedObj.LockScreen = .T.

   CASE TYPE( "ThisFORM" )= "O" AND ;
        NORM( ThisFORM.Baseclass)<> NORM( "Toolbar" )

     loScreenLockedObj = ThisFORM
     llOldLockScreen  = ThisFORM.Lockscreen
     ThisFORM.Lockscreen = .T.
   ENDCASE

   *-- Step 2.  Save the current agent's config, assume a default cookie
   LOCAL ;
         lcCookieLanguage, ;
         lcCookieLocale, ;
         lcFinalLanguage, ;
         lcFinalLocale, ;
         llCookieHere, ;
         lnCookieConfig, ;
         lnFinalConfig

   lcCookieLanguage = ccDefaultLanguage
   lcCookieLocale  = ccDefaultLocale
   lcFinalLocale   = tcLocale
   lcFinalLanguage = tcLanguage
   lnFinalConfig   = this.GetConfig()
   lnCookieConfig  = NULL

   this.SetLocale( lcFinalLocale)
   this.SetLanguage( lcFinalLanguage)

   this.Push()

   *-- Step 3. Check for a cookie.
   IF ( loBasis.Baseclass == "Form" OR ;
        loBasis.Baseclass == "Page" OR ;
        loBasis.Baseclass == "Toolbar" ) AND ;
        TYPE( "loBasis.oINTLMemento" )= "O" AND ;
        this.IsINTLClass(loBasis.oINTLMemento)

      llCookieHere = .T.

      *-- Step 3a.  Use the cookie to configure This
      LOCAL loBasisMemento
      loBasisMemento = loBasis.oINTLMemento
      lcCookieLocale  = loBasisMemento.GetLocale()
      lcCookieLanguage = loBasisMemento.GetLanguage()
      lnCookieConfig  = loBasisMemento.GetConfig()
      lnFinalConfig   = BITOR( lnFinalConfig, lnCookieConfig)
      loBasisMemento.Mov( This)
   ENDIF


   *-- Step 4.  Collection access being so slow, load an array with object pointers.
   DIMENSION laObjects[ 1]
   = this.objarray( loBasis, @laObjects)

   *-- Step 5.  Localize back to cOriginal, if required
   IF llCookieHere AND ( ;
      lcCookieLanguage<> ccDefaultLanguage OR ;
      lcCookieLocale <> ccDefaultLocale OR ;
      lnFinalConfig <> this.GetConfig() )

     IF lcCookieLocale <> ccDefaultLocale
       this.SetLocale( ccDeFaultLocale)
     ENDIF

     IF lcCookieLanguage<> ccDefaultLanguage
       this.SetLanguage( ccDeFaultLanguage, lcCookieLanguage)
     ENDIF

     this.Execute( @laObjects, -1)
   ENDIF


   *-- Step 6.  Localize to the new language/locale (if required)
   this.POP()
   this.SetConfig( lnFinalConfig)

   IF lcFinalLanguage<> ccDefaultLanguage OR ;
      lcFinalLocale<> ccDefaultLocale OR ;
      lnFinalConfig <> lnCookieConfig

     this.SetLanguage( lcFinalLanguage, ccDefaultLanguage)
     this.Execute( @laObjects, +1)

     *-- Leave a cookie behind
     this.AdornMemento( loBasis)

   ELSE

     *-- Remove the cookie
     IF TYPE( "loBasis.oINTLMemento" )= "O"
       loBasis.RemoveObject("oINTLMemento" )
     ENDIF
   ENDIF


   *-- Unlock the screen
   IF ! ISNULL( loScreenLockedObj)
     loScreenLockedObj.Lockscreen = llOldLockScreen
   ENDIF

   RETURN lcRetVal

*====================================
*-- INTL::ObjArray( oa)
*====================================
* Sample call:
*   DIMENSION laTempArray[ 1]
*   =ACOPY( this.laElements, laTempArray)
*   =objArray( this.loMasterContainer, @laTempArray)
*   =ACOPY( laTempArray, this.laElements )
*
FUNCTION objArray( toPassedObject, taPassedArray)

   IF ISNULL( toPassedObject) OR ISNULL( taPassedArray)
     RETURN NULL
   ENDIF

   LOCAL lnI, laSelObj, lcObject, laTempArray, lcbaseClass, loIterator
   loIterator = NULL

   IF TYPE( "toPassedObject" )<> "O" OR TYPE( "taPassedArray[ 1]" )= "U"
     RETURN 0
   ENDIF

   DIMENSION laSelObj[ 1]
   lcBaseCLass = UPPER( toPassedObject.BaseClass)+ " "

   *-- Don't bother with ignorables.
   IF !( lcBaseCLass $ ccIgnoreables)
     DIMENSION taPassedArray[ IIF( ALEN( taPassedArray)= 1 AND ;
                                      TYPE( "taPassedArray[ 1]" )<> "O", ;
                                   1, ;
                                   ALEN( taPassedArray)+ 1)]

     taPassedArray[ ALEN( taPassedArray)] = toPassedObject
   ENDIF

   IF lcBaseCLass $ ccContainers AND ( AMEMBERS( laSelObj,toPassedObject,2)>0)
     loIterator = CREATE( "cINTLTraverse", toPassedObject)
     LOCAL oObjectAdd
     oObjectAdd = .F.
     DO WHILE !ISNULL( oObjectAdd)
       oObjectAdd = loIterator.Next()
       IF !ISNULL( oObjectAdd)
         DIMENSION taPassedArray[ ALEN( taPassedArray)+ 1 ]
         taPassedArray[ ALEN( taPassedArray)] = oObjectAdd
       ENDIF
     ENDDO
   ENDIF
   RETURN

*====================================
*-- INTL::SetConversion(cn[x])
*====================================
*
FUNCTION SetConversion(tcLocale, tnFactor, txOther)
 LOCAL lxtest
*-- A hook call, basically
 lxtest = cINTLMemento::SetConversion( @tcLocale, @tnFactor, @txOther)
 IF !ISNULL( lxTest)
   RETURN lxTest
 ELSE
   *-- See if there is a currency strategy
   lxTest = this.GetStrategy( "Currency" )
   IF this.IsINTLClass( lxtest)
     RETURN lxtest.SetConversion( @tcLocale, @tnFactor, @txOther)
   ELSE
     RETURN NULL
   ENDIF
 ENDIF

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L S T R A T E G Y
* Purpose..: SuperClass for localization classes
* Version..: March 25 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLStrategy AS cINTLMemento

  PROTECTED cAlias,  ;
            cTable,  ;
            lStrategyOpen, ;
            lUpdate, ;
            lUpdateable

  cAlias         = NULL
  cTable         = NULL
  lStrategyOpen  = .F.
  lUpdate        = .T.
  lUpdateable    = .T.
  nDefaultConfig = 1
  cType          = "Strategy"

  *====================================
  *-- cINTLStrategy::GetAlias()
  *====================================
  * Returns the alias name of the strategy's
  * resource table.
  *
  FUNCTION GetAlias()
    RETURN this.cAlias

  *====================================
  *-- cINTLStrategy::GetTable()
  *====================================
  * Returns the name of the strategy's
  * resource table.
  *
  FUNCTION GetTable()
    RETURN this.cTable


  *====================================
  *-- cINTLStrategy::GetUpdateMode()
  *====================================
  * Returns the setting for the update mode
  * of the current strategy.
  *
  FUNCTION GetUpdateMode()
    RETURN this.lUpdate

  *====================================
  *-- cINTLStrategy::I( txpara1, tcSpecialProc)
  *====================================
  FUNCTION I( txpara1, tcSpecialProc)

    *-- Defer first to any hook
    IF INTL_HOOK_TEST
      LOCAL lxRetVal
      lxRetVal = this.oHook.I( @txPara1, @tcSpecialProc)
      IF !ISNULL( lxRetVal)
        RETURN lxRetVal
      ENDIF
    ENDIF

   *-- Reject null parameters
    IF ISNULL( txPara1) OR ISNULL( tcSpecialProc)
      RETURN NULL
    ENDIF

    LOCAL ;
       jcOldExact, ;
       jcPossible, ;
       jcRetVal, ;
       jcSearchString, ;
       jcStringsFile, ;
       jlHadC_Enter, ;
       jlHadEsc, ;
       jlHadHotKey, ;
       jnNewCol, ;
       jnNumPara, ;
       jnParaLen, ;
       jnParaLPad, ;
       jnParaRPad, ;
       JnRatio

    jnNumPara = PARAMETERS()

    DO CASE
    *-- Nothing to process. Done.
    CASE EMPTY( txPara1) OR ISNULL( txPara1)
      RETURN txPara1

    *-- Non Character. Done.
    CASE TYPE( "txPara1" )<> "C"
      RETURN txPara1
    ENDCASE

    IF jnNumPara = 1
      tcSpecialProc = ""
    ENDIF

    *?  =============================================
    *?  This whole test might not be necessary.  Removing or
    *?  simplifying this will improve performance.
    *?
    IF ! this.lStrategyOpen
     IF ! this.OpenStrategy()
        *-- Nothing can be done...
        RETURN txPara1
     ELSE
       this.lStrategyOpen = .T.
     ENDIF
    ENDIF
    *?
    *?  =============================================

    *-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    *-- Lets remember a few things about our phrase
    *-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    jnParaLen    = LENC( txPara1)

    *-- Leading spaces
    jnParaLPad   = jnParaLen - LENC( LTRIM( txPara1 ))

    *-- Trailing spaces
    jnParaRPad   = jnParaLen - LENC( RTRIM( txPara1 ))

    *-- Remember if Hot keys are present
    IF "\" $ txPara1
      jlHadEsc    = "\?" $ txPara1
      jlHadC_Enter = "\!" $ txPara1
      jlHadHotKey = "\<" $ txPara1
    ENDIF
    jlHadColon  = RIGHTC( txPara1, 1)= ":"
    jlHadEqual  = RIGHTC( txPara1, 1)= "="

    *-- Note that NoHot() just returns a modified passed string.
    *-- We ALLWAYS want this passed by
    *-- value, so....
    jcSearchString = ALLTRIM( NoHot( txPara1 ))

    *-- Exact must be ON
    jcOldExact = SET( "EXACT" )
    SET EXACT ON

    IF EMPTY( Order( "Strings" ))
      Local lcTagname
      lcTagname = "c"+ this.GetLanguage()
      IF ! EMPTY( lcTagName)
        SET ORDER TO ( lcTagName) IN Strings
      ELSE
        *-- Thanks to Rick Hodder for this one...
        SET EXACT &jcOldExact
        RETURN txPara1
      ENDIF
    ENDIF

    IF SEEK(  jcSearchString, "STRINGS" )
      LOCAL cLang
      cLang = this.GetLanguage()

      IF ISNULL( cLang)
        cLang = ccDefaultLanguage
      ENDIF
      jcPossible = TRIM( strings.c&cLang)
    ELSE
      jcPossible = ""
    ENDIF

    *-- Sorry to be slow...
    SET EXACT &jcOldExact

    *?  =============================================
    *?  This feature might not be necessary.  Removing this
    *?  can increase speed.  You might not want to have this
    *?  segment in a production version.  This adds the
    *?  unfound string to the table for future translation
    *?  Note the limitation - - no hot keys are conveyed
    *?  by the special procs process ( jcSearchString)
        IF ! FOUND( "strings" ) AND this.GetUpdateMode()
          IF PROPER( ORDER( "Strings" )) == PROPER( ccDefaultLanguageField)
            this.ResourceInsert( IIF( EMPTY( tcSpecialProc), ;
                                      ALLTRIM( txPara1), ;
                                      jcSearchString ))
          ENDIF
        ENDIF
    *?  =============================================
    jcRetVal = ""

    IF Empty( jcPossible)
       jcRetVal = txPara1
    ELSE

       *-- Remove any hotkeys the object didn't have
       IF !jlHadEsc
          jcPossible = STRTRAN( jcPossible, "\?" )
       ELSE
          *-- Thanks to Bob Grommes for the following
          IF ! "\?" $ jcPossible
             jcPossible = "\?" + jcPossible
          ENDIF
       ENDIF

       IF !jlHadC_Enter
          jcPossible = STRTRAN( jcPossible, "\!" )
       ELSE
          *-- Thanks to Bob Grommes for the following
          IF ! "\!" $ jcPossible
             jcPossible = "\!" + jcPossible
          ENDIF
       ENDIF

       IF !jlHadHotKey
          jcPossible = STRTRAN( jcPossible, "\<" )
       ENDIF

       IF !jlHadColon AND RIGHTC( jcPossible, 1)= ":"
          jcPossible = LEFTC( jcPossible, LENC( jcPossible)- 1)
       ENDIF

       *-- Fix thanks to David Bornstein, Nov 26 2002
       IF jlHadColon AND RIGHTC( jcPossible, 1)<> ":"
          jcPossible = jcPossible+ ":"
       ENDIF


       IF !jlHadEqual AND RIGHTC( jcPossible, 1)= "="
          jcPossible = LEFTC( jcPossible, LENC( jcPossible)- 1)
       ENDIF

       *-- Restore leading and trailing spaces
       jcRetVal =  REPLICATE( " ", jnParaLPad)+ jcPossible+ ;
                     REPLICATE( " ", jnParaRPad)

    ENDIF

    RETURN jcRetVal


  *====================================
  *-- cINTLStrategy::Init( toPassed)
  *====================================
  * Ignore this object?
  FUNCTION Init( toPassed)

   cINTLMemento::Init( topassed)

   *-- Open resources, if required.
   LOCAL lcTable
   lctable = this.getTable()
   IF ( !ISNULL( lctable )) AND ;
      ( !EMPTY( lctable )) AND ;
      ( !USED( lctable )) AND ;
      ( !this.OpenStrategy())

     *? Raise an exception?
     RETURN .F.
   ENDIF

  *====================================
  *-- cINTLStrategy::LoopOut( toPassed)
  *====================================
  * Ignore this object?
  *
  FUNCTION LoopOut( toPassed)

    LOCAL llRetVal
    llRetVal = .F.

    *-- Comment field ignore
    *-- Columns and headers have no comment property!!!  Argh!
    *? Having to do the following is expensive and, in my opinion,
    *? stupid. This test must fire for every object.  Sheesh!
    *? Removing this IF statement is can improve performance
    *? if you don't intend to use INTL IGNORE in comment fields.
    IF !toPassed.BaseClass $ "Column Header Separator" AND ;
        "INTL IGNORE" $ UPPER(toPassed.Comment)
      RETURN .T.
    ENDIF

    *-- INTL Property ignore
    IF TYPE( "toPassed.INTL" ) <> "U"

      lxObjINTL = toPassed.INTL

      *-- IF INTL property is NULL, do as usual <<- - TAKE NOTE!
      IF ! ISNULL( lxObjINTL)
        *-- Type?
        DO CASE
        *-- It's an object
        CASE this.IsINTLClass( lxObjINTL)
          lxObjINTL.Localize( toPassed)
          RETURN .T.

        CASE TYPE( "lxObjINTL" )= "N"
          *-- zero, or less, means ignore
          IF lxObjINTL<= 0
            RETURN .T.
          ELSE
            *-- Greater than zero, and different from current,
            *-- means create a temporary new INTL object to
            *-- handle the localize request
            IF lxObjINTL<>this.GetConfig()
              LOCAL loTempINTL
              loTempINTL = CREATE("INTL" )
              *-- Configure the temp INTL object
              this.Mov( loTempINTL)                 && New
              *-- Modify config of temp INTL object
              loTempINTL.SetConfig( toPassed.INTL)  && New
              loTempINTL.Localize( toPassed)
              RETURN .T.
            ENDIF
          ENDIF

        *-- INTL =False value means ignore
        CASE TYPE( "lxObjINTL" )= "L" AND !lxObjINTL
          RETURN .T.
        ENDCASE
      ENDIF
    ELSE
      IF this.GetExplicit()
        RETURN .T.
      ENDIF
    ENDIF
    RETURN llRetVal

  *====================================
  *-- cINTLStrategy::OpenStrategy( [ c[ c]])
  *====================================
  *
  FUNCTION OpenStrategy( tcFile, tcOptions)

    *-- Nulls. Sorry.
    IF ISNULL( tcFile) OR ISNULL( tcOptions)
      RETURN NULL
    ENDIF

    LOCAL llRetVal, lSetIndex, lSetExclusive, lcAlias
    llRetVal = .F.

    lcAlias = this.GetAlias()

    IF EMPTY( tcFile)
      tcFile = this.GetTable()
    ENDIF

    IF EMPTY( tcFile) OR ! this.SetTable( tcFile)
      RETURN llRetVal
    ENDIF

    IF EMPTY( tcOptions)
      tcOptions = ""
    ELSE
      tcOptions =UPPER( tcOptions)
    ENDIF

    lSetIndex     = ! ( "NOINDEX" $ tcOptions)
    lSetExclusive = "EXCLUSIVE" $ tcOptions

    IF ! USED( lcAlias)
      IF ! FILE( tcFile)
        tcFile = GETFILE( "DBF", ;
                          "Where is "+ lcAlias+ " table?", ;
                          "Open", ;
                           1)

        IF "Untitled" $ tcFile
          *-- Remove the path from the file name
          * tcFile = this.TrimFile( tcFile)+ lcAlias+ ".DBF"
          tcFile = ALLTRIM( IIF( RATC( "\", tcFile)= 0, ;
                           tcFile, ;
                           LEFTC( tcFile, RATC( "\", tcFile ))))+ ;
                  lcAlias+ ".DBF"

        ENDIF

        IF ! ".DBF" $ UPPER( tcFile) OR ;
           ! FILE( tcFile)
          = this.CreateStrategyTable( tcFile)
        ENDIF
      ENDIF

      *-- Error block start
      LOCAL llError, lcOldError
      lcOldError = ON( "ERROR" )
      ON ERROR llError = .T.

      IF ! lSetExclusive
        USE ( tcFile) IN 0 ALIAS &lcAlias ORDER TAG (ccDefaultLanguageField) AGAIN SHARED
      ELSE
        USE ( tcFile) IN 0 ALIAS &lcAlias ORDER TAG (ccDefaultLanguageField) EXCLUSIVE
      ENDIF

      ON ERROR &lcOldError

      IF llError
        *? raise an exception?
        RETURN .F.
      ENDIF
      *-- Error block End


      IF lSetindex
        *-- Check if the tag exists!
        IF TAGCOUNT( "Strings", "Strings" ) = 0
          this.CreateStrategyCDX()
        ENDIF
        IF EMPTY( ORDER())
          SET ORDER TO TAG (ccDefaultLanguageField) IN &lcAlias
        ENDIF
      ENDIF
    ELSE
      IF lSetExclusive
        SELECT Strings
        USE ( DBF()) ALIAS &lcAlias EXCLUSIVE
      ENDIF

      IF lSetIndex
        *-- Make sure order is set
        IF !ISTAG( ccDefaultLanguageField, lcAlias)
          this.CreateStrategyCDX()
        ENDIF
      ENDIF
    ENDIF

  *====================================
  *-- cINTLStrategy::ResourceInsert( c[c])
  *====================================
  * Insert the passed item into the resource file
  *
  FUNCTION ResourceInsert( txPassed, tcWhere)
    IF ISNULL( txpassed)
      RETURN NULL
    ENDIF
    IF ISNULL( tcWhere) OR EMPTY( tcWhere)
      tcWhere = ""
    ENDIF

    LOCAL lcAlias, lxTemp, llRetVal
    lcAlias = this.cAlias
    lxTemp =lcAlias + "."+ccDefaultLanguageField
    lxTemp =&lxTemp

    IF TYPE( "txPassed" ) = TYPE( "lxTemp" )
      llRetVal = .T.
      INSERT INTO (this.cAlias) ;
                  ( (ccDefaultLanguageField )) ;
             VALUES (  txPassed               )
      this.ResourceLogLocation(  txPassed, tcWhere)
    ENDIF

  *====================================
  *-- cINTLStategy::ResourceLogLocation( c[c])
  *====================================
  * Update the cWhere field in the resource table
  *
  FUNCTION ResourceLogLocation( tcPassed, tcWhere)
    IF ISNULL( tcpassed)
      RETURN NULL
    ENDIF
    IF TYPE( "tcPassed" ) <> "C" OR EMPTY( tcPassed)
      RETURN .F.
    ENDIF
    IF TYPE( "tcWhere" ) <> "C"
      RETURN .F.
    ENDIF
    LOCAL lcAlias, lxTemp, llRetVal
    lcAlias = this.cAlias
    lxTemp =lcAlias + "."+ccDefaultLanguageField
    lxTemp =&lxTemp

    IF TYPE( "tcPassed" ) = TYPE( "lxTemp" )
      IF TYPE( "&lcAlias..cWhere" ) <> "U"
        IF SEEK( NoHot(tcPassed), this.cAlias, ccDefaultLanguageField)
          llRetVal = .T.
          IF ATC( tcWhere, &lcAlias..cWhere)= 0
            LOCAL lnAlias
            lnAlias = SELECT()
            SELECT ( lcAlias)
            REPLACE cWhere WITH cWhere + ;
                                IIF(EMPTY( cWhere),'',CHR(13)+ CHR(10 ))+ ;
                                tcWhere
            SELECT (lnAlias)
          ENDIF
        ELSE
        ENDIF
      ELSE
        * this.ResourceInsert( tcPassed, tcWhere)
      ENDIF
    ENDIF

  *====================================
  *-- cINTLStrategy::SetAlias( c)
  *====================================
  * Sets the alias of the table used by
  * this INTL strategy
  *
  FUNCTION SetAlias( tcAlias)
    IF ISNULL( tcAlias)
      RETURN NULL
    ENDIF

    LOCAL llRetVal
    llRetVal = .F.
    IF ( ! EMPTY( tcAlias )) AND ;
       TYPE( "tcAlias" ) = "C"

      this.cAlias = tcFile
      llRetVal = .T.
    ENDIF
    RETURN llRetVal


  *====================================
  *-- cINTLStrategy::SetTable( c)
  *====================================
  * Sets the table used by this INTL strategy
  *
  FUNCTION SetTable( tcFile)
    IF ISNULL( tcFile)
      RETURN NULL
    ENDIF

    LOCAL llRetVal
    llRetVal = .F.
    IF ( ! EMPTY( tcFIle )) AND ;
       TYPE( "tcFile" ) = "C" AND ;
       FILE( tcFile)

      this.cTable = tcFile
      llRetVal = .T.
    ENDIF
    RETURN llRetVal


  *====================================
  *-- cINTLStrategy::SetUpdateMode( l)
  *====================================
  * tlTurnOn: Logical turn on?
  * Returns:  True if successful.
  *
  FUNCTION SetUpdateMode( tlTurnOn)

    *-- Reject a null parameter
    IF ISNULL( tlTurnOn)
      RETURN NULL
    ENDIF

    *-- Bail if we aren't inherantly updateable
    IF ! this.lUpdateable
      RETURN .F.
    ENDIF

    *-- Cast numerics. Make 0, negatives = .F., .T. otherwise.
    IF TYPE( "tlTurnOn" )= "N"
      tlTurnOn = tlTurnon > 0
    ENDIF

    *-- Bail if parameter is bad
    IF TYPE( "tlTurnOn" )<> "L"
      RETURN .F.
    ENDIF
    this.lUpdate = tlTurnOn
    RETURN .T.

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L C U R R E N C Y
* Purpose..: Currency localization class
* Version..: March 25 1996
*
* Remarks..: This class is my standard (and minimalist) implementation for
*            localizing currency objects
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLCurrency AS cINTLStrategy
  *-- Exposed properties
  Name = "cINTLCurrency"
  cType = "Currency"


  DIMENSION aConversion[ 1, 2]
  aConversion[ 1, 1] = ccDefaultLanguage
  aConversion[ 1, 2] = 1
  lUpdateable = .F.

*====================================
*-- INTLCurrency::Execute( ax)
*====================================
* Traverse an array of object references
*
FUNCTION Execute( laObjects, txpassed2)

 #DEFINE coINTL  "_SCREEN.oINTL"

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.Execute( @laObjects, @txpassed2)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   IF ISNULL( laObjects)
     RETURN NULL
   ENDIF

   LOCAL ;
         lcFontCombo,     ;
         lcObjBaseClass,  ;
         lnBreak,         ;
         lnConfig,        ;
         lnI,             ;
         lnOldINTLConfig, ;
         lxObjINTL,       ;
         lxRetVal

   llIsExplicit   = this.GetExplicit()
   lnOldINTLConfig = NULL
   lnThisConfig   = this.GetConfig()
   lxRetVal = NULL

   FOR lnI = 1 to ALEN( laObjects)

     *-- Bail for the standard reasons
     IF this.LoopOut( laObjects[ lnI])
       LOOP
     ENDIF

     *-- Currency category localization
     IF UPPER( laObjects[ lnI].Baseclass+ " " ) $ ccCurrencies AND ;
        "$" $ UPPER( laObjects[ lni].Format) AND ;
        TYPE( "laObjects[ lni].Value" ) $ "NY"

        local loDataObject
        loDataObject = laObjects[ lni]
        IF loDataObject.Parent.Class = "Column"
          loDataObject = loDataObject.Parent
        ENDIF

         IF txPassed2 < 0   &&  localizing back to Original
           IF TYPE( "loDataObject.ControlSource" ) <> "U" AND ;
              !EMPTY(loDataObject.ControlSource)
             Local lcTemp
             lcTemp = ALLTRIM( STRTRAN(loDataObject.ControlSource,"(" + coINTL+ ".oCurrencyStrategy.I(" ))
             lcTemp = LEFTC( lcTemp, LENC(lcTemp)-2)
             loDataObject.ResetToDefault( "ControlSource" )
             loDataObject.ControlSource = lcTemp
           ELSE
             loDataObject.Value = loDataObject.Value/this.nConfig
           ENDIF
         ELSE
           *-- localizing to new locale
           IF TYPE( "loDataObject.ControlSource" ) <> "U" AND ;
              !EMPTY(loDataObject.ControlSource)
              loDataObject.ControlSource = "(" + coINTL+ ".oCurrencyStrategy.I("+loDataObject.ControlSource+" ))"
           ELSE
              loDataObject.Value = this.I(loDataObject.Value)
           ENDIF
         ENDIF
     ENDIF

   ENDFOR
   RETURN lxRetVal


  *====================================
  *-- cINTLCurrency::GetConfig( )
  *====================================
  FUNCTION GetConfig( )
    RETURN this.GetConversion()

  *====================================
  *-- cINTLCurrency::GetConversion( xxx)
  *====================================
  FUNCTION GetConversion( tcLocale, txOther1, txOther2)

    *-- Defer first to any hook
    IF INTL_HOOK_TEST
      LOCAL lxRetVal
      lxRetVal = this.oHook.GetConversion( @tcLocale, @txOther1, @txOther2)
      IF !ISNULL( lxRetVal)
        RETURN lxRetVal
      ENDIF
    ENDIF

   *-- Reject a null locale
    IF ISNULL( tcLocale)
      RETURN NULL
    ENDIF

    IF EMPTY( tcLocale)
      tcLocale = this.GetLocale()
    ENDIF

    *-- character only
    IF AT_C( TYPE( "tcLocale" ), "ODNYTLG" )> 0
      RETURN -1
    ENDIF

    LOCAL lnRetVal
    lnRetVal = this.aConversion[ 1, 2]

    tcLocale = PROPER( tcLocale)

    lnRetVal = 1
    LOCAL lnIndex
    lnIndex = ASCAN( this.aConversion, tcLocale)
    IF lnIndex<> 0
      lnRetVal = this.aConversion[ lnIndex+ 1]
    ENDIF
    RETURN lnRetVal

  *====================================
  *-- cINTLCurrency::I( txPassed1, txPassed2)
  *====================================
  * Sets properties to default values
  *
  *-- Numeric value.  Convert.  Done.
  FUNCTION I( txPassed1, txPassed2)

    *-- Defer first to any hook
    IF INTL_HOOK_TEST
      LOCAL lxRetVal
      lxRetVal = this.oHook.I( @txPassed1, @txPassed2)
      IF !ISNULL( lxRetVal)
        RETURN lxRetVal
      ENDIF
    ENDIF

    IF ISNULL( txPassed1) OR ISNULL( txPassed2)
      RETURN NULL
    ENDIF

    IF TYPE( "txPassed1" )$ "YN"
      RETURN txPassed1 * this.GetConversion( this.GetLocale(), txPassed2)
    ELSE
      RETURN NULL
    ENDIF

  *====================================
  *-- cINTLCurrency::SetDefaults()
  *====================================
  * Sets INTL memento properties to default values
  *
  FUNCTION SetDefaults()
    *-- Broadcast first to any hook
    IF INTL_HOOK_TEST
      this.oHook.SetDefaults()
    ENDIF
    this.SetLocale( ccDefaultLocale)
    this.SetConversion( ccDefaultLocale, 1)
    this.SetConfig( this.nDefaultConfig)
    RETURN

  *====================================
  *-- cINTLCurrency::SetConversion( cnx)
  *====================================
  * txPassed1/2: A locale name & conversion factor
  * Returns:  True.
  *
  FUNCTION SetConversion( tcLocale, tnFactor, txOther)

    *-- Defer first to any hook
    IF INTL_HOOK_TEST
      LOCAL lxRetVal
      lxRetVal = this.oHook.SetConversion( @tcLocale, @tnFactor)
      IF !ISNULL( lxRetVal)
        RETURN lxRetVal
      ENDIF
    ENDIF

    IF ISNULL( tcLocale) OR ISNULL( tnFactor)
      RETURN NULL
    ENDIF

    LOCAL llRetVal, lcLocale, lnFactor
    llRetVal = .F.
    lnFactor = 0
    lcLocale =''

    *-- Resolve parameters intp
    DO CASE
    CASE TYPE( "tcLocale" )= "C"
      lcLocale = tcLocale
    CASE TYPE( "tcLocale" )= "N"
      lnFactor = tcLocale
    ENDCASE

    DO CASE
    CASE TYPE( "tnFactor" )= "C" AND EMPTY( lcLocale)
      lcLocale = tnFactor
    CASE TYPE( "tnFactor" )= "N" AND EMPTY( lnFactor)
      lnFactor = tnFactor
    ENDCASE

    IF EMPTY( lnFactor)
      RETURN .F.
    ENDIF

    IF EMPTY( lcLocale)
      lcLocale = this.GetLocale()
    ENDIF

    IF TYPE( "lnFactor" )<> "N" OR lnFactor<= 0
      RETURN llRetVal
    ENDIF

    llRetVal = .T.
    lcLocale = PROPER( lcLocale)

    LOCAL lnIndex
    lnIndex = ASCAN( this.aConversion, lcLocale)
    IF lnIndex = 0
      DIMENSION this.aConversion[ ALEN( this.aConversion, 1)+ 1, 2]
      lnIndex =ALEN( this.aConversion, 1)
      this.aConversion[ lnIndex, 1] = lcLocale
      this.aConversion[ lnIndex, 2] = lnFactor
    ELSE
      this.aConversion[ lnIndex+ 1] = lnFactor
    ENDIF

    RETURN llRetval


ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L D A T A
* Purpose..: Data localization strategy
* Version..: March 25 1996
* Notes....: Configuration integers:
*               [ 1] BoundColumn
*               [ 2] ControlSource
*               [ 4] RowSource
*               [ 8] RecordSource
*               [16] InputMask
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLData AS cINTLStrategy

  Name   = "cINTLData"
  cType  = "Data"
  cAlias = "Strings"
  cTable = ccDefaultStringsTable
  nConfig = 1

*====================================
*-- INTLData::Execute( ax)
*====================================
* Traverse an array of object references
*
FUNCTION Execute( laObj, txpassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.Execute( @laObj, @txpassed2)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( laObj)
     RETURN .F.
   ENDIF

   LOCAL llIsExplicit, lcObjBaseClass, lnThisConfig, lxRetVal, lcTemp, lnI
   lxRetVal = NULL

   llIsExplicit = this.GetExplicit()
   lnThisConfig = this.GetConfig()

   FOR lnI = 1 to ALEN( laObj)

     *-- Performance note: Cast to a memvar to avoid
     *-- repeatedly accessing a property.
     lcObjBaseClass =UPPER( laObj[ lnI].Baseclass+ " " )

     *-- Bail if the object doesn't do data
     IF ! lcObjBaseClass $ ccDataObjects
       LOOP
     ENDIF

     *-- Bail for the standard reasons
     IF this.LoopOut( laObj[ lnI])
       LOOP
     ENDIF

     Note: Boundcolumn not supported any longer  [smb Feb 11 1997]
     #IF .F.
     *-- Bound column category localization
     IF lcObjBaseclass $ ccBoundColumns AND BITTEST( lnThisConfig, 0)
         lcTemp = this.I( laObj[ lnI].BoundColumn, "BoundColumn" )
         IF LOWER(laObj[ lnI].BoundColumn) <> LOWER(lcTemp)
           laObj[ lnI].ResetToDefault( "BoundColumn" )
           laObj[ lnI].BoundColumn = lcTemp
         ENDIF
     ENDIF
     #ENDIF

     *-- Control source category localization
     IF lcObjBaseclass $ ccControlSources AND BITTEST( lnThisConfig, 1)
         lcTemp = this.I( laObj[ lnI].ControlSource, "ControlSource" )
         IF LOWER(laObj[ lnI].ControlSource) <> LOWER(lcTemp)
           laObj[ lnI].ResetToDefault( "ControlSource" )
           laObj[ lnI].ControlSource = lcTemp
         ENDIF

     ENDIF

     *-- RowSources category localization
     IF lcObjBaseclass $ ccRowSources AND BITTEST( lnThisConfig, 2)
       LOCAL lnTemp
       lnTemp = laObj[ lnI].ListIndex
       lcTemp = this.I( laObj[ lnI].RowSource, "RowSource" )
       IF LOWER(laObj[ lnI].RowSource) <> LOWER(lcTemp)
         *-- Preserve the listindex property, which is lost when
         *-- the rowsource is changed
         LOCAL lnTemp
         lnTemp = laObj[ lnI].ListIndex
         laObj[ lnI].ResetToDefault( "RowSource" )
         laObj[ lnI].RowSource = lcTemp
         laObj[ lnI].ListIndex = lnTemp
       ENDIF
     ENDIF

     *-- RecordSource category localization
     IF lcObjBaseclass $ ccRecordSources AND BITTEST( lnThisConfig, 3)
       lcTemp = this.I( laObj[ lnI].RecordSource, "RecordSource" )
       IF LOWER(laObj[ lnI].RecordSource) <> LOWER(lcTemp)
         laObj[ lnI].ResetToDefault( "RecordSource" )
         laObj[ lnI].RecordSource = lcTemp
       ENDIF
     ENDIF

     *-- InputMask category localization
     IF lcObjBaseclass $ ccInputMasks AND BITTEST( lnThisConfig, 4)
       lcTemp = this.I( laObj[ lnI].InputMask, "InputMask" )
       IF LOWER(laObj[ lnI].InputMask) <> LOWER(lcTemp)
         laObj[ lnI].ResetToDefault( "InputMask" )
         laObj[ lnI].InputMask = lcTemp
       ENDIF
     ENDIF

   ENDFOR
   RETURN lxRetVal

*====================================
*-- INTLData::I( cc)
*====================================
FUNCTION I( tcPassed1, tcContext)
   LOCAL lcCookie
   lcCookie = ''
   IF EMPTY( tcPassed1) OR ISNULL( tcPassed1) OR TYPE( 'tcPassed1') <> "C"
     RETURN tcPassed1
   ENDIF
   IF EMPTY( tcContext)
     tcContext = ''
   ELSE
     lcCookie = "(("+ PROPER( tcContext) + "))"
   ENDIF

   RETURN STRTRAN(cINTLStrategy::I( lcCookie+ tcPassed1),lcCookie)

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L F O N T
* Purpose..: Font localization strategy
* Version..: March 25 1996
* Notes....: Configuration integers:
*               [ 1] FontName & Size
*               [ 2] DynamicFontName & Size
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLFont AS cINTLStrategy

 Name = "cINTLFont"
 cType = "Font"
 nDefaultConfig = 3    && Fonts and DynamicFonts
 nConfig       = 3

 cAlias        = "Strings"
 cTable        = ccDefaultStringsTable

*====================================
*-- INTLFont::Execute( ax)
*====================================
* Traverse an array of object references
*
FUNCTION Execute( laObj, txpassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.Execute( @laObj, @txpassed2)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   IF ISNULL( laObj)
     RETURN NULL
   ENDIF

   LOCAL ARRAY laFonts[ 1, 2]
   LOCAL ;
         lcFontCombo,     ;
         lcObjBaseClass,  ;
         lnBreak,         ;
         lnConfig,        ;
         lnI,             ;
         lnOldINTLConfig, ;
         lxObjINTL,       ;
         lxRetVal

   lxRetVal = NULL
   llIsExplicit   = this.GetExplicit()
   lnOldINTLConfig = NULL
   lnThisConfig   = this.GetConfig()

   FOR lnI = 1 to ALEN( laObj)
     *-- Bail for the standard reasons
     IF this.LoopOut( laObj[ lnI])
       LOOP
     ENDIF

     *-- Performance note: Cast to a memvar to avoid
     *-- repeatedly accessing a property.
     lcObjBaseclass =UPPER( laObj[ lnI].Baseclass+ " " )

     *-- FONT category localization
     DO CASE
     CASE lcObjBaseclass $ ccFonts

       IF BITTEST( lnThisConfig, 0)
         lcFontCombo = this.I( laObj[ lnI].FontName+ ;
                              ","+ ;
                              ALLTRIM( STR( laObj[ lnI].FontSize, 3 )), "Font" )
         lnBreak    = AT_C( ",", lcFontCombo)
         laObj[ lnI].FontName = LEFTC( lcFontCombo, lnBreak- 1)
         laObj[ lnI].FontSize = VAL( SUBSTRC( lcFontCombo, lnBreak+ 1 ))
       ENDIF

       IF BITTEST( lnThisConfig, 1) AND ;
         lcObjBaseclass = "COLUMN " AND ;
         ! EMPTY( laObj[ lnI].DynamicFontName)
          *-- Same code as above, basically.
         lcFontCombo = this.I( laObj[ lnI].DynamicFontName+ ","+ ;
                              ALLTRIM( STR( laObj[ lnI].DynamicFontSize, 3 )), "DynamicFont" )
         lnBreak    = AT_C( ",", lcFontCombo)
         laObj[ lnI].DynamicFontName = LEFTC( lcFontCombo, lnBreak- 1)
         laObj[ lnI].DynamicFontSize = VAL( SUBSTRC( lcFontCombo, lnBreak+ 1 ))
       ENDIF

     *-- Supported OLE Controls
     CASE lcObjBaseclass = "OLECONTROL "
       LOCAL lcClass
       lcClass = UPPER( laObj[ lni].OleClass)
       DO CASE
       *-- TreeView, ListView, TabStrip, StatusBar, and SSTab Controls
       CASE lcClass = "COMCTL.TREECTRL"       OR ;
            lcClass = "COMCTL.LISTVIEWCTRL"   OR ;
            lcClass = "TABSTRIP.TABSTRIPCTRL" OR ;
            lcClass = "COMCTL.SBARCTRL"  OR ;
            lcClass = "TABDLG.SSTAB"     OR ;
            lcClass = "THREED.SSPANEL"   OR ;
            lcClass = "THREED.SSOPTION"  OR ;
            lcClass = "THREED.SSFRAME"   OR ;
            lcClass = "THREED.SSCOMMAND" OR ;
            lcClass = "THREED.SSCHECK"

         WITH laObj[ lni].Object
           lcFontCombo = this.I( .Font.Name+ ;
                              ","+ ;
                              ALLTRIM( STR( .Font.Size, 3 )), "Font" )
           lnBreak    = AT_C( ",", lcFontCombo)
           .Font.Name = LEFTC( lcFontCombo, lnBreak- 1)
           .Font.Size = VAL( SUBSTRC( lcFontCombo, lnBreak+ 1 ))
         ENDWITH

       ENDCASE
     ENDCASE

   ENDFOR
   RETURN lxRetVal
FUNCTION I( tcPassed1, tcContext)
   LOCAL lcCookie
   lcCookie = ''
   IF EMPTY( tcPassed1) OR ISNULL( tcPassed1) OR TYPE( 'tcPassed1') <> "C"
     RETURN tcPassed1
   ENDIF
   IF EMPTY( tcContext)
     tcContext = ''
   ELSE
     lcCookie = "(("+ PROPER( tcContext) + "))"
   ENDIF

   RETURN STRTRAN(cINTLStrategy::I( lcCookie+ tcPassed1),lcCookie)



*====================================
*-- cINTLFont::SetConfig( tnPassed)
*====================================
*
FUNCTION SetConfig( txPara1)

   *-- Defer first to any hook
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.SetConfig( @txPara1)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( txPara1)
     RETURN NULL
   ENDIF

   *-- Character and numeric only
   IF AT_C( TYPE( "txPara1" ), "--YDT--OGU" ) > 0
     RETURN .F.
   ENDIF

   LOCAL llRetVal, lnI
   LOCAL ARRAY laPropsServed[ 2]
   laPropsServed[ 1] = "FontName"          && and size
   laPropsServed[ 2] = "DynamicFontName"   && and size
   llRetVal = .F.

   DO CASE
   *-- If Empty, set default.
   CASE EMPTY( txPara1)
     this.nConfig = 3
     llRetVal = .T.

   CASE TYPE( "TxPara1" )= "N" AND BETWEEN( txPara1, 1, ( 2^ALEN( laPropsServed ))- 1)
     this.nConfig = txPara1
     llRetVal = .T.

   CASE TYPE( "TxPara1" )= "C"
     this.nConfig = 0
     FOR lnI = 1 TO ALEN( laPropsServed)
       IF ATCC( laPropsServed[ lnI], txPara1)> 0
         this.nConfig = BITSET( this.nConfig, lnI- 1)
         llRetVal = .T.
       ENDIF
     ENDFOR
   ENDCASE

   RETURN llRetVal


ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L P I C T U R E
* Purpose..: Picture localization strategy
* Version..: March 25 1996
* Notes....: Configuration integers:
*               [ 1] Picture
*               [ 2] DisabledPicture
*               [ 4] DownPicture
*               [ 8] Icon
*               [16] DragIcon
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLPicture AS cINTLStrategy

 Name = "cINTLPicture"
 cType = "Picture"
 nConfig = 9
 cAlias = "Strings"
 cTable = ccDefaultStringsTable

*====================================
*-- INTLPicture::Execute( ax)
*====================================
* Traverse the array of object references
*
FUNCTION Execute( laObj, txpassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.Execute( @laObj, @txpassed2)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( laObj)
     RETURN NULL
   ENDIF
   LOCAL llIsExplicit, lcObjBaseClass, lnThisConfig, lxRetVal, lnI

   lxRetVal = NULL

   llIsExplicit = this.GetExplicit()
   lnThisConfig = this.GetConfig()

   FOR lnI = 1 to ALEN( laObj)

     *-- Performance note: Cast to a memvar to avoid
     *-- repeatedly accessing a property.
     lcObjBaseClass =UPPER( laObj[ lnI].Baseclass+ " " )

     *-- Bail if the object doesn't do pictures
     IF ! lcObjBaseClass $ ccPictureObjects
       LOOP
     ENDIF

     *-- Bail for the standard reasons
     IF this.LoopOut( laObj[ lnI])
       LOOP
     ENDIF

     *-- Picture category localization
     IF lcObjBaseclass $ ccPictures AND BITTEST( lnThisConfig, 0)
         laObj[ lnI].Picture = this.I( laObj[ lnI].Picture, "Picture" )
     ENDIF

     *-- DisabledPicture category localization
     IF lcObjBaseclass $ ccDownPictures AND BITTEST( lnThisConfig, 1)
         laObj[ lnI].DisabledPicture = this.I( laObj[ lnI].DisabledPicture, "DisabledPicture" )
     ENDIF

     *-- DownPicture category localization
     IF lcObjBaseclass $ ccDownPictures AND BITTEST( lnThisConfig, 2)
         laObj[ lnI].DownPicture = this.I( laObj[ lnI].DownPicture, "DownPicture" )
     ENDIF

     *-- Icon category localization
     IF lcObjBaseclass $ ccIcons AND BITTEST( lnThisConfig, 3)
         laObj[ lnI].Icon = this.I( laObj[ lnI].Icon, "Icon" )
     ENDIF

     *-- DragIcon category localization
     IF lcObjBaseclass $ ccDragIcons AND BITTEST( lnThisConfig, 4)
         laObj[ lnI].DragIcon = this.I( laObj[ lnI].DragIcon, "DragIcon" )
     ENDIF
   ENDFOR
   RETURN lxRetVal

*====================================
*-- INTLPicture::I( cc)
*====================================
FUNCTION I( tcPassed1, tcContext)
   LOCAL lcCookie
   lcCookie = ''

   IF EMPTY( tcPassed1) OR ISNULL( tcPassed1) OR TYPE( 'tcPassed1') <> "C"
     RETURN tcPassed1
   ENDIF

   IF EMPTY( tcContext)
     tcContext = ''
   ELSE
     lcCookie = "(("+ PROPER( tcContext) + "))"
   ENDIF

   RETURN STRTRAN(cINTLStrategy::I( lcCookie+ tcPassed1), lcCookie)

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L S T R I N G
* Purpose..: String localization strategy
* Version..: March 25 1996
* Notes....: Configuration integers:
*               [ 1] Caption
*               [ 2] Tooltip
*               [ 4] StatusBarText
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLString AS cINTLStrategy

 cAlias = "Strings"
 cTable = ccDefaultStringsTable
 cType = "String"
 lStrategyOpen = .F.
 Name = "cINTLString"
 nConfig = 7
 nDefaultConfig = 7


*====================================
*-- cINTLString::aLang( a)
*====================================
* Return an array of languages supported by this Strategy
* taArray must be passed by reference
*
FUNCTION aLang( taArray)

   *-- Defer first to any hook
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.aLang( @taArray )
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( taArray)
     RETURN NULL
   ENDIF

   LOCAL lnRetVal

   lnRetVal = 0

   *-- accept arrays only
   IF TYPE( "taArray[ 1]" )= "U"
      RETURN lnRetVal
   ENDIF

   *-- open ( and later close) the Strategy
   *-- file, if required.
   * IF ( ! this.lStrategyOpen)  AND !USED( this.cAlias)
   IF ( ! this.lStrategyOpen)  OR !USED( this.cAlias)
     IF !this.OpenStrategy()
       RETURN 0
     ELSE
       this.lStrategyOpen = .T.
     ENDIF
   ENDIF

   LOCAL ARRAY laFields[ 1]
   IF aFields( laFields, this.cAlias)> 0
     LOCAL lnI
     FOR lnI = 1 TO ALEN( laFields, 1)
       IF laFields[ lnI, 2] = "C" AND laFields[ lnI, 1]<> "CWHERE"
         DIMENSION taArray[ lnI]
         taArray[ lnI] = PROPER( SUBSTRC( laFields[ lnI, 1], 2 ))
         lnRetVal = lnRetVal+ 1
       ENDIF
     ENDFOR
   ENDIF

   RETURN lnRetVal


*====================================
*-- cINTLString::IsValidLanguage( [ c])
*====================================
*
FUNCTION IsValidLanguage( tcLanguage)

   *-- Defer first to any hook
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.IsValidLanguage( @tcLanguage )
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   DO CASE
   CASE ISNULL( tcLanguage)
     RETURN NULL
   CASE EMPTY( tcLanguage) OR AT_C( TYPE( "tcLanguage" ), "-NYDTL-OGU" ) > 0
     RETURN .F.
   CASE PROPER( tcLanguage) = PROPER( ccMylang)
     RETURN .T.
   ENDCASE

   tcLanguage = PROPER( tcLanguage)
   DIMENSION ScratchArray[ 1]
   this.aLang( @ScratchArray)
   RETURN ASCAN( ScratchArray, tcLanguage)> 0


*====================================
*-- cINTLString::Execute( ax)
*====================================
* Traverse the passed array
*
FUNCTION Execute( laObj, txpassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     this.oHook.Execute( @laObj, @txpassed2)
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( laObj)
     RETURN NULL
   ENDIF

   LOCAL ARRAY laFonts[ 1, 2]
   LOCAL ;
         lcFontCombo, ;
         lcObjBaseClass, ;
         llIsExplicit, ;
         lnConfig, ;
         lnI, ;
         lnOldINTLConfig, ;
         lnThisConfig, ;
         lxObjINTL, ;
         lxRetVal

   llIsExplicit   = this.GetExplicit()
   lnOldINTLConfig = NULL
   lnThisConfig   = this.GetConfig()
   lxRetVal       = NULL

   *?  ER:  Use an iterator class to iterate
   *?  arrays of objects themselves...
   FOR lnI = 1 to ALEN( laObj)

     *-- Bail for the standard reasons
     IF this.LoopOut( laObj[ lnI])
       LOOP
     ENDIF

     *-- Performance note: Cast to a memvar to avoid
     *-- repeatedly accessing a property.
     lcObjBaseclass = UPPER( laObj[ lnI].Baseclass+ " " )

     DO CASE
     *-- CAPTION category localization
     CASE lcObjBaseclass $ ccCaptionObjects
       IF BITTEST( lnThisConfig, 0) AND ;
          lcObjBaseclass $ ccCaptions AND ;
          !EMPTY( laObj[ lnI].Caption)

         laObj[ lnI].Caption = this.I( laObj[ lnI].Caption)
       ENDIF

       IF BITTEST( lnThisConfig, 1) AND ;
          lcObjBaseclass $ ccToolTips AND ;
          !EMPTY( laObj[ lnI].ToolTipText)

         laObj[ lnI].ToolTipText = this.I( laObj[ lnI].ToolTipText)
       ENDIF

       IF BITTEST( lnThisConfig, 2) AND ;
          lcObjBaseclass $ ccStatusbarTexts AND ;
          !EMPTY( laObj[ lnI].StatusBarText)

         laObj[ lnI].StatusBarText = this.I( laObj[ lnI].StatusBarText)
       ENDIF

     *-- Supported OLE Controls
     CASE lcObjBaseclass = "OLECONTROL "
       LOCAL lcClass
       lcClass = UPPER( laObj[ lni].OleClass)

       DO CASE
       *-- TreeView Control
       CASE lcClass = "COMCTL.TREECTRL"
         IF laObj[ lni].Object.Nodes.Count> 0
           IF BITTEST( lnThisConfig, 0)
             *-- Load an array of node references (for faster traversal)
             WITH laObj[ lni].Object
               LOCAL ARRAY aNodes[ .Nodes.Count]
               LOCAL lnz
               FOR lnz = 1 TO ALEN( aNodes, 1)
                 aNodes( lnz)= .Nodes( lnZ)
               ENDFOR
             ENDWITH

             FOR lnZ = 1 TO ALEN( aNodes, 1)
               aNodes( lnZ).Text = this.I( aNodes( lnZ).Text)
             ENDFOR
           ENDIF
         ENDIF

       *-- ListView Control
       CASE lcClass = "COMCTL.LISTVIEWCTRL"
         IF laObj[ lni].Object.ListItems.Count > 0
           IF BITTEST( lnThisConfig, 0)
             *-- Load an array of item references (for faster traversal)
             WITH laObj[ lni].Object
               LOCAL ARRAY aItems[ .ListItems.Count]
               LOCAL lnz
               FOR lnz = 1 TO ALEN( aItems, 1)
                 aItems( lnz)= .ListItems( lnZ)
               ENDFOR
             ENDWITH

             *-- Localize the caption
             FOR lnZ = 1 TO ALEN( aItems, 1)
               aItems( lnZ).Text = this.I( aItems( lnZ).Text)
             ENDFOR
           ENDIF
         ENDIF

       *-- Tabstrip Control
       CASE lcClass = "TABSTRIP.TABSTRIPCTRL"
         *-- Load an array of page references (for faster traversal)
         IF laObj[ lni].Object.Tabs.Count > 0
           WITH laObj[ lni].Object
             LOCAL ARRAY aPages[ .Tabs.Count]
             LOCAL lnz
             FOR lnz = 1 TO ALEN( aPages, 1)
               aPages( lnz)= .Tabs( lnZ)
             ENDFOR
           ENDWITH

           *-- Localize the caption
           IF BITTEST( lnThisConfig, 0)
             *-- Few pages expected so don't bother creating a reference array
             FOR lnZ = 1 TO ALEN( aPages)
               aPages( lnZ).Caption = this.I( aPages( lnZ).Caption)
             ENDFOR
           ENDIF

           *-- Localize the tooltiptext
           IF BITTEST( lnThisConfig, 1)
             *-- Few pages expected so don't bother creating a reference array
             FOR lnZ = 1 TO ALEN( aPages)
               aPages( lnZ).ToolTiptext = this.I( aPages( lnZ).ToolTiptext)
             ENDFOR
           ENDIF
         ENDIF

       *-- Statusbar Control
       CASE lcClass = "COMCTL.SBARCTRL"
         *-- Few panels expected so don't bother creating a reference array
         *-- Localize the caption
         IF BITTEST( lnThisConfig, 0)
           FOR EACH oPanel IN laObj[ lni].Object.Panels
             oPanel.Text = this.I( oPanel.Text)
           ENDFOR
         ENDIF

       *-- SSTab Control
       CASE lcClass = "TABDLG.SSTAB"
         *-- Few panels expected so don't bother creating a reference array
         *-- Localize the caption
         IF BITTEST( lnThisConfig, 0)
           LOCAL lnIndex
           *-- SSTab is zero-based
           FOR lnIndex = 0 TO laObj[ lni].Object.Tabs-1
             laObj[ lni].Object.TabCaption( lnIndex)= this.I( laObj[ lni].Object.TabCaption( lnIndex ))
           ENDFOR
         ENDIF

       *-- Threed panel and Option controls
       CASE lcClass = "THREED.SSPANEL" OR ;
            lcClass = "THREED.SSOPTION" OR ;
            lcClass = "THREED.SSFRAME" OR ;
            lcClass = "THREED.SSCOMMAND" OR ;
            lcClass = "THREED.SSCHECK"
         IF BITTEST( lnThisConfig, 0)
             laObj[ lni].Object.Caption = this.I( laObj[ lni].Object.Caption)
            ENDIF

       ENDCASE
     ENDCASE
   ENDFOR
   RETURN lxRetVal


*====================================
*-- cINTLString::CreateStrategyTable( [ c])
*====================================
*
FUNCTION CreateStrategyTable( tcFile)
* Create a local Strategy table

   *-- Defer first to any hook
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.CreateStrategyTable( @tcFile)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( tcFile)
     RETURN NULL
   ENDIF


 IF TYPE( 'tcFile')= "O" OR ;
    EMPTY( tcFile) OR ;
    TYPE( "tcFile" )<> "C"
    tcFile = this.cAlias
 ENDIF

*-- Don't clobber any existing file.  Ever.
 IF ! FILE( this.GetTable())

   PRIVATE jcStr
   jcStr = ccDefaultLanguageField + " C(" + cnStringWidth+ "), "

   *-- Recon any INTLLANG
   LOCAL jctest
   jctest = this.GetLanguage()
   IF TYPE( "jcTest" ) = "C" AND ;
      NOT EMPTY( jcTest) AND ;
      ! ( PROPER( jcTest) = ccDefaultLanguage OR;
          PROPER( jcTest) = ccMyLang )

      jcStr = jcStr + " c" + jcTest + " C("+ cnStringWidth+ "), "
   ENDIF

   *-- Recon any wonky default INTLLANG
   IF PROPER( ccMyLang)<> ccDefaultLanguage
      jcStr = jcStr + " c" + ALLTRIM( ccMyLang) + " C(" + cnStringWidth+ "), "
   ENDIF

   jcStr = jcStr + "cWhere M"
   LOCAL lcFileName
   lcFilename = this.GetTable()
   CREATE TABLE &lcFileName ( &jcStr)
   this.CreateStrategyCDX()
   *-- Don't assume we want it open
   USE
   RETURN .T.
 ENDIF
 RETURN .F.


*====================================
*-- cINTLString::CreateStrategyCDX()
*====================================
FUNCTION CreateStrategyCDX()
*) Description.......: PROCEDURE CreateStrategyCDX
*)                     Reindex the strings table
*] Dependencies......: Assumes, for now, that strings is local

   *-- Broadcast to hooks
   IF INTL_HOOK_TEST
     this.oHook.CreateStrategyCDX()
   ENDIF

   LOCAL jnOldArea, jlWasUsed, jcStringsFile, jcField, jni, lcOldOrder
   LOCAL ARRAY jaFields[ 1]

   jlWasUsed     = .F.
   jnOldArea     = SELECT( 0)
   jcStringsFile = this.GetTable()

   jlWasUsed =USED( "Strings" )
   IF ! this.OpenStrategy( , "NOINDEX EXCLUSIVE" )
     RETURN .F.
   ENDIF
   SELECT Strings
   lcOldOrder =ORDER()
   DELETE TAG ALL

   *-- First tag, all versions, is the cOriginal field
   IF TYPE( "Strings." + ccDefaultLanguageField)<> "U"
     INDEX ON STRTRAN( STRTRAN( STRTRAN( STRTRAN( STRTRAN( cOriginal, "\<" ), "\!" ), "\?" ), ":" ), "=" ) TAG (ccDefaultLanguageField)
   ENDIF

   DIMENSION jaFields[ 1]
   this.aLang( @jaFields)
   FOR jni = 1 TO ALEN( jaFields, 1)
     IF TYPE( "jaFields( jni)" )= "C"
       jcField = "C"+ jaFields( jni)
       IF INLIST( PROPER( jcField), PROPER( ccDefaultLanguageField ))
         LOOP
       ENDIF
       INDEX ON STRTRAN( STRTRAN( STRTRAN( STRTRAN( STRTRAN( &jcField, "\<" ), "\!" ), "\?" ), ":" ), "=" ) TAG &jcField
     ENDIF
   ENDFOR

   *-- Make sure it's non- EXCLUSIVE, or unused
   *-- if originally so
   IF jlWasUsed
     USE ( jcStringsFile)
     IF ! EMPTY( lcOldOrder)
       SET ORDER TO lcOldorder
     ENDIF

   ELSE
     USE
   ENDIF

   SELECT ( jnOldArea)
   RETURN .T.

*====================================
*-- cINTLString::SetConfig( tnPassed)
*====================================
*
FUNCTION SetConfig( txPara1)

   *-- Broadcast to hooks
   IF INTL_HOOK_TEST
     this.oHook.SetConfig( txPara1)
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( txPara1)
     RETURN NULL
   ENDIF

   *-- Character and numeric only
   IF AT_C( TYPE( "txPara1" ), "--YDT--OGU" ) > 0
     RETURN .F.
   ENDIF

   LOCAL llRetVal, lnI
   LOCAL ARRAY laProps[ 3]
   laProps[ 1] = "Caption"
   laProps[ 2] = "TooltipText"
   laProps[ 3] = "StatusBarText"
   llRetVal = .F.

   DO CASE
   *-- If Empty, set default.
   CASE EMPTY( txPara1)
     this.nConfig = 7
     llRetVal = .T.

   CASE TYPE( "TxPara1" )= "N" AND BETWEEN( txPara1, 1, ( 2^ALEN( laProps ))- 1)
     this.nConfig = txPara1
     llRetVal = .T.

   CASE TYPE( "TxPara1" )= "C"
     this.nConfig = 0
     FOR lnI = 1 TO ALEN( laProps)
       IF ATCC( laProps[ lnI], txPara1)> 0
         this.nConfig = BITSET( this.nConfig, lnI- 1)
         llRetVal = .T.
       ENDIF
     ENDFOR
   ENDCASE
   IF llRetVal
     this.LoadStrategies()
   ENDIF
   RETURN llRetVal

   *====================================
   *-- cINTLString::IsInResource(x)
   *====================================
   * Is the passed item in the resource file?
   *
   FUNCTION IsInResource( txElement)
     IF ISNULL( txElement)
       RETURN NULL
     ENDIF
     LOCAL llRetVal, lcAlias, lcOldExact
     llRetVal = .F.
     IF TYPE( "txElement" ) = "C"
       lcAlias = this.GetAlias()
       *-- Open the resource table again
       IF USED( lcAlias) OR this.OpenStrategy()
         lcOldExact = SET( "Exact" )
         SET EXACT ON
*!*	         IF KEYMATCH( NoHot(txElement), ;
*!*	                      TAGNO( ccDefaultLanguageField, ;
*!*	                             '', ;
*!*	                             this.cAlias), ;
*!*	                      this.cAlias)
         IF INDEXSEEK( NoHot(txElement), ;
                       .T., ;
                       this.cAlias, ;
                       TAGNO( ccDefaultLanguageField, this.cAlias ))


           llRetVal = .T.
         ENDIF
         SET EXACT &lcOldExact
       ENDIF
     ENDIF
     RETURN llRetVal

  *====================================
  *-- cINTLString::ResourceInsert( c[c])
  *====================================
  * Insert the passed item into the resource file
  *
  FUNCTION ResourceInsert( txPassed, tcWhere)
    IF ISNULL( txpassed)
      RETURN NULL
    ENDIF
    IF ISNULL( tcWhere) OR EMPTY( tcWhere)
      tcWhere = ""
    ENDIF

    LOCAL lcAlias, lxTemp, llRetVal
    lcAlias = this.cAlias
    lxTemp =lcAlias + "."+ccDefaultLanguageField
    lxTemp =&lxTemp

    IF TYPE( "txPassed" ) = TYPE( "lxTemp" )
      llRetVal = .T.
      INSERT INTO (this.cAlias) ;
                  ( (ccDefaultLanguageField )) ;
             VALUES (  txPassed               )
      this.ResourceLogLocation(  txPassed, tcWhere)
    ENDIF


  *====================================
  *-- cINTLString::UpdateResource( c[c])
  *====================================
  * Insert the passed item into the resource file
  *
  FUNCTION UpdateResource( txPassed, tcWhere)
    IF ISNULL( txPassed)
      RETURN NULL
    ENDIF
    IF ISNULL( tcWhere) OR EMPTY( tcWhere)
      tcWhere = ""
    ENDIF

    LOCAL llRetVal
    llRetVal = .F.
    IF ! this.IsInResource( txPassed)
      llRetVal = this.ResourceInsert( txPassed, tcWhere)
    ELSE
      IF !EMPTY( tcWhere)
        llRetVal = this.ResourceLogLocation( txPassed, tcWhere)
      ENDIF
    ENDIF
    RETURN llRetVal

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I N T L R I G H T T O L E F T
* Purpose..: Right-to-Left strategy for Middle Eastern writing systems
* Version..: Feb 6 1997
* Notes....: Configuration integers:
*               [ 1] ON
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLRightToLeft AS cINTLStrategy

 Name   = "cINTLRIGHTTOLEFT"
 cType  = "Righttoleft"
 nConfig = 1

*====================================
*-- INTLRightToLeft::Execute( ax)
*====================================
* Traverse the array of object references
*
FUNCTION Execute( laObj, txpassed2)

   *-- Broadcast first to the hooks
   IF INTL_HOOK_TEST
     LOCAL lxRetVal
     lxRetVal = this.oHook.Execute( @laObj, @txpassed2)
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ENDIF
   ENDIF

   *-- Reject a null parameter
   IF ISNULL( laObj)
     RETURN NULL
   ENDIF
   LOCAL llIsExplicit, lcObjBaseClass, lnThisConfig, lxRetVal, lnI

   lxRetVal = NULL

   llIsExplicit = this.GetExplicit()
   lnThisConfig = this.GetConfig()

   FOR lnI = 1 to ALEN( laObj)

     *-- Performance note: Cast to a memvar to avoid
     *-- repeatedly accessing a property.
     lcObjBaseClass =UPPER( laObj[ lnI].Baseclass+ " " )

     *-- Bail if the object doesn't do Right-To-Left
     IF lcObjBaseClass $ ccNoRightToLeft
       LOOP
     ENDIF

     *-- Bail for the standard reasons
     IF this.LoopOut( laObj[ lnI])
       LOOP
     ENDIF

     *-- Reverse the alignment or ordering sequences
     DO CASE

     *-- Secial Checkbox consideration
     *-- Flip the Alignment property
     CASE lcObjBaseClass = "CHECKBOX "
       IF laObj[ lnI].Alignment = 0
         laObj[ lnI].Alignment = 1
       ELSE
         laObj[ lnI].Alignment = 0
       ENDIF

     *-- Secial Optionbutton consideration
     *-- Flip the Alignment property
     CASE lcObjBaseClass = "OPTIONBUTTON "
       IF laObj[ lnI].Alignment = 0
         laObj[ lnI].Alignment = 1
       ELSE
         laObj[ lnI].Alignment = 0
       ENDIF

     *-- Columns and Headers are special, with Top/Middle/Bottom
     *-- left and right alignments...
     CASE lcObjBaseClass = "COLUMN " OR ;
          lcObjBaseClass = "HEADER "
       DO CASE
       CASE laObj[ lnI].Alignment = 0 OR ;
            laObj[ lnI].Alignment = 4 OR ;
            laObj[ lnI].Alignment = 7 OR ;
         laObj[ lnI].Alignment = laObj[ lnI].Alignment+ 1

       CASE laObj[ lnI].Alignment = 1 OR ;
            laObj[ lnI].Alignment = 5 OR ;
            laObj[ lnI].Alignment = 8 OR ;
         laObj[ lnI].Alignment = laObj[ lnI].Alignment- 1

       ENDCASE

     *-- These controls also have alignments
     CASE lcObjBaseClass $ "COMBOBOX EDITBOX LABEL SPINNER "
        IF laObj[ lnI].Alignment = 0
         laObj[ lnI].Alignment = 1
       ELSE
         laObj[ lnI].Alignment = 0
       ENDIF

     *-- Secial Grid consideration
     *-- Reverse the Columns
     CASE lcObjBaseClass = "GRID "
       LOCAL _lni, _lnj, _lnk
       _lnk = 0
       FOR _lni = laObj[ lnI].ColumnCount TO (laObj[ lnI].ColumnCount/2) STEP -1
         _lnk = _lnk+ 1
         _lnj = 1
         DO WHILE .T.
           IF  laObj[ lnI].Columns(_lnj).ColumnOrder = _lni
             laObj[ lnI].Columns(_lnj).ColumnOrder = _lnk
             EXIT
           ENDIF
           _lnj =_lnj+1
         ENDDO
       ENDFOR


     *-- Secial PageFrame consideration
     *-- Reverse the pages...
     *-- ...and don't lose the activepage.
     CASE lcObjBaseClass = "PAGEFRAME "
       LOCAL _lni, _lnj, lnActive
       lnActive = laObj[ lnI].ActivePage
       FOR _lni = 1 TO laObj[ lnI].PageCount
         _lnj = 1
         DO WHILE .T.
           IF  laObj[ lnI].Pages(_lnj).PageOrder = _lni
             laObj[ lnI].Pages(_lnj).PageOrder = 1
             EXIT
           ENDIF
           _lnj =_lnj+1
         ENDDO
       ENDFOR
       laObj[ lni].ActivePage =laObj[ lnI].PageCount- lnActive+ 1

     *-- Secial Line consideration
     *-- Lineslant!
     CASE lcObjBaseClass = "LINE "
       IF laObj[ lnI].LineSlant = "\"
         laObj[ lnI].LineSlant = "/"
       ELSE
         laObj[ lnI].LineSlant = "\"
       ENDIF

     ENDCASE

     *-- Flip the Objects about a form's vertical axis
     IF TYPE("laObj[ lnI].Parent" )= "U"
       RETURN lxRetVal
     ENDIF

     LOCAL loParent
     loParent = laObj[ lnI].Parent

     DO CASE
     *-- Do nothing
     CASE laObj[ lnI].BaseClass == "COLUMN"

     *-- Special Page consideration
     CASE loParent.BaseClass == "PAGE "
       laObj[ lnI].Left = loParent.Parent.PageWidth- laObj[ lnI].Left- laObj[ lnI].Width

     CASE TYPE("laObj[ lnI].Left" )= "U" OR ;
          TYPE("loParent.Width" )= "U"

     CASE PEMSTATUS(laObj[ lnI], "Left", 1) && Read only

     OTHERWISE

       laObj[ lnI].Left = loParent.Width- laObj[ lnI].Left- laObj[ lnI].Width
     ENDCASE

   ENDFOR
   RETURN lxRetVal
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* I N T L T R A V E R S E
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cINTLTraverse AS Custom
 oCurrent  = NULL
 cBaseclass = ''
 nObject   = 0
 oHook     = NULL

*====================================
*-- cINTLTraverse::Init( o)
*====================================
*
FUNCTION Init( toObject)
   this.oCurrent = toObject
   this.cBaseclass = this.oCurrent.BaseClass
   this.Name      = "cINTLTraverse"
   RETURN

*====================================
*-- cINTLTraverse::Next()
*====================================
*
FUNCTION Next
   LOCAL lxRetVal
   lxRetVal = NULL

   *-- Defer first to any hook
   IF !ISNULL( this.oHook)
     lxRetVal = this.oHook.Next()
     IF !ISNULL( lxRetVal)
       RETURN lxRetVal
     ELSE
       this.oHook = NULL
     ENDIF
   ENDIF

   this.nObject = this.nObject+ 1
   LOCAL lcBaseClass

   lcBaseclass = this.cBaseclass

   DO CASE
   CASE lcBaseClass = "Pageframe"

     IF this.nObject <= this.oCurrent.PageCount
       lxRetVal = this.oCurrent.Pages( this.nObject)
     ENDIF

     IF ISNULL( this.oHook) AND;
        this.oCurrent.PageCount>0 ;
        AND ! ISNULL( lxRetVal)

       this.oHook = CREATEOBJECT( "cINTLTraverse", @lxRetVal)
     ENDIF


   CASE lcBaseClass = "Commandgroup" OR ;
        lcBaseClass = "Optiongroup"
     IF this.nObject <= this.oCurrent.ButtonCount
       lxRetVal = this.oCurrent.Buttons( this.nObject)
     ENDIF

   CASE INLIST( lcBaseClass, ;
               "Container", ;
               "Column", ;
               "Control", ;
               "Page", ;
               "Form", ;
               "Toolbar" )
       IF this.nObject <= this.oCurrent.ControlCount
         lxRetVal = this.oCurrent.Controls( this.nObject)
       ELSE

         RETURN NULL
       ENDIF

     IF ! ISNULL( lxRetVal) AND ;
        UPPER( lxRetVal.Baseclass) $ ccContainers AND ;
        ISNULL( this.oHook) AND;
        this.oCurrent.ControlCount>0

       this.oHook = CREATEOBJECT( "cINTLTraverse", @lxRetVal)
       * lxRetval = this.oHook.Next()
     ENDIF

   CASE lcBaseClass = "Grid"
     IF this.nObject <= this.oCurrent.ColumnCount
       lxRetVal = this.oCurrent.Columns( this.nObject)
     ENDIF
     IF ISNULL( this.oHook) AND;
        this.oCurrent.ColumnCount>0 ;
        AND ! ISNULL( lxRetVal)
       this.oHook = CREATEOBJECT( "cINTLTraverse", @lxRetVal)
     ENDIF

   CASE lcBaseClass = "Formset"
     IF this.nObject <= this.oCurrent.FormCount
       lxRetVal = this.oCurrent.Forms( this.nObject)
     ENDIF
     IF ISNULL( this.oHook) AND;
        this.oCurrent.FormCount>0 ;
        AND ! ISNULL( lxRetVal)
       this.oHook = CREATEOBJECT( "cINTLTraverse", @lxRetVal)
     ENDIF
   ENDCASE

   *-- Skip Ignorables.
   IF !ISNULL( lxRetVal) AND ;
      TYPE( "lxRetval" )= "O" AND ;
      UPPER( lxRetval.BaseClass+ " " ) $ ccIgnoreables
      lxRetVal = this.Next()
   ENDIF

   RETURN lxRetVal

ENDDEFINE


*!*********************************************
*!
*!       Procedure: NoHot( c)
*!
*!*********************************************
Procedure NoHot
*  Author............: Steven M. Black
*} Project...........: common
*  Created...........: 05/09/92
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE NoFeatures
*)                     Feed it a string, and it strips out hotkey assignments
*)                     returning the featureless string
*] Dependencies......:
*  Calling Samples...: nohot( <ExpC>)
*  Parameter List....:
*  Returns...........:
*  Major change list.:
PARAMETERS tcPassedPrompt
PRIVATE lcRetVal
lcRetval = tcPassedPrompt
*-- This is the fastest, though not the most legible, way
*-- to code this.
*--                                     Hot Key, Ctrl Enter, Escape
RETURN STRTRAN( STRTRAN( STRTRAN( STRTRAN( STRTRAN( lcRetVal, "\<" ), "\!" ), "\?" ), ":" ), "=" )



*!*********************************************
*!
*!       Procedure: nodelims( c)
*!
*!*********************************************
PROCEDURE nodelims
*  Author............: Steven M. Black
*} Project...........: INTL
*  Created...........: 01/10/94
*  Copyright.........: ( c) Steven Black Consulting, 1994
*) Description.......: PROCEDURE nodelims
*)                     Remove leading and trailing delimiters
*] Dependencies......:
*  Calling Samples...:
*  Parameter List....:
*  Returns...........:
*  Major change list.:

PARAMETER tcToUndelim
PRIVATE jcRetVal, jcLeft, jcRight

jcRetVal = ALLTRIM( tcToUndelim)
DO WHILE LENC( jcRetVal) >=3
   jcLeft  = LEFTC(  jcRetVal, 1)
   jcRight = RIGHTC( jcRetVal, 1)
   IF ( jcLeft = '"' AND jcRight = '"') OR ;
      ( jcLeft = "'" AND jcRight = "'" ) OR ;
      ( jcLeft = "[ " AND jcRight = "]" )

      jcRetVal = SUBSTRC( jcRetVal, 2, LENC( jcRetVal)- 2)

   ELSE
      EXIT
   ENDIF

ENDDO
RETURN jcRetVal

*====================================
*-- toleft( cc[ n])
*====================================
*  Program...........: TOLEFT.PRG
*  Author............: Steven M. Black
*} Project...........: INTL
*  Created...........: 10/05/93
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: Returns characters from a character expression
*)                     to the left of a specified string
*] Dependencies......: None
*  Calling Samples...: toleft( <expC1>, <expC2>[ , <expN>])
*                      tcSearch     - The string to search for
*                      tcExpression - The string that is searched
*                      tnOccurence  - Which occurence of C1 in C2
*  Parameter List....:
*  Returns...........:
*  Major change list.:
PROCEDURE toleft
PARAMETER tcSearch, tcExpression, tnOccurence
RETURN LEFTC( tcExpression, ;
             AT_C( tcSearch, ;
                 tcExpression, ;
                 IIF( EMPTY( tnOccurence), 1, tnOccurence )) - 1)

*====================================
*-- toright( cc[ n])
*====================================
*  Program...........: TORIGHT.PRG
*  Author............: Steven M. Black
*} Project...........: Common
*  Created...........: 10/05/93
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: Returns characters from a character expression
*)                     to the right of a specified string
*] Dependencies......: None
*  Calling Samples...: toright( <expC1>, <expC2>, [ , <expN>])
*  Parameter List....: tcToSearch   - The string to search for
*                      tcExpression - The string to search within
*                      tnOccurence  - Which occurence of C1 in C2
*  Returns...........:
*  Major change list.:
PROCEDURE toright
PARAMETER tcToSearch, tcExpression, tnOccurence
PRIVATE xnsplitpos
xnsplitpos = AT_C( tcToSearch, ;
                 tcExpression, ;
                 IIF( EMPTY( tnOccurence), ;
                      1, ;
                      tnOccurence ))

RETURN IIF( xnsplitpos = 0, ;
            "", ;
            RIGHTC( tcExpression, ;
                   LENC( tcExpression)- xnsplitpos- LENC( tcToSearch)+ 1 ))


*====================================
*-- within( ccc[ n[ n]])
*====================================
*  Program...........: WITHIN.PRG
*  Author............: Steven M. Black
*} Project...........: Common
*  Created...........: 10/04/93
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: Returns string contained within two
*)                     others.  Case sensitive
*] Dependencies......:
*  Calling Samples...: within( <expC>, <expC>, <expC> [ , <expN> [ , <expN>]])
*  Parameter List....: tcExpression
*                      tcLeft
*                      tcRight
*                      tnFirstOne
*                      tnFollowing
*  Returns...........:
*  Major change list.:
PROCEDURE within
PARAMETER tcExpression, tcLeft, tcRight, tnFirstOne, tnFollowing

PRIVATE lcReturnVal, tnLeftpos
lcReturnVal = [ ]
tnLeftpos = AT_C( tcLeft, tcExpression, IIF( EMPTY( tnFirstOne), 1, tnFirstOne ))
IF tnLeftpos> 0
    tnLeftpos = tnLeftpos+ LENC( tcLeft)
    IF tnLeftpos< LENC( tcExpression)
        lcReturnVal = SUBSTRC( tcExpression, ;
                              tnLeftpos, ;
                              AT_C( tcRight, ;
                                  SUBSTRC( tcExpression, tnLeftpos), ;
                                  IIF( EMPTY( tnFollowing), 1, tnFollowing ))- 1)
    ENDIF
ENDIF
RETURN lcReturnVal

*====================================
*-- withinc( ccc[ n[ n]])
*====================================
*  Program...........: WITHINC.PRG
*  Author............: Steven M. Black
*} Project...........: Common
*  Created...........: 10/04/93
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: Returns string contained within two
*)                     others.  Case in- sensitive
*] Dependencies......:
*  Calling Samples...: within( <expC>, <expC>, <expC> [ , <expN> [ , <expN>]])
*  Parameter List....: tcExpression
*                      tcLeft
*                      tcRight
*                      tnFirstOne
*                      tnFollowing
*  Returns...........:
*  Major change list.:
PROCEDURE withinc
PARAMETER tcExpression,  tcLeft,  tcRight,  tnFirstOne,  tnFollowing
PRIVATE lcRetVal,  lnLeft
lcRetVal = [ ]
lnLeft = ATCC( tcLeft, tcExpression, IIF( EMPTY( tnFirstOne), 1, tnFirstOne ))
IF lnLeft>0
    lnLeft = lnLeft+ LENC( tcLeft)
    IF lnLeft<LENC( tcExpression)
        lcRetVal = SUBSTRC( tcExpression, ;
                           lnLeft, ;
                           ATCC( tcRight, ;
                                SUBSTRC( tcExpression, lnLeft), ;
                                IIF( EMPTY( tnFollowing), 1, tnFollowing ))- 1)
    ENDIF
ENDIF
RETURN lcRetVal


* ///////////////////////////////////
* G E N M E N U X  start
* ///////////////////////////////////
*!*********************************************
*!
*!       Procedure: intlmenu
*!
*!*********************************************
PROCEDURE intlmenu
*  Program...........: INTLMENU.PRG
*  Version...........: 3.00.003 July 6 95
*  Author............: Steven Black
*} Project...........: INTL
*  Created...........: 10/06/93
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: GENMENUX driver for INTL
*] Dependencies......:
*  Calling Samples...:
*  Parameter List....:
*  Returns...........:
*  Major change list.:

#DEFINE  ccIntlUpdate   "OFF"
#DEFINE ccItsExpression "~"
*   Translation of...
*      Menu Pads
*      Menu Bars
*      Menu Messages
*
*  CONFIG.FP/FPW/FPM/FPU Directives List
*  =====================================
*    _MNXDRV2=INTL
*    _INTLTiming=Run|Generate
*    _INTLLang=<Language>
*    _INTLUpdate=Off|On|<Path to Strings.DBF>
*
*  Memvars
*  =======
*    m._INTLLang="<Language>"
*    m._INTLTiming="Run"|"Generate"
*    m._INTLUpdate="Off"|"On"|"<Path to Strings.DBF>"
*
*
*  Procedure Snippet Directives List
*  =============================
*    *:MNXDRV2 INTL
*    *:!INTL/ *:NOINTL / *:INTL IGNORE
*
*  Comment Directives List
*  =======================
*    *:INTL IGNORE

PRIVATE jcWorkAround, lcLanguage, lcLocalize, lcStrUpd, lcStrUpdPath, ;
        llStrUpd, llExplicit


*-- Bail out if required
IF OBJTYPE = 1
  IF WORDSEARCH( "*:INTL IGNORE", "SETUP" )<> CHR( 0) OR ;
     ( TYPE( "m._INTL" )= "C" AND UPPER( m._INTL)= "OFF" )
    GO BOTTOM
    RETURN
  ENDIF
ENDIF

*-- These could well be #DEFINEs, assuming
*-- we liked those...
llExplicit = .F.
m.cr = CHR( 13)
m.lf = CHR( 10)
cr_lf = CHR( 13)+ CHR( 10)

lcItsExprChar = ccItsExpression

jcWorkAround = configfp( "IntlTiming", configfp( "_INTLTiming", [ ]))

lcLocalize = IIF( TYPE( "_INTLTiming" )= "U", ;
                  PROPER( jcWorkAround), ;
                  PROPER( _INTLTiming) )

IF EMPTY( lcLocalize) OR ! INLIST( lcLocalize, "Run", "Generate" )
  lcLocalize = "Run"
ENDIF

*-- Support "INTLLANG" and "_INTLLang".
jcWorkAround = configfp( "IntlLang", configfp( "_INTLLang", ccDefaultLanguage ))

lcLanguage = IIF( TYPE( "_INTLLang" )= "U", ;
                  PROPER( jcWorkAround), ;
                  _INTLLang )

IF EMPTY( lcLanguage)
   lcLanguage = ccDefaultLanguage
ENDIF

*-- update strings table as we *build* the run- time version.
lcStrUpd = IIF( TYPE( "_INTLUpdate" )= "U", ;
               UPPER( configfp( "_INTLUpdate", ccIntlUpdate )), ;
               UPPER( TRIM( m._INTLUpdate )))

llStrUpd = ! ( UPPER( lcStrUpd) == "OFF" )

*-- Do we want updating?
IF llStrUpd
   *-- lcStrUpd contains either "ON", "OFF", or a path to STRINGS.DBF
   *-- Is there a path?
   lcStrUpdPath = IIF( ( ! lcStrUpd == "ON" ) AND ( ! lcStrUpd == "OFF" ), ;
                       lcStrUpd, ;
                       curdir())

   *-- Do some error checking on this path
   *-- Take the strings file name out
   lcStrUpdPath = STRTRAN( lcStrUpdPath, ccDefaultStringsTable)

   *-- Ending backslash or colon
   IF ! EMPTY( lcStrUpdPath) AND ! RIGHTC( lcStrUpdPath, 1) $ ":\"
      lcStrUpdPath = lcStrUpdPath+ "\"
   ENDIF

   *-- Is there a STRINGS table there?
   IF FILE( lcStrUpdPath + ccDefaultStringsTable)
      *-- Is it the currently open strings table ( if any)
      IF USED( "STRINGS" )
         * Make sure it's the correct one
         IF ! lcStrUpdPath $ UPPER( DBF( "Strings" ))
            =warning( "INTL: Open strings file doesn't match target." + ;
           CHR( 13) + "       No update will be performed." )
            llStrUpd = .F.
         ENDIF
      ELSE
         *-- Open the strings table
         USE ( lcStrUpdPath + ccDefaultStringsTable) ORDER 1 IN 0
      ENDIF

   ELSE
      =warning( "INTL: Invalid path to STRINGS table: "+ lcStrUpdPath+ ;
           CHR( 13) + "       No update will be performed." )
      llStrUpd = .F.
   ENDIF

ENDIF

*-- Going through each part of the menu
SCAN
  IF ! EMPTY( PROMPT) ;
      AND ! "I(" $ PROMPT ;
      AND ! "\-" $ PROMPT ;
      AND ! "*:INTL IGNORE" $ UPPER( comment)

    REPLACE PROMPT WITH ["+ ]+ ImenuEnvlp( "["+ TRIM( PROMPT)+ "]" )+ [ + "]

    *{ 07/06/95 ARMACNEILL
    *{ Support for really cool language sensitive menus
    *? Crash city if invalid key, like Alt- *
    #IF .F.
    IF NOT EMPTY( keyname)
      REPLACE comment WITH comment + ;
        [ *:KEYLAB &_intlLabel]+ m.cr_lf + ;
        '*:PREDEF _intlLabel = "'+ LEFTC( keyname, ATCC( "+ ", keyname ))+ '" + ;
        SUBSTRC( TRIM( {{STRTRAN( STRTRAN( prompt, [ "+ ]), [ + "])}}), ATCC( "\<", {{STRTRAN( STRTRAN( prompt, [ "+ ]), [ + "])}})+ 2, 1) '

    ENDIF
    #ENDIF
    *{ 07/06/96  ARMACNEILL
    *{ End of changes

    *-- April 22 1997 Localize key names and key labels
    IF VAL(ItemNum)>1
      IF NOT EMPTY( keyname)
        REPLACE comment WITH comment + m.cr_lf+ ;
          [*:KEYLAB &_intlLabel]+ m.cr_lf + ;
          '*:PREDEF _INTLLabel = I("{{KeyName}}" )'
      ENDIF

      *-- April 22 1997 Localize key names and key labels
      IF NOT EMPTY( keyLabel)
        REPLACE KeyLabel WITH  ["+ _INTLLabel +"]
      ENDIF
    ENDIF



    IF ! EMPTY( message)
      jcMessage = message
      *-- We could have embedded CR_LF or just LF
      *-- ... another one of those gotchas <sigh>
      IF RIGHTC( message, 2) = m.cr_lf
        jcMessage = LEFTC( message, LENC( message) - 2)
      ELSE
        IF RIGHTC( message, 1) = m.lf
          jcMessage = LEFTC( message, LENC( message) - 1)
        ENDIF
      ENDIF

      IF oktoint( jcMessage)
         REPLACE message WITH IMenuEnvlp( jcMessage)  + ;
             IIF( RIGHTC( message, 2) = m.cr_lf, cr_lf, "" )

      ENDIF

    ENDIF
  ENDIF
ENDSCAN

RETURN


*!*********************************************
*!
*!       Procedure: IMenuEnvlp
*!
*!*********************************************
PROCEDURE IMenuEnvlp
*  Author............: SMB
*} Project...........: INTL GENSCRNX driver
*  Created...........: 02/06/1993
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE IMenuEnvlp
*)                     Wrap the passed string in a
*)                     call to I() or other calls
*] Dependencies......:
*  Calling Samples...: IMenuEnvlp( <expC>[ , <expC>[ , <expC>]])
*  Parameter List....:
*             tcPassedString - What to wrap
*             [ tcLeader]     - L.H.S., default is "I( "
*             [ tcFollower]   - R.H.S., default is ")"
*  Returns...........:
*  Major change list.: Jul 2 1993 - Can now EVAL the enveloped
*                                   string for compile- time
*                                   localization.

PARAMETER tcPassedString, tcLeader, tcFollower
PRIVATE jnNumPara, jcPrompt

IF EMPTY( tcPassedString)
   RETURN ""
ENDIF

jnNumPara = PARAMETERS()
IF jnNumpara < 3
   tcFollower = ")"
ENDIF

IF jnNumPara < 2
   tcLeader   = "I("
ENDIF

DO CASE
CASE lcLocalize = "Run"
   *-- Update the strings table?
   *-- This does it
   IF llStrUpd
      =updstrings( TRIM( Prompt), lcMnx_name ))
   ENDIF
   RETURN  tcLeader + TRIM( tcPassedString) + tcFollower

CASE lcLocalize = "Generate"
   RETURN  "[" + EVAL( tcLeader+ TRIM( tcPassedString)+ tcFollower) + "]"

ENDCASE
RETURN
* ///////////////////////////////////
* G E N M E N U  end
* ///////////////////////////////////


* ///////////////////////////////////
* C O M M O N  start
* ///////////////////////////////////

*!*********************************************
*!
*!       Procedure: OkToInt( c)
*!
*!*********************************************
PROCEDURE oktoint
*  Author............: Steven M. Black
*  Version...........: 1.2 MAR 3 1994
*} Project...........: INTL
*  Created...........: 02/06/1993
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE oktoint
*)                     Returns .T. if we should
*)                     internationalize the passed string
*)                     i.e.  it's not empy, it's text, and
*)                     it isn't I()'ed already
*] Dependencies......:
*  Calling Samples...:
*  Parameter List....:
*  Returns...........:
*  Major change list.:

PARAMETER tcToInt

  RETURN ( ! EMPTY( tcToInt )) AND ;
          NeedInt( tcToInt)


*!*********************************************
*!
*!       Procedure: NeedInt( c)
*!
*!*********************************************
PROCEDURE needint
*  Author............: Steven M. Black
*  Version...........: 1.2 Mar 12 1995
*} Project...........: INTL
*  Created...........: 02/06/1993
*  Copyright.........: ( c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE needint
*)                     Return .T. if I() is not called in
*)                     the passed string
*] Dependencies......:
*  Calling Samples...: needint( <expC>)
*  Parameter List....:
*  Returns...........:
*  Major change list.:
PARAMETER tcPassedString
RETURN ! ( LEFTC( tcPassedString, 2) = "I( " OR ( "+ I( " $ tcPassedString) OR ( "=I( " $ tcPassedString) )


*!*********************************************
*!
*!       Procedure: updstrings( cc)
*!
*!*********************************************
PROCEDURE updstrings
*  Author............: STEVEN M Black
*} Project...........: INTL
*  Created...........: 03/06/94
*  Copyright.........: ( c) Steven Black Consulting, 1994
*) Description.......: PROCEDURE updstrings
*)                     Update the strings file
*] Dependencies......:
PARAMETER tcString, tcFile
PRIVATE ALL LIKE j*

IF ! SEEK(  NOHOT( tcString), "STRINGS" )

   IF TYPE( "strings.cwhere" )<> "U"
      INSERT INTO strings ;
                  ( (ccDefaultLanguageField), cwhere) ;
           VALUES ( ALLTRIM( tcString), tcFile)
   ELSE
      INSERT INTO strings ;
                  ( (ccDefaultLanguageField )) ;
           VALUES ( ALLTRIM( tcString ))
   ENDIF

ELSE

   IF TYPE( "strings.cwhere" )<> "U" AND ( ! tcFile $ strings.cWhere)
      REPLACE strings.cWhere WITH strings.cWhere + ;
                                  CHR( 13) + CHR( 10) + ;
                                  tcFile
   ENDIF
ENDIF
RETURN


*!*********************************************
*!
*!       Procedure: trimpath
*!
*!*********************************************
FUNCTION trimpath
PARAMETERS filename, trim_ext, plattype
PRIVATE at_pos

IF EMPTY( m.filename)
  RETURN ""
ENDIF
m.at_pos=AT_C( ":", m.filename)
IF m.at_pos>0
  m.filename=SUBSTRC( m.filename, m.at_pos+ 1)
ENDIF
IF m.trim_ext
  m.filename=trimext( m.filename)
ENDIF
IF m.plattype
  m.filename=IIF( _DOS.OR._UNIX, UPPER( m.filename), LOWER( m.filename))
ENDIF
m.filename=ALLTRIM( SUBSTRC( m.filename, AT_C( "\", m.filename, ;
           MAX( OCCURS( "\", m.filename), 1))+ 1))
DO WHILE LEFTC( m.filename, 1)=="."
  m.filename=ALLTRIM( SUBSTRC( m.filename, 2))
ENDDO
DO WHILE RIGHTC( m.filename, 1)=="."
  m.filename=ALLTRIM( LEFTC( m.filename, LENC( m.filename)- 1))
ENDDO
RETURN m.filename

*!*********************************************
*!
*!       Procedure: trimext
*!
*!*********************************************
FUNCTION trimext
PARAMETERS filename,plattype
PRIVATE at_pos,at_pos2

m.at_pos=RATC('.',m.filename)
IF m.at_pos>0
  m.at_pos2=MAX(RATC('T',m.filename),RATC(':',m.filename))
  IF m.at_pos>m.at_pos2
    m.filename=LEFTC(m.filename,m.at_pos-1)
  ENDIF
ENDIF
IF m.plattype
  m.filename=IIF(_DOS.OR._UNIX,UPPER(m.filename),LOWER(m.filename))
ENDIF
RETURN ALLTRIM(m.filename)

* END trimext



*!*********************************************
*!
*!       Procedure: trimfile
*!
*!*********************************************
FUNCTION trimfile
PARAMETERS filename,plattype
PRIVATE at_pos

m.at_pos=RATC('\',m.filename)
m.filename=ALLTRIM(IIF(m.at_pos=0,m.filename,LEFTC(m.filename,m.at_pos)))
IF m.plattype
  m.filename=IIF(_DOS.OR._UNIX,UPPER(m.filename),LOWER(m.filename))
ENDIF
RETURN m.filename

* END trimfile


*!*********************************************
*!
*!       Procedure: wordsearch
*!
*!*********************************************
FUNCTION wordsearch
PARAMETERS find_str, searchfld, ignoreword, returnmline, occurance
PRIVATE var_type, memodata, memline, memline2, str_data, lastmline
PRIVATE matchcount, linecount, linecount2, at_mline, at_mline2, mline2
PRIVATE cr, lf, lf_pos, lf_pos2, at_pos

m.cr=CHR( 13)
m.lf=CHR( 10)
IF PARAMETERS()<=1
  IF TYPE( "OBJTYPE" )=="N".AND.TYPE( "CENTER" )=="L"
    m.searchfld=( OBJTYPE=1)
  ELSE
    m.searchfld=dfltfld()
  ENDIF
ENDIF
IF TYPE( "m.returnmline" )=="N"
  m.returnmline=.T.
ENDIF
DO CASE
  CASE TYPE( "m.occurance" )#"N"
    m.occurance=1
  CASE m.occurance<0
    RETURN IIF( m.returnmline, 0, CHR( 0))
ENDCASE
m.var_type=TYPE( "m.searchfld" )
DO CASE
  CASE m.var_type=="L"
    IF m.searchfld
      IF EMPTY( SETUPCODE)
        RETURN IIF( m.returnmline, 0, CHR( 0))
      ENDIF
      m.memodata=SETUPCODE
      m.searchfld="SETUPCODE"
    ELSE
      IF EMPTY( COMMENT)
        RETURN IIF( m.returnmline, 0, CHR( 0))
      ENDIF
      m.memodata=COMMENT
      m.searchfld="COMMENT"
    ENDIF
  CASE m.var_type=="C"
    m.memodata=EVALUATE( m.searchfld)
    IF EMPTY( m.searchfld)
      RETURN IIF( m.returnmline, 0, CHR( 0))
    ENDIF
  OTHERWISE
    RETURN IIF( m.returnmline, 0, CHR( 0))
ENDCASE
m.find_str=ALLTRIM( m.find_str)
IF EMPTY( m.find_str).OR.EMPTY( m.memodata).OR.m.memodata==CHR( 0)
  RETURN IIF( m.returnmline, 0, CHR( 0))
ENDIF
m.memline2=""
m.lastmline=_MLINE
m.at_mline=0
m.at_mline2=0
m.mline2=0
m.lf_pos=0
m.lf_pos2=0
m.matchcount=0
m.linecount=0
m.linecount2=0
m.memodata=m.lf+ m.memodata
_MLINE=ATCC( m.lf+ m.find_str, m.memodata)
IF _MLINE=0
  m.memodata=m.cr+ SUBSTRC( m.memodata, 2)
  _MLINE=ATCC( m.cr+ m.find_str, m.memodata)
  IF _MLINE=0
    _MLINE=m.lastmline
    RETURN IIF( m.returnmline, 0, CHR( 0))
  ENDIF
ENDIF
DO WHILE .T.
  DO CASE
    CASE m.occurance>0.AND._MLINE>=LENC( m.memodata)
      EXIT
    CASE _MLINE>=LENC( m.memodata)
      m.occurance=- 1
    OTHERWISE
      m.at_mline=_MLINE
      m.memline=ALLTRIM( MLINE( m.memodata, 1, _MLINE))
      m.lf_pos=AT_C( m.lf, SUBSTRC( m.memodata, m.at_mline+ 1, LENC( m.memline)))
      IF m.lf_pos>0
        m.memline=ALLTRIM( LEFTC( m.memline, m.lf_pos- 1))
      ENDIF
      m.str_data=SUBSTRC( m.memline, LENC( m.find_str)+ 1, 1)
      m.at_pos=ATCC( m.find_str, m.memline)
      IF m.at_pos#1.OR.( .NOT.m.ignoreword.AND..NOT.EMPTY( m.str_data))
        m.at_pos=0
        m.memodata=m.lf+ SUBSTRC( m.memodata, _MLINE)
        _MLINE=ATCC( m.lf+ m.find_str, m.memodata)
        IF _MLINE>0
          LOOP
        ENDIF
        m.memodata=m.cr+ SUBSTRC( m.memodata, 2)
        _MLINE=ATCC( m.cr+ m.find_str, m.memodata)
        IF _MLINE>0
          LOOP
        ENDIF
        IF m.occurance>0
          EXIT
        ENDIF
      ENDIF
      m.matchcount=m.matchcount+ 1
      IF m.matchcount<m.occurance.OR.m.occurance=0
        IF m.at_pos=1.AND.( m.ignoreword.OR.EMPTY( m.str_data))
          m.mline2=_MLINE
          m.at_mline2=m.at_mline
          m.memline2=m.memline
          m.lf_pos2=m.lf_pos
          m.linecount2=m.linecount
        ENDIF
        IF BETWEEN( _MLINE, 1, LENC( m.memodata))
          _MLINE=_MLINE- 2
          m.linecount=m.linecount+ _MLINE
          LOOP
        ENDIF
      ENDIF
  ENDCASE
  IF m.occurance<=0
    IF m.mline2=0
      RETURN IIF( m.returnmline, 0, CHR( 0))
    ENDIF
    _MLINE=m.mline2
    m.at_mline=m.at_mline2
    m.memline=m.memline2
    m.lf_pos=m.lf_pos2
    m.linecount=m.linecount2
    m.occurance=1
  ENDIF
  m.mline2=_MLINE
  _MLINE=m.lastmline
  m.at_pos=0
  m.str_data=SUBSTRC( m.memline, LENC( m.find_str)+ 1)
  IF m.ignoreword.AND..NOT.LEFTC( m.str_data, 1)==" "
    m.at_pos=AT_C( " ", m.str_data)
    IF m.at_pos>0
      m.str_data=SUBSTRC( m.str_data, m.at_pos+ 1)
    ENDIF
  ENDIF
  m.str_data=ALLTRIM( m.str_data)
  IF .NOT.m.returnmline
    RETURN m.str_data
  ENDIF
  m.returnmline=m.mline2- m.at_mline+ 1- IIF( m.lf_pos>0, 1, 0)
  RETURN m.at_mline+ m.linecount
ENDDO
_MLINE=m.lastmline
RETURN IIF( m.returnmline, 0, CHR( 0))
* END wordsearch
FUNCTION dfltfld

IF TYPE( "NAMECHANGE" )=="L" .AND. OBJTYPE= 1
  RETURN "SETUP"
ENDIF
IF TYPE( "OUTFILE" )=="M" .OR. TYPE( "PTXDATA" )=="M"
  RETURN "NAME"
ENDIF
RETURN "COMMENT"


* ///////////////////////////////////
* C O M M O N  end
* ///////////////////////////////////

*-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*-- INTL Revision Notes
*-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*-- New in version 3.0
*--   Multicurrency support
*--   INTL classes can be chained
*--   [ removed] Support for VFP builders
*--   Support for VFP class browser addins
*--   Single- source, multi- version
*--   Support for object INTL properties
*--   Push and Pop INTL Class settings
*--   Trailing ":" and "=" now considered spurrious.
*--
*-- New in version 2.6c
*--   INTL no longer localizes PICTURE clauses.  If you
*--   want to override this, look for the following codr
*--   and remove the comment on the REPLACE statement
*--
*--      *-- Picture clauses are localizable
*--      CASE objtype = cnSayGet AND ;
*--        objcode >= 1
*--
*--        IF oktoint( picture)
*--          * REPLACE picture WITH IntlEnvlp( picture)
*--        ENDIF
*--
*--        =Msg_Err()
*--        LOOP
*--
*--
*-- New in version 2.6
*--   New *:INTL EXPLICIT directives allow subtle same- language
*--   variants, such as ZIP and POSTAL CODE, when localizing
*--   applications with only slight differences.
*--
*--   UNIX compatibility
*--
*--   *:INTL IGNORE works in menu setup snippet
*--
*--   Bug fix: In some circumstances, *:INTL ALIGN LEFT or
*--            *:INTL ALIGN CENTER setup directives were
*--            ineffective
*--
*-- New in version 2.53
*--   _INTLLang in CONFIG.FP was not being
*--   respected for generate- time localizations. Fixed.
*--
*-- New in version 2.5
*--   Full Macintosh support
*--   INTLMENU and INTL consolidated
*--
*-- New in Version 1.35
*--   Fix:  Intl and i() now don't clobber the color of
*--         right and center- aligned text.
*--
*--   Hint: To make text on box borders behave, use
*--         a *:INTL TEXT ON LINE in the text comment. This assumes
*--         makes the text aligned left.
*--
*--   Fix:  Updating strings table at generation of run- time
*--         version now functions properly
*--
*--   Fix:  INTL sometimes didn't localize error and
*--         message strings
*--
*--   Support "*:INTLALIGN [ LEFT|RIGHT|CENTER]" ( old)
*--       and "*:INTL ALIGN [ LEFT|RIGHT|CENTER]" ( new)
*--       in the setup and comment snippets.  New method
*--       is more consistent, while still supporting the
*--       old syntax.
*--
*-- Support for object exceptions ( i.e. skip certain objects)
*--       with either
*--         _INTLExcept= <cExcptStr>     in config.fp
*--         m._INTLExcept = <cExcptStr>  generate- time memvar, overrides
*--                                      config.fp directive
*--         *:INTL EXCEPT <cExcptStr>    in setup snippet, *combined*
*--                                      with remanent of config.fp or
*--                                      memvar values.
*--       where <cExeptStr> can contain one or any of the following
*--       strings or combinations:  "SAY", "POPUP".
*--
*-- New in Version 1.34
*--   Better Demo behavior and control
*--   Misc bug fixes
*--   envlp() renamed IntlEnvlp()
*--
*-- New in Version 1.33
*--   Support for refreshing the strings table at
*--   generation of run- time programs.  A new directive,
*--   _INTLUpdate in config.fp, or a m._INTLUpdate override
*--   is either OFF or ON.
*--
*-- New in Version 1.32
*--   Workaround for FoxPro bug involving SAVE and
*--   RESTORE MACRO when certain CONFIG.FP/FPW statements
*--   are present.
*--
*--   Fixed a problem where somehow just LF terminates MESSAGE
*--   and ERROR expressions.
*--
*-- New in Version 1.31
*--   Bug fix for text to the right of CB and IB when
*--          Growth is to the left
*--
*-- New in Version 1.30
*--   *:INTL FREE comment directive allows strings to
*--          grow without regard to other objects


***********************************************************************
* E N H A N C E M E N T   R E Q U E S T S
***********************************************************************
*  SetStrings, GetStrings
*  Config which tolerances to show.          [ arm 4.25.95]
*  Add fields to strings table.              [ arm 4.25.95]
*  Localize method code.                     [ arm 4.25.95]
*  Prevent multi- instancing the INTL object. [ arm 4.26.95]
*  Conversion manager
*



***********************************************************************
* P R O P O S E D
***********************************************************************
FUNCTION warning
 PARAMETERS cmnd_str, operand

 m.warnings = m.warnings+ 1
 IF TYPE( "m.cmnd_str" )#"C"
   RETURN m.warnings
 ENDIF
 IF TYPE( "m.operand" ) == "C"
   m.operand = STRTRAN( m.operand, " ", "" )
   IF LEFTC( m.operand, 1) == "."
     m.operand = SUBSTRC( m.operand, 2)
   ENDIF
   m.cmnd_str = m.cmnd_str+ " '"+ m.operand+ "' not found"
 ENDIF
 IF TYPE( "m.fscxbase" ) == "C".AND..NOT.EMPTY( m.fscxbase)
   m.cmnd_str = m.cmnd_str+ "  [ "+ trimpath( m.fscxbase)+ "]"
 ENDIF
 WAIT CLEAR
 IF TYPE( "m.autohalt" ) == "C".AND.m.autohalt == "OFF"
   WAIT LEFTC( m.cmnd_str, 254) WINDOW NOWAIT
   RETURN m.warnings
 ENDIF
 IF _FOX26.OR..NOT.EMPTY( _FOX25REV)
   m.cmnd_str ='GENSCRNX Warning Mode - {C}ancel  {S}uspend  {I}gnore'+ CHR( 13)+ ;
              CHR( 13)+ m.cmnd_str
 ENDIF
 CLEAR TYPEAHEAD
 WAIT LEFTC( m.cmnd_str, 254) WINDOW
 DO CASE
   CASE MDOWN()
     = .F.
   CASE UPPER( CHR( LASTKEY())) == "I"
     RETURN m.warnings
   CASE UPPER( CHR( LASTKEY())) == "S"
     m.lasterror =ON( "ERROR" )
     ON ERROR
     WAIT CLEAR
     CLEAR TYPEAHEAD
     m.lastcursr = SET( "CURSOR" )
     ACTIVATE WINDOW Command
     SET ESCAPE ON
     SUSPEND
     SET ESCAPE OFF
     SET CURSOR &lastcursr
     ON ERROR &lasterror
     RETURN m.warnings
 ENDCASE
 m.autorun = "OFF"
*  DO cleanup
 CANCEL
* END warning
FUNCTION IsTag ( tcTagName, tcAlias)
  *-- Receives a tag name and an alias ( which is optional)
  *-- and returns .T. if the tag name exists in the alias.
  *-- If no alias is passed, the current alias is assumed.
  LOCAL llIsTag, ;
        lcTagFound

  IF PARAMETERS() < 2
    tcAlias = ALIAS()
  ENDIF

  IF EMPTY( tcAlias)
    RETURN .F.
  ENDIF

  llIsTag = .F.
  tcTagName = UPPER( ALLTRIM( tcTagName ))

  lnTagNum = 1
  lcTagFound = TAG( lnTagNum, tcAlias)
  DO WHILE !EMPTY( lcTagFound)
    IF UPPER( ALLTRIM( lcTagFound )) == tcTagName
      llIsTag = .T.
      EXIT
    ENDIF
    lnTagNum = lnTagNum + 1
    lcTagFound = TAG( lnTagNum, tcAlias)
  ENDDO

  RETURN llIsTag


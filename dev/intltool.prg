*  Program...........: INTLTool.PRG
*  Author............: Steven M. Black
*  Version...........: 5.0.020 February 7 2005
*} Project...........: INTL for Visual FoxPro
*  Created...........: 4/10/93
*  Copyright.........: (c) Steven Black Consulting /UP! 1993-2005
*) Description.......: Ancilary tools for the INTL Toolkit for Visual FoxPro
*-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*  Calling Samples...:
*       =>To update the Strings table
*            SET PROC TO INTLTool
*            oIterator= create("CProjectIterator","C:\VFP\Samples\Tastrade\Tastrade")
*            oVisitor= create("cIntlUpdateVisitor")
*            oIterator.Accept( oVisitor)
*-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#DEFINE ccBreakStr      " .+-/\*$#@(){}^%!=<>,;"

*///////////////////////////////////
* A B S T R A C T I T E R A T O R
*
* Abstract iterator class
*///////////////////////////////////
DEFINE CLASS cAbstractIterator AS Custom
cType= "Abstract"
Abstract_ID= "Visual INTL Iterator"   && Class signature, don't change.

*====================================
*-- cAbstractIterator::Accept( o)
*====================================
* Accept a visitor object
*
FUNCTION Accept( toPassed)
IF TYPE( "toPassed")="O" AND PEMSTATUS( toPassed, "Visit", 5)
  RETURN toPassed.Visit( THIS)
ENDIF
RETURN

*====================================
*-- cAbstractIterator::Close()
*====================================
FUNCTION Close()
RETURN .NULL.

*====================================
*-- cAbstractIterator::First()
*====================================
FUNCTION First()
RETURN .NULL.

*====================================
*-- cAbstractIterator::GetAlias(c)
*====================================
FUNCTION GetAlias(x)
RETURN .NULL.

*====================================
*-- cAbstractIterator::GetCurrentSourceID(x)
*====================================
FUNCTION GetCurrentSourceID(x)
RETURN .NULL.

*====================================
*-- cAbstractIterator::GetStructure()
*====================================
FUNCTION GetStructure(x)
RETURN .NULL.

*====================================
*-- cAbstractIterator::GetType()
*====================================
FUNCTION GetType(x)
RETURN This.cType

*====================================
*-- cAbstractIterator::Init( x)
*====================================
FUNCTION Init(x)
RETURN

*====================================
*-- cAbstractIterator::Last()
*====================================
FUNCTION LastItem()
RETURN .NULL.

*====================================
*-- cAbstractIterator::Next()
*====================================
FUNCTION Next
RETURN .NULL.

*====================================
*-- cAbstractIterator::Open(xx)
*====================================
FUNCTION Open(x,y)
RETURN .NULL.

*====================================
*-- cAbstractIterator::Prior()
*====================================
FUNCTION Prior()
RETURN .NULL.

*====================================
*-- cAbstractIterator::ProgrammaticChange()
*====================================
PROTECTED FUNCTION ProgrammaticChange()
RETURN .NULL.

*====================================
*-- cAbstractIterator::Release()
*====================================
FUNCTION Release()
RELEASE THIS
RETURN

*====================================
*-- cAbstractIterator::SetAlias(c)
*====================================
FUNCTION SetAlias(x)
RETURN .NULL.

*====================================
*-- cAbstractIterator::SetStructure()
*====================================
FUNCTION SetStructure(x)
RETURN .NULL.

ENDDEFINE


*///////////////////////////////////
* T A B L E I T E R A T O R
*
* General purpose table iterator
*///////////////////////////////////
DEFINE CLASS cTableIterator AS cAbstractIterator
PROTECTED cType, cStructure, cAlias
cType  = "Table"
cStructure = ''
cAlias = ''
cSuffix= ".DBF"
lTableOpened=.f.

*====================================
*-- cTableIterator::Close( )
*====================================
* Close the table
*
FUNCTION Close()
LOCAL llRetVal
IF USED( This.GetAlias())
  LOCAL lcAlias
  lcAlias= This.GetAlias()
  USE IN ( lcAlias)
  llRetVal= .T.
ENDIF
RETURN llRetVal

*====================================
*-- cTableIterator::Destroy( )
*====================================
FUNCTION Destroy()
IF This.lTableOpened
  This.Close()
ENDIF
RETURN

*====================================
*-- cTableIterator::First()
*====================================
* Go to top of file
*
FUNCTION First
IF ! USED( This.GetAlias())
  RETURN .F.
ENDIF
IF ! BOF( This.GetAlias())
  LOCAL lcAlias
  lcAlias= This.GetAlias()
  GO TOP IN (lcAlias)
ELSE
  RETURN .F.
ENDIF
This.ProgrammaticChange()
RETURN

*====================================
*-- cTableIterator::GetAlias()
*====================================
* Return the alias of the table being iterated
*
FUNCTION GetAlias( )
RETURN This.cAlias

*====================================
*-- cTableIterator::GetStructure( )
*====================================
* Return the name of the table being iterated
*
FUNCTION GetStructure()
RETURN This.cStructure

*====================================
*-- cTableIterator::Init( c)
*====================================
FUNCTION Init( tcPassed)

IF ISNULL( tcPassed) OR ;
   EMPTY( tcPassed) OR ;
   TYPE( "tcPassed") <> "C"
  RETURN .F.
ENDIF

*-- Parse the passed string
This.SetAlias( STRTRAN(TrimPath( tcPassed),"."))

This.SetStructure( FULLPATH(tcPassed + IIF( "." $ tcPassed, '', This.cSuffix)))

IF !USED( This.GetAlias())
  IF ! This.Open(This.GetStructure(), This.GetAlias())
    RETURN .F.
  ENDIF
ELSE
  *-- could have the same alias used, but a different file!
  IF ! This.GetStructure() $ DBF( This.GetAlias())
    RETURN .F.
  ENDIF
ENDIF
RETURN

*====================================
*-- cTableIterator::Last()
*====================================
* Go to the last record in the table
*
FUNCTION Last
IF ! USED( This.GetAlias())
  RETURN .F.
ENDIF
LOCAL lcAlias
lcAlias= This.GetAlias()
GO BOTTOM IN ( lcAlias)
This.ProgrammaticChange()
RETURN

*====================================
*-- cTableIterator::Next()
*====================================
* Go to the last next record in the table
*
FUNCTION Next
LOCAL lcAlias
lcAlias= This.GetAlias()
IF ! USED( lcAlias)
  RETURN .F.
ENDIF
IF ! EOF( lcAlias)
  SKIP IN ( lcAlias)
  IF EOF( lcAlias)
    GO BOTTOM IN ( lcAlias)
    RETURN .F.
  ENDIF
ELSE
  RETURN .F.
ENDIF
This.ProgrammaticChange()
RETURN

*====================================
*-- cTableIterator::Open( x)
*====================================
* Open the table to be iterated
*
FUNCTION Open( tcFilename, tcAlias)
IF ISNULL(tcFilename) OR ISNULL(tcAlias)
  RETURN .NULL.
ENDIF
IF EMPTY( tcFileName) OR TYPE( "tcFileName") <> "C"
  tcFileName= This.GetStructure()
  IF EMPTY( tcFileName) OR TYPE( "tcFileName") <> "C"
    RETURN .F.
  ENDIF
ENDIF
IF EMPTY( tcAlias)
  tcAlias= This.GetAlias()
  IF EMPTY( tcAlias)
    tcAlias= TRIMPATH( tcFileName, .T.)
  ENDIF
  IF EMPTY( tcAlias)
    RETURN .F.
  ENDIF
ENDIF
IF ! ("." $ tcFileName)
  tcFileName=tcFileName+ This.cSuffix
ENDIF
IF ! FILE( tcFIleName)
  RETURN .F.
ENDIF

LOCAL lnErrorFlag, lcOldError
lnErrorFlag= 0
lcOldError= ON("Error")
ON ERROR lnErrorFlag=1

USE (tcFilename) ALIAS (tcAlias) AGAIN SHARED IN 0

IF ! EMPTY( lcOldError)
  ON ERROR &lcOldError
ELSE
  ON ERROR
ENDIF
IF lnErrorFlag= 0
  This.ProgrammaticChange()
  This.lTableOpened= .T.
ENDIF
RETURN lnErrorFlag=0

*====================================
*-- cTableIterator::Prior()
*====================================
* Go to the previous record
*
FUNCTION Prior
LOCAL llRetVal, lcAlias
lcAlias= This.GetAlias()
IF ! USED( lcAlias)
  RETURN .F.
ENDIF

IF ! BOF( lcAlias)
  SKIP -1 IN ( lcAlias)
  IF BOF( lcAlias)
    LOCATE
    RETURN .F.
  ENDIF
ELSE
  RETURN .F.
ENDIF
This.ProgrammaticChange()
RETURN

*====================================
*-- cTableIterator::SetAlias( c)
*====================================
* Set the alias of the file to iterate
*
FUNCTION SetAlias( tcPassed )
This.cAlias= PROPER( tcPassed)
RETURN

*====================================
*-- cTableIterator::SetStructure( c)
*====================================
* Set the table to iterate
*
FUNCTION SetStructure( tcPassed)
This.cStructure= UPPER( tcPassed)
RETURN

ENDDEFINE


*///////////////////////////////////
* C P R O J E C T I T E R A T O R
*
* A general purpose project iterator
*///////////////////////////////////
DEFINE CLASS cProjectIterator AS cTableIterator
PROTECTED cProjectHomeDir

cProjectHomeDir= ""
cType          = "Project"
cSuffix        = ".PJX"


*====================================
*-- cProjectIterator::Init( x)
*====================================
* Parameters:
*   tcPassed: the .PJX file
*
FUNCTION Init( tcPassed)
IF TYPE( "tcPassed") <> "C"
  RETURN .F.
ENDIF

LOCAL llRetVal
*-- Adjust for missing file name suffix
IF ! "." $ tcpassed
  tcpassed=ALLTRIM(tcpassed+This.cSuffix)
ENDIF

*-- Open the table as usual
llRetVal= cTableIterator::Init( tcPassed)

*-- Set the project home directory property
IF llRetVal
  LOCAL lcAliasHandle
  lcAliasHandle=This.GetAlias()
  This.SetProjectHomeDir( &lcAliasHandle..HomeDir)
ELSE
  *? Raise an exception
ENDIF
RETURN llRetVal

*====================================
*-- cProjectIterator::GetCurrentSourceID()
*====================================
*-- Return the full path of the project element
*
FUNCTION GetCurrentSourceID()
LOCAL lcAlias
lcAlias=This.GetAlias()
RETURN FULLPATH( STRTRAN( ALLTRIM( &lcAlias..Name), CHR(0)), This.GetHomeDir())

*====================================
*-- cProjectIterator::GetHomeDir()
*====================================
* Return the project home directory
*
FUNCTION GetHomeDir()
RETURN This.cProjectHomeDir

*====================================
*-- cProjectIterator::SetprojectHomeDir( c)
*====================================
* Set the project home directory property
*
PROTECTED FUNCTION SetProjectHomeDir( tcPath)
This.cProjectHomeDir= AddBs( STRTRAN( ALLTRIM( tcPath), CHR(0)))
RETURN

ENDDEFINE


*///////////////////////////////////
* C S C X I T E R A T O R
*
* A general purpose .SCX iterator
*///////////////////////////////////
DEFINE CLASS cSCXIterator AS cTableIterator
cType          = "Form"
cSuffix        = ".SCX"
ENDDEFINE

*///////////////////////////////////
* V C X I T E R A T O R
*
* A general purpose .VCX iterator
*///////////////////////////////////
DEFINE CLASS cVCXIterator AS cTableIterator
cType          = "Visual Class Library"
cSuffix        = ".VCX"
ENDDEFINE

*///////////////////////////////////
* M N X I T E R A T O R
*
* A general purpose .MNX iterator
*///////////////////////////////////
DEFINE CLASS cMNXIterator AS cTableIterator
cType          = "Menu"
cSuffix        = ".MNX"
ENDDEFINE

*///////////////////////////////////
* C F R X I T E R A T O R
*
* A general purpose .FRX iterator
*///////////////////////////////////
DEFINE CLASS cFRXIterator AS cTableIterator
cType          = "Report"
cSuffix        = ".FRX"
ENDDEFINE

********************************************************************************

********************************************************************************

*///////////////////////////////////
*   A B S T R A C T V I S I T O R
*///////////////////////////////////
DEFINE CLASS cAbstractVisitor AS Line
oVisitee= .NULL.

FUNCTION Visit( toObj)
RETURN .NULL.

FUNCTION GetCurrentSourceID( toObj)
RETURN .NULL.

ENDDEFINE

*///////////////////////////////////
*   M E T A D A T A V I S I T O R
*///////////////////////////////////
DEFINE CLASS cMetaDataVisitor AS cAbstractVisitor
FUNCTION VisitCode( tcCode)
FUNCTION VisitCodeMemo( tcCode, tcFile)
FUNCTION VisitPropertiesMemo( tcCode, tcProperty)
FUNCTION VisitDBCRecord( loIterator)
FUNCTION VisitExpression( tcExpression)
FUNCTION VisitSCXRecord( loIterator)
FUNCTION VisitMNXRecord( loIterator)
FUNCTION VisitMetaTable( loIterator)
FUNCTION VisitPJX( toProject)
FUNCTION VisitFRXRecord( loIterator)
FUNCTION VisitFRX( loIterator)
FUNCTION VisitString( tcElement, tcOrigin)

*====================================
*-- MetaDataVisitor::PropSrch( ccn)
*====================================
*-- Search the properties memo
*
FUNCTION PropSrch( tcPropString, tcProperty, tnOccurence)
LOCAL lcRetVal, lnAtPos, lcMemoData, lcPropLine, loMemoWidth
lcRetVal=CHR(0)

lnOccurence=IIF(Empty(tnOccurence),1,tnOccurence)
lcMemoData=tcPropString

lnAtPos=atc(tcProperty,lcMemoData,lnOccurence)
IF lnAtPos>0
  loMemoWidth= CREATE("SetMemoWidth", 1024)
  m.lcPropLine= mline(lcMemoData,1,lnAtPos-1)
  lnAtPos=at("=",m.lcPropLine,1)
  IF lnAtPos> 0
    m.lcPropLine=ALLTRIM(SUBS( m.lcPropLine,lnAtPos+1))
  ELSE
    m.lcPropLine= ''
  ENDIF
ENDIF
lcRetVal=IIF(EMPTY(lcPropLine),lcRetVal, lcPropLine)
RETURN lcRetVal

ENDDEFINE

*///////////////////////////////////
*   cINTLReportTransformVisitor
*
*  This visitor is designed to audit the
*  visitee for localizeable resources
*///////////////////////////////////
DEFINE CLASS cINTLReportTransformVisitor AS cMetaDataVisitor
*====================================
*-- cINTLReportTransformVisitor::Visit( o)
*====================================
FUNCTION VISIT( toIterator)
IF ISNULL( toIterator)
  RETURN .NULL.
ENDIF
IF TYPE( "toIterator") <> "O"
  RETURN .F.
ENDIF

This.oVisitee= toIterator
toIterator.First()
LOCAL lcType
lcType= toIterator.GetType()
DO CASE
CASE PROPER( lcType)="Project"
  This.VisitPJX( toIterator)
CASE PROPER( lcType)="Report"
  This.VisitFRX( toIterator)
ENDCASE
RETURN

*====================================
*-- cINTLReportTransformVisitor::VisitPJX( o)
*====================================
FUNCTION VisitPJX( toIterator)
LOCAL lcProjItem, nAtPos, lcExt, loEngine
DO WHILE .T.
  * lcProjItem= This.GetCurrentSourceID( toIterator)
  lcProjItem= toIterator.GetCurrentSourceID()
  nAtPos= RAT(".", lcProjItem)
  IF nAtPos> 0
    lcExt= LOWER( SUBS(lcProjItem, nAtPos))
    IF lcExt == ".frx"
      loEngine= CREATEOBJECT( "cFRXIterator", lcProjItem)
      This.Visit( loEngine)
    ENDIF
  ENDIF
  IF toIterator.Next()
    LOOP
  ENDIF
  EXIT
ENDDO
RETURN

*====================================
*-- cINTLReportTransformVisitor::VisitFRX( o)
*====================================
FUNCTION VisitFRX( toIterator)
LOCAL lnOldSelect, lcAlias
lnOldSelect= SELECT()
lcAlias= toIterator.GetAlias()
SELECT ( lcAlias)
DO WHILE .T.
  IF ObjType= 5
    WAIT WINDOW toIterator.getAlias()+ " --- "+ ALLTRIM( Expr) NOWAIT
    This.VisitFRXRecord( toIterator)
  ENDIF
  IF toIterator.Next()
    LOOP
  ENDIF
  EXIT
ENDDO
SELECT (lnOldSelect)
RETURN

*====================================
*-- cINTLReportTransformVisitor::VisitFRXRecord( o)
*====================================
FUNCTION VisitFRXRecord(toIterator)
REPLACE Expr WITH "I("+ ALLTRIM( Expr)+ ")", ObjType WITH 8
RETURN

ENDDEFINE

*///////////////////////////////////
*   I N T L U p d a t e V i s i t o r
*
*  This visitor is designed to audit the
*  visitee for localizeable resources
*///////////////////////////////////
DEFINE CLASS cINTLUpdateVisitor AS cMetaDataVisitor
cOldINTLUpdate= .NULL.
cOldINTLLang= .NULL.
lINTLInstanced= .NULL.

*====================================
*-- cINTLUpdateVisitor::Init( o)
*====================================
FUNCTION INIT( toPassed)

*-- We'll need an INTL object to poke with
IF TYPE("_SCREEN.oINTL")<>"U" AND ;
   ISNULL(_SCREEN.oINTL)

  _SCREEN.RemoveObject("oINTL")
ENDIF

IF TYPE( "_SCREEN.oINTL")= "U"
  LOCAL lnError, lcError, lcConfigLang, lni
  LOCAL ARRAY laLang[1]

  lcError= ON("Error")
  lnError= 0
  ON ERROR lnError= -1

  SET PROC TO INTL ADDITIVE

  IF TYPE("_SCREEN.oINTL") = "O"
    _SCREEN.RemoveObject( "oINTL")
  ENDIF

 _SCREEN.AddObject( "oINTL", "INTL")
  IF !EMPTY( lcError)
    ON ERROR &lcError
  ELSE
    ON ERROR
  ENDIF

  IF lnError= -1
    * Raise an exception
    WAIT WIND "INTL Update Error:"+ ;
              CHR(13)+ ;
              "Problem Instantiating INTL object"
    RETURN .F.
  ENDIF
  This.lINTLInstanced= .T.
  _SCREEN.oINTL.aLang( @laLang)

  lcConfigLang=''
  FOR lni= 1 TO ALEN( laLang)
    IF LOWER( laLang[lni]) <>"original"
      lcConfigLang= laLang[lni]
      EXIT
    ENDIF
  ENDFOR

  IF !EMPTY( lcConfigLang)
    This.cOldINTLLang= _SCREEN.oINTL.GetLanguage()
    This.cOldINTLUpdate= _SCREEN.oINTL.GetUpdateMode()
    _SCREEN.oINTL.SetLanguage( lcConfigLang)
    _SCREEN.oINTL.SetUpdateMode( .T.)
  ENDIF
ENDIF
RETURN

*====================================
*-- cINTLUpdateVisitor::Destroy()
*====================================
FUNCTION Destroy
IF ! ISNULL( This.cOldINTLUpdate)
  _SCREEN.oINTL.SetUpdateMode( This.cOldINTLUpdate)
ENDIF
IF ! ISNULL( This.cOldINTLLang)
  _SCREEN.oINTL.SetLanguage( This.cOldINTLLang)
ENDIF

IF ! ISNULL( This.lINTLInstanced)
  _SCREEN.RemoveObject( "oINTL")
ENDIF
RETURN

*====================================
*-- cINTLUpdateVisitor::GetCurrentSourceID( o)
*====================================
* Return values suitable for the
* STRINGS.cWhere field
*
FUNCTION GetCurrentSourceID( toIterator)
LOCAL lcType, lcAlias
IF TYPE( "toIterator") <> "O"
  IF TYPE( "This.oVisitee")<>"O"
    RETURN ""
  ELSE
    toIterator= This.oVisitee
  ENDIF
ENDIF
lcType= toIterator.GetType()
DO CASE
CASE lcType= "Project"
   lcAlias= toIterator.GetAlias()
   RETURN FULLPATH( STRTRAN( ALLTRIM( &lcAlias..Name), CHR(0)), toIterator.GetHomeDir())

CASE lcType= "Form"
   lcAlias= toIterator.GetAlias()
   RETURN toIterator.GetStructure() + " -- "+ ALLTRIM( &lcAlias..oBjName)

CASE lcType= "Visual Class Library"
   LOCAL lcAlias, lnOldSelect, lcRetVal
   lcAlias= toIterator.GetAlias()
   *-- Kluge here: "PARENT" is a keyword, and also a field in the VCX :-\
   lnOldSelect= SELECT()
   SELECT (lcAlias)
   lcRetVal= toIterator.GetStructure() + " -- "+ ;
          IIF(!EMPTY(Parent), ALLTRIM(Parent)+".","")+ ;
          ALLTRIM(ObjName)
   SELECT (lnOldSelect)
   RETURN lcRetVal

CASE lcType= "Report" OR ;
     lcType= "Menu"
   RETURN toIterator.GetStructure()

ENDCASE
RETURN

*====================================
*-- cINTLUpdateVisitor::Visit( o)
*====================================
FUNCTION VISIT( toIterator)
IF ISNULL( toIterator)
  RETURN .NULL.
ENDIF

*-- Hook here to visit .PRG files
IF TYPE( "toIterator") = "C"
  LOCAL lnPos, lcFName
  lcFName= toIterator
  lnPos=RAT(".", lcFName)
  IF lnPos>0
    LOCAL lcExt
    lcExt= UPPER( SUBSTR( lcFName, LnPos +1))
    IF INLIST( lcExt, "PRG", "MPR", "SPR", "H")
      RETURN This.VisitCode( lcFName)
    ENDIF
  ENDIF
  RETURN .F.
ENDIF

IF TYPE( "toIterator") <> "O"
  RETURN .F.
ENDIF

This.oVisitee= toIterator
toIterator.First()
LOCAL lcType
lcType= toIterator.GetType()
DO CASE
CASE PROPER( lcType)="Project"
  This.VisitPJX( toIterator)

CASE PROPER( lcType)="Form"
  This.VisitMetaTable( toIterator, "VisitSCXRecord")

CASE PROPER( lcType)="Visual Class Library"
  This.VisitMetaTable( toIterator, "VisitSCXRecord")

CASE PROPER( lcType)="Menu"
  This.VisitMetaTable( toIterator, "VisitMNXRecord")

CASE PROPER( lcType)="Report"
  This.VisitMetaTable( toIterator, "VisitFRXRecord")

CASE PROPER( lcType)="Table"
  WAIT WINDOW toIterator.GetStructure() NOWAIT
  DO CASE

  CASE ".dbc" $ LOWER( toIterator.GetStructure())
    This.VisitMetaTable( toIterator, "VisitDBCRecord")
  ENDCASE
ENDCASE
WAIT CLEAR
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitCode( c)
*====================================
FUNCTION VisitCode( tcFileName)
IF ISNULL( tcFileName)
  RETURN .NULL.
ENDIF
IF TYPE("tcFileName") <> "C"
  RETURN .F.
ENDIF

LOCAL lcFileName, lcOldAlias, jnOldBlock
lcFileName= ALLTRIM( UPPER( tcFilename))

*-- Thanks to Mark Giesen at >MHS:MARK@AGIS for
*-- the following fix for long file names with embedded spaces.
IF " " $ lcFileName
  lcFileName= '"' + lcFilename+ '"'
ENDIF

IF !FILE( lcFileName)
  WAIT WIND NOWAIT 'File ' + ;
                   lcFileName + ;
                   ' Not Found'
ENDIF

lcOldAlias  = ALIAS()
WAIT WINDOW lcFileName NOWAIT
IF ! USED( "IntlTemp")
  *-- Create a cursor if it's not open
  jnOldBlock = SET("BLOCKSIZE")
  SET BLOCKSIZE TO 32
  CREATE CURSOR IntlTemp ;
            ( mOld M)

  SET BLOCKSIZE TO ( jnOldBlock)
  APPEND BLANK
ELSE
  SELECT IntlTemp
  REPLACE mOld WITH ""
ENDIF
APPEND MEMO mOld FROM &lcFileName OVERWRITE
This.VisitCodeMemo( mOld, lcFileName)
USE IN IntlTemp
IF !EMPTY( lcOldAlias) AND USED ( lcOldAlias)
  SELECT ( lcOldAlias)
ENDIF
WAIT CLEAR

*====================================
*-- cINTLUpdateVisitor::VisitCodeMemo( m, c)
*====================================
FUNCTION VisitCodeMemo( tmMemo, tcFileName)
PRIVATE ;
  lcFirstChars, ;
  lcLine, ;
  llIsContin, ;
  lni, ;
  loMemoWidth

loMemoWidth= CREATE("SetMemoWidth", 8000)
*-- Line counters
STORE 0 TO lnOldLineCount, lnNewLineCount

*-- Process the memo
* _MLINE = 0
lcLine= ''

* FOR lni = 1 to MEMLINES( tmMemo)
FOR lni = 1 to ALINES( laLines, tmMemo)
  *-- read the next line in the file
  * lcLine  = lcLine+ MLINE( tmMemo, 1, _MLINE)
  lcLine  = lcLine+ laLines[lni]
  *-- trim it
  lcLine = ALLTRIM( lcLine)

  *-- continuation maybe?
  IF RIGHT( lcLine, 1)= CHR(59)
    lcLine= LEFT( lcLine, LEN( lcLine)-1)+ " "
    LOOP
  ENDIF

  *-- comment maybe?
  lcFirstChars = LEFT( LTRIM( STRTRAN( lcLine,CHR(9))), 2)
  IF EMPTY( lcLine) OR lcFirstChars = "*"
    *-- we're done...  next line please.
    lcLine= ''
    LOOP
  ENDIF

  This.strproc( lcLine, "I(", "strings", tcFileName)
   * This.strproc( lcSnipLine, "MSGSVC(", "msgsvc", lcFileName)
  lcLine= ""
ENDFOR
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitDBCRecord( o)
*====================================
FUNCTION VisitDBCRecord( loIterator)
*? Not supported as of yet
RETURN

LOCAL lnOldSelect
lnOldSelect= SELECT()
SELECT( loIterator.cAlias)
IF ObjectType= "Field"
  ? "DBC Field Record", RECNO(loIterator.cAlias)
ENDIF
SELECT (lnOldSelect)
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitExpression( c)
*====================================
FUNCTION VisitExpression( tcExpression)
IF tcExpression= "'" OR ;
   tcExpression= '"' OR ;
   tcExpression= "["

  This.VisitString( TrimDelim( tcExpression))
ENDIF
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitSCXRecord( o)
*====================================
FUNCTION VisitSCXRecord( loIterator)
LOCAL lcAlias, lcProperties, lcMethods

lcAlias= loIterator.GetAlias()
lcProperties=ALLTRIM(&lcAlias..Properties)
IF ! EMPTY( lcProperties)
  This.VisitPropertiesMemo(lcProperties,"Caption")
  This.VisitPropertiesMemo(lcProperties,"ToolTipText")
  This.VisitPropertiesMemo(lcProperties,"StatusBarText")
ENDIF
lcProperties= ''

lcMethods= ALLTRIM(&lcAlias..Methods)
IF ! EMPTY( lcMethods)
  This.VisitCodeMemo( lcMethods, loIterator.GetCurrentSourceId())
ENDIF
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitPropertiesMemo( c)
*====================================
FUNCTION VisitPropertiesMemo( tcMemo, tcProperty)
LOCAL lnI, lcProp
lnI= 0
DO WHILE .T.
  lni=lni+1
  lcprop= TrimDelim(This.PropSrch(tcMemo, tcProperty, lni))
  IF lcProp=CHR(0)
    EXIT
  ENDIF
  This.VisitString( lcProp)
ENDDO
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitMNXRecord( o)
*====================================
FUNCTION VisitMNXRecord( loIterator)

* Message field, Prompt field
LOCAL lnOldSelect, lcAlias
lnOldSelect=SELECT()
lcAlias= loIterator.GetAlias()
SELECT ( lcAlias)
DO WHILE .T.
  IF ! EMPTY( Prompt) ;
    AND ! "\-" $ Prompt

    This.VisitString( TrimDelim(Prompt))

    IF ! EMPTY( Message)
      jcMessage = TrimDelim(message)
      *-- We could have embedded CR_LF or just LF
      *-- ... another one of those gotchas <sigh>
      IF RIGHT( message, 2) = CHR(13)+CHR(10)  && CR+LF
        jcMessage = LEFT( message, LEN( message) - 2)
      ELSE
        IF RIGHT( message, 1) = CHR(10)        && LF
          jcMessage = LEFT( message, LEN( message) - 1)
        ENDIF
      ENDIF

      This.VisitString( jcMessage)

    ENDIF
  ENDIF
  IF loIterator.Next()
    LOOP
  ENDIF
  EXIT
ENDDO
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitMetaTable( o)
*====================================
FUNCTION VisitMetaTable( toIterator, tcMethod)
LOCAL lcStructure
lcStructure= toIterator.GetStructure()
DO WHILE .T.
  WAIT WINDOW lcStructure NOWAIT
  LOCAL loEngine
  loEngine= CREATEOBJECT("cTableIterator", lcStructure)
  DO WHILE .T.
    LOCAL lcHold
    lcHold="This."+tcMethod
    &lcHold.( loEngine)
    IF loEngine.Next()
      LOOP
    ENDIF
    EXIT
  ENDDO
  IF toIterator.Next()
    LOOP
  ENDIF
  EXIT
ENDDO
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitPJX( o)
*====================================
FUNCTION VisitPJX( toIterator)
LOCAL lcProjItem, nAtPos, lcExt, loEngine
DO WHILE .T.
  lcProjItem= This.GetCurrentSourceID( toIterator)
  nAtPos= RAT(".", lcProjItem)
  IF nAtPos> 0
    lcExt= LOWER( SUBS(lcProjItem, nAtPos))

    DO CASE
    CASE lcExt == ".scx"
      loEngine= CREATEOBJECT( "cSCXIterator", lcProjItem)
      IF !ISNULL( loEngine) AND TYPE( "loEngine")= "O"
        loEngine.Accept( THIS)
      ENDIF

    CASE lcExt == ".vcx"
      loEngine= CREATEOBJECT( "cVCXIterator", lcProjItem)
      IF !ISNULL( loEngine) AND TYPE( "loEngine")= "O"
        loEngine.Accept( THIS)
      ENDIF

    CASE lcExt == ".mnx"
      loEngine= CREATEOBJECT( "cMNXIterator", lcProjItem)
      IF !ISNULL( loEngine) AND TYPE( "loEngine")= "O"
        * This.Visit( loEngine)
        loEngine.Accept( THIS)
      ENDIF

    CASE lcExt == ".frx"
      loEngine= CREATEOBJECT( "cFRXIterator", lcProjItem)
      * This.Visit( loEngine)
      IF !ISNULL( loEngine) AND TYPE( "loEngine")= "O"
        loEngine.Accept( THIS)
      ENDIF

    CASE lcExt == ".dbc"
      loEngine= CREATEOBJECT( "cTableIterator", lcProjItem)
      * This.Visit( loEngine)
      IF !ISNULL( loEngine) AND TYPE( "loEngine")= "O"
        loEngine.Accept( THIS)
      ENDIF


    CASE lcExt == ".prg" OR ;
         lcExt == ".spr" OR ;
         lcExt == ".mpr" OR ;
         lcExt == ".ini" OR ;
         lcExt == ".h"

      This.VisitCode( lcProjItem)
    ENDCASE
  ENDIF
  IF toIterator.Next()
    LOOP
  ENDIF
  EXIT
ENDDO
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitFRXRecord( o)
*====================================
FUNCTION VisitFRXRecord( loIterator)
LOCAL lnOldSelect, lcAlias
lnOldSelect= SELECT()
lcAlias= loIterator.GetAlias()
SELECT ( lcAlias)
IF ObjType= 5
  This.VisitExpression( Expr)
ENDIF
SELECT (lnOldSelect)
RETURN

*====================================
*-- cINTLUpdateVisitor::VisitString( c[c])
*====================================
FUNCTION VisitString( tcElement, tcOrigin)
IF ! EMPTY( tcElement) ;
   AND ! "I( " $ tcElement ;
   AND ! "\- " $ tcElement

  LOCAL lcOrigin
  lcOrigin= tcOrigin

  IF EMPTY( lcOrigin) OR TYPE ('lcOrigin')<> "C"
    lcOrigin= This.GetCurrentSourceID()
  ENDIF

  _SCREEN.oINTL.UpdateResource( tcElement, lcOrigin)

ENDIF
RETURN

*====================================
*-- cINTLUpdateVisitor::strproc( ccc)
*====================================
FUNCTION strproc( tcLine, tcLeadFunc, tcAlias, tcSource)

LOCAL ;
  lcIntlString, ;
  lcSearchKey, ;
  lnI, ;
  lnNumOcc

tcLeadFunc = UPPER( tcLeadFunc)
*-- Assume strings table by default
IF EMPTY( tcAlias)
   tcAlias = "strings"
ENDIF

*-- Check for the function leader loke "I(" or "MSGSVC("
IF tcLeadFunc $ UPPER( tcLine)
   *-- Normalize it
   lcSearchKey = STRTRAN( tcLine, LOWER( tcLeadFunc), UPPER(tcLeadFunc))
   lnNumOcc = OCCURS( tcLeadFunc, lcSearchKey)

   FOR lnI = 1 to lnNumOcc
     *-- Check that what precedes I( is a break character
     IF RIGHT( toLeft( tcLeadFunc, lcSearchKey, lni), 1) $ ccBreakStr
        lcIntlString = withinc( lcSearchKey, tcLeadFunc, ")", lni )
        lcIntlString = trimdelim( ALLTRIM( lcIntlString))
        This.VisitString( lcIntlString, tcSource)
     ENDIF
   ENDFOR
ENDIF
RETURN

ENDDEFINE

*************************************************************
* SET Classes, with thanks to Tom Rettig.
*************************************************************
DEFINE CLASS Set AS Custom  && abstract class
   PROTECTED uDefault,;
             uOldSet,;
             uNewSet,;
             lNoReset

   FUNCTION GetOld
      RETURN This.uOldSet

   FUNCTION GetNew
      RETURN This.uNewSet

   FUNCTION GetDefault
      RETURN This.uDefault

   PROTECTED PROCEDURE Init(tcSet, tuValue)
      This.uOldSet = SET(tcSet)
      This.uNewSet = NVL(tuValue, This.uDefault)
ENDDEFINE  && CLASS Set AS Custom  && abstract class

DEFINE CLASS SetMemoWidth AS Set
   uDefault = 50

   PROTECTED PROCEDURE Init(tnValue, tlNoReset)
      IF tlNoReset
         This.lNoReset = .T.
      ENDIF
      * VFP sets a maximum of 1024 when given a higher number.
      IF DoDefault("MEMOWIDTH", MIN(1024, NVL(tnValue, This.uDefault)))
         SET MEMOWIDTH TO This.uNewSet
      ELSE
         RETURN .F.
      ENDIF

   PROTECTED PROCEDURE Destroy
      IF NOT This.lNoReset
         SET MEMOWIDTH TO This.uOldSet
      ENDIF
ENDDEFINE  && CLASS SetMemoWidth AS Set

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
m.at_pos=AT( ":", m.filename)
IF m.at_pos>0
  m.filename=SUBSTR( m.filename, m.at_pos+ 1)
ENDIF
IF m.trim_ext
  m.filename=trimext( m.filename)
ENDIF
IF m.plattype
  m.filename=IIF( _DOS.OR._UNIX, UPPER( m.filename), LOWER( m.filename))
ENDIF
m.filename=ALLTRIM( SUBSTR( m.filename, AT( "\", m.filename, ;
           MAX( OCCURS( "\", m.filename), 1))+ 1))
DO WHILE LEFT( m.filename, 1)=="."
  m.filename=ALLTRIM( SUBSTR( m.filename, 2))
ENDDO
DO WHILE RIGHT( m.filename, 1)=="."
  m.filename=ALLTRIM( LEFT( m.filename, LEN( m.filename)- 1))
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

m.at_pos=RAT('.',m.filename)
IF m.at_pos>0
  m.at_pos2=MAX(RAT('T',m.filename),RAT(':',m.filename))
  IF m.at_pos>m.at_pos2
    m.filename=LEFT(m.filename,m.at_pos-1)
  ENDIF
ENDIF
IF m.plattype
  m.filename=IIF(_DOS.OR._UNIX,UPPER(m.filename),LOWER(m.filename))
ENDIF
RETURN ALLTRIM(m.filename)

*!*********************************************
*!
*!       Procedure: trimfile
*!
*!*********************************************
FUNCTION trimfile
PARAMETERS filename,plattype
PRIVATE at_pos

m.at_pos=RAT('\',m.filename)
m.filename=ALLTRIM(IIF(m.at_pos=0,m.filename,LEFT(m.filename,m.at_pos)))
IF m.plattype
  m.filename=IIF(_DOS.OR._UNIX,UPPER(m.filename),LOWER(m.filename))
ENDIF
RETURN m.filename


*!*********************************************
*!
*!       Procedure: trimdelim
*!
*!*********************************************
FUNCTION trimdelim( tcPassed, i)
LOCAL lcPassed
lcPassed= ALLTRIM( tcPassed)
i= LEN( lcPassed)- 2
IF LEFT( lcPassed, 1)== '"' AND RIGHT(lcPassed, 1)== '"'
  RETURN SUBSTR( lcPassed, 2, i)
ENDIF
IF LEFT( lcPassed, 1)== "'" AND RIGHT(lcPassed, 1)== "'"
  RETURN SUBSTR( lcPassed, 2, i)
ENDIF
IF LEFT( lcPassed, 1)== '[' AND RIGHT(lcPassed, 1)== ']'
  RETURN SUBSTR( lcPassed, 2, i)
ENDIF
RETURN lcPassed

*!*********************************************
*!
*!       Procedure: addbs
*!
*!*********************************************
FUNCTION AddBs( tcString)
LOCAL lcString
lcString= tcString
IF RIGHT( lcString,1)<> "\"
  lcString= lcString+ "\"
ENDIF
RETURN lcString


*!*********************************************
*!
*!       Procedure: within
*!
*!*********************************************
*) Description.......: Returns string contained within two
*)                     others.  Case sensitive
*] Dependencies......:
*  Calling Samples...: within( <expC>, <expC>, <expC> [,<expN> [,<expN>]])
*  Parameter List....: tcExpression
*                      tcLeft
*                      tcRight
*                      tnFirstOne
*                      tnFollowing

PROCEDURE within
PARAMETER tcExpression, tcLeft, tcRight, tnFirstOne, tnFollowing

LOCAL lcReturnVal, tnLeftpos
lcReturnVal = []
tnLeftpos = AT( tcLeft, tcExpression, IIF( EMPTY( tnFirstOne), 1, tnFirstOne))
IF tnLeftpos> 0
  tnLeftpos = tnLeftpos+LEN( tcLeft)
  IF tnLeftpos< LEN( tcExpression)
    lcReturnVal = SUBSTR( tcExpression, ;
                          tnLeftpos, ;
                          AT( tcRight, ;
                              SUBSTR( tcExpression, tnLeftpos), ;
                              IIF( EMPTY( tnFollowing), 1, tnFollowing))-1)
    ENDIF
ENDIF
RETURN lcReturnVal


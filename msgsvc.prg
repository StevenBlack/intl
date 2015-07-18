*  Program...........: MSGSVC.PRG
*************************************************************************
*                      INTL Toolkit Version
*************************************************************************
*  Version...........: 5.00.60 January 9 26 1997
*  Latest Version....: Check http://www.stevenblack.com
*  Description.......: Central Square for Messages.
*  Author............: Steven M. Black - email: steveb@stevenblack.com
*  Special thanks to.: Dale Kiefling
*                      Andrew MacNeill
*                      Alan Schwartz
*                      Drew Speedie
*
*)                     This version contains some support
*)                     functions for portability.... Take note
*)                     that I(), NOHOT(), msgevltxt() etc... are all
*)                     dups found elsewhere in INTL.
*} Project...........: INTL
*  Created...........: 09/22/93
*  Copyright.........: (c) Steven Black Consulting, 1993-1997
*)
*] Dependencies......: Assumes that if MsgSvc.DBF is open, it is
*]                     ORDER()'d properly
*
*  Calling Samples
*          Typical...: =msgsvc( "Some Key Expression")
*     String Swaps...: =msgvvc( "SomeKey", "Two~three~ain't bad"]
*  Thermometer bar...: =msgsvc( "in-bar message", "Therm", 30)
*
*  Parameter List....: tcMessageKey
*                      txVariable
*                      tnHowFar
*  Returns...........: Either Character, Numeric, or Logical depending
*                      on the cRetType field in MSGSVC.DBF
*
*  Major change list.: See at EOF()
*
*===========================================================
*  ER List for VFP (no promises)
*            Add a MESSAGE capability to MSGSVC
*            Parameter that sets the default button (ala MESSAGEBOX())?
*=============================================================
#DEFINE ccCr_Lf         CHR( 13) + CHR( 10)
#DEFINE ccParseDelim    "~"
#DEFINE FALSE           .F.
#DEFINE TRUE            .T.
#DEFINE cnSideMargin    18

*==============================================================
* If your development language is NOT English, then modify
* the lines below and specify your own native language terms
* for OK, Cancel, Yes, No, etc...
#DEFINE ccOK     "Ok"
#DEFINE ccCANCEL "Cancel"
#DEFINE ccABORT  "Abort"
#DEFINE ccRETRY  "Retry"
#DEFINE ccIGNORE "Ignore"
#DEFINE ccYES    "Yes"
#DEFINE ccNO     "No"

*===============================================================
LPARAMETERS txPara1, txPara2, txPara3

IF TYPE("_Screen.oMsgSvc")="U"
  _SCREEN.AddObject("oMsgSvc", "cMsgSvc")
ENDIF
RETURN _Screen.oMsgSvc.MsgSvc(  txPara1, txPara2, txPara3)


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c A b s t r a c t D i r e c t o r
* Version..: February 27 1997
*-- Roles of the message "director"
*--    Created by client
*--    Creates/Maintains builders
*--    Notifies builders
*--    Retrieves results from builder and displays the result
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cAbstractDirector AS Line

  * DataSession     = 1   && Public
  cDefaultBuilder = .NULL.
  *-- Supported sorts of PROPER(message ID) and the dialog builder class
  DIMENSION aBuilders[1,2]
  aBuilders[1,1]= .NULL.
  aBuilders[1,2]= "Unknown"

 *====================================
 *-- cAbstractDirector::GetBuilder()
 *====================================
 * Retrieve items from the aBuilders array
 *
  FUNCTION GetBuilder( tcFunction)
    IF ISNULL( tcFunction)
      RETURN .NULL.
    ENDIF

    LOCAL ;
          lcFunction, ;
          lnHit, ;
          lcRetVal

    lcRetVal= THIS.cDefaultBuilder
    IF TYPE( "tcFunction") <> "C"
      RETURN lcRetVal
    ENDIF

    lcFunction= PROPER( ALLTRIM( TokenNum( tcFunction, 1)))
    lnHit= ASCAN( THIS.aBuilders, lcFunction)
    IF lnHit> 0
      RETURN THIS.aBuilders[ lnHit+1]
    ELSE
      lnHit= ASCAN( THIS.aBuilders, "Default")
      IF lnHit> 0
        RETURN THIS.aBuilders[ lnHit+1]
      ELSE
        RETURN lcRetVal
      ENDIF
    ENDIF

 *====================================
 *-- cAbstractDirector::SetBuilder
 *====================================
 * Add items to the aBuilders array
 *
  FUNCTION SetBuilder( tcId, tcClass)
  LOCAL llRetVAal

  IF ISNULL( tcId) OR ISNULL( tcClass)
    RETURN .NULL.
  ENDIF

  llRetVal= .F.

  IF EMPTY( tcId) OR ;
     EMPTY( tcClass) OR ;
     TYPE( "tcId") <> "C" OR ;
     TYPE( "tcClass") <> "C"

    RETURN llRetVal
  ENDIF

  llRetVal= .T.

  LOCAL lnFound, lntemp
  lnFound=ASCAN( THIS.aBuilders, tcId)
  IF lnFound > 0
    THIS.aBuilders( lnFound+1)= ALLTRIM(tcClass)
  ELSE
    lnTemp= ALEN(aBuilders)
    DIMENSION THIS.aBuilders[ lnTemp+ 2]
    THIS.aBuilders[ lnTemp+ 1]= PROPER( tcId)
    THIS.aBuilders[ lnTemp+ 2]= PROPER( tcClass)
  ENDIF
  RETURN llRetVal

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c M e s s a g e D i r e c t o r
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cMessageDirector AS cAbstractDirector

  cDefaultBuilder= "cDialogBuilder"

  *-- The name of the message resource file.
  cTable= "MSGSVC.DBF"

  *-- The alias of the message resource file
  cAlias= "MsgSvc"

  *-- Global switch for optional icon animation on slower systems.
  *-- Set to .F. to disable all animation
  lAnimateIcons= .T.
  *-- Pointer to oINTL object.
  oINTLPointer= .NULL.

  *-- The return value from the message or dialog we will build.
  ReturnValue= ''

  *-- Supported sorts of PROPER(message ID) and the dialog builder class
  DIMENSION aBuilders[1,2]
  aBuilders[1,1]= "Default"
  aBuilders[1,2]= "cDialogBuilder"

  *-- Array of currently active dialogs.  Messages get put on this
  *-- stack so more than one message can be up at one time.
  DIMENSION aDialogs[1]
  aDialogs[1]= .NULL.

  *-- Abstract Methods of this class
  FUNCTION FindIntl(o)
  FUNCTION GetDialogHandle(c)
  FUNCTION MsgSvc( x1, x2, x3)
  FUNCTION OpenTable
  FUNCTION CloseTable

 *====================================
 *-- cAbstractDirector::cdx_msgsvc()
 *====================================
 * Reindex the resource file.
 * Named for backward compatibility with prior versions of MsgSvc.
 *
  FUNCTION cdx_msgsvc

    LOCAL lnOldArea, lcOldError, lnError

    lnError= 0
    lcOldError= ON("Error")
    ON ERROR lnError=1

    lnOldArea = SELECT(0)

    IF ! USED( THIS.cAlias)
      USE (THIS.cTable) IN 0 EXCLUSIVE
    ELSE
      SELECT ( THIS.cAlias)
    ENDIF

    IF lnError= 0
      DELETE TAG ALL
      INDEX ON UPPER( cKey) TAG cKey
    ENDIF

    SELECT (lnOldArea)
    ON ERROR &lcOldError

    RETURN lnError==0


 *====================================
 *-- cAbstractDirector::GetDialogHandle(c)
 *====================================
 * Retrieve the LIFO dialog of a given tipe
 * from the dialog stack
 *
  FUNCTION GetDialogHandle( tcType)
    LOCAL loRetVal, lnI
    loRetVal= .NULL.
    IF TYPE( "tcType")= "C"
      FOR lnI= ALEN( THIS.aDialogs) TO 1 STEP -1
        IF TYPE( "THIS.aDialogs[ lnI]") = "O" AND ;
           ! ISNULL( THIS.aDialogs[ lnI])
          IF UPPER( ALLTRIM( THIS.aDialogs[ lni].Type))== UPPER( ALLTRIM( tcType))
            loRetVal= THIS.aDialogs[ lni]
          ENDIF
        ENDIF
      ENDFOR
    ENDIF
    RETURN loRetVal

 *====================================
 *-- cAbstractDirector::I()
 *====================================
 *
  FUNCTION I( tcPassed)
    IF TYPE( "tcPassed")= "C" AND ;
       TYPE( "_SCREEN.oINTL")="O"

      RETURN _SCREEN.oINTL.I( tcPassed)
    ELSE
      RETURN tcPassed
    ENDIF

 *====================================
 *-- cAbstractDirector::Init()
 *====================================
 *
  FUNCTION INIT
    IF TYPE( "_SCREEN.oINTL")="O"
      THIS.oINTLPointer= _SCREEN.oINTL
    ELSE
      THIS.oINTLPointer= THIS
    ENDIF

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c M s g S v c ( class cMessageDirector)
*          : Concrete implementation of the abstract message director.
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cMsgSvc AS cMessageDirector

  *-- Stock builder ID's and builders
  DIMENSION aBuilders[16,2]

  aBuilders[1,1]= "Default"
  aBuilders[1,2]= "cDialogBuilder"

  aBuilders[2,1]= "Ok"
  aBuilders[2,2]= "cDialogBuilder"

  aBuilders[3,1]= "Ync"
  aBuilders[3,2]= "cDialogBuilder"

  aBuilders[4,1]= "Nyc"
  aBuilders[4,2]= "cDialogBuilder"

  aBuilders[5,1]= "Ari"
  aBuilders[5,2]= "cDialogBuilder"

  aBuilders[6,1]= "Yn"
  aBuilders[6,2]= "cDialogBuilder"

  aBuilders[7,1]= "Ny"
  aBuilders[7,2]= "cDialogBuilder"

  aBuilders[8,1]= "Text"
  aBuilders[8,2]= "cTextBuilder"

  aBuilders[9,1]= "Oc"
  aBuilders[9,2]= "cDialogBuilder"

  aBuilders[10,1]= "Rc"
  aBuilders[10,2]= "cDialogBuilder"

  aBuilders[11,1]= "Cancel"
  aBuilders[11,2]= "cDialogBuilder"

  aBuilders[12,1]= "Therm"
  aBuilders[12,2]= "cThermBuilder"

  aBuilders[13,1]= "Wait"
  aBuilders[13,2]= "cWaitWindBuilder"

  aBuilders[14,1]= "Nowait"
  aBuilders[14,2]= "cWaitWindBuilder"

  aBuilders[15,1]= "Working"
  aBuilders[15,2]= "cWorkingDialogBuilder"

  aBuilders[16,1]= "Tip"
  aBuilders[16,2]= "cTipBuilder"



 *====================================
 *-- cMsgSvc::MsgSvc
 *====================================
 * Workhorse function -- message "director"
 *
 * Interface notes (by type)
 *   CLL - Lookup in MsgSvc
 *
 *   CCL - Lookup with cookie substitution
 *
 *   CNL - Lookup [IF therm THEN setPercent(n)
 *
 *   NLL - IF EXIST( Therm) THEN LIFO therm update
 *         ELSE QuickTherm+update
 *
 *   NCL - IF EXIST( Therm )THEN LIFO therm/message update
 *         ELSE QuickTherm+update+message
 *
 *   LLL - IF EXIST( Working) THEN LIFO Working.Release()
 *
 *
  FUNCTION MsgSvc( txPassed1, txPassed2, txPassed3)

  LOCAL ;
    jcCounter, ;
    lcLangField, ;
    jcOldtalk, ;
    jcRetVal, ;
    jcVariable, ;
    jlNowait, ;
    llSwap, ;
    jnCounter, ;
    jnNumToSwap, ;
    jnWaitTime, ;
    lcFunction, ;
    lcWaitTime, ;
    llTherm, ;
    llWaitWind, ;
    llWorking, ;
    loParameterPackage, ;
    loSpecPackage, ;
    loSetExact, ;
    lcPTypes, ;
    lnI, ;
    lcI, ;
    lxPassed1, ;
    lxPassed2, ;
    lxPassed3

    lxPassed1= txPassed1
    lxPassed2= txPassed2
    lxPassed3= txPassed3

    loSetExact= CREATE("SetExact", "OFF")

    *-- Get a handle on the INTL object
    THIS.oINTLPointer= THIS.FindINTL( THIS)

    *-- Create a spec package to pass arround as a parameter
    loSpecPackage= CREATE( "cPackage")

    *-- Package the parameters
    loParameterPackage= CREATE( "cPackage")
    loSpecPackage.AddItem("Call parameters", loParameterPackage)

    *-- Place the call parameters in the package
    FOR lnI= 1 TO 3
      lcI=STR( lni,1)
      loParameterPackage.AddItem( "Parameter"+lcI, lxPassed&lci.)
    ENDFOR

    *-- loParameterPackage is already stored within loSpecPackage
    *-- so delete it now... it's no longer needed.
    loParameterPackage=.NULL.

    *-- Add INTL to the spec package
    loSpecPackage.AddItem("Intl", THIS.oINTLPointer)

    lcPTypes= TYPE("lxPassed1")+ ;
              TYPE("lxPassed2")+ ;
              TYPE("lxPassed3")

    *##########################################
    * Parameter pre-processing and dispatching
    *##########################################
    LOCAL loDialog
    DO CASE

    *-- If there is a number in the call, assume we are
    *-- dealing with a thermometer.
    CASE "N" $ lcPTypes
      *-- Assume a thermometer
      llTherm= .T.

      *-- If the numeric value is non-zero, then update
      *-- an existing therm.
      LOCAL lcZeroPos
      lcZeroPos= STR(AT("N", lcPTypes),1)

      IF lxPassed&lcZeroPos > 0
        *-- Is there a therm on the stack? If so,
        *-- update it and we're done.
        loDialog= THIS.GetDialogHandle("Therm")
        IF ! ISNULL( loDialog)
          LOCAL lni, lci, lxTest
          *-- Due to predicate dependency on nPercent,
          *-- process for percentage first
          FOR lni= 1 to 3
            lci= STR( lni,1)
            lxtest= lxPassed&lci
            IF TYPE( "lxtest")= "N"
              loDialog.SetPercent( lxTest)
              *-- ... which might kill loDialog...
              EXIT
            ENDIF
          ENDFOR

          *-- Process for Text next
          IF ! ISNULL( loDialog)
            FOR lni= 1 to 3
              lci= STR( lni,1)
              lxtest= lxPassed&lci
              IF TYPE( "lxtest")= "C"
                IF !(UPPER( lxTest)=="THERM")
                  loDialog.Settext( THIS.I(lxTest))
                ENDIF
              ENDIF
            ENDFOR
          ENDIF

          *-- Done
          RETURN
        ENDIF
      ENDIF

      *-- If we get here, then we're talking of
      *-- a new Dialog... Proceed as normal, except...
      IF lcPTypes= "NLL"
        lxPassed2= lxPassed1
        lxPassed1= "Therm Default"
      ENDIF

      *-- Swap the order if the numeric is first
      IF lcPTypes= "NC"
        LOCAL lx
        lx= lxPassed2
        lxPassed2= lxPassed1
        lxPassed1= lx
      ENDIF

    *-- Embedded cookie swapping
    CASE lcPTypes= "CC"
      llSwap = .T.


    CASE lcPTypes= "LLL"
      *-- Dismissing a Working message
      loDialog= THIS.GetDialogHandle("Working")
      IF ! ISNULL( loDialog)
         loDialog.Release( )
      ENDIF
      *-- A desired side effect, allowing msgsvc().
      *-- Open resource table.
      RETURN THIS.OpenTable()

    ENDCASE
    *###########################################

    *-- Open MsgSvc
    IF ! THIS.OpenTable()
      RETURN []
    ENDIF

    LOCAL lcOrig
    lcOrig= lxPassed1

    *-- Change to allow for Length
    IF TYPE("lxPassed1")= "C"
      lxPassed1= UPPER( LEFT( lxPassed1, 60))
    ENDIF

    *-- Default return is blank string
    jcRetVal= []

    *-- Seek the cookie in the table
    IF NOT SEEK( lxPassed1, [MsgSvc])
      IF EMPTY( lxPassed2)
        lxPassed2= []
      ENDIF

      IF ok2insert()
        INSERT INTO msgsvc ( ckey, cfunction, coriginal) ;
            VALUES ( lcOrig, ;
                     IIF(llTherm,"THERM","Ok"), ;
                     lcOrig)
      ENDIF
    ENDIF

    *-- Get the appropriate language field
    lcLangField= "Original"
    IF TYPE( "THIS.oINTLPointer")="O" AND ;
      THIS.oINTLPointer.Name <> THIS.Name

      LOCAL lcTempLang, lcTestField
      lcTempLang= THIS.oINTLPointer.GetLanguage()
      lcTestField= THIS.cAlias+ ".c" +lcTempLang

      IF TYPE( lcTestField) <> "U"
        lcLangField= THIS.oINTLPointer.GetLanguage()
      ENDIF
    ENDIF

    *-- Scatter to an object
    LOCAL loMsgSpec, lcOldAlias
    lcOldAlias=Alias()
    SELECT MsgSvc
    SCATTER NAME loMsgSpec MEMO

    loSpecPackage.AddItem( "Message spec", loMsgSpec)

    IF ! EMPTY(lcOldAlias)
      SELECT (lcOldAlias)
    ENDIF

    *== Swap the language(s)
    IF lcLangField<> "Original" AND ! EMPTY( loMsgSpec.c&lcLangField.)
      loMsgSpec.cOriginal= loMsgSpec.c&lcLangField.
    ENDIF

    *-- Cookie substitution
    IF llSwap
      DO CASE
      CASE TYPE( [lxPassed2]) = [C]
         LOCAL lcWorkPiece
         lcWorkPiece= loMsgSpec.cOriginal
         *-- We may have more than one string to swap-in
         jnNumToSwap = tokens( lxPassed2, ccParseDelim, .T.)
         FOR jnCounter = 1 TO jnNumToSwap
           jcCounter = STR(jnCounter,1)
           *-- What's our variable "word"?
           jcVariable = tokennum( lxPassed2, jnCounter, ccParseDelim, .T.)
           *-- Accept n occurences of %C% and %Cn% for first (perhaps only) swap
           DO CASE
           *-- uppercase
           CASE [%C]+jcCounter+[%] $ lcWorkPiece
             lcWorkPiece = STRTRANC( lcWorkPiece, ;
                                    [%C]+jcCounter+[%], ;
                                    jcvariable)
           *-- lowercase
           CASE [%c]+jcCounter+[%] $ lcWorkPiece
             lcWorkPiece = STRTRANC( lcWorkPiece, ;
                                    [%c]+jcCounter+[%], ;
                                    jcvariable)
           *-- uppercase
           CASE "%C%" $ UPPER(lcWorkPiece)
             lcWorkPiece = STRTRANC( lcWorkPiece, [%C%], jcvariable, 1)

           *-- lowercase
           CASE "%c%" $ UPPER(lcWorkPiece)
             lcWorkPiece = STRTRANC( lcWorkPiece, [%c%], jcvariable, 1)

           ENDCASE
         ENDFOR

         IF "%C" $ UPPER(lcWorkPiece)
           *-- Here we've stripped all tokens except unfulfilled suffix ones.  Cleanup.
           FOR jnCounter = 1 TO 9
             jcCounter = STR(jnCounter,1)
            IF !"%C" $ UPPER(lcWorkPiece)
              EXIT
            ENDIF
            DO CASE
             *-- uppercase
             CASE [%C]+jcCounter+[%] $ lcWorkPiece
               lcWorkPiece = STRTRANC( lcWorkPiece, ;
                                      [%C]+jcCounter+[%], '')
             *-- lowercase
             CASE [%c]+jcCounter+[%] $ lcWorkPiece
               lcWorkPiece = STRTRANC( lcWorkPiece, ;
                                      [%c]+jcCounter+[%], '')
             *-- uppercase
             CASE "%C%" $ UPPER(lcWorkPiece)
               lcWorkPiece = STRTRANC( lcWorkPiece, [%C%], '' )

             *-- lowercase
             CASE "%c%" $ UPPER(lcWorkPiece)
               lcWorkPiece = STRTRANC( lcWorkPiece, [%c%], '')

             ENDCASE
           ENDFOR
         ENDIF
         loMsgSpec.cOriginal= lcWorkPiece

      CASE TYPE( [lxPassed2]) = [N]
        loMsgSpec.cOriginal = STRTRAN( loMsgSpec.cOriginal, [%N%], ALLTRIM( STR( lxPassed2)))
      CASE TYPE( [lxPassed2]) = [D]
        loMsgSpec.cOriginal = STRTRAN( loMsgSpec.cOriginal, [%D%], DTOC( lxPassed2))
      ENDCASE
    ENDIF

    *-- A pipe symbol is akin to CR+LF
    loMsgSpec.cOriginal = STRTRAN( loMsgSpec.cOriginal, "|", ccCR_LF)

    *-- Mangle the animation if globally required
    IF !EMPTY(loMsgSpec.cGuiVisual) AND ;
       ! THIS.lAnimateIcons  AND ;
       ATC("Animate",loMsgSpec.cGuiVisual )> 0

       loMsgSpec.cGuiVisual= LEFT(loMsgSpec.cGuiVisual, ;
                                  ATC("Animate",loMsgSpec.cGuiVisual )-1)
    ENDIF

    *-- Pass Object to an appropriate builder
    LOCAL loMsg, lcBuilderName, lcBuilderCookie

    loMsg= .NULL.
    lcBuilderCookie= loMsgSpec.cFunction

    *-- Hook for TEXT values
    IF UPPER( lcBuilderCookie)= "TEXT"
      RETURN ALLTRIM( loMsgSpec.cOriginal)
    ENDIF

    lcBuilderName= THIS.GetBuilder( lcBuilderCookie)
    loBuilder    = CREATE( lcBuilderName)

    ************!!!!!!!!!!!!*****************
    loBuilder.Build( @loMsg, loSpecPackage)
    ************!!!!!!!!!!!!*****************

    *-- Place MessgeObject in aDialogs array
    IF !ISNULL( loMsg) AND TYPE( "loMsg")= "O"
      LOCAL lnThisDialog
      IF ALEN( THIS.aDialogs)= 1 AND ISNULL( THIS.aDialogs[1])
        lnThisDialog= 1
      ELSE
        DIMENSION THIS.aDialogs( ALEN( THIS.aDialogs)+ 1)
        lnThisDialog= ALEN( THIS.aDialogs)
      ENDIF
      THIS.aDialogs[ lnThisDialog]= loMsg
      THIS.aDialogs[ lnThisDialog].oReturnPointer= THIS

      IF EMPTY( MsgSvc.cRow + MsgSvc.cCol)
        THIS.aDialogs[ lnThisDialog].AutoCenter= .T.
      ENDIF
      *-------------------------------------------------------------------
      *-- This next line of code brought here because SetFocus() is
      *-- triggering premature visibility in VFP 5
      loBuilder.SetButtonFocus( THIS.aDialogs[ lnThisDialog], @loSpecPackage)
      *----------------------------------------------------------------

      *-- Release unneeded object references
      loBuilder.Release()
      RELEASE loMsgSpec
      loSpecPackage.Release()

      THIS.aDialogs[ lnThisDialog].SHOW()

      *-- IF the dialog was modal, it's gone
      *-- so clean up the stack
      LOCAL lnMaxDialog
      lnMaxDialog= ALEN( THIS.aDialogs)
      DO WHILE lnMaxDialog > 1 AND ISNULL( THIS.aDialogs[ lnMaxDialog])
        lnMaxDialog= lnMaxDialog-1
        DIMENSION THIS.aDialogs[ lnMaxDialog]
      ENDDO
    ELSE

      RETURN THIS.ReturnValue

    ENDIF

    RETURN IIF( lnThisDialog <= ALEN(THIS.aDialogs) AND ;
                         ! ISNULL(THIS.aDialogs[lnThisDialog]) AND ;
                         TYPE( "THIS.aDialogs[lnThisDialog]")="O"  , ;
                THIS.aDialogs[lnThisDialog],;
                THIS.ReturnValue)

 *====================================
 *-- cMsgSvc::CloseTable
 *====================================
 * Close the class's resource table
 *
  FUNCTION CloseTable
    USE IN (THIS.cAlias)

 *====================================
 *-- cMsgSvc::OpenTable
 *====================================
 * Open the class's resource table
 *
  FUNCTION OpenTable

    LOCAL lcOldError
    lcOldError= ON( "Error")
    ON ERROR lnError= -1

    *-- make sure the table's open
    IF ! USED( THIS.cAlias)
      USE LOCFILE( THIS.cTable, [DBF], [Where is ]+ THIS.cTable+[?] ) ORDER 1 IN 0
    ENDIF
    IF EMPTY( ORDER( THIS.cAlias))
      SET ORDER TO TAG cKey IN (THIS.cAlias)
    ENDIF

    ON ERROR &lcOldError

    RETURN USED( THIS.cAlias)

 *====================================
 *-- cMsgSvc::FindINTL( loDefault)
 *====================================
 * Locate INTL object
 *
  FUNCTION FindINTL( loDefault)
    LOCAL loRetVal
    loRetVal= .NULL.
    DO CASE
    CASE ISNULL( loDefault)
      * Do nothing

    CASE TYPE( "_SCREEN.oINTL")="O" AND ;
       ! ISNULL( _SCREEN.oINTL)

      loRetVal= _SCREEN.oINTL

    OTHERWISE
      IF TYPE( "loDefault")= "O"
        loRetVal= loDefault
      ELSE
        loRetVal= THIS
      ENDIF

    ENDCASE

    RETURN loRetVal

ENDDEFINE

DEFINE CLASS SetExact AS Relation
  cOldExact= .NULL.

  FUNCTION Init( tcNew)
    THIS.cOldExact= SET("Exact")
    IF TYPE( "tcNew")= "C"
      SET EXACT &tcNew
    ENDIF

  FUNCTION Destroy
    LOCAL lcString
    lcString= THIS.cOldExact
    SET EXACT &lcString

ENDDEFINE
*_BLD
*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c A b s t r a c t B u i l d e r
* Version..: Feb 27 1997
*-- Roles of a builder
*--   Created by the Director
*--   Handles build request from the director
*--   Passes it back to the director
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cAbstractBuilder AS Relation
  Visible= .F.

 *====================================
 *-- cAbstractBuilder::Build( oo)
 *====================================
 * Define the interface...
 *
  FUNCTION Build( to1, to2)
    RETURN .NULL.

 *====================================
 *-- cAbstractBuilder::Release()
 *====================================
 * Release this object
 *
  FUNCTION RELEASE
    RELEASE THIS

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c A b s t r a c t M s g B u i l d e r
* Version..: April 5 1996
*-- Roles of a builder
*--   Created by the Director
*--   Handles request from the director
*--   Creates the appropriate dialog
*--   Passes it back to the director
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cAbstractMsgBuilder AS cAbstractBuilder


  cFormClass  =  ""
  cButtonClass=  ""
  cImageClass =  ""
  cTextClass  =  ""
  cThermClass=   ""
  cTimerClass =  ""


  cTitleProp  =  "cTitle"
  cErrorProp  =  "cErrNo"
  oINTLPointer= .NULL.

  lButtons= .F.
  lText   = .F.
  lTitle  = .T.
  lImage  = .T.
  lArrange= .T.
  lTimer  = .T.

  FUNCTION AddButtons( toDialog, toSpecPackage)
  FUNCTION AddImage( toDialog, toSpecPackage)
  FUNCTION Addtext( toDialog, toSpecPackage)
  FUNCTION AddTherm( toDialog, toSpecPackage)
  FUNCTION AddTimer( toDialog, toSpecPackage)
  FUNCTION AddTitle( toDialog, toSpecPackage)
  FUNCTION Arrange( toDialogPackage)
  FUNCTION Build( toDialog, toSpecPackage)

 *====================================
 *-- cAbstractMsgBuilder::I( c)
 *====================================
 * Default I() behavior
 *
  FUNCTION I( tcPassed)
    RETURN tcPassed

 *====================================
 *-- cAbstractMsgBuilder::Init()
 *====================================
 * Constructor
 *
  FUNCTION INIT
    *-- Pointer the INTL object.
    IF TYPE("_SCREEN.oINTL")= "O" AND ! ISNULL(_SCREEN.oINTL)
      THIS.oINTLPointer= _SCREEN.oINTL
    ELSE
      THIS.oINTLPointer= THIS
    ENDIF

  FUNCTION SetReturnType(toDialog, toSpecPackage)
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c G e n e r i c M s g  B u i l d e r
* Version..: April 5 1996
* Assumes..: Image is to left of text
*            Buttons are below text
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cGenericMsgBuilder AS cAbstractMsgBuilder
  cFormClass  =  "cFrmMsgSvc"
  cButtonClass=  "cCtrCommandButton"
  cImageClass =  "cImgMsgSvc"
  cTextClass  =  "cEdtMsgSvc"
  cThermClass =  "cCtrTherm"
  cTimerClass =  "cTmrMsgSvc"

  lButtons= .T.
  lText   = .T.

 *====================================
 *-- cGenericMsgBuilder::Build(oo)
 *====================================
 *
  FUNCTION Build( toDialog, toSpecPackage)
    cAbstractMsgBuilder::Build( @toDialog, toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem("Message Spec")
    loCallParameters = ToSpecPackage.GetItem("Call parameters")

    *-- Process special cases
    *-- Go through the call parameters, looking for special
    *-- Button and Text cookies
    LOCAL lni, lci, lxtest

    FOR lni= 1 TO loCallParameters.ItemCount
      lcI= STR( lni, 1)
      lxTest= loCallParameters.GetItem( "Parameter"+lcI)

      IF TYPE("lxTest")<> "C"
        LOOP
      ELSE
        lxTest= UPPER( STRTRAN(lxTest," "))
      ENDIF
      * Changed thanks to ARM
      IF .F.
        IF "NOBUTTON" $ lxTest
          THIS.lButtons= .F.
        ENDIF

        IF "NOTEXT" $ lxTest
          THIS.lText= .F.
        ENDIF
      ENDIF
      IF "NOBUTTON" $ lxTest ;
          OR "NOBUTTON" $ UPPER( loMessageSpec.cFunction)
        THIS.lButtons= .F.
      ENDIF

      IF "NOTEXT" $ lxTest ;
          OR "NOTEXT" $ UPPER( loMessageSpec.cFunction)
        THIS.lText= .F.
      ENDIF


    ENDFOR

    *-- Create the dialog
    toDialog=CREATE( THIS.cFormClass)

    *-- Tile details
    IF THIS.lTitle
      THIS.AddTitle( @toDialog, @toSpecPackage)
    ENDIF

    *-- Add an image
    IF THIS.lImage
      THIS.AddImage( @toDialog, @toSpecPackage)
    ENDIF

    *-- Add text
    IF THIS.lText
      THIS.Addtext( @toDialog, @toSpecPackage)
    ENDIF

    *-- Thermometer
    IF "THERM" $ UPPER( loMessageSpec.cFunction)
      THIS.AddTherm( @toDialog, @toSpecPackage)
      loMessageSpec.cFunction= LEFT(loMessageSpec.cFunction, MAX(0,ATC("Therm",loMessageSpec.cFunction)-1))
    ENDIF

    *-- Buttons
    IF THIS.lButtons
      THIS.AddButtons( @toDialog, @toSpecPackage)
    ENDIF

    *-- Timer
    IF THIS.lTimer
      THIS.AddTimer( @toDialog, @toSpecPackage)
    ENDIF

    *-- Return values
    THIS.SetReturnType( @toDialog, @toSpecPackage)

    *-- Position the dialog
    THIS.PositionDialog( @toDialog, @toSpecPackage)

    *-- Set the focus if required
    *? IN VFP 5.0a this causes a  visible screen resize! Commented out 3.20.97
    * Workaround: Moved to the director
    *THIS.SetButtonFocus( @toDialog, @toSpecPackage)

 *====================================
 *-- cGenericMsgBuilder::Arrange(o)
 *====================================
 *
  FUNCTION Arrange( toDialog)
  IF ISNULL( toDialog)
    RETURN .NULL.
  ENDIF
  LOCAL lnI, lnOldMemoWidth, lnMaxWidth, lnMaxHeight, lnWidestLine, llDone

  *-- Position the graphic
  IF TYPE("toDialog.oImage")= "O"
    WITH toDialog.oImage
      .Top = 7* toDialog.nVDBU
      .Left= 7* toDialog.nHDBU
      .Visible= .T.
    ENDWITH
  ENDIF

  *-- Position the text
  IF TYPE("toDialog.oText")= "O"
    WITH toDialog.oText
      .Top = 7* toDialog.nVDBU

      IF TYPE("toDialog.oImage")="O"
        .Left= toDialog.oImage.Left+ toDialog.oImage.Width+ (4* toDialog.nHDBU)
      ELSE
        .Left= 7* toDialog.nHDBU
      ENDIF

      *-- Size the text portion
      lnOldmemoWidth= SET("MemoWidth")
      lnMaxWidth= toDialog.MaxWidth- (7* toDialog.nHDBU)- .Left
      lnMinWidth= toDialog.MinWidth- (7* toDialog.nHDBU)- .Left

      * Pick a reasonable widest maximum first Memowidth
      * 8 is the minimum memowidth in 3.0/5.0
      SET MEMOWIDTH TO MAX( 8, lnMaxWidth/ (FONTMETRIC( 6, .FontName, .FontSize)*0.85))

      DO WHILE .T.

        lnWidestLine= 0

        FOR lni= 1 TO MEMLINES( .Value)
          lnWidestLine= MAX( lnWidestLine, ;
                             TXTWIDTH( MLINE( .Value, lnI), ;
                                       .FontName, ;
                                       .FontSize)* FONTMETRIC(6, .FontName, .FontSize))
        ENDFOR

        IF lnWidestLine< lnMinWidth
          EXIT
        ENDIF

        IF lnWidestLine> lnMaxWidth
          lnScratch= MEMLINES( .Value)
          DO WHILE MEMLINES( .Value)= lnScratch AND SET("MEMOWIDTH")> 80
            SET MEMOWIDTH TO SET("MEMOWIDTH")- 1  && Slow
          ENDDO
          LOOP
        ENDIF
        EXIT
      ENDDO

      .Width = MAX( toDialog.MinWidth, lnWidestLine+ .Margin+ 3)
      .Height= 18+ ( MAX( 2, MEMLINES( .VALUE))* (FONTMETRIC(1, .FontName, .FontSize)+ ;
                                        FONTMETRIC(5, .FontName, .FontSize)))

      *-- A final pass to adjust for the case of a single line
      IF MEMLINES( .VALUE)= 1
        .TOP= .TOP + 6 * toDialog.nVDBU
      ENDIF
      .Visible= .T.
      SET MEMOWIDTH to lnOldMemoWidth
    ENDWITH
  ENDIF

  *-- Position the therm bar
  IF TYPE("toDialog.oTherm")= "O"
    WITH toDialog.oTherm
      .Top= (4* toDialog.nVDBU)  && margin before buttons
      lnMaxHeight= 0
      FOR lni= 1 TO toDialog.ControlCount
        IF toDialog.Controls( lnI).Name= .Name
          LOOP
        ENDIF
        lnMaxHeight= MAX( lnMaxHeight, toDialog.Controls( lnI).Top + toDialog.Controls( lnI).Height)
      ENDFOR
      .Top= .Top + lnMaxHeight
      .Visible= .T.
    ENDWITH
  ENDIF

  *-- Position the buttons
  IF TYPE("toDialog.oButtons")= "O"
    WITH toDialog.oButtons
      .Top= (4* toDialog.nVDBU)  && margin before buttons
      lnMaxHeight= 0
      FOR lni= 1 TO toDialog.ControlCount
        IF toDialog.Controls( lnI).Name= .Name
          LOOP
        ENDIF
        lnMaxHeight= MAX( lnMaxHeight, toDialog.Controls( lnI).Top + toDialog.Controls( lnI).Height)
      ENDFOR
      .Top= .Top + lnMaxHeight
      .Visible= .T.
    ENDWITH
  ENDIF

  IF ISNULL( toDialog)
    RETURN
  ENDIF

  *  LOCAL lnI, lnMaxHeight, lnMaxWidth
  WITH toDialog
    *-- Size the dialog
    lnMaxHeight= .MinHeight
    lnMaxWidth = .MinWidth

    FOR lni= 1 TO toDialog.ControlCount
      lnMaxHeight= MAX( lnMaxHeight, .Controls( lnI).Top+  .Controls( lnI).Height)
      lnMaxWidth = MAX( lnMaxWidth,  .Controls( lnI).Left+ .Controls( lnI).Width)
    ENDFOR

    .Height= (7* .nVDBU)+ lnMaxHeight
    .Width = 2*(7* .nHDBU)+ lnMaxWidth

    *-- Final fine-tune of thermometer
    IF TYPE("toDialog.oTherm")= "O"
      .oTherm.Left= .Width/2 - .oTherm.Width/2
    ENDIF

    *-- Final fine-tune of buttons
    IF TYPE("toDialog.oButtons")= "O"
      .oButtons.Left= .Width/2 - .oButtons.Width/2
      .oButtons.Top= MAX( .oButtons.Top, .Height- (7* .nVDBU)- .oButtons.Height)
    ENDIF

    *-- Start the timer, if there's one
    IF TYPE("toDialog.oTimer")= "O"
      .oTimer.Enabled= .T.
    ENDIF


  ENDWITH

 *====================================
 *-- cGenericMsgBuilder::AddTitle(oo)
 *====================================
 *
  FUNCTION AddTitle( toDialog, toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem("Message Spec")
    LOCAL loINTL
    loINTL= toSpecPackage.GetItem("INTL")
    IF TYPE( "loINTL") <> "O"
      loINTL= THIS
    ENDIF

    LOCAL lcTitle
    lcTitle= "loMessageSpec."+ THIS.cTitleProp

    IF TYPE( "&lcTitle") <> "U"
      lcTitle= ALLTRIM(&lcTitle)
      IF !EMPTY( lcTitle)
        *-- "\" means never a title, even in Windows
        IF ALLTRIM( lcTitle) == "\"
          RETURN
        ENDIF

        *-- Build the title, including error number...
        IF !EMPTY( lcTitle)
           toDialog.Caption = loINTL.I( ALLTRIM( lcTitle))
        ENDIF
      ENDIF
    ENDIF

    LOCAL lcError
    lcError= "loMessageSpec."+ THIS.cErrorProp
    IF TYPE( "&lcError") <> "U"
      lcError= ALLTRIM(&lcError)
      IF !EMPTY( lcError)
        toDialog.Caption = loINTL.I( strippat( stripext( SYS(16,1)))+ [ Error No ])+ ;
                           ALLTRIM( lcError)+ ;
                           [ ]+ ;
                           toDialog.Caption
      ENDIF
    ENDIF


    *-- In Windows all boxes have titles...
    IF EMPTY( toDialog.Caption)
       toDialog.Caption= loINTL.I( strippat( stripext( SYS(16,1))))
    ENDIF

 *====================================
 *-- cGenericMsgBuilder::AddImage(oo)
 *====================================
 *
  FUNCTION AddImage( toDialog, toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem( "Message spec")

    IF !EMPTY( loMessageSpec.cGuiVisual)
      toDialog.AddObject( "oImage", THIS.cImageClass, toSpecPackage)
    ENDIF

 *====================================
 *-- cGenericMsgBuilder::AddButtons(oo)
 *====================================
 *
  FUNCTION AddButtons( toDialog, toSpecPackage)
    toDialog.AddObject( "oButtons", THIS.cButtonClass, toSpecPackage)

 *====================================
 *-- cGenericMsgBuilder::AddTherm(oo)
 *====================================
 *
  FUNCTION AddTherm( toDialog, toSpecPackage)
    toDialog.AddObject( "oTherm", THIS.cThermClass, toSpecPackage)

 *====================================
 *-- cGenericMsgBuilder::Addtext(oo)
 *====================================
 *
  FUNCTION Addtext( toDialog, toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem( "Message spec")

    toDialog.AddObject( "oText", THIS.cTextClass, toSpecPackage)
    toDialog.SetText( loMessageSpec.cOriginal)
    toDialog.SetTextAlignment( loMessageSpec.cAlignment)

 *====================================
 *-- cGenericMsgBuilder::Addtimer(oo)
 *====================================
 *
  FUNCTION AddTimer( toDialog, toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem( "Message spec")
    *-- We might require a timer...
    IF VAL( loMessageSpec.cTimeout)> 0
      toDialog.AddObject( "oTimer", THIS.cTimerClass, toSpecPackage)
      toDialog.oTimer.Top= 0
      toDialog.oTimer.Left= 0      
    ENDIF

 *====================================
 *-- cGenericMsgBuilder::I(c)
 *====================================
 *
 *? Wire this to oINTL
  FUNCTION I( tcPassed)
    RETURN tcPassed

 *====================================
 *-- cGenericMsgBuilder::PositionDialog(oo)
 *====================================
 * Set the apropriate focus, if appropriate.
   FUNCTION PositionDialog(toDialog, toSpecPackage)
     LOCAL loMessageSpec
     loMessageSpec= toSpecPackage.GetItem( "Message spec")
     IF !EMPTY( loMessageSpec.cRow) OR ;
       !EMPTY( loMessageSpec.cCol)

       toDialog.TOP= VAL( loMessageSpec.cRow)
       toDialog.Left= VAL( loMessageSpec.cCol)
       toDialog.AutoCenter= .F.
     ENDIF

 *====================================
 *-- cGenericMsgBuilder::SetButtonFocus(oo)
 *====================================
 * Set the apropriate focus.
 *
  FUNCTION SetButtonFocus(toDialog, toSpecPackage)
  LOCAL loMessageSpec
  loMessageSpec= toSpecPackage.GetItem( "Message spec")
  LOCAL lnTemp
  lnTemp= VAL( loMessageSpec.cObject)

  IF lnTemp > 0 AND ;
     TYPE( "toDialog.oButtons") = "O" AND ;
       toDialog.oButtons.ControlCount >= lnTemp

    toDialog.oButtons.Controls( lnTemp).SetFocus()
 ENDIF

 *====================================
 *-- cGenericMsgBuilder::SetReturnType(oo)
 *====================================
 *
  FUNCTION SetReturnType(toDialog, toSpecPackage)
  LOCAL loMessageSpec
  loMessageSpec= toSpecPackage.GetItem( "Message spec")
  DO CASE
  CASE TYPE( "loMessageSpec.cRetType") = "U"
  CASE EMPTY( loMessageSpec.cRetType)
  CASE loMessageSpec.cRetType= "C"
    toDialog.nReturnIndex= 1

  CASE loMessageSpec.cRetType= "N"
    toDialog.nReturnIndex= 2

  CASE loMessageSpec.cRetType= "L"
    toDialog.nReturnIndex= 3

  CASE loMessageSpec.cRetType= "M"
    toDialog.nReturnIndex= 4

  ENDCASE

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c D i a l o g B u i l d e r
* Version..: March 31 1996
* Assumes..: Image is to left of text
*            Buttons are below text
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cDialogBuilder AS cGenericMsgBuilder
 *====================================
 *-- cDialogBuilder::Build(oo)
 *====================================
  FUNCTION BUILD(toDialog, toSpecPackage)
    cGenericMsgBuilder::Build( @toDialog, @toSpecPackage)
    THIS.Arrange( @toDialog)
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c W o r k i n g D i a l o g B u i l d e r
* Version..: March 31 1996
* Assumes..: Image is to left of text
*            Buttons are below text
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cWorkingDialogBuilder AS cGenericMsgBuilder
  cFormClass  =  "cFrmWorkingMsgSvc"
  lButtons= .T.
  lText   = .T.

 *====================================
 *-- cWorkingDialogBuilder::Build(oo)
 *====================================
  FUNCTION BUILD(toDialog, toSpecPackage)
    cGenericMsgBuilder::Build( @toDialog, @toSpecPackage)
    THIS.Arrange( @toDialog)
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T h e r m B u i l d e r
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cThermBuilder AS cGenericMsgBuilder
  cFormClass  =  "cFrmThermMsgSvc"
  lButtons= .T.
  lText   = .T.

 *====================================
 *-- cThermBuilder::Build(oo)
 *====================================
  FUNCTION BUILD(toDialog, toSpecPackage)
    cGenericMsgBuilder::Build( @toDialog, @toSpecPackage)
    LOCAL loMessageSpec, loCallParameters, lxSecondParameter
    loMessageSpec    = toSpecPackage.GetItem("Message Spec")
    loCallParameters = ToSpecPackage.GetItem("Call parameters")

    *-- Go through the call parameters, looking for Numerics
    LOCAL lni, lci, lxtest
    FOR lni= 1 TO loCallParameters.ItemCount
      lcI= STR( lni, 1)
      lxTest= loCallParameters.GetItem( "Parameter"+lcI)
      IF TYPE( "lxTest")= "N"
        toDialog.SetPercent( lxtest)
      ENDIF
      DO CASE
      CASE TYPE("lnText")<> "C"
      CASE AT( "NOBUTTON", UPPER( STRTRAN(lxTest," "))) > 0
        toDialog.oButtons.Visible= .F.
      CASE AT( "BUTTON", UPPER( STRTRAN(lxTest," "))) > 0
        toDialog.oButtons.Visible= .T.
        LOOP
      ENDCASE
    ENDFOR

    THIS.Arrange( @toDialog)

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T i p B u i l d e r
* Version..: April 3 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cTipBuilder AS cGenericMsgBuilder
  cFormClass  =  "cFrmTODMsgSvc"
  lButtons= .F.
  lText   = .F.
  lTitle  = .F.
  lImage  = .F.
  lTimer  = .F.
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c W a i t W i n d B u i l d e r
* Version..: April 3 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cWaitWindBuilder AS cAbstractMsgBuilder
* Compatibility note: Schemes not supported anymore since DOS is, er, dead.
 *====================================
 *-- cWaitWindBuilder::Build(oo)
 *====================================
  FUNCTION Build( toDialog, toSpecPackage)
    cAbstractMsgBuilder::Build( @toDialog, @toSpecPackage)
    LOCAL llWaitWind, jlNoWait, llWorking, jcRetVal, jnWaitTime, loMessageSpec

    lcWaitTime   = []
    jnWaitTime   = 0
    loMessageSpec= toSpecPackage.GetItem("Message spec")

    IF [WAIT ] $ loMessageSpec.cFunction
       llWaitWind = .t.

       IF [NOWAIT] $ loMessageSpec.cFunction
          jlNowait = .T.
       ENDIF

       IF !EMPTY( loMessageSpec.cTimeOut)
          lcWaitTime =  loMessageSpec.cTimeOut
       ENDIF

       jnWaitTime = VAL( lcWaitTime)
       *-- We could have a WAIT/NOWAIT *and* a TIMEOUT
       *-- In this case, make the TIMEOUT prevail
       IF jnWaitTime > 0
          jlNowait = .f.
       ENDIF

    ENDIF

    IF ! EMPTY( loMessageSpec.cErrno)
        loMessageSpec.cOriginal = strippat( stripext( SYS(16,1))) + ;
                     I( [ Error No ]) + ;
                     ALLTRIM( loMessageSpec.cerrno) + ;
                     [ ] + ;
                     loMessageSpec.cOriginal
    ENDIF
    IF jnWaitTime > 0
      THIS.waitwind( loMessageSpec.cOriginal, jnWaitTime)
    ELSE
      THIS.waitwind( loMessageSpec.cOriginal, jlNowait)
    ENDIF
   jcRetVal = []


 *====================================
 *-- cWaitWindBuilder::WaitWind(cx)
 *====================================
  FUNCTION WaitWind( tcPhrase, txwaiting)
    *  Parameter List....: tcPhrase  - What goes in the WAIT window
    *                      txWaiting - Numeric = TIMEOUT
    *                                  .T.= Wait, .F. = NoWait

    *-- you only need to pass the first one...

    PRIVATE ;
       jcAnswerVal, ;
       jcWaitType, ;
       jlWaiting, ;
       jnWaiting

    jnWaiting  = 0
    jlWaiting  = .F.
    jcWaitType = TYPE( "txWaiting")

    DO CASE
    CASE jcWaitType = "N"
       jnWaiting = txwaiting
    CASE jcWaitType = "L"
       jlWaiting = ! txwaiting
    ENDCASE

    jcAnswerVal= []
    jcPosition = []    && Roughed-in for the next release
    jcNowait   = []
    jcTime     = []

    DO CASE
    CASE jlWaiting                                        && defaults to .f. if nothing was passed...
       jcAnswerVal= "TO jcAnswerVal"
    CASE jnWaiting > 0
       jcAnswerVal= "TO jcAnswerVal"
       jcTime     = "TIME jnWaiting"
    OTHERWISE
       jcNoWait= "NOWAIT"
    ENDCASE

    WAIT WINDOW tcPhrase &jcPosition. &jcNowait. &jcTime. &jcAnswerVal.

    RETURN jcAnswerVal
ENDDEFINE

*_FRM

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c F r m M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cfrmMsgSvc AS FORM
  * Base class for message services forms
  * ER's
  *   ? HalfHeightCaption option
  *   ? No title bar option
  *   ? ShowTips option
  *   ? Help option

*-- Standard form properties
  *  MinHeight= 84
  MinHeight  = 15
  MinWidth   = 175
  MaxWidth   = SYSMETRIC(1) * 0.62
  AlwaysOnTop= .T.
  AutoCenter = .T.
  BackColor  = RGB( 192, 192, 192)
  BorderStyle= 0 && no border
  Caption    = "MsgSvc"
  Closable   = .T.
  ColorSource= 4 && Windows control panel
  ControlBox = .F.
  Desktop    = .T.
  FontName   = "MS Sans Serif"
  FontSize   = 8
  FontBold   = .F.
  Height     = 175
  MaxButton  = .F.
  ShowWindow = 1
  MinButton  = .F.
  WindowType = 1   && Modal

*-- Custom properties
  oReturnPointer= .NULL.
  nReturnIndex = 1
  Type = "Dialog"
  nHDBU=  6   && Horizontal Dialog Base Units
  nVDBU=  8   && Vertical and


  *-- Initialize the return array
  DIMENSION aRetVals[4]  && For button return values

 *====================================
 *-- cFrmMsgSvc::Init
 *====================================
  FUNCTION Init
    *-- Initialize array (bin) of return values
    THIS.aRetVals[1]= ''   && Original language caption
    THIS.aRetVals[2]= 0    && Button number
    THIS.aRetVals[3]= .F.  && First button
    THIS.aRetVals[4]= 0    && MESSAGEBOX()-Compatible

    *-- Horizontal and Vertical dialog base units
    THIS.nHDBU = FONTMETRIC(6, THIS.FontName, THIS.FontSize)/4
    THIS.nVDBU = FONTMETRIC(1, THIS.FontName, THIS.FontSize)/8

 *====================================
 *-- cFrmMsgSvc::GetPercent( n)
 *====================================
 *
  FUNCTION GetPercent
    RETURN 0

 *====================================
 *-- cFrmMsgSvc::SetPercent( n)
 *====================================
 *
  FUNCTION SetPercent( tnPassed)
  IF TYPE( "THISFORM.oImageTimer")= "O" AND ;
    THISFORM.oImageTimer.Enabled

    *-- Force an image animation
    THISFORM.oImageTimer.Timer()

  ENDIF

 *====================================
 *-- cFrmMsgSvc::SetText( c)
 *====================================
 *
  FUNCTION SetText( tcPassed)
  IF TYPE( "THIS.oText") = "O" AND ;
     TYPE( "tcPassed") = "C"

     THIS.oText.Value= ALLTRIM(tcPassed)
  ENDIF

 *====================================
 *-- cFrmMsgSvc::SetAlignment( c)
 *====================================
 *
  FUNCTION SetTextAlignment( tcPassed)
  IF TYPE( "THIS.oText") = "O" AND ;
     TYPE( "tcPassed") = "C"
    tcPassed= UPPER( tcPassed)
    DO CASE
    CASE EMPTY (tcPassed) or tcPassed= "L"
      THIS.oText.Alignment= 0
    CASE tcPassed= "C"
      THIS.oText.Alignment= 2
    CASE tcPassed= "R"
      THIS.oText.Alignment= 1
    ENDCASE
  ENDIF

 *====================================
 *-- cFrmMsgSvc::Unload
 *====================================
 * Pass the return values up the tree
  FUNCTION Unload
    IF ! ISNULL( THIS.oReturnPointer)
      THIS.oReturnPointer.ReturnValue= THIS.aRetVals[ THIS.nReturnIndex]
    ENDIF
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c F r m T h e r m M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cFrmThermMsgSvc AS cFrmMsgSvc
  Height= 100
  Width = 300
  WindowType= 0  && Modeless

*-- Custom properties
  Type= "Therm"
  cFirstLine= ""


 *====================================
 *-- cFrmThermMsgSvc::GetPercent( n)
 *====================================
 *
  FUNCTION GetPercent( tnPassed)
    IF TYPE( "THIS.oTherm") = "O" AND ;
       !ISNULL( THIS.oTherm)

       RETURN THIS.oTherm.GetPercent( )
    ELSE
      RETURN 0
    ENDIF


 *====================================
 *-- cFrmThermMsgSvc::SetPercent( n)
 *====================================
 *
  FUNCTION SetPercent( tnPassed)
    IF TYPE( "THIS.oTherm") = "O" AND ;
       !ISNULL( THIS.oTherm)

       cFrmMsgSvc::SetPercent()

       THIS.oTherm.SetPercent( tnPassed)
       IF TYPE( "THIS.oButtons")= "O"
         THIS.oButtons.Controls(1).SetFocus()
       ENDIF
    ENDIF

 *====================================
 *-- cFrmThermMsgSvc::SetText( c)
 *====================================
 *
  FUNCTION SetText( tcPassed)
    IF ISNULL( tcPassed)
      RETURN .NULL.
    ENDIF
    IF TYPE( "tcPassed") <> "C"
      RETURN .F.
    ENDIF
    Local lcPassed
    lcPassed= ALLTRIM( tcPassed)

    IF THIS.GetPercent()= 0
      THIS.cFirstLine= lcPassed
      tcPassed= ccCR_LF
    ENDIF


    IF ! EMPTY( THIS.cFirstLine)
      lcPassed= THIS.cFirstLine+ ;
                ccCR_LF+ ;
                tcPassed
    ENDIF

    cFrmMsgSvc::SetText( lcPassed)



ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c F r m W o r k i n g M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cFrmWorkingMsgSvc AS cFrmMsgSvc
  Height    = 100
  Width     = 300
  WindowType= 0  && Modeless
  Type      = "Working"
ENDDEFINE



*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c F R M T O D M s g S v c
* Version..: April 3 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cFrmTODMsgSvc AS cfrmMsgSvc
  ScaleMode  = 3
  Height     = 230
  Width      = 427
  DoCreate   = .T.
  AutoCenter = .T.
  BackColor  = RGB(192,192,192)
  BorderStyle= 2
  Caption    = "Tip Of The Day"
  FontSize   = 8
  KeyPreview= .T.
  MaxButton  = .F.
  MaxWidth   = 430
  MinButton  = .F.
  WindowType = 1
  WindowState= 0

  *-- The active workarea prior to TOD
  noldarea= 1
  Name    = "Tip"
  Type    = "Tip Of The Day"

  *-- Did we open TOD?
  ltodopened = .F.

  *-- Do we want random tips
  lRandomTip= .T.

  ADD OBJECT shape1 AS shape WITH ;
    BackColor    = RGB(192,192,192), ;
    Height       = 185, ;
    Left         = 12, ;
    Top          = 12, ;
    Width        = 301, ;
    SpecialEffect= 0, ;
    Name         = "Shape1"

  ADD OBJECT shape2 AS shape WITH ;
    BackColor  = RGB(255,255,255), ;
    BorderStyle= 1, ;
    Height     = 171, ;
    Left       = 19, ;
    Top        = 19, ;
    Width      = 287, ;
    Name       = "Shape2"

  ADD OBJECT cmdOk AS cTODButton WITH ;
    Top     = 12, ;
    Left    = 325, ;
    Caption = ccOK, ;
    Name    = "cmdOk"


  ADD OBJECT cmdNextTip AS cTODButton WITH ;
    Top     = 41, ;
    Left    = 325, ;
    Caption = "\<Next Tip...", ;
    Name    = "cmdNextTip"


  ADD OBJECT cmdMoreTips AS cTODButton WITH ;
    Top     = 80, ;
    Left    = 325, ;
    Caption = "\<More Tips", ;
    Name    = "cmdMoreTips"


  ADD OBJECT cmdHelp AS cTODButton WITH ;
    Top     = 109, ;
    Left    = 325, ;
    Caption = "\<Help", ;
    Name    = "cmdHelp"


  ADD OBJECT check1 AS checkbox WITH ;
    Top      = 203, ;
    Left     = 12, ;
    Height   = 18, ;
    Width    = 300, ;
    FontName = "MS Sans Serif", ;
    FontSize = 8, ;
    FontBold = .F., ;
    BackColor= RGB(192,192,192), ;
    Caption  = "\<Show Tips at Startup", ;
    Name     = "Check1"

  ADD OBJECT edit1 AS editbox WITH ;
    BackColor    = RGB(255,255,255), ;
    BackStyle    = 0, ;
    BorderStyle  = 0, ;
    FontName     = "MS Sans Serif", ;
    FontSize     = 8, ;
    FontBold     = .F., ;
    Height       = 122, ;
    Left         = 25, ;
    Top          = 66, ;
    Width        = 275, ;
    SpecialEffect= 1, ;
    ReadOnly     = .T., ;
    ScrollBars   = 0, ;
    TabStop      = .F., ;
    Name         = "Edit1"


  ADD OBJECT label1 AS clblMsgSvc WITH ;
    FontName= "MS Sans Serif", ;
    FontSize= 8, ;
    FontBold= .T., ;
    Caption = "Did you know...", ;
    Height  = 18, ;
    Left    = 65, ;
    Top     = 38, ;
    Width   = 200, ;
    Name    = "Label1"


  ADD OBJECT image1 AS image WITH ;
    Picture= "tod.bmp", ;
    Height = 40, ;
    Left   = 24, ;
    Top    = 24, ;
    Width  = 39, ;
    Name   = "Image1"


  PROCEDURE Load
    THIS.nOldArea=SELECT()
    SELECT *, " " AS Temp FROM MsgSvc ;
      INTO CURSOR __Tod ;
     WHERE UPPER(ALLTRIM(cKey)) == "TIP"


  FUNCTION Init
    THIS.Edit1.BackStyle=1
    IF THIS.lRandomTip
      LOCAL lnRecords
      =RAND(-1)
      lnRecords=RAND()* RECCOUNT("__Tod")

      SKIP INT(lnRecords) IN __Tod
      IF EOF()
        GO BOTTOM
      ENDIF
    ENDIF
    IF TYPE( "_SCREEN.oINTL")= "O"
      _Screen.oINTL.Localize(THIS)
      LOCAL lcTemp, lcField
      lcTemp=_Screen.oINTL.GetLanguage()
      lcField= "__Tod.c"+lcTemp
      IF EMPTY( &lcField)
        lcTemp= "Original"
      ENDIF
      THIS.Edit1.Controlsource= "__Tod.c"+lcTemp
    ELSE
      THIS.Edit1.Controlsource= "__TOD.cOriginal"
    ENDIF

    *? Kluge
    THIS.Edit1.BackStyle=0

  PROCEDURE Destroy
    SELECT (THIS.nOldArea)
    IF THIS.lTODOpened
      USE IN __Tod
    ENDIF


  PROCEDURE KeyPress( nKeyCode, nShiftAltCtrl)
  *-- Respond intelligently on escape
  IF nKeycode= 27
    THIS.Release()
  ENDIF

  PROCEDURE cmdOk.Click
    RELEASE THISFORM


  PROCEDURE cmdNextTip.Click
    LOCAL lnOldArea
    lnOldArea= SELECT()
    SELECT __Tod
    SKIP
    IF EOF()
      LOCATE
    ENDIF
    SELECT (lnOldArea)
    THISFORM.REFRESH


  PROCEDURE cmdMoreTips.Click
    =MsgSvc("Subclass to suit")

  PROCEDURE check1.Interactivechange( tnIndex)
    =MsgSvc("Subclass to suit")

  PROCEDURE cmdHelp.Click
    Help

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c P a c k a g e
*          : This class serves as a holder (package) of other objects so
*          : that several object references can be passed as one object.
*
* Pattern  : COMPOSITE
*
* Version..: April 6 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cPackage AS Relation  && A lightweight.
  DIMENSION aItems[1,2]
  Itemcount= 0
  cClassId= "Package"

 *====================================
 *-- cPackage::Init
 *====================================
 *
 *
  FUNCTION Init
    THIS.aItems[1]= .NULL.
    THIS.aItems[2]= .NULL.

 *====================================
 *-- cPackage::GetItem(c)
 *====================================
 * Return the first item of a given type.
 *
  FUNCTION GetItem( tcType)
    IF ISNULL( tcType)
      RETURN .NULL.
    ENDIF

    LOCAL lcRetVal, lcType, lnHit

    lcRetVal= []
    IF TYPE( "tcType") <> "C"
      RETURN lcRetVal
    ENDIF

    lcType= PROPER( ALLTRIM( tcType))
    lnHit= ASCAN( THIS.aItems, lcType)
    IF lnHit> 0
      RETURN THIS.aItems[ lnHit+1]
    ELSE
      RETURN lcRetVal
    ENDIF

 *====================================
 *-- cPackage::AddItem(cx)
 *====================================
 * Add an item to this package
 *
  FUNCTION AddItem( tcType, txItem )
    LOCAL llRetVAal

    IF ISNULL( tcType) OR ISNULL( txItem)
      RETURN .NULL.
    ENDIF

    llRetVal= .F.

    IF EMPTY( tcType) OR ;
       TYPE( "tcType") <> "C"

      RETURN llRetVal
    ENDIF

    LOCAL lnFound, lntemp
    lnFound=ASCAN( THIS.aItems, tcType)
    IF lnFound > 0
      THIS.aItems( lnFound+1)= txItem
    ELSE
      IF ISNULL( THIS.aItems[ 1])
        lnTemp= 0
      ELSE
        lnTemp= ALEN( THIS.aItems)
        DIMENSION THIS.aItems[ lnTemp+ 2]
      ENDIF
      THIS.aItems[ lnTemp+ 1]= PROPER( tcType)
      THIS.aItems[ lnTemp+ 2]= txItem
    ENDIF
    llRetVal= .T.
    THIS.ItemCount= IIF(ISNULL( THIS.aItems[1]), 0 , ALEN( THIS.aItems,1))
  RETURN llRetVal

 *====================================
 *-- cPackage::Release()
 *====================================
 * Clean up this item and release
 *
 FUNCTION Release
  LOCAL lni
  FOR lni= 1 TO ALEN(THIS.aItems,1)
    IF TYPE("THIS.aItems[lni, 2].cClassId") <> "U" AND THIS.aItems[lni, 2].cClassId= THIS.cClassId
      THIS.aItems[lni, 2].Release()
    ENDIF
    THIS.aItems[lni, 1]= .NULL.
    THIS.aItems[lni, 2]= .NULL.
  ENDFOR

  RELEASE THIS

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T O D B u t t o n
*          : Tip of the day button
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cTODButton AS CommandButton
  Height  = 24
  Width   = 90
  FontName= "MS Sans Serif"
  FontSize= 8
  FontBold= .F.
  Name    = "TipOfTheDayButton"
ENDDEFINE

*
*-- EndDefine: tod
**************************************************



*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c C m d M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cCmdMsgSvc AS CommandButton
  Height= 23
  FontName= "MS SANS Serif"
  FontSize= 8
  FontBold= .F.
  DIMENSION aRetVals[4]

 *====================================
 *-- cCmdMsgSvc::Init(o)
 *====================================
 *
 FUNCTION Init( toSpecPackage)
    THIS.aRetVals[1]= ''   && Original language caption
    THIS.aRetVals[2]= 0    && Button number
    THIS.aRetVals[3]= .F.  && First button
    THIS.aRetVals[4]= 0    && MESSAGEBOX()-Compatible

 *====================================
 *-- cCmdMsgSvc::
 *====================================
 * Pass the return values up the tree
  FUNCTION Click
    THISFORM.aRetVals[1]= THIS.aRetVals[1]  && Original language caption
    THISFORM.aRetVals[2]= THIS.aRetVals[2]  && Button number
    THISFORM.aRetVals[3]= THIS.aRetVals[3]  && First button
    THISFORM.aRetVals[4]= THIS.aRetVals[4]  && MESSAGEBOX()-Compatible

    THISFORM.Release()

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T m r M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cTmrMsgSvc AS Timer
 *====================================
 *-- cTmrMsgSvc::Init
 *====================================
 *
 Name= "cTmrMsgSvc"
 Top = 0
 Left= 0

 FUNCTION Init( toSpecPackage)
   LOCAL loMessageSpec
   loMessageSpec= toSpecPackage.GetItem( "Message spec")
   IF VAL( loMessageSpec.cTimeout) > 0
     THIS.Interval= VAL( loMessageSpec.cTimeout)*1000
   ENDIF

 FUNCTION Timer
   THISFORM.Release()

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c A b s t r a c t M s g C o n t a i n e r
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cAbstractMsgContainer AS Container
  oINTLPointer= .NULL.
  FUNCTION Init( o)
  FUNCTION SetPercent(n)
  FUNCTION GetPercent(n)
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c L i n T h e r m
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cLinTherm AS Line
  BorderColor = RGB( 192, 192, 192)
  BorderWidth = 2
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c C t r T h e r m
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cCtrThermBar AS cAbstractMsgContainer
  BackColor    = RGB( 0, 0, 255)
  BackStyle    = 1     && 1= Opaque
  BorderWidth  = 0
  SpecialEffect= 1     && 1= Sunken


ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c C t r T h e r m
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cCtrTherm AS cAbstractMsgContainer
  BackColor    = RGB( 192, 192, 192)
  BackStyle    = 1     && 1= Opaque
  BorderWidth  = 1
  Height= 20
  SpecialEffect= 1     && 1= Sunken
  Width= 285

  nBorder= 3
  nPercent= 0
 *====================================
 *-- cCtrTherm::Init(o)
 *====================================
 * Build the thermometer bar illusion
  FUNCTION INIT( toSpecPackage)
  THIS.AddObject( "oLabel", "cThermBarLblMsgSvc")
  WITH THIS.oLabel
    .Top  = (THIS.Height/2)- (.Height/2) +1
    .Left = (THIS.Width/2)- (TXTWIDTH(.Caption, .FontName, .FontSize)/2)
    .Visible= .T.
  ENDWITH

  THIS.AddObject( "oTherm", "cCtrThermBar")

  WITH THIS.oTherm
    .Top= THIS.nBorder
    .Left=THIS.nBorder
    .Height= THIS.Height-(2*THIS.nBorder)
    .Visible      = .T.
    .AddObject( "oLabel", "cThermBarLblMsgSvc")
    WITH .oLabel
      .Top  = THIS.Height/2- .Height/2- THIS.nBorder
      .ForeColor= RGB(255,255,255)
      .Visible= .F.
    ENDWITH
  ENDWITH

  *-- Lay down therm bar separators
  LOCAL lnI, lcI
  THIS.oLabel.Visible= .F.
  FOR lnI= 1 TO 19
    lcI=ALLTRIM(STR( lni,2))
    THIS.AddObject("oSep"+lcI, "cLinTherm")
    WITH THIS.oSep&lcI.
      .Visible=.T.
      .Left= lni*THIS.Width/20
      .Height= THIS.Height- 5
      .Width= 0
      .Top= 3
    ENDWITH
  ENDFOR

  IF THIS.SpecialEffect= 1  && Sunken
    THIS.AddObject("H3D", "Line")
    WITH THIS.H3D
      .BorderColor=RGB(255,255,255)
      .BorderWidth=1
      .Top=THIS.Height-1
      .Left=1
      .Width=THIS.Width-2
      .Height=0
      .Visible= .T.
    ENDWITH
    THIS.AddObject("V3D", "Line")
    WITH THIS.V3D
      .BorderColor=RGB(255,255,255)
      .BorderWidth=1
      .Top= 1
      .Left= THIS.Width-1
      .Width=0
      .Height=THIS.height-1
      .Visible= .T.
    ENDWITH
  ENDIF

  THIS.RefreshTherm()

 *====================================
 *-- cCtrTherm::GetPercent(n)
 *====================================
  FUNCTION GetPercent( tnPercent)
    RETURN THIS.nPercent

 *====================================
 *-- cCtrTherm::SetPercent(n)
 *====================================
  FUNCTION SetPercent( tnPercent)
    DO CASE
    CASE TYPE( "tnPercent") <> "N"
    CASE tnPercent >= 100
      THISFORM.Release()
    CASE tnPercent < 0
      THIS.nPercent = 0
    OTHERWISE
      THIS.nPercent= tnPercent
    ENDCASE
    THIS.RefreshTherm()

 *====================================
 *-- cCtrTherm::RefreshTherm()
 *====================================
  FUNCTION RefreshTherm
   THIS.oLabel.Caption=ALLTRIM(STR(INT(THIS.nPercent),3))+ " %"
   WITH THIS.oTherm
     .Width= MAX(0, MIN(THIS.nPercent,100))/100 * (THIS.Width - (2*THIS.nBorder))
     WITH .oLabel
       .Caption=ALLTRIM(STR(THIS.nPercent,3,0))+ " %"
       .Left = THIS.Width/2- TXTWIDTH(.Caption, ;
                                     .FontName, ;
                                     .FontSize)/2 ;
                          - THIS.nBorder-1

       .ForeColor= RGB(255,255,255)
       .Visible= .F.
     ENDWITH
   ENDWITH
ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c C t r C o m m a n d B u t t o n
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cCtrCommandButton AS cAbstractMsgContainer
 BackStyle= 0
 BorderWidth= 0
 Spacing= 6
 ButtonClass= "cCmdMsgSvc"

 DIMENSION aTrans[5]
 DIMENSION aOriginal[5]
 FUNCTION I( tcPassed)
   RETURN tcPassed

 *====================================
 *-- cCtrCommandButton::Init(oo)
 *====================================
 FUNCTION Init( toSpecPackage)

   *-- Analyse toSpecPackage
   THIS.ButtonSpec( toSpecPackage)
   *-- localize the captions
   *-- Create Buttons
   THIS.AddButtons( THISFORM)

 *====================================
 *-- cCtrCommandButton::ButtonSpec(o)
 *====================================
 FUNCTION ButtonSpec( toSpecPackage)
 LOCAL lcFunction, lcUppFunction, loMessageSpec
 loMessageSpec=toSpecPackage.GetItem( "Message spec")
 LOCAL loINTL
 loINTL= toSpecPackage.GetItem( "INTL")
 IF TYPE( "loINTL") <> "O"
   loINTL= THIS
 ENDIF

 lcFunction= loMessageSpec.cFunction

 IF EMPTY( lcFunction)
   lcFunction= ccOK
 ENDIF
 lcUppFunc = UPPER( ALLTRIM(lcFunction))

 DO CASE
 CASE lcUppFunc== [OK]
    DIMENSION THIS.aOriginal[1], THIS.aTrans[1]
    THIS.aOriginal[1]= ccOK
    THIS.aTrans[1]   = loINTL.I( [\!\<OK])

 CASE lcUppFunc== [OC]
    DIMENSION THIS.aOriginal[2], THIS.aTrans[2]
    THIS.aOriginal[1]= ccOK
    THIS.aOriginal[2]= ccCANCEL
    THIS.aTrans[1]   = loINTL.I( [\!\<] + ccOK )
    THIS.aTrans[2]   = loINTL.I( [\?\<] + ccCANCEL )

   CASE lcUppFunc== [YN]
    DIMENSION THIS.aOriginal[2], THIS.aTrans[2]
    THIS.aOriginal[1]= ccYES
    THIS.aOriginal[2]= ccNO
    THIS.aTrans[1]   = loINTL.I( [\!\<] + ccYES)
    THIS.aTrans[2]   = loINTL.I( [\<] + ccNO)

   CASE lcUppFunc== [NY]
    DIMENSION THIS.aOriginal[2], THIS.aTrans[2]
    THIS.aOriginal[1]= ccNO
    THIS.aOriginal[2]= ccYES
    THIS.aTrans[1]   = loINTL.I( [\<] + ccNO)
    THIS.aTrans[2]   = loINTL.I( [\?\<] + ccYES)

   CASE lcUppFunc== [YNC]
    DIMENSION THIS.aOriginal[3], THIS.aTrans[3]
    THIS.aOriginal[1]= ccYES
    THIS.aOriginal[2]= ccNO
    THIS.aOriginal[3]= ccCancel
    THIS.aTrans[1]   = loINTL.I( [\!\<]+ ccYes)
    THIS.aTrans[2]   = loINTL.I( [\<]+ ccNO)
    THIS.aTrans[3]   = loINTL.I( [\?\<]+ ccCANCEL)

   CASE lcUppFunc== [NYC]
    DIMENSION THIS.aOriginal[3], THIS.aTrans[3]
    THIS.aOriginal[1]= ccNO
    THIS.aOriginal[2]= ccYES
    THIS.aOriginal[3]= ccCANCEL
    THIS.aTrans[1]   = loINTL.I( [\!\<] + ccNO)
    THIS.aTrans[2]   = loINTL.I( [\<]+ ccYES)
    THIS.aTrans[3]   = loINTL.I( [\?\<]+ ccCANCEL)

   CASE lcUppFunc== [RC]
    DIMENSION THIS.aOriginal[2], THIS.aTrans[2]
    THIS.aOriginal[1]= ccRETRY
    THIS.aOriginal[2]= ccCANCEL
    THIS.aTrans[1]   = loINTL.I( [\!\<]+ ccRETRY)
    THIS.aTrans[2]   = loINTL.I( [\?\<]+ ccCANCEL)

   CASE lcUppFunc== [ARI]
    DIMENSION THIS.aOriginal[3], THIS.aTrans[3]
    THIS.aOriginal[1]= ccABORT
    THIS.aOriginal[2]= ccRETRY
    THIS.aOriginal[3]= ccIGNORE
    THIS.aTrans[1]   = loINTL.I( [\!\<] + ccABORT)
    THIS.aTrans[2]   = loINTL.I( [\<]+ ccRETRY)
    THIS.aTrans[3]   = loINTL.I( [\<] + ccIGNORE)

   CASE lcUppFunc== [CANCEL]
    DIMENSION THIS.aOriginal[1], THIS.aTrans[1]
    THIS.aOriginal[1]= ccCANCEL
    THIS.aTrans[1]   = loINTL.I( [\?\<]+ ccCANCEL)

   CASE lcUppFunc== [WORKING]
    llWorking= .T.

   * CASE [;] $ lcUppFunc
   OTHERWISE
    lcHoldVar = []
    jnNumButtons = tokens( lcFunction, [;], .T.)
    DIMENSION THIS.aOriginal[jnNumButtons], THIS.aTrans[jnNumButtons]
    FOR jni = 1 TO jnNumButtons
       jcThisWord      = tokennum( lcFunction, jni, [;], .T.)   && *? added .T. on a hunch
       THIS.aOriginal[jnI] = jcThisWord
       THIS.aTrans[jnI] = loINTL.I( jcThisword)
       lcHoldVar       = lcHoldVar + THIS.aTrans[jnI] + [;]
    ENDFOR
    *-- Eliminate trailing ";"
    lcFunction = LEFT( lcHoldVar, LEN( lcHoldVar) - 1 )
 ENDCASE

 *====================================
 *-- cCtrCommandButton::AddButtons(oo)
 *   Add buttons to the button container
 *====================================
 FUNCTION AddButtons( toDialog)
   LOCAL lnI, lcI, loTemp, laTemp, lcMsgBox
   lcMsgBox= SPACE(9)+          ;
             PADR( ccOK,    10)+ ;
             PADR( ccCANCEL,10)+ ;
             PADR( ccABORT, 10)+ ;
             PADR( ccRETRY, 10)+ ;
             PADR( ccIGNORE,10)+ ;
             PADR( ccYES,   10)+ ;
             PADR( ccNO,    10)

   FOR lnI= 1 TO ALEN( THIS.aTrans)
     IF TYPE("THIS.aTrans[ lnI]")= "L"
       EXIT
     ENDIF
     lcName= "cmd"+STR( lnI,1)
     THIS.AddObject( lcName, THIS.ButtonClass)
     loTemp= THIS.&lcName.
     loTemp.Caption= NoOldHot(THIS.aTrans[ lnI])
     *-- Add button characteristics
     loTemp.aRetVals[1]= NOHOT(THIS.aOriginal[ lnI]) && Original language caption
     loTemp.aRetVals[2]= lnI                  && Button number
     loTemp.aRetVals[3]= (lnI=1)              && First button?
     loTemp.aRetVals[4]= INT(AT(loTemp.aRetVals[1], lcMsgBox)/10) && MessageBox() compatibility

     *-- Load ESC & Ctrl-Enter properties here
     IF "\!" $ THIS.aTrans[lnI]
       loTemp.Default=.T.
     ENDIF

     IF "\?" $ THIS.aTrans[lnI]
       loTemp.Cancel=.T.
     ENDIF
   ENDFOR

   *-- Lay them out
   LOCAL lnSpacing, lnHeight, lnMaxWidth, lnAvgWidth
   lnMaxWidth= 0
   lnAvgWidth= 0
   IF THIS.ControlCount > 0
     lnAvgWidth= FONTMETRIC(6, ;
                            THIS.Controls(1).FontName, ;
                            THIS.Controls(1).FontSize)

     *-- WIN95 guidelines
     lnSpacing= lnAvgWidth
     lnHeight=  FONTMETRIC(1, ;
                           THIS.Controls(1).FontName, ;
                           THIS.Controls(1).FontSize) * 7/4
   ENDIF


   FOR lnI=1 TO THIS.ControlCount
     lnMaxWidth= MAX( lnMaxWidth, lnAvgWidth* ;
                                  TXTWIDTH( NoHot(THIS.Controls(lnI).Caption), ;
                                  THIS.Controls(lnI).FontName, ;
                                  THIS.Controls(lnI).FontSize))
   ENDFOR
   lnMaxWidth= lnMaxWidth * (2.2)

   *-- Adjust the button sizes
   FOR lnI=1 TO THIS.ControlCount
     THIS.Controls(lnI).Width= lnMaxWidth
     THIS.Controls(lnI).Height= toDialog.nVDBU*14
     THIS.Controls(lnI).Left  = (toDialog.nHDBU*4)+ ;
                                ((lnI-1)* (lnMaxWidth+ (toDialog.nHDBU*4)))
     THIS.Controls(lnI).Top= 0
     THIS.Controls(lnI).Visible= .T.
   ENDFOR
   IF THIS.ControlCount> 0
     THIS.Height= THIS.Controls(1).Height
     THIS.Width = 2*(toDialog.nHDBU*4)+ ;
                  (THIS.ControlCount* lnMaxWidth)+ ;
                  ((THIS.ControlCount-1)*(toDialog.nHDBU*4))
   ELSE
     THIS.Parent.RemoveObject( THIS.Name)
     * THIS.Height= 0
     * THIS.Width=  0
   ENDIF
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c E d t M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cEdtMsgSvc AS EditBox
  Alignment  = 0
  BackStyle  = 0 && Transparent
  BorderStyle= 0 && none
  FontName   = "MS SANS Serif"
  FontSize   = 8
  FontBold   = .F.
  ReadOnly   = .T.
  ScrollBars = 0 && none
  TabStop    = .F.
  Margin     = 0
  Width      = 200

 *====================================
 *-- cEdtMsgSvc::Init()
 *====================================
 *
  FUNCTION INIT( toSpecPackage)

 *====================================
 *-- cEdtMsgSvc::When()
 *====================================
 * No focus here please
 *
  FUNCTION When
    RETURN .F.

ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T m r A n i m a t e M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cTmrAnimateMsgSvc AS cTmrMsgSvc
 *====================================
 *-- cTmrMsgSvc::Init
 *====================================
 *
 Interval = 400
 nCounter = 0
 nMaxImage= 1
 Enabled  = .F.

 DIMENSION aImages[1]

 FUNCTION Timer
   THIS.nCounter= THIS.nCounter+1
   IF THIS.nCounter > THIS.nMaxImage
     THIS.nCounter= 1
   ENDIF
   THISFORM.oImage.Picture= THIS.aImages[ THIS.nCounter]


 FUNCTION SetImage( toImage, tnImages)
   *? Limited to 10 images???
   THIS.nMaxImage= tnImages
   DIMENSION THIS.aImages[ tnImages]
   LOCAL lnI, lcPre, lcPost, lnTemp, lcVarChar
   lnTemp= AT( ".", toImage.Picture)

   lcPre= LEFT( toImage.Picture, lnTemp -1)
   lcVarChar= RIGHT( lcPre,1)
   lcPre= LEFT( lcPre, LEN( lcPre)-1)

   lcPost= SUBS( toImage.Picture, lnTemp)

   FOR lnI= 1 TO tnImages
     THIS.aImages[lnI]= lcPre+ CHR( ASC( lcVarChar)+lnI-1)+lcPost
   ENDFOR

ENDDEFINE


*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c I m g M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cImgMsgSvc AS Image
  Top   = 12
  Left  = 12
  Width = 32
  Height= 32
  BackStyle= 0  && Transparent

  cPictureProp= "cGuiVisual"
  lAnimate= .f.
  nAnimate= 1

 *====================================
 *-- cImgMsgSvc::Init(o)
 *====================================
 *
  FUNCTION INIT( toSpecPackage)
    LOCAL loMessageSpec
    loMessageSpec= toSpecPackage.GetItem("Message spec")

    LOCAL lcImageFile
    lcImageFile= EVAL("loMessageSpec."+ THIS.cPictureProp)
    IF EMPTY( lcImageFile)
      RETURN .F.
    ENDIF

    lcImageFile=UPPER( lcImageFile)
    IF "ANIMATE" $ lcImageFile
      LOCAL lnAnimatePos, lcAnimateSpec, lnAnimate
      lnAnimatePos= AT( "ANIMATE", lcImageFile)
      lcAnimateSpec= SUBS( lcImageFile, lnAnimatePos)
      lcImageFile= ALLTRIM( LEFT( lcImageFile, lnAnimatePos-1))
      lcAnimateSpec= ALLTRIM(STRTRAN( lcAnimateSpec, "ANIMATE"))
      lnAnimate= VAL( lcAnimateSpec)
      IF lnAnimate> 0
        THIS.lAnimate= .T.
        THIS.nAnimate= lnAnimate
      ENDIF
    ENDIF

    *-- There could be nothing left...
    IF EMPTY( lcImageFile)
      RETURN .F.
    ENDIF


    IF FILE( ALLTRIM( lcImageFile))
      THIS.Picture= lcImageFile
    ELSE
      RETURN .F.
    ENDIF

    IF THIS.lAnimate
      THISFORM.AddObject("oImageTimer", "cTmrAnimateMsgSvc", tospecpackage)
      THISFORM.oImageTimer.SetImage( THIS, THIS.nAnimate)
      THISFORM.oImageTimer.Enabled= .T.
    ENDIF
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c L b l M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cLblMsgSvc AS Label
  FontName= "MS Sans Serif"
  FontSize= 8
  FontBold= .F.
  BackStyle= 0  && Transparent
ENDDEFINE

*//////////////////////////////////////////////////////////////////////////////
* CLASS....: c T h e r m B a r L b l M s g S v c
* Version..: March 31 1996
*//////////////////////////////////////////////////////////////////////////////
DEFINE CLASS cThermBarLblMsgSvc AS Label
  FontBold= .F.
  BackStyle= 0  && transparent
  BorderStyle= 0

ENDDEFINE




*!***********************************************
*!
*!      Procedure: WAITWIND
*!
*!***********************************************
PROCEDURE waitwind
*  Program...........: WAITWIND.PRG
*  Version...........: 1.1 Dec 27 1994
*  Author............: Steven M. Black
*} Project...........: common
*  Created...........: 11/22/91
*  Copyright.........: (c) Steven Black Consulting, 1991
*) Description.......: A Wait window shell -- From Lisa Slater's
*)                     compuserve suggestion
*] Dependencies......:
*  Calling Samples...:
*  Parameter List....: tcPhrase   - What goes in the WAIT window
*                      tnSchemeNo - Color of the WAIT window
*                      txWaiting  - Numeric = TIMEOUT
*                                   TRUE     = WAIT, .F. = NoWait

PARAMETERS ;
           tcPhrase, ;
           tnSchemeno, ;
           txwaiting
*-- you only need to pass the first one...

PRIVATE ;
   jcAnswerVal, ;
   jcWaitType, ;
   jlWaiting, ;
   jnWaiting

jnWaiting  = 0
jlWaiting  = .F.
jcWaitType = TYPE( "txWaiting")

DO CASE
CASE jcWaitType = "N"
   jnWaiting = txwaiting
CASE jcWaitType = "L"
   jlWaiting = txwaiting
ENDCASE

IF EMPTY( tnSchemeno)
   tnSchemeno = 5
ENDIF

jcAnswerVal = []
IF PARAMETERS() > 1
   SET COLOR OF SCHEME 5 TO SCHEME tnSchemeno
ENDIF

DO CASE
CASE jlWaiting                                        && defaults to .f. if nothing was passed...
   WAIT WINDOW tcPhrase TO jcAnswerVal
CASE jnWaiting > 0
   WAIT WINDOW tcPhrase TO jcAnswerVal TIME jnWaiting
OTHERWISE
   WAIT WINDOW tcPhrase NOWAIT
ENDCASE

SET COLOR OF SCHEME 5 TO

RETURN jcAnswerVal


*!***********************************************
*!
*!      Procedure: OK2INSERT
*!
*!***********************************************
procedure ok2insert
*  Author............: Steven M. Black
*  Version...........: 1.3 March 11 1995
*} Project...........: INTL
*  Created...........: 10/26/93
*  Copyright.........: (c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE ok2insert
*)                     Sort of kills the point of the INSERT,
*)                     so tell me a better way...

PARAMETER tcNewAlias

PRIVATE jlRetVal, jcOldError, jnOldAlias
jnOldalias=0
jlRetVal = .T.

jcOldError        = ON( "ERROR")
ON ERROR jlRetVal = .F.

IF ! EMPTY( tcNewAlias)
   jnOldAlias = SELECT()
   SELECT (tcNewAlias)
ENDIF

IF EOF() OR BOF()
  LOCATE
ENDIF

*-- do something that might trigger an error
jcField = FIELD( 1)
REPLACE &jcField WITH &jcField

ON ERROR &jcOldError

IF ! EMPTY( jnOldALias)
  SELECT ( jnOldAlias)
ENDIF

RETURN jlRetVal


*!***********************************************
*!
*!      Procedure: EVLTXT
*!
*!***********************************************
procedure msgevltxt
*  Author............: Ken Levy
*  Version...........: 1.1 Dec 27 1993
*} Project...........: GENSCRNX
*  Created...........: 09/23/93
*  Copyright.........: Public Domain
*) Description.......: PROCEDURE msgevltxt
*)                     Evaluated {{}} within strings

PARAMETERS m.olD_Text
PRIVATE ;
        m.eval_str1, ;
        m.eval_str2, ;
        m.eval_str, ;
        m.nEw_Text, ;
        m.olD_Text, ;
        m.var_type
PRIVATE ;
        m.at_pos, ;
        m.at_pos2, ;
        m.at_pos3, ;
        m.at_pos4, ;
        m.at_pos5, ;
        m.nEw_Str, ;
        m.old_Str
PRIVATE ;
        m.at_line, ;
        m.cR_lf, ;
        m.evlmode, ;
        m.i, ;
        m.j, ;
        m.mThd_Str, ;
        m.onError, ;
        m.sellast

IF TYPE( [m.old_text])#[C]
   RETURN m.old_Text
ENDIF
m.cR_lf   = CHR( 10)+ CHR( 13)
m.onError = ON( [ERROR])
m.nEw_Text= m.old_Text
m.at_pos3 = 1
DO WHILE .T.
   m.at_pos= AT( [{{], SUBSTR( m.old_Text, m.at_pos3))
   IF m.at_pos= 0
      EXIT
   ENDIF
   m.at_pos2= AT( [}}], SUBSTR( m.old_Text, m.at_pos+ m.at_pos3-1))
   IF m.at_pos2= 0
      EXIT
   ENDIF
   m.at_pos4= AT( [{{], SUBSTR( m.old_Text, m.at_pos+ m.at_pos3+ 1))
   IF m.at_pos4>0.and.m.at_pos4<m.at_pos2
      m.at_pos4= OCCURS( [{{], SUBSTR( m.old_Text, m.at_pos+ m.at_pos3-1, ;
         m.at_pos2-m.at_pos4))
      m.at_pos4 = AT( [{{], SUBSTR( m.old_Text, m.at_pos+ m.at_pos3-1), m.at_pos4)
      m.old_Str = SUBSTR( m.old_Text, m.at_pos+ m.at_pos3-1, m.at_pos2+ 1)
      m.eval_str= SUBSTR( m.old_Str, 3, LEN( m.old_Str)-2)
      m.old_Str = msgevltxt( m.eval_str)
      m.old_Text= STRTRAN( m.old_Text, m.eval_str, m.old_Str)
      m.nEw_Text= STRTRAN( m.nEw_Text, m.eval_str, m.old_Str)
      LOOP
   ENDIF
   m.old_Str = SUBSTR( m.old_Text, m.at_pos+ m.at_pos3-1, m.at_pos2+ 1)
   m.eval_str= ALLTRIM( SUBSTR( m.old_Str, 3, LEN( m.old_Str)-4))
   * DO esc_check
   m.evlmode = .F.

   DO CASE
   CASE EMPTY( m.eval_str)
      m.eval_str= []
   CASE LEFT( m.eval_str, 2)== [&.]
      m.eval_str= SUBSTR( m.eval_str, 3)
      &eval_str                                       &&;
         --------------------------------------------------------------;
         ERROR ocCured during MACRO substitution OF {{&. <expc> }}.
      m.eval_str= []
   CASE LEFT( m.eval_str, 1)== [<]
     *[smb]  m.eval_str= INSERT( SUBSTR( m.eval_str, 2))     &&;
         --------------------------------------------------------------;
         ERROR ocCured during evaluation OF {{< <FILE> }}.
   OTHERWISE
      m.eval_str= EVALUATE( m.eval_str)               &&;
         --------------------------------------------------------------;
         ERROR ocCured during evaluation OF {{ <expc> }}.
   ENDCASE
   IF EMPTY( m.onError)
      ON ERROR
   ELSE
      ON ERROR &onError
   ENDIF
   m.var_type= TYPE( [m.eval_str])
   DO CASE
   CASE m.var_type== [C]
      m.nEw_Str= m.eval_str
   CASE m.var_type== [N]
      m.nEw_Str= ALLTRIM( STR( m.eval_str, 24, 12))
      DO WHILE RIGHT( m.nEw_Str, 1)== [0]
         m.nEw_Str= LEFT( m.nEw_Str, LEN( m.nEw_Str)-1)
         IF RIGHT( m.nEw_Str, 1)== [.]
            m.nEw_Str= LEFT( m.nEw_Str, LEN( m.nEw_Str)-1)
            EXIT
         ENDIF
      ENDDO
   CASE m.var_type== [D]
      m.nEw_Str= DTOC( m.eval_str)
   CASE m.var_type== [L]
      m.nEw_Str= IIF( m.eval_str, [TRUE], [FALSE])
   OTHERWISE
      m.nEw_Str= m.old_Str
   ENDCASE
   m.nEw_Text= STRTRAN( m.nEw_Text, m.old_Str, m.nEw_Str)
   m.at_pos2 = m.at_pos+ LEN( m.nEw_Str)
   IF m.at_pos2<= 0
      EXIT
   ENDIF
   m.at_pos3= m.at_pos3+ m.at_pos2
ENDDO
m.j= 0
DO WHILE [{{]$m.nEw_Text.and.[}}]$m.nEw_Text
   *         =esc_check()
   m.i       = LEN( m.nEw_Text)
   m.nEw_Text= msgevltxt( m.nEw_Text)
   IF m.i= LEN( m.nEw_Text)
      IF m.j>= 2
         EXIT
      ENDIF
      m.j= m.j+ 1
   ENDIF
ENDDO
RETURN m.nEw_Text


*!*********************************************
*!
*!       Procedure: tokennum
*!
*!*********************************************
PROCEDURE tokennum
*  Author............: Steven M. Black
*} Project...........: COMMON
*  Version...........: 1.1  Feb 6 1994
*  Created...........: Sometime in early '92
*  Copyright.........: (c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE tokennum
*)                     Return a specified of tokens from a string
*] Dependencies......:
*  Calling Samples...: tokennum( <expC>, <expN>[, <expC>])
*  Parameter List....: tcPassedStr
*                      tnTokenNum
*                      tcBreakChar
*                      tlCountDupBreaks
*  Returns...........: The n'th token in a string
*  Major change list.: Support for counting duplicate break characters

PARAMETERS ;
           tcPassedStr, ;
           tnTokenNum, ;
           tcBreakChar, ;
           tlCountDupBreaks

PRIVATE ;
   jcRetVal, ;
   jcString1, ;
   jcX

jcX = CHR(253)

IF PARAMETERS() = 2
   tcBreakChar = " .,"
ENDIF

m.jcString1 = ALLTRIM( m.tcPassedStr)

m.jcString1 = CHRTRAN( m.jcString1, tcBreakChar, REPLICATE(jcX, LEN(tcBreakChar)) )

DO WHILE (! tlCountDupBreaks) AND AT( jcX+ jcX, m.jcString1) > 0
   m.jcString1 = STRTRAN( m.jcString1, jcX+ jcX, jcX)
ENDDO

DO CASE
CASE m.tnTokenNum > 1

  DO CASE
  *-- no token tnTokenNum past end of string.
  CASE AT( jcX, m.jcString1, m.tnTokenNum-1) = 0
    m.jcRetVal = ""

  *-- token tnTokenNum is last token in string.
  CASE AT( jcX, m.jcString1, m.tnTokenNum) = 0
    m.jcRetVal = SUBSTR( m.jcString1, ;
                         AT( jcX, m.jcString1, m.tnTokenNum-1)+ 1)

   *-- token tnTokenNum is in the middle.
   OTHERWISE
    lnStartPos = AT( jcX, m.jcString1, m.tnTokenNum-1) +1
    m.jcRetVal = SUBSTR( m.jcString1, ;
                         lnStartPos, ;
                         AT( jcX, m.jcString1, m.tnTokenNum) - lnStartPos)
   ENDCASE

CASE m.tnTokenNum = 1

  *-- get first token.
  IF AT( jcX, m.jcString1) > 0
     m.jcRetVal = SUBSTR( m.jcString1, 1, AT( jcX, m.jcString1)-1)

  *-- there is only one token.  get it.
  ELSE
     m.jcRetVal = m.jcString1
  ENDIF

ENDCASE

m.jcRetVal = ALLTRIM( m.jcRetVal)

RETURN m.jcRetVal


*!*********************************************
*!
*!       Procedure: tokens
*!
*!*********************************************
PROCEDURE tokens
*  Author............: Steven M. Black
*} Project...........: Common
*  Version...........: 1.1  Feb 6 1994
*  Created...........: Sometime in early '92
*  Copyright.........: (c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE tokens
*)
*] Dependencies......:
*  Calling Samples...: tokens( <expC>[, <expC>])
*  Parameter List....: tcPassedString
*                      tcBreakChar
*                      tlCountDupBreaks
*  Returns...........: The number of tokens in a string
*  Major change list.: Support for counting duplicate break characters


PARAMETERS ;
           tcPassedString, ;
           tcBreakChar, ;
           tlCountDupBreaks

PRIVATE ;
        tcBreakChar, ;
        tcPassedString, ;
        jcX

jcX = CHR( 253)

DO CASE
CASE PARAMETERS() = 0
   RETURN ""
CASE PARAMETERS() = 1
   m.tcBreakChar = " .,"
ENDCASE

m.tcPassedString = CHRTRAN( m.tcPassedString, ;
                            m.tcBreakChar, ;
                            REPLICATE( jcX, LEN( m.tcBreakChar)))

m.tcPassedString = ALLTRIM( m.tcPassedString)

DO WHILE (! tlCountDupBreaks) AND AT( jcX+ jcX, m.tcPassedString) > 0
   m.tcPassedString = STRTRAN( m.tcPassedString, jcX+jcX, jcX)
ENDDO

RETURN ( OCCURS( jcX, m.tcPassedString) + 1)

FUNCTION i
LPARAMETERS Passed
RETURN Passed


*!*********************************************
*!
*!       Procedure: NoHot
*!
*!*********************************************
Procedure NoHot
*  Author............: Steven M. Black
*} Project...........: common
*  Created...........: 05/09/92
*  Copyright.........: (c) Steven Black Consulting, 1993
*) Description.......: PROCEDURE NoFeatures
*)                     Feed it a string, and it strips out hotkey assignments
*)                     returning the featurless string
*] Dependencies......:
*  Calling Samples...: nohot(<ExpC>)
*  Parameter List....:

PARAMETERS tcPassedPrompt
*-- This is the fastest, though not the most legible, way
*-- to code this.
*--                                     Hot Key, Ctrl Enter, Escape
RETURN STRTRAN( STRTRAN( STRTRAN( tcPassedPrompt, "\<"), "\!"), "\?")


*!*********************************************
*!
*!       Procedure: NoOldHot
*!
*!*********************************************
Procedure NoOldHot
PARAMETERS tcPassedPrompt
*-- This is the fastest, though not the most legible, way
*-- to code this.
*--
RETURN STRTRAN( STRTRAN( tcPassedPrompt, "\!"), "\?")


*!***********************************************
*!
*!      Procedure: STRIPPAT
*!
*!***********************************************
FUNCTION strippat
PARAMETER tcFileName

PRIVATE ;
   jnColPos, ;
   jnNamelen, ;
   jnSlashPos

m.jnSlashPos = RAT( "\", tcFileName)
IF m.jnSlashPos <> 0
   m.jnNamelen  = LEN( tcFileName) - m.jnSlashPos
   tcFileName   = RIGHT( tcFileName, m.jnNamelen)
ELSE
   m.jnColPos = RAT( ":", tcFileName)
   IF m.jnColPos <> 0
      m.jnNamelen  = LEN( tcFileName) - m.jnColPos
      tcFileName   = RIGHT( tcFileName, m.jnNamelen)
   ENDIF
ENDIF
RETURN tcFileName


*!***********************************************
*!
*!      Procedure: STRIPEXT
*!
*!***********************************************
FUNCTION stripext
PARAMETER m.tcFileName

PRIVATE ;
   jcRetVal, ;
   jnDotPos, ;
   jnTermintr

jcRetVal = m.tcFileName

m.jnDotPos   = RAT( ".", m.tcFileName)
m.jnTermintr = MAX( RAT( "\", m.tcFileName), RAT( ":", m.tcFileName))

IF m.jnDotPos > m.jnTermintr
   m.jcRetVal = LEFT( m.tcFileName, m.jnDotPos-1)
ENDIF

RETURN m.jcRetVal

*!*********************************************
*!
*!       Function: strtranc
*!
*!*********************************************
FUNCTION strtranc
*  Author............: Ken Levy
*  Version...........: 2.0
*} Project...........: GENSCRNX
PARAMETERS tcSearched, tcSearchFor , tcReplacement, tnStartOccurrence, tnNumberOfOccurrences
PRIVATE lcRetVal, at_pos, at_pos2, lnOccurence, lnSubstitutionsDone

IF EMPTY( tcSearched).OR.EMPTY( tcSearchFor )
  RETURN tcSearched
ENDIF

lcRetVal= tcSearched
IF TYPE('tnStartOccurrence')# 'N'
  tnStartOccurrence= 1
ENDIF

IF TYPE( 'tnNumberOfOccurrences')#'N'
  tnNumberOfOccurrences= LEN( tcSearched)
ENDIF

IF tnStartOccurrence< 1 OR tnNumberOfOccurrences< 1
  RETURN tcSearched
ENDIF

lnOccurence=0
lnSubstitutionsDone=0
m.at_pos2=1
DO WHILE .T.
  m.at_pos= ATC( tcSearchFor ,SUBSTR( lcRetVal, m.at_pos2))
  IF m.at_pos=0
    EXIT
  ENDIF
  lnOccurence= lnOccurence+ 1
  IF lnOccurence< tnStartOccurrence
    m.at_pos2= m.at_pos+ m.at_pos2+ LEN( tcSearchFor)- 1
    LOOP
  ENDIF

  *[smb] 6/20/97
  lcRetVal=LEFT( lcRetVal, m.at_pos+ m.at_pos2- 2)+ tcReplacement+ ;
         IIF( (m.at_pos+ m.at_pos2+ LEN( tcSearchFor )- 1)> LEN(lcRetVal), ;
          '' , ;
         SUBSTR(lcRetVal, m.at_pos+ m.at_pos2+ LEN( tcSearchFor )- 1))

  lnSubstitutionsDone= lnSubstitutionsDone+ 1
  IF lnSubstitutionsDone>= tnNumberOfOccurrences
    EXIT
  ENDIF
  m.at_pos2= m.at_pos+ m.at_pos2+ LEN( tcReplacement)- 1
  IF m.at_pos2> LEN( lcRetVal)
    EXIT
  ENDIF
ENDDO
RETURN lcRetVal

* END strtranc

****************************************************************************
* MSGSVC() History
*
* ==========================================================================
* MSGSVC NEW FOR FALL 97              IMPROVED                   Oct 11 1997
* ==========================================================================
*  Single Ok button now the same size as the others.
*
* ==========================================================================
* MSGSVC NEW FOR VFP 5.0              IMPROVED                   Aug 15 1997
* ==========================================================================
*   Esc key no longer closes dialogs that don't have cancel buttons
*   Editbox backcolor problem in Tip-Of-The-Day dialog fixed
*   Better handling of %C% embedded cookies
*   Strings like "Yes", "No", "Cancel", etc are longer assumed to be English original.
*   Esc key closes the tip of the day dialog
*
* ==========================================================================
* MSGSVC NEW FOR VFP 3.0              IMPROVED                      Apr 6 96
* ==========================================================================
*   Win95 GUI
*   Tip of the day
*   Animated icons
*   Objectified
*   Looks better if icon is missing
*   No Read.
*   WORKING functionality
*   Return type "C" -- It's the default but doesn't work if specified
*   Lowercase %Cx% now being respected in Msgsvc
*   Default dialog is now Grey
*   Flexbox re-engineerd to look more like MESSAGEBOX
*   Default Windows font now ARIAL 10 B for VFP
*   Default Windows font now MS Sans Serif 8 Regular for VFP :)
*   MESSAGEBOX() return value compatibility
*

*  Program...........: GENMENUX.PRG
*  Author............: Andrew Ross MacNeill
*  Version...........: 3.0a
*} Project...........: GENMENUX
*  Created...........: 07/04/93
*  Copyright.........: (None - Placed in Public Domain)
*) Description.......: Pre/Post Compiler for Menus
*)                     Provides lots of features for MENU directives
*)                     Based on original piece by Steven Black
*)                             and GENSCRNX by Ken Levy of JPL
*] Dependencies......:
*  Calling Samples...:
*  Parameter List....:
*  Returns...........:
*  Major change list.:
*{ 08/19/93 Addition of Clauses for *:MESSAGE to force messages
*{                      TO appear IN the  MESSAGE clause (useful FOR DOS MENUS)
*{                      This is   called BY HAVING A LINE IN the  comments BOX starting WITH
*{                      *:MESSAGE AND then the  MESSAGE clause AS it   would appear including
*{                      quotes, etc.
*{ 08/20/93 Addition of Clauses for *:DELETE
*{                      This allows you  TO remove items FROM the  MENU during compilation TIME
*{                      Useful FOR taking out  features until ready.
*{                      Simply place *:DELETE IN the  Comments BOX
*{ 08/20/93 Addition of Reordering Procedure that reorganizes the menu
*{                      AFTER GENMENUX has  done its  thing such AS removing OR changing items
*{                      The  MENU must GET renumbered IN ORDER TO appear correctly. This now
*{                      takes place AFTER ALL OF the  pre -processing has  been completed.
*{ 08/20/93 Support for Two Driver Levels
*{                      First LEVEL is   FOR complete pre -processing
*{                      IF you  want the  MENU TO actually be   generated OR IF you  want
*{                      simply TO RUN A PROGRAM FOR A specific MENU
*{ 08/25/93 Removed references to INTL and SMB as per request by SMB
*{ 08/25/93 Fixed problem in standard directives that only allowed
*{                      MESSAGE AND COLOR settings TO be   IN the  first LINE OF the
*{                      Comments snippet
*{                      Bug  FROM SMB
*{ 08/25/93 Fixed bug with m.prompt under Windows
*{                      Bug  FROM SMB
*{ 08/25/93 Added support for PADCOLOR which sets the default color of
*{                      MENU pads throughout the  SYSTEM
*{ 08/26/93 Added support for CONFIG.FP. All MNX and MPR drivers may be
*{                      defined IN the  CONFIG.FP FILE BY USING the  _MNXDRV OR _MPRDRV
*{                      setting.  IF any  drivers are  NOT available, A WAIT WINDOW
*{                      is   displayed AND times out  AFTER 3    seconds.
*{                      Request FROM SMB
*{ 08/26/93 Finished support for DEFAULT setting which makes the menu
*{                      become the  DEFAULT MENU BY USE OF the  SET SYSMENU SAVE COMMAND
*{                      being processed RIGHT AT the  END OF the  file.
*{ 08/26/93 Added support to force all *: statements to be changed to
*{                      *-:    WHEN processed.
*{                      Request FROM SMB
*{ 08/26/93 Added support for *:NOAUTO directive in setup statement
*{                      which removes the  SET SYSMENU AUTOMATIC statement FROM
*{                      the  created SPR  file.
*{                      This was  an   ER   FROM Andy Neil OF MM.
*{ 08/27/93 Added support for *:AUTOHOT directive in setup or _AUTOHOT=ON
*{                      IN CONFIG.FP. This will automatically ADD A Hotkey TO A MENU PAD
*{                      WHEN it   is   created.  This is   useful IF you  sometimes forget TO
*{                      CREATE hotkeys FOR your menus.  BY DEFAULT, it   uses the  first
*{                      letter OF the  MENU Pad.  IF it   is   already being USED BY one  OF
*{                      the  other MENU pads, it   will proceed TO the  NEXT letter, AND so   on.
*{ 08/27/93 Fix Bug in Reordering Menu procedure that caused problems
*{                      WITH MENU items that had  NOT been defined.
*{ 08/27/93 Added *:POPFILES directive for EARLY testing. This directive
*{                      should be   placed ON the  FIRST BAR IN A submenu IN ORDER TO make
*{                      the  entire submenu INTO A dynamic POPUP PROMPT FILES LIKE *.   *
*{                      COMMAND line. This would allow you  TO provide ACCESS ONLY TO
*{                      specific files. Please DO NOT USE THIS FUNCTION YET.
*{                      IN ORDER FOR it   TO FUNCTION properly, you  need TO place A
*{                      *:POPCOMMAND directive that defines what is   done ON the
*{                      ON SELECTION POPUP. This directive must be   A VALID FOXPRO
*{                      function.
*{ 09/07/93 Fixed AUTOHOT option.
*{ 09/07/93 _GENMENUX setting in CONFIG.FP is overriden by MNXDRV5 driver.
*{ 09/07/93 Added support for AUTORUN in CONFIG.FP, runtime and setup code
*{ 09/14/93 Added support for *:IF which will add RELEASE PADs in the clean up code
*{ 09/14/93 Enlarged Thermometer to overlay on top of standard Menu thermometer
*{ 09/17/93 Added support for *:GENIF (Compile-time IF statement that DELETES
*{                      the  PAD OR BAR IF A variable is   true during build.
*{ 09/25/93 Support for the whole clause of POPFILES has now been added.
*{ 09/26/93 Support for POPFIELD directive added.
*{ 09/28/93 Fixed Bugs from Steve Black
*{ 09/28/93 Changed All LOCATE FOR SETUPTYPE=1 TO GO TOP based on a
*{                      suggestion from Barry Chertov (MM). MM don't usually put
*{                      setup code and SETUPTYPE=1 is only valid for those menus
*{                      where the setup is filled in.
*{ 09/29/93 Ensured that MPRDRVs existed by forcing a PRG extension
*{                      if it was forgotten.
*{ 10/04/93 Recovered from Crash! Added support for WORDSEARCH() by
*{                      Ken Levy (JPL) to better support directives.
*{ 10/05/93 Ensured that ON SELECTION POPUP command was placed directly
*{                      after the POPUP definition to avoid any problems in the
*{                      clean up code. From Suggestion by SS
*{ 10/05/93 Added NOXGEN directive to tell GENMENUX NOT to process anything
*{ 10/07/93 Added support for {{}} statement via Ken Levy's evlTxt function.
*{                      This updating of {{}} statements is done after the first
*{                      MPR driver and BEFORE the second.
*{ 10/07/93 Problem with NOGEN fixed.
*{ 10/10/93 Fixed MENUNAME.
*{
*{***************************
*{ RELEASE OF VERSION 1.0
*{***************************
*{
*{ 10/12/93 Added *:SYSPOP option that wraps Procedure with PUSH/POP SET SYSMENU
*{                      SYSPOP is a CONFIG.FP, Setup and Procedure Directive.
*{ 10/12/93 Allowed all MNX Drivers and GENMENUX to be memvars with _ during compilation.
*{                      These will not override menu defaults but act as additional
*{                      substitutes.
*{ 10/12/93 Created BARHOT directive that creates hot keys for Menu Bar items.
*{                      This directive can be called for a single Menu Bar or for every
*{                      single item.  It will only work if the menu bar is for a
*{                      Command/Procedure or Bar #. It will not work for submenus.
*{                      However, if you place BARHOT at the top pad of a menu, it will
*{                      ensure that BARHOT is active for all bars in that menu.
*{                      This allows you to only use BARHOT on certain Menu Popups
*{ 10/12/93 Fixed an option with AUTOHOT that didn't check for duplicates
*{                      when creating the menu bar hot keys.
*{ 10/14/93 Started working on Menu Template options using directives
*{                      INSBAR and DEFBAR.
*{ 10/15/93 Added HIDE directive that hides the menu bar while it's being
*{                      generated.  If you use the HIDE directive, GENMENUX automatically
*{                      calls the NOAUTO directive to properly hide the menu.
*{ 10/19/93 Added support for InsObj and defObj directive. These directives
*{                      provide complete menu copy/paste handling across menu template files.
*{ 10/19/93 Added AUTOWIN directive that will create a window and place the
*{                      the menu inside the window and activate the window, etc - all automatically
*{                      This is an ER from SB instead of having to call *:WINDOW and define
*{                      the Window yourself. AUTOWIN allows you to place and size the Window
*{                      during Menu Generation.
*{ 10/19/93 Added AUTOPOS directive that will allow the user to click on the
*{                      desired location of the Menu during generation. Perhaps the name
*{                      of this directive will change in the near future.
*{ 10/19/93 When using the MENUNAME directive, you need to activate the menu
*{                      after DEFINing it since SET SYSMENU AUTOMATIC won't do it. Instead
*{                      of automatically doing it, use the directive AUTOACT. This directive
*{                      will also automatically ACTIVATE _MSYSMENU if used.
*{ 10/19/93 Added FOUNDATION directive that creates a Foundation read
*{                      clause at the bottom of the menu file. This foundation read
*{                      will perform a VALID clause based on the directive's clause.
*{                      If there is no directive clause, the FOUNDATION READ is performed
*{                      on whether the Prompt is "EXIT" or "QUIT"
*{ 10/19/93 Added *:PADPOS and POPPOS directives that places Pads at Row and Column
*{                      specified by PadPOS.
*{ 10/19/93 Added *:SELECTPAD directive that forces you to actively press
*{                      Enter when highlighting a PAD to see the Popup.
*{                      When using the SELECT directives, you should place positions
*{                      on the Popups to work properly.
*{ 10/19/93 Added *:VERTICAL directive that makes the menu a vertical menu
*{                      instead of the standard horizontal menu
*{                      VERTICAL has two parameters the line to begin at and the lines
*{                      to skip between the two.
*{ 10/19/93 Added *:SELECTBAR directive that forces you to actively press
*{                      Enter when highlighting a BAR to see the Popup.
*{                      When using the SELECT directives, you should place positions
*{                      on the Popups to work properly.
*{ 10/19/93 Added *:POPTITLE as a popup directive that places a title
*{                      on a popup.
*{ 10/20/93 Added directive to make definition of PAD and/or popup optional
*{                      by verifying existence of PAD before Defining Popup.
*{                      Since the actual DEFINE POPUP takes time, the IF statement
*{                      will make the calling of the menu quicker. Currently it's called
*{                      *:POPME and can be called in the submenu popup or passed the
*{                      parameter of the popup to Quick Pop
*{                      This directive is based on a driver by MicroMega
*{ 10/20/93 New Directive that allows you to define the menu as one of the
*{                      four options (Append,Replace,Before,After) *:LOCATION
*{                      This directive takes one of the above statements as a parameter
*{                      In addition BEFORE and AFTER take the name of the menu pad
*{                      or menu name to replace as a parameter.
*{                      If it knows the PAD NAME based on the parameter, it uses it
*{                      otherwise it defaults to the passed parameter
*{ 10/20/93 Directive to identify PADNAME *:PADNAME and POPUP Name *:POPNAME
*{ 10/20/93 Added support for *:TRNTXT directive.
*{ 10/20/93 Fixed problem that occurs under Windows where the project file
*{                      contains double backslashes and it shouldn't.
*{ 10/21/93 Added new wordSearch by Ken Levy (JPL) from GENSCRNX 1.7a
*{ 10/22/93 Addition of qualFile from Steve Sawyer to fix bug with relative paths
*{                      While Steve's fix didn't completely work, this has been fixed
*{                      using stuff found in GENMENU.
*{ 10/22/93 Creation of *:ARRAY directive that will place a Loop for the
*{                      the length of the array to create menu items.
*{ 10/23/93 Renamed all TEMPLATE objects into GENSCRNX Style directives.
*{                      Removed INSBAR and DEFBAR directives. Doing this changes
*{                      the structure of the FOXMNX file slightly.
*{                      WHILE GENMENUX will support INSOBJ and DEFOBJ, it doesn't
*{                      yet support BASOBJ and its work.
*{ 10/23/93 Added support for DELOBJ which deletes an Object AFTER
*{                      menu pre-processing has been done (ie After MNXDRV2)
*{ 10/23/93 Added support for COLOR PAIR with *:COLOR and COLOR SET with *:COLORSET
*{ 10/23/93 Added support for AUTOWIN to allow users to DEFINE WINDOW
*{                      with additional clauses by themselves.
*{ 10/23/93 Made POPME accept a clause so the user can define the
*{                      IF condition.
*{ 10/24/93 Addition of NOCOMMENT directive that removes all comments
*{                      from the generated MPR file. NOCOMMENT is a
*{                      CONFIG.FP and Setup directive.
*{ 10/24/93 Addition of INSCX directive (from a suggestion by Mike Feltman)
*{                      this directive places the DO MPR clause in the SCX file
*{                      specified. If specified with a SAVE option, INSCX will add
*{                      PUSH MENU _MSYSMENU to the Code.
*{ 10/25/93 Changes Header notes so that "*** By GENMENUX" only appears once.
*{                      Based on an ER by Steve Black (10/25/93)
*{ 10/25/93 Allowed GENMENUX Setup Directives to be called in the top level Menu
*{                      Procedure file.
*{ 10/25/93 Removed the AUTOWIN option and added its directives to the WINDOW
*{                      directive.
*{ 10/25/93 Cleaned up cleanup code to ensure that jctProjExt would be closed
*{                      when it was erased. Bug note by Ken Levy (JPL)
*{ 10/26/93 Turned off Cursor when running application
*{ 10/25/93 GENMENUX now respects the TMPFILES setting in the CONFIG.FP so
*{                      Temporary files will be created in the appropriate directories.
*{ 10/26/93 Fixed bug in *:WINDOW that was automatically trying to define the
*{                      WINDOW when the directive was used.
*{ 10/26/93 Updated EVLTXT with GENSCRNX 1.7a Version.
*{ 10/27/93 GENMENUX now calls CLEANUP to ensure files are closed and removed properly.
*{ 10/27/93 Fixed temporary project to correctly reference temporary menu file
*{ 10/28/93 Ensures variables are defined as PRIVATE or #DEFINEd
*{ 10/30/93 The following changes are all due to ERs from Ken Levy (JPL)
*{                      All PUBLIC Statements have been removed from GENMENUX.
*{                      GENMENUX now uses uniqueFlnm to come up with Unique File Names
*{                      A Mismatched IF...ENDIF was cleaned up. Wasn't causing problems.
*{                      A new directive *:NOTHERM causes GENMENUX to use FoxPro's
*{                              normal looking Thermometer instead of the advanced thermometer.
*{                      GENMENUX no longer includes my name as part of the comment.
*{ 10/30/93 Cleaned up Thermometer for messages.
*{ 11/01/93 Fixed problem with AUTOHOT that was sometimes making a non
*{                      alpha character the hot key.
*{ 11/01/93 Implementation of the POPPRECOMMAND which allows you to
*{                      run a command before a popup is defined.
*{ 11/01/93 Cleaned up the calling of the POP Commands to work if called
*{                      from within a top level menu.
*{***************************
*{ RELEASE OF VERSION 1.1
*{***************************
*{ 11/12/93 On Line 443, changed code so jcOutFile wouldn't get changed.
*{ 11/12/93 Updated ERRHNDLR to reflect Ken Levy's changes.
*{ 11/16/93 Ensured that directives were CASE-INSENSITIVE
*{ 11/16/93 Added NOACT directive that removes the ACTIVATE MENU option
*{			automatically performed by GENMENUX.
*{ 11/19/93 Updated Re-ordering routine to accomodate popups with similar
*{			or same names.
*{ 11/19/93 Fixed problem with SELECTBAR that was causing invalid syntax
*{			in the MPR file.
*{ 11/19/93 Enhanced IF processing to speed it up (thanks to MS)
*{ 11/20/93 Added the support of Keywords to be used in the *:IF statement
*{			at present (to be expanded later) that allows GENMENUX to put
*{			in the names of the PROMPTS, levels, barnames, and numbers
*{			when highlighted with * as in *PROMPT*
*{ 11/20/93 Enhanced support for the FOUNDATION directive so that any clauses
*{			you add to it are added to the READ.
*{ 11/20/93 Enhanced support for the {{}} clauses by performing an EVLTXT
*{			on the CONFIG.FP, Setup Snippet, Procedure Snippet and each
*{			Comment Snippet before reordering.
*{ 11/20/93 Provided better support for Escape during menu generation.
*{***************************
*{ RELEASE OF VERSION 1.1a
*{***************************
*{ 11/27/93 Put in code that verified type of driver being run ie if MNXDRV2 acted
*{			like a Full MNX driver, then it wouldn't be rerun over and over.
*{			Also message was placed on thermometer for MNXDRV2.
*{ 11/27/93	Verified UPDTHERM procedures so thermometer messages were properly wiped out
*{			under Windows. Previously, they weren't being completely cleared.
*{ 12/6/93	Addition of MNXDRV0 which copies genmenu to a temporary file and
*{			appends functions into it.
*{ 1/5/94	Updates from GENSCRNX to make GENMENUX more environment aware
*{			ER From KL
*{ 1/6/94	Updates from GENSCRNX for better warnings, etc
*{			ER from SMB
*{ 1/28/94	Fixed Problem with Environment Reset (wasn't resetting environment)
*{ 1/28/94 	Inserted insRec, and dupRec records from GENSCRNX 1.8 b2
*{			This is cautious because the USER is responsible for making any changes
*{			to the Menu Number, etc.
*{			INSREC is not included because the nature of GENMENU is slightly
*{			different than the nature of GENSCRN.
*{ 1/28/94	Added support for MENUCOLOR directive that adds the COLOR line to the DEFINE
*{			Menu command. This is also supported by the MENUSCHEME directive which provides
*{			SCHEME Support.
*{ 3/19/94	Changed *:ARRAY to not force you to implement the ON SELECTION BAR statement.
*{			Previously, you had to place the action in the array itself.
*{ 03/23/94	Added ccNoPad to comment out the DEFINE PAD statement that overlaps badly when
*{			using the *:IF statement with menu pads.
*{ 04/02/94	Various fixed from ERs and bug reports from Colin Keeler concerning
*{			various syntax errors (whoops! <g>) and using GENMENUX Exclusively
*{ 04/02/94	Fix for *:IF that was only putting the *:IF clause at the very end of the Procedure even if
*{			a return clause was there.  Thanks for Eldor for pointing this one out!
*{ 04/02/94	Another fix for *:IF that puts parentheses around the whole *:IF statement to ensure that
*{			the entire clause is used with the IF NOT statement. Thanks for Randy P. for pointing this out!
*{ 04/02/94	Fix by Paul Bienick regarding use of quotations with the POPCOMMAND statement (thanks Paul)
*{ 04/02/94	Laid in basics for a new directive *:CASE that will create a CASE statement for all of the DEFINE
*{			statements for each specific item. If a CASE statement is used, it will create a specific menu
*{			file
*{ 04/02/94	The CASE directive will place all of the items without a CASE statement
*{			at the bottom of the CASE statement so they are used regardless of the logical statement.
*{ 04/04/94	Updated any messages to being calls to the GENSCRNX Warning function
*{			ER from SMB.
*{ 04/06/94	Fixed CASE statement to work properly with Popups and ON PAD statements.
*{			Moved final CASE statement to after the regular menu setups.
*{ 04/06/94	Added *:BEFORE and *:AFTER pads for popups and bars
*{			This directive may be passed with either a numeric or character
*{			(for Bars and Pads respectively) to reorder the appropriate placement
*{			of the menu pads. This is especially useful when using the
*{			CASE statement for individual items
*{ 04/06/94	Added clauses to *:COLOR directives that allow users to identify
*{			the special color settings for Windows.
*{			The clauses are RED, AQUA, GREY, MAROON, GREEN, ROYAL BLUE,
*{				BURGUNDY, LIGHT GREEN, BABY BLUE, BLUE, VIOLET, YELLOW,
*{				DARK GREY
*{ 04/08/94	Added WORDSTUFF, ERROR_HND and ESC_CHECK FROM GENSCRNX 2.0
*{ 04/14/94	Added REFPRG setup directive. This directive will create a separate program
*{			that will refresh any of the menu options with the *:CASE statements
*{			without having to recall the MPR file.
*{			This is done by identifying the BAR where the menu pad is.
*{			This directive makes it easier to refresh the menu bar. A good place
*{			to put it is inside the Foundation Read loop
*{ 04/14/94	Fixed error handler to display proper table name
*{ 04/15/94	Started Beta Testing
*{ 04/16/94	Changed Version No to 2.0 to match with all other GENX Products. Request from SB
*{ 04/21/94	Added New wordsearch and wordstuff functions from GENSCRNX
*{ 04/21/94	Changed all prompts for GENSCRNX to GENMENUX
*{ 04/21/94 Fixed bug with NOXGEN directive
*{ 04/21/94	Allowed IGNORE to properly ignore additional directives
*{ 04/21/94	Sped up *:CASE directive processing
*{ 04/23/94	Added new dfltfld required for wordsearch
*{ 04/23/94	Changed path directives to be more Mac friendly
*{ 04/30/94	Allowed multiple drivers to be called at each level
*{ 04/30/94	Improved ARRAY directive's handling of arrays
*{ 05/03/94	Fixed problem with multiple drivers at MPRlevel 1 and 2
*{ 05/03/94	CASE statement no longer bombs if only one case statement
*{ 05/03/94	PUKE Color statement revised to Khaki (Puke still works tho)
*{ 05/06/94	*:COLOR Keywords now only works with Windows
*{ 05/07/94	Changed DupRec and InsBlank to work properly
*{***************************
*{ RELEASE OF VERSION 2.0
*{***************************
*{ 07/27/94	Fixes for CASE statement to work properly with menus
*{ 07/27/94	Fixes to support EXCLUSIVE setting turned on when dealing with menus
*{ 07/27/94	Fixes to deal with empty menus
*{ 09/01/94	Fixes to allow CONFIG.FP drivers to work properly
*{ 09/15/94	Fix to provide warning if the file m.genmenu is not present
*{ 09/15/94	Created directive called *:VARIABLE which allows menu bar/pad
*{			to be variable driven. Gets called near the end of the process
*{			Thanks to Andy Neil asking for it!
*{***************************
*{ RELEASE OF VERSION 2.0a
*{***************************
*{ 10/28/94	Support for new GENMENU code that supports color scheme
*{ 12/08/94 Cleaned up TMPFILES support
*{ **************************
*{ BETA PERIOD FOR VFP 3.0
*{ **************************
*{ 05/13/95	Fixed bug because of project manager
*{ 05/13/95	Added *:FONT clauses to Comment snippets
*{			to support additional calls by Foxpro
*{ 05/13/95	Added *:CLAUSE directive to support any new calls FoxPro adds on
*{			These are added to the end of the DEFINE xxx statement.
*{ 05/13/95	Added *:SKIP_REDIRECT directive to Setup snippets
*{			This moves the SKIP FOR statements into a special program
*{			that can be called via a DO <procName> IN MPR file
*{			This speeds up menu generation (Thanks Lisa! (hugs <s>)
*{ 05/13/95	In order to accomodate different procedures, GENMENUX will use a
*{			Code Holder cursor to hold the various procedures that it may be
*{			creating while running. SKIP REDIRECT is an example of such a code
*{			holder.
*{ 			Functions include: UPDCODE and STORECODE
*{ 05/13/95	Removal of GENMENU's LOCFILE statement
*{			This is controlled by the *:NOLOC setup or comment or CONFIG.FP directive
*{ 05/13/95	Inclusion of the SKIP_AUTO directive in the Setup will
*{			force the DO <lcSkipProc> function to be called in the menu cleanup
*{			to handle any SET SKIP statements found in the *:SKIP_REDIR statements
*{ 05/13/95	The directive *:PREDEF allows the user to run a program that returns
*{			text or issue a command right before the DEFINE BAR command
*{			is issued for a particular item
*{			This is useful for setting up variables, etc.
*{			This process is run twice. Once during the first pass through
*{			the next during the last pass through allowing for
*{			other statements to be dropped in.
*{ 05/13/95	GENMENUX is now more open to different Platforms
*{			The directives *:KEYWIN, *:KEYMAC, *:KEYDOS and *:KEYUNIX
*{			all allow the user identify different key labels depending on the
*{			PLATFORM the user is on.
*{			This is done in the first pass so that tools such as AUTOHOT are useful!
*{ 			To activate this function, place *:XPLATKEYS in the Setup of the menu
*{			of the CONFIG.FP file.
*{ 05/13/95	Version Control directive : *:AUTO_VER
*{			This directive (originally conceived by Matt Peirse) will turn a menu
*{			into a simply command.
*{			If this directive is in the Setup snippet then GENMENU is NEVER called
*{			instead the output goes to the MPR file and it updates a version number
*{			To make use of it in a program, the procedure file should include a
*{			<< >> identifier such as
*{			WAIT WINDOW "The version number is "+LTRIM(STR(<<prompt>>))
*{ 05/13/95	DEFCOMMAND is a new Setup directive that allows you to PREDEFINE
*{			global command statements for use within GENMENUX.
*{			It comes in two flavours DEFCOMMAND_ALWAYS and DEFCOMMAND_INCLUDE
*{			ALWAYS replaces existing code
*{			INCLUDE only does it to undefined code
*{ 05/13/95	Directive BASEHDR allows users to identify a program that contains
*{			all of their standard settings for a header.
*{			They can specify this in the CONFIG.FP file
*{ 05/15/95	AUTOVER now works properly and if there is any text in the comment snippet
*{			It will attempt to run it.
*{			Also if in the comment snippet the code called resets the variable _UpdateVersion
*{			to .F., the version number will not be updated
*{ 07/06/95	KEYLAB will update the KEY LABEL statement to a variable as the
*{			menu building does not allow you to do this on your own.
*{***************************
*{ RELEASE OF VERSION 3.0
*{***************************
*{ 09/05/95	Fixes in Reordering menu to account for mixed case menu levels.
*{			Noted by Toni Taylor

PARAMETERS tcProjDbf, tnProjRecno

PRIVATE ALL LIKE j*, l*
*]      Definition of Directives
#DEFINE ccDelete "*:DELETE"
#DEFINE ccDelObj "*:DELOBJ"
#DEFINE ccMessage "*:MESSAGE"
#DEFINE ccIgnore "*:IGNORE"
#DEFINE ccMNXDRV1 "*:MNXDRV1"
#DEFINE ccMNXDRV2 "*:MNXDRV2"
#DEFINE ccMNXDRV3 "*:MNXDRV3"
#DEFINE ccMNXDRV4 "*:MNXDRV4"
#DEFINE ccMNXDRV5 "*:MNXDRV5"
#DEFINE ccMPRDRV1 "*:MPRDRV1"
#DEFINE ccMPRDRV2 "*:MPRDRV2"
#DEFINE ccMNXDRV0 "*:MNXDRV0"
#DEFINE ccMMNXDRV0 "_MNXDRV0"
#DEFINE ccmMnxDRV1 "_MNXDRV1"
#DEFINE ccmMnxDRV2 "_MNXDRV2"
#DEFINE ccmMnxDRV3 "_MNXDRV3"
#DEFINE ccmMnxDRV4 "_MNXDRV4"
#DEFINE ccmMnxDRV5 "_MNXDRV5"
#DEFINE ccmMPRDRV1 "_MPRDRV1"
#DEFINE ccmMPRDRV2 "_MPRDRV2"
#DEFINE ccColorSet "*:COLORSET"
#DEFINE ccColor "*:COLOR"
#DEFINE ccMenuName "*:MENUNAME"
#DEFINE ccDefault "*:SYSDEFAULT"
#DEFINE ccRowofStars "******************************************"
#DEFINE ccCaseHdr ccRowOfStars+CHR(13)+[** Menu CASE Statement (GENMENUX 3.0a ]+CHR(13)
#DEFINE ccMenuxHdr CHR(13)+"** Menu Builder Enhancements by GENMENUX 3.0a  **"+CHR(13)
#DEFINE ccMenuxNote CHR(13)+"** This file has been modified using "
#DEFINE ccMenuXFtr CHR(13)+"**   GENMENUX 3.0a   - FoxPro Menu Processor **"+CHR(13)
#DEFINE ccMNXTItle "GENMENUX - FoxPro Menu Processor"
#DEFINE ccMNXVer "Version 3.0a  "
#DEFINE ccNoShadow "*:NOSHADOW"
#DEFINE ccNoMargin "*:NOMARGIN"
#DEFINE ccPopColor "*:POPCOLOR"
#DEFINE ccPadColor "*:PADCOLOR"
#DEFINE ccNoPadCol "*:NOPADCOLOR"
#DEFINE ccNoPopCol "*:NOPOPCOLOR"
#DEFINE ccMenuColor "*:MENUCOLOR"
#DEFINE ccMenuScheme "*:MENUSCHEME"
#DEFINE ccNoAuto "*:NOAUTO"
#DEFINE ccAutoHot "*:AUTOHOT"
#DEFINE ccNoPad "*:NOPAD"
#DEFINE ccPopFiles "*:POPFILES"
#DEFINE ccPopField "*:POPFIELD"
#DEFINE ccPopCommand "*:POPCOMMAND"
#DEFINE ccAutoRun "*:AUTORUN ON"
#DEFINE ccNoGen "*:NOGEN"
#DEFINE ccNoxGen "*:NOXGEN"
#DEFINE ccIFDir "*:IF"
#DEFINE ccGenIf "*:GENIF"
#DEFINE ccSysPop "*:SYSPOP"
#DEFINE ccmSysPop "_SYSPOP"
#DEFINE ccPopSys "POP MENU _MSYSMENU"
#DEFINE ccPushSys "PUSH MENU _MSYSMENU"
#DEFINE ccSetSys "SET SYSMENU TO DEFAULT"
#DEFINE ccBarHot "*:BARHOT"
#DEFINE ccMBarHot "_BARHOT"
#DEFINE ccHideMenu "*:HIDE"
#DEFINE ccMHideMenu "_HIDE"
#DEFINE ccAutoAct "*:AUTOACT"
#DEFINE ccMAutoAct "_AUTOACT"
#DEFINE ccFoundation "*:FOUNDATION"
#DEFINE ccMFoundation "_FOUNDATION"
#DEFINE ccPadPos "*:PADPOS"
#DEFINE ccPOPPOS "*:POPPOS"
#DEFINE ccSelectPad "*:SELECTPAD"
#DEFINE ccMSelectPad "_SELECTPAD"
#DEFINE ccVertical "*:VERTICAL"
#DEFINE ccMVertical "_VERTICAL"
#DEFINE ccSelectBar "*:SELECTBAR"
#DEFINE ccMSelectBar "_SELECTBAR"
#DEFINE ccPopTitle "*:POPTITLE"
#DEFINE ccPadName "*:PADNAME"
#DEFINE ccPopName "*:POPNAME"
#DEFINE ccTrnTxt "*:TRNTXT"
#DEFINE ccArray "*:ARRAY"
#DEFINE ccVariable "*:VARIABLE"
#DEFINE ccNoComment "*:NOCOMMENT"
#DEFINE ccMNoComment "_NOCOMMENT"
#DEFINE ccInScx "*:INSCX"
#DEFINE ccPopPreCommand "*:POPPRECOMMAND"
#DEFINE ccPopPreComm "*:POPPRECOMMAND"
#DEFINE ccNoAct "*:NOACT"
#DEFINE ccmNoAct "_NOACT"
#DEFINE ccCase "*:CASE"
#DEFINE ccBefore "*:BEFORE"
#DEFINE ccAfter "*:AFTER"
#DEFINE ccRefPrg "*:REFPRG"
#DEFINE ccMRefPrg "_REFPRG"
#DEFINE ccFont "*:FONT"
#DEFINE ccClause "*:CLAUSE"
#DEFINE ccSkipRedir "*:SKIP_REDIRECT"
#DEFINE ccSkipAuto "*:SKIP_AUTO"
#DEFINE ccNoLoc "*:NOLOC"
#DEFINE ccMNoLoc "_NOLOC"
#DEFINE ccPreDef "*:PREDEF"
#DEFINE ccWinKey	"*:KEYWIN"
#DEFINE ccMacKey	"*:KEYMAC"
#DEFINE ccUnixKey	"*:KEYUNIX"
#DEFINE ccDosKey	"*:KEYDOS"
#DEFINE ccWinPrompt
#DEFINE ccDosPrompt
#DEFINE ccUnixPrompt
#DEFINE ccMacPrompt
#DEFINE ccXplatKeys "*:XPLATKEYS"
#DEFINE ccMXPlatKeys "_XPLATKEYS"
#DEFINE ccAutoVer "*:AUTOVERSION"
#DEFINE ccCommAll "*:DEFCOMMAND_ALWAYS"
#DEFINE ccCommInc "*:DEFCOMMAND_INCLUDE"
#DEFINE ccMCommAll "_DEFCOMMAND_ALWAYS"
#DEFINE ccMCommInc "_DEFCOMMAND_INCLUDE"
#DEFINE ccMBaseHdr "_BASEHDR"
#DEFINE ccKeyLab "*:KEYLAB"

*] Menu Template Directives
#DEFINE ccDefLib "*:DEFLIB"
#DEFINE ccMDefLib "_DEFLIB"
#DEFINE ccBasLib "*:BASLIB"
#DEFINE ccMBasLib "_BASLIB"
#DEFINE ccIncLib "*:INCLIB"
#DEFINE ccmIncLib "_INCLIB"
#DEFINE ccInsObj "*:INSOBJ"
#DEFINE ccdefObj "*:DEFOBJ"
#DEFINE ccAutoWin "*:AUTOWIN"
#DEFINE ccAutoPos "*:AUTOPOS"
#DEFINE ccQuickDef "*:DEFPOPIF"
#DEFINE ccLocation "*:LOCATION"
#DEFINE ccNoXTherm "*:NOXTHERM"
#DEFINE ccMNoxTherm "_NOXTHERM"
** Note that these next two are interdependent
** You have to have BAR in order to have a LINE
#DEFINE ccLine "*:LINE"
#DEFINE ccNoBar "*:NOBAR"
#DEFINE ccWindow "*:WINDOW"

*] Menu Object Definitions
#DEFINE ccMenuPad 77
#DEFINE ccMenuComm 67
#DEFINE ccMenuFile 1
#DEFINE ccMenuPopup 2
#DEFINE ccMenuItem 3
#DEFINE ccMenuSubMenu 77
#DEFINE ccMenuProc 80
#DEFINE ccMenuBar 78
*] Default Menu Insertions
#DEFINE ccPadHotKey "ALT+"
#DEFINE ccBarHotKey "CTRL+"

*] Definition of Various objCode Settings
#DEFINE ccSubMenu 77
#DEFINE ccCommand 67
#DEFINE ccProc 80
#DEFINE ccBar 78

*] ASCII Definitions
#DEFINE ccReturn CHR(13)
#DEFINE ccTab CHR(9)
#DEFINE ccNull CHR(0)
#DEFINE ccLineFeed CHR(10  )
#DEFINE ccNewLine ccReturn+ccLineFeed

*] Standard GENMENU Definitions
#DEFINE c_ui_whereisLOC         "WHERE is"

*] Definition of Standard statements
#DEFINE ccReadFound "READ "
#DEFINE ccFxColSet "COLOR SCHEME "
#DEFINE ccFxColPair "COLOR "
#DEFINE ccEndIf "ENDIF"+ccReturn + ccReturn
#DEFINE ccIf ccReturn+"IF "

*} Definition of Menu Template File
#DEFINE ccFoxMNX "*:FOXMNX"
#DEFINE ccMFoxMNX "_FOXMNX"


*] Keyword Definitions
#DEFINE ccKeyPrompt "*PROMPT*"
#DEFINE ccKeyName "*NAME*"
#DEFINE ccKeyLevel "*LEVEL*"
#DEFINE ccKeyItem "*ITEMNUM*"

PRIVATE ALL LIKE last*

*{ 1/5/94 - Update from KL
m.lastselect=SELECT()
m.lastsetpath=SET('PATH')
m.lastpoint=SET('POINT')
SET POINT TO '.'
m.lastsetcomp=SET('COMPATIBLE')
SET COMPATIBLE OFF
m.lastsetexac=SET('EXACT')
SET EXACT OFF
m.lastsetsfty=SET('SAFETY')
SET SAFETY OFF
m.lastsetdel=SET('DELETED')
SET DELETED OFF
m.lastsetcry=SET('CARRY')
SET CARRY OFF
m.lastsetnear=SET('NEAR')
SET NEAR OFF
m.lastsetdec=SET('DECIMALS')
SET DECIMALS TO 9
m.lastsetexcl=SET('EXCLUSIVE')
SET EXCLUSIVE OFF
m.lastsetudfp=SET('UDFPARMS')
SET UDFPARMS TO VALUE
m.lastmemow=SET('MEMOWIDTH')

SET MEMOWIDTH TO 255

SET ESCAPE OFF

PRIVATE jgStatus, jWarnings, jPathFox
jgStatus=0
m.jWarnings=0
jPathFox=SYS(2004)

** Some generic variables
lcSkipProc = [SETSKIP]

** Save last message on SayTherm so we can use it to our advantage
PRIVATE lcLastSay
lcLastSay=[]

*] Private of thermometer Variables
PRIVATE gx_graphic,gx_thermWidth
IF _WINDOWS OR _MAC
	gx_graphic =.T.
	m.gx_thermWidth = 56.269
ELSE
	gx_graphic = .F.
	m.gx_thermWidth = 55
ENDIF

*] Define Post GENMENU Driver Defaults
lMprDrv1=' '
lMprDrv2=' '

*] Define Refresh Program File
lcRefPrg=[REFMENU.PRG]

jcCurrErr=ON("ERROR")
ON ERROR DO errorhnd WITH ERROR(),MESSAGE(),PROGRAM(),LINENO(),MESSAGE(1)

DIMENSION ja_file_ext(4)
ja_file_ext(1)='.EXE'
ja_file_ext(2)='.APP'
ja_file_ext(3)='.PRG'
ja_file_ext(4)='.FXP'

jfConfigFp=SYS(2019)
IF FILE(jfConfigFp)
	jnConfArea=SELECT()
	SELECT 0
	CREATE CURSOR CONFIGFP (FP       M)
	INSERT BLANK
	APPEND MEMO FP       FROM (jfConfigFp) OVERWRITE
	REPLACE FP       WITH evltxt(FP)
	SELECT (jnConfArea)
ELSE
	jfConfigFp=''
ENDIF
PRIVATE m.genmenux, m.genmenu, m.autoRun, m.fConfigFp
m.genmenux=IIF(TYPE('_GENMENUX')=='C',UPPER(_GENMENUX),configfp('GENMENUX','ON'))
m.genmenu=add_fext(configfp('_GENMENUX',jPathFox+'GENMENU.PRG'))
m.autorun=IIF(TYPE('_AUTORUN')=='C',UPPER(_AUTORUN),;
	configfp('AUTORUN','OFF'))

IF configfp(ccMNoXTherm,"OFF")="ON"
	llNoXTherm=.T.
ELSE
	llNoXTherm=.F.
ENDIF

*-- We should be in the pjxbase here
*-- Pointing at a menu file

*-- ... but to be safe
SELECT 0
USE ( m.tcProjDbf) ALIAS pjxbase AGAIN SHARED
jcprojpath = SUBSTR(m.tcprojdbf,1,RAT("\",m.tcprojdbf))
lcProjPath= jcProjPath
lcProjFile=TRIM(name)

GOTO tnProjRecNo

jnOldAlias  = SELECT()
jcProjAlias = ALIAS()
jnProjRec   = RECNO()

*-- A few things we need a lot of....
jcOutfile    = ALLTRIM( SUBSTR(outfile,1      ,AT(ccnull,outfile)-1))
jcOutfile = FULLPATH(jcoutfile, jcprojpath)
jcResultFile = STRTRAN( UPPER( jcOutfile), ".MPR", ".MPX")

IF [3.0]$ VERSION()
	lcMenuName = STRTRAN( UPPER( TRIM( TRIMPATH ( name))) , [.MNX] )
	lcMenuName = UPPER( LEFT( lcMenuName, LEN( lcMenuName) -1 ))
	lcOutMain = TRIM( outFile)
	lcOutMain = UPPER( LEFT( lcOutMain, LEN( lcOutMain) -1 ))

	lcOutMain = ALLTRIM(SUBSTR(outfile,1, AT( ccnull , outfile)-1))
	lcOutMain = FULLPATH( lcOutMain, lcProjPath)
	IF _MAC AND RIGHT( lcOutMain ,1) = ":"
	   lcOutMain = lcOutMain + justfname(SUBSTR(outfile,1, AT( ccnull,outfile)-1))
	ENDIF
	lcMenuName = FULLPATH(ALLTRIM(name), lcProjPath)
	IF _MAC AND RIGHT(lcMenuName,1) = ":"
	   lcMenuName = lcMenuName + justfname(name)
	ENDIF
	lcMenuBase = basename( lcMenuName )

ELSE
	lcMenuName = STRTRAN( UPPER( TRIM( TRIMPATH ( name))) , [.MNX] )
	lcMenuName = UPPER( LEFT( lcMenuName, LEN( lcMenuName) -1 ))
	lcOutMain = TRIM( TRIMPATH (outFile))
	lcOutMain = UPPER( LEFT( lcOutMain, LEN( lcOutMain) -1 ))

	lcMenuBase = basename( lcMenuName )

ENDIF



IF '\\'$jcOutFile
	jcOutFile=STRTRAN(jcOutFile,'\\','\')
ENDIF

** IF LEN(jcOutFile)>50
** 	jcOutFile=LEFT(jcOutFile,50)+"..."
** ENDIF
jcWait = "GENMENUX : Menu " + IIF(LEN(jcOutFile)>50,'...'+RIGHT(jcOutfile,41),jcOutFile)
jcCursor=SET("CURSOR")
SET CURSOR OFF
DO actTherm WITH jcWait
DO updTherm WITH 10

*-- Create a temporary project
jcTProj    = uniqueFlnm()
jcTProjExt = jcTProj + ".PJX"

** Find out TEMPFILES setting in CONFIG.FP
jcTmpDir=configfp("TMPFILES")
*! Ignoring Mac because this has caused some problems
IF NOT EMPTY(jcTmpDir) AND NOT _MAC
	jcTProjExt=jcTmpDir+IIF(RIGHT(jcTmpDir,1)=[\],[],[\])+jcTProjExt
ENDIF
COPY TO ( jcTProjExt) FOR TYPE = "H"
*-- Replace the pointer
GOTO jnProjRec

*-- Copy the menu file to a temp
DO sayTherm WITH "Creating Temporary Files "
jcMaster   = TRIM( pjxbase.Name)
IF '\\'$jcMaster
	jcMaster=STRTRAN(jcMaster,'\\','\')
ENDIF
 IF NOT FILE(jcMaster)
	jcMaster= FULLPATH(ALLTRIM(pjxBase.name), lcProjFile)
ENDIF
m.lcMNX_Name=JUSTFNAME(ALLTRIM(pjxBase.name))
jcTName    = uniqueFlnm()
jcTNameExt = jcTname + ".MNX"
IF NOT EMPTY(jcTmpDir) AND NOT _MAC
	jcTNameExt=jcTmpDir+"\"+jcTNameExt
ENDIF

*{ 1/6/94
** IF NOT FILE(jcMaster) AND FILE(FULLPATH(jcMaster))
**	jcMaster=FULLPATH(jcMaster)
** ENDIF
*}
jcMaster=FULLPATH(jcMaster)
** g_mnxfile[1] = FULLPATH(ALLTRIM(name), m.g_projpath)
jcMaster=FULLPATH(jcMaster, m.lcProjPath)
IF '\\'$jcMaster
	IF SUBSTR(jcMaster,2,1)==':'
    	jcMaster=LEFT(jcMaster,2)+'\'+trimpath(jcMaster)
	ELSE
		jcMaster='\'+trimpath(jcMaster)
	ENDIF
ENDIF

*{ 05/13/95	ARMACNEILL
*{ Check in VFP to see if we can restore errors here.
jcErr=ON("ERROR")
ON ERROR notOpened=.T.
notOpened=.F.

SELECT 0
USE (jcMaster) SHARED AGAIN

IF notOpened
	USE (FULLPATH(TRIMPATH(jcMaster),CURDIR())) AGAIN SHARED
ENDIF

ON ERROR &jcErr

COPY TO ( jcTNameExt)

USE ( jcTNameExt)

*] Preliminary Setup Directives
GO TOP

** Defaults
IF NOT EMPTY(configfp( ccMBaseHdr,""))
	jcText=configfp(ccMBaseHdr)
	IF FILE(jcText)
    	APPEND MEMO setup FROM (jcText )
    ENDIF
ENDIF


IF ccAutoVer$ UPPER (setup) OR ccAutoVer $ UPPER (procedure)
	** This is the automatic version numbering routine
	DO sayTherm WITH "Building build number menu..."
	** Let's use it!!!!
	SET TEXTMERGE TO (jcOutFile) NOSHOW
	SET TEXTMERGE ON
	
	notOpened=.F.
	jcErr=ON("ERROR")
	ON ERROR notOpened=.T.
	SELECT 0
	USE (jcMaster) SHARED AGAIN

	IF notOpened
		USE (FULLPATH(TRIMPATH(jcMaster),CURDIR())) AGAIN SHARED
	ENDIF
	ON ERROR &jcErr
	
	LOCATE FOR objtype = ccMenuItem
	
	** REPLACE Prompt WITH LTRIM(STR(1 + VAL(prompt)))

	_UpdateVersion=.T.

      ** _UpdateVersion=.T.

      *&* >L< change
      *&* notice that I am not REPLACing Prompt up-top

       IF .F.  && Andrew
         ** run code identified in comment snippet
              FOR jni=1 TO MEMLINES(comment)
                jcLine=MLINE(comment,jni)
                &jcLine
              ENDFOR
       ELSE      && >L< version
          IF NOT EMPTY(comment)
             * you can add additional stuff to do in here!!
             PRIVATE m.proc, m.olderr
             m.proc = SYS(3)+".PRG"
             DO WHILE FILE(m.proc)
               *&* highly unlikely, but <g>...
                 m.proc = SYS(3)+".PRG"
             ENDDO
             COPY MEMO comment TO (m.proc)
             m.olderr = ON("ERROR")
             ON ERROR WAIT WINDOW "Custom Build Error!" NOWAIT
             DO (m.proc)
             IF FILE(STRTRAN(m.proc,"PRG", "ERR"))
                ERASE (STRTRAN(m.proc,"PRG", "ERR"))
                WAIT WINDOW "Custom Build procedure had errors!"
                *&* yes, there are other ways for the
                *&* procedure to fail, but the proc itself
                *&* can and should handle its own errors...
             ENDIF
             ERASE (m.proc)
             ERASE (STRTRAN(m.proc,"PRG","FXP"))
             ON ERROR &olderr

             REPLACE Prompt WITH Prompt
             *&* just to make sure it updates with
             *&* every build, even if your prg in Comment
             *&* forgets to change the MNX directly
             *&* and still sets _UpdateVersion to .F.
             *&* for some off-the-wall reason...

             *&* -- the point here is that we want
             *&* AUTO_VER regenerated *on every build*,
             *&* that's the guaranteed effect, no matter
             *&* what else you figure out to have the Comment do.
             *&* I've had it scan through the project and do
             *&* tasks completely unrelated to versioning!!
          ENDIF
       ENDIF
       *&*

      IF _UpdateVersion
          *&* didn't get reset in the Comments procedure
          REPLACE Prompt WITH LTRIM(STR(1 + VAL(prompt)))
      ENDIF

     \       <<procedure>>
     \

	
	\<<procedure>>
	\

	SET TEXTMERGE TO
	SET TEXTMERGE OFF

	USE
	
	
	DO cleanup
	
	COMPILE (jcOutFile)
	
	RETURN 0
ENDIF

** Set up CASE Statement variable
llCase=.F.
** llNoXGen contains True/False depending on what is to be updated.
llNoGen=.F.
IF ccNoXGen$setup OR ccNoXGen$PROCEDURE
	IF ccNoGen$Setup OR ccNoGen$PROCEDURE
		llNoGen=.T.
	ELSE
		llNoGen=.F.
	ENDIF
	llnoxGen=.T.
ELSE
	llNoXGen=.F.
ENDIF

IF llNoXGen
	jcTProj    = tcProjDbf
	jcTProjExt = tcProjDbf
ENDIF

IF ccNoXTherm$setup OR ccNoXTherm$PROCEDURE
	llNoXTherm=.T.
ELSE
	IF configfp(ccMNoXTherm,"OFF")="ON"
		llNoXTherm=.T.
	ELSE
		llNoXTherm=.F.
	ENDIF
ENDIF

IF ccXplatKeys$ UPPER( setup)  OR ccXplatKeys$ UPPER( procedure )
	llXPlatKeys=.T.
ELSE
	IF configfp(ccMXPlatKeys,"OFF")="ON"
		llXPlatKeys =.T.
	ELSE
		llXPlatKeys =.F.
	ENDIF
ENDIF

IF ccRefPrg$setup OR ccRefPrg$PROCEDURE
	DO CASE
		CASE ccRefPrg$setup
			lcRefPrg=wordSearch(ccRefPrg,[setup])
		CASE ccRefPrg$Procedure
			lcRefPrg=wordSearch(ccRefPrg,[procedure])
	ENDCASE
	IF lcRefPrg=ccNull OR EMPTY(lcRefPrg)
		lcRefPrg=[REFMENU.PRG]
	ENDIF
	llRefPrg=.T.
ELSE
	lcRefPrg=configfp(ccMRefPrg,"OFF")
	IF lcRefPrg=[OFF] OR lcRefPrg=ccNull OR EMPTY(lcRefPrg)
		llRefPrg=.F.
	ELSE
		llRefPrg=.T.
	ENDIF
ENDIF

IF llRefPrg
	IF ATC(".",lcRefPrg)=0
		lcRefPrg=FORCEEXT(lcRefPrg,"PRG")
	ENDIF
	IF FILE(lcRefPrg)
		=WARNING([Refresh Menu Program exists. GENMENUX will delete!])
		IF FILE(lcRefPrg)
			ERASE (lcRefPrg)
		ENDIF
	ENDIF
ENDIF

IF llNoxGen
	SELECT PjxBase
	GO tnProjRecno
ENDIF

*{ 05/13/95	NOLOC removes the LOCFILE statement!
IF ccNoLoc $ UPPER(setup) OR ccNoLoc $ UPPER(PROCEDURE)
	llNoLoc=.T.
ELSE
	IF configfp( ccMNoLoc ,"OFF")="ON"
		llNoLoc=.T.
	ELSE
		llNoLoc=.F.
	ENDIF
ENDIF


IF NOT llNoxGen
	REPLACE setup WITH setup + ccReturn+ccRowOfStars+ccReturn+ccMenuxHdr+ccMenuxNote+ccMenuxFtr

	** CHANGE Location Parameter OF MENU
	IF ccLocation$UPPER(setup) OR ccLocation$UPPER(PROCEDURE)
		IF ccLocation$UPPER(setup)
			jcLoc=wordsearch(ccLocation,"setup")
		ELSE
			jcLoc=wordSearch(ccLocation,"procedure")
		ENDIF
		IF NOT jcLoc=CHR(0)
			DO CASE
				CASE UPPER(jcLoc)='REPLACE'
					REPLACE location WITH 0
				CASE UPPER(jcLoc)='APPEND'
					REPLACE location WITH 1
				OTHERWISE
					DO CASE
						CASE 'BEFORE'$UPPER(jcLoc)
							REPLACE location WITH 2
							REPLACE Name WITH fMnuName(ALLTRIM(STRTRAN(UPPER(jcLoc),"BEFORE")))
						CASE 'AFTER'$UPPER(jcLoc)
							REPLACE location WITH 3
							REPLACE Name WITH fMnuName(ALLTRIM(STRTRAN(UPPER(jcLoc),"AFTER")))
					ENDCASE
			ENDCASE
		ENDIF

	ENDIF

	IF ccSkipRedir$UPPER(setup) OR ccSkipRedir$UPPER(procedure)
		IF ccSkipRedir$UPPER(setup)
			lcSkipProc=wordsearch(ccSkipRedir,"setup")
			IF lcSkipProc = CHR(0) OR EMPTY( lcSkipProc)
				lcSkipProc = [SETSKIP]
			ENDIF
			REPLACE setup WITH strtranc(setup,ccSkipRedir,"*-:"+SUBSTR(ccSkipRedir,3      ,LEN(ccSkipRedir)))
		ELSE
			** In procedure code
			lcSkipProc=wordsearch(ccSkipRedir,"procedure")
			IF lcSkipProc = CHR(0) OR EMPTY( lcSkipProc)
				lcSkipProc = [SETSKIP]
			ENDIF
			REPLACE procedure WITH strtranc(procedure,ccSkipRedir,"*-:"+SUBSTR(ccSkipRedir,3      ,LEN(ccSkipRedir)))
		ENDIF
		llSkipRedir=.T.
		
		IF ccSkipAuto $ UPPER( setup) OR ccSkipAuto $ UPPER( procedure)
			=addCleanup ( [DO ]+lcSkipProc+ccReturn+ccReturn )
			REPLACE procedure WITH strtranc(procedure, ccSkipAuto ,"*-:"+SUBSTR( ccSkipAuto,3      ,LEN(ccSkipAuto)))
			REPLACE setup WITH strtranc(setup,ccSkipAuto,"*-:"+SUBSTR( ccSkipAuto,3      ,LEN(ccSkipAuto)))
		ENDIF
		
	ELSE
		llSkipRedir=.F.
	ENDIF


	IF ccVertical$UPPER(setup) OR ccVertical$UPPER(PROCEDURE)
		llVertical=.T.
		IF ccVertical$UPPER(setup)
			lcStartPos=wordsearch(ccVertical,"setup")
			REPLACE setup WITH strtranc(setup,ccVertical,"*-:"+SUBSTR(ccVertical,3      ,LEN(ccVertical)))
		ELSE
			lcStartPos=wordsearch(ccVertical,"procedure")
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccVertical,"*-:"+SUBSTR(ccVertical,3      ,LEN(ccVertical)))
		ENDIF
	ELSE
		IF configfp(ccMVertical,"OFF")="ON"
			llVertical=.T.
			lcStartPos='0,1'
		ELSE
			llVertical=.F.
		ENDIF
	ENDIF
	IF llVertical
		=addSetup(ccNoBar+ccReturn+ccAutoAct+ccReturn)
		** UPDATE MENU positions BY placing the  *:PADPOS directive ON each MENU PAD
		jnRec=RECNO()
		IF NOT TYPE("lcStartPos")='U'
			IF OCCURS(",",lcStartPos)>0
				lcSkipRow=VAL(SUBSTR(lcStartPos,ATC(',',lcStartPos)+1,LEN(lcStartPos)-ATC(',',lcStartPos)))
				IF lcSkipRow=0
					lcSkipRow=1
				ENDIF
			ELSE
				lcSkipRow=1
			ENDIF
			jnStartRow=VAL(lcStartPos)
		ELSE
			jnStartRow=0
		ENDIF
		jnStartCol=0
		SCAN FOR levelName='_MSYSMENU' AND objType=3
			DO esc_check
			IF ccIgnore$comment
				LOOP
			ENDIF
			REPLACE comment WITH ccPadPos+" "+LTRIM(STR(jnstartRow))+","+LTRIM(STR(jnStartCol))+ccReturn+comment
			jnStartRow=jnStartRow+lcSkipRow
			jnStartCol=jnStartCol
		ENDSCAN
		jnStartCol=jnStartCol+10
		jnStartRow=VAL(lcStartPos)
		SCAN FOR NOT levelName='_MSYSMENU' AND VAL(itemnum)=1
			IF ccIgnore$comment
				LOOP
			ENDIF
			REPLACE comment WITH ccPOPPOS+" "+LTRIM(STR(jnStartRow))+","+LTRIM(STR(jnStartCol))+ccReturn+comment
			jnStartRow=jnStartRow+lcSkipRow
		ENDSCAN
		GO (jnRec)
	ENDIF

	IF ccAutoAct$UPPER(setup) OR ccAutoAct$UPPER(PROCEDURE)
		REPLACE setup WITH strtranc(setup,ccAutoAct,"*-:"+SUBSTR(ccAutoAct,3      ,LEN(ccAutoAct)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccAutoAct,"*-:"+SUBSTR(ccAutoAct,3      ,LEN(ccAutoAct)))
		=AddCleanup("ACTIVATE MENU _MSYSMENU")
	ELSE
		IF configfp(ccmAutoAct,"OFF")="ON"
			=AddCleanup("ACTIVATE MENU _MSYSMENU")
		ENDIF
	ENDIF

	IF ccNoAct$UPPER(setup) OR ccNoAct$UPPER(PROCEDURE)
		REPLACE setup WITH strtranc(setup,ccNoAct,"*-:"+SUBSTR(ccNoAct,3      ,LEN(ccNoAct)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoAct,"*-:"+SUBSTR(ccNoAct,3      ,LEN(ccNoAct)))
		llNoAct=.T.
	ELSE
		IF configfp(ccmNoAct,"OFF")="ON"
			llNoAct=.T.
		ELSE
			llNoAct=.F.
		ENDIF
	ENDIF


	jcDefComm= []
	jcDefComm = configfp (ccMCommAll,"")
	
	IF ccCommAll$ UPPER(procedure)
		jcDefComm = wordSearch (ccCommAll, "procedure")
	ENDIF
	IF ccCommAll$ UPPER(setup)
		jcDefComm = wordSearch (ccCommAll, "setup")
	ENDIF
	
	jcDefComI= []
	jcDefComI = configfp (ccMCommInc,"")
	IF ccCommInc$ UPPER(procedure)
		jcDefComI = wordSearch ( ccCommInc, "procedure")
	ENDIF
	IF ccCommInc$ UPPER(setup)
		jcDefComI = wordSearch ( ccCommInc, "setup")
	ENDIF
	
	IF ccDefault$UPPER(setup) OR ccDefault$UPPER(PROCEDURE)
		REPLACE Cleanup WITH ccReturn ;
			+ "SET SYSMENU SAVE"+ccReturn+Cleanup
		REPLACE setup WITH strtranc(setup,ccDefault,"*-:"+SUBSTR(ccDefault,3      ,LEN(ccDefault)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccDefault,"*-:"+SUBSTR(ccDefault,3      ,LEN(ccDefault)))
	ENDIF

	IF ccNoShadow$UPPER(setup) OR ccNoShadow$UPPER(PROCEDURE)
		llNoShadow=.T.
		REPLACE setup WITH strtranc(setup,ccNoShadow,"*-:"+SUBSTR(ccNoShadow,3      ,LEN(ccNoShadow)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoShadow,"*-:"+SUBSTR(ccNoShadow,3      ,LEN(ccNoShadow)))
	ELSE
		llNoShadow=.F.
	ENDIF

	IF ccNoMargin$UPPER(setup) OR ccNoMargin$UPPER(PROCEDURE)
		llNoMargin=.T.
		REPLACE setup WITH strtranc(setup,ccNoMargin,"*-:"+SUBSTR(ccNoMargin,3      ,LEN(ccNoMargin)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoMargin,"*-:"+SUBSTR(ccNoMargin,3      ,LEN(ccNoMargin)))
	ELSE
		llNoMargin=.F.
	ENDIF
	IF ccSysPop$UPPER(setup) OR ccSysPop$UPPER(PROCEDURE)
		llSysPop=.T.
		REPLACE setup WITH strtranc(setup,ccSysPop,"*-:"+SUBSTR(ccSysPop,3      ,LEN(ccSysPop)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccSysPop,"*-:"+SUBSTR(ccSysPop,3      ,LEN(ccSysPop)))
	ELSE
		IF configfp(ccMSysPop,"OFF")="ON"
			llSysPop=.T.
		ELSE
			llSysPop=.F.
		ENDIF
	ENDIF

	IF ccNoComment$UPPER(setup) OR ccNoComment$UPPER(PROCEDURE)
		llNoComment=.T.
		REPLACE setup WITH strtranc(setup,ccNoComment,"*-:"+SUBSTR(ccNoComment,3      ,LEN(ccNoComment)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoComment,"*-:"+SUBSTR(ccNoComment,3      ,LEN(ccNoComment)))
	ELSE
		IF configfp(ccMNoComment,"OFF")="ON"
			llNoComment=.T.
		ELSE
			llNoComment=.F.
		ENDIF
	ENDIF

	IF ccInScx$UPPER(setup) OR ccInScx$UPPER(PROCEDURE)
		IF ccInScx$UPPER(setup)
			lcScxFile=wordSearch(ccInScx,"setup")
			REPLACE setup WITH strtranc(setup,ccInScx,"*-:"+SUBSTR(ccInScx,3      ,LEN(ccInScx)))
		ELSE
			lcScxFile=wordSearch(ccInScx,"procedure")
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccInScx,"*-:"+SUBSTR(ccInScx,3      ,LEN(ccInScx)))
		ENDIF
		IF lcScxFile=ccnull

		ELSE
			** Strip out  any  additional clauses FROM lcScFile IF it   exists
			IF OCCURS(" ",ALLTRIM(lcScxFile))>0
				lcScxClause=UPPER(TRIM(SUBSTR(lcScxFile,AT(" ",lcScxFile,1),LEN(lcScxFile))))
				lcScxFile=STRTRAN(UPPER(lcScxFile),UPPER(lcScxClause))
			ELSE
				lcScxClause=ccNull
			ENDIF
			** SELECT SCREEN FILE (IF possible) AND place DO xxx.mpr AT the
			** BOTTOM OF the  SETUP clause.
			lcScxFile=FORCEEXT(lcScxFile,"SCX")
			IF FILE(lcScxFile)
				jnMnxArea=SELECT()
				SELECT 0
				USE (lcScxFile) ALIAS scxFile
				LOCATE FOR objType=1
				jcClause="DO "+JUSTFNAME(jcOutFile)
				** IF the  MenuxHeader is   IN the  setup code, the  process will NOT run.
				IF ATLINE(ccMenuXHdr,UPPER(setupCode))=0
					IF "SAVE"$lcScxClause
						jcNewLine=ccMenuxHdr+ccReturn+ccPushSys+ccReturn+jcClause+ccReturn
						REPLACE procCode WITH STRTRAN(procCode,ccMenuxHdr+ccReturn+ccPopSys)
						REPLACE procCode WITH ccMenuxHdr+ccReturn+ccPopSys+ccReturn+proccode
						IF "MODAL"$lcScxClause
							REPLACE WHEN WITH STRTRAN(WHEN,jcNewLine)
							REPLACE WHEN WITH ccReturn+jcNewLine+WHEN
							REPLACE whenType WITH 1
							REPLACE DEACTIVATE WITH STRTRAN(DEACTIVATE,ccMenuxHdr+ccReturn+ccPopSys)
							REPLACE DEACTIVATE WITH ccReturn+ccMenuxHdr+ccReturn+ccPopSys+ccReturn+DEACTIVATE
							REPLACE deactType WITH 1
						ELSE
							REPLACE setupcode WITH STRTRAN(setupcode,jcNewLine)
							REPLACE setupcode WITH setupcode+ccReturn+jcNewLine
						ENDIF
					ELSE
						jcNewLine=ccMenuxHdr+ccReturn+jcClause
						REPLACE setupcode WITH STRTRAN(setupcode,jcNewLine)
						REPLACE setupcode WITH setupcode+ccReturn+jcNewLine
					ENDIF
				ENDIF
				USE
				SELECT (jnMnxArea)
			ELSE
				** Cannot DO it.
			ENDIF
		ENDIF
	ELSE
		lcScxFile=ccNull
	ENDIF

	IF ccHideMenu$UPPER(setup) OR ccHideMenu$UPPER(PROCEDURE)
		REPLACE setup WITH strtranc(setup,ccHideMenu,"*-:"+SUBSTR(ccHideMenu,3      ,LEN(ccHideMenu)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccHideMenu,"*-:"+SUBSTR(ccHideMenu,3      ,LEN(ccHideMenu)))
		REPLACE setup WITH ccNoAuto+ccReturn+setup+ccReturn+"HIDE MENU _MSYSMENU SAVE"
		REPLACE cleanup WITH "SHOW MENU _MSYSMENU"+ccReturn+cleanup
	ELSE
		IF configfp(ccMHideMenu,"OFF")="ON"
			REPLACE setup WITH setup+ccReturn+"HIDE MENU _MSYSMENU"
			REPLACE cleanup WITH "SHOW MENU _MSYSMENU"+ccReturn+cleanup
		ENDIF
	ENDIF

	IF ccBarHot$UPPER(setup) OR ccBarHot$UPPER(PROCEDURE)
		llbarHot=.T.
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccBarHot,"*-:"+SUBSTR(ccBarHot,3      ,LEN(ccBarHot)))
		REPLACE setup WITH strtranc(setup,ccBarHot,"*-:"+SUBSTR(ccBarHot,3      ,LEN(ccBarHot)))
	ELSE
		IF configfp(ccMBarHot,"OFF")="ON"
			llBarHot=.T.
		ELSE
			llBarHot=.F.
		ENDIF
	ENDIF

	IF ccFoxMNX$(setup) OR ccFoxMNX$UPPER(PROCEDURE)
		llFoxMnx=.T.
		*{ 04/02/94 ARMACNEILL - Bug fix put in
		IF ccFoxMnx$(setup)
			lcFoxMnx=wordsearch(ccFoxMnx,"setup")
		ELSE
			lcFoxMnx=wordsearch(ccFoxMnx,"procedure")
		ENDIF
		REPLACE setup WITH strtranc(setup,ccFoxMNX,"*-:"+SUBSTR(ccFoxMNX,3      ,LEN(ccFoxMNX)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccFoxMNX,"*-:"+SUBSTR(ccFoxMNX,3      ,LEN(ccFoxMNX)))
	ELSE
		lcFoxMNX=configfp(ccmFoxMNX,"")
		IF EMPTY(lcFoxMNX)
			llFoxMNX=.F.
		ELSE
			llFoxMNX=.T.
		ENDIF
	ENDIF
	IF llFoxMnx
		IF NOT FILE(lcFoxMNX)
			** CREATE MENU Template FILE
			=fMakeMNX(lcFoxMNX)
		ENDIF
	ENDIF

	lcDefLib=''
	IF ccDefLib$UPPER(setup) OR ccDefLib$UPPER(PROCEDURE)
		IF ccDefLib$UPPER(setup)
			lcDefLib=wordSearch(ccDefLib,"setup")
			REPLACE setup WITH strtranc(setup,ccDefLib,"*-:"+SUBSTR(ccDefLib,3      ,LEN(ccDefLib)))
		ELSE
			lcDefLib=wordSearch(ccDefLib,"procedure")
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccDefLib,"*-:"+SUBSTR(ccDefLib,3      ,LEN(ccDefLib)))

		ENDIF
	ELSE
		lcDefLib=configfp(ccmDefLib,"")
		IF EMPTY(lcDefLib)
			lcDefLib=''
		ENDIF
	ENDIF

	lcBasLib=''
	IF ccIncLib$UPPER(setup) OR ccIncLib$UPPER(PROCEDURE)
		IF ccIncLib$UPPER(setup)
			lcBasLib=wordSearch(ccIncLib,"setup")
			REPLACE setup WITH strtranc(setup,ccIncLib,"*-:"+SUBSTR(ccIncLib,3      ,LEN(ccIncLib)))
		ELSE
			lcBasLib=wordSearch(ccIncLib,"procedure")
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccIncLib,"*-:"+SUBSTR(ccIncLib,3      ,LEN(ccIncLib)))

		ENDIF
	ELSE
		lcBasLib=configfp(ccMIncLib,"")
		IF EMPTY(lcBasLib)
			lcBasLib=''
		ENDIF
	ENDIF

	IF ccNoBar$UPPER(setup) OR ccNoBar$UPPER(PROCEDURE)
		llNoBar=.T.
		REPLACE setup WITH strtranc(setup,ccNoBar,"*-:"+SUBSTR(ccNoBar,3      ,LEN(ccNoBar)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoBar,"*-:"+SUBSTR(ccNoBar,3      ,LEN(ccNoBar)))
	ELSE
		llNoBar=.F.
	ENDIF

	IF ccNoAuto$UPPER(setup) OR ccNoAuto$UPPER(PROCEDURE)
		llNoAuto=.T.
		REPLACE setup WITH strtranc(setup,ccNoAuto,"*-:"+SUBSTR(ccNoAuto,3      ,LEN(ccNoAuto)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccNoAuto,"*-:"+SUBSTR(ccNoAuto,3      ,LEN(ccNoAuto)))
	ELSE
		llNoAuto=.F.
	ENDIF

	IF ccAutoRun$UPPER(setup) OR m.autoRun='ON' OR ccAutoRun$UPPER(PROCEDURE)
		llAutoRun=.T.
		REPLACE setup WITH strtranc(setup,ccAutoRun,"*-:"+SUBSTR(ccAutoRun,3      ,LEN(ccAutoRun)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccAutoRun,"*-:"+SUBSTR(ccAutoRun,3      ,LEN(ccAutoRun)))
	ELSE
		llAutoRun=.F.
	ENDIF

	IF ccNoGen$UPPER(setup) OR ccNoGen$UPPER(PROCEDURE)
		llNoGen=.T.
		REPLACE setup WITH strtranc(setup,ccAutoRun,"*-:"+SUBSTR(ccAutoRun,3      ,LEN(ccAutoRun)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccAutoRun,"*-:"+SUBSTR(ccAutoRun,3      ,LEN(ccAutoRun)))
	ELSE
		llNoGen=.F.
	ENDIF

	IF ccAutoHot$UPPER(setup) OR ccAutoHot$UPPER(PROCEDURE)
		llAutoHot=.T.
		REPLACE setup WITH strtranc(setup,ccAutoHot,"*-:"+SUBSTR(ccAutoHot,3      ,LEN(ccAutoHot)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccAutoHot,"*-:"+SUBSTR(ccAutoHot,3      ,LEN(ccAutoHot)))
	ELSE
		IF configfp("_AUTOHOT","OFF")="ON"
			llAutoHot=.T.
		ELSE
			llAutoHot=.F.
		ENDIF
	ENDIF

	IF ccSelectPad$UPPER(setup) OR ccSelectPad$UPPER(PROCEDURE)
		llSelectPad=.T.
		REPLACE setup WITH strtranc(setup,ccSelectPad,"*-:"+SUBSTR(ccSelectPad,3      ,LEN(ccSelectPad)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccSelectPad,"*-:"+SUBSTR(ccSelectPad,3      ,LEN(ccSelectPad)))
	ELSE
		IF configfp(ccMSelectPad,"OFF")="ON"
			llSelectPad=.T.
		ELSE
			llSelectPad=.F.
		ENDIF
	ENDIF

	IF ccSelectBar$UPPER(setup) OR ccSelectBar$UPPER(PROCEDURE)
		llSelectBar=.T.
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccSelectBar,"*-:"+SUBSTR(ccSelectBar,3      ,LEN(ccSelectBar)))
		REPLACE setup WITH strtranc(setup,ccSelectBar,"*-:"+SUBSTR(ccSelectBar,3      ,LEN(ccSelectBar)))
	ELSE
		IF configfp(ccMSelectBar,"OFF")="ON"
			llSelectBar=.T.
		ELSE
			llSelectBar=.F.
		ENDIF
	ENDIF

	IF ccFoundation$UPPER(setup) OR ccFoundation$UPPER(PROCEDURE)
		DO sayTherm WITH "Building foundation read..."
		IF ccFoundation$UPPER(setup)
			jClause=wordSearch(ccFoundation,"SETUP")
		ELSE
			jClause=wordSearch(ccFoundation,"PROCEDURE")
		ENDIF
		REPLACE setup WITH strtranc(setup,ccFoundation,"*-:"+SUBSTR(ccFoundation,3      ,LEN(ccFoundation)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccFoundation,"*-:"+SUBSTR(ccFoundation,3      ,LEN(ccFoundation)))
		IF EMPTY(ALLTRIM(STRTRAN(jClause," "))) OR jClause=CHR(0)
			jClause='INLIST(UPPER(PROMPT()),"EXIT","QUIT")'
		ENDIF
		=addCleanup(ccReadFound+" "+jClause,"TOP")
	ELSE
		IF configfp(ccMFoundation,"OFF")="ON"
			=addCleanup(ccReadFound+[ VALID INLIST(UPPER(PROMPT()),"EXIT","QUIT")],"TOP")
		ENDIF
	ENDIF

	IF ccAutoWin$UPPER(setup)
		jWinName=wordsearch(ccAutoWin,"setup")
		jStart="DEFINE WINDOW "+jWinName
		IF NOT "FROM"$jStart
			WAIT WINDOW NOWAIT "Define Window on screen and press F8 when completed"
			DEFINE WINDOW w_jTemp FROM 5,5    TO 10  ,25   FLOAT GROW
			ACTIVATE WINDOW w_jTemp
			READ VALID NOT INKEY()=-7
			jWlCol=WLCOL("W_JTEMP")
			jWlRow=WLROW("W_JTEMP")
			jWCols=LTRIM(STR(jWlCol+WCOLS("W_JTEMP")))
			jWRows=LTRIM(STR(jwlRow+WROWS("W_JTEMP")))
			jWlCol=LTRIM(STR(jWlCol))
			jWlRow=LTRIM(STR(jWlRow))
			RELEASE WINDOW w_jtemp
			WAIT CLEAR
			jWinCoords="FROM "+jWlRow+","+jWlCol+" TO "+jWRows+","+jWCols

			=addSetup(jStart+" "+jWinCoords+" SYSTEM")
			=addCleanup("ACTIVATE WINDOW "+jWinName,"Top")
			=addSetup(ccWindow+" "+jWinName)
		ELSE
			=addSetup(jStart)
			jWinName=ALLTRIM(jWinName)
			IF AT(" ",jWinName)>0
				jWinName=LEFT(jWinName,AT(' ',jWinName))
			ENDIF
			=addCleanup("ACTIVATE WINDOW "+jWinName,"Top")
			=addSetup(ccWindow+" "+jWinName)
		ENDIF
		** WAIT WINDOW
	ENDIF

	IF ccAutoPos$UPPER(setup) OR ccAutoPos$UPPER(PROCEDURE)
		** Allow developer TO identify position OF MENU BY pointing AND clicking
		WAIT WINDOW NOWAIT "Click on the position where you want to place the menu."
		HIDE WINDOW ALL
		READ VALID NOT INKEY()=-7
		SHOW WINDOW ALL
		WAIT CLEAR
		jLine=MROW()
		IF jLine>0
			=addSetup(ccLine+" "+LTRIM(STR(jLine)))
		ENDIF
	ENDIF

	IF ccWindow$UPPER(setup) OR ccWindow$UPPER(PROCEDURE)
		jWindow='WONTOP()'
		** Identify MNX    Driver
		IF ccWindow$UPPER(setup)
			jWindow=wordsearch(ccWindow,"setup")
		ELSE
			jWindow=wordSearch(ccWindow,"procedure")
		ENDIF
		jClauses=''
		IF AT('CLAUSES',jWindow)>0
			jClauses=SUBSTR(jWindow,AT("CLAUSES",jWindow),LEN(jWindow))
			jWindow=ALLTRIM(LEFT(jWindow,AT("CLAUSES",jWindow)-1))
		ENDIF
		IF NOT "SCREEN"$UPPER(jWindow) AND NOT "WINDOW"$UPPER(jWindow)
			jWindow='WINDOW '+jWindow
		ENDIF
		jWinName=STRTRAN(jWindow,"WINDOW")
		jClauses=STRTRAN(jClauses,"CLAUSES")
		IF "WINDOW"$jWindow AND NOT EMPTY(jClauses)
			jStart="DEFINE WINDOW "+jWinName+" "+jClauses
			IF NOT "FROM"$jStart
				WAIT WINDOW NOWAIT "Define Window on screen and press F8 when completed"
				DEFINE WINDOW w_jTemp FROM 5,5    TO 10  ,25   FLOAT GROW
				ACTIVATE WINDOW w_jTemp
				READ VALID NOT INKEY()=-7
				jWlCol=WLCOL("W_JTEMP")
				jWlRow=WLROW("W_JTEMP")
				jWCols=LTRIM(STR(jWlCol+WCOLS("W_JTEMP")))
				jWRows=LTRIM(STR(jwlRow+WROWS("W_JTEMP")))
				jWlCol=LTRIM(STR(jWlCol))
				jWlRow=LTRIM(STR(jWlRow))
				RELEASE WINDOW w_jtemp
				WAIT CLEAR
				jWinCoords="FROM "+jWlRow+","+jWlCol+" TO "+jWRows+","+jWCols

				=addSetup(jStart+" "+jWinCoords+" SYSTEM")
				=addCleanup("ACTIVATE WINDOW "+jWinName,"Top")
				** =addSetup(ccWindow+" "+jWinName)
			ELSE
				=addSetup(jStart)
				jWinName=ALLTRIM(jWinName)
				IF AT(" ",jWinName)>0
					jWinName=LEFT(jWinName,AT(' ',jWinName))
				ENDIF
				=addCleanup("ACTIVATE WINDOW "+jWinName,"Top")
				** =addSetup(ccWindow+" "+jWinName)
			ENDIF
		ENDIF
		** UPDATE ccPopColor Setup
		REPLACE setup WITH strtranc(setup,ccWindow,"*-:"+SUBSTR(ccWindow,3      ,LEN(ccWindow)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccWindow,"*-:"+SUBSTR(ccWindow,3      ,LEN(ccWindow)))
		llWindow=.T.
	ELSE
		llWindow=.F.
	ENDIF

	IF ccPopColor$UPPER(setup) OR ccPopColor$UPPER(PROCEDURE)
		jPopColor='3'
		** Identify COLOR Setup
		IF ccPopColor$UPPER(setup)
			jPopColor=wordSearch(ccPopColor,"setup")
		ELSE
			jPopColor=wordSearch(ccPopColor,"procedure")
		ENDIF

		IF jPopColor=ccNull
			jPopColor=' 3'
		ENDIF
		llPopColor=.T.
		** UPDATE ccPopColor Setup
		REPLACE setup WITH strtranc(setup,ccPopColor,"*-:"+SUBSTR(ccPopColor,3      ,LEN(ccPopColor)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccPopColor,"*-:"+SUBSTR(ccPopColor,3      ,LEN(ccPopColor)))
		IF "2.6"$VERSION()
			** Update code for popup
			llPopColor=.F.
			REPLACE ALL scheme WITH VAL(jPopColor) FOR scheme=3 AND NOT UPPER(levelname)="_MSYSMENU"
			GO TOP
		ENDIF
	ELSE
		llPopColor=.F.
	ENDIF

	IF ccpadColor$UPPER(setup) OR ccPadColor$UPPER(PROCEDURE)
		jpadColor='4'
		** Identify MNX    Driver
		IF ccPadColor$UPPER(setup)
			jPadColor=wordSearch(ccPadColor,"setup")
		ELSE
			jPadColor=wordSearch(ccPadColor,"procedure")
		ENDIF

		IF jPadColor=ccNull
			jPadColor='4'
		ENDIF
		** UPDATE ccPopColor Setup
		REPLACE setup WITH strtranc(setup,ccPadColor,"*-:"+SUBSTR(ccPadColor,3      ,LEN(ccPadColor)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccPadColor,"*-:"+SUBSTR(ccPadColor,3      ,LEN(ccPadColor)))
		llpadColor=.T.
		IF "2.6"$VERSION()
			** Update code for popup
			llPadColor=.F.
			REPLACE ALL scheme WITH VAL(jPadColor) FOR scheme=4 AND UPPER(levelname)="_MSYSMENU"
			GO TOP
		ENDIF
	ELSE
		llpadColor=.F.
	ENDIF

	IF ccLine$UPPER(setup) OR ccLine$UPPER(PROCEDURE)
		jLine=0
		** Identify MNX    Driver
		IF ccLine$UPPER(setup)
			jLine=wordSearch(ccLine,"setup")
		ELSE
			jLine=wordSearch(ccLine,"procedure")
		ENDIF

		IF jLine=ccNull
			jLine='0'
		ENDIF
		** Identify MNX    Driver
		** UPDATE ccPopColor Setup
		REPLACE setup WITH strtranc(setup,ccLine,"*-:"+SUBSTR(ccLine,3      ,LEN(ccLine)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccLine,"*-:"+SUBSTR(ccLine,3      ,LEN(ccLine)))
		llChngLine=.T.
	ELSE
		llChngLine=.F.
	ENDIF

	IF ccMenuName$UPPER(setup) OR ccMenuName$UPPER(PROCEDURE)
		jMenuName='_MSYSMENU'
		** Identify New    Name
		IF ccMEnuName$UPPER(setup)
			jMenuName=wordSearch(ccMenuName,"setup")
		ELSE
			jMenuName=wordSearch(ccMenuname,"procedure")
		ENDIF
		IF jMenuName=CHR(0) OR EMPTY(jMenuName)
			llChngName=.F.
		ELSE
			llChngName=.T.
		ENDIF
		** UPDATE ccPopColor Setup
		REPLACE setup WITH strtranc(setup,ccMenuName,"*-:"+SUBSTR(ccMenuName,3      ,LEN(ccMenuName)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccMenuName,"*-:"+SUBSTR(ccMenuName,3      ,LEN(ccMenuName)))
	ELSE
		llChngName=.F.
	ENDIF

	*]      MNXDRV1 Directives
	DO sayTherm WITH "MNX1 Drivers"
	DO updTherm WITH 20
	GO TOP
	** Look for any MNXDRV1 directives
	** Now handles multiple drivers
	jlGoAhead=.F.
	RELEASE ja_drv1
	DIMENSION ja_drv1(1)
	IF ccMNXDRV1$UPPER(setup) OR ccMNXDRV1$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMnxDrv1,@ja_drv1)
		jlGoAhead=.T.
	ENDIF
	jMnxDrivers=[]
	jMnxDrivers=configfp(ccmMnxDrv1)
	IF NOT (EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0))
		** Pull IN MNXDriver FROM CONFIGFP
		jlGoAhead=.T.
		jnLen=ALEN(ja_drv1,1)
		DIMENSION ja_drv1(jnLen+1,1)
		ja_drv1(jnLen+1,1)=jMnxDrivers
	ENDIF
	IF jlGoAhead
		=doDrvArr(@ja_drv1)
		** UPDATE Driver Setup
		GO TOP
		REPLACE setup WITH strtranc(setup,ccMNXDRV1,"*-:"+SUBSTR(ccMNXDRV1,3      ,LEN(ccMnxDrv1)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccMNXDRV1,"*-:"+SUBSTR(ccMNXDRV1,3      ,LEN(ccMnxDrv1)))
	ENDIF

	RELEASE ja_drv1
	*{ 11/20/93 Enhanced support for the {{ }} delimiters
	GO TOP
	IF '{{'$setup
		REPLACE setup WITH evltxt(setup)
	ENDIF
	IF '{{'$PROCEDURE
		REPLACE PROCEDURE WITH evltxt(PROCEDURE)
	ENDIF
	*{ 11/20/93

	*] New Section in GENMENUX - Menu PAD Processing
	** This section processes only the menu PADS in the menu
	DO sayTherm WITH "Updating Menu Pads..."
	SCAN FOR objCode=ccMenuPad AND UPPER(levelName)='_MSYSMENU'

		DO esc_check

		IF ccIgnore$comment
			LOOP
		ENDIF
		IF EMPTY(keyName) AND llAutoHot
			** No       Hot    KEY so       let   's create one
			** What is       the    letter besides the    \< clause IF any
			IF "\<"$PROMPT
				jPrmpt=SUBSTR(PROMPT,ATC("\<",PROMPT,1)+2      ,1)
				REPLACE keyName WITH ccPadHotkey+LEFT(noHot(jPrmpt),1)
				jPrmpt=SUBSTR(PROMPT,ATC("\<",PROMPT,1)+2      ,1)
				jKeyName=LEFT(noHot(jPrmpt),1)
				jRec=RECNO()
				jUsed=.T.
				jAttempts=0
				DO WHILE jUsed AND jAttempts<4
					LOCATE FOR keyName=ccPadHotKey+jKeyName AND NOT RECNO()=jRec
					jAttempts=jAttempts+1
					jUsed=FOUND()
					GO (jRec)
					IF NOT BETWEEN(UPPER(jKeyName),"A","Z")
						jUsed=.T.
					ENDIF
					IF jUsed
						** FIND another
						jKeyName=SUBSTR(noHot(jPrmpt),jAttempts+1,1)
					ELSE
						EXIT
					ENDIF
				ENDDO
				IF NOT jUsed
					REPLACE keyName WITH ccPadHotKey+jKeyName
				ENDIF
			ELSE
				jPrmpt=PROMPT()
				jKeyName=LEFT(noHot(jPrmpt),1)
				jRec=RECNO()
				jUsed=.T.
				jAttempts=0
				DO WHILE jUsed AND jAttempts<4
					LOCATE FOR keyName=ccPadHotKey+jKeyName AND NOT RECNO()=jRec
					jAttempts=jAttempts+1
					jUsed=FOUND()
					GO (jRec)
					IF NOT BETWEEN(UPPER(jKeyName),"A","Z")
						jUsed=.T.
					ENDIF
					IF jUsed
						** FIND another
						jKeyName=SUBSTR(noHot(jPrmpt),jAttempts+1,1)
					ELSE
						EXIT
					ENDIF
				ENDDO
				IF NOT jUsed
					REPLACE keyName WITH ccPadHotKey+jKeyName
				ENDIF
			ENDIF
		ENDIF
		IF ccBarHot$UPPER(comment)
			jRec=RECNO()
			SKIP
			jLevel=levelName
			REPLACE ALL comment WITH ccBarHot+ccReturn+comment FOR levelname=jLevel
			GO (jRec)
		ENDIF
		** New  thing. IF USER puts ccBarHot IN MENU TOP, it   will force it
		** INTO ALL OF the  SAME items

	ENDSCAN

	*]      Standard GENMENUX Drivers
	DO sayTherm WITH  "Processing...."
	DO updTherm WITH 30
	SCAN
		DO esc_check
		IF ccIgnore$UPPER(comment)   && OR NOT "*:"$comment && Ignore any GENMENUX directives
			LOOP
		ENDIF
		IF ccPadName$UPPER(comment)
			** This driver should ONLY work IF MENU is   A PAD OF _MSYSMENU
			IF levelName='_MSYSMENU'
				jcnewName=wordSearch(ccPadName)
				IF NOT jcNewName=CHR(0)
					REPLACE name WITH jcNewName
					REPLACE comment WITH strtranc(UPPER(comment),ccPadName,"*-:"+SUBSTR(ccPadName,3      ,LEN(ccPadName)))
				ELSE

				ENDIF
			ELSE
				** Put  IN
			ENDIF
		ENDIF

		IF ccPopName$UPPER(comment)
			** IF this driver is   NOT called IN A submenu, ie   the
			** levelname is   _MSYSMENU. GO down one  LEVEL AND try  TO
			** FIND out  POPNAME
			jnCurrRec=RECNO()
			jcNewName=wordSearch(ccPopName)
			IF levelName='_MSYSMENU'
				SKIP
				IF levelName='_MSYSMENU'
					** This driver was  called too  high up
					GO (jnCurrRec)
					EXIT
				ENDIF
			ENDIF
			jcOldName=levelName
			IF NOT jcNewName=CHR(0)
				REPLACE ALL levelName WITH jcNewName FOR levelName=jcOldName
				GO TOP
				LOCATE FOR levelName=jcNewName
				** First RECORD - you  have TO CHANGE the  Name
				REPLACE name WITH jcNewName
			ENDIF
			GO (jnCurrRec)
		ENDIF

		IF ccDefLib$UPPER(comment)
			lcDefLib=wordSearch(ccDefLib)
			REPLACE comment WITH strtranc(comment,ccDefLib,"*-:"+SUBSTR(ccDefLib,3      ,LEN(ccDefLib)))
		ENDIF
		IF ccIncLib$UPPER(comment)
			lcBasLib=wordSearch(ccIncLib)
			REPLACE comment WITH strtranc(comment,ccIncLib,"*-:"+SUBSTR(ccIncLib,3      ,LEN(ccIncLib)))
		ENDIF
		IF ccdefObj$UPPER(comment)
			IF fdefObj(wordSearch(ccdefObj),lcDefLib)
				REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
			ENDIF
		ENDIF
		IF ccInsObj$UPPER(comment)
			IF fInsObj(wordSearch(ccInsObj),lcBasLib)
				REPLACE comment WITH strtranc(comment,ccInsObj,"*-:"+SUBSTR(ccInsObj,3      ,LEN(ccInsObj)))
			ENDIF
		ENDIF
		** Running this here so       we       can    DELETE it       afterwards
		IF ccPopFiles$UPPER(comment)
			*{ 10/30/93
			jMemLine=MLINE(comment,ATLINE(ccPopFiles,UPPER(comment)))
			IF ccPopFiles$UPPER(jMemLine)
				** Check which LINE you   're in so you can see
				** IF you    have TO UPDATE the    item.
				** Remember. TO USE POPFILES, you    have TO CREATE an       EMPTY
				** submenu OR be       the    ONLY item IN the    submenu
				IF levelName="_MSYSMENU"
					** Next record will be proper level
					SKIP
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ELSE
					** Previous record will be proper level
					SKIP -1
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ENDIF
				REPLACE comment WITH comment+CHR(13)+ccDelete
				REPLACE comment WITH strtranc(comment,ccPopFiles,"*-:"+SUBSTR(ccPopFiles,3      ,LEN(ccPopFiles)))
				** IF USER hasn't added CCPOPCOMMAND to Comment
				** we       will DO so       automatically
				IF NOT ccPopCommand$UPPER(comment)
					REPLACE comment WITH comment+CHR(13)+STRTRAN(ccPopCommand,'"')
				ENDIF
			ENDIF
		ENDIF
		IF ccPopField$UPPER(comment)
			jMemLine=MLINE(comment,ATLINE(ccPopField,UPPER(comment)))
			IF ccPopField$UPPER(jMemLine)
				** Check which LINE you   're in so you can see
				** IF you    have TO UPDATE the    item.
				** Remember. TO USE POPFILES, you    have TO CREATE an       EMPTY
				** submenu OR be       the    ONLY item IN the    submenu
				IF levelName="_MSYSMENU"
					** Next record will be proper level
					SKIP
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ELSE
					** Previous record will be proper level
					SKIP -1
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ENDIF
				REPLACE comment WITH comment+CHR(13)+ccDelete
				REPLACE comment WITH strtranc(comment,ccPopField,"*-:"+SUBSTR(ccPopField,3      ,LEN(ccPopField)))
				** IF USER hasn't added CCPOPCOMMAND to Comment
				** we       will DO so       automatically
				IF NOT ccPopCommand$UPPER(comment)
					REPLACE comment WITH comment+CHR(13)+STRTRAN(ccPopCommand,'"')
				ENDIF
			ENDIF
		ENDIF
		IF ccPopCommand$UPPER(comment)
			jMemLine=MLINE(comment,ATLINE(ccPopCommand,UPPER(comment)))
			IF ccPopCommand$UPPER(jMemLine)
				IF levelName="_MSYSMENU"
					** Next record will be proper level
					SKIP
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ELSE
					** Previous record will be proper level
					SKIP -1
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ENDIF
				REPLACE comment WITH strtranc(comment,ccPopCommand,"*-:"+SUBSTR(ccPopCommand,3      ,LEN(ccPopCommand)))
			ENDIF
		ENDIF
		IF ccPopPreCommand$UPPER(comment)
			jMemLine=MLINE(comment,ATLINE(ccPopPreCommand,UPPER(comment)))
			IF ccPopPreCommand$UPPER(jMemLine)
				IF levelName="_MSYSMENU"
					** Next record will be proper level
					SKIP
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ELSE
					** Previous record will be proper level
					SKIP -1
					REPLACE comment WITH comment+CHR(13)+jMemLine
					SKIP
				ENDIF
				REPLACE comment WITH strtranc(comment,ccpopprecommand,"*-:"+SUBSTR(ccPopPreCommand,3,LEN(ccPopPreCommand)))
			ENDIF
		ENDIF
		** check FOR GENIF statement here so       we       can    ADD DELETE TO the
		** Comment snippet TO DELETE it
		IF ccGenIf$UPPER(comment)
			jMemLine=MLINE(comment,ATLINE(ccGenIf,UPPER(comment)))
			IF ccGenIf$UPPER(jMemLine)
				jIfClause=wordSearch(ccGenIf,"jMemLine")
				IF NOT EVAL(jIfClause)
					REPLACE comment WITH comment+CHR(13)+ccDelete
					REPLACE comment WITH strtranc(comment,ccGenIf,"*-:"+SUBSTR(ccGenIf,3      ,LEN(ccGenIf)))
				ENDIF
			ENDIF
		ENDIF
		IF ccDelete$UPPER(comment)
			WAIT WINDOW NOWAIT "Deleting menu item..."
			** Here we       would DELETE an       item but    IN ORDER TO DO that
			** we       have TO reorder the    entire MENU ROW
			** FIND out    LEVEL name
			jcLevel=levelName
			lcCurrNum=itemNum
			jcurrRec=RECNO()
			** IF we       are    AT A PAD name, we       have TO DELETE EVERY item IN the    PAD
			IF UPPER(ALLTRIM(jcLevel))='_MSYSMENU' OR objCode=ccSubMenu
				DELETE
				SKIP
				jName=ALLTRIM(Name)
				DO sayTherm WITH "Removing "+jName+" pad..."
				DELETE ALL FOR levelName=jName
				GO (jCurrRec)
			ELSE
				DELETE
			ENDIF
			** Probably the    best thing TO DO would be       TO reorder the    MENU
			** AFTER ALL OF the    work had    been done ON it.
			WAIT CLEAR
		ENDIF
		IF ccMessage$UPPER(comment)
			** FIND out    what LINE comment is       ON AND pull IN just the    comment
			jMemLine=MLINE(comment,ATLINE(ccMessage,UPPER(comment)))
			IF ccMessage$UPPER(jMemLine) && AND EMPTY(message)
				** REPLACE MESSAGE WITH STRTRAN(UPPER(jMemLine),ccMessage)
				REPLACE MESSAGE WITH wordSearch(ccMessage)
				REPLACE comment WITH strtranc(comment,ccMessage,"*-:"+SUBSTR(ccMessage,3      ,LEN(ccMessage)))
			ENDIF
		ENDIF
		IF ccPadColor$UPPER(comment)
			** FIND out    what LINE comment is       ON AND pull IN just the    comment
			jMemLine=MLINE(comment,ATLINE(ccPadColor,UPPER(comment)))
			IF ccPadColor$UPPER(jMemLine)
				REPLACE SCHEME WITH VAL(STRTRAN(UPPER(jMemLine),ccPadColor))
				REPLACE comment WITH strtranc(comment,ccPadColor,"*-:"+SUBSTR(ccPadColor,3      ,LEN(ccPadColor)))
			ENDIF
		ENDIF
		IF ccSysPop$UPPER(comment) OR llSysPop
			** ADD PUSH/POP MENU TO PROCEDURE IF exists
			IF procType=1    AND NOT EMPTY(PROCEDURE)
				jStart=ccReturn+ccPushSys+ccReturn+ccSetSys+ccReturn+ccReturn
				jEnd=ccReturn+ccReturn+ccPopSys
				REPLACE PROCEDURE WITH jStart+PROCEDURE+jEnd
				REPLACE comment WITH strtranc(comment,ccPopSys,"*-:"+SUBSTR(ccPopSys,3      ,LEN(ccPopSys)))
			ENDIF
		ENDIF
		IF ccBarHot$UPPER(comment) OR llBarHot
			** ONLY work FOR Bars, Commands AND Procedures
			IF EMPTY(keyName) AND (NOT EMPTY(PROCEDURE) OR objCode=78   OR NOT EMPTY(COMMAND))
				** No       Hot    KEY so       let   's create one
				** What is       the    letter besides the    \< clause IF any
				IF "\<"$PROMPT
					jPrmpt=SUBSTR(PROMPT,ATC("\<",PROMPT,1)+2      ,1)
					jKeyName=LEFT(noHot(jPrmpt),1)
					jRec=RECNO()
					jUsed=.T.
					jAttempts=0
					DO WHILE jUsed AND jAttempts<4
						LOCATE FOR keyName=ccBarHotKey+jKeyName AND NOT RECNO()=jRec
						jAttempts=jAttempts+1
						jUsed=FOUND()
						GO (jRec)
						IF NOT BETWEEN(jkeyName,'A','Z')
							jUsed=.T.
						ENDIF
						IF jUsed
							** FIND another
							jKeyName=SUBSTR(noHot(jPrmpt),jAttempts+1,1)
						ELSE
							EXIT
						ENDIF
					ENDDO
					IF NOT jUsed
						REPLACE keyName WITH ccBarHotKey+jKeyName
						REPLACE keyLabel WITH "^"+jKeyName
					ELSE
					ENDIF
				ELSE
					jPrmpt=PROMPT()
					jKeyName=ccBarHotKey+LEFT(noHot(jPrmpt),1)
					jRec=RECNO()
					jUsed=.T.
					jAttempts=0
					DO WHILE jUsed AND jAttempts<4
						jAttempts=jAttempts+1
						LOCATE FOR keyName=jKeyName AND NOT RECNO()=jRec
						jUsed=FOUND()
						GO (jRec)
						IF jUsed
							** FIND another
							jKeyName=ccBarHotKey+ SUBSTR(noHot(jPrmpt),jAttempts+1,1)
						ELSE
							EXIT
						ENDIF
					ENDDO
					IF NOT jUsed
						REPLACE keyLabel WITH STRTRAN(jKeyName,ccBarHotKey,"^")
						REPLACE keyName WITH jKeyName
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		
		IF ccTrnTxt$comment
			jcText=wordsearch(ccTrnTxt)
			IF NOT jcText=CHR(0)
				jcSrchWord=LEFT(jcText,ATC("||",jcText)-1)
				jcNewWord=SUBSTR(jcText,ATC("||",jcText)+2,LEN(jcText))
				REPLACE PROCEDURE WITH strtranc(PROCEDURE,jcSrchWord,jcNewWord)
			ENDIF
		ENDIF
		
	ENDSCAN

	*]      MNXDRV2 Drivers
	** Find first
	DO sayTherm WITH "MNX2 Drivers"
	DO updTherm WITH 40
	GO TOP
	** Look for any MNXDRV2 directives
	** Currently only handles one
	jlGoAhead=.F.
	DIMENSION ja_drv2(1)
	IF ccMNXDRV2$UPPER(setup) OR ccMNXDRV2$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMnxDrv2,@ja_drv2)
		jlGoAhead=.T.
	ENDIF
	jMnxDrivers=[]
	jMnxDrivers=configfp(ccmMnxDrv2)
	IF NOT (EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0))
		** Pull IN MNXDriver FROM CONFIGFP
		jlGoAhead=.T.
		jnLen=ALEN(ja_drv2,1)
		DIMENSION ja_drv2(jnLen+1,1)
		ja_drv2(jnLen+1,1)=jMnxDrivers
	ENDIF
	IF jlGoAhead

		SCAN
			DO esc_check
			IF ccIgnore$comment
				LOOP
			ENDIF
			=doDrvArr(@ja_drv2)
			jNoFile=3
			
			=evlTxt()
			
		ENDSCAN
		IF jNoFile=3
			** UPDATE Driver Setup
			GO TOP
			REPLACE setup WITH strtranc(setup,ccMNXDRV2,"*-:"+SUBSTR(ccMNXDRV2,3      ,LEN(ccMnxDrv2)))
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccMNXDRV2,"*-:"+SUBSTR(ccMNXDRV2,3      ,LEN(ccMnxDrv2)))
		ENDIF
	ENDIF
	RELEASE ja_drv2
	
	*]      Standard Post-MNXDRV2 GENMENUX Drivers
	DO sayTherm WITH  "Processing...."
	DO updTherm WITH 30
	SCAN
		DO esc_check
			IF ccIgnore$comment
				LOOP
			ENDIF

			** jcT=groupCode("comment", "*:FUNCTION" , "*:ENDFNCT")
			
			** IF NOT EMPTY(jct)
			** 	REPLACE PROCEDURE WITH jct
			** ENDIF
			

		*{ 11/20/93 Enhanced support for {{ }} Directives
		=evlRec()
		IF ccDelObj$comment
			WAIT WINDOW NOWAIT "Deleting menu item..."
			** Here we       would DELETE an       item but    IN ORDER TO DO that
			** we       have TO reorder the    entire MENU ROW
			** FIND out    LEVEL name
			jcLevel=levelName
			lcCurrNum=itemNum
			jCurrRec=RECNO()
			** IF we   are  AT A PAD name OR Submenu TOP, we   have TO DELETE EVERY item IN the  PAD
			IF UPPER(ALLTRIM(jcLevel))='_MSYSMENU' OR objCode=ccSubMenu
				DELETE
				SKIP
				jName=ALLTRIM(Name)
				DO sayTherm WITH "Removing "+jName+" pad..."
				DELETE ALL FOR levelName=jName
				GO (jCurrRec)
			ELSE
				DELETE
			ENDIF
			** Probably the    best thing TO DO would be       TO reorder the    MENU
			** AFTER ALL OF the    work had    been done ON it.
			WAIT CLEAR
		ENDIF
		IF llAutoHot AND EMPTY(keyName) AND UPPER(levelName)='_MSYSMENU'
			DO sayTherm WITH "Updating hot keys..."
			** Automatically ADD hot    keys
			** Put  IN check IN here AGAIN!!
			jPrmpt=SUBSTR(PROMPT,ATC("\<",PROMPT,1)+2      ,1)
			REPLACE keyName WITH ccPadHotkey+LEFT(noHot(jPrmpt),1)
			jPrmpt=SUBSTR(PROMPT,ATC("\<",PROMPT,1)+2      ,1)
			jKeyName=LEFT(noHot(jPrmpt),1)
			jRec=RECNO()
			jUsed=.T.
			jAttempts=0
			DO WHILE jUsed AND jAttempts<4
				LOCATE FOR keyName=ccPadHotKey+jKeyName AND NOT RECNO()=jRec
				jAttempts=jAttempts+1
				jUsed=FOUND()
				GO (jRec)
				IF BETWEEN(UPPER(jKeyName),'A','Z')
					jUsed=.T.
				ENDIF
				IF jUsed
					** FIND another
					jKeyName=SUBSTR(noHot(jPrmpt),jAttempts+1,1)
				ELSE
					
				ENDIF
			ENDDO
			IF NOT jUsed
				REPLACE keyName WITH ccPadHotKey+jKeyName
			ENDIF
			** REPLACE keyName WITH "ALT+"+LEFT(nohot(PROMPT),1)
		ENDIF
		
		*{ 05/13/95	Replaces SKIP statements in a procedure statement in the end of the code
		IF llSkipRedir OR ccSkipRedir $ UPPER(comment)
			jcSkipProc = WordSearch (ccSkipRedir, "comment")
			IF jcSkipProc = ccNull
				jcSkipProc = lcSkipProc
			ENDIF
			
			** Code should see if the SKIP FOR statement is empty and then be smart about it!
			IF EMPTY(skipFor)
				
			ELSE
				** What do we need here?
				** The syntax of SET SKIP is
				** SET SKIP OF BAR _MFI_NEW OF _MFILE .T.
				** Except that we may also be skipping BARS or EVEN menus
				** therefore
				lcSkipFor= TRIM(skipFor)
				
				REPLACE skipFor WITH []

				lcStart = ccIf + TRIM( lcSkipFor) + ccReturn
				
				DO CASE
					CASE objtype= ccMenuFile
						** First we support the Menu level
						** So all we need to know the popup name
						** Since the menu can only be MSYSMENU
						jcLevel= [_MSYSMENU]
						
						lcMiddle= ccTab+[SET SKIP OF MENU ] + jcLevel + [ .T. ]+ccReturn+ [ELSE] ;
							+ ccReturn+ ccTab+ [SET SKIP OF MENU ]+ jcLevel + [ .F. ]+ ccReturn
						
						=storeCode( jcSkipProc, [SKIP] , lcStart+lcMiddle+ccEndIf)
					
					CASE objtype= ccMenuPopup
						** Now we'll support the Popup level
						** So all we need to know the popup name
						jcLevel=TRIM(levelname)
						
						lcMiddle= ccTab+[SET SKIP OF POPUP ] + jcLevel + [ .T. ]+ccReturn+ [ELSE] ;
							+ ccReturn+ ccTab+ [SET SKIP OF ]+ jcLevel + [ .F. ]+ ccReturn
						
						=storeCode( jcSkipProc, [SKIP] , lcStart + lcMiddle + ccEndIf )
					
					CASE objtype= ccMenuItem
						** For now we'll only support the lowest level (BAR)
						** So we need to know the popup name
						jcLevel=TRIM(levelname)
						jcBar=IIF( EMPTY(name), LTRIM(itemnum), RTRIM(name) )
						
						IF objCode= ccMenuPad AND UPPER ( levelname ) = "_MSYSMENU"
							lcMiddle= ccTab+[SET SKIP OF PAD ]+jcBar+ [ OF ]+jcLevel + [ .T. ]+ccReturn+ [ELSE] ;
								+ ccReturn+ ccTab+ [SET SKIP OF PAD ]+jcBar+ [ OF ]+jcLevel + [ .F. ]+ ccReturn
						ELSE
							lcMiddle= ccTab+[SET SKIP OF BAR ]+jcBar+ [ OF ]+jcLevel + [ .T. ]+ccReturn+ [ELSE] ;
								+ ccReturn+ ccTab+ [SET SKIP OF BAR ]+jcBar+ [ OF ]+jcLevel + [ .F. ]+ ccReturn
						ENDIF

						=storeCode( jcSkipProc, [SKIP] , lcStart + lcMiddle + ccEndIf )
					
				ENDCASE

			ENDIF
		ENDIF

		*{ 05/13/95
		IF NOT EMPTY(jcDefComm) AND objtype = ccMenuItem AND objCode = ccMenuComm
			REPLACE command WITH jcDefComm
		ENDIF

		*{ 05/13/95
		IF NOT EMPTY(jcDefComI) AND objtype = ccMenuItem AND objCode = ccMenuComm AND EMPTY(command)
			REPLACE command WITH jcDefComI
		ENDIF


		IF llXPlatKeys AND [*:KEY] $ UPPER( comment)
			jcValue = xPlatKeys()
			
			jnPreRec=RECNO()
			jcLev=levelname
			jnItem = VAL(itemNum)
			IF VAL( itemNum)>0
				LOCATE FOR levelname = jcLev AND VAL(itemNum)= jnItem -1
				IF FOUND()
					IF EMPTY(message)
						REPLACE message WITH [""]
					ENDIF
					REPLACE message WITH message+ ccReturn + ccReturn+ ccReturn + ;
						[** Cross Platform Keys ] + ccReturn + ;
						jcValue + ccReturn + ccReturn
				ELSE
					=WARNING( "Can't find higher level menu" )
				ENDIF
			ENDIF			
			GO (jnPreRec)
			REPLACE keyName WITH [&_keyPrompt]
			REPLACE keyLabel WITH []
			
		ENDIF


		
		IF ccPreDef $ UPPER(comment)
			jcPrefDef = WordSearch (ccPreDef)
			jnPreRec=RECNO()
			jcLev=levelname
			jnItem = VAL(itemNum)
			IF VAL( itemNum)>1
				LOCATE FOR levelname = jcLev AND VAL(itemNum)= jnItem -1
				IF FOUND()
					IF EMPTY(Message)
						REPLACE message WITH [""]
					ENDIF
					REPLACE message WITH message+ ccReturn + ccReturn+ ccReturn + ;
						[** Predefined statement ] + ccReturn + ;
						jcPrefDef + ccReturn + ccReturn
				ELSE
					WAIT WINDOW "Can't find it!"
				ENDIF
			ELSE
				IF VAL(itemNum) = 1 AND UPPER(levelname) = [_MSYSMENU]
					** How to handle this...
					** Put it in the Setup clause
					GO TOP
					REPLACE setup WITH setup+ ccReturn + ccReturn+ ccReturn + ;
						[** Predefined statement ] + ccReturn + ;
						jcPrefDef + ccReturn + ccReturn
				ELSE
					** 	unsure of how to do this!
				ENDIF
			ENDIF			
			GO (jnPreRec)
			
		ENDIF
		
		*{ 5/13/95 Enhanced support for {{ }} Directives
		=evlRec()
		
	ENDSCAN

	** Add code for Skip Procedure
	GO BOTT
	IF llSkipRedir
		=updCode (lcSkipProc, [MENU CLEANUP] )
	ENDIF
	** Add code for any other forgotten procedures
	IF USED("CODEHLDR")
		jnArea=SELECT()
		SELECT procName FROM codeHldr WHERE type = [SKIP] AND NOT DELETED() INTO ARRAY ja_skips
		SELECT (jnArea)
		IF _TALLY>0
			FOR jnSkipi=1 TO ALEN(ja_skips)
				=updCode (ja_skips( jnSkipi ) , [MENU CLEANUP] )
			ENDFOR
		ENDIF
	ENDIF	

	*]      Reordering Menus
	** Reordering part of GENMENUX
	jcCurrLevel=' '
	jnStart=0
	DO sayTherm WITH "Reordering menu..."
	DO updTherm WITH 50
	jDel=SET("DELETE")
	SET DELETED ON
	** First thing we need to do is identify all of the different levels
	** in the menu
	jnCUrrArea=SELECT()
	SELECT levelName FROM DBF() WHERE NOT EMPTY(numItems)=.T. INTO ARRAY jaLevels
	
	IF _TALLY>0
		FOR ji      =1          TO ALEN(jaLevels,1)
			jnStart=0
			*{ 09/05/95 Andrew Ross MacNeill
			*{
			SCAN FOR UPPER(levelname) = UPPER(jaLevels(ji   ,1))
				IF ccIgnore$comment
					LOOP
				ENDIF
				** IF levelName=jcCurrLevel
				*! This needs to be checked out to make sure that it works
				*! everytime we re-arrange the menu.
				** We are doing this so that if you are at the top of the level
				** it gets reset.
				*! if this causes problems, it is because we are adding a new
				*! record somewhere with an itemnum of zero.
				IF VAL(itemnum)=0
					jnStart=0
				ENDIF
				IF STR(jnStart,3)=itemNum OR EMPTY(itemNum)
					** Great. RIGHT NUMBER
				ELSE
					REPLACE itemNum WITH STR(jnStart,3)
				ENDIF
				jnStart=jnStart+1
				**      ELSE
				**              ** tHE LEVEL on this item should be 0 so we will continue
				**              jcCurrLevel=levelName
				**              jnStart=1
				**      ENDIF
			ENDSCAN
		ENDFOR
	ENDIF
	USE DBF() EXCLUSIVE
	PACK
	USE DBF()
	SET DELETE &jDel

	*] Post re-ordering drivers
	** Since the only one being done is the *:IF clause
	** we will ATTEMPT To group them all together
	*{ 11/20/93 ARMacNeill
	llIf=''
	SCAN
			IF ccIgnore$comment
				LOOP
			ENDIF
		DO esc_check

		*{ 5/13/95 Enhanced support for {{ }} Directives
		=evlRec()

		** IF Support
		IF ccIfDir$UPPER(comment)
			DO sayTherm WITH "Handling *:IF Directive for "+ALLTRIM(PROMPT)+"..."
			jClause=' '
			jMemLine=MLINE(comment,ATLINE(ccIfDir,UPPER(comment)))
			IF ccIfDir$UPPER(jMemLine)
				** jClause=STRTRANC(jMemLine,ccIfDir)
				jClause=wordSearch(ccIfDir,"jMemLine")
			ENDIF
			** Handle Keywords here
			IF ccKeyName$jClause
				jClause=STRTRANC(jClause,ccKeyName,ALLTRIM(name))
			ENDIF
			IF ccKeyPrompt$jClause
				jClause=STRTRANC(jClause,ccKeyPrompt,ALLTRIM(NOHOT(PROMPT)))
			ENDIF
			IF ccKeyLevel$jClause
				jClause=STRTRANC(jClause,ccKeyLevel,ALLTRIM(levelname))
			ENDIF
			IF ccKeyItem$jClause
				jClause=STRTRANC(jClause,ccKeyItem,ALLTRIM(itemnum))
			ENDIF

			*{ 04/02/94 ARMACNEILL - Putting entire IF clause with [ ] to bracket better code.
			jPre=CHR(13)+"IF NOT ("+jClause+')'+CHR(13)
			IF levelName='_MSYSMENU'
				*{ 09/28/93	Added TO ensure that PADS could be removed!
				IF EMPTY(ALLTRIM(name))
					REPLACE Name WITH LOWER(SYS(2015))
				ENDIF
				jDetail=IIF(EMPTY(name),"   RELEASE PAD "+LTRIM(itemNum)+" OF "+ALLTRIM(levelName), ;
					"   RELEASE PAD "+ALLTRIM(Name)+" OF "+ALLTRIM(levelName))
			ELSE
				jDetail=IIF(EMPTY(name),"   RELEASE BAR "+LTRIM(itemNum)+" OF "+ALLTRIM(levelName), ;
					"   RELEASE BAR "+ALLTRIM(Name)+" OF "+ALLTRIM(levelName))
			ENDIF
			jPost=CHR(13)+"ENDIF"+CHR(13)
			** DO addCleanUp WITH jPre+jDetail+jPost,"Top"
			llIf=llIf+CHR(13)+jPre+jDetail+jPost
		ENDIF

		*{ 07/06/95	ARMACNEILL
		*{ Support for new Key Label statement
		IF ccKeyLab $ comment
			jcNewLab = wordSearch(ccKeyLab)
			IF NOT EMPTY(jcNewLab) OR NOT jcNewLab = CHR(0)
				REPLACE keyname WITH jcNewLab
			ENDIF
		ENDIF

	ENDSCAN
	IF NOT EMPTY(llIf)
		DO addCleanUp WITH llIf,"Top"
	ENDIF
	*]      MNXDRV3 Drivers
	** Find first
	DO sayTherm WITH "MNX3 Drivers"
	DO updTherm WITH 60
	GO TOP
	** Look for any MNXDRV3 directives
	** handles multiples
	jlGoAhead=.F.
	DIMENSION ja_drv3(1)
	IF ccMNXDRV3$UPPER(setup) OR ccMNXDRV3$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMnxDrv3,@ja_drv3)
		jlGoAhead=.T.
	ENDIF
	jMnxDrivers=[]
	jMnxDrivers=configfp(ccmMnxDrv3)
	IF NOT (EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0))
		** Pull IN MNXDriver FROM CONFIGFP
		jlGoAhead=.T.
		jnLen=ALEN(ja_drv3,1)
		DIMENSION ja_drv3(jnLen+1,1)
		ja_drv3(jnLen+1,1)=jMnxDrivers
	ENDIF
	IF jlGoAhead
		SCAN
			DO esc_check
			IF ccIgnore$comment
				LOOP
			ENDIF
			=doDrvArr(@ja_drv3)
			jNoFile=3

			*{ 5/13/95 Enhanced support for {{ }} Directives
			=evlRec()

		ENDSCAN

		IF jNoFile=3
			** UPDATE Driver Setup
			GO TOP
			REPLACE setup WITH strtranc(setup,ccMNXDRV3,"*-:"+SUBSTR(ccMNXDRV3,3      ,LEN(ccMnxDrv3)))
			REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccMNXDRV3,"*-:"+SUBSTR(ccMNXDRV3,3      ,LEN(ccMnxDrv3)))
		ENDIF

	ENDIF
	RELEASE ja_drv3

	** Steps in between MNXDRV3 and 4
	SCAN
		IF ccTrnTxt$comment
			jcText=wordsearch(ccTrnTxt)
			IF NOT jcText=CHR(0)
				jcSrchWord=LEFT(jcText,ATC("||",jcText)-1)
				jcNewWord=SUBSTR(jcText,ATC("||",jcText)+2,LEN(jcText))
				REPLACE PROCEDURE WITH strtranc(PROCEDURE,jcSrchWord,jcNewWord)
			ENDIF
		ENDIF
		jcVar=wordSearch(ccVariable)
		IF NOT jcVar=CHR(0)
			REPLACE prompt WITH ["+]+jcVar+[+"]
		ENDIF
		*{ 5/13/95 Enhanced support for {{ }} Directives
		=evlRec()

	ENDSCAN

	*]      MNXDRV4 Drivers
	* Find first
	DO sayTherm WITH "MNX4 Drivers"
	DO updTherm WITH 70
	GO TOP
	** Look for any MNXDRV4 directives
	** Handles multiples
	jlGoAhead=.F.
	DIMENSION ja_drv4(1)
	IF ccMNXdrv4$UPPER(setup) OR ccMNXdrv4$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMnxdrv4,@ja_drv4)
		jlGoAhead=.T.
	ENDIF
	jMnxDrivers=[]
	jMnxDrivers=configfp(ccmMnxdrv4)
	IF NOT (EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0))
		** Pull IN MNXDriver FROM CONFIGFP
		jlGoAhead=.T.
		jnLen=ALEN(ja_drv4,1)
		DIMENSION ja_drv4(jnLen+1,1)
		ja_drv4(jnLen+1,1)=jMnxDrivers
	ENDIF
	IF jlGoAhead
		=doDrvArr(@ja_drv4)
		** UPDATE Driver Setup
		GO TOP
		REPLACE setup WITH strtranc(setup,ccMNXDRV4,"*-:"+SUBSTR(ccMNXDRV4,3      ,LEN(ccMnxdrv4)))
		REPLACE PROCEDURE WITH strtranc(PROCEDURE,ccMNXdrv4,"*-:"+SUBSTR(ccMNXdrv4,3      ,LEN(ccMnxDrv4)))
	ENDIF
	RELEASE ja_drv4

	*]      MNXDRV5 Drivers (replaces GENMENU)
	** Find first
	DO sayTherm WITH "Identifying MNX5 drivers..."
	DO updTherm WITH 80
	GO TOP
	** Look for any MNXDRV2 directives
	** Currently only handles one
	jMnxDrivers=' '
	IF ccMNXDRV5$UPPER(setup) OR ccMNXDRV5$UPPER(procedure)
		** Identify MNX    Driver
		IF ccMNXDRV5$UPPER(setup)
			jMnxDrivers=wordsearch(ccMNXDrv5,'setup')
		ELSE
			jMNXDrivers=wordSearch(ccMnxDrv5,'procedure')
		ENDIF
	ENDIF
	IF EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0)
		** Pull IN MNXDriver FROM CONFIGFP
		jMnxDrivers=configfp('_MNXDRV5')
	ENDIF
	IF EMPTY(ALLTRIM(jMnxDrivers))
		** Pull IN MNXDriver FROM CONFIGFP
		jMnxDrivers=configfp('_GENMENUX')
	ENDIF
	IF NOT EMPTY(ALLTRIM(jmnxDrivers))
		jMnxDrivers=ALLTRIM(STRTRAN(STRTRAN(jMnxDrivers,'"'),"'"))
		m.genMenu=jMnxDrivers
	ENDIF

	*{ 12/6/93 New Support for MNXDRV 0
	jMnxDrivers=''
	IF ccMNXDRV0$UPPER(setup) OR ccMNXDRV0$UPPER(procedure)
		** Identify MNX    Driver
		IF ccMNXDRV0$UPPER(setup)
			jMnxDrivers=wordsearch(ccMNXDrv0,'setup')
		ELSE
			jMNXDrivers=wordSearch(ccMnxDrv0,'procedure')
		ENDIF
	ENDIF
	IF EMPTY(ALLTRIM(jMnxDrivers)) OR jMnxDrivers=CHR(0)
		** Pull IN MNXDriver FROM CONFIGFP
		jMnxDrivers=configfp('_MNXDRV0')
	ENDIF
	IF NOT EMPTY(ALLTRIM(jmnxDrivers))
		jMnxDrivers=ALLTRIM(STRTRAN(STRTRAN(jMnxDrivers,'"'),"'"))
		** m.genMenu=jMnxDrivers
		** Okay - jMnxDrivers now contains the name of the file
		** that we will use to append to m.genmenu's temporary file
		m.jGenMenu=uniqueFlnm()+".TMP"
		jArea=SELECT()
		SELECT 0
		CREATE CURSOR _tm (OBJECT M(10))
		APPEND BLANK
		APPEND MEMO OBJECT FROM (m.genMenu) OVERWRITE
		REPLACE object WITH object+CHR(13)
		APPEND MEMO OBJECT FROM (jMnxDrivers)
		COPY MEMO OBJECT TO (m.jGenMenu)
		USE
		SELECT (jArea)
		m.genMenu=m.jGenMenu
	ENDIF
	*]      MPRDRV1 Drivers
	** Find first
	DO sayTherm WITH "MPR1 Drivers"
	DO updTherm WITH 90
	GO TOP
	** Look for any MPRDRV directives
	** Handles multiples
	jlDriver1=.F.
	DIMENSION ja_drv1(1)
	IF ccMPRDRV1$UPPER(setup) OR ccMPRDRV1$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMPRDrv1,@ja_drv1)
		jlDriver1=.T.
	ENDIF
	jMPRDrivers=[]
	jMPRDrivers=configfp(ccmMPRDrv1)
	IF NOT (EMPTY(ALLTRIM(jMPRDrivers)) OR jMPRDrivers=CHR(0))
		** Pull IN MPRDriver FROM CONFIGFP
		jlDriver1=.T.
		jnLen=ALEN(ja_drv1,1)
		DIMENSION ja_drv1(jnLen+1,1)
		ja_drv1(jnLen+1,1)=jMPRDrivers
	ENDIF
	jMprDrivers=' '

	*]      MPRDRV2 Drivers
	** Find first
	DO sayTherm WITH "MPR2 Drivers"
	DO updTherm WITH 90
	GO TOP
	** Look for any MNXDRV2 directives
	** Currently only handles one
	jlDriver2=.F.
	DIMENSION ja_drv2(1)
	IF ccMPRdrv2$UPPER(setup) OR ccMPRdrv2$UPPER(PROCEDURE)
		** Identify MNX Driver
		jlGoAhead=drvArray(ccMPRdrv2,@ja_drv2)
		jlDriver2=.T.
	ENDIF
	jMPRDrivers=[]
	jMPRDrivers=configfp(ccmMPRdrv2)
	IF NOT (EMPTY(ALLTRIM(jMPRDrivers)) OR jMPRDrivers=CHR(0))
		** Pull IN MPRDriver FROM CONFIGFP
		jlDriver2=.T.
		jnLen=ALEN(ja_drv2,1)
		DIMENSION ja_drv2(jnLen+1,1)
		ja_drv2(jnLen+1,1)=jMPRDrivers
	ENDIF
	jMprDrivers=' '
	USE
	
	DO sayTherm WITH "Preparing file for menu generation..."
	SELECT ( jnOldAlias)

	*-- Copy this project record to memvars
	SCATTER MEMVAR MEMO

	*-- Modify the name
	m.name    = LOWER(STRTRAN(FULLPATH(jcTNameExt),UPPER(jcProjPath)))
	m.name=jcTNameExt
	jcRealOut=m.outFile
	m.outFile=JUSTFNAME(m.outFile)
	IF NOT EMPTY(jcTmpDir) AND NOT _MAC
		m.outFile=jcTmpDir+"\"+m.outFile
	ENDIF
	m.OutFile=m.outFile+ccNull
	USE ( jcTProjExt) IN 0          ALIAS tempproj
	jnJunk = SELECT()

	*-- Insert into the temporary project
	INSERT INTO ( jcTProjExt) FROM MEMVAR

	SELECT tempproj
	USE

	SET ESCAPE ON

	IF USED('CONFIGFP')
		USE IN CONFIGFP
	ENDIF
	IF NOT FILE(m.genmenu)
		DO cleanup
		RETURN 2
	ENDIF

	IF USED("FOXMNX")
		USE IN FOXMNX
	ENDIF

	WAIT CLEAR

	DO sayTherm WITH "Running menu generator..."
ENDIF
**** HERE IS WHERE WE RUN GENMENU
IF llNoXGen
	USE IN pjxBase
	jcTProjExt=tcProjDbf
	jnRecGen=tnProjRecNo
ELSE
	jnRecGen=2
ENDIF
IF NOT llNoGen
	ON ERROR
	IF NOT FILE(m.genmenu)
		=warning("Menu Generator: "+m.genmenu+" not found!")
	ENDIF
	DO ( m.genmenu) WITH jcTProjExt, jnRecGen

	ON ERROR DO errorhnd WITH ERROR(),MESSAGE(),PROGRAM(),LINENO(),MESSAGE(1)

ENDIF
****

SET ESCAPE OFF
** Any major changes to the SPR file we will do here.
** This will be done by comparing the SCX file and making changes in the
** MPR file.
DO sayTherm WITH "Updating Menu File..."
** Remove MNXDRV0 file
IF LEFT(m.genmenu,1)=[_]
	ERASE (m.genmenu)
ENDIF

IF NOT (llNoGen OR llNoXGen)
	IF USED("TEMPSCX")
		USE IN tempScx
	ENDIF
	IF USED("TEMPPROJ")
		USE IN tempProj
	ENDIF
	SELECT 0
	USE ( jcTNameExt) ALIAS tempScx
	** Select temporary project so we can fool around with the MPR file
	USE ( jcTProjExt) IN 0          ALIAS tempproj
	SELECT tempProj
	GO BOTT
	APPEND MEMO OBJECT FROM (ALLTRIM(outFile)) OVERWRITE
	ERASE (ALLTRIM(outFile))
	SELECT tempScx
	GO TOP
	IF NOT llNoXGen
		SCAN
			IF ccIgnore$comment
				LOOP
			ENDIF
			DO esc_check
			
			** Let's update Menu COLOR schemes and Pairs
			IF ccMenuColor$UPPER(setup) OR ccMenuColor$UPPER(procedure)
				DO sayTherm WITH "Updating menu color pair..."
				DO CASE
					CASE ccMenuColor$UPPER(setup)
						jcColPair=wordSearch(ccMenuColor,"setup")
					CASE ccMenuColor$UPPER(procedure)
						jcColPair=wordSearch(ccMenuColor,"procedure")
				ENDCASE
				llChngCol=.T.
			ELSE
				llChngCol=.F.
			ENDIF
			
			IF ccMenuScheme$UPPER(setup) OR ccMenuScheme$UPPER(procedure)
				DO sayTherm WITH "Updating menu color scheme..."
				DO CASE
					CASE ccMenuColor$UPPER(setup)
						jcColScheme=wordSearch(ccMenuColor,"setup")
					CASE ccMenuColor$UPPER(procedure)
						jcColScheme=wordSearch(ccMenuColor,"procedure")
				ENDCASE
				llChngScheme=.T.
			ELSE
				llChngScheme=.F.
			ENDIF
			
			
			** Let   's see if we can update any popups with PROMPTS or the like
			
			IF ccPopFiles$UPPER(comment) AND ccPopCommand$UPPER(comment)
				DO sayTherm WITH "Updating menu popups..."
				** Better FIND out    what the    POPFILES COMMAND is
				jFileExt='*.*'
				jMemLine=MLINE(comment,ATLINE(ccPopFiles,UPPER(comment)))
				IF ccPopFiles$UPPER(jMemLine)
					jExt=ALLTRIM(STRTRAN(UPPER(jMemLine),STRTRAN(ccPopFiles,'"')))
					IF NOT EMPTY(ALLTRIM(jExt))
						jFileExt=jExt
					ENDIF
					jFileExt=STRTRAN(STRTRAN(STRTRAN(STRTRAN(jFileExt,'"'),"'"),"["),"]")
				ENDIF
				** Better FIND out    what the    SELECTION POPUP COMMAND is
				jPopCommand=''
				jMemLine=MLINE(comment,ATLINE(ccPopCommand,UPPER(comment)))
				IF ccPopCommand$UPPER(jMemLine)
					jPopCommand=wordSearch(ccPopCommand,"JMEMLINE")
					*{ 04/02/94 Instead of removing all double quotes only remove ones around each side
					** jPopCommand=ALLTRIM(STRTRAN(jPopCommand,'"'))
					IF LEFT(RTRIM(jPopCommand),1)='"'
						jPopCommand=SUBSTR(TRIM(jPopCommand),2,LEN(jPopCommand))
					ENDIF
					IF RIGHT(jPopCommand,1)='"'
						jPopCommand=LEFT(jPopCommand,LEN(jPopCommand)-1)
					ENDIF
					
				ENDIF
				jLine=CHR(13)+"ON SELECTION POPUP "+ALLTRIM(levelName)+" "+jPopCommand
				WAIT WINDOW NOWAIT "Updating popups for "+levelName
				** GET the    PAD Name
				jPopup=levelName
				SELECT tempProj
				jnLine=ATLINE("DEFINE POPUP "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				IF jnLine>0
					jcFullLine=MLINE(OBJECT,jnLine)
					jcPopName=SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+12   ,10)
					jcNewLine=strtranc(jcFullLine,"DEFINE POPUP "+ALLTRIM(jPopup)+" ","DEFINE POPUP "+ALLTRIM(jPopup)+" PROMPT FILES LIKE "+jFileExt+" ")
					jcNewLine=ccReturn+jcNewLine+ccReturn+jLine
					** REPLACE OBJECT WITH strtranc(OBJECT,'DEFINE POPUP open ',"DEFINE POPUP open PROMPT FILES LIKE *.* ")
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
					** REPLACE OBJECT WITH OBJECT+jLine
				ELSE
					=WARNING([Could not identify line with Define Popup])
				ENDIF
				WAIT CLEAR
			ENDIF
			SELECT tempscx
			IF ccPopField$UPPER(comment) AND ccPopCommand$UPPER(comment)
				DO sayTherm WITH "Updating menu popups..."
				** Better FIND out    what the    POPFILES COMMAND is
				jFileExt='*.*'
				*{ 10/30/93
				jMemLine=MLINE(comment,ATLINE(ccPopField,UPPER(comment)))
				IF ccPopField$UPPER(jMemLine)
					jExt=wordsearch(ccPopField,'jMemLine')
					jExt=ALLTRIM(STRTRAN(jExt,'"'))
					IF NOT EMPTY(ALLTRIM(jExt)) AND NOT jExt=CHR(0)
						jFileExt=jExt
					ENDIF
					jFileExt=STRTRAN(STRTRAN(STRTRAN(STRTRAN(jFileExt,'"'),"'"),"["),"]")
				ENDIF
				** Better FIND out    what the    SELECTION POPUP COMMAND is
				jPopCommand=''
				jMemLine=MLINE(comment,ATLINE(ccPopCommand,UPPER(comment)))
				IF ccPopCommand$UPPER(jMemLine)
					jPopCommand=wordSearch(ccPopCommand,"jMemLine")
					jPopCommand=ALLTRIM(STRTRAN(jPopCommand,'"'))
				ENDIF
				IF ATLINE(ccPopPreComm,UPPER(comment))>0
					jMem2=MLINE(comment,ATLINE(ccPopPreComm,UPPER(comment)))
					** Popup has a Pre popup command
					WAIT WINDOW "Identifying pre-definition command..." NOWAIT
					jcPopPre=wordSearch(ccPopPreComm,'jMem2')
					jcPopPre=ALLTRIM(STRTRAN(jcPopPre,'"'))
				ELSE
					jcPopPre=''
				ENDIF
				jLine=CHR(13)+CHR(13)+"ON SELECTION POPUP "+ALLTRIM(levelName)+" "+jPopCommand
				WAIT WINDOW NOWAIT "Updating popups for "+levelName
				** GET the    PAD Name
				jPopup=levelName
				SELECT tempProj
				jnLine=ATLINE("DEFINE POPUP "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				IF jnLine>0
					jcFullLine=MLINE(OBJECT,jnLine)
					jcPopName=SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+12   ,10)
					jcNewLine=strtranc(jcFullLine,"DEFINE POPUP "+ALLTRIM(jPopup)+" ","DEFINE POPUP "+ALLTRIM(jPopup)+" PROMPT FIELD "+jFileExt+" ")
					IF NOT EMPTY(jcPopPre)
						jcNewLine=ccReturn+jcPopPre+ccReturn+jcNewLine+CHR(13)+CHR(13)+jLine
					ELSE
						jcNewLine=ccReturn+jcNewLine+CHR(13)+CHR(13)+jLine
					ENDIF
					** REPLACE OBJECT WITH strtranc(OBJECT,'DEFINE POPUP open ',"DEFINE POPUP open PROMPT FILES LIKE *.* ")
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)

					** REPLACE OBJECT WITH OBJECT+jLine
				ELSE
					=WARNING([No line with Define Popup])
				ENDIF
				WAIT CLEAR
				SELECT tempScx
			ENDIF

			IF ccPOPPOS$UPPER(comment)
				jFileExt='*.*'
				jPosition=wordsearch(ccPOPPOS)
				IF NOT jPosition=CHR(0)
				** GET the    PAD Name
				DO sayTherm WITH "Updating menu popup positions..."
				jPopup=levelName
				jPrompt=ALLTRIM(PROMPT)
				jLevel=ALLTRIM(levelName)
				SELECT tempProj

				jnLine=ATLINE("DEFINE POPUP "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				IF jnLine>0
					jcFullLine=MLINE(OBJECT,jnLine)
					jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					IF EMPTY(jPopUp)
						jPopup=ALLTRIM(LEFT(jcPopName,11  ))
					ENDIF
					jcNewLine=strtranc(jcFullLine,"DEFINE POPUP "+ALLTRIM(jPopup),"DEFINE POPUP "+ALLTRIM(jPopup)+" FROM "+jPosition+" ")
					jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ELSE
					=WARNING([No line with Define POPUP])
				ENDIF
				SELECT tempscx
				ENDIF
			ENDIF
			IF ccPadPos$UPPER(comment)
				jFileExt='*.*'
				jPosition=wordsearch(ccPadPos)
				IF NOT jPosition=CHR(0)
				** GET the    PAD Name
				DO sayTherm WITH "Updating menu pad positions..."
				jPopup=Name
				jPrompt=ALLTRIM(PROMPT)
				jLevel=ALLTRIM(levelName)
				SELECT tempProj

				IF NOT EMPTY(jpopup)
					jnLine=ATLINE("DEFINE PAD "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				ELSE
					jnLine=ATLINE("OF "+UPPER(ALLTRIM(jLevel))+' PROMPT "'+UPPER(jPrompt),UPPER(OBJECT))
				ENDIF
				IF jnLine>0
					jcFullLine=MLINE(OBJECT,jnLine)
					jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE PAD ",jcFullLine)+11   ,ATC("PROMPT",jcFullLine) ))
					IF EMPTY(jPopUp)
						jPopup=ALLTRIM(LEFT(jcPopName,11  ))
					ENDIF
					jcNewLine=strtranc(jcFullLine,"DEFINE PAD "+ALLTRIM(jPopup)+" OF _MSYSMENU","DEFINE PAD "+ALLTRIM(jPopup)+" OF _MSYSMENU AT "+jPosition+" ")
					jcNewLine=ccReturn+jcNewLine
					** REPLACE OBJECT WITH strtranc(OBJECT,'DEFINE POPUP open ',"DEFINE POPUP open PROMPT FILES LIKE *.* ")
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
					** REPLACE OBJECT WITH OBJECT+jLine
				ELSE
					=WARNING([No line with Define PAD])
				ENDIF
				ENDIF
				SELECT tempscx
			ENDIF

			IF ccPopTitle$UPPER(comment)
				jFileExt='*.*'
				jTitle=wordsearch(ccPopTitle)
				
				IF NOT jTitle=CHR(0)
				** GET the    PAD Name
				DO sayTherm WITH "Updating menu popup titles..."
				jPopup=levelName
				jPrompt=ALLTRIM(PROMPT)
				jLevel=ALLTRIM(levelName)
				SELECT tempProj

				jnLine=ATLINE("DEFINE POPUP "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				IF jnLine>0
					jcFullLine=MLINE(OBJECT,jnLine)
					jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+13   ,10  ))
					IF EMPTY(jPopUp)
						jPopup=ALLTRIM(LEFT(jcPopName,11  ))
					ENDIF
					jcNewLine=strtranc(jcFullLine,"DEFINE POPUP "+ALLTRIM(jPopup),"DEFINE POPUP "+ALLTRIM(jPopup)+" TITLE "+jTitle+" ")
					jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ELSE
					=WARNING([No line with Define POPUP to update Title])
				ENDIF
				ENDIF
				SELECT tempscx
			ENDIF

			** Conditional POPUP definition
			IF ccQuickDef$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating popup definition..."
				jPopup=levelName
				jPrompt=ALLTRIM(PROMPT)
				jLevel=ALLTRIM(levelName)
				jCondit=wordSearch(ccQuickDef)
				SELECT tempProj
				jnLine=ATLINE("DEFINE POPUP "+UPPER(ALLTRIM(jLevel)),UPPER(OBJECT))
				IF jnLine>0
					IF jCondit=CHR(0) OR EMPTY(ALLTRIM(jCondit))
						jcStart='IF TYPE("'+ALLTRIM(jPopup)+'")="U" OR "'+ALLTRIM(jPopup)+'"$SYS(2013)'
					ELSE
						jcStart='IF '+jCondit
					ENDIF
					jcEnd='ENDIF'
					jcFullLine=MLINE(OBJECT,jnLine)
					** jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					jcNewLine=jcStart+ccReturn+ccTab+jcFullLine+ccReturn+jcEnd
					jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ELSE
					=WARNING([No line with Define POPUP])
				ENDIF
				SELECT tempscx
			ENDIF

			** COLOR Pair FOR MENU objects
			IF ccColorset$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating popup colour scheme definition..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
				ENDIF
				** New  COLOR Setting
				jcSet=wordSearch(ccColorSet)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0    AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)

					** jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					IF RIGHT(ALLTRIM(jcFullLine),1)=";"
						jcFullLine=LEFT(jcFullLine,RAT(';',jcFullLine)-1)
						jcNewLine=jcFullLine+ccFXColSet+" "+jcSet+' '
						IF "DEFINE PAD"$jSrch
							jcNewLine=STRTRAN(jcNewLine,"COLOR SCHEME 3")
						ENDIF
					ELSE
						jcNewLine=jcFullLine+ccFXColSet+" "+jcSet
						IF "DEFINE PAD"$jSrch
							jcNewLine=STRTRAN(jcNewLine,"COLOR SCHEME 3")
						ENDIF
					ENDIF
					** jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF

			** COLOR Pair FOR MENU objects
			IF ccColor$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating popup colour pair definition..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
				ENDIF
				** New  COLOR Setting
				jcSet=wordSearch(ccColor)
				IF _WINDOWS OR _MAC
					DO CASE
						CASE PROPER(jcSet)=[Red]
							jcSet=[,RGB(,,,255,0,0),,RGB(,,,255,0,0),,RGB(,,,255,0,0),,RGB(,,,255,0,0)]
						CASE PROPER(jcSet)= "White"
							jcSet=[,RGB(,,,255,255,255),RGB(,,,255,255,255),RGB(,,,255,255,255),RGB(,,,255,255,255)]
						CASE PROPER(jcSet)= "Grey"
							jcSet=[,RGB(,,,192,192,192),RGB(,,,192,192,192),RGB(,,,192,192,192),RGB(,,,192,192,192)]
						CASE PROPER(jcSet)= "Maroon"
							jcSet=[,RGB(,,,128,0,0),RGB(,,,128,0,0),RGB(,,,128,0,0),RGB(,,,128,0,0)]
						CASE PROPER(jcSet)= "Puke" OR PROPER(jcSet)="Khaki"
							jcSet=[,RGB(,,,128,128,0),RGB(,,,128,128,0),RGB(,,,128,128,0),RGB(,,,128,128,0)]
						CASE PROPER(jcSet)= "Green"
							jcSet=[,RGB(,,,0,128,0),RGB(,,,0,128,0),RGB(,,,0,128,0),RGB(,,,0,128,0)]
						CASE PROPER(jcSet)= "Aqua"
							jcSet=[,RGB(,,,0,128,128),RGB(,,,0,128,128),RGB(,,,0,128,128),RGB(,,,0,128,128)]
						CASE PROPER(jcSet)= "Royal Blue"
							jcSet=[,RGB(,,,0,0,128),RGB(,,,0,0,128),RGB(,,,0,0,128),RGB(,,,0,0,128)]
						CASE PROPER(jcSet)= "Burgundy"
							jcSet=[,RGB(,,,128,0,128),RGB(,,,128,0,128),RGB(,,,128,0,128),RGB(,,,128,0,128)]
						CASE PROPER(jcSet)= "Light Green"
							jcSet=[,RGB(,,,0,255,0),RGB(,,,0,255,0),RGB(,,,0,255,0),RGB(,,,0,255,0)]
						CASE PROPER(jcSet)= "Baby Blue"
							jcSet=[,RGB(,,,0,255,255),RGB(,,,0,255,255),RGB(,,,0,255,255),RGB(,,,0,255,255)]
						CASE PROPER(jcSet)= "Blue"
							jcSet=[,RGB(,,,0,0,255),RGB(,,,0,0,255),RGB(,,,0,0,255),RGB(,,,0,0,255)]
						CASE PROPER(jcSet)= "Black"
							jcSet=[,RGB(,,,0,0,0),,RGB(,,,0,0,0),RGB(,,,0,0,0)]
						CASE PROPER(jcSet)= "Violet"
							jcSet=[,RGB(,,,255,0,255),RGB(,,,255,0,255),RGB(,,,255,0,255),RGB(,,,255,0,255)]
						CASE PROPER(jcSet)= "Yellow"
							jcSet=[,RGB(,,,255,255,0),RGB(,,,255,255,0),RGB(,,,255,255,0),RGB(,,,255,255,0)]
						CASE PROPER(jcSet)= "Dark Grey"
							jcSet=[,RGB(,,,128,128,128),RGB(,,,128,128,128),RGB(,,,128,128,128),RGB(,,,128,128,128)]
					ENDCASE
				ENDIF
				
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0    AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					** jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					IF RIGHT(ALLTRIM(jcFullLine),1)=";"
						jcFullLine=LEFT(jcFullLine,RAT(';',jcFullLine)-1)
						jcNewLine=jcFullLine+ccFXColPair+" "+jcSet+' '
						IF "DEFINE PAD"$jSrch
							jcNewLine=STRTRAN(jcNewLine,"COLOR SCHEME 3")
						ENDIF
					ELSE
						jcNewLine=jcFullLine+ccFXColPair+" "+jcSet
						IF "DEFINE PAD"$jSrch
							jcNewLine=STRTRAN(jcNewLine,"COLOR SCHEME 3")
						ENDIF
					ENDIF
					** jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF

			** BEFORE Setting
			IF ccBefore$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating BEFORE menu definition..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
				ENDIF
				jcSet=wordSearch(ccBefore)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0    AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)

					IF RIGHT(ALLTRIM(jcFullLine),1)=";"
						jcFullLine=LEFT(jcFullLine,RAT(';',jcFullLine)-1)
						jcNewLine=jcFullLine+[ BEFORE ]+jcSet+' '
					ELSE
						jcNewLine=jcFullLine+[ BEFORE ]+jcSet
					ENDIF
					** jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF

			** AFTER Setting
			IF ccAFTER$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating AFTER menu definition..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
				ENDIF
				jcSet=wordSearch(ccAFTER)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0    AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					** jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					IF RIGHT(ALLTRIM(jcFullLine),1)=";"
						jcFullLine=LEFT(jcFullLine,RAT(';',jcFullLine)-1)
						jcNewLine=jcFullLine+[ AFTER ]+jcSet+' '
					ELSE
						jcNewLine=jcFullLine+[ AFTER ]+jcSet
					ENDIF
					** jcNewLine=ccReturn+jcNewLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF


			IF ccArray$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating popup definition with dynamic array..."
				jcArr=wordsearch(ccArray)
				jPopup=levelName
				jPrompt=ALLTRIM(PROMPT)
				jLevel=ALLTRIM(levelName)
				SELECT tempProj
				jnLine=ATLINE("DEFINE BAR 1 OF "+UPPER(ALLTRIM(jPopup)),UPPER(OBJECT))
				IF jnLine>0
					jcStart=[PRIVATE ji]+ccReturn+;
						[FOR ji=1 TO ALEN(]+jcArr+[,1)]+ccReturn+ccTab + ;
						[IF ALEN(]+jcArr+[,2)<2]+ccReturn
					jcMid1=ccTab+ccTab+[DEFINE BAR ji OF ]+ALLTRIM(jLevel)+[ PROMPT ]+jcArr+[(ji)]+ccReturn+;
						ccTab+[ELSE]+ccReturn
					jcMiddle=ccTab+ccTab+[DEFINE BAR ji OF ]+ALLTRIM(jLevel)+[ PROMPT ]+jcArr+[(ji,1)]+;
						ccReturn+ccTab+[ENDIF]+ccReturn
					jcMid2=ccTab+[IF ALEN(]+jcArr+[,2)>1]+[ AND NOT EMPTY(]+jcArr+[(ji,2))]+ccReturn+;
						ccTab+ccTab+;
							[ON SELECTION BAR ji OF ]+ALLTRIM(jLevel)+[ &]+jcArr+'(ji,2)'+ccReturn+;
							ccTab+"ENDIF"+ccReturn
					jcMiddle=jcMid1+jcMiddle+jcMid2
					jcEnd='ENDFOR'
					** =addCleanup(jcStart+jcMiddle+jcEnd,"TOP")
					** jcStart='IF TYPE("'+ALLTRIM(jPopup)+'")="U" OR "'+ALLTRIM(jPopup)+'"$SYS(2013)'
					** jcEnd='ENDIF'
					jcFullLine=MLINE(OBJECT,jnLine)
					** jcPopName=ALLTRIM(SUBSTR(jcFullLine,ATC("DEFINE POPUP ",jcFullLine)+11   ,10  ))
					** jcNewLine=jcStart+ccReturn+ccTab+jcFullLine+ccReturn+jcEnd
					** jcNewLine=ccReturn+jcNewLine
					jcNewLine=ccReturn+jcStart+jcMiddle+jcEnd
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
					** Update Refresh Program
					IF llRefPrg
						jnTempArea=SELECT()
						SELECT 0
						CREATE CURSOR junk (Object M(10))
						APPEND BLANK
						IF FILE(lcRefPrg)
							APPEND MEMO Object FROM (lcRefPrg) OVERWRITE
						ENDIF
						REPLACE Object WITH Object+ccReturn+[** Update Array]+ccReturn+jcNewLine
						COPY MEMO Object TO (lcRefPrg)
						SELECT (jnTempArea)
						USE IN junk
					ENDIF
				ELSE
					=WARNING([No line with Define Popup])
				ENDIF
				SELECT tempscx
			ENDIF


			** COLOR Pair FOR MENU objects
			IF ccNoPad$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating PAD definitions..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					jSrch2="ON PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					? "Looking  for "+jSrch
				ENDIF
				** New  COLOR Setting
				jcSet=wordSearch(ccNoPad)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0 AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					jcNewLine="** "+jcFullLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				jnLine=ATLINE(jSrch2,UPPER(OBJECT))
				IF jnLine>0 AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					jcNewLine="** "+jcFullLine
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF
			
			*{ 05/13/95	Support for FONT Directives
			*{ This is only supported in VFP
			IF ccFont$UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating Font definitions..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					jSrch2="ON PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					? "Looking  for "+jSrch
				ENDIF
				** New  COLOR Setting
				jcSet=wordSearch(ccFont)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0 AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					IF RIGHT(TRIM(jcFullLine),1)=[;]
						jcFullLine= SUBSTR( jcFullLine,1, LEN(TRIM(jcFullLine))-1)
					ENDIF
					jcNewLine=jcFullLine+ [ FONT ]+jcSet
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF


			*{ 05/13/95	Support for CLAUSES Directives
			IF ccClause$ UPPER(comment)
				** GET the    PAD Name
				DO sayTherm WITH "Updating Clause definitions..."
				** Identify IF item is   A POPUP BAR OR PAD
				** This can  be   done FROM the  objCode
				IF NOT levelName='_MSYSMENU'
					IF EMPTY(name)
						jBar=ALLTRIM(itemNum)
					ELSE
						jBar=ALLTRIM(name)
					ENDIF
					jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
				ELSE
					jBar=ALLTRIM(name)
					jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					jSrch2="ON PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
					? "Looking  for "+jSrch
				ENDIF
				** New  COLOR Setting
				jcSet=wordSearch(ccClause)
				SELECT tempProj
				jnLine=ATLINE(jSrch,UPPER(OBJECT))
				IF jnLine>0 AND NOT jcSet=CHR(0)
					jcFullLine=MLINE(OBJECT,jnLine)
					IF RIGHT(TRIM(jcFullLine),1)=[;]
						jcFullLine= SUBSTR( jcFullLine,1, LEN(TRIM(jcFullLine))-1)
					ENDIF
					jcNewLine=jcFullLine+ [ ]+jcSet
					REPLACE OBJECT WITH strtranc(OBJECT,jcFullLine,jcNewLine)
				ENDIF
				SELECT tempscx
			ENDIF

			*{ 04/02/94 	Statements for CASE directive
			** CASE directive is very special so it will create another cursor to do the work in it.
			IF ccCase$UPPER(comment)
				Do sayTherm WITH "Defining CASE statements..."
				jcCase=wordSearch(ccCase,"comment")
				** We will store all of the CASEs to an array until finished the SCAN, then we will
				** create the CASE cursor and manipulate it.
				IF NOT TYPE([AC_CASE])=[C]
					DIMENSION ac_case(1)
				ELSE
					IF ASCAN(ac_case,jcCase)=0
						jnLen=ALEN(ac_case,1)
						DIMENSION ac_case(jnLen+1)
					ENDIF
				ENDIF
				IF ASCAN(ac_case,jcCase)=0
					jnLen=ALEN(ac_case,1)
					ac_case(jnLen)=jcCase
				ENDIF
				llCase=.T.
				IF UPPER(levelName)=[_MSYSMENU]
					** This is a PAD so we should update all of the items underneath it with the same
					** Case statement because we don't want them to show up unless it has a popup
					** or pad associated with it
					SKIP
					jcLevel=levelName
					jnCurrRec=RECNO()
					REPLACE ALL comment WITH comment+CHR(13)+ccCase+[ ]+jcCase ;
						FOR levelName=jcLevel AND NOT ccCase$comment
					GO (jnCurrRec)
				ENDIF
			ENDIF



		ENDSCAN
		
		*{ 05/13/95	Support for NOLOC (which removes the LOC FILE statement

		SELECT tempProj
		IF llNoLoc

			DO sayTherm WITH "Updating LOCFILE statements..."
			jcLocLine = LTRIM(MLINE(object, ATLINE( [IN LOCFILE(], object)))
			jcLocWords = SUBSTR( jcLocLine , ATC([IN LOCFILE], jcLocLine), ATC ( lcMenuBase, jcLocLine) -2)
			** REPLACE object WITH STRTRAN (object , jcLocWords, [IN ]+lcOutMain )
			IF [3.0] $ VERSION()
				jcLookFor = jcLocWords+lcMenuBase + ;
						[" ,"MPX;MPR|FXP;PRG" ,"]+ c_ui_whereisLOC +[ ]+lcMenuBase +[?")]
			ELSE			
				jcLookFor = [IN LOCFILE("]+ lcMenuBase + ;
							[" ,"MPX;MPR|FXP;PRG" ,"Where is ]+lcMenuBase +[?")]

			ENDIF
			REPLACE object WITH STRTRAN (object, jcLookFor, ;
						[IN ]+ TRIMPATH( lcOutMain) )
		
		ENDIF


		** Now that we're out of the table we can manipulate the Object table into a case statement
		
		IF llCase AND TYPE([AC_CASE])=[C]
			
			DO updCase
				** We only need to do this if the CASE cursor hasn't been created
				** Because we need to define the CASE array
				IF .F.
				llCase=.T.
				DO sayTherm WITH "Updating menu for CASE statement..."
				jnCurrArea=SELECT()
				SELECT 0
				CREATE TABLE _casecurs (prologue M(10), menuDef M(10), proc M(10), junk M(10), ;
					junk2 M(10), junk3 M(10))
				USE (DBF()) ALIAS caseCurs
				APPEND BLANK
				REPLACE menuDef WITH tempproj.Object
				** Using variables and this should speed up processing a bit.
				jnProLine=ATLINE("SET SYSMENU AUTOMATIC",UPPER(tempProj.object))
				IF jnProLine=0
					jnProLine=1
				ENDIF
				** We default the values to the min and max of the memo field
				jnClnLine=ATLINE("Cleanup Code & Procedures",tempProj.object)
				IF jnClnLine=0
					REPLACE tempProj.object WITH TempProj.object+CHR(13)+CHR(13)+CHR(13)
					jnClnLine=MEMLINES(tempProj.object)
				ENDIF
				jcPrologue=[]
				jcProc=[]
				_MLINE=0
				IF jnProLine>0 AND jnClnLine>0
					FOR ji=1 TO jnProLine
						jcPrologue=jcPrologue+MLINE(tempProj.object,ji)+CHR(13)+CHR(10)
					ENDFOR
					FOR ji=jnProLine+1 TO jnClnLine-3
						REPLACE junk WITH junk+MLINE(tempProj.object,ji)+CHR(13)+CHR(10)
					ENDFOR
					FOR ji=jnClnLine-2 TO MEMLINES(tempProj.object)
						jcProc=jcproc+MLINE(tempProj.object,ji)+CHR(13)+CHR(10)
					ENDFOR
					REPLACE prologue WITH jcPrologue
					REPLACE menuDef WITH junk
					REPLACE junk WITH []
					REPLACE proc WITH jcProc
				ELSE
					=warning([Problem with standard menu code.])
				ENDIF
				IF jnClnLine>0
					** FOR ji=jnClnLine-2 TO MEMLINES(tempProj.object)
					** 	REPLACE proc WITH proc+MLINE(tempProj.object,ji)+CHR(13)+CHR(10)
					** ENDFOR

					** FOR ji=jnProLine TO jnClnLine-3
					** 	REPLACE junk WITH junk+MLINE(tempProj.object,ji)+CHR(13)+CHR(10)
					** ENDFOR
					** REPLACE menuDef WITH junk
					** REPLACE junk WITH []
					** 	
				ENDIF
				** Now we need to scan the table again but this time for each CASE statement
				** In this case, we will be using the junk field to hold everything until we're ready
				REPLACE junk WITH junk+[DO CASE]+CHR(13)
				FOR jnCase=1 TO ALEN(ac_case,1)
					SELECT CaseCurs
					jcCase=ac_case(jnCase)
					DO sayTherm WITH [Building statement for ]+jcCase+[...]
					REPLACE junk WITH junk+[CASE ]+jcCase+CHR(13)+CHR(10)
					SELECT (jnCurrArea)
					** Try to speed this thing up here by only looking at CASE items
					SCAN FOR ccCase$comment && FOR ccCase+[ ]+jcCase$comment
			IF ccIgnore$comment
				LOOP
			ENDIF
						jcJunk2=[]
						jcJunk3=[]
						jcCase2=wordSearch(ccCase,"comment")
						IF NOT jcCase2==jcCase
							LOOP
						ENDIF
						jLevel=UPPER(levelName)
						IF NOT jLevel='_MSYSMENU'
							IF EMPTY(name)
								jBar=ALLTRIM(itemNum)
							ELSE
								jBar=ALLTRIM(name)
							ENDIF
							jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))
						ELSE
							jBar=ALLTRIM(name)
							jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
						ENDIF
						SELECT CaseCurs
						jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
						IF jnLine=0
							=WARNING([Could not find ]+jSrch)
						ENDIF
						IF jnLine>0
							jcFullLine=MLINE(menuDef,jnLine)
							** Now let's just make sure we get the whole line
							jNumLine=jnLine
							IF RIGHT(ALLTRIM(jcFullLine),1)=";"
								jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+1)
								jNumLine=jNumLine+1
								IF RIGHT(ALLTRIM(jcFullLine),1)=";"
									jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+2)
									jNumLine=jNumLine+1
								ENDIF
							ENDIF
							_MLINE=0
							FOR ji=1 TO jnLine-1
								jcjunk2 = jcjunk2+MLINE(menuDef,ji)+CHR(13)+CHR(10)
							ENDFOR
							FOR ji=jNumLine+1 TO MEMLINES(menuDef)
								jcjunk3 = jcjunk3+MLINE(menuDef,ji)+CHR(13)+CHR(10)
							ENDFOR
							REPLACE menuDef WITH jcjunk2+jcjunk3
							** REPLACE junk3 WITH [], junk2 WITH []
							jcJunk3=[]
							jcJunk2=[]
							REPLACE junk WITH junk+jcFullLine+CHR(13)
						ENDIF

						IF [PAD]$jSrch
							jSrch=[ON PAD ]+jBar+[ OF ]+jLevel
							SELECT CaseCurs
							jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
							IF jnLine=0
								=WARNING([Could not find ]+jSrch)
							ENDIF
							IF jnLine>0
								jcFullLine=MLINE(menuDef,jnLine)
								
								** Now let's just make sure we get the whole line
								jNumLine=jnLine
								IF RIGHT(ALLTRIM(jcFullLine),1)=";"
									jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+1)
									jNumLine=jNumLine+1
									IF RIGHT(ALLTRIM(jcFullLine),1)=";"
										jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+2)
										jNumLine=jNumLine+1
									ENDIF
								ENDIF
								_MLINE=0
								FOR ji=1 TO jnLine-1
									jcjunk2 = jcjunk2+MLINE(menuDef,ji)+CHR(13)+CHR(10)
								ENDFOR
								FOR ji=jNumLine+1 TO MEMLINES(menuDef)
									jcjunk3 =jcjunk3+MLINE(menuDef,ji)+CHR(13)+CHR(10)
								ENDFOR
								REPLACE menuDef WITH jcjunk2+jcjunk3
								jcjunk3 =[]
								jcjunk2 =[]
								REPLACE junk WITH junk+jcFullLine+CHR(13)
							ENDIF
						ENDIF							

						IF [ACTIVATE POPUP]$UPPER(jcFullLine)
							** Identify popup (last item!)
							jPopName=ALLTRIM(SUBSTR(jcFullLine, AT("POPUP",jcFullLine)+6,15))
							jSrch=[DEFINE POPUP ]+jPopName
							SELECT CaseCurs
							jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
							IF jnLine=0
								=WARNING([Could not find ]+jSrch)
							ENDIF
							IF jnLine>0
								jcFullLine=MLINE(menuDef,jnLine)
								
								** Now let's just make sure we get the whole line
								jNumLine=jnLine
								IF RIGHT(ALLTRIM(jcFullLine),1)=";"
									jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+1)
									jNumLine=jNumLine+1
									IF RIGHT(ALLTRIM(jcFullLine),1)=";"
										jcFullLine=jcFullLine+CHR(13)+MLINE(menuDef,jnLine+2)
										jNumLine=jNumLine+1
									ENDIF
								ENDIF
								_MLINE=0
								FOR ji=1 TO jnLine-1
									jcjunk2 =jcjunk2+MLINE(menuDef,ji)+CHR(13)+CHR(10)
								ENDFOR
								FOR ji=jNumLine+1 TO MEMLINES(menuDef)
									jcjunk3 =jcjunk3+MLINE(menuDef,ji)+CHR(13)+CHR(10)
								ENDFOR
								REPLACE menuDef WITH jcjunk2+jcjunk3
								jcjunk3 =[]
								jcjunk2 =[]
								REPLACE junk WITH junk+jcFullLine+CHR(13)
							ENDIF
							
							SELECT (jnCurrArea)
							
							
						ENDIF
						
						
					ENDSCAN
				ENDFOR
				SELECT CaseCurs
				** Now if REFPRG is turned on, create the program
				** with the CASE statement
				REPLACE junk WITH ccCaseHdr+junk+[ENDCASE]+CHR(13) && +menuDef+CHR(13)
				IF llRefPrg
					IF TYPE([LCREFPRG])=[U] OR EMPTY(lcRefPrg)
						=WARNING("Refresh Program was not identified!")
					ELSE
						COPY MEMO Junk TO (lcRefPrg)
					ENDIF
				ENDIF
				REPLACE junk WITH menuDef+CHR(13)+junk+CHR(13)
				REPLACE menuDef WITH prologue+junk+proc
				SELECT tempProj
				REPLACE object WITH CaseCurs.menuDef
				USE IN caseCurs
				ERASE casecurs.dbf
				ERASE casecurs.fpt
				SELECT (jnCurrArea)
				ENDIF
		ENDIF
	ENDIF
	DO sayTherm WITH [Updating project file...]
	ERASE (jcOutFile)
	SELECT tempproj
	COPY MEMO OBJECT TO (jcOutFile)
	USE IN tempScx
	USE IN tempProj

	** Select temporary project so we can fool around with the MPR file
	USE ( jcTProjExt) IN 0          ALIAS tempproj
	SELECT tempProj
	GO BOTT
	APPEND MEMO OBJECT FROM ( jcOutFile) OVERWRITE
	*] Run MPRDRV1 Driver
	IF jlDriver1 AND NOT llNoxGen
		=DoDrvArr(@ja_drv1)
	ENDIF

	IF NOT llNoXGen
		IF NOT llNoGen
			*] GENERAL MPR    Changes
			** IF NOSHADOW, remove any    references TO SHADOW IN the    MPR    FILE
			DO sayTherm WITH "Updating Generated Code..."
			IF llNoShadow
				REPLACE OBJECT WITH STRTRAN(OBJECT,"SHADOW ")
			ENDIF
			** IF NOMARGIN, remove any    references TO MARGIN IN the    MPR    FILE
			IF llNoMargin
				REPLACE OBJECT WITH STRTRAN(OBJECT,"MARGIN ","")
			ENDIF
			** IF POPCOLOR, REPLACE ALL references TO COLOR SCHEME 4          (GENMENU DEFAULT) WITH jPopColor
			IF llpadColor
				REPLACE OBJECT WITH STRTRAN(OBJECT,"COLOR SCHEME 4","COLOR SCHEME "+jPadColor)
			ENDIF
			** IF POPCOLOR, REPLACE ALL references TO COLOR SCHEME 3          (GENMENU DEFAULT) WITH jPadColor
			IF llPopColor
				REPLACE OBJECT WITH STRTRAN(OBJECT,"COLOR SCHEME 3","COLOR SCHEME "+jPopColor)
			ENDIF

			IF llSelectPad
				REPLACE OBJECT WITH STRTRAN(OBJECT,CHR(10)+"ON PAD",CHR(10)+"ON SELECTION PAD")
			ENDIF
			IF llSelectBar
				REPLACE OBJECT WITH STRTRAN(OBJECT,CHR(10)+"ON BAR",CHR(10)+"ON SELECTION BAR")
			ENDIF
			** IF LINE is       changing MARK it       here

			IF llWindow OR llChngLine OR llNoBar OR llChngName OR llChngCol OR llChngScheme
				jStartLine='DEFINE MENU _MSYSMENU '
				IF llWindow
					jPreAmble=CHR(13)+"SET SYSMENU TO "+ccReturn+ccReturn+"IF WEXIST('"+ALLTRIM(jWinName)+"')"+ccReturn+ccTab
					jStartLine=jStartLine+" IN "+jWindow
					jPostAmble=ccReturn+"ELSE"+ccReturn+ccTab+"SET SYSMENU TO"+ccReturn+"ENDIF"+ccReturn
				ENDIF
				IF llChngLine
					** IF LINE has    been changed, SYSTEM has    TO have NOBAR turned on.
					IF NOT llNoBar
						jStartLine=jStartLine+" BAR AT LINE "+jLine
					ELSE
						** This are    mutually EXCLUSIVE
						** Ignore LINE
						** REPLACE OBJECT WITH STRTRAN(OBJECT,"SET SYSMENU AUTOMATIC","DEFINE MENU _MSYSMENU AT LINE "+jLine)
					ENDIF
				ENDIF
				IF llNoBar AND NOT llChngLine
					jStartLine=jstartLine
					** REPLACE setup WITH strtranc(setup,ccNoBar,"*-:"+SUBSTR(ccNoBar,3      ,LEN(ccNoBar)))
				ELSE
					IF NOT llNoBar
						IF NOT "BAR"$jStartLine
							jStartLine=jStartLine+" BAR"
						ENDIF
					ENDIF
				ENDIF
				IF llChngCol
					jStartLine=jStartLine+" COLOR "+jcColPair
				ENDIF
				IF llChngScheme
					jStartLine=jStartLine+" COLOR SCHEME "+jcColScheme
				ENDIF
				IF llWindow
					jPostAmble=ccReturn+"ELSE"+ccReturn+ccTab+STRTRAN(jStartLine,"IN "+ALLTRIM(jWindow))+ccReturn+"ENDIF"+ccReturn
				ENDIF
				IF llWindow AND NOT "SCREEN"$jWindow
					jStartLine=jPreAmble+jStartLine+jPostAmble
				ENDIF
				
				** UPDATE SET SYSMENU AUTOMATIC LINE
				REPLACE OBJECT WITH STRTRAN(OBJECT,"SET SYSMENU TO"+CHR(13)+CHR(10),"SET SYSMENU TO"+ccReturn+jStartLine+CHR(13)+CHR(10))
			ENDIF
			** Remove SET SYSMENU AUTOMATIC FROM SPR    FILE
			IF llNoAuto
				REPLACE OBJECT WITH STRTRAN(OBJECT,"SET SYSMENU AUTOMATIC")
			ENDIF

			IF llNoAct
				REPLACE OBJECT WITH STRTRAN(OBJECT,"ACTIVATE MENU _MSYSMENU")
			ENDIF

			IF llXplatKeys
				** Remove empty key labels
				REPLACE OBJECT WITH STRTRAN(object, [KEY &_keyPrompt, ""], [KEY &_keyPrompt] )
			ENDIF
				
				
			** CHANGE MENU Name AFTER Everything is       done
			IF llChngName
				** CHANGE MENU Name
				REPLACE OBJECT WITH STRTRAN(OBJECT,"_MSYSMENU",jMenuName)
			ENDIF

			IF "{{"$OBJECT
				REPLACE OBJECT WITH evltxt(OBJECT)
			ENDIF

			*] RUN MPRDRV2 Driver
			IF jlDriver2
				=DoDrvArr(@ja_drv2)
			ENDIF
		ENDIF
	ENDIF
	ERASE (jcOutFile)
	IF llNoComment
		** Strip out  out  ALL comments FROM this FILE
		DO sayTherm WITH "Stripping comments..."
		** Strip out  out  ALL comments FROM this FILE
		FOR ji  =1    TO MEMLINES(OBJECT)
			IF LEFT(ALLTRIM(MLINE(OBJECT,ji  )),1)='*' AND LEN(ALLTRIM(MLINE(OBJECT,ji  )))>1
				** This is   A comment (DUMP IT  !)
				cld =MLINE(OBJECT,ji  )
				REPLACE OBJECT WITH STRTRAN(OBJECT,cld ,ccNull)
			ENDIF
		ENDFOR
		FOR ji  =1    TO MEMLINES(OBJECT)
			IF LEFT(ALLTRIM(MLINE(OBJECT,ji  )),1)='*'
				** This is   A comment (DUMP IT  !)
				cld =MLINE(OBJECT,ji  )
				REPLACE OBJECT WITH STRTRAN(OBJECT,cld ,ccNull)
			ENDIF
		ENDFOR

		DO WHILE OCCURS(ccReturn+ccLineFeed+ccReturn,OBJECT)>0
			REPLACE OBJECT WITH STRTRAN(OBJECT,ccReturn+ccLineFeed+ccReturn,ccReturn)
		ENDDO
		DO WHILE OCCURS(ccReturn+ccReturn,OBJECT)>0
			REPLACE OBJECT WITH STRTRAN(OBJECT,ccReturn+ccReturn,ccReturn)
		ENDDO
	ENDIF
	COPY MEMO OBJECT TO (jcOutFile)
	SELECT tempProj
	USE

	*-- Return to pjxbase
	SELECT (jnOldAlias)

	*-- Now compile the result
	COMPILE ( jcOutFile )

	*-- load the object code
	DO sayTherm WITH "Updating Object Code..."
	DO updTherm WITH 50
	* APPEND MEMO object FROM (jcTName + ".MPX") OVERWRITE
	APPEND MEMO OBJECT FROM ( jcResultFile) OVERWRITE
ENDIF

DO sayTherm WITH "Removing temporary files..."
DO updTherm WITH 95
*-- Erase temporary files
ERASE ( jcTName + ".MNT")
ERASE ( jcTName + ".MPX")
ERASE ( jcTName + ".MNX")
ERASE ( jcTName + ".MPR")
ERASE ( jcTProj + ".PJT")
ERASE ( jcTProj + ".PJX")

IF USED("PJXBASE")
	USE IN pjxBase
ENDIF

WAIT CLEAR
DO updTherm WITH 100
DO deatherm
DO cleanup
SET CURSOR &jcCursor
ON ERROR &jcCurrErr
SET ESCAPE ON
** If menu is to be run immediately after being created
IF NOT llNoXGen
	IF llAutoRun
		DO (jcResultFile)
	ENDIF
ENDIF

RETURN  jgStatus

*!*****************************************************************
*!
*!       Function: CONFIGFP
*!
*!*****************************************************************
FUNCTION configfp
PARAMETERS find_opt,find_dflt,occurrence
PRIVATE cnfg_opt,config_str,memline,at_pos,at_pos2,i
PRIVATE lf, cr
m.lf=ccLineFeed
m.cr=ccReturn
IF TYPE('m.find_dflt')#'C'
  m.find_dflt=''
ENDIF
IF EMPTY(m.find_opt).OR.EMPTY(jfconfigfp)
  RETURN UPPER(ALLTRIM(m.find_dflt))
ENDIF
m.config_str=CONFIGFP.FP
m.find_opt=UPPER(m.find_opt)
m.cnfg_opt=m.find_dflt
IF TYPE('m.occurrence')#'N'
  m.occurrence=1
ENDIF
FOR m.i = m.occurrence TO 255
  m.at_pos=ATC(m.find_opt,m.config_str,m.i)
  IF m.at_pos=0
    EXIT
  ENDIF
  IF m.at_pos>1
    m.memline=SUBSTR(m.config_str,m.at_pos-1,1)
    IF .NOT.INLIST(m.memline,m.lf,m.cr,' ',CHR(9))
      EXIT
    ENDIF
  ENDIF
  m.memline=trimdelim(STRTRAN(STRTRAN(ALLTRIM(UPPER(SUBSTR(m.config_str,m.at_pos))),;
            CHR(9),' '),CHR(34),''))
  IF _MAC
    DO WHILE .T.
      m.at_pos2=AT(' =',m.memline)
      IF m.at_pos2=0
        EXIT
      ENDIF
      m.memline=STRTRAN(m.memline,' =','=')
    ENDDO
  ELSE
    m.memline=STRTRAN(STRTRAN(STRTRAN(STRTRAN(m.memline,CHR(39),''),;
              '[',''),']',''),' ','')
  ENDIF
  m.at_pos2=AT(m.cr,m.memline)
  IF m.at_pos2>0
    m.memline=LEFT(m.memline,m.at_pos2-1)
  ENDIF
  m.at_pos=AT('=',m.memline)
  IF m.at_pos=(LEN(m.find_opt)+1)
    m.cnfg_opt=SUBSTR(m.memline,m.at_pos+1)
    EXIT
  ENDIF
ENDFOR
RETURN UPPER(ALLTRIM(m.cnfg_opt))

* END configfp



	*!*****************************************************************
	*!
	*!       Function: ADD_FEXT
	*!
	*!*****************************************************************
FUNCTION add_fext
	PARAMETERS m.filename
	PRIVATE m.filename,m.i

	IF EMPTY(m.filename) .OR. '.'$m.filename
		m.filename=IIF(_WINDOWS,LOWER(m.filename),UPPER(m.filename))
		RETURN m.filename
	ENDIF
	FOR m.i    = 1          TO ALEN(ja_file_ext)
		IF FILE(m.filename+ja_file_ext(m.i))
			m.filename=m.filename+ja_file_ext(m.i)
			m.filename=IIF(_WINDOWS,LOWER(m.filename),UPPER(m.filename))
			RETURN m.filename
		ENDIF
	ENDFOR
	m.filename=m.filename+'.PRG'
	m.filename=IIF(_WINDOWS,LOWER(m.filename),UPPER(m.filename))
	RETURN m.filename

	* END add_fext

	*!*****************************************************************
	*!
	*!       Function: EVLTXT
	*!
	*!*****************************************************************
FUNCTION evltxt
	PARAMETERS m.old_text
	PRIVATE m.old_text,m.new_text,m.eval_str,m.eval_str1,m.eval_str2,m.var_type
	PRIVATE m.at_pos,m.at_pos2,m.at_pos3,m.at_pos4,m.at_pos5,m.old_str,m.new_str
	PRIVATE m.i ,m.j ,m.at_line,m.onerror,ccReturn_lf,m.evlmode,m.mthd_str,m.sellast

	IF NOT TYPE("m.old_text") = [C]
		RETURN []
	ENDIF
	ccReturn_lf=CHR(13  )+CHR(10  )
	m.onerror=ON('ERROR')
	m.new_text=m.old_text
	m.at_pos3=1
	DO WHILE .T.
		m.at_pos=AT('{{',SUBSTR(m.old_text,m.at_pos3))
		IF m.at_pos=0
			EXIT
		ENDIF
		m.at_pos2=AT('}}',SUBSTR(m.old_text,m.at_pos+m.at_pos3-1))
		IF m.at_pos2=0
			EXIT
		ENDIF
		m.at_pos4=AT('{{',SUBSTR(m.old_text,m.at_pos+m.at_pos3+1))
		IF m.at_pos4>0 AND m.at_pos4<m.at_pos2
			m.at_pos4=OCCURS('{{',SUBSTR(m.old_text,m.at_pos+m.at_pos3-1,;
				m.at_pos2-m.at_pos4))
			m.at_pos4=AT('{{',SUBSTR(m.old_text,m.at_pos+m.at_pos3-1),m.at_pos4)
			m.old_str=SUBSTR(m.old_text,m.at_pos+m.at_pos3-1,m.at_pos2+1)
			m.eval_str=SUBSTR(m.old_str,3,LEN(m.old_str)-2)
			m.old_str=evltxt(m.eval_str)
			m.old_text=STRTRAN(m.old_text,m.eval_str,m.old_str)
			m.new_text=STRTRAN(m.new_text,m.eval_str,m.old_str)
			LOOP
		ENDIF
		m.old_str=SUBSTR(m.old_text,m.at_pos+m.at_pos3-1,m.at_pos2+1)
		m.eval_str=ALLTRIM(SUBSTR(m.old_str,3,LEN(m.old_str)-4))
		DO esc_check
		m.evlmode=.F.
		ON ERROR DO errorhnd WITH ERROR(),MESSAGE(),PROGRAM(),LINENO(),;
			m.old_str+ccReturn_lf+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+;
			'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+;
			ccReturn_lf+MESSAGE(1)
		DO CASE
			CASE EMPTY(m.eval_str)
				m.eval_str=''
			CASE LEFT(m.eval_str,2)=='&.'
				m.eval_str=SUBSTR(m.eval_str,3)
				&eval_str &&;
					;
					ERROR occured during MACRO substitution OF {{&.   <expC> }}.
				m.eval_str=''
			CASE LEFT(m.eval_str,1)=='<'
				m.eval_str=INSERT(SUBSTR(m.eval_str,2)) &&;
					;
					ERROR occured during evaluation OF {{< <FILE> }}.
			CASE '::'$m.eval_str
				m.eval_str1=''
				m.eval_str2=''
				m.at_pos4=AT('||',m.eval_str)
				IF m.at_pos4>0
					m.eval_str2=IIF(m.at_pos4>0,SUBSTR(m.eval_str,m.at_pos4+2),'')
					m.eval_str=LEFT(m.eval_str,m.at_pos4-1)
				ENDIF
				FOR m.i  = 1    TO 2
					m.at_pos4=AT('::',m.eval_str)
					m.evlmode=.T.
					m.eval_str=objdata(LEFT(m.eval_str,m.at_pos4-1),;
						SUBSTR(m.eval_str,m.at_pos4+2)) &&;
						;
						ERROR occured during evaluation OF {{ <expC1> ::   <expC2> }}.
					IF m.i =1 AND NOT EMPTY(m.eval_str2)
						m.eval_str1=m.eval_str
						m.eval_str=m.eval_str2
						LOOP
					ENDIF
					m.evlmode=.F.
					IF m.i =2
						m.eval_str2=m.eval_str
						IF EMPTY(m.eval_str2)
							m.eval_str=m.eval_str1
							EXIT
						ENDIF
						IF EMPTY(m.eval_str1)
							m.eval_str=m.eval_str2
							EXIT
						ENDIF
						m.sellast=SELECT()
						IF NOT USED('_TEMPFILE')
							CREATE CURSOR _TEMPFILE (COMMENT M, SETUPCODE M)
							INSERT BLANK
						ENDIF
						SELECT _TEMPFILE
						LOCATE
						REPLACE COMMENT WITH m.eval_str2, SETUPCODE WITH m.eval_str1
						m.eval_str1=''
						m.eval_str2=''
						DO WHILE .T.
							=esc_check()
							m.mthd_str=wordsearch(m.c_method)
							IF m.mthd_str==ccNull
								m.eval_str=COMMENT+ccReturn_lf+SETUPCODE
								EXIT
							ENDIF
							IF EMPTY(m.mthd_str)
								REPLACE COMMENT WITH strtranc(m.c_method,m.m_method,1,1)
								LOOP
							ENDIF
							m.at_pos4=ATC(m.c_method+' '+m.mthd_str+ccReturn,COMMENT+ccReturn)
							IF m.at_pos4=0
								REPLACE COMMENT WITH strtranc(m.c_method,m.m_method,1,1)
								LOOP
							ENDIF
							m.at_pos5=ATC(m.c_endmthd,SUBSTR(COMMENT,m.at_pos4))
							IF m.at_pos5>0
								m.at_pos5=m.at_pos5+LEN(m.c_endmthd)
							ELSE
								m.at_pos5=LEN(COMMENT)+1
							ENDIF
							m.eval_str1=SUBSTR(COMMENT,m.at_pos4,m.at_pos5)+ccReturn_lf
							REPLACE COMMENT WITH LEFT(COMMENT,m.at_pos4-1)+;
								SUBSTR(COMMENT,m.at_pos4+m.at_pos5)
							m.at_pos4=ATC(m.c_method+' '+m.mthd_str+ccReturn,SETUPCODE+ccReturn)
							IF m.at_pos4=0
								LOOP
							ENDIF
							m.at_pos5=ATC(m.c_endmthd,SUBSTR(SETUPCODE,m.at_pos4))
							IF m.at_pos5>0
								m.at_pos5=m.at_pos5+LEN(m.c_endmthd)
							ELSE
								m.at_pos5=LEN(SETUPCODE)+1
							ENDIF
							REPLACE SETUPCODE WITH LEFT(SETUPCODE,m.at_pos4-1)+m.eval_str1+;
								SUBSTR(SETUPCODE,m.at_pos4+m.at_pos5)
						ENDDO
						m.eval_str=SETUPCODE
						SELECT (m.sellast)
					ENDIF
					EXIT
				ENDFOR
				m.eval_str1=''
				m.eval_str2=''
			OTHERWISE
				m.eval_str=EVALUATE(m.eval_str) &&;
					;
					ERROR occured during evaluation OF {{ <expC> }}.
		ENDCASE
		IF EMPTY(m.onerror)
			ON ERROR
		ELSE
			ON ERROR &onerror
		ENDIF
		m.var_type=TYPE('m.eval_str')
		DO CASE
			CASE m.var_type=='C'
				m.new_str=m.eval_str
			CASE m.var_type=='N'
				m.new_str=ALLTRIM(STR(m.eval_str,24  ,12  ))
				DO WHILE RIGHT(m.new_str,1)=='0'
					m.new_str=LEFT(m.new_str,LEN(m.new_str)-1)
					IF RIGHT(m.new_str,1)=='.'
						m.new_str=LEFT(m.new_str,LEN(m.new_str)-1)
						EXIT
					ENDIF
				ENDDO
			CASE m.var_type=='D'
				m.new_str=DTOC(m.eval_str)
			CASE m.var_type=='L'
				m.new_str=IIF(m.eval_str,'.T.','.F.')
			OTHERWISE
				m.new_str=m.old_str
		ENDCASE
		m.new_text=STRTRAN(m.new_text,m.old_str,m.new_str)
		m.at_pos2=m.at_pos+LEN(m.new_str)
		IF m.at_pos2<=0
			EXIT
		ENDIF
		m.at_pos3=m.at_pos3+m.at_pos2
	ENDDO
	m.j =0
	DO WHILE '{{'$m.new_text AND '}}'$m.new_text
		=esc_check()
		m.i =LEN(m.new_text)
		m.new_text=evltxt(m.new_text)
		IF m.i =LEN(m.new_text)
			IF m.j >=2
				EXIT
			ENDIF
			m.j =m.j +1
		ENDIF
	ENDDO
	RETURN m.new_text

	* END evltxt


	*!*****************************************************************
	*!
	*!      Procedure: ERRORHND
	*!
	*!*****************************************************************
PROCEDURE errorhnd
PARAMETER error_no,msg,prg_name,line_no,codeline
PRIVATE colright,row,col,lasterror,lastcursr,prompt,maxcols
PRIVATE prg_name2,prg_name3,prg_nameno,prg_flag

m.lasterror=ON('ERROR')
ON ERROR
SET ESCAPE OFF
WAIT CLEAR
CLEAR GETS
CLEAR TYPEAHEAD
m.lastcursr=SET('CURSOR')
SET CURSOR OFF
m.prg_flag=.F.
m.prg_name2=m.prg_name
FOR m.prg_nameno = 32 TO 1 STEP -1
  m.prg_name3=PROGRAM(m.prg_nameno)
  IF EMPTY(m.prg_name3)
    LOOP
  ENDIF
  IF m.prg_name3=m.prg_name
    m.prg_flag=.T.
    LOOP
  ENDIF
  IF m.prg_flag
    m.prg_name2=m.prg_name2+', '+m.prg_name3
  ENDIF
ENDFOR
m.row=IIF(_DOS.OR._UNIX,INT((SROWS()-20)/2),0)
m.col=IIF(_DOS.OR._UNIX,INT((SCOLS()-69)/2),0)
DEFINE WINDOW win_prompt FROM m.row,m.col;
                         TO m.row+20,m.col+69;
              TITLE ' GENMENUX Error Mode ';
              DOUBLE FLOAT SHADOW COLOR SCHEME 7
ACTIVATE WINDOW win_prompt
m.maxcols=WCOLS()-2
m.colright=WCOLS()-19
IF LEN(m.prg_name2)>(m.colright-8)
  m.prg_name2=LEFT(LEFT(m.prg_name2,m.colright-8),RAT(',',m.prg_name2)-1)
ENDIF
m.codeline=ALLTRIM(m.codeline)
m.colorschm=IIF(_WINDOWS.OR._MAC,2,1)
@ 1,1 EDIT m.codeline;
      SIZE 8,m.maxcols;
      NOMODIFY SCROLL;
      COLOR SCHEME (m.colorschm)
@ 9,1 TO 9,m.maxcols
@ 10,1 SAY 'Error message :  '
?? PADR(ALLTRIM(m.msg),m.colright)
@ 11,1 SAY 'Error number  :  '
?? LTRIM(STR(m.error_no))
@ 12,1 SAY 'Procedure name:  '
?? PADR(ALLTRIM(m.prg_name2),m.colright)
@ 13,1 SAY 'Line number   :  '
?? IIF(m.line_no>0,LTRIM(STR(m.line_no)),'Unknown')
IF .NOT.EMPTY(ALIAS()) AND USED([TEMPSCX])
  @ 14,1 SAY 'Data source   :  '
  ?? PADR(DBF('tempscx')+'  [MNXBASE]',m.colright)
  @ 15,1 SAY 'Data current  :  '
  ?? PADR(ALLTRIM(DBF())+'  ['+ALIAS()+']',m.colright)
  @ 16,1 SAY 'Record number :  '
  ?? LTRIM(STR(RECNO()))
ENDIF
@ 17,1 TO 17,m.maxcols
@ 18,9 GET m.prompt ;
       PICTURE "@*HT \!\<Cancel;\<Suspend;\<Ignore" ;
       SIZE 1,11,8 ;
       DEFAULT 1
SET CURSOR ON
READ CYCLE MODAL OBJECT 2
DO CASE
  CASE m.prompt=2
    @ 18,0 CLEAR
    ACTIVATE SCREEN
    ACTIVATE WINDOW Command
    SET ESCAPE ON
    SUSPEND
    SET ESCAPE OFF
    RELEASE WINDOW win_prompt
    SET CURSOR &lastcursr
    ON ERROR &lasterror
    RETURN
  CASE m.prompt=3
    RELEASE WINDOW win_prompt
    SET CURSOR &lastcursr
    ON ERROR &lasterror
    RETURN
ENDCASE
RELEASE WINDOW win_prompt
m.gen_mode=.F.
DO cleanup
CANCEL

* END errorhnd



PROCEDURE esc_check
PRIVATE i

IF CHRSAW()
  m.i=INKEY('H')
  IF m.i=27
    DO cleanup
    CANCEL
  ENDIF
ENDIF
RETURN

* END esc_check


	*!*****************************************************************
	*!
	*!      Procedure: ACTTHERM
	*!
	*!*****************************************************************
PROCEDURE acttherm
	PARAMETER m.text
	PRIVATE m.prompt
	#DEFINE c_dlgFace "MS Sans Serif"
	#DEFINE c_dlgSize 8
	#DEFINE c_dlgStyle "B"
	IF gx_graphic
		IF llNoXTherm
			DEFINE WINDOW gxthermCol ;
				AT  INT((SROW() - (( 5.615 * ;
				FONTMETRIC(1, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
				FONTMETRIC(1, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2), ;
				INT((SCOL() - (( 63.833 * ;
				FONTMETRIC(6, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
				FONTMETRIC(6, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2) ;
				SIZE 5.615,63.833 ;
				FONT c_dlgFace, c_dlgsize ;
				STYLE c_dlgstyle ;
				NOFLOAT ;
				NOCLOSE ;
				NONE ;
				COLOR RGB(0, 0, 0, 192 , 192 , 192 )

		ELSE
			DEFINE WINDOW gxThermCol ;
				AT  INT((SROW() - (( 20.615 * ;
				FONTMETRIC(1      , c_dlgface, c_dlgsize, c_dlgstyle )) / ;
				FONTMETRIC(1      , WFONT(1      ,""), WFONT( 2      ,""), WFONT(3      ,"")))) / 2), ;
				INT((SCOL() - (( 63.833 * ;
				FONTMETRIC(6      , c_dlgface, c_dlgsize, c_dlgstyle )) / ;
				FONTMETRIC(6      , WFONT(1      ,""), WFONT( 2      ,""), WFONT(3      ,"")))) / 2) ;
				SIZE 17.615,63.833 ;
				FONT "MS Sans Serif", c_dlgsize ;
				STYLE c_dlgstyle ;
				NOFLOAT ;
				NOCLOSE ;
				NONE ;
				COLOR RGB(0      , 0      , 0      , 192, 192, 192)
		ENDIF

		MOVE WINDOW gxThermCol CENTER
		ACTIVATE WINDOW gxThermCol NOSHOW
		@ 0.5,3          SAY m.text FONT c_dlgFace, c_dlgSize STYLE c_dlgStyle
		@ 0.000,0.000 TO 0.000,63.833 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		@ 0.000,0.000 TO 17.615,0.000 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		@ 0.385,0.667 TO 17.231,0.667 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 0.308,0.667 TO 0.308,63.167 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 0.385,63.000 TO 17.308,63.000 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		@ 5.231,0.667 TO 17.231,63.167 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		@ 5.538,0.000 TO 17.538,63.833 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 0.000,63.667 TO 17.615,63.667 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 3.000,3.333 TO 4.231,3.333 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 3.000,60.333 TO 4.308,60.333 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		@ 3.000,3.333 TO 3.000,60.333 ;
			COLOR RGB(128, 128, 128, 128, 128, 128)
		@ 4.231,3.333 TO 4.231,60.500 ;
			COLOR RGB(255, 255, 255, 255, 255, 255)
		m.gx_thermWidth = 56.269

		IF NOT llNoXTherm
			@ 14   ,3          SAY PADC(ccMNXTitle,WCOLS("gxThermcol")) ;
				FONT c_dlgFace, c_dlgSize STYLE c_dlgStyle
			@ 15   ,3          SAY PADC(ccMNXVer,WCOLS("gxThermcol")) ;
				FONT c_dlgFace, c_dlgSize STYLE c_dlgStyle
		ENDIF
		SHOW WINDOW gxThermCol TOP
	ELSE
		IF llNoXTherm
			DEFINE WINDOW gxThermCol;
				FROM INT((SROW()-6)/2), INT((SCOL()-57  )/2) ;
				TO INT((SROW()-6)/2) + 6, INT((SCOL()-57  )/2) + 57  ;
				DOUBLE COLOR SCHEME 5
			ACTIVATE WINDOW gxThermCol NOSHOW
		ELSE
			DEFINE WINDOW gxThermCol;
				FROM INT((SROW()-20)/2), INT((SCOL()-62)/2) ;
				TO INT((SROW()-10)/2) + 10   , INT((SCOL()-62)/2) + 62      ;
				DOUBLE COLOR SCHEME 5
			ACTIVATE WINDOW gxThermCol NOSHOW
		ENDIF

		@ 0      ,3          SAY m.text
		@ 2      ,1          TO 4      ,m.gx_thermWidth+4
		IF NOT llNoXTherm
			@ 9      ,3          SAY PADC(ccMNXTitle,WCOLS("gxThermCol") )
			@ 10     ,3          SAY PADC(ccMNXVer,WCOLS("gxThermCol") )
		ENDIF
		SHOW WINDOW gxThermCol TOP
	ENDIF
	ACTIVATE SCREEN
	RETURN


	*!*****************************************************************
	*!
	*!      Procedure: DEATHERM
	*!
	*!*****************************************************************
PROCEDURE deatherm
	IF WEXIST("gxThermCol")
		RELEASE WINDOW gxThermCol && thermomete
	ENDIF
	RETURN

	*!*****************************************************************
	*!
	*!      Procedure: UPDTHERM
	*!
	*!*****************************************************************
PROCEDURE updTherm
	PARAMETER m.percent
	ACTIVATE WINDOW gxThermCol
	IF m.percent>100
		m.percent=100
	ENDIF
	m.nblocks = (m.percent/100) * (m.gx_thermWidth)
	IF m.gx_graphic
		@ 3.000,3.333 TO 4.231,m.nblocks + 3.333 ;
			PATTERN 1          COLOR RGB(128, 128, 128, 128, 128, 128)
	ELSE
		@ 3      ,3          SAY REPLICATE("Û",m.nblocks)
		@ 3      ,WCOLS()/2         -LEN(LTRIM(STR(m.percent))) SAY LTRIM(STR(m.percent))+"%"

	ENDIF
	ACTIVATE SCREEN
	RETURN
	*: EOF: UPDTHERM.PRG

	*!*****************************************************************
	*!
	*!      Procedure: SAYTHERM
	*!
	*!*****************************************************************
PROCEDURE saytherm
	PARAMETERS m.string
	IF NOT lcLastSay$m.string
		lcLastSay=m.string
	ENDIF
	ACTIVATE WINDOW gxThermCol
	IF LEN(m.string)>WCOLS()-3
		m.string=LEFT(m.string,WCOLS()-3)
	ENDIF
	IF m.gx_graphic
		@ 1.5,3 CLEAR TO 3, WCOLS()-1
		@ 1.5,3          SAY REPLICATE([ ],WCOLS()) FONT c_dlgFace, c_dlgSize STYLE c_dlgStyle && CLEAR TO 1.5, WCOLS()
		@ 1.5,3          SAY m.string FONT c_dlgFace, c_dlgSize STYLE c_dlgStyle
	ELSE
		@ 1      ,3       CLEAR TO 1,WCOLS()-1
		@ 1      ,3       SAY m.string
	ENDIF
	ACTIVATE SCREEN
	RETURN
	*: EOF: SAYTHERM.PRG

	*!*****************************************************************
	*!
	*!       Function: STRTRANC
	*!
	*!*****************************************************************
FUNCTION strtranc
	PARAMETERS expc1,expc2,expc3,expn1,expn2
	PRIVATE expr,at_pos,at_pos2,i,j

	IF EMPTY(m.expc1) .OR. EMPTY(m.expc2)
		RETURN m.expc1
	ENDIF
	m.expr=m.expc1
	IF TYPE('m.expn1')#'N'
		m.expn1=1
	ENDIF
	IF TYPE('m.expn2')#'N'
		m.expn2=LEN(m.expc1)
	ENDIF
	IF m.expn1<1 .OR. m.expn2<1
		RETURN m.expc1
	ENDIF
	m.i=0
	m.j=0
	m.at_pos2=1
	DO WHILE .T.
		m.at_pos=ATC(m.expc2,SUBSTR(m.expr,m.at_pos2))
		IF m.at_pos=0
			EXIT
		ENDIF
		m.i=m.i+1
		IF m.i<m.expn1
			m.at_pos2=m.at_pos+m.at_pos2+LEN(m.expc2)-1
			LOOP
		ENDIF
		m.expr=LEFT(m.expr,m.at_pos+m.at_pos2-2)+m.expc3+;
			SUBSTR(m.expr,m.at_pos+m.at_pos2+LEN(m.expc2)-1)
		m.j=m.j+1
		IF m.j>=m.expn2
			EXIT
		ENDIF
		m.at_pos2=m.at_pos+m.at_pos2+LEN(m.expc3)-1
		IF m.at_pos2>LEN(m.expr)
			EXIT
		ENDIF
	ENDDO
	RETURN m.expr

	* END strtranc


	*!*****************************************************************
	*!
	*!      Procedure: NOHOT
	*!
	*!*****************************************************************
PROCEDURE noHot
	** Based on NOHOT from INTL by SMB

	PARAMETERS tcVar
	PRIVATE lcRetVal

	lcRetval = tcVar

	RETURN STRTRAN( STRTRAN( STRTRAN( lcRetVal, "\<"), "\!"), "\?")


	*
	* ADDBS - Add a backslash unless there is one already there.
	*
	*!*****************************************************************
	*!
	*!       Function: ADDBS
	*!
	*!*****************************************************************
FUNCTION addbs
	* Add a backslash to a path name, if there isn't already one there
	PARAMETER m.pathname
	PRIVATE ALL
	m.pathname = ALLTRIM(UPPER(m.pathname))
	IF !(RIGHT(m.pathname,1) $ '\:') AND !EMPTY(m.pathname)
		m.pathname = m.pathname + '\'
	ENDIF
	RETURN m.pathname

	*
	* JUSTFNAME - Return just the filename (i.e., no path) from "filname"
	*
	*!*****************************************************************
	*!
	*!       Function: JUSTFNAME
	*!
	*!*****************************************************************
FUNCTION justfname
	PARAMETERS m.filname
	PRIVATE ALL
	IF RAT('\',m.filname) > 0
		m.filname = SUBSTR(m.filname,RAT('\',m.filname)+1      ,255)
	ENDIF
	IF AT(':',m.filname) > 0
		m.filname = SUBSTR(m.filname,AT(':',m.filname)+1      ,255)
	ENDIF
	RETURN ALLTRIM(UPPER(m.filname))

	*
	* JUSTPATH - Returns just the pathname.
	*
	*!*****************************************************************
	*!
	*!       Function: JUSTPATH
	*!
	*!*****************************************************************
FUNCTION justpath
	* Return just the path name from "filname"
	PARAMETERS m.filname
	PRIVATE ALL
	m.filname = ALLTRIM(UPPER(m.filname))
	IF '\' $ m.filname
		m.filname = SUBSTR(m.filname,1      ,RAT('\',m.filname))
		IF RIGHT(m.filname,1) = '\' AND LEN(m.filname) > 1          ;
				AND SUBSTR(m.filname,LEN(m.filname)-1      ,1) <> ':'
			m.filname = SUBSTR(m.filname,1      ,LEN(m.filname)-1)
		ENDIF
		RETURN m.filname
	ELSE
		RETURN ''
	ENDIF

	*
	* FORCEEXT - Force filename to have a paricular extension.
	*
	*!*****************************************************************
	*!
	*!       Function: FORCEEXT
	*!
	*!*****************************************************************
FUNCTION forceext
	* Force the extension of "filname" to be whatever ext is.
	PARAMETERS m.filname,m.ext
	PRIVATE ALL
	IF SUBSTR(m.ext,1      ,1) = "."
		m.ext = SUBSTR(m.ext,2      ,3)
	ENDIF

	m.pname = justpath(m.filname)
	m.filname = justfname(UPPER(ALLTRIM(m.filname)))
	IF AT('.',m.filname) > 0
		m.filname = SUBSTR(m.filname,1      ,AT('.',m.filname)-1) + '.' + m.ext
	ELSE
		m.filname = m.filname + '.' + m.ext
	ENDIF
	RETURN addbs(m.pname) + m.filname


	************************************************
	*!*****************************************************************
	*!
	*!      Procedure: ADDSETUP
	*!
	*!*****************************************************************
PROCEDURE addSetup
	************************************************

	*  Procedure.........: addSetup
	*  Author............:  Andrew Ross MacNeill
	*% Project...........: GENMENUX
	*  Created...........: 09/14/93
	*) Description.......: Adds clause to setup
	*)
	*  Calling Samples...:
	*  Parameter List....:
	*( Major change list.:


	PARAMETERS tcToAdd

	PRIVATE ALL LIKE j*
	** Assumes that MNX file is open
	jCurrRec=RECNO()
	GO TOP
	LOCATE FOR objCode=22
	REPLACE setup WITH setup+CHR(13)+CHR(13)+tcToAdd
	REPLACE setupType WITH 1
	GO (jCurrRec)


	************************************************
	*!*****************************************************************
	*!
	*!      Procedure: ADDCLEANUP
	*!
	*!*****************************************************************
PROCEDURE addCleanUp
	************************************************

	*  Procedure.........: addCleanUp
	*  Author............:  Andrew Ross MacNeill
	*% Project...........: GENMENUX
	*  Created...........: 09/14/93
	*) Description.......: Adds clause to Clean up
	*)
	*  Calling Samples...:
	*  Parameter List....:
	*( Major change list.:


	PARAMETERS tcToAdd, tcPlace

	IF PARAMETERS()=1
		tcPlace='Bottom'
	ENDIF

	PRIVATE ALL LIKE j*

	** Assumes that MNX file is open
	jCurrRec=IIF(NOT EOF(),RECNO(),RECCOUNT())
	GO TOP
	LOCATE FOR objCode=22
	IF EMPTY(cleanup)
		REPLACE cleanup WITH tcToAdd
	ELSE
		jlDone=.F.
		FOR jni =1    TO MEMLINES(cleanup)
			*{ 04/02/94 ER by Eldor to allow for RETURNS in the menu procedure call.
			IF UPPER(LEFT(MLINE(cleanup,jni ),9))='PROCEDURE' OR ;
					UPPER(LEFT(MLINE(cleanup,jni ),8))='FUNCTION' OR ;
					UPPER(LEFT(MLINE(cleanup,jni),6))="RETURN"
				REPLACE cleanup WITH STRTRANC(cleanup,MLINE(cleanup,jni ),ccReturn+tcToAdd+ccReturn+MLINE(cleanup,jni ))
				jlDone=.T.
				EXIT
			ELSE

			ENDIF
		ENDFOR
		IF NOT jlDone
			IF tcPlace='Bottom'
				REPLACE cleanup WITH cleanUp+CHR(13)+CHR(13)+tcToAdd
			ELSE
				REPLACE cleanup WITH tcToAdd+CHR(13)+CHR(13)+cleanup
			ENDIF
		ENDIF
	ENDIF
	REPLACE cleanType WITH 1
	GO (jCurrRec)

	*!*****************************************************************
	*!
	*!      Procedure: CLEANUP
	*!
	*!*****************************************************************
PROCEDURE cleanup
	PARAMETERS tlMprCheck

	RELEASE WINDOWS gxThermCol
	IF USED( [CODEHLDR] )
		USE IN CODEHLDR
	ENDIF
	
	IF USED('_TEMPFILE')
		USE IN _TEMPFILE
	ENDIF
	IF USED("TEMP")
		USE IN TEMP
	ENDIF
	IF USED('CONFIGFP')
		USE IN CONFIGFP
	ENDIF
	IF USED('PJXBASE')
		USE IN PJXBASE
	ENDIF
	IF USED('PJXDATA')
		USE IN PJXDATA
	ENDIF
	IF USED("TEMPPROJ")
		USE IN TEMPPROJ
	ENDIF
	IF USED([CASECURS])
		USE IN CaseCurs
		ERASE _CASECUR.DBF
		ERASE _CASECUR.FPT
	ENDIF
	IF FILE("_CASECUR.DBF")
		ERASE _CASECUR.DBF
		ERASE _CASECUR.FPT
	ENDIF
	IF TYPE("JCTPROJEXT")='C'
		IF USED(jctProjExt)
			USE IN (jctProjExt)
		ENDIF
		IF FILE(jcTProjExt)
			ERASE (jcTProjExt)
		ENDIF
		jcTProjExt=FORCEEXT(jcTProjExt,"FPT")
		IF FILE(jcTProjExt)
			ERASE (jcTProjExt)
		ENDIF
		jcTProjExt=FORCEEXT(jcTProjExt,"PJT")
		IF FILE(jcTProjExt)
			ERASE (jcTProjExt)
		ENDIF
	ENDIF
	IF TYPE("JCTNAME")='C'
		IF USED(jctName)
			USE IN (jcTName)
		ENDIF

		IF USED("TEMPSCX")
			USE IN tempScx
		ENDIF
		
		IF FILE(jctNameExt)
			ERASE (jctNameExt)
		ENDIF
		jctNameExt=FORCEEXT(jctNameExt,"MNT")
		IF FILE(jctNameExt)
			ERASE (jctNameExt)
		ENDIF
	ENDIF

	DO restoreSet
	
	* END cleanup


	*!*****************************************************************
	*!
	*!      Procedure: FINSOBJ
	*!
	*!*****************************************************************
PROCEDURE fInsObj
	PARAMETER tcobj_name, tcobj_Lib
	*) This function will insert the Submenu as defined in the Menu Template
	*) file defined in the CONFIG.FP file.
	** Find out if you can find tcobj_Lib
	** Strip out the Library name (if any from tcobj_name)
	PRIVATE ALL LIKE j*
	IF OCCURS(".",tcobj_name)>0
		tcobj_Lib=LEFT(tcobj_name,ATC(".",tcobj_name,1))
		tcobj_name=STRTRAN(tcobj_name,tcobj_Lib)
		tcobj_Lib=STRTRAN(tcobj_Lib,".")
	ENDIF
	PRIVATE jnCurrArea
	jnCurrArea=SELECT()
	jnCurrRec=RECNO()
	DO sayTherm WITH "Inserting menu item "+tcobj_Lib+'.'+tcobj_name+" from Menu template..."
	IF NOT llFoxMNX
		RETURN .F.
	ENDIF
	IF NOT FILE(lcFoxMNX)
		RETURN .F.
	ENDIF
	IF USED("FOXMNX")
		SELECT FoxMNX
	ELSE
		SELECT 0
		USE (lcFoxMNX) ALIAS FoxMNX
	ENDIF
	LOCATE FOR objName_=tcobj_name AND objLib_=tcobj_Lib
	IF FOUND()
		SELECT * FROM FoxMNX WHERE objName_=tcobj_name AND objLib_=tcobj_Lib INTO CURSOR jtmp
		jNewBars=_TALLY
		SELECT (jnCurrArea)
		** jnCurrRec=RECNO()
		GO TOP
		jT  =uniqueFlnm()
		COPY NEXT (jnCurrRec) TO (jt  )
		SELECT 0
		USE (jt  ) ALIAS newMenu
		GO BOTT
		jnRec=RECNO()
		jlevelName=levelName
		jitemNum=itemNum
		jPrompt=PROMPT
		jComment=comment
		DELETE
		SELECT jtmp
		SCAN
			SCATTER MEMVAR MEMO
			jDefined=("*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
			** IF NOT wordSearch(jDefined,"comment")=tcobj_Lib+'.'+tcobj_name
			IF jDefined$m.comment
				** Redefine it   TO CALL the  MENU template AGAIN!
				m.comment=STRTRANC(m.comment,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)),ccInsObj)
			ENDIF
			** ENDIF
			INSERT INTO newMenu FROM MEMVAR
		ENDSCAN
		USE
		SELECT newMenu
		GO (jnRec)
		SKIP
		REPLACE LevelName WITH jlevelName
		REPLACE itemNum WITH jItemNum
		jPrompt=PROMPT
		SELECT (jnCurrArea)
		GO (jnCurrRec)
		SKIP
		jT2 =uniqueFlnm()
		COPY REST TO (jt2 )
		SELECT newMenu
		APPEND FROM (jt2 )
		USE DBF() EXCLU
		PACK
		USE (DBF()) ALIAS newMenu
		ERASE (jt2 +'.DBF')
		ERASE (jt2 +'.FPT')
		SELECT newMenu
		USE
		SELECT (jnCurrArea)
		DELETE ALL
		APPEND FROM (jt  )
		USE (DBF()) EXCLUSIVE
		PACK
		USE (DBF())
		ERASE (jt  +'.DBF')
		ERASE (jt  +'.FPT')
		** GATHER MEMVAR MEMO
		GO TOP
		** GO (jnRec)   && Go to the new place
		LOCATE FOR levelName=jLevelName AND itemnum=jItemNum AND PROMPT=jPrompt
		IF EOF()
			SKIP (jNewBars*-1)
		ENDIF
		REPLACE comment WITH comment+jComment
	ELSE
		SELECT (jnCurrArea)
		RETURN .F.
	ENDIF
	SELECT (jnCurrArea)
	RETURN .T.


	*!*****************************************************************
	*!
	*!      Procedure: FDEFOBJ
	*!
	*!*****************************************************************
PROCEDURE fdefObj
	PARAMETER tcobj_name,tcobj_Lib
	*) This function will insert the Bar into the Menu Template
	*) file defined in the CONFIG.FP file.
	** Strip out  the  LIBRARY name (IF any  FROM tcobj_name)
	PRIVATE ALL LIKE j*

	IF OCCURS(".",tcobj_name)>0
		tcobj_Lib=LEFT(tcobj_name,ATC(".",tcobj_name,1))
		tcobj_name=STRTRAN(tcobj_name,tcobj_Lib)
		tcobj_Lib=STRTRAN(tcobj_Lib,".")
	ENDIF
	DO sayTherm WITH "Defining Library Object..."
	PRIVATE jnCurrArea
	jnCurrArea=SELECT()
	jnCurrRec=RECNO()
	** Header record and then any submenus that go along with it
	SCATTER MEMVAR MEMO
	SKIP
	IF objType=2
		jlSub=.T.
		** Entire MENU AS well
		jLevel=levelName
		JcTable=uniqueFlnm()
		jTable=DBF()
		SELECT * FROM (jTable) WHERE levelName=jLevel INTO TABLE (jcTable)
		USE DBF() ALIAS jcTable
	ELSE
		jlSub=.F.
	ENDIF
	IF NOT llFoxMNX
		USE IN jcTable
		ERASE (jcTable+".DBF")
		ERASE (jcTable+".FPT")
		SELECT (jnCurrArea)
		RETURN .F.
	ENDIF
	IF NOT FILE(lcFoxMNX)
		USE IN jcTable
		ERASE (jcTable+".DBF")
		ERASE (jcTable+".FPT")
		RETURN .F.
	ENDIF
	IF USED("FOXMNX")
		SELECT FoxMNX
	ELSE
		SELECT 0
		USE (lcFoxMNX) ALIAS FoxMNX
	ENDIF
	LOCATE FOR objName_=tcobj_name AND objLib_=tcobj_Lib
	IF FOUND()
		IF NOT jlSub
			GATHER MEMVAR MEMO
		ELSE
			DELETE FOR objName_=tcobj_name AND objLib_=tcobj_Lib
			INSERT INTO FOXMNX FROM MEMVAR
			SELECT FoxMNX
			REPLACE objName_ WITH tcobj_name, objLib_ WITH tcobj_Lib, ;
				objMNX_ WITH lcMNX_Name, OBJFLAG_ WITH .T.
			REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
			** REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))

			** Fix from Colin Keeler
			IF AT('.',lcMNX_name)>0
				lcMNX_name=LEFT(lcMNX_Name,AT(',',lcMNX_Name)-1)
			ENDIF

			jnRec=RECNO()
			APPEND FROM (jcTable)
			GO (jnRec)
			DO WHILE NOT EOF()
				REPLACE objName_ WITH tcobj_name, objLib_ WITH tcobj_Lib, ;
					objMNX_ WITH lcMNX_Name, OBJFLAG_ WITH .T.
				REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
				SKIP
			ENDDO
			USE IN jcTable
			ERASE (jcTable+".DBF")
			ERASE (jcTable+".FPT")
		ENDIF
	ELSE
		INSERT INTO FOXMNX FROM MEMVAR
		SELECT FoxMNX
		REPLACE objName_ WITH tcobj_name, objLib_ WITH tcobj_Lib, ;
			objMNX_ WITH lcMNX_Name, OBJFLAG_ WITH .T.
		REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
		IF jlSub
			jnRec=RECNO()
			APPEND FROM (jcTable)
			GO (jnRec)
			DO WHILE NOT EOF()
				REPLACE objName_ WITH tcobj_name, objLib_ WITH tcobj_Lib, ;
					objMNX_ WITH lcMNX_Name, OBJFLAG_ WITH .T.
				REPLACE comment WITH strtranc(comment,ccdefObj,"*-:"+SUBSTR(ccdefObj,3      ,LEN(ccdefObj)))
				SKIP
			ENDDO
			USE IN jcTable
			ERASE (jcTable+".DBF")
			ERASE (jcTable+".FPT")
		ENDIF
		SELECT FoxMNX
		USE (DBF()) EXCLUSIVE
		PACK
		USE (DBF()) ALIAS FoxMnx
		SELECT (jnCurrArea)
		GO (jnCurrRec)
		RETURN .T.
	ENDIF
	SELECT FoxMNX
	USE (DBF()) EXCLUSIVE
	PACK
	USE (DBF()) ALIAS FoxMNX
	SELECT (jnCurrArea)
	GO (jnCurrRec)
	RETURN .T.

	*!*****************************************************************
	*!
	*!      Procedure: FMAKEMNX
	*!
	*!*****************************************************************
PROCEDURE fMakeMNX
	*) Procedure to create Menu Template File
	PARAMETER tcFile
	PRIVATE ALL LIKE j*
	PRIVATE jnCurrArea
	jnCurrArea=SELECT()
	IF FILE(tcFile)
		RETURN .T.
	ENDIF
	DO sayTherm WITH "Creating Menu Template..."
	COPY STRUCTURE EXTENDED TO MNX.TMP
	SELECT 0
	USE MNX.TMP
	** Although we aren't using a lot of these fields, we will keep them in
	** here for future use.
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJNAME_","C",24  )
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJBASE_","C",35  )
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJFIELD_","C",24  )
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJLIB_","C",10  )
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJMNX_","C",8)
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJFLAG_","L",1)
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJCMNT_","M",10  )
	INSERT INTO MNX.TMP (field_name,field_type, field_len) ;
		VALUES ("OBJMEMO_","M",10  )
	CREATE (tcFile) FROM MNX.TMP
	USE (tcFile) ALIAS FoxMNX
	SELECT (jnCurrArea)
	ERASE MNX.TMP

	*!*****************************************************************
	*!
	*!      Procedure: MAKEMENU
	*!
	*!*****************************************************************
PROCEDURE makeMenu
	*) Procedure that completely rewrites menu structure from Record 1
	*) this should be used if you have appended any menu pads from a
	*) different menu that contained submenus, etc.
	PARAMETER tcMnxName
	*) tcMnxName should be open as MNXFile but just in case, we will open it again
	PRIVATE ALL LIKE j*
	IF DBF()=tcMnxName
		jcAlias=ALIAS()
	ELSE
		SELECT 0
		USE (tcMnxName) ALIAS BaseMNX
		jcAlias="BASEMNX"
	ENDIF
	jTemp=uniqueFlnm()
	jTempDbf=jTemp+".DBF"
	jTempFpt=jTemp+".FPT"
	jTempMnx=jTemp+".MNX"
	jTempMnt=jTemp+".MNT"
	GO TOP
	COPY NEXT 1    TO (jTempDbf)
	SELECT 0
	USE (jTempDbf) ALIAS jTemp
	SELECT * FROM baseMnx WHERE levelname='_MSYSMENU' INTO CURSOR tmp
	numPads=_TALLY-1
	SELECT * FROM baseMnx WHERE objType=2    AND levelName='_MSYSMENU' INTO CURSOR t2
	SCATTER MEMVAR MEMO
	INSERT INTO jTemp FROM MEMVAR
	SELECT * FROM (tcMnxName) WHERE objType=2    AND NOT levelName='_MSYSMENU' ORDER BY itemNum INTO CURSOR tmp
	SELECT * FROM (tcMnxName) WHERE objType=3    AND objCode=ccSubMenu ORDER BY itemNum INTO CURSOR tmp2
	SCAN
		** First RECORD has  TO be   HEADER
		jRec=RECNO()
		SCATTER MEMVAR MEMO
		INSERT INTO jTemp FROM MEMVAR
		SELECT tmp
		GO (jRec)
		SCATTER MEMVAR MEMO
		INSERT INTO jTemp FROM MEMVAR
		SELECT * FROM (tcMnxName) WHERE levelName=m.levelName AND NOT objType=2    ORDER BY itemNum INTO CURSOR t1
		SCAN
			SCATTER MEMVAR MEMO
			INSERT INTO jTemp FROM MEMVAR
		ENDSCAN
		SELECT tmp2
	ENDSCAN
	USE IN tmp2
	USE IN tmp
	IF FILE(jTempMNX)
		ERASE (jTempMNX)
	ENDIF
	IF FILE(jTempMNT)
		ERASE (jTempMNT)
	ENDIF
	SELECT (jcAlias)
	ZAP
	SELECT jTemp
	USE
	RENAME (jTempDBF) TO (jTempMNX)
	RENAME (jTempFPT) TO (jTempMNT)
	USE (tcMNXName)
	APPEND FROM (jTempMNX)
	ERASE (jTempMnx)
	ERASE (jTempMNT)
	USE (tcMnxName) ALIAS (jcAlias)

	*]      Reordering Menus
	** Reordering part of GENMENUX
	jcCurrLevel=' '
	jnStart=0
	DO sayTherm WITH "Reordering menu..."
	DO updTherm WITH 50
	jDel=SET("DELETE")
	SET DELETED ON
	** First thing we need to do is identify all of the different levels
	** in the menu
	jnCUrrArea=SELECT()
	SELECT levelName FROM DBF() WHERE NOT EMPTY(numItems)=.T. INTO ARRAY jaLevels

	IF _TALLY>0
	FOR ji      =1          TO ALEN(jaLevels,1)
		jnStart=0
		SCAN FOR levelname=jaLevels(ji   ,1)
			** IF levelName=jcCurrLevel
			IF STR(jnStart,3)=itemNum OR EMPTY(itemNum)
				** Great. RIGHT NUMBER
			ELSE
				REPLACE itemNum WITH STR(jnStart,3)
			ENDIF
			jnStart=jnStart+1
			**      ELSE
			**              ** tHE LEVEL on this item should be 0 so we will continue
			**              jcCurrLevel=levelName
			**              jnStart=1
			**      ENDIF
		ENDSCAN
	ENDFOR
	ENDIF
	USE DBF() EXCLUSIVE
	PACK
	USE DBF()
	SET DELETE &jDel

	****
	*!*****************************************************************
	*!
	*!       Function: FMNUNAME
	*!
	*!*****************************************************************
FUNCTION fMnuName
	PARAMETER tcMnuName
	tcDefault='_MSYSTEM'
	DO CASE
		CASE tcMnuName='SYSTEM'
			RETURN '_MSYSTEM'
		CASE tcMnuName='FILE'
			RETURN '_MFILE'
		CASE tcMnuName='EDIT'
			RETURN '_MEDIT'
		CASE tcMnuName='DATABASE'
			RETURN '_MDATA'
		CASE tcMnuName='RECORD'
			RETURN '_MRECORD'
		CASE tcMnuName='PROGRAM'
			RETURN '_MPROGRAM'
		CASE tcMnuName='WINDOW'
			RETURN '_MWINDOW'
		OTHERWISE
			RETURN tcMnuName
	ENDCASE

	*!*****************************************************************
	*!
	*!       Function: QUALFILE
	*!
	*!*****************************************************************
FUNCTION qualFile
	** BY Steve Sawyer
	PARAMETERS pcHomeDir,pcFileName
	********************************************
	* This procedure is passed the "home" directory from
	* a project file and uses it to determine a fully-
	* qualified filename for any project element.
	* Note that the project "element" for screen files
	* must be the file indicated in the "OUTFILE" field,
	* rather than the file in the NAME field.
	********************************************
	PRIVATE lcFile,lcHomeDir,lcHomDriv
	pcHomeDir=ALLTRIM(pcHomeDir)
	pcFileName=ALLTRIM(pcFileName)
	lcHomeDriv=LEFT(pcHomeDir,2)
	IF RIGHT(pcHomeDir,1) = CHR(0)
		lcHomeDir=SUBSTR(pcHomeDir,1,LEN(pcHomeDir)-1)
	ELSE
		lcHomeDir=pcHomeDir
	ENDIF
	IF RIGHT(lcHomeDir,1) = "\"
		lchomeDir=SUBSTR(lcHomeDir,1,LEN(lcHomeDir)-1)
	ENDIF
	lcFile=pcFileName
	DO CASE
		CASE LEFT(lcFile,1) = "\"
			* No   drive spec
			lcFile=lcHomeDriv + ;
				TRIM(lcFile)
		CASE ! (SUBSTR(lcFile,2,1) = ":" OR ;
				LEFT(lcFile,1) = "\"  OR ;
				LEFT(lcFile,3) = "..\")
			* Below home DIRECTORY
			** Addition BY ARM  TO check FOR EMPTY lcHomeDirs
			IF EMPTY(lcHomeDir)
				** lcHomeDir='..'
			ENDIF
			lcFile=lcHomeDir + "\" + ;
				TRIM(lcFile)
		CASE LEFT(lcFile,3) = "..\"
			* Collateral DIRECTORY
			lcTmpName=lcFile
			lcTmpPath=lcHomeDir
			DO WHILE LEFT(lcTmpName,3) = "..\"
				lcTmpName=SUBSTR(lcTmpName,4)
				lcTmpPath=SUBSTR(lcTmpPath,1,RAT("\",lcTmpPath)-1)
			ENDDO
			IF LEFT(lcTmpName,2) # "\"
				lcTmpName="\" + lcTmpName
			ENDIF
			lcFile=lcTmpPath+lcTmpName
		OTHERWISE
			* DO nothing = fully-qualified filename
	ENDCASE
	IF CHR(0) $ lcFile
		lcFile=STUFF(lcFile,AT(CHR(0),lcFile),1,"")
	ENDIF ( CHR(0) $ lcFile )
	RETURN lcFile


	*!*****************************************************************
	*!
	*!      Procedure: PROJDIR
	*!
	*!*****************************************************************
PROCEDURE ProjDir
	PRIVATE jnCurrArea,jnCurrRec
	jnCurrArea=SELECT()
	SELECT PJXBASE
	jnCurrRec=RECNO()
	GO TOP
	jcHome=JUSTPATH(PJXBASE.NAME)
	GO (jnCurrRec)
	RETURN jcHome

	*!*****************************************************************
	*!
	*!       Function: UNIQUEFLNM
	*!
	*!*****************************************************************
FUNCTION uniqueflnm
	*) From GENSCRNX Ken Levy (JPL)
	PRIVATE m.filename

	DO WHILE .T.
		m.filename='_'+ALLTRIM(SUBSTR(SYS(3),2,7))
		IF NOT FILE(m.filename+'.DBF')
			EXIT
		ENDIF
	ENDDO
	RETURN (m.filename)

	*!*****************************************************************
	*!
	*!       Function: EVLREC (From Ken Levy of JPL)
	*!
	*!*****************************************************************
FUNCTION evlrec
	PRIVATE evlflag,evlloop,i,field_name,field_type,field_eval

	m.evlflag=.F.
	m.evlloop=.T.
	DO WHILE m.evlloop
		m.evlloop=.F.
		FOR m.i = 1 TO FCOUNT()
			m.field_name=FIELD(m.i)
			m.field_type=TYPE(m.field_name)
			IF m.field_type#'M'
				LOOP
			ENDIF
			m.field_eval=EVALUATE(m.field_name)
			IF '{{'$m.field_eval
				REPLACE (m.field_name) WITH evltxt(m.field_eval)
				m.evlflag=.T.
				m.evlloop=.T.
			ENDIF
		ENDFOR
		EXIT
	ENDDO
	RETURN m.evlflag

	* END evlrec


PROCEDURE restoreset

IF TYPE('m.lastselect')=='N'
  SELECT (m.lastselect)
ENDIF
SET MEMOWIDTH TO (m.lastmemow)
_MLINE=0
ACTIVATE SCREEN
@ 0,0 SAY ''
IF EMPTY(m.lastpoint)
  SET POINT TO
ELSE
  SET POINT TO (m.lastpoint)
ENDIF
IF m.lastsetudfp=='VALUE'
  SET UDFPARMS TO VALUE
ELSE
  SET UDFPARMS TO REFERENCE
ENDIF
IF m.lastsetexac=='ON'
  SET EXACT ON
ELSE
  SET EXACT OFF
ENDIF
IF m.lastsetexcl=='ON'
  SET EXCLUSIVE ON
ELSE
  SET EXCLUSIVE OFF
ENDIF
IF EMPTY(m.lastsetpath)
  SET PATH TO
ELSE
  SET PATH TO (m.lastsetpath)
ENDIF
SET DECIMALS TO (m.lastsetdec)
IF m.lastsetnear=='ON'
  SET NEAR ON
ELSE
  SET NEAR OFF
ENDIF
IF m.lastsetcry=='ON'
  SET CARRY ON
ELSE
  SET CARRY OFF
ENDIF
IF m.lastsetdel=='ON'
  SET DELETED ON
ELSE
  SET DELETED OFF
ENDIF
IF m.lastsetsfty=='ON'
  SET SAFETY ON
ELSE
  SET SAFETY OFF
ENDIF
IF m.lastsetcomp=='ON'
  SET COMPATIBLE ON
ELSE
  SET COMPATIBLE OFF
ENDIF
ON ERROR
IF _WINDOWS.OR._MAC
  SET MESSAGE TO
ENDIF
SET CURSOR ON
SET ESCAPE ON
RETURN

* END restoreset

** WARNING Function for GENSCRNX 1.8 (b2)
FUNCTION warning
PARAMETERS cmnd_str,operand

IF TYPE([JWARNINGS])=[U]
	m.jWarnings=0
ENDIF
m.jwarnings=m.jwarnings+1
IF TYPE('m.cmnd_str')#'C'
  RETURN m.jwarnings
ENDIF
IF TYPE('m.operand')=='C'
  m.operand=STRTRAN(m.operand,' ','')
  IF LEFT(m.operand,1)=='.'
    m.operand=SUBSTR(m.operand,2)
  ENDIF
  m.cmnd_str=m.cmnd_str+" '"+m.operand+"' not found"
ENDIF
WAIT CLEAR
IF TYPE('m.autohalt')=='C'.AND.m.autohalt=='OFF'
  WAIT LEFT(m.cmnd_str,254) WINDOW NOWAIT
  RETURN m.jwarnings
ENDIF
 m.cmnd_str='GENMENUX Warning Mode - {C}ancel  {S}uspend  {I}gnore'+CHR(13)+;
          CHR(13)+m.cmnd_str
CLEAR TYPEAHEAD
WAIT LEFT(m.cmnd_str,254) WINDOW
DO CASE
  CASE MDOWN()
    =.F.
  CASE UPPER(CHR(LASTKEY()))=='I'
    RETURN m.jwarnings
  CASE UPPER(CHR(LASTKEY()))=='S'
    m.lasterror=ON('ERROR')
    ON ERROR
    WAIT CLEAR
    CLEAR TYPEAHEAD
    m.lastcursr=SET('CURSOR')
    ACTIVATE WINDOW Command
    SET ESCAPE ON
    SUSPEND
    SET ESCAPE OFF
    SET CURSOR &lastcursr
    ON ERROR &lasterror
    RETURN m.jwarnings
ENDCASE
m.autorun='OFF'
DO cleanup
CANCEL

* END warning

** TRIMPATH function from GENSCRNX 1.8 (b2)
FUNCTION trimpath
PARAMETERS filename,trim_ext,plattype
PRIVATE at_pos

IF EMPTY(m.filename)
  RETURN ''
ENDIF
m.at_pos=AT(':',m.filename)
IF m.at_pos>0
  m.filename=SUBSTR(m.filename,m.at_pos+1)
ENDIF
IF m.trim_ext
  m.filename=trimext(m.filename)
ENDIF
IF m.plattype
  m.filename=IIF(_DOS.OR._UNIX,UPPER(m.filename),LOWER(m.filename))
ENDIF
RETURN ALLTRIM(SUBSTR(m.filename,AT('\',m.filename,;
       MAX(OCCURS('\',m.filename),1))+1))

* END trimpath


**** INSERT Functions from GENSCRNX
*** Modified for GENMENUX
** SCX Specific fields have been removed.

FUNCTION insblank
PARAMETERS skiprec
PRIVATE lastfilter,r

m.lastfilter=FILTER()

IF RECNO()<1
  m.r=RECNO()
  LOCATE FOR OBJTYPE#1.AND..NOT.EMPTY(PLATFORM)
  m.r_scxdata=IIF(EOF(),m.r_scxdata,RECNO())
  IF EOF()
    GOTO m.r
    IF EMPTY(m.lastfilter)
      SET FILTER TO
    ELSE
      SET FILTER TO &lastfilter
    ENDIF
    RETURN .F.
  ENDIF
ENDIF
IF TYPE('m.skiprec')#'N'
  m.skiprec=0
ENDIF
SKIP m.skiprec
IF m.skiprec>0.OR.BOF()
  SKIP -1
ENDIF
SET FILTER TO
INSERT BLANK

m.r=RECNO()

SCAN REST
  IF VPOS<0
    REPLACE HPOS WITH HPOS+1
  ENDIF
  IF HEIGHT<0.OR.HEIGHT>=256
    REPLACE WIDTH WITH WIDTH+1
  ENDIF
ENDSCAN

IF TYPE('PLATFORM')=='C'
  SET FILTER TO PLATFORM==m.platform_
  LOCATE FOR OBJTYPE#1.AND..NOT.EMPTY(PLATFORM)
ELSE
  SET FILTER TO
  LOCATE FOR OBJTYPE#1
ENDIF
m.r_scxdata=IIF(EOF(),m.r_scxdata,RECNO())
GOTO m.r
IF EMPTY(m.lastfilter)
  SET FILTER TO
ELSE
  SET FILTER TO &lastfilter
ENDIF

RETURN .T.

* END insblank



FUNCTION duprec
PARAMETERS skiprec

IF RECNO()<1
  RETURN .F.
ENDIF
IF TYPE('m.skiprec')#'N'
  m.skiprec=0
ENDIF
RELEASE a_fscatter
SCATTER TO a_fscatter MEMO
IF .NOT.insblank(m.skiprec)
  RELEASE a_fscatter
  RETURN .F.
ENDIF
GATHER FROM a_fscatter MEMO
RELEASE a_fscatter
RETURN .T.

* END duprec


PROCEDURE prevLevel
*) Function : prevLevel
*) Returns menu level prior to current one
** Used when creating inteliigent refresh programs
*! For now, just return the level previous - this will have to become smart
*! to allow for submenus, etc
PRIVATE jnCurrRec, jcLevel, jcNewLevel
jnCurrRec=RECNO()
jcLevel=levelName
IF BOF()
	RETURN []
ENDIF
SKIP-1
IF levelName=jcLevel
	SKIP -1
	jcNewLevel=levelName
ELSE
	jcNewLevel=levelName
ENDIF
GO (jnCurrRec)
RETURN jcNewLevel



FUNCTION dfltfld

IF TYPE('NAMECHANGE')=='L'.AND.OBJTYPE=1
  RETURN 'SETUP'
ENDIF
IF TYPE('OUTFILE')=='M'.OR.TYPE('PTXDATA')=='M'
  RETURN 'NAME'
ENDIF
RETURN 'COMMENT'

* END dfltfld



FUNCTION wordstuff
PARAMETERS stuff_str,insflag,insbefore,searchfld,occurance
PRIVATE var_type,memodata,memline,snptname,at_pos,lf_pos,str_len,remove_str
PRIVATE null,cr,lf,cr_lf

m.null=CHR(0)
m.cr=CHR(13)
m.lf=CHR(10)
m.cr_lf=m.cr+m.lf
IF TYPE('m.insflag')=='N'
  m.insflag=(m.insflag=1)
ENDIF
IF PARAMETERS()<=3
  IF TYPE('OBJTYPE')=='N'.AND.TYPE('CENTER')=='L'
    m.searchfld=(OBJTYPE=1)
  ELSE
    m.searchfld=dfltfld()
  ENDIF
ENDIF
m.var_type=TYPE('m.searchfld')
DO CASE
  CASE m.var_type=='L'
    IF m.searchfld
      m.memodata=SETUPCODE
      m.searchfld='SETUPCODE'
    ELSE
      m.memodata=COMMENT
      m.searchfld='COMMENT'
    ENDIF
  CASE m.var_type=='C'
    m.memodata=EVALUATE(m.searchfld)
  OTHERWISE
    RETURN .F.
ENDCASE
m.stuff_str=ALLTRIM(m.stuff_str)
DO WHILE LEFT(m.memodata,1)==m.cr.OR.LEFT(m.memodata,1)==m.lf
  m.memodata=SUBSTR(m.memodata,2)
ENDDO
m.remove_str=m.stuff_str
m.at_pos=AT(' ',m.remove_str)
IF m.at_pos>0
  m.remove_str=ALLTRIM(LEFT(m.remove_str,m.at_pos-1))
ENDIF
m.str_len=0
m.at_pos=wordsearch(m.remove_str,m.searchfld,.F.,@m.str_len,m.occurance)
IF m.at_pos=0.OR.m.str_len=0
  m.at_pos=0
ENDIF
IF m.at_pos>0
  m.memline=SUBSTR(m.memodata,m.at_pos,m.str_len)
  m.lf_pos=AT(m.lf,m.memline)
  IF m.lf_pos>0
    m.str_len=m.lf_pos
  ENDIF
  m.memodata=LEFT(m.memodata,m.at_pos-1)+SUBSTR(m.memodata,m.at_pos+m.str_len)
ENDIF
IF .NOT.m.insflag
  IF m.at_pos=0
    RETURN .F.
  ENDIF
  IF UPPER(LEFT(m.searchfld,2))=='M.'
    &searchfld=m.memodata
  ELSE
    REPLACE (m.searchfld) WITH m.memodata
  ENDIF
  RETURN .T.
ENDIF
DO CASE
  CASE m.at_pos>0
    m.stuff_str=LEFT(m.memodata,m.at_pos-1)+m.stuff_str+m.cr_lf+;
                SUBSTR(m.memodata,m.at_pos)
  CASE m.insbefore
    IF .NOT.EMPTY(m.memodata)
      m.memodata=m.cr_lf+m.memodata
    ENDIF
    m.stuff_str=m.stuff_str+m.memodata
  OTHERWISE
    IF .NOT.EMPTY(m.memodata).AND..NOT.RIGHT(m.memodata,1)==m.cr_lf.AND.;
       .NOT.RIGHT(m.memodata,1)==m.lf
      m.memodata=m.memodata+m.cr_lf
    ENDIF
    DO WHILE RIGHT(m.memodata,1)==m.cr.OR.RIGHT(m.memodata,1)==m.lf
      m.memodata=LEFT(m.memodata,LEN(m.memodata)-1)
    ENDDO
    m.stuff_str=m.memodata+m.cr_lf+m.stuff_str+m.cr
ENDCASE
DO WHILE RIGHT(m.stuff_str,1)==m.cr.OR.RIGHT(m.stuff_str,1)==m.lf
  m.stuff_str=LEFT(m.stuff_str,LEN(m.stuff_str)-1)
ENDDO
m.stuff_str=m.stuff_str+m.cr
IF UPPER(LEFT(m.searchfld,2))=='M.'
  &searchfld=m.stuff_str
ELSE
  REPLACE (m.searchfld) WITH m.stuff_str
ENDIF
RETURN .T.

* END wordstuff



FUNCTION linesearch
PARAMETERS find_str,searchfld

RETURN wordsearch(m.find_str,m.searchfld,.T.)

* END linesearch



FUNCTION wordsearch
PARAMETERS find_str,searchfld,ignoreword,returnmline,occurance
PRIVATE var_type,memodata,memline,memline2,str_data,lastmline
PRIVATE matchcount,linecount,linecount2,at_mline,at_mline2,mline2
PRIVATE null,cr,lf,lf_pos,lf_pos2,at_pos

m.null=CHR(0)
m.cr=CHR(13)
m.lf=CHR(10)
IF PARAMETERS()<=1
  IF TYPE('OBJTYPE')=='N'.AND.TYPE('CENTER')=='L'
    m.searchfld=(OBJTYPE=1)
  ELSE
    m.searchfld=dfltfld()
  ENDIF
ENDIF
IF TYPE('m.returnmline')=='N'
  m.returnmline=.T.
ENDIF
DO CASE
  CASE TYPE('m.occurance')#'N'
    m.occurance=1
  CASE m.occurance<0
    RETURN IIF(m.returnmline,0,m.null)
ENDCASE
m.var_type=TYPE('m.searchfld')
DO CASE
  CASE m.var_type=='L'
    IF m.searchfld
      IF EMPTY(SETUPCODE)
        RETURN IIF(m.returnmline,0,m.null)
      ENDIF
      m.memodata=SETUP
      m.searchfld='SETUP'
    ELSE
      IF EMPTY(COMMENT)
        RETURN IIF(m.returnmline,0,m.null)
      ENDIF
      m.memodata=COMMENT
      m.searchfld='COMMENT'
    ENDIF
  CASE m.var_type=='C'
    m.memodata=EVALUATE(m.searchfld)
    IF EMPTY(m.searchfld)
      RETURN IIF(m.returnmline,0,m.null)
    ENDIF
  OTHERWISE
    RETURN IIF(m.returnmline,0,m.null)
ENDCASE
m.find_str=ALLTRIM(m.find_str)
IF EMPTY(m.find_str).OR.EMPTY(m.memodata).OR.m.memodata==m.null
  RETURN IIF(m.returnmline,0,m.null)
ENDIF
m.memline2=''
m.lastmline=_MLINE
m.at_mline=0
m.at_mline2=0
m.mline2=0
m.lf_pos=0
m.lf_pos2=0
m.matchcount=0
m.linecount=0
m.linecount2=0
m.memodata=m.lf+m.memodata
_MLINE=ATC(m.lf+m.find_str,m.memodata)
IF _MLINE=0
  m.memodata=m.cr+SUBSTR(m.memodata,2)
  _MLINE=ATC(m.cr+m.find_str,m.memodata)
  IF _MLINE=0
    _MLINE=m.lastmline
    RETURN IIF(m.returnmline,0,m.null)
  ENDIF
ENDIF
DO WHILE .T.
  DO CASE
    CASE m.occurance>0.AND._MLINE>=LEN(m.memodata)
      EXIT
    CASE _MLINE>=LEN(m.memodata)
      m.occurance=-1
    OTHERWISE
      m.at_mline=_MLINE
      m.memline=ALLTRIM(MLINE(m.memodata,1,_MLINE))
      m.lf_pos=AT(m.lf,SUBSTR(m.memodata,m.at_mline+1,LEN(m.memline)))
      IF m.lf_pos>0
        m.memline=ALLTRIM(LEFT(m.memline,m.lf_pos-1))
      ENDIF
      m.str_data=SUBSTR(m.memline,LEN(m.find_str)+1,1)
      m.at_pos=ATC(m.find_str,m.memline)
      IF m.at_pos#1.OR.(.NOT.m.ignoreword.AND..NOT.EMPTY(m.str_data))
        m.at_pos=0
        m.memodata=m.lf+SUBSTR(m.memodata,_MLINE)
        _MLINE=ATC(m.lf+m.find_str,m.memodata)
        IF _MLINE>0
          LOOP
        ENDIF
        m.memodata=m.cr+SUBSTR(m.memodata,2)
        _MLINE=ATC(m.cr+m.find_str,m.memodata)
        IF _MLINE>0
          LOOP
        ENDIF
        IF m.occurance>0
          EXIT
        ENDIF
      ENDIF
      m.matchcount=m.matchcount+1
      IF m.matchcount<m.occurance.OR.m.occurance=0
        IF m.at_pos=1.AND.(m.ignoreword.OR.EMPTY(m.str_data))
          m.mline2=_MLINE
          m.at_mline2=m.at_mline
          m.memline2=m.memline
          m.lf_pos2=m.lf_pos
          m.linecount2=m.linecount
        ENDIF
        IF BETWEEN(_MLINE,1,LEN(m.memodata))
          _MLINE=_MLINE-2
          m.linecount=m.linecount+_MLINE
          LOOP
        ENDIF
      ENDIF
  ENDCASE
  IF m.occurance<=0
    IF m.mline2=0
      RETURN IIF(m.returnmline,0,m.null)
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
  m.str_data=SUBSTR(m.memline,LEN(m.find_str)+1)
  IF m.ignoreword.AND..NOT.LEFT(m.str_data,1)==' '
    m.at_pos=AT(' ',m.str_data)
    IF m.at_pos>0
      m.str_data=SUBSTR(m.str_data,m.at_pos+1)
    ENDIF
  ENDIF
  m.str_data=ALLTRIM(m.str_data)
  IF .NOT.m.returnmline
    RETURN m.str_data
  ENDIF
  m.returnmline=m.mline2-m.at_mline+1-IIF(m.lf_pos>0,1,0)
  RETURN m.at_mline+m.linecount
ENDDO
_MLINE=m.lastmline
RETURN IIF(m.returnmline,0,m.null)

* END wordsearch



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

* END trimext


	***********
	** PLANNED ENHANCEMENTS
	** These items have NOT been implemented yet.
	** GENMENU is not as robust (or does not seem to be) as GENSCRN in the
	** sense that fields are used for one purpose only when they could
	** be used EVERYWHERE. A case in point is the SCHEME field to store the
	** color sets for menu items but NO! The SCHEME field is only used
	** when defining System Wide PADS.
	** This will be fixed at a later date but for now, we have to make due
	** with what we have. ARMacNeill
	***********
	*{ 08/25/93 Add support for Individual PADCOLOR (set in the Comments) which
	*{ sets the  colors OF individual pads.
	*{ IN doing this, support FOR *:COLORSET was  removed FROM the  SYSTEM
	*{ AS GENMENU does NOT provide support FOR this natively AND
	*{ the  code is   still being written FOR this functionality AT A later
	*{ date.
	*{ Don't forget about {{ }} support. and evltxt()
	*{ When calling NOBAR and WINDOW, ensure that if the Window does not
	*{ exist that the BAR option is still removed.

	*{ Think about support for an *:ARRAY feature that would make the
	*{ POPUP entirely dynamic. This would CREATE A FUNCTION CALL
	*{ that would LOOP through the  ARRAY AND CREATE the  remainder
	*{ OF the  popup.  This would be   akin TO the  WINWORD Quick List.

	*********
	** Initials Glossary
	*********
	** This is just so I know whose initials I am using
	** SMB - Steven Black (SMB Consulting)
	** KL - Ken Levy (JPL)
	** AN - Andy Neil (MicroMega)
	** SS - Steve Sawyer
	** MS - Martin Schiff


	*************************************
	*** KNOWN PROBLEMS WITH GENMENUX
	*************************************

	*{ 09/08/93 ARMacNeill
	** If you have not SET DEFAULT to the directory where your menu is
	** GENMENUX will crash out.

	*{ 09/28/93 Notes for FoxPro Windows
	** FoxPro for Windows handles Menus slightly differently than DOS in order to conform to the
	** Windows standard.  One of the differences is that the main system menu _MSYSMENU is
	** not allowed to be moved from the top of the desktop.  To overcome this, add the directive
	** *:MENUNAME to your menu and rename it to something other than _MSYSMENU.  This
	** will result in a Menu that will use the default FoxPro for Windows font which is FoxFont
	** Size 10.  If you want to have a more "Windows" like menu,  DEFINE your window using the
	** FONT clause of "MS Sans Serif",10.
	** The following directives will have this problem under FoxPro Windows :
	** *:WINDOW
	** *:LINE
	** And any other directives that affect the positioning of the system menu.
	** Keep in mind that if you use the *:MENUNAME directive, you have to add
	** ACTIVATE MENU <MenuName> to the Cleanup code if you want the menu
	** to be immediately activated.



	** COPYRIGHT NOTICE
	** Compressed file: GENMENUX.ZIP
	** System: GenMenuX
	** Author: Andrew Ross MacNeill
	** Copyright: None (Public Domain)

	** All source code and documentation contained in GENMENUX.ZIP has been placed into the public domain.
	** You may use, modify, copy, distribute, and demonstrate any source code, example programs, or documentation contained in GENMENUX.ZIP freely without copyright protection.
	** ALL FILES contained IN GENMENUX.ZIP are  provided 'as is' without warranty OF any  kind.
	** IN no   event shall its  authors, contributors, OR distributors be   liable FOR any  damages.

	** COMMENTS/SUGGESTIONS/PROBLEMS/QUESTIONS
	** Please use CompuServe's FoxForum (section 3rd Party Products) directed to:
	** Andrew Ross MacNeill 76100,2725

PROCEDURE updCase
llCase=.T.
DO sayTherm WITH "Updating menu for CASE statement..."
jnCurrArea=SELECT()
SELECT 0
CREATE TABLE _casecurs (prologue M(10), menuDef M(10), proc M(10), junk M(10), ;
	junk2 M(10), junk3 M(10))
USE (DBF()) ALIAS caseCurs
APPEND BLANK
REPLACE menuDef WITH tempproj.Object
_MLINE=0
jnProLine=ATC("SET SYSMENU AUTOMATIC",UPPER(menuDef))-1
IF jnProLine=0
	jnProLine=1
ENDIF
** We default the values to the min and max of the memo field
jnClnLine=ATC("Cleanup Code & Procedures",menuDef)-167
IF jnClnLine=-167
	jnClnLine=0
ENDIF
IF jnClnLine=0
	REPLACE menuDef WITH menuDef+CHR(13)+CHR(13)+CHR(13)
	jnClnLine=LEN(ALLTRIM(menuDef))
ENDIF
		
jcPrologue=[]
jcProc=[]
			
_MLINE=0
IF jnProLine>0 AND jnClnLine>0
	DO WHILE _MLINE<jnProLine
		jcPrologue=jcPrologue+MLINE(menuDef,1,_MLINE)+CHR(13)+CHR(10)
	ENDDO
	DO WHILE _MLINE<jnClnLine
		REPLACE junk WITH junk+MLINE(menuDef,1,_MLINE)+CHR(13)+CHR(10)
	ENDDO
	DO WHILE _MLINE<LEN(menuDef)
		jcProc=jcproc+MLINE(menuDef,1,_MLINE)+CHR(13)+CHR(10)
	ENDDO
	REPLACE prologue WITH jcPrologue
	REPLACE menuDef WITH junk
	REPLACE junk WITH []
	REPLACE PROC WITH jcProc
ELSE
	=warning([Problem with standard menu code.])
ENDIF

** Now we need to scan the table again but this time for each CASE statement
** In this case, we will be using the junk field to hold everything until we're ready
REPLACE junk WITH junk+[DO CASE]+CHR(13)
FOR jnCase=1 TO ALEN(ac_case,1)
	=esc_check()
	SELECT CaseCurs
	jcCase=ac_case(jnCase)
	DO sayTherm WITH [Building statement for ]+jcCase+[...]
	REPLACE junk WITH junk+[CASE ]+jcCase+CHR(13)+CHR(10)
	SELECT (jnCurrArea)
	** Try to speed this thing up here by only looking at CASE items
	SCAN FOR ccCase$comment && FOR ccCase+[ ]+jcCase$comment
		IF ccIgnore$Comment
			LOOP
		ENDIF
		IF objType=2
			** Ignore objTypes of 2 because they don't have any code behind them!
			LOOP
		ENDIF
		=esc_check()
		jcJunk2=[]
		jcJunk3=[]
		jcCase2=wordSearch(ccCase,"comment")
		IF NOT jcCase2==jcCase
			LOOP
		ENDIF
		jLevel=UPPER(levelName)
		IF NOT jLevel='_MSYSMENU'
			IF EMPTY(name)
				jBar=ALLTRIM(itemNum)
			ELSE
				jBar=ALLTRIM(name)
			ENDIF
			jSrch="DEFINE BAR "+UPPER(ALLTRIM(jBar))+" OF "+jLevel
		ELSE
			jBar=ALLTRIM(name)
			jSrch="DEFINE PAD "+UPPER(ALLTRIM(name))+" OF _MSYSMENU"
		ENDIF
		_MLINE=0
		SELECT CaseCurs
		jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
		IF jnLine=0
			=WARNING([Could not find ]+jSrch)
		ENDIF
		IF jnLine>0
			jcFullLine=MLINE(menuDef,jnLine)
			** Now let's just make sure we get the whole line
			jcFullLine=retFullLine(menudef,jnLine)
			REPLACE menuDef WITH STRTRAN(menudef,jcFullLine)
			** REPLACE junk3 WITH [], junk2 WITH []
			jcJunk3=[]
			jcJunk2=[]
			REPLACE junk WITH junk+jcFullLine+CHR(13)
		ENDIF
		IF [PAD]$jSrch
			jSrch=[ON PAD ]+jBar+[ OF ]+jLevel
			SELECT CaseCurs
			jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
			IF jnLine=0
				=WARNING([Could not find ]+jSrch)
			ENDIF
			IF jnLine>0
				jcFullLine=MLINE(menuDef,jnLine)
				** Now let's just make sure we get the whole line
				jcFullLine=retFullLine(menudef,jnLine)
				_MLINE=0
				REPLACE menuDef WITH STRTRAN(menuDef,jcFullLine)
				jcjunk3 =[]
				jcjunk2 =[]
				REPLACE junk WITH junk+jcFullLine+CHR(13)
			ENDIF
		ENDIF							

						IF [BAR]$jSrch
							jSrch=[ON SELECTION BAR ]+jBar+[ OF ]+jLevel
							SELECT CaseCurs
							jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
							IF jnLine=0
								=WARNING([Could not find ]+jSrch)
							ENDIF
							IF jnLine>0
								jcFullLine=MLINE(menuDef,jnLine)
								** Now let's just make sure we get the whole line
								jcFullLine=retFullLine(menudef,jnLine)
								_MLINE=0
								REPLACE menuDef WITH STRTRAN(menuDef,jcFullLine)
								jcjunk3 =[]
								jcjunk2 =[]
								REPLACE junk WITH junk+jcFullLine+CHR(13)
							ENDIF
						ENDIF							

						IF [ACTIVATE POPUP]$UPPER(jcFullLine)
							** Identify popup (last item!)
							jPopName=ALLTRIM(SUBSTR(jcFullLine, AT("POPUP",jcFullLine)+6,15))
							jSrch=[DEFINE POPUP ]+jPopName
							SELECT CaseCurs
							jnLine=ATLINE(UPPER(jSrch),UPPER(menuDef))
							IF jnLine=0
								=WARNING([Could not find ]+jSrch)
							ENDIF
							IF jnLine>0
								jcFullLine=MLINE(menuDef,jnLine)
								
								** Now let's just make sure we get the whole line
								jcFullLine=retFullLine(menudef,jnLine)
								REPLACE menuDef WITH STRTRAN(menuDef,jcFullLine)
								jcjunk3 =[]
								jcjunk2 =[]
								REPLACE junk WITH junk+jcFullLine+CHR(13)
							ENDIF
							
							SELECT (jnCurrArea)
						ENDIF
					ENDSCAN
				ENDFOR
				SELECT CaseCurs
				** Now if REFPRG is turned on, create the program
				** with the CASE statement
				REPLACE junk WITH ccCaseHdr+junk+[ENDCASE]+CHR(13) && +menuDef+CHR(13)
				IF llRefPrg
					IF TYPE([LCREFPRG])=[U] OR EMPTY(lcRefPrg)
						=WARNING("Refresh Program was not identified!")
					ELSE
						COPY MEMO Junk TO (lcRefPrg)
					ENDIF
				ENDIF
				REPLACE junk WITH menuDef+CHR(13)+junk+CHR(13)
				REPLACE menuDef WITH prologue+junk+proc
				SELECT tempProj
				REPLACE object WITH CaseCurs.menuDef
				USE IN caseCurs
				ERASE _casecur.dbf
				ERASE _casecur.fpt
				SELECT (jnCurrArea)

PROCEDURE retFullLine
*) Procedure to return full line of memo field based on semi-colons
PARAMETER tcMemo, tnLine

PRIVATE ALL LIKE j*
jcFullLine=MLINE(menuDef,tnLine)
				
IF RIGHT(ALLTRIM(jcFullLine),1)=";"
	jcFullLine=jcFullLine+CHR(13)+CHR(10)+MLINE((tcMemo),tnLine+1)
	IF RIGHT(ALLTRIM(jcFullLine),1)=";"
		jcFullLine=jcFullLine+CHR(13)+CHR(10)+MLINE((tcMemo),tnLine+2)
	ENDIF
ENDIF
RETURN jcFullLine

PROCEDURE drvArray
*) Function to create an array of all the driver statements in the setup or procedure snippet
*) Passed parameter of driver directive
PARAMETERS tcDriver, a_drv
EXTERNAL ARRAY a_drv
PRIVATE ALL LIKE j*
IF tcDriver$setup
	jnNumSetup=OCCURS(tcDriver,Setup)
	IF jnNumSetup>0
		FOR ji=1 TO jnNumSetup
			DIMENSION a_drv(ji)
			a_drv(ji)=wordsearch(tcDriver,[setup],.t.,.f.,ji)
		ENDFOR
	ENDIF
ELSE
	jnNumProc=OCCURS(tcDriver,Procedure)
	jnNewLen=ALEN(a_drv,1)
	IF jnNumProc>0
		FOR ji2=1 TO jnNumProc
			DIMENSION a_drv(jnNewLen+ji2)
			a_drv(jnNewLen+ji2)=wordsearch(tcDriver,[procedure],.t.,.f.,ji2)
		ENDFOR
	ENDIF
ENDIF

PROCEDURE doDrvArr
*) Function to create an array of all the driver statements in the setup or procedure snippet
*) Passed parameter of driver directive
PARAMETERS a_drv
EXTERNAL ARRAY a_drv
PRIVATE jFile, ji
FOR ji=1 TO ALEN(a_drv,1)
	jFile=a_drv(ji,1)
	IF EMPTY(jFile)
		LOOP
	ENDIF
	IF NOT FILE(jFile)
		jFile=FORCEEXT(jFile,"PRG")
	ENDIF
	IF NOT FILE(jFile)
		=WARNING([File ]+jFile+[ does not exist.])
	ELSE
		DO sayTherm WITH lcLastSay+[: ]+jFile+"..."
		DO (jFile)
	ENDIF
ENDFOR

FUNCTION trimdelim
PARAMETERS str_data,i

m.str_data=ALLTRIM(m.str_data)
m.i=LEN(m.str_data)-2
IF LEFT(m.str_data,1)=='"'.AND.RIGHT(m.str_data,1)=='"'
  RETURN SUBSTR(m.str_data,2,m.i)
ENDIF
IF LEFT(m.str_data,1)=="'".AND.RIGHT(m.str_data,1)=="'"
  RETURN SUBSTR(m.str_data,2,m.i)
ENDIF
IF LEFT(m.str_data,1)=='['.AND.RIGHT(m.str_data,1)==']'
  RETURN SUBSTR(m.str_data,2,m.i)
ENDIF
RETURN m.str_data

* END trimdelim

PROCEDURE storeCode
*) procedure to store Specified code in a
*) cursor called CODEHLDR while working on it

PARAMETER tcProc, tcType, tcCode

PRIVATE jnCurrArea
jnCurrArea=SELECT()

IF NOT USED("CODEHLDR")
	SELECT 0
	CREATE CURSOR CODEHLDR (procName C(10), type C(10), code M)
ENDIF

SELECT codeHldr

LOCATE FOR UPPER( procName) = UPPER( tcProc)
IF NOT FOUND()
	APPEND BLANK
	REPLACE procName WITH tcProc, type WITH tcType
ENDIF
REPLACE code WITH code + tcCode

SELECT (jnCurrArea)


PROCEDURE updCode
*) procedure to replace specific memo field with code
*) from the CODEHLDR cursor

PARAMETER tcProc, tcLocation

IF NOT USED( [CODEHLDR] )
	RETURN
ENDIF
PRIVATE jnCurrArea, jcRetProc, jnRec
jnCurrArea=SELECT()

SELECT codeHldr
LOCATE FOR UPPER( procName) = UPPER( tcProc)
IF FOUND()
	jcRetProc= code
	DELETE
ELSE
	jcRetProc= []
ENDIF

SELECT (jnCurrArea)

DO CASE
	CASE tcLocation = [MENU SETUP]
		
		jnRec=RECNO()
		GO TOP
		REPLACE setup WITH setup+ ccReturn+ jcRetProc
		GO (jnRec)
		
	CASE tcLocation = [MENU CLEANUP]
		
		jnRec=RECNO()
		GO TOP
		REPLACE cleanup WITH cleanup+ ccReturn+ [PROCEDURE ]+tcProc+ccReturn+jcRetProc
		GO (jnRec)
		
	CASE tcLocation = [MENU PROCEDURE]
		
		jnRec=RECNO()
		GO TOP
		REPLACE Procedure WITH procedure + ccReturn+ jcRetProc
		GO (jnRec)
	
	CASE tcLocation = [PROCEDURE]

		REPLACE procedure WITH procedure + ccReturn + jcRetProc	
		
ENDCASE

SELECT (jnCurrArea)


*
* STRIPEXT - Strip the extension from a file name.
*
* Description:
* Use the algorithm employed by FoxPRO itself to strip a
* file of an extension (if any): Find the rightmost dot in
* the filename.  If this dot occurs to the right of a "\"
* or ":", then treat everything from the dot rightward
* as an extension.  Of course, if we found no dot,
* we just hand back the filename unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any extension removed
*
FUNCTION stripext
PARAMETER m.filename
PRIVATE m.dotpos, m.terminator
m.dotpos = RAT(".", m.filename)
m.terminator = MAX(RAT("\", m.filename), RAT(":", m.filename))
IF m.dotpos > m.terminator
   m.filename = LEFT(m.filename, m.dotpos-1)
ENDIF
RETURN m.filename



*
* STRIPPATH - Strip the path from a file name.
*
* Description:
* Find positions of backslash in the name of the file.  If there is one
* take everything to the right of its position and make it the new file
* name.  If there is no slash look for colon.  Again if found, take
* everything to the right of it as the new name.  If neither slash
* nor colon are found then return the name unchanged.
*
* Parameters:
* filename - character string representing a file name
*
* Return value:
* The string "filename" with any path removed
*
FUNCTION strippath
PARAMETER m.filename
PRIVATE m.slashpos, m.namelen, m.colonpos
m.slashpos = RAT("\", m.filename)
IF m.slashpos > 0
   m.namelen  = LEN(m.filename) - m.slashpos
   m.filename = RIGHT(m.filename, m.namelen)
ELSE
   m.colonpos = RAT(":", m.filename)
   IF m.colonpos > 0
      m.namelen  = LEN(m.filename) - m.colonpos
      m.filename = RIGHT(m.filename, m.namelen)
   ENDIF
ENDIF
RETURN m.filename


*
* BASENAME - returns strippath(stripext(filespec))
*
FUNCTION basename
PARAMETER m.filespec
RETURN strippath(stripext(m.filespec))


PROCEDURE xplatKeys

** Routine to identify cross platform key labels
** Thanks to >L< for the suggestions
** Returns a fairly large text string with returns in it
** that identify what a menu prompt should have for keys

PRIVATE ALL LIKE j*

jcWinKey = wordSearch ( ccWinKey )
jcWinKey = IIF( jcWinKey = ccNull, [], jcWinKey )
jcMacKey = wordSearch ( ccMacKey )
jcMacKey = IIF( jcMacKey = ccNull, [], jcMacKey )
jcDOSKey = wordSearch ( ccDOSKey )
jcDOSKey = IIF( jcDOSKey = ccNull, [], jcDOSKey )
jcUnixKey = wordSearch ( ccUnixKey )
jcUnixKey = IIF( jcUnixKey = ccNull, [], jcUnixKey )


jcRetVal= ccReturn + "DO CASE " + ccReturn + ;
	ccTab + "CASE _WINDOWS " + ccReturn + ;
	ccTab + ccTab + "_keyPrompt = ["+jcWinKey + " ] "+ ccReturn + ;
	ccTab + "CASE _MAC " + ccReturn + ;
	ccTab + ccTab + "_keyPrompt = ["+jcMacKey +  " ] "+ ccReturn + ;
	ccTab + "CASE _UNIX " + ccReturn + ;
	ccTab + ccTab + "_keyPrompt = ["+jcUnixKey +  " ] "+ ccReturn + ;
	ccTab + "CASE _DOS " + ccReturn + ;
	ccTab + ccTab + "_keyPrompt = ["+jcDosKey +  " ] "+ ccReturn + ;
	"ENDCASE "


RETURN jcRetVal




PROCEDURE groupCode

** Returns code from within a snippet based on a start and ending point

PARAMETERS tcSnippet, tcStart, tcEnd
PRIVATE jcNewText, old_text, m.at_pos
m.new_text=[]
m.old_text= comment

DO WHILE .T.

	m.at_pos=ATC(tcStart, m.old_text)
	IF m.at_pos=0
		EXIT
	ENDIF
	m.old_text=SUBSTR(m.old_text,m.at_pos+2)
	m.at_pos=ATC( tcEnd ,m.old_text)
	IF m.at_pos=0
		m.new_text=m.new_text+m.cr_lf+m.old_text+m.cr_lf
		EXIT
	ENDIF
	m.new_text=m.new_text+ ccNewLine+ LEFT(m.old_text,m.at_pos-1)+ ccNewLine
	m.old_text=SUBSTR(m.old_text,m.at_pos+2)
	=esc_check()
ENDDO

RETURN m.new_Text

**********************************************************************
* Program....: i.prg
* Author.....: Steven Black
* Project....: INTL for Visual FoxPro
* Repository.: https://github.com/StevenBlack/intl/
* Purpose....: Helper function to broker localization calls.
**********************************************************************
LPARAMETERS txFirst, txSecond
IF TYPE( "_SCREEN.oINTL" ) = "O"
    RETURN _SCREEN.oINTL.I( txFirst, txSecond )
ELSE
    RETURN txFirst
ENDIF

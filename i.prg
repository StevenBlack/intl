**********************************************************************
* Program....: i.prg
* Version....:
* Author.....: Steven Black
* Purpose....: Helper function to broker localization calls.
**********************************************************************
LPARAMETERS txFirst, txSecond
IF TYPE( "_SCREEN.oINTL" ) = "O"
    RETURN _SCREEN.oINTL.I( txFirst, txSecond )
ELSE
    RETURN txFirst
ENDIF

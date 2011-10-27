PARAMETERS txFirst, txSecond
IF TYPE("_SCREEN.oINTL")="O"
 RETURN _SCREEN.oINTL.I(txFirst, txSecond)
ELSE
 RETURN txFirst
ENDIF

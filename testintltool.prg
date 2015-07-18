SET PROCEDURE TO INTL ADDITIVE
SET PROCEDURE TO INTLTOOL ADDITIVE
IF TYPE("_SCREEN.oINTL")="O"
  _SCREEN.oINTL.Release()
ENDIF
_SCREEN.AddObject("oINTL", "INTL")
oVisitor= create("cIntlUpdateVisitor")
oVisitor.VisitCodeMemo( FILETOSTR("TestIntlTool.TXT"))
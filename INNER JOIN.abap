*Inner Join*

REPORT  Z_TESTEINNERJOIN.

TABLES ZABELA_TESTE5.

TYPES: BEGIN OF TY_MATER,
  MATER LIKE ZABELA_TESTE5-MATER,
  DENOM LIKE ZABELA_TESTE5-DENOM,
  BRGEW LIKE ZABELA_TESTE5-BRGEW,
  NTGEW LIKE ZABELA_TESTE5-NTGEW,
  GEWEI LIKE ZABELA_TESTE5-GEWEI,
  STATUS LIKE ZABELA_TESTE5-STATUS,
  TPMAT LIKE ZABELA_TESTE-TPMAT,
  DENOM1 LIKE ZABELA_TESTE-DENOM,
  END OF TY_MATER.

  DATA T_MATER TYPE TABLE OF TY_MATER.

DATA W_MATER TYPE TY_MATER.

*TELA DE SELEÇÃO
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_TPMAT FOR ZABELA_TESTE5-TPMAT,
                  S_MATER FOR ZABELA_TESTE5-MATER.

  SELECTION-SCREEN END OF BLOCK B01.

  START-OF-SELECTION.

  PERFORM F_SELECIONA_DADOS.

  PERFORM F_IMPRIME_DADOS.
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECIONA_DADOS .


SELECT ZABELA_TESTE5~MATER ZABELA_TESTE5~DENOM ZABELA_TESTE5~BRGEW ZABELA_TESTE5~NTGEW
  ZABELA_TESTE5~GEWEI ZABELA_TESTE5~STATUS ZABELA_TESTE~TPMAT ZABELA_TESTE~DENOM
  FROM ZABELA_TESTE5
  INNER JOIN ZABELA_TESTE
  ON ZABELA_TESTE5~TPMAT = ZABELA_TESTE~TPMAT
  INTO TABLE T_MATER
  WHERE ZABELA_TESTE5~TPMAT IN S_TPMAT
  AND ZABELA_TESTE5~MATER IN S_MATER.

  IF SY-SUBRC <> 0.
    MESSAGE TEXT-002 TYPE 'I'.
    STOP.
    ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_IMPRIME_DADOS .

LOOP AT T_MATER INTO W_MATER.

  WRITE:/ W_MATER-MATER, W_MATER-DENOM, W_MATER-BRGEW, W_MATER-NTGEW,
          W_MATER-GEWEI, W_MATER-STATUS, W_MATER-TPMAT, W_MATER-DENOM1.

  ENDLOOP.


ENDFORM.                    " F_IMPRIME_DADOS

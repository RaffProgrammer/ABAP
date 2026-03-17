*Salvar de uma tabela em um repositório SAP*


TABLES: J_1BNFDOC.

TYPES: BEGIN OF ty_J_1BNFDOC,
  DOCNUM LIKE J_1BNFDOC-DOCNUM,
  DOCTYP LIKE J_1BNFDOC-DOCTYP,
  NFNUM  LIKE J_1BNFDOC-NFNUM,
  DOCDAT LIKE J_1BNFDOC-DOCDAT,
  CRENAM LIKE J_1BNFDOC-CRENAM,
  ZTERM  LIKE J_1BNFDOC-ZTERM,
  END OF TY_J_1BNFDOC.

DATA: T_J_1BNFDOC TYPE TABLE OF TY_J_1BNFDOC,
      T_TEXT      TYPE TABLE OF STRING,
      VL_FILENAME TYPE STRING.

DATA: W_J_1BNFDOC TYPE TY_J_1BNFDOC,
      W_TEXT      TYPE STRING.

PARAMETERS: P_FILE TYPE STRING.

SELECT-OPTIONS: s_docnum FOR J_1BNFDOC-DOCNUM.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_file.
PERFORM F_ARQUIVO.

START-OF-SELECTION.

PERFORM F_SELECIONA_DADOS.
PERFORM F_DOWNLOAD.
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECIONA_DADOS .

SELECT DOCNUM
       DOCTYP
       NFNUM
       DOCDAT
       CRENAM
       ZTERM
 FROM J_1BNFDOC
 INTO TABLE T_J_1BNFDOC
  WHERE DOCNUM IN S_DOCNUM.

  LOOP AT T_J_1BNFDOC INTO W_J_1BNFDOC.

CONCATENATE W_J_1BNFDOC-DOCNUM
            W_J_1BNFDOC-DOCTYP
            W_J_1BNFDOC-NFNUM
            W_J_1BNFDOC-DOCDAT
            W_J_1BNFDOC-CRENAM
            W_J_1BNFDOC-ZTERM INTO W_TEXT SEPARATED BY ';'.

APPEND W_TEXT TO T_TEXT.
CLEAR W_TEXT.

  ENDLOOP.

  CONCATENATE P_FILE '\NF_' J_1BNFDOC-NFNUM '_' SY-DATUM '_' SY-UZEIT INTO VL_FILENAME.

ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DOWNLOAD .

  OPEN DATASET VL_FILENAME FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  LOOP AT T_TEXT INTO W_TEXT.
    TRANSFER W_TEXT TO VL_FILENAME.
  ENDLOOP.

  CLOSE DATASET VL_FILENAME.

ENDFORM.                    " F_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  F_ARQUIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ARQUIVO .

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    CHANGING
      SELECTED_FOLDER      = P_FILE
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.

ENDFORM.                    " F_ARQUIVO

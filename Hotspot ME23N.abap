*ALV com Hotspot na ME23N*


TYPE-POOLS SLIS.

TYPES: BEGIN OF TY_EKKOP,
  EBELN  TYPE EKKO-EBELN,
  BSART  TYPE EKKO-BSART,
  EKGRP  TYPE EKKO-EKGRP,
  BEDAT  TYPE EKKO-BEDAT,
  LIFNR  TYPE EKKO-LIFNR,
  NETWR  TYPE EKPO-NETWR,
END OF TY_EKKOP.

*TABELAS TRANSPARENTES

TABLES: EKKO,
        EKPO.



*TABELAS INTERNAS

DATA: T_EKKO          TYPE TABLE OF EKKO,
      T_EKPO          TYPE TABLE OF EKPO,
      T_SAIDA         TYPE TABLE OF ZESTRUTURAEKKO,
      T_FIELDCAT      TYPE SLIS_T_FIELDCAT_ALV,
      T_SORT          TYPE SLIS_T_SORTINFO_ALV,
      T_EKKOP         TYPE TABLE OF TY_EKKOP,
      T_total         TYPE NETWR.



*WORK AREAS

DATA: W_SAIDA         TYPE ZESTRUTURAEKKO,
      W_SELVAR        TYPE SELVAR,
      W_FIELDCAT      TYPE SLIS_FIELDCAT_ALV,
      W_SORT          TYPE SLIS_SORTINFO_ALV,
      W_LAYOUT        TYPE SLIS_LAYOUT_ALV,
      W_EKKOP         TYPE TY_EKKOP.

SELECTION-SCREEN BEGIN OF BLOCK BC01 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: S_EBELN FOR EKKO-EBELN OBLIGATORY.

SELECTION-SCREEN END OF BLOCK BC01.

START-OF-SELECTION.

  PERFORM SELECIONA_DADOS.

  PERFORM F_SOMA.

  PERFORM MONTA_TABELA_SAIDA.

  PERFORM F_MONTA_ALV.
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECIONA_DADOS .

  SELECT
    EKKO~EBELN
    EKKO~BSART
    EKKO~EKGRP
    EKKO~BEDAT
    EKKO~LIFNR
    EKPO~NETWR
    INTO TABLE T_EKKOP
    FROM EKKO
    INNER JOIN EKPO ON EKPO~EBELN = EKKO~EBELN
        WHERE EKKO~EBELN IN S_EBELN[].

  IF SY-SUBRC IS INITIAL.

  ELSE.
    MESSAGE TEXT-003 TYPE 'I'."NÃO FOI ENCONTRADO NENHUM REGISTRO COM TAIS PARÂMETROS
    STOP.

  ENDIF.



ENDFORM.                    " SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  MONTA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MONTA_TABELA_SAIDA .

  DATA: lv_EBELN TYPE EBELN.

  SORT: T_EKKOP BY EBELN.

  LOOP AT T_EKKOP INTO W_EKKOP.

    CLEAR W_SAIDA.
    W_SAIDA-EBELN = W_EKKOP-EBELN.
    W_SAIDA-BSART = W_EKKOP-BSART.
    W_SAIDA-EKGRP = W_EKKOP-EKGRP.
    W_SAIDA-BEDAT = W_EKKOP-BEDAT.
    W_SAIDA-LIFNR = W_EKKOP-LIFNR.
    W_SAIDA-NETWR = W_EKKOP-NETWR.

    lv_EBELN = W_EKKOP-EBELN.

    APPEND W_SAIDA TO T_SAIDA.

  ENDLOOP.


ENDFORM.                    " MONTA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_MONTA_ALV .

  PERFORM F_DEFINE_FIELDCAT.
  PERFORM F_ORDENA.
  PERFORM F_LAYOUT.
  PERFORM F_IMPRIME_ALV.

ENDFORM.                    " F_MONTA_ALV
*&---------------------------------------------------------------------*
*&      Form  F_DEFINE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DEFINE_FIELDCAT .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
     I_PROGRAM_NAME               = SY-REPID
     I_INTERNAL_TABNAME           = 'T_SAIDA'
     I_STRUCTURE_NAME             = 'ZESTRUTURAEKKO'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
   CHANGING
     CT_FIELDCAT                  = T_FIELDCAT
  EXCEPTIONS
    INCONSISTENT_INTERFACE       = 1
    PROGRAM_ERROR                = 2
    OTHERS                       = 3
           .
  IF SY-SUBRC <> 0.
    MESSAGE TEXT-004 TYPE 'I'."Erro na Definição da FIELDCAT
    STOP.

  ELSE.

    LOOP AT T_FIELDCAT INTO W_FIELDCAT.
      CASE W_FIELDCAT-FIELDNAME.
        WHEN 'EBELN'.
          W_FIELDCAT-HOTSPOT = 'X'.

      ENDCASE.

      MODIFY T_FIELDCAT FROM W_FIELDCAT INDEX SY-TABIX TRANSPORTING SELTEXT_S SELTEXT_M SELTEXT_L REPTEXT_DDIC HOTSPOT.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_DEFINE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_ORDENA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ORDENA .

  CLEAR W_SORT.
  W_SORT-SPOS = 1.
  W_SORT-FIELDNAME = 'EBELN'.
  W_SORT-TABNAME = 'T_SAIDA'.
  W_SORT-UP = 'X'.
  APPEND W_SORT TO T_SORT.

ENDFORM.                    " F_ORDENA
*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .

  W_LAYOUT-ZEBRA = 'X'.
  W_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

ENDFORM.                    " F_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_IMPRIME_ALV .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
*    I_INTERFACE_CHECK                 = ' '
*    I_BYPASSING_BUFFER                = ' '
*    I_BUFFER_ACTIVE                   = ' '
    I_CALLBACK_PROGRAM                = SY-REPID
*    I_CALLBACK_PF_STATUS_SET          = ' '
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*    I_CALLBACK_TOP_OF_PAGE            = ' '
*    I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*    I_CALLBACK_HTML_END_OF_LIST       = ' '
*    I_STRUCTURE_NAME                  =
*    I_BACKGROUND_ID                   = ' '
*    I_GRID_TITLE                      =
*    I_GRID_SETTINGS                   =
    IS_LAYOUT                         = W_LAYOUT
    IT_FIELDCAT                       = T_FIELDCAT
*    IT_EXCLUDING                      =
*    IT_SPECIAL_GROUPS                 =
    IT_SORT                           = T_SORT
*    IT_FILTER                         =
*    IS_SEL_HIDE                       =
*    I_DEFAULT                         = 'X'
   I_SAVE                            = 'X'
*   IS_VARIANT                        =
*    IT_EVENTS                         =
*    IT_EVENT_EXIT                     =
*    IS_PRINT                          =
*    IS_REPREP_ID                      =
*    I_SCREEN_START_COLUMN             = 0
*    I_SCREEN_START_LINE               = 0
*    I_SCREEN_END_COLUMN               = 0
*    I_SCREEN_END_LINE                 = 0
*    I_HTML_HEIGHT_TOP                 = 0
*    I_HTML_HEIGHT_END                 = 0
*    IT_ALV_GRAPHICS                   =
*    IT_HYPERLINK                      =
*    IT_ADD_FIELDCAT                   =
*    IT_EXCEPT_QINFO                   =
*    IR_SALV_FULLSCREEN_ADAPTER        =
*  IMPORTING
*    E_EXIT_CAUSED_BY_CALLER           =
*    ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = T_SAIDA
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2.

ENDFORM.                    " F_IMPRIME_ALV

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: lv_ebeln TYPE ebeln.

  CASE r_ucomm.
    WHEN '&IC1'.
      READ TABLE t_saida INTO W_saida INDEX rs_selfield-tabindex.
      IF sy-subrc = 0.
        lv_ebeln = W_saida-ebeln.
        SET PARAMETER ID 'BES' FIELD lv_ebeln.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  F_SOMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SOMA .

*  LOOP AT t_ekkoP INTO W_ekkoP.
*    T_total = 0.
*
*    READ TABLE t_ekkoP INTO W_ekkoP WITH KEY ebeln = W_ekkoP-ebeln BINARY SEARCH.
*
*    WHILE sy-subrc = 0.
*      T_total = T_total + W_ekKOP-netwr.
*
*      READ TABLE t_ekkoP INTO W_ekkoP WITH KEY ebeln = W_ekkoP-ebeln BINARY SEARCH TRANSPORTING NO FIELDS.
*    ENDWHILE.
*
*    READ TABLE t_saida INTO W_SAIDA WITH KEY ebeln = W_ekkoP-ebeln.
*    IF sy-subrc = 0.
*      W_saida-netwr = T_total.
*      MODIFY t_saida FROM W_saida TRANSPORTING netwr.
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.                    " F_SOMA

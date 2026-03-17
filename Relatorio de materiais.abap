*RELATORIO DE MATERIAIS USANDO A TABELA MARA*

REPORT  ZRMC_RELATORIO_MATERIAIS.


TYPE-POOLS SLIS.


*Tabelas Transparentes
TABLES: MARA.


*Tabelas Internas
DATA: T_MARA     TYPE TABLE OF MARA,
      T_SAIDA    TYPE TABLE OF ZSRMC_ESTRUTUA_MATERIAIS,
      T_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      T_SORT     TYPE SLIS_T_SORTINFO_ALV.


*Work Area
DATA: W_MARA     TYPE MARA,
      W_SAIDA    TYPE ZSRMC_ESTRUTUA_MATERIAIS,
      W_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      W_SORT     TYPE SLIS_SORTINFO_ALV,
      W_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      W_VARIANT  TYPE DISVARIANT.


*Tela de Seleção
SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_MATNR FOR MARA-MATNR,
                S_MATKL FOR MARA-MATKL.
SELECTION-SCREEN END OF BLOCK A1.



START-OF-SELECTION.

  PERFORM VALIDA_CAMPOS.

  PERFORM SELECIONA_DADOS.

  PERFORM F_MONTA_TAB_SAIDA.

  PERFORM F_MONTA_ALV.



*&---------------------------------------------------------------------*
*&      Form  VALIDA_CAMPOS
*&---------------------------------------------------------------------*
FORM VALIDA_CAMPOS .

  IF S_MATNR AND S_MATKL IS INITIAL.
    MESSAGE TEXT-002 TYPE 'I'.    "Por favor, preencha pelo menos um critério de seleção
    STOP.
  ENDIF.

ENDFORM.                    " VALIDA_CAMPOS


*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM SELECIONA_DADOS .

  SELECT *
     FROM MARA
     INTO TABLE T_MARA
     WHERE MATNR IN S_MATNR
       OR MATKL IN S_MATKL
       AND LVORM = ' '.


  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE TEXT-003 TYPE 'I'.    "Material não encontrado
    STOP.
  ENDIF.

ENDFORM.                    " SELECIONA_DADOS


*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TAB_SAIDA
*&---------------------------------------------------------------------*
FORM F_MONTA_TAB_SAIDA .

  LOOP AT T_MARA INTO W_MARA.

    CLEAR W_SAIDA.
    IF SY-SUBRC IS INITIAL.

      IF W_MARA-MATNR IS INITIAL.
        W_SAIDA-MATNR = '-'.
      ELSE.
        W_SAIDA-MATNR = W_MARA-MATNR.
      ENDIF.

      IF W_MARA-ERSDA IS INITIAL.
        W_SAIDA-ERSDA = '-'.
      ELSE.
        W_SAIDA-ERSDA = W_MARA-ERSDA.
      ENDIF.

      IF W_MARA-MATKL IS INITIAL.
        W_SAIDA-MATKL = '-'.
      ELSE.
        W_SAIDA-MATKL = W_MARA-MATKL.
      ENDIF.

      IF W_MARA-MEINS IS INITIAL.
        W_SAIDA-MEINS = '-'.
      ELSE.
        W_SAIDA-MEINS = W_MARA-MEINS.
      ENDIF.

      IF W_MARA-EAN11 IS INITIAL.
        W_SAIDA-EAN11 = '-'.
      ELSE.
        W_SAIDA-EAN11 = W_MARA-EAN11.
      ENDIF.

      IF W_MARA-FERTH IS INITIAL.
        W_SAIDA-FERTH = '-'.
      ELSE.
        W_SAIDA-FERTH = W_MARA-FERTH.
      ENDIF.


    ENDIF.


    APPEND W_SAIDA TO T_SAIDA.


  ENDLOOP.

ENDFORM.                    " F_MONTA_TAB_SAIDA


*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
FORM F_MONTA_ALV .

  PERFORM F_DEFINE_FIELDCAT.

  PERFORM F_ORDENA.

  PERFORM F_LAYOUT.

  PERFORM F_IMPRIME_ALV.

ENDFORM.                    " F_MONTA_ALV


*&---------------------------------------------------------------------*
*&      Form  F_DEFINE_FIELDCAT
*&---------------------------------------------------------------------*
FORM F_DEFINE_FIELDCAT .


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
   EXPORTING
     I_PROGRAM_NAME               = SY-REPID
     I_INTERNAL_TABNAME           = 'T_SAIDA'
     I_STRUCTURE_NAME             = 'ZSRMC_ESTRUTUA_MATERIAIS'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
    CHANGING
      CT_FIELDCAT                  = T_FIELDCAT
   EXCEPTIONS
     INCONSISTENT_INTERFACE       = 1
     PROGRAM_ERROR                = 2
     OTHERS                       = 3.

  IF SY-SUBRC <> 0.
    MESSAGE TEXT-004 TYPE 'I'.    "Erro na definição da fieldcat
    STOP.
  ENDIF.

ENDFORM.                    " F_DEFINE_FIELDCAT


*&---------------------------------------------------------------------*
*&      Form  F_ORDENA
*&---------------------------------------------------------------------*
FORM F_ORDENA .

  CLEAR W_SORT.
  W_SORT-SPOS = 1.
  W_SORT-FIELDNAME = 'MATNR'.
  W_SORT-TABNAME = 'T_SAIDA'.
  W_SORT-UP = 'X'.
  APPEND W_SORT TO T_SORT.

ENDFORM.                    " F_ORDENA


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
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
FORM F_IMPRIME_ALV .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = SY-REPID
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
     IS_LAYOUT                         = W_LAYOUT
     IT_FIELDCAT                       = T_FIELDCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
     IT_SORT                           = T_SORT
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
     I_SAVE                            = 'X'
   IS_VARIANT                        = W_VARIANT
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          = T_SAIDA
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2.

ENDFORM.                    " F_IMPRIME_ALV

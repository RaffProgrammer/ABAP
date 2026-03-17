*Validação de dados se o estoque minimo maior que disponivel linha vermelho*

REPORT  ZMM_RELAT_MATERIAIS_JS.

TYPE-POOLS SLIS.

*TABELAS TRANSPARENTES
TABLES: MARD,
        RESB.


*TABELAS INTERNAS
DATA: T_MARD     TYPE TABLE OF MARD,
      T_RESB     TYPE TABLE OF RESB,
      T_SAIDA    TYPE TABLE OF ZSMM01,
      T_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      T_SORT     TYPE SLIS_T_SORTINFO_ALV.


*WORK AREA
DATA: W_MARD     TYPE MARD,
      W_RESB     TYPE RESB,
      W_SAIDA    TYPE ZSMM01,
      W_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      W_SORT     TYPE SLIS_SORTINFO_ALV,
      W_LAYOUT   TYPE SLIS_LAYOUT_ALV,
      W_VARIANT  TYPE DISVARIANT.


*TELA DE SELEÇÃO
SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_MATNR FOR MARD-MATNR OBLIGATORY,
                S_WERKS FOR MARD-WERKS.
PARAMETERS:     P_ESTOQ TYPE RESB-BDMNG OBLIGATORY.
SELECTION-SCREEN END OF BLOCK A1.


START-OF-SELECTION.
  PERFORM F_SELECIONA_DADOS.

  PERFORM F_MONTA_TAB_SAIDA.

  PERFORM F_MONTA_ALV.


*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM F_SELECIONA_DADOS .

  SELECT *                              "Acessar os dados da MARD com base na tela de seleção
    FROM MARD
    INTO TABLE T_MARD
    WHERE MATNR IN S_MATNR
      AND WERKS IN S_WERKS.

  IF SY-SUBRC IS INITIAL.

    SELECT *                            "Acessar a RESB com os valores iguais a MARD
      FROM RESB
      INTO TABLE T_RESB
      FOR ALL ENTRIES IN T_MARD
      WHERE MATNR = T_MARD-MATNR
        AND WERKS = T_MARD-WERKS
        AND LGORT = T_MARD-LGORT.

    IF SY-SUBRC <> 0.
      MESSAGE TEXT-004 TYPE 'I'. "Material não encontrado
      STOP.
    ENDIF.

  ELSE.
    MESSAGE TEXT-002 TYPE 'I'. "Não foi encontrado nenhum registro com esses parâmetros
    STOP.

  ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS


*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TAB_SAIDA
*&---------------------------------------------------------------------*
FORM F_MONTA_TAB_SAIDA .

  LOOP AT T_RESB INTO W_RESB.

    CLEAR W_SAIDA.
    W_SAIDA-RSNUM = W_RESB-RSNUM.       "N Reserva
    W_SAIDA-BDMNG = W_RESB-BDMNG.       "Qtd Reserva
    W_SAIDA-MEINS = W_RESB-MEINS.       "Unid Medida


    READ TABLE T_MARD INTO W_MARD
    WITH KEY MATNR = W_RESB-MATNR
             WERKS = W_RESB-WERKS
             LGORT = W_RESB-LGORT.


    IF SY-SUBRC IS INITIAL.
      W_SAIDA-MATNR = W_MARD-MATNR.         "Cod Material
      W_SAIDA-WERKS = W_MARD-WERKS.         "Centro
      W_SAIDA-LGORT = W_MARD-LGORT.         "Deposito
      W_SAIDA-LABST = W_MARD-LABST.         "Qtd Estoque Livre

      W_SAIDA-DISPO = W_SAIDA-LABST - W_SAIDA-BDMNG.          "Calcular campo disponível
    ENDIF.

    IF P_ESTOQ > W_SAIDA-LABST.
      W_SAIDA-COLOR = 'C610'. "Vermelho
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
     I_STRUCTURE_NAME             = 'ZSMM01'
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
    MESSAGE TEXT-003 TYPE 'I'.    "Erro na definição da fieldcat
    STOP.
  ENDIF.

ENDFORM.                    " F_DEFINE_FIELDCAT


*&---------------------------------------------------------------------*
*&      Form  F_ORDENA
*&---------------------------------------------------------------------*
FORM F_ORDENA .

  CLEAR W_SORT.
  W_SORT-SPOS = 1.
  W_SORT-FIELDNAME = 'RSNUM'.
  W_SORT-TABNAME = 'T_SAIDA'.
  W_SORT-UP = 'X'.
  APPEND W_SORT TO T_SORT.

ENDFORM.                    " F_ORDENA


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
FORM F_LAYOUT .

  W_LAYOUT-ZEBRA = 'X'.
  W_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  W_LAYOUT-INFO_FIELDNAME = 'COLOR'.

ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_ALV
*&---------------------------------------------------------------------*
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

*ALV somando tabela e variante obrigatória (VBAK E VBAP)*

REPORT  Z_ALVVARIANTE3TEST.

TYPE-POOLS SLIS.

TYPES: BEGIN OF TY_VBAKP,
  KUNNR  TYPE VBAK-KUNNR,
  MATNR  TYPE VBAP-MATNR,
  ERDAT  TYPE VBAK-ERDAT,
  AUART  TYPE VBAK-AUART,
  VKORG  TYPE VBAK-VKORG,
  ARKTX  TYPE VBAP-ARKTX,
  VBELN  TYPE VBAK-VBELN,
  KWMENG TYPE VBAP-KWMENG,
END OF TY_VBAKP.

*TABELAS TRANSPARENTES

TABLES: VBAK,
        VBAP.



*TABELAS INTERNAS

DATA: T_VBAK          TYPE TABLE OF VBAK,

      T_VBAP          TYPE TABLE OF VBAP,

      T_SAIDA         TYPE TABLE OF ZESTRUTURA3,

      T_VARIANT       TYPE TABLE OF VARIANT,

      T_FIELDCAT      TYPE SLIS_T_FIELDCAT_ALV,

      T_SORT          TYPE SLIS_T_SORTINFO_ALV,

      T_HEADER        TYPE SLIS_T_LISTHEADER,

      T_VBAKP         TYPE TABLE OF TY_VBAKP.



*WORK AREAS

DATA: "W_VBAKP          TYPE VBAP,

*      W_VBAP          TYPE VBAP,

      W_SAIDA         TYPE ZESTRUTURA3,

      W_SELVAR        TYPE SELVAR,

      W_FIELDCAT      TYPE SLIS_FIELDCAT_ALV,

      W_SORT          TYPE SLIS_SORTINFO_ALV,

      W_LAYOUT        TYPE SLIS_LAYOUT_ALV,

      W_HEADER        TYPE SLIS_LISTHEADER,

      W_VARIANT       TYPE DISVARIANT,

      W_VBAKP         TYPE TY_VBAKP.



*TELA DE SELEÇÃO

SELECTION-SCREEN BEGIN OF BLOCK BC01 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: S_KUNNR FOR VBAK-KUNNR,
                S_VKORG FOR VBAK-VKORG,
                S_MATNR FOR VBAP-MATNR,
                S_ERDAT FOR VBAK-ERDAT.


SELECTION-SCREEN END OF BLOCK BC01.

SELECTION-SCREEN BEGIN OF BLOCK BC02 WITH FRAME TITLE TEXT-002.

PARAMETERS: P_VARIAN TYPE SLIS_VARI.

SELECTION-SCREEN END OF BLOCK BC02.

IF S_KUNNR IS INITIAL
  AND S_VKORG IS INITIAL
  AND S_ERDAT IS INITIAL.
  MESSAGE TEXT-008 TYPE 'I'.
  STOP.

ENDIF.



*VARIANTE

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARIAN.
  PERFORM F_VARIANT_F4 CHANGING P_VARIAN.


*PERFOMS PARA ORGANIZAÇÃO

START-OF-SELECTION.

  PERFORM SELECIONA_DADOS.

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
    VBAK~KUNNR
    VBAP~MATNR
    VBAK~ERDAT
    VBAK~AUART
    VBAK~VKORG
    VBAP~ARKTX
    VBAK~VBELN
    VBAP~KWMENG
    INTO TABLE T_VBAKP
    FROM VBAK
    INNER JOIN VBAP ON VBAP~VBELN = VBAK~VBELN
        WHERE VBAK~KUNNR IN S_KUNNR[]
        AND VBAK~VKORG IN S_VKORG[]
        AND VBAK~ERDAT IN S_ERDAT[].

  IF SY-SUBRC IS INITIAL.

    "SELECT * FROM VBAP INTO TABLE T_VBAP
      "FOR ALL ENTRIES IN T_VBAK
      "WHERE VBELN = T_VBAK-VBELN.

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


  DATA: lv_kunnr TYPE kunnr,        " Armazena o cliente atual
        lv_matnr TYPE matnr,        " Armazena o material atual
        lv_soma TYPE kwmeng.       " Armazena a soma de KWMENG

  SORT: T_VBAKP BY KUNNR MATNR.

  "Loop na VBAK e na VBAT

  LOOP AT T_VBAKP INTO W_VBAKP.

    "READ TABLE T_VBAK INTO W_VBAKP WITH KEY VBELN = W_VBAKP-VBELN.


    " Se o KUNNR e MATNR forem iguais aos anteriores, acumula a soma

    IF lv_kunnr = W_VBAKP-KUNNR AND lv_matnr = W_VBAKP-MATNR.
      lv_soma = lv_soma + W_VBAKP-KWMENG.
    ELSE.


      " Caso contrário, verifica se já existe um registro na T_SAIDA

      IF lv_kunnr IS NOT INITIAL AND lv_matnr IS NOT INITIAL.


        " Adiciona o registro anterior na tabela de saída

        W_SAIDA-KWMENG = lv_soma.
        APPEND W_SAIDA TO T_SAIDA.

      ENDIF.


      " Atualiza o KUNNR, MATNR e reinicia a soma

      CLEAR W_SAIDA.
      W_SAIDA-KUNNR = W_VBAKP-KUNNR.
      W_SAIDA-MATNR = W_VBAKP-MATNR.
      W_SAIDA-ERDAT = W_VBAKP-ERDAT.
      W_SAIDA-AUART = W_VBAKP-AUART.
      W_SAIDA-VKORG = W_VBAKP-VKORG.
      W_SAIDA-ARKTX = W_VBAKP-ARKTX.


      lv_kunnr = W_VBAKP-KUNNR.
      lv_matnr = W_VBAKP-MATNR.
      lv_soma = W_VBAKP-KWMENG.  " Inicia a soma com o valor atual de KWMENG
    ENDIF.
  ENDLOOP.


  " Após o loop, insere o último registro na T_SAIDA

  IF lv_kunnr IS NOT INITIAL AND lv_matnr IS NOT INITIAL.
    W_SAIDA-KWMENG = lv_soma.
    APPEND W_SAIDA TO T_SAIDA.
  ENDIF.


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
      I_STRUCTURE_NAME             = 'ZESTRUTURA3'
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
  W_SORT-FIELDNAME = 'KUNNR'.
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


  W_VARIANT-VARIANT = P_VARIAN.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
*    I_INTERFACE_CHECK                 = ' '
*    I_BYPASSING_BUFFER                = ' '
*    I_BUFFER_ACTIVE                   = ' '
    I_CALLBACK_PROGRAM                = SY-REPID
*    I_CALLBACK_PF_STATUS_SET          = ' '
*    I_CALLBACK_USER_COMMAND           = ' '
    I_CALLBACK_TOP_OF_PAGE            = 'F_CABECALHO'
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
   IS_VARIANT                        = W_VARIANT
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
*&      Form  F_CABECALHO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CABECALHO.


  CLEAR W_HEADER.
  REFRESH T_HEADER.

  W_HEADER-TYP = 'H'.
  W_HEADER-INFO = TEXT-005."Vendas
  APPEND W_HEADER TO T_HEADER.

  W_HEADER-TYP = 'S'.
  W_HEADER-KEY = TEXT-006."DATA.:
  WRITE SY-DATUM TO W_HEADER-INFO.
  APPEND W_HEADER TO T_HEADER.

  W_HEADER-TYP = 'S'.
  W_HEADER-KEY = TEXT-007."HORA.:
  WRITE SY-UZEIT TO W_HEADER-INFO.
  APPEND W_HEADER TO T_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.


ENDFORM.                    "F_CABECALHO



*&---------------------------------------------------------------------*
*&      Form  F_VARIANT_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_VARIAN  text
*----------------------------------------------------------------------*
FORM F_VARIANT_F4  CHANGING P_P_VARIAN.


  DATA: VL_VARIANT TYPE DISVARIANT.

  VL_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT                = VL_VARIANT
*     I_TABNAME_HEADER          =
*     I_TABNAME_ITEM            =
*     IT_DEFAULT_FIELDCAT       =
      I_SAVE                    = 'A'
*     I_DISPLAY_VIA_GRID        = ' '
    IMPORTING
*     E_EXIT                    = VL_VARIANT
      ES_VARIANT                = VL_VARIANT
    EXCEPTIONS
      NOT_FOUND                 = 1
      PROGRAM_ERROR             = 2
      OTHERS                    = 3.
  IF SY-SUBRC = 0.

    P_P_VARIAN = VL_VARIANT-VARIANT.

  ENDIF.


ENDFORM.                    " F_VARIANT_F4

*Batch Input com ALV,verde para certo e vermelho pra errado*

REPORT  ZRMCBATCHINPUT.

TYPE-POOLS SLIS.

*TIPOS
TYPES: BEGIN OF TY_FILE,
       CODI LIKE RF02D-KUNNR,
       NAME LIKE KNA1-NAME1,
       ENDE LIKE KNA1-STRAS,
       CITY LIKE KNA1-ORT01,
       TELF LIKE KNA1-TELF1,
END OF TY_FILE.

TYPES: BEGIN OF TY_ALV,
       CODI TYPE RF02D-KUNNR,
       STAT TYPE ICON_D,
       MESG TYPE STRING,
END OF TY_ALV.

TYPES: BEGIN OF TY_CSV,
  LINE(400) TYPE C,
  END OF TY_CSV.

*TABELAS INTERNAS
DATA: T_FILE     TYPE STANDARD TABLE OF TY_FILE,
      T_BDCDATA  TYPE STANDARD TABLE OF BDCDATA,
      T_CSV      TYPE STANDARD TABLE OF TY_CSV,
      T_ALV      TYPE STANDARD TABLE OF TY_ALV,
      T_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      T_SORT     TYPE SLIS_T_SORTINFO_ALV,
      T_HEADER   TYPE SLIS_T_LISTHEADER.

*WORK AREA
DATA: W_FILE    TYPE TY_FILE,
      W_BDCDATA TYPE BDCDATA,
      W_CSV     TYPE TY_CSV,
      W_ALV     TYPE TY_ALV,
      W_FIELDCAT      TYPE SLIS_FIELDCAT_ALV,
      W_SORT          TYPE SLIS_SORTINFO_ALV,
      W_LAYOUT        TYPE SLIS_LAYOUT_ALV,
      W_HEADER        TYPE SLIS_LISTHEADER.

*TELA DE SELEÇÃO
PARAMETERS: P_FILE TYPE LOCALFILE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F_SELECIONA_ARQUIVO.

START-OF-SELECTION.
 INCLUDE: <ICON>.

  PERFORM F_UPLOAD_FILE.
  PERFORM F_MONTA_BDC.
  PERFORM F_MONTA_TABELA_SAIDA.
  PERFORM F_MONTA_ALV.

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_ARQUIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECIONA_ARQUIVO .

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
   EXPORTING
*   PROGRAM_NAME        = SYST-REPID
*   DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          = P_FILE
*   STATIC              = ' '
*   MASK                = ' '
*   FILEOPERATION       = 'R'
*   PATH                =
    CHANGING
      FILE_NAME           = P_FILE
*   LOCATION_FLAG       = 'P'
* EXCEPTIONS
*   MASK_TOO_LONG       = 1
*   OTHERS              = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " F_SELECIONA_ARQUIVO
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_UPLOAD_FILE .
  DATA: VL_FILE TYPE STRING.

  VL_FILE = P_FILE.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = VL_FILE
      FILETYPE                      = 'ASC'
*   HAS_FIELD_SEPARATOR           = ' '
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
*   ISDOWNLOAD                    = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
    TABLES
      DATA_TAB                      = T_CSV
* CHANGING
*   ISSCANPERFORMED               = ' '
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_READ_ERROR               = 2
     NO_BATCH                      = 3
     GUI_REFUSE_FILETRANSFER       = 4
     INVALID_TYPE                  = 5
     NO_AUTHORITY                  = 6
     UNKNOWN_ERROR                 = 7
     BAD_DATA_FORMAT               = 8
     HEADER_NOT_ALLOWED            = 9
     SEPARATOR_NOT_ALLOWED         = 10
     HEADER_TOO_LONG               = 11
     UNKNOWN_DP_ERROR              = 12
     ACCESS_DENIED                 = 13
     DP_OUT_OF_MEMORY              = 14
     DISK_FULL                     = 15
     DP_TIMEOUT                    = 16
     OTHERS                        = 17.

  LOOP AT T_CSV INTO W_CSV.

    SPLIT W_CSV AT ';' INTO    W_FILE-CODI
                               W_FILE-NAME
                               W_FILE-ENDE
                               W_FILE-CITY
                               W_FILE-TELF.

    APPEND W_FILE TO T_FILE.

  ENDLOOP.

ENDFORM.                    " F_UPLOAD_FILE
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_MONTA_BDC .

  PERFORM F_ABRE_PASTA.

  LOOP AT T_FILE INTO W_FILE.

    PERFORM F_MONTA_TELA USING 'SAPMF02D' '0101'.
    PERFORM F_MONTA_DADOS USING 'BDC_CURSOR' 'RF02D-D0110'.
    PERFORM F_MONTA_DADOS USING 'BDC_OKCODE' '/00'.
    PERFORM F_MONTA_DADOS USING 'RF02D-KUNNR' W_FILE-CODI.
    PERFORM F_MONTA_DADOS USING 'RF02D-D0110' 'X'.

    PERFORM F_MONTA_TELA USING 'SAPMF02D' '0110'.
    PERFORM F_MONTA_DADOS USING 'BDC_CURSOR' 'KNA1-TELF1'.
    PERFORM F_MONTA_DADOS USING 'BDC_OKCODE' '/00'.
    PERFORM F_MONTA_DADOS USING 'KNA1-NAME1' W_FILE-NAME.
    PERFORM F_MONTA_DADOS USING 'KNA1-STRAS' W_FILE-ENDE.
    PERFORM F_MONTA_DADOS USING 'KNA1-ORT01' W_FILE-CITY.
    PERFORM F_MONTA_DADOS USING 'KNA1-TELF1' W_FILE-TELF.

    PERFORM F_INSERI_BDC.

    IF SY-SUBRC = 0.
      MESSAGE TEXT-001 TYPE 'S'. "Sucesso ao inserir o Cliente

    ELSEIF SY-SUBRC <> 0.
      MESSAGE TEXT-002 TYPE 'E'. "Erro ao inserir o Cliente

    ENDIF.

  ENDLOOP.

  PERFORM F_FECHA_PASTA.

ENDFORM.                    " F_MONTA_BDC
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TELA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0164   text
*      -->P_0165   text
*----------------------------------------------------------------------*
FORM F_MONTA_TELA  USING    P_PROGRAM
                            P_SCREEN.

  CLEAR W_BDCDATA.
  W_BDCDATA-PROGRAM  = P_PROGRAM.
  W_BDCDATA-DYNPRO   = P_SCREEN.
  W_BDCDATA-DYNBEGIN = 'X'.
  APPEND W_BDCDATA TO T_BDCDATA.

ENDFORM.                    " F_MONTA_TELA
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0180   text
*      -->P_0181   text
*----------------------------------------------------------------------*
FORM F_MONTA_DADOS  USING    P_NAME
                             P_VALUE.

  CLEAR W_BDCDATA.
  W_BDCDATA-FNAM = P_NAME.
  W_BDCDATA-FVAL = P_VALUE.
  APPEND W_BDCDATA TO T_BDCDATA.

ENDFORM.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_ABRE_PASTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ABRE_PASTA .

  CALL FUNCTION 'BDC_OPEN_GROUP'
   EXPORTING
     CLIENT                    = SY-MANDT
*   DEST                      = FILLER8
     GROUP                     = 'CARGA_BATCH'
*   HOLDDATE                  = FILLER8
     KEEP                      = 'X'
     USER                      = SY-UNAME
*   RECORD                    = FILLER1
*   PROG                      = SY-CPROG
*   DCPFM                     = '%'
*   DATFM                     = '%'
* IMPORTING
*   QID                       =
   EXCEPTIONS
     CLIENT_INVALID            = 1
     DESTINATION_INVALID       = 2
     GROUP_INVALID             = 3
     GROUP_IS_LOCKED           = 4
     HOLDDATE_INVALID          = 5
     INTERNAL_ERROR            = 6
     QUEUE_ERROR               = 7
     RUNNING                   = 8
     SYSTEM_LOCK_ERROR         = 9
     USER_INVALID              = 10
     OTHERS                    = 11
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " F_ABRE_PASTA
*&---------------------------------------------------------------------*
*&      Form  F_INSERI_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_INSERI_BDC .

  CALL FUNCTION 'BDC_INSERT'
   EXPORTING
     TCODE                  = 'xd02'
*   POST_LOCAL             = NOVBLOCAL
*   PRINTING               = NOPRINT
*   SIMUBATCH              = ' '
*   CTUPARAMS              = ' '
    TABLES
      DYNPROTAB              = T_BDCDATA
   EXCEPTIONS
     INTERNAL_ERROR         = 1
     NOT_OPEN               = 2
     QUEUE_ERROR            = 3
     TCODE_INVALID          = 4
     PRINTING_INVALID       = 5
     POSTING_INVALID        = 6
     OTHERS                 = 7
            .
  IF SY-SUBRC <> 0.
    MESSAGE TEXT-003 TYPE 'I'. "Erro ao Abrir Pasta
    ELSE.
    REFRESH T_BDCDATA.
  ENDIF.


ENDFORM.                    " F_INSERI_BDC
*&---------------------------------------------------------------------*
*&      Form  F_FECHA_PASTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FECHA_PASTA .

  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      NOT_OPEN    = 1
      QUEUE_ERROR = 2
      OTHERS      = 3.

  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " F_FECHA_PASTA
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

  CLEAR W_FIELDCAT.
  W_FIELDCAT-COL_POS = 1.
  W_FIELDCAT-FIELDNAME = 'STAT'.
  W_FIELDCAT-TABNAME = 'T_ALV'.
  W_FIELDCAT-SELTEXT_M = 'Status'.
  APPEND W_FIELDCAT TO T_FIELDCAT.

  CLEAR W_FIELDCAT.
  W_FIELDCAT-COL_POS = 2.
  W_FIELDCAT-FIELDNAME = 'CODI'.
  W_FIELDCAT-TABNAME = 'T_ALV'.
  W_FIELDCAT-SELTEXT_M = 'Código Cliente'.
  APPEND W_FIELDCAT TO T_FIELDCAT.

  CLEAR W_FIELDCAT.
  W_FIELDCAT-COL_POS = 3.
  W_FIELDCAT-FIELDNAME = 'MESG'.
  W_FIELDCAT-TABNAME = 'T_ALV'.
  W_FIELDCAT-SELTEXT_M = 'Mensagem'.
  APPEND W_FIELDCAT TO T_FIELDCAT.


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
  W_SORT-FIELDNAME = 'CODI'.
  W_SORT-TABNAME = 'T_ALV'.
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
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
     I_CALLBACK_PROGRAM                = SY-REPID
*     I_CALLBACK_PF_STATUS_SET          = ' '
*      I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE            = 'F_CABECALHO'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
     IS_LAYOUT                         = W_LAYOUT
     IT_FIELDCAT                       = T_FIELDCAT
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
     IT_SORT                           = T_SORT
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = 'X'
*     IS_VARIANT                        = W_VARIANT
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      T_OUTTAB                          = T_ALV
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2.

ENDFORM.                    " F_IMPRIME_ALV
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TABELA_SAÍDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_MONTA_TABELA_SAIDA .

  LOOP AT T_FILE INTO W_FILE.
    W_ALV-CODI = W_FILE-CODI.

  IF W_FILE-CODI IS NOT INITIAL
 AND W_FILE-NAME IS NOT INITIAL
 AND W_FILE-ENDE IS NOT INITIAL
 AND W_FILE-CITY IS NOT INITIAL
 AND W_FILE-TELF IS NOT INITIAL.

    W_ALV-MESG = 'Sucesso ao Inserir as Informações'.
    W_ALV-STAT = ICON_LED_GREEN.

   ELSE.

    W_ALV-MESG = 'Erro ao Inserir as Informações'.
    W_ALV-STAT = ICON_LED_RED.

  ENDIF.



  APPEND W_ALV TO T_ALV.

ENDLOOP.


ENDFORM.                    " F_MONTA_TABELA_SAÍDA

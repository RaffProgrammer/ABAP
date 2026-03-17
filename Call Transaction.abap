*Chamar Transação*

REPORT  Z_CALLTRANSACTION MESSAGE-ID Z_CLASSEMSG2.

TYPES: BEGIN OF TY_FILE,
  FORNE LIKE ZABELA_TESTE4-FORNE,
  DENOM LIKE ZABELA_TESTE4-DENOM,
  ENDER LIKE ZABELA_TESTE4-ENDER,
  TELEF LIKE ZABELA_TESTE4-TELEF,
  EMAIL LIKE ZABELA_TESTE4-EMAIL,
  CNPJ LIKE ZABELA_TESTE4-CNPJ,
  END OF TY_FILE.

DATA: T_FILE TYPE STANDARD TABLE OF TY_FILE.
DATA: T_BDCDATA TYPE STANDARD TABLE OF BDCDATA.
DATA: T_MESSAGE TYPE STANDARD TABLE OF BDCMSGCOLL.

DATA: W_FILE TYPE TY_FILE.
DATA: W_BDCDATA TYPE BDCDATA.
DATA: W_MESSAGE TYPE BDCMSGCOLL.

PARAMETERS: P_FILE TYPE LOCALFILE,
           P_MODE TYPE C DEFAULT 'A'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F_SELECIONA_ARQUIVO.

START-OF-SELECTION.
  PERFORM F_UPLOAD_FILE.
  PERFORM F_MONTA_BDC.
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
      DATA_TAB                      = T_FILE
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
     OTHERS                        = 17
            .
  IF SY-SUBRC <> 0.
MESSAGE E000.

  ENDIF.


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

LOOP AT T_FILE INTO W_FILE.

  PERFORM F_MONTA_TELA  USING 'SAPLZTABELA'              '0004'.
  PERFORM F_MONTA_DADOS USING 'BDC_CURSOR'              'ZABELA_TESTE4-FORNE(01)'.
  PERFORM F_MONTA_DADOS USING 'BDC_OKCODE'              '=NEWL'.

  PERFORM F_MONTA_TELA  USING 'SAPLZTABELA'             '0004'.
  PERFORM F_MONTA_DADOS USING 'BDC_CURSOR'              'ZABELA_TESTE4-CNPJ(01)'.
  PERFORM F_MONTA_DADOS USING 'BDC_OKCODE'              '=SAVE'.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-FORNE(01)' W_FILE-FORNE.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-DENOM(01)' W_FILE-DENOM.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-ENDER(01)' W_FILE-ENDER.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-TELEF(01)' W_FILE-TELEF.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-EMAIL(01)' W_FILE-EMAIL.
  PERFORM F_MONTA_DADOS USING 'ZABELA_TESTE4-CNPJ(01)'  W_FILE-CNPJ.

  PERFORM F_MONTA_TELA  USING 'SAPLZTABELA'             '0004'.
  PERFORM F_MONTA_DADOS USING 'BDC_CURSOR'              'ZABELA_TESTE4-FORNE(02)'.
  PERFORM F_MONTA_DADOS USING 'BDC_OKCODE'              '=BACK'.
  PERFORM F_MONTA_DADOS USING 'BDC_OKCODE'              '=BACK'.
  PERFORM F_MONTA_TELA  USING 'SAPLZTABELA'              '0004'.
  PERFORM F_MONTA_DADOS USING 'BDC_CURSOR'              'ZABELA_TESTE4-FORNE(02)'.
  PERFORM F_MONTA_DADOS USING 'BDC_OKCODE'              '=BACK'.

CALL TRANSACTION 'ZTESTETRANSA4'
USING T_BDCDATA
      MODE P_MODE
      UPDATE 'A'
      MESSAGES INTO T_MESSAGE.

PERFORM F_IMPRIME_MESSAGE.

CLEAR: T_BDCDATA[], W_BDCDATA, T_MESSAGE[].

ENDLOOP.

ENDFORM.                    " F_MONTA_BDC
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TELA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0168   text
*      -->P_0169   text
*----------------------------------------------------------------------*
FORM F_MONTA_TELA  USING    P_PROGRAM
                            P_SCREEN.
  CLEAR W_BDCDATA.
  W_BDCDATA-PROGRAM = P_PROGRAM.
  W_BDCDATA-DYNPRO = P_SCREEN.
  W_BDCDATA-DYNBEGIN = 'X'.
  APPEND W_BDCDATA TO T_BDCDATA.

ENDFORM.                    " F_MONTA_TELA
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0184   text
*      -->P_0185   text
*----------------------------------------------------------------------*
FORM F_MONTA_DADOS  USING    P_NAME
                             P_VALUE.

  CLEAR W_BDCDATA.
  W_BDCDATA-FNAM = P_NAME.
  W_BDCDATA-FVAL = P_VALUE.
  APPEND W_BDCDATA TO T_BDCDATA.

ENDFORM.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_IMPRIME_MESSAGE .

  DATA: VL_ID TYPE BAPIRET2-ID,
        VL_NUMBER TYPE BAPIRET2-NUMBER,
        VL_MESS1 TYPE BAPIRET2-MESSAGE_V1,
        VL_MESS2 TYPE BAPIRET2-MESSAGE_V2,
        VL_MESS3 TYPE BAPIRET2-MESSAGE_V3,
        VL_MESS4 TYPE BAPIRET2-MESSAGE_V4,
        VL_MESSAGE TYPE BAPIRET2-MESSAGE.

LOOP AT T_MESSAGE INTO W_MESSAGE WHERE MSGTYP = 'E' OR MSGTYP = 'S'.

  VL_ID     = W_MESSAGE-MSGID.
  VL_NUMBER = W_MESSAGE-MSGNR.
  VL_MESS1 =  W_MESSAGE-MSGV1.
  VL_MESS2 =  W_MESSAGE-MSGV2.
  VL_MESS3 =  W_MESSAGE-MSGV3.
  VL_MESS4 =  W_MESSAGE-MSGV4.


CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
  EXPORTING
    ID                 = VL_ID
    NUMBER             = VL_NUMBER
*   LANGUAGE           = SY-LANGU
    TEXTFORMAT         = 'ASC'
*   LINKPATTERN        =
   MESSAGE_V1         = VL_MESS1
   MESSAGE_V2         = VL_MESS2
   MESSAGE_V3         = VL_MESS3
   MESSAGE_V4         = VL_MESS4
*   LANGUAGE_ISO       =
 IMPORTING
   MESSAGE            = VL_MESSAGE.

WRITE: VL_MESSAGE.

ENDLOOP.


ENDFORM.                    " F_IMPRIME_MESSAGE

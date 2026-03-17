*Preencher fieldcat manualmente*

TYPES: BEGIN OF y_relat,                  "DECLARACAO
         vbeln  TYPE vbak-vbeln,
         erdat  TYPE vbak-erdat,
         kunnr  TYPE vbak-kunnr,
         name1  TYPE kna1-name1,
         vkorg  TYPE vbak-vkorg,
         posnr  TYPE vbap-posnr,
         matnr  TYPE vbap-matnr,
         maktx  TYPE makt-maktx,
         netwr  TYPE vbap-netwr,
         waerk  TYPE vbap-waerk,
         kwmeng TYPE vbap-kwmeng,
         vrkme  TYPE vbap-vrkme,
         brgew  TYPE vbap-brgew,
       END OF y_relat.

DATA: gt_relat TYPE TABLE OF y_relat.

DATA: gs_vbak TYPE vbak,
      gs_vbap TYPE vbap.


SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vbeln FOR gs_vbak-vbeln,
                s_erdat FOR gs_vbak-erdat,
                s_vkorg FOR gs_vbak-vkorg,
                s_matnr FOR gs_vbap-matnr,
                s_kunnr FOR gs_vbak-kunnr.
SELECTION-SCREEN END OF BLOCK a1.

START-OF-SELECTION.
  PERFORM zf_busca_dados.
  PERFORM zf_chama_alv.


*&---------------------------------------------------------------------*
*&      Form  ZF_BUSCA_DADOS
*&---------------------------------------------------------------------*
FORM ZF_BUSCA_DADOS .

  DATA: ls_relat TYPE y_relat.

  " SELECT vbeln, erdat, vkorg, netwr         "DEL001 - SANTOS4 AULA6

  SELECT vbeln, erdat, kunnr, vkorg          "SELECT
    FROM   vbak
    INTO TABLE @DATA(lt_vbak)
    WHERE vbeln IN @s_vbeln                         "FILTRO
    AND   erdat IN @s_erdat
    AND   vkorg IN @s_vkorg
    AND   kunnr IN @s_kunnr.

  IF sy-subrc IS INITIAL.              "precisa validar se tem dados na ltvbak, se nao trará todos os registros.

    SELECT kunnr, name1
      FROM kna1
      INTO TABLE @DATA(lt_kna1) FOR ALL ENTRIES IN @lt_vbak
      WHERE kunnr EQ @lt_vbak-kunnr.

    SELECT vbeln, posnr, matnr, netwr, waerk, kwmeng, vrkme, brgew
      FROM vbap
      INTO TABLE @DATA(lt_vbap) FOR ALL ENTRIES IN @lt_vbak
      WHERE vbeln EQ @lt_vbak-vbeln
      AND   matnr IN @s_matnr.

    IF sy-subrc IS INITIAL.
      SELECT matnr, maktx
        FROM makt
        INTO TABLE @DATA(lt_makt) FOR ALL ENTRIES IN @lt_vbap
        WHERE matnr EQ @lt_vbap-matnr
        AND   spras EQ @sy-langu.       "sy-langu é o idioma que estou logado
    ENDIF.

  ENDIF.

  LOOP AT lt_vbap INTO DATA(ls_vbap).

    READ TABLE lt_vbak INTO DATA(ls_vbak) WITH KEY vbeln = ls_vbap-vbeln.
    IF SY-SUBRC IS INITIAL.
      ls_relat-vbeln = ls_vbak-vbeln.             "ALIMENTACAO DA TABELA INTERNA
      ls_relat-erdat = ls_vbak-erdat.
      ls_relat-kunnr = ls_vbak-kunnr.
      ls_relat-vkorg = ls_vbak-vkorg.

      READ TABLE lt_kna1 INTO DATA(ls_kna1) WITH KEY kunnr = ls_vbak-kunnr.
      IF SY-SUBRC IS INITIAL.
        ls_relat-name1 = ls_kna1-name1.
      ENDIF.
    ENDIF.

    READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_vbap-matnr.
    IF SY-SUBRC IS INITIAL.
      ls_relat-maktx = ls_makt-maktx.
    ENDIF.

    ls_relat-posnr = ls_vbap-posnr.
    ls_relat-matnr = ls_vbap-matnr.
    ls_relat-netwr = ls_vbap-netwr.
    ls_relat-waerk = ls_vbap-waerk.
    ls_relat-kwmeng = ls_vbap-kwmeng.
    ls_relat-vrkme = ls_vbap-vrkme.
    ls_relat-brgew = ls_vbap-brgew.

    APPEND ls_relat TO gt_relat.
    CLEAR ls_relat.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_CHAMA_ALV
*&---------------------------------------------------------------------*

FORM ZF_CHAMA_ALV .

  DATA: lt_fieldcat TYPE TABLE OF slis_fieldcat_alv.

  DATA: ls_layout   TYPE slis_layout_alv,
        ls_fieldcat TYPE slis_fieldcat_alv.

  "DEFINIÇÃO DE CATALOGO DE CAMPO

  ls_fieldcat-fieldname = 'VBELN'.
  ls_fieldcat-ref_fieldname = 'VBELN'.
  ls_fieldcat-ref_tabname = 'VBAK'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'ERDAT'.
  ls_fieldcat-ref_fieldname = 'ERDAT'.
  ls_fieldcat-ref_tabname = 'VBAK'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KUNNR'.
  ls_fieldcat-ref_fieldname = 'KUNNR'.
  ls_fieldcat-ref_tabname = 'VBAK'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-ref_fieldname = 'NAME1'.
  ls_fieldcat-ref_tabname = 'KNA1'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'POSNR'.
  ls_fieldcat-ref_fieldname = 'POSNR'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-ref_fieldname = 'MATNR'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-ref_fieldname = 'MAKTX'.
  ls_fieldcat-ref_tabname = 'MAKT'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'NETWR'.
  ls_fieldcat-ref_fieldname = 'NETWR'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'WAERK'.
  ls_fieldcat-ref_fieldname = 'WAERK'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'KWMENG'.
  ls_fieldcat-ref_fieldname = 'KWMENG'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'VRKME'.
  ls_fieldcat-ref_fieldname = 'VRKME'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-fieldname = 'BRGEW'.
  ls_fieldcat-ref_fieldname = 'BRGEW'.
  ls_fieldcat-ref_tabname = 'VBAP'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  "Definição de layout
  LS_LAYOUT-ZEBRA = 'X'.
  LS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = ls_layout
      IT_FIELDCAT   = lt_fieldcat
    TABLES
      T_OUTTAB      = gt_relat
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

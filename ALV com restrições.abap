*ALV selecionar quando foi liberado o produto e por quem, determinado por verde ou vermelho*


TYPE-POOLS: slis.

INCLUDE: <icon>.

"Tabelas
TABLES: sscrfields,     "Fields on selection screens
        smp_dyntxt.     "Menu Painter: program interface for dynamic texts

"Tipos
TYPES: BEGIN OF ty_saida.
        INCLUDE STRUCTURE zteste_mmt101.
TYPES:  status_icon TYPE icon_d.
TYPES: END OF ty_saida.


"Tabelas e Estruturas
DATA: lt_zteste_mmt101 TYPE TABLE OF zteste_mmt101,
      lt_saida         TYPE TABLE OF ty_saida,
      lt_fieldcat      TYPE STANDARD TABLE OF slis_fieldcat_alv,
      lt_dtent         LIKE sval OCCURS 0 WITH HEADER LINE,         "popup para data de entrega
      ls_zteste_mmt101 TYPE zteste_mmt101,
      ls_saida         TYPE ty_saida,
      ls_fieldcat      TYPE slis_fieldcat_alv,
      ls_layout        TYPE slis_layout_alv,
      "Variáveis
      lv_pop_answer    TYPE c.


"Tela de Seleção
SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_rsnum FOR ls_zteste_mmt101-rsnum,
                so_rspos FOR ls_zteste_mmt101-rspos,
                so_dtent FOR ls_zteste_mmt101-dt_prev_entrega,
                so_werks FOR ls_zteste_mmt101-werks,
                so_lgort FOR ls_zteste_mmt101-lgort,
                so_matnr FOR ls_zteste_mmt101-matnr,
                so_statu FOR ls_zteste_mmt101-status,
                so_aprov FOR ls_zteste_mmt101-aprovador,
                so_dtapr FOR ls_zteste_mmt101-dt_aprov_reprov.
SELECTION-SCREEN END OF BLOCK A1.

SELECTION-SCREEN FUNCTION KEY 1.


INITIALIZATION.

  "Botão 1
  smp_dyntxt-text       = 'Cadastrar e-mails'.
  smp_dyntxt-icon_id    = icon_change_text.
  smp_dyntxt-icon_text  = 'Cadastrar e-mails'.
  smp_dyntxt-quickinfo  = 'Cadastro de e-mails'.
  sscrfields-functxt_01 = smp_dyntxt.
  CLEAR smp_dyntxt.


AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
  ENDCASE.



START-OF-SELECTION.

  PERFORM f_seleciona_dados.
  PERFORM f_monta_alv.


*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM F_SELECIONA_DADOS .

  SELECT *
    FROM zteste_mmt101
    INTO TABLE lt_zteste_mmt101
    WHERE rsnum           IN so_rsnum
      AND rspos           IN so_rspos
      AND dt_prev_entrega IN so_dtent
      AND werks           IN so_werks
      AND lgort           IN so_lgort
      AND matnr           IN so_matnr
      AND status          IN so_statu
      AND aprovador       IN so_aprov
      AND dt_aprov_reprov IN so_dtapr.

  IF sy-subrc = 0.
    PERFORM f_monta_tab_saida.
  ELSE.
    MESSAGE TEXT-002 TYPE 'I'.
*    STOP.
  ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS


*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TAB_SAIDA
*&---------------------------------------------------------------------*
FORM F_MONTA_TAB_SAIDA .

  LOOP AT lt_zteste_mmt101 INTO ls_zteste_mmt101.
    MOVE-CORRESPONDING ls_zteste_mmt101 TO ls_saida.

    IF ls_saida-status = 'A'.
      ls_saida-status_icon = icon_led_green.
    ELSEIF ls_saida-status = 'R'.
      ls_saida-status_icon = icon_led_red.
    ELSEIF ls_saida-status = 'P'.
      ls_saida-status_icon = icon_ps_milestone.
      ls_saida-dt_prev_entrega = ' '.
      ls_saida-aprovador = ' '.
      ls_saida-nome = ' '.
      ls_saida-dt_aprov_reprov = ' '.
      ls_saida-hr_aprov_reprov = ' '.
    ENDIF.

    APPEND ls_saida TO lt_saida.
  ENDLOOP.


ENDFORM.                    " F_MONTA_TAB_SAIDA


*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
FORM F_MONTA_ALV .

  PERFORM f_define_fieldcat.
  PERFORM f_layout.
  PERFORM f_imprime_alv.

ENDFORM.                    " F_MONTA_ALV


*&---------------------------------------------------------------------*
*&      Form  F_DEFINE_FIELDCAT
*&---------------------------------------------------------------------*
FORM F_DEFINE_FIELDCAT .

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-fieldname = 'STATUS_ICON'.
  ls_fieldcat-seltext_m = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-fieldname = 'RSNUM'.
  ls_fieldcat-seltext_m = 'Reserva'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-fieldname = 'RSPOS'.
  ls_fieldcat-seltext_m = 'Item'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-seltext_m = 'Material'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-fieldname = 'WERKS'.
  ls_fieldcat-seltext_m = 'Centro'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 6.
  ls_fieldcat-fieldname = 'LGORT'.
  ls_fieldcat-seltext_m = 'Depósito'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 7.
  ls_fieldcat-fieldname = 'ERFMG'.
  ls_fieldcat-seltext_m = 'Quantidade'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 8.
  ls_fieldcat-fieldname = 'DT_PREV_ENTREGA'.
  ls_fieldcat-seltext_m = 'Dt Prev Entrega'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 9.
  ls_fieldcat-fieldname = 'APROVADOR'.
  ls_fieldcat-seltext_m = 'Aprovador'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 10.
  ls_fieldcat-fieldname = 'NOME'.
  ls_fieldcat-seltext_m = 'Nome Completo'.
  APPEND ls_fieldcat TO lt_fieldcat.
  CLEAR ls_fieldcat.

  ls_fieldcat-col_pos = 11.
  ls_fieldcat-fieldname = 'DT_APROV_REPROV'.
  ls_fieldcat-seltext_m = 'Dt Apr/Rep'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 12.
  ls_fieldcat-fieldname = 'HR_APROV_REPROV'.
  ls_fieldcat-seltext_m = 'Hr Apr/Rep'.
  APPEND ls_fieldcat TO lt_fieldcat.

  "Habilitar hotspot para número de reserva
  LOOP AT lt_fieldcat INTO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'RSNUM'.
        ls_fieldcat-hotspot = 'X'.
    ENDCASE.

    MODIFY lt_fieldcat FROM ls_fieldcat INDEX sy-tabix TRANSPORTING hotspot.

  ENDLOOP.

ENDFORM.                    " F_DEFINE_FIELDCAT


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
FORM F_LAYOUT .

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_ALV
*&---------------------------------------------------------------------*
FORM F_IMPRIME_ALV .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     I_CALLBACK_PROGRAM                = sy-repid
     I_CALLBACK_PF_STATUS_SET          = 'PF_STATUS'
     I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
     IS_LAYOUT                         = ls_layout
     IT_FIELDCAT                       = lt_fieldcat

    TABLES
      T_OUTTAB                          = lt_saida
   EXCEPTIONS
     PROGRAM_ERROR                     = 1
     OTHERS                            = 2.

  IF SY-SUBRC <> 0.

  ENDIF.


ENDFORM.                    " F_IMPRIME_ALV


*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM PF_STATUS USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ZSTANDARD'.

ENDFORM.                    "PF_STATUS


*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM USER_COMMAND USING r_ucomm  TYPE sy-ucomm
                        selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN '&BACK'.
      LEAVE PROGRAM.



    WHEN '&APR'.
          READ TABLE lt_saida INTO ls_saida INDEX selfield-tabindex.

          PERFORM f_popup_entrega.

          "Atualiza os dados após aprovado
          ls_saida-status_icon = icon_led_green.
          ls_saida-status      = 'A'.
          ls_saida-aprovador   = sy-uname.
          ls_saida-nome        = sy-uname.
          ls_saida-dt_aprov_reprov = sy-datum.
          ls_saida-hr_aprov_reprov = sy-uzeit.
          ls_saida-dt_prev_entrega = lt_dtent-value.
          selfield-refresh = 'X'.

          "Modifica a linha seleciona e insere na tabela
          MODIFY lt_saida FROM ls_saida INDEX selfield-tabindex.
          MODIFY zteste_mmt101 FROM TABLE lt_saida.


      WHEN '&REP'.
        PERFORM f_popup_reprova.

        "Confirmar reprovação
        CASE lv_pop_answer.
          WHEN '1'.
            READ TABLE lt_saida INTO ls_saida INDEX selfield-tabindex.
            CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
              EXPORTING
                I_MSGID  = 'ZCMMT101TESTE'
                I_MSGTY  = 'S'
                I_MSGNO  = '000'
                I_MSGV1  = LS_SAIDA-RSNUM
                I_LINENO = 1.
        ENDCASE.

        ls_saida-status_icon = icon_led_red.
        ls_saida-status      = 'R'.
        ls_saida-aprovador   = sy-uname.
        ls_saida-nome        = sy-uname.
        ls_saida-dt_aprov_reprov = sy-datum.
        ls_saida-hr_aprov_reprov = sy-uzeit.
        selfield-refresh = 'X'.

        "Modifica a linha selecionada e insere na tabela
        MODIFY lt_saida FROM ls_saida INDEX selfield-tabindex.
        MODIFY zteste_mmt101 FROM TABLE lt_saida.


    WHEN '&IC1'.
      IF selfield-sel_tab_field = '1-RSNUM'.

        READ TABLE lt_saida INTO ls_saida INDEX selfield-tabindex.

        IF sy-subrc = 0.
          SET PARAMETER ID 'RES' FIELD ls_saida-rsnum.
          CALL TRANSACTION 'MB23' AND SKIP FIRST SCREEN.
        ENDIF.

      ENDIF.
  ENDCASE.

ENDFORM.                    "USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_POPUP_ENTREGA
*&---------------------------------------------------------------------*
FORM F_POPUP_ENTREGA .

  lt_dtent-tabname = 'ZTESTE_MMT101'.
  lt_dtent-fieldname = 'DT_PREV_ENTREGA'.
  APPEND lt_dtent.

  "Alterar data de previsão de entrega
  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING

    TABLES
      FIELDS                = lt_dtent
   EXCEPTIONS
     ERROR_IN_FIELDS       = 1
     OTHERS                = 2.

ENDFORM.                    " F_POPUP_ENTREGA


*&---------------------------------------------------------------------*
*&      Form  F_POPUP_REPROVA
*&---------------------------------------------------------------------*
FORM F_POPUP_REPROVA.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = 'Atenção'
      TEXT_QUESTION  = 'Tem certeza que deseja executar a ação?'
      TEXT_BUTTON_1  = 'Sim'
      TEXT_BUTTON_2  = 'Não'
      DEFAULT_BUTTON = '2'
    IMPORTING
      ANSWER         = lv_pop_answer
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

ENDFORM.                    " F_POPUP_REPROVA

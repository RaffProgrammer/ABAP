*Transofrmar pdf, salvar no pc e mandar por email*

FUNCTION z_sd_emite_recibo.
*"----------------------------------------------------------------------
""Local Interface:
*"  IMPORTING
*"     VALUE(P_EMAIL) TYPE  CHAR200 OPTIONAL
*"     VALUE(P_BASE64) TYPE  STRING OPTIONAL
*"     VALUE(P_PDF_LOCAL) TYPE  STRING OPTIONAL
*"     VALUE(P_LDEST) TYPE  RSPOPNAME OPTIONAL
*"     VALUE(P_NOME_ARQUIVO) TYPE  CHAR200 OPTIONAL
*"----------------------------------------------------------------------
----------------------------------------------------------------------
Variáveis *
---------------------------------------------------------------------
DATA: lv_xstring TYPE xstring,
lv_len TYPE i,
lv_spool_id TYPE tsp01-rqident,
lt_content TYPE STANDARD TABLE OF solix,
lv_spoolid TYPE rspoid,
lv_titleline TYPE tsp01-rqtitle.

"Uso para envio do Email
DATA: doc_size TYPE so_obj_len,
doc_otf  TYPE STANDARD TABLE OF soli  WITH HEADER LINE, "#EC *
doc_hnd  TYPE STANDARD TABLE OF soli  WITH HEADER LINE, "#EC *
doc_hexa TYPE STANDARD TABLE OF solix WITH HEADER LINE, "#EC *
doc_data TYPE sodocchgi1,
doc_sndr LIKE soextreci1-receiver,
doc_sdty LIKE soextreci1-adr_typ,
doc_pack TYPE STANDARD TABLE OF sopcklsti1 WITH HEADER LINE, "#EC *
doc_head TYPE STANDARD TABLE OF solisti1   WITH HEADER LINE, "#EC *
doc_text TYPE STANDARD TABLE OF solisti1   WITH HEADER LINE, "#EC *
doc_rece TYPE STANDARD TABLE OF somlreci1  WITH HEADER LINE, "#EC *
doc_tbln LIKE sy-tabix.

"---

CHECK p_base64 IS NOT INITIAL.

CLEAR: lv_xstring.
REFRESH lt_content.

"Converte Base64 to Xstring
CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
EXPORTING
input  = p_base64
IMPORTING
output = lv_xstring.

"Converte conteúdo em tabela binaria
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
EXPORTING
buffer = lv_xstring
IMPORTING
output_length = lv_len
TABLES
binary_tab = lt_content.

CALL METHOD cl_bcs_convert=>xstring_to_solix
EXPORTING
iv_xstring = lv_xstring
RECEIVING
et_solix   = lt_content.

lv_len = xstrlen( lv_xstring ).

"---

IF p_pdf_local IS NOT INITIAL. "Faz o download do PDF

" Save file locally
CALL METHOD cl_gui_frontend_services=>gui_download
EXPORTING
bin_filesize = lv_len
filename     = p_pdf_local
filetype     = 'BIN'
CHANGING
data_tab     = lt_content.

ENDIF.

IF p_ldest IS NOT INITIAL.

lv_titleline = p_nome_arquivo.

CALL FUNCTION 'ADS_CREATE_PDF_SPOOLJOB'
EXPORTING
dest              = p_ldest
pages             = 10
pdf_data          = lv_xstring
immediate_print   = 'X'
titleline         = lv_titleline
receiver          = sy-uname
IMPORTING
spoolid           = lv_spoolid
EXCEPTIONS
no_data           = 1
not_pdf           = 2
wrong_devtype     = 3
operation_failed  = 4
cannot_write_file = 5
device_missing    = 6
no_such_device    = 7
OTHERS            = 8.
IF sy-subrc <> 0.
MESSAGE 'Erro ao realizar a impressão' TYPE 'E'.
ENDIF.

ENDIF.

IF p_email IS NOT INITIAL. "Envia PDF por email

Cabeçalho da Mensagem
doc_data-obj_name = 'EMAIL'.
doc_data-obj_langu = sy-langu.
doc_data-sensitivty = 'O'. "P F O G E
doc_data-obj_prio = '3'.
doc_data-priority   = '3'.
doc_data-free_del   = 'X'.
doc_data-doc_size   = lv_len.

Assunto do email
CONCATENATE 'Anexo Recibo ref. ao Documento nº' p_nome_arquivo INTO doc_data-obj_descr SEPARATED BY space.

Email Externo (Remetente)
doc_sndr = 'saint-gobain@saint-gobain.com'.
doc_sdty = 'INT'.

Corpo do Email e substituição 
doc_text-line = 'Prezado'.
APPEND doc_text.

Corpo do Email e substituição 
doc_text-line = ' '.
APPEND doc_text.

Corpo do Email e substituição
doc_text-line = 'Segue em anexo Recibo conforme dados abaixo:'.
APPEND doc_text.

Corpo do Email e substituição 
CONCATENATE 'Documento: ' p_nome_arquivo INTO doc_text-line SEPARATED BY space.
APPEND doc_text.

Corpo do Email e substituição
doc_text-line = 'Favor imprimir e entregar ao transportador.'.
APPEND doc_text.

Informações do Conteúdo do mail (Corpo do Email)
CLEAR doc_pack.
REFRESH doc_pack.
DESCRIBE TABLE doc_text LINES doc_tbln.
doc_pack-head_start = 1.
doc_pack-head_num = 1.
doc_pack-body_start = 1.
doc_pack-body_num = doc_tbln.
doc_pack-doc_type = 'RAW'.
APPEND doc_pack.

Informações do arquivo anexo
REFRESH doc_head.
CONCATENATE p_nome_arquivo '.PDF' INTO doc_head.
APPEND doc_head.

Informações do Conteúdo do mail (Anexo)
CLEAR doc_pack.
DESCRIBE TABLE doc_hexa LINES doc_tbln.
doc_pack-transf_bin = 'X'.
doc_pack-head_start = 1.
doc_pack-head_num = 0.
doc_pack-body_start = 1.
doc_pack-body_num = doc_tbln.
doc_pack-doc_type = 'PDF'.
doc_pack-obj_name = 0001.
doc_pack-obj_descr = doc_head.
doc_pack-doc_size = lv_len.
APPEND doc_pack.

Destinatário
REFRESH doc_rece.
doc_rece-receiver = p_email.
doc_rece-rec_type = 'U'.
doc_rece-express = 'X'.
doc_rece-notif_read = 'X'.
doc_rece-notif_ndel = 'X'.
APPEND doc_rece.

Envio do Email
CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
EXPORTING
document_data = doc_data
put_in_outbox = 'X'
sender_address = doc_sndr
sender_address_type = doc_sdty
commit_work = 'X'
TABLES
packing_list = doc_pack[]
object_header = doc_head[]
contents_txt = doc_text[]
contents_hex = doc_hexa[]
receivers = doc_rece[]
EXCEPTIONS
too_many_receivers = 1
document_not_sent = 2
document_type_not_exist = 3
operation_no_authorization = 4
parameter_error = 5
x_error = 6
enqueue_error = 7
OTHERS = 8.
IF sy-subrc <> 0.
EXIT.
ENDIF.
ENDIF.

ENDFUNCTION.

CLASS zcl_ext_email_utilities DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES:
      BEGIN OF ts_mail_recipient,
        address TYPE cl_bcs_mail_message=>ty_address,
        is_cc   TYPE cl_bcs_mail_message=>ty_copy,
        is_bcc  TYPE cl_bcs_mail_message=>ty_copy,
      END OF ts_mail_recipient.
    TYPES:
      BEGIN OF ts_mail_attachment,
        content_binary TYPE xstring,                               " For image/png or application/pdf
        content_text   TYPE string,                                " For text/plain
        content_type   TYPE cl_bcs_mail_bodypart=>ty_content_type, " i.e.: image/png or application/pdf or text/plain
        filename       TYPE string,
      END OF ts_mail_attachment.
    TYPES:
      BEGIN OF ts_mail_body,
        content      TYPE string,
        content_type TYPE cl_bcs_mail_bodypart=>ty_content_type,
        newline      TYPE abap_bool,
      END OF ts_mail_body.
    TYPES:
      BEGIN OF ts_table_column_text,
        fieldname TYPE string,
        col_text  TYPE string,
      END OF ts_table_column_text.
    TYPES:
      BEGIN OF ts_zip_content,
        filename     TYPE string,
        contents_txt TYPE string,
        codepage     TYPE abap_encoding,
        contents_bin TYPE xstring,
      END OF ts_zip_content.
*    TYPES: BEGIN OF ts_param_value ,
*             param TYPE string ,
*             value TYPE string ,
*           END OF ts_param_value .
*
*    TYPES: BEGIN OF ts_param_table ,
*             param TYPE string ,
*             value TYPE STANDARD TABLE OF any ,
*           END OF ts_param_table .
    TYPES tt_mail_recipient    TYPE TABLE OF ts_mail_recipient WITH EMPTY KEY.
    TYPES tt_mail_attachment   TYPE TABLE OF ts_mail_attachment WITH EMPTY KEY.
    TYPES tt_mail_body         TYPE TABLE OF ts_mail_body WITH EMPTY KEY.
    TYPES tt_table_column_text TYPE TABLE OF ts_table_column_text WITH KEY fieldname.
    TYPES tt_zip_content       TYPE TABLE OF ts_zip_content WITH EMPTY KEY.

    CONSTANTS:
      BEGIN OF c_attachment_content_type,
        image_png   TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'image/png',
        pdf         TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'application/pdf',
        xml         TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'application/xml',
        text_plain  TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'text/plain',
        text_html   TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'text/html',
        spreadsheet TYPE cl_bcs_mail_bodypart=>ty_content_type
                    VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        csv         TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'text/csv',
      END OF c_attachment_content_type.
    CONSTANTS c_prd_sysid TYPE syst-sysid VALUE 'GSP' ##NO_TEXT.
    CONSTANTS:
      BEGIN OF c_domain,
        prd      TYPE string VALUE '@pttgcgroup.com',
        dev      TYPE string VALUE '@dev-pttgcgroup.com',
        after_at TYPE string VALUE '@.+',
      END OF c_domain.

    CLASS-METHODS create_instance
      RETURNING VALUE(ro_mail) TYPE REF TO zcl_ext_email_utilities.

    CLASS-METHODS replace_var_with_data
      IMPORTING iw_data TYPE any
      CHANGING  cv_text TYPE string.

    CLASS-METHODS replace_hmlt_tr_tag_with_data
      IMPORTING it_data      TYPE ANY TABLE
                iv_elemid_tr TYPE any DEFAULT 'ITEMS'
      CHANGING  cv_text      TYPE string.

    METHODS get_email_template_instance
      IMPORTING iv_template_id           TYPE zcl_t2_smtg_email_api=>ty_smtg_tmpl_id
                is_email_template        TYPE zcl_t2_smtg_email_api=>ty_gs_email_template OPTIONAL
      RETURNING VALUE(ro_email_template) TYPE REF TO zcl_t2_smtg_email_api.

    METHODS get_email_instance
      RETURNING VALUE(ro_email) TYPE REF TO cl_bcs_mail_message.

    "! <p class="shorttext synchronized"></p>
    "!
    "! @parameter iv_address          | <p class="shorttext synchronized">Not used (Default by system)</p>
    "! @parameter iv_sender_address   | <p class="shorttext synchronized"></p>
    "! @parameter iv_subject          | <p class="shorttext synchronized"></p>
    "! @parameter it_recipient        | <p class="shorttext synchronized"></p>
    "! @parameter it_mail_attachment  | <p class="shorttext synchronized"></p>
    "! @parameter iv_body             | <p class="shorttext synchronized"></p>
    "! @parameter it_body             | <p class="shorttext synchronized"></p>
    "! @parameter iv_send_async       | <p class="shorttext synchronized"></p>
    "! @parameter iv_commit_work      | <p class="shorttext synchronized"></p>
    "! @parameter iv_set_background   | <p class="shorttext synchronized"></p>
    "! @parameter iv_encoding         | <p class="shorttext synchronized"></p>
    "! @parameter iv_with_email_templ | <p class="shorttext synchronized"></p>
    "! @parameter io_email_template   | <p class="shorttext synchronized"></p>
    "! @parameter iv_template_id      | <p class="shorttext synchronized"></p>
    "! @parameter is_email_template   | <p class="shorttext synchronized"></p>
    "! @parameter iv_language         | <p class="shorttext synchronized"></p>
    "! @parameter it_data_key         | <p class="shorttext synchronized"></p>
    "! @parameter et_status           | <p class="shorttext synchronized"></p>
    "! @parameter ev_mail_status      | <p class="shorttext synchronized"></p>
    "! @parameter ev_msg              | <p class="shorttext synchronized"></p>
    "! @parameter ev_msg_longtext     | <p class="shorttext synchronized"></p>
    METHODS send_email
      IMPORTING iv_address          TYPE cl_bcs_mail_message=>ty_address             OPTIONAL
                iv_sender_address   TYPE cl_bcs_mail_message=>ty_address             OPTIONAL
                iv_subject          TYPE cl_bcs_mail_message=>ty_subject             OPTIONAL
                it_recipient        TYPE tt_mail_recipient                           OPTIONAL
                it_mail_attachment  TYPE tt_mail_attachment                          OPTIONAL
                iv_body             TYPE string                                      OPTIONAL
                it_body             TYPE tt_mail_body                                OPTIONAL
                iv_send_async       TYPE abap_bool                                   DEFAULT abap_true
                iv_commit_work      TYPE abap_bool                                   DEFAULT space
                iv_set_background   TYPE abap_bool                                   DEFAULT space
                iv_encoding         TYPE abap_encoding                               OPTIONAL
                iv_with_email_templ TYPE abap_bool                                   DEFAULT space
                io_email_template   TYPE REF TO zcl_t2_smtg_email_api                OPTIONAL
                iv_template_id      TYPE zcl_t2_smtg_email_api=>ty_smtg_tmpl_id      OPTIONAL
                is_email_template   TYPE zcl_t2_smtg_email_api=>ty_gs_email_template OPTIONAL
                iv_language         TYPE cl_abap_context_info=>ty_language_key       OPTIONAL
                it_data_key         TYPE zcl_t2_smtg_email_api=>ty_gt_data_key       OPTIONAL
      EXPORTING et_status           TYPE cl_bcs_mail_message=>tyt_status
                ev_mail_status      TYPE cl_bcs_mail_message=>ty_status
                ev_msg              TYPE string
                ev_msg_longtext     TYPE string.

    METHODS set_itab_to_html_styles
      IMPORTING iv_table_id    TYPE string OPTIONAL
                iv_table_class TYPE string OPTIONAL
                iv_table_style TYPE string DEFAULT 'width: 80%; border: #999 1px solid; border-collapse: collapse;'
                iv_tr_class    TYPE string OPTIONAL
                iv_tr_style    TYPE string OPTIONAL
                iv_th_class    TYPE string OPTIONAL
                iv_th_style    TYPE string DEFAULT 'font-weight: bold; border: #999 1px solid; background: #eee;'
                iv_td_class    TYPE string OPTIONAL
                iv_td_style    TYPE string DEFAULT 'border: #999 1px solid;'.

    METHODS convert_itab_to_html
      IMPORTING it_table        TYPE ANY TABLE
                it_mapping_name TYPE tt_table_column_text OPTIONAL
      RETURNING VALUE(rv_value) TYPE string.

    METHODS create_zip_attachment_contents
      IMPORTING it_contents       TYPE tt_zip_content
      RETURNING VALUE(rv_xstring) TYPE xstring.

    "! <p class="shorttext synchronized">set placeholder</p>
    METHODS set_placeholder
      IMPORTING iv_placeholder_name  TYPE string
                iv_placeholder_value TYPE string.

    "! <p class="shorttext synchronized">set Itab Placeholder</p>
    METHODS set_placeholder_itab
      IMPORTING iv_placeholder_name  TYPE string
                it_placeholder_value TYPE STANDARD TABLE
                it_column_text       TYPE tt_table_column_text OPTIONAL.

    METHODS get_email_template_subj_body
      IMPORTING iv_template_id    TYPE zcl_t2_smtg_email_api=>ty_smtg_tmpl_id
                io_email_template TYPE REF TO zcl_t2_smtg_email_api                OPTIONAL
                is_email_template TYPE zcl_t2_smtg_email_api=>ty_gs_email_template OPTIONAL
                iv_language       TYPE cl_abap_context_info=>ty_language_key       OPTIONAL
                it_data_key       TYPE zcl_t2_smtg_email_api=>ty_gt_data_key       OPTIONAL
                iv_det            TYPE abap_bool                                   DEFAULT abap_true
      EXPORTING ev_subject        TYPE string
                ev_body_html      TYPE string
                ev_body_text      TYPE string.

    METHODS replace_var_with_t_data_key
      IMPORTING it_data_key TYPE zcl_t2_smtg_email_api=>ty_gt_data_key
      CHANGING  cv_string   TYPE string.

    METHODS get_email_template
      IMPORTING iv_template_id TYPE zcl_t2_smtg_email_api=>ty_smtg_tmpl_id
                iv_language    TYPE cl_abap_context_info=>ty_language_key DEFAULT sy-langu
      EXPORTING ev_subject     TYPE cl_bcs_mail_message=>ty_subject
                ev_body        TYPE string
                ev_body_txt    TYPE string.

    METHODS det_sender
      IMPORTING
        iv_system_id TYPE sysysid DEFAULT sy-sysid
      CHANGING
        cv_sender    TYPE string.

    METHODS det_subject
      CHANGING cv_subject TYPE string.

    CLASS-METHODS replace_to_non_prd_domain
      IMPORTING
        iv_address        TYPE clike
        iv_system_id      TYPE sysysid DEFAULT sy-sysid
      RETURNING
        VALUE(rv_address) TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS find_text_position
      IMPORTING iv_text    TYPE any
                iv_findtxt TYPE any
                iv_spos    TYPE i OPTIONAL     " Start position
      EXPORTING ev_spos    TYPE i
                ev_epos    TYPE i
                ev_offset  TYPE i.

    DATA mo_mail        TYPE REF TO cl_bcs_mail_message.
    DATA mt_data_key    TYPE zcl_t2_smtg_email_api=>ty_gt_data_key.
    DATA mv_cellpadding TYPE i                                     VALUE 0 ##NO_TEXT.
    DATA mv_cellspacing TYPE i                                     VALUE 0 ##NO_TEXT.
    DATA mv_table_class TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_table_id    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_table_style TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_tr_class    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_tr_style    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_th_class    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_th_style    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_td_class    TYPE string                                VALUE '' ##NO_TEXT.
    DATA mv_td_style    TYPE string                                VALUE '' ##NO_TEXT.

    METHODS _create_new_email_instance.

    METHODS _set_background_process
      IMPORTING iv_phase_modify TYPE abap_bool DEFAULT space.

    METHODS _get_description
      IMPORTING it_table        TYPE ANY TABLE
                it_mapping_name TYPE tt_table_column_text OPTIONAL
      RETURNING VALUE(rt_table) TYPE tt_table_column_text.

    METHODS _title
      IMPORTING it_desc         TYPE tt_table_column_text
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _table_params
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _tr_params
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _th_params
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _td_params
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _value_to_string
      IMPORTING iv_val          TYPE any
      RETURNING VALUE(rv_value) TYPE string.

    METHODS _footer
      RETURNING VALUE(rv_value) TYPE string.

    "! <p class="shorttext synchronized">Replace placeholder than CDS</p>
    METHODS _replace_placeholder
      IMPORTING iv_replace_string TYPE string
      RETURNING VALUE(rv_value)   TYPE string.

    CLASS-METHODS _convert_datatype_to_string
      IMPORTING iv_data TYPE any
                iv_type TYPE abap_typekind
      EXPORTING ev_data TYPE string.
ENDCLASS.



CLASS zcl_ext_email_utilities IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    FINAL(lo_test) = zcl_ext_email_utilities=>create_instance( ).

    DATA lt_table_test TYPE TABLE OF i_paymentterms WITH EMPTY KEY.

    lo_test->convert_itab_to_html( it_table = lt_table_test ).
  ENDMETHOD.


  METHOD create_instance.
    RETURN NEW #( ).
  ENDMETHOD.


  METHOD get_email_instance.
    _create_new_email_instance( ).

    RETURN mo_mail.
  ENDMETHOD.


  METHOD get_email_template_instance.
    TRY.
        RETURN zcl_t2_smtg_email_api=>get_instance( iv_template_id    = iv_template_id
                                                    is_email_template = is_email_template ).
      CATCH zcx_t2_smtg_email_common.
    ENDTRY.
  ENDMETHOD.


  METHOD send_email.
    DATA lx_mail            TYPE REF TO cx_bcs_mail.
    DATA lo_email_template  TYPE REF TO zcl_t2_smtg_email_api.
    DATA lo_mail_body       TYPE REF TO cl_bcs_mail_textpart.
    DATA lo_mail_binarypart TYPE REF TO cl_bcs_mail_binarypart.
    DATA lo_mail_textpart   TYPE REF TO cl_bcs_mail_textpart.
    DATA lv_binary_content  TYPE xstring.
    DATA lv_text_content    TYPE string.
    DATA lv_body_html       TYPE abap_bool.
    DATA lv_body_plain      TYPE abap_bool.
    DATA lv_set_email_templ TYPE abap_bool.

    CLEAR: et_status,
           ev_mail_status,
           ev_msg,
           ev_msg_longtext.

    TRY.
        _create_new_email_instance( ).

        IF mo_mail IS NOT BOUND.
          ev_mail_status  = 'E'.      " Error
          ev_msg          = 'MO_MAIL Instance has not beed created'.
          ev_msg_longtext = 'MO_MAIL Instance has not beed created'.
          RETURN.
        ENDIF.

        " Email To...
        IF iv_sender_address IS NOT INITIAL.
          " mo_mail->set_sender( iv_address = iv_sender_address ).
        ENDIF.

        " Add recipient...
        LOOP AT it_recipient INTO DATA(ls_recipient) WHERE address IS NOT INITIAL.
          TRY.
              mo_mail->add_recipient( iv_address = ls_recipient-address
                                      iv_copy    = COND #( WHEN ls_recipient-is_cc IS NOT INITIAL THEN
                                                             ls_recipient-is_cc
                                                           WHEN ls_recipient-is_bcc IS NOT INITIAL THEN
                                                             ls_recipient-is_bcc
                                                           ELSE
                                                             cl_bcs_mail_message=>to ) ).
            CATCH cx_bcs_mail.
          ENDTRY.
        ENDLOOP.

        " Email Attachment...
        " Example :
        "   1. https://help.sap.com/docs/btp/sap-business-technology-platform/integration-and-connectivity-sending-mails-using-smtp
        "   2. https://software-heroes.com/en/blog/abap-rap-send-mail
        LOOP AT it_mail_attachment INTO DATA(ls_mail_attachment) WHERE filename IS NOT INITIAL.
          CLEAR: lo_mail_binarypart,
                 lo_mail_textpart.

          CASE |{ ls_mail_attachment-content_type CASE = LOWER }|.
            WHEN c_attachment_content_type-image_png
              OR c_attachment_content_type-pdf
              OR c_attachment_content_type-spreadsheet.
              IF ls_mail_attachment-content_binary IS NOT INITIAL.
                lv_binary_content = ls_mail_attachment-content_binary.
              ELSEIF ls_mail_attachment-content_text IS NOT INITIAL.
                lv_binary_content = /ui2/cl_json=>string_to_raw( iv_string   = ls_mail_attachment-content_text
                                                                 iv_encoding = iv_encoding ).
              ENDIF.

              lo_mail_binarypart = cl_bcs_mail_binarypart=>create_instance(
                                       iv_content      = lv_binary_content
                                       iv_content_type = |{ ls_mail_attachment-content_type CASE = LOWER }|
                                       iv_filename     = ls_mail_attachment-filename ).
              IF lo_mail_binarypart IS BOUND.
                TRY.
                    mo_mail->add_attachment( io_attachment = lo_mail_binarypart ).
                  CATCH cx_bcs_mail.
                ENDTRY.
              ENDIF.
            WHEN c_attachment_content_type-text_plain
              OR c_attachment_content_type-text_html.
              IF ls_mail_attachment-content_binary IS NOT INITIAL.
                lv_text_content = /ui2/cl_json=>raw_to_string( iv_xstring  = ls_mail_attachment-content_binary
                                                               iv_encoding = iv_encoding ).
              ELSEIF ls_mail_attachment-content_text IS NOT INITIAL.
                lv_text_content = ls_mail_attachment-content_text.
              ENDIF.

              lo_mail_textpart = cl_bcs_mail_textpart=>create_instance(
                                     iv_content      = lv_text_content
                                     iv_content_type = |{ ls_mail_attachment-content_type CASE = LOWER }|
                                     iv_filename     = ls_mail_attachment-filename ).
              IF lo_mail_textpart IS BOUND.
                TRY.
                    mo_mail->add_attachment( io_attachment = lo_mail_textpart ).
                  CATCH cx_bcs_mail.
                ENDTRY.
              ENDIF.
            WHEN OTHERS.
              CONTINUE.
          ENDCASE.
        ENDLOOP.

        IF iv_with_email_templ IS NOT INITIAL.
          lo_email_template = COND #( WHEN io_email_template IS BOUND
                                      THEN io_email_template
                                      ELSE get_email_template_instance( iv_template_id    = iv_template_id
                                                                        is_email_template = is_email_template ) ).

          IF lo_email_template IS BOUND.
            TRY.
                DATA(lv_language) = COND #( WHEN iv_language IS NOT INITIAL
                                            THEN iv_language
                                            ELSE cl_abap_context_info=>get_user_language_abap_format( ) ).
              CATCH cx_abap_context_info_error.
            ENDTRY.

            TRY.
                lo_email_template->render( EXPORTING iv_language  = COND #( WHEN lv_language IS NOT INITIAL
                                                                            THEN lv_language
                                                                            ELSE sy-langu )
                                                     it_data_key  = it_data_key
                                           IMPORTING ev_subject   = DATA(lv_subject_templ)
                                                     ev_body_html = DATA(lv_body_html_templ)
                                                     ev_body_text = DATA(lv_body_text_templ) ).

                lv_set_email_templ = abap_true.

                TRY.
                    " Title of Email...
                    mo_mail->set_subject( iv_subject = CONV #( lv_subject_templ ) ).

                    " Email Body...
                    IF lv_body_html_templ IS NOT INITIAL.
                      lo_mail_body = cl_bcs_mail_textpart=>create_text_html( lv_body_html_templ ).
                    ELSE.
                      lo_mail_body = cl_bcs_mail_textpart=>create_text_plain( lv_body_text_templ ).
                    ENDIF.

                    mo_mail->set_main( io_main = lo_mail_body ).
                  CATCH cx_bcs_mail.
                ENDTRY.
              CATCH zcx_t2_smtg_email_common.
            ENDTRY.
          ENDIF.
        ENDIF.

        IF lv_set_email_templ IS INITIAL.
          " Title of Email...
          mo_mail->set_subject( iv_subject = iv_subject ).

          " Email Body...
          CLEAR: lv_body_html,
                 lv_body_plain,
                 lv_text_content.

          IF iv_body IS NOT INITIAL. " IF IV_BODY = HTML String

            lv_body_html = abap_true.
            lv_text_content = iv_body.

          ELSE.
            LOOP AT it_body INTO DATA(ls_body) WHERE    content IS NOT INITIAL
                                                     OR newline IS NOT INITIAL.
              DATA(lv_newline) = COND #( WHEN to_lower( ls_body-content_type ) = c_attachment_content_type-text_html
                                         THEN `<br>`
                                         ELSE `\\n` ).

              IF ls_body-content IS NOT INITIAL.
                IF lv_text_content IS INITIAL.
                  lv_text_content = ls_body-content.
                ELSE.
                  IF ls_body-newline IS INITIAL.
                    lv_text_content = |{ lv_text_content }{ ls_body-content }|.
                  ELSE.
                    lv_text_content = |{ lv_text_content }{ lv_newline }{ ls_body-content }|.
                  ENDIF.
                ENDIF.
              ELSEIF ls_body-newline IS NOT INITIAL.
                IF lv_text_content IS INITIAL.
                  lv_text_content = lv_newline.
                ELSE.
                  lv_text_content = |{ lv_text_content }{ lv_newline }|.
                ENDIF.
              ENDIF.
            ENDLOOP.

            " Body of Email...
            READ TABLE it_body INTO ls_body INDEX 1.
            IF sy-subrc = 0.
              CASE |{ ls_body-content_type CASE = LOWER }|.
                WHEN c_attachment_content_type-text_html.
                  lv_body_html = abap_true.
                WHEN OTHERS.
                  lv_body_plain = abap_true.
              ENDCASE.
            ELSE.
              lv_body_html  = space.
              lv_body_plain = abap_true.
            ENDIF.
          ENDIF.

          CASE abap_true.
            WHEN lv_body_html.
              lo_mail_body = cl_bcs_mail_textpart=>create_text_html( lv_text_content ).
            WHEN lv_body_plain.
              lo_mail_body = cl_bcs_mail_textpart=>create_text_plain( lv_text_content ).
          ENDCASE.

          IF lo_mail_body IS BOUND.
            TRY.
                mo_mail->set_main( io_main = lo_mail_body ).
              CATCH cx_bcs_mail.
            ENDTRY.
          ENDIF.
        ENDIF.

        " Is Background Process (bgPF) ?
        IF iv_set_background IS NOT INITIAL.
          _set_background_process( ).
        ENDIF.

        " Send Email...
        IF iv_send_async IS NOT INITIAL.
          mo_mail->send_async( ).

          " COMMIT WORK is mandatory otherwise the background process will not start and the email remain in status Waiting.
          IF iv_commit_work IS NOT INITIAL.
            COMMIT WORK.
          ENDIF.
        ELSE.
          mo_mail->send( IMPORTING et_status      = et_status
                                   ev_mail_status = ev_mail_status ).

          IF iv_commit_work IS NOT INITIAL.
            COMMIT WORK.
          ENDIF.
        ENDIF.

        ev_mail_status = COND #( WHEN ev_mail_status IS NOT INITIAL THEN ev_mail_status ELSE 'S' ).
        ev_msg         = 'Email was sent successfully'.
      CATCH cx_bcs_mail INTO lx_mail.
        ev_mail_status  = 'E'.      " Error
        ev_msg          = lx_mail->get_text( ).
        ev_msg_longtext = lx_mail->get_longtext( ).
    ENDTRY.
  ENDMETHOD.


  METHOD convert_itab_to_html.
*      DATA(lt_descr) = _get_description( it_table        = it_table
*                                         it_mapping_name = it_mapping_name ).

    DATA(lt_descr) = COND tt_table_column_text( WHEN it_mapping_name IS NOT INITIAL
                                                THEN it_mapping_name
                                                ELSE _get_description( it_table        = it_table
                                                                       it_mapping_name = it_mapping_name ) ).

    DATA(lv_tr) = _tr_params( ).
    DATA(lv_td) = _td_params( ).

    DATA lv_row TYPE string VALUE ''.

    LOOP AT it_table ASSIGNING FIELD-SYMBOL(<ls_row>).
      CLEAR lv_row.

      LOOP AT lt_descr ASSIGNING FIELD-SYMBOL(<ls_struct>).
        ASSIGN COMPONENT <ls_struct>-fieldname OF STRUCTURE <ls_row> TO FIELD-SYMBOL(<lv_value>).
        lv_row = |{ lv_row }  <td{ lv_td }>{ _value_to_string( iv_val = <lv_value> ) }</td>|.
      ENDLOOP.

      rv_value = |{ rv_value } <tr{ lv_tr }>{ lv_row } </tr>|.
    ENDLOOP.

    rv_value = |{ _title( lt_descr ) }{ rv_value }{ _footer( ) }|.
  ENDMETHOD.


  METHOD create_zip_attachment_contents.
    DATA lv_xstring TYPE xstring.

    DATA(lo_zippers) = NEW cl_abap_zip( ). "" ZIP class Declaration

    LOOP AT it_contents INTO FINAL(ls_content) WHERE    contents_bin IS NOT INITIAL
                                                     OR contents_txt IS NOT INITIAL.
      CLEAR lv_xstring.

      IF ls_content-contents_bin IS NOT INITIAL.
        lv_xstring = ls_content-contents_bin.
      ELSEIF ls_content-contents_txt IS NOT INITIAL.
        lv_xstring = /ui2/cl_json=>string_to_raw( iv_string   = ls_content-contents_txt
                                                  iv_encoding = ls_content-codepage ).
      ENDIF.

      IF lv_xstring IS INITIAL.
        CONTINUE.
      ENDIF.

      " Xstring to binary
      " add file to zip
      lo_zippers->add( name    = ls_content-filename
                       content = lv_xstring ).
    ENDLOOP.

    " save zip
    rv_xstring = lo_zippers->save( ).
  ENDMETHOD.


  METHOD set_itab_to_html_styles.
    IF iv_table_id IS SUPPLIED.
      mv_table_id = iv_table_id.
    ENDIF.
    IF iv_table_class IS SUPPLIED.
      mv_table_class = iv_table_class.
    ENDIF.
    " IF table_style IS SUPPLIED.
    mv_table_style = iv_table_style.
    " ENDIF.

    IF iv_tr_class IS SUPPLIED.
      mv_tr_class = iv_tr_class.
    ENDIF.
    IF iv_tr_style IS SUPPLIED.
      mv_tr_style = iv_tr_style.
    ENDIF.

    IF iv_th_class IS SUPPLIED.
      mv_th_class = iv_th_class.
    ENDIF.
    " IF th_style IS SUPPLIED.
    mv_th_style = iv_th_style.
    " ENDIF.

    IF iv_td_class IS SUPPLIED.
      mv_td_class = iv_td_class.
    ENDIF.
    " IF td_style IS SUPPLIED.
    mv_td_style = iv_td_style.
    " ENDIF.
  ENDMETHOD.


  METHOD _set_background_process.
    CASE iv_phase_modify.
      WHEN abap_true.
        " Switch to modify phase
        cl_abap_tx=>modify( ).
      WHEN OTHERS.
        " Switch to save phase
        cl_abap_tx=>save( ).
    ENDCASE.
  ENDMETHOD.


  METHOD _create_new_email_instance.
    IF mo_mail IS BOUND.
      RETURN.
    ENDIF.

    TRY.
        mo_mail = cl_bcs_mail_message=>create_instance( ).
      CATCH cx_bcs_mail.
    ENDTRY.
  ENDMETHOD.


  METHOD _footer.
    rv_value = |</table>|.
  ENDMETHOD.


  METHOD _table_params.
    IF mv_table_id IS NOT INITIAL.
      rv_value = |{ rv_value } id="{ mv_table_id }"|.
    ENDIF.

    IF mv_table_class IS NOT INITIAL.
      rv_value = |{ rv_value } class="{ mv_table_class }"|.
    ENDIF.

    IF mv_table_style IS NOT INITIAL.
      rv_value = |{ rv_value } style="{ mv_table_style }"|.
    ENDIF.
  ENDMETHOD.


  METHOD _td_params.
    IF mv_td_class IS NOT INITIAL.
      rv_value = |{ rv_value } class="{ mv_td_class }"|.
    ENDIF.

    IF mv_td_style IS NOT INITIAL.
      rv_value = |{ rv_value } style="{ mv_td_style }"|.
    ENDIF.
  ENDMETHOD.


  METHOD _th_params.
    IF mv_th_class IS NOT INITIAL.
      rv_value = |{ rv_value } class="{ mv_th_class }"|.
    ENDIF.

    IF mv_th_style IS NOT INITIAL.
      rv_value = |{ rv_value } style="{ mv_th_style }"|.
    ENDIF.
  ENDMETHOD.


  METHOD _get_description.
    DATA(lo_description) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( it_table ) ).
    DATA(lt_components) = CAST cl_abap_structdescr( lo_description->get_table_line_type( ) )->get_components( ).

    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<ls_component>).
      TRY.
          DATA(ls_mapping_name) = it_mapping_name[ fieldname = <ls_component>-name ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR ls_mapping_name.
      ENDTRY.

      APPEND VALUE #( fieldname = <ls_component>-name
                      col_text  = COND #( WHEN ls_mapping_name-col_text IS NOT INITIAL
                                          THEN ls_mapping_name-col_text
                                          ELSE <ls_component>-name ) ) TO rt_table.
*                      description = COND #( WHEN ls_mapping_name-description IS NOT INITIAL
*                                            THEN ls_mapping_name-description
*                                            ELSE <component>-name ) ) TO rt_table.

    ENDLOOP.
  ENDMETHOD.


  METHOD _title.
    DATA(lv_th) = _th_params( ).

    LOOP AT it_desc ASSIGNING FIELD-SYMBOL(<ls_item>).
      rv_value = |{ rv_value }  <th{ lv_th }>{ <ls_item>-col_text }</th>|.
    ENDLOOP.

    rv_value = |<table{ _table_params( ) }> <tr{ _tr_params( ) }>{ rv_value } </tr>|.
  ENDMETHOD.


  METHOD _tr_params.
    IF mv_tr_class IS NOT INITIAL.
      rv_value = |{ rv_value } class="{ mv_tr_class }"|.
    ENDIF.

    IF mv_tr_style IS NOT INITIAL.
      rv_value = |{ rv_value } style="{ mv_tr_style }"|.
    ENDIF.
  ENDMETHOD.


  METHOD _value_to_string.
    rv_value = CONV string( iv_val ).
  ENDMETHOD.


  METHOD set_placeholder.
    APPEND VALUE #( name  = iv_placeholder_name
                    value = iv_placeholder_value )
           TO mt_data_key.
  ENDMETHOD.


  METHOD set_placeholder_itab.
    APPEND VALUE #( name  = iv_placeholder_name
                    " Convert ITAB to HTML. zcl_itab_to_html
                    value = convert_itab_to_html( it_table        = it_placeholder_value
                                                  it_mapping_name = it_column_text ) )
           TO mt_data_key.
  ENDMETHOD.


  METHOD get_email_template_subj_body.
    DATA lo_email_template TYPE REF TO zcl_t2_smtg_email_api.

    TRY.
        lo_email_template = COND #( WHEN io_email_template IS BOUND
                                    THEN io_email_template
                                    ELSE get_email_template_instance( iv_template_id    = iv_template_id
                                                                      is_email_template = is_email_template ) ).

        lo_email_template->render(
          EXPORTING iv_language  = COND #( WHEN iv_language IS NOT INITIAL
                                           THEN iv_language
                                           ELSE cl_abap_context_info=>get_user_language_abap_format( ) )
                    it_data_key  = it_data_key
          IMPORTING ev_subject   = ev_subject
                    ev_body_html = ev_body_html
                    ev_body_text = ev_body_text ).
        IF iv_det IS NOT INITIAL.
          det_subject( CHANGING cv_subject = ev_subject ).
        ENDIF.

        IF it_data_key IS NOT SUPPLIED.
          ev_subject   = _replace_placeholder( ev_subject ).
          ev_body_html = _replace_placeholder( ev_body_html ).
          ev_body_text = _replace_placeholder( ev_body_text ).
        ENDIF.

      CATCH zcx_t2_smtg_email_common.

      CATCH cx_abap_context_info_error.

    ENDTRY.
  ENDMETHOD.


  METHOD _replace_placeholder.
    rv_value = iv_replace_string.
    LOOP AT mt_data_key INTO DATA(ls_data_key).
      REPLACE ALL OCCURRENCES OF ls_data_key-name IN rv_value WITH ls_data_key-value.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_email_template.
    FREE: ev_subject,
          ev_body,
          ev_body_txt.
    TRY.
        DATA(lo_instance) = zcl_t2_smtg_email_template=>get( iv_id = CONV #( iv_template_id ) ).
        DATA(ls_tmpl_cont) = lo_instance->get_tmpl_cont( iv_langu = CONV #( iv_language ) ).

        " NOTE : NEED TO HAS IF NOT FOUND GET DEFAULT LANGU 'EN' ???????????
        " NOTE : NEED TO HAS IF NOT FOUND GET DEFAULT LANGU 'EN' ???????????
        " NOTE : NEED TO HAS IF NOT FOUND GET DEFAULT LANGU 'EN' ???????????

        ev_subject = ls_tmpl_cont-subject.
        ev_body = ls_tmpl_cont-body_html.
        ev_body_txt = ls_tmpl_cont-body_txt.
      CATCH zcx_t2_smtg_email_common.
        " Do Nothing
    ENDTRY.
  ENDMETHOD.


  METHOD replace_var_with_t_data_key.
    DATA lv_name TYPE string.

    DATA(lv_new_string) = cv_string.
    LOOP AT it_data_key ASSIGNING FIELD-SYMBOL(<ls_data_key>).
      CONCATENATE '{{' <ls_data_key>-name '}}' INTO lv_name.
      REPLACE ALL OCCURRENCES OF lv_name IN lv_new_string WITH <ls_data_key>-value.
    ENDLOOP.
    cv_string = lv_new_string.
  ENDMETHOD.


  METHOD det_sender.
    CHECK iv_system_id <> c_prd_sysid.
    FIND FIRST OCCURRENCE OF '@' IN cv_sender MATCH OFFSET DATA(lv_m_offset).
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.
    IF    cv_sender+lv_m_offset = c_domain-prd
    " Add condition for email that outside @pttgcgroup
       OR ( cv_sender+lv_m_offset <> c_domain-prd AND cv_sender+lv_m_offset <> c_domain-dev ).
      cv_sender = cv_sender(lv_m_offset) && c_domain-dev.
    ENDIF.
  ENDMETHOD.


  METHOD det_subject.
    CHECK sy-sysid <> c_prd_sysid.
    cv_subject = |[{ sy-sysid }{ sy-mandt }] { cv_subject }|.
  ENDMETHOD.


  METHOD find_text_position.
    FIND iv_findtxt IN iv_text+iv_spos MATCH OFFSET DATA(lv_offset).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ev_spos   = lv_offset + iv_spos.
    ev_epos   = ev_spos + strlen( iv_findtxt ).
    ev_offset = ev_epos - ev_spos.
  ENDMETHOD.


  METHOD replace_hmlt_tr_tag_with_data.
    DATA lv_row_body  TYPE string.
    DATA lv_hmtl_1row TYPE string.

    find_text_position( EXPORTING iv_text    = cv_text
                                  iv_findtxt = |<tr id="{ iv_elemid_tr }">|
                        IMPORTING ev_spos    = DATA(lv_spos1)
                                  ev_epos    = DATA(lv_epos1) ).

    " Must found tag ITEM table to display item
    IF lv_spos1 IS INITIAL.
      RETURN.
    ENDIF.

    find_text_position( EXPORTING iv_text    = cv_text
                                  iv_findtxt = '</tr>'
                                  iv_spos    = lv_epos1
                        IMPORTING ev_epos    = DATA(lv_epos2) ).

    DATA(lv_offset) = lv_epos2 - lv_spos1.
    lv_hmtl_1row = cv_text+lv_spos1(lv_offset).

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<lfw_item>).
      lv_row_body = |{ lv_row_body } { lv_hmtl_1row }|.
      replace_var_with_data( EXPORTING iw_data = <lfw_item>
                             CHANGING  cv_text = lv_row_body ).
    ENDLOOP.

    REPLACE ALL OCCURRENCES OF lv_hmtl_1row IN cv_text WITH lv_row_body.
  ENDMETHOD.


  METHOD replace_var_with_data.
    DATA lv_name TYPE string.

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lt_replace_data) = VALUE zcl_t2_smtg_email_api=>ty_gt_data_key( ).

    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( iw_data ) ).
    IF lo_struct IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lv_new_string) = cv_text.
    DATA(lt_comp) = lo_struct->get_components( ).
    LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<lfw_comp>).
      ASSIGN COMPONENT <lfw_comp>-name OF STRUCTURE iw_data TO FIELD-SYMBOL(<lv_value>) ELSE UNASSIGN.
      IF <lv_value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      _convert_datatype_to_string( EXPORTING iv_data = <lv_value>
                                             iv_type = <lfw_comp>-type->type_kind
                                   IMPORTING ev_data = DATA(lv_data) ).

      CONCATENATE '{{' <lfw_comp>-name '}}' INTO lv_name.
      REPLACE ALL OCCURRENCES OF lv_name IN lv_new_string WITH lv_data.
    ENDLOOP.

    cv_text = lv_new_string.
  ENDMETHOD.


  METHOD replace_to_non_prd_domain.
    IF iv_system_id <> c_prd_sysid.

      rv_address = iv_address.
      REPLACE PCRE c_domain-after_at IN rv_address WITH c_domain-dev.
    ELSE.
      rv_address = iv_address.
    ENDIF.

  ENDMETHOD.


  METHOD _convert_datatype_to_string.
    TYPES lty_packed TYPE p LENGTH 16 DECIMALS 2.

    DATA(lv_data) = NEW string( iv_data ).

    CASE iv_type.
      WHEN cl_abap_typedescr=>typekind_date.
        ev_data = |{ CONV d( lv_data->* ) DATE = USER }|.
      WHEN cl_abap_typedescr=>typekind_time.
        ev_data = |{ CONV t( lv_data->* ) TIME = USER }|.
      WHEN cl_abap_typedescr=>typekind_num.
        ev_data = lv_data->*.
      WHEN cl_abap_typedescr=>typekind_float.
        ev_data = |{ CONV f( lv_data->* ) NUMBER = USER }|.
      WHEN cl_abap_typedescr=>typekind_decfloat
        OR cl_abap_typedescr=>typekind_decfloat16
        OR cl_abap_typedescr=>typekind_packed.
        ev_data = |{ CONV decfloat16( lv_data->* ) NUMBER = USER }|.
      WHEN cl_abap_typedescr=>typekind_decfloat34.
        ev_data = |{ CONV decfloat34( lv_data->* ) NUMBER = USER }|.
      WHEN cl_abap_typedescr=>typekind_packed.
        ev_data = |{ CONV lty_packed( lv_data->* ) NUMBER = USER }|.
      WHEN cl_abap_typedescr=>typekind_int
        OR cl_abap_typedescr=>typekind_int1
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int8.
        ev_data = |{ CONV i( lv_data->* ) NUMBER = USER }|.
      WHEN cl_abap_typedescr=>typekind_clike
        OR cl_abap_typedescr=>typekind_simple
        OR cl_abap_typedescr=>typekind_string
        OR cl_abap_typedescr=>typekind_csequence
        OR cl_abap_typedescr=>typekind_char.
        ev_data = lv_data->*.
      WHEN OTHERS.
        ev_data = lv_data->*.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

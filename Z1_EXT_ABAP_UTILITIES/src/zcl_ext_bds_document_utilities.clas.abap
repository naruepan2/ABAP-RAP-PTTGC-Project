CLASS zcl_ext_bds_document_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_parallel.

    TYPES ty_classname TYPE c LENGTH 30.

    CLASS-METHODS bds_get_file
      IMPORTING
        !iv_parallel       TYPE abap_bool                           DEFAULT space
        !iv_filename       TYPE zcl_t2_bds_document_get=>bds_compid
        !iv_classname      TYPE ty_classname                        DEFAULT 'ZPTTGC_FILE_TEMPLATE'
        !iv_classtype      TYPE zcl_t2_bds_document_get=>classtype  DEFAULT 'OT'
        !iv_object_key     TYPE zcl_t2_bds_document_get=>bds_typeid DEFAULT 'ZPTTGC_FILE_TEMPLATE'
        !iv_filetype       TYPE string                              DEFAULT '.xlsx'
      EXPORTING
        !et_file_content   TYPE zcl_t2_bds_document_get=>tt_bapicontent
        !ev_filename       TYPE string
        !ev_file_encodex64 TYPE string
        !ev_file_x_content TYPE xstring
        !ev_full_filename  TYPE zcl_t2_bds_document_get=>bds_compid
        !ev_mimetype       TYPE zcl_t2_bds_document_get=>bds_mimetp
      RAISING
        zcx_ext_general_error .

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES ty_parallel_action TYPE c LENGTH 20 .

    CONSTANTS : BEGIN OF c_parallel_action ,
                  bds_get_file TYPE ty_parallel_action VALUE 'BDS_GET_FILE',
                END OF c_parallel_action .
    CLASS-DATA mv_dummy TYPE string.
    DATA mv_parallel_action TYPE ty_parallel_action .

    DATA :
      BEGIN OF gs_bds_get_file_data ,
        BEGIN OF import ,
          iv_filename TYPE zcl_t2_bds_document_get=>bds_compid,
        END OF import ,
        BEGIN OF export ,
          et_file_content   TYPE zcl_t2_bds_document_get=>tt_bapicontent,
          ev_filename       TYPE string,
          ev_file_encodex64 TYPE string,
          ev_file_x_content TYPE xstring,
          ev_full_filename  TYPE zcl_t2_bds_document_get=>bds_compid,
          ev_mimetype       TYPE zcl_t2_bds_document_get=>bds_mimetp,
        END OF export ,
      END OF gs_bds_get_file_data .

ENDCLASS.



CLASS zcl_ext_bds_document_utilities IMPLEMENTATION.
  METHOD bds_get_file.

    IF iv_parallel IS NOT INITIAL.

      DATA lt_processes TYPE cl_abap_parallel=>t_in_inst_tab.

      DATA(lo_bds) = NEW zcl_ext_bds_document_utilities( ).
      lo_bds->mv_parallel_action    = c_parallel_action-bds_get_file.
      lo_bds->gs_bds_get_file_data-import = VALUE #( iv_filename = iv_filename ).

      INSERT lo_bds INTO TABLE lt_processes.
      NEW cl_abap_parallel( )->run_inst( EXPORTING p_in_tab  = lt_processes
                                         IMPORTING p_out_tab = DATA(lt_finished) ).

      lo_bds = CAST zcl_ext_bds_document_utilities(  lt_finished[ 1 ]-inst ) .
      et_file_content   = lo_bds->gs_bds_get_file_data-export-et_file_content .
      ev_filename       = lo_bds->gs_bds_get_file_data-export-ev_filename.
      ev_file_encodex64 = lo_bds->gs_bds_get_file_data-export-ev_file_encodex64.
      ev_file_x_content = lo_bds->gs_bds_get_file_data-export-ev_file_x_content.
      ev_full_filename  = lo_bds->gs_bds_get_file_data-export-ev_full_filename.
      ev_mimetype       = lo_bds->gs_bds_get_file_data-export-ev_mimetype.

    ELSE.

      DATA lt_signature  TYPE zcl_t2_bds_document_get=>tt_bapisignat.
      DATA lt_components TYPE zcl_t2_bds_document_get=>tt_bapicompon.
      DATA lt_uris       TYPE zcl_t2_bds_document_get=>tt_bapiuri.
      DATA lt_content    TYPE zcl_t2_bds_document_get=>tt_bapicontent.

      TRY.
          zcl_t2_bds_document_get=>get_with_url( EXPORTING classname  = iv_classname
                                                           classtype  = iv_classtype
                                                           client     = sy-mandt
                                                           object_key = iv_object_key
                                                 CHANGING  uris       = lt_uris
                                                           signature  = lt_signature
                                                           components = lt_components ).

          DELETE lt_components WHERE comp_id <> iv_filename.

          READ TABLE lt_components INTO DATA(ls_component) INDEX 1.
          IF sy-subrc = 0.
            DELETE lt_signature WHERE    doc_count  <> ls_component-doc_count
                                      OR comp_count <> ls_component-comp_count.

            " Return Document by Transferring Content
            zcl_t2_bds_document_get=>get_with_table( EXPORTING classname  = iv_classname
                                                               classtype  = iv_classtype
                                                               client     = sy-mandt
                                                     CHANGING  content    = lt_content
                                                               signature  = lt_signature
                                                               components = lt_components ).

            ev_full_filename = ls_component-comp_id.
            ev_filename      = ls_component-comp_id.
            et_file_content  = lt_content.
            ev_mimetype      = ls_component-mimetype.

            REPLACE ALL OCCURRENCES OF iv_filetype IN ev_filename WITH '' IGNORING CASE.
            ev_filename = condense( ev_filename ).

            ev_file_x_content = zcl_t2_binary_to_xstring=>scms_binary_to_xstring(
              EXPORTING
                iv_input_length = CONV #( ls_component-comp_size )
                it_binary_tab   = lt_content
            ).

            ev_file_encodex64 = cl_web_http_utility=>encode_x_base64( ev_file_x_content ).
          ELSE.
            MESSAGE e014 INTO mv_dummy WITH iv_filename  .
            RAISE EXCEPTION TYPE zcx_ext_general_error USING MESSAGE.
          ENDIF.
        CATCH cx_aco_application_exception cx_aco_system_failure INTO DATA(lx_error).
          RAISE EXCEPTION TYPE zcx_ext_general_error
            EXPORTING
              io_previous = lx_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD if_abap_parallel~do.

    CASE mv_parallel_action .
      WHEN c_parallel_action-bds_get_file .

        TRY.
            bds_get_file(
              EXPORTING
                iv_filename       = gs_bds_get_file_data-import-iv_filename
              IMPORTING
                et_file_content   = gs_bds_get_file_data-export-et_file_content
                ev_filename       = gs_bds_get_file_data-export-ev_filename
                ev_file_encodex64 = gs_bds_get_file_data-export-ev_file_encodex64
                ev_file_x_content = gs_bds_get_file_data-export-ev_file_x_content
                ev_full_filename  = gs_bds_get_file_data-export-ev_full_filename
                ev_mimetype       = gs_bds_get_file_data-export-ev_mimetype
            ).
          CATCH zcx_ext_general_error.

        ENDTRY.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_createchangeasset_buffer DEFINITION
  INHERITING FROM cl_abap_behv
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES tt_zsrtr_createchangeasset     TYPE TABLE OF zsrtr_createchangeasset WITH EMPTY KEY.
    TYPES tt_ztrtr_0066_a                TYPE TABLE OF ztrtr_0066_a WITH DEFAULT KEY.

    TYPES tt_createchangeassettp_read    TYPE TABLE FOR READ RESULT zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_crea    TYPE TABLE FOR CREATE zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_delt    TYPE TABLE FOR DELETE zr_rtr_createchangeassettp.

    TYPES tt_createchangeassettp_keys    TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~uploadassetfilecontent.
    TYPES tt_createchangeassettp_result1 TYPE TABLE FOR ACTION RESULT zr_rtr_createchangeassettp\\createchangeasset~uploadassetfilecontent.
    TYPES tt_createchangeassettp_mapped1 TYPE RESPONSE FOR MAPPED EARLY zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_failed1 TYPE RESPONSE FOR FAILED EARLY zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_report1 TYPE RESPONSE FOR REPORTED EARLY zr_rtr_createchangeassettp.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instnace) TYPE REF TO lhc_createchangeasset_buffer.

    METHODS create_asset_entity_from_file
      IMPORTING it_keys     TYPE tt_createchangeassettp_keys
      CHANGING  ct_result   TYPE tt_createchangeassettp_result1
                cs_mapped   TYPE tt_createchangeassettp_mapped1
                cs_failed   TYPE tt_createchangeassettp_failed1
                cs_reported TYPE tt_createchangeassettp_report1.

  PRIVATE SECTION.
    CLASS-DATA go_instnace TYPE REF TO lhc_createchangeasset_buffer.

ENDCLASS.


CLASS lhc_createchangeasset_buffer IMPLEMENTATION.
  METHOD get_instance.
    go_instnace = COND #( WHEN go_instnace IS NOT BOUND THEN NEW #( ) ELSE go_instnace ).
    RETURN go_instnace.
  ENDMETHOD.

  METHOD create_asset_entity_from_file.
    DATA lt_spreadsheet_data         TYPE tt_zsrtr_createchangeasset.
    DATA lt_ztrtr_0066_a             TYPE tt_ztrtr_0066_a.
    DATA lt_createchangeasset_read   TYPE tt_createchangeassettp_read.
    DATA lt_createchangeasset_crea   TYPE tt_createchangeassettp_crea.
    DATA lt_createchangeassettp_delt TYPE tt_createchangeassettp_delt.

    DATA lv_has_eror                 TYPE abap_bool.
    DATA lv_tabix                    TYPE sy-tabix.
    DATA lt_excel_log                TYPE zcl_ext_spreadsheet_utilities=>tt_excel_log.

    DATA(ls_key) = it_keys[ 1 ].

    DATA(lo_spreadsheet) = zcl_ext_spreadsheet_utilities=>create_instance( ).

    lo_spreadsheet->read_spreadsheet_data(
      EXPORTING
        iv_file_content       = lo_spreadsheet->decode_x64_to_xstring( iv_encode_x64 = ls_key-%param-assetfilecontent )
        iv_begin_row          = 15
        it_worksheet_position = VALUE #( ( 1 ) )
        iv_date_format        = abap_true
        iv_set_alpha_in       = abap_true
      IMPORTING
        et_data               = lt_spreadsheet_data
        ev_has_error          = lv_has_eror
        et_excel_log          = lt_excel_log ).

    IF lv_has_eror IS NOT INITIAL.
*      lt_excel_log = VALUE #( BASE lt_excel_log
*                              excel_row = 99
*                              ( excel_col = 1 message = 'TEST Error1' )
*                              ( excel_col = 2 message = 'TEST Error2' )
*                              ( excel_col = 3 message = 'TEST Error3' ) ).
*
*      cs_failed-createchangeasset = VALUE #( ( %cid                           = ls_key-%cid
*                                               %fail-cause                    = if_abap_behv=>cause-unspecific
*                                               %action-uploadassetfilecontent = if_abap_behv=>mk-on ) ).
*
*      LOOP AT lt_excel_log INTO DATA(ls_excel_log).
*        INSERT INITIAL LINE INTO TABLE cs_reported-createchangeasset ASSIGNING FIELD-SYMBOL(<ls_reported>).
*        <ls_reported>-%cid = ls_key-%cid.
*        <ls_reported>-%msg = new_message( id       = 'ZMRTR_ASSET_MSG_1'
*                                          number   = '002'
*                                          severity = if_abap_behv_message=>severity-error
*                                          v1       = ls_excel_log-excel_row
*                                          v2       = ls_excel_log-excel_col
*                                          v3       = ls_excel_log-message ).
*        <ls_reported>-%action-uploadassetfilecontent = if_abap_behv=>mk-on.
*        <ls_reported>-%global = if_abap_behv=>mk-on.
*      ENDLOOP.
*
*      RETURN.
    ENDIF.

    lt_ztrtr_0066_a = CORRESPONDING #( lt_spreadsheet_data ).
    lt_createchangeasset_read = CORRESPONDING #( lt_ztrtr_0066_a MAPPING TO ENTITY ).

    LOOP AT lt_excel_log ASSIGNING FIELD-SYMBOL(<ls_excel_log>) GROUP BY ( excel_row = <ls_excel_log>-excel_row )
         ASCENDING ASSIGNING FIELD-SYMBOL(<lgs_excel_log>).
      lv_tabix += 1.

      LOOP AT GROUP <lgs_excel_log> ASSIGNING FIELD-SYMBOL(<ls_excel_log_grp>).
        <ls_excel_log_grp>-excel_row = lv_tabix.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_createchangeasset_read ASSIGNING FIELD-SYMBOL(<ls_rtr_createchangeasset>).
      lv_tabix = sy-tabix.

      INSERT INITIAL LINE INTO TABLE lt_createchangeasset_crea ASSIGNING FIELD-SYMBOL(<ls_createchangeasset_crea>).
      <ls_createchangeasset_crea> = CORRESPONDING #( <ls_rtr_createchangeasset> ).

      TRY.
          <ls_createchangeasset_crea>-assetuuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      ASSIGN lt_excel_log[ lv_tabix ] TO <ls_excel_log> ELSE UNASSIGN.
      IF sy-subrc IS INITIAL.
        <ls_createchangeasset_crea>-returntype            = CONV #( if_abap_behv_message=>severity-error ).
        <ls_createchangeasset_crea>-returncriticalitycode = 1.
        <ls_createchangeasset_crea>-returnmessage         = <ls_excel_log>-message.
      ENDIF.

      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_createchangeasset_crea>-%control TO FIELD-SYMBOL(<lf_val>) ELSE UNASSIGN.
        IF sy-subrc IS NOT INITIAL.
          EXIT.
        ENDIF.

        IF <lf_val> IS ASSIGNED.
          <lf_val> = if_abap_behv=>mk-on.
        ENDIF.
      ENDDO.
    ENDLOOP.

    SELECT FROM zr_rtr_createchangeassettp WITH
      PRIVILEGED ACCESS
      FIELDS assetuuid
      INTO CORRESPONDING FIELDS OF TABLE @lt_createchangeassettp_delt.

    MODIFY ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
           ENTITY createchangeasset
           DELETE FROM CORRESPONDING #( lt_createchangeassettp_delt )

           ENTITY createchangeasset
           CREATE AUTO FILL CID WITH lt_createchangeasset_crea
           MAPPED DATA(ls_asset_modify_mapped)
           FAILED DATA(ls_asset_modify_failed)
           REPORTED DATA(ls_asset_modify_report).

    cs_failed   = ls_asset_modify_failed.
    cs_reported = ls_asset_modify_report.
    cs_mapped   = ls_asset_modify_mapped.

    READ ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
         ENTITY createchangeasset
         ALL FIELDS WITH CORRESPONDING #( ls_asset_modify_mapped-createchangeasset )
         RESULT DATA(lt_asset_read_result).

    ct_result = VALUE #( FOR ls_asset_read_result IN lt_asset_read_result
                         ( %cid   = ls_key-%cid
                           %param = CORRESPONDING #( ls_asset_read_result ) ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lhc_createchangeasset DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR createchangeasset
      RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR createchangeasset RESULT result.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR createchangeasset RESULT result.

    METHODS downloadassettemplate FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~downloadassettemplate RESULT result.

    METHODS postcreatechangeasset FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~postcreatechangeasset RESULT result.

    METHODS simulatecreatechangeasset FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~simulatecreatechangeasset RESULT result.

    METHODS uploadassetfilecontent FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~uploadassetfilecontent RESULT result.
ENDCLASS.


CLASS lhc_createchangeasset IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    IF     requested_features-%action-simulatecreatechangeasset = if_abap_behv=>mk-off
       AND requested_features-%action-postcreatechangeasset     = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
         ENTITY createchangeasset
         FIELDS ( assetuuid returntype ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          DATA(ls_result) = lt_result[ KEY draft
                                       %tky = ls_key-%tky ].

          result = VALUE #(
              LET lv_error           = CONV msgty( if_abap_behv_message=>severity-error )
                  lv_allowed_acction = COND #( WHEN ls_result-returntype = lv_error
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
              IN
                  BASE result
                  ( %tky    = ls_key-%tky
                    %action = VALUE #(
                        simulatecreatechangeasset = COND #( WHEN requested_features-%action-simulatecreatechangeasset = if_abap_behv=>mk-on
                                                            THEN lv_allowed_acction
                                                            ELSE if_abap_behv=>fc-o-disabled )
                        postcreatechangeasset     = COND #( WHEN requested_features-%action-postcreatechangeasset = if_abap_behv=>mk-on
                                                            THEN lv_allowed_acction
                                                            ELSE if_abap_behv=>fc-o-disabled ) ) ) ).
        CATCH cx_sy_itab_line_not_found.
          result = VALUE #( BASE result
                            ( %tky    = ls_key-%tky
                              %action = VALUE #( simulatecreatechangeasset = if_abap_behv=>fc-o-disabled
                                                 postcreatechangeasset     = if_abap_behv=>fc-o-disabled ) ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_features.
  ENDMETHOD.

  METHOD downloadassettemplate.
    DATA lv_filename TYPE zcl_t2_asset_bds_get_file=>bds_compid.

    DATA(ls_key) = keys[ 1 ].

    TRY.
        lv_filename = zcl_ext_abap_config=>get_instance(
                          iv_program = 'ZBP_R_RTR_CREATECHANGEASSETTP' )->get_single_value(
                                                                           iv_identifier = 'ASSET_TEMPLATE'
                                                                           iv_parameter1 = 'DOWNLOAD' ).
      CATCH zcx_ext_abap_config INTO FINAL(lcx_ext_abap_config).
        failed-createchangeasset = VALUE #( ( %cid                          = ls_key-%cid
                                              %fail-cause                   = if_abap_behv=>cause-unspecific
                                              %action-downloadassettemplate = if_abap_behv=>mk-on ) ).
        reported-createchangeasset = VALUE #( ( %cid                          = ls_key-%cid
                                                %msg                          = new_message_with_text(
                                                    severity = if_abap_behv_message=>severity-error
                                                    text     = lcx_ext_abap_config->get_text( ) )
                                                %action-downloadassettemplate = if_abap_behv=>mk-on ) ).
        RETURN.
    ENDTRY.

    TRY.
        zcl_t2_asset_bds_get_file=>asset_bds_get_file_template( EXPORTING iv_filename       = lv_filename
                                                                          _dest_            = 'NONE'
                                                                IMPORTING ev_file_encodex64 = DATA(lv_file_x64_content)
                                                                          ev_mimetype       = DATA(lv_mimetype) ).
      CATCH cx_aco_application_exception
            cx_aco_communication_failure
            cx_aco_system_failure.
        RETURN.
    ENDTRY.

    result = VALUE #( ( %cid   = ls_key-%cid
                        %param = VALUE #( assetfilename    = lv_filename
                                          assetfilecontent = lv_file_x64_content
                                          assetmimetype    = lv_mimetype ) ) ).
  ENDMETHOD.

  METHOD postcreatechangeasset.
  ENDMETHOD.

  METHOD simulatecreatechangeasset.
  ENDMETHOD.

  METHOD uploadassetfilecontent.
    lhc_createchangeasset_buffer=>get_instance( )->create_asset_entity_from_file( EXPORTING it_keys     = keys
                                                                                  CHANGING  ct_result   = result
                                                                                            cs_mapped   = mapped
                                                                                            cs_failed   = failed
                                                                                            cs_reported = reported ).
  ENDMETHOD.
ENDCLASS.

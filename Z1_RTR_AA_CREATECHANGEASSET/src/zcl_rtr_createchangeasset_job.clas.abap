" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Naruepan Wongrachtachai
" Created on : Jan 20, 2025
" WRICEF ID  : RTR-AA0020
" TR Number  : GSDK909427
" -----------------------------------------------------------------------
" Description:
"   RTR_AA020 Create and Change Asset Master
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
"
" -----------------------------------------------------------------------
CLASS zcl_rtr_createchangeasset_job DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    TYPES ty_char1     TYPE c LENGTH 1.
    TYPES tt_assetuuid TYPE SORTED TABLE OF zr_rtr_createchangeassettp WITH UNIQUE KEY assetuuid.

    CONSTANTS cv_selname_uuid TYPE c LENGTH 8 VALUE 'SO_UUID'.
    CONSTANTS cv_selname_mode TYPE c LENGTH 8 VALUE 'SO_MODE'.

  PRIVATE SECTION.
    METHODS _create_application_log
      IMPORTING it_assetuuid  TYPE tt_assetuuid
                iv_createmode TYPE ty_char1.

    METHODS _reset_createchangeasset_proc.

ENDCLASS.


CLASS zcl_rtr_createchangeasset_job IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #( kind          = if_apj_dt_exec_object=>select_option
                                datatype      = 'CHAR'
                                mandatory_ind = abap_true
                                ( selname    = cv_selname_uuid
                                  length     = 32
                                  param_text = 'Asset UUID' )      ##NO_TEXT
                                ( selname    = cv_selname_mode
                                  length     = 1
                                  param_text = 'Process Mode' ) ) ##NO_TEXT.
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    DATA lt_assetuuid  TYPE tt_assetuuid.
    DATA lv_createmode TYPE ty_char1.

    lt_assetuuid = VALUE #( FOR <ls_parameters> IN it_parameters
                            WHERE ( selname = cv_selname_uuid )
                            ( assetuuid = CONV #( <ls_parameters>-low ) ) ).
    lv_createmode = VALUE #( it_parameters[ selname = cv_selname_mode ]-low OPTIONAL ).

    IF lt_assetuuid IS INITIAL.
      _reset_createchangeasset_proc( ).
      RETURN.
    ENDIF.

    DATA(lo_instance) = zcl_rtr_createchangeasset_main=>get_instance( ).

    CASE lv_createmode.
      WHEN '1'.        " Simulate Asset
        lo_instance->post_create_change_asset( it_keys_simu = VALUE #( FOR <ls_assetuuid> IN lt_assetuuid
                                                                       ( assetuuid = <ls_assetuuid>-assetuuid ) )
                                               iv_set_simu  = abap_true ).
      WHEN '2'.        " Create/Change Asset
        lo_instance->post_create_change_asset( it_keys_post = VALUE #( FOR <ls_assetuuid> IN lt_assetuuid
                                                                       ( assetuuid = <ls_assetuuid>-assetuuid ) )
                                               iv_set_simu  = space ).
      WHEN OTHERS.
    ENDCASE.

    _reset_createchangeasset_proc( ).
    _create_application_log( it_assetuuid  = lt_assetuuid
                             iv_createmode = lv_createmode ).
  ENDMETHOD.

  METHOD _reset_createchangeasset_proc.
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name( ).

    SELECT FROM zr_rtr_createchangeassettp WITH
      PRIVILEGED ACCESS
      FIELDS assetuuid, returntype, isprocessed
      WHERE (    createdby     = @lv_uname
              OR lastchangedby = @lv_uname )
        AND isprocessed IS NOT INITIAL
      INTO TABLE @FINAL(lt_asset_isprocessed).

    IF lt_asset_isprocessed IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_rtr_createchangeassettp
           ENTITY createchangeasset
           UPDATE FIELDS ( isprocessed ) WITH VALUE #( FOR <ls_assetuuid> IN lt_asset_isprocessed
                                                       ( assetuuid   = <ls_assetuuid>-assetuuid
                                                         isprocessed = space ) )
           " TODO: variable is assigned but never used (ABAP cleaner)
           FAILED DATA(ls_failed)
           " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(ls_reported).

    COMMIT ENTITIES.
  ENDMETHOD.

  METHOD _create_application_log.
    DATA lo_free TYPE REF TO if_bali_free_text_setter.
    DATA lv_text TYPE cl_bali_free_text_setter=>ty_text.

    IF it_assetuuid IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
      FROM zr_rtr_createchangeassettp AS createchangeassettp
             INNER JOIN
               @it_assetuuid AS zit_assetuuid ON createchangeassettp~assetuuid = zit_assetuuid~assetuuid
      FIELDS createchangeassettp~assetuuid,
             createchangeassettp~assetlineno,
             createchangeassettp~returntype,
             createchangeassettp~returncriticalitycode,
             createchangeassettp~returntypedescription,
             createchangeassettp~returnmessage
      ORDER BY createchangeassettp~assetlineno,
               createchangeassettp~assetuuid
      INTO TABLE @FINAL(lt_createchangeassettp)
      PRIVILEGED ACCESS.

    IF lt_createchangeassettp IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_log) = cl_bali_log=>create( ).
        DATA(lo_header) = cl_bali_header_setter=>create( object      = 'ZALO_RTR_CRACHGASSET'
                                                         subobject   = COND #( WHEN iv_createmode = '1'
                                                                               THEN 'SIMULATE_LOG'
                                                                               ELSE 'POSTING_LOG' )
                                                         external_id = cl_system_uuid=>create_uuid_c32_static( ) ).

        lo_log->set_header( lo_header ).

        LOOP AT lt_createchangeassettp ASSIGNING FIELD-SYMBOL(<ls_createchangeassettp>).
          DATA(lr_assetlineno) = NEW string( |{ <ls_createchangeassettp>-assetlineno ALPHA = OUT }| ).
          lr_assetlineno->* = condense( val = lr_assetlineno->* ).

          ##NO_TEXT
          lv_text = |Line No. { lr_assetlineno->* }: { <ls_createchangeassettp>-returnmessage } |.

          lo_free = cl_bali_free_text_setter=>create( severity = COND #( WHEN <ls_createchangeassettp>-returntype = 'E' THEN
                                                                           if_bali_constants=>c_severity_error
                                                                         WHEN <ls_createchangeassettp>-returntype = 'A' THEN
                                                                           if_bali_constants=>c_severity_termination
                                                                         WHEN <ls_createchangeassettp>-returntype = 'X' THEN
                                                                           if_bali_constants=>c_severity_exit
                                                                         WHEN <ls_createchangeassettp>-returntype = 'W' THEN
                                                                           if_bali_constants=>c_severity_warning
                                                                         WHEN <ls_createchangeassettp>-returntype = 'I' THEN
                                                                           if_bali_constants=>c_severity_information
                                                                         ELSE
                                                                           if_bali_constants=>c_severity_status )
                                                      text     = lv_text ).
          lo_log->add_item( lo_free ).
        ENDLOOP.

        cl_bali_log_db=>get_instance( )->save_log( log                        = lo_log
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime
            cx_uuid_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

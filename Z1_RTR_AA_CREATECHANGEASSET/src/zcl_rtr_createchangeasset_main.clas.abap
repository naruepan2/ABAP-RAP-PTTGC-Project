" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Naruepan Wongrachtachai
" Created on : Oct 07, 2025
" WRICEF ID  : RTR-AA0020
" TR Number  : GSDK903648
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
CLASS zcl_rtr_createchangeasset_main DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES if_abap_parallel.

    TYPES tt_zsrtr_createchangeasset_upl TYPE TABLE OF zsrtr_createchangeasset_upload WITH EMPTY KEY.
    TYPES tt_zsrtr_createchangeasset     TYPE TABLE OF zsrtr_createchangeasset WITH EMPTY KEY.
    TYPES tt_ztrtr_0102_01               TYPE TABLE OF ztrtr_0102_01_a WITH DEFAULT KEY.

    " General type for ZR_RTR_CREATECHANGEASSETTP
    TYPES tt_createchangeassettp_read    TYPE TABLE FOR READ RESULT zr_rtr_createchangeassettp\\createchangeasset.
    TYPES tt_createchangeassettp_crea    TYPE TABLE FOR CREATE zr_rtr_createchangeassettp\\createchangeasset.
    TYPES tt_createchangeassettp_delt    TYPE TABLE FOR DELETE zr_rtr_createchangeassettp\\createchangeasset.

    TYPES ts_createchangeassettp_read    TYPE STRUCTURE FOR READ RESULT zr_rtr_createchangeassettp\\createchangeasset.

    " General type for ZR_RTR_CREATECHANGEASSETMSGTP
    TYPES tt_createchangeassetmsgtp_read TYPE TABLE FOR READ RESULT zr_rtr_createchangeassettp\\createchangeassetmsg.
    TYPES tt_createchangeassetmsgtp_crea TYPE TABLE FOR CREATE zr_rtr_createchangeassettp\\createchangeasset\_createchangeassetmsg.
    TYPES tt_createchangeassetmsgtp_updt TYPE TABLE FOR UPDATE zr_rtr_createchangeassettp\\createchangeassetmsg.
    TYPES tt_createchangeassetmsgtp_delt TYPE TABLE FOR DELETE zr_rtr_createchangeassettp\\createchangeassetmsg.

    TYPES ts_createchangeassetmsgtp_read TYPE STRUCTURE FOR READ RESULT zr_rtr_createchangeassettp\\createchangeassetmsg.
    TYPES ts_createchangeassetmsgtp_crea TYPE STRUCTURE FOR CREATE zr_rtr_createchangeassettp\\createchangeasset\_createchangeassetmsg.

    " For Upload CreateChangeAsset File
    TYPES tt_createchangeassettp_keys1   TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~uploadassetfilecontent.
    TYPES tt_createchangeassettp_mapped1 TYPE RESPONSE FOR MAPPED EARLY zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_failed1 TYPE RESPONSE FOR FAILED EARLY zr_rtr_createchangeassettp.
    TYPES tt_createchangeassettp_report1 TYPE RESPONSE FOR REPORTED EARLY zr_rtr_createchangeassettp.

    " For Delete all of CreateChangeAsset
    TYPES tt_createchangeassettp_keys2   TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~refreshcreatechangeassetrecord.
    TYPES tt_createchangeassettp_result2 TYPE TABLE FOR ACTION RESULT zr_rtr_createchangeassettp\\createchangeasset~refreshcreatechangeassetrecord.

    " For Simulate CreateChangeAsset
    TYPES tt_createchangeassettp_keys3   TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~simulatecreatechangeasset.
*    TYPES tt_createchangeassettp_result3 TYPE TABLE FOR ACTION RESULT zr_rtr_createchangeassettp\\createchangeasset~simulatecreatechangeasset.

    " For Post CreateChangeAsset
    TYPES tt_createchangeassettp_keys4   TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~postcreatechangeasset.
*    TYPES tt_createchangeassettp_result4 TYPE TABLE FOR ACTION RESULT zr_rtr_createchangeassettp\\createchangeasset~postcreatechangeasset.

    " Asset
    TYPES ty_createsubnumber             TYPE zcl_t2_bapi_fixedasset_create=>xsubno.

    TYPES ty_text50                      TYPE c LENGTH 50.
    TYPES ty_processmode                 TYPE c LENGTH 15.

    TYPES ts_asset_key                   TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_key.
    TYPES ts_generaldata                 TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg001.
    TYPES ts_generaldatax                TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg001x.
    TYPES ts_inventory                   TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg011.
    TYPES ts_inventoryx                  TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg011x.
    TYPES ts_timedependentdata           TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg003.
    TYPES ts_timedependentdatax          TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg003x.
    TYPES ts_allocations                 TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg004.
    TYPES ts_allocationsx                TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg004x.
    TYPES ts_origin                      TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg009.
    TYPES ts_originx                     TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg009x.
    TYPES ts_investacctassignmnt         TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg010.
    TYPES ts_investacctassignmntx        TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg010x.
    TYPES ts_leasing                     TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg005.
    TYPES ts_leasingx                    TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_feglg005x.
    TYPES ts_depreciationareas           TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_dep_areas.
    TYPES ts_depreciationareasx          TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_dep_areasx.
    TYPES tt_depreciationareas           TYPE zcl_t2_bapi_fixedasset_create=>_bapi1022_dep_areas.
    TYPES tt_depreciationareasx          TYPE zcl_t2_bapi_fixedasset_create=>_bapi1022_dep_areasx.
    TYPES tt_extensionin                 TYPE zcl_t2_bapi_fixedasset_create=>_bapiparex.

    TYPES ty_companycode                 TYPE bukrs.
    TYPES ty_asset                       TYPE bf_anln1.
    TYPES ty_subnumber                   TYPE bf_anln2.
    TYPES ts_assetcreated                TYPE zcl_t2_bapi_fixedasset_create=>bapi1022_reference.
    TYPES ts_return                      TYPE bapiret2.

    CONSTANTS c_thb TYPE i_currency-currency VALUE 'THB'.

    " If change this constants, please change value of domain ZD_RTR_AA_FILEPROCESSMODE as well
    CONSTANTS: BEGIN OF c_processmodetext,
                 ##NO_TEXT
                 create     TYPE string VALUE 'Create',
                 ##NO_TEXT
                 create_sub TYPE string VALUE 'Create-Sub',
                 ##NO_TEXT
                 create_ex  TYPE string VALUE 'Create-Ex',
                 ##NO_TEXT
                 change     TYPE string VALUE 'Change',
               END OF c_processmodetext.

    CONSTANTS: BEGIN OF c_processmode,
                 ##NO_TEXT
                 create     TYPE string VALUE 'CREATE',
                 ##NO_TEXT
                 create_sub TYPE string VALUE 'CREATE-SUB',
                 ##NO_TEXT
                 create_ex  TYPE string VALUE 'CREATE-EX',
                 ##NO_TEXT
                 change     TYPE string VALUE 'CHANGE',
               END OF c_processmode.

    " If change this constants, please change value of domain ZD_RTR_AA_MESSAGESTATUS as well
    CONSTANTS: BEGIN OF c_runtype,
                 ##NO_TEXT
                 upload   TYPE c LENGTH 15 VALUE 'Upload',
                 ##NO_TEXT
                 simulate TYPE c LENGTH 15 VALUE 'Simulate',
                 ##NO_TEXT
                 posting  TYPE c LENGTH 15 VALUE 'Create/Change',
               END OF c_runtype.

    CONSTANTS: BEGIN OF c_addi_msgtype,
                 terminate        TYPE symsgty VALUE 'A',
                 pending          TYPE symsgty VALUE 'P',
                 simulate_success TYPE symsgty VALUE 'M',
               END OF c_addi_msgtype.

    CONSTANTS: BEGIN OF c_allowed_blank,
                 char      TYPE c LENGTH 1 VALUE '!',
                 date      TYPE d          VALUE '99999999',
                 time      TYPE t          VALUE '999999',
                 numberic1 TYPE n LENGTH 2 VALUE '99',
                 numberic2 TYPE n LENGTH 3 VALUE '999',
               END OF c_allowed_blank.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instnace) TYPE REF TO zcl_rtr_createchangeasset_main.

    METHODS constructor.

    METHODS create_asset_entity_from_file
      IMPORTING it_keys     TYPE tt_createchangeassettp_keys1
      CHANGING  cs_mapped   TYPE tt_createchangeassettp_mapped1 OPTIONAL
                cs_failed   TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS delete_all_to_asset_entity
      IMPORTING it_keys     TYPE tt_createchangeassettp_keys2
      CHANGING  ct_result   TYPE tt_createchangeassettp_result2 OPTIONAL
                cs_mapped   TYPE tt_createchangeassettp_mapped1 OPTIONAL
                cs_failed   TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS handle_asset_message_entity
      CHANGING ct_message_crea TYPE tt_createchangeassetmsgtp_crea OPTIONAL
               ct_message_delt TYPE tt_createchangeassetmsgtp_delt OPTIONAL.

    METHODS simulate_asset_master
      IMPORTING it_keys     TYPE tt_createchangeassettp_keys3
      CHANGING  " ct_result   TYPE tt_createchangeassettp_result3 OPTIONAL
                cs_mapped   TYPE tt_createchangeassettp_mapped1 OPTIONAL
                cs_failed   TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS post_asset_master
      IMPORTING it_keys     TYPE tt_createchangeassettp_keys4
      CHANGING  " ct_result   TYPE tt_createchangeassettp_result4 OPTIONAL
                cs_mapped   TYPE tt_createchangeassettp_mapped1 OPTIONAL
                cs_failed   TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS post_create_change_asset
      IMPORTING it_keys_simu      TYPE tt_createchangeassettp_keys3   OPTIONAL
                it_keys_post      TYPE tt_createchangeassettp_keys4   OPTIONAL
                iv_set_simu       TYPE abap_boolean                   DEFAULT space
                iv_commit_entites TYPE abap_boolean                   OPTIONAL
      CHANGING  " ct_result_simu TYPE tt_createchangeassettp_result3 OPTIONAL
                " ct_result_post TYPE tt_createchangeassettp_result4 OPTIONAL
                cs_mapped         TYPE tt_createchangeassettp_mapped1 OPTIONAL
                cs_failed         TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported       TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS set_createchangeassettp_read
      IMPORTING it_result   TYPE tt_createchangeassettp_read OPTIONAL
                is_result   TYPE ts_createchangeassettp_read OPTIONAL
                iv_append   TYPE abap_boolean                DEFAULT abap_true
                iv_set_simu TYPE abap_boolean                DEFAULT space.

    METHODS set_ui_keys
      IMPORTING it_keys_simu TYPE tt_createchangeassettp_keys3 OPTIONAL
                it_keys_post TYPE tt_createchangeassettp_keys4 OPTIONAL
                iv_set_simu  TYPE abap_boolean                 DEFAULT space.

    METHODS get_ui_keys
      EXPORTING et_keys_simu TYPE tt_createchangeassettp_keys3
                et_keys_post TYPE tt_createchangeassettp_keys4
                ev_set_simu  TYPE abap_boolean.

    METHODS get_createchangeassettp_read
      EXPORTING et_result       TYPE tt_createchangeassettp_read
                et_message_crea TYPE tt_createchangeassetmsgtp_crea
                et_message_updt TYPE tt_createchangeassetmsgtp_updt
                et_message_delt TYPE tt_createchangeassetmsgtp_delt.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_rtr_createchangeasset_main.

    DATA mo_abap_config          TYPE REF TO zcl_ext_abap_config.

    DATA mt_result               TYPE tt_createchangeassettp_read.
    DATA mt_message_read         TYPE tt_createchangeassetmsgtp_read.
    DATA mt_message_crea         TYPE tt_createchangeassetmsgtp_crea.
    DATA mt_message_updt         TYPE tt_createchangeassetmsgtp_updt.
    DATA mt_message_delt         TYPE tt_createchangeassetmsgtp_delt.

    DATA mt_keys_simu            TYPE tt_createchangeassettp_keys3.
    DATA mt_keys_post            TYPE tt_createchangeassettp_keys4.

    DATA mt_unitofmeasure        TYPE SORTED TABLE OF i_unitofmeasure WITH UNIQUE KEY unitofmeasure.
    DATA mt_country              TYPE SORTED TABLE OF i_country WITH UNIQUE KEY country.
    DATA mt_currency             TYPE SORTED TABLE OF i_currency WITH UNIQUE KEY currency.
    DATA mt_companycode          TYPE SORTED TABLE OF i_companycode WITH UNIQUE KEY companycode.

    DATA ms_asset_key            TYPE ts_asset_key.
    DATA ms_generaldata          TYPE ts_generaldata.
    DATA ms_generaldatax         TYPE ts_generaldatax.
    DATA ms_inventory            TYPE ts_inventory.
    DATA ms_inventoryx           TYPE ts_inventoryx.
    DATA ms_timedependentdata    TYPE ts_timedependentdata.
    DATA ms_timedependentdatax   TYPE ts_timedependentdatax.
    DATA ms_allocations          TYPE ts_allocations.
    DATA ms_allocationsx         TYPE ts_allocationsx.
    DATA ms_origin               TYPE ts_origin.
    DATA ms_originx              TYPE ts_originx.
    DATA ms_investacctassignmnt  TYPE ts_investacctassignmnt.
    DATA ms_investacctassignmntx TYPE ts_investacctassignmntx.
    DATA ms_leasing              TYPE ts_leasing.
    DATA ms_leasingx             TYPE ts_leasingx.
    DATA ms_depreciationareas    TYPE ts_depreciationareas.
    DATA ms_depreciationareasx   TYPE ts_depreciationareasx.
    DATA mt_depreciationareas    TYPE tt_depreciationareas.
    DATA mt_depreciationareasx   TYPE tt_depreciationareasx.
    DATA mv_createsubnumber      TYPE ty_createsubnumber.
    DATA mt_extensionin          TYPE tt_extensionin.

    DATA mv_companycode          TYPE ty_companycode.
    DATA mv_asset                TYPE ty_asset.
    DATA mv_subnumber            TYPE ty_subnumber.
    DATA ms_assetcreated         TYPE ts_assetcreated.
    DATA ms_return               TYPE ts_return.
    DATA mv_simulate             TYPE abap_boolean.
    DATA mv_tabix                TYPE sy-tabix.

    METHODS _check_mandatory_fields
      IMPORTING iv_createmode TYPE string
      EXPORTING ev_has_error  TYPE abap_boolean
      CHANGING  ct_result     TYPE tt_createchangeassettp_read
                cs_failed     TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported   TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS _preparing_asset
      IMPORTING is_result      TYPE ts_createchangeassettp_read
                iv_processmode TYPE string.

    METHODS _build_mandatory_to_failed
      IMPORTING iv_text       TYPE string                         OPTIONAL
                iv_fulltext   TYPE string                         OPTIONAL
                iv_msgv1      TYPE ty_text50                      OPTIONAL
                iv_msgv2      TYPE ty_text50                      OPTIONAL
                iv_msgv3      TYPE ty_text50                      OPTIONAL
                iv_msgv4      TYPE ty_text50                      OPTIONAL
                iv_createmode TYPE string
                iv_messageno  TYPE symsgno                        DEFAULT '013'
      CHANGING  cs_result     TYPE ts_createchangeassettp_read    OPTIONAL
                cs_failed     TYPE tt_createchangeassettp_failed1 OPTIONAL
                cs_reported   TYPE tt_createchangeassettp_report1 OPTIONAL.

    METHODS _mark_x_to_fields
      IMPORTING iv_structure_in  TYPE any
                iv_mark_x_all    TYPE abap_boolean DEFAULT space
      EXPORTING ev_structure_out TYPE any.

    METHODS _get_data_from_data_definition
      IMPORTING it_result TYPE tt_createchangeassettp_read.

    METHODS _get_message_result
      IMPORTING it_result              TYPE tt_createchangeassettp_read
      RETURNING VALUE(rt_message_read) TYPE tt_createchangeassetmsgtp_read.

    METHODS _populate_change_before_post
      CHANGING cs_any_structure TYPE any OPTIONAL
               ct_any_table     TYPE any OPTIONAL.

    METHODS _check_change_mandatory_field
      IMPORTING iv_any_field        TYPE any
      RETURNING VALUE(rv_mandatory) TYPE abap_boolean.

    METHODS _check_abap_config
      CHANGING co_abap_config TYPE REF TO zcl_ext_abap_config.

ENDCLASS.


CLASS zcl_rtr_createchangeasset_main IMPLEMENTATION.
  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS NOT BOUND THEN NEW #( ) ELSE go_instance ).
    RETURN go_instance.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).

    _check_abap_config( CHANGING co_abap_config = mo_abap_config ).
  ENDMETHOD.

  METHOD create_asset_entity_from_file.
    TYPES: BEGIN OF lts_company,
             companycode TYPE i_companycode-companycode,
             currency    TYPE i_companycode-currency,
           END OF lts_company.
    TYPES ltt_company TYPE HASHED TABLE OF lts_company WITH UNIQUE KEY companycode.

    TYPES: BEGIN OF lts_unitofmeasure,
             unitofmeasure   TYPE i_unitofmeasure-unitofmeasure,
             unitofmeasure_e TYPE i_unitofmeasure-unitofmeasure_e,
           END OF lts_unitofmeasure.
    TYPES ltt_unitofmeasure TYPE SORTED TABLE OF lts_unitofmeasure WITH UNIQUE KEY unitofmeasure
                                                                   WITH NON-UNIQUE SORTED KEY k2 COMPONENTS unitofmeasure_e.

    DATA lt_company                   TYPE ltt_company.
    DATA lt_unitofmeasure             TYPE ltt_unitofmeasure.
    DATA lt_spreadsheet_data          TYPE tt_zsrtr_createchangeasset_upl.
    DATA lt_ztrtr_0102_01             TYPE tt_ztrtr_0102_01.
    DATA lt_createchangeasset_read    TYPE tt_createchangeassettp_read.
    DATA lt_createchangeasset_crea    TYPE tt_createchangeassettp_crea.
    DATA lt_createchangeassetmsg_crea TYPE tt_createchangeassetmsgtp_crea.
    DATA lt_companycode               TYPE SORTED TABLE OF i_companycode WITH UNIQUE KEY companycode.
    DATA lt_unitofmeasurecode         TYPE SORTED TABLE OF i_unitofmeasure WITH UNIQUE KEY unitofmeasure.

    DATA lv_begin_row                 TYPE i VALUE 15.
    DATA lv_tabix_root                TYPE sy-tabix.
    DATA lv_tabix_child               TYPE sy-tabix.
    DATA lv_table_index               TYPE sy-tabix.
    DATA lt_excel_log                 TYPE zcl_ext_spreadsheet_utilities=>tt_excel_log.

    DATA lv_additional_check          TYPE abap_boolean.

    DATA lt_no_depreciation_key       TYPE RANGE OF zcl_t2_bapi_fixedasset_create=>bapi1022_dep_areas-dep_key.

    FIELD-SYMBOLS <ls_createchangeassetmsg_crea> TYPE ts_createchangeassetmsgtp_crea.

    DATA(ls_key) = it_keys[ 1 ].

    _check_abap_config( CHANGING co_abap_config = mo_abap_config ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Read Spreadsheet data from file
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA(lo_spreadsheet) = zcl_ext_spreadsheet_utilities=>create_instance( ).

    lo_spreadsheet->read_spreadsheet_data(
      EXPORTING
        iv_file_content       = lo_spreadsheet->decode_x64_to_xstring( iv_encode_x64 = ls_key-%param-assetfilecontent )
        iv_begin_row          = lv_begin_row
        it_worksheet_position = VALUE #( ( 1 ) )
        iv_user_date_format   = abap_true
        iv_set_alpha_in       = abap_true
      IMPORTING
        et_data               = lt_spreadsheet_data
        et_excel_log          = lt_excel_log ).

    lt_ztrtr_0102_01 = CORRESPONDING #( lt_spreadsheet_data ).
    lt_createchangeasset_read = CORRESPONDING #( lt_ztrtr_0102_01 MAPPING TO ENTITY ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Populate Spreadsheet data
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT lt_excel_log ASSIGNING FIELD-SYMBOL(<ls_excel_log>) GROUP BY ( excel_row = <ls_excel_log>-excel_row )
         ASCENDING ASSIGNING FIELD-SYMBOL(<lsg_excel_log>).
      lv_tabix_root += 1.

      LOOP AT GROUP <lsg_excel_log> ASSIGNING FIELD-SYMBOL(<ls_excel_log_grp>).
        <ls_excel_log_grp>-excel_row = ( <ls_excel_log_grp>-excel_row - lv_begin_row ) + lv_tabix_root.
      ENDLOOP.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Fetch data to validation
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lt_companycode = CORRESPONDING #( lt_createchangeasset_read DISCARDING DUPLICATES MAPPING companycode = companycode ).
    lt_unitofmeasurecode = CORRESPONDING #( lt_createchangeasset_read DISCARDING DUPLICATES MAPPING unitofmeasure = baseunit ).

    IF lt_companycode IS NOT INITIAL.
      SELECT
        FROM i_companycode
               INNER JOIN
                 @lt_companycode AS zit_companycode ON i_companycode~companycode = zit_companycode~companycode
        FIELDS i_companycode~companycode,
               i_companycode~currency
        INTO TABLE @lt_company
        PRIVILEGED ACCESS.
    ENDIF.

    IF lt_companycode IS NOT INITIAL.
      SELECT
        FROM i_unitofmeasure
               INNER JOIN
                 @lt_unitofmeasurecode AS zit_unitofmeasurecode ON i_unitofmeasure~unitofmeasure = zit_unitofmeasurecode~unitofmeasure
        FIELDS i_unitofmeasure~unitofmeasure,
               i_unitofmeasure~unitofmeasure_e
        INTO TABLE @lt_unitofmeasure
        PRIVILEGED ACCESS.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Preparing upload data
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    mo_abap_config->get_range_value( EXPORTING iv_identifier = 'NO_DEPRECIATION_KEY'
                                     IMPORTING et_range      = lt_no_depreciation_key ).

    DATA(lv_processmode) = VALUE ty_processmode( ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Preparing upload data
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT lt_createchangeasset_read ASSIGNING FIELD-SYMBOL(<ls_rtr_createchangeasset>).
      lv_tabix_root   = sy-tabix.
      lv_table_index += 1.
      lv_tabix_child  = 0.
      lv_additional_check = space.
      lv_processmode = COND #( WHEN lv_processmode IS INITIAL
                               THEN <ls_rtr_createchangeasset>-processmode
                               ELSE lv_processmode ).

      INSERT INITIAL LINE INTO TABLE lt_createchangeasset_crea ASSIGNING FIELD-SYMBOL(<ls_createchangeasset_crea>).
      <ls_createchangeasset_crea> = CORRESPONDING #( <ls_rtr_createchangeasset> ).
      <ls_createchangeasset_crea>-%cid                      = |%CID_ROOT_{ lv_tabix_root }|.
      <ls_createchangeasset_crea>-processmode               = SWITCH #( to_upper( <ls_rtr_createchangeasset>-processmode )
                                                                        WHEN c_processmode-create THEN
                                                                          c_processmodetext-create
                                                                        WHEN c_processmode-create_ex THEN
                                                                          c_processmodetext-create_ex
                                                                        WHEN c_processmode-create_sub THEN
                                                                          c_processmodetext-create_sub
                                                                        WHEN c_processmode-change THEN
                                                                          c_processmodetext-change
                                                                        ELSE
                                                                          <ls_rtr_createchangeasset>-processmode ).
      <ls_createchangeasset_crea>-assetlineno               = COND #( WHEN <ls_rtr_createchangeasset>-assetlineno IS NOT INITIAL
                                                                      THEN <ls_rtr_createchangeasset>-assetlineno
                                                                      ELSE lv_table_index ).
      <ls_createchangeasset_crea>-runtype                   = c_runtype-upload.
      <ls_createchangeasset_crea>-currencycode              = VALUE #( lt_company[
                                                                           companycode = <ls_createchangeasset_crea>-companycode ]-currency DEFAULT c_thb ).
      <ls_createchangeasset_crea>-negativeamountisallowed01 = COND #( WHEN <ls_createchangeasset_crea>-negativeamountisallowed01 IS NOT INITIAL
                                                                      THEN abap_true ).
      <ls_createchangeasset_crea>-negativeamountisallowed15 = COND #( WHEN <ls_createchangeasset_crea>-negativeamountisallowed15 IS NOT INITIAL
                                                                      THEN abap_true ).

      IF     <ls_createchangeasset_crea>-depreciationkeyanlb01 IN lt_no_depreciation_key
         AND lt_no_depreciation_key IS NOT INITIAL.
        <ls_createchangeasset_crea>-usefullifeinyearsanlb01   = '0'.
        <ls_createchangeasset_crea>-usefullifeinperiodsanlb01 = '0'.
      ENDIF.

      IF     <ls_createchangeasset_crea>-depreciationkeyanlb15 IN lt_no_depreciation_key
         AND lt_no_depreciation_key IS NOT INITIAL.
        <ls_createchangeasset_crea>-usefullifeinyearsanlb15   = '0'.
        <ls_createchangeasset_crea>-usefullifeinperiodsanlb15 = '0'.
      ENDIF.

      ASSIGN lt_excel_log[ excel_row = lv_tabix_root ] TO <ls_excel_log> ELSE UNASSIGN.
      IF sy-subrc IS INITIAL.
        <ls_createchangeasset_crea>-returntype    = c_addi_msgtype-terminate.    " Termination Message
        <ls_createchangeasset_crea>-returnmessage = <ls_excel_log>-message.
      ELSE.
        <ls_createchangeasset_crea>-returntype    = c_addi_msgtype-pending.    " Pending
      ENDIF.

      " Additional checking
      IF lv_processmode <> <ls_createchangeasset_crea>-processmode.
        lv_additional_check = abap_true.

        ##NO_TEXT
        MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 024
                INTO <ls_createchangeasset_crea>-returnmessage.

        <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
      ENDIF.

      IF lv_additional_check IS INITIAL.
        CASE to_upper( <ls_createchangeasset_crea>-processmode ).
          WHEN c_processmode-create
            OR c_processmode-create_ex
            OR c_processmode-create_sub.
            IF    to_upper( <ls_createchangeasset_crea>-processmode ) = c_processmode-create
               OR to_upper( <ls_createchangeasset_crea>-processmode ) = c_processmode-create_ex.
              IF to_upper( <ls_createchangeasset_crea>-processmode ) = c_processmode-create.
                IF    <ls_createchangeasset_crea>-masterfixedasset IS NOT INITIAL
                   OR <ls_createchangeasset_crea>-fixedasset       IS NOT INITIAL.
                  lv_additional_check = abap_true.

                  ##NO_TEXT
                  MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 011
                          WITH <ls_createchangeasset_crea>-masterfixedasset
                               <ls_createchangeasset_crea>-fixedasset
                          INTO <ls_createchangeasset_crea>-returnmessage.

                  <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
                ENDIF.
              ELSEIF to_upper( <ls_createchangeasset_crea>-processmode ) = c_processmode-create_ex.
                IF <ls_createchangeasset_crea>-masterfixedasset IS INITIAL.
                  lv_additional_check = abap_true.

                  ##NO_TEXT
                  MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 003
                          WITH 'Asset No.'
                          INTO <ls_createchangeasset_crea>-returnmessage.

                  <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
                ELSEIF <ls_createchangeasset_crea>-fixedasset IS NOT INITIAL.
                  lv_additional_check = abap_true.

                  ##NO_TEXT
                  MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 012
                          INTO <ls_createchangeasset_crea>-returnmessage.

                  <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
                ENDIF.
              ENDIF.
            ELSEIF NOT line_exists( lt_company[ companycode = <ls_createchangeasset_crea>-companycode ] ).
              lv_additional_check = abap_true.

              ##NO_TEXT
              MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 010
                      WITH <ls_createchangeasset_crea>-companycode
                      INTO <ls_createchangeasset_crea>-returnmessage.

              <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
            ELSEIF     <ls_createchangeasset_crea>-quantity IS NOT INITIAL
                   AND <ls_createchangeasset_crea>-baseunit IS INITIAL.
              lv_additional_check = abap_true.

              ##NO_TEXT
              MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 003
                      WITH 'Base Unit'
                      INTO <ls_createchangeasset_crea>-returnmessage.

              <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
            ELSEIF NOT line_exists( lt_unitofmeasure[ KEY k2
                                                      unitofmeasure_e = <ls_createchangeasset_crea>-baseunit ] ).
              lv_additional_check = abap_true.
              DATA(lv_baseunit) = CONV string( <ls_createchangeasset_crea>-baseunit ).

              ##NO_TEXT
              MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 009
                      WITH lv_baseunit
                      INTO <ls_createchangeasset_crea>-returnmessage.

              <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
              CLEAR <ls_createchangeasset_crea>-baseunit.
            ENDIF.
          WHEN c_processmode-change.
            IF <ls_createchangeasset_crea>-companycode IS NOT INITIAL.
              IF NOT line_exists( lt_company[ companycode = <ls_createchangeasset_crea>-companycode ] ).
                lv_additional_check = abap_true.

                ##NO_TEXT
                MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 010
                        WITH <ls_createchangeasset_crea>-companycode
                        INTO <ls_createchangeasset_crea>-returnmessage.

                <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
              ENDIF.
            ENDIF.
            IF     <ls_createchangeasset_crea>-quantity IS NOT INITIAL
               AND <ls_createchangeasset_crea>-baseunit IS INITIAL.
              lv_additional_check = abap_true.

              ##NO_TEXT
              MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 003
                      WITH 'Base Unit'
                      INTO <ls_createchangeasset_crea>-returnmessage.

              <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
            ELSEIF <ls_createchangeasset_crea>-baseunit IS NOT INITIAL.
              IF NOT line_exists( lt_unitofmeasure[ KEY k2
                                                    unitofmeasure_e = <ls_createchangeasset_crea>-baseunit ] ).
                lv_additional_check = abap_true.
                lv_baseunit = CONV string( <ls_createchangeasset_crea>-baseunit ).

                ##NO_TEXT
                MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 009
                        WITH lv_baseunit
                        INTO <ls_createchangeasset_crea>-returnmessage.

                <ls_createchangeasset_crea>-returntype = c_addi_msgtype-terminate.    " Termination Message
                CLEAR <ls_createchangeasset_crea>-baseunit.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF lv_additional_check IS NOT INITIAL.
        lv_tabix_child += 1.

        INSERT INITIAL LINE INTO TABLE lt_createchangeassetmsg_crea ASSIGNING <ls_createchangeassetmsg_crea>.
        <ls_createchangeassetmsg_crea> = CORRESPONDING #( <ls_rtr_createchangeasset> EXCEPT %target ).
        <ls_createchangeassetmsg_crea>-%cid_ref = <ls_createchangeasset_crea>-%cid.
        <ls_createchangeassetmsg_crea>-%target  = VALUE #(
            ( %cid          = |%CID_ROOT_{ lv_tabix_root }_CHILD_{ lv_tabix_child }|
              returntype    = <ls_createchangeasset_crea>-returntype
              runtype       = c_runtype-upload
              returnmessage = <ls_createchangeasset_crea>-returnmessage
              %control      = VALUE #( returntype    = if_abap_behv=>mk-on
                                       returnmessage = if_abap_behv=>mk-on ) ) ).
      ENDIF.

      LOOP AT lt_excel_log ASSIGNING <ls_excel_log> WHERE excel_row = lv_tabix_root. "#EC CI_STDSEQ
        lv_tabix_child += 1.

        INSERT INITIAL LINE INTO TABLE lt_createchangeassetmsg_crea ASSIGNING <ls_createchangeassetmsg_crea>.
        <ls_createchangeassetmsg_crea> = CORRESPONDING #( <ls_rtr_createchangeasset> EXCEPT %target ).
        <ls_createchangeassetmsg_crea>-%cid_ref = <ls_createchangeasset_crea>-%cid.
        <ls_createchangeassetmsg_crea>-%target  = VALUE #(
            ( %cid          = |%CID_ROOT_{ lv_tabix_root }_CHILD_{ lv_tabix_child }|
              returntype    = c_addi_msgtype-terminate
              runtype       = c_runtype-upload
              returnmessage = <ls_excel_log>-message
              %control      = VALUE #( returntype    = if_abap_behv=>mk-on
                                       returnmessage = if_abap_behv=>mk-on ) ) ).
      ENDLOOP.

      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_createchangeasset_crea>-%control TO FIELD-SYMBOL(<lv_val>) ELSE UNASSIGN.
        IF sy-subrc IS NOT INITIAL.
          EXIT.
        ENDIF.

        IF <lv_val> IS ASSIGNED.
          <lv_val> = if_abap_behv=>mk-on.
        ENDIF.
      ENDDO.

      CLEAR: <ls_createchangeasset_crea>-%control-assetuuid,
             <ls_createchangeasset_crea>-%control-createdat,
             <ls_createchangeasset_crea>-%control-createdby,
             <ls_createchangeasset_crea>-%control-lastchangedat,
             <ls_createchangeasset_crea>-%control-lastchangedby,
             <ls_createchangeasset_crea>-%control-locallastchangedat.
    ENDLOOP.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Inserting upload data
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    MODIFY ENTITIES OF zr_rtr_createchangeassettp
           ENTITY createchangeasset
           EXECUTE refreshcreatechangeassetrecord
           FROM CORRESPONDING #( it_keys )

           ENTITY createchangeasset
           CREATE AUTO FILL CID WITH lt_createchangeasset_crea

           ENTITY createchangeasset
           CREATE BY \_createchangeassetmsg AUTO FILL CID WITH lt_createchangeassetmsg_crea

           MAPPED DATA(ls_asset_modify_mapped)
           FAILED DATA(ls_asset_modify_failed)
           REPORTED DATA(ls_asset_modify_report).

    cs_failed   = ls_asset_modify_failed.
    cs_reported = ls_asset_modify_report.
    cs_mapped   = ls_asset_modify_mapped.
  ENDMETHOD.

  METHOD delete_all_to_asset_entity.
    DATA lt_createchangeassettp_delt TYPE tt_createchangeassettp_delt.
    DATA lv_message                  TYPE string.

    DATA(ls_key) = it_keys[ 1 ].
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name( ).

    SELECT FROM zr_rtr_createchangeassettp
      FIELDS COUNT(*)
      WHERE createdby   = @lv_uname
        AND isprocessed = @space
      INTO @FINAL(lv_createchangeassettp_rec).

    IF lv_createchangeassettp_rec <= 0.
      MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 004 INTO lv_message.  "##NO_TEXT

      ct_result = VALUE #( ( %cid           = ls_key-%cid
                             %param-message = lv_message ) ).
      RETURN.
    ENDIF.

    SELECT FROM zr_rtr_createchangeassettp
      FIELDS assetuuid
      WHERE createdby   = @lv_uname
        AND isprocessed = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_createchangeassettp_delt.

    IF lines( lt_createchangeassettp_delt ) <= 0.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_rtr_createchangeassettp
           ENTITY createchangeasset
           DELETE FROM CORRESPONDING #( lt_createchangeassettp_delt )

           MAPPED DATA(ls_asset_modify_mapped)
           FAILED DATA(ls_asset_modify_failed)
           REPORTED DATA(ls_asset_modify_report).

    IF cs_failed-createchangeasset IS INITIAL.
      MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER 005 INTO lv_message.  "##NO_TEXT

      ct_result = VALUE #( ( %cid           = ls_key-%cid
                             %param-message = lv_message ) ).
    ENDIF.

    cs_failed   = ls_asset_modify_failed.
    cs_reported = ls_asset_modify_report.
    cs_mapped   = ls_asset_modify_mapped.
  ENDMETHOD.

  METHOD handle_asset_message_entity.
    IF ct_message_delt IS NOT INITIAL.
      MODIFY ENTITIES OF zr_rtr_createchangeassettp
             ENTITY createchangeassetmsg
             DELETE FROM CORRESPONDING #( ct_message_delt )
             " TODO: variable is assigned but never used (ABAP cleaner)
             FAILED   FINAL(ls_failed_delt).
    ENDIF.

    IF ct_message_crea IS NOT INITIAL.
      MODIFY ENTITIES OF zr_rtr_createchangeassettp
             ENTITY createchangeasset
             CREATE BY \_createchangeassetmsg AUTO FILL CID WITH ct_message_crea
             " TODO: variable is assigned but never used (ABAP cleaner)
             REPORTED FINAL(ls_reported_crea)
             " TODO: variable is assigned but never used (ABAP cleaner)
             FAILED   FINAL(ls_failed_crea)
             " TODO: variable is assigned but never used (ABAP cleaner)
             MAPPED   FINAL(ls_mapped_crea).
    ENDIF.
  ENDMETHOD.

  METHOD simulate_asset_master.
    post_create_change_asset( EXPORTING it_keys_simu = it_keys
                                        iv_set_simu  = abap_true
                              CHANGING  " ct_result_simu = ct_result
                                        cs_mapped    = cs_mapped
                                        cs_failed    = cs_failed
                                        cs_reported  = cs_reported ).
  ENDMETHOD.

  METHOD post_asset_master.
    post_create_change_asset( EXPORTING it_keys_post = it_keys
                                        iv_set_simu  = space
                              CHANGING  " ct_result_post = ct_result
                                        cs_mapped    = cs_mapped
                                        cs_failed    = cs_failed
                                        cs_reported  = cs_reported ).
  ENDMETHOD.

  METHOD post_create_change_asset.
    DATA lt_result            TYPE TABLE FOR READ RESULT zr_rtr_createchangeassettp\\createchangeasset.
    DATA lt_result_update     TYPE TABLE FOR UPDATE zr_rtr_createchangeassettp\\createchangeasset.
    DATA lt_processes         TYPE cl_abap_parallel=>t_in_inst_tab.

    DATA lo_createchangeasset TYPE REF TO zcl_rtr_createchangeasset_main.

    IF it_keys_simu IS SUPPLIED.
      READ ENTITIES OF zr_rtr_createchangeassettp
           ENTITY createchangeasset
           ALL FIELDS WITH CORRESPONDING #( it_keys_simu )
           RESULT lt_result.
    ELSEIF it_keys_post IS SUPPLIED.
      READ ENTITIES OF zr_rtr_createchangeassettp
           ENTITY createchangeasset
           ALL FIELDS WITH CORRESPONDING #( it_keys_post )
           RESULT lt_result.
    ELSE.
      RETURN.
    ENDIF.

    IF lines( lt_result ) IS INITIAL.
      RETURN.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Check Mandatory fields
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    mt_message_delt = VALUE #( FOR ls_message_read IN _get_message_result( lt_result )
                               ( CORRESPONDING #( ls_message_read ) ) ).

    handle_asset_message_entity( CHANGING ct_message_delt = mt_message_delt ).

    _check_mandatory_fields( EXPORTING iv_createmode = COND #( WHEN iv_set_simu IS NOT INITIAL
                                                               THEN '1'
                                                               ELSE '2' )
                             CHANGING  ct_result     = lt_result
                                       cs_failed     = cs_failed
                                       cs_reported   = cs_reported ).

    lt_result_update = VALUE #( FOR <ls_result_upd> IN lt_result
                                WHERE ( returntype IS NOT INITIAL )
                                ( %data    = CORRESPONDING #( <ls_result_upd> MAPPING isprocessed = DEFAULT space )
                                  %control = VALUE #( returnmessage = if_abap_behv=>mk-on
                                                      isprocessed   = if_abap_behv=>mk-on
                                                      runtype       = if_abap_behv=>mk-on
                                                      returntype    = if_abap_behv=>mk-on ) ) ).
    IF lt_result_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_rtr_createchangeassettp
             ENTITY createchangeasset
             UPDATE FROM lt_result_update
             FAILED   cs_failed
             MAPPED   cs_mapped
             REPORTED cs_reported.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Preparing Parallel process
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    CLEAR: mt_message_delt,
           mt_message_crea.

    DELETE lt_result WHERE returntype IS NOT INITIAL.

    IF lt_result IS NOT INITIAL.
      LOOP AT lt_result INTO DATA(ls_result).
        lo_createchangeasset = NEW #( ).
        lo_createchangeasset->set_createchangeassettp_read( is_result   = ls_result
                                                            iv_append   = space
                                                            iv_set_simu = iv_set_simu ).
        INSERT lo_createchangeasset INTO TABLE lt_processes.
      ENDLOOP.

      CLEAR lt_result.

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Run Parallel process
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      NEW cl_abap_parallel( )->run_inst( EXPORTING p_in_tab  = lt_processes
                                         IMPORTING p_out_tab = DATA(lt_finished) ).

      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Get data after Parallel process had been done
      """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      LOOP AT lt_finished INTO DATA(ls_finished).
        CAST zcl_rtr_createchangeasset_main( ls_finished-inst )->get_createchangeassettp_read(
                                                                IMPORTING et_result       = lt_result
                                                                          et_message_delt = DATA(lt_message_delt)
                                                                          et_message_crea = DATA(lt_message_crea) ).

        LOOP AT lt_result INTO ls_result.
*        IF it_keys_simu IS SUPPLIED.
*          ct_result_simu = VALUE #( ( %cid_ref     = VALUE #( it_keys_simu[ KEY id
*                                                                            %tky = ls_result-%tky ]-%cid_ref OPTIONAL )
*                                      %tky         = ls_result-%tky
*                                      %param-%data = CORRESPONDING #( ls_result-%data ) ) ).
*        ELSEIF it_keys_post IS SUPPLIED.
*          ct_result_post = VALUE #( ( %cid_ref     = VALUE #( it_keys_simu[ KEY id
*                                                                            %tky = ls_result-%tky ]-%cid_ref OPTIONAL )
*                                      %tky         = ls_result-%tky
*                                      %param-%data = CORRESPONDING #( ls_result-%data ) ) ).
*        ENDIF.

          INSERT CORRESPONDING #( ls_result ) INTO TABLE lt_result_update ASSIGNING FIELD-SYMBOL(<ls_result_update>).
          <ls_result_update>-isprocessed = space.
          <ls_result_update>-%control    = VALUE #( masterfixedasset = if_abap_behv=>mk-on
                                                    companycode      = if_abap_behv=>mk-on
                                                    fixedasset       = if_abap_behv=>mk-on
                                                    isprocessed      = if_abap_behv=>mk-on
                                                    returnmessage    = if_abap_behv=>mk-on
                                                    runtype          = if_abap_behv=>mk-on
                                                    returntype       = if_abap_behv=>mk-on ).
        ENDLOOP.

        mt_message_delt = VALUE #( BASE mt_message_delt
                                   ( LINES OF lt_message_delt ) ).
        mt_message_crea = VALUE #( BASE mt_message_crea
                                   ( LINES OF lt_message_crea ) ).
      ENDLOOP.

      MODIFY ENTITIES OF zr_rtr_createchangeassettp
             ENTITY createchangeasset
             UPDATE FROM lt_result_update
             FAILED   cs_failed
             MAPPED   cs_mapped
             REPORTED cs_reported.
    ENDIF.

    IF     cs_mapped-createchangeasset IS INITIAL
       AND lt_result_update            IS NOT INITIAL.
      cs_mapped-createchangeasset = VALUE #( FOR <ls_result_update_2> IN lt_result_update
                                             ( %tky = <ls_result_update_2>-%tky ) ).
    ENDIF.

    IF iv_commit_entites IS NOT INITIAL.
      COMMIT ENTITIES.
    ENDIF.

    handle_asset_message_entity( CHANGING ct_message_crea = mt_message_crea
                                          ct_message_delt = mt_message_delt ).
  ENDMETHOD.

  METHOD _check_mandatory_fields.
    DATA lt_companycode_range   TYPE RANGE OF i_companycode-company.
    DATA lt_no_depreciation_key TYPE RANGE OF zcl_t2_bapi_fixedasset_create=>bapi1022_dep_areas-dep_key.

    CLEAR: mt_message_read,
           mt_message_crea,
           mt_message_updt,
           mt_message_delt.

    _check_abap_config( CHANGING co_abap_config = mo_abap_config ).

    mo_abap_config->get_range_value( EXPORTING iv_identifier = 'NO_DEPRECIATION_KEY'
                                     IMPORTING et_range      = lt_no_depreciation_key ).

    mt_message_read = _get_message_result( ct_result ).

    LOOP AT ct_result ASSIGNING FIELD-SYMBOL(<ls_result>)
         WHERE     returntype <> c_addi_msgtype-terminate
               AND returntype <> CONV symsgid( if_abap_behv_message=>severity-success )
         GROUP BY ( processmode = <ls_result>-processmode
                    size        = GROUP SIZE
                    index       = GROUP INDEX )
         ASSIGNING FIELD-SYMBOL(<lsg_result>).

      CLEAR mv_tabix.

      LOOP AT GROUP <lsg_result> ASSIGNING FIELD-SYMBOL(<ls_result_grp>).
        CLEAR: <ls_result_grp>-returnmessage,
               <ls_result_grp>-returntype,
               <ls_result_grp>-returntypedescription,
               <ls_result_grp>-returncriticalitycode.
      ENDLOOP.

      LOOP AT GROUP <lsg_result> ASSIGNING <ls_result_grp>.
        CASE to_upper( <ls_result_grp>-processmode ).
          WHEN c_processmode-create             " Create
            OR c_processmode-create_ex          " Create-Ex
            OR c_processmode-create_sub.        " Create-Sub
            CASE to_upper( <ls_result_grp>-processmode ).
              WHEN c_processmode-create         " Create
                OR c_processmode-create_ex.     " Create-Ex
                IF <ls_result_grp>-assetclass IS INITIAL.                   " Asset Class
                  _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Class'                   ##NO_TEXT
                                                        iv_createmode = iv_createmode
                                                        iv_messageno  = '003'
                                              CHANGING  cs_result     = <ls_result_grp>
                                                        cs_failed     = cs_failed
                                                        cs_reported   = cs_reported ).
                ENDIF.
              WHEN c_processmode-create_sub.    " Create-Sub
                IF <ls_result_grp>-masterfixedasset IS INITIAL.             " Asset No.
                  _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset No.'                     ##NO_TEXT
                                                        iv_createmode = iv_createmode
                                                        iv_messageno  = '003'
                                              CHANGING  cs_result     = <ls_result_grp>
                                                        cs_failed     = cs_failed
                                                        cs_reported   = cs_reported ).
                ENDIF.
            ENDCASE.

            IF <ls_result_grp>-companycode IS INITIAL.                      " Company code
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Company code'                      ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-fixedassetdescription IS INITIAL.            " Description 1
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Description'                 ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-assetadditionaldescription IS INITIAL.       " Description 2
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Description (2)'             ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-baseunit IS INITIAL.                         " UOM
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Base Unit'                         ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-costcenter IS INITIAL.                       " Cost center
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Cost center'                       ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-plant IS INITIAL.                            " Plant
              IF mo_abap_config IS BOUND.
                mo_abap_config->get_range_value( EXPORTING iv_identifier = 'COMPANYCODE'
                                                           iv_parameter1 = 'EXCEPT'
                                                           iv_parameter2 = 'PLANT'
                                                 IMPORTING et_range      = lt_companycode_range ).
              ENDIF.

              IF     NOT <ls_result_grp>-companycode IN lt_companycode_range
                 AND     lt_companycode_range        IS NOT INITIAL.
                _build_mandatory_to_failed( EXPORTING iv_text       = 'Plant'                           ##NO_TEXT
                                                      iv_createmode = iv_createmode
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
            IF <ls_result_grp>-group2assetevaluationkey IS INITIAL.         " BOI Number
              _build_mandatory_to_failed( EXPORTING iv_text       = 'BOI Number'                        ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-group3assetevaluationkey IS INITIAL.         " Asset Condition
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Condition'                   ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-group4assetevaluationkey IS INITIAL.         " Insurance Type
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Insurance Type'                    ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-group5assetevaluationkey IS INITIAL.         " Asset Type
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Type'                        ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     <ls_result_grp>-assetstatusnewpurchase IS NOT INITIAL
               AND <ls_result_grp>-assetstatususepurchase IS NOT INITIAL.
              _build_mandatory_to_failed( EXPORTING iv_messageno  = '022'
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-depreciationkeyanlb01 IS INITIAL.            " Depreciation Key (01)
              _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Year (01)'             ##NO_TEXT
                                                    iv_msgv2      = '999'
                                                    iv_createmode = iv_createmode
                                                    iv_messageno  = '021'
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     NOT <ls_result_grp>-depreciationkeyanlb01 IN lt_no_depreciation_key
               AND     lt_no_depreciation_key                IS NOT INITIAL.
              IF     <ls_result_grp>-usefullifeinyearsanlb01   IS INITIAL           " Useful life Year (01)
                 AND <ls_result_grp>-usefullifeinperiodsanlb01 IS INITIAL.          " Useful life Period (01)
                _build_mandatory_to_failed(
                  EXPORTING iv_text       = 'Useful life Year (01) and Useful life Period (01)' ##NO_TEXT
                            iv_createmode = iv_createmode
                  CHANGING  cs_result     = <ls_result_grp>
                            cs_failed     = cs_failed
                            cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinyearsanlb01 > 999.          " Useful life Year (01)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Year (01)'             ##NO_TEXT
                                                      iv_msgv2      = '999'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinperiodsanlb01 > 12.        " Useful life Period (01)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Period (01)'             ##NO_TEXT
                                                      iv_msgv2      = '12'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
            IF <ls_result_grp>-depreciationkeyanlb15 IS INITIAL.            " Depreciation Key (15)
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Depreciation Key (15)'             ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     NOT <ls_result_grp>-depreciationkeyanlb15 IN lt_no_depreciation_key
               AND     lt_no_depreciation_key                IS NOT INITIAL.
              IF     <ls_result_grp>-usefullifeinyearsanlb15   IS INITIAL           " Useful life Year (15)
                 AND <ls_result_grp>-usefullifeinperiodsanlb15 IS INITIAL.          " Useful life Period (15)
                _build_mandatory_to_failed(
                  EXPORTING iv_text       = 'Useful life Year (15) and Useful life Period (15)' ##NO_TEXT
                            iv_createmode = iv_createmode
                  CHANGING  cs_result     = <ls_result_grp>
                            cs_failed     = cs_failed
                            cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinyearsanlb15 > 999.          " Useful life Year (15)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Year (15)'             ##NO_TEXT
                                                      iv_msgv2      = '999'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinperiodsanlb15 > 12.        " Useful life Period (15)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Period (15)'             ##NO_TEXT
                                                      iv_msgv2      = '12'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
          WHEN c_processmode-change.            " Change
            IF <ls_result_grp>-masterfixedasset IS INITIAL.                 " Asset No.
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset No.'                         ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                                    iv_messageno  = '003'
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-companycode IS INITIAL.                      " Company code
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Company code'                      ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF <ls_result_grp>-fixedasset IS INITIAL.                 " Sub-number
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Sub-number'                        ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                                    iv_messageno  = '003'
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-fixedassetdescription ) IS NOT INITIAL.   " Description 1
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Description'                 ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-assetadditionaldescription ) IS NOT INITIAL. " Description 2
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Description (2)'             ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-baseunit ) IS NOT INITIAL.    " UOM
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Base Unit'                         ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-costcenter ) IS NOT INITIAL.  " Cost center
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Cost center'                       ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-plant ) IS NOT INITIAL.      " Plant
              IF mo_abap_config IS BOUND.
                mo_abap_config->get_range_value( EXPORTING iv_identifier = 'COMPANYCODE'
                                                           iv_parameter1 = 'EXCEPT'
                                                           iv_parameter2 = 'PLANT'
                                                 IMPORTING et_range      = lt_companycode_range ).
              ENDIF.

              IF     NOT <ls_result_grp>-companycode IN lt_companycode_range
                 AND     lt_companycode_range        IS NOT INITIAL.
                _build_mandatory_to_failed( EXPORTING iv_text       = 'Plant'                           ##NO_TEXT
                                                      iv_createmode = iv_createmode
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-group2assetevaluationkey ) IS NOT INITIAL.  " BOI Number
              _build_mandatory_to_failed( EXPORTING iv_text       = 'BOI Number'                        ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-group3assetevaluationkey ) IS NOT INITIAL.  " Asset Condition
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Condition'                   ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-group4assetevaluationkey ) IS NOT INITIAL.  " Insurance Type
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Insurance Type'                    ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-group5assetevaluationkey ) IS NOT INITIAL.  " Asset Type
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Asset Type'                        ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     <ls_result_grp>-assetstatusnewpurchase = c_allowed_blank-char
               AND <ls_result_grp>-assetstatususepurchase = c_allowed_blank-char.
              _build_mandatory_to_failed( EXPORTING iv_messageno  = '023'
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ELSEIF     <ls_result_grp>-assetstatusnewpurchase IS NOT INITIAL
                   AND <ls_result_grp>-assetstatususepurchase IS NOT INITIAL.
              _build_mandatory_to_failed( EXPORTING iv_messageno  = '022'
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-depreciationkeyanlb01 ) IS NOT INITIAL.     " Depreciation Key (01)
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Depreciation Key (01)'             ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     <ls_result_grp>-depreciationkeyanlb01 IS NOT INITIAL
               AND (     NOT <ls_result_grp>-depreciationkeyanlb01 IN lt_no_depreciation_key
                     AND     lt_no_depreciation_key                IS NOT INITIAL ).
              IF     <ls_result_grp>-usefullifeinyearsanlb01   IS INITIAL           " Useful life Year (01)
                 AND <ls_result_grp>-usefullifeinperiodsanlb01 IS INITIAL.          " Useful life Period (01)
                _build_mandatory_to_failed(
                  EXPORTING iv_text       = 'Useful life Year (01) and Useful life Period (01)' ##NO_TEXT
                            iv_createmode = iv_createmode
                  CHANGING  cs_result     = <ls_result_grp>
                            cs_failed     = cs_failed
                            cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinyearsanlb01 > 999.          " Useful life Year (01)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Year (01)'             ##NO_TEXT
                                                      iv_msgv2      = '999'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinperiodsanlb01 > 12.        " Useful life Period (01)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Period (01)'             ##NO_TEXT
                                                      iv_msgv2      = '12'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
            IF _check_change_mandatory_field( <ls_result_grp>-depreciationkeyanlb15 ) IS NOT INITIAL.     " Depreciation Key (15)
              _build_mandatory_to_failed( EXPORTING iv_text       = 'Depreciation Key (15)'             ##NO_TEXT
                                                    iv_createmode = iv_createmode
                                          CHANGING  cs_result     = <ls_result_grp>
                                                    cs_failed     = cs_failed
                                                    cs_reported   = cs_reported ).
            ENDIF.
            IF     <ls_result_grp>-depreciationkeyanlb15 IS NOT INITIAL
               AND (     NOT <ls_result_grp>-depreciationkeyanlb15 IN lt_no_depreciation_key
                     AND     lt_no_depreciation_key                IS NOT INITIAL ).
              IF     <ls_result_grp>-usefullifeinyearsanlb15   IS INITIAL           " Useful life Year (15)
                 AND <ls_result_grp>-usefullifeinperiodsanlb15 IS INITIAL.          " Useful life Period (15)
                _build_mandatory_to_failed(
                  EXPORTING iv_text       = 'Useful life Year (15) and Useful life Period (15)' ##NO_TEXT
                            iv_createmode = iv_createmode
                  CHANGING  cs_result     = <ls_result_grp>
                            cs_failed     = cs_failed
                            cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinyearsanlb15 > 999.          " Useful life Year (15)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Year (15)'             ##NO_TEXT
                                                      iv_msgv2      = '999'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ELSEIF <ls_result_grp>-usefullifeinperiodsanlb15 > 12.        " Useful life Period (15)
                _build_mandatory_to_failed( EXPORTING iv_msgv1      = 'Useful life Period (15)'             ##NO_TEXT
                                                      iv_msgv2      = '12'
                                                      iv_createmode = iv_createmode
                                                      iv_messageno  = '021'
                                            CHANGING  cs_result     = <ls_result_grp>
                                                      cs_failed     = cs_failed
                                                      cs_reported   = cs_reported ).
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      mt_message_delt = VALUE #( BASE mt_message_delt
                                 FOR ls_message_read IN mt_message_read
                                 USING KEY id WHERE (     %is_draft = <ls_result_grp>-%is_draft
                                                      AND assetuuid = <ls_result_grp>-assetuuid )
                                 ( CORRESPONDING #( ls_message_read ) ) ).
    ENDLOOP.

    handle_asset_message_entity( CHANGING ct_message_crea = mt_message_crea
                                          ct_message_delt = mt_message_delt ).

    IF ev_has_error IS SUPPLIED.
      IF lines( cs_failed-createchangeasset ) > 0.
        ev_has_error = abap_true.
      ELSE.
        LOOP AT mt_message_crea INTO DATA(ls_message_crea).
          IF line_exists( ls_message_crea-%target[
                              returntype = CONV symsgty( if_abap_behv_message=>severity-error ) ] ).
            ev_has_error = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _preparing_asset.
    DATA lt_companycode_range TYPE RANGE OF i_companycode-company.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    CLEAR: ms_asset_key,
           ms_generaldata,
           ms_generaldatax,
           ms_inventory,
           ms_inventoryx,
           ms_timedependentdata,
           ms_timedependentdatax,
           ms_allocations,
           ms_allocationsx,
           ms_origin,
           ms_originx,
           ms_investacctassignmnt,
           ms_investacctassignmntx,
           ms_leasing,
           ms_leasingx,
           ms_depreciationareas,
           ms_depreciationareasx,
           mt_depreciationareas,
           mt_depreciationareasx,
           mt_extensionin.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    _check_abap_config( CHANGING co_abap_config = mo_abap_config ).

    " Key
    ms_asset_key = VALUE #( companycode = is_result-companycode
                            asset       = is_result-masterfixedasset
                            subnumber   = is_result-fixedasset ).

    " Tab: General
    ms_generaldata = VALUE #(
        assetclass    = is_result-assetclass
        descript      = is_result-fixedassetdescription
        descript2     = is_result-assetadditionaldescription
        main_descript = is_result-masterfixedassetdescription
        serial_no     = is_result-assetserialnumber
        invent_no     = is_result-inventory
        quantity      = is_result-quantity
        base_uom      = is_result-baseunit
        base_uom_iso  = VALUE #( mt_unitofmeasure[ unitofmeasure = is_result-baseunit ]-unitofmeasureisocode OPTIONAL ) ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_generaldata
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_generaldatax ).

    " Tab: Inventory
    ms_inventory = VALUE #( date            = is_result-lastinventorydate
                            note            = is_result-inventorynote
                            include_in_list = COND #( WHEN is_result-lastinventorydate IS NOT INITIAL
                                                        OR is_result-inventorynote     IS NOT INITIAL
                                                      THEN abap_true ) ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_inventory
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_inventoryx ).

    " Tab: Time-dependence
    ms_timedependentdata = VALUE #( from_date  = is_result-validitystartdate
                                    costcenter = is_result-costcenter
                                    resp_cctr  = is_result-responsiblecostcenter
                                    plant      = is_result-plant
                                    location   = is_result-assetlocation
                                    room       = is_result-room
                                    plate_no   = is_result-vehiclelicenseplatenumber
                                    person_no  = is_result-personnelnumber
                                    profit_ctr = is_result-profitcenter
                                    segment    = is_result-segment ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_timedependentdata
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_timedependentdatax ).

    " Tab: Assignments
    ms_allocations = VALUE #( evalgroup1 = is_result-group1assetevaluationkey
                              evalgroup2 = is_result-group2assetevaluationkey
                              evalgroup3 = is_result-group3assetevaluationkey
                              evalgroup4 = is_result-group4assetevaluationkey
                              evalgroup5 = is_result-group5assetevaluationkey
                              assetsupno = is_result-fixedassetgroup ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_allocations
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_allocationsx ).

    " Tab: Origin
    ms_origin = VALUE #(
        LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                      THEN condense( val = to_upper( is_result-currencycode ) )
                                      ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
        IN  vendor_no   = is_result-supplier
            vendor      = is_result-assetsuppliername
            purch_new   = COND #( WHEN is_result-assetstatusnewpurchase = c_allowed_blank-char THEN c_allowed_blank-char
                                  WHEN is_result-assetstatusnewpurchase IS NOT INITIAL         THEN abap_true )
            trade_id    = is_result-partnercompany
            country     = is_result-assetcountryoforigin
            country_iso = VALUE #( mt_country[ country = is_result-assetcountryoforigin ]-countryisocode OPTIONAL )
            type_name   = is_result-assettypename
*            currency    = lv_currencycode
*            currency_iso = VALUE #( mt_currency[ currency = lv_currencycode ]-currencyisocode OPTIONAL )
    ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_origin
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_originx ).

    " See SNOTE 2401977 - How to fill in field "purchased used" in BAPI_FIXEDASSET_CREATE1
    CASE to_upper( iv_processmode ).
      WHEN c_processmode-create                     " CREATE
        OR c_processmode-create_sub                 " CREATE-SUB
        OR c_processmode-create_ex.                 " CREATE-EX'
        IF    is_result-assetstatusnewpurchase IS NOT INITIAL
           OR is_result-assetstatususepurchase IS NOT INITIAL.
          ms_originx-purch_new = abap_true.
        ENDIF.
      WHEN c_processmode-change.
        IF    is_result-assetstatusnewpurchase IS NOT INITIAL
           OR is_result-assetstatususepurchase IS NOT INITIAL.
          ms_originx-purch_new = abap_true.
        ENDIF.
    ENDCASE.

    CLEAR ms_originx-currency_iso.

    " Tab: Account Assignment for Investment
    ms_investacctassignmnt = VALUE #( invest_ord  = is_result-investmentorder
                                      wbs_elem    = ''
                                      wbs_element = is_result-investmentprojectwbselement ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_investacctassignmnt
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_investacctassignmntx ).

    " Tab: Leasing
    ms_leasing = VALUE #(
        LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                      THEN condense( val = to_upper( is_result-currencycode ) )
                                      ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
        IN  company    = is_result-leasesupplier
            agrmnt_no  = is_result-leaseagreement
            agrmntdate = is_result-leaseagreementdate
            noticedate = is_result-leasetermenddate
            start_date = is_result-leasetermstartdate
            lngth_yrs  = is_result-leasedurationinfiscalyears
            lngth_prds = is_result-leasedurationinfiscalperio
            type       = is_result-leasetype
            base_value = is_result-basevalueasnew
*            currency   = lv_currencycode
*            currency_iso = VALUE #( mt_currency[ currency = lv_currencycode ]-currencyisocode OPTIONAL )
            purchprice = is_result-purchaseprice
            text       = is_result-leasedassetnote
            no_paymnts = is_result-noleasepayments
            cycle      = is_result-paymentcycle
            in_advance = COND #( WHEN is_result-advancepayments = c_allowed_blank-char THEN c_allowed_blank-char
                                 WHEN is_result-advancepayments IS NOT INITIAL         THEN abap_true )
            payment    = is_result-leasepayment
            interest   = is_result-annualinterestrate ).

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_leasing
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_leasingx ).
    ms_leasingx-in_advance = abap_true.

    CLEAR: ms_leasingx-currency,
           ms_leasingx-currency_iso.

    " Tab: Depreciation Areas (01)
    CLEAR: ms_depreciationareas,
           ms_depreciationareasx.

    ms_depreciationareas = VALUE #(
        LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                      THEN condense( val = to_upper( is_result-currencycode ) )
                                      ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
        IN  area            = '01'
            dep_key         = is_result-depreciationkeyanlb01
            ulife_yrs       = is_result-usefullifeinyearsanlb01
            ulife_prds      = is_result-usefullifeinperiodsanlb01
*            currency        = lv_currencycode
*            currency_iso    = VALUE #( mt_currency[ currency = lv_currencycode ]-currencyisocode OPTIONAL )
            odep_start_date = is_result-depreciationstartdate01
            scrapvalue      = is_result-scrapamountcocdcrcyanlb01
            neg_values      = COND #( WHEN is_result-negativeamountisallowed01 = c_allowed_blank-char THEN
                                        c_allowed_blank-char
                                      WHEN is_result-negativeamountisallowed01 IS NOT INITIAL THEN
                                        abap_true ) ).

    INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_depreciationareasx ).

    ms_depreciationareasx-area = '01'.

    CASE to_upper( iv_processmode ).
      WHEN c_processmode-create                     " CREATE
        OR c_processmode-create_sub                 " CREATE-SUB
        OR c_processmode-create_ex.                 " CREATE-EX'
        ms_depreciationareasx-ulife_yrs  = abap_true.
        ms_depreciationareasx-ulife_prds = abap_true.
        ms_depreciationareasx-neg_values = abap_true.
      WHEN c_processmode-change.
        IF ms_depreciationareas-neg_values IS NOT INITIAL.
          ms_depreciationareasx-neg_values = abap_true.
        ENDIF.
    ENDCASE.

    CLEAR: ms_depreciationareasx-currency,
           ms_depreciationareasx-currency_iso.

    INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.

    " Tab: Depreciation Areas (15)
    CLEAR: ms_depreciationareas,
           ms_depreciationareasx.

    ms_depreciationareas = VALUE #(
        LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                      THEN condense( val = to_upper( is_result-currencycode ) )
                                      ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
        IN  area            = '15'
            dep_key         = is_result-depreciationkeyanlb15
            ulife_yrs       = is_result-usefullifeinyearsanlb15
            ulife_prds      = is_result-usefullifeinperiodsanlb15
*            currency        = lv_currencycode
*            currency_iso    = VALUE #( mt_currency[ currency = lv_currencycode ]-currencyisocode OPTIONAL )
            odep_start_date = is_result-depreciationstartdate15
            scrapvalue      = is_result-scrapamountcocdcrcyanlb15
            neg_values      = COND #( WHEN is_result-negativeamountisallowed15 = c_allowed_blank-char THEN
                                        c_allowed_blank-char
                                      WHEN is_result-negativeamountisallowed15 IS NOT INITIAL THEN
                                        abap_true ) ).

    INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

    _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                 iv_mark_x_all    = space
                       IMPORTING ev_structure_out = ms_depreciationareasx ).

    ms_depreciationareasx-area = '15'.

    CASE to_upper( iv_processmode ).
      WHEN c_processmode-create                     " CREATE
        OR c_processmode-create_sub                 " CREATE-SUB
        OR c_processmode-create_ex.                 " CREATE-EX'
        ms_depreciationareasx-ulife_yrs  = abap_true.
        ms_depreciationareasx-ulife_prds = abap_true.
        ms_depreciationareasx-neg_values = abap_true.
      WHEN c_processmode-change.
        IF ms_depreciationareas-neg_values IS NOT INITIAL.
          ms_depreciationareasx-neg_values = abap_true.
        ENDIF.
    ENDCASE.

    CLEAR: ms_depreciationareasx-currency,
           ms_depreciationareasx-currency_iso.

    INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.

    " Tab: Depreciation Areas (31)
    IF is_result-scrapamountcocdcrcyanlb31 IS NOT INITIAL.
      CLEAR: ms_depreciationareas,
             ms_depreciationareasx.

      ms_depreciationareas = VALUE #(
          LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                        THEN condense( val = to_upper( is_result-currencycode ) )
                                        ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
          IN  area       = '31'
              scrapvalue = is_result-scrapamountcocdcrcyanlb31 ).

      INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

      _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                   iv_mark_x_all    = space
                         IMPORTING ev_structure_out = ms_depreciationareasx ).

      ms_depreciationareasx-area = '31'.

      CLEAR: ms_depreciationareasx-currency,
             ms_depreciationareasx-currency_iso.

      INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.
    ENDIF.

    " Tab: Depreciation Areas (35)
    IF is_result-scrapamountcocdcrcyanlb35 IS NOT INITIAL.
      CLEAR: ms_depreciationareas,
             ms_depreciationareasx.

      ms_depreciationareas = VALUE #(
          LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                        THEN condense( val = to_upper( is_result-currencycode ) )
                                        ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
          IN  area       = '35'
              scrapvalue = is_result-scrapamountcocdcrcyanlb35 ).

      INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

      _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                   iv_mark_x_all    = space
                         IMPORTING ev_structure_out = ms_depreciationareasx ).

      ms_depreciationareasx-area = '35'.

      CLEAR: ms_depreciationareasx-currency,
             ms_depreciationareasx-currency_iso.

      INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.
    ENDIF.

    IF mo_abap_config IS BOUND.
      CLEAR lt_companycode_range.

      mo_abap_config->get_range_value( EXPORTING iv_identifier = 'COMPANYCODE'
                                                 iv_parameter1 = 'SCRAP_AREA'
                                                 iv_parameter2 = '41_45'
                                       IMPORTING et_range      = lt_companycode_range ).
      IF     is_result-companycode IN lt_companycode_range
         AND lt_companycode_range  IS NOT INITIAL.
        " Tab: Depreciation Areas (41)
        IF is_result-scrapamountcocdcrcyanlb41 IS NOT INITIAL.
          CLEAR: ms_depreciationareas,
                 ms_depreciationareasx.

          ms_depreciationareas = VALUE #(
              LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                            THEN condense( val = to_upper( is_result-currencycode ) )
                                            ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
              IN  area       = '41'
                  scrapvalue = is_result-scrapamountcocdcrcyanlb41 ).

          INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

          _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                       iv_mark_x_all    = space
                             IMPORTING ev_structure_out = ms_depreciationareasx ).

          ms_depreciationareasx-area = '41'.

          CLEAR: ms_depreciationareasx-currency,
                 ms_depreciationareasx-currency_iso.

          INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.
        ENDIF.

        " Tab: Depreciation Areas (45)
        IF is_result-scrapamountcocdcrcyanlb45 IS NOT INITIAL.
          CLEAR: ms_depreciationareas,
                 ms_depreciationareasx.

          ms_depreciationareas = VALUE #(
              LET lv_currencycode = COND #( WHEN is_result-currencycode IS NOT INITIAL
                                            THEN condense( val = to_upper( is_result-currencycode ) )
                                            ELSE VALUE #( mt_companycode[ companycode = is_result-companycode ]-currency DEFAULT c_thb ) )
              IN  area       = '45'
                  scrapvalue = is_result-scrapamountcocdcrcyanlb45 ).

          INSERT ms_depreciationareas INTO TABLE mt_depreciationareas.

          _mark_x_to_fields( EXPORTING iv_structure_in  = ms_depreciationareas
                                       iv_mark_x_all    = space
                             IMPORTING ev_structure_out = ms_depreciationareasx ).

          ms_depreciationareasx-area = '45'.

          CLEAR: ms_depreciationareasx-currency,
                 ms_depreciationareasx-currency_iso.

          INSERT ms_depreciationareasx INTO TABLE mt_depreciationareasx.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE to_upper( iv_processmode ).
      WHEN c_processmode-create.                     " CREATE
      WHEN c_processmode-create_sub.                 " CREATE-SUB
        mv_createsubnumber = abap_true.

*        IF     ms_asset_key-asset       IS NOT INITIAL
*           AND ms_asset_key-companycode IS NOT INITIAL.
*          SELECT FROM i_fixedasset
*            FIELDS fixedasset
*            WHERE companycode      = @ms_asset_key-companycode
*              AND masterfixedasset = @ms_asset_key-asset
*            ORDER BY fixedasset DESCENDING
*            INTO @ms_asset_key-subnumber
*            UP TO 1 ROWS.
*          ENDSELECT.
*          IF sy-subrc IS INITIAL.
*            mv_createsubnumber = abap_true.
*          ENDIF.
*        ENDIF.
      WHEN c_processmode-create_ex.                 " CREATE-EX'

      WHEN c_processmode-change.                    " CHANGE
        _populate_change_before_post( CHANGING cs_any_structure = ms_generaldata ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_inventory ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_timedependentdata ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_allocations ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_origin ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_investacctassignmnt ).
        _populate_change_before_post( CHANGING cs_any_structure = ms_leasing ).
        _populate_change_before_post( CHANGING ct_any_table = mt_depreciationareas ).
    ENDCASE.
  ENDMETHOD.

  METHOD _build_mandatory_to_failed.
    " TODO: parameter CS_FAILED is never used or assigned (ABAP cleaner)
    " TODO: parameter CS_REPORTED is never used or assigned (ABAP cleaner)

    DATA lv_message TYPE string.
    " TODO: parameter CS_FAILED is never used or assigned (ABAP cleaner)
    " TODO: parameter CS_REPORTED is never used or assigned (ABAP cleaner)

    IF iv_fulltext IS SUPPLIED.
      lv_message = iv_fulltext.
    ELSEIF iv_text IS SUPPLIED.
      MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER iv_messageno WITH iv_text
              INTO lv_message ##NEEDED.
    ELSE.
      MESSAGE ID 'ZMRTR_ASSET_MSG_1' TYPE 'E' NUMBER iv_messageno
              WITH iv_msgv1 iv_msgv2 iv_msgv3 iv_msgv4
              INTO lv_message ##NEEDED.
    ENDIF.

    cs_result-returntype    = CONV #( if_abap_behv_message=>severity-error ).
    cs_result-runtype       = COND #( WHEN iv_createmode = '1' THEN c_runtype-simulate
                                      WHEN iv_createmode = '2' THEN c_runtype-posting ).
    cs_result-returnmessage = COND #( WHEN cs_result-returnmessage IS INITIAL
                                      THEN lv_message
                                      ELSE cs_result-returnmessage ).

    mv_tabix += 1.

    INSERT INITIAL LINE INTO TABLE mt_message_crea ASSIGNING FIELD-SYMBOL(<ls_message_crea>).
    <ls_message_crea> = CORRESPONDING #( cs_result EXCEPT %target ).
    <ls_message_crea>-%target = VALUE #( ( %cid          = |ZCID_CHILD_{ mv_tabix }|
                                           returntype    = CONV #( if_abap_behv_message=>severity-error )
                                           runtype       = COND #( WHEN iv_createmode = '1' THEN c_runtype-simulate
                                                                   WHEN iv_createmode = '2' THEN c_runtype-posting )
                                           returnmessage = lv_message
                                           %control      = VALUE #( returntype    = if_abap_behv=>mk-on
                                                                    runtype       = if_abap_behv=>mk-on
                                                                    returnmessage = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD _mark_x_to_fields.
    DATA lv_index TYPE sy-index.

    CLEAR ev_structure_out.

    IF ev_structure_out IS NOT SUPPLIED.
      RETURN.
    ENDIF.

    DO.
      lv_index = sy-index.

      IF iv_mark_x_all IS INITIAL.
        ASSIGN COMPONENT lv_index OF STRUCTURE iv_structure_in TO FIELD-SYMBOL(<lv_val_source>) ELSE UNASSIGN.
        IF sy-subrc = 0.
          ASSIGN COMPONENT lv_index OF STRUCTURE ev_structure_out TO FIELD-SYMBOL(<lv_val_target>) ELSE UNASSIGN.
          IF sy-subrc = 0.
            IF <lv_val_source> IS NOT INITIAL.
              <lv_val_target> = abap_true.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        ASSIGN COMPONENT lv_index OF STRUCTURE ev_structure_out TO <lv_val_target> ELSE UNASSIGN.
        IF sy-subrc = 0.
          <lv_val_target> = abap_true.
        ELSE.
          EXIT.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD _get_data_from_data_definition.
    DATA lt_unitofmeasure TYPE SORTED TABLE OF i_unitofmeasure WITH UNIQUE KEY unitofmeasure.
    DATA lt_country       TYPE SORTED TABLE OF i_country WITH UNIQUE KEY country.
    DATA lt_companycode   TYPE SORTED TABLE OF i_companycode WITH UNIQUE KEY companycode.
    DATA lt_currencycode  TYPE SORTED TABLE OF i_currency WITH UNIQUE KEY currency.

    CLEAR: mt_unitofmeasure,
           mt_country,
           mt_companycode,
           mt_currency.

    IF it_result IS INITIAL.
      RETURN.
    ENDIF.

    lt_unitofmeasure = CORRESPONDING #( it_result DISCARDING DUPLICATES MAPPING unitofmeasure = baseunit ).
    lt_companycode = CORRESPONDING #( it_result DISCARDING DUPLICATES MAPPING companycode = companycode ).

    IF lt_unitofmeasure IS NOT INITIAL.
      SELECT
        FROM i_unitofmeasure
               INNER JOIN
                 @lt_unitofmeasure AS zit_unitofmeasure ON i_unitofmeasure~unitofmeasure = zit_unitofmeasure~unitofmeasure
        FIELDS i_unitofmeasure~unitofmeasure,
               i_unitofmeasure~unitofmeasureisocode,
               i_unitofmeasure~unitofmeasuresapcode
        INTO CORRESPONDING FIELDS OF TABLE @mt_unitofmeasure
        PRIVILEGED ACCESS.
    ENDIF.

    IF lt_companycode IS NOT INITIAL.
      SELECT
        FROM i_companycode
               INNER JOIN
                 @lt_companycode AS zit_companycode ON i_companycode~companycode = zit_companycode~companycode
        FIELDS i_companycode~companycode,
               i_companycode~country,
               i_companycode~currency
        INTO CORRESPONDING FIELDS OF TABLE @mt_companycode
        PRIVILEGED ACCESS.
    ENDIF.

    lt_country = CORRESPONDING #( it_result DISCARDING DUPLICATES MAPPING country = assetcountryoforigin ).
    lt_country = CORRESPONDING #( BASE ( lt_country ) mt_companycode DISCARDING DUPLICATES MAPPING country = country ).
    lt_currencycode = CORRESPONDING #( mt_companycode DISCARDING DUPLICATES MAPPING currency = currency ).

    IF lt_country IS NOT INITIAL.
      SELECT
        FROM i_country
               INNER JOIN
                 @lt_country AS zit_country ON i_country~country = zit_country~country
        FIELDS i_country~country,
               i_country~countryisocode
        INTO CORRESPONDING FIELDS OF TABLE @mt_country
        PRIVILEGED ACCESS.
    ENDIF.

    IF lt_currencycode IS NOT INITIAL.
      SELECT
        FROM i_currency
               INNER JOIN
                 @lt_currencycode AS zit_currencycode ON i_currency~currency = zit_currencycode~currency
        FIELDS i_currency~currency,
               i_currency~currencyisocode
        INTO CORRESPONDING FIELDS OF TABLE @mt_currency
        PRIVILEGED ACCESS.
    ENDIF.
  ENDMETHOD.

  METHOD _get_message_result.
    IF it_result IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_rtr_createchangeassettp
         ENTITY createchangeasset BY \_createchangeassetmsg
         FIELDS ( returnmsguuid assetuuid ) WITH VALUE #( FOR ls_result IN it_result
                                                          ( assetuuid = ls_result-assetuuid ) )
         RESULT rt_message_read.
  ENDMETHOD.

  METHOD if_abap_parallel~do.
    DATA lt_depreciationareas  TYPE zcl_t2_bapi_fixedasset_change=>_bapi1022_dep_areas.
    DATA lt_depreciationareasx TYPE zcl_t2_bapi_fixedasset_change=>_bapi1022_dep_areasx.

    DATA lv_testrun            TYPE abap_boolean.
    DATA lv_dest               TYPE rfcdest                                             VALUE 'NONE'.
    DATA lv_contain_error      TYPE c LENGTH 3                                          VALUE 'EAX'.

    CLEAR: mt_message_read,
           mt_message_crea,
           mt_message_updt,
           mt_message_delt.

    _get_data_from_data_definition( mt_result ).

    mt_message_read = _get_message_result( mt_result ).

    lv_testrun = COND #( WHEN mv_simulate IS NOT INITIAL THEN abap_true ).

    LOOP AT mt_result ASSIGNING FIELD-SYMBOL(<ls_result>) WHERE returntype IS INITIAL.

      _preparing_asset( is_result      = <ls_result>
                        iv_processmode = to_upper( <ls_result>-processmode ) ).

      TRY.
          CASE to_upper( <ls_result>-processmode ).
            WHEN c_processmode-create
              OR c_processmode-create_sub
              OR c_processmode-create_ex.
              """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
              " Create new Fixed Asset
              """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
              zcl_t2_bapi_fixedasset_create=>bapi_fixedasset_create1(
                EXPORTING allocations          = ms_allocations
                          allocationsx         = ms_allocationsx
                          createsubnumber      = mv_createsubnumber
                          generaldata          = ms_generaldata
                          generaldatax         = ms_generaldatax
                          inventory            = ms_inventory
                          inventoryx           = ms_inventoryx
                          investacctassignmnt  = ms_investacctassignmnt
                          investacctassignmntx = ms_investacctassignmntx
                          key                  = ms_asset_key
                          leasing              = ms_leasing
                          leasingx             = ms_leasingx
                          origin               = ms_origin
                          originx              = ms_originx
                          testrun              = lv_testrun
                          timedependentdata    = ms_timedependentdata
                          timedependentdatax   = ms_timedependentdatax
                          _dest_               = lv_dest
                IMPORTING asset                = mv_asset
                          assetcreated         = ms_assetcreated
                          companycode          = mv_companycode
                          return               = ms_return
                          subnumber            = mv_subnumber
                CHANGING  depreciationareas    = mt_depreciationareas
                          depreciationareasx   = mt_depreciationareasx
                          extensionin          = mt_extensionin ).

              IF NOT ms_return-type CA lv_contain_error.
                CASE to_upper( <ls_result>-processmode ).
                  WHEN c_processmode-create.
                    IF ms_assetcreated IS NOT INITIAL.
                      <ls_result>-masterfixedasset = ms_assetcreated-asset.
                      <ls_result>-companycode      = ms_assetcreated-companycode.
                      <ls_result>-fixedasset       = ms_assetcreated-subnumber.
                    ENDIF.
                  WHEN c_processmode-create_sub
                    OR c_processmode-create_ex.
                    <ls_result>-masterfixedasset = COND #( WHEN ms_assetcreated-asset IS NOT INITIAL
                                                           THEN ms_assetcreated-asset
                                                           ELSE <ls_result>-masterfixedasset ).
                    <ls_result>-companycode      = COND #( WHEN ms_assetcreated-companycode IS NOT INITIAL
                                                           THEN ms_assetcreated-companycode
                                                           ELSE <ls_result>-companycode ).
                    <ls_result>-fixedasset       = COND #( WHEN ms_assetcreated-subnumber IS NOT INITIAL
                                                           THEN ms_assetcreated-subnumber
                                                           ELSE <ls_result>-fixedasset ).
                ENDCASE.
              ENDIF.
            WHEN c_processmode-change.
              """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
              " Change Fixed Asset
              """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
              lt_depreciationareas  = CORRESPONDING zcl_t2_bapi_fixedasset_change=>_bapi1022_dep_areas( mt_depreciationareas ).
              lt_depreciationareasx = CORRESPONDING zcl_t2_bapi_fixedasset_change=>_bapi1022_dep_areasx( mt_depreciationareasx ).
              DATA(lt_extensionin) = CORRESPONDING zcl_t2_bapi_fixedasset_change=>_bapiparex( mt_extensionin ).

              zcl_t2_bapi_fixedasset_change=>bapi_fixedasset_change(
                EXPORTING allocations          = CORRESPONDING #( ms_allocations )
                          allocationsx         = CORRESPONDING #( ms_allocationsx )
                          asset                = ms_asset_key-asset
                          companycode          = ms_asset_key-companycode
                          generaldata          = CORRESPONDING #( ms_generaldata )
                          generaldatax         = CORRESPONDING #( ms_generaldatax )
                          inventory            = CORRESPONDING #( ms_inventory )
                          inventoryx           = CORRESPONDING #( ms_inventoryx )
                          investacctassignmnt  = CORRESPONDING #( ms_investacctassignmnt )
                          investacctassignmntx = CORRESPONDING #( ms_investacctassignmntx )
                          leasing              = CORRESPONDING #( ms_leasing )
                          leasingx             = CORRESPONDING #( ms_leasingx )
                          origin               = CORRESPONDING #( ms_origin )
                          originx              = CORRESPONDING #( ms_originx )
                          subnumber            = ms_asset_key-subnumber
                          timedependentdata    = CORRESPONDING #( ms_timedependentdata )
                          timedependentdatax   = CORRESPONDING #( ms_timedependentdatax )
                          _dest_               = lv_dest
                IMPORTING return               = ms_return
                CHANGING  depreciationareas    = lt_depreciationareas
                          depreciationareasx   = lt_depreciationareasx
                          extensionin          = lt_extensionin ).
          ENDCASE.

          IF ms_return-type CA lv_contain_error.
            <ls_result>-returntype    = CONV #( if_abap_behv_message=>severity-error ).    " Error
            <ls_result>-returnmessage = ms_return-message.
          ELSE.
            <ls_result>-returntype    = COND #( WHEN mv_simulate IS NOT INITIAL
                                                THEN c_addi_msgtype-simulate_success                        " Simulate Success
                                                ELSE CONV #( if_abap_behv_message=>severity-success ) ).    " Success
            <ls_result>-returnmessage = ms_return-message.
          ENDIF.

          <ls_result>-runtype = COND #( WHEN mv_simulate IS NOT INITIAL
                                        THEN c_runtype-simulate      " Simulate Success
                                        ELSE c_runtype-posting ).    " Success

          IF mv_simulate IS NOT INITIAL.
            zcl_t2_bapi_transaction=>bapi_transaction_rollback( _dest_ = lv_dest ).
          ELSE.
            IF ms_return-type CA lv_contain_error.
              zcl_t2_bapi_transaction=>bapi_transaction_rollback( _dest_ = lv_dest ).
            ELSE.
              zcl_t2_bapi_transaction=>bapi_transaction_commit( wait   = abap_true
                                                                _dest_ = lv_dest ).

              CASE to_upper( <ls_result>-processmode ).
                WHEN c_processmode-create
                  OR c_processmode-create_sub
                  OR c_processmode-create_ex.
                  CLEAR: lt_depreciationareas,
                         lt_depreciationareasx.

                  LOOP AT mt_depreciationareas INTO DATA(ls_depreciationareas).
                    INSERT INITIAL LINE INTO TABLE lt_depreciationareas ASSIGNING FIELD-SYMBOL(<ls_depreciationareas>).
                    <ls_depreciationareas>-area       = ls_depreciationareas-area.
                    <ls_depreciationareas>-scrapvalue = ls_depreciationareas-scrapvalue.

                    INSERT INITIAL LINE INTO TABLE lt_depreciationareasx ASSIGNING FIELD-SYMBOL(<ls_depreciationareasx>).
                    <ls_depreciationareasx>-area       = ls_depreciationareas-area.
                    <ls_depreciationareasx>-scrapvalue = COND #( WHEN <ls_depreciationareas>-scrapvalue IS NOT INITIAL
                                                                 THEN abap_true
                                                                 ELSE abap_false ).
                  ENDLOOP.

                  zcl_t2_bapi_fixedasset_change=>bapi_fixedasset_change(
                    EXPORTING asset              = ms_assetcreated-asset
                              companycode        = ms_assetcreated-companycode
                              subnumber          = ms_assetcreated-subnumber
                              _dest_             = lv_dest
                    IMPORTING return             = DATA(ls_return_created_tmp)
                    CHANGING  depreciationareas  = lt_depreciationareas
                              depreciationareasx = lt_depreciationareasx ).
                  IF NOT ls_return_created_tmp-type CA lv_contain_error.
                    zcl_t2_bapi_transaction=>bapi_transaction_commit( wait   = abap_true
                                                                      _dest_ = lv_dest ).
                  ENDIF.
              ENDCASE.
            ENDIF.
          ENDIF.
        CATCH cx_aco_application_exception
              cx_aco_communication_failure
              cx_aco_system_failure INTO DATA(lx_error).
          <ls_result>-returntype    = CONV #( if_abap_behv_message=>severity-error ).    " Error
          <ls_result>-returnmessage = lx_error->get_text( ).
          <ls_result>-runtype       = COND #( WHEN mv_simulate IS NOT INITIAL
                                              THEN c_runtype-simulate      " Simulate Success
                                              ELSE c_runtype-posting ).    " Success
          CONTINUE.
      ENDTRY.

      mv_tabix += 1.        " Reuse for parallel run

      INSERT INITIAL LINE INTO TABLE mt_message_crea ASSIGNING FIELD-SYMBOL(<ls_message_crea>).
      <ls_message_crea> = CORRESPONDING #( <ls_result> EXCEPT %target ).
      <ls_message_crea>-%target = VALUE #(
          ( %cid          = ''      "|%CID_CHILD_{ mv_tabix }|
            returntype    = COND #( WHEN ms_return-type CA lv_contain_error
                                    THEN CONV #( if_abap_behv_message=>severity-error )
                                    ELSE CONV #( if_abap_behv_message=>severity-success ) )
            runtype       = COND #( WHEN mv_simulate IS NOT INITIAL
                                    THEN c_runtype-simulate
                                    ELSE c_runtype-posting )
            returnmessage = ms_return-message
            %control      = VALUE #( returntype    = if_abap_behv=>mk-on
                                     runtype       = if_abap_behv=>mk-on
                                     returnmessage = if_abap_behv=>mk-on ) ) ).

      mt_message_delt = VALUE #( BASE mt_message_delt
                                 FOR ls_message_read IN mt_message_read
                                 USING KEY id WHERE (     %is_draft = <ls_result>-%is_draft
                                                      AND assetuuid = <ls_result>-assetuuid )
                                 ( CORRESPONDING #( ls_message_read ) ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_createchangeassettp_read.
    et_result = mt_result.
    et_message_crea = mt_message_crea.
    et_message_updt = mt_message_updt.
    et_message_delt = mt_message_delt.
  ENDMETHOD.

  METHOD set_createchangeassettp_read.
    IF iv_append IS NOT INITIAL.
      IF it_result IS SUPPLIED.
        mt_result = VALUE #( BASE mt_result
                             ( LINES OF it_result ) ).
      ELSEIF is_result IS SUPPLIED.
        mt_result = VALUE #( BASE mt_result
                             ( is_result ) ).
      ENDIF.
    ELSE.
      IF it_result IS SUPPLIED.
        mt_result = it_result.
      ELSEIF is_result IS SUPPLIED.
        mt_result = VALUE #( ( is_result ) ).
      ENDIF.
    ENDIF.

    mv_simulate = iv_set_simu.
  ENDMETHOD.

  METHOD set_ui_keys.
    mt_keys_simu = it_keys_simu.
    mt_keys_post = it_keys_post.
    mv_simulate  = iv_set_simu.
  ENDMETHOD.

  METHOD get_ui_keys.
    et_keys_simu = mt_keys_simu.
    et_keys_post = mt_keys_post.
    ev_set_simu  = mv_simulate.
  ENDMETHOD.

  METHOD _populate_change_before_post.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_components LIKE LINE OF lt_components.

    FIELD-SYMBOLS <lv_structure> TYPE any.
    FIELD-SYMBOLS <lv_value>     TYPE any.

    IF cs_any_structure IS SUPPLIED.
      zcl_ext_spreadsheet_utilities=>get_abap_dynamic_components( EXPORTING is_structure  = cs_any_structure
                                                                  IMPORTING et_components = lt_components ).

      LOOP AT lt_components INTO ls_components.
        CASE ls_components-type->type_kind.
          WHEN cl_abap_typedescr=>typekind_date.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_any_structure TO <lv_value> ELSE UNASSIGN.
            IF <lv_value> IS ASSIGNED.
              IF <lv_value> = c_allowed_blank-date.
                CLEAR <lv_value>.
              ENDIF.
            ENDIF.
          WHEN cl_abap_typedescr=>typekind_time.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_any_structure TO <lv_value> ELSE UNASSIGN.
            IF <lv_value> IS ASSIGNED.
              IF <lv_value> = c_allowed_blank-time.
                CLEAR <lv_value>.
              ENDIF.
            ENDIF.
          WHEN cl_abap_typedescr=>typekind_num.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_any_structure TO <lv_value> ELSE UNASSIGN.
            IF <lv_value> IS ASSIGNED.
              IF    <lv_value> = c_allowed_blank-numberic1
                 OR <lv_value> = c_allowed_blank-numberic2.
                CLEAR <lv_value>.
              ENDIF.
            ENDIF.
          WHEN cl_abap_typedescr=>typekind_decfloat
            OR cl_abap_typedescr=>typekind_decfloat16
            OR cl_abap_typedescr=>typekind_decfloat34
            OR cl_abap_typedescr=>typekind_float
            OR cl_abap_typedescr=>typekind_int
            OR cl_abap_typedescr=>typekind_int1
            OR cl_abap_typedescr=>typekind_int2
            OR cl_abap_typedescr=>typekind_int8
            OR cl_abap_typedescr=>typekind_intf
            OR cl_abap_typedescr=>typekind_packed.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_any_structure TO <lv_value> ELSE UNASSIGN.
            IF <lv_value> IS ASSIGNED.
              IF <lv_value> < 0.
                CLEAR <lv_value>.
              ENDIF.
            ENDIF.
          WHEN cl_abap_typedescr=>typekind_clike
            OR cl_abap_typedescr=>typekind_simple
            OR cl_abap_typedescr=>typekind_string
            OR cl_abap_typedescr=>typekind_csequence
            OR cl_abap_typedescr=>typekind_char.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE cs_any_structure TO <lv_value> ELSE UNASSIGN.
            IF <lv_value> IS ASSIGNED.
              IF <lv_value> = c_allowed_blank-char.
                CLEAR <lv_value>.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ELSEIF ct_any_table IS SUPPLIED.
      zcl_ext_spreadsheet_utilities=>get_abap_dynamic_components( EXPORTING it_table      = ct_any_table
                                                                  IMPORTING et_components = lt_components ).

      LOOP AT ct_any_table ASSIGNING <lv_structure>.
        LOOP AT lt_components INTO ls_components.
          CASE ls_components-type->type_kind.
            WHEN cl_abap_typedescr=>typekind_date.
              ASSIGN COMPONENT ls_components-name OF STRUCTURE <lv_structure> TO <lv_value> ELSE UNASSIGN.
              IF <lv_value> IS ASSIGNED.
                IF <lv_value> = c_allowed_blank-date.
                  CLEAR <lv_value>.
                ENDIF.
              ENDIF.
            WHEN cl_abap_typedescr=>typekind_time.
              ASSIGN COMPONENT ls_components-name OF STRUCTURE <lv_structure> TO <lv_value> ELSE UNASSIGN.
              IF <lv_value> IS ASSIGNED.
                IF <lv_value> = c_allowed_blank-time.
                  CLEAR <lv_value>.
                ENDIF.
              ENDIF.
            WHEN cl_abap_typedescr=>typekind_num.
              ASSIGN COMPONENT ls_components-name OF STRUCTURE <lv_structure> TO <lv_value> ELSE UNASSIGN.
              IF <lv_value> IS ASSIGNED.
                IF    <lv_value> = c_allowed_blank-numberic1
                   OR <lv_value> = c_allowed_blank-numberic2.
                  CLEAR <lv_value>.
                ENDIF.
              ENDIF.
            WHEN cl_abap_typedescr=>typekind_decfloat
              OR cl_abap_typedescr=>typekind_decfloat16
              OR cl_abap_typedescr=>typekind_decfloat34
              OR cl_abap_typedescr=>typekind_float
              OR cl_abap_typedescr=>typekind_int
              OR cl_abap_typedescr=>typekind_int1
              OR cl_abap_typedescr=>typekind_int2
              OR cl_abap_typedescr=>typekind_int8
              OR cl_abap_typedescr=>typekind_intf
              OR cl_abap_typedescr=>typekind_packed.
              ASSIGN COMPONENT ls_components-name OF STRUCTURE <lv_structure> TO <lv_value> ELSE UNASSIGN.
              IF <lv_value> IS ASSIGNED.
                IF <lv_value> < 0.
                  CLEAR <lv_value>.
                ENDIF.
              ENDIF.
            WHEN cl_abap_typedescr=>typekind_clike
              OR cl_abap_typedescr=>typekind_simple
              OR cl_abap_typedescr=>typekind_string
              OR cl_abap_typedescr=>typekind_csequence
              OR cl_abap_typedescr=>typekind_char.
              ASSIGN COMPONENT ls_components-name OF STRUCTURE <lv_structure> TO <lv_value> ELSE UNASSIGN.
              IF <lv_value> IS ASSIGNED.
                IF <lv_value> = c_allowed_blank-char.
                  CLEAR <lv_value>.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD _check_change_mandatory_field.
    " Describe the data object at runtime
    DATA(lr_typedescr) = cl_abap_typedescr=>describe_by_data( iv_any_field ).

    IF lr_typedescr IS NOT BOUND.
      RETURN.
    ENDIF.

    CASE lr_typedescr->type_kind.
      WHEN cl_abap_typedescr=>typekind_date.
        IF iv_any_field = c_allowed_blank-date.
          rv_mandatory = abap_true.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_time.

        IF iv_any_field = c_allowed_blank-time.
          rv_mandatory = abap_true.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_num.
        IF    iv_any_field = c_allowed_blank-numberic1
           OR iv_any_field = c_allowed_blank-numberic2.
          rv_mandatory = abap_true.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_decfloat
        OR cl_abap_typedescr=>typekind_decfloat16
        OR cl_abap_typedescr=>typekind_decfloat34
        OR cl_abap_typedescr=>typekind_float
        OR cl_abap_typedescr=>typekind_int
        OR cl_abap_typedescr=>typekind_int1
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int8
        OR cl_abap_typedescr=>typekind_intf
        OR cl_abap_typedescr=>typekind_packed.
        IF iv_any_field < 0.
          rv_mandatory = abap_true.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_clike
        OR cl_abap_typedescr=>typekind_simple
        OR cl_abap_typedescr=>typekind_string
        OR cl_abap_typedescr=>typekind_csequence
        OR cl_abap_typedescr=>typekind_char.
        IF iv_any_field = c_allowed_blank-char.
          rv_mandatory = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD _check_abap_config.
    IF co_abap_config IS NOT BOUND.
      TRY.
          co_abap_config = zcl_ext_abap_config=>get_instance( iv_program = 'ZBP_R_RTR_CREATECHANGEASSETTP' ).
        CATCH zcx_ext_abap_config.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*/////////////////////////////////////////////////////////////////////////
*// Project Name: SMILE
*// Created by  : Naruepan M.
*// Created on  : 09.07.2025
*// WRICEF ID   :
*// TR Number   : GSDK900609
*//-----------------------------------------------------------------------
*// Description: VAT Report
*//-----------------------------------------------------------------------
*// Change History
*//-----------------------------------------------------------------------
*// Date |TR Number |Search Term |Developer |Description
*// -------- ----------- ----------- ----------- -------------------------
*// 24.12.2025 GSDK907972 CH01    Potsawat M. Load and save cache
*/////////////////////////////////////////////////////////////////////////

CLASS zcl_ext_custom_entity_utils DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get_sql_query_provider
      IMPORTING io_request                TYPE REF TO if_rap_query_request OPTIONAL
      EXPORTING ev_orderby_string         TYPE string
                ev_select_string          TYPE string
                ev_sql_where_string       TYPE string
                ev_entity_id              TYPE string
                ev_up_to_rows             TYPE int8
                ev_offset                 TYPE int8
                ev_is_ui_identification   TYPE abap_bool
                et_filter_cond            TYPE if_rap_query_filter=>tt_name_range_pairs
                eo_filter_as_tree         TYPE REF TO if_rap_query_filter_tree
                et_parameters             TYPE if_rap_query_request=>tt_parameters
                et_requested_elements     TYPE if_rap_query_request=>tt_requested_elements
                ev_search_expression      TYPE string
                et_sort_elements          TYPE if_rap_query_request=>tt_sort_elements
                et_aggregated_elements    TYPE if_rap_query_aggregation=>tt_aggregation_elements
                et_aggr_grouped_elements  TYPE if_rap_query_aggregation=>tt_grouped_elements
                ev_is_data_requested      TYPE abap_bool
                ev_is_total_rec_requested TYPE abap_bool.

* BOI CH01
    CLASS-METHODS load_cache
      IMPORTING
        io_request                 TYPE REF TO if_rap_query_request OPTIONAL
      EXPORTING
        et_data                    TYPE STANDARD TABLE
        ev_total_number_of_records TYPE int8
      RAISING
        cx_abap_message_digest
        zcx_ext_general_error.

    CLASS-METHODS save_cache
      IMPORTING
        io_request TYPE REF TO if_rap_query_request OPTIONAL
        it_data    TYPE STANDARD TABLE
      RAISING
        cx_abap_message_digest
        zcx_ext_general_error.

    CLASS-METHODS generate_cache_key
      IMPORTING
        io_request          TYPE REF TO if_rap_query_request OPTIONAL
      RETURNING
        VALUE(rv_cache_key) TYPE ze_hash_sha1
      RAISING
        cx_abap_message_digest.
* EOI CH01

ENDCLASS.


CLASS zcl_ext_custom_entity_utils IMPLEMENTATION.
  METHOD get_sql_query_provider.
    CLEAR: ev_orderby_string,
           ev_select_string,
           ev_up_to_rows,
           ev_offset,
           ev_sql_where_string,
           et_parameters,
           et_filter_cond,
           ev_is_ui_identification,
           ev_entity_id,
           ev_is_data_requested,
           ev_is_total_rec_requested,
           et_requested_elements,
           ev_search_expression,
           et_sort_elements,
           et_aggregated_elements,
           et_aggr_grouped_elements,
           eo_filter_as_tree.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Example:
    "     SELECT (lv_select_string) FROM <table>
    "      WHERE (lv_sql_where_string)
    "      ORDER BY (lv_orderby_string)
    "      INTO TABLE @DATA(<internal_table>)
    "      UP TO @lv_uptorow ROWS
    "      OFFSET @lv_offset.
    "
    "  To set Line of io_response->set_total_number_of_records
    "     SELECT COUNT(*) FROM <table> INTO @DATA(lv_total_records).
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    ev_up_to_rows             = io_request->get_paging( )->get_page_size( ). " UP TO @ev_top ROWS
    ev_offset                 = io_request->get_paging( )->get_offset( ).    " OFFSET @ev_skip
    ev_entity_id              = io_request->get_entity_id( ).
    ev_is_data_requested      = io_request->is_data_requested( ).
    ev_is_total_rec_requested = io_request->is_total_numb_of_rec_requested( ).

    " $select handling
    " Use SELECT FROM <DB_TABLE> FIELDS (ev_select_string)
    DATA(lt_fields) = io_request->get_requested_elements( ).

    IF lt_fields IS NOT INITIAL.
      CONCATENATE LINES OF lt_fields INTO ev_select_string SEPARATED BY ','.
    ELSE.
      " check coding. If no columns are specified via $select retrieve all columns from the model instead?
      ev_select_string = '*'.
    ENDIF.

    DATA(lo_filter) = io_request->get_filter( ).

    ev_sql_where_string = lo_filter->get_as_sql_string( ). " WHERE (ev_sql_dyn_where)

    TRY.
        " get and add filter
        et_filter_cond = lo_filter->get_as_ranges( ).   " get_filter_conditions( ).
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    IF eo_filter_as_tree IS SUPPLIED.
      eo_filter_as_tree = lo_filter->get_as_tree( ).
    ENDIF.

    IF ev_up_to_rows = io_request->get_paging( )->page_size_unlimited.
      ev_is_ui_identification = abap_true.
      ev_up_to_rows           = 1.
    ENDIF.

    " $orderby was called
    " Use ORDER BY (ev_orderby_string)
    et_sort_elements = io_request->get_sort_elements( ).

    IF     et_sort_elements IS INITIAL
       AND ev_entity_id     IS NOT INITIAL.
      " Not support Parent(Custom Entity) and Child(Custom Entity)
      DATA(lo_custom_entity) = xco_cp_cds=>custom_entity( EXPORTING iv_name = CONV #( ev_entity_id ) ).
      IF lo_custom_entity IS BOUND.
        TRY.
            DATA(lt_cds_fields) = lo_custom_entity->fields->all->get( ).

            LOOP AT lt_cds_fields INTO DATA(ls_cds_field).
              IF ls_cds_field->content( )->get_key_indicator( ) IS NOT INITIAL.
                INSERT VALUE #( element_name = ls_cds_field->name
                                descending   = space )
                       INTO TABLE et_sort_elements.
              ENDIF.
            ENDLOOP.
          CATCH cx_root.
        ENDTRY.
      ENDIF.
    ENDIF.

    IF     et_sort_elements  IS NOT INITIAL
       AND ev_orderby_string IS SUPPLIED.
      LOOP AT et_sort_elements INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          CONCATENATE ev_orderby_string ls_sort-element_name 'DESCENDING' INTO ev_orderby_string SEPARATED BY space.
        ELSE.
          CONCATENATE ev_orderby_string ls_sort-element_name 'ASCENDING' INTO ev_orderby_string SEPARATED BY space.
        ENDIF.

        IF sy-tabix <> lines( et_sort_elements ).
          CONCATENATE ev_orderby_string ',' INTO ev_orderby_string.
        ENDIF.
      ENDLOOP.

      SHIFT ev_orderby_string LEFT DELETING LEADING space.
    ENDIF.

    IF et_parameters IS SUPPLIED.
      et_parameters = io_request->get_parameters( ).
    ENDIF.

    IF et_requested_elements IS SUPPLIED.
      et_requested_elements = io_request->get_requested_elements( ).
    ENDIF.

    IF ev_search_expression IS SUPPLIED.
      ev_search_expression = io_request->get_search_expression( ).
    ENDIF.

    IF    et_aggregated_elements   IS SUPPLIED
       OR et_aggr_grouped_elements IS SUPPLIED.
      DATA(lo_aggregation) = io_request->get_aggregation( ).

      IF et_aggregated_elements IS SUPPLIED.
        et_aggregated_elements = lo_aggregation->get_aggregated_elements( ).
      ENDIF.

      IF et_aggr_grouped_elements IS SUPPLIED.
        et_aggr_grouped_elements = lo_aggregation->get_grouped_elements( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD load_cache.
* BOI CH01
    get_sql_query_provider(
      EXPORTING
        io_request                = io_request
      IMPORTING
        ev_up_to_rows             = DATA(lv_up_to_rows)
        ev_offset                 = DATA(lv_offset)
        ev_is_data_requested      = DATA(lv_is_data_requested)
        ev_is_total_rec_requested = DATA(lv_is_total_rec_requested)
    ).

    "Skip
    IF lv_offset = 0.
      RAISE EXCEPTION TYPE zcx_ext_general_error
        EXPORTING
          is_textid = VALUE #(
            msgid = 'CNV_PE_UI'
            msgno = '111'
          ).
    ENDIF.

    DATA(lv_cache_key) = generate_cache_key( io_request ).

    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name( ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Table: ZTEXT_0009
    " Key Column client                             clnt(3)
    " Key Column uname        syuname               char(12)    User Name
    " Key Column hash         ze_hash_sha1          char(40)    Hash
    "     Column data         ze_data               string      Data
    "     Column created_by   abp_creation_user     char(12)    Created By User
    "     Column created_at   abp_creation_tstmpl   dec(21,7)   Creation Date Time
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    SELECT SINGLE *
      FROM ztext_0009
      WHERE uname = @lv_uname AND
            hash = @lv_cache_key
      INTO @DATA(ls_ztext_0009).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ext_general_error
        EXPORTING
          is_textid = VALUE #(
            msgid = 'BGRFC'
            msgno = '136'
          ).
    ENDIF.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json  = ls_ztext_0009-data
      CHANGING
        data = et_data
    ).

    IF lv_is_total_rec_requested = abap_true.
      ev_total_number_of_records = lines( et_data ).
    ENDIF.

    DELETE et_data
      TO lv_offset.

    DELETE et_data
      FROM lv_up_to_rows + 1.

    IF lv_is_data_requested = abap_false.
      CLEAR et_data[].
    ENDIF.
* EOI CH01
  ENDMETHOD.

  METHOD save_cache.
* BOI CH01
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Table: ZTEXT_0009
    " Key Column client                             clnt(3)
    " Key Column uname        syuname               char(12)    User Name
    " Key Column hash         ze_hash_sha1          char(40)    Hash
    "     Column data         ze_data               string      Data
    "     Column created_by   abp_creation_user     char(12)    Created By User
    "     Column created_at   abp_creation_tstmpl   dec(21,7)   Creation Date Time
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA:
      ls_ztext_0009 TYPE ztext_0009.

    DATA(lv_cache_key) = generate_cache_key( io_request ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      EXPORTING
        data     = it_data
        compress = abap_true
    ).

    CONVERT DATE cl_abap_context_info=>get_system_date( )
      TIME cl_abap_context_info=>get_system_time( )
      INTO TIME STAMP DATA(lv_ts)
      TIME ZONE 'UTC'.

    ls_ztext_0009-uname = cl_abap_context_info=>get_user_technical_name( ).
    ls_ztext_0009-hash = lv_cache_key.
    ls_ztext_0009-data = lv_json.
    ls_ztext_0009-created_by = cl_abap_context_info=>get_user_technical_name( ).
    ls_ztext_0009-created_at = lv_ts.

    MODIFY ztext_0009
      FROM @ls_ztext_0009.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ext_general_error
        EXPORTING
          is_textid = VALUE #(
            msgid = '/ACCGO/CAS_FLLW_MSG'
            msgno = '045'
            attr1 = 'ZTEXT_0009'
          ).
    ENDIF.

    "Delete Outdated Cache
    DATA(lv_ts_2) = cl_abap_tstmp=>subtractsecs_to_short(
      EXPORTING
        tstmp   = lv_ts
        secs    = '86400'
    ).

    DELETE FROM ztext_0009
      WHERE created_at <= @lv_ts_2.

* EOI CH01
  ENDMETHOD.

  METHOD generate_cache_key.
* BOI CH01
    DATA:
      lv_data TYPE string.

    get_sql_query_provider(
      EXPORTING
        io_request                = io_request
      IMPORTING
        ev_orderby_string         = DATA(lv_orderby_string)
        ev_select_string          = DATA(lv_select_string)
        ev_sql_where_string       = DATA(lv_sql_where_string)
        ev_entity_id              = DATA(lv_entity_id)
    ).

    lv_data = |{ lv_entity_id }{ lv_select_string }{ lv_sql_where_string }{ lv_orderby_string }|.

    cl_abap_message_digest=>calculate_hash_for_char(
      EXPORTING
        if_algorithm     = 'SHA1'
        if_data          = lv_data
      IMPORTING
        ef_hashstring    = DATA(lv_key)
    ).

    rv_cache_key = lv_key.
* EOI CH01
  ENDMETHOD.

ENDCLASS.

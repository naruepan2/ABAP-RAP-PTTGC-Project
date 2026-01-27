*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_abap_behv_msg IMPLEMENTATION.
  METHOD constructor.
    super->constructor( previous = ix_previous ).
    me->mv_msgty = iv_msgty.
    me->mv_msgv1 = iv_msgv1.
    me->mv_msgv2 = iv_msgv2.
    me->mv_msgv3 = iv_msgv3.
    me->mv_msgv4 = iv_msgv4.
    CLEAR me->textid.
    IF is_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = is_textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_abap_utilities_local IMPLEMENTATION.
  METHOD constructor.
    _get_abap_datfm_datatype( ).
  ENDMETHOD.

  METHOD convert_dynamic_extern_value.
    CASE iv_inttype.
      WHEN cl_abap_typedescr=>typekind_date.
        DATA(lv_date_format) = iv_date_format.

        IF lv_date_format IS INITIAL.
          lv_date_format = cl_abap_datfm=>get_datfm( ).
        ENDIF.

        IF contains_any_of( val = iv_value
                            sub = _get_abcde( ) ).
          CLEAR ev_value.
        ELSEIF contains_any_not_of( val = iv_value
                                    sub = './-' ).
          TRY.
              cl_abap_datfm=>conv_date_int_to_ext( EXPORTING im_datint   = CONV d( iv_value )
                                                             im_datfmdes = lv_date_format
                                                   IMPORTING ex_datext   = ev_value ).
            CATCH cx_abap_datfm_format_unknown.
              CLEAR ev_value.
          ENDTRY.
        ELSE.
          ev_value = iv_value.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_time.
        IF contains_any_of( val = iv_value
                            sub = _get_abcde( ) ).
          CLEAR ev_value.
        ELSEIF contains_any_not_of( val = iv_value
                                    sub = ':' ).
          TRY.
              cl_abap_timefm=>conv_time_int_to_ext( EXPORTING time_int            = CONV t( iv_value )
                                                              format_according_to = iv_time_format
                                                    IMPORTING time_ext            = ev_value ).
            CATCH cx_parameter_invalid_range.
              CLEAR ev_value.
          ENDTRY.
        ELSE.
          ev_value = iv_value.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_float
        OR cl_abap_typedescr=>typekind_packed
        OR cl_abap_typedescr=>typekind_decfloat
        OR cl_abap_typedescr=>typekind_decfloat16
        OR cl_abap_typedescr=>typekind_decfloat34
        OR cl_abap_typedescr=>typekind_numeric
        OR cl_abap_typedescr=>typekind_int
        OR cl_abap_typedescr=>typekind_int1
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int8.
        TRY.
            DATA(lr_decfloat34) = NEW decfloat34( iv_value ).

            IF iv_user_format = cl_abap_format=>n_environment.
              ev_value = |{ lr_decfloat34->* NUMBER = ENVIRONMENT }|.
            ELSE.
              ev_value = |{ lr_decfloat34->* NUMBER = USER }|.
            ENDIF.
          CATCH cx_root.
            CLEAR ev_value.
        ENDTRY.
      WHEN cl_abap_typedescr=>typekind_string.
        ev_value = iv_value.
      WHEN cl_abap_typedescr=>typekind_xstring.
        zcl_ext_abap_utilities=>convert_xstring_to_string( EXPORTING iv_xstring = CONV xstring( iv_value )
                                                           IMPORTING ev_string  = ev_value ).
      WHEN cl_abap_typedescr=>typekind_char
        OR cl_abap_typedescr=>typekind_clike
        OR cl_abap_typedescr=>typekind_simple
        OR cl_abap_typedescr=>typekind_num.
        conv_inout_dynamic( EXPORTING iv_value      = iv_value
                                      iv_inout_type = iv_inout_type
                                      iv_convexit   = iv_convexit
                                      iv_typekind   = iv_inttype
                            IMPORTING ev_value      = ev_value ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD convert_dynamic_intern_value.
    DATA lo_descr_ref TYPE REF TO cl_abap_elemdescr.

    CASE iv_inttype.
      WHEN cl_abap_typedescr=>typekind_date.
        DATA(lv_date_format) = VALUE xudatfm( ).
        lv_date_format = iv_date_format.

        IF contains_any_of( val = iv_value
                            sub = './-' ).
          DATA(lv_date_text) = VALUE text10( ).
          lv_date_text = iv_value.

          IF lv_date_format IS NOT INITIAL.
            TRY.
                cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext   = lv_date_text
                                                               im_datfmdes = lv_date_format
                                                     IMPORTING ex_datint   = ev_value ).
              CATCH cx_abap_datfm_no_date
                    cx_abap_datfm_invalid_date
                    cx_abap_datfm_format_unknown
                    cx_abap_datfm_ambiguous.
                ev_value = iv_value.
            ENDTRY.
          ELSE.
            LOOP AT mt_fixed_values INTO FINAL(ls_fixed_values).
              lv_date_format = CONV #( ls_fixed_values-low ).

              TRY.
                  cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext   = lv_date_text
                                                                 im_datfmdes = lv_date_format
                                                       IMPORTING ex_datint   = ev_value ).
                  EXIT.
                CATCH cx_abap_datfm_no_date
                      cx_abap_datfm_invalid_date
                      cx_abap_datfm_format_unknown
                      cx_abap_datfm_ambiguous.
              ENDTRY.
            ENDLOOP.
          ENDIF.
        ELSE.
          ev_value = iv_value.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_time.
        IF contains_any_of( val = iv_value
                            sub = ':' ).
          TRY.
              cl_abap_timefm=>conv_time_ext_to_int( EXPORTING time_ext      = iv_value
                                                              is_24_allowed = abap_true
                                                    IMPORTING time_int      = ev_value ).
            CATCH cx_abap_timefm_invalid.
              ev_value = iv_value.
          ENDTRY.
        ELSE.
          ev_value = iv_value.
        ENDIF.
      WHEN cl_abap_typedescr=>typekind_float
        OR cl_abap_typedescr=>typekind_packed
        OR cl_abap_typedescr=>typekind_decfloat
        OR cl_abap_typedescr=>typekind_decfloat16
        OR cl_abap_typedescr=>typekind_decfloat34
        OR cl_abap_typedescr=>typekind_numeric
        OR cl_abap_typedescr=>typekind_int
        OR cl_abap_typedescr=>typekind_int1
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int2
        OR cl_abap_typedescr=>typekind_int8.
        TRY.
            cl_abap_decfloat=>read_decfloat34( EXPORTING string = iv_value
                                               IMPORTING value  = ev_value ).
          CATCH cx_sy_conversion_overflow
                cx_abap_decfloat_invalid_char
                cx_abap_decfloat_parse_err.
            TRY.
                " Format "1,000,000.00" => remove commas
                REPLACE ALL OCCURRENCES OF PCRE '[+%,]' IN iv_value WITH space.

*                CONDENSE <lf_input_value> NO-GAPS.
*                ev_value = <lf_input_value>.
                ev_value = condense( val = iv_value
                                     to  = `` ).
              CATCH cx_sy_conversion_no_number
                    cx_sy_regex_too_complex.
                CLEAR ev_value.
            ENDTRY.
        ENDTRY.
      WHEN cl_abap_typedescr=>typekind_string.
        ev_value = iv_value.
      WHEN cl_abap_typedescr=>typekind_xstring.
        zcl_ext_abap_utilities=>convert_string_to_xstring( EXPORTING iv_string    = CONV string( iv_value )
                                                           IMPORTING ev_rawstring = ev_value ).
      WHEN cl_abap_typedescr=>typekind_char
        OR cl_abap_typedescr=>typekind_clike
        OR cl_abap_typedescr=>typekind_simple
        OR cl_abap_typedescr=>typekind_num.
        conv_inout_dynamic( EXPORTING iv_value      = iv_value
                                      iv_inout_type = iv_inout_type
                                      iv_convexit   = iv_convexit
                                      iv_typekind   = iv_inttype
                            IMPORTING ev_value      = ev_value ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD conv_inout_dynamic.
    DATA lv_subrc TYPE sy-subrc.

    IF iv_value IS INITIAL.
      RETURN.
    ENDIF.

    CONDENSE iv_value.

    ev_value = iv_value.

    IF iv_convexit IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_conv) = shift_left( val = iv_convexit
                                sub = `==`  ).

    CASE lv_conv.
      WHEN 'ALPHA'.
        CASE iv_inout_type.
          WHEN zcl_ext_abap_utilities=>c_convert_inout_type-external.
            ev_value = |{ ev_value ALPHA = OUT }|.
          WHEN OTHERS.
            ev_value = |{ ev_value ALPHA = IN }|.
        ENDCASE.
      WHEN 'MATN1'.
        TRY.
            zcl_ext_abap_utilities=>get_product( EXPORTING iv_product = iv_value
                                                 IMPORTING es_product = DATA(ls_material) ).

            CASE iv_inout_type.
              WHEN zcl_ext_abap_utilities=>c_convert_inout_type-external.
                ev_value = ls_material-productexternalid.
              WHEN OTHERS.
                ev_value = ls_material-product.
            ENDCASE.
          CATCH cx_root.
        ENDTRY.
      WHEN 'ABPSP'
        OR 'ABPSN'.

        DO 3 TIMES.
          TRY.
              CASE sy-index.
                WHEN 1.
                  zcl_ext_abap_utilities=>get_wbselementdata(
                    EXPORTING iv_wbselementinternalid = iv_value
                    IMPORTING es_wbselementdata       = DATA(ls_wbselementdata)
                              ev_subrc                = lv_subrc ).
                WHEN 2.
                  zcl_ext_abap_utilities=>get_wbselementdata( EXPORTING iv_wbselementexternalid = iv_value
                                                              IMPORTING es_wbselementdata       = ls_wbselementdata
                                                                        ev_subrc                = lv_subrc ).
                WHEN 3.
                  zcl_ext_abap_utilities=>get_wbselementdata( EXPORTING iv_wbselement     = iv_value
                                                              IMPORTING es_wbselementdata = ls_wbselementdata
                                                                        ev_subrc          = lv_subrc ).
              ENDCASE.
            CATCH cx_root.
              CONTINUE.
          ENDTRY.

          CASE iv_inout_type.
            WHEN zcl_ext_abap_utilities=>c_convert_inout_type-external.
              ev_value = ls_wbselementdata-wbselementexternalid.
            WHEN OTHERS.
              ev_value = COND #( WHEN iv_typekind = cl_abap_typedescr=>typekind_num
                                 THEN ls_wbselementdata-wbselementinternalid
                                 ELSE ls_wbselementdata-wbselementexternalid ).
          ENDCASE.

          IF lv_subrc IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.
    ENDCASE.
  ENDMETHOD.

  METHOD check_bank_account_number.
    CLEAR: rv_found,
           ev_msg.

    TRY.
        /atl/cl_il_bank_number_check=>check( iv_bankl    = iv_bankl
                                             iv_bankn    = iv_bankn
                                             iv_s_error  = iv_s_error
                                             iv_res_only = iv_res_only ).
        rv_found = abap_true.
      CATCH cx_fiil_error INTO DATA(lx_error).
        rv_found = abap_false.
        ev_msg   = lx_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_dynamic_describe.
    DATA lo_tabledescr  TYPE REF TO cl_abap_tabledescr.
    DATA lo_structdescr TYPE REF TO cl_abap_structdescr.
    DATA lo_elemdescr   TYPE REF TO cl_abap_elemdescr.
    DATA lt_components  TYPE cl_abap_structdescr=>component_table.
    DATA ls_components  LIKE LINE OF lt_components.

    CLEAR: eo_object,
           ev_object_name,
           et_components.

    TRY.
        DATA(lo_typedescr) = cl_abap_typedescr=>describe_by_data_ref( ir_data ).

        CASE lo_typedescr->type_kind.
          WHEN cl_abap_typedescr=>typekind_table.
            lo_tabledescr  = CAST cl_abap_tabledescr( lo_typedescr ).
            eo_object      = lo_tabledescr.
            ev_object_name = 'CL_ABAP_TABLEDESCR'.

            IF lo_tabledescr IS BOUND.
              lo_structdescr = CAST cl_abap_structdescr( lo_tabledescr->get_table_line_type( ) ).
              lt_components  = lo_structdescr->get_components( ).

              LOOP AT lt_components INTO ls_components.
                IF ls_components-as_include IS INITIAL.
                  et_components = VALUE #( BASE et_components
                                           ( ls_components ) ).
                ELSE.
                  _get_include_describe_fields( EXPORTING io_abap_datadescr = ls_components-type
                                                CHANGING  ct_components     = et_components ).
                ENDIF.
              ENDLOOP.
            ENDIF.
          WHEN cl_abap_typedescr=>typekind_struct1
            OR cl_abap_typedescr=>typekind_struct2.
            lo_structdescr = CAST cl_abap_structdescr( lo_typedescr ).
            eo_object      = lo_structdescr.
            ev_object_name = 'CL_ABAP_STRUCTDESCR'.

            IF lo_structdescr IS BOUND.
              lt_components = lo_structdescr->get_components( ).

              LOOP AT lt_components INTO ls_components.
                IF ls_components-as_include IS INITIAL.
                  et_components = VALUE #( BASE et_components
                                           ( ls_components ) ).
                ELSE.
                  _get_include_describe_fields( EXPORTING io_abap_datadescr = ls_components-type
                                                CHANGING  ct_components     = et_components ).
                ENDIF.
              ENDLOOP.
            ENDIF.
          WHEN OTHERS.
            lo_elemdescr   = CAST cl_abap_elemdescr( lo_typedescr ).
            eo_object      = lo_elemdescr.
            ev_object_name = 'CL_ABAP_ELEMDESCR'.
        ENDCASE.
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.

  METHOD split_text.
    DATA lt_texts TYPE string_table.

    CLEAR et_split_texts.

    IF iv_delimiter <> space.
      lt_texts = xco_cp=>string( iv_text )->split( iv_delimiter )->value.
    ELSE.
      lt_texts = VALUE #( ( iv_text ) ).
    ENDIF.

    DELETE lt_texts WHERE table_line IS INITIAL.

    IF lt_texts IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        LOOP AT lt_texts INTO DATA(lv_texts).
          _split_text_local( EXPORTING iv_text        = lv_texts
                                       iv_len         = iv_len
                             CHANGING  ct_split_texts = et_split_texts ).
        ENDLOOP.
      CATCH cx_sy_create_data_error INTO DATA(lx_sy_create_data_error).
        RAISE EXCEPTION NEW cx_sy_create_data_error( previous = lx_sy_create_data_error ).
    ENDTRY.
  ENDMETHOD.

  METHOD _get_include_describe_fields.
    LOOP AT CAST cl_abap_structdescr( io_abap_datadescr )->get_components( ) INTO DATA(ls_components).
      IF ls_components-as_include IS INITIAL.
        ct_components = VALUE #( BASE ct_components
                                 ( ls_components ) ).
      ELSE.
        _get_include_describe_fields( EXPORTING io_abap_datadescr = ls_components-type
                                      CHANGING  ct_components     = ct_components ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD _split_text_local.
    DATA lr_split_texts TYPE REF TO data.
    DATA lr_dref        TYPE REF TO data.
    DATA lv_index       TYPE i.
    DATA lv_len_inp     TYPE i.
    DATA lv_len         TYPE i.
    DATA lv_delimiter   TYPE c LENGTH 1 VALUE space.
    DATA lv_substring   TYPE string.
    DATA lv_substring1  TYPE string.
    FIELD-SYMBOLS <lv_string>      TYPE any.
    FIELD-SYMBOLS <lv_string1>     TYPE any.
    FIELD-SYMBOLS <lv_line>        TYPE any.
    FIELD-SYMBOLS <lt_split_texts> TYPE table.

    lv_len_inp = iv_len.

    IF lv_len_inp <= 0.
      lv_len_inp = 256.
    ENDIF.

    CREATE DATA lr_dref TYPE c LENGTH lv_len_inp.
    IF lr_dref IS BOUND.
      ASSIGN lr_dref->* TO <lv_line> ELSE UNASSIGN.
    ENDIF.

    IF <lv_line> IS NOT ASSIGNED.
      RAISE EXCEPTION NEW cx_sy_create_data_error( textid = cx_sy_create_data_error=>unknown_type ).
    ENDIF.

    DATA(lo_datadescr) = cl_abap_datadescr=>describe_by_data( p_data = <lv_line> ).
    DATA(lo_tabledescr) = cl_abap_tabledescr=>create( p_line_type  = CAST #( lo_datadescr )
                                                      p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                      p_unique     = abap_false ).

    CREATE DATA lr_split_texts TYPE HANDLE lo_tabledescr.
    IF lr_split_texts IS BOUND.
      ASSIGN lr_split_texts->* TO <lt_split_texts> ELSE UNASSIGN.
    ENDIF.

    IF <lt_split_texts> IS NOT ASSIGNED.
      RAISE EXCEPTION NEW cx_sy_create_data_error( textid = cx_sy_create_data_error=>unknown_type ).
    ENDIF.

    ASSIGN iv_text TO <lv_string>.

    DO.
      lv_len = strlen( <lv_string> ).
      IF lv_len <= lv_len_inp.
        <lv_line> = <lv_string>.
        APPEND <lv_line> TO <lt_split_texts>.
        EXIT.
      ELSE.
        " Find a point to break the line
        lv_index = lv_len_inp.
        WHILE lv_index > 0.
          lv_substring = <lv_string>+lv_index(1).
          IF lv_substring = lv_delimiter.
            EXIT.
          ENDIF.
          lv_index = lv_index - 1.
        ENDWHILE.
        IF lv_index = 0.
          lv_index = lv_len_inp.
        ENDIF.

        " Append line to result table
        <lv_line> = <lv_string>(lv_index).
        APPEND <lv_line> TO <lt_split_texts>.

        " Continue with the remaining text
        ASSIGN <lv_string> TO <lv_string1>.
        UNASSIGN <lv_string>.
        IF lv_substring = lv_delimiter. " a Space was found
          lv_index = lv_index + 1.
        ENDIF.
        lv_len = strlen( <lv_string1> ) - lv_index.
        lv_substring1 = <lv_string1>+lv_index(lv_len).
        ASSIGN lv_substring1 TO <lv_string>.
        UNASSIGN <lv_string1>.
      ENDIF.
    ENDDO.

    ct_split_texts = VALUE #( BASE ct_split_texts
                              ( LINES OF <lt_split_texts> ) ).
  ENDMETHOD.

  METHOD _get_abcde.
    ##NO_TEXT
    rv_abcde = `ABCDEFGHIJKLMNOPQRSTUVWXYZ`.
  ENDMETHOD.

  METHOD _get_abap_datfm_datatype.
    DATA lo_descr_ref TYPE REF TO cl_abap_elemdescr.

    DATA(lv_date_format) = VALUE xudatfm( ).

    IF lv_date_format IS INITIAL.
      lo_descr_ref ?= cl_abap_elemdescr=>describe_by_data( lv_date_format ).
      IF lo_descr_ref IS BOUND.
        lo_descr_ref->get_ddic_fixed_values( RECEIVING  p_fixed_values = mt_fixed_values
                                             EXCEPTIONS not_found      = 1
                                                        no_ddic_type   = 2
                                                        OTHERS         = 3 ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

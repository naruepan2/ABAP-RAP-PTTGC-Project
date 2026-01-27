CLASS zcl_ext_domainfixvalue_ce DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_domainfixvalue_ce IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    " https://community.sap.com/t5/technology-blog-posts-by-sap/how-to-create-a-value-help-for-custom-and-released-domain-fixed-values/ba-p/13605706

    DATA lt_business_data TYPE TABLE OF zi_ext_domainfixvalue .
    DATA ls_business_data TYPE zi_ext_domainfixvalue .
    DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
    DATA(lt_requested_fields)  = io_request->get_requested_elements( ).
    DATA(lt_sort_order)    = io_request->get_sort_elements( ).

    DATA lv_domain_name  TYPE sxco_ad_object_name  .
    DATA lv_pos TYPE i.

    TRY.
        DATA(lv_filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(lt_filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).

        READ TABLE lt_filter_condition_ranges WITH KEY name = 'DOMAIN_NAME'
               INTO DATA(ls_filter_cond_domain_name).

        IF ls_filter_cond_domain_name IS NOT INITIAL.
          lv_domain_name = ls_filter_cond_domain_name-range[ 1 ]-low.
        ELSE.
          "do some exception handling
          io_response->set_total_number_of_records( lines( lt_business_data ) ).
          io_response->set_data( lt_business_data ).
          EXIT.

        ENDIF.

        ls_business_data-domain_name = lv_domain_name .

        CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( lv_domain_name ) )->get_ddic_fixed_values(
          EXPORTING
            p_langu        = sy-langu
          RECEIVING
            p_fixed_values = DATA(lt_fixed_values)
          EXCEPTIONS
            not_found      = 1
            no_ddic_type   = 2
            OTHERS         = 3 ).

        IF sy-subrc > 0.
          "do some exception handling
          io_response->set_total_number_of_records( lines( lt_business_data ) ).
          io_response->set_data( lt_business_data ).
          EXIT.
        ENDIF.

        LOOP AT lt_fixed_values INTO DATA(ls_fixed_value).
          lv_pos += 1.
          ls_business_data-pos = lv_pos.
          ls_business_data-low = ls_fixed_value-low .
          ls_business_data-high = ls_fixed_value-high.
          ls_business_data-description = ls_fixed_value-ddtext.
          APPEND ls_business_data TO lt_business_data.
        ENDLOOP.

        IF lv_top IS NOT INITIAL.
          DATA(lv_max_index) = lv_top + lv_skip.
        ELSE.
          lv_max_index = 0.
        ENDIF.

        SELECT * FROM @lt_business_data AS data_source_fields   ##ITAB_KEY_IN_SELECT
           WHERE (lv_filter_condition_string)
           INTO TABLE @lt_business_data
           UP TO @lv_max_index ROWS.

        IF lv_skip IS NOT INITIAL.
          DELETE lt_business_data TO lv_skip.
        ENDIF.

        io_response->set_total_number_of_records( lines( lt_business_data ) ).
        io_response->set_data( lt_business_data ).

      CATCH cx_root INTO DATA(lx_root).
        DATA(lv_error) = cl_message_helper=>get_latest_t100_exception( lx_root )->if_message~get_longtext( ).
        DATA(ls_error) = cl_message_helper=>get_latest_t100_exception( lx_root )->t100key.

        "do some exception handling

    ENDTRY.

  ENDMETHOD.
ENDCLASS.

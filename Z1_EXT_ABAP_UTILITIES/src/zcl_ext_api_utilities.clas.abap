CLASS zcl_ext_api_utilities DEFINITION
  PUBLIC
  CREATE PRIVATE.

  " ---------------------------------------------------------------------
  " Note:
  " ---------------------------------------------------------------------
  " Be aware that data type used for boolean need to be either "BOOLEAN" not abap_bool
  "   class-data MC_BOOL_TYPES type STRING
  "                      read-only value `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL\TYPE=BOOLEAN\TYPE=BOOLE_D\TYPE=XFELD.
  "   class-data MC_BOOL_3STATE type STRING
  "                             read-only value `\TYPE=BOOLEAN.
  "
  "   For True/False --> Use type BOOLEAN, ABAP_BOOL, BOOLEAN, BOOLE_D or XFELD
  " ---------------------------------------------------------------------

  PUBLIC SECTION.
    TYPES ty_char1            TYPE c LENGTH 1.
    TYPES ty_num3             TYPE n LENGTH 3.
    TYPES ty_created_url_type TYPE n LENGTH 1.

    TYPES: BEGIN OF ts_url,
             method           TYPE if_web_http_client=>method,
             url              TYPE string,
             set_if_match     TYPE abap_boolean,
             check_etag       TYPE abap_boolean,
             timeout          TYPE i,
             get_x_csrf       TYPE abap_boolean,
             get_if_match     TYPE abap_boolean,
             force_get_x_csrf TYPE abap_boolean,
             json_data        TYPE /ui2/cl_json=>json,
             content_type     TYPE string,
           END OF ts_url.

    TYPES: BEGIN OF ts_msg,
             response_typ TYPE ty_char1,
             response_msg TYPE string,
           END OF ts_msg.

    TYPES: BEGIN OF ts_response,
             method      TYPE if_web_http_client=>method,            " Use constants of if_web_http_client
             url         TYPE string,                                " Pass URL or Destination of SM59
             response    TYPE REF TO if_web_http_response,
             return_msg  TYPE TABLE OF ts_msg WITH EMPTY KEY,
             json_data   TYPE REF TO data,
             last_error  TYPE i,
             http_status TYPE if_web_http_response=>http_status,
             res_header  TYPE if_web_http_request=>name_value_pairs,
             context     TYPE string,
           END OF ts_response.

    TYPES tt_url      TYPE TABLE OF ts_url WITH EMPTY KEY.
    TYPES tt_response TYPE TABLE OF ts_response WITH EMPTY KEY.

    CONSTANTS: BEGIN OF c_header,
                 csrf_token_header TYPE string VALUE 'X-CSRF-Token',
                 accept            TYPE string VALUE 'Accept',
                 get_etag          TYPE string VALUE 'etag',
                 content_type      TYPE string VALUE 'Content-Type',
                 set_etag          TYPE string VALUE 'If-Match',
                 fetch             TYPE string VALUE 'Fetch',
               END OF c_header.

    CONSTANTS: BEGIN OF c_content_type,
                 application_json TYPE string VALUE 'application/json',
                 multipart_mixed  TYPE string VALUE 'multipart/mixed',
               END OF c_content_type.

    CONSTANTS: BEGIN OF c_severity,
                 error   TYPE ty_char1 VALUE 'E',
                 success TYPE ty_char1 VALUE 'S',
               END OF c_severity.

    CONSTANTS: BEGIN OF c_url_type,
                 by_url         TYPE ty_created_url_type VALUE '0',
                 by_destination TYPE ty_created_url_type VALUE '1',
               END OF c_url_type.

    CONSTANTS: BEGIN OF c_method,
                 get     TYPE if_web_http_client=>method VALUE if_web_http_client=>get,
                 post    TYPE if_web_http_client=>method VALUE if_web_http_client=>post,
                 put     TYPE if_web_http_client=>method VALUE if_web_http_client=>put,
                 delete  TYPE if_web_http_client=>method VALUE if_web_http_client=>delete,
                 head    TYPE if_web_http_client=>method VALUE if_web_http_client=>head,
                 options TYPE if_web_http_client=>method VALUE if_web_http_client=>options,
                 patch   TYPE if_web_http_client=>method VALUE if_web_http_client=>patch,
                 trace   TYPE if_web_http_client=>method VALUE if_web_http_client=>trace,
                 connect TYPE if_web_http_client=>method VALUE if_web_http_client=>connect,
               END OF c_method.

    CONSTANTS: BEGIN OF c_suffix_system,
                 odata    TYPE string VALUE '/sap/opu/odata/sap/',
                 odata_v2 TYPE string VALUE '/sap/opu/odata2/sap/',
                 odata_v4 TYPE string VALUE '/sap/opu/odata4/sap/',
               END OF c_suffix_system.

    CONSTANTS c_xml_tag TYPE string VALUE '<?xml version="1.0" encoding="utf-8"?>'.

    INTERFACES if_oo_adt_classrun.

    METHODS constructor.

    METHODS create_http_by_url
      IMPORTING iv_url             TYPE string
      EXPORTING ev_msg             TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS create_http_by_destination
      IMPORTING iv_destination     TYPE rfcdest
      EXPORTING ev_msg             TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS get_request
      EXPORTING eo_http_request    TYPE REF TO if_web_http_request
                et_header          TYPE if_web_http_request=>name_value_pairs
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS get_response
      EXPORTING eo_http_response   TYPE REF TO if_web_http_response
                et_header          TYPE if_web_http_request=>name_value_pairs
                ev_response_text   TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS set_header_fields_request
      IMPORTING it_fields          TYPE if_web_http_request=>name_value_pairs
      EXPORTING ev_msg             TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS execute_request_single
      IMPORTING iv_uri_path         TYPE string
                iv_method           TYPE if_web_http_client=>method DEFAULT if_web_http_client=>get
                iv_username         TYPE string                     OPTIONAL
                iv_password         TYPE string                     OPTIONAL
                iv_bearer           TYPE string                     OPTIONAL
                iv_get_x_csrf       TYPE abap_boolean               OPTIONAL
                iv_get_if_match     TYPE abap_boolean               OPTIONAL
                iv_force_get_x_csrf TYPE abap_boolean               OPTIONAL
                iv_set_if_match     TYPE abap_boolean               OPTIONAL
                iv_check_etag       TYPE abap_boolean               OPTIONAL
                iv_timeout          TYPE i                          DEFAULT 0
                iv_json_data        TYPE /ui2/cl_json=>json         OPTIONAL
                iv_content_type     TYPE string                     DEFAULT c_content_type-application_json
      EXPORTING eo_http_request     TYPE REF TO if_web_http_request
                eo_http_response    TYPE REF TO if_web_http_response
                et_header           TYPE if_web_http_request=>name_value_pairs
                ev_has_error        TYPE abap_boolean
                ev_msg              TYPE string
      RETURNING VALUE(ro_instance)  TYPE REF TO zcl_ext_api_utilities.

    METHODS execute_requests_multiple
      IMPORTING it_url       TYPE tt_url
                iv_username  TYPE string OPTIONAL
                iv_password  TYPE string OPTIONAL
                iv_bearer    TYPE string OPTIONAL
      EXPORTING et_response  TYPE tt_response
                eo_instance  TYPE REF TO zcl_ext_api_utilities
                ev_has_error TYPE abap_boolean
                ev_msg       TYPE string.

    METHODS set_authorization_basic
      IMPORTING iv_username        TYPE string OPTIONAL
                iv_password        TYPE string OPTIONAL
                iv_bearer          TYPE string OPTIONAL
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS set_csrf_token
      IMPORTING iv_csrf_token      TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS set_if_match_etag
      IMPORTING iv_etag            TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS get_if_match_etag
      IMPORTING iv_uri_path TYPE string
      EXPORTING ev_etag     TYPE string.

    METHODS get_response_info
      EXPORTING eo_response        TYPE REF TO if_web_http_response
                ev_response_msg    TYPE string
                er_json_data       TYPE REF TO data
                ev_last_error      TYPE i
                es_http_status     TYPE if_web_http_response=>http_status
                et_res_header      TYPE if_web_http_request=>name_value_pairs
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS xml_string_to_json
      IMPORTING iv_xml_string      TYPE string
      EXPORTING er_data            TYPE REF TO data
                ev_msg             TYPE string
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    METHODS destroy.

    METHODS http_close.

    METHODS get_http_destination
      EXPORTING eo_http_destination TYPE REF TO if_http_destination
                eo_http_client      TYPE REF TO if_web_http_client
                eo_http_request     TYPE REF TO if_web_http_request
      RETURNING VALUE(ro_instance)  TYPE REF TO zcl_ext_api_utilities.

    CLASS-METHODS create_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_api_utilities.

    CLASS-METHODS get_system_url
      IMPORTING iv_suffix_odata TYPE string       DEFAULT space
                iv_f_api        TYPE abap_boolean OPTIONAL
      RETURNING VALUE(rv_url)   TYPE string.

    CLASS-METHODS convert_data_to_json_with_ui2
      IMPORTING iv_data             TYPE data
                iv_compress         TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_name             TYPE string                         OPTIONAL
                iv_pretty_name      TYPE /ui2/cl_json=>pretty_name_mode OPTIONAL
                io_type_descr       TYPE REF TO cl_abap_typedescr       OPTIONAL
                iv_assoc_arrays     TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_ts_as_iso8601    TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_expand_includes  TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-true
                iv_assoc_arrays_opt TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_numc_as_string   TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                it_name_mappings    TYPE /ui2/cl_json=>name_mappings    OPTIONAL
                iv_conversion_exits TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-true
                iv_format_output    TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_hex_as_base64    TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-true
      RETURNING VALUE(rv_json)      TYPE /ui2/cl_json=>json.

    CLASS-METHODS convert_data_to_json_with_xco
      IMPORTING iv_data                TYPE data
                io_json_transformation TYPE REF TO if_xco_json_transformation DEFAULT xco_cp_json=>transformation->underscore_to_pascal_case
                it_name_mapping        TYPE sxco_t_json_name_mapping          OPTIONAL
      RETURNING VALUE(rv_json)         TYPE string.

    CLASS-METHODS convert_json_to_data_with_ui2
      IMPORTING iv_json             TYPE /ui2/cl_json=>json             OPTIONAL
                iv_jsonx            TYPE xstring                        OPTIONAL
                iv_pretty_name      TYPE /ui2/cl_json=>pretty_name_mode DEFAULT /ui2/cl_json=>pretty_mode-none
                iv_assoc_arrays     TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                iv_assoc_arrays_opt TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-false
                it_name_mappings    TYPE /ui2/cl_json=>name_mappings    OPTIONAL
                iv_conversion_exits TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-true
                iv_hex_as_base64    TYPE /ui2/cl_json=>bool             DEFAULT /ui2/cl_json=>c_bool-true
      CHANGING  cv_data             TYPE data.

    CLASS-METHODS convert_json_to_data_with_xco
      IMPORTING iv_json                TYPE string
                io_json_transformation TYPE REF TO if_xco_json_transformation DEFAULT xco_cp_json=>transformation->underscore_to_pascal_case
                it_name_mapping        TYPE sxco_t_json_name_mapping          OPTIONAL
      CHANGING  cv_data                TYPE data.

    CLASS-METHODS convert_abap_timestamp_to_java
      IMPORTING iv_date             TYPE cl_abap_context_info=>ty_system_date OPTIONAL
                iv_time             TYPE cl_abap_context_info=>ty_system_time DEFAULT '000000'
                iv_msec             TYPE ty_num3                              DEFAULT '000'
      RETURNING VALUE(rv_timestamp) TYPE string.

    CLASS-METHODS convert_java_timestamp_to_abap
      IMPORTING iv_timestamp TYPE string
      EXPORTING ev_date      TYPE cl_abap_context_info=>ty_system_date
                ev_time      TYPE cl_abap_context_info=>ty_system_time
                ev_msec      TYPE ty_num3.

  PRIVATE SECTION.
    DATA mo_http_destination TYPE REF TO if_http_destination.
    DATA mo_http_client      TYPE REF TO if_web_http_client.
    DATA mo_http_request     TYPE REF TO if_web_http_request.
    DATA mo_http_response    TYPE REF TO if_web_http_response.

    DATA mv_username         TYPE string.
    DATA mv_password         TYPE string.
    DATA mv_bearer           TYPE string.
    DATA mv_csrf_token       TYPE string.
    DATA mv_etag             TYPE string.

    METHODS _check_required_conditions
      EXPORTING ev_msg          TYPE string
      RETURNING VALUE(rv_subrc) TYPE sy-subrc.

    METHODS _check_header_request
      IMPORTING iv_method       TYPE if_web_http_client=>method
                iv_get_x_csrf   TYPE abap_boolean OPTIONAL
                iv_check_etag   TYPE abap_boolean OPTIONAL
      EXPORTING ev_msg          TYPE string
      RETURNING VALUE(rv_subrc) TYPE sy-subrc.

    METHODS _check_http_is_created
      EXPORTING ev_msg          TYPE string
      RETURNING VALUE(rv_subrc) TYPE sy-subrc.

    METHODS _check_url_is_required
      IMPORTING iv_uri_path     TYPE string
      EXPORTING ev_msg          TYPE string
      RETURNING VALUE(rv_subrc) TYPE sy-subrc.

ENDCLASS.


CLASS zcl_ext_api_utilities IMPLEMENTATION.
  METHOD constructor.
  ENDMETHOD.

  METHOD convert_abap_timestamp_to_java.
    DATA lv_date_input     TYPE cl_abap_context_info=>ty_system_date.
    DATA lv_date           TYPE cl_abap_context_info=>ty_system_date.
    DATA lv_days_timestamp TYPE timestampl.
    DATA lv_secs_timestamp TYPE timestampl.
    DATA lv_days_i         TYPE i.
    DATA lv_sec_i          TYPE i.
    DATA lv_timestamp      TYPE timestampl.
    DATA lv_dummy          TYPE string ##NEEDED.

    CONSTANTS lc_day_in_sec TYPE i VALUE 86400.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Copy from class CL_PCO_UTILITY=>CONVERT_ABAP_TIMESTAMP_TO_JAVA
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    lv_date_input = COND #( WHEN iv_date IS NOT INITIAL THEN iv_date ELSE cl_abap_context_info=>get_system_date( ) ).

    " Milliseconds for the days since January 1, 1970, 00:00:00 GMT
    " one day has 86400 seconds
    lv_date           = '19700101'.
    lv_days_i         = lv_date_input - lv_date.

    " Time stamp for passed days until today in seconds
    lv_days_timestamp = lv_days_i * lc_day_in_sec.

    lv_sec_i          = iv_time.
    " Time stamp for time at present day
    lv_secs_timestamp = lv_sec_i.

    lv_timestamp = ( lv_days_timestamp + lv_secs_timestamp ) * 1000.
    rv_timestamp = lv_timestamp.

    SPLIT rv_timestamp AT '.' INTO rv_timestamp lv_dummy.
    rv_timestamp += iv_msec.

    rv_timestamp = condense( val  = rv_timestamp
                             from = ` `
                             to   = `` ).

    rv_timestamp = |/Date({ rv_timestamp })/|.
  ENDMETHOD.

  METHOD convert_data_to_json_with_ui2.
    rv_json = /ui2/cl_json=>serialize( data             = iv_data
                                       compress         = iv_compress
                                       name             = iv_name
                                       pretty_name      = iv_pretty_name
                                       type_descr       = io_type_descr
                                       assoc_arrays     = iv_assoc_arrays
                                       ts_as_iso8601    = iv_ts_as_iso8601
                                       expand_includes  = iv_expand_includes
                                       assoc_arrays_opt = iv_assoc_arrays_opt
                                       numc_as_string   = iv_numc_as_string
                                       name_mappings    = it_name_mappings
                                       conversion_exits = iv_conversion_exits
                                       format_output    = iv_format_output
                                       hex_as_base64    = iv_hex_as_base64 ).
  ENDMETHOD.

  METHOD convert_data_to_json_with_xco.
    DATA lo_json_transformation TYPE REF TO if_xco_json_transformation.

    IF it_name_mapping IS NOT INITIAL.
      lo_json_transformation = xco_cp_json=>transformation->name_replacement( it_name_mapping = it_name_mapping ).
    ELSEIF io_json_transformation IS BOUND.
      lo_json_transformation = io_json_transformation.
    ELSE.
      lo_json_transformation = xco_cp_json=>transformation->underscore_to_pascal_case.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Reference: https://software-heroes.com/en/blog/abap-cloud-json-conversion
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " ABAP to JSON

    rv_json = xco_cp_json=>data->from_abap( iv_data
                              )->apply( VALUE #( ( lo_json_transformation ) )
                              )->to_string( ).
  ENDMETHOD.

  METHOD convert_java_timestamp_to_abap.
    DATA lv_date      TYPE cl_abap_context_info=>ty_system_date.
    DATA lv_days_i    TYPE i.
    DATA lv_sec_i     TYPE i.
    DATA lv_timestamp TYPE timestampl.
    DATA lv_timsmsec  TYPE timestampl.
    CONSTANTS lc_day_in_sec TYPE i VALUE 86400.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Copy from class CL_PCO_UTILITY=>CONVERT_JAVA_TIMESTAMP_TO_ABAP
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    DATA(lv_java_timestamp) = iv_timestamp.

    " Extract /Date(1615161600000)/ to 1615161600000
    FIND PCRE '([0-9]+)' IN lv_java_timestamp IGNORING CASE SUBMATCHES DATA(lv_js_timestamp).

    " IV_TIMESTAMP stores milliseconds since January 1, 1970, 00:00:00 GMT
    lv_timestamp = lv_js_timestamp / 1000.   " timestamp in seconds

    " One day has 86400 seconds: Timestamp in days
    lv_days_i    = lv_timestamp DIV lc_day_in_sec.
    lv_date      = '19700101'.
    ev_date      = lv_date + lv_days_i.

    " Rest seconds (timestamp - days)
    lv_sec_i     = lv_timestamp MOD lc_day_in_sec.
    ev_time      = lv_sec_i.

    " Rest sec and milli seconds
    lv_timsmsec  = lv_timestamp MOD lc_day_in_sec.
    lv_timsmsec  -= lv_sec_i.
    ev_msec      = lv_timsmsec * 1000.
  ENDMETHOD.

  METHOD convert_json_to_data_with_ui2.
    CLEAR cv_data.

    /ui2/cl_json=>deserialize( EXPORTING json             = iv_json
                                         jsonx            = iv_jsonx
                                         pretty_name      = iv_pretty_name
                                         assoc_arrays     = iv_assoc_arrays
                                         assoc_arrays_opt = iv_assoc_arrays_opt
                                         name_mappings    = it_name_mappings
                                         conversion_exits = iv_conversion_exits
                                         hex_as_base64    = iv_hex_as_base64
                               CHANGING  data             = cv_data ).
  ENDMETHOD.

  METHOD convert_json_to_data_with_xco.
    DATA lo_json_transformation TYPE REF TO if_xco_json_transformation.

    IF it_name_mapping IS NOT INITIAL.
      lo_json_transformation = xco_cp_json=>transformation->name_replacement( it_name_mapping = it_name_mapping ).
    ELSEIF io_json_transformation IS BOUND.
      lo_json_transformation = io_json_transformation.
    ELSE.
      " If use transformation->underscore_to_pascal_case. It will transform as example
      "   ABAP Field       UNDERSCORE_TO_PASCAL_CASE
      "  company_code  -->       CompanyCode
      "  document_date -->       DocumentDate
      lo_json_transformation = xco_cp_json=>transformation->underscore_to_pascal_case.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Reference: https://software-heroes.com/en/blog/abap-cloud-json-conversion
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " JSON to ABAP

    xco_cp_json=>data->from_string( iv_json
                    )->apply( VALUE #( ( lo_json_transformation ) )
                    )->write_to( REF #( cv_data ) ).
  ENDMETHOD.

  METHOD create_http_by_url.
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**    " For S/4 HANA Public Cloud
**    "  - use class cl_http_destination_provider=>create_by_url( iv_url )
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**    TRY.
**        IF mo_http_client IS BOUND.
**          mo_http_client->close( ).
**        ENDIF.
**
**        ro_instance         = me.
**        mo_http_destination = cl_http_destination_provider=>create_by_url( iv_url ).
**
**        mo_http_client  = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).
**
**        mo_http_request = mo_http_client->get_http_request( ).
**      CATCH cx_http_dest_provider_error
**            cx_web_http_client_error
**            cx_web_message_error
**       INTO DATA(lx_exct).
**        ev_msg = lx_exct->get_longtext( ).
**    ENDTRY.
  ENDMETHOD.

  METHOD create_http_by_destination.
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**    " For S/4 HANA Public Cloud
**    "  - use class cl_http_destination_provider=>create_by_destination( iv_destination )
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**    TRY.
**        IF mo_http_client IS BOUND.
**          mo_http_client->close( ).
**        ENDIF.
**
**        ro_instance         = me.
**        mo_http_destination = cl_http_destination_provider=>create_by_destination( iv_destination ).
**
**        mo_http_client  = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).
**
**        mo_http_request = mo_http_client->get_http_request( ).
**      CATCH cx_http_dest_provider_error
**            cx_web_http_client_error
**            cx_web_message_error
**       INTO DATA(lx_exct).
**        ev_msg = lx_exct->get_longtext( ).
**    ENDTRY.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " For S/4 HANA Private Cloud
    "  - Wrapper standard class: cl_outbound_provider_http=>create_by_destination( iv_name )
    "  - in Tier2 and release API state C1 as well
    "  - To throw exception. Be able to inheriting from cx_static_check
    "  - Wrapper from:
    "       DATA lx_outbound_provider_http TYPE REF TO cx_outbound_provider_http.
    "
    "       TRY.
    "           ro_destination = cl_outbound_provider_http=>create_by_destination( iv_name ).
    "       CATCH cx_outbound_provider_http INTO lx_outbound_provider_http.
    "           RAISE EXCEPTION NEW zcx_t2_outbound_provider_http( previous = lx_outbound_provider_http ).
    "       ENDTRY.
    "
    "   - eo_client  -> cl_web_http_client_manager=>create_by_http_destination( ro_destination ).
    "   - eo_request -> eo_request = get_client( )->get_http_request( ).
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TRY.
        IF mo_http_client IS BOUND.
          mo_http_client->close( ).
        ENDIF.

        ro_instance = me.

        NEW zcl_outbound_provider_http_utl( )->create_by_destination( EXPORTING iv_destination = iv_destination
                                                                      IMPORTING eo_destination = mo_http_destination
                                                                                eo_client      = mo_http_client
                                                                                eo_request     = mo_http_request ).
      CATCH zcx_t2_outbound_provider_http
            cx_web_http_client_error
            cx_web_message_error INTO DATA(lx_exct).
        ev_msg = lx_exct->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD execute_request_single.
    DATA lt_set_header TYPE if_web_http_request=>name_value_pairs.

    CLEAR: eo_http_request,
           eo_http_response,
           et_header,
           ev_has_error,
           ev_msg.

    ro_instance = me.

    CLEAR: mv_csrf_token,
           mv_etag.

    IF _check_http_is_created( IMPORTING ev_msg = ev_msg ) IS NOT INITIAL.
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    IF _check_url_is_required( EXPORTING iv_uri_path = iv_uri_path
                               IMPORTING ev_msg      = ev_msg ) IS NOT INITIAL.
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    set_authorization_basic( iv_username = iv_username
                             iv_password = iv_password
                             iv_bearer   = iv_bearer ).

    TRY.
        mo_http_request->set_uri_path( i_uri_path = iv_uri_path ).
      CATCH cx_web_message_error.
    ENDTRY.

    TRY.
        IF _check_required_conditions( IMPORTING ev_msg = ev_msg ) IS NOT INITIAL.
          ev_has_error = abap_true.
          mo_http_client->close( ).
          RETURN.
        ENDIF.

        TRY.
            IF     mv_username IS NOT INITIAL
               AND mv_password IS NOT INITIAL.
              mo_http_request->set_authorization_basic( i_username = mv_username
                                                        i_password = mv_password ).
            ELSEIF mv_bearer IS NOT INITIAL.
              mo_http_request->set_authorization_bearer( i_bearer = mv_bearer ).
            ENDIF.
          CATCH cx_web_message_error.
        ENDTRY.

        CASE iv_method.
          WHEN if_web_http_client=>get
            OR if_web_http_client=>head.
            lt_set_header = VALUE #( ( name = c_header-accept            value = iv_content_type )
                                     ( name = c_header-csrf_token_header value = c_header-fetch ) ).

            mo_http_request->set_header_fields( lt_set_header ).
            eo_http_request = mo_http_request.

          WHEN if_web_http_client=>post.
            lt_set_header = VALUE #( value = iv_content_type
                                     ( name = c_header-content_type )
                                     ( name = c_header-accept ) ).

            " ---------------------------------------------------------------------
            " Use parameter --> iv_force_get_x_csrf
            " to fetch new X-CSRF-Token and avoid HTTP 403 (forbidden) error
            " ---------------------------------------------------------------------
            IF    (     iv_get_x_csrf IS NOT INITIAL
                    AND mv_csrf_token IS INITIAL )
               OR iv_force_get_x_csrf IS NOT INITIAL.
              " To call Fetch and Set X-CSRF-Token
              mo_http_client->set_csrf_token( ).

              mv_csrf_token = mo_http_request->get_header_field( i_name = c_header-csrf_token_header ).
            ENDIF.

            " ---------------------------------------------------------------------
            " Set X-CSRF-Token
            " ---------------------------------------------------------------------
            IF mv_csrf_token IS NOT INITIAL.
              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-csrf_token_header value = mv_csrf_token ) ).
            ENDIF.

            " ---------------------------------------------------------------------
            " Set If-Match / Etag
            " ---------------------------------------------------------------------
            IF iv_set_if_match IS NOT INITIAL.
              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-set_etag        value = mv_etag ) ).
            ELSEIF iv_get_if_match IS NOT INITIAL.
              " ---------------------------------------------------------------------
              " Use parameter --> iv_get_if_match
              " to fetch new If-Match / Etag
              " ---------------------------------------------------------------------
              get_if_match_etag( EXPORTING iv_uri_path = iv_uri_path
                                 IMPORTING ev_etag     = mv_etag ).

              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-set_etag        value = mv_etag ) ).
            ENDIF.

            IF _check_header_request( EXPORTING iv_method     = iv_method
                                                iv_get_x_csrf = iv_get_x_csrf
                                                iv_check_etag = iv_check_etag
                                      IMPORTING ev_msg        = ev_msg ) IS NOT INITIAL.
              mo_http_client->close( ).
              RETURN.
            ENDIF.

            mo_http_request->set_header_fields( lt_set_header ).

            " Set JSON content to create any documents
            IF     iv_json_data IS NOT INITIAL
               AND iv_json_data IS SUPPLIED.
              TRY.
                  mo_http_request->set_text( i_text = iv_json_data ).
                CATCH cx_web_message_error.
              ENDTRY.
            ENDIF.

            eo_http_request = mo_http_request.

          WHEN if_web_http_client=>put
            OR if_web_http_client=>patch.
            lt_set_header = VALUE #( value = iv_content_type
                                     ( name = c_header-content_type )
                                     ( name = c_header-accept ) ).

            " ---------------------------------------------------------------------
            " Use parameter --> iv_force_get_x_csrf
            " to fetch new X-CSRF-Token and avoid HTTP 403 (forbidden) error
            " ---------------------------------------------------------------------
            IF    (     iv_get_x_csrf IS NOT INITIAL
                    AND mv_csrf_token IS INITIAL )
               OR iv_force_get_x_csrf IS NOT INITIAL.
              " To call Fetch and Set X-CSRF-Token
              mo_http_client->set_csrf_token( ).

              mv_csrf_token = mo_http_request->get_header_field( i_name = c_header-csrf_token_header ).
            ENDIF.

            " ---------------------------------------------------------------------
            " Set X-CSRF-Token
            " ---------------------------------------------------------------------
            IF mv_csrf_token IS NOT INITIAL.
              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-csrf_token_header value = mv_csrf_token ) ).
            ENDIF.

            " ---------------------------------------------------------------------
            " Set If-Match / Etag
            " ---------------------------------------------------------------------
            IF iv_set_if_match IS NOT INITIAL.
              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-set_etag        value = mv_etag ) ).
            ELSEIF iv_get_if_match IS NOT INITIAL.
              " ---------------------------------------------------------------------
              " Use parameter --> iv_get_if_match
              " to fetch new If-Match / Etag
              " ---------------------------------------------------------------------
              get_if_match_etag( EXPORTING iv_uri_path = iv_uri_path
                                 IMPORTING ev_etag     = mv_etag ).

              lt_set_header = VALUE #( BASE lt_set_header
                                       ( name = c_header-set_etag        value = mv_etag ) ).
            ENDIF.

            IF _check_header_request( EXPORTING iv_method     = iv_method
                                                iv_get_x_csrf = iv_get_x_csrf
                                                iv_check_etag = iv_check_etag
                                      IMPORTING ev_msg        = ev_msg ) IS NOT INITIAL.
              mo_http_client->close( ).
              RETURN.
            ENDIF.

            mo_http_request->set_header_fields( lt_set_header ).

            " Set JSON content to create any documents
            IF     iv_json_data IS NOT INITIAL
               AND iv_json_data IS SUPPLIED.
              TRY.
                  mo_http_request->set_text( i_text = iv_json_data ).
                CATCH cx_web_message_error.
              ENDTRY.
            ENDIF.

            eo_http_request = mo_http_request.

          WHEN if_web_http_client=>delete.

          WHEN OTHERS.
            mo_http_client->close( ).
            RETURN.
        ENDCASE.

        mo_http_response = mo_http_client->execute( i_method  = iv_method
                                                    i_timeout = iv_timeout ).

        eo_http_response = mo_http_response.
        et_header        = mo_http_response->get_header_fields( ).

        IF    iv_method = if_web_http_client=>get
           OR iv_method = if_web_http_client=>head
           OR iv_method = if_web_http_client=>options.
          mv_csrf_token = VALUE #( et_header[ name = |{ c_header-csrf_token_header CASE = LOWER }| ]-value OPTIONAL ).
          mv_etag       = VALUE #( et_header[ name = |{ c_header-get_etag CASE = LOWER }| ]-value OPTIONAL ).
        ENDIF.
      CATCH cx_web_http_client_error INTO DATA(lx_exct).
        ev_has_error = abap_true.
        ev_msg = lx_exct->get_longtext( ).
      CATCH cx_web_message_error INTO DATA(lx_exct2).
        ev_has_error = abap_true.
        ev_msg = lx_exct2->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD execute_requests_multiple.
    TYPES lty_status_code TYPE c LENGTH 3.

*    DATA lr_errordetails TYPE REF TO data.
    DATA lv_set_if_match TYPE abap_boolean.
    DATA lv_check_etag   TYPE abap_boolean.
    DATA lv_content_type TYPE string.

    FIELD-SYMBOLS <ls_msg> TYPE ts_msg.

    CLEAR: eo_instance,
           et_response,
           ev_msg,
           ev_has_error.

    IF _check_http_is_created( IMPORTING ev_msg = ev_msg ) IS NOT INITIAL.
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    LOOP AT it_url INTO DATA(ls_url) WHERE url IS NOT INITIAL.
      create_http_by_url( ls_url-url ).

      lv_set_if_match = COND #( WHEN ls_url-set_if_match IS NOT INITIAL THEN ls_url-set_if_match ).
      lv_check_etag   = COND #( WHEN ls_url-check_etag IS NOT INITIAL THEN ls_url-check_etag ).
      lv_content_type = COND #( WHEN ls_url-content_type IS NOT INITIAL
                                THEN ls_url-content_type
                                ELSE c_content_type-application_json ).

      execute_request_single( iv_uri_path         = ls_url-url
                              iv_method           = ls_url-method
                              iv_username         = iv_username
                              iv_password         = iv_password
                              iv_bearer           = iv_bearer
                              iv_set_if_match     = lv_set_if_match
                              iv_check_etag       = lv_check_etag
                              iv_timeout          = ls_url-timeout
                              iv_get_x_csrf       = ls_url-get_x_csrf
                              iv_get_if_match     = ls_url-get_if_match
                              iv_force_get_x_csrf = ls_url-force_get_x_csrf
                              iv_json_data        = ls_url-json_data
                              iv_content_type     = lv_content_type ).

      get_response_info( IMPORTING eo_response    = DATA(lo_response)
                                   er_json_data   = DATA(lr_json_data)
                                   ev_last_error  = DATA(lv_last_error)
                                   es_http_status = DATA(ls_http_status)
                                   et_res_header  = DATA(lt_res_header) ).

      APPEND INITIAL LINE TO et_response ASSIGNING FIELD-SYMBOL(<ls_response>).
      <ls_response>-url         = ls_url-url.
      <ls_response>-method      = ls_url-method.
      <ls_response>-response    = lo_response.
      <ls_response>-json_data   = lr_json_data.
      <ls_response>-last_error  = lv_last_error.
      <ls_response>-http_status = ls_http_status.
      <ls_response>-res_header  = lt_res_header.

      IF lo_response IS BOUND.
        <ls_response>-context = lo_response->get_text( ).
      ENDIF.

      IF CONV lty_status_code( ls_http_status-code ) CP '2*'.   " Successful responses
        APPEND INITIAL LINE TO <ls_response>-return_msg ASSIGNING <ls_msg>.
        <ls_msg>-response_typ = c_severity-success.
        <ls_msg>-response_msg = 'OK'.
      ELSEIF CONV lty_status_code( ls_http_status-code ) CP '4*'.     " Client error responses
        APPEND INITIAL LINE TO <ls_response>-return_msg ASSIGNING <ls_msg>.
        <ls_msg>-response_typ = c_severity-error.
        <ls_msg>-response_msg = 'Error - Check LR_JSON_DATA to retrieve error message'.
*        TRY.
*            lr_errordetails = REF #( lr_json_data->('ERROR')->('INNERERROR')->('ERRORDETAILS') ).
*            IF lr_errordetails IS BOUND.
*              ASSIGN lr_errordetails->* TO FIELD-SYMBOL(<lt_json>) ELSE UNASSIGN.
*            ENDIF.
*
*            IF <lt_json> IS ASSIGNED.
*              TRY.
*                  LOOP AT <lt_json>->* ASSIGNING FIELD-SYMBOL(<ls_json>).
*                    ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <ls_json>->* TO FIELD-SYMBOL(<lv_val>).
*                    IF sy-subrc <> 0.
*                      CONTINUE.
*                    ENDIF.
*
*                    APPEND INITIAL LINE TO <ls_response>-return_msg ASSIGNING <ls_msg>.
*                    <ls_msg>-response_typ = c_severity-error.
*                    <ls_msg>-response_msg = <lv_val>->*.
*                  ENDLOOP.
*                CATCH cx_root.
*              ENDTRY.
*            ELSE.
*              APPEND INITIAL LINE TO <ls_response>-return_msg ASSIGNING <ls_msg>.
*              <ls_msg>-response_typ = c_severity-error.
*              <ls_msg>-response_msg = 'Error'.
*            ENDIF.
*          CATCH cx_root INTO FINAL(lx_error).
*            <ls_msg>-response_typ = c_severity-error.
*            <ls_msg>-response_msg = lx_error->get_longtext( ).
*        ENDTRY.
      ELSEIF CONV lty_status_code( ls_http_status-code ) CP '5*'.     " Server error responses
        " Do nothing
      ENDIF.
    ENDLOOP.

    http_close( ).
    eo_instance = me.
  ENDMETHOD.

  METHOD destroy.
    TRY.
        IF mo_http_client IS BOUND.
          mo_http_client->close( ).
        ENDIF.

        FREE: mo_http_destination,
              mo_http_client,
              mo_http_request,
              mo_http_response.

        FREE: mv_csrf_token,
              mv_etag,
              mv_bearer,
              mv_password,
              mv_username.
      CATCH cx_web_http_client_error.
    ENDTRY.
  ENDMETHOD.

  METHOD get_request.
    ro_instance = me.

    IF mo_http_request IS BOUND.
      eo_http_request = mo_http_request.
      et_header       = eo_http_request->get_header_fields( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_response.
    ro_instance = me.

    IF mo_http_response IS BOUND.
      eo_http_response = mo_http_response.
      et_header        = mo_http_response->get_header_fields( ).
      ev_response_text = mo_http_response->get_text( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_response_info.
    CLEAR: eo_response,
           ev_response_msg,
           er_json_data,
           ev_last_error,
           es_http_status,
           et_res_header.

    ro_instance = me.

    IF mo_http_response IS NOT BOUND.
      RETURN.
    ENDIF.

    eo_response     = mo_http_response.
    ev_response_msg = mo_http_response->get_text( ).

    IF ev_last_error IS SUPPLIED.
      ev_last_error = mo_http_response->get_last_error( ).
    ENDIF.

    IF es_http_status IS SUPPLIED.
      TRY.
          es_http_status = mo_http_response->get_status( ).
        CATCH cx_web_message_error.
      ENDTRY.
    ENDIF.

    IF et_res_header IS SUPPLIED.
      et_res_header = mo_http_response->get_header_fields( ).
    ENDIF.

    " Convert JSON to post table
    IF er_json_data IS SUPPLIED.
      IF ev_response_msg IS NOT INITIAL.
        /ui2/cl_json=>deserialize( EXPORTING json         = ev_response_msg
                                             pretty_name  = /ui2/cl_json=>pretty_mode-none
                                             assoc_arrays = abap_true
                                   CHANGING  data         = er_json_data ).

        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        "  SAMPLE CODE
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*          IF eo_json_data IS BOUND.
*            DATA(lv_errordetails) = `LR_JSON_DATA->ERROR->INNERERROR->ERRORDETAILS`.
*
*            ASSIGN (lv_errordetails) TO FIELD-SYMBOL(<lt_json>) ELSE UNASSIGN.
*            IF <lt_json> IS ASSIGNED.
*              LOOP AT <lt_json>->* ASSIGNING FIELD-SYMBOL(<ls_json>).
*                ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <ls_json>->* TO FIELD-SYMBOL(<lv_val>).
*                CHECK sy-subrc EQ 0.
*
*                DATA(lv_msg_out) = NEW string( <lv_val>->* ).
*                EXIT.
*              ENDLOOP.
*            ENDIF.
*          ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD create_instance.
    RETURN NEW #( ).
  ENDMETHOD.

  METHOD get_system_url.
    DATA lt_string       TYPE TABLE OF string.
    DATA lv_host         TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_port         TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_out_protocol TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_vh_switch    TYPE abap_bool.

    DATA(lv_url_part) = cl_web_http_utility=>get_location( IMPORTING host         = lv_host
                                                                     port         = lv_port
                                                                     out_protocol = lv_out_protocol
                                                                     vh_switch    = lv_vh_switch ).

    IF iv_suffix_odata IS NOT INITIAL.
      rv_url = |{ lv_url_part }{ iv_suffix_odata }|.
    ELSE.
      rv_url = lv_url_part.
    ENDIF.

    IF iv_f_api IS NOT INITIAL.
      SPLIT lv_host AT '.' INTO TABLE lt_string.
      IF lt_string[] IS NOT INITIAL.
        DATA(lv_prefix) = |{ lt_string[ 1 ] }|.
        DATA(lv_api) = |{ lt_string[ 1 ] }-api|.
        REPLACE FIRST OCCURRENCE OF lv_prefix IN rv_url WITH lv_api.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD http_close.
    TRY.
        IF mo_http_client IS BOUND.
          mo_http_client->close( ).
        ENDIF.

        FREE: mo_http_destination,
              mo_http_client,
              mo_http_request,
              mo_http_response.
      CATCH cx_web_http_client_error.
    ENDTRY.
  ENDMETHOD.

  METHOD get_http_destination.
    ro_instance         = me.
    eo_http_destination = mo_http_destination.

    TRY.
        eo_http_client = COND #( WHEN mo_http_client IS BOUND THEN
                                   mo_http_client
                                 WHEN mo_http_destination IS BOUND THEN
                                   cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ) ).
      CATCH cx_web_http_client_error.
    ENDTRY.

    eo_http_request = COND #( WHEN mo_http_request IS BOUND THEN mo_http_request
                              WHEN mo_http_client IS BOUND  THEN mo_http_client->get_http_request( ) ).
  ENDMETHOD.

  METHOD set_authorization_basic.
    ro_instance = me.
    mv_username = COND #( WHEN iv_username IS NOT INITIAL THEN iv_username ELSE mv_username ).
    mv_password = COND #( WHEN iv_password IS NOT INITIAL THEN iv_password ELSE mv_password ).
    mv_bearer   = COND #( WHEN iv_bearer IS NOT INITIAL THEN iv_bearer ELSE mv_bearer ).
  ENDMETHOD.

  METHOD set_csrf_token.
    ro_instance = me.
    mv_csrf_token = COND #( WHEN iv_csrf_token IS NOT INITIAL THEN iv_csrf_token ELSE mv_csrf_token ).
  ENDMETHOD.

  METHOD set_if_match_etag.
    ro_instance = me.
    mv_etag = COND #( WHEN iv_etag IS NOT INITIAL THEN iv_etag ELSE mv_etag ).
  ENDMETHOD.

  METHOD get_if_match_etag.
    DATA lcl_api_utils TYPE REF TO zcl_ext_api_utilities.
    DATA lt_set_header TYPE if_web_http_request=>name_value_pairs.

    CLEAR ev_etag.

    lcl_api_utils = NEW #( ).
    lcl_api_utils->mo_http_client  = mo_http_client.
    lcl_api_utils->mo_http_request = mo_http_request.

    TRY.
        lcl_api_utils->mo_http_request->set_uri_path( i_uri_path = iv_uri_path ).
        lcl_api_utils->mo_http_request->set_header_fields( lt_set_header ).

        lcl_api_utils->mo_http_response = lcl_api_utils->mo_http_client->execute( i_method = if_web_http_client=>get ).

        DATA(lt_header_etag) = lcl_api_utils->mo_http_response->get_header_fields( ).
        ev_etag              = VALUE #( lt_header_etag[ name = |{ c_header-get_etag CASE = LOWER }| ]-value DEFAULT mv_etag ).
      CATCH cx_web_message_error
            cx_web_http_client_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD set_header_fields_request.
    ro_instance = me.

    TRY.
        mo_http_request->set_header_fields( VALUE #( FOR ls_field IN it_fields
                                                     ( name  = ls_field-name
                                                       value = ls_field-value ) ) ).
      CATCH cx_web_message_error INTO DATA(lx_exct).
        ev_msg = lx_exct->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD xml_string_to_json.
    TYPES: BEGIN OF node,
             node_type TYPE if_sxml_node=>node_type,
             name      TYPE string,
             value     TYPE string,
             array     TYPE c LENGTH 1,
           END OF node.
    DATA lt_nodes TYPE TABLE OF node WITH EMPTY KEY.

    CLEAR er_data.
    CLEAR ev_msg.

    ro_instance = me.

    DATA(lv_xml) = cl_abap_conv_codepage=>create_out( )->convert( replace( val  = iv_xml_string
                                                                           sub  = |\n|
                                                                           with = ``
                                                                           occ  = 0  ) ).

    " Parsing XML into an internal table
    DATA(lo_reader) = cl_sxml_string_reader=>create( lv_xml ).
    CLEAR lt_nodes.
    TRY.
        DO.
          lo_reader->next_node( ).
          IF lo_reader->node_type = if_sxml_node=>co_nt_final.
            EXIT.
          ENDIF.
          APPEND VALUE #( node_type = lo_reader->node_type
                          name      = lo_reader->prefix &&
                                      COND string(
                                        WHEN lo_reader->prefix IS NOT INITIAL
                                        THEN `:` ) && lo_reader->name
                          value     = lo_reader->value ) TO lt_nodes.
          IF lo_reader->node_type <> if_sxml_node=>co_nt_element_open.
            CONTINUE.
          ENDIF.

          DO.
            lo_reader->next_attribute( ).
            IF lo_reader->node_type <> if_sxml_node=>co_nt_attribute.
              EXIT.
            ENDIF.
            APPEND VALUE #( node_type = if_sxml_node=>co_nt_initial
                            name      = lo_reader->prefix &&
                                        COND string(
                                         WHEN lo_reader->prefix IS NOT INITIAL
                                         THEN `:` ) && lo_reader->name
                            value     = lo_reader->value ) TO lt_nodes.
          ENDDO.
        ENDDO.
      CATCH cx_sxml_parse_error INTO DATA(lx_parse_error).
        ev_msg = lx_parse_error->get_longtext( ).
        RETURN.
    ENDTRY.

    " Determine the array limits in the internal table
    LOOP AT lt_nodes ASSIGNING FIELD-SYMBOL(<ls_node_open>)
         WHERE
                   node_type  = if_sxml_node=>co_nt_element_open
               AND array     IS INITIAL.
      DATA(lv_open) = sy-tabix.
      LOOP AT lt_nodes ASSIGNING FIELD-SYMBOL(<ls_node_close>)
           FROM lv_open + 1
           WHERE
                     node_type = if_sxml_node=>co_nt_element_close
                 AND name      = <ls_node_open>-name.
        DATA(lv_close_index) = sy-tabix.
        IF lv_close_index >= lines( lt_nodes ).
          CONTINUE.
        ENDIF.

        ASSIGN lt_nodes[ lv_close_index + 1 ] TO FIELD-SYMBOL(<ls_node>).
        IF     <ls_node>-node_type = if_sxml_node=>co_nt_element_open
           AND <ls_node>-name      = <ls_node_open>-name.
          <ls_node>-array = 'O'.
          <ls_node>-array = '_'.
        ELSEIF
                  (     <ls_node>-node_type  = if_sxml_node=>co_nt_element_open
                    AND <ls_node>-name      <> <ls_node_open>-name )
               OR <ls_node>-node_type = if_sxml_node=>co_nt_element_close.
          <ls_node_close>-array = COND #(
            WHEN <ls_node_open>-array = 'O' THEN 'C' ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " Render the internal table to JSON-XML
    TRY.
        DATA(lo_writer) = CAST if_sxml_writer(
         cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ) ).
      CATCH cx_sxml_illegal_argument_error.
        " handle exception
    ENDTRY.
    " create( type = if_sxml=>co_xt_xml10 ) ).

    lo_writer->open_element( name = 'object' ).

    LOOP AT lt_nodes ASSIGNING <ls_node>.
      CASE <ls_node>-node_type.
        WHEN if_sxml_node=>co_nt_element_open.
          IF <ls_node>-array IS INITIAL.
            lo_writer->open_element( name = 'object' ).
            lo_writer->write_attribute( name  = 'name'
                                        value = <ls_node>-name ).
          ELSEIF <ls_node>-array = 'O'.
            lo_writer->open_element( name = 'array' ).
            lo_writer->write_attribute( name  = 'name'
                                        value = <ls_node>-name ).
            lo_writer->open_element( name = 'object' ).
          ELSEIF <ls_node>-array = '_'.
            lo_writer->open_element( name = 'object' ).
          ENDIF.
        WHEN if_sxml_node=>co_nt_element_close.
          IF <ls_node>-array <> 'C'.
            lo_writer->close_element( ).
          ELSE.
            lo_writer->close_element( ).
            lo_writer->close_element( ).
          ENDIF.
        WHEN if_sxml_node=>co_nt_initial.
          lo_writer->open_element( name = 'str' ).
          lo_writer->write_attribute( name  = 'name'
                                      value = |a_{ <ls_node>-name }| ).
          lo_writer->write_value( <ls_node>-value ).
          lo_writer->close_element( ).
        WHEN if_sxml_node=>co_nt_value.
          lo_writer->open_element( name = 'str' ).
          lo_writer->write_attribute( name  = 'name'
                                      value = |e_{ <ls_node>-name }| ).
          lo_writer->write_value( <ls_node>-value ).
          lo_writer->close_element( ).
        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDLOOP.
    lo_writer->close_element( ).

    DATA(lv_json) = CAST cl_sxml_string_writer( lo_writer )->get_output( ).

    IF lv_json IS NOT INITIAL.
      /ui2/cl_json=>deserialize( EXPORTING jsonx       = lv_json
                                           pretty_name = /ui2/cl_json=>pretty_mode-none
                                 CHANGING  data        = er_data ).
    ENDIF.
  ENDMETHOD.

  METHOD _check_header_request.
    IF NOT (    iv_method = if_web_http_client=>put
             OR iv_method = if_web_http_client=>patch
             OR iv_method = if_web_http_client=>post
             OR iv_method = if_web_http_client=>delete ).
      RETURN.
    ENDIF.

    IF     iv_get_x_csrf IS NOT INITIAL
       AND mv_csrf_token IS INITIAL.
      ev_msg   = 'X-CSRF-Token is required'.
      rv_subrc = 4.
      RETURN.
    ENDIF.

    IF     iv_check_etag IS NOT INITIAL
       AND mv_etag       IS INITIAL.
      ev_msg   = 'ETag is required'.
      rv_subrc = 4.
    ENDIF.
  ENDMETHOD.

  METHOD _check_required_conditions.
    rv_subrc = 0.

    IF mo_http_client IS NOT BOUND.
      ev_msg   = 'HTTP Client is initial'.
      rv_subrc = 4.
    ELSEIF mo_http_request IS NOT BOUND.
      ev_msg   = 'HTTP Request is initial'.
      rv_subrc = 4.
    ENDIF.
  ENDMETHOD.

  METHOD _check_http_is_created.
    CLEAR rv_subrc.

    IF mo_http_destination IS NOT BOUND.
      ev_msg   = 'HTTP Destination for Web Development is not created'.
      rv_subrc = 4.
    ELSEIF mo_http_client IS NOT BOUND.
      ev_msg   = 'HTTP Client for Web Development is not created'.
      rv_subrc = 4.
    ENDIF.
  ENDMETHOD.

  METHOD _check_url_is_required.
    IF iv_uri_path IS INITIAL.
      ev_msg   = 'URL Path is required'.
      rv_subrc = 4.
    ENDIF.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Example: How to use this class
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    NEW lcl_sample_post( )->sample_post_material_document( out ).
    NEW lcl_sample_post( )->sample_pickalldelivery( out ).
  ENDMETHOD.
ENDCLASS.

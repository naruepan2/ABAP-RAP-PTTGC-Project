CLASS zcl_ext_pdf_utilities DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_mimetype     TYPE cl_bcs_mail_bodypart=>ty_content_type.

    TYPES tt_pdf_document TYPE TABLE OF xstring WITH EMPTY KEY.

    CONSTANTS c_xml_tag      TYPE string VALUE '<?xml version="1.0" encoding="UTF-8"?>'.
    CONSTANTS c_default_form TYPE string VALUE 'Form'.

    CONSTANTS: BEGIN OF c_mimetype_type,
                 pdf TYPE ty_mimetype VALUE 'application/pdf',
                 xml TYPE ty_mimetype VALUE 'application/xml',
               END OF c_mimetype_type.

    CONSTANTS: BEGIN OF c_xml_header,
                 no               TYPE string VALUE 'no',               " No XML header is output
                 without_encoding TYPE string VALUE 'without_encoding', " An XML header is output without specifying the encoding
                 full             TYPE string VALUE 'full',             " Default; an XML header is output and encoding is specified
               END OF c_xml_header.

    CONSTANTS: BEGIN OF c_locale,
                 english TYPE string VALUE 'en_US',
                 thai    TYPE string VALUE 'th_TH',
               END OF c_locale.

    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_pdf_utilities.

    METHODS encode_string_to_x64
      IMPORTING iv_string            TYPE string
                iv_encoding          TYPE abap_encoding OPTIONAL
      RETURNING VALUE(rv_encode_x64) TYPE string.

    METHODS encode_xstring_to_x64
      IMPORTING iv_xstring           TYPE xstring
      RETURNING VALUE(rv_encode_x64) TYPE string.

    METHODS encode_string_to_utf8
      IMPORTING iv_string             TYPE string
      RETURNING VALUE(rv_encode_utf8) TYPE string.

    CLASS-METHODS decode_x64_to_xstring
      IMPORTING iv_encode_x64     TYPE string
      RETURNING VALUE(rv_xstring) TYPE xstring.

    CLASS-METHODS decode_x64_to_string
      IMPORTING iv_encode_x64    TYPE string
      RETURNING VALUE(rv_string) TYPE string.

    CLASS-METHODS decode_utf8_to_string
      IMPORTING iv_encode_utf8   TYPE xstring
      RETURNING VALUE(rv_string) TYPE string.

    METHODS build_xml_pdf
      IMPORTING iv_root_form_node  TYPE string        OPTIONAL
                iv_child_form_node TYPE string        OPTIONAL
                iv_encoding        TYPE abap_encoding OPTIONAL
      EXPORTING ev_mimetype        TYPE ty_mimetype
                ev_error           TYPE abap_bool
                ev_msg             TYPE string
      CHANGING  cs_data            TYPE any           OPTIONAL
                ct_data            TYPE ANY TABLE     OPTIONAL
      RETURNING VALUE(rv_xmlpdf)   TYPE string.

    METHODS build_xml_pdf_to_xstring
      IMPORTING iv_root_form_node  TYPE string        OPTIONAL
                iv_child_form_node TYPE string        OPTIONAL
                iv_encoding        TYPE abap_encoding OPTIONAL
      EXPORTING ev_x_xmlpdf        TYPE xstring
                ev_xmlpdf          TYPE string
                ev_mimetype        TYPE ty_mimetype
                ev_error           TYPE abap_bool
                ev_msg             TYPE string
      CHANGING  cs_data            TYPE any           OPTIONAL
                ct_data            TYPE ANY TABLE     OPTIONAL.

    METHODS build_xml_pdf_with_encode_x64
      IMPORTING iv_root_form_node  TYPE string        OPTIONAL
                iv_child_form_node TYPE string        OPTIONAL
                iv_encoding        TYPE abap_encoding OPTIONAL
      EXPORTING ev_xmlpdf          TYPE string
                ev_encodex64       TYPE string
                ev_mimetype        TYPE ty_mimetype
                ev_error           TYPE abap_bool
                ev_msg             TYPE string
      CHANGING  cs_data            TYPE any           OPTIONAL
                ct_data            TYPE ANY TABLE     OPTIONAL.

    METHODS transformation_to_xml
      IMPORTING it_srcbind        TYPE abap_trans_srcbind_tab
                iv_root_form_node TYPE string        DEFAULT c_default_form
                iv_add_start_tag  TYPE abap_boolean  OPTIONAL
                iv_add_end_tag    TYPE abap_boolean  OPTIONAL
                iv_encoding       TYPE abap_encoding OPTIONAL
      EXPORTING ev_string         TYPE string
                ev_xstring        TYPE xstring
                ev_encode_x64     TYPE string.

    METHODS create_fp_fdp_services
      IMPORTING iv_service_definition TYPE if_fp_fdp_api=>ty_service_definition
                iv_root_node          TYPE string OPTIONAL
                iv_max_depth          TYPE i DEFAULT 5
                iv_encoding           TYPE abap_encoding OPTIONAL
      EXPORTING eo_api                TYPE REF TO if_fp_fdp_api
                et_keys               TYPE if_fp_fdp_api=>tt_select_keys
                ev_xsd_schema         TYPE xstring
                ev_xsd_schema_string  TYPE string
                ev_has_error          TYPE abap_boolean
                ev_error_msg          TYPE string.

    METHODS render_pdf
      IMPORTING iv_xml_data       TYPE xstring
                iv_xdp_layout     TYPE xstring
                iv_locale         TYPE string DEFAULT c_locale-english
                is_options        TYPE cl_fp_ads_util=>ty_gs_options_pdf OPTIONAL
      EXPORTING ev_pdf            TYPE xstring
                ev_pdf_encode_x64 TYPE string
                ev_pages          TYPE int4
                ev_trace_string   TYPE string
                ev_error_msg      TYPE cl_print_queue_utils=>ty_msg.

    METHODS render_4_pq_and_create_pq
      IMPORTING iv_xml_data         TYPE xstring
                iv_xdp_layout       TYPE xstring
                iv_locale           TYPE string                                            DEFAULT c_locale-english
                iv_pq_name          TYPE cl_fp_ads_util=>ty_pq_name
                is_options          TYPE cl_fp_ads_util=>ty_gs_options_pdl                 OPTIONAL
                iv_create_queue     TYPE abap_boolean                                      OPTIONAL
                iv_name_of_main_doc TYPE cl_print_queue_utils=>ty_doc_name                 OPTIONAL
                iv_itemid           TYPE cl_print_queue_utils=>ty_itemid                   OPTIONAL
                iv_pages            TYPE cl_print_queue_utils=>ty_page_count               DEFAULT 0
                iv_number_of_copies TYPE cl_print_queue_utils=>ty_nr_copies                DEFAULT 1
                it_attachment_data  TYPE cl_print_queue_utils=>ty_attachment_data_info_tab OPTIONAL
      EXPORTING ev_pdl              TYPE xstring
                ev_pages            TYPE int4
                ev_trace_string     TYPE string
                ev_pdf_trace        TYPE xstring
                ev_itemid           TYPE cl_print_queue_utils=>ty_itemid
                ev_error_msg        TYPE cl_print_queue_utils=>ty_msg.

    METHODS convert_data_to_string_xstring
      IMPORTING it_srcbind    TYPE abap_trans_srcbind_tab
                iv_xml_header TYPE string        OPTIONAL
                iv_encoding   TYPE abap_encoding OPTIONAL
      EXPORTING ev_string     TYPE string
                ev_xstring    TYPE xstring.

    METHODS merge_pdf_documents
      IMPORTING it_documents              TYPE tt_pdf_document
      EXPORTING ev_error_msg              TYPE cl_print_queue_utils=>ty_msg
                ev_has_error              TYPE abap_boolean
      RETURNING VALUE(rv_merged_document) TYPE xstring.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_ext_pdf_utilities.

ENDCLASS.


CLASS zcl_ext_pdf_utilities IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.

    RETURN go_instance.
  ENDMETHOD.

  METHOD build_xml_pdf.
    DATA lv_xml_string      TYPE string.
    DATA lv_root_form_node  TYPE string.
    DATA lv_child_form_node TYPE string.

    CLEAR rv_xmlpdf.
    CLEAR: ev_error,
           ev_msg.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " - Generate XML to XSD:
    "       https://www.freeformatter.com/xsd-generator.html#before-output
    " - XML Formatter:
    "       https://www.freeformatter.com/xml-formatter.html#before-output
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_root_form_node  = iv_root_form_node.
    lv_child_form_node = iv_child_form_node.

    IF    (     lv_root_form_node  IS INITIAL
            AND lv_child_form_node IS INITIAL )
       OR (     lv_root_form_node  IS NOT INITIAL
            AND lv_child_form_node IS INITIAL ).
      lv_root_form_node  = ''.
      lv_child_form_node = c_default_form.
    ENDIF.

    IF lv_root_form_node IS NOT INITIAL.
      rv_xmlpdf = |{ c_xml_tag }<{ lv_root_form_node }>|.
    ELSE.
      rv_xmlpdf = c_xml_tag.
    ENDIF.

    IF cs_data IS SUPPLIED.
      transformation_to_xml( EXPORTING it_srcbind  = VALUE #( ( name = lv_child_form_node value = REF #( cs_data ) ) )
                                       iv_encoding = iv_encoding
                             IMPORTING ev_string   = lv_xml_string ).

      rv_xmlpdf = rv_xmlpdf && lv_xml_string.
    ELSEIF ct_data IS SUPPLIED.
      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).

        transformation_to_xml(
          EXPORTING it_srcbind  = VALUE #( ( name = iv_child_form_node value = REF #( <ls_data> ) ) )
                    iv_encoding = iv_encoding
          IMPORTING ev_string   = lv_xml_string ).

        rv_xmlpdf = rv_xmlpdf && lv_xml_string.

      ENDLOOP.
    ELSE.
      CLEAR rv_xmlpdf.
      ev_error = abap_true.
      ev_msg   = 'CS_DATA or CT_DATA parameters must be passed'.
      RETURN.
    ENDIF.

    IF lv_root_form_node IS NOT INITIAL.
      rv_xmlpdf = |{ rv_xmlpdf }</{ lv_root_form_node }>|.
    ENDIF.

    rv_xmlpdf   = condense( rv_xmlpdf ).
    ev_mimetype = c_mimetype_type-pdf.
  ENDMETHOD.

  METHOD build_xml_pdf_to_xstring.
    ev_xmlpdf = build_xml_pdf( EXPORTING iv_root_form_node  = iv_root_form_node
                                         iv_child_form_node = iv_child_form_node
                                         iv_encoding        = iv_encoding
                               IMPORTING ev_mimetype        = ev_mimetype
                                         ev_error           = ev_error
                                         ev_msg             = ev_msg
                               CHANGING  cs_data            = cs_data
                                         ct_data            = ct_data ).

    IF ev_xmlpdf IS NOT INITIAL.
      ev_x_xmlpdf = /ui2/cl_json=>string_to_raw( iv_string   = ev_xmlpdf
                                                 iv_encoding = iv_encoding ).
    ENDIF.
  ENDMETHOD.

  METHOD build_xml_pdf_with_encode_x64.
    CLEAR: ev_xmlpdf,
           ev_encodex64.

    ev_xmlpdf = build_xml_pdf( EXPORTING iv_root_form_node  = iv_root_form_node
                                         iv_child_form_node = iv_child_form_node
                                         iv_encoding        = iv_encoding
                               IMPORTING ev_mimetype        = ev_mimetype
                                         ev_error           = ev_error
                                         ev_msg             = ev_msg
                               CHANGING  cs_data            = cs_data
                                         ct_data            = ct_data ).

    IF ev_xmlpdf IS NOT INITIAL.
      ev_encodex64 = encode_string_to_x64( iv_string = ev_xmlpdf ).
    ENDIF.
  ENDMETHOD.

  METHOD encode_string_to_x64.
    rv_encode_x64 = cl_web_http_utility=>encode_x_base64( /ui2/cl_json=>string_to_raw( iv_string   = iv_string
                                                                                       iv_encoding = iv_encoding ) ).
  ENDMETHOD.

  METHOD encode_xstring_to_x64.
    rv_encode_x64 = cl_web_http_utility=>encode_x_base64( iv_xstring ).
  ENDMETHOD.

  METHOD encode_string_to_utf8.
    rv_encode_utf8 = cl_web_http_utility=>encode_utf8( unencoded = iv_string ).
  ENDMETHOD.

  METHOD decode_x64_to_xstring.
    rv_xstring = cl_web_http_utility=>decode_x_base64( encoded = iv_encode_x64 ).
  ENDMETHOD.

  METHOD decode_x64_to_string.
    rv_string = cl_web_http_utility=>decode_base64( encoded = iv_encode_x64 ).
  ENDMETHOD.

  METHOD decode_utf8_to_string.
    rv_string = cl_web_http_utility=>decode_utf8( encoded = iv_encode_utf8 ).
  ENDMETHOD.

  METHOD create_fp_fdp_services.
    CLEAR: eo_api,
           et_keys,
           ev_xsd_schema,
           ev_xsd_schema_string,
           ev_has_error,
           ev_error_msg.

    TRY.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Initiate Business Data Reader
        "   - https://help.sap.com/docs/btp/sap-business-technology-platform/rap-data-services-for-print-forms#initiate-business-data-reader
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        eo_api = cl_fp_fdp_services=>get_instance( iv_service_definition = iv_service_definition
                                                   iv_root_node          = iv_root_node
                                                   iv_max_depth          = iv_max_depth ).
        IF eo_api IS NOT BOUND.
          RETURN.
        ENDIF.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Retrieve XML Data from Service Definition
        "   - https://help.sap.com/docs/btp/sap-business-technology-platform/rap-data-services-for-print-forms#retrieve-xml-data-from-service-definition
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF et_keys IS SUPPLIED.
          et_keys = eo_api->get_keys( ).
        ENDIF.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Retrieve XML Schema Definition from Service Definition
        "   - https://help.sap.com/docs/btp/sap-business-technology-platform/rap-data-services-for-print-forms#retrieve-xml-schema-definition-from-service-definition
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF ev_xsd_schema IS SUPPLIED.
          ev_xsd_schema = eo_api->get_xsd_v2( ).
        ENDIF.

        IF ev_xsd_schema_string IS SUPPLIED.
          " To get XSD Schema, Copy this string into Editor and then save it to ".XSD" file
          ev_xsd_schema_string = /ui2/cl_json=>raw_to_string( iv_xstring  = eo_api->get_xsd_v2( )
                                                              iv_encoding = iv_encoding ).
        ENDIF.
      CATCH cx_fp_fdp_error INTO FINAL(lx_fp_fdp_error).
        ev_error_msg = lx_fp_fdp_error->get_longtext( ).
        ev_has_error = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD render_pdf.
    CLEAR: ev_pdf,
           ev_pdf_encode_x64,
           ev_pages,
           ev_trace_string,
           ev_error_msg.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " - Reference to:
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/runtime-api-for-ads-rendering-calls
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/rap-data-services-for-print-forms
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TRY.
        " Render PDF
        cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = iv_xml_data
                                              iv_xdp_layout   = iv_xdp_layout
                                              iv_locale       = iv_locale
                                              is_options      = is_options
                                    IMPORTING ev_pdf          = ev_pdf
                                              ev_pages        = ev_pages
                                              ev_trace_string = ev_trace_string ).

        IF ev_pdf_encode_x64 IS SUPPLIED.
          ev_pdf_encode_x64 = encode_xstring_to_x64( iv_xstring = ev_pdf ).
        ENDIF.
      CATCH cx_fp_ads_util INTO DATA(lx_fp_ads_util).
        ev_error_msg = lx_fp_ads_util->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD render_4_pq_and_create_pq.
    DATA lv_print_data TYPE cl_print_queue_utils=>ty_print_data.
    DATA lv_qname      TYPE cl_print_queue_utils=>ty_pqname.

    CLEAR: ev_pdl,
           ev_pages,
           ev_trace_string,
           ev_pdf_trace,
           ev_itemid,
           ev_error_msg.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " - Reference to:
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/runtime-api-for-ads-rendering-calls
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/rap-data-services-for-print-forms
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TRY.
        " Render in Print Queue Format
        cl_fp_ads_util=>render_4_pq( EXPORTING iv_xml_data     = iv_xml_data
                                               iv_xdp_layout   = iv_xdp_layout
                                               iv_locale       = iv_locale
                                               iv_pq_name      = iv_pq_name
                                               is_options      = is_options
                                     IMPORTING ev_pdl          = ev_pdl
                                               ev_pages        = ev_pages
                                               ev_trace_string = ev_trace_string ).

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " To create a print queue item API
        "   - https://help.sap.com/docs/btp/sap-business-technology-platform/printing
        " Parameter:
        "   IV_QNAME:            Name of the print queue
        "   IV_PRINT_DATA:       Print document contained in xstring format
        "   IV_NAME_OF_MAIN_DOC: Name of the main document
        "   IV_NUMBER_OF_COPIES: Number of copies
        "   IV_PAGES:            Number of pages
        "   IT_ATTACHMENT_DATA:  List of attachments within the structure. This includes the name and the attachment data in xstring
        "   EV_ERR_MSG:          Error messages
        "   RV_ITEMID:           Returns the ID of the item with the parameter
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        IF iv_create_queue IS NOT INITIAL.
          lv_print_data = ev_pdl.
          lv_qname      = iv_pq_name.

          ev_itemid = cl_print_queue_utils=>create_queue_item_by_data(
                        EXPORTING iv_qname            = lv_qname
                                  iv_print_data       = lv_print_data
                                  iv_name_of_main_doc = iv_name_of_main_doc
                                  iv_itemid           = iv_itemid
                                  iv_pages            = iv_pages
                                  iv_number_of_copies = iv_number_of_copies
                                  it_attachment_data  = it_attachment_data
                        IMPORTING ev_err_msg          = ev_error_msg ).
        ENDIF.
      CATCH cx_fp_ads_util INTO DATA(lx_fp_ads_util).
        ev_error_msg = lx_fp_ads_util->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

  METHOD transformation_to_xml.
    CLEAR: ev_string,
           ev_xstring.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " - Generate XML to XSD:
    "       https://www.freeformatter.com/xsd-generator.html#before-output
    " - XML Formatter:
    "       https://www.freeformatter.com/xml-formatter.html#before-output
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    IF it_srcbind[] IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_srcbind) = it_srcbind[].

    LOOP AT lt_srcbind ASSIGNING FIELD-SYMBOL(<ls_srcbind>) WHERE name IS INITIAL.
      <ls_srcbind>-name = c_default_form.   "'data'.
    ENDLOOP.

    " Call Transformation to transform data to XML string
    convert_data_to_string_xstring( EXPORTING it_srcbind    = lt_srcbind
                                              iv_xml_header = c_xml_header-no
                                    IMPORTING ev_string     = ev_string ).

**    REPLACE ALL OCCURRENCES OF |<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values>|
**    IN ev_string
**    WITH |<?xml version="1.0" encoding="UTF-8"?><form1>|.
**    REPLACE ALL OCCURRENCES OF |</asx:values></asx:abap>|
**    IN ev_string
**    WITH |</form1>|.
    REPLACE ALL OCCURRENCES OF |<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values>|
            IN ev_string
            WITH space.
    REPLACE ALL OCCURRENCES OF |</asx:values></asx:abap>|
            IN ev_string
            WITH space.

    REPLACE ALL OCCURRENCES OF '﻿' IN ev_string WITH 'ฅ'.
    ev_string = translate( val  = ev_string
                           from = `ฅ`
                           to   = ` ` ).

    ev_string = condense( ev_string ).

    IF     iv_root_form_node IS NOT INITIAL
       AND iv_add_start_tag  IS NOT INITIAL.
      CONCATENATE c_xml_tag
                  '<'
                  iv_root_form_node
                  '>'
                  ev_string
                  INTO ev_string.
    ENDIF.

    IF     iv_root_form_node IS NOT INITIAL
       AND iv_add_end_tag    IS NOT INITIAL.
      CONCATENATE ev_string
                  '</'
                  iv_root_form_node
                  '>'
                  INTO ev_string.
    ENDIF.

    IF ev_xstring IS SUPPLIED.
      ev_xstring = /ui2/cl_json=>string_to_raw( iv_string   = ev_string
                                                iv_encoding = iv_encoding ).
    ENDIF.

    IF ev_encode_x64 IS SUPPLIED.
      ev_encode_x64 = encode_string_to_x64( iv_string = ev_string ).
    ENDIF.
  ENDMETHOD.

  METHOD convert_data_to_string_xstring.
    DATA lv_string TYPE string.

    CLEAR ev_string.
    CLEAR ev_xstring.

    IF it_srcbind IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_xml_header IS NOT INITIAL.
      CALL TRANSFORMATION id
           SOURCE (it_srcbind)
           OPTIONS xml_header = iv_xml_header
           RESULT XML lv_string.
    ELSE.
      CALL TRANSFORMATION id
           SOURCE (it_srcbind)
           RESULT XML lv_string.
    ENDIF.

    IF ev_string IS SUPPLIED.
      ev_string = lv_string.
    ENDIF.

    IF ev_xstring IS SUPPLIED.
      ev_xstring = /ui2/cl_json=>string_to_raw( iv_string   = lv_string
                                                iv_encoding = iv_encoding ).
    ENDIF.
  ENDMETHOD.

  METHOD merge_pdf_documents.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " PDF Merger API
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/pdf-merger-api
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/class-and-interface-of-pdf-merger-api
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Create an instance of the PDF merger class
    DATA(lo_merger) = cl_rspo_pdf_merger=>create_instance( ).

    " Add the data of the PDF document to the list of files which shall be merged
    LOOP AT it_documents INTO FINAL(lv_document).
      lo_merger->add_document( lv_document ).
    ENDLOOP.

    TRY.
        " Merge both documents and receive the result
        rv_merged_document = lo_merger->merge_documents( ).
      CATCH cx_rspo_pdf_merger INTO FINAL(lx_rspo_pdf_merger).
        ev_error_msg = lx_rspo_pdf_merger->get_longtext( ).
        ev_has_error = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    NEW lcl_main_local( )->sample_tmpl_store_client( out ).
  ENDMETHOD.
ENDCLASS.

"----------------------------------------------------------------------
"  ZCL_XML_DYN_UTIL
"  Generic XML → dynamic internal table by attribute mapping (sXML)
"----------------------------------------------------------------------
CLASS zcl_ext_sxml_utilities DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_attr_map,
             xml_name  TYPE string, " attribute name in XML (case-sensitive)
             comp_name TYPE string, " component name in target structure
           END OF ts_attr_map,
           tt_attr_map TYPE STANDARD TABLE OF ts_attr_map WITH EMPTY KEY.

    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_sxml_utilities.

    " Flavor #1: fill a caller-provided table (ANY TABLE)
    METHODS parse_by_attr_to_table
      IMPORTING iv_input_string           TYPE string       OPTIONAL
                iv_input_xstring          TYPE xstring      OPTIONAL
                it_row_element            TYPE string_table
                iv_ns_uri                 TYPE string       OPTIONAL
                it_inherit_from_ancestors TYPE string_table OPTIONAL
                it_attr_map               TYPE tt_attr_map  OPTIONAL
      CHANGING  ct_result                 TYPE ANY TABLE
      RAISING   cx_static_check.

    " Flavor #2: create and return a dynamic table typed to ir_line_type
    METHODS parse_by_attr_create
      IMPORTING iv_input_string           TYPE string       OPTIONAL
                iv_input_xstring          TYPE xstring      OPTIONAL
                it_row_element            TYPE string_table
                iv_ns_uri                 TYPE string       OPTIONAL
                it_inherit_from_ancestors TYPE string_table OPTIONAL
                io_line_type              TYPE REF TO cl_abap_structdescr
                it_attr_map               TYPE tt_attr_map  OPTIONAL
      EXPORTING er_result_tab             TYPE REF TO data
      RAISING   cx_static_check.

  PRIVATE SECTION.
    TYPES: BEGIN OF ts_strval,
             name TYPE string,
             val  TYPE string,
           END OF ts_strval,
           tt_strval TYPE STANDARD TABLE OF ts_strval WITH EMPTY KEY
                                                      WITH NON-UNIQUE SORTED KEY k2 COMPONENTS name.

    CLASS-DATA go_instance TYPE REF TO zcl_ext_sxml_utilities.

    METHODS _conv_string_to_xstring
      IMPORTING iv_input_string TYPE string
      RETURNING VALUE(rv_x)     TYPE xstring.

    METHODS _get_line_descr_from_anytable
      IMPORTING it_table        TYPE ANY TABLE
      RETURNING VALUE(ro_descr) TYPE REF TO cl_abap_structdescr.

    METHODS _get_components_flat
      IMPORTING io_line        TYPE REF TO cl_abap_structdescr
      RETURNING VALUE(rt_comp) TYPE abap_component_tab.

    METHODS _assign_component_from_string
      IMPORTING iv_comp_name TYPE string
                iv_value     TYPE string
      CHANGING  cv_row       TYPE any
                co_line      TYPE REF TO cl_abap_structdescr.

    METHODS _collect_attrs
      IMPORTING it_attr         TYPE if_sxml_attribute=>attributes
      RETURNING VALUE(rt_attrs) TYPE tt_strval.

    METHODS _find_attr_value
      IMPORTING it_pairs        TYPE tt_strval
                iv_name         TYPE string
      RETURNING VALUE(rv_value) TYPE string.

ENDCLASS.


CLASS zcl_ext_sxml_utilities IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.

    RETURN go_instance.
  ENDMETHOD.

  METHOD parse_by_attr_to_table.
    " Normalize input
    DATA lv_x                 TYPE xstring.
    " Keep inherited attributes (e.g., 'time' from parent)
    DATA lt_inherit           TYPE tt_strval.
    " Compose attribute set = inherited + current row's attributes
    DATA lt_attrs_row         TYPE tt_strval.
    DATA lv_match_row_element TYPE abap_bool.

    DATA lt_row_element_range TYPE RANGE OF string.

    " Create a row of the target type and assign fields
    DATA lr_row               TYPE REF TO data.

    FIELD-SYMBOLS <lt_result>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_inherit> TYPE ts_strval.
    FIELD-SYMBOLS <lv_row>     TYPE any.

    IF iv_input_xstring IS SUPPLIED AND iv_input_xstring IS NOT INITIAL.
      lv_x = iv_input_xstring.
    ELSEIF iv_input_string IS SUPPLIED.
      lv_x = _conv_string_to_xstring( iv_input_string ).
    ELSE.
      RETURN.
    ENDIF.

    lt_row_element_range = VALUE #( FOR <lv_row_element> IN it_row_element WHERE ( table_line IS NOT INITIAL )
                                    ( sign = 'I' option = 'EQ' low = <lv_row_element> ) ).

    " Determine line type of ct_result at runtime
    DATA(lo_line) = _get_line_descr_from_anytable( ct_result ).
    DATA(lt_comp) = _get_components_flat( lo_line ).

    " Build attr->component mapping (default: identity by name)
    DATA lt_map TYPE tt_attr_map.
    IF it_attr_map IS INITIAL.
      LOOP AT lt_comp INTO DATA(ls_comp).
        APPEND VALUE ts_attr_map( xml_name  = ls_comp-name
                                  comp_name = ls_comp-name ) TO lt_map.
      ENDLOOP.
    ELSE.
      lt_map = it_attr_map.
    ENDIF.

    " sXML streaming reader
    DATA(lo_reader) = cl_sxml_string_reader=>create( input = lv_x ). " efficient stream parser
    DATA lo_event TYPE REF TO if_sxml_node.

    ASSIGN ct_result TO <lt_result>.

    WHILE lo_reader->read_next_node( ).
      lo_event = lo_reader->read_current_node( ).

      CASE lo_event->type.
        WHEN if_sxml_node=>co_nt_element_open.
          DATA(lo_open_element) = CAST if_sxml_open_element( lo_event ).

          " Update inherited attributes, if any were requested
          IF it_inherit_from_ancestors IS NOT INITIAL.
            DATA(lt_attrs_here) = _collect_attrs( lo_open_element->get_attributes( ) ).

            LOOP AT it_inherit_from_ancestors INTO DATA(lv_inh).
              DATA(lv_attr_val) = _find_attr_value( it_pairs = lt_attrs_here
                                                    iv_name  = lv_inh ).

              IF lv_attr_val IS NOT INITIAL.
                DELETE lt_inherit WHERE name = lv_inh.
                APPEND VALUE ts_strval( name = lv_inh
                                        val  = lv_attr_val ) TO lt_inherit.
              ENDIF.
            ENDLOOP.
          ENDIF.

          " Row creation condition: element name matches and (namespace ok)
          IF     lo_open_element->qname-name IN lt_row_element_range
             AND ( iv_ns_uri IS INITIAL OR lo_open_element->qname-namespace = iv_ns_uri ).
            CLEAR lt_attrs_row.

            lt_attrs_row = lt_inherit.
            lv_match_row_element = abap_true.

            IF lt_attrs_row IS NOT INITIAL.
              APPEND LINES OF _collect_attrs( lo_open_element->get_attributes( ) ) TO lt_attrs_row.

              " Create a row of the target type and assign fields
              CREATE DATA lr_row TYPE HANDLE lo_line.
              ASSIGN lr_row->* TO <lv_row>.

              LOOP AT lt_map INTO DATA(ls_map).
                lv_attr_val = _find_attr_value( it_pairs = lt_attrs_row
                                                iv_name  = ls_map-xml_name ).
                IF lv_attr_val IS NOT INITIAL.
                  _assign_component_from_string( EXPORTING iv_comp_name = ls_map-comp_name
                                                           iv_value     = lv_attr_val
                                                 CHANGING  cv_row       = <lv_row>
                                                           co_line      = lo_line ).
                ENDIF.
              ENDLOOP.

              APPEND <lv_row> TO <lt_result>.
            ENDIF.
          ELSE.
            APPEND VALUE #( name = lo_open_element->qname-name ) TO lt_attrs_row.
          ENDIF.
        WHEN if_sxml_node=>co_nt_element_close.
          DATA(lo_close_element) = CAST if_sxml_close_element( lo_event ).

          IF     lo_close_element->qname-name IN lt_row_element_range
             AND ( iv_ns_uri IS INITIAL OR lo_close_element->qname-namespace = iv_ns_uri ).
            IF     lt_attrs_row         IS NOT INITIAL
               AND lv_match_row_element IS NOT INITIAL.
              CREATE DATA lr_row TYPE HANDLE lo_line.
              ASSIGN lr_row->* TO <lv_row>.

              LOOP AT lt_map INTO ls_map.
                lv_attr_val = _find_attr_value( it_pairs = lt_attrs_row
                                                iv_name  = ls_map-xml_name ).
                IF lv_attr_val IS NOT INITIAL.
                  _assign_component_from_string( EXPORTING iv_comp_name = ls_map-comp_name
                                                           iv_value     = lv_attr_val
                                                 CHANGING  cv_row       = <lv_row>
                                                           co_line      = lo_line ).
                ENDIF.
              ENDLOOP.

              APPEND <lv_row> TO <lt_result>.
            ENDIF.

            " Clear inherited attributes when closing a row element
            CLEAR lv_match_row_element.
            CLEAR lt_attrs_row.
          ENDIF.
        WHEN if_sxml_node=>co_nt_value.
          DATA(lo_value_element) = CAST if_sxml_value( lo_event ).

          READ TABLE lt_attrs_row ASSIGNING <ls_inherit>
               WITH KEY k2 COMPONENTS name = lo_open_element->qname-name.
          IF sy-subrc = 0.
            <ls_inherit>-val = lo_value_element->get_value( ).
          ENDIF.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDWHILE.
  ENDMETHOD.

  METHOD parse_by_attr_create.
    " Create dynamic table with the line type the caller passed in
    DATA(lo_tabledescr) = cl_abap_tabledescr=>create( p_line_type = io_line_type ).
    CREATE DATA er_result_tab TYPE HANDLE lo_tabledescr.
    ASSIGN er_result_tab->* TO FIELD-SYMBOL(<lt_result>) ##NEEDED.

    " Delegate to flavor #1
    parse_by_attr_to_table( EXPORTING iv_input_string           = iv_input_string
                                      iv_input_xstring          = iv_input_xstring
                                      it_row_element            = it_row_element
                                      iv_ns_uri                 = iv_ns_uri
                                      it_inherit_from_ancestors = it_inherit_from_ancestors
                                      it_attr_map               = it_attr_map
                            CHANGING  ct_result                 = <lt_result> ).
  ENDMETHOD.

  METHOD _conv_string_to_xstring.
    " Use canonical converter (works in ABAP Cloud)
    rv_x = cl_abap_conv_codepage=>create_out( )->convert( iv_input_string ).
  ENDMETHOD.

  METHOD _get_line_descr_from_anytable.
    DATA(lo_tabdescr) = CAST cl_abap_tabledescr(
                          cl_abap_typedescr=>describe_by_data( it_table ) ).
    ro_descr ?= lo_tabdescr->get_table_line_type( ).
  ENDMETHOD.

  METHOD _get_components_flat.
    DATA(lt_comp) = io_line->get_components( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      IF ls_comp-as_include = abap_true.
        " Recursively expand structure components
        DATA(lo_sub) = CAST cl_abap_structdescr( ls_comp-type ).
        DATA(lt_sub) = _get_components_flat( lo_sub ).
        APPEND LINES OF lt_sub TO rt_comp.
      ELSE.
        " Direct component, append as-is
        APPEND ls_comp TO rt_comp.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD _collect_attrs.
    LOOP AT it_attr INTO DATA(lo_attr).
      APPEND VALUE ts_strval( name = lo_attr->qname-name
                              val  = lo_attr->get_value( ) ) TO rt_attrs.
    ENDLOOP.
  ENDMETHOD.

  METHOD _find_attr_value.
    READ TABLE it_pairs INTO DATA(ls_pairs)
         WITH KEY k2 COMPONENTS name = iv_name.
    IF sy-subrc = 0.
      rv_value = ls_pairs-val.
    ENDIF.
  ENDMETHOD.

  METHOD _assign_component_from_string.
    DATA lo_descr_ref TYPE REF TO cl_abap_elemdescr.
    " Convert string into target component type and assign into cs_row-<comp>
    FIELD-SYMBOLS <lv_row> TYPE any.

    ASSIGN cv_row TO <lv_row>.

    DATA(lt_comp) = _get_components_flat( co_line ).
    READ TABLE lt_comp INTO DATA(ls_comp) WITH KEY name = iv_comp_name.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Prepare a temp variable of the component's data type
    DATA lr_comp TYPE REF TO data.
    CREATE DATA lr_comp TYPE HANDLE ls_comp-type.
    ASSIGN lr_comp->* TO FIELD-SYMBOL(<lv_comp>).

    DATA(lv_value) = iv_value.

    " Minimal smart conversions:
    IF    CAST cl_abap_datadescr( ls_comp-type )->absolute_name = '\\TYPE-POOL=D\\TYPE=DATS'
       OR ls_comp-type->type_kind = cl_abap_elemdescr=>typekind_date.
      " 'YYYY-MM-DD' → 'YYYYMMDD'
      DATA(lv_date_format) = VALUE xudatfm( ).
      DATA(lv_date) = VALUE d( ).
      DATA(lv_date_found) = VALUE abap_bool( ).

      lo_descr_ref ?= cl_abap_elemdescr=>describe_by_data( lv_date_format ).
      IF lo_descr_ref IS BOUND.
        lo_descr_ref->get_ddic_fixed_values( RECEIVING  p_fixed_values = DATA(lt_fixed_values)
                                             EXCEPTIONS not_found      = 1
                                                        no_ddic_type   = 2
                                                        OTHERS         = 3 ).
      ENDIF.
      LOOP AT lt_fixed_values INTO FINAL(ls_fixed_values).
        lv_date_format = CONV #( ls_fixed_values-low ).

        TRY.
            cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext   = lv_value
                                                           im_datfmdes = lv_date_format
                                                 IMPORTING ex_datint   = lv_date ).
            lv_date_found = abap_true.
            EXIT.
          CATCH cx_abap_datfm_no_date
                cx_abap_datfm_invalid_date
                cx_abap_datfm_format_unknown
                cx_abap_datfm_ambiguous.
        ENDTRY.
      ENDLOOP.

      IF lv_date_found IS NOT INITIAL.
        lv_value = lv_date.
      ELSE.
        REPLACE ALL OCCURRENCES OF '-' IN lv_value WITH ''.
        REPLACE ALL OCCURRENCES OF '.' IN lv_value WITH ''.
        REPLACE ALL OCCURRENCES OF '/' IN lv_value WITH ''.
      ENDIF.
    ELSEIF ls_comp-type->type_kind = cl_abap_elemdescr=>typekind_time.
      " 'HH:MM:SS' → 'HHMMSS'

      DATA(lv_time) = VALUE t( ).
      IF contains_any_of( val = iv_value
                          sub = ':' ).
        TRY.
            cl_abap_timefm=>conv_time_ext_to_int( EXPORTING time_ext      = lv_value
                                                            is_24_allowed = abap_true
                                                  IMPORTING time_int      = lv_time ).

            lv_value = lv_time.
          CATCH cx_abap_timefm_invalid.
            REPLACE ALL OCCURRENCES OF ':' IN lv_value WITH ''.
        ENDTRY.
      ELSE.
        REPLACE ALL OCCURRENCES OF ':' IN lv_value WITH ''.
      ENDIF.
    ENDIF.

    TRY.
        <lv_comp> = lv_value. " Let ABAP implicit conversion do the rest
      CATCH cx_root.
        " swallow conversion issues to keep parsing going; you may log here
        RETURN.
    ENDTRY.

    ASSIGN COMPONENT iv_comp_name OF STRUCTURE <lv_row> TO FIELD-SYMBOL(<lv_comp_value>).
    IF <lv_comp_value> IS ASSIGNED.
      <lv_comp_value> = <lv_comp>.
    ENDIF.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    DATA lo_sample_xml TYPE REF TO lcl_sample_xml.

    lo_sample_xml->sample_xml_display( io_out = out ).
  ENDMETHOD.
ENDCLASS.

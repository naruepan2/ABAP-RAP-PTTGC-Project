CLASS zcl_ext_spreadsheet_utilities DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES ty_rawstring          TYPE x LENGTH 255.
    TYPES ty_mimetype           TYPE cl_bcs_mail_bodypart=>ty_content_type.

    TYPES tt_worksheet_position TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES tt_worksheet_names    TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES tt_rawstring          TYPE TABLE OF ty_rawstring WITH EMPTY KEY.

    TYPES:
      BEGIN OF ts_excel_data_ref,
        sheet            TYPE string,
        sheet_position   TYPE i,
        data_ref         TYPE REF TO data,
        data_ref_records TYPE i,
      END OF ts_excel_data_ref.
    TYPES tt_excel_data_ref TYPE STANDARD TABLE OF ts_excel_data_ref WITH EMPTY KEY.

    TYPES:
      BEGIN OF ts_excel_log,
        excel_row TYPE i,
        excel_col TYPE i,
        message   TYPE string,
      END OF ts_excel_log.
    TYPES tt_excel_log TYPE STANDARD TABLE OF ts_excel_log WITH EMPTY KEY.

    CONSTANTS c_mimetype_xlsx          TYPE ty_mimetype
                                       VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
    CONSTANTS c_xlsx_type              TYPE string                               VALUE '.xlsx'.
    CONSTANTS c_start_spreadsheet_date TYPE cl_abap_context_info=>ty_system_date VALUE '19000101'.

    CLASS-METHODS create_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_spreadsheet_utilities.

    METHODS constructor.

    METHODS read_spreadsheet_data
      IMPORTING iv_file_content         TYPE xstring
                iv_begin_row            TYPE i                                  OPTIONAL
                iv_end_row              TYPE i                                  OPTIONAL
                iv_begin_column         TYPE i                                  OPTIONAL
                iv_end_column           TYPE i                                  OPTIONAL
                it_worksheet_name       TYPE tt_worksheet_names                 OPTIONAL
                it_worksheet_position   TYPE tt_worksheet_position              OPTIONAL
                iv_append_itab          TYPE abap_boolean                       OPTIONAL
                iv_user_date_format     TYPE abap_boolean                       OPTIONAL            " Get date format from User Configuration(SU01)
                iv_date_format          TYPE xudatfm                            DEFAULT '1'         " Format DD.MM.YYYY (Gregorian Date)
                iv_set_alpha_in         TYPE abap_boolean                       DEFAULT abap_true
                io_value_transformation TYPE REF TO if_xco_xlsx_ra_vt_row_value OPTIONAL            " see detail: xco_cp_xlsx_read_access=>value_transformation
                iv_get_all_worksheet    TYPE abap_boolean                       OPTIONAL
                iv_only_not_error       TYPE abap_boolean                       OPTIONAL
                iv_clear_all_if_error   TYPE abap_boolean                       OPTIONAL
                iv_ignore_map_to_itab   TYPE abap_boolean                       OPTIONAL
                iv_exceed_to_background TYPE i                                  OPTIONAL
      EXPORTING et_data                 TYPE table
                et_worksheets           TYPE tt_excel_data_ref
                ev_has_error            TYPE abap_boolean
                ev_msg                  TYPE string
                et_excel_log            TYPE tt_excel_log
      RETURNING VALUE(ro_instance)      TYPE REF TO zcl_ext_spreadsheet_utilities.

    METHODS write_spreadsheet_data
      IMPORTING it_data               TYPE STANDARD TABLE
                it_header_content     TYPE tt_worksheet_names OPTIONAL
                iv_file_content       TYPE xstring            OPTIONAL
                iv_worksheet_name     TYPE string             OPTIONAL
                iv_position           TYPE i                  OPTIONAL
                iv_with_header        TYPE abap_boolean       DEFAULT abap_true
                iv_user_date_format   TYPE abap_boolean       OPTIONAL                      " Get date format from User Configuration(SU01)
                iv_date_format        TYPE xudatfm            DEFAULT '1'                   " Format DD.MM.YYYY (Gregorian Date)
                iv_set_alpha_out      TYPE abap_boolean       DEFAULT abap_true
                iv_user_format        TYPE i                  OPTIONAL                      " cl_abap_format=>n_user
                iv_only_not_error     TYPE abap_boolean       OPTIONAL
                iv_clear_all_if_error TYPE abap_boolean       OPTIONAL
      EXPORTING ev_file_content       TYPE xstring
                ev_mimetype           TYPE ty_mimetype
                ev_has_error          TYPE abap_boolean
                ev_msg                TYPE string
                et_excel_log          TYPE tt_excel_log
      RETURNING VALUE(ro_instance)    TYPE REF TO zcl_ext_spreadsheet_utilities.

    METHODS convert_input_data_format
      IMPORTING iv_value           TYPE any
                iv_convert_inout   TYPE c            DEFAULT '1'       " 1 = Input, 2 = Output
                iv_date_format     TYPE xudatfm      OPTIONAL
                iv_current_row     TYPE i            OPTIONAL
                iv_runno_row       TYPE i            OPTIONAL
                iv_set_alpha_inout TYPE c            OPTIONAL
                iv_user_format     TYPE i            OPTIONAL
      EXPORTING ev_value           TYPE any
                ev_error           TYPE abap_boolean
      CHANGING  ct_excel_log       TYPE tt_excel_log OPTIONAL.

    CLASS-METHODS encode_string_to_x64
      IMPORTING iv_string            TYPE string
                iv_encoding          TYPE abap_encoding OPTIONAL
      RETURNING VALUE(rv_encode_x64) TYPE string.

    CLASS-METHODS encode_xstring_to_x64
      IMPORTING iv_xstring           TYPE xstring
      RETURNING VALUE(rv_encode_x64) TYPE string.

    CLASS-METHODS decode_x64_to_xstring
      IMPORTING iv_encode_x64     TYPE string
      RETURNING VALUE(rv_xstring) TYPE xstring.

    METHODS transfer_spreadsheet_to_itab
      IMPORTING it_worksheets         TYPE tt_excel_data_ref OPTIONAL
                iv_begin_row          TYPE i                 OPTIONAL
                iv_end_row            TYPE i                 OPTIONAL
                iv_begin_column       TYPE i                 OPTIONAL
                iv_end_column         TYPE i                 OPTIONAL
                iv_append_itab        TYPE abap_boolean      OPTIONAL
                iv_user_date_format   TYPE abap_boolean      OPTIONAL            " Get date format from User Configuration(SU01)
                iv_date_format        TYPE xudatfm           DEFAULT '1'         " Format DD.MM.YYYY (Gregorian Date)
                iv_set_alpha_inout    TYPE c                 OPTIONAL
                iv_only_not_error     TYPE abap_boolean      OPTIONAL
                iv_clear_all_if_error TYPE abap_boolean      OPTIONAL
      EXPORTING et_data               TYPE table
                et_worksheets         TYPE tt_excel_data_ref
                ev_has_error          TYPE abap_boolean
                et_excel_log          TYPE tt_excel_log
      RETURNING VALUE(ro_instance)    TYPE REF TO zcl_ext_spreadsheet_utilities.

    CLASS-METHODS get_abap_field_elemdescr
      IMPORTING iv_field           TYPE any
      RETURNING VALUE(ro_elemtype) TYPE REF TO cl_abap_elemdescr.

    CLASS-METHODS get_abap_dynamic_components
      IMPORTING is_structure       TYPE any          OPTIONAL
                it_table           TYPE ANY TABLE    OPTIONAL
                iv_no_client_field TYPE abap_boolean DEFAULT space
      EXPORTING eo_structdescr     TYPE REF TO cl_abap_structdescr
                eo_tabledescr      TYPE REF TO cl_abap_tabledescr
                et_components      TYPE cl_abap_structdescr=>component_table.

  PRIVATE SECTION.
    DATA mv_max_column        TYPE i.
    DATA mv_is_read_file      TYPE abap_boolean.
    DATA mv_process_in_bckgrd TYPE abap_boolean.

    DATA mt_fixed_values      TYPE cl_abap_elemdescr=>fixvalues.
    DATA mt_worksheets        TYPE tt_excel_data_ref.

    DATA mv_date_format       TYPE xudatfm.

    METHODS _create_dynamic_table
      IMPORTING it_data       TYPE ANY TABLE
      EXPORTING ev_max_column TYPE i
                er_dyn_tab    TYPE REF TO data
      RAISING   cx_sy_table_creation
                cx_sy_struct_creation.

    METHODS _mapping_spreadsheet_to_itab
      IMPORTING iv_begin_row          TYPE i            OPTIONAL
                iv_end_row            TYPE i            OPTIONAL
                iv_begin_column       TYPE i            OPTIONAL
                iv_end_column         TYPE i            OPTIONAL
                iv_append_itab        TYPE abap_boolean OPTIONAL
                iv_user_date_format   TYPE abap_boolean OPTIONAL                    " Get date format from User Configuration(SU01)
                iv_date_format        TYPE xudatfm      OPTIONAL
                iv_set_alpha_inout    TYPE c            OPTIONAL
                iv_only_not_error     TYPE abap_boolean OPTIONAL
                iv_clear_all_if_error TYPE abap_boolean OPTIONAL
      EXPORTING ev_has_error          TYPE abap_boolean
      CHANGING  ct_spreadsheet        TYPE table
                ct_data               TYPE table
                ct_excel_log          TYPE tt_excel_log OPTIONAL.

    METHODS _mapping_itab_to_spreadsheet
      IMPORTING it_data               TYPE table
                it_header_content     TYPE tt_worksheet_names OPTIONAL
                iv_user_date_format   TYPE abap_boolean       OPTIONAL              " Get date format from User Configuration(SU01)
                iv_date_format        TYPE xudatfm            OPTIONAL
                iv_set_alpha_inout    TYPE c                  OPTIONAL
                iv_with_header        TYPE abap_boolean       DEFAULT abap_true
                iv_user_format        TYPE i                  OPTIONAL
                iv_only_not_error     TYPE abap_boolean       OPTIONAL
                iv_clear_all_if_error TYPE abap_boolean       OPTIONAL
      EXPORTING ev_has_error          TYPE abap_boolean
      CHANGING  ct_spreadsheet        TYPE table
                ct_excel_log          TYPE tt_excel_log       OPTIONAL.

    METHODS _get_abap_datfm_datatype.

    METHODS _replace_string_dec_to_zero
      IMPORTING iv_value TYPE any
      EXPORTING ev_value TYPE any.

    CLASS-METHODS _get_all_of_components
      IMPORTING is_structure        TYPE ANY TABLE                  OPTIONAL
                it_data             TYPE ANY TABLE                  OPTIONAL
                io_abap_structdescr TYPE REF TO cl_abap_structdescr OPTIONAL
                io_abap_tabledescr  TYPE REF TO cl_abap_tabledescr  OPTIONAL
      CHANGING  ct_components       TYPE cl_abap_structdescr=>component_table.

ENDCLASS.


CLASS zcl_ext_spreadsheet_utilities IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    NEW lcl_sample_utils( )->display_sample_read_xlsx( out ).
  ENDMETHOD.

  METHOD create_instance.
    RETURN NEW #( ).
  ENDMETHOD.

  METHOD constructor.
    _get_abap_datfm_datatype( ).
  ENDMETHOD.

  METHOD read_spreadsheet_data.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Reference:
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/xlsx
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/xlsx-read-access
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lo_file_contnt          TYPE REF TO if_xco_cp_xlsx_doc_file_contnt.
    DATA lo_read_access          TYPE REF TO if_xco_xlsx_ra_document.
    DATA lo_worksheet            TYPE REF TO if_xco_xlsx_ra_worksheet.
    DATA lo_selection_pattern    TYPE REF TO if_xco_xlsx_slc_pattern.
    DATA lo_value_transformation TYPE REF TO if_xco_xlsx_ra_vt_row_value.

    DATA lv_get_all_worksheet    TYPE abap_bool.

    FIELD-SYMBOLS <ls_excel_data_ref> TYPE ts_excel_data_ref.

    " The implementation of the visitor, such as a dedicated local class containing the
    " logic that will be performed for each visited cell.

    CLEAR: et_data,
           et_worksheets,
           ev_has_error,
           ev_msg,
           et_excel_log,
           mv_is_read_file.

    ro_instance = me.

    " Validate input parameters
    IF iv_file_content IS INITIAL.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Spreadsheet or File Content does not found' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ELSEIF iv_begin_row > iv_end_row AND iv_end_row > 0.
      ev_has_error = abap_true.
      ev_msg       = 'Begin Row is greater than End Row'.
    ELSEIF iv_begin_column > iv_end_column AND iv_end_column > 0.
      ev_has_error = abap_true.
      ev_msg       = 'Begin Column is greater than End Column'.
    ENDIF.

    " Read file content
    lo_file_contnt = xco_cp_xlsx=>document->for_file_content( iv_file_content ).
    IF lo_file_contnt IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Cannot read File Content' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    " Access file content
    lo_read_access = lo_file_contnt->read_access( ).
    IF lo_read_access IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Cannot access Spreadsheet file' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    " Prepare table for spreadsheet
    _create_dynamic_table( EXPORTING it_data       = et_data
                           IMPORTING ev_max_column = mv_max_column
                                     er_dyn_tab    = DATA(lr_dyn_itab) ).

    IF lr_dyn_itab IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Internal Table has some error' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    ASSIGN lr_dyn_itab->* TO FIELD-SYMBOL(<lt_itab>).

    " A selection pattern that was obtained via XCO_CP_XLSX_SELECTION=>PATTERN_BUILDER.
    " The selection pattern LO_PATTERN_4 is completely unbounded, matching all cells of the
    " worksheet, hence also all values of the above worksheet.
    lo_selection_pattern = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    TRY.
        lo_value_transformation = COND #( WHEN io_value_transformation IS BOUND
                                          THEN CAST #( io_value_transformation )
                                          ELSE CAST #( xco_cp_xlsx_read_access=>value_transformation->best_effort ) ).
      CATCH cx_root.
        lo_value_transformation = CAST #( xco_cp_xlsx_read_access=>value_transformation->best_effort ).
    ENDTRY.

    IF it_worksheet_name IS NOT INITIAL.
      lv_get_all_worksheet = iv_get_all_worksheet.
      lv_get_all_worksheet = space.                     " To support on-premise or private cloud only

      IF lv_get_all_worksheet IS NOT INITIAL.
*        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*        " At current It supports public cloud only
*        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*        DATA(lt_worksheets) = VALUE if_xco_xlsx_ra_worksheets=>list( ).
*
*        lt_worksheets = lo_read_access->get_workbook( )->worksheet->all->get( ).
*
*        DATA(lt_worksheet_name) = it_worksheet_name.
*
*        LOOP AT lt_worksheet_name ASSIGNING FIELD-SYMBOL(<lv_worksheet_name>).
*          <lv_worksheet_name> = |{ <lv_worksheet_name> CASE = UPPER }|.
*        ENDLOOP.
*
*        LOOP AT lt_worksheets INTO DATA(ls_worksheets) WHERE table_line IS NOT INITIAL.
*          IF lt_worksheet_name IS NOT INITIAL.
*            IF NOT line_exists( lt_worksheet_name[ table_line = |{ ls_worksheets->get_name( ) CASE = UPPER }| ] ).
*              CONTINUE.
*            ENDIF.
*          ENDIF.
*
*          CLEAR <lt_itab>.
*          " At this point, the internal table LT_ROWS will contain the rows from the worksheet
*          " selection.
*          ls_worksheets->select( lo_selection_pattern
*            )->row_stream(
*            )->operation->write_to( REF #( <lt_itab> )
*            )->if_xco_xlsx_ra_operation~execute( ).
*
*          INSERT INITIAL LINE INTO TABLE et_worksheets ASSIGNING <ls_excel_data_ref>.
*          <ls_excel_data_ref>-sheet            = |{ ls_worksheets->get_name( ) CASE = UPPER }|.
*          <ls_excel_data_ref>-data_ref         = REF #( <lt_itab> ).
*          <ls_excel_data_ref>-data_ref_records = lines( <lt_itab> ).
*
*          IF     <ls_excel_data_ref>-data_ref_records >= abs( iv_exceed_to_background )
*             AND iv_exceed_to_background              IS SUPPLIED.
*            mv_process_in_bgpf = abap_true.
*          ENDIF.
*
*          IF     et_data IS SUPPLIED
*             AND (    iv_ignore_map_to_itab IS INITIAL
*                   OR mv_process_in_bckgrd  IS INITIAL ).
*            _mapping_spreadsheet_to_itab( EXPORTING iv_begin_row          = iv_begin_row
*                                                    iv_end_row            = iv_end_row
*                                                    iv_begin_column       = iv_begin_column
*                                                    iv_end_column         = iv_end_column
*                                                    iv_append_itab        = iv_append_itab
*                                                    iv_user_date_format   = iv_user_date_format
*                                                    iv_date_format        = iv_date_format
*                                                    iv_set_alpha_inout    = iv_set_alpha_inout
*                                                    iv_only_not_error     = iv_only_not_error
*                                                    iv_clear_all_if_error = iv_clear_all_if_error
*                                          IMPORTING ev_error              = ev_has_error
*                                          CHANGING  ct_spreadsheet        = <lt_itab>
*                                                    ct_data               = et_data
*                                                    ct_excel_log          = et_excel_log ).
*          ENDIF.
*        ENDLOOP.
      ELSE.
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        " Read with WorkSheet
        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
        DATA(lt_worksheet_name) = it_worksheet_name.

        LOOP AT lt_worksheet_name ASSIGNING FIELD-SYMBOL(<lv_worksheet_name>) WHERE table_line IS NOT INITIAL.
          CLEAR lo_worksheet.

          <lv_worksheet_name> = to_upper( <lv_worksheet_name> ).

          lo_worksheet = lo_read_access->get_workbook( )->worksheet->for_name( iv_name = <lv_worksheet_name> ).

          IF    lo_worksheet IS NOT BOUND
             OR (     lo_worksheet            IS BOUND
                  AND lo_worksheet->exists( ) IS INITIAL ).
            et_excel_log = VALUE #( BASE et_excel_log
                                    ( message = |{ <lv_worksheet_name> } is not exists| ) ).
            ev_msg       = COND #( WHEN ev_msg IS INITIAL THEN VALUE #( et_excel_log[ 1 ]-message OPTIONAL ) ELSE ev_msg ).
            ev_has_error = abap_true.
            CONTINUE.
          ENDIF.

          CLEAR <lt_itab>.
          " At this point, the internal table LT_ROWS will contain the rows from the worksheet
          " selection.
          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_to( REF #( <lt_itab> )
            )->set_value_transformation( CAST #( lo_value_transformation )
            )->execute( ).

          INSERT INITIAL LINE INTO TABLE et_worksheets ASSIGNING <ls_excel_data_ref>.
          <ls_excel_data_ref>-sheet            = <lv_worksheet_name>.
          <ls_excel_data_ref>-data_ref         = REF #( <lt_itab> ).
          <ls_excel_data_ref>-data_ref_records = lines( <lt_itab> ).

          IF     <ls_excel_data_ref>-data_ref_records >= abs( iv_exceed_to_background )
             AND <ls_excel_data_ref>-data_ref_records  > 0
             AND iv_exceed_to_background              IS SUPPLIED.
            mv_process_in_bckgrd = abap_true.
          ENDIF.

          " Mapping from spreadsheet to internal table
          IF     et_data IS SUPPLIED
             AND (    iv_ignore_map_to_itab IS INITIAL
                   OR mv_process_in_bckgrd  IS INITIAL ).
            _mapping_spreadsheet_to_itab(
              EXPORTING iv_begin_row          = iv_begin_row
                        iv_end_row            = iv_end_row
                        iv_begin_column       = iv_begin_column
                        iv_end_column         = iv_end_column
                        iv_append_itab        = iv_append_itab
                        iv_user_date_format   = iv_user_date_format
                        iv_date_format        = iv_date_format
                        iv_set_alpha_inout    = COND #( WHEN iv_set_alpha_in IS NOT INITIAL THEN '1' )
                        iv_only_not_error     = iv_only_not_error
                        iv_clear_all_if_error = iv_clear_all_if_error
              IMPORTING ev_has_error          = ev_has_error
              CHANGING  ct_spreadsheet        = <lt_itab>
                        ct_data               = et_data
                        ct_excel_log          = et_excel_log ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSEIF it_worksheet_position IS NOT INITIAL.
      DATA(lt_worksheet_position) = it_worksheet_position.
      DELETE lt_worksheet_position WHERE table_line <= 0.
      SORT lt_worksheet_position BY table_line.
      DELETE ADJACENT DUPLICATES FROM lt_worksheet_position COMPARING ALL FIELDS.

      LOOP AT lt_worksheet_position INTO DATA(lv_worksheet_position).
        CLEAR lo_worksheet.
        " Read access for the worksheet at position n
        lo_worksheet = lo_read_access->get_workbook( )->worksheet->at_position( lv_worksheet_position ).

        IF    lo_worksheet IS NOT BOUND
           OR (     lo_worksheet            IS BOUND
                AND lo_worksheet->exists( ) IS INITIAL ).
          et_excel_log = VALUE #( BASE et_excel_log
                                  ( message = |Position of Worksheet { lv_worksheet_position } is not exists| ) ).
          ev_msg       = COND #( WHEN ev_msg IS INITIAL THEN VALUE #( et_excel_log[ 1 ]-message OPTIONAL ) ELSE ev_msg ).
          ev_has_error = abap_true.
          CONTINUE.
        ENDIF.

        CLEAR <lt_itab>.

        " At this point, the internal table LT_ROWS will contain the rows from the worksheet
        " selection.
        lo_worksheet->select( lo_selection_pattern
          )->row_stream(
          )->operation->write_to( REF #( <lt_itab> )
          )->set_value_transformation( CAST #( lo_value_transformation )
          )->execute( ).

        INSERT INITIAL LINE INTO TABLE et_worksheets ASSIGNING <ls_excel_data_ref>.
        <ls_excel_data_ref>-sheet_position   = lv_worksheet_position.
        <ls_excel_data_ref>-data_ref         = REF #( <lt_itab> ).
        <ls_excel_data_ref>-data_ref_records = lines( <lt_itab> ).

        IF     <ls_excel_data_ref>-data_ref_records >= abs( iv_exceed_to_background )
           AND <ls_excel_data_ref>-data_ref_records  > 0
           AND iv_exceed_to_background              IS SUPPLIED.
          mv_process_in_bckgrd = abap_true.
        ENDIF.

        " Mapping from spreadsheet to internal table
        IF     et_data IS SUPPLIED
           AND (    iv_ignore_map_to_itab IS INITIAL
                 OR mv_process_in_bckgrd  IS INITIAL ).
          _mapping_spreadsheet_to_itab(
            EXPORTING iv_begin_row          = iv_begin_row
                      iv_end_row            = iv_end_row
                      iv_begin_column       = iv_begin_column
                      iv_end_column         = iv_end_column
                      iv_append_itab        = iv_append_itab
                      iv_user_date_format   = iv_user_date_format
                      iv_date_format        = iv_date_format
                      iv_set_alpha_inout    = COND #( WHEN iv_set_alpha_in IS NOT INITIAL THEN '1' )
                      iv_only_not_error     = iv_only_not_error
                      iv_clear_all_if_error = iv_clear_all_if_error
            IMPORTING ev_has_error          = ev_has_error
            CHANGING  ct_spreadsheet        = <lt_itab>
                      ct_data               = et_data
                      ct_excel_log          = et_excel_log ).
        ENDIF.
      ENDLOOP.
    ELSE.
      " Read access for the worksheet at position 1, such as the first worksheet in the workbook.
      lo_worksheet = lo_read_access->get_workbook( )->worksheet->at_position( 1 ).

      IF    lo_worksheet IS NOT BOUND
         OR (     lo_worksheet            IS BOUND
              AND lo_worksheet->exists( ) IS INITIAL ).
        et_excel_log = VALUE #( BASE et_excel_log
                                ( message = 'First worksheet does not found' ) ).
        ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
        ev_has_error = abap_true.
        RETURN.
      ENDIF.

      " At this point, the internal table LT_ROWS will contain the rows from the worksheet
      " selection.
      lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_to( REF #( <lt_itab> )
        )->set_value_transformation( CAST #( lo_value_transformation )
        )->execute( ).

      INSERT INITIAL LINE INTO TABLE et_worksheets ASSIGNING <ls_excel_data_ref>.
      <ls_excel_data_ref>-sheet_position   = 1.
      <ls_excel_data_ref>-data_ref         = REF #( <lt_itab> ).
      <ls_excel_data_ref>-data_ref_records = lines( <lt_itab> ).

      IF     <ls_excel_data_ref>-data_ref_records >= abs( iv_exceed_to_background )
         AND <ls_excel_data_ref>-data_ref_records  > 0
         AND iv_exceed_to_background              IS SUPPLIED.
        mv_process_in_bckgrd = abap_true.
      ENDIF.

      " Mapping from spreadsheet to internal table
      IF     et_data IS SUPPLIED
         AND (    iv_ignore_map_to_itab IS INITIAL
               OR mv_process_in_bckgrd  IS INITIAL ).
        _mapping_spreadsheet_to_itab(
          EXPORTING iv_begin_row        = iv_begin_row
                    iv_end_row          = iv_end_row
                    iv_begin_column     = iv_begin_column
                    iv_end_column       = iv_end_column
                    iv_append_itab      = iv_append_itab
                    iv_user_date_format = iv_user_date_format
                    iv_date_format      = iv_date_format
                    iv_set_alpha_inout  = COND #( WHEN iv_set_alpha_in IS NOT INITIAL THEN '1' )
          IMPORTING ev_has_error        = ev_has_error
          CHANGING  ct_spreadsheet      = <lt_itab>
                    ct_data             = et_data
                    ct_excel_log        = et_excel_log ).
      ENDIF.
    ENDIF.

    IF et_worksheets IS NOT INITIAL.
      mt_worksheets = VALUE #( BASE mt_worksheets
                               ( LINES OF et_worksheets ) ).
    ENDIF.
  ENDMETHOD.

  METHOD write_spreadsheet_data.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Reference:
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/xlsx
    "   - https://help.sap.com/docs/btp/sap-business-technology-platform/xlsx-write-access
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lo_write_access      TYPE REF TO if_xco_xlsx_wa_document.
    DATA lo_worksheet         TYPE REF TO if_xco_xlsx_wa_worksheet.
    DATA lo_selection_pattern TYPE REF TO if_xco_xlsx_slc_pattern.

    CLEAR: ev_file_content,
           ev_mimetype,
           ev_has_error,
           ev_msg,
           et_excel_log.

    ro_instance = me.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " At current It supports public cloud only
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    IF iv_file_content IS NOT INITIAL.
*      lo_write_access = xco_cp_xlsx=>document->for_file_content( iv_file_content = iv_file_content )->write_access( ).
      lo_write_access = xco_cp_xlsx=>document->empty( )->write_access( ).
      " TODO: variable is assigned but never used (ABAP cleaner)
      DATA(lv_file_content) = lo_write_access->get_file_content( ).
    ELSE.
      lo_write_access = xco_cp_xlsx=>document->empty( )->write_access( ).
    ENDIF.

    IF lo_write_access IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Spreadsheet or File Content cannot write access' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    IF iv_worksheet_name IS NOT INITIAL.
*      lo_worksheet = lo_write_access->get_workbook( )->add_new_sheet( iv_worksheet_name ).
    ELSEIF iv_position IS NOT INITIAL.
      lo_worksheet = lo_write_access->get_workbook( )->worksheet->at_position( iv_position ).
    ELSE.
      lo_worksheet = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).
    ENDIF.

    IF lo_worksheet IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Spreadsheet or File cannot add new sheet' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    " Prepare table for spreadsheet
    _create_dynamic_table( EXPORTING it_data       = it_data
                           IMPORTING ev_max_column = mv_max_column
                                     er_dyn_tab    = DATA(lr_dyn_itab) ).

    IF lr_dyn_itab IS NOT BOUND.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'Internal Table has some error' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    ASSIGN lr_dyn_itab->* TO FIELD-SYMBOL(<lt_itab>).

    " Mapping from internal table to spreadsheet
    _mapping_itab_to_spreadsheet(
      EXPORTING it_data               = it_data
                it_header_content     = it_header_content
                iv_user_date_format   = iv_user_date_format
                iv_date_format        = iv_date_format
                iv_set_alpha_inout    = COND #( WHEN iv_set_alpha_out IS NOT INITIAL THEN '2' )
                iv_with_header        = iv_with_header
                iv_user_format        = iv_user_format
                iv_only_not_error     = iv_only_not_error
                iv_clear_all_if_error = iv_clear_all_if_error
      IMPORTING ev_has_error          = ev_has_error
      CHANGING  ct_spreadsheet        = <lt_itab>
                ct_excel_log          = et_excel_log ).

    IF <lt_itab> IS INITIAL.
      et_excel_log = VALUE #( BASE et_excel_log
                              ( message = 'No data found in the internal table' ) ).
      ev_msg       = VALUE #( et_excel_log[ 1 ]-message OPTIONAL ).
      ev_has_error = abap_true.
      RETURN.
    ENDIF.

    " A selection pattern that was obtained via XCO_CP_XLSX_SELECTION=>PATTERN_BUILDER.
    " The selection pattern LO_PATTERN_4 is completely unbounded, matching all cells of the
    " worksheet, hence also all values of the above worksheet.
    lo_selection_pattern = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_from( REF #( <lt_itab> )
      )->set_value_transformation( xco_cp_xlsx_write_access=>value_transformation->best_effort
      )->execute( ).

    " At this point, the rows of internal table LT_ROWS will have been written into the
    " worksheet selection.
    ev_file_content = lo_write_access->get_file_content( ).
    ev_mimetype     = c_mimetype_xlsx.
    " ----------------------------------------------------------------------
  ENDMETHOD.

  METHOD convert_input_data_format.
    TYPES lty_date_txt TYPE c LENGTH 10.

    CONSTANTS lc_base_date TYPE d VALUE '18991230'. " Excel base date minus 1

    DATA lx_root        TYPE REF TO cx_root.
    DATA lo_elemtype    TYPE REF TO cl_abap_elemdescr.
    DATA lv_decfloat16  TYPE decfloat16.
    DATA lv_decfloat34  TYPE decfloat34.
    DATA lv_date_format TYPE xudatfm.

    CASE iv_convert_inout.
      WHEN '1'.      " Input
        IF iv_value IS INITIAL.
          RETURN.
        ENDIF.

        lo_elemtype = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( ev_value ) ).

        CASE lo_elemtype->type_kind.
          WHEN cl_abap_typedescr=>typekind_date.
            TRY.
                lv_date_format = iv_date_format.

                IF iv_user_format IS NOT INITIAL.
                  lv_date_format = cl_abap_datfm=>get_datfm( ).
                ENDIF.

                IF NOT to_upper( lv_date_format ) CO '123456789ABC'.
                  CLEAR lv_date_format.
                ENDIF.

                ##DATE_FORMAT
                IF lv_date_format IS NOT INITIAL.
                  cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext   = condense( val = iv_value )
                                                                 im_datfmdes = lv_date_format
                                                       IMPORTING ex_datint   = ev_value ).
                ELSE.
                  " May occurs low performance of not pass iv_date_format because it will be find date format pattern as possible
                  LOOP AT mt_fixed_values INTO DATA(ls_fixed_values).
                    TRY.
                        cl_abap_datfm=>conv_date_ext_to_int(
                          EXPORTING im_datext   = iv_value
                                    im_datfmdes = CONV cl_abap_datfm=>ty_datfm( ls_fixed_values-low )
                          IMPORTING ex_datint   = ev_value ).
                        EXIT.
                      CATCH cx_abap_datfm.
                    ENDTRY.
                  ENDLOOP.

                  IF ev_value IS INITIAL.
                    TRY.
                        cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext = condense( val = iv_value )
                                                             IMPORTING ex_datint = ev_value ).
                      CATCH cx_root INTO FINAL(lx_error).
                        TRY.
                            DATA(lr_dattxt) = NEW lty_date_txt( |{ CONV d( lc_base_date + iv_value ) DATE = USER }| ).

                            cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext = lr_dattxt->*
                                                                 IMPORTING ex_datint = ev_value ).
                          CATCH cx_root.
                            ev_error     = abap_true.
                            ct_excel_log = VALUE #( BASE ct_excel_log
                                                    ( excel_row = iv_current_row
                                                      excel_col = iv_runno_row
                                                      message   = COND #( WHEN lx_error->get_longtext( ) IS NOT INITIAL
                                                                          THEN lx_error->get_longtext( )
                                                                          ELSE lx_error->get_text( ) ) ) ).
                        ENDTRY.
                    ENDTRY.
                  ENDIF.
                ENDIF.
              CATCH cx_abap_datfm INTO DATA(lx_date1).
                IF condense( val = iv_value ) CO '1234567890'.
                  ev_value = CONV d( c_start_spreadsheet_date + CONV i( condense( val = iv_value ) ) - 2 ).

                  IF CONV d( ev_value ) < c_start_spreadsheet_date.
                    CLEAR ev_value.
                  ENDIF.
                ELSE.
                  CLEAR ev_value.

                  ev_error     = abap_true.
                  ct_excel_log = VALUE #( BASE ct_excel_log
                                          ( excel_row = iv_current_row
                                            excel_col = iv_runno_row
                                            message   = lx_date1->get_text( ) ) ).
                ENDIF.
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_time.
            TRY.
                cl_abap_timefm=>conv_time_ext_to_int( EXPORTING time_ext      = condense( val = iv_value )
                                                                is_24_allowed = abap_true
                                                      IMPORTING time_int      = ev_value ).
              CATCH cx_abap_timefm_invalid INTO DATA(lx_time).
                CLEAR ev_value.

                ev_error     = abap_true.
                ct_excel_log = VALUE #( BASE ct_excel_log
                                        ( excel_row = iv_current_row
                                          excel_col = iv_runno_row
                                          message   = COND #( WHEN lx_time->get_longtext( ) IS NOT INITIAL
                                                              THEN lx_time->get_longtext( )
                                                              ELSE lx_time->get_text( ) ) ) ).
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_decfloat16.
            DATA(lv_value_decfloat16) = VALUE string( ).

            _replace_string_dec_to_zero( EXPORTING iv_value = iv_value
                                         IMPORTING ev_value = lv_value_decfloat16 ).

            TRY.
                cl_abap_decfloat=>read_decfloat16( EXPORTING string = lv_value_decfloat16   " Character Format
                                                   IMPORTING value  = lv_decfloat16 ).

                ev_value = lv_decfloat16.
              CATCH cx_root INTO DATA(lx_decfloat16).
                IF lv_value_decfloat16 IS NOT INITIAL.
                  CLEAR ev_value.

                  ev_error     = abap_true.
                  ct_excel_log = VALUE #( BASE ct_excel_log
                                          ( excel_row = iv_current_row
                                            excel_col = iv_runno_row
                                            message   = COND #( WHEN lx_decfloat16->get_longtext( ) IS NOT INITIAL
                                                                THEN lx_decfloat16->get_longtext( )
                                                                ELSE lx_decfloat16->get_text( ) ) ) ).
                ENDIF.
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_packed
            OR cl_abap_typedescr=>typekind_float
            OR cl_abap_typedescr=>typekind_decfloat
            OR cl_abap_typedescr=>typekind_decfloat34.
            DATA(lv_value_decfloat34) = VALUE string( ).

            _replace_string_dec_to_zero( EXPORTING iv_value = iv_value
                                         IMPORTING ev_value = lv_value_decfloat34 ).

            TRY.
                cl_abap_decfloat=>read_decfloat34( EXPORTING string = lv_value_decfloat34    " Character Format
                                                   IMPORTING value  = lv_decfloat34 ).

                ev_value = lv_decfloat34.
              CATCH cx_root INTO DATA(lx_decfloat34).
                IF lv_value_decfloat34 IS NOT INITIAL.
                  DATA(lv_decfloat34_msg) = COND #( WHEN lx_decfloat34->get_longtext( ) IS NOT INITIAL
                                                    THEN lx_decfloat34->get_longtext( )
                                                    ELSE lx_decfloat34->get_text( ) ).
                ENDIF.

                TRY.
                    SPLIT lv_value_decfloat34 AT '.' INTO DATA(lv_num1) DATA(lv_num2).
                    lv_num1 = replace( val  = lv_num1
                                       sub  = `,`
                                       with = ``
                                       occ  = 0 ).

                    DATA(lr_decval) = NEW string( |{ lv_num1 },{ lv_num2 }| ).

                    cl_abap_decfloat=>read_decfloat34( EXPORTING string = lr_decval->*         " Character Format
                                                       IMPORTING value  = lv_decfloat34 ).

                    ev_value = lv_decfloat34.
                  CATCH cx_root INTO lx_decfloat34.
                    IF lv_value_decfloat34 IS NOT INITIAL.
                      CLEAR ev_value.

                      ev_error     = abap_true.
                      ct_excel_log = VALUE #( BASE ct_excel_log
                                              ( excel_row = iv_current_row
                                                excel_col = iv_runno_row
                                                message   = lv_decfloat34_msg ) ).
                    ENDIF.
                ENDTRY.
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_oref
            OR cl_abap_typedescr=>typekind_dref
            OR cl_abap_typedescr=>typekind_table
            OR cl_abap_typedescr=>typekind_struct1
            OR cl_abap_typedescr=>typekind_struct2.
            " Not support
          WHEN cl_abap_typedescr=>typekind_string.
            ev_value = iv_value.
          WHEN cl_abap_typedescr=>typekind_xstring.
            ev_value = /ui2/cl_json=>string_to_raw( iv_string   = iv_value
                                                    iv_encoding = space ).      "'4110'
          WHEN OTHERS.
            ev_value = iv_value.

            IF iv_set_alpha_inout IS NOT INITIAL.
              IF lo_elemtype->edit_mask IS NOT INITIAL.
                TRY.
                    DATA(lv_convexit) = substring( val = lo_elemtype->edit_mask
                                                   off = 2 ).

                    IF lv_convexit IS NOT INITIAL.
                      ev_value = |{ ev_value ALPHA = IN }|.
                    ENDIF.
                  CATCH cx_sy_range_out_of_bounds.
                ENDTRY.
              ENDIF.
            ENDIF.
        ENDCASE.
      WHEN '2'.      " Output
        IF iv_value IS INITIAL.
          RETURN.
        ENDIF.

        lo_elemtype = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( iv_value ) ).

        CASE lo_elemtype->type_kind.
          WHEN cl_abap_typedescr=>typekind_date.
            TRY.
                lv_date_format = COND #( WHEN iv_date_format IS NOT INITIAL
                                         THEN iv_date_format
                                         ELSE cl_abap_datfm=>get_datfm( ) ).

                IF lv_date_format IS INITIAL.
                  lv_date_format = '1'.     " Format with DD.MM.YYYY.
                ENDIF.

                IF NOT to_upper( lv_date_format ) CO '123456789ABC'.
                  lv_date_format = '1'.     " Format with DD.MM.YYYY.
                ENDIF.

                cl_abap_datfm=>conv_date_int_to_ext( EXPORTING im_datint   = iv_value
                                                               im_datfmdes = lv_date_format
                                                     IMPORTING ex_datext   = ev_value ).
              CATCH cx_abap_datfm_format_unknown INTO DATA(lx_date2).
                CLEAR ev_value.

                ev_error     = abap_true.
                ct_excel_log = VALUE #( BASE ct_excel_log
                                        ( excel_row = iv_current_row
                                          excel_col = iv_runno_row
                                          message   = COND #( WHEN lx_date2->get_longtext( ) IS NOT INITIAL
                                                              THEN lx_date2->get_longtext( )
                                                              ELSE lx_date2->get_text( ) ) ) ).
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_time.
            TRY.
                cl_abap_timefm=>conv_time_int_to_ext(
                  EXPORTING time_int            = iv_value
                            without_seconds     = abap_false
                            format_according_to = SWITCH #( iv_user_format
                                                            WHEN cl_abap_format=>n_raw
                                                              OR cl_abap_format=>n_user
                                                              OR cl_abap_format=>n_environment
                                                            THEN iv_user_format
                                                            ELSE cl_abap_format=>n_environment )
                  IMPORTING time_ext            = ev_value ).
              CATCH cx_parameter_invalid_range INTO DATA(lx_time2).
                CLEAR ev_value.

                ev_error     = abap_true.
                ct_excel_log = VALUE #( BASE ct_excel_log
                                        ( excel_row = iv_current_row
                                          excel_col = iv_runno_row
                                          message   = COND #( WHEN lx_time2->get_longtext( ) IS NOT INITIAL
                                                              THEN lx_time2->get_longtext( )
                                                              ELSE lx_time2->get_text( ) ) ) ).
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_decfloat16.
            TRY.
                lv_decfloat16 = iv_value.

                CASE iv_user_format.
                  WHEN cl_abap_format=>n_raw.
                    ev_value = |{ lv_decfloat16 NUMBER = RAW }|.
                  WHEN cl_abap_format=>n_user.
                    ev_value = |{ lv_decfloat16 NUMBER = USER }|.
                  WHEN cl_abap_format=>n_environment.
                    ev_value = |{ lv_decfloat16 NUMBER = ENVIRONMENT }|.
                  WHEN OTHERS.
                    ev_value = lv_decfloat34.
                ENDCASE.
              CATCH cx_root INTO lx_root.
                CLEAR ev_value.

                ev_error     = abap_true.
                ct_excel_log = VALUE #( BASE ct_excel_log
                                        ( excel_row = iv_current_row
                                          excel_col = iv_runno_row
                                          message   = COND #( WHEN lx_root->get_longtext( ) IS NOT INITIAL
                                                              THEN lx_root->get_longtext( )
                                                              ELSE lx_root->get_text( ) ) ) ).
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_packed
            OR cl_abap_typedescr=>typekind_float
            OR cl_abap_typedescr=>typekind_decfloat
            OR cl_abap_typedescr=>typekind_decfloat34.
            TRY.
                lv_decfloat34 = iv_value.

                CASE iv_user_format.
                  WHEN cl_abap_format=>n_raw.
                    ev_value = |{ lv_decfloat34 NUMBER = RAW }|.
                  WHEN cl_abap_format=>n_user.
                    ev_value = |{ lv_decfloat34 NUMBER = USER }|.
                  WHEN cl_abap_format=>n_environment.
                    ev_value = |{ lv_decfloat34 NUMBER = ENVIRONMENT }|.
                  WHEN OTHERS.
                    ev_value = lv_decfloat34.
                ENDCASE.
              CATCH cx_root INTO lx_root.
                CLEAR ev_value.

                ev_error     = abap_true.
                ct_excel_log = VALUE #( BASE ct_excel_log
                                        ( excel_row = iv_current_row
                                          excel_col = iv_runno_row
                                          message   = COND #( WHEN lx_root->get_longtext( ) IS NOT INITIAL
                                                              THEN lx_root->get_longtext( )
                                                              ELSE lx_root->get_text( ) ) ) ).
            ENDTRY.
          WHEN cl_abap_typedescr=>typekind_oref
            OR cl_abap_typedescr=>typekind_dref
            OR cl_abap_typedescr=>typekind_table
            OR cl_abap_typedescr=>typekind_struct1
            OR cl_abap_typedescr=>typekind_struct2.
            " Not support
          WHEN cl_abap_typedescr=>typekind_string.
            ev_value = iv_value.
          WHEN cl_abap_typedescr=>typekind_xstring.
            ev_value = /ui2/cl_json=>raw_to_string( iv_xstring  = iv_value
                                                    iv_encoding = space ).      "'4110'
          WHEN OTHERS.
            ev_value = iv_value.

            IF iv_set_alpha_inout IS NOT INITIAL.
              IF lo_elemtype->edit_mask IS NOT INITIAL.
                TRY.
                    DATA(lv_convexit2) = substring( val = lo_elemtype->edit_mask
                                                    off = 2 ).

                    IF lv_convexit2 IS NOT INITIAL.
                      ev_value = |{ ev_value ALPHA = OUT }|.
                    ENDIF.
                  CATCH cx_sy_range_out_of_bounds INTO DATA(lx_out_of_bounds).
                    CLEAR ev_value.

                    ev_error     = abap_true.
                    ct_excel_log = VALUE #( BASE ct_excel_log
                                            ( excel_row = iv_current_row
                                              excel_col = iv_runno_row
                                              message   = COND #( WHEN lx_out_of_bounds->get_longtext( ) IS NOT INITIAL
                                                                  THEN lx_out_of_bounds->get_longtext( )
                                                                  ELSE lx_out_of_bounds->get_text( ) ) ) ).
                ENDTRY.
              ENDIF.
            ENDIF.
        ENDCASE.
    ENDCASE.
  ENDMETHOD.

  METHOD _create_dynamic_table.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.

    CLEAR: ev_max_column,
           er_dyn_tab.

    _get_all_of_components( EXPORTING it_data       = it_data
                            CHANGING  ct_components = lt_components ).
    IF lt_components IS INITIAL.
      RETURN.
    ENDIF.

    ev_max_column = lines( lt_components ).

    DATA(lt_components_transpose) = VALUE cl_abap_structdescr=>component_table(
        FOR lv_i = 1 THEN lv_i + 1 WHILE lv_i <= ev_max_column
        ( name = |COLUMN{ lv_i }|
          type = CAST cl_abap_datadescr( cl_abap_datadescr=>describe_by_name( p_name = 'STRING' ) ) ) ).

    TRY.
        DATA(lo_tabledescr) = cl_abap_tabledescr=>create(
            p_line_type = CAST #( cl_abap_structdescr=>create( p_components = lt_components_transpose ) ) ).
      CATCH cx_sy_struct_attributes
            cx_sy_table_creation
            cx_sy_struct_creation.
        RETURN.
    ENDTRY.

    IF lo_tabledescr IS BOUND.
      CREATE DATA er_dyn_tab TYPE HANDLE lo_tabledescr.
    ENDIF.
  ENDMETHOD.

  METHOD _mapping_spreadsheet_to_itab.
    DATA lo_new_struct_descr TYPE REF TO cl_abap_structdescr.
    DATA lr_output_line      TYPE REF TO data.
    DATA lv_index            TYPE sy-index.
    DATA lv_index_data       TYPE sy-index.
    DATA lv_begin_row        TYPE i.
    DATA lv_end_row          TYPE i.
    DATA lv_current_row      TYPE i.
    DATA lv_has_error        TYPE abap_bool.

    FIELD-SYMBOLS <lv_output> TYPE any.

    CLEAR ev_has_error.

    IF iv_append_itab IS NOT INITIAL.
      CLEAR mv_is_read_file.
    ENDIF.

    IF ct_spreadsheet IS INITIAL.
      RETURN.
    ELSEIF mv_is_read_file IS NOT INITIAL.
      RETURN.
    ENDIF.

    mv_is_read_file = abap_true.        " Set already read file
    mv_date_format  = iv_date_format.   " Set date format

    IF iv_user_date_format IS NOT INITIAL.
      DATA(lv_date_format) = cl_abap_datfm=>get_datfm( ).
      mv_date_format = COND #( WHEN lv_date_format IS NOT INITIAL THEN lv_date_format ELSE mv_date_format ).
    ENDIF.

    lv_begin_row = COND #( WHEN iv_begin_row IS NOT INITIAL THEN iv_begin_row ELSE 1 ).
    lv_end_row   = COND #( WHEN iv_end_row IS NOT INITIAL THEN iv_end_row ELSE lines( ct_spreadsheet ) ).

    DATA(lv_begin_column) = COND #( WHEN iv_begin_column IS NOT INITIAL THEN iv_begin_column ELSE 1 ).
    DATA(lv_end_column) = COND #( WHEN iv_end_column IS NOT INITIAL THEN iv_end_column ELSE mv_max_column ).

    " Assign data into CT_DATA
    get_abap_dynamic_components( EXPORTING it_table      = ct_data
                                 IMPORTING et_components = DATA(lt_components) ).

    TRY.
        lo_new_struct_descr = CAST cl_abap_structdescr(
                                        cl_abap_structdescr=>create( p_components = lt_components   " Component Table
                                                                     p_strict     = abap_true ) ).  " Type Creation According to ABAP-OO Rules?
      CATCH cx_sy_struct_creation INTO DATA(lx_sy_struct_creation).
        ev_has_error = abap_true.
        ct_excel_log = VALUE #( ( message = lx_sy_struct_creation->get_text( ) ) ).
        RETURN.
    ENDTRY.

    " Mapping and Assign value to CT_DATA
    LOOP AT ct_spreadsheet ASSIGNING FIELD-SYMBOL(<lv_spreadsheet>) FROM lv_begin_row TO lv_end_row.
      CLEAR lv_index_data.

      lv_current_row = sy-tabix.

      IF <lv_spreadsheet> IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          CREATE DATA lr_output_line TYPE HANDLE lo_new_struct_descr.

          ASSIGN lr_output_line->* TO <lv_output> ELSE UNASSIGN.

          IF <lv_output> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.
        CATCH cx_root INTO DATA(lx_error). " TODO: variable is assigned but never used (ABAP cleaner)
          CONTINUE.
      ENDTRY.

      " Looping Columns
      DO.
        lv_index = sy-index.

        ASSIGN COMPONENT lv_index OF STRUCTURE <lv_spreadsheet> TO FIELD-SYMBOL(<lv_source_val>) ELSE UNASSIGN.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        " Check input Start/End Column
        IF     lv_begin_column IS NOT INITIAL
           AND lv_end_column   IS NOT INITIAL.
          IF lv_index NOT BETWEEN lv_begin_column AND lv_end_column.
            CONTINUE.
          ENDIF.
        ELSEIF     lv_begin_column IS NOT INITIAL
               AND lv_end_column   IS INITIAL.
          IF lv_index < lv_begin_column.
            CONTINUE.
          ENDIF.
        ELSEIF     lv_begin_column IS INITIAL
               AND lv_end_column   IS NOT INITIAL.
          IF lv_index > lv_end_column.
            EXIT.
          ENDIF.
        ENDIF.

        " Assign data into CT_DATA
        IF <lv_output> IS ASSIGNED.
          lv_index_data += 1.

          ASSIGN COMPONENT lv_index_data OF STRUCTURE <lv_output> TO FIELD-SYMBOL(<lv_target_val>) ELSE UNASSIGN.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          convert_input_data_format( EXPORTING iv_value           = <lv_source_val>
                                               iv_convert_inout   = '1'
                                               iv_date_format     = mv_date_format
                                               iv_current_row     = lv_current_row
                                               iv_runno_row       = lv_index_data
                                               iv_set_alpha_inout = iv_set_alpha_inout
                                     IMPORTING ev_value           = <lv_target_val>
                                               ev_error           = lv_has_error
                                     CHANGING  ct_excel_log       = ct_excel_log ).
        ENDIF.

        UNASSIGN: <lv_source_val>, <lv_target_val>.
      ENDDO.

      IF lv_has_error IS NOT INITIAL.
        ev_has_error = lv_has_error.
      ENDIF.

      IF     iv_only_not_error IS NOT INITIAL
         AND lv_has_error      IS NOT INITIAL.
        UNASSIGN <lv_output>.
        CONTINUE.
      ENDIF.

      INSERT INITIAL LINE INTO TABLE ct_data ASSIGNING FIELD-SYMBOL(<ls_data>) ELSE UNASSIGN.
      IF <ls_data> IS ASSIGNED.
        <ls_data> = CORRESPONDING #( <lv_output> ).
      ENDIF.

      UNASSIGN <lv_output>.
      CLEAR lr_output_line.
    ENDLOOP.

    IF iv_clear_all_if_error IS NOT INITIAL.
      IF ev_has_error IS NOT INITIAL.
        CLEAR ct_data.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _mapping_itab_to_spreadsheet.
    DATA lr_output_line TYPE REF TO data.
    DATA lv_current_row TYPE sy-index.
    DATA lv_index       TYPE sy-index.
    DATA lv_has_error   TYPE abap_bool.
    FIELD-SYMBOLS <lv_spreadsheet> TYPE any.
    FIELD-SYMBOLS <lv_source_val>  TYPE any.
    FIELD-SYMBOLS <lv_target_val>  TYPE any.

    IF iv_with_header IS NOT INITIAL.
      IF it_header_content IS NOT INITIAL.
        INSERT INITIAL LINE INTO TABLE ct_spreadsheet ASSIGNING <lv_spreadsheet>.

        LOOP AT it_header_content ASSIGNING FIELD-SYMBOL(<it_header_content>).
          lv_index = sy-tabix.

          ASSIGN COMPONENT lv_index OF STRUCTURE <it_header_content> TO <lv_source_val>.
          IF sy-subrc = 0.
            ASSIGN COMPONENT lv_index OF STRUCTURE <lv_spreadsheet> TO <lv_target_val>.
            IF sy-subrc = 0.
              <lv_target_val> = <lv_source_val>.
            ELSE.
              EXIT.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        DATA(lt_components) = CAST cl_abap_structdescr(
                                CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( ct_spreadsheet )
                                                       )->get_table_line_type( ) )->get_components( ).
        IF lt_components IS NOT INITIAL.
          INSERT INITIAL LINE INTO TABLE ct_spreadsheet ASSIGNING <lv_spreadsheet>.

          LOOP AT lt_components INTO DATA(ls_component).
            lv_index = sy-tabix.

            ASSIGN COMPONENT lv_index OF STRUCTURE <lv_spreadsheet> TO <lv_target_val>.
            IF sy-subrc = 0.
              TRY.
                  <lv_target_val> = ls_component-name.
                CATCH cx_root.
              ENDTRY.
            ELSE.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    mv_date_format = iv_date_format.   " Set date format

    IF iv_user_date_format IS NOT INITIAL.
      DATA(lv_date_format) = cl_abap_datfm=>get_datfm( ).
      mv_date_format = COND #( WHEN lv_date_format IS NOT INITIAL THEN lv_date_format ELSE mv_date_format ).
    ENDIF.

    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<lv_data>).
      lv_current_row = sy-tabix.

      CREATE DATA lr_output_line LIKE LINE OF ct_spreadsheet.
      IF lr_output_line IS NOT BOUND.
        CONTINUE.
      ELSE.
        ASSIGN lr_output_line->* TO <lv_spreadsheet> ELSE UNASSIGN.
      ENDIF.

      IF <lv_spreadsheet> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DO.
        lv_index = sy-index.

        ASSIGN COMPONENT lv_index OF STRUCTURE <lv_data> TO <lv_source_val>.
        IF sy-subrc = 0.
          ASSIGN COMPONENT lv_index OF STRUCTURE <lv_spreadsheet> TO <lv_target_val>.
          IF sy-subrc = 0.
            convert_input_data_format( EXPORTING iv_value           = <lv_source_val>
                                                 iv_convert_inout   = '2'
                                                 iv_date_format     = mv_date_format
                                                 iv_current_row     = lv_current_row
                                                 iv_runno_row       = lv_index
                                                 iv_set_alpha_inout = iv_set_alpha_inout
                                                 iv_user_format     = iv_user_format
                                       IMPORTING ev_value           = <lv_target_val>
                                                 ev_error           = lv_has_error
                                       CHANGING  ct_excel_log       = ct_excel_log ).
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.

      IF lv_has_error IS NOT INITIAL.
        ev_has_error = lv_has_error.
      ENDIF.

      IF     iv_only_not_error IS NOT INITIAL
         AND lv_has_error      IS NOT INITIAL.
        UNASSIGN <lv_spreadsheet>.
        CONTINUE.
      ENDIF.

      INSERT <lv_spreadsheet> INTO TABLE ct_spreadsheet.

      UNASSIGN: <lv_source_val>, <lv_target_val>.
    ENDLOOP.

    IF iv_clear_all_if_error IS NOT INITIAL.
      IF ev_has_error IS NOT INITIAL.
        CLEAR ct_spreadsheet.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD encode_string_to_x64.
    rv_encode_x64 = cl_web_http_utility=>encode_x_base64( /ui2/cl_json=>string_to_raw( iv_string   = iv_string
                                                                                       iv_encoding = iv_encoding ) ).
  ENDMETHOD.

  METHOD encode_xstring_to_x64.
    rv_encode_x64 = cl_web_http_utility=>encode_x_base64( iv_xstring ).
  ENDMETHOD.

  METHOD decode_x64_to_xstring.
    rv_xstring = cl_web_http_utility=>decode_x_base64( encoded = iv_encode_x64 ).
  ENDMETHOD.

  METHOD _get_abap_datfm_datatype.
    DATA(lr_xudatfm)      = NEW xudatfm( ).
    DATA(lo_elemtype_dat) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( lr_xudatfm->* ) ).

    IF lo_elemtype_dat IS BOUND.

      lo_elemtype_dat->get_ddic_fixed_values( EXPORTING  p_langu        = sy-langu
                                              RECEIVING  p_fixed_values = mt_fixed_values
                                              EXCEPTIONS not_found      = 1
                                                         no_ddic_type   = 2
                                                         OTHERS         = 3 ).
    ENDIF.
  ENDMETHOD.

  METHOD transfer_spreadsheet_to_itab.
    ro_instance = me.

    IF et_data IS NOT SUPPLIED.
      RETURN.
    ENDIF.

    IF     it_worksheets IS SUPPLIED
       AND it_worksheets IS NOT INITIAL.
      mt_worksheets = it_worksheets.
    ENDIF.

    LOOP AT mt_worksheets REFERENCE INTO DATA(lr_worksheets).
      IF lr_worksheets IS BOUND.
        ASSIGN lr_worksheets->data_ref->* TO FIELD-SYMBOL(<lt_itab>) ELSE UNASSIGN.
      ENDIF.

      IF <lt_itab> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      " Mapping from spreadsheet to internal table
      _mapping_spreadsheet_to_itab( EXPORTING iv_begin_row          = iv_begin_row
                                              iv_end_row            = iv_end_row
                                              iv_begin_column       = iv_begin_column
                                              iv_end_column         = iv_end_column
                                              iv_append_itab        = iv_append_itab
                                              iv_user_date_format   = iv_user_date_format
                                              iv_date_format        = iv_date_format
                                              iv_set_alpha_inout    = '1'
                                              iv_only_not_error     = iv_only_not_error
                                              iv_clear_all_if_error = iv_clear_all_if_error
                                    IMPORTING ev_has_error          = ev_has_error
                                    CHANGING  ct_spreadsheet        = <lt_itab>
                                              ct_data               = et_data
                                              ct_excel_log          = et_excel_log ).
    ENDLOOP.

    IF et_worksheets IS SUPPLIED.
      et_worksheets = mt_worksheets.
    ENDIF.
  ENDMETHOD.

  METHOD get_abap_field_elemdescr.
    ro_elemtype = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( iv_field ) ).
  ENDMETHOD.

  METHOD get_abap_dynamic_components.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component  LIKE LINE OF lt_components.

    CLEAR: eo_structdescr,
           eo_structdescr,
           et_components.

    IF is_structure IS SUPPLIED.
      eo_structdescr = CAST #( cl_abap_structdescr=>describe_by_data( p_data = is_structure ) ).
    ELSEIF it_table IS SUPPLIED.
      eo_tabledescr  = CAST #( cl_abap_tabledescr=>describe_by_data( p_data = it_table ) ).

      IF eo_tabledescr IS BOUND.
        eo_structdescr = CAST #( eo_tabledescr->get_table_line_type( ) ).
      ENDIF.
    ELSE.
      RETURN.
    ENDIF.

    IF eo_structdescr IS BOUND.
      IF et_components IS SUPPLIED.
        _get_all_of_components( EXPORTING io_abap_structdescr = eo_structdescr
                                CHANGING  ct_components       = lt_components ).
        IF     iv_no_client_field IS NOT INITIAL
           AND lt_components      IS NOT INITIAL.
          LOOP AT lt_components INTO ls_component.
            TRY.
                IF CAST cl_abap_elemdescr( CAST cl_abap_elemdescr( ls_component-type ) )->get_relative_name( ) = 'MANDT'.
                  CONTINUE.
                ENDIF.
              CATCH cx_root.
            ENDTRY.
          ENDLOOP.

          et_components = lt_components.
        ELSE.
          et_components = lt_components.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _get_all_of_components.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component  LIKE LINE OF lt_components.

    TRY.
        IF it_data IS SUPPLIED.
          lt_components = CAST cl_abap_structdescr( CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data(
                                                                                 it_data ) )->get_table_line_type( ) )->get_components( ).

          LOOP AT lt_components INTO ls_component.
            IF ls_component-as_include IS INITIAL.
              INSERT ls_component INTO TABLE ct_components.
            ELSE.
              IF ls_component-type IS INSTANCE OF cl_abap_structdescr.
                _get_all_of_components( EXPORTING io_abap_structdescr = CAST #( ls_component-type )
                                        CHANGING  ct_components       = ct_components ).
              ELSEIF ls_component-type IS INSTANCE OF cl_abap_tabledescr.
                _get_all_of_components( EXPORTING io_abap_tabledescr = CAST #( ls_component-type )
                                        CHANGING  ct_components      = ct_components ).
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSEIF is_structure IS SUPPLIED.
          lt_components = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data(
                                                        p_data = is_structure ) )->get_components( ).
          LOOP AT lt_components INTO ls_component.
            IF ls_component-as_include IS INITIAL.
              INSERT ls_component INTO TABLE ct_components.
            ELSE.
              IF ls_component-type IS INSTANCE OF cl_abap_structdescr.
                _get_all_of_components( EXPORTING io_abap_structdescr = CAST #( ls_component-type )
                                        CHANGING  ct_components       = ct_components ).
              ELSEIF ls_component-type IS INSTANCE OF cl_abap_tabledescr.
                _get_all_of_components( EXPORTING io_abap_tabledescr = CAST #( ls_component-type )
                                        CHANGING  ct_components      = ct_components ).
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSEIF io_abap_structdescr IS SUPPLIED.
          lt_components = CAST cl_abap_structdescr( io_abap_structdescr )->get_components( ).

          LOOP AT lt_components INTO ls_component.
            IF ls_component-as_include IS INITIAL.
              INSERT ls_component INTO TABLE ct_components.
            ELSE.
              IF ls_component-type IS INSTANCE OF cl_abap_structdescr.
                _get_all_of_components( EXPORTING io_abap_structdescr = CAST #( ls_component-type )
                                        CHANGING  ct_components       = ct_components ).
              ELSEIF ls_component-type IS INSTANCE OF cl_abap_tabledescr.
                _get_all_of_components( EXPORTING io_abap_tabledescr = CAST #( ls_component-type )
                                        CHANGING  ct_components      = ct_components ).
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSEIF io_abap_tabledescr IS SUPPLIED.
          lt_components = CAST cl_abap_structdescr( CAST cl_abap_tabledescr( io_abap_tabledescr )->get_table_line_type( ) )->get_components( ).

          LOOP AT lt_components INTO ls_component.
            IF ls_component-as_include IS INITIAL.
              INSERT ls_component INTO TABLE ct_components.
            ELSE.
              IF ls_component-type IS INSTANCE OF cl_abap_structdescr.
                _get_all_of_components( EXPORTING io_abap_structdescr = CAST #( ls_component-type )
                                        CHANGING  ct_components       = ct_components ).
              ELSEIF ls_component-type IS INSTANCE OF cl_abap_tabledescr.
                _get_all_of_components( EXPORTING io_abap_tabledescr = CAST #( ls_component-type )
                                        CHANGING  ct_components      = ct_components ).
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD _replace_string_dec_to_zero.
    IF iv_value IS INITIAL.
      RETURN.
    ENDIF.

    ev_value = condense( val = iv_value ).

    TRY.
        REPLACE ALL OCCURRENCES OF ` ` IN ev_value WITH ''.     " Space of string character
      CATCH cx_sy_replace_infinite_loop.
    ENDTRY.
    TRY.
        REPLACE ALL OCCURRENCES OF ` ` IN ev_value WITH ''.     " Special character of spreadsheet (Try to copy value while debugging)
      CATCH cx_sy_replace_infinite_loop.
    ENDTRY.
    TRY.
        REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN ev_value WITH ''. " New line (Unix/Linux systems)
      CATCH cx_sy_replace_infinite_loop.
    ENDTRY.
    TRY.
        REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN ev_value WITH ''.   " New line (Windows system)
      CATCH cx_sy_replace_infinite_loop.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

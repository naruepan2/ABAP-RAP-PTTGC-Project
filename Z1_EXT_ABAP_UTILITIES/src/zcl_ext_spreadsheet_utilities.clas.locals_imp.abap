*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_sample_utils IMPLEMENTATION.
  METHOD display_sample_read_xlsx.
    TYPES:
      BEGIN OF lts_spreadsheet,
        column1  TYPE string,
        column2  TYPE string,
        column3  TYPE kunnr,
        column4  TYPE bukrs,
        column5  TYPE c LENGTH 1,
        column6  TYPE netwr,
        column7  TYPE i,
        column8  TYPE datum,
        column9  TYPE datum,
        column10 TYPE string,
        column11 TYPE string,
      END OF lts_spreadsheet.

    TYPES ltt_spreadsheet TYPE TABLE OF lts_spreadsheet WITH EMPTY KEY.

    DATA lt_spreadsheet TYPE ltt_spreadsheet.

    DATA(lo_spreadsheet_instance) = zcl_ext_spreadsheet_utilities=>create_instance( ).

    lo_spreadsheet_instance->read_spreadsheet_data( EXPORTING iv_file_content = _sample_excel_xstring( )
                                                              iv_begin_row    = 2
                                                    IMPORTING et_data         = lt_spreadsheet ).
    IF lt_spreadsheet IS INITIAL.
      " Display as Mock up data
      APPEND INITIAL LINE TO lt_spreadsheet ASSIGNING FIELD-SYMBOL(<ls_spreadsheet>).
      <ls_spreadsheet>-column1  = '30000000252'.
      <ls_spreadsheet>-column2  = '5011'.
      <ls_spreadsheet>-column3  = '68100011'.
      <ls_spreadsheet>-column4  = '1000'.
      <ls_spreadsheet>-column5  = '3'.
      <ls_spreadsheet>-column6  = '3.03'.
      <ls_spreadsheet>-column7  = '0'.
      <ls_spreadsheet>-column8  = '20250417'.
      <ls_spreadsheet>-column9  = '20250416'.
      <ls_spreadsheet>-column10 = 'Test Text for col 9'.
      <ls_spreadsheet>-column11 = 'Test Text for col 10'.
    ENDIF.

    io_out->write( lt_spreadsheet ).
  ENDMETHOD.

  METHOD _sample_excel_xstring.
    rv_xstring = ''.
  ENDMETHOD.
ENDCLASS.

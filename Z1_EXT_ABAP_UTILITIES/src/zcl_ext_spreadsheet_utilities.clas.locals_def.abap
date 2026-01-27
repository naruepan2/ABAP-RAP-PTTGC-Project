*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_sample_utils DEFINITION.
  PUBLIC SECTION.

    METHODS display_sample_read_xlsx
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

  PRIVATE SECTION.

    METHODS _sample_excel_xstring
      RETURNING VALUE(rv_xstring) TYPE xstring.

ENDCLASS.

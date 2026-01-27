*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_sample_xml DEFINITION.
  PUBLIC SECTION.
    METHODS sample_xml_display
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

  PRIVATE SECTION.

    METHODS _get_example_xml_1
      RETURNING VALUE(rv_xml) TYPE string.

    METHODS _get_example_xml_2
      RETURNING VALUE(rv_xml) TYPE string.

    METHODS _get_example_xml_3
      RETURNING VALUE(rv_xml) TYPE string.
ENDCLASS.

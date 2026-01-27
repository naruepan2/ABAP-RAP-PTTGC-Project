*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_sample_post DEFINITION.
  PUBLIC SECTION.
    METHODS sample_post_material_document
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS sample_pickalldelivery
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.

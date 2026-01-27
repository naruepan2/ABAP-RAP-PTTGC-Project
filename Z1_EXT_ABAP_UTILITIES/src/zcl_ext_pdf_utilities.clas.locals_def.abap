*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_main_local DEFINITION.

  PUBLIC SECTION.
    METHODS sample_tmpl_store_client
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.

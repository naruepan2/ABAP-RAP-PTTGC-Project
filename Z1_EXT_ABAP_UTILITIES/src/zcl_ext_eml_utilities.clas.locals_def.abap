*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_eml_utilities_local DEFINITION.
  PUBLIC SECTION.
    METHODS check_operation
      CHANGING ct_operation TYPE abp_behv_changes_tab.

    METHODS sample_post_dynamic_form_1
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS sample_post_dynamic_form_2
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

  PRIVATE SECTION.
ENDCLASS.

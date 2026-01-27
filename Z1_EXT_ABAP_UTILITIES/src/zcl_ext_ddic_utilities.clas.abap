CLASS zcl_ext_ddic_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
*  class-METHODS :
*    get_domain_fixvalue      IMPORTING iv_value TYPE clike
*                             EXPORTING ev_description type clike .
    CLASS-METHODS get_domain_fixvalue_desc
      IMPORTING iv_value              TYPE clike
      RETURNING VALUE(rv_description) TYPE cl_abap_elemdescr=>fixvalue-ddtext.

    CLASS-METHODS conv_field_input
      IMPORTING iv_in  TYPE clike
      EXPORTING ev_out TYPE clike.

    CLASS-METHODS conv_field_output
      IMPORTING iv_in  TYPE any
      EXPORTING ev_out TYPE clike.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_ddic_utilities IMPLEMENTATION.

  METHOD get_domain_fixvalue_desc.

    DATA(lt_fixed_values) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( iv_value ) )->get_ddic_fixed_values( ).
    rv_description = VALUE #( lt_fixed_values[ low = iv_value ]-ddtext OPTIONAL ) .

  ENDMETHOD.

  METHOD conv_field_input.

    CHECK iv_in IS NOT INITIAL .

    DATA(lv_edit_mask) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( iv_in ) )->edit_mask .

    CASE lv_edit_mask .
      WHEN '==ALPHA'.
        ev_out = |{ iv_in ALPHA = IN }| .
      WHEN '==MATN1' .
        SELECT SINGLE FROM i_product
        FIELDS product
        WHERE productexternalid = @iv_in
        INTO @ev_out
        PRIVILEGED ACCESS .
      WHEN OTHERS .
        ev_out = iv_in .
    ENDCASE.

  ENDMETHOD.

  METHOD conv_field_output .

    CHECK iv_in IS NOT INITIAL .

    DATA(lv_edit_mask) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( iv_in ) )->edit_mask .
    DATA(lv_type_kind) = CAST cl_abap_typedescr( cl_abap_elemdescr=>describe_by_data( iv_in ) )->type_kind .


    CASE lv_edit_mask .
      WHEN '==ALPHA'.
        ev_out = |{ iv_in ALPHA = OUT }| .
      WHEN '==MATN1' .
        SELECT SINGLE FROM i_product
        FIELDS productexternalid
        WHERE product = @iv_in
        INTO @ev_out
        PRIVILEGED ACCESS .
      WHEN OTHERS .

        CASE lv_type_kind.
          WHEN cl_abap_typedescr=>typekind_date .
            DATA(lv_val_date) = CONV datum( iv_in ) .
            ev_out = |{ lv_val_date DATE = USER }| .
          WHEN cl_abap_typedescr=>typekind_time .
            DATA(lv_val_time) = CONV uzeit( iv_in ) .
            ev_out = |{ lv_val_time TIME = USER }| .
          WHEN OTHERS .
            ev_out = iv_in .
        ENDCASE.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.

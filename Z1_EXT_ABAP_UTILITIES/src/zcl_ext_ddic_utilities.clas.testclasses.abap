*"* use this source file for your ABAP unit test classes
CLASS ltcl_ DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_get_domain_fixvalue_desc FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_ IMPLEMENTATION.

  METHOD test_get_domain_fixvalue_desc.
    DATA ls_cpi TYPE zi_ext_cpipathconfig .
    ls_cpi-authenticationtype = '0' .
    DATA(lv_desc) = zcl_ext_ddic_utilities=>get_domain_fixvalue_desc( ls_cpi-authenticationtype ).
  ENDMETHOD.

ENDCLASS.

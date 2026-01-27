*"* use this source file for your ABAP unit test classes
CLASS ltcl_domain DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS:
      c_dummy_mail TYPE string VALUE 'test@test.com',
      c_test_mail  TYPE string VALUE 'test@dev-pttgcgroup.com'.
    DATA: mo_cut TYPE REF TO zcl_ext_email_utilities.

    METHODS:
      setup,
      gsd FOR TESTING RAISING cx_static_check,
      gsq FOR TESTING RAISING cx_static_check,
      gsp FOR TESTING RAISING cx_static_check,
      sender_gsd FOR TESTING RAISING cx_static_check,
      sender_gsp FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_domain IMPLEMENTATION.

  METHOD setup.
    mo_cut = zcl_ext_email_utilities=>create_instance( ).
  ENDMETHOD.

  METHOD gsd.
    FINAL(lv_act) =
      zcl_ext_email_utilities=>replace_to_non_prd_domain(
        iv_address   = c_dummy_mail
        iv_system_id = 'GSD'
      ).
    cl_abap_unit_assert=>assert_equals(
      exp = c_test_mail
      act = lv_act
    ).
  ENDMETHOD.

  METHOD gsp.

    FINAL(lv_act) =
      zcl_ext_email_utilities=>replace_to_non_prd_domain(
        iv_address   = c_dummy_mail
        iv_system_id = 'GSP'
      ).
    cl_abap_unit_assert=>assert_equals(
      exp = c_dummy_mail
      act = lv_act
    ).
  ENDMETHOD.

  METHOD gsq.
    FINAL(lv_act) =
      zcl_ext_email_utilities=>replace_to_non_prd_domain(
        iv_address   = c_dummy_mail
        iv_system_id = 'GSQ'
      ).
    cl_abap_unit_assert=>assert_equals(
      exp = c_test_mail
      act = lv_act
    ).
  ENDMETHOD.

  METHOD sender_gsd.
    DATA(lv_act) = c_dummy_mail.
    mo_cut->det_sender(
      EXPORTING iv_system_id = 'GSD'
      CHANGING cv_sender = lv_act
    ).
    cl_abap_unit_assert=>assert_equals(
      exp = c_test_mail
      act = lv_act
    ).
  ENDMETHOD.

  METHOD sender_gsp.
    DATA(lv_act) = c_dummy_mail.
    mo_cut->det_sender(
      EXPORTING iv_system_id = 'GSP'
      CHANGING cv_sender = lv_act
    ).
    cl_abap_unit_assert=>assert_equals(
      exp = c_dummy_mail
      act = lv_act
    ).
  ENDMETHOD.

ENDCLASS.

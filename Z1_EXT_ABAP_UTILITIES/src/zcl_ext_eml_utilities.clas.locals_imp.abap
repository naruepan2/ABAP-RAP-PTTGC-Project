*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_eml_utilities_local IMPLEMENTATION.
  METHOD check_operation.
    DATA lt_operation TYPE RANGE OF abp_behv_changes-op.

    lt_operation = VALUE #( sign   = 'I'
                            option = 'EQ'
                            ( low = if_abap_behv=>op-m-create )
                            ( low = if_abap_behv=>op-m-update )
                            ( low = if_abap_behv=>op-m-delete )
                            ( low = if_abap_behv=>op-m-action )
                            ( low = if_abap_behv=>op-m-create_ba ) ).

    LOOP AT ct_operation ASSIGNING FIELD-SYMBOL(<ls_operation>).
      IF NOT <ls_operation>-op IN lt_operation.
        CLEAR <ls_operation>-op.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sample_post_dynamic_form_1.
    DATA(lv_string) =
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |           Sample MODIFY ENTITIES OPERATIONS, Dynamic Form            { cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA:\n| &&
      |     _bp_root           TYPE TABLE FOR CREATE i_businesspartnertp_3,\n| &&
      |     _bp_address        TYPE TABLE FOR CREATE i_businesspartnertp_3\\_businesspartneraddress,\n| &&
      |     _bp_identification TYPE TABLE FOR CREATE i_businesspartnertp_3\\_businesspartneridentification,\n| &&
      |     _bp_address_usage  TYPE TABLE FOR CREATE i_businesspartneraddresstp_3\\_businesspartneraddressusage.\n\n| &&
      |lt_operation = VALUE abp_behv_changes_tab(\n| &&
      |                    ( VALUE abp_behv_changes(\n| &&
      |                        op = if_abap_behv=>op-m-create\n| &&
      |                        entity_name = 'I_BUSINESSPARTNERTP_3'\n| &&
      |                        instances = REF #( _bp_root )\n| &&
      |                    ) )\n| &&
      |                    ( VALUE abp_behv_changes(\n| &&
      |                        op = if_abap_behv=>op-m-create_ba\n| &&
      |                        entity_name = 'I_BUSINESSPARTNERTP_3'\n| &&
      |                        sub_name = '_BUSINESSPARTNERADDRESS'\n| &&
      |                        instances = REF #( _bp_address )\n| &&
      |                    ) )\n| &&
      |                    ( VALUE abp_behv_changes(\n| &&
      |                        op = if_abap_behv=>op-m-create_ba\n| &&
      |                        entity_name = 'I_BUSINESSPARTNERTP_3'\n| &&
      |                        sub_name = '_BUSINESSPARTNERIDENTIFICATION'\n| &&
      |                        instances = REF #( _bp_identification )\n| &&
      |                    ) )\n| &&
      |                    ( VALUE abp_behv_changes(\n| &&
      |                        op = if_abap_behv=>op-m-create_ba\n| &&
      |                        entity_name = 'I_BUSINESSPARTNERADDRESSTP_3'\n| &&
      |                        sub_name = '_BUSINESSPARTNERADDRESSUSAGE'\n| &&
      |                        instances = REF #( _bp_address_usage )\n| &&
      |                    ) )\n| &&
      |              ).\n\n| &&
      |MODIFY ENTITIES IN LOCAL MODE\n| &&
      |      OPERATIONS lt_operation\n| &&
      |      MAPPED   et_mapped\n| &&
      |      FAILED   et_failed\n| &&
      |      REPORTED et_reported.\n| &&
      |**********************************************************************\n|.

    io_out->write( lv_string ).
  ENDMETHOD.

  METHOD sample_post_dynamic_form_2.
    DATA(lv_string) =
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |           Sample MODIFY ENTITIES OPERATIONS, Dynamic Form            { cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA: failed_dyn       TYPE abp_behv_response_tab,\n| &&
      |      reported_dyn     TYPE abp_behv_response_tab,\n| &&
      |      mapped_dyn       TYPE abp_behv_response_tab,\n| &&
      |      op_tab           TYPE abp_behv_changes_tab,\n| &&
      |      create_root_tab  TYPE TABLE FOR CREATE demo_managed_root,\n| &&
      |      update_root_tab  TYPE TABLE FOR UPDATE demo_managed_root,\n| &&
      |      delete_root_tab  TYPE TABLE FOR UPDATE demo_managed_root,\n| &&
      |      cba              TYPE TABLE FOR CREATE demo_managed_root_child,\n| &&
      |      update_child_tab TYPE TABLE FOR UPDATE demo_managed_child,\n| &&
      |      delete_child_tab TYPE TABLE FOR DELETE demo_managed_child.\n| &&
      |\n| &&
      |create_root_tab = VALUE #( \n| &&
      |  ( %cid = 'cid1' key_field = 5 %control-key_field = if_abap_behv=>mk-on\n| &&
      |    data_field1_root = 'aaa' %control-data_field1_root = if_abap_behv=>mk-on\n| &&
      |    data_field2_root = 'bbb' %control-data_field2_root = if_abap_behv=>mk-on )\n| &&
      |  ( %cid = 'cid2' key_field = 6 %control-key_field = if_abap_behv=>mk-on\n| &&
      |    data_field1_root = 'ccc' %control-data_field1_root = if_abap_behv=>mk-on\n| &&
      |    data_field2_root = 'ddd' %control-data_field2_root = if_abap_behv=>mk-on )\n| &&
      |  ( %cid = 'cid3' key_field = 7 %control-key_field = if_abap_behv=>mk-on\n| &&
      |    data_field1_root = 'eee' %control-data_field1_root = if_abap_behv=>mk-on\n| &&
      |    data_field2_root = 'fff' %control-data_field2_root = if_abap_behv=>mk-on )\n| &&
      |).\n| &&
      |\n| &&
      |update_root_tab = VALUE #( \n| &&
      |  ( %cid_ref = 'cid2' %control-key_field = if_abap_behv=>mk-on\n| &&
      |    data_field1_root = 'GGG' %control-data_field1_root = if_abap_behv=>mk-on\n| &&
      |    data_field2_root = 'HHH' %control-data_field2_root = if_abap_behv=>mk-on )\n| &&
      |).\n| &&
      |\n| &&
      |cba = VALUE #( \n| &&
      |  ( %cid_ref = 'cid1' %target = VALUE #( (\n| &&
      |      %cid = 'cid_cba1' %control-key_field = if_abap_behv=>mk-off\n| &&
      |      data_field1_child = 'iii' %control-data_field1_child = if_abap_behv=>mk-on\n| &&
      |      data_field2_child = 'jjj' %control-data_field2_child = if_abap_behv=>mk-on ) ) )\n| &&
      |  ( %cid_ref = 'cid2' %target = VALUE #( (\n| &&
      |      %cid = 'cid_cba2' %control-key_field = if_abap_behv=>mk-off\n| &&
      |      data_field1_child = 'kkk' %control-data_field1_child = if_abap_behv=>mk-on\n| &&
      |      data_field2_child = 'lll' %control-data_field2_child = if_abap_behv=>mk-on ) ) )\n| &&
      |  ( %cid_ref = 'cid3' %target = VALUE #( (\n| &&
      |      %cid = 'cid_cba3' %control-key_field = if_abap_behv=>mk-off\n| &&
      |      data_field1_child = 'mmm' %control-data_field1_child = if_abap_behv=>mk-on\n| &&
      |      data_field2_child = 'nnn' %control-data_field2_child = if_abap_behv=>mk-on ) ) )\n| &&
      |).\n| &&
      |\n| &&
      |update_child_tab = VALUE #( \n| &&
      |  ( key_field = 6 %control-key_field = if_abap_behv=>mk-off\n| &&
      |    data_field1_child = 'OOO' %control-data_field1_child = if_abap_behv=>mk-on\n| &&
      |    data_field2_child = 'PPP' %control-data_field2_child = if_abap_behv=>mk-on )\n| &&
      |).\n| &&
      |\n| &&
      |delete_root_tab = VALUE #( ( key_field = 7 ) ).\n| &&
      |delete_child_tab = VALUE #( ( key_field = 7 ) ).\n| &&
      |\n| &&
      |op_tab = VALUE #( \n| &&
      |  ( op = if_abap_behv=>op-m-create entity_name = 'DEMO_MANAGED_ROOT' instances = REF #( create_root_tab ) )\n| &&
      |  ( op = if_abap_behv=>op-m-update entity_name = 'DEMO_MANAGED_ROOT' instances = REF #( update_root_tab ) )\n| &&
      |  ( op = if_abap_behv=>op-m-delete entity_name = 'DEMO_MANAGED_ROOT' instances = REF #( delete_root_tab ) )\n| &&
      |  ( op = if_abap_behv=>op-m-create_ba entity_name = 'DEMO_MANAGED_ROOT' sub_name = '_CHILD' instances = REF #( cba ) )\n| &&
      |  ( op = if_abap_behv=>op-m-update entity_name = 'DEMO_MANAGED_CHILD' instances = REF #( update_child_tab ) )\n| &&
      |  ( op = if_abap_behv=>op-m-delete entity_name = 'DEMO_MANAGED_CHILD' instances = REF #( delete_child_tab ) )\n| &&
      |).\n| &&
      |\n| &&
      |MODIFY ENTITIES OPERATIONS op_tab\n| &&
      |  FAILED   failed_dyn\n| &&
      |  REPORTED reported_dyn\n| &&
      |  MAPPED   mapped_dyn.\n| &&
      |**********************************************************************\n|.

    io_out->write( lv_string ).
  ENDMETHOD.
ENDCLASS.

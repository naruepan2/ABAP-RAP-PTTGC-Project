" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Naruepan Wongrachtachai
" Created on : Jan 20, 2026
" WRICEF ID  : RTR-AA0020
" TR Number  : GSDK909428
" -----------------------------------------------------------------------
" Description:
"   RTR_AA020 Create and Change Asset Master
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
"
" -----------------------------------------------------------------------
CLASS lcl_event_createchangeasset DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    TYPES tt_simulatecreatechangeasset TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~simulatecreatechangeasset.
    TYPES tt_postcreatechangeasset     TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~postcreatechangeasset.

    METHODS simulatecreatechangeassetevent FOR ENTITY EVENT simulate_changeasset_table FOR createchangeasset~simulatecreatechangeassetevent.
    METHODS postcreatechangeassetevent FOR ENTITY EVENT posting_changeasset_table FOR createchangeasset~postcreatechangeassetevent.
ENDCLASS.


CLASS lcl_event_createchangeasset IMPLEMENTATION.
  METHOD postcreatechangeassetevent.
    IF posting_changeasset_table IS INITIAL.
      RETURN.
    ENDIF.

    zcl_rtr_createchangeasset_main=>get_instance(
            )->simulate_asset_master( it_keys = VALUE #( FOR ls_posting_changeasset IN posting_changeasset_table
                                                         ( assetuuid = ls_posting_changeasset-assetuuid ) ) ).
  ENDMETHOD.

  METHOD simulatecreatechangeassetevent.
    IF simulate_changeasset_table IS INITIAL.
      RETURN.
    ENDIF.

    zcl_rtr_createchangeasset_main=>get_instance(
            )->simulate_asset_master( it_keys = VALUE #( FOR ls_simulate_changeasset IN simulate_changeasset_table
                                                         ( assetuuid = ls_simulate_changeasset-assetuuid ) ) ).
  ENDMETHOD.
ENDCLASS.

" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Naruepan Wongrachtachai
" Created on : Oct 07, 2025
" WRICEF ID  : RTR-AA0020
" TR Number  : GSDK903648
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
CLASS zcl_rtr_createchangeasset_bgpf DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES if_bgmc_operation.
    INTERFACES if_bgmc_op_single_tx_uncontr.

    TYPES ty_char1 TYPE c LENGTH 1.

    METHODS constructor
      IMPORTING it_keys_simu  TYPE zcl_rtr_createchangeasset_main=>tt_createchangeassettp_keys3 OPTIONAL
                it_keys_post  TYPE zcl_rtr_createchangeasset_main=>tt_createchangeassettp_keys4 OPTIONAL
                iv_createmode TYPE ty_char1.

  PRIVATE SECTION.
    DATA mt_keys_simu  TYPE zcl_rtr_createchangeasset_main=>tt_createchangeassettp_keys3.
    DATA mt_keys_post  TYPE zcl_rtr_createchangeasset_main=>tt_createchangeassettp_keys4.
    DATA mv_createmode TYPE ty_char1.

ENDCLASS.


CLASS zcl_rtr_createchangeasset_bgpf IMPLEMENTATION.
  METHOD constructor.
    mt_keys_simu  = it_keys_simu.
    mt_keys_post  = it_keys_post.
    mv_createmode = iv_createmode.
  ENDMETHOD.

  METHOD if_bgmc_op_single_tx_uncontr~execute.
    DATA(lo_instance) = zcl_rtr_createchangeasset_main=>get_instance( ).

    CASE mv_createmode.
      WHEN '1'.        " Simulate Asset
        lo_instance->post_create_change_asset( it_keys_simu      = mt_keys_simu
                                               iv_set_simu       = abap_true
                                               iv_commit_entites = abap_true ).
      WHEN '2'.        " Create/Change Asset
        lo_instance->post_create_change_asset( it_keys_post      = mt_keys_post
                                               iv_set_simu       = space
                                               iv_commit_entites = abap_true ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

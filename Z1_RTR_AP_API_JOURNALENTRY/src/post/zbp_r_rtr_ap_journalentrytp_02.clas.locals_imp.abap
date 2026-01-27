" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by  : Naruepan Wongrachtachai
" Created on  : Aug 19, 2025
" WRICEF ID   : RTR-AP011
" TR Number   : GSDK902154
" -----------------------------------------------------------------------
" Description:
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
" -----------------------------------------------------------------------
CLASS lhc_journalentryaccountingpost DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validate FOR READ
      IMPORTING keys FOR FUNCTION journalentry~validate RESULT result.

    METHODS internalpostje FOR MODIFY
      IMPORTING keys FOR ACTION journalentry~internalpostje.

    METHODS post FOR MODIFY
      IMPORTING keys FOR ACTION journalentry~post.

ENDCLASS.


CLASS lhc_journalentryaccountingpost IMPLEMENTATION.
  METHOD validate.
    zcl_rtr_ap_journalentry_post=>get_instance( )->validate_accounting_document(
      " TODO: variable is assigned but never used (ABAP cleaner)
      IMPORTING et_result   = DATA(lt_result)
                es_failed   = DATA(ls_failed)
                es_reported = DATA(ls_reported) ).

    failed = CORRESPONDING #( DEEP ls_failed ).
    reported = CORRESPONDING #( DEEP ls_reported ).
  ENDMETHOD.

  METHOD internalpostje.
    DATA(lo_instance) = zcl_rtr_ap_journalentry_post=>get_instance( ).

    lo_instance->save_accounting_document( IMPORTING es_failed   = failed
                                                     es_mapped   = mapped
                                                     es_reported = reported ).
  ENDMETHOD.

  METHOD post.
    DATA(lo_instance) = zcl_rtr_ap_journalentry_post=>get_instance( ).
    lo_instance->set_interface_api_keys( it_keys = keys ).
    lo_instance->set_current_action( iv_action = zcl_rtr_ap_journalentry_post=>c_action-post ).

    READ ENTITIES OF zr_rtr_ap_journalentrytp IN LOCAL MODE ##EML_READ_IN_LOCAL_MODE_OK
         ENTITY journalentry
         EXECUTE validate
         FROM CORRESPONDING #( DEEP lo_instance->get_interface_api_keys( ) )
         " TODO: variable is assigned but never used (ABAP cleaner)
         RESULT   FINAL(lt_result)
         FAILED   FINAL(ls_failed)
         REPORTED FINAL(ls_reported).

    failed = CORRESPONDING #( DEEP ls_failed ).
    reported = CORRESPONDING #( DEEP ls_reported ).

    LOOP AT lo_instance->mt_journalentry_keys INTO DATA(ls_journalentry_key).
      APPEND VALUE #( %cid = ls_journalentry_key-cid
                      " Mapping the key fields to %tmp and %key for response
                      %pid = ls_journalentry_key-pid )
             TO mapped-JournalEntry.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

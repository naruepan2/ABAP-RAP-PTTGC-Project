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
CLASS lsc_zr_rtr_ap_journalentrytp DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers    REDEFINITION.

    METHODS save              REDEFINITION.

    METHODS cleanup           REDEFINITION.

    METHODS cleanup_finalize  REDEFINITION.

ENDCLASS.


CLASS lsc_zr_rtr_ap_journalentrytp IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.
    DATA(lo_instance) = zcl_rtr_ap_journalentry_post=>get_instance( ).

    CASE lo_instance->get_current_action( ).
      WHEN zcl_rtr_ap_journalentry_post=>c_action-post.
        lo_instance->adjust_numbers_post_je( CHANGING cs_mapped   = mapped
                                                      cs_reported = reported ).
      WHEN zcl_rtr_ap_journalentry_post=>c_action-reverse.
        " Nothing to do
    ENDCASE.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
    zcl_rtr_ap_journalentry_post=>get_instance( )->clear_document_from_api( )->clear_api_keys( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
    zcl_rtr_ap_journalentry_post=>get_instance( )->clear_document_from_api( ).
  ENDMETHOD.
ENDCLASS.

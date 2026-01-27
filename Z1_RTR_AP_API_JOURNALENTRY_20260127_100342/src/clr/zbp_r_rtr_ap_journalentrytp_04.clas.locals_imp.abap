CLASS lhc_journalentryaccountclearin DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS clearing FOR MODIFY
      IMPORTING keys FOR ACTION journalentry~clearing RESULT result.

ENDCLASS.

CLASS lhc_journalentryaccountclearin IMPLEMENTATION.

  METHOD clearing.


    LOOP AT keys INTO DATA(ls_key).

      DATA(lv_pid) = zcl_rtr_ap_journalentry_clear=>get_instance( )->set_postclear_mapping( ls_key ) .

      mapped-journalentry = VALUE #( BASE mapped-journalentry
                                         ( %cid = ls_key-%cid
                                           %pid = lv_pid ) ).

    ENDLOOP.

    zcl_rtr_ap_journalentry_clear=>get_instance( )->post_clear( ).
    zcl_rtr_ap_journalentry_clear=>get_instance( )->get_postclear_data( IMPORTING et_data = DATA(lt_data) ).


    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      APPEND INITIAL LINE TO reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported>).
      <ls_reported>-%cid = <ls_data>-cid.
      <ls_reported>-%pid = <ls_data>-pid.
      <ls_reported>-%msg = NEW zcx_ext_general_error( is_bapiret2 = CORRESPONDING #( <ls_data>-message ) ).

      IF <ls_data>-message-type CA 'EAX' OR NOT ( <ls_data>-message-id = 'F5' AND <ls_data>-message-number = '312' ).
        failed-journalentry = VALUE #( BASE failed-journalentry
                                         ( %cid = <ls_data>-cid
                                           %pid = <ls_data>-pid
                                           %fail-cause = if_abap_behv=>cause-unspecific ) ).
      ELSE .

        SELECT SINGLE
          FROM zr_rtr_ap_journalentrytp
          FIELDS *                            "#EC CI_ALL_FIELDS_NEEDED
          WHERE companycode        = @<ls_data>-doc_clear-bukrs
            AND fiscalyear         = @<ls_data>-doc_clear-gjahr
            AND accountingdocument = @<ls_data>-doc_clear-belnr
          INTO @DATA(ls_journalentry_result)
          PRIVILEGED ACCESS.

        APPEND VALUE #( %cid         = <ls_data>-cid
                        %param-%pid  = <ls_data>-pid
                        %param-%data = CORRESPONDING #( ls_journalentry_result ) )
               TO result.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

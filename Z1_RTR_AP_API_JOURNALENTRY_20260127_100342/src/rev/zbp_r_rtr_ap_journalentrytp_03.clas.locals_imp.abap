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
CLASS lhc_journalentryaccountingreve DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS reverse FOR MODIFY
      IMPORTING keys FOR ACTION journalentry~reverse RESULT result.

ENDCLASS.


CLASS lhc_journalentryaccountingreve IMPLEMENTATION.
  METHOD reverse.
    DATA lt_keys_je TYPE zcl_rtr_ap_journalentry_post=>tt_journalentry_key.

    DATA(lo_instance) = zcl_rtr_ap_journalentry_post=>get_instance( ).
    lo_instance->set_current_action( iv_action = zcl_rtr_ap_journalentry_post=>c_action-reverse ).

    lt_keys_je = VALUE #( FOR <ls_key> IN keys
                          ( companycode        = <ls_key>-%param-companycode
                            fiscalyear         = <ls_key>-%param-fiscalyear
                            accountingdocument = <ls_key>-%param-accountingdocument ) ).
    SORT lt_keys_je BY companycode
                       fiscalyear
                       accountingdocument.
    DELETE ADJACENT DUPLICATES FROM lt_keys_je COMPARING ALL FIELDS.

    IF lt_keys_je IS NOT INITIAL.
      SELECT FROM i_journalentry
        FIELDS companycode,
               fiscalyear,
               accountingdocument,
               reversalreason,
               reversedocument,
               reversedocumentfiscalyear,
               reversalreferencedocumentcntxt,
               reversalreferencedocument,
               isreversal,
               isreversed
        FOR ALL ENTRIES IN @lt_keys_je
        WHERE companycode        = @lt_keys_je-companycode
          AND fiscalyear         = @lt_keys_je-fiscalyear
          AND accountingdocument = @lt_keys_je-accountingdocument
        ORDER BY PRIMARY KEY
        INTO TABLE @DATA(lt_journalentry_db)
        PRIVILEGED ACCESS.
    ENDIF.

    LOOP AT keys INTO DATA(ls_key) GROUP BY ( companycode        = ls_key-%param-companycode
                                              accountingdocument = ls_key-%param-accountingdocument
                                              fiscalyear         = ls_key-%param-fiscalyear )
         ASCENDING INTO DATA(ls_group).
      LOOP AT GROUP ls_group INTO DATA(ls_group_param). EXIT. ENDLOOP.

      IF line_exists( lt_journalentry_db[ companycode        = ls_group_param-%param-companycode
                                          fiscalyear         = ls_group_param-%param-fiscalyear
                                          accountingdocument = ls_group_param-%param-accountingdocument
                                          isreversed         = abap_true ] ).
        APPEND VALUE #( %cid               = ls_key-%cid
                        companycode        = ls_group_param-%param-companycode
                        fiscalyear         = ls_group_param-%param-fiscalyear
                        accountingdocument = ls_group_param-%param-accountingdocument
                        %fail              = VALUE #( cause = if_abap_behv=>cause-unspecific ) )
               TO failed-journalentry.
        APPEND VALUE #( %cid               = ls_key-%cid
                        companycode        = ls_group_param-%param-companycode
                        fiscalyear         = ls_group_param-%param-fiscalyear
                        accountingdocument = ls_group_param-%param-accountingdocument
                        %msg               = new_message( id       = 'F5'
                                                          number   = '361'
                                                          severity = if_abap_behv_message=>severity-error ) )
               TO reported-journalentry.
        CONTINUE.
      ENDIF.

      DATA(lv_pid) = lo_instance->get_pid( ).

      TRY.
          lo_instance->reverse_accounting_document(
              iv_companycode        = ls_group_param-%param-companycode
              iv_accountingdocument = ls_group_param-%param-accountingdocument
              iv_fiscalyear         = ls_group_param-%param-fiscalyear
              iv_postingdate        = COND #( WHEN ls_group_param-%param-postingdate          IS NOT INITIAL
                                               AND ls_group_param-%param-%control-postingdate  = if_abap_behv=>mk-on
                                              THEN ls_group_param-%param-postingdate )
              iv_reversalreason     = COND #( WHEN ls_group_param-%param-reversalreason          IS NOT INITIAL
                                               AND ls_group_param-%param-%control-reversalreason  = if_abap_behv=>mk-on
                                              THEN ls_group_param-%param-reversalreason ) ).

          lo_instance->set_interface_api_keys_rev( is_keys = CORRESPONDING #( DEEP ls_group_param ) ).

          APPEND VALUE #( %cid = ls_group_param-%cid
                          " Mapping the key fields to %tmp and %key for response
                          %pid = lv_pid )
                 TO mapped-journalentry.

          SELECT SINGLE
            FROM zr_rtr_ap_journalentrytp
                   INNER JOIN
                     i_journalentry ON  zr_rtr_ap_journalentrytp~companycode        = i_journalentry~companycode
                                    AND zr_rtr_ap_journalentrytp~fiscalyear         = i_journalentry~reversedocumentfiscalyear
                                    AND zr_rtr_ap_journalentrytp~accountingdocument = i_journalentry~reversedocument
            FIELDS zr_rtr_ap_journalentrytp~*
            WHERE i_journalentry~companycode        = @ls_group_param-%param-companycode
              AND i_journalentry~fiscalyear         = @ls_group_param-%param-fiscalyear
              AND i_journalentry~accountingdocument = @ls_group_param-%param-accountingdocument
            INTO @DATA(ls_journalentry_result)
            PRIVILEGED ACCESS.
          IF sy-subrc IS INITIAL.
            APPEND VALUE #( %cid               = ls_group_param-%cid
                            %pid               = lv_pid
                            companycode        = ls_group_param-%param-companycode
                            fiscalyear         = ls_group_param-%param-fiscalyear
                            accountingdocument = ls_group_param-%param-accountingdocument
                            %msg               = new_message( id       = 'F5'
                                                              number   = '312'
                                                              severity = if_abap_behv_message=>severity-success
                                                              v1       = ls_journalentry_result-accountingdocument
                                                              v2       = ls_journalentry_result-companycode ) )
                   TO reported-journalentry.

            APPEND VALUE #( %cid         = ls_group_param-%cid
                            %param-%pid  = lv_pid
                            %param-%data = CORRESPONDING #( ls_journalentry_result ) )
                   TO result.
          ENDIF.
        CATCH zcx_t2_static_check INTO DATA(lx_error).
          APPEND VALUE #( %cid               = ls_group_param-%cid
                          %pid               = lv_pid
                          companycode        = ls_group_param-%param-companycode
                          fiscalyear         = ls_group_param-%param-fiscalyear
                          accountingdocument = ls_group_param-%param-accountingdocument
                          %fail              = VALUE #( cause = if_abap_behv=>cause-unspecific ) )
                 TO failed-journalentry.
          APPEND VALUE #( %cid               = ls_group_param-%cid
                          %pid               = lv_pid
                          companycode        = ls_group_param-%param-companycode
                          fiscalyear         = ls_group_param-%param-fiscalyear
                          accountingdocument = ls_group_param-%param-accountingdocument
                          %msg               = new_message( id       = lx_error->if_t100_message~t100key-msgid
                                                            number   = lx_error->if_t100_message~t100key-msgno
                                                            severity = if_abap_behv_message=>severity-error
                                                            v1       = lx_error->if_t100_message~t100key-attr1
                                                            v2       = lx_error->if_t100_message~t100key-attr2
                                                            v3       = lx_error->if_t100_message~t100key-attr3
                                                            v4       = lx_error->if_t100_message~t100key-attr4 ) )
                 TO reported-journalentry.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

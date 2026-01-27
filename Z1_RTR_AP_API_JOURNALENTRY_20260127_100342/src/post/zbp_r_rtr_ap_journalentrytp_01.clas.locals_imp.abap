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
CLASS lhc_journalentryaccountingmain DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR journalentry~journalentryaccountingmain RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ journalentry RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK journalentry.

ENDCLASS.


CLASS lhc_journalentryaccountingmain IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD read.
    DATA lt_je_read_tp TYPE TABLE OF zr_rtr_ap_journalentrytp.
    DATA lt_je_read_db TYPE TABLE OF I_JournalEntryTP.
    DATA lv_field_list TYPE string.

    DATA(ls_key) = keys[ 1 ].

    DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( ls_key-%control ) ).
    DATA(lt_components)  = lo_structdescr->get_components( ).

    LOOP AT lt_components INTO DATA(ls_components).
      ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_key-%control TO FIELD-SYMBOL(<lv_field>) ELSE UNASSIGN.
      IF    sy-subrc   IS NOT INITIAL
         OR <lv_field> <> if_abap_behv=>mk-on.
        CONTINUE.
      ENDIF.

      IF lv_field_list IS INITIAL.
        lv_field_list = ls_components-name.
      ELSE.
        CONCATENATE lv_field_list ',' ls_components-name INTO lv_field_list.
      ENDIF.
    ENDLOOP.

    IF lv_field_list IS INITIAL.
      lv_field_list = '*'.
    ENDIF.

    SELECT FROM zr_rtr_ap_journalentrytp WITH
      PRIVILEGED ACCESS
      FIELDS (lv_field_list)
      FOR ALL ENTRIES IN @keys          "#EC CI_FAE_NO_LINES_OK
      WHERE CompanyCode        = @keys-CompanyCode
        AND AccountingDocument = @keys-AccountingDocument
        AND FiscalYear         = @keys-FiscalYear
      INTO CORRESPONDING FIELDS OF TABLE @lt_je_read_tp.
    IF lt_je_read_tp IS NOT INITIAL.
      result = CORRESPONDING #( DEEP lt_je_read_tp ).
    ELSE.
      SELECT FROM I_JournalEntryTP WITH
        PRIVILEGED ACCESS
        FIELDS (lv_field_list)
        FOR ALL ENTRIES IN @keys        "#EC CI_FAE_NO_LINES_OK
        WHERE CompanyCode        = @keys-CompanyCode
          AND AccountingDocument = @keys-AccountingDocument
          AND FiscalYear         = @keys-FiscalYear
        INTO CORRESPONDING FIELDS OF TABLE @lt_je_read_db.
      IF lt_je_read_db IS NOT INITIAL.
        result = CORRESPONDING #( DEEP lt_je_read_db ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

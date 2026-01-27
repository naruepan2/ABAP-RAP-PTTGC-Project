" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by  : Waristha Panthongsem
" Created on  : 01/09/2025
" WRICEF ID   : RTR-AP012
" TR Number   : GSDK902154/GSDK902340
" -----------------------------------------------------------------------
" Description:
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
" -----------------------------------------------------------------------
CLASS zcl_rtr_ap_journalentry_clear DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPES ty_post_clear_input TYPE STRUCTURE FOR ACTION IMPORT zr_rtr_ap_journalentrytp\\journalentry~Clearing.

    TYPES: BEGIN OF ty_post_data,
*              created_by_user TYPE syuname,
             ftclear TYPE zcl_t2_journal_entry_clearing=>_ftclear,
             ftpost  TYPE zcl_t2_journal_entry_clearing=>_ftpost,
           END OF ty_post_data.
    TYPES: BEGIN OF ty_change_data,
             reference1indocumentheader TYPE zd_rtr_journalentryclearp-reference1indocumentheader,
             reference2indocumentheader TYPE zd_rtr_journalentryclearp-reference2indocumentheader,
           END OF ty_change_data.
    TYPES: BEGIN OF ty_post_clear_data,
             cid         TYPE abp_behv_cid,
             pid         TYPE abp_behv_pid,
             post_data   TYPE ty_post_data,
             change_data TYPE ty_change_data,
             doc_clear   TYPE LINE OF zcl_t2_journal_entry_clearing=>_blntab,
             message     TYPE bapiret2,
           END OF ty_post_clear_data,
           tt_post_clear_data TYPE STANDARD TABLE OF ty_post_clear_data WITH DEFAULT KEY.

    CLASS-METHODS class_constructor.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_result) TYPE REF TO zcl_rtr_ap_journalentry_clear.

    METHODS set_postclear_mapping
      IMPORTING is_key        TYPE ty_post_clear_input
      RETURNING VALUE(rv_pid) TYPE abp_behv_pid.

    METHODS post_clear.

    METHODS get_postclear_data
      EXPORTING et_data TYPE tt_post_clear_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_field_mapping,
        src_field TYPE string,
        trg_level TYPE string,
        trg_field TYPE string,
      END OF ty_field_mapping,
      tt_field_mapping TYPE STANDARD TABLE OF ty_field_mapping WITH EMPTY KEY.


    CLASS-DATA go_instance TYPE REF TO zcl_rtr_ap_journalentry_clear.
    CLASS-DATA :
      BEGIN OF gs_field_ftpost_mapping,
        parent TYPE tt_field_mapping,
        _item  TYPE tt_field_mapping,
      END OF gs_field_ftpost_mapping.

    DATA mt_post_clear_data TYPE tt_post_clear_data .

    METHODS call_post_clear_bdc
      IMPORTING
        is_data             TYPE zcl_rtr_ap_journalentry_clear=>ty_post_data
      EXPORTING
        es_doc_clear TYPE LINE OF zcl_t2_journal_entry_clearing=>_blntab
        es_result    TYPE bapiret2.

    METHODS call_fi_document_change
      IMPORTING
        is_fi_key   TYPE zcl_t2_journal_entry_clearing=>blntab
        is_chg_data TYPE ty_change_data.
    METHODS get_payment_term
      IMPORTING
        iv_supplier           TYPE lifnr
        iv_companycode        TYPE bukrs
      RETURNING
        value(rv_paymentterm) TYPE dzterm.

    CLASS-METHODS _set_field_ftpost_mapping.
ENDCLASS.



CLASS zcl_rtr_ap_journalentry_clear IMPLEMENTATION.

  METHOD class_constructor.
    _set_field_ftpost_mapping(  ) .
  ENDMETHOD.

  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS BOUND THEN go_instance ELSE NEW #( ) ).
    RETURN go_instance .

  ENDMETHOD.

  METHOD set_postclear_mapping.
    TRY.
        DATA(lv_pid) = cl_system_uuid=>create_uuid_x16_static( ).

        DATA(lt_ftclear) = VALUE zcl_t2_journal_entry_clearing=>_ftclear( ).  " tt_ftclear( ).
        DATA(lt_ftpost) = VALUE zcl_t2_journal_entry_clearing=>_ftpost( ).

        lt_ftclear = VALUE #( BASE lt_ftclear
                              FOR ls_apar_clear IN is_key-%param-_aparclear
                              FOR ls_doc_apar IN ls_apar_clear-_document
                              ( agkoa  = ls_apar_clear-accounttype
                                agkon  = ls_apar_clear-aparaccount
                                agbuk  = is_key-%param-companycode
                                xnops  = COND #( WHEN ls_apar_clear-specialglcode IS INITIAL THEN abap_on )
                                agums  = ls_apar_clear-specialglcode
                                selfd  = 'BELNR'
                                selvon = |{ ls_doc_apar-AccountingDocument }{ is_key-%param-documentdate(4) }| ) ).

        lt_ftclear = VALUE #( BASE lt_ftclear
                              FOR ls_gl_clear IN is_key-%param-_glclear
                              FOR ls_doc_gl IN ls_gl_clear-_document
                              ( agkoa  = 'S'
                                agkon  = ls_gl_clear-glaccount
                                agbuk  = is_key-%param-companycode
                                xnops  = abap_on
                                selfd  = 'BELNR'
                                selvon = |{ ls_doc_gl-AccountingDocument }{ is_key-%param-documentdate(4) }| ) ).

        FIELD-SYMBOLS <lv_src_val> TYPE any.

        LOOP AT gs_field_ftpost_mapping-parent INTO DATA(ls_mapping).

          ASSIGN COMPONENT ls_mapping-src_field OF STRUCTURE is_key-%param TO <lv_src_val>.

          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          IF <lv_src_val> IS INITIAL.
            CONTINUE.
          ENDIF.
          IF ls_mapping-trg_field IS INITIAL.
            CONTINUE.
          ENDIF.

          DATA(lv_val) = VALUE string( ).

          zcl_ext_ddic_utilities=>conv_field_output( EXPORTING iv_in  = <lv_src_val>
                                                     IMPORTING ev_out = lv_val ).

          CONDENSE lv_val.

          lt_ftpost = VALUE #( BASE lt_ftpost
                               ( stype = ls_mapping-trg_level count = 1 fnam = ls_mapping-trg_field fval = lv_val ) ).

        ENDLOOP.

        LOOP AT is_key-%param-_item INTO DATA(ls_item).

          DATA(lv_ind) = CONV docln6( sy-tabix ).

          ls_item-PaymentTerms = COND #( WHEN ls_item IS NOT INITIAL
                                         THEN ls_item-PaymentTerms
                                         ELSE get_payment_term( iv_supplier    = ls_item-Account
                                                                iv_companycode = is_key-%param-companycode  ) ).

          LOOP AT gs_field_ftpost_mapping-_item INTO ls_mapping.

            ASSIGN COMPONENT ls_mapping-src_field OF STRUCTURE ls_item TO <lv_src_val>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            IF <lv_src_val> IS INITIAL.
              CONTINUE.
            ENDIF.
            IF ls_mapping-trg_field IS INITIAL.
              CONTINUE.
            ENDIF.

            lv_val = VALUE #( ).

            zcl_ext_ddic_utilities=>conv_field_output( EXPORTING iv_in  = <lv_src_val>
                                                       IMPORTING ev_out = lv_val ).

            CONDENSE lv_val.

            lt_ftpost = VALUE #(
                BASE lt_ftpost
                ( stype = ls_mapping-trg_level count = lv_ind fnam = ls_mapping-trg_field fval = lv_val ) ).

          ENDLOOP.

        ENDLOOP.

        DATA(ls_change_data) = VALUE ty_change_data(
                                         Reference1InDocumentHeader = is_key-%param-reference1indocumentheader
                                         Reference2InDocumentHeader = is_key-%param-reference2indocumentheader ).

        DATA(ls_post_clear_data) = VALUE ty_post_clear_data( cid               = is_key-%cid
                                                             pid               = lv_pid
                                                             post_data-ftclear = lt_ftclear
                                                             post_data-ftpost  = lt_ftpost
                                                             change_data       = ls_change_data ).

        APPEND ls_post_clear_data TO mt_post_clear_data.

        RETURN lv_pid.

      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD _set_field_ftpost_mapping.
    gs_field_ftpost_mapping-parent = VALUE #( trg_level = 'K' " Header

                                            ( src_field = 'COMPANYCODE'                 trg_field = 'BKPF-BUKRS' )
                                            ( src_field = 'ACCOUNTINGDOCUMENTTYPE'      trg_field = 'BKPF-BLART' )
                                            ( src_field = 'DOCUMENTDATE'                trg_field = 'BKPF-BLDAT' )
                                            ( src_field = 'POSTINGDATE'                 trg_field = 'BKPF-BUDAT' )
                                            ( src_field = 'CURRENCYCODE'                trg_field = 'BKPF-WAERS' )
                                            ( src_field = 'CURRENCYTRANSLATIONDATE'     trg_field = 'BKPF-WWERT' )
                                            ( src_field = 'EXCHANGERATE'                trg_field = 'BKPF-KURSF' )
                                            ( src_field = 'DOCUMENTHEADERTEXT'          trg_field = 'BKPF-BKTXT' )
                                            ( src_field = 'REFERENCEDOCUMENT'           trg_field = 'BKPF-XBLNR' )
*                                            ( src_field = 'REFERENCE1INDOCUMENTHEADER'  trg_field = 'BKPF-XREF1_HD' )
*                                            ( src_field = 'REFERENCE2INDOCUMENTHEADER'  trg_field = 'BKPF-XREF2_HD' )
                                            ).



*    gs_field_ftpost_mapping-_item  = VALUE #( trg_level = 'K' " Header
*                                            ( src_field = 'BRANCHCODE'                      trg_field = 'BKPF-BRNCH' ) ).

    gs_field_ftpost_mapping-_item  = VALUE #( BASE gs_field_ftpost_mapping-_item trg_level = 'P' " Item
*                                            ( src_field = 'REFERENCEDOCUMENTITEM'           trg_field = '' )
                                            ( src_field = 'POSTINGKEY'                      trg_field = 'BSEG-BSCHL' )
                                            ( src_field = 'ACCOUNT'                         trg_field = 'BSEG-HKONT' )
                                            ( src_field = 'SPECIALGLCODE'                   trg_field = 'RF05A-NEWUM' )
                                            ( src_field = 'AMOUNTINTRANSACTIONCURRENCY'     trg_field = 'BSEG-WRBTR' )
                                            ( src_field = 'BRANCHCODE'                      trg_field = 'BSEG-J_1TPBUPL' )
                                            ( src_field = 'BUSINESSPLACE'                   trg_field = 'BSEG-BUPLA' )
                                            ( src_field = 'DUECALCULATIONBASEDATE'          trg_field = 'BSEG-ZFBDT' )
                                            ( src_field = 'PAYMENTTERMS'                    trg_field = 'BSEG-ZTERM' )
                                            ( src_field = 'PAYMENTMETHOD'                   trg_field = 'BSEG-ZLSCH' )
                                            ( src_field = 'PAYMENTMETHODSUPPLEMENT'         trg_field = 'BSEG-UZAWE' )
                                            ( src_field = 'PAYMENTBLOCKINGREASON'           trg_field = 'BSEG-ZLSPR' )
                                            ( src_field = 'BPBANKACCOUNTINTERNALID'         trg_field = 'BSEG-BVTYP' )
                                            ( src_field = 'DOCUMENTITEMTEXT'                trg_field = 'BSEG-SGTXT' )
                                            ( src_field = 'ASSIGNMENTREFERENCE'             trg_field = 'BSEG-ZUONR' )
                                            ( src_field = 'VALUEDATE'                       trg_field = 'BSEG-VALUT' )
                                            ( src_field = 'REFERENCE1IDBYBUSINESSPARTNER'   trg_field = 'BSEG-XREF1' )
                                            ( src_field = 'REFERENCE2IDBYBUSINESSPARTNER'   trg_field = 'BSEG-XREF2' )
                                            ( src_field = 'REFERENCE3IDBYBUSINESSPARTNER'   trg_field = 'BSEG-XREF3' )
                                            ( src_field = 'PROFITCENTER'                    trg_field = 'BSEG-PRCTR' )
                                            ( src_field = 'PAYEEISALTERNATIVEPAYEE'         trg_field = 'RF05A-REGUL' )
                                            ( src_field = 'NAME'                            trg_field = 'BSEC-NAME1' )
                                            ( src_field = 'NAME2'                           trg_field = 'BSEC-NAME2' )
                                            ( src_field = 'NAME3'                           trg_field = 'BSEC-NAME3' )
                                            ( src_field = 'NAME4'                           trg_field = 'BSEC-NAME4' )
                                            ( src_field = 'SHORTSTREETNAME'                 trg_field = 'BSEC-STRAS' )
                                            ( src_field = 'CITYNAME'                        trg_field = 'BSEC-ORT01' )
                                            ( src_field = 'POSTALCODE'                      trg_field = 'BSEC-PSTLZ' )
                                            ( src_field = 'COUNTRY'                         trg_field = 'BSEC-LAND1' )
                                            ( src_field = 'BANKNUMBER'                      trg_field = 'BSEC-BANKL' )
                                            ( src_field = 'BANKACCOUNT'                     trg_field = 'BSEC-BANKN' )
                                            ( src_field = 'TAXNUMBER3'                      trg_field = 'BSEC-STCD3' ) ).
  ENDMETHOD.

  METHOD post_clear.
    LOOP AT mt_post_clear_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      call_post_clear_bdc( EXPORTING is_data      = <ls_data>-post_data
                           IMPORTING es_doc_clear = <ls_data>-doc_clear
                                     es_result    = <ls_data>-message ).

      IF <ls_data>-doc_clear IS NOT INITIAL AND <ls_data>-message-type = 'S'.
        call_fi_document_change( is_fi_key   = <ls_data>-doc_clear
                                 is_chg_data = <ls_data>-change_data ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD call_post_clear_bdc.

    DATA : lt_blntab  TYPE zcl_t2_journal_entry_clearing=>_blntab,
           lt_ftclear TYPE zcl_t2_journal_entry_clearing=>_ftclear,
           lt_ftpost  TYPE zcl_t2_journal_entry_clearing=>_ftpost,
           lt_fttax   TYPE zcl_t2_journal_entry_clearing=>_fttax.

    lt_ftclear = CORRESPONDING #( is_data-ftclear ).
    lt_ftpost = CORRESPONDING #( is_data-ftpost ).

    TRY.

        zcl_t2_journal_entry_clearing=>zfm_call_post_inf_clear(
           IMPORTING
            es_return         = DATA(ls_result)
          CHANGING
            t_blntab          = lt_blntab
            t_ftclear         = lt_ftclear
            t_ftpost          = lt_ftpost
            t_fttax           = lt_fttax
        ).

        es_doc_clear = VALUE #( lt_blntab[ 1 ] OPTIONAL ) .
        es_result    = ls_result .

      CATCH cx_aco_application_exception.
      CATCH cx_aco_communication_failure.
      CATCH cx_aco_system_failure.
    ENDTRY.

  ENDMETHOD.


  METHOD get_postclear_data.
    et_data = mt_post_clear_data .
  ENDMETHOD.

  METHOD call_fi_document_change.
    DATA(lt_accchg) = VALUE zcl_t2_journal_entry_change=>_accchg(
                                ( fdname = 'XREF1_HD' newval = is_chg_data-Reference1InDocumentHeader )
                                ( fdname = 'XREF2_HD' newval = is_chg_data-Reference2InDocumentHeader ) ).

    TRY.
        zcl_t2_journal_entry_change=>zfm_fi_document_change( EXPORTING i_belnr  = is_fi_key-belnr
                                                                       i_bukrs  = is_fi_key-bukrs
                                                                       i_gjahr  = is_fi_key-gjahr
                                                             CHANGING  t_accchg = lt_accchg ).

      CATCH cx_aco_application_exception
            cx_aco_communication_failure
            cx_aco_system_failure.
        " handle exception
    ENDTRY.
  ENDMETHOD.

  METHOD get_payment_term.
    SELECT SINGLE FROM I_SupplierCompany
      FIELDS PaymentTerms
      WHERE Supplier = @iv_supplier AND CompanyCode = @iv_companycode
      INTO @rv_paymentterm.
  ENDMETHOD.

ENDCLASS.

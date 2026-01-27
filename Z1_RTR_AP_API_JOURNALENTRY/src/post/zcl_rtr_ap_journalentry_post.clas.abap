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
CLASS zcl_rtr_ap_journalentry_post DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES zif_rtr_ap_journalentry.

    " API Structure
    TYPES ts_keys_post                   TYPE STRUCTURE FOR ACTION IMPORT zr_rtr_ap_journalentrytp\\journalentry~post.
    TYPES tt_keys_post                   TYPE TABLE FOR ACTION IMPORT zr_rtr_ap_journalentrytp\\journalentry~post.

    TYPES ts_keys_reverse                TYPE STRUCTURE FOR ACTION IMPORT zr_rtr_ap_journalentrytp\\journalentry~reverse.
    TYPES tt_keys_reverse                TYPE TABLE FOR ACTION IMPORT zr_rtr_ap_journalentrytp\\journalentry~reverse.

    TYPES ts_validate_failed             TYPE RESPONSE FOR FAILED EARLY zr_rtr_ap_journalentrytp.
    TYPES ts_validate_reported           TYPE RESPONSE FOR REPORTED EARLY zr_rtr_ap_journalentrytp.
    TYPES tt_validate_result             TYPE TABLE FOR FUNCTION RESULT zr_rtr_ap_journalentrytp\\journalentry~validate.

    TYPES ts_save_failed                 TYPE RESPONSE FOR FAILED EARLY zr_rtr_ap_journalentrytp.
    TYPES ts_save_mapped                 TYPE RESPONSE FOR MAPPED EARLY zr_rtr_ap_journalentrytp.
    TYPES ts_save_reported               TYPE RESPONSE FOR REPORTED EARLY zr_rtr_ap_journalentrytp.

    TYPES ts_late_mapped                 TYPE RESPONSE FOR MAPPED LATE zr_rtr_ap_journalentrytp.
    TYPES ts_late_reported               TYPE RESPONSE FOR REPORTED LATE zr_rtr_ap_journalentrytp.

    " Header
    TYPES ts_journalentry_header         TYPE zd_rtr_ap_journalentryposti1 WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_header         TYPE TABLE OF ts_journalentry_header WITH EMPTY KEY.

    " GL Items
    TYPES ts_journalentry_glitems        TYPE zd_rtr_ap_journalentryglitems WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_glitems        TYPE TABLE OF ts_journalentry_glitems WITH EMPTY KEY.

    " Creditor Items
    TYPES ts_journalentry_creditoritem   TYPE zd_rtr_ap_journalentryapitems WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_creditoritem   TYPE TABLE OF ts_journalentry_creditoritem WITH EMPTY KEY.

    " Debitor Items
    TYPES ts_journalentry_debtoritem     TYPE zd_rtr_ap_journalentryaritems WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_debtoritem     TYPE TABLE OF ts_journalentry_debtoritem WITH EMPTY KEY.

    " Product Tax Items
    TYPES ts_journalentry_producttaxitem TYPE zd_rtr_ap_journalentrytaxitems WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_producttaxitem TYPE TABLE OF ts_journalentry_producttaxitem WITH EMPTY KEY.

    " WithHolding Tax Items
    TYPES ts_journalentry_whtitems       TYPE zd_rtr_ap_journalentrywhtitems WITH INDICATORS control TYPE if_abap_behv=>t_xflag.
    TYPES tt_journalentry_whtitems       TYPE TABLE OF ts_journalentry_whtitems WITH EMPTY KEY.

    TYPES ts_customer                    TYPE i_customer.
    TYPES ts_supplier                    TYPE i_supplier.

    TYPES: BEGIN OF ts_journalentry_key,
             companycode        TYPE fis_bukrs,
             fiscalyear         TYPE fis_gjahr_no_conv,
             accountingdocument TYPE farp_belnr_d,
           END OF ts_journalentry_key.

    TYPES: BEGIN OF ts_journalentry_mapped,
             cid       TYPE abp_behv_cid,
             cid_index TYPE sy-tabix,
             pid       TYPE abp_behv_pid,
             tmp       TYPE ts_journalentry_key.
             INCLUDE TYPE ts_journalentry_key.
    TYPES:   msg       TYPE REF TO if_abap_behv_message,
           END OF ts_journalentry_mapped.

    TYPES tt_customer                TYPE SORTED TABLE OF i_customer WITH UNIQUE KEY customer.
    TYPES tt_supplier                TYPE SORTED TABLE OF i_supplier WITH UNIQUE KEY supplier.
    TYPES tt_customercompany         TYPE SORTED TABLE OF i_customercompany WITH UNIQUE KEY customer companycode.
    TYPES tt_suppliercompany         TYPE SORTED TABLE OF i_suppliercompany WITH UNIQUE KEY supplier companycode.
    TYPES tt_country                 TYPE SORTED TABLE OF i_country WITH UNIQUE KEY country.
    TYPES tt_currency                TYPE SORTED TABLE OF i_currency WITH UNIQUE KEY currency.
    TYPES tt_companycode             TYPE SORTED TABLE OF i_companycode WITH UNIQUE KEY companycode.
    TYPES tt_unitofmeasure           TYPE SORTED TABLE OF i_unitofmeasure WITH UNIQUE KEY unitofmeasure.
    TYPES tt_product                 TYPE SORTED TABLE OF i_product WITH UNIQUE KEY product.
    TYPES tt_companycodecurrencyrole TYPE SORTED TABLE OF i_companycodecurrencyrole WITH UNIQUE KEY companycode currencyrole.

    TYPES tt_journalentry_key        TYPE TABLE OF ts_journalentry_key WITH EMPTY KEY
                                                                       WITH NON-UNIQUE SORTED KEY k2 COMPONENTS companycode fiscalyear accountingdocument.
    TYPES tt_journalentry_mapped     TYPE TABLE OF ts_journalentry_mapped WITH EMPTY KEY
                                                                          WITH NON-UNIQUE SORTED KEY k2 COMPONENTS cid cid_index.

    CONSTANTS: BEGIN OF c_accttype,
                 customer  TYPE i_journalentryitem-financialaccounttype VALUE 'D',
                 vendor    TYPE i_journalentryitem-financialaccounttype VALUE 'K',
                 glaccount TYPE i_journalentryitem-financialaccounttype VALUE 'S',
               END OF c_accttype.

    CONSTANTS: BEGIN OF c_msgty,
                 error   TYPE c LENGTH 1 VALUE 'E',
                 success TYPE c LENGTH 1 VALUE 'S',
               END OF c_msgty.

    CONSTANTS: BEGIN OF c_debitcreditcode,
                 debit  TYPE shkzg VALUE 'S', " Debit -> '+'
                 credit TYPE shkzg VALUE 'H', " Credit -> '-'
               END OF c_debitcreditcode.

    CONSTANTS: BEGIN OF c_curr_type,
                 documentcurr   TYPE curtp VALUE '00', " Document currency
                 compancodecurr TYPE curtp VALUE '10', " Company code currency
                 groupcurr      TYPE curtp VALUE '30', " Group currency
                 hardcurr       TYPE curtp VALUE '40', " Hard currency
               END OF c_curr_type.

    CONSTANTS: BEGIN OF c_key_tmp,
                 fiscalyear         TYPE i_journalentryitem-fiscalyear         VALUE '0000',
                 accountingdocument TYPE i_journalentryitem-accountingdocument VALUE '$',
               END OF c_key_tmp.

    CONSTANTS c_any_error          TYPE c LENGTH 3  VALUE 'EAX'.

    CONSTANTS c_program_zrtr_ap011 TYPE c LENGTH 30 VALUE 'ZCL_RTR_AP_JOURNALENTRY_POST'.

    ALIASES ty_char1 FOR zif_rtr_ap_journalentry~ty_char1.
    ALIASES c_action FOR zif_rtr_ap_journalentry~c_action.

    DATA mt_journalentry_keys TYPE tt_journalentry_mapped READ-ONLY.
    DATA mv_action            TYPE ty_char1               READ-ONLY.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS constructor.

    METHODS set_interface_api_keys
      IMPORTING it_keys            TYPE tt_keys_post
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS get_interface_api_keys
      RETURNING VALUE(rt_keys) TYPE tt_keys_post.

    METHODS set_interface_api_keys_rev
      IMPORTING is_keys            TYPE ts_keys_reverse
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS get_interface_api_keys_rev
      RETURNING VALUE(rt_keys) TYPE tt_keys_reverse.

    METHODS prepare_document_from_api
      IMPORTING is_key             TYPE ts_keys_post
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS check_accounting_document
      EXPORTING et_return          TYPE zcl_t2_bapi_acc_document=>_bapiret2
                es_return          TYPE bapiret2
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS posting_accounting_document
      EXPORTING ev_companycode        TYPE i_journalentry-companycode
                ev_accountingdocument TYPE i_journalentry-accountingdocument
                ev_fiscalyear         TYPE i_journalentry-fiscalyear
                et_return             TYPE zcl_t2_bapi_acc_document=>_bapiret2
                es_return             TYPE bapiret2
      RETURNING VALUE(ro_instance)    TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS validate_accounting_document
      EXPORTING et_result          TYPE tt_validate_result
                es_failed          TYPE ts_validate_failed
                es_reported        TYPE ts_validate_reported
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS save_accounting_document
      EXPORTING es_failed          TYPE ts_save_failed
                es_mapped          TYPE ts_save_mapped
                es_reported        TYPE ts_save_reported
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS acc_document_check
      IMPORTING is_documentheader    TYPE zcl_t2_bapi_acc_document=>bapiache09
                is_customercpd       TYPE zcl_t2_bapi_acc_document=>bapiacpa09  OPTIONAL
                is_contractheader    TYPE zcl_t2_bapi_acc_document=>bapiaccahd  OPTIONAL
      EXPORTING et_return            TYPE zcl_t2_bapi_acc_document=>_bapiret2
      CHANGING  ct_accountgl         TYPE zcl_t2_bapi_acc_document=>_bapiacgl09 OPTIONAL
                ct_accountreceivable TYPE zcl_t2_bapi_acc_document=>_bapiacar09 OPTIONAL
                ct_accountpayable    TYPE zcl_t2_bapi_acc_document=>_bapiacap09 OPTIONAL
                ct_accounttax        TYPE zcl_t2_bapi_acc_document=>_bapiactx09 OPTIONAL
                ct_currencyamount    TYPE zcl_t2_bapi_acc_document=>_bapiaccr09 OPTIONAL
                ct_criteria          TYPE zcl_t2_bapi_acc_document=>_bapiackec9 OPTIONAL
                ct_valuefield        TYPE zcl_t2_bapi_acc_document=>_bapiackev9 OPTIONAL
                ct_extension1        TYPE zcl_t2_bapi_acc_document=>_bapiacextc OPTIONAL
                ct_paymentcard       TYPE zcl_t2_bapi_acc_document=>_bapiacpc09 OPTIONAL
                ct_contractitem      TYPE zcl_t2_bapi_acc_document=>_bapiaccait OPTIONAL
                ct_extension2        TYPE zcl_t2_bapi_acc_document=>_bapiparex  OPTIONAL
                ct_realestate        TYPE zcl_t2_bapi_acc_document=>_bapiacre09 OPTIONAL
                ct_accountwt         TYPE zcl_t2_bapi_acc_document=>_bapiacwt09 OPTIONAL.

    METHODS acc_document_post
      IMPORTING is_documentheader     TYPE zcl_t2_bapi_acc_document=>bapiache09
                is_customercpd        TYPE zcl_t2_bapi_acc_document=>bapiacpa09  OPTIONAL
                is_contractheader     TYPE zcl_t2_bapi_acc_document=>bapiaccahd  OPTIONAL
                iv_testrun            TYPE abap_bool                             DEFAULT abap_true
                iv_postdocument       TYPE abap_bool                             DEFAULT abap_true
      EXPORTING ev_obj_type           TYPE zcl_t2_bapi_acc_document=>bapiache09-obj_type
                ev_obj_key            TYPE zcl_t2_bapi_acc_document=>bapiache09-obj_key
                ev_obj_sys            TYPE zcl_t2_bapi_acc_document=>bapiache09-obj_sys
                ev_companycode        TYPE i_journalentry-companycode
                ev_accountingdocument TYPE i_journalentry-accountingdocument
                ev_fiscalyear         TYPE i_journalentry-fiscalyear
                et_return             TYPE zcl_t2_bapi_acc_document=>_bapiret2
                ev_error              TYPE abap_bool
      CHANGING  ct_accountgl          TYPE zcl_t2_bapi_acc_document=>_bapiacgl09 OPTIONAL
                ct_accountreceivable  TYPE zcl_t2_bapi_acc_document=>_bapiacar09 OPTIONAL
                ct_accountpayable     TYPE zcl_t2_bapi_acc_document=>_bapiacap09 OPTIONAL
                ct_accounttax         TYPE zcl_t2_bapi_acc_document=>_bapiactx09 OPTIONAL
                ct_currencyamount     TYPE zcl_t2_bapi_acc_document=>_bapiaccr09 OPTIONAL
                ct_criteria           TYPE zcl_t2_bapi_acc_document=>_bapiackec9 OPTIONAL
                ct_valuefield         TYPE zcl_t2_bapi_acc_document=>_bapiackev9 OPTIONAL
                ct_extension1         TYPE zcl_t2_bapi_acc_document=>_bapiacextc OPTIONAL
                ct_paymentcard        TYPE zcl_t2_bapi_acc_document=>_bapiacpc09 OPTIONAL
                ct_contractitem       TYPE zcl_t2_bapi_acc_document=>_bapiaccait OPTIONAL
                ct_extension2         TYPE zcl_t2_bapi_acc_document=>_bapiparex  OPTIONAL
                ct_realestate         TYPE zcl_t2_bapi_acc_document=>_bapiacre09 OPTIONAL
                ct_accountwt          TYPE zcl_t2_bapi_acc_document=>_bapiacwt09 OPTIONAL.

    METHODS clear_api_keys
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS clear_document_from_api
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_rtr_ap_journalentry_post.

    METHODS set_current_action
      IMPORTING iv_action TYPE ty_char1.

    METHODS get_current_action
      RETURNING VALUE(rv_action) TYPE ty_char1.

    METHODS set_journalentry_temp_keys
      IMPORTING is_journalentry_keys TYPE ts_journalentry_mapped.

    METHODS get_pid
      RETURNING VALUE(rv_pid) TYPE sysuuid_x16.

    METHODS reverse_accounting_document
      IMPORTING iv_companycode        TYPE zd_rtr_ap_journalentryreverse-companycode
                iv_accountingdocument TYPE zd_rtr_ap_journalentryreverse-accountingdocument
                iv_fiscalyear         TYPE zd_rtr_ap_journalentryreverse-fiscalyear
                iv_postingdate        TYPE zd_rtr_ap_journalentryreverse-postingdate    OPTIONAL
                iv_reversalreason     TYPE zd_rtr_ap_journalentryreverse-reversalreason OPTIONAL
      RAISING   zcx_t2_static_check.

    METHODS adjust_numbers_post_je
      CHANGING cs_mapped   TYPE ts_late_mapped
               cs_reported TYPE ts_late_reported.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_rtr_ap_journalentry_post.

    DATA mt_keys_post               TYPE tt_keys_post.
    DATA mt_keys_reverse            TYPE tt_keys_reverse.

    DATA ms_documentheader          TYPE zcl_t2_bapi_acc_document=>bapiache09.
    DATA mt_extension2              TYPE zcl_t2_bapi_acc_document=>_bapiparex.

    DATA mt_accountgl               TYPE zcl_t2_bapi_acc_document=>_bapiacgl09.
    DATA mt_currencyamount          TYPE zcl_t2_bapi_acc_document=>_bapiaccr09.
    DATA mt_criteria                TYPE zcl_t2_bapi_acc_document=>_bapiackec9.

    DATA ms_customercpd             TYPE zcl_t2_bapi_acc_document=>bapiacpa09.
    DATA mt_accountpayable          TYPE zcl_t2_bapi_acc_document=>_bapiacap09.
    DATA mt_accountreceivable       TYPE zcl_t2_bapi_acc_document=>_bapiacar09.
    DATA mt_accounttax              TYPE zcl_t2_bapi_acc_document=>_bapiactx09.
    DATA mt_accountwt               TYPE zcl_t2_bapi_acc_document=>_bapiacwt09.

    DATA mt_customer                TYPE tt_customer.
    DATA mt_supplier                TYPE tt_supplier.
    DATA mt_customercompany         TYPE tt_customercompany.
    DATA mt_suppliercompany         TYPE tt_suppliercompany.
    DATA mt_country                 TYPE tt_country.
    DATA mt_currency                TYPE tt_currency.
    DATA mt_companycode             TYPE tt_companycode.
    DATA mt_unitofmeasure           TYPE tt_unitofmeasure.
    DATA mt_product                 TYPE tt_product.
    DATA mt_companycodecurrencyrole TYPE tt_companycodecurrencyrole.

    DATA mo_abap_config_inst        TYPE REF TO zcl_ext_abap_config.

    DATA mv_itemno_acc              TYPE posnr_acc.

    METHODS _check_customer_supplier
      IMPORTING iv_customer TYPE i_customer-customer OPTIONAL
                iv_supplier TYPE i_supplier-supplier OPTIONAL
      EXPORTING es_customer TYPE ts_customer
                es_supplier TYPE ts_supplier.

    METHODS _fill_documentheader
      IMPORTING is_documentheader_api TYPE ts_journalentry_header               OPTIONAL
                is_documentheader     TYPE zcl_t2_bapi_acc_document=>bapiache09 OPTIONAL
      CHANGING  cs_documentheader     TYPE zcl_t2_bapi_acc_document=>bapiache09
                ct_extension2         TYPE zcl_t2_bapi_acc_document=>_bapiparex OPTIONAL.

    METHODS _fill_accountpayable
      IMPORTING is_documentheader_api       TYPE ts_journalentry_header                OPTIONAL
                is_accountpayable_api       TYPE ts_journalentry_creditoritem          OPTIONAL
                it_journalentry_whtitem_api TYPE tt_journalentry_whtitems              OPTIONAL
                is_documentheader           TYPE zcl_t2_bapi_acc_document=>bapiache09  OPTIONAL
                is_accountpayable           TYPE zcl_t2_bapi_acc_document=>bapiacap09  OPTIONAL
                is_currencyamount           TYPE zcl_t2_bapi_acc_document=>bapiaccr09  OPTIONAL
      CHANGING  cs_customercpd              TYPE zcl_t2_bapi_acc_document=>bapiacpa09  OPTIONAL
                ct_accountpayable           TYPE zcl_t2_bapi_acc_document=>_bapiacap09
                ct_accounttax               TYPE zcl_t2_bapi_acc_document=>_bapiactx09 OPTIONAL
                ct_currencyamount           TYPE zcl_t2_bapi_acc_document=>_bapiaccr09
                ct_criteria                 TYPE zcl_t2_bapi_acc_document=>_bapiackec9 OPTIONAL
                ct_valuefield               TYPE zcl_t2_bapi_acc_document=>_bapiackev9 OPTIONAL
                ct_extension1               TYPE zcl_t2_bapi_acc_document=>_bapiacextc OPTIONAL
                ct_paymentcard              TYPE zcl_t2_bapi_acc_document=>_bapiacpc09 OPTIONAL
                ct_contractitem             TYPE zcl_t2_bapi_acc_document=>_bapiaccait OPTIONAL
                ct_extension2               TYPE zcl_t2_bapi_acc_document=>_bapiparex  OPTIONAL
                ct_realestate               TYPE zcl_t2_bapi_acc_document=>_bapiacre09 OPTIONAL
                ct_accountwt                TYPE zcl_t2_bapi_acc_document=>_bapiacwt09 OPTIONAL.

    METHODS _fill_accountreceivable
      IMPORTING is_documentheader_api       TYPE ts_journalentry_header                OPTIONAL
                is_accountreceivable_api    TYPE ts_journalentry_debtoritem            OPTIONAL
                it_journalentry_whtitem_api TYPE tt_journalentry_whtitems              OPTIONAL
                is_documentheader           TYPE zcl_t2_bapi_acc_document=>bapiache09  OPTIONAL
                is_accountreceivable        TYPE zcl_t2_bapi_acc_document=>bapiacar09  OPTIONAL
                is_currencyamount           TYPE zcl_t2_bapi_acc_document=>bapiaccr09  OPTIONAL
      CHANGING  cs_customercpd              TYPE zcl_t2_bapi_acc_document=>bapiacpa09  OPTIONAL
                ct_accountreceivable        TYPE zcl_t2_bapi_acc_document=>_bapiacar09
                ct_accounttax               TYPE zcl_t2_bapi_acc_document=>_bapiactx09 OPTIONAL
                ct_currencyamount           TYPE zcl_t2_bapi_acc_document=>_bapiaccr09
                ct_criteria                 TYPE zcl_t2_bapi_acc_document=>_bapiackec9 OPTIONAL
                ct_valuefield               TYPE zcl_t2_bapi_acc_document=>_bapiackev9 OPTIONAL
                ct_extension1               TYPE zcl_t2_bapi_acc_document=>_bapiacextc OPTIONAL
                ct_paymentcard              TYPE zcl_t2_bapi_acc_document=>_bapiacpc09 OPTIONAL
                ct_contractitem             TYPE zcl_t2_bapi_acc_document=>_bapiaccait OPTIONAL
                ct_extension2               TYPE zcl_t2_bapi_acc_document=>_bapiparex  OPTIONAL
                ct_realestate               TYPE zcl_t2_bapi_acc_document=>_bapiacre09 OPTIONAL
                ct_accountwt                TYPE zcl_t2_bapi_acc_document=>_bapiacwt09 OPTIONAL.

    METHODS _fill_accountgl
      IMPORTING is_documentheader_api TYPE ts_journalentry_header                OPTIONAL
                is_accountgl_api      TYPE ts_journalentry_glitems               OPTIONAL
                is_documentheader     TYPE zcl_t2_bapi_acc_document=>bapiache09  OPTIONAL
                is_accountgl          TYPE zcl_t2_bapi_acc_document=>bapiacgl09  OPTIONAL
                is_currencyamount     TYPE zcl_t2_bapi_acc_document=>bapiaccr09  OPTIONAL
      CHANGING  ct_accountgl          TYPE zcl_t2_bapi_acc_document=>_bapiacgl09
                ct_accounttax         TYPE zcl_t2_bapi_acc_document=>_bapiactx09 OPTIONAL
                ct_currencyamount     TYPE zcl_t2_bapi_acc_document=>_bapiaccr09
                ct_criteria           TYPE zcl_t2_bapi_acc_document=>_bapiackec9 OPTIONAL
                ct_valuefield         TYPE zcl_t2_bapi_acc_document=>_bapiackev9 OPTIONAL
                ct_extension1         TYPE zcl_t2_bapi_acc_document=>_bapiacextc OPTIONAL
                ct_paymentcard        TYPE zcl_t2_bapi_acc_document=>_bapiacpc09 OPTIONAL
                ct_contractitem       TYPE zcl_t2_bapi_acc_document=>_bapiaccait OPTIONAL
                ct_extension2         TYPE zcl_t2_bapi_acc_document=>_bapiparex  OPTIONAL
                ct_realestate         TYPE zcl_t2_bapi_acc_document=>_bapiacre09 OPTIONAL.

    METHODS _fill_vendor_customer_onetime
      IMPORTING is_accountpayable_api    TYPE ts_journalentry_creditoritem OPTIONAL
                is_accountreceivable_api TYPE ts_journalentry_debtoritem   OPTIONAL
      CHANGING  cs_customercpd           TYPE zcl_t2_bapi_acc_document=>bapiacpa09.

    METHODS _fill_accountwt
      IMPORTING is_withholdingtax_api TYPE ts_journalentry_whtitems             OPTIONAL
                is_accountwt          TYPE zcl_t2_bapi_acc_document=>bapiacwt09 OPTIONAL
      CHANGING  ct_accountwt          TYPE zcl_t2_bapi_acc_document=>_bapiacwt09.

    METHODS _fill_accounttax
      IMPORTING is_documentheader_api    TYPE ts_journalentry_header                OPTIONAL
                is_accountpayable_api    TYPE ts_journalentry_creditoritem          OPTIONAL
                is_accountreceivable_api TYPE ts_journalentry_debtoritem            OPTIONAL
                is_accountgl_api         TYPE ts_journalentry_glitems               OPTIONAL
                is_producttaxitem_api    TYPE ts_journalentry_producttaxitem        OPTIONAL
                is_documentheader        TYPE zcl_t2_bapi_acc_document=>bapiache09  OPTIONAL
                is_accounttax            TYPE zcl_t2_bapi_acc_document=>bapiactx09  OPTIONAL
                is_currencyamount        TYPE zcl_t2_bapi_acc_document=>bapiaccr09  OPTIONAL
      CHANGING  ct_accounttax            TYPE zcl_t2_bapi_acc_document=>_bapiactx09
                ct_currencyamount        TYPE zcl_t2_bapi_acc_document=>_bapiaccr09 OPTIONAL.

    METHODS _fill_currencyamount
      IMPORTING is_documentheader_api    TYPE ts_journalentry_header               OPTIONAL
                is_accountpayable_api    TYPE ts_journalentry_creditoritem         OPTIONAL
                is_accountreceivable_api TYPE ts_journalentry_debtoritem           OPTIONAL
                is_accountgl_api         TYPE ts_journalentry_glitems              OPTIONAL
                is_documentheader        TYPE zcl_t2_bapi_acc_document=>bapiache09 OPTIONAL
                is_producttaxitem        TYPE ts_journalentry_producttaxitem       OPTIONAL
                is_currencyamount        TYPE zcl_t2_bapi_acc_document=>bapiaccr09 OPTIONAL
      CHANGING  ct_currencyamount        TYPE zcl_t2_bapi_acc_document=>_bapiaccr09.

    METHODS _fill_tax_is_exempt_api
      IMPORTING is_documentheader_api    TYPE ts_journalentry_header                OPTIONAL
                it_accountpayable_api    TYPE tt_journalentry_creditoritem          OPTIONAL
                it_accountreceivable_api TYPE tt_journalentry_debtoritem            OPTIONAL
                it_accountgl_api         TYPE tt_journalentry_glitems               OPTIONAL
                it_producttaxitem_api    TYPE tt_journalentry_producttaxitem        OPTIONAL
      CHANGING  ct_accounttax            TYPE zcl_t2_bapi_acc_document=>_bapiactx09
                ct_currencyamount        TYPE zcl_t2_bapi_acc_document=>_bapiaccr09 OPTIONAL.

    METHODS _fill_downpayment_api
      IMPORTING is_documentheader_api    TYPE ts_journalentry_header                OPTIONAL
                it_accountpayable_api    TYPE tt_journalentry_creditoritem          OPTIONAL
                it_accountreceivable_api TYPE tt_journalentry_debtoritem            OPTIONAL
      CHANGING  ct_accounttax            TYPE zcl_t2_bapi_acc_document=>_bapiactx09
                ct_currencyamount        TYPE zcl_t2_bapi_acc_document=>_bapiaccr09 OPTIONAL.

    METHODS _convert_structure_conversion
      CHANGING cv_data TYPE any.

    METHODS _get_country_code_sap_to_iso
      IMPORTING iv_country               TYPE i_country-country
      RETURNING VALUE(rv_countryisocode) TYPE i_country-countryisocode.

    METHODS _get_currency_code_sap_to_iso
      IMPORTING iv_currency               TYPE i_currency-currency
      RETURNING VALUE(rv_currencyisocode) TYPE i_currency-currencyisocode.

    METHODS _get_company_code_country
      IMPORTING iv_companycode    TYPE i_companycode-companycode
      RETURNING VALUE(rv_country) TYPE i_companycode-country.

    METHODS _get_unitofmeasure_to_iso
      IMPORTING iv_unitofmeasure               TYPE i_unitofmeasure-unitofmeasure
      RETURNING VALUE(rv_unitofmeasureisocode) TYPE i_unitofmeasure-unitofmeasureisocode.

    METHODS _get_product_type
      IMPORTING iv_product            TYPE i_product-product
      RETURNING VALUE(rv_producttype) TYPE i_product-producttype.

    METHODS _get_companycodecurrencyrole
      IMPORTING iv_companycode     TYPE i_companycodecurrencyrole-companycode
                iv_currencyrole    TYPE i_companycodecurrencyrole-currencyrole
      RETURNING VALUE(rv_currency) TYPE i_companycodecurrencyrole-currency.

    METHODS _get_customer_supplier_zterm
      IMPORTING iv_customer            TYPE i_customer-customer OPTIONAL
                iv_supplier            TYPE i_supplier-supplier OPTIONAL
                iv_companycode         TYPE i_suppliercompany-companycode
      RETURNING VALUE(rv_paymentterms) TYPE i_suppliercompany-paymentterms.

ENDCLASS.


CLASS zcl_rtr_ap_journalentry_post IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.

    RETURN go_instance.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).

    TRY.
        mo_abap_config_inst = zcl_ext_abap_config=>get_instance( iv_program = c_program_zrtr_ap011 ).
      CATCH zcx_ext_abap_config.
    ENDTRY.
  ENDMETHOD.

  METHOD set_interface_api_keys.
    ro_instance = me.
    mt_keys_post = it_keys.
  ENDMETHOD.

  METHOD get_interface_api_keys.
    rt_keys = mt_keys_post.
  ENDMETHOD.

  METHOD prepare_document_from_api.
    DATA ls_journalentry_header         TYPE ts_journalentry_header.
    DATA lt_journalentry_glitems        TYPE tt_journalentry_glitems.
    DATA lt_journalentry_creditoritem   TYPE tt_journalentry_creditoritem.
    DATA lt_journalentry_debtoritem     TYPE tt_journalentry_debtoritem.
    DATA lt_journalentry_producttaxitem TYPE tt_journalentry_producttaxitem.
    DATA lt_journalentry_whtitem        TYPE tt_journalentry_whtitems.

    CLEAR me->mv_itemno_acc.

    ro_instance = me.

    " -------------------------------------------------------------------------------------
    ls_journalentry_header = CORRESPONDING #( is_key-%param MAPPING control = %control ).
    lt_journalentry_glitems = CORRESPONDING #( is_key-%param-_item MAPPING control = %control ).
    lt_journalentry_creditoritem = CORRESPONDING #( is_key-%param-_creditoritem MAPPING control = %control ).
    lt_journalentry_debtoritem = CORRESPONDING #( is_key-%param-_debtoritem MAPPING control = %control ).
    lt_journalentry_producttaxitem = CORRESPONDING #( is_key-%param-_producttaxitem MAPPING control = %control ).
    lt_journalentry_whtitem = CORRESPONDING #( is_key-%param-_withholdingtaxitem MAPPING control = %control ).

    " -------------------------------------------------------------------------------------
    " Fill Document Header
    _fill_documentheader( EXPORTING is_documentheader_api = ls_journalentry_header
                          CHANGING  cs_documentheader     = ms_documentheader
                                    ct_extension2         = mt_extension2 ).

    " Fill Document Item
    LOOP AT lt_journalentry_glitems INTO FINAL(ls_journalentry_glitems).
      _fill_accountgl( EXPORTING is_documentheader_api = ls_journalentry_header
                                 is_accountgl_api      = ls_journalentry_glitems
                       CHANGING  ct_accountgl          = mt_accountgl
                                 ct_currencyamount     = mt_currencyamount
                                 ct_criteria           = mt_criteria
                                 ct_accounttax         = mt_accounttax ).
    ENDLOOP.

    " Fill Creditor Item
    LOOP AT lt_journalentry_creditoritem INTO FINAL(ls_journalentry_creditoritem).
      _fill_accountpayable( EXPORTING is_documentheader_api       = ls_journalentry_header
                                      is_accountpayable_api       = ls_journalentry_creditoritem
                                      it_journalentry_whtitem_api = lt_journalentry_whtitem
                            CHANGING  cs_customercpd              = ms_customercpd
                                      ct_accountpayable           = mt_accountpayable
                                      ct_currencyamount           = mt_currencyamount
                                      ct_extension2               = mt_extension2
                                      ct_accountwt                = mt_accountwt ).
    ENDLOOP.

    " Fill Debitor Item
    LOOP AT lt_journalentry_debtoritem INTO FINAL(ls_journalentry_debtoritem).
      _fill_accountreceivable( EXPORTING is_documentheader_api       = ls_journalentry_header
                                         is_accountreceivable_api    = ls_journalentry_debtoritem
                                         it_journalentry_whtitem_api = lt_journalentry_whtitem
                               CHANGING  cs_customercpd              = ms_customercpd
                                         ct_accountreceivable        = mt_accountreceivable
                                         ct_currencyamount           = mt_currencyamount
                                         ct_extension2               = mt_extension2
                                         ct_accountwt                = mt_accountwt ).
    ENDLOOP.

    " Fill Product Tax Item
    LOOP AT lt_journalentry_producttaxitem INTO FINAL(ls_journalentry_producttaxitem).
      _fill_accounttax( EXPORTING is_documentheader_api = ls_journalentry_header
                                  is_producttaxitem_api = ls_journalentry_producttaxitem
                        CHANGING  ct_accounttax         = mt_accounttax
                                  ct_currencyamount     = mt_currencyamount ).
    ENDLOOP.

    " Fill Withholding Tax Item
*    LOOP AT lt_journalentry_whtitem INTO FINAL(ls_journalentry_whtitem).
*      _fill_accountwt( EXPORTING is_withholdingtax_api = ls_journalentry_whtitem
*                       CHANGING  ct_accountwt          = mt_accountwt ).
*    ENDLOOP.

    _fill_tax_is_exempt_api( EXPORTING is_documentheader_api = ls_journalentry_header
                                       it_accountgl_api      = lt_journalentry_glitems
                             CHANGING  ct_accounttax         = mt_accounttax
                                       ct_currencyamount     = mt_currencyamount ).

    _fill_downpayment_api( EXPORTING is_documentheader_api    = ls_journalentry_header
                                     it_accountpayable_api    = lt_journalentry_creditoritem
                                     it_accountreceivable_api = lt_journalentry_debtoritem
                           CHANGING  ct_accounttax            = mt_accounttax
                                     ct_currencyamount        = mt_currencyamount ).
  ENDMETHOD.

  METHOD check_accounting_document.
    CLEAR et_return.
    CLEAR es_return.

    ro_instance = me.

    acc_document_check( EXPORTING is_documentheader    = ms_documentheader
                                  is_customercpd       = ms_customercpd
                        IMPORTING et_return            = et_return
                        CHANGING  ct_accountgl         = mt_accountgl
                                  ct_accountreceivable = mt_accountreceivable
                                  ct_accountpayable    = mt_accountpayable
                                  ct_accounttax        = mt_accounttax
                                  ct_currencyamount    = mt_currencyamount
                                  ct_criteria          = mt_criteria
                                  ct_extension2        = mt_extension2
                                  ct_accountwt         = mt_accountwt ).

    TRY.
        DATA(ls_rw609_msg) = et_return[ id     = 'RW'
                                        number = 609 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    LOOP AT et_return INTO DATA(ls_return) WHERE     type   CA c_any_error
                                                 AND id     <> 'RW'
                                                 AND number <> 609.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      es_return = ls_return.
    ELSEIF ls_rw609_msg IS NOT INITIAL.
      es_return = ls_rw609_msg.
    ELSE.
      TRY.
          ls_return = et_return[ type = c_msgty-success ].
          es_return = ls_return.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD posting_accounting_document.
    CLEAR et_return.
    CLEAR es_return.

    ro_instance = me.

    acc_document_post( EXPORTING is_documentheader     = ms_documentheader
                                 is_customercpd        = ms_customercpd
                                 iv_testrun            = abap_false
                                 iv_postdocument       = abap_true
                       IMPORTING ev_companycode        = ev_companycode
                                 ev_accountingdocument = ev_accountingdocument
                                 ev_fiscalyear         = ev_fiscalyear
                                 et_return             = et_return
                       CHANGING  ct_accountgl          = mt_accountgl
                                 ct_accountreceivable  = mt_accountreceivable
                                 ct_accountpayable     = mt_accountpayable
                                 ct_accounttax         = mt_accounttax
                                 ct_currencyamount     = mt_currencyamount
                                 ct_criteria           = mt_criteria
                                 ct_extension2         = mt_extension2
                                 ct_accountwt          = mt_accountwt ).

    TRY.
        DATA(ls_rw609_msg) = et_return[ id     = 'RW'
                                        number = 609 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    LOOP AT et_return INTO DATA(ls_return) WHERE     type   CA c_any_error
                                                 AND id     <> 'RW'
                                                 AND number <> 609.
      EXIT.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      es_return = ls_return.
    ELSEIF ls_rw609_msg IS NOT INITIAL.
      es_return = ls_rw609_msg.
    ELSE.
      TRY.
          ls_return = et_return[ type = c_msgty-success ].
          es_return = ls_return.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD validate_accounting_document.
    DATA lv_tabix TYPE sy-tabix.

    ro_instance = me.

    DATA(lt_keys) = get_interface_api_keys( ).

    LOOP AT lt_keys INTO DATA(ls_key).
      lv_tabix = sy-tabix.

      zcl_t2_fi_tax_set_bypass=>fi_tax_set_bypass( iv_activate_bypass = abap_true ).

      clear_document_from_api(
                )->prepare_document_from_api( is_key = CORRESPONDING #( DEEP ls_key )
                )->check_accounting_document( IMPORTING et_return = DATA(lt_return) ).

      zcl_t2_fi_tax_set_bypass=>fi_tax_set_bypass( iv_activate_bypass = abap_false ).

      DATA(lv_pid) = get_pid( ).

      LOOP AT lt_return TRANSPORTING NO FIELDS WHERE type CA zcl_rtr_ap_journalentry_post=>c_any_error. "#EC CI_STDSEQ
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        APPEND VALUE #( %cid    = ls_key-%cid
                        %fail   = VALUE #( cause = if_abap_behv=>cause-unspecific )
                        %action = VALUE #( validate = if_abap_behv=>mk-on ) )
               TO es_failed-journalentry.

        LOOP AT lt_return INTO DATA(ls_return) WHERE type CA zcl_rtr_ap_journalentry_post=>c_any_error. "#EC CI_STDSEQ
          APPEND VALUE #( %cid    = ls_key-%cid
                          %msg    = new_message( id       = ls_return-id
                                                 number   = ls_return-number
                                                 severity = if_abap_behv_message=>severity-error
                                                 v1       = ls_return-message_v1
                                                 v2       = ls_return-message_v2
                                                 v3       = ls_return-message_v3
                                                 v4       = ls_return-message_v4 )
                          %action = VALUE #( validate = if_abap_behv=>mk-on ) )
                 TO es_reported-journalentry.
        ENDLOOP.
      ELSE.
        LOOP AT lt_return INTO ls_return WHERE type = zcl_rtr_ap_journalentry_post=>c_msgty-success. "#EC CI_STDSEQ
          APPEND VALUE #( %cid    = ls_key-%cid
                          %pid    = lv_pid
                          %msg    = new_message( id       = ls_return-id
                                                 number   = ls_return-number
                                                 severity = if_abap_behv_message=>severity-success
                                                 v1       = ls_return-message_v1
                                                 v2       = ls_return-message_v2
                                                 v3       = ls_return-message_v3
                                                 v4       = ls_return-message_v4 )
                          %action = VALUE #( validate = if_abap_behv=>mk-on ) )
                 TO es_reported-journalentry.
        ENDLOOP.

        APPEND VALUE #( %cid   = ls_key-%cid
                        %param = CORRESPONDING #( ls_key-%param MAPPING %pid = DEFAULT lv_pid ) ) TO et_result.

        APPEND VALUE #( cid       = ls_key-%cid
                        pid       = lv_pid
                        cid_index = lv_tabix
                        tmp       = VALUE #( companycode        = ls_key-%param-companycode
                                             fiscalyear         = c_key_tmp-fiscalyear
                                             accountingdocument = |{ c_key_tmp-accountingdocument }{ lv_tabix }| ) )
               TO mt_journalentry_keys.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD save_accounting_document.
    DATA lv_tabix TYPE sy-tabix.
    DATA lv_pid   TYPE sysuuid_x16.

    ro_instance = me.

    DATA(lt_keys) = get_interface_api_keys( ).

    LOOP AT lt_keys INTO DATA(ls_key).
      lv_tabix = sy-tabix.

      READ TABLE mt_journalentry_keys INTO DATA(ls_journalentry_key)
           WITH KEY k2 COMPONENTS cid       = ls_key-%cid
                                  cid_index = lv_tabix.
      IF sy-subrc IS INITIAL.
        lv_pid = ls_journalentry_key-pid.
      ELSE.
        TRY.
            lv_pid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
        ENDTRY.
      ENDIF.

      zcl_t2_fi_tax_set_bypass=>fi_tax_set_bypass( iv_activate_bypass = abap_true ).

      clear_document_from_api(
                )->prepare_document_from_api( is_key = CORRESPONDING #( DEEP ls_key )
                )->posting_accounting_document( IMPORTING ev_companycode        = DATA(lv_companycode)
                                                          ev_accountingdocument = DATA(lv_accountingdocument)
                                                          ev_fiscalyear         = DATA(lv_fiscalyear)
                                                          et_return             = DATA(lt_return)  ).

      zcl_t2_fi_tax_set_bypass=>fi_tax_set_bypass( iv_activate_bypass = abap_false ).

      LOOP AT lt_return TRANSPORTING NO FIELDS WHERE type CA zcl_rtr_ap_journalentry_post=>c_any_error. "#EC CI_STDSEQ
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        APPEND VALUE #( %fail   = VALUE #( cause = if_abap_behv=>cause-unspecific )
                        %action = VALUE #( post = if_abap_behv=>mk-on ) )
               TO es_failed-journalentry.

        LOOP AT lt_return INTO DATA(ls_return) WHERE type CA zcl_rtr_ap_journalentry_post=>c_any_error. "#EC CI_STDSEQ
          APPEND VALUE #( companycode        = lv_companycode
                          fiscalyear         = lv_fiscalyear
                          accountingdocument = lv_accountingdocument
                          %msg               = new_message( id       = ls_return-id
                                                            number   = ls_return-number
                                                            severity = if_abap_behv_message=>severity-error
                                                            v1       = ls_return-message_v1
                                                            v2       = ls_return-message_v2
                                                            v3       = ls_return-message_v3
                                                            v4       = ls_return-message_v4 )
                          %action            = VALUE #( post = if_abap_behv=>mk-on ) )
                 TO es_reported-journalentry.
        ENDLOOP.
      ELSE.
        APPEND VALUE #( %cid = ls_key-%cid
                        %pid = lv_pid
                        %key = VALUE #( companycode        = lv_companycode
                                        fiscalyear         = lv_fiscalyear
                                        accountingdocument = lv_accountingdocument ) )
               TO es_mapped-journalentry.

        LOOP AT lt_return INTO ls_return WHERE type = zcl_rtr_ap_journalentry_post=>c_msgty-success. "#EC CI_STDSEQ
          DATA(lo_msg) = new_message( id       = ls_return-id
                                      number   = ls_return-number
                                      severity = if_abap_behv_message=>severity-success
                                      v1       = ls_return-message_v1
                                      v2       = ls_return-message_v2
                                      v3       = ls_return-message_v3
                                      v4       = ls_return-message_v4 ).

          APPEND VALUE #( %cid               = ls_key-%cid
                          %pid               = lv_pid
                          companycode        = lv_companycode
                          fiscalyear         = lv_fiscalyear
                          accountingdocument = lv_accountingdocument
                          %msg               = lo_msg )
                 TO es_reported-journalentry.

          READ TABLE mt_journalentry_keys ASSIGNING FIELD-SYMBOL(<ls_journalentry_key>)
               WITH KEY k2 COMPONENTS cid       = ls_key-%cid
                                      cid_index = lv_tabix.
          IF sy-subrc IS INITIAL.
            <ls_journalentry_key>-companycode        = lv_companycode.
            <ls_journalentry_key>-fiscalyear         = lv_fiscalyear.
            <ls_journalentry_key>-accountingdocument = lv_accountingdocument.
            <ls_journalentry_key>-msg                = lo_msg.
          ELSE.
            mt_journalentry_keys = VALUE #( BASE mt_journalentry_keys
                                            ( tmp                = VALUE #(
                                                  companycode        = ls_key-%param-companycode
                                                  fiscalyear         = c_key_tmp-fiscalyear
                                                  accountingdocument = |{ c_key_tmp-accountingdocument }{ lv_tabix }| )
                                              companycode        = lv_companycode
                                              fiscalyear         = lv_fiscalyear
                                              accountingdocument = lv_accountingdocument
                                              msg                = lo_msg ) ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD acc_document_check.
    CLEAR et_return.

    TRY.
        zcl_t2_bapi_acc_document=>bapi_acc_document_check( EXPORTING contractheader    = is_contractheader
                                                                     customercpd       = is_customercpd
                                                                     documentheader    = is_documentheader
                                                                     _dest_            = 'NONE'
                                                           CHANGING  accountgl         = ct_accountgl
                                                                     accountpayable    = ct_accountpayable
                                                                     accountreceivable = ct_accountreceivable
                                                                     accounttax        = ct_accounttax
                                                                     accountwt         = ct_accountwt
                                                                     contractitem      = ct_contractitem
                                                                     criteria          = ct_criteria
                                                                     currencyamount    = ct_currencyamount
                                                                     extension1        = ct_extension1
                                                                     extension2        = ct_extension2
                                                                     paymentcard       = ct_paymentcard
                                                                     realestate        = ct_realestate
                                                                     return            = et_return
                                                                     valuefield        = ct_valuefield ).
      CATCH cx_aco_application_exception
            cx_aco_communication_failure
            cx_aco_system_failure INTO FINAL(lx_error).
        et_return = VALUE #( ( type    = c_msgty-error
                               message = lx_error->get_longtext( ) ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD acc_document_post.
    DATA lt_return_check TYPE zcl_t2_bapi_acc_document=>_bapiret2.
    DATA lt_return_post  TYPE zcl_t2_bapi_acc_document=>_bapiret2.

    CLEAR: et_return,
           ev_error.
    CLEAR: ev_obj_type,
           ev_obj_key,
           ev_obj_sys,
           ev_companycode,
           ev_accountingdocument,
           ev_fiscalyear.

    IF     iv_postdocument IS INITIAL
       AND iv_testrun      IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_testrun IS NOT INITIAL.
      acc_document_check( EXPORTING is_documentheader    = is_documentheader
                                    is_customercpd       = is_customercpd
                                    is_contractheader    = is_contractheader
                          IMPORTING et_return            = lt_return_check
                          CHANGING  ct_accountgl         = ct_accountgl
                                    ct_accountreceivable = ct_accountreceivable
                                    ct_accountpayable    = ct_accountpayable
                                    ct_accounttax        = ct_accounttax
                                    ct_currencyamount    = ct_currencyamount
                                    ct_criteria          = ct_criteria
                                    ct_valuefield        = ct_valuefield
                                    ct_extension1        = ct_extension1
                                    ct_paymentcard       = ct_paymentcard
                                    ct_contractitem      = ct_contractitem
                                    ct_extension2        = ct_extension2
                                    ct_realestate        = ct_realestate
                                    ct_accountwt         = ct_accountwt ).

      LOOP AT lt_return_check TRANSPORTING NO FIELDS WHERE type CA c_any_error.
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        ev_error = abap_true.
      ENDIF.

      et_return = lt_return_check.
    ENDIF.

    IF ev_error IS NOT INITIAL.
      RETURN.
    ENDIF.

    TRY.
        zcl_t2_bapi_acc_document=>bapi_acc_document_post( EXPORTING contractheader    = is_contractheader
                                                                    customercpd       = is_customercpd
                                                                    documentheader    = is_documentheader
                                                                    _dest_            = space
                                                          IMPORTING obj_key           = ev_obj_key
                                                                    obj_sys           = ev_obj_sys
                                                                    obj_type          = ev_obj_type
                                                          CHANGING  accountgl         = ct_accountgl
                                                                    accountpayable    = ct_accountpayable
                                                                    accountreceivable = ct_accountreceivable
                                                                    accounttax        = ct_accounttax
                                                                    accountwt         = ct_accountwt
                                                                    contractitem      = ct_contractitem
                                                                    criteria          = ct_criteria
                                                                    currencyamount    = ct_currencyamount
                                                                    extension1        = ct_extension1
                                                                    extension2        = ct_extension2
                                                                    paymentcard       = ct_paymentcard
                                                                    realestate        = ct_realestate
                                                                    return            = lt_return_post
                                                                    valuefield        = ct_valuefield ).

        LOOP AT lt_return_post TRANSPORTING NO FIELDS WHERE type CA c_any_error.
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          ev_error = abap_true.
        ENDIF.

        et_return             = lt_return_post.
        ev_accountingdocument = ev_obj_key+0(10).
        ev_companycode        = ev_obj_key+10(4).
        ev_fiscalyear         = ev_obj_key+14(4).
      CATCH cx_aco_application_exception
            cx_aco_communication_failure
            cx_aco_system_failure INTO FINAL(lx_error).
        et_return = VALUE #( ( type    = c_msgty-error
                               message = lx_error->get_longtext( ) ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD clear_api_keys.
    ro_instance = me.

    CLEAR mt_keys_post.
    CLEAR mt_keys_reverse.
    CLEAR mt_journalentry_keys.
    CLEAR mv_action.
  ENDMETHOD.

  METHOD clear_document_from_api.
    ro_instance = me.

    CLEAR ms_documentheader.
    CLEAR mt_extension2.

    CLEAR mt_accountgl.
    CLEAR mt_currencyamount.
    CLEAR mt_criteria.

    CLEAR ms_customercpd.
    CLEAR mt_accountpayable.
    CLEAR mt_accountreceivable.
    CLEAR mt_accounttax.
    CLEAR mt_accountwt.

    CLEAR mt_customer.
    CLEAR mt_supplier.
    CLEAR mt_country.
    CLEAR mt_currency.
    CLEAR mt_companycode.
    CLEAR mt_unitofmeasure.
    CLEAR mt_product.

    CLEAR mv_itemno_acc.
  ENDMETHOD.

  METHOD _check_customer_supplier.
    CLEAR: es_customer,
           es_supplier.

    IF     iv_customer IS INITIAL
       AND iv_supplier IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_customer IS SUPPLIED.
      TRY.
          es_customer = mt_customer[ customer = iv_customer ].
        CATCH cx_sy_itab_line_not_found.
          SELECT SINGLE FROM i_customer WITH
            PRIVILEGED ACCESS
            FIELDS customer,
                   isonetimeaccount
            WHERE customer = @iv_customer
            INTO CORRESPONDING FIELDS OF @es_customer.
          IF sy-subrc IS INITIAL.
            INSERT es_customer INTO TABLE mt_customer.
          ENDIF.
      ENDTRY.
    ELSEIF iv_supplier IS SUPPLIED.
      TRY.
          es_supplier = mt_supplier[ supplier = iv_supplier ].
        CATCH cx_sy_itab_line_not_found.
          SELECT SINGLE FROM i_supplier WITH
            PRIVILEGED ACCESS
            FIELDS supplier,
                   isonetimeaccount
            WHERE supplier = @iv_supplier
            INTO CORRESPONDING FIELDS OF @es_supplier.
          IF sy-subrc IS INITIAL.
            INSERT es_supplier INTO TABLE mt_supplier.
          ENDIF.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_accountgl.
    " TODO: parameter CT_ACCOUNTTAX is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_VALUEFIELD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_EXTENSION1 is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_PAYMENTCARD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_CONTRACTITEM is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_EXTENSION2 is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_REALESTATE is never used or assigned (ABAP cleaner)

    DATA ls_accountgl TYPE zcl_t2_bapi_acc_document=>bapiacgl09.

    IF is_accountgl_api IS SUPPLIED.
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accountgl-itemno_acc    = COND #( WHEN is_accountgl_api-referencedocumentitem IS NOT INITIAL
                                           THEN is_accountgl_api-referencedocumentitem
                                           ELSE mv_itemno_acc ).
      " General Ledger Account
      ls_accountgl-gl_account    = is_accountgl_api-glaccount.
      " Item Text
      ls_accountgl-item_text     = is_accountgl_api-documentitemtext.
      " Indicator for statistical line items
      " LS_ACCOUNTGL-STAT_CON         =
      " Logical Transaction
      " LS_ACCOUNTGL-LOG_PROC         =
      " Accounting Document Number
      " LS_ACCOUNTGL-AC_DOC_NO        =
      " Business Partner Reference Key
      ls_accountgl-ref_key_1     = is_accountgl_api-reference1idbybusinesspartner.
      " Business Partner Reference Key
      ls_accountgl-ref_key_2     = is_accountgl_api-reference2idbybusinesspartner.
      " Reference Key for Line Item
      ls_accountgl-ref_key_3     = is_accountgl_api-reference3idbybusinesspartner.
      " Transaction Key
      " LS_ACCOUNTGL-ACCT_KEY         =
      " Account Type
      " LS_ACCOUNTGL-ACCT_TYPE        =
      " Document Type
      ls_accountgl-doc_type      = is_documentheader_api-accountingdocumenttype.
      " Company Code
      ls_accountgl-comp_code     = is_documentheader_api-companycode.
      " Business Area
      " LS_ACCOUNTGL-BUS_AREA         =
      " Functional Area
      " LS_ACCOUNTGL-FUNC_AREA        =
      " Plant
      ls_accountgl-plant         = is_accountgl_api-plant.
      " Fiscal Period
      " LS_ACCOUNTGL-FIS_PERIOD       =
      " Fiscal Year
      " LS_ACCOUNTGL-FISC_YEAR        =
      " Posting Date in the Document
      ls_accountgl-pstng_date    = is_documentheader_api-postingdate.
      " Value Date
      ls_accountgl-value_date    = is_accountgl_api-valuedate.
      " Financial Management Area
      " LS_ACCOUNTGL-FM_AREA          =
      " Customer Number
      ls_accountgl-customer      = is_accountgl_api-customer.
      " Indicator: Line Item Not Liable to Cash Discount?
      " LS_ACCOUNTGL-CSHDIS_IND       =
      " Account Number of Vendor or Creditor
      " LS_ACCOUNTGL-VENDOR_NO        =
      " Assignment Number
      ls_accountgl-alloc_nmbr    = is_accountgl_api-assignmentreference.
      " Tax on sales/purchases code
      ls_accountgl-tax_code      = is_accountgl_api-taxcode.
      " Tax Jurisdiction
      " LS_ACCOUNTGL-TAXJURCODE       =
      " Technical Key of External Object
      " LS_ACCOUNTGL-EXT_OBJECT_ID    =
      " Business Scenario in Controlling for Logistical Objects
      " LS_ACCOUNTGL-BUS_SCENARIO     =
      " Cost Object
      " LS_ACCOUNTGL-COSTOBJECT       =
      " Cost Center
      ls_accountgl-costcenter    = is_accountgl_api-costcenter.
      " Activity Type
      " LS_ACCOUNTGL-ACTTYPE          =
      " Profit Center
      ls_accountgl-profit_ctr    = is_accountgl_api-profitcenter.
      " Partner Profit Center
      " LS_ACCOUNTGL-PART_PRCTR       =
      " Network Number for Account Assignment
      ls_accountgl-network       = is_accountgl_api-projectnetwork.
      " Work Breakdown Structure Element (WBS Element)
      ls_accountgl-wbs_element   = is_accountgl_api-wbselement.
      " Order Number
      ls_accountgl-orderid       = is_accountgl_api-orderid.
      " Order Item Number
      " LS_ACCOUNTGL-ORDER_ITNO       =
      " Routing number of operations in the order
      " LS_ACCOUNTGL-ROUTING_NO       =
      " Operation/Activity Number
      " LS_ACCOUNTGL-ACTIVITY         =
      " Condition type
      " LS_ACCOUNTGL-COND_TYPE        =
      " Condition Counter
      " LS_ACCOUNTGL-COND_COUNT       =
      " Level Number
      " LS_ACCOUNTGL-COND_ST_NO       =
      " Fund
      " LS_ACCOUNTGL-FUND             =
      " Funds Center
      " LS_ACCOUNTGL-FUNDS_CTR        =
      " Commitment Item
      " LS_ACCOUNTGL-CMMT_ITEM        =
      " Business Process
      " LS_ACCOUNTGL-CO_BUSPROC       =
      " Main Asset Number
      " LS_ACCOUNTGL-ASSET_NO         =
      " Asset Subnumber
      " LS_ACCOUNTGL-SUB_NUMBER       =
      " Billing Type
      " LS_ACCOUNTGL-BILL_TYPE        =
      " Sales Order Number
      ls_accountgl-sales_ord     = is_accountgl_api-salesorder.
      " Item Number in Sales Order
      ls_accountgl-s_ord_item    = is_accountgl_api-salesorderitem.
      " Distribution Channel
      ls_accountgl-distr_chan    = is_accountgl_api-distributionchannel.
      " Division
      ls_accountgl-division      = is_accountgl_api-division.
      " Sales Organization
      ls_accountgl-salesorg      = is_accountgl_api-salesorganization.
      " Sales Group
      " LS_ACCOUNTGL-SALES_GRP        =
      " Sales Office
      " LS_ACCOUNTGL-SALES_OFF        =
      " Sold-to party
      " LS_ACCOUNTGL-SOLD_TO          =
      " Indicator: subsequent debit/credit
      " LS_ACCOUNTGL-DE_CRE_IND       =
      " Partner profit center for elimination of internal business
      " LS_ACCOUNTGL-P_EL_PRCTR       =
      " Indicator: Update quantity in RW
      " LS_ACCOUNTGL-XMFRW            =
      " Quantity
      ls_accountgl-quantity      = is_accountgl_api-quantityinentryunit.
      " Base Unit of Measure
      ls_accountgl-base_uom      = is_accountgl_api-baseunit.
      " Base unit of measure in ISO code
      ls_accountgl-base_uom_iso  = _get_unitofmeasure_to_iso( is_accountgl_api-baseunit ).
      " Actual Invoiced Quantity
      " LS_ACCOUNTGL-INV_QTY          =
      " Billing quantity in stockkeeping unit
      " LS_ACCOUNTGL-INV_QTY_SU       =
      " Sales unit
      " LS_ACCOUNTGL-SALES_UNIT       =
      " Sales unit in ISO code
      " LS_ACCOUNTGL-SALES_UNIT_ISO   =
      " Quantity in order price quantity unit
      " LS_ACCOUNTGL-PO_PR_QNT        =
      " Order price unit (purchasing)
      " LS_ACCOUNTGL-PO_PR_UOM        =
      " Purchase order price unit in ISO code
      " LS_ACCOUNTGL-PO_PR_UOM_ISO    =
      " Quantity in Unit of Entry
      " LS_ACCOUNTGL-ENTRY_QNT        =
      " Unit of Entry
      " LS_ACCOUNTGL-ENTRY_UOM        =
      " Unit of entry in ISO code
      " LS_ACCOUNTGL-ENTRY_UOM_ISO    =
      " Volume
      " LS_ACCOUNTGL-VOLUME           =
      " Volume unit
      " LS_ACCOUNTGL-VOLUMEUNIT       =
      " Volume unit in ISO code
      " LS_ACCOUNTGL-VOLUMEUNIT_ISO   =
      " Gross Weight
      " LS_ACCOUNTGL-GROSS_WT         =
      " Net weight
      " LS_ACCOUNTGL-NET_WEIGHT       =
      " Weight unit
      " LS_ACCOUNTGL-UNIT_OF_WT       =
      " Unit of weight in ISO code
      " LS_ACCOUNTGL-UNIT_OF_WT_ISO   =
      " Item category in purchasing document
      " LS_ACCOUNTGL-ITEM_CAT         =
      " Material Number
      " LS_ACCOUNTGL-MATERIAL         =
      " Material Number Long
      ls_accountgl-material_long = is_accountgl_api-material.
      " Material Type
      ls_accountgl-matl_type     = _get_product_type( is_accountgl_api-material ).
      " Movement Indicator
      " LS_ACCOUNTGL-MVT_IND          =
      " Revaluation
      " LS_ACCOUNTGL-REVAL_IND        =
      " Origin Group as Subdivision of Cost Element
      " LS_ACCOUNTGL-ORIG_GROUP       =
      " Material-related origin
      " LS_ACCOUNTGL-ORIG_MAT         =
      " Sequential number of account assignment
      " LS_ACCOUNTGL-SERIAL_NO        =
      " Partner Account Number
      " LS_ACCOUNTGL-PART_ACCT        =
      " Trading Partner's Business Area
      " LS_ACCOUNTGL-TR_PART_BA       =
      " Company ID of Trading Partner
      ls_accountgl-trade_id      = is_accountgl_api-tradingpartner.
      " Valuation Area
      " LS_ACCOUNTGL-VAL_AREA         =
      " Valuation Type
      " LS_ACCOUNTGL-VAL_TYPE         =
      " Reference Date
      " LS_ACCOUNTGL-ASVAL_DATE       =
      " Purchasing Document Number
      " LS_ACCOUNTGL-PO_NUMBER        =
      " Item Number of Purchasing Document
      " LS_ACCOUNTGL-PO_ITEM          =
      " Item number of the SD document
      " LS_ACCOUNTGL-ITM_NUMBER       =
      " Condition Category (Examples: Tax, Freight, Price, Cost)
      " LS_ACCOUNTGL-COND_CATEGORY    =
      " Functional Area
      " LS_ACCOUNTGL-FUNC_AREA_LONG   =
      " Commitment Item
      " LS_ACCOUNTGL-CMMT_ITEM_LONG   =
      " Grant
      " LS_ACCOUNTGL-GRANT_NBR        =
      " Transaction Type
      " LS_ACCOUNTGL-CS_TRANS_T       =
      " Funded Program
      " LS_ACCOUNTGL-MEASURE          =
      " Segment for Segmental Reporting
      ls_accountgl-segment       = is_accountgl_api-segment.
      " Partner Segment for Segmental Reporting
      " LS_ACCOUNTGL-PARTNER_SEGMENT  =
      " Document Number for Earmarked Funds
      " LS_ACCOUNTGL-RES_DOC          =
      " Earmarked Funds: Document Item
      " LS_ACCOUNTGL-RES_ITEM         =
      " Billing Period of Performance Start Date
      " LS_ACCOUNTGL-BILLING_PERIOD_START_DATE =
      " Billing Period of Performance End Date
      " LS_ACCOUNTGL-BILLING_PERIOD_END_DATE   =
      " PPA Exclude Indicator
      " LS_ACCOUNTGL-PPA_EX_IND                =
      " PPA Fast Pay Indicator
      " LS_ACCOUNTGL-FASTPAY                   =
      " Partner Grant
      " LS_ACCOUNTGL-PARTNER_GRANT_NBR         =
      " FM: Budget Period
      " LS_ACCOUNTGL-BUDGET_PERIOD             =
      " FM: Partner Budget Period
      " LS_ACCOUNTGL-PARTNER_BUDGET_PERIOD     =
      " Partner Fund
      " LS_ACCOUNTGL-PARTNER_FUND              =
      " Document item number referring to tax document.
      " LS_ACCOUNTGL-ITEMNO_TAX                =
      " Payment Type for Grantor
      " LS_ACCOUNTGL-PAYMENT_TYPE              =
      " Expense Type for Grantor
      " LS_ACCOUNTGL-EXPENSE_TYPE              =
      " Grantor Program Profile
      " LS_ACCOUNTGL-PROGRAM_PROFILE           =
      " Business place
      ls_accountgl-businessplace = is_accountgl_api-businessplace.

      _convert_structure_conversion( CHANGING cv_data = ls_accountgl ).

      APPEND ls_accountgl TO ct_accountgl.

      IF is_accountgl_api-soldmaterial IS NOT INITIAL.
        APPEND VALUE #( itemno_acc = COND #( WHEN is_accountgl_api-referencedocumentitem IS NOT INITIAL
                                             THEN is_accountgl_api-referencedocumentitem
                                             ELSE mv_itemno_acc )
                        fieldname  = 'ARTNR'
                        character  = is_accountgl_api-soldmaterial ) TO ct_criteria.
      ENDIF.

      _fill_currencyamount( EXPORTING is_documentheader_api = is_documentheader_api
                                      is_accountgl_api      = is_accountgl_api
                            CHANGING  ct_currencyamount     = ct_currencyamount ).

      " mo_abap_config_inst->get_range_value( EXPORTING iv_identifier = 'TAX_EXEMPT'
      "                                       IMPORTING et_range      = lt_tax_exempt ).
      "
      " IF     ls_accountgl-tax_code IN lt_tax_exempt
      "    AND lt_tax_exempt         IS NOT INITIAL
      "    AND mv_set_tax_exempt     IS INITIAL.
      "  DATA(lt_accounttax_exem) = VALUE zcl_t2_bapi_acc_document=>_bapiactx09( ).
      "  DATA(lt_currencyamount_exem) = VALUE zcl_t2_bapi_acc_document=>_bapiaccr09( ).
      "
      "  _fill_accounttax( EXPORTING is_documentheader_api = is_documentheader_api
      "                              is_accountgl_api      = CORRESPONDING #( is_accountgl_api
      "                                                         EXCEPT GLAccount
      "                                                                AmountInCompanyCodeCurrency
      "                                                                AmountInFreeDefinedCurrency1
      "                                                                AmountInGroupCurrency
      "                                                                AmountInTransactionCurrency )
      "                    CHANGING  ct_accounttax         = lt_accounttax_exem
      "                              ct_currencyamount     = lt_currencyamount_exem ).
      "
      "  LOOP AT lt_accounttax_exem INTO DATA(ls_accounttax_exem).
      "    APPEND CORRESPONDING #( ls_accounttax_exem ) TO ct_accounttax.
      "  ENDLOOP.
      "
      "  LOOP AT lt_currencyamount_exem INTO DATA(ls_currencyamount_exem).
      "    APPEND CORRESPONDING #( ls_currencyamount_exem ) TO ct_currencyamount.
      "  ENDLOOP.
      "
      "  mv_set_tax_exempt = abap_true.
      " ENDIF.
    ELSEIF is_accountgl IS SUPPLIED.
      mv_itemno_acc += 1.

      ls_accountgl = CORRESPONDING #( is_accountgl ).

      _convert_structure_conversion( CHANGING cv_data = ls_accountgl ).

      APPEND ls_accountgl TO ct_accountgl.

      _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                      is_currencyamount = is_currencyamount
                            CHANGING  ct_currencyamount = ct_currencyamount ).
    ENDIF.
  ENDMETHOD.

  METHOD _fill_accountpayable.
    " TODO: parameter CT_ACCOUNTTAX is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_CRITERIA is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_VALUEFIELD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_EXTENSION1 is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_PAYMENTCARD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_CONTRACTITEM is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_REALESTATE is never used or assigned (ABAP cleaner)

    DATA ls_accountpayable TYPE zcl_t2_bapi_acc_document=>bapiacap09.

    DATA(lv_supplier) = COND i_supplier-supplier( WHEN is_accountpayable_api-creditor IS NOT INITIAL
                                                  THEN |{ is_accountpayable_api-creditor ALPHA = IN }|
                                                  ELSE |{ is_accountpayable-vendor_no ALPHA = IN }| ).

    _check_customer_supplier( EXPORTING iv_supplier = lv_supplier
                              IMPORTING es_supplier = DATA(ls_supplier) ).
    IF ls_supplier-supplier IS INITIAL.
      IF is_accountpayable_api IS SUPPLIED.
        ls_supplier-supplier = |{ is_accountpayable_api-creditor ALPHA = IN }|.
      ELSEIF is_accountpayable IS SUPPLIED.
        ls_supplier-supplier = |{ is_accountpayable-vendor_no ALPHA = IN }|.
      ENDIF.
    ENDIF.

    IF is_accountpayable_api IS SUPPLIED.
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accountpayable-itemno_acc         = COND #( WHEN is_accountpayable_api-referencedocumentitem IS NOT INITIAL
                                                     THEN is_accountpayable_api-referencedocumentitem
                                                     ELSE mv_itemno_acc ).
      " Account Number of Vendor or Creditor
      ls_accountpayable-vendor_no          = ls_supplier-supplier.
      " General Ledger Account
      ls_accountpayable-gl_account         = is_accountpayable_api-altvrecnclnaccts.
      " Business Partner Reference Key
      ls_accountpayable-ref_key_1          = is_accountpayable_api-reference1idbybusinesspartner.
      " Business Partner Reference Key
      ls_accountpayable-ref_key_2          = is_accountpayable_api-reference2idbybusinesspartner.
      " Reference Key for Line Item
      ls_accountpayable-ref_key_3          = is_accountpayable_api-reference3idbybusinesspartner.
      " Company Code
      ls_accountpayable-comp_code          = is_documentheader_api-companycode.
      " Business Area
      " LS_ACCOUNTPAYABLE-BUS_AREA        =
      " Terms of Payment Key
      ls_accountpayable-pmnttrms           = COND #( WHEN is_accountpayable_api-paymentterms IS NOT INITIAL
                                                     THEN is_accountpayable_api-paymentterms
                                                     ELSE _get_customer_supplier_zterm(
                                                              iv_supplier    = ls_supplier-supplier
                                                              iv_companycode = is_documentheader_api-companycode ) ).
      " Baseline Date For Due Date Calculation
      ls_accountpayable-bline_date         = is_accountpayable_api-duecalculationbasedate.
      " Days for first cash discount
*     LS_ACCOUNTPAYABLE-dsct_days1      =
      " Days for second cash discount
      " LS_ACCOUNTPAYABLE-DSCT_DAYS2      =
      " Deadline for net conditions
      " LS_ACCOUNTPAYABLE-NETTERMS        =
      " Percentage for First Cash Discount
      " LS_ACCOUNTPAYABLE-DSCT_PCT1       =
      " Percentage for Second Cash Discount
      " LS_ACCOUNTPAYABLE-DSCT_PCT2       =
      " Payment method
      ls_accountpayable-pymt_meth          = is_accountpayable_api-paymentmethod.
      " Payment Method Supplement
      ls_accountpayable-pmtmthsupl         = is_accountpayable_api-paymentmethodsupplement.
      " Payment block key
      ls_accountpayable-pmnt_block         = is_accountpayable_api-paymentblockingreason.
      " State Central Bank Indicator
      " LS_ACCOUNTPAYABLE-SCBANK_IND      =
      " Supplying Country
      " LS_ACCOUNTPAYABLE-SUPCOUNTRY      =
      " Supplier country ISO code
      " LS_ACCOUNTPAYABLE-SUPCOUNTRY_ISO  =
      " Service Indicator (Foreign Payment)
      " LS_ACCOUNTPAYABLE-BLLSRV_IND      =
      " Assignment Number
      ls_accountpayable-alloc_nmbr         = is_accountpayable_api-assignmentreference.
      " Item Text
      ls_accountpayable-item_text          = is_accountpayable_api-documentitemtext.
      " ISR Subscriber Number
      " LS_ACCOUNTPAYABLE-PO_SUB_NO       =
      " ISR Check Digit
      " LS_ACCOUNTPAYABLE-PO_CHECKDG      =
      " ISR Reference Number
      " LS_ACCOUNTPAYABLE-PO_REF_NO       =
      " Withholding tax code
      " LS_ACCOUNTPAYABLE-W_TAX_CODE      =
      " Business Place
      ls_accountpayable-businessplace      = is_accountpayable_api-businessplace.
      " Section Code
      " LS_ACCOUNTPAYABLE-SECTIONCODE     =
      " Instruction Key 1
      " LS_ACCOUNTPAYABLE-INSTR1          =
      " Instruction Key 2
      " LS_ACCOUNTPAYABLE-INSTR2          =
      " Instruction Key 3
      " LS_ACCOUNTPAYABLE-INSTR3          =
      " Instruction Key 4
      " LS_ACCOUNTPAYABLE-INSTR4          =
      " Account number of the branch
      " LS_ACCOUNTPAYABLE-BRANCH          =
      " Currency for automatic payment
      " LS_ACCOUNTPAYABLE-PYMT_CUR        =
      " Amount in Payment Currency
      " LS_ACCOUNTPAYABLE-PYMT_AMT        =
      " ISO code currency
      " LS_ACCOUNTPAYABLE-PYMT_CUR_ISO    =
      " Special G/L Indicator
      ls_accountpayable-sp_gl_ind          = is_accountpayable_api-specialglcode.
      " Tax on sales/purchases code
      ls_accountpayable-tax_code           = is_accountpayable_api-taxcode.
      " Date Relevant for Determining the Tax Rate
      " LS_ACCOUNTPAYABLE-TAX_DATE        =
      " Tax Jurisdiction
      " LS_ACCOUNTPAYABLE-TAXJURCODE      =
      " Alternative payee
      ls_accountpayable-alt_payee          = is_accountpayable_api-alternativepayee.
      " Bank type of alternative payer
      " LS_ACCOUNTPAYABLE-ALT_PAYEE_BANK  =
      " Partner Bank Type
      ls_accountpayable-partner_bk         = is_accountpayable_api-bpbankaccountinternalid.
      " Short Key for a House Bank
*     LS_ACCOUNTPAYABLE-bank_id         =
      " Com. Interface: Business Partner GUID
      " LS_ACCOUNTPAYABLE-PARTNER_GUID    =
      " Profit Center
      ls_accountpayable-profit_ctr         = is_accountpayable_api-profitcenter.
      " Fund
      " LS_ACCOUNTPAYABLE-FUND            =
      " Grant
      " LS_ACCOUNTPAYABLE-GRANT_NBR       =
      " Funded Program
      " LS_ACCOUNTPAYABLE-MEASURE         =
      " ID for Account Details
      " LS_ACCOUNTPAYABLE-HOUSEBANKACCTID =
      " FM: Budget Period
      " LS_ACCOUNTPAYABLE-BUDGET_PERIOD   =
      " PPA Exclude Indicator
      " LS_ACCOUNTPAYABLE-PPA_EX_IND      =
      " Branch Code
      ls_accountpayable-part_businessplace = is_accountpayable_api-branchcode.

      " Set Extension 2
      IF is_accountpayable_api-creditcontrolarea IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'CREDITCONTROLAREA'
                                   valuepart1 = 'ACCOUNTPAYABLE'
                                   valuepart2 = ls_accountpayable-itemno_acc
                                   valuepart3 = is_accountpayable_api-creditcontrolarea
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountpayable_api-invoicereference IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'INVOICEREFERENCE'
                                   valuepart1 = 'ACCOUNTPAYABLE'
                                   valuepart2 = ls_accountpayable-itemno_acc
                                   valuepart3 = is_accountpayable_api-invoicereference
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountpayable_api-invoicereferencefiscalyear IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'INVOICEREFERENCEFISCALYEAR'
                                   valuepart1 = 'ACCOUNTPAYABLE'
                                   valuepart2 = ls_accountpayable-itemno_acc
                                   valuepart3 = is_accountpayable_api-invoicereferencefiscalyear
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountpayable_api-purchasingdocument IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'PURCHASINGDOCUMENT'
                                   valuepart1 = 'ACCOUNTPAYABLE'
                                   valuepart2 = ls_accountpayable-itemno_acc
                                   valuepart3 = is_accountpayable_api-purchasingdocument
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountpayable_api-purchasingdocumentitem IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'PURCHASINGDOCUMENTITEM'
                                   valuepart1 = 'ACCOUNTPAYABLE'
                                   valuepart2 = ls_accountpayable-itemno_acc
                                   valuepart3 = is_accountpayable_api-purchasingdocumentitem
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      _convert_structure_conversion( CHANGING cv_data = ls_accountpayable ).

      APPEND ls_accountpayable TO ct_accountpayable.

      IF     (    ls_supplier-isonetimeaccount                  IS NOT INITIAL
               OR is_accountpayable_api-payeeisalternativepayee IS NOT INITIAL )
         AND is_accountpayable_api-name IS NOT INITIAL.
        _fill_vendor_customer_onetime( EXPORTING is_accountpayable_api = is_accountpayable_api
                                       CHANGING  cs_customercpd        = cs_customercpd ).
      ENDIF.

      _fill_currencyamount( EXPORTING is_documentheader_api = is_documentheader_api
                                      is_accountpayable_api = is_accountpayable_api
                            CHANGING  ct_currencyamount     = ct_currencyamount ).

      " Fill Withholding Tax Item
      LOOP AT it_journalentry_whtitem_api INTO FINAL(ls_journalentry_whtitem)
           WHERE referencedocumentitem = ls_accountpayable-itemno_acc.
        _fill_accountwt( EXPORTING is_withholdingtax_api = ls_journalentry_whtitem
                         CHANGING  ct_accountwt          = ct_accountwt ).
      ENDLOOP.
      IF ct_accountwt IS INITIAL.
        APPEND INITIAL LINE TO ct_accountwt ASSIGNING FIELD-SYMBOL(<ls_accountwt>).
        <ls_accountwt>-itemno_acc = COND #( WHEN is_accountpayable_api-referencedocumentitem IS NOT INITIAL
                                            THEN is_accountpayable_api-referencedocumentitem
                                            ELSE mv_itemno_acc ).
        <ls_accountwt>-wt_type    = '01'.
      ENDIF.
    ELSEIF is_accountpayable IS SUPPLIED.
      mv_itemno_acc += 1.

      ls_accountpayable            = CORRESPONDING #( is_accountpayable ).
      " Accounting Document Line Item Number
      ls_accountpayable-itemno_acc = mv_itemno_acc.
      " Account Number of Vendor or Creditor
      ls_accountpayable-vendor_no  = ls_supplier-supplier.

      _convert_structure_conversion( CHANGING cv_data = ls_accountpayable ).

      IF ls_accountpayable-tax_code IS NOT INITIAL.
        _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                        is_currencyamount = is_currencyamount
                              CHANGING  ct_currencyamount = ct_currencyamount ).
      ELSE.
        _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                        is_currencyamount = is_currencyamount
                              CHANGING  ct_currencyamount = ct_currencyamount ).
      ENDIF.

      APPEND ls_accountpayable TO ct_accountpayable.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_accountreceivable.
    " TODO: parameter CT_ACCOUNTTAX is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_CRITERIA is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_VALUEFIELD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_EXTENSION1 is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_PAYMENTCARD is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_CONTRACTITEM is never used or assigned (ABAP cleaner)
    " TODO: parameter CT_REALESTATE is never used or assigned (ABAP cleaner)

    DATA ls_accountreceivable TYPE zcl_t2_bapi_acc_document=>bapiacar09.

    DATA(lv_customer) = COND i_customer-customer( WHEN is_accountreceivable_api-debtor IS NOT INITIAL
                                                  THEN |{ is_accountreceivable_api-debtor ALPHA = IN }|
                                                  ELSE |{ is_accountreceivable-customer ALPHA = IN }| ).

    _check_customer_supplier( EXPORTING iv_customer = lv_customer
                              IMPORTING es_customer = DATA(ls_customer) ).
    IF ls_customer-customer IS INITIAL.
      IF is_accountreceivable_api IS SUPPLIED.
        ls_customer-customer = |{ is_accountreceivable_api-debtor ALPHA = IN }|.
      ELSEIF is_accountreceivable IS SUPPLIED.
        ls_customer-customer = |{ is_accountreceivable-customer ALPHA = IN }|.
      ENDIF.
    ENDIF.

    IF is_accountreceivable_api IS SUPPLIED.
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accountreceivable-itemno_acc         = COND #( WHEN is_accountreceivable_api-referencedocumentitem IS NOT INITIAL
                                                        THEN is_accountreceivable_api-referencedocumentitem
                                                        ELSE mv_itemno_acc ).
      " Account Number of Vendor or Creditor
      ls_accountreceivable-customer           = ls_customer-customer.
      " General Ledger Account
      ls_accountreceivable-gl_account         = is_accountreceivable_api-altvrecnclnaccts.
      " Business Partner Reference Key
      ls_accountreceivable-ref_key_1          = is_accountreceivable_api-reference1idbybusinesspartner.
      " Business Partner Reference Key
      ls_accountreceivable-ref_key_2          = is_accountreceivable_api-reference2idbybusinesspartner.
      " Reference Key for Line Item
      ls_accountreceivable-ref_key_3          = is_accountreceivable_api-reference3idbybusinesspartner.
      " Company Code
      ls_accountreceivable-comp_code          = is_documentheader_api-companycode.
      " Business Area
      " LS_ACCOUNTRECEIVABLE-BUS_AREA        =
      " Terms of Payment Key
      ls_accountreceivable-pmnttrms           = COND #( WHEN is_accountreceivable_api-paymentterms IS NOT INITIAL
                                                        THEN is_accountreceivable_api-paymentterms
                                                        ELSE _get_customer_supplier_zterm(
                                                                 iv_customer    = ls_customer-customer
                                                                 iv_companycode = is_documentheader_api-companycode ) ).
      " Baseline Date For Due Date Calculation
      ls_accountreceivable-bline_date         = is_accountreceivable_api-duecalculationbasedate.
      " Days for first cash discount
      " LS_ACCOUNTRECEIVABLE-dsct_days1      =
      " Days for second cash discount
      " LS_ACCOUNTRECEIVABLE-DSCT_DAYS2      =
      " Deadline for net conditions
      " LS_ACCOUNTRECEIVABLE-NETTERMS        =
      " Percentage for First Cash Discount
      " LS_ACCOUNTRECEIVABLE-DSCT_PCT1       =
      " Percentage for Second Cash Discount
      " LS_ACCOUNTRECEIVABLE-DSCT_PCT2       =
      " Payment method
      ls_accountreceivable-pymt_meth          = is_accountreceivable_api-paymentmethod.
      " Payment Method Supplement
      ls_accountreceivable-pmtmthsupl         = is_accountreceivable_api-paymentmethodsupplement.
      " Payment Reference
      " LS_ACCOUNTRECEIVABLE-PAYMT_REF       =
      " Dunning keys
      " LS_ACCOUNTRECEIVABLE-DUNN_KEY        =
      " Dunning block
      " LS_ACCOUNTRECEIVABLE-DUNN_BLOCK      =
      " Payment block key
      ls_accountreceivable-pmnt_block         = is_accountreceivable_api-paymentblockingreason.
      " VAT Registration Number
      " LS_ACCOUNTRECEIVABLE-VAT_REG_NO      =
      " Assignment Number
      ls_accountreceivable-alloc_nmbr         = is_accountreceivable_api-assignmentreference.
      " Item Text
      ls_accountreceivable-item_text          = is_accountreceivable_api-documentitemtext.
      " Partner Bank Type
      " LS_ACCOUNTRECEIVABLE-PARTNER_BK      =.
      " State Central Bank Indicator
      " LS_ACCOUNTRECEIVABLE-SCBANK_IND      =
      " Business Place
      ls_accountreceivable-businessplace      = is_accountreceivable_api-businessplace.
      " Section Code
      " LS_ACCOUNTRECEIVABLE-SECTIONCODE     =
      " Account number of the branch
      " LS_ACCOUNTRECEIVABLE-BRANCH          =
      " Currency for automatic payment
      " LS_ACCOUNTRECEIVABLE-PYMT_CUR        =
      " ISO code currency
      " LS_ACCOUNTRECEIVABLE-PYMT_CUR_ISO    =
      " Amount in Payment Currency
      " LS_ACCOUNTRECEIVABLE-PYMT_AMT        =
      " Credit control area
      " LS_ACCOUNTRECEIVABLE-C_CTR_AREA      =
      " Short Key for a House Bank
      " LS_ACCOUNTRECEIVABLE-bank_id         =
      " Supplying Country
      " LS_ACCOUNTRECEIVABLE-SUPCOUNTRY      =
      " Supplier country ISO code
      " LS_ACCOUNTRECEIVABLE-SUPCOUNTRY_ISO  =
      " Tax on sales/purchases code
      ls_accountreceivable-tax_code           = is_accountreceivable_api-taxcode.
      " Tax Jurisdiction
      " LS_ACCOUNTRECEIVABLE-TAXJURCODE      =
      " Date Relevant for Determining the Tax Rate
      " LS_ACCOUNTRECEIVABLE-TAX_DATE        =
      " Special G/L Indicator
      ls_accountreceivable-sp_gl_ind          = is_accountreceivable_api-specialglcode.
      " Com. Interface: Business Partner GUID
      " LS_ACCOUNTRECEIVABLE-PARTNER_GUID    =
      " Alternative payee
      " LS_ACCOUNTRECEIVABLE-ALT_PAYEE       =
      " Bank type of alternative payer
      " LS_ACCOUNTRECEIVABLE-ALT_PAYEE_BANK  =
      " Dunning Area
      " LS_ACCOUNTRECEIVABLE-DUNN_AREA       =
      " Technical Case Key (Case GUID)
      " LS_ACCOUNTRECEIVABLE-CASE_GUID       =
      " Profit Center
      " LS_ACCOUNTRECEIVABLE-PROFIT_CTR      =
      " Fund
      " LS_ACCOUNTRECEIVABLE-FUND            =
      " Grant
      " LS_ACCOUNTRECEIVABLE-GRANT_NBR       =
      " Funded Program
      " LS_ACCOUNTRECEIVABLE-MEASURE         =
      " ID for Account Details
      " LS_ACCOUNTRECEIVABLE-housebankacctid =
      " Document Number for Earmarked Funds
      " LS_ACCOUNTRECEIVABLE-RES_DOC         =
      " Earmarked Funds: Document Item
      " LS_ACCOUNTRECEIVABLE-RES_ITEM        =
      " Long Fund (Obsolete)
      " LS_ACCOUNTRECEIVABLE-FUND_LONG       =
      " Dispute Management: Dispute Interface Category
      " LS_ACCOUNTRECEIVABLE-DISPUTE_IF_TYPE =
      " FM: Budget Period
      " LS_ACCOUNTRECEIVABLE-BUDGET_PERIOD   =
      " Payment Service Provider
      " LS_ACCOUNTRECEIVABLE-PAYS_PROV       =
      " Payment Reference of Payment Service Provider
      " LS_ACCOUNTRECEIVABLE-PAYS_TRAN       =
      " Unique Reference to Mandate for each Payee
      " LS_ACCOUNTRECEIVABLE-SEPA_MANDATE_ID =
      " Branch Code
      ls_accountreceivable-part_businessplace = is_accountreceivable_api-branchcode.

      " Set Extension 2
      IF is_accountreceivable_api-creditcontrolarea IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'CREDITCONTROLAREA'
                                   valuepart1 = 'ACCOUNTRECEIVABLE'
                                   valuepart2 = ls_accountreceivable-itemno_acc
                                   valuepart3 = is_accountreceivable_api-creditcontrolarea
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountreceivable_api-invoicereference IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'INVOICEREFERENCE'
                                   valuepart1 = 'ACCOUNTRECEIVABLE'
                                   valuepart2 = ls_accountreceivable-itemno_acc
                                   valuepart3 = is_accountreceivable_api-invoicereference
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_accountreceivable_api-invoicereferencefiscalyear IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'INVOICEREFERENCEFISCALYEAR'
                                   valuepart1 = 'ACCOUNTRECEIVABLE'
                                   valuepart2 = ls_accountreceivable-itemno_acc
                                   valuepart3 = is_accountreceivable_api-invoicereferencefiscalyear
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      _convert_structure_conversion( CHANGING cv_data = ls_accountreceivable ).

      APPEND ls_accountreceivable TO ct_accountreceivable.

      IF    ls_customer-isonetimeaccount  IS NOT INITIAL
         OR is_accountreceivable_api-name IS NOT INITIAL.
        _fill_vendor_customer_onetime( EXPORTING is_accountreceivable_api = is_accountreceivable_api
                                       CHANGING  cs_customercpd           = cs_customercpd ).
      ENDIF.

      _fill_currencyamount( EXPORTING is_documentheader_api    = is_documentheader_api
                                      is_accountreceivable_api = is_accountreceivable_api
                            CHANGING  ct_currencyamount        = ct_currencyamount ).

      " Fill Withholding Tax Item
      LOOP AT it_journalentry_whtitem_api INTO FINAL(ls_journalentry_whtitem)
           WHERE referencedocumentitem = ls_accountreceivable-itemno_acc.
        _fill_accountwt( EXPORTING is_withholdingtax_api = ls_journalentry_whtitem
                         CHANGING  ct_accountwt          = ct_accountwt ).
      ENDLOOP.
      IF ct_accountwt IS INITIAL.
        APPEND INITIAL LINE TO ct_accountwt ASSIGNING FIELD-SYMBOL(<ls_accountwt>).
        <ls_accountwt>-itemno_acc = COND #( WHEN is_accountreceivable_api-referencedocumentitem IS NOT INITIAL
                                            THEN is_accountreceivable_api-referencedocumentitem
                                            ELSE mv_itemno_acc ).
        <ls_accountwt>-wt_type    = '01'.
      ENDIF.
    ELSEIF is_accountreceivable IS SUPPLIED.
      mv_itemno_acc += 1.

      ls_accountreceivable            = CORRESPONDING #( is_accountreceivable ).
      " Accounting Document Line Item Number
      ls_accountreceivable-itemno_acc = mv_itemno_acc.
      " Account Number of Vendor or Creditor
      ls_accountreceivable-customer   = ls_customer-customer.

      _convert_structure_conversion( CHANGING cv_data = ls_accountreceivable ).

      IF ls_accountreceivable-tax_code IS NOT INITIAL.
        _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                        is_currencyamount = is_currencyamount
                              CHANGING  ct_currencyamount = ct_currencyamount ).
      ELSE.
        _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                        is_currencyamount = is_currencyamount
                              CHANGING  ct_currencyamount = ct_currencyamount ).
      ENDIF.

      APPEND ls_accountreceivable TO ct_accountreceivable.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_accounttax.
    DATA ls_accounttax TYPE zcl_t2_bapi_acc_document=>bapiactx09.
    DATA lt_taxcode    TYPE RANGE OF i_taxcode-taxcode.
    DATA lt_cond_key   TYPE RANGE OF i_taxconditiontype-conditiontype.

    IF    is_accountpayable_api    IS SUPPLIED
       OR is_accountreceivable_api IS SUPPLIED
       OR is_accountgl_api         IS SUPPLIED
       OR is_producttaxitem_api    IS SUPPLIED.
      " New position with calculated tax
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accounttax-itemno_acc = COND #( WHEN is_accountpayable_api IS SUPPLIED
                                          AND is_accountpayable_api-referencedocumentitem IS NOT INITIAL THEN
                                           is_accountpayable_api-referencedocumentitem
                                         WHEN is_accountreceivable_api IS SUPPLIED
                                          AND is_accountreceivable_api-referencedocumentitem IS NOT INITIAL THEN
                                           is_accountreceivable_api-referencedocumentitem
                                         WHEN is_accountgl_api IS SUPPLIED
                                          AND is_accountgl_api-referencedocumentitem IS NOT INITIAL THEN
                                           is_accountgl_api-referencedocumentitem
                                         WHEN is_producttaxitem_api IS SUPPLIED
                                          AND is_producttaxitem_api-referencedocumentitem IS NOT INITIAL THEN
                                           is_producttaxitem_api-referencedocumentitem
                                         ELSE
                                           mv_itemno_acc ).
      " General Ledger Account
      ls_accounttax-gl_account = COND #( WHEN is_accountpayable_api          IS SUPPLIED
                                          AND is_accountpayable_api-creditor IS NOT INITIAL THEN
                                           is_accountpayable_api-creditor
                                         WHEN is_accountreceivable_api        IS SUPPLIED
                                          AND is_accountreceivable_api-debtor IS NOT INITIAL THEN
                                           is_accountreceivable_api-debtor
                                         WHEN is_accountgl_api           IS SUPPLIED
                                          AND is_accountgl_api-glaccount IS NOT INITIAL THEN
                                           is_accountgl_api-glaccount ).

      IF     is_producttaxitem_api         IS SUPPLIED
         AND is_producttaxitem_api-taxcode IS NOT INITIAL.
        DATA(lt_abap_config) = mo_abap_config_inst->get_multiple_value( ).
        DATA(lv_set_taxcode) = VALUE abap_bool( ).
        DATA(lv_set_cond_key) = VALUE abap_bool( ).

        LOOP AT lt_abap_config INTO DATA(ls_abap_config) WHERE    identifier = 'TAXCODE' "#EC CI_SORTSEQ
                                                               OR identifier = 'COND_KEY'. "#EC CI_SORTSEQ
          CASE ls_abap_config-identifier.
            WHEN 'TAXCODE'.
              lt_taxcode = VALUE #( ( sign   = ls_abap_config-valuesign
                                      option = ls_abap_config-valueoption
                                      low    = ls_abap_config-valuelowchar
                                      high   = ls_abap_config-valuehighchar ) ).

              IF     is_producttaxitem_api-taxcode IN lt_taxcode
                 AND lt_taxcode                    IS NOT INITIAL
                 AND lv_set_taxcode                IS INITIAL.
                ls_accounttax-gl_account = ls_abap_config-parameter1.
                lv_set_taxcode           = abap_true.
              ENDIF.
            WHEN 'COND_KEY'.
              lt_cond_key = VALUE #( ( sign   = ls_abap_config-valuesign
                                       option = ls_abap_config-valueoption
                                       low    = ls_abap_config-valuelowchar
                                       high   = ls_abap_config-valuehighchar ) ).

              IF     is_producttaxitem_api-taxcode IN lt_cond_key
                 AND lt_cond_key                   IS NOT INITIAL
                 AND lv_set_cond_key               IS INITIAL.
                " Condition Type
                ls_accounttax-cond_key = ls_abap_config-parameter1.
                " Transaction Key
                ls_accounttax-acct_key = ls_abap_config-parameter2.
                lv_set_cond_key        = abap_true.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        LOOP AT lt_abap_config INTO ls_abap_config WHERE identifier = 'TAX_EXEMPT'. "#EC CI_SORTSEQ
          lt_taxcode = VALUE #( ( sign   = ls_abap_config-valuesign
                                  option = ls_abap_config-valueoption
                                  low    = ls_abap_config-valuelowchar
                                  high   = ls_abap_config-valuehighchar ) ).

          IF     is_producttaxitem_api-taxcode IN lt_taxcode
             AND lt_taxcode                    IS NOT INITIAL.
            CLEAR ls_accounttax-gl_account.
            CLEAR ls_accounttax-cond_key.
            CLEAR ls_accounttax-acct_key.
          ENDIF.
        ENDLOOP.
      ENDIF.

      " CONDITION TYPE
      " LS_ACCOUNTTAX-COND_KEY    =
      " Transaction Key
      " LS_ACCOUNTTAX-ACCT_KEY          = LS_MWDAT-ktosl.
      " Tax on sales/purchases code
      ls_accounttax-tax_code    = COND #( WHEN is_accountpayable_api         IS SUPPLIED
                                           AND is_accountpayable_api-taxcode IS NOT INITIAL THEN
                                            is_accountpayable_api-taxcode
                                          WHEN is_accountreceivable_api         IS SUPPLIED
                                           AND is_accountreceivable_api-taxcode IS NOT INITIAL THEN
                                            is_accountreceivable_api-taxcode
                                          WHEN is_accountgl_api         IS SUPPLIED
                                           AND is_accountgl_api-taxcode IS NOT INITIAL THEN
                                            is_accountgl_api-taxcode
                                          WHEN is_producttaxitem_api         IS SUPPLIED
                                           AND is_producttaxitem_api-taxcode IS NOT INITIAL THEN
                                            is_producttaxitem_api-taxcode ).
      " Tax rate
      " LS_ACCOUNTTAX-TAX_RATE         =
      " Date Relevant for Determining the Tax Rate
      " LS_ACCOUNTTAX-TAX_DATE         =
      " Tax Jurisdiction
      " LS_ACCOUNTTAX-TAXJURCODE       =
      " Tax jurisdiction code - jurisdiction for lowest level tax
      " LS_ACCOUNTTAX-TAXJURCODE_DEEP  =
      " Tax Jurisdiction Code Level
      " LS_ACCOUNTTAX-TAXJURCODE_LEVEL =
      " Document item number referring to tax document.
      " LS_ACCOUNTTAX-ITEMNO_TAX       =
      " Indicator: Direct Tax Posting
      " LS_ACCOUNTTAX-DIRECT_TAX       =
      " Valid-From Date of the Tax Rate
      " LS_ACCOUNTTAX-TAX_CALC_DT_FROM =
      " Tax Reporting Country/Region
      ls_accounttax-tax_country = _get_company_code_country( iv_companycode = is_documentheader_api-companycode ).

      _convert_structure_conversion( CHANGING cv_data = ls_accounttax ).

      APPEND ls_accounttax TO ct_accounttax.

      IF ct_currencyamount IS SUPPLIED.
        IF is_accountpayable_api IS SUPPLIED.
          " Tax Amount in Document Currency
          _fill_currencyamount( EXPORTING is_documentheader_api = is_documentheader_api
                                          is_accountpayable_api = is_accountpayable_api
                                CHANGING  ct_currencyamount     = ct_currencyamount ).
        ELSEIF is_accountreceivable_api IS SUPPLIED.
          " Tax Amount in Document Currency
          _fill_currencyamount( EXPORTING is_documentheader_api    = is_documentheader_api
                                          is_accountreceivable_api = is_accountreceivable_api
                                CHANGING  ct_currencyamount        = ct_currencyamount ).
        ELSEIF is_accountgl_api IS SUPPLIED.
          " Tax Amount in Document Currency
          _fill_currencyamount( EXPORTING is_documentheader_api = is_documentheader_api
                                          is_accountgl_api      = is_accountgl_api
                                CHANGING  ct_currencyamount     = ct_currencyamount ).
        ELSEIF is_producttaxitem_api IS SUPPLIED.
          " Tax Amount in Document Currency
          _fill_currencyamount( EXPORTING is_documentheader_api = is_documentheader_api
                                          is_producttaxitem     = is_producttaxitem_api
                                CHANGING  ct_currencyamount     = ct_currencyamount ).
        ENDIF.
      ENDIF.
    ELSEIF is_accounttax IS SUPPLIED.
      " New position with calculated tax
      mv_itemno_acc += 1.

      ls_accounttax = CORRESPONDING #( is_accounttax ).
      ls_accounttax-itemno_acc = mv_itemno_acc.

      _convert_structure_conversion( CHANGING cv_data = ls_accounttax ).

      APPEND ls_accounttax TO ct_accounttax.

      IF ct_currencyamount IS SUPPLIED.
        IF is_currencyamount IS SUPPLIED.
          " Tax Amount in Document Currency
          _fill_currencyamount( EXPORTING is_documentheader = is_documentheader
                                          is_currencyamount = is_currencyamount
                                CHANGING  ct_currencyamount = ct_currencyamount ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_accountwt.
    DATA ls_accountwt TYPE zcl_t2_bapi_acc_document=>bapiacwt09.

    IF is_withholdingtax_api IS SUPPLIED.
      " Accounting Document Line Item Number
      ls_accountwt-itemno_acc      = COND #( WHEN is_withholdingtax_api-referencedocumentitem IS NOT INITIAL
                                             THEN is_withholdingtax_api-referencedocumentitem
                                             ELSE mv_itemno_acc ).
      " Indicator for withholding tax type
      ls_accountwt-wt_type         = is_withholdingtax_api-withholdingtaxtype.
      " Withholding tax code
      ls_accountwt-wt_code         = is_withholdingtax_api-withholdingtaxcode.

      " Withholding tax base amount in document currency (31 digits)
      ls_accountwt-bas_amt_tc_long = is_withholdingtax_api-taxbaseamountintranscrcy.

      " Withholding tax amount already withheld in doc crcy (31d)
      ls_accountwt-awh_amt_tc_long = is_withholdingtax_api-amountintransactioncurrency.

      " Withholding tax base amount in document currency (31 digits)
      ls_accountwt-bas_amt_lc_long = is_withholdingtax_api-taxbaseamountincocodecrcy.

      " Withholding tax amount (local crcy) already withheld (31d)
      ls_accountwt-awh_amt_lc_long = is_withholdingtax_api-amountincompanycodecurrency.

      IF ls_accountwt-wt_type IS INITIAL.
        RETURN.
      ENDIF.

      APPEND ls_accountwt TO ct_accountwt.
    ELSEIF is_accountwt IS SUPPLIED.
      ls_accountwt            = CORRESPONDING #( is_accountwt ).
      " Accounting Document Line Item Number
      ls_accountwt-itemno_acc = mv_itemno_acc.

      IF ls_accountwt-wt_type IS INITIAL.
        RETURN.
      ENDIF.

      APPEND ls_accountwt TO ct_accountwt.
    ENDIF.

    " LS_ACCOUNTWT-itemno_acc  = .                                " Accounting Document Line Item Number
    " LS_ACCOUNTWT-wt_type     = .                                " Indicator for withholding tax type
    " LS_ACCOUNTWT-wt_code     = .                                " Withholding tax code
    " LS_ACCOUNTWT-BAS_AMT_LC  = .                                " Withholding Tax Base Amount (Local Currency)
    " LS_ACCOUNTWT-bas_amt_tc  = .                                " Withholding tax base amount in document currency
    " LS_ACCOUNTWT-BAS_AMT_L2  = .                                " Withholding tax base amount in 2nd local currency
    " LS_ACCOUNTWT-BAS_AMT_L3  = .                                " Withholding tax base amount in 3rd local currency
    " LS_ACCOUNTWT-MAN_AMT_LC  = .                                " Enter withholding tax amount in local currency manually
    " LS_ACCOUNTWT-man_amt_tc  = .                                " Enter withholding tax amount in document currency manually
    " LS_ACCOUNTWT-MAN_AMT_L2  = .                                " Manually entered with/tax amount in 2nd local currency
    " LS_ACCOUNTWT-MAN_AMT_L3  = .                                " With/tax amount in 3rd local currency entered manually
    " LS_ACCOUNTWT-AWH_AMT_LC  = .                                " Withholding tax amount (in local currency) already withheld
    " LS_ACCOUNTWT-AWH_AMT_TC  = .                                " Withholding tax amount already withheld in document currency
    " LS_ACCOUNTWT-AWH_AMT_L2  = .                                " Withholding tax amount already withheld in 2nd local curr.
    " LS_ACCOUNTWT-AWH_AMT_L3  = .                                " With/tax amount already withheld in 3rd local currency
    " LS_ACCOUNTWT-BAS_AMT_IND = .                                " Indicator: Withholding tax base amount entered manually
    " LS_ACCOUNTWT-MAN_AMT_IND = .                                " Indicator: Withholding tax amount entered manually
    " APPEND LS_ACCOUNTWT TO ct_accountwt.
  ENDMETHOD.

  METHOD _fill_currencyamount.
    " TODO: parameter IS_DOCUMENTHEADER is never used (ABAP cleaner)

    DATA ls_currencyamount  TYPE zcl_t2_bapi_acc_document=>bapiaccr09.
    DATA lv_curr_type       TYPE curtp.
    DATA lv_amt_doccur      TYPE ze_rtr_ap_journalentry_amount.
    DATA lv_amt_base        TYPE ze_rtr_ap_journalentry_amount.
    DATA lv_debitcreditcode TYPE shkzg.
    DATA lv_control         TYPE if_abap_behv=>t_xflag.

    IF    is_accountpayable_api    IS SUPPLIED
       OR is_accountreceivable_api IS SUPPLIED
       OR is_accountgl_api         IS SUPPLIED.
      DO 4 TIMES.
        lv_control = SWITCH #( sy-index
                               WHEN 1 THEN COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                                     is_accountpayable_api-control-amountintransactioncurrency
                                                   WHEN is_accountreceivable_api IS SUPPLIED THEN
                                                     is_accountreceivable_api-control-amountintransactioncurrency
                                                   WHEN is_accountgl_api IS SUPPLIED THEN
                                                     is_accountgl_api-control-amountintransactioncurrency )
                               WHEN 2 THEN COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                                     is_accountpayable_api-control-amountincompanycodecurrency
                                                   WHEN is_accountreceivable_api IS SUPPLIED THEN
                                                     is_accountreceivable_api-control-amountincompanycodecurrency
                                                   WHEN is_accountgl_api IS SUPPLIED THEN
                                                     is_accountgl_api-control-amountincompanycodecurrency )
                               WHEN 3 THEN COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                                     is_accountpayable_api-control-amountingroupcurrency
                                                   WHEN is_accountreceivable_api IS SUPPLIED THEN
                                                     is_accountreceivable_api-control-amountingroupcurrency
                                                   WHEN is_accountgl_api IS SUPPLIED THEN
                                                     is_accountgl_api-control-amountingroupcurrency )
                               WHEN 4 THEN COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                                     is_accountpayable_api-control-amountinfreedefinedcurrency1
                                                   WHEN is_accountreceivable_api IS SUPPLIED THEN
                                                     is_accountreceivable_api-control-amountinfreedefinedcurrency1
                                                   WHEN is_accountgl_api IS SUPPLIED THEN
                                                     is_accountgl_api-control-amountinfreedefinedcurrency1 ) ).

        IF lv_control <> if_abap_behv=>mk-on.
          CONTINUE.
        ENDIF.

        " Set Curenccy type
        lv_curr_type = SWITCH #( sy-index
                                 WHEN 1 THEN c_curr_type-documentcurr
                                 WHEN 2 THEN c_curr_type-compancodecurr
                                 WHEN 3 THEN c_curr_type-groupcurr
                                 WHEN 4 THEN c_curr_type-hardcurr ).
        " Set Debit Credit Code
        lv_debitcreditcode = COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                       is_accountpayable_api-debitcreditcode
                                     WHEN is_accountreceivable_api IS SUPPLIED THEN
                                       is_accountreceivable_api-debitcreditcode
                                     WHEN is_accountgl_api IS SUPPLIED THEN
                                       is_accountgl_api-debitcreditcode ).

        " Set space because interface will set amount with sign already.
        " Can delete this line when interface will use Debit/Credit code instead.
        lv_debitcreditcode = space.

        " Set Document Amount
        lv_amt_doccur = SWITCH #( sy-index
                                  WHEN 1 THEN
                                    COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountpayable_api-amountintransactioncurrency
                                                      ELSE is_accountpayable_api-amountintransactioncurrency )
                                            WHEN is_accountreceivable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountreceivable_api-amountintransactioncurrency
                                                      ELSE is_accountreceivable_api-amountintransactioncurrency )
                                            WHEN is_accountgl_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountgl_api-amountintransactioncurrency
                                                      ELSE is_accountgl_api-amountintransactioncurrency ) )
                                  WHEN 2 THEN
                                    COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountpayable_api-amountincompanycodecurrency
                                                      ELSE is_accountpayable_api-amountincompanycodecurrency )
                                            WHEN is_accountreceivable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountreceivable_api-amountincompanycodecurrency
                                                      ELSE is_accountreceivable_api-amountincompanycodecurrency )
                                            WHEN is_accountgl_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountgl_api-amountincompanycodecurrency
                                                      ELSE is_accountgl_api-amountincompanycodecurrency ) )
                                  WHEN 3 THEN
                                    COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountpayable_api-amountingroupcurrency
                                                      ELSE is_accountpayable_api-amountingroupcurrency )
                                            WHEN is_accountreceivable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountreceivable_api-amountingroupcurrency
                                                      ELSE is_accountreceivable_api-amountingroupcurrency )
                                            WHEN is_accountgl_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountgl_api-amountingroupcurrency
                                                      ELSE is_accountgl_api-amountingroupcurrency ) )
                                  WHEN 4 THEN
                                    COND #( WHEN is_accountpayable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountpayable_api-amountinfreedefinedcurrency1
                                                      ELSE is_accountpayable_api-amountinfreedefinedcurrency1 )
                                            WHEN is_accountreceivable_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountreceivable_api-amountinfreedefinedcurrency1
                                                      ELSE is_accountreceivable_api-amountinfreedefinedcurrency1 )
                                            WHEN is_accountgl_api IS SUPPLIED THEN
                                              COND #( WHEN lv_debitcreditcode = c_debitcreditcode-credit
                                                      THEN - is_accountgl_api-amountinfreedefinedcurrency1
                                                      ELSE is_accountgl_api-amountinfreedefinedcurrency1 ) ) ).

        " Set Document Amount
        lv_amt_base = lv_amt_doccur.

        " Accounting Document Line Item Number
        ls_currencyamount-itemno_acc      = COND #( WHEN is_accountpayable_api IS SUPPLIED
                                                     AND is_accountpayable_api-referencedocumentitem IS NOT INITIAL THEN
                                                      is_accountpayable_api-referencedocumentitem
                                                    WHEN is_accountreceivable_api IS SUPPLIED
                                                     AND is_accountreceivable_api-referencedocumentitem IS NOT INITIAL THEN
                                                      is_accountreceivable_api-referencedocumentitem
                                                    WHEN is_accountgl_api IS SUPPLIED
                                                     AND is_accountgl_api-referencedocumentitem IS NOT INITIAL THEN
                                                      is_accountgl_api-referencedocumentitem
                                                    ELSE
                                                      mv_itemno_acc ).
        " Currency Type and Valuation View
        ls_currencyamount-curr_type       = lv_curr_type.
        " Currency Key
        ls_currencyamount-currency        = COND #( WHEN lv_curr_type = c_curr_type-documentcurr
                                                    THEN is_documentheader_api-currencycode
                                                    ELSE _get_companycodecurrencyrole(
                                                             iv_companycode  = is_documentheader_api-companycode
                                                             iv_currencyrole = lv_curr_type ) ).
        " Exchange rate
        ls_currencyamount-exch_rate       = is_documentheader_api-exchangerate.
        " Amount in Document Currency
        " LS_CURRENCYAMOUNT-amt_doccur  =
        " Indirect quoted exchange rate
        " LS_CURRENCYAMOUNT-EXCH_RATE_V  =
        " Tax Base Amount in Document Currency
        " LS_CURRENCYAMOUNT-AMT_BASE     =
        " Amount eligible for cash discount in document currency
        " LS_CURRENCYAMOUNT-DISC_BASE    =
        " Cash discount amount in the currency of the currency types
        " LS_CURRENCYAMOUNT-DISC_AMT     =

        " Amount in Document Currency (31 digits)
        ls_currencyamount-amt_doccur_long = lv_amt_doccur.
        " Amount in Document Currency (31 digits)
        ls_currencyamount-amt_base_long   = lv_amt_base.
        " Amount eligible for cash discount in document currency (31d)
        " LS_CURRENCYAMOUNT-DISC_BASE_LONG   =
        " Cash discount amount in the crcy of the currency types (31d)
        " LS_CURRENCYAMOUNT-DISC_AMT_LONG    =

        IF ls_currencyamount-currency IS NOT INITIAL.
          ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
        ENDIF.

        APPEND ls_currencyamount TO ct_currencyamount.
      ENDDO.
    ELSEIF is_producttaxitem IS SUPPLIED.
      DO 2 TIMES.
        lv_control = SWITCH #( sy-index
                               WHEN 1 THEN is_producttaxitem-control-amountintransactioncurrency
                               WHEN 2 THEN is_producttaxitem-control-amountincompanycodecurrency ).

        IF lv_control <> if_abap_behv=>mk-on.
          CONTINUE.
        ENDIF.

        " Set Curenccy type
        lv_curr_type  = SWITCH #( sy-index
                                  WHEN 1 THEN c_curr_type-documentcurr
                                  WHEN 2 THEN c_curr_type-compancodecurr ).

        " Set Document Amount
        lv_amt_doccur = SWITCH #( sy-index
                                  WHEN 1 THEN is_producttaxitem-amountintransactioncurrency
                                  WHEN 2 THEN is_producttaxitem-amountincompanycodecurrency ).

        " Set Document Amount
        lv_amt_base = SWITCH #( sy-index
                                WHEN 1 THEN is_producttaxitem-taxbaseamountintranscrcy
                                WHEN 2 THEN is_producttaxitem-taxbaseamountincocodecrcy ).

        " Accounting Document Line Item Number
        ls_currencyamount-itemno_acc      = COND #( WHEN is_producttaxitem-referencedocumentitem IS NOT INITIAL
                                                    THEN is_producttaxitem-referencedocumentitem
                                                    ELSE mv_itemno_acc ).
        " Currency Type and Valuation View
        ls_currencyamount-curr_type       = lv_curr_type.
        " Currency Key
        ls_currencyamount-currency        = COND #( WHEN lv_curr_type = c_curr_type-documentcurr
                                                    THEN is_documentheader_api-currencycode
                                                    ELSE _get_companycodecurrencyrole(
                                                             iv_companycode  = is_documentheader_api-companycode
                                                             iv_currencyrole = lv_curr_type ) ).
        " Exchange rate
        ls_currencyamount-exch_rate       = is_documentheader_api-exchangerate.
        " Amount in Document Currency
*       LS_CURRENCYAMOUNT-amt_doccur  =
        " Indirect quoted exchange rate
        " LS_CURRENCYAMOUNT-EXCH_RATE_V  =
        " Tax Base Amount in Document Currency
        " LS_CURRENCYAMOUNT-AMT_BASE     =
        " Amount eligible for cash discount in document currency
        " LS_CURRENCYAMOUNT-DISC_BASE    =
        " Cash discount amount in the currency of the currency types
        " LS_CURRENCYAMOUNT-DISC_AMT     =

        " Amount in Document Currency (31 digits)
        ls_currencyamount-amt_doccur_long = lv_amt_doccur.
        " Amount in Document Currency (31 digits)
        ls_currencyamount-amt_base_long   = lv_amt_base.
        " Amount eligible for cash discount in document currency (31d)
        " LS_CURRENCYAMOUNT-DISC_BASE_LONG   =
        " Cash discount amount in the crcy of the currency types (31d)
        " LS_CURRENCYAMOUNT-DISC_AMT_LONG    =

        " Amount in Document Currency
        " LS_CURRENCYAMOUNT-TAX_AMT      =
        " Amount in Document Currency (31 digits)
        ls_currencyamount-tax_amt_long    = lv_amt_doccur.

        IF ls_currencyamount-currency IS NOT INITIAL.
          ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
        ENDIF.

        APPEND ls_currencyamount TO ct_currencyamount.
      ENDDO.
    ELSEIF is_currencyamount IS SUPPLIED.
      ls_currencyamount = CORRESPONDING #( is_currencyamount ).

      IF ls_currencyamount-currency IS NOT INITIAL.
        ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
      ENDIF.

      APPEND ls_currencyamount TO ct_currencyamount.
    ENDIF.
  ENDMETHOD.

  METHOD _fill_documentheader.
    IF is_documentheader_api IS SUPPLIED.
      " Reference Transaction
      cs_documentheader-obj_type             = COND #( WHEN is_documentheader_api-originalreferencedocumenttype IS NOT INITIAL
                                                       THEN to_upper(
                                                                is_documentheader_api-originalreferencedocumenttype )
                                                       ELSE 'BKPFF' ).
      " Reference Key
*     CS_DOCUMENTHEADER-obj_key          =
      " Logical system of source document
*     CS_DOCUMENTHEADER-obj_sys          =
      " Business Transaction
      cs_documentheader-bus_act              = COND #( WHEN is_documentheader_api-businesstransactiontype IS NOT INITIAL
                                                       THEN to_upper( is_documentheader_api-businesstransactiontype )
                                                       ELSE 'RFBU' ).
      " User name
      cs_documentheader-username             = COND #( WHEN is_documentheader_api-createdbyuser IS NOT INITIAL
                                                       THEN is_documentheader_api-createdbyuser
                                                       ELSE cl_abap_context_info=>get_user_technical_name( ) ).
      " Document Header Text
      cs_documentheader-header_txt           = is_documentheader_api-documentheadertext.
      " Company Code
      cs_documentheader-comp_code            = is_documentheader_api-companycode.
      " Document Date in Document
      cs_documentheader-doc_date             = COND #( WHEN is_documentheader_api-documentdate IS NOT INITIAL
                                                       THEN to_upper( is_documentheader_api-documentdate )
                                                       ELSE cl_abap_context_info=>get_system_date( ) ).
      " Posting Date in the Document
      cs_documentheader-pstng_date           = COND #( WHEN is_documentheader_api-postingdate IS NOT INITIAL
                                                       THEN to_upper( is_documentheader_api-postingdate )
                                                       ELSE cl_abap_context_info=>get_system_date( ) ).
      " Translation Date
      cs_documentheader-trans_date           = is_documentheader_api-exchangeratedate.
      " Fiscal Year
*     CS_DOCUMENTHEADER-fisc_year        =
      " Fiscal Period
*     CS_DOCUMENTHEADER-fis_period       =
      " Document Type
      cs_documentheader-doc_type             = to_upper( is_documentheader_api-accountingdocumenttype ).
      " Reference Document Number
      cs_documentheader-ref_doc_no           = is_documentheader_api-documentreferenceid.
      " Accounting Document Number
*     CS_DOCUMENTHEADER-ac_doc_no        =
      " Cancel: object key (AWREF_REV and AWORG_REV)
*     CS_DOCUMENTHEADER-obj_key_r        =
      " Reason for reversal
      cs_documentheader-reason_rev           = is_documentheader_api-reversalreason.
      " Component in ACC Interface
*     CS_DOCUMENTHEADER-compo_acc        =
      " Reference Document Number (for Dependencies see Long Text)
      cs_documentheader-ref_doc_no_long      = is_documentheader_api-documentreferenceid.
      " Accounting Principle
*     CS_DOCUMENTHEADER-acc_principle    =
      " Indicator: Negative posting
*     CS_DOCUMENTHEADER-neg_postng       =
      " Invoice Ref.: Object Key (AWREF_REB and AWORG_REB)
*     CS_DOCUMENTHEADER-obj_key_inv      =
      " Billing category
*     CS_DOCUMENTHEADER-bill_category    =
      " Tax Reporting Date
*     CS_DOCUMENTHEADER-vatdate          =
      " Invoice Receipt Date
*     CS_DOCUMENTHEADER-invoice_rec_date =
      " ECS Environment
*     CS_DOCUMENTHEADER-ecs_env          =
      " Indicator: Partial Reversal
*     CS_DOCUMENTHEADER-partial_rev      =
      cs_documentheader-bus_transaction_type = cs_documentheader-bus_act.
      cs_documentheader-planned_rev_date     = is_documentheader_api-reversaldate.

      " Reference Structure for BAPI Parameters EXTENSIONIN/EXTENSIONOUT
      " The accounting document can be supplemented and changed in an implemented BAdI ( ACC_DOCUMENT)
      " before the active accounting component is called.
      " The class CL_EXM_IM_ACC_DOCUMENT is available as example implementation.
      IF is_documentheader_api-reference1indocumentheader IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'REFERENCE1INDOCUMENTHEADER'
                                   valuepart1 = 'HEADER'
                                   valuepart2 = ''          " Use to set Accounting Document Line Item Number
                                   valuepart3 = is_documentheader_api-reference1indocumentheader
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.

      IF is_documentheader_api-reference2indocumentheader IS NOT INITIAL.
        ct_extension2 = VALUE #( BASE ct_extension2
                                 ( structure  = 'REFERENCE2INDOCUMENTHEADER'
                                   valuepart1 = 'HEADER'
                                   valuepart2 = ''          " Use to set Accounting Document Line Item Number
                                   valuepart3 = is_documentheader_api-reference2indocumentheader
                                   valuepart4 = c_program_zrtr_ap011 ) ).
      ENDIF.
    ELSEIF is_documentheader IS SUPPLIED.
      cs_documentheader = CORRESPONDING #( is_documentheader ).
      cs_documentheader-bus_act  = COND #( WHEN cs_documentheader-bus_act IS INITIAL
                                           THEN 'RFBU'           " Business Transaction
                                           ELSE cs_documentheader-bus_act ).
      cs_documentheader-username = COND #( WHEN cs_documentheader-username IS INITIAL
                                           THEN cl_abap_context_info=>get_user_technical_name( )  " User name
                                           ELSE cs_documentheader-username ).
    ENDIF.
  ENDMETHOD.

  METHOD _fill_vendor_customer_onetime.
    IF is_accountpayable_api IS SUPPLIED.
      cs_customercpd-name       = is_accountpayable_api-name.
      cs_customercpd-name_2     = is_accountpayable_api-name2.
      cs_customercpd-name_3     = is_accountpayable_api-name3.
      cs_customercpd-name_4     = is_accountpayable_api-name4.
      cs_customercpd-city       = is_accountpayable_api-cityname.
      cs_customercpd-country    = is_accountpayable_api-country.
      cs_customercpd-street     = is_accountpayable_api-shortstreetname.
      cs_customercpd-postl_code = is_accountpayable_api-postalcode.
      cs_customercpd-bank_acct  = is_accountpayable_api-bankaccount.
      cs_customercpd-bank_no    = is_accountpayable_api-banknumber.
      cs_customercpd-bank_ctry  = is_accountpayable_api-country.
      cs_customercpd-tax_no_3   = is_accountpayable_api-taxnumber3.
    ELSEIF is_accountreceivable_api IS SUPPLIED.
      cs_customercpd-name       = is_accountreceivable_api-name.
      cs_customercpd-name_2     = is_accountreceivable_api-name2.
      cs_customercpd-name_3     = is_accountreceivable_api-name3.
      cs_customercpd-name_4     = is_accountreceivable_api-name4.
      cs_customercpd-city       = is_accountreceivable_api-cityname.
      cs_customercpd-country    = is_accountreceivable_api-country.
      cs_customercpd-street     = is_accountreceivable_api-shortstreetname.
      cs_customercpd-postl_code = is_accountreceivable_api-postalcode.
      cs_customercpd-bank_acct  = is_accountreceivable_api-bankaccount.
      cs_customercpd-bank_no    = is_accountreceivable_api-banknumber.
      cs_customercpd-bank_ctry  = is_accountreceivable_api-country.
      cs_customercpd-tax_no_3   = is_accountreceivable_api-taxnumber3.
    ENDIF.

    IF cs_customercpd-country IS NOT INITIAL.
      cs_customercpd-country_iso = _get_country_code_sap_to_iso( cs_customercpd-country ).
    ENDIF.

    _convert_structure_conversion( CHANGING cv_data = cs_customercpd ).
  ENDMETHOD.

  METHOD _convert_structure_conversion.
    IF cv_data IS INITIAL.
      RETURN.
    ENDIF.

    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE cv_data TO FIELD-SYMBOL(<lv_val>).
      IF sy-subrc IS INITIAL.
        IF <lv_val> IS NOT INITIAL.
          zcl_ext_abap_utilities=>convert_dynamic_inout_value(
            EXPORTING iv_value      = <lv_val>
                      iv_inout_type = zcl_ext_abap_utilities=>c_convert_inout_type-internal
            IMPORTING ev_value      = <lv_val> ).
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD _get_country_code_sap_to_iso.
    DATA ls_country TYPE i_country.

    IF iv_country IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_countryisocode = mt_country[ country = iv_country ]-countryisocode.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_country WITH
          PRIVILEGED ACCESS
          FIELDS country,
                 countryisocode
          WHERE country = @iv_country
          INTO @DATA(ls_country_tmp).
        IF sy-subrc IS INITIAL.
          ls_country = CORRESPONDING #( ls_country_tmp ).
          rv_countryisocode = ls_country_tmp-countryisocode.

          INSERT ls_country INTO TABLE mt_country.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _get_currency_code_sap_to_iso.
    DATA ls_currency TYPE i_currency.

    IF iv_currency IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_currencyisocode = mt_currency[ currency = iv_currency ]-currencyisocode.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_currency WITH
          PRIVILEGED ACCESS
          FIELDS currency,
                 currencyisocode
          WHERE currency = @iv_currency
          INTO @DATA(ls_currency_tmp).
        IF sy-subrc IS INITIAL.
          ls_currency = CORRESPONDING #( ls_currency_tmp ).
          rv_currencyisocode = ls_currency_tmp-currencyisocode.

          INSERT ls_currency INTO TABLE mt_currency.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _get_company_code_country.
    DATA ls_companycode TYPE i_companycode.

    IF iv_companycode IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_country = mt_companycode[ companycode = iv_companycode ]-country.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_companycode WITH
          PRIVILEGED ACCESS
          FIELDS companycode,
                 companycodename,
                 country,
                 currency,
                 language,
                 fiscalyearvariant
          WHERE companycode = @iv_companycode
          INTO @DATA(ls_companycode_tmp).
        IF sy-subrc IS INITIAL.
          ls_companycode = CORRESPONDING #( ls_companycode_tmp ).
          rv_country = ls_companycode-country.

          INSERT ls_companycode INTO TABLE mt_companycode.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _get_unitofmeasure_to_iso.
    DATA ls_unitofmeasure TYPE i_unitofmeasure.

    IF iv_unitofmeasure IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_unitofmeasureisocode = mt_unitofmeasure[ unitofmeasure = iv_unitofmeasure ]-unitofmeasureisocode.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_unitofmeasure WITH
          PRIVILEGED ACCESS
          FIELDS unitofmeasure,
                 unitofmeasureisocode
          WHERE unitofmeasure = @iv_unitofmeasure
          INTO @DATA(ls_unitofmeasure_tmp).
        IF sy-subrc IS INITIAL.
          ls_unitofmeasure = CORRESPONDING #( ls_unitofmeasure_tmp ).
          rv_unitofmeasureisocode = ls_unitofmeasure-unitofmeasure.

          INSERT ls_unitofmeasure INTO TABLE mt_unitofmeasure.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _get_product_type.
    DATA ls_product TYPE i_product.

    IF iv_product IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_producttype = mt_product[ product = iv_product ]-producttype.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_product WITH
          PRIVILEGED ACCESS
          FIELDS product,
                 producttype
          WHERE product = @iv_product
          INTO @DATA(ls_product_tmp).
        IF sy-subrc IS INITIAL.
          ls_product = CORRESPONDING #( ls_product_tmp ).
          rv_producttype = ls_product-producttype.

          INSERT ls_product INTO TABLE mt_product.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _get_companycodecurrencyrole.
    DATA ls_companycodecurrencyrole TYPE i_companycodecurrencyrole.

    IF     iv_companycode  IS INITIAL
       AND iv_currencyrole IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_currency = mt_companycodecurrencyrole[ companycode  = iv_companycode
                                                  currencyrole = iv_currencyrole ]-currency.
      CATCH cx_sy_itab_line_not_found.
        SELECT SINGLE FROM i_companycodecurrencyrole WITH
          PRIVILEGED ACCESS
          FIELDS companycode,
                 currencyrole,
                 currency
          WHERE companycode  = @iv_companycode
            AND currencyrole = @iv_currencyrole
          INTO @DATA(ls_companycodecurrencyrole_tmp).
        IF sy-subrc IS INITIAL.
          ls_companycodecurrencyrole = CORRESPONDING #( ls_companycodecurrencyrole_tmp ).
          rv_currency = ls_companycodecurrencyrole-currency.

          INSERT ls_companycodecurrencyrole INTO TABLE mt_companycodecurrencyrole.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

  METHOD _fill_tax_is_exempt_api.
    DATA ls_accounttax     TYPE zcl_t2_bapi_acc_document=>bapiactx09.
    DATA ls_currencyamount TYPE zcl_t2_bapi_acc_document=>bapiaccr09.

    DATA lv_amt_base       TYPE ze_rtr_ap_journalentry_amount.

    DATA lt_tax_exempt     TYPE RANGE OF i_taxcode-taxcode.

*    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    " Check Tax is exempt
*    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    mo_abap_config_inst->get_range_value( EXPORTING iv_identifier = 'TAX_EXEMPT'
                                          IMPORTING et_range      = lt_tax_exempt ).

    IF lt_tax_exempt IS INITIAL.
      lt_tax_exempt = VALUE #( sign   = 'I'
                               option = 'EQ'
                               ( low = 'VX' )
                               ( low = 'OX' ) ).
    ENDIF.

    IF it_accountpayable_api IS SUPPLIED.
      LOOP AT it_accountpayable_api INTO DATA(ls_accountpayable_api) WHERE taxcode IN lt_tax_exempt.
        lv_amt_base += ls_accountpayable_api-amountintransactioncurrency.
      ENDLOOP.
    ELSEIF it_accountreceivable_api IS SUPPLIED.
      LOOP AT it_accountreceivable_api INTO DATA(ls_accountreceivable_api) WHERE taxcode IN lt_tax_exempt.
        lv_amt_base += ls_accountreceivable_api-amountintransactioncurrency.
      ENDLOOP.
    ELSEIF it_accountgl_api IS SUPPLIED.
      LOOP AT it_accountgl_api INTO DATA(ls_accountgl_api) WHERE taxcode IN lt_tax_exempt.
        lv_amt_base += ls_accountgl_api-amountintransactioncurrency.
      ENDLOOP.

    ELSEIF it_producttaxitem_api IS SUPPLIED.
      LOOP AT it_producttaxitem_api INTO DATA(ls_producttaxitem_api) WHERE taxcode IN lt_tax_exempt.
        lv_amt_base += ls_producttaxitem_api-amountintransactioncurrency.
      ENDLOOP.
    ELSE.
      RETURN.
    ENDIF.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " New position with calculated tax
    mv_itemno_acc += 1.

    " Accounting Document Line Item Number
    ls_accounttax-itemno_acc = mv_itemno_acc.
    " Tax on sales/purchases code
    ls_accounttax-tax_code   = COND #( WHEN it_accountpayable_api IS SUPPLIED    THEN ls_accountpayable_api-taxcode
                                       WHEN it_accountreceivable_api IS SUPPLIED THEN ls_accountreceivable_api-taxcode
                                       WHEN it_accountgl_api IS SUPPLIED         THEN ls_accountgl_api-taxcode
                                       WHEN it_producttaxitem_api IS SUPPLIED    THEN ls_producttaxitem_api-taxcode ).

    DATA(lt_abap_config) = mo_abap_config_inst->get_multiple_value( iv_identifier = 'TAX_CODE_EXEMPT' ).

    LOOP AT lt_abap_config INTO DATA(ls_abap_config).
      lt_tax_exempt = VALUE #( ( sign   = ls_abap_config-valuesign
                                 option = ls_abap_config-valueoption
                                 low    = ls_abap_config-valuelowchar
                                 high   = ls_abap_config-valuehighchar ) ).

      IF     ls_accounttax-tax_code IN lt_tax_exempt
         AND lt_tax_exempt          IS NOT INITIAL.
        " Condition Type
        ls_accounttax-cond_key = ls_abap_config-parameter1.
        EXIT.
      ENDIF.
    ENDLOOP.

    " Populate Condition Type
    IF ls_accounttax-cond_key IS INITIAL.
      ls_accounttax-cond_key = COND #( WHEN ls_accounttax-tax_code = 'VX' THEN 'MWVS'
                                       WHEN ls_accounttax-tax_code = 'OX' THEN 'MWAS' ).
    ENDIF.

    " Amount in Document Currency (31 digits)
    ls_currencyamount-amt_base_long = lv_amt_base.
    " Tax Reporting Country/Region
    ls_accounttax-tax_country = _get_company_code_country( iv_companycode = is_documentheader_api-companycode ).

    _convert_structure_conversion( CHANGING cv_data = ls_accounttax ).

    APPEND ls_accounttax TO ct_accounttax.

    " Accounting Document Line Item Number
    ls_currencyamount-itemno_acc = mv_itemno_acc.
    " Currency Key
    ls_currencyamount-currency   = is_documentheader_api-currencycode.

    IF ls_currencyamount-currency IS NOT INITIAL.
      ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
    ENDIF.

    APPEND ls_currencyamount TO ct_currencyamount.
  ENDMETHOD.

  METHOD _fill_downpayment_api.
    DATA ls_accounttax     TYPE zcl_t2_bapi_acc_document=>bapiactx09.
    DATA ls_currencyamount TYPE zcl_t2_bapi_acc_document=>bapiaccr09.

    DATA lv_amt_base       TYPE ze_rtr_ap_journalentry_amount.

    DATA lt_taxcode        TYPE RANGE OF i_taxcode-taxcode.

    DATA lt_abap_config    TYPE zcl_ext_abap_config=>tt_abap_config.
    DATA ls_abap_config    TYPE zcl_ext_abap_config=>ty_abap_config.

    LOOP AT it_accountreceivable_api INTO DATA(ls_accountreceivable_api) WHERE     taxcode       IS NOT INITIAL
                                                                               AND specialglcode IS NOT INITIAL
                                                                               AND specialglcode <> 'F'.
      lv_amt_base += ls_accountreceivable_api-amountintransactioncurrency.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      " New position with calculated tax
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accounttax-itemno_acc = mv_itemno_acc.
      " Tax on sales/purchases code
      ls_accounttax-tax_code   = ls_accountreceivable_api-taxcode.

      lt_abap_config = mo_abap_config_inst->get_multiple_value( iv_identifier = 'COND_KEY' ).

      LOOP AT lt_abap_config INTO ls_abap_config.
        lt_taxcode = VALUE #( ( sign   = ls_abap_config-valuesign
                                option = ls_abap_config-valueoption
                                low    = ls_abap_config-valuelowchar
                                high   = ls_abap_config-valuehighchar ) ).

        IF     ls_accounttax-tax_code IN lt_taxcode
           AND lt_taxcode             IS NOT INITIAL.
          " Condition Type
          ls_accounttax-cond_key = ls_abap_config-parameter1.
          EXIT.
        ENDIF.
      ENDLOOP.

      " Amount in Document Currency (31 digits)
      ls_currencyamount-amt_base_long = lv_amt_base.
      " Tax Reporting Country/Region
      ls_accounttax-tax_country = _get_company_code_country( iv_companycode = is_documentheader_api-companycode ).

      _convert_structure_conversion( CHANGING cv_data = ls_accounttax ).

      APPEND ls_accounttax TO ct_accounttax.

      " Accounting Document Line Item Number
      ls_currencyamount-itemno_acc = mv_itemno_acc.
      " Currency Key
      ls_currencyamount-currency   = is_documentheader_api-currencycode.

      IF ls_currencyamount-currency IS NOT INITIAL.
        ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
      ENDIF.

      APPEND ls_currencyamount TO ct_currencyamount.
    ENDIF.

    CLEAR lv_amt_base.

    LOOP AT it_accountpayable_api INTO DATA(ls_accountpayable_api) WHERE     taxcode       IS NOT INITIAL
                                                                         AND specialglcode IS NOT INITIAL
                                                                         AND specialglcode <> 'F'.
      lv_amt_base += ls_accountpayable_api-amountintransactioncurrency.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      " New position with calculated tax
      mv_itemno_acc += 1.

      " Accounting Document Line Item Number
      ls_accounttax-itemno_acc = mv_itemno_acc.
      " Tax on sales/purchases code
      ls_accounttax-tax_code   = ls_accountpayable_api-taxcode.

      lt_abap_config = mo_abap_config_inst->get_multiple_value( iv_identifier = 'COND_KEY' ).

      LOOP AT lt_abap_config INTO ls_abap_config.
        lt_taxcode = VALUE #( ( sign   = ls_abap_config-valuesign
                                option = ls_abap_config-valueoption
                                low    = ls_abap_config-valuelowchar
                                high   = ls_abap_config-valuehighchar ) ).

        IF     ls_accounttax-tax_code IN lt_taxcode
           AND lt_taxcode             IS NOT INITIAL.
          " Condition Type
          ls_accounttax-cond_key = ls_abap_config-parameter1.
          EXIT.
        ENDIF.
      ENDLOOP.

      " Amount in Document Currency (31 digits)
      ls_currencyamount-amt_base_long = lv_amt_base.
      " Tax Reporting Country/Region
      ls_accounttax-tax_country = _get_company_code_country( iv_companycode = is_documentheader_api-companycode ).

      _convert_structure_conversion( CHANGING cv_data = ls_accounttax ).

      APPEND ls_accounttax TO ct_accounttax.

      " Accounting Document Line Item Number
      ls_currencyamount-itemno_acc = mv_itemno_acc.
      " Currency Key
      ls_currencyamount-currency   = is_documentheader_api-currencycode.

      IF ls_currencyamount-currency IS NOT INITIAL.
        ls_currencyamount-currency_iso = _get_currency_code_sap_to_iso( ls_currencyamount-currency ).
      ENDIF.

      APPEND ls_currencyamount TO ct_currencyamount.
    ENDIF.
  ENDMETHOD.

  METHOD _get_customer_supplier_zterm.
    DATA ls_customercompany TYPE i_customercompany.
    DATA ls_suppliercompany TYPE i_suppliercompany.

    IF     iv_customer IS INITIAL
       AND iv_supplier IS INITIAL.
      RETURN.
    ELSEIF iv_companycode IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_customer IS SUPPLIED.
      TRY.
          rv_paymentterms = mt_customercompany[ customer    = iv_customer
                                                companycode = iv_companycode ]-paymentterms.
        CATCH cx_sy_itab_line_not_found.
          SELECT SINGLE FROM i_customercompany WITH
            PRIVILEGED ACCESS
            FIELDS customer,
                   companycode,
                   paymentterms
            WHERE customer    = @iv_customer
              AND companycode = @iv_companycode
            INTO CORRESPONDING FIELDS OF @ls_customercompany.
          IF sy-subrc IS INITIAL.
            INSERT ls_customercompany INTO TABLE mt_customercompany.
          ENDIF.
      ENDTRY.
    ELSEIF iv_supplier IS SUPPLIED.
      TRY.
          rv_paymentterms = mt_suppliercompany[ supplier    = iv_supplier
                                                companycode = iv_companycode ]-paymentterms.
        CATCH cx_sy_itab_line_not_found.
          SELECT SINGLE FROM i_suppliercompany WITH
            PRIVILEGED ACCESS
            FIELDS supplier,
                   companycode,
                   paymentterms
            WHERE supplier    = @iv_supplier
              AND companycode = @iv_companycode
            INTO CORRESPONDING FIELDS OF @ls_suppliercompany.
          IF sy-subrc IS INITIAL.
            INSERT ls_suppliercompany INTO TABLE mt_suppliercompany.
          ENDIF.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD get_current_action.
    RETURN mv_action.
  ENDMETHOD.

  METHOD set_current_action.
    mv_action = iv_action.
  ENDMETHOD.

  METHOD set_journalentry_temp_keys.
    mt_journalentry_keys = VALUE #( BASE mt_journalentry_keys
                                    ( is_journalentry_keys ) ).
  ENDMETHOD.

  METHOD get_interface_api_keys_rev.
    RETURN mt_keys_reverse.
  ENDMETHOD.

  METHOD set_interface_api_keys_rev.
    mt_keys_reverse = VALUE #( BASE mt_keys_reverse
                               ( is_keys ) ).
  ENDMETHOD.

  METHOD get_pid.
    TRY.
        RETURN cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.
  ENDMETHOD.

  METHOD reverse_accounting_document.
    DATA lx_error TYPE REF TO zcx_t2_static_check.

    TRY.
        zcl_t2_journal_entry_reverse=>call_fbra_and_fb08( iv_bukrs   = iv_companycode
                                                          iv_augbl   = iv_accountingdocument
                                                          iv_gjahr   = iv_fiscalyear
                                                          iv_stgrd   = iv_reversalreason
                                                          iv_xsimu   = abap_true
                                                          iv_no_auth = abap_true ).

        TRY.
            zcl_t2_journal_entry_reverse=>call_fbra_and_fb08( iv_bukrs   = iv_companycode
                                                              iv_augbl   = iv_accountingdocument
                                                              iv_gjahr   = iv_fiscalyear
                                                              iv_stgrd   = iv_reversalreason
                                                              iv_xsimu   = space
                                                              iv_no_auth = abap_true ).
          CATCH zcx_t2_static_check INTO lx_error.
            RAISE EXCEPTION NEW zcx_t2_static_check( textid = lx_error->if_t100_message~t100key ).
        ENDTRY.
      CATCH zcx_t2_static_check.
        TRY.
            zcl_t2_journal_entry_reverse=>call_fb08( iv_bukrs   = iv_companycode
                                                     iv_belnr   = iv_accountingdocument
                                                     iv_gjahr   = iv_fiscalyear
                                                     iv_stgrd   = iv_reversalreason
                                                     iv_budat   = iv_postingdate
                                                     iv_xsimu   = space
                                                     iv_no_auth = abap_true ).
          CATCH zcx_t2_static_check INTO lx_error.
            RAISE EXCEPTION NEW zcx_t2_static_check( textid = lx_error->if_t100_message~t100key ).
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD adjust_numbers_post_je.
    DATA(lo_instance) = zcl_rtr_ap_journalentry_post=>get_instance( ).

    MODIFY ENTITIES OF zr_rtr_ap_journalentrytp PRIVILEGED
           ENTITY journalentry
           EXECUTE internalpostje
           FROM CORRESPONDING #( lo_instance->get_interface_api_keys( ) )
           FAILED   FINAL(ls_failed)
           REPORTED FINAL(ls_reported).

    LOOP AT lo_instance->mt_journalentry_keys INTO DATA(ls_journalentry_key).
      APPEND VALUE #( " Mapping the key fields to %tmp and %key for response
                      %pid = ls_journalentry_key-pid
                      " Set actual key fields to %key for response
                      %key = VALUE #( companycode        = ls_journalentry_key-companycode
                                      fiscalyear         = ls_journalentry_key-fiscalyear
                                      accountingdocument = ls_journalentry_key-accountingdocument ) )
             TO cs_mapped-journalentry.
    ENDLOOP.

    cs_reported = CORRESPONDING #( DEEP ls_reported ).
  ENDMETHOD.
ENDCLASS.

class ZCL_EXT_ABAP_UTILITIES definition
  public
  final
  create private .

public section.

  types:
    ty_char1           TYPE c LENGTH 1 .
  types:
    ty_char2           TYPE c LENGTH 2 .
  types:
    ty_char4           TYPE c LENGTH 4 .
  types:
    ty_char132         TYPE c LENGTH 132 .
  types:
    ty_char255         TYPE c LENGTH 255 .
  types TS_UNITOFMEASURE type I_UNITOFMEASURE .
  types TS_MATERIAL type I_PRODUCT .
  types TS_BUSINESSPARTNER type I_BUSINESSPARTNER .
  types TS_CUSTOMER type I_CUSTOMER .
  types TS_SUPPLIER type I_SUPPLIER .
  types TS_WBSELEMENT type I_WBSELEMENTBASICDATA .
  types:
    BEGIN OF ts_business_object,
             name           TYPE if_cbo_dev_bo_node=>tv_id,
             type           TYPE string,
             is_root        TYPE abap_bool,
             data_retrieval TYPE REF TO if_cbo_dev_business_object,
             records_lists  TYPE if_xco_dda_record=>list,
             t_data         TYPE TABLE OF REF TO data WITH EMPTY KEY,
           END OF ts_business_object .
  types:
    BEGIN OF ts_bali_msg_log,
             severity   TYPE cl_bali_message_setter=>ty_severity,
             id         TYPE cl_bali_message_setter=>ty_id,
             number     TYPE cl_bali_message_setter=>ty_number,
             variable_1 TYPE cl_bali_message_setter=>ty_variable,
             variable_2 TYPE cl_bali_message_setter=>ty_variable,
             variable_3 TYPE cl_bali_message_setter=>ty_variable,
             variable_4 TYPE cl_bali_message_setter=>ty_variable,
           END OF ts_bali_msg_log .
  types:
    BEGIN OF ts_bali_free_msg_log,
             severity TYPE cl_bali_message_setter=>ty_severity,
             text     TYPE cl_bali_free_text_setter=>ty_text,
           END OF ts_bali_free_msg_log .
  types:
    BEGIN OF ts_zip_content,
             filename     TYPE string,
             contents_txt TYPE string,
             codepage     TYPE abap_encoding,
             contents_bin TYPE xstring,
           END OF ts_zip_content .
  types:
    BEGIN OF ts_tline,
             tdformat TYPE ty_char2,
             tdline   TYPE ty_char132,
           END OF ts_tline .
  types:
    tt_unitofmeasure     TYPE SORTED TABLE OF ts_unitofmeasure
                                WITH UNIQUE KEY unitofmeasure
                                WITH NON-UNIQUE SORTED KEY k2 COMPONENTS unitofmeasure_e .
  types:
    tt_unit              TYPE TABLE OF i_unitofmeasure-unitofmeasure WITH EMPTY KEY .
  types:
    tt_material          TYPE SORTED TABLE OF ts_material WITH UNIQUE KEY product
                                                                WITH NON-UNIQUE SORTED KEY k2 COMPONENTS productexternalid .
  types:
    tt_businesspartner   TYPE STANDARD TABLE OF ts_businesspartner WITH EMPTY KEY .
  types:
    tt_customer          TYPE STANDARD TABLE OF ts_customer WITH EMPTY KEY .
  types:
    tt_supplier          TYPE STANDARD TABLE OF ts_supplier WITH EMPTY KEY .
  types:
    tt_wbselement        TYPE SORTED TABLE OF ts_wbselement WITH UNIQUE KEY wbselementinternalid
                                                                  WITH NON-UNIQUE SORTED KEY k2 COMPONENTS wbselementexternalid
                                                                  WITH NON-UNIQUE SORTED KEY k3 COMPONENTS wbselement .
  types:
    tt_partner           TYPE TABLE OF gpart_kk WITH EMPTY KEY .
  types:
    tt_business_object   TYPE TABLE OF ts_business_object WITH EMPTY KEY .
  types:
    tt_child_node        TYPE TABLE OF if_cbo_dev_bo_node=>tv_id WITH EMPTY KEY .
  types:
    tt_bali_msg_log      TYPE TABLE OF ts_bali_msg_log WITH EMPTY KEY .
  types:
    tt_bali_free_msg_log TYPE TABLE OF ts_bali_free_msg_log WITH EMPTY KEY .
  types:
    tt_id                TYPE STANDARD TABLE OF usalias WITH EMPTY KEY .
  types:
    tt_zip_content       TYPE TABLE OF ts_zip_content WITH EMPTY KEY .
  types:
    tt_tline             TYPE TABLE OF ts_tline WITH EMPTY KEY .

  constants C_XML_TAG type STRING value '<?xml version="1.0" encoding="UTF-8"?>' ##NO_TEXT.
  constants C_DEFAULT_FORM type STRING value 'Form' ##NO_TEXT.
  constants:
    BEGIN OF c_attachment_content_type,
                 image_png   TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'image/png',
                 pdf         TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'application/pdf',
                 xml         TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'application/xml',
                 text_plain  TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'text/plain',
                 text_html   TYPE cl_bcs_mail_bodypart=>ty_content_type VALUE 'text/html',
                 spreadsheet TYPE cl_bcs_mail_bodypart=>ty_content_type
                             VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
               END OF c_attachment_content_type .
  constants:
    BEGIN OF c_convert_inout_type,
                 internal TYPE i VALUE 1,
                 external TYPE i VALUE 2,
               END OF c_convert_inout_type .
  constants:
    BEGIN OF c_factorycalendar_id,
                 th TYPE cl_fhc_calendar_runtime=>ty_fcal_id VALUE 'FCTH',
               END OF c_factorycalendar_id .
  constants C_KOART_D type KOART value 'D' ##NO_TEXT.
  constants C_KOART_K type KOART value 'K' ##NO_TEXT.
  class-data GT_UNITOFMEASURE type TT_UNITOFMEASURE read-only .
  class-data GT_MATERIAL type TT_MATERIAL read-only .
  class-data GT_BUSINESSPARTNER type TT_BUSINESSPARTNER read-only .
  class-data GT_CUSTOMER type TT_CUSTOMER read-only .
  class-data GT_SUPPLIER type TT_SUPPLIER read-only .
  class-data GT_WBSELEMENT type TT_WBSELEMENT read-only .
  constants C_MSGTY_E type MSGTY value 'E' ##NO_TEXT.

  class-methods CLASS_CONSTRUCTOR .
*                iv_replace_item_tag TYPE abap_boolean DEFAULT abap_false
  class-methods TRANSFORMATION_TO_XML
    importing
      !IT_SRCBIND type ABAP_TRANS_SRCBIND_TAB
      !IV_FORM_NAME type STRING default C_DEFAULT_FORM
      !IV_ADD_START_TAG type ABAP_BOOLEAN optional
      !IV_ADD_END_TAG type ABAP_BOOLEAN optional
      !IV_ENCODING type ABAP_ENCODING optional
    exporting
      !EV_STRING type STRING
      !EV_XSTRING type XSTRING
      !EV_ENCODE_X64 type STRING .
  class-methods CONVERT_PRODUCT_UNIT
    importing
      value(IV_INPUT) type ANY
      !IV_IS_ALTERNATIVEUNIT type ABAP_BOOL default SPACE
      !IV_PRODUCT type MATNR
      !IV_UNIT_OUT type MEINS default SPACE
      !IV_UNIT_IN type MEINS default SPACE
      !IV_CLFNOBJECTINTERNALID type CL_MD_PRODUCT_UNIT_CONVERSION=>TY_CLFNOBJECTINTERNALID optional
      !IV_BATCH type CL_MD_PRODUCT_UNIT_CONVERSION=>TY_BATCH optional
      !IV_PLANT type CL_MD_PRODUCT_UNIT_CONVERSION=>TY_PLANT optional
      !IV_TOINTERNALUNIT type ABAP_BOOL default ABAP_TRUE
      !IV_SET_FLOOR type ABAP_BOOL optional
      !IV_SET_CEIL type ABAP_BOOL optional
    exporting
      value(EV_OUTPUT) type ANY
      !EV_ERROR type ABAP_BOOL
      !EV_MESSAGE type ANY .
  class-methods NUMBER_RANGE_GET
    importing
      !IV_IGNORE_BUFFER type CL_NUMBERRANGE_RUNTIME=>NR_IGNORE_BUFFER default SPACE
      !IV_NR_RANGE_NR type CL_NUMBERRANGE_RUNTIME=>NR_INTERVAL
      !IV_OBJECT type CL_NUMBERRANGE_RUNTIME=>NR_OBJECT
      !IV_QUANTITY type CL_NUMBERRANGE_RUNTIME=>NR_QUANTITY default '1'
      !IV_SUBOBJECT type CL_NUMBERRANGE_RUNTIME=>NR_SUBOBJECT default SPACE
      !IV_TOYEAR type CL_NUMBERRANGE_RUNTIME=>NR_TOYEAR default '0000'
    exporting
      !EV_NUMBER type CL_NUMBERRANGE_RUNTIME=>NR_NUMBER
      !EV_RETURNCODE type CL_NUMBERRANGE_RUNTIME=>NR_RETURNCODE
      !EV_RETURNED_QUANTITY type CL_NUMBERRANGE_RUNTIME=>NR_RETURNED_QUANTITY
      !EV_MESSAGE type STRING
      !EO_CLASS_ERROR type ref to OBJECT .
  class-methods GET_UNITOFMEASURE
    importing
      !IV_UNIT type I_UNITOFMEASURE-UNITOFMEASURE
    exporting
      value(ES_UNITOFMEASURE) type TS_UNITOFMEASURE
      value(EV_UNIT_IN) type I_UNITOFMEASURE-UNITOFMEASURE
      value(EV_UNIT_OUT) type I_UNITOFMEASURE-UNITOFMEASURE_E .
  class-methods GET_UNITOFMEASURE_TABLE
    importing
      !IT_UNIT type TT_UNIT
      !IV_FIND_ALL type ABAP_BOOL optional
    returning
      value(RT_UNITOFMEASURE) type TT_UNITOFMEASURE .
  class-methods GET_BUSINESSPARTNER_DETAILS
    importing
      !IT_PARTNER type TT_PARTNER
    exporting
      !ET_BUSINESSPARTNER type TT_BUSINESSPARTNER .
  class-methods GET_CUSTOMER_SUPPLIER_DETAILS
    importing
      !IV_TYPE type KOART
      !IT_PARTNER type TT_PARTNER
    exporting
      !ET_CUSTOMER type TT_CUSTOMER
      !ET_SUPPLIER type TT_SUPPLIER .
  class-methods ENCODE_STRING_TO_X64
    importing
      !IV_STRING type STRING
      !IV_ENCODING type ABAP_ENCODING optional
    returning
      value(RV_ENCODE_X64) type STRING .
  class-methods CONVERT_STRING_TO_DECIMAL
    importing
      value(IV_INPUT) type CLIKE
    exporting
      value(EV_OUTPUT) type ANY
      !EV_F_SUCCESS type C .
  class-methods GET_LOCK_OBJECT_INSTANCE
    importing
      !IV_NAME type IF_ABAP_LOCK_OBJECT=>TV_NAME
    exporting
      !EV_SUBRC type SY-SUBRC
      !EV_MSG type STRING
    returning
      value(RO_LOCK_OBJECT) type ref to IF_ABAP_LOCK_OBJECT .
  class-methods DEQUEUE_ALL_OBJECT_INSTANCE
    importing
      !IV_SYNCHRONOUS type IF_ABAP_LOCK_OBJECT=>TV_SYNCHRONOUS default SPACE .
  class-methods ASSIGN_X_STRUCTURE
    importing
      !IS_N type ANY
    changing
      !CS_X type ANY .
  class-methods BUILD_XML_PDF
    importing
      !IV_FORM_NAME type STRING
      !IV_PAGE_NAME type STRING optional
    exporting
      !EV_ERROR type ABAP_BOOL
      !EV_MSG type STRING
    changing
      !CS_DATA type ANY optional
      !CT_DATA type ANY TABLE optional
    returning
      value(RV_XMLPDF) type STRING .
  class-methods BUILD_XML_PDF_WITH_ENCODE_X64
    importing
      !IV_FORM_NAME type STRING
      !IV_PAGE_NAME type STRING optional
    exporting
      !EV_XMLPDF type STRING
      !EV_ENCODEX64 type STRING
    changing
      !CS_DATA type ANY optional
      !CT_DATA type ANY TABLE optional .
  class-methods ACCESS_CUSTOM_BUSINESS_OBJECT
    importing
      !IV_BUSINESS_OBJECT type IF_CBO_DEV_BUSINESS_OBJECT=>TV_ID
      !IT_CHILD_NODE_ID type TT_CHILD_NODE optional
    exporting
      !ES_ROOT_NODE_OBJ type TS_BUSINESS_OBJECT
      !ET_CHILD_NODE_OBJ type TT_BUSINESS_OBJECT
      !ET_BUSINESS_OBJECT type TT_BUSINESS_OBJECT .
  class-methods GET_CURRENT_DATE_TIME
    importing
      !IV_TIMEZONE type CL_ABAP_CONTEXT_INFO=>TY_TIME_ZONE optional
      !IV_USER_TIME_ZONE type ABAP_BOOL optional
    exporting
      !EV_DATE type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_DATE
      !EV_TIME type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_TIME .
  class-methods GET_CURRENT_THAILAND_DATE_TIME
    exporting
      !EV_DATE type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_DATE
      !EV_TIME type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_TIME
      !EV_TIMEZONE type CL_ABAP_CONTEXT_INFO=>TY_TIME_ZONE .
  class-methods GET_CURRENT_TIMESTAMP
    returning
      value(RV_TIMESTAMP) type TIMESTAMP .
  class-methods GET_CURRENT_TIMESTAMP_LONG
    returning
      value(RV_TIMESTAMPL) type ABP_LASTCHANGE_TSTMPL .
  class-methods DATE_PLAUSIBILITY_CHECK
    importing
      value(IV_DATE) type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_DATE
    returning
      value(RV_VALID_DATE) type ABAP_BOOLEAN .
  class-methods DATE_IS_VALID
    importing
      value(IV_DATE) type ANY
    returning
      value(RV_VALID_DATE) type ABAP_BOOLEAN .
  class-methods CREATE_BALI_LOG
    importing
      !IV_OBJECT type CL_BALI_HEADER_SETTER=>TY_OBJECT
      !IV_SUBOBJECT type CL_BALI_HEADER_SETTER=>TY_SUBOBJECT optional
      !IV_EXTERNAL_ID type CL_BALI_HEADER_SETTER=>TY_EXTERNAL_ID optional
      !IT_MESSAGE type TT_BALI_MSG_LOG optional
      !IT_FREE_MESSAGE type TT_BALI_FREE_MSG_LOG optional
      !IV_ASSIGN_TO_APPL_JOB type IF_BALI_LOG_DB=>TY_ASSIGN_TO_CURR_APPJOB default ABAP_TRUE
      !IV_COMMIT_WORK type ABAP_BOOLEAN default ABAP_TRUE .
  class-methods NEW_MESSAGE_WITH_TEXT
    importing
      !IV_SEVERITY type IF_ABAP_BEHV_MESSAGE=>T_SEVERITY default IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR
      !IV_TEXT type TY_CHAR255
    returning
      value(RO_OBJ) type ref to IF_ABAP_BEHV_MESSAGE .
  class-methods GET_VALUES_FROM_JOB_PARAM
    importing
      value(IT_PARAMETERS) type IF_APJ_DT_EXEC_OBJECT=>TT_TEMPL_VAL
      value(IV_SELNAME) type IF_APJ_DT_EXEC_OBJECT=>TY_TEMPL_VAL-SELNAME
    exporting
      value(EV_VALUE) type ANY
      value(ET_RANGE) type STANDARD TABLE .
  class-methods CONVERT_STRING_TO_XSTRING
    importing
      !IV_STRING type STRING
      !IV_ENCODING type ABAP_ENCODING optional
    exporting
      !EV_RAWSTRING type XSTRING
      !EV_ENCODE_X64 type XSTRING .
  class-methods CONVERT_XSTRING_TO_STRING
    importing
      !IV_XSTRING type XSTRING
      !IV_ENCODING type ABAP_ENCODING optional
    exporting
      !EV_STRING type STRING
      !EV_DECODE_X64 type STRING .
  class-methods SET_BACKGROUND_PROCESS
    importing
      !IV_PHASE_MODIFY type ABAP_BOOL default SPACE .
  class-methods CONVERT_DYNAMIC_INOUT_VALUE
    importing
      !IV_VALUE type ANY
      !IV_INOUT_TYPE type I default C_CONVERT_INOUT_TYPE-INTERNAL
      !IV_DATE_FORMAT type CL_ABAP_DATFM=>TY_DATFM optional
      !IV_TIME_FORMAT type CL_ABAP_TIMEFM=>TY_FORMAT default CL_ABAP_TIMEFM=>ENVIRONMENT
    exporting
      !EV_VALUE type ANY .
  class-methods CONVERT_CURR_TO_DECFLOAT
    importing
      !IV_AMOUNT_CURR type P
      !IV_CUKY type SYCURR
    exporting
      !EV_AMOUNT_DECFLOAT type DECFLOAT34 .
  class-methods CONVERT_DECFLOAT_TO_CURR
    importing
      !IV_AMOUNT_DECFLOAT type DECFLOAT
      !IV_CUKY type SYCURR
    exporting
      !EV_AMOUNT_CURR type P
      !EV_ROUNDED type ABAP_BOOL .
  class-methods CHECK_BANK_ACCOUNT_NUMBER
    importing
      !IV_BANKL type ANY
      !IV_BANKN type ANY
      !IV_S_ERROR type /ATL/CL_IL_BANK_NUMBER_CHECK=>TY_LOEVM
      !IV_RES_ONLY type /ATL/CL_IL_BANK_NUMBER_CHECK=>TY_LOEVM optional
    exporting
      !EV_MSG type STRING
    returning
      value(RV_FOUND) type ABAP_BOOL .
  class-methods GET_DYNAMIC_DESCR
    importing
      !IR_DATA type ref to DATA
    exporting
      !EO_OBJECT type ref to OBJECT
      !EV_OBJECT_NAME type STRING
      !ET_COMPONENTS type CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE .
  class-methods GET_TABLE_DESC_FROM_VIEW
    importing
      !IV_VIEW type SXCO_CDS_OBJECT_NAME
    returning
      value(RO_TABLE_DESC) type ref to CL_ABAP_TABLEDESCR .
  class-methods CHECK_AUTHORIZATION
    importing
      !IV_OBJECT type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDOBJECTCL
      !IV_ACTIVITY type IF_CHDO_OBJECT_TOOLS_REL=>TV_ACTIV_AUTH
      !IV_DEVCLASS type IF_CHDO_OBJECT_TOOLS_REL=>TV_CDDEVCLASS
    returning
      value(RV_IS_AUTHORIZED) type ABAP_BOOL .
  class-methods READING_CHANGE_DOCUMENTS
    importing
      !IV_OBJECTCLASS type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDOBJECTCL
      !IT_OBJECTID type CL_CHDO_READ_TOOLS=>TT_R_OBJECTID optional
      !IV_DATE_OF_CHANGE type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDDATUM optional
      !IV_TIME_OF_CHANGE type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDUZEIT optional
      !IV_DATE_UNTIL type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDDATUM optional
      !IV_TIME_UNTIL type IF_CHDO_OBJECT_TOOLS_REL=>TY_CDUZEIT optional
      !IT_USERNAME type CL_CHDO_READ_TOOLS=>TT_R_USER optional
      !IO_READ_ARCHIVE type ref to IF_ARCH_READ_API optional
      !IS_READ_OPTIONS type CL_CHDO_READ_TOOLS=>TY_ATTRIBUTES optional
    exporting
      !ET_CDREDADD_TAB type CL_CHDO_READ_TOOLS=>TT_CDREDADD_TAB
      !EV_ERROR type ABAP_BOOL
      !EV_ERROR_MSG type STRING
    changing
      !CT_CDHDR type CL_CHDO_READ_TOOLS=>TT_CDHDR optional .
  class-methods GET_CALENDAR_UTILITIES
    returning
      value(RO_SCAL_UTILS) type ref to CL_SCAL_UTILS .
  class-methods GET_PDF_MERGER_INSTANCE
    returning
      value(RO_PDF_MERGER) type ref to IF_RSPO_PDF_MERGER .
  class-methods CREATE_ABAP_ZIP
    importing
      !IT_CONTENTS type TT_ZIP_CONTENT
    returning
      value(RV_XSTRING) type XSTRING .
  class-methods PRODUCT_GET_BATCHES
    importing
      !IV_PRODUCT type CL_MD_PRODUCT_GET_BATCHES=>TY_PRODUCT optional
      !IV_BATCH_NUMBER type CL_MD_PRODUCT_GET_BATCHES=>TY_BATCH_NUMBER optional
      !IV_PLANT type CL_MD_PRODUCT_GET_BATCHES=>TY_PLANT optional
      !IV_EXPIRY_DATE_FROM type CL_MD_PRODUCT_GET_BATCHES=>TY_EXPIRY_DATE_FROM optional
      !IV_EXPIRY_DATE_TO type CL_MD_PRODUCT_GET_BATCHES=>TY_EXPIRY_DATE_TO default '99991231'
      !IV_AVAILABLE_DATE_FROM type CL_MD_PRODUCT_GET_BATCHES=>TY_AVAILABLE_DATE_FROM optional
      !IV_AVAILABLE_DATE_TO type CL_MD_PRODUCT_GET_BATCHES=>TY_AVAILABLE_DATE_TO default '99991231'
    exporting
      !ET_BATCHES type CL_MD_PRODUCT_GET_BATCHES=>TT_BATCHES
      !ES_RETURN type CL_MD_PRODUCT_GET_BATCHES=>TY_BAPIRETURN .
  class-methods GET_FACTORYCALENDAR_RUNTIME
    importing
      !IV_FACTORYCALENDAR_ID type CL_FHC_CALENDAR_RUNTIME=>TY_FCAL_ID default C_FACTORYCALENDAR_ID-TH
    returning
      value(RO_FCAL_RUNTIME) type ref to IF_FHC_FCAL_RUNTIME .
  class-methods GET_HOLIDAYCALENDAR_RUNTIME
    importing
      !IV_HOLIDAYCALENDAR_ID type CL_FHC_CALENDAR_RUNTIME=>TY_HCAL_ID default C_FACTORYCALENDAR_ID-TH
    returning
      value(RO_HCAL_RUNTIME) type ref to IF_FHC_HCAL_RUNTIME .
  class-methods GET_HOLIDAY_RUNTIME
    importing
      !IV_HOLIDAY_ID type CL_FHC_CALENDAR_RUNTIME=>TY_HOL_ID                            " Check value from table THOL
    returning
      value(RO_HOLIDAY_RUNTIME) type ref to IF_FHC_HOLIDAY_RUNTIME .
  class-methods CONVERT_DATE_TO_FACTORYDATE
    importing
      !IV_DATE type IF_FHC_FCAL_RUNTIME=>TY_FHC_DATE
      !IV_CORRECT_OPTION type IF_FHC_FCAL_RUNTIME=>TE_CORRECT_OPTION default IF_FHC_FCAL_RUNTIME=>GC_CORRECT_OPTION_PLUS
      !IV_FACTORYCALENDAR_ID type CL_FHC_CALENDAR_RUNTIME=>TY_FCAL_ID default C_FACTORYCALENDAR_ID-TH
    exporting
      !EV_DATE type IF_FHC_FCAL_RUNTIME=>TY_FHC_DATE
      !EV_FACTORYDATE type IF_FHC_FCAL_RUNTIME=>TY_FHC_FACTORYDATE .
  class-methods GET_LAST_DAY_OF_MONTHS
    importing
      !IV_DAY_IN type IF_FHC_FCAL_RUNTIME=>TY_FHC_DATE
    returning
      value(RV_LAST_DAY_OF_MONTH) type IF_FHC_FCAL_RUNTIME=>TY_FHC_DATE
    raising
      CX_SCAL .
  class-methods IS_BATCH_PROCESSING
    returning
      value(RV_BATCH) type CL_FDT_OBJ_SYSTEM_VARIABLES=>TY_SYBATCH .
  class-methods SPLIT_TEXT
    importing
      !IV_TEXT type STRING
      !IV_LEN type I default 256
      !IV_DELIMITER type STRING default SPACE
    exporting
      !ET_SPLIT_TEXTS type TABLE
    raising
      CX_SY_CREATE_DATA_ERROR .
  class-methods TEXT_TO_TLINE_TAB
    importing
      !IV_TEXT type STRING
    returning
      value(RT_LINES) type TT_TLINE .
  class-methods CONVERT_TIMESTAMP_TO_DATETIME
    importing
      !IV_TIMESTAMP type TIMESTAMP optional
      !IV_TIMESTAMPL type TZNTSTMPL optional
      !IV_SET_TIMEZONE type ABAP_BOOL optional
      !IV_UTC_TIMEZONE type ABAP_BOOL optional
    exporting
      !EV_DATE type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_DATE
      !EV_TIME type CL_ABAP_CONTEXT_INFO=>TY_SYSTEM_TIME .
  class-methods GET_PRODUCT
    importing
      !IV_PRODUCT type I_PRODUCT-PRODUCT
    exporting
      !ES_PRODUCT type I_PRODUCT
      !EV_SUBRC type SY-SUBRC .
  class-methods GET_WBSELEMENTDATA
    importing
      !IV_WBSELEMENTINTERNALID type I_WBSELEMENTBASICDATA-WBSELEMENTINTERNALID optional
      !IV_WBSELEMENTEXTERNALID type I_WBSELEMENTBASICDATA-WBSELEMENTEXTERNALID optional
      !IV_WBSELEMENT type I_WBSELEMENTBASICDATA-WBSELEMENT optional
    exporting
      !ES_WBSELEMENTDATA type I_WBSELEMENTBASICDATA
      !EV_SUBRC type SY-SUBRC .
  class-methods ADD_SUBTRACT_CALC_DATE
    importing
      !IV_DATE type D
      !IV_DAY type I default 0
      !IV_MONTH type I default 0
      !IV_YEAR type I default 0
      !IV_SIGN type TY_CHAR1 default '+'
      !IO_CALCULATION type ref to IF_XCO_DATE_CALCULATION default XCO_CP_TIME=>DATE_CALCULATION->ULTIMO
    returning
      value(RV_DATE) type D .
  class-methods ADD_SUBTRACT_CALC_DATE_TIME
    importing
      !IV_DATE type D
      !IV_TIME type T optional
      !IV_DAY type I default 0
      !IV_MONTH type I default 0
      !IV_YEAR type I default 0
      !IV_HOUR type I default 0
      !IV_MINUTE type I default 0
      !IV_SECOND type I default 0
      !IV_SIGN type TY_CHAR1 default '+'
      !IO_CALCULATION type ref to IF_XCO_DATE_CALCULATION default XCO_CP_TIME=>DATE_CALCULATION->ULTIMO
    exporting
      !EV_DATE type D
      !EV_TIME type T .
  class-methods ZSPELL_AMOUNT
    importing
      value(IV_CURRENCY) type WAERK
      value(IV_LANGUAGE) type SPRAS
      value(IV_AMOUNT) type ANY
    exporting
      value(EV_SPELL_AMOUNT) type STRING .
  class-methods TEXT_TO_MSGVN
    importing
      !IV_TEXT type ANY
      !IV_LEN type I default 50
    exporting
      !EV_MSGV1 type ANY
      !EV_MSGV2 type ANY
      !EV_MSGV3 type ANY
      !EV_MSGV4 type ANY .
  class-methods CHECK_PRODUCTION_CLIENT
    returning
      value(RV_PRODUCTION) type ABAP_BOOL .
  class-methods SY_TO_S_MSG
    importing
      !IV_MSGTY type MSGTY default C_MSGTY_E
    returning
      value(RS_MSG) type BAPIRET2 .
  class-methods SY_TO_T_MSG
    importing
      !IV_MSGTY type MSGTY default C_MSGTY_E
    changing
      !CT_MSG type BAPIRETTAB .
private section.

  class-data GO_ABAP_LOCAL type ref to LCL_ABAP_UTILITIES_LOCAL .
ENDCLASS.



CLASS ZCL_EXT_ABAP_UTILITIES IMPLEMENTATION.


  METHOD assign_x_structure.
    ASSIGN: is_n TO FIELD-SYMBOL(<ls_struct_n>),
            cs_x TO FIELD-SYMBOL(<ls_struct_x>).

    DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( cs_x ) ).
    DATA(lt_components) = lo_structdescr->get_components( ).

    <ls_struct_x> = CORRESPONDING #( <ls_struct_n> ).

    DO.
      DATA(lv_ind) = sy-index.

      ASSIGN COMPONENT lv_ind OF STRUCTURE <ls_struct_x> TO FIELD-SYMBOL(<lv_field_x>).
      IF sy-subrc = 0.

        READ TABLE lt_components INTO DATA(ls_component) INDEX lv_ind.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT ls_component-name OF STRUCTURE <ls_struct_n> TO FIELD-SYMBOL(<lv_field_n>).
        IF sy-subrc = 0 AND <lv_field_n> IS NOT INITIAL.
          <lv_field_x> = cl_abap_behv=>flag_changed.
        ENDIF.

      ELSE.
        EXIT.
      ENDIF.

    ENDDO.
  ENDMETHOD.


  METHOD build_xml_pdf.
    " ---------------------------------------------------------------------
    " Use Class ZCL_EXT_PDF_UTILITIES instead
    " ---------------------------------------------------------------------
    DATA lo_object TYPE REF TO object.

    DATA(lt_ptab)  = VALUE abap_parmbind_tab( ).
    FINAL(lv_meth) = `BUILD_XML_PDF`.

    TRY.
        CREATE OBJECT lo_object TYPE (`ZCL_EXT_PDF_UTILITIES`).

        IF lo_object IS BOUND.
          lt_ptab = VALUE abap_parmbind_tab( ( name  = 'IV_FORM_NAME'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_form_name ) )
                                             ( name  = 'IV_PAGE_NAME'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_page_name ) )
                                             ( name  = 'EV_ERROR'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_error ) )
                                             ( name  = 'EV_MSG'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_msg ) )
                                             ( name  = 'CS_DATA'
                                               kind  = cl_abap_objectdescr=>changing
                                               value = REF #( cs_data ) )
                                             ( name  = 'CT_DATA'
                                               kind  = cl_abap_objectdescr=>changing
                                               value = REF #( ct_data ) )
                                             ( name  = 'RV_XMLPDF'
                                               kind  = cl_abap_objectdescr=>receiving
                                               value = REF #( rv_xmlpdf ) ) ).
          IF cs_data IS SUPPLIED.
            DELETE lt_ptab WHERE name = 'CT_DATA'.
          ELSEIF ct_data IS SUPPLIED.
            DELETE lt_ptab WHERE name = 'CS_DATA'.
          ENDIF.

          CALL METHOD lo_object->(lv_meth)
            PARAMETER-TABLE lt_ptab.
        ENDIF.
      CATCH cx_root INTO DATA(lx_error).
        ev_error = abap_true.
        ev_msg   = lx_error->get_longtext( ).
    ENDTRY.

**    DATA lv_xml_string TYPE string.
**
**    CLEAR rv_xmlpdf.
**    CLEAR: ev_error,
**           ev_msg.
**
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**    " - Generate XML to XSD:
**    "       https://www.freeformatter.com/xsd-generator.html#before-output
**    " - XML Formatter:
**    "       https://www.freeformatter.com/xml-formatter.html#before-output
**    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
**
**    rv_xmlpdf = |{ c_xml_tag }<{ iv_form_name }>|.
**
**    IF cs_data IS SUPPLIED.
**      transformation_to_xml( EXPORTING it_srcbind = VALUE #( ( name = iv_page_name value = REF #( cs_data ) ) )
**                             IMPORTING ev_string  = lv_xml_string ).
**
**      rv_xmlpdf = rv_xmlpdf && lv_xml_string.
**    ELSEIF ct_data IS SUPPLIED.
**      LOOP AT ct_data ASSIGNING FIELD-SYMBOL(<ls_data>).
**
**        transformation_to_xml( EXPORTING it_srcbind = VALUE #( ( name = iv_page_name value = REF #( <ls_data> ) ) )
**                               IMPORTING ev_string  = lv_xml_string ).
**
**        rv_xmlpdf = rv_xmlpdf && lv_xml_string.
**
**      ENDLOOP.
**    ELSE.
**      CLEAR rv_xmlpdf.
**      ev_error = abap_true.
**      ev_msg   = 'CS_DATA or CT_DATA parameters must be passed'.
**      RETURN.
**    ENDIF.
**
**    rv_xmlpdf = |{ rv_xmlpdf }</{ iv_form_name }>|.
**    rv_xmlpdf = condense( rv_xmlpdf ).
  ENDMETHOD.


  METHOD build_xml_pdf_with_encode_x64.
    " TODO: parameter EV_XMLPDF is only cleared or assigned in commented-out code (ABAP cleaner)
    " TODO: parameter EV_ENCODEX64 is never cleared or assigned (ABAP cleaner)

    " ---------------------------------------------------------------------
    " Use Class ZCL_EXT_PDF_UTILITIES instead
    " ---------------------------------------------------------------------
    DATA lo_object TYPE REF TO object.

    DATA(lt_ptab)  = VALUE abap_parmbind_tab( ).

    FINAL(lv_meth) = `BUILD_XML_PDF_WITH_ENCODE_X64`.

    TRY.
        CREATE OBJECT lo_object TYPE (`ZCL_EXT_PDF_UTILITIES`).

        IF lo_object IS BOUND.
          lt_ptab = VALUE abap_parmbind_tab( ( name  = 'IV_FORM_NAME'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_form_name ) )
                                             ( name  = 'IV_PAGE_NAME'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_page_name ) )
                                             ( name  = 'EV_XMLPDF'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_xmlpdf ) )
                                             ( name  = 'EV_ENCODEX64'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_encodex64 ) )
                                             ( name  = 'CS_DATA'
                                               kind  = cl_abap_objectdescr=>changing
                                               value = REF #( cs_data ) )
                                             ( name  = 'CT_DATA'
                                               kind  = cl_abap_objectdescr=>changing
                                               value = REF #( ct_data ) ) ).
          IF cs_data IS SUPPLIED.
            DELETE lt_ptab WHERE name = 'CT_DATA'.
          ELSEIF ct_data IS SUPPLIED.
            DELETE lt_ptab WHERE name = 'CS_DATA'.
          ENDIF.

          CALL METHOD lo_object->(lv_meth)
            PARAMETER-TABLE lt_ptab.
        ENDIF.
      CATCH cx_root INTO DATA(lx_error).
        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA(lv_error_msg) = lx_error->get_longtext( ).
    ENDTRY.

**    CLEAR: ev_xmlpdf,
**           ev_encodex64.
**
**    ev_xmlpdf = build_xml_pdf( EXPORTING iv_form_name = iv_form_name
**                                         iv_page_name = iv_page_name
**                               CHANGING  cs_data      = cs_data
**                                         ct_data      = ct_data ).
**
**    IF ev_xmlpdf IS NOT INITIAL.
**      ev_encodex64 = encode_string_to_x64( iv_string = ev_xmlpdf ).
**    ENDIF.
  ENDMETHOD.


  METHOD check_bank_account_number.
    rv_found = go_abap_local->check_bank_account_number( EXPORTING iv_bankl    = iv_bankl
                                                                   iv_bankn    = iv_bankn
                                                                   iv_s_error  = iv_s_error
                                                                   iv_res_only = iv_res_only
                                                         IMPORTING ev_msg      = ev_msg ).
  ENDMETHOD.


  METHOD class_constructor.
    IF go_abap_local IS NOT BOUND.
      go_abap_local = NEW #( ).
    ENDIF.
  ENDMETHOD.


  METHOD convert_curr_to_decfloat.
*    rv_amount_decfloat = cl_abap_decfloat=>convert_curr_to_decfloat( amount_curr = iv_amount_curr
*                                                                     cuky        = iv_cuky ).

    DATA lv_shift TYPE i.

    CLEAR ev_amount_decfloat.

    DATA(lv_decimal_places) = cl_abap_decfloat=>get_decimal_places_for_cuky( cuky = iv_cuky ).

    lv_shift = 2 - lv_decimal_places.
    ev_amount_decfloat = iv_amount_curr * ( 10 ** lv_shift ).
  ENDMETHOD.


  METHOD convert_decfloat_to_curr.
*    cl_abap_decfloat=>convert_decfloat_to_curr( EXPORTING amount_decfloat = iv_amount_decfloat
*                                                          cuky            = iv_cuky
*                                                IMPORTING amount_curr     = ev_amount_curr
*                                                          rounded         = ev_rounded ).

    DATA lv_shift TYPE i.

    CLEAR: ev_amount_curr,
           ev_rounded.

    DATA(lv_decimal_places) = cl_abap_decfloat=>get_decimal_places_for_cuky( cuky = iv_cuky ).

    lv_shift = lv_decimal_places - 2.
    ev_amount_curr = iv_amount_decfloat * ( 10 ** lv_shift ).
  ENDMETHOD.


  METHOD convert_dynamic_inout_value.
    IF ev_value IS NOT SUPPLIED.
      RETURN.
    ENDIF.

    DATA(lo_elemdescr) = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( ev_value ) ).

    IF lo_elemdescr IS NOT BOUND.
      ev_value = iv_value.
      RETURN.
    ENDIF.

    CASE iv_inout_type.
      WHEN c_convert_inout_type-internal.
        go_abap_local->convert_dynamic_intern_value( EXPORTING iv_value       = iv_value
                                                               iv_inout_type  = iv_inout_type
                                                               iv_inttype     = lo_elemdescr->type_kind
                                                               iv_convexit    = lo_elemdescr->edit_mask
                                                               iv_date_format = iv_date_format
                                                     IMPORTING ev_value       = ev_value ).
      WHEN c_convert_inout_type-external.
        go_abap_local->convert_dynamic_extern_value( EXPORTING iv_value       = iv_value
                                                               iv_inout_type  = iv_inout_type
                                                               iv_inttype     = lo_elemdescr->type_kind
                                                               iv_convexit    = lo_elemdescr->edit_mask
                                                               iv_date_format = iv_date_format
                                                               iv_time_format = iv_time_format
                                                     IMPORTING ev_value       = ev_value ).
      WHEN OTHERS.
        ev_value = iv_value.
    ENDCASE.
  ENDMETHOD.


  METHOD convert_product_unit.
    DATA lv_output_source TYPE menge_d.
    DATA lv_output_target TYPE menge_d.
    DATA lv_unit_in       TYPE meins.
    DATA lv_unit_out      TYPE meins.

    CLEAR: ev_output,
           ev_error,
           ev_message.

    get_product( EXPORTING iv_product = iv_product
                 IMPORTING es_product = DATA(ls_material) ).

    lv_unit_in  = iv_unit_in.
    lv_unit_out = iv_unit_out.

    IF iv_tointernalunit IS NOT INITIAL.
      get_unitofmeasure( EXPORTING iv_unit    = lv_unit_in
                         IMPORTING ev_unit_in = lv_unit_in ).

      get_unitofmeasure( EXPORTING iv_unit    = lv_unit_out
                         IMPORTING ev_unit_in = lv_unit_out ).
    ENDIF.

    TRY.
        IF    lv_unit_in IS INITIAL
           OR lv_unit_in  = ls_material-baseunit.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Convert Base Unit --> Alternative Unit
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          cl_md_product_unit_conversion=>convert( EXPORTING input                = iv_input
                                                            is_alternativeunit   = space
                                                            product              = iv_product
                                                            alternativeunit      = lv_unit_out
                                                            clfnobjectinternalid = iv_clfnobjectinternalid
                                                            batch                = iv_batch
                                                            plant                = iv_plant
                                                  IMPORTING output               = ev_output
                                                  CHANGING  baseunit             = lv_unit_in ).
        ELSEIF     lv_unit_in IS NOT INITIAL
               AND (    lv_unit_out IS INITIAL
                     OR lv_unit_out  = ls_material-baseunit ).
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Convert Alternative Unit --> Base Unit
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          cl_md_product_unit_conversion=>convert( EXPORTING input                = iv_input
                                                            is_alternativeunit   = abap_true
                                                            product              = iv_product
                                                            alternativeunit      = lv_unit_in
                                                            clfnobjectinternalid = iv_clfnobjectinternalid
                                                            batch                = iv_batch
                                                            plant                = iv_plant
                                                  IMPORTING output               = ev_output
                                                  CHANGING  baseunit             = lv_unit_out ).
        ELSEIF     lv_unit_in  IS NOT INITIAL
               AND lv_unit_out IS NOT INITIAL
               AND lv_unit_in  <> ls_material-baseunit
               AND lv_unit_out <> ls_material-baseunit.
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " Convert Alternative Unit --> Alternative Unit
          """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
          cl_md_product_unit_conversion=>convert( EXPORTING input                = iv_input
                                                            is_alternativeunit   = abap_true
                                                            product              = iv_product
                                                            alternativeunit      = lv_unit_in
                                                            clfnobjectinternalid = iv_clfnobjectinternalid
                                                            batch                = iv_batch
                                                            plant                = iv_plant
                                                  IMPORTING output               = lv_output_source ).

          cl_md_product_unit_conversion=>convert( EXPORTING input                = iv_input
                                                            is_alternativeunit   = abap_true
                                                            product              = iv_product
                                                            alternativeunit      = lv_unit_out
                                                            clfnobjectinternalid = iv_clfnobjectinternalid
                                                            batch                = iv_batch
                                                            plant                = iv_plant
                                                  IMPORTING output               = lv_output_target ).

          IF iv_is_alternativeunit IS INITIAL.
            IF lv_output_target <> 0.
              ev_output = lv_output_source / lv_output_target.
            ELSE.
              ev_output = 0.
            ENDIF.
          ELSE.
            IF lv_output_target <> 0.
              ev_output = lv_output_target / lv_output_source.
            ELSE.
              ev_output = 0.
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH cx_md_product_unit_conversion INTO DATA(lx_excpt).
        ev_message = lx_excpt->get_text( ).
        ev_error   = abap_true.
    ENDTRY.

    IF iv_set_floor IS NOT INITIAL.
      ev_output = floor( ev_output ).
    ELSEIF iv_set_ceil IS NOT INITIAL.
      ev_output = ceil( ev_output ).
    ENDIF.
  ENDMETHOD.


  METHOD convert_string_to_decimal.
    " Expected input, sample £10.000,52
    " Output should be 10000.52

    CHECK    cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'C'
          OR cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'P'
          OR cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'F'
          OR cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'I'
          OR cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'N'.

    TRY.
        iv_input = condense( val  = iv_input
                             from = ` `
                             to   = `` ).

*        REPLACE ALL OCCURRENCES OF REGEX '[^(0-9.,)]' IN iv_input WITH ''.
        REPLACE ALL OCCURRENCES OF PCRE '[^(0-9.,)]' IN iv_input WITH ''.

        IF iv_input IS NOT INITIAL.
          FIND ALL OCCURRENCES OF '.' IN iv_input MATCH COUNT DATA(lv_dot_count).
          FIND ALL OCCURRENCES OF ',' IN iv_input MATCH COUNT DATA(lv_comma_count).

          IF lv_dot_count > 1.
            REPLACE ALL OCCURRENCES OF SUBSTRING '.' IN iv_input WITH ''.
            iv_input = translate( val  = iv_input
                                  from = `,`
                                  to   = `.` ).

          ELSEIF lv_comma_count > 1.
            REPLACE ALL OCCURRENCES OF SUBSTRING ',' IN iv_input WITH ''.

          ELSE.
            FIND FIRST OCCURRENCE OF '.' IN iv_input MATCH OFFSET DATA(lv_dot_place).
            FIND FIRST OCCURRENCE OF ',' IN iv_input MATCH OFFSET DATA(lv_comma_place).

            "£10.000,00 -> 10,000.00
            IF lv_dot_place IS NOT INITIAL AND lv_comma_place IS NOT INITIAL.
              IF lv_dot_place < lv_comma_place.
                iv_input = translate( val  = iv_input
                                      from = `,`
                                      to   = `;` ).
                REPLACE ALL OCCURRENCES OF SUBSTRING '.' IN iv_input WITH ''.
                iv_input = translate( val  = iv_input
                                      from = `;`
                                      to   = `.` ).
              ELSE.
                REPLACE ALL OCCURRENCES OF SUBSTRING ',' IN iv_input WITH ''.
              ENDIF.

                                                            "£10000,00
            ELSEIF lv_dot_place IS INITIAL AND lv_comma_place IS NOT INITIAL.
              iv_input = translate( val  = iv_input
                                    from = `,`
                                    to   = `.` ).
            ENDIF.
          ENDIF.

          ev_output = iv_input.

          IF cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'C'.
            ev_output = condense( val  = ev_output
                                  from = ` `
                                  to   = `` ).
          ELSEIF cl_abap_datadescr=>get_data_type_kind( p_data = ev_output ) = 'N'.
            REPLACE ALL OCCURRENCES OF ',' IN iv_input WITH ''.
            REPLACE ALL OCCURRENCES OF '.' IN iv_input WITH ''.
            ev_output = iv_input.
          ENDIF.
        ENDIF.

        ev_f_success = 'X'.

      CATCH cx_root INTO DATA(lx_error). " TODO: variable is assigned but never used (ABAP cleaner)
    ENDTRY.
  ENDMETHOD.


  METHOD convert_string_to_xstring.
    CLEAR: ev_rawstring,
           ev_encode_x64.

    IF iv_string IS INITIAL.
      RETURN.
    ENDIF.

    IF ev_rawstring IS SUPPLIED.
      ev_rawstring = /ui2/cl_json=>string_to_raw( iv_string   = iv_string
                                                  iv_encoding = iv_encoding ).
    ENDIF.

    IF ev_encode_x64 IS SUPPLIED.
      /ui2/cl_json=>string_to_xstring( EXPORTING in  = iv_string
                                       CHANGING  out = ev_encode_x64 ).
    ENDIF.
  ENDMETHOD.


  METHOD convert_xstring_to_string.
    CLEAR: ev_string,
           ev_decode_x64.

    IF iv_xstring IS INITIAL.
      RETURN.
    ENDIF.

    IF ev_string IS SUPPLIED.
      ev_string = /ui2/cl_json=>raw_to_string( iv_xstring  = iv_xstring
                                               iv_encoding = iv_encoding ).
    ENDIF.

    IF ev_decode_x64 IS SUPPLIED.
      ev_decode_x64 = /ui2/cl_json=>xstring_to_string( in = iv_xstring ).
    ENDIF.
  ENDMETHOD.


  METHOD create_bali_log.
    " TODO: parameter IV_EXTERNAL_ID is never used (ABAP cleaner)

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Document:
    "   - https://help.sap.com/docs/SAP_S4HANA_CLOUD/6aa39f1ac05441e5a23f484f31e477e7/f7c20f7b2fce4fbaba79ae0c5182d869.html
    "   - https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/creating-change-document-objects
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " severity: use if_bali_constants
    "   c_severity_default      type if_bali_constants=>ty_severity value c_severity_status
    "   c_severity_error        type if_bali_constants=>ty_severity value 'E'
    "   c_severity_exit         type if_bali_constants=>ty_severity value 'X'
    "   c_severity_information  type if_bali_constants=>ty_severity value 'I'
    "   c_severity_status       type if_bali_constants=>ty_severity value 'S'
    "   c_severity_termination  type if_bali_constants=>ty_severity value 'A'
    "   c_severity_warning      type if_bali_constants=>ty_severity value 'W'
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lo_message      TYPE REF TO if_bali_message_setter.
    DATA lo_free_message TYPE REF TO if_bali_free_text_setter.

    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object    = iv_object
                                                                                       subobject = iv_subobject ) ).
        IF lo_log IS NOT BOUND.
          RETURN.
        ENDIF.

        " Add a message as item to the log
        LOOP AT it_message INTO FINAL(ls_message).
          lo_message = cl_bali_message_setter=>create( severity   = ls_message-severity
                                                       id         = ls_message-id
                                                       number     = ls_message-number
                                                       variable_1 = ls_message-variable_1
                                                       variable_2 = ls_message-variable_2
                                                       variable_3 = ls_message-variable_3
                                                       variable_4 = ls_message-variable_4 ).
          lo_log->add_item( item = lo_message ).
        ENDLOOP.

**    "Add a second message, this time from system fields SY-MSGID, ...
**    MESSAGE ID 'ZTEST' TYPE 'S' NUMBER '058' INTO DATA(l_text).
**
**    lo_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

        " Add a free text to the log
        LOOP AT it_free_message INTO FINAL(ls_free_message).
          lo_free_message = cl_bali_free_text_setter=>create( severity = ls_free_message-severity
                                                              text     = ls_free_message-text ).
          lo_log->add_item( item = lo_free_message ).
        ENDLOOP.

        " Save the log into the database
        cl_bali_log_db=>get_instance( )->save_log( log                        = lo_log
                                                   assign_to_current_appl_job = iv_assign_to_appl_job ).
        IF iv_commit_work IS NOT INITIAL.
          COMMIT WORK.
        ENDIF.
      CATCH cx_bali_runtime INTO DATA(lx_bali_error). " TODO: variable is assigned but never used (ABAP cleaner)
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD date_is_valid.
    DATA lv_date TYPE d.

    rv_valid_date = abap_true.

    lv_date = COND #( WHEN iv_date IS INITIAL THEN '00000000' ELSE iv_date ).
    IF lv_date IS INITIAL.
      RETURN.
    ENDIF.

    lv_date += 1.
    IF lv_date CP '000101*'.
      rv_valid_date = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD date_plausibility_check.
    DATA lv_check_year_1 TYPE p LENGTH 8 DECIMALS 0.
    DATA lv_check_year_2 TYPE p LENGTH 8 DECIMALS 0.

    CLEAR rv_valid_date.
    rv_valid_date = abap_true.

    IF iv_date CN '0123456789'.
      rv_valid_date = abap_false.
    ENDIF.

    IF    iv_date+4(2) < '01'
       OR iv_date+4(2) > '12'.
      rv_valid_date = abap_false.
    ENDIF.

    IF    iv_date+6(2) < '01'
       OR iv_date+6(2) > '31'.
      rv_valid_date = abap_false.
    ENDIF.

    IF    iv_date+4(2) = '01'
       OR iv_date+4(2) = '03'
       OR iv_date+4(2) = '05'
       OR iv_date+4(2) = '07'
       OR iv_date+4(2) = '08'
       OR iv_date+4(2) = '10'
       OR iv_date+4(2) = '12'.
      IF iv_date+6(2) > '31'.
        rv_valid_date = abap_false.
      ENDIF.
    ELSEIF    iv_date+4(2) = '04'
           OR iv_date+4(2) = '06'
           OR iv_date+4(2) = '09'
           OR iv_date+4(2) = '11'.
      IF iv_date+6(2) > '30'.
        rv_valid_date = abap_false.
      ENDIF.
    ELSE.
      lv_check_year_1 = iv_date(4) MOD 4.      " alle 4 Jahre ist schaltjahr
      IF lv_check_year_1 = 0.
        lv_check_year_1 = iv_date(4) MOD 100.  " aber nicht alle 100 Jahre
        lv_check_year_2 = iv_date(4) MOD 400.  " aber alle 400 Jahre
        IF     lv_check_year_1  = 0
           AND lv_check_year_2 <> 0.
          IF iv_date+6(2) > '28'.
            rv_valid_date = abap_false.
          ENDIF.
        ELSE.
          IF iv_date+6(2) > '29'.
            rv_valid_date = abap_false.
          ENDIF.
        ENDIF.
      ELSE.
        IF iv_date+6(2) > '28'.
          rv_valid_date = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD encode_string_to_x64.
    CLEAR rv_encode_x64.

*    rv_encode_x64 = /ui2/cl_json=>xstring_to_string( in = /ui2/cl_json=>string_to_raw( iv_string   = iv_string
*                                                                                       iv_encoding = '' ) ).
    rv_encode_x64 = cl_web_http_utility=>encode_x_base64( /ui2/cl_json=>string_to_raw( iv_string   = iv_string
                                                                                       iv_encoding = iv_encoding ) ).
  ENDMETHOD.


  METHOD get_businesspartner_details.
    DATA lt_bp TYPE tt_businesspartner.

    CLEAR et_businesspartner.

    IF it_partner[] IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_partner) = it_partner.

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<lv_partner>).
      READ TABLE gt_businesspartner ASSIGNING FIELD-SYMBOL(<ls_businesspartner>) BINARY SEARCH
           WITH KEY businesspartner = <lv_partner>.
      IF sy-subrc = 0.
        INSERT <ls_businesspartner> INTO TABLE et_businesspartner.
      ELSE.
        INSERT <ls_businesspartner> INTO TABLE lt_bp.
      ENDIF.
    ENDLOOP.

    IF lt_bp[] IS NOT INITIAL.
      SELECT FROM i_businesspartner
        FIELDS *
        FOR ALL ENTRIES IN @lt_bp
        WHERE businesspartner = @lt_bp-businesspartner
        INTO TABLE @DATA(lt_businesspartner).
      IF lt_businesspartner IS NOT INITIAL.
        INSERT LINES OF lt_businesspartner INTO TABLE gt_businesspartner.
        INSERT LINES OF lt_businesspartner INTO TABLE et_businesspartner.

        SORT: gt_businesspartner BY businesspartner,
              et_businesspartner BY businesspartner.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_current_date_time.
    DATA lv_timezone TYPE cl_abap_context_info=>ty_time_zone.

    CLEAR: ev_date,
           ev_time.

    IF    iv_timezone       IS NOT INITIAL
       OR iv_user_time_zone IS NOT INITIAL.
      GET TIME STAMP FIELD DATA(lv_timestamp).

      IF iv_timezone IS NOT INITIAL.
        lv_timezone = |{ iv_timezone CASE = UPPER }|.
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE ev_date TIME ev_time.
      ELSEIF iv_user_time_zone IS NOT INITIAL.
        TRY.
            lv_timezone = cl_abap_context_info=>get_user_time_zone(
                              iv_buser = CONV #( cl_abap_context_info=>get_user_technical_name( ) ) ).
            CONVERT TIME STAMP lv_timestamp TIME ZONE lv_timezone INTO DATE ev_date TIME ev_time.
          CATCH cx_abap_context_info_error.
            ev_date = cl_fdt_obj_system_variables=>get_current_date( ).
            ev_time = cl_fdt_obj_system_variables=>get_current_time( ).
        ENDTRY.
      ENDIF.
    ELSE.
      ev_date = cl_abap_context_info=>get_system_date( ).
      ev_time = cl_abap_context_info=>get_system_time( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_current_thailand_date_time.
    CLEAR: ev_date,
           ev_time.

    ev_timezone = 'UTC+7'.

    get_current_date_time( EXPORTING iv_timezone = 'UTC+7'
                           IMPORTING ev_date     = ev_date
                                     ev_time     = ev_time ).
  ENDMETHOD.


  METHOD get_current_timestamp.
    GET TIME STAMP FIELD rv_timestamp.
  ENDMETHOD.


  METHOD get_current_timestamp_long.
    GET TIME STAMP FIELD rv_timestampl.
  ENDMETHOD.


  METHOD get_customer_supplier_details.
    DATA lt_bp_d TYPE tt_customer.
    DATA lt_bp_k TYPE tt_supplier.
    FIELD-SYMBOLS <lv_partner> LIKE LINE OF it_partner.

    CLEAR: et_customer,
           et_supplier.

    IF it_partner[] IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_partner) = it_partner.

    CASE iv_type.
      WHEN c_koart_d.
        LOOP AT lt_partner ASSIGNING <lv_partner>.
          READ TABLE gt_customer ASSIGNING FIELD-SYMBOL(<ls_customer>) BINARY SEARCH
               WITH KEY customer = <lv_partner>.
          IF sy-subrc = 0.
            INSERT <ls_customer> INTO TABLE et_customer.
          ELSE.
            INSERT <ls_customer> INTO TABLE lt_bp_d.
          ENDIF.
        ENDLOOP.

        IF lt_bp_d IS NOT INITIAL.
          SELECT FROM i_customer
            FIELDS *
            FOR ALL ENTRIES IN @lt_bp_d
            WHERE customer = @lt_bp_d-customer
            INTO TABLE @DATA(lt_customer).
          IF lt_customer IS NOT INITIAL.
            INSERT LINES OF lt_customer INTO TABLE gt_customer.
            INSERT LINES OF lt_customer INTO TABLE et_customer.

            SORT: gt_customer BY customer,
                  et_customer BY customer.
          ENDIF.
        ENDIF.
      WHEN c_koart_k.
        LOOP AT lt_partner ASSIGNING <lv_partner>.
          READ TABLE gt_supplier ASSIGNING FIELD-SYMBOL(<ls_supplier>) BINARY SEARCH
               WITH KEY supplier = <lv_partner>.
          IF sy-subrc = 0.
            INSERT <ls_supplier> INTO TABLE et_supplier.
          ELSE.
            INSERT <ls_supplier> INTO TABLE lt_bp_k.
          ENDIF.
        ENDLOOP.

        IF lt_bp_k IS NOT INITIAL.
          SELECT FROM i_supplier
            FIELDS *
            FOR ALL ENTRIES IN @lt_bp_k
            WHERE supplier = @lt_bp_k-supplier
            INTO TABLE @DATA(lt_supplier).
          IF lt_supplier IS NOT INITIAL.
            INSERT LINES OF lt_supplier INTO TABLE gt_supplier.
            INSERT LINES OF lt_supplier INTO TABLE et_supplier.

            SORT: gt_supplier BY supplier,
                  et_supplier BY supplier.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.


  METHOD access_custom_business_object.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Reference Link:
    "  https://help.sap.com/docs/SAP_S4HANA_CLOUD/0f69f8fb28ac4bf48d2b57b9637e81fa/6d62cdaaac194dac9bf13802b9e6cd04.html
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lt_root_data       TYPE TABLE OF REF TO data.
    DATA lt_child_data      TYPE TABLE OF REF TO data.
    DATA lr_root_data       TYPE REF TO data.
    DATA lr_child_data      TYPE REF TO data.
    DATA ls_business_object TYPE ts_business_object.

    CLEAR: es_root_node_obj,
           et_child_node_obj,
           et_business_object.

    DATA(lo_data_retrieval) = cl_cbo_developer_access=>business_object( to_upper( iv_business_object ) ).
    IF lo_data_retrieval IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lo_root) = lo_data_retrieval->root_node( )->data_retrieval( ).
    IF lo_root IS BOUND.
      DATA(lt_root_records) = lo_root->get_records( )->resolve( ).

      LOOP AT lt_root_records INTO DATA(lo_root_records).
        DATA(lr_root_data_object) = lo_root_records->get_data_object( )->get_reference( ).
        IF lr_root_data_object IS BOUND.
          lr_root_data = REF #( lr_root_data_object->* ).
          INSERT lr_root_data INTO TABLE lt_root_data.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CLEAR ls_business_object.
    ls_business_object-name           = to_upper( iv_business_object ).
    ls_business_object-type           = 'ROOT'.
    ls_business_object-is_root        = abap_true.
    ls_business_object-data_retrieval = COND #( WHEN lo_data_retrieval IS BOUND THEN lo_data_retrieval ).
    ls_business_object-records_lists  = COND #( WHEN lo_root IS BOUND THEN lo_root->get_records( )->resolve( ) ).
    ls_business_object-t_data         = lt_root_data.
    INSERT ls_business_object INTO TABLE et_business_object.

    es_root_node_obj = ls_business_object.

    LOOP AT it_child_node_id INTO DATA(ls_child_node_id) WHERE table_line IS NOT INITIAL.
      DATA(lo_child) = lo_data_retrieval->child_node( iv_child_node_id = ls_child_node_id )->data_retrieval( ).
      IF lo_child IS BOUND.
        DATA(lt_childrecords) = lo_child->get_records( )->resolve( ).

        LOOP AT lt_childrecords INTO DATA(lo_child_records).
          DATA(lr_child_data_object) = lo_child_records->get_data_object( )->get_reference( ).
          IF lr_child_data_object IS BOUND.
            lr_child_data = REF #( lr_child_data_object->* ).
            INSERT lr_child_data INTO TABLE lt_child_data.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR ls_business_object.
      ls_business_object-name           = to_upper( ls_child_node_id ).
      ls_business_object-type           = 'CHILD'.
      ls_business_object-is_root        = space.
      ls_business_object-data_retrieval = COND #( WHEN lo_data_retrieval IS BOUND THEN lo_data_retrieval ).
      ls_business_object-records_lists  = COND #( WHEN lo_child IS BOUND THEN lo_child->get_records( )->resolve( ) ).
      ls_business_object-t_data         = lt_child_data.
      INSERT ls_business_object INTO TABLE et_business_object.
      INSERT ls_business_object INTO TABLE et_child_node_obj.

      CLEAR: lo_child,
             lt_childrecords,
             lt_child_data,
             lr_child_data.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_dynamic_descr.
    CLEAR: eo_object,
           ev_object_name,
           et_components.

    go_abap_local->get_dynamic_describe( EXPORTING ir_data        = ir_data
                                         IMPORTING eo_object      = eo_object
                                                   ev_object_name = ev_object_name
                                                   et_components  = et_components ).
  ENDMETHOD.


  METHOD get_table_desc_from_view.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Example: https://community.sap.com/t5/technology-q-a/xco-library-deep-nested-structure/qaq-p/12637411
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " get fields from current view entity
    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( iv_view ) ).
    DATA(lt_comp) = lo_struct->get_components( ).

    " get compositions from view entity
    LOOP AT xco_cp_cds=>view_entity( iv_view )->compositions->all->get( ) INTO DATA(lo_composition).
      APPEND INITIAL LINE TO lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
      <ls_comp>-name = lo_composition->content( )->get( )-alias.
      <ls_comp>-type = get_table_desc_from_view( lo_composition->target ).
    ENDLOOP.

    " build output
    TRY.
        ro_table_desc = cl_abap_tabledescr=>create( cl_abap_structdescr=>create( lt_comp ) ).
      CATCH cx_sy_table_creation
            cx_sy_struct_creation.
    ENDTRY.
  ENDMETHOD.


  METHOD get_unitofmeasure.
    DATA ls_unitofmeasure LIKE LINE OF gt_unitofmeasure.
    DATA lv_select_string TYPE string.
    DATA lv_unit          TYPE i_unitofmeasure-unitofmeasure.

    CHECK iv_unit IS NOT INITIAL.

    CLEAR: es_unitofmeasure,
           ev_unit_in,
           ev_unit_out.

    lv_unit = |{ iv_unit CASE = UPPER }|.

    READ TABLE gt_unitofmeasure INTO ls_unitofmeasure
         WITH TABLE KEY unitofmeasure = lv_unit.
    IF sy-subrc = 0.
      es_unitofmeasure = ls_unitofmeasure.
      ev_unit_in       = ls_unitofmeasure-unitofmeasure.
      ev_unit_out      = ls_unitofmeasure-unitofmeasure_e.
      RETURN.
    ENDIF.

    READ TABLE gt_unitofmeasure INTO ls_unitofmeasure
         WITH KEY k2 COMPONENTS unitofmeasure_e = lv_unit.
    IF sy-subrc = 0.
      es_unitofmeasure = ls_unitofmeasure.
      ev_unit_in       = ls_unitofmeasure-unitofmeasure.
      ev_unit_out      = ls_unitofmeasure-unitofmeasure_e.
      RETURN.
    ENDIF.

    IF es_unitofmeasure IS SUPPLIED.
      lv_select_string = '*'.
    ELSE.
      CONCATENATE 'UnitOfMeasure'
                  'UnitOfMeasure_E'
                  INTO lv_select_string SEPARATED BY ','.
    ENDIF.

    SELECT SINGLE FROM i_unitofmeasure
      FIELDS (lv_select_string)
      WHERE unitofmeasure = @lv_unit
      INTO CORRESPONDING FIELDS OF @ls_unitofmeasure.
    IF sy-subrc = 0.
      es_unitofmeasure = ls_unitofmeasure.
      ev_unit_in       = ls_unitofmeasure-unitofmeasure.
      ev_unit_out      = ls_unitofmeasure-unitofmeasure_e.

      INSERT ls_unitofmeasure INTO TABLE gt_unitofmeasure.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM i_unitofmeasure
      FIELDS (lv_select_string)
      WHERE unitofmeasure_e = @lv_unit
      INTO CORRESPONDING FIELDS OF @ls_unitofmeasure.
    IF sy-subrc = 0.
      es_unitofmeasure = ls_unitofmeasure.
      ev_unit_in       = ls_unitofmeasure-unitofmeasure.
      ev_unit_out      = ls_unitofmeasure-unitofmeasure_e.

      INSERT ls_unitofmeasure INTO TABLE gt_unitofmeasure.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD get_unitofmeasure_table.
    CLEAR rt_unitofmeasure.

    DATA(lt_unit) = it_unit.

    DELETE lt_unit WHERE table_line IS INITIAL.

    IF lt_unit IS INITIAL.
      RETURN.
    ENDIF.

    SORT lt_unit BY table_line. DELETE ADJACENT DUPLICATES FROM lt_unit COMPARING ALL FIELDS.

    SELECT FROM i_unitofmeasure
      FIELDS *
      FOR ALL ENTRIES IN @lt_unit
      WHERE unitofmeasure = @lt_unit-table_line
      INTO TABLE @DATA(lt_unitofmeasure_1).

    IF iv_find_all IS NOT INITIAL.
      SELECT FROM i_unitofmeasure
        FIELDS *
        FOR ALL ENTRIES IN @lt_unit
        WHERE unitofmeasure_e = @lt_unit-table_line
        INTO TABLE @DATA(lt_unitofmeasure_2).
    ENDIF.

    IF lt_unitofmeasure_1 IS NOT INITIAL.
      rt_unitofmeasure = CORRESPONDING #( BASE ( rt_unitofmeasure ) lt_unitofmeasure_1 DISCARDING DUPLICATES ).
    ENDIF.
    IF lt_unitofmeasure_2 IS NOT INITIAL.
      rt_unitofmeasure = CORRESPONDING #( BASE ( rt_unitofmeasure ) lt_unitofmeasure_2 DISCARDING DUPLICATES ).
    ENDIF.
  ENDMETHOD.


  METHOD get_values_from_job_param.
    CLEAR: et_range[],
           ev_value.

    LOOP AT it_parameters INTO DATA(ls_parameters)
         WHERE selname = iv_selname.

      IF et_range IS SUPPLIED.
        APPEND INITIAL LINE TO et_range ASSIGNING FIELD-SYMBOL(<ls_range>).
        <ls_range> = CORRESPONDING #( ls_parameters ).
      ENDIF.

      IF ev_value IS SUPPLIED AND ev_value IS INITIAL.
        ev_value = ls_parameters-low.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_lock_object_instance.
    CLEAR: ev_subrc,
           ev_msg.

    TRY.
        ro_lock_object = cl_abap_lock_object_factory=>get_instance( iv_name = iv_name ).
      CATCH cx_abap_lock_failure INTO DATA(lx_lock_failure2).
        ev_msg   = lx_lock_failure2->get_longtext( ).
        ev_subrc = 4.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD dequeue_all_object_instance.
    cl_abap_lock_object_factory=>dequeue_all( iv_synchronous ).
  ENDMETHOD.


  METHOD new_message_with_text.
    DATA lv_v1 TYPE symsgv.
    DATA lv_v2 TYPE symsgv.
    DATA lv_v3 TYPE symsgv.
    DATA lv_v4 TYPE symsgv.

    lv_v1 = iv_text(50).
    lv_v2 = iv_text+50(50).
    lv_v3 = iv_text+100(50).
    lv_v4 = iv_text+150(50).

    ro_obj = NEW lcl_abap_behv_msg( is_textid = VALUE #(
                                        msgid = '00'
                                        msgno = '001'
                                        attr1 = COND #( WHEN lv_v1 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV1' )
                                        attr2 = COND #( WHEN lv_v2 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV2' )
                                        attr3 = COND #( WHEN lv_v3 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV3' )
                                        attr4 = COND #( WHEN lv_v4 IS NOT INITIAL THEN 'IF_T100_DYN_MSG~MSGV4' ) )
                                    iv_msgty  = SWITCH #( iv_severity
                                                          WHEN if_abap_behv_message=>severity-error       THEN 'E'
                                                          WHEN if_abap_behv_message=>severity-warning     THEN 'W'
                                                          WHEN if_abap_behv_message=>severity-information THEN 'I'
                                                          WHEN if_abap_behv_message=>severity-success     THEN 'S' )
                                    iv_msgv1  = |{ lv_v1 }|
                                    iv_msgv2  = |{ lv_v2 }|
                                    iv_msgv3  = |{ lv_v3 }|
                                    iv_msgv4  = |{ lv_v4 }| ).

    ro_obj->m_severity = iv_severity.
  ENDMETHOD.


  METHOD number_range_get.
    CLEAR: ev_number,
           ev_returncode,
           ev_returned_quantity.

    TRY.
        cl_numberrange_runtime=>number_get( EXPORTING ignore_buffer     = iv_ignore_buffer
                                                      nr_range_nr       = iv_nr_range_nr
                                                      object            = iv_object
                                                      quantity          = iv_quantity
                                                      subobject         = iv_subobject
                                                      toyear            = iv_toyear
                                            IMPORTING number            = ev_number
                                                      returncode        = ev_returncode
                                                      returned_quantity = ev_returned_quantity ).
      CATCH cx_nr_object_not_found INTO DATA(lx_obj_not_found).
        ev_returncode  = '4'.
        ev_message     = lx_obj_not_found->get_text( ).
        eo_class_error = lx_obj_not_found.
      CATCH cx_number_ranges INTO DATA(lx_num_rg).
        ev_returncode  = '4'.
        ev_message     = lx_num_rg->get_text( ).
        eo_class_error = lx_num_rg.
      CATCH cx_root INTO DATA(lx_root).
        ev_returncode  = '4'.
        ev_message     = lx_root->get_text( ).
        eo_class_error = lx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD set_background_process.
    CASE iv_phase_modify.
      WHEN abap_true.
        " Switch to modify phase
        cl_abap_tx=>modify( ).
      WHEN OTHERS.
        " Switch to save phase
        cl_abap_tx=>save( ).
    ENDCASE.
  ENDMETHOD.


  METHOD transformation_to_xml.
    " TODO: parameter EV_STRING is never cleared or assigned (ABAP cleaner)
    " TODO: parameter EV_XSTRING is never cleared or assigned (ABAP cleaner)
    " TODO: parameter EV_ENCODE_X64 is never cleared or assigned (ABAP cleaner)

    " ---------------------------------------------------------------------
    " Use Class ZCL_EXT_PDF_UTILITIES instead
    " ---------------------------------------------------------------------
    DATA lo_object TYPE REF TO object.
    DATA lt_ptab   TYPE abap_parmbind_tab.

    FINAL(lv_meth2) = `TRANSFORMATION_TO_XML`.

    TRY.
        CREATE OBJECT lo_object TYPE (`ZCL_EXT_PDF_UTILITIES`).

        IF lo_object IS BOUND.
          lt_ptab = VALUE abap_parmbind_tab( ( name  = 'IT_SRCBIND'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( it_srcbind ) )
                                             ( name  = 'IV_FORM_NAME'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_form_name ) )
                                             ( name  = 'IV_ADD_START_TAG'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_add_start_tag ) )
                                             ( name  = 'IV_ADD_END_TAG'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_add_end_tag ) )
                                             ( name  = 'IV_ENCODING'
                                               kind  = cl_abap_objectdescr=>exporting
                                               value = REF #( iv_encoding ) )
                                             ( name  = 'EV_STRING'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_string ) )
                                             ( name  = 'EV_XSTRING'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_xstring ) )
                                             ( name  = 'EV_ENCODE_X64'
                                               kind  = cl_abap_objectdescr=>importing
                                               value = REF #( ev_encode_x64 ) ) ).

          CALL METHOD lo_object->(lv_meth2)
            PARAMETER-TABLE lt_ptab.
        ENDIF.
      CATCH cx_root INTO DATA(lx_error).
        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA(lv_error_msg) = lx_error->get_longtext( ).
    ENDTRY.

    " CLEAR: ev_string,
    " ev_xstring.
    "
    " """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " - Generate XML to XSD:
    " https://www.freeformatter.com/xsd-generator.html#before-output
    " - XML Formatter:
    " https://www.freeformatter.com/xml-formatter.html#before-output
    " """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "
    " IF it_srcbind[] IS INITIAL.
    " RETURN.
    " ENDIF.
    "
    " DATA(lt_srcbind) = it_srcbind[].
    "
    " LOOP AT lt_srcbind ASSIGNING FIELD-SYMBOL(<ls_srcbind>) WHERE name IS INITIAL.
    " <ls_srcbind>-name = 'data'.
    " ENDLOOP.
    "
    " CALL TRANSFORMATION id
    " SOURCE (lt_srcbind)
    " OPTIONS xml_header = 'no'
    " RESULT XML ev_string.
    "
    " REPLACE ALL OCCURRENCES OF |<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values>|
    " IN ev_string
    " WITH |<?xml version="1.0" encoding="UTF-8"?><form1>|.
    " REPLACE ALL OCCURRENCES OF |</asx:values></asx:abap>|
    " IN ev_string
    " WITH |</form1>|.
    " REPLACE ALL OCCURRENCES OF |<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0"><asx:values>|
    " IN ev_string
    " WITH space.
    " REPLACE ALL OCCURRENCES OF |</asx:values></asx:abap>|
    " IN ev_string
    " WITH space.
    "
    " REPLACE ALL OCCURRENCES OF '﻿' IN ev_string WITH 'ฅ'.
    " ev_string = translate( val  = ev_string
    " from = `ฅ`
    " to   = ` ` ).
    "
    " ev_string = condense( ev_string ).
    "
    " IF     iv_form_name     IS NOT INITIAL
    " AND iv_add_start_tag IS NOT INITIAL.
    " CONCATENATE c_xml_tag
    " '<'
    " iv_form_name
    " '>'
    " ev_string
    " INTO ev_string.
    " ENDIF.
    "
    " IF     iv_form_name   IS NOT INITIAL
    " AND iv_add_end_tag IS NOT INITIAL.
    " CONCATENATE ev_string
    " '</'
    " iv_form_name
    " '>'
    " INTO ev_string.
    " ENDIF.
    "
    " IF iv_replace_item_tag IS NOT INITIAL.
    " -
    " DO.
    " -
    " FIND FIRST OCCURRENCE OF |<item>| IN ev_string RESULTS DATA(lw_result).
    " IF sy-subrc = 0 AND lw_result IS NOT INITIAL.
    " -
    " DATA(lv_bef_string) = ev_string(lw_result-offset).
    " -
    " FIND ALL OCCURRENCES OF '<' IN lv_bef_string RESULTS DATA(lt_result_open_tag)
    " MATCH COUNT DATA(lv_open_tag_count).
    " FIND ALL OCCURRENCES OF '>' IN lv_bef_string RESULTS DATA(lt_result_close_tag)
    " MATCH COUNT DATA(lv_close_tag_count).
    " -
    " DATA(lv_pos) = lt_result_open_tag[ lv_open_tag_count ]-offset + 1.
    " DATA(lv_len) = lt_result_close_tag[ lv_close_tag_count ]-offset - lv_pos.
    " -
    " DATA(lv_item_name) = lv_bef_string+lv_pos(lv_len).
    " DATA(lv_beg_item_tag) = |<{ lv_item_name }>|.
    " DATA(lv_end_item_tag) = |</{ lv_item_name }>|.
    " -
    " ELSE.
    " EXIT.
    " ENDIF.
    " -
    " ENDDO.
    " -
    " ENDIF.
    "
    " IF ev_xstring IS SUPPLIED.
    " ev_xstring = /ui2/cl_json=>string_to_raw( iv_string   = ev_string
    " iv_encoding = iv_encoding ).
    " ENDIF.
    "
    " IF ev_encode_x64 IS SUPPLIED.
    " ev_encode_x64 = encode_string_to_x64( iv_string = ev_string ).
    " ENDIF.
  ENDMETHOD.


  METHOD check_authorization.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "  Reference:
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/authorization-checks
    """""""""""""""""""""""""""""""""""""""""

    " iv_object : Change document object name
    " it_activity : Activity to be checked. Possible values '01' = create,
    "                                                       '02' = change,
    "                                                       '03' = read,
    "                                                       '06' = delete
    " it_devclass : development class of change document object
    rv_is_authorized = cl_chdo_object_tools_rel=>if_chdo_object_tools_rel~check_authorization(
                           iv_object   = iv_object
                           iv_activity = iv_activity
                           iv_devclass = iv_devclass ).
  ENDMETHOD.


  METHOD reading_change_documents.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "  Reference:
    "       https://help.sap.com/docs/btp/sap-business-technology-platform/reading-change-document-object-definition
    """""""""""""""""""""""""""""""""""""""""
    CLEAR: et_cdredadd_tab,
           ev_error,
           ev_error_msg.

    TRY.
        cl_chdo_read_tools=>changedocument_read( EXPORTING i_objectclass    = iv_objectclass        " change document object name
                                                           it_objectid      = it_objectid
                                                           i_date_of_change = iv_date_of_change
                                                           i_time_of_change = iv_time_of_change
                                                           i_date_until     = iv_date_until
                                                           i_time_until     = iv_time_until
                                                           it_username      = it_username
                                                           iv_read_archive  = io_read_archive
                                                           is_read_options  = is_read_options
                                                 IMPORTING et_cdredadd_tab  = et_cdredadd_tab       " result returned in table
                                                 CHANGING  ct_cdhdr         = ct_cdhdr ).
      CATCH cx_chdo_read_error INTO DATA(lx_chdo_read_error).
        ev_error     = abap_true.
        ev_error_msg = lx_chdo_read_error->get_longtext( ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_calendar_utilities.
    RETURN NEW #( ).
  ENDMETHOD.


  METHOD get_pdf_merger_instance.
    RETURN cl_rspo_pdf_merger=>create_instance( ).
  ENDMETHOD.


  METHOD create_abap_zip.
    DATA lv_xstring TYPE xstring.

    DATA(lo_zippers) = NEW cl_abap_zip( ). "" Zip class Declaration

    LOOP AT it_contents INTO FINAL(ls_content) WHERE    contents_bin IS NOT INITIAL
                                                     OR contents_txt IS NOT INITIAL.
      CLEAR lv_xstring.

      IF ls_content-contents_bin IS NOT INITIAL.
        lv_xstring = ls_content-contents_bin.
      ELSEIF ls_content-contents_txt IS NOT INITIAL.
        convert_string_to_xstring( EXPORTING iv_string    = ls_content-contents_txt
                                             iv_encoding  = ls_content-codepage
                                   IMPORTING ev_rawstring = lv_xstring ).
      ENDIF.

      IF lv_xstring IS INITIAL.
        CONTINUE.
      ENDIF.

      " Xstring to binary
      " add file to zip
      lo_zippers->add( name    = ls_content-filename
                       content = lv_xstring ).
    ENDLOOP.

    " save zip
    rv_xstring = lo_zippers->save( ).
  ENDMETHOD.


  METHOD product_get_batches.
    CLEAR: et_batches,
           es_return.

    cl_md_product_get_batches=>get_batches( EXPORTING product             = iv_product
                                                      batch_number        = iv_batch_number
                                                      plant               = iv_plant
                                                      expiry_date_from    = iv_expiry_date_from
                                                      expiry_date_to      = iv_expiry_date_to
                                                      available_date_from = iv_available_date_from
                                                      available_date_to   = iv_available_date_to
                                            IMPORTING batches             = et_batches
                                                      return              = es_return ).
  ENDMETHOD.


  METHOD get_factorycalendar_runtime.
    DATA lv_factorycalendar_id TYPE cl_fhc_calendar_runtime=>ty_fcal_id.
    DATA lv_extract_wfcid      TYPE ty_char4.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Check iv_factorycalendar_id by:
    "   I_FactoryCalendar       -> FACTORYCALENDAR
    "   I_PublicHolidayCalendar -> PUBLICHOLIDAYCALENDAR
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_extract_wfcid      = |{ iv_factorycalendar_id ALIGN = RIGHT WIDTH = 4 PAD = '_' }|.
    lv_factorycalendar_id = lv_extract_wfcid.

    TRY.
        ro_fcal_runtime = cl_fhc_calendar_runtime=>create_factorycalendar_runtime(
                              iv_factorycalendar_id = lv_factorycalendar_id ).
      CATCH cx_fhc_runtime.
    ENDTRY.
  ENDMETHOD.


  METHOD get_holidaycalendar_runtime.
    DATA lv_holidaycalendar_id TYPE cl_fhc_calendar_runtime=>ty_fcal_id.
    DATA lv_extract_wfcid      TYPE ty_char4.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Check iv_holidaycalendar_id by:
    "   I_FactoryCalendar       -> FACTORYCALENDAR
    "   I_PublicHolidayCalendar -> PUBLICHOLIDAYCALENDAR
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_extract_wfcid      = |{ iv_holidaycalendar_id ALIGN = RIGHT WIDTH = 4 PAD = '_' }|.
    lv_holidaycalendar_id = lv_extract_wfcid.

    TRY.
        ro_hcal_runtime = cl_fhc_calendar_runtime=>create_holidaycalendar_runtime(
                              iv_holidaycalendar_id = lv_holidaycalendar_id ).
      CATCH cx_fhc_runtime.
    ENDTRY.
  ENDMETHOD.


  METHOD get_holiday_runtime.
    DATA lv_holiday_id    TYPE cl_fhc_calendar_runtime=>ty_fcal_id.
    DATA lv_extract_wfcid TYPE ty_char4.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Check iv_holiday_id by:
    "   I_PublicHolidayCode -> PUBLICHOLIDAYCODE
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    lv_extract_wfcid = |{ iv_holiday_id ALIGN = RIGHT WIDTH = 4 PAD = '_' }|.
    lv_holiday_id = lv_extract_wfcid.

    TRY.
        ro_holiday_runtime = cl_fhc_calendar_runtime=>create_holiday_runtime( iv_holiday_id = lv_holiday_id ).
      CATCH cx_fhc_runtime.
    ENDTRY.
  ENDMETHOD.


  METHOD convert_date_to_factorydate.
    DATA(lo_fcal_runtime) = get_factorycalendar_runtime( iv_factorycalendar_id = iv_factorycalendar_id ).

    IF lo_fcal_runtime IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        ev_factorydate = lo_fcal_runtime->convert_date_to_factorydate( iv_date           = iv_date
                                                                       iv_correct_option = iv_correct_option ).

        ev_date = lo_fcal_runtime->convert_factorydate_to_date( iv_factorydate = ev_factorydate ).
      CATCH cx_fhc_runtime.
    ENDTRY.
  ENDMETHOD.


  METHOD get_last_day_of_months.
    CONSTANTS lc_januar   TYPE n LENGTH 2 VALUE '01'.
    CONSTANTS lc_december TYPE n LENGTH 2 VALUE '12'.
    CONSTANTS lc_lowdate  TYPE n LENGTH 4 VALUE '1800'.
    CONSTANTS lc_first    TYPE n LENGTH 2 VALUE '01'.

    CONSTANTS: BEGIN OF lc_highdate,
                 j TYPE n LENGTH 4 VALUE '9999',
                 m TYPE n LENGTH 2 VALUE '12',
                 t TYPE n LENGTH 2 VALUE '31',
               END OF lc_highdate.

    DATA: BEGIN OF ls_date,
            j TYPE n LENGTH 4,
            m TYPE n LENGTH 2,
            t TYPE n LENGTH 2,
          END OF ls_date.

    DATA lv_zahl TYPE i.

    ls_date = iv_day_in.

    IF    ls_date-m < lc_januar OR ls_date-m > lc_december
       OR ls_date-j < lc_lowdate.
      RAISE EXCEPTION NEW cx_scal( textid = cx_scal=>date_invalid ).
    ENDIF.

    IF     ls_date-j = lc_highdate-j
       AND ls_date-m = lc_highdate-m.
      rv_last_day_of_month = lc_highdate.
    ELSE.
      IF ls_date-m = lc_december.
        lv_zahl = ls_date-j + 1.
        ls_date-j = lv_zahl.
        ls_date-m = lc_first.
      ELSE.
        lv_zahl = ls_date-m + 1.
        ls_date-m = lv_zahl.
      ENDIF.
      " First day of the following month
      ls_date-t = lc_first.
      rv_last_day_of_month = ls_date.
      rv_last_day_of_month -= 1.
    ENDIF.
  ENDMETHOD.


  METHOD is_batch_processing.
    RETURN cl_fdt_obj_system_variables=>is_batch_processing( ).
  ENDMETHOD.


  METHOD split_text.
    TRY.
        go_abap_local->split_text( EXPORTING iv_text        = iv_text
                                             iv_len         = iv_len
                                             iv_delimiter   = iv_delimiter
                                   IMPORTING et_split_texts = et_split_texts ).
      CATCH cx_sy_create_data_error INTO DATA(lx_sy_create_data_error).
        RAISE EXCEPTION NEW cx_sy_create_data_error( previous = lx_sy_create_data_error ).
    ENDTRY.
  ENDMETHOD.


  METHOD text_to_tline_tab.
    TYPES lty_tdline TYPE ty_char132.

    DATA lt_tdline TYPE TABLE OF lty_tdline WITH EMPTY KEY.
    DATA lt_texts  TYPE string_table.
    DATA lv_text   TYPE string.

    CLEAR rt_lines.

    IF iv_text IS INITIAL.
      RETURN.
    ENDIF.

    lv_text = iv_text.

    TRY.
        lv_text = replace( val  = lv_text
                           sub  = cl_abap_char_utilities=>horizontal_tab
                           with = `,,`
                           occ  = 0 ).
        lv_text = replace( val  = lv_text
                           sub  = `\t`
                           with = `,,`
                           occ  = 0 ).
        lv_text = replace( val  = lv_text
                           sub  = `\T`
                           with = `,,`
                           occ  = 0 ).
        lv_text = replace( val  = lv_text
                           sub  = `\n`
                           with = cl_abap_char_utilities=>newline
                           occ  = 0 ).
        lv_text = replace( val  = lv_text
                           sub  = `\N`
                           with = cl_abap_char_utilities=>newline
                           occ  = 0 ).
      CATCH cx_sy_range_out_of_bounds
            cx_sy_strg_par_val INTO DATA(lx_strg_error).
        RAISE EXCEPTION NEW cx_sy_create_data_error( textid = lx_strg_error->textid ).
    ENDTRY.

    TRY.
        lt_texts = xco_cp=>string( lv_text )->split( CONV #( cl_abap_char_utilities=>newline ) )->value.

        LOOP AT lt_texts INTO DATA(lv_texts).
          CLEAR lt_tdline.

          go_abap_local->split_text( EXPORTING iv_text        = lv_texts
                                               iv_len         = 132
                                     IMPORTING et_split_texts = lt_tdline ).

          LOOP AT lt_tdline INTO DATA(lv_tdline).
            rt_lines = VALUE #( BASE rt_lines
                                ( tdformat = COND #( WHEN sy-tabix = 1 THEN '*' ELSE '=' )
                                  tdline   = lv_tdline ) ).
          ENDLOOP.
        ENDLOOP.
      CATCH cx_sy_create_data_error.
        CLEAR rt_lines.
    ENDTRY.
  ENDMETHOD.


  METHOD convert_timestamp_to_datetime.
    DATA lv_timestamp TYPE timestamp.

    CLEAR: ev_date,
           ev_time.

    IF    (     iv_timestamp  IS NOT SUPPLIED
            AND iv_timestampl IS NOT SUPPLIED )
       OR (     iv_timestamp  IS INITIAL
            AND iv_timestampl IS INITIAL ).
      RETURN.
    ENDIF.

    TRY.
        lv_timestamp = COND #( WHEN iv_timestampl IS SUPPLIED
                               THEN cl_abap_tstmp=>move_to_short_trunc( tstmp_src = iv_timestampl )
                               ELSE iv_timestamp ).
      CATCH cx_parameter_invalid_type
            cx_parameter_invalid_range.
        RETURN.
    ENDTRY.

    IF iv_set_timezone IS NOT INITIAL.
      IF iv_utc_timezone IS NOT INITIAL.
        ev_date = xco_cp_time=>time_zone->utc->get_date( iv_timestamp = lv_timestamp ).
        ev_time = xco_cp_time=>time_zone->utc->get_time( iv_timestamp = lv_timestamp ).
      ELSE.
        ev_date = xco_cp_time=>time_zone->user->get_date( iv_timestamp = lv_timestamp ).
        ev_time = xco_cp_time=>time_zone->user->get_time( iv_timestamp = lv_timestamp ).
      ENDIF.
    ELSE.
      CONVERT TIME STAMP lv_timestamp TIME ZONE space INTO DATE ev_date.
      CONVERT TIME STAMP lv_timestamp TIME ZONE space INTO TIME ev_time.
    ENDIF.
  ENDMETHOD.


  METHOD get_product.
    DATA ls_material TYPE ts_material.

    CLEAR: es_product,
           ev_subrc.

    READ TABLE gt_material INTO ls_material
         WITH TABLE KEY product = iv_product.
    IF sy-subrc = 0.
      es_product = ls_material.
      ev_subrc   = sy-subrc.
    ELSE.
      READ TABLE gt_material INTO ls_material
           WITH KEY k2 COMPONENTS productexternalid = iv_product.
      IF sy-subrc = 0.
        es_product = ls_material.
        ev_subrc   = sy-subrc.
      ELSE.
        SELECT SINGLE FROM i_product
          FIELDS product,
                 baseunit,
                 productexternalid,
                 producttype,
                 productgroup,
                 externalproductgroup,
                 isbatchmanagementrequired
          WHERE product           = @iv_product
             OR productexternalid = @iv_product
          INTO CORRESPONDING FIELDS OF @ls_material.
        IF sy-subrc = 0.
          es_product = ls_material.
          ev_subrc   = sy-subrc.
          INSERT ls_material INTO TABLE gt_material.
        ELSE.
          ev_subrc = sy-subrc.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_wbselementdata.
    DATA ls_wbselement   TYPE ts_wbselement.
    DATA lv_where_string TYPE string.

    CLEAR: es_wbselementdata,
           ev_subrc.

    IF iv_wbselementinternalid IS SUPPLIED.
      lv_where_string = `WBSELEMENTINTERNALID = @IV_WBSELEMENTINTERNALID`.

      READ TABLE gt_wbselement INTO ls_wbselement
           WITH TABLE KEY wbselementinternalid = iv_wbselementinternalid.
    ELSEIF iv_wbselementexternalid IS SUPPLIED.
      lv_where_string = `WBSELEMENTEXTERNALID = @IV_WBSELEMENTEXTERNALID`.

      READ TABLE gt_wbselement INTO ls_wbselement
           WITH KEY k2 COMPONENTS wbselementexternalid = iv_wbselementexternalid.
    ELSEIF iv_wbselement IS SUPPLIED.
      lv_where_string = `WBSELEMENT = @IV_WBSELEMENT`.

      READ TABLE gt_wbselement INTO ls_wbselement
           WITH KEY k3 COMPONENTS wbselement = iv_wbselement.
    ELSE.
      ev_subrc = 8.
      RETURN.
    ENDIF.

    IF sy-subrc = 0.
      es_wbselementdata = ls_wbselement.
      ev_subrc = sy-subrc.
    ELSE.
      SELECT SINGLE FROM i_wbselementbasicdata
        FIELDS wbselementinternalid,
               wbselementexternalid,
               wbselement,
               wbselementshortid,
               wbsdescription,
               companycode,
               controllingarea,
               functionalarea,
               profitcenter,
               plant,
               costcenter,
               projectinternalid,
               wbselementobject
        WHERE (lv_where_string)
        INTO CORRESPONDING FIELDS OF @ls_wbselement.
      IF sy-subrc = 0.
        es_wbselementdata = ls_wbselement.
        ev_subrc = sy-subrc.
        INSERT ls_wbselement INTO TABLE gt_wbselement.
      ELSE.
        ev_subrc = sy-subrc.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD add_subtract_calc_date.
    DATA lv_value TYPE string.

    IF iv_date IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_date) = xco_cp_time=>date( iv_year  = substring( val = iv_date
                                                                 off = 0
                                                                 len = 4 )
                                           iv_month = substring( val = iv_date
                                                                 off = 4
                                                                 len = 2 )
                                           iv_day   = substring( val = iv_date
                                                                 off = 6
                                                                 len = 2 ) ).
      CATCH cx_sy_range_out_of_bounds.
    ENDTRY.

    IF lo_date IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lo_calculation) = COND #( WHEN io_calculation IS BOUND
                                   THEN io_calculation
                                   ELSE xco_cp_time=>date_calculation->preserving ).

    CASE iv_sign.
      WHEN '+'.
        DATA(lo_date_add) = lo_date->add( iv_year        = iv_year
                                          iv_month       = iv_month
                                          iv_day         = iv_day
                                          io_calculation = lo_calculation ).
        lv_value = lo_date_add->as( xco_cp_time=>format->abap )->value.
      WHEN '-'.
        DATA(lo_date_sub) = lo_date->subtract( iv_year        = iv_year
                                               iv_month       = iv_month
                                               iv_day         = iv_day
                                               io_calculation = lo_calculation ).
        lv_value = lo_date_sub->as( xco_cp_time=>format->abap )->value.
    ENDCASE.

    TRY.
        rv_date = substring( val = lv_value
                             off = 0
                             len = 8 ).
      CATCH cx_sy_range_out_of_bounds.
    ENDTRY.
  ENDMETHOD.


  METHOD add_subtract_calc_date_time.
    DATA lo_moment TYPE REF TO if_xco_cp_tm_moment.
    DATA lv_value  TYPE string.

    IF iv_date IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        IF iv_time IS NOT INITIAL.

          DATA(lv_hour) = CONV if_xco_cp_tm_time=>tv_hour( substring( val = iv_time
                                                                      off = 0
                                                                      len = 2 ) ).
          DATA(lv_minute) = CONV if_xco_cp_tm_time=>tv_hour( substring( val = iv_time
                                                                        off = 2
                                                                        len = 2 ) ).
          DATA(lv_second) = CONV if_xco_cp_tm_time=>tv_hour( substring( val = iv_time
                                                                        off = 4
                                                                        len = 2 ) ).

        ENDIF.

        lo_moment = xco_cp_time=>moment( iv_year   = substring( val = iv_date
                                                                off = 0
                                                                len = 4 )
                                         iv_month  = substring( val = iv_date
                                                                off = 4
                                                                len = 2 )
                                         iv_day    = substring( val = iv_date
                                                                off = 6
                                                                len = 2 )
                                         iv_hour   = lv_hour
                                         iv_minute = lv_minute
                                         iv_second = lv_second ).
      CATCH cx_sy_range_out_of_bounds.
    ENDTRY.

    IF lo_moment IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lo_calculation) = COND #( WHEN io_calculation IS BOUND
                                   THEN io_calculation
                                   ELSE xco_cp_time=>date_calculation->preserving ).

    CASE iv_sign.
      WHEN '+'.
        DATA(lo_moment_add) = lo_moment->add( iv_year        = iv_year
                                              iv_month       = iv_month
                                              iv_day         = iv_day
                                              iv_hour        = iv_hour
                                              iv_minute      = iv_minute
                                              iv_second      = iv_second
                                              io_calculation = lo_calculation ).
        lv_value = lo_moment_add->as( xco_cp_time=>format->abap )->value.
      WHEN '-'.
        DATA(lo_moment_sub) = lo_moment->subtract( iv_year        = iv_year
                                                   iv_month       = iv_month
                                                   iv_day         = iv_day
                                                   iv_hour        = iv_hour
                                                   iv_minute      = iv_minute
                                                   iv_second      = iv_second
                                                   io_calculation = lo_calculation ).
        lv_value = lo_moment_sub->as( xco_cp_time=>format->abap )->value.
    ENDCASE.

    TRY.
        ev_date = substring( val = lv_value
                             off = 0
                             len = 8 ).
        ev_time = substring( val = lv_value
                             off = 8
                             len = 6 ).
      CATCH cx_sy_range_out_of_bounds.
    ENDTRY.
  ENDMETHOD.


  METHOD zspell_amount.
    TRY.
        DATA:
        lv_spellamount TYPE string.
        DATA: lo_config TYPE REF TO zcl_ext_abap_config.
        DATA lr_Cur TYPE RANGE OF char20.
        DATA lv_language(5).
        DATA : lv_main(20),
               lv_Sub(20).

        IF iv_language = 'E'.
          lv_language = 'EN'.
        ELSE.
          lv_language = 'TH'.
        ENDIF.

        lo_config = zcl_ext_abap_config=>get_instance( 'CURRENCY_DETAIL' ).
        lo_config->get_range_value(
        EXPORTING
            iv_identifier = iv_currency
            iv_parameter1 = lv_language
        IMPORTING
            et_range      = lr_cur ).
        READ TABLE lr_cur INDEX 1 INTO DATA(ls_cur) .
        IF  sy-subrc = 0.
          lv_main = ls_cur-low.
          lv_sub = ls_cur-high.
        ENDIF.
        TRY.
            CALL METHOD zcl_t2_spell_amount=>spell_amount
              EXPORTING
                iv_amount   = iv_amount
                iv_currency = iv_currency
                iv_language = iv_language
              IMPORTING
                es_in_words = DATA(ls_spell_words).

          CATCH zcx_t2_static_check INTO DATA(lx_err).
        ENDTRY.


        lv_spellamount = ls_spell_words-word.

        IF iv_language  = '2'.
          IF ls_spell_words-decword IS INITIAL
          OR ls_spell_words-decword =  'ศูนย์'.
            CONCATENATE lv_spellamount
                        lv_main
                        'ถ้วน'
            INTO lv_spellamount.
          ELSE.
            CONCATENATE lv_spellamount
                        lv_main
                         ls_spell_words-decword
                        lv_sub
            INTO lv_spellamount.
          ENDIF.
        ELSE.
          IF ls_spell_words-decword IS INITIAL
                OR ls_spell_words-decword = 'ZERO'.
            CONCATENATE lv_spellamount
                        lv_main 'ONLY'
            INTO lv_spellamount
            SEPARATED BY space.
          ELSE.
            CONCATENATE lv_spellamount
                        lv_main 'AND'
                         ls_spell_words-decword
                         lv_sub
            INTO lv_spellamount
            SEPARATED BY space.
          ENDIF.
        ENDIF.

        ev_spell_amount = lv_spellamount.
      CATCH cx_root INTO DATA(lx_error).
        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA(lv_error_msg) = lx_error->get_longtext( ).
    ENDTRY.
  ENDMETHOD.


  METHOD text_to_msgvn.

    DATA: lc_times    TYPE i VALUE 4,
          lc_pref_var TYPE string VALUE 'LV_MSGV'.

    DATA: lv_msgtxt TYPE string,
          lv_len    TYPE i,
          lv_msgv1  TYPE sy-msgv1,
          lv_msgv2  TYPE sy-msgv2,
          lv_msgv3  TYPE sy-msgv3,
          lv_msgv4  TYPE sy-msgv4.

*    DATA(lo_type) = cl_abap_typedescr=>describe_by_name( p_name = iv_elmtnm ).
*    CHECK lo_type IS NOT INITIAL.
*    DATA(lv_len) = lo_type->length.

    CLEAR: ev_msgv1, ev_msgv2, ev_msgv3, ev_msgv4.
    lv_msgtxt = iv_text.
    lv_len = iv_len.
    DO lc_times TIMES.
      DATA(lv_name) = lc_pref_var && sy-index.
      ASSIGN (lv_name) TO FIELD-SYMBOL(<ls_msgvn>).
      IF sy-subrc IS INITIAL AND <ls_msgvn> IS ASSIGNED.
        IF lv_msgtxt IS NOT INITIAL.
          TRY.
              <ls_msgvn> = lv_msgtxt(lv_len).
              lv_msgtxt = lv_msgtxt+lv_len.
            CATCH cx_root.
              <ls_msgvn> = lv_msgtxt.
              CLEAR: lv_msgtxt.
              EXIT.
          ENDTRY.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    ev_msgv1 = lv_msgv1.
    ev_msgv2 = lv_msgv2.
    ev_msgv3 = lv_msgv3.
    ev_msgv4 = lv_msgv4.

  ENDMETHOD.


  METHOD check_production_client.
    SELECT SINGLE * "#EC CI_ALL_FIELDS_NEEDED
    FROM zi_t000
    WHERE Mandt = @sy-mandt
    AND   cccategory = 'P'
    INTO @DATA(ls_client).
      IF sy-subrc = 0.
        rv_production = 'X'.
      ENDIF.
ENDMETHOD.


  METHOD sy_to_s_msg.
    IF iv_msgty IS INITIAL.
      rs_msg-type = sy-msgty.
    ELSE.
      rs_msg-type = iv_msgty.
    ENDIF.
    rs_msg-id = sy-msgid.
    rs_msg-number = sy-msgno.
    rs_msg-message_v1 = sy-msgv1.
    rs_msg-message_v2 = sy-msgv2.
    rs_msg-message_v3 = sy-msgv3.
    rs_msg-message_v4 = sy-msgv4.

    MESSAGE ID rs_msg-id TYPE rs_msg-type NUMBER rs_msg-number
      WITH rs_msg-message_v1 rs_msg-message_v2 rs_msg-message_v3 rs_msg-message_v4
      INTO rs_msg-message.
  ENDMETHOD.


  METHOD sy_to_t_msg.
    DATA(ls_msg) = sy_to_s_msg( iv_msgty = iv_msgty ).
    IF ls_msg IS NOT INITIAL.
      APPEND ls_msg TO ct_msg.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

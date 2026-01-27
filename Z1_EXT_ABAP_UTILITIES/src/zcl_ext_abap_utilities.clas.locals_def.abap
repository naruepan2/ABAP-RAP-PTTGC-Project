*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CLASS lcl_abap_behv_msg DEFINITION INHERITING FROM cx_no_check CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.

    ALIASES mv_msgty FOR if_t100_dyn_msg~msgty.
    ALIASES mv_msgv1 FOR if_t100_dyn_msg~msgv1.
    ALIASES mv_msgv2 FOR if_t100_dyn_msg~msgv2.
    ALIASES mv_msgv3 FOR if_t100_dyn_msg~msgv3.
    ALIASES mv_msgv4 FOR if_t100_dyn_msg~msgv4.

    METHODS constructor
      IMPORTING is_textid   LIKE if_t100_message=>t100key OPTIONAL
                ix_previous LIKE previous                 OPTIONAL
                iv_msgty    TYPE symsgty                  OPTIONAL
                iv_msgv1    TYPE simple                   OPTIONAL
                iv_msgv2    TYPE simple                   OPTIONAL
                iv_msgv3    TYPE simple                   OPTIONAL
                iv_msgv4    TYPE simple                   OPTIONAL.

ENDCLASS.


CLASS lcl_abap_utilities_local DEFINITION.
  PUBLIC SECTION.

    METHODS constructor.

    METHODS convert_dynamic_intern_value
      IMPORTING VALUE(iv_value) TYPE any
                iv_inout_type   TYPE i
                iv_inttype      TYPE abap_typekind           OPTIONAL
                iv_convexit     TYPE abap_editmask           OPTIONAL
                iv_date_format  TYPE cl_abap_datfm=>ty_datfm OPTIONAL
      EXPORTING VALUE(ev_value) TYPE any.

    METHODS convert_dynamic_extern_value
      IMPORTING VALUE(iv_value) TYPE any
                iv_inout_type   TYPE i
                iv_inttype      TYPE abap_typekind             OPTIONAL
                iv_convexit     TYPE abap_editmask             OPTIONAL
                iv_date_format  TYPE cl_abap_datfm=>ty_datfm   OPTIONAL
                iv_time_format  TYPE cl_abap_timefm=>ty_format OPTIONAL
                iv_user_format  TYPE i                         DEFAULT cl_abap_format=>n_user
      EXPORTING VALUE(ev_value) TYPE any.

    METHODS conv_inout_dynamic
      IMPORTING VALUE(iv_value) TYPE any
                iv_inout_type   TYPE i
                iv_convexit     TYPE abap_editmask OPTIONAL
                iv_typekind     TYPE abap_typekind OPTIONAL
      EXPORTING VALUE(ev_value) TYPE any.

    METHODS check_bank_account_number
      IMPORTING iv_bankl        TYPE any
                iv_bankn        TYPE any
                iv_s_error      TYPE /atl/cl_il_bank_number_check=>ty_loevm
                iv_res_only     TYPE /atl/cl_il_bank_number_check=>ty_loevm OPTIONAL
      EXPORTING ev_msg          TYPE string
      RETURNING VALUE(rv_found) TYPE abap_bool.

    METHODS get_dynamic_describe
      IMPORTING ir_data        TYPE REF TO data
      EXPORTING eo_object      TYPE REF TO object
                ev_object_name TYPE string
                et_components  TYPE cl_abap_structdescr=>component_table.

    METHODS split_text
      IMPORTING iv_text        TYPE string
                iv_len         TYPE i DEFAULT 256
                iv_delimiter   TYPE string DEFAULT space
      EXPORTING et_split_texts TYPE table
      RAISING   cx_sy_create_data_error.

  PRIVATE SECTION.
    TYPES ty_abcde TYPE c LENGTH 26.

    DATA mt_fixed_values TYPE cl_abap_elemdescr=>fixvalues.

    METHODS _get_include_describe_fields
      IMPORTING io_abap_datadescr TYPE REF TO cl_abap_datadescr
      CHANGING  ct_components     TYPE cl_abap_structdescr=>component_table.

    METHODS _split_text_local
      IMPORTING iv_text        TYPE string
                iv_len         TYPE i
      CHANGING  ct_split_texts TYPE table
      RAISING   cx_sy_create_data_error.

    METHODS _get_abcde
      RETURNING VALUE(rv_abcde) TYPE ty_abcde.

    METHODS _get_abap_datfm_datatype.

ENDCLASS.

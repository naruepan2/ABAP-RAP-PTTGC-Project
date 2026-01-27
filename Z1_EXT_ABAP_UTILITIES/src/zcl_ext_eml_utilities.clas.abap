CLASS zcl_ext_eml_utilities DEFINITION
  PUBLIC
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_response,
        entity_name     TYPE abp_behv_changes-entity_name,
        mapped          TYPE abp_behv_response_tab,
        failed          TYPE abp_behv_response_tab,
        reported        TYPE abp_behv_response_tab,
        failed_commit   TYPE abp_behv_response_tab,
        reported_commit TYPE abp_behv_response_tab,
      END OF ts_response.

    TYPES tt_response TYPE TABLE OF ts_response WITH EMPTY KEY.

    INTERFACES if_oo_adt_classrun.

    METHODS constructor.

    CLASS-METHODS create_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_eml_utilities.

    CLASS-METHODS convert_date_to_timestamp
      IMPORTING iv_date             TYPE cl_abap_context_info=>ty_system_date
      RETURNING VALUE(rv_timestamp) TYPE timestamp.

    CLASS-METHODS convert_timestamp_to_date
      IMPORTING iv_timestamp   TYPE timestamp
      RETURNING VALUE(rv_date) TYPE cl_abap_context_info=>ty_system_date.

    CLASS-METHODS get_current_timestamp
      RETURNING VALUE(rv_timestamp) TYPE timestamp.

    CLASS-METHODS get_current_timestamp_long
      RETURNING VALUE(rv_timestampl) TYPE abp_lastchange_tstmpl.

    CLASS-METHODS mark_x_behv_flag_control
      IMPORTING iv_mark_all TYPE abap_boolean OPTIONAL
      CHANGING  cs_data     TYPE any.

    CLASS-METHODS convert_key_pid_static
      IMPORTING iv_pid         TYPE abp_behv_pid
                iv_entity_name TYPE abp_behv_changes-entity_name
      EXPORTING ev_value       TYPE any.

    METHODS convert_key_pid
      IMPORTING iv_pid             TYPE abp_behv_pid
                iv_entity_name     TYPE abp_behv_changes-entity_name
      EXPORTING ev_value           TYPE any
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_eml_utilities.

    METHODS clear_eml_operation
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_eml_utilities.

    METHODS collect_eml_operation
      IMPORTING iv_clear_all        TYPE abap_boolean DEFAULT space
                iv_operation        TYPE abp_behv_changes-op
                iv_entity_name      TYPE abp_behv_changes-entity_name
                iv_association_name TYPE abp_behv_changes-sub_name OPTIONAL
                ir_data             TYPE REF TO data
      EXPORTING ev_error            TYPE abap_boolean
                ev_msg              TYPE string
      RETURNING VALUE(ro_instance)  TYPE REF TO zcl_ext_eml_utilities.

    METHODS post_eml_operations
      IMPORTING it_operation       TYPE abp_behv_changes_tab OPTIONAL
                iv_local_mode      TYPE abap_boolean         DEFAULT space
                iv_privileged_mode TYPE abap_boolean         DEFAULT space
                iv_testrun         TYPE abap_boolean         DEFAULT space
                iv_commit          TYPE abap_boolean         DEFAULT space
      EXPORTING et_mapped          TYPE abp_behv_response_tab
                et_failed          TYPE abp_behv_response_tab
                et_reported        TYPE abp_behv_response_tab
                et_failed_commit   TYPE abp_behv_response_tab
                et_reported_commit TYPE abp_behv_response_tab
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_eml_utilities.

    METHODS commit_eml_operations
      IMPORTING it_entities        TYPE abp_entity_name_tab
                iv_simulation_mode TYPE abap_bool OPTIONAL
      EXPORTING et_failed_commit   TYPE abp_behv_response_tab
                et_reported_commit TYPE abp_behv_response_tab
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_eml_utilities.

  PRIVATE SECTION.
    CLASS-DATA mo_eml_utilities_local TYPE REF TO lcl_eml_utilities_local.

    DATA mt_operation TYPE abp_behv_changes_tab.
    DATA mt_response  TYPE tt_response.

ENDCLASS.


CLASS zcl_ext_eml_utilities IMPLEMENTATION.
  METHOD constructor.
    IF mo_eml_utilities_local IS NOT BOUND.
      mo_eml_utilities_local = NEW #( ).
    ENDIF.
  ENDMETHOD.

  METHOD clear_eml_operation.
    ro_instance = me.

    CLEAR: mt_operation,
           mt_response.
  ENDMETHOD.

  METHOD collect_eml_operation.
    DATA lv_operation TYPE abp_behv_changes-op.

    CLEAR: ev_error,
           ev_msg.

    ro_instance  = me.
    lv_operation = iv_operation.

    IF iv_association_name IS NOT INITIAL.
      lv_operation = if_abap_behv=>op-m-create_ba.
    ENDIF.

    IF lv_operation IS INITIAL.
      ev_error = abap_true.
      ev_msg   = 'Operation is required'.
      RETURN.
    ELSEIF iv_entity_name IS INITIAL.
      ev_error = abap_true.
      ev_msg   = 'Entity Name is required'.
      RETURN.
    ELSEIF ir_data IS NOT BOUND.
      ev_error = abap_true.
      ev_msg   = 'There is not any content data'.
      RETURN.
    ENDIF.

    IF iv_clear_all IS NOT INITIAL.
      clear_eml_operation( ).
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " OP:
    "  if_abap_behv=>op-m-create    type if_abap_behv=>t_char01 value 'C'
    "  if_abap_behv=>op-m-update    type if_abap_behv=>t_char01 value 'U'
    "  if_abap_behv=>op-m-delete    type if_abap_behv=>t_char01 value 'D'
    "  if_abap_behv=>op-m-action    type if_abap_behv=>t_char01 value 'A'
    "  if_abap_behv=>op-m-create_ba type if_abap_behv=>t_char01 value 'O'
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    mt_operation = VALUE #( BASE mt_operation
                            ( op          = lv_operation
                              entity_name = |{ iv_entity_name CASE = UPPER }|
                              sub_name    = |{ iv_association_name CASE = UPPER }|
                              instances   = REF #( ir_data ) ) ).
  ENDMETHOD.

  METHOD create_instance.
    RETURN NEW #( ).
  ENDMETHOD.

  METHOD convert_date_to_timestamp.
    CONVERT DATE iv_date INTO TIME STAMP rv_timestamp TIME ZONE space.
  ENDMETHOD.

  METHOD convert_key_pid.
    ro_instance = me.

    CLEAR ev_value.

    IF    iv_entity_name IS INITIAL
       OR iv_pid         IS INITIAL.
      RETURN.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " iv_entity_name => Specifies the RAP BO entity <bdef> for which the keys should be converted
    "   Example: iv_entity_name = I_MATERIALDOCUMENTTP
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA(lv_entity_name) = CONV abp_entity_name( |{ iv_entity_name CASE = UPPER }| ).

    " Convert PID to any Entity Name
    CONVERT KEY OF (lv_entity_name) FROM iv_pid TO ev_value.
  ENDMETHOD.

  METHOD convert_key_pid_static.
    DATA(lo_instance) = NEW zcl_ext_eml_utilities( ).
    IF lo_instance IS BOUND.
      lo_instance->convert_key_pid( EXPORTING iv_pid         = iv_pid
                                              iv_entity_name = iv_entity_name
                                    IMPORTING ev_value       = ev_value ).
    ENDIF.
  ENDMETHOD.

  METHOD convert_timestamp_to_date.
    CONVERT TIME STAMP iv_timestamp TIME ZONE space INTO DATE rv_date.
  ENDMETHOD.

  METHOD get_current_timestamp.
    GET TIME STAMP FIELD rv_timestamp.
  ENDMETHOD.

  METHOD get_current_timestamp_long.
    GET TIME STAMP FIELD rv_timestampl.
  ENDMETHOD.

  METHOD mark_x_behv_flag_control.
    DATA(lo_structdescr) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( cs_data ) ).
    IF lo_structdescr IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(lt_components_main) = lo_structdescr->get_components( ).

    DATA(lt_components_temp) = lt_components_main.
    DELETE lt_components_temp WHERE name = cl_abap_behv=>co_techfield_name-cid.

    CLEAR lt_components_main.

    LOOP AT lt_components_temp INTO DATA(ls_components_main) WHERE name <> cl_abap_behv=>co_techfield_name-control.
      IF ls_components_main-type IS INSTANCE OF cl_abap_structdescr.
        INSERT LINES OF CAST cl_abap_structdescr( ls_components_main-type )->get_components( )
               INTO TABLE lt_components_main.
      ELSE.
        INSERT ls_components_main INTO TABLE lt_components_main.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_components_main INTO ls_components_main.
      ASSIGN COMPONENT ls_components_main-name OF STRUCTURE cs_data TO FIELD-SYMBOL(<lv_val>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_control_field) = |{ cl_abap_behv=>co_techfield_name-control }-{ ls_components_main-name }|.

      ASSIGN COMPONENT lv_control_field OF STRUCTURE cs_data TO FIELD-SYMBOL(<lv_control>).
      IF sy-subrc = 0.
        IF iv_mark_all IS NOT INITIAL.
          <lv_control> = cl_abap_behv=>flag_changed.
        ELSE.
          <lv_control> = COND #( WHEN <lv_val> IS NOT INITIAL
                                 THEN cl_abap_behv=>flag_changed
                                 ELSE cl_abap_behv=>flag_null ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_eml_operations.
    DATA lt_operation   TYPE abp_behv_changes_tab.
    DATA lt_commit_tab  TYPE abp_entity_name_tab.
    DATA lv_entity_name TYPE abp_entity_name.

    CLEAR: et_failed,
           et_mapped,
           et_reported,
           et_failed_commit,
           et_reported_commit.

    ro_instance = me.

    IF mt_operation IS NOT INITIAL.
      APPEND LINES OF mt_operation TO lt_operation.
    ENDIF.

    IF it_operation IS NOT INITIAL.
      APPEND LINES OF it_operation TO lt_operation.
    ENDIF.

    mo_eml_utilities_local->check_operation( CHANGING ct_operation = lt_operation ).

    DELETE lt_operation WHERE    op          IS INITIAL
                              OR entity_name IS INITIAL
                              OR instances   IS NOT BOUND.

    IF lt_operation IS INITIAL.
      RETURN.
    ENDIF.

**********************************************************************
*                   SAMPLE EML OPERATIONS
**********************************************************************
**    DATA:
**      _bp_root           TYPE TABLE FOR CREATE i_businesspartnertp_3,
**      _bp_address        TYPE TABLE FOR CREATE i_businesspartnertp_3\_businesspartneraddress,
**      _bp_identification TYPE TABLE FOR CREATE i_businesspartnertp_3\_businesspartneridentification,
**      _bp_address_usage  TYPE TABLE FOR CREATE i_businesspartneraddresstp_3\_businesspartneraddressusage.
**
**    lt_operation = VALUE abp_behv_changes_tab(
**                        ( VALUE abp_behv_changes(
**                            op = if_abap_behv=>op-m-create
**                            entity_name = 'I_BUSINESSPARTNERTP_3'
**                            instances =  REF #( _bp_root )
**                        ) )
**                        ( VALUE abp_behv_changes(
**                            op = if_abap_behv=>op-m-create_ba
**                            entity_name = 'I_BUSINESSPARTNERTP_3'
**                            sub_name = '_BUSINESSPARTNERADDRESS'
**                            instances = REF #( _bp_address )
**                        ) )
**                        ( VALUE abp_behv_changes(
**                            op = if_abap_behv=>op-m-create_ba
**                            entity_name = 'I_BUSINESSPARTNERTP_3'
**                            sub_name = '_BUSINESSPARTNERIDENTIFICATION'
**                            instances = REF #( _bp_identification )
**                        ) )
**                        ( VALUE abp_behv_changes(
**                            op = if_abap_behv=>op-m-create_ba
**                            entity_name = 'I_BUSINESSPARTNERADDRESSTP_3'
**                            sub_name = '_BUSINESSPARTNERADDRESSUSAGE'
**                            instances = REF #( _bp_address_usage )
**                        ) )
**    ).
**********************************************************************

    IF iv_local_mode IS NOT INITIAL.
      MODIFY ENTITIES IN LOCAL MODE
             OPERATIONS lt_operation
             MAPPED   et_mapped
             FAILED   et_failed
             REPORTED et_reported.
    ELSEIF iv_privileged_mode IS NOT INITIAL.
      MODIFY ENTITIES PRIVILEGED
             OPERATIONS lt_operation
             MAPPED   et_mapped
             FAILED   et_failed
             REPORTED et_reported.
    ELSE.
      MODIFY ENTITIES
             OPERATIONS lt_operation
             MAPPED   et_mapped
             FAILED   et_failed
             REPORTED et_reported.
    ENDIF.

    IF    iv_testrun IS NOT INITIAL
       OR iv_commit  IS NOT INITIAL.
      LOOP AT lt_operation INTO FINAL(ls_operation) WHERE entity_name IS NOT INITIAL.
        lv_entity_name = to_upper( ls_operation-entity_name ).
        COLLECT lv_entity_name INTO lt_commit_tab.
      ENDLOOP.

      IF lt_commit_tab IS NOT INITIAL.
        CASE abap_true.
          WHEN iv_testrun.
            COMMIT ENTITIES IN SIMULATION MODE
                   RESPONSES OF lt_commit_tab
                   FAILED   et_failed_commit
                   REPORTED et_reported_commit.
          WHEN iv_commit.
            COMMIT ENTITIES
                   RESPONSES OF lt_commit_tab
                   FAILED   et_failed_commit
                   REPORTED et_reported_commit.
        ENDCASE.
      ENDIF.
    ENDIF.

    mt_response = VALUE #( BASE mt_response
                           ( entity_name     = lv_entity_name
                             mapped          = et_mapped
                             failed          = et_failed
                             reported        = et_reported
                             failed_commit   = et_failed_commit
                             reported_commit = et_reported_commit ) ).
  ENDMETHOD.

  METHOD commit_eml_operations.
    ro_instance = me.

    IF it_entities IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF iv_simulation_mode IS NOT INITIAL.
      COMMIT ENTITIES IN SIMULATION MODE
             RESPONSES OF it_entities
             FAILED   et_failed_commit
             REPORTED et_reported_commit.
    ELSE.
      COMMIT ENTITIES
             RESPONSES OF it_entities
             FAILED   et_failed_commit
             REPORTED et_reported_commit.
    ENDIF.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    NEW lcl_eml_utilities_local( )->sample_post_dynamic_form_1( out ).
    NEW lcl_eml_utilities_local( )->sample_post_dynamic_form_2( out ).
  ENDMETHOD.
ENDCLASS.

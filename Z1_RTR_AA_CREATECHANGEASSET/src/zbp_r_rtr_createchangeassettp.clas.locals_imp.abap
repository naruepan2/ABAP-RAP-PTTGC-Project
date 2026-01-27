" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Naruepan Wongrachtachai
" Created on : Oct 07, 2025
" WRICEF ID  : RTR-AA020
" TR Number  : GSDK903648
" -----------------------------------------------------------------------
" Description:
"   RTR_AA020 Create and Change Asset Master
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
"
" -----------------------------------------------------------------------
CLASS lcl_createchangeasset_buffer DEFINITION.

  PUBLIC SECTION.
    TYPES ty_assetlineno               TYPE zr_rtr_createchangeassettp-assetlineno.

    TYPES tt_createchangeasset_key     TYPE TABLE OF zr_rtr_createchangeassettp-assetuuid.
    TYPES tt_simulatecreatechangeasset TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~simulatecreatechangeasset.
    TYPES tt_postcreatechangeasset     TYPE TABLE FOR ACTION IMPORT zr_rtr_createchangeassettp\\createchangeasset~postcreatechangeasset.

    CONSTANTS cv_max_records TYPE i VALUE 1000.

    CLASS-DATA gt_assetuuid_key  TYPE tt_createchangeasset_key.
    CLASS-DATA gt_simulate_key   TYPE tt_simulatecreatechangeasset.
    CLASS-DATA gt_posting_key    TYPE tt_postcreatechangeasset.
    CLASS-DATA gv_current_action TYPE c LENGTH 1.
    CLASS-DATA gv_total_records  TYPE i.
    CLASS-DATA gv_max_records    TYPE i.
    CLASS-DATA gv_event_flag     TYPE abap_boolean.
    CLASS-DATA gv_bgpf_flag      TYPE abap_boolean.
    CLASS-DATA gv_appjob_flag    TYPE abap_boolean.
    CLASS-DATA gv_job_text       TYPE cl_apj_rt_api=>ty_job_text.

    CLASS-METHODS unlock_createchangeasset.

ENDCLASS.


CLASS lcl_createchangeasset_buffer IMPLEMENTATION.
  METHOD unlock_createchangeasset.
    IF lcl_createchangeasset_buffer=>gt_assetuuid_key IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
           ENTITY createchangeasset
           UPDATE FIELDS ( isprocessed ) WITH VALUE #( FOR <lv_assetuuid> IN lcl_createchangeasset_buffer=>gt_assetuuid_key
                                                       ( assetuuid   = <lv_assetuuid>
                                                         isprocessed = space ) )
           " TODO: variable is assigned but never used (ABAP cleaner)
           FAILED FINAL(ls_failed)
           " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED FINAL(ls_reported).
  ENDMETHOD.
ENDCLASS.


CLASS lsc_zr_rtr_createchangeassettp DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.


CLASS lsc_zr_rtr_createchangeassettp IMPLEMENTATION.
  METHOD save_modified.
    DATA lv_job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZJT_RTR_CREATECHANGEASSET'.
    DATA ls_job_start_info    TYPE cl_apj_rt_api=>ty_start_info.
    DATA lv_job_name          TYPE cl_apj_rt_api=>ty_jobname.

    IF lcl_createchangeasset_buffer=>gv_appjob_flag IS NOT INITIAL.
      TRY.
          ls_job_start_info-start_immediately = abap_true.

          " Create Schedule job
          " To check application job. Search application name " Schedule Create or Change AssetMaster Jobs"
          cl_apj_rt_api=>schedule_job(
            EXPORTING iv_job_template_name   = lv_job_template_name
                      iv_job_text            = lcl_createchangeasset_buffer=>gv_job_text
                      is_start_info          = ls_job_start_info
                      it_job_parameter_value = VALUE #(
                          ( name    = zcl_rtr_createchangeasset_job=>cv_selname_uuid
                            t_value = VALUE #( FOR lv_assetuuid IN lcl_createchangeasset_buffer=>gt_assetuuid_key
                                               ( sign   = 'I'
                                                 option = 'EQ'
                                                 low    = lv_assetuuid ) ) )
                          ( name    = zcl_rtr_createchangeasset_job=>cv_selname_mode
                            t_value = VALUE #( sign   = 'I'
                                               option = 'EQ'
                                               ( low  = lcl_createchangeasset_buffer=>gv_current_action ) ) ) )
            IMPORTING ev_jobname             = lv_job_name ).

          " Success message
          ##NO_TEXT
          APPEND VALUE #( %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-success
                                     text     = |Create/Change job scheduled (job name: { lv_job_name })| ) )
                 TO reported-createchangeasset.
        CATCH cx_apj_rt INTO DATA(lx_job_scheduling_error).
          APPEND VALUE #( %msg = new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                              number   = 000
                                              severity = if_abap_behv_message=>severity-error
                                              v1       = lx_job_scheduling_error->get_longtext( ) ) )
                 TO reported-createchangeasset.

          lcl_createchangeasset_buffer=>unlock_createchangeasset( ).
        CATCH cx_root INTO DATA(lx_root_exception).
          APPEND VALUE #( %msg = new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                              number   = 000
                                              severity = if_abap_behv_message=>severity-error
                                              v1       = lx_root_exception->get_longtext( ) ) )
                 TO reported-createchangeasset.

          lcl_createchangeasset_buffer=>unlock_createchangeasset( ).
      ENDTRY.
    ELSEIF lcl_createchangeasset_buffer=>gv_event_flag IS NOT INITIAL.
      CASE lcl_createchangeasset_buffer=>gv_current_action.
        WHEN '1'.
          RAISE ENTITY EVENT zr_rtr_createchangeassettp~simulatecreatechangeassetevent
                FROM VALUE #( FOR ls_simulate IN lcl_createchangeasset_buffer=>gt_simulate_key
                              ( assetuuid = ls_simulate-assetuuid ) ).
        WHEN '2'.
          RAISE ENTITY EVENT zr_rtr_createchangeassettp~postcreatechangeassetevent
                FROM VALUE #( FOR ls_posting IN lcl_createchangeasset_buffer=>gt_posting_key
                              ( assetuuid = ls_posting-assetuuid ) ).
      ENDCASE.
    ENDIF.

    CLEAR: lcl_createchangeasset_buffer=>gt_assetuuid_key,
           lcl_createchangeasset_buffer=>gv_current_action,
           lcl_createchangeasset_buffer=>gt_simulate_key,
           lcl_createchangeasset_buffer=>gt_posting_key,
           lcl_createchangeasset_buffer=>gv_job_text.
    CLEAR: lcl_createchangeasset_buffer=>gv_appjob_flag,
           lcl_createchangeasset_buffer=>gv_event_flag,
           lcl_createchangeasset_buffer=>gv_bgpf_flag.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_createchangeasset DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR createchangeasset
      RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR createchangeasset RESULT result.

    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR createchangeasset RESULT result.

    METHODS downloadassettemplate FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~downloadassettemplate RESULT result.

    METHODS postcreatechangeasset FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~postcreatechangeasset.

    METHODS simulatecreatechangeasset FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~simulatecreatechangeasset.

    METHODS uploadassetfilecontent FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~uploadassetfilecontent.

    METHODS refreshcreatechangeassetrecord FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~refreshcreatechangeassetrecord RESULT result.

    METHODS precheck_postcreatechangeasset FOR PRECHECK
      IMPORTING keys FOR ACTION createchangeasset~postcreatechangeasset.

    METHODS precheck_simulatecreatechangea FOR PRECHECK
      IMPORTING keys FOR ACTION createchangeasset~simulatecreatechangeasset.

    METHODS createchangeassetappjob FOR MODIFY
      IMPORTING keys FOR ACTION createchangeasset~createchangeassetappjob.

ENDCLASS.


CLASS lhc_createchangeasset IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    IF     requested_features-%action-simulatecreatechangeasset = if_abap_behv=>mk-off
       AND requested_features-%action-postcreatechangeasset     = if_abap_behv=>mk-off.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
         ENTITY createchangeasset
         FIELDS ( assetuuid returntype ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).

    LOOP AT keys INTO DATA(ls_key).
      TRY.
          DATA(ls_result) = lt_result[ KEY id
                                       %tky = ls_key-%tky ].

          result = VALUE #(
              LET lv_terminate        = 'A'   " Termination Message message
                  lv_error            = CONV msgty( if_abap_behv_message=>severity-error )
                  lv_success          = CONV msgty( if_abap_behv_message=>severity-success )
                  lv_allowed_posting  = COND #( WHEN ls_result-returntype = lv_terminate
                                                  OR ls_result-returntype = lv_success THEN
                                                  if_abap_behv=>fc-o-disabled
                                                WHEN ls_result-returntype = lv_error THEN
                                                  if_abap_behv=>fc-o-enabled
                                                ELSE
                                                  if_abap_behv=>fc-o-enabled )
                  lv_allowed_simulate = COND #( WHEN ls_result-returntype = lv_terminate
                                                  OR ls_result-returntype = lv_success
                                                THEN if_abap_behv=>fc-o-disabled
                                                ELSE if_abap_behv=>fc-o-enabled )
              IN
                  BASE result
                  ( %tky    = ls_key-%tky
                    %action = VALUE #(
                        simulatecreatechangeasset = COND #( WHEN requested_features-%action-simulatecreatechangeasset = if_abap_behv=>mk-on
                                                            THEN lv_allowed_simulate
                                                            ELSE if_abap_behv=>fc-o-disabled )
                        postcreatechangeasset     = COND #( WHEN requested_features-%action-postcreatechangeasset = if_abap_behv=>mk-on
                                                            THEN lv_allowed_posting
                                                            ELSE if_abap_behv=>fc-o-disabled ) ) ) ).
        CATCH cx_sy_itab_line_not_found.
          result = VALUE #( BASE result
                            ( %tky    = ls_key-%tky
                              %action = VALUE #( simulatecreatechangeasset = if_abap_behv=>fc-o-disabled
                                                 postcreatechangeasset     = if_abap_behv=>fc-o-disabled ) ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_features.
  ENDMETHOD.

  METHOD downloadassettemplate.
    DATA lv_filename TYPE zcl_t2_bds_document_get=>bds_compid.

    DATA(ls_key) = keys[ 1 ].

    TRY.
        lv_filename = zcl_ext_abap_config=>get_instance(
                          iv_program = 'ZBP_R_RTR_CREATECHANGEASSETTP' )->get_single_value(
                                                                           iv_identifier = 'ASSET_TEMPLATE'
                                                                           iv_parameter1 = 'DOWNLOAD' ).
      CATCH zcx_ext_abap_config INTO FINAL(lx_ext_abap_config).
        failed-createchangeasset = VALUE #( ( %cid                          = ls_key-%cid
                                              %fail-cause                   = if_abap_behv=>cause-unspecific
                                              %action-downloadassettemplate = if_abap_behv=>mk-on ) ).
        reported-createchangeasset = VALUE #( ( %cid                          = ls_key-%cid
                                                %msg                          = new_message_with_text(
                                                    severity = if_abap_behv_message=>severity-error
                                                    text     = lx_ext_abap_config->get_text( ) )
                                                %action-downloadassettemplate = if_abap_behv=>mk-on ) ).
        RETURN.
    ENDTRY.

    TRY.
        zcl_ext_bds_document_utilities=>bds_get_file( EXPORTING iv_filename       = lv_filename
                                                      IMPORTING ev_file_encodex64 = DATA(lv_file_x64_content)
                                                                ev_mimetype       = DATA(lv_mimetype) ).
      CATCH zcx_ext_general_error.
        RETURN.
    ENDTRY.

    result = VALUE #( ( %cid   = ls_key-%cid
                        %param = VALUE #( assetfilename    = lv_filename
                                          assetfilecontent = lv_file_x64_content
                                          assetmimetype    = lv_mimetype ) ) ).
  ENDMETHOD.

  METHOD postcreatechangeasset.
    DATA lv_total_records      TYPE i.
    DATA lv_background_process TYPE i.

    lv_total_records = lines( keys ).

    TRY.
        lv_background_process = zcl_ext_abap_config=>get_instance(
                                    iv_program = 'ZBP_R_RTR_CREATECHANGEASSETTP' )->get_single_value(
                                        iv_identifier = 'BACKGROUND_PROCESS'
                                        iv_parameter1 = 'MAX_RECORD' ).
      CATCH zcx_ext_abap_config.
        lv_background_process = lcl_createchangeasset_buffer=>cv_max_records.
    ENDTRY.

    IF lv_total_records <= lv_background_process.
      zcl_rtr_createchangeasset_main=>get_instance( )->post_asset_master( EXPORTING it_keys     = keys
                                                                          CHANGING  " ct_result   = result
                                                                                    cs_mapped   = mapped
                                                                                    cs_failed   = failed
                                                                                    cs_reported = reported ).
      IF reported-createchangeasset IS INITIAL.
        reported-%other = VALUE #( ( new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                                  number   = '020'
                                                  severity = if_abap_behv_message=>severity-success ) ) ).
      ENDIF.
    ELSE.
      failed-createchangeasset = VALUE #( ( %tky = keys[ 1 ]-%tky ) ).
      reported-createchangeasset = VALUE #( ( %tky        = keys[ 1 ]-%tky
                                              %msg        = new_message(
                                                                id       = 'ZMRTR_ASSET_MSG_1'
                                                                number   = '015'
                                                                v1       = lv_background_process
                                                                severity = if_abap_behv_message=>severity-warning )
                                              %action     = VALUE #( postcreatechangeasset = if_abap_behv=>mk-on )
                                              %state_area = 'POSTING' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD simulatecreatechangeasset.
    DATA lv_total_records      TYPE i.
    DATA lv_background_process TYPE i.

    lv_total_records = lines( keys ).

    TRY.
        lv_background_process = zcl_ext_abap_config=>get_instance(
                                    iv_program = 'ZBP_R_RTR_CREATECHANGEASSETTP' )->get_single_value(
                                        iv_identifier = 'BACKGROUND_PROCESS'
                                        iv_parameter1 = 'MAX_RECORD' ).
      CATCH zcx_ext_abap_config.
        lv_background_process = lcl_createchangeasset_buffer=>cv_max_records.
    ENDTRY.

    IF lv_total_records <= lv_background_process.
      zcl_rtr_createchangeasset_main=>get_instance( )->simulate_asset_master( EXPORTING it_keys     = keys
                                                                              CHANGING  " ct_result   = result
                                                                                        cs_mapped   = mapped
                                                                                        cs_failed   = failed
                                                                                        cs_reported = reported ).
      IF reported-createchangeasset IS INITIAL.
        reported-%other = VALUE #( ( new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                                  number   = '019'
                                                  severity = if_abap_behv_message=>severity-success ) ) ).
      ENDIF.
    ELSE.
      failed-createchangeasset = VALUE #( ( %tky        = keys[ 1 ]-%tky
                                            %fail-cause = if_abap_behv=>cause-unspecific ) ).
      reported-createchangeasset = VALUE #(
          ( %tky        = keys[ 1 ]-%tky
            %msg        = new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                       number   = '015'
                                       v1       = lv_background_process
                                       severity = if_abap_behv_message=>severity-error )
            %action     = VALUE #( simulatecreatechangeasset = if_abap_behv=>mk-on )
            %state_area = 'SIMULATE' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD uploadassetfilecontent.
    zcl_rtr_createchangeasset_main=>get_instance( )->create_asset_entity_from_file( EXPORTING it_keys     = keys
                                                                                    CHANGING  cs_mapped   = mapped
                                                                                              cs_failed   = failed
                                                                                              cs_reported = reported ).
  ENDMETHOD.

  METHOD refreshcreatechangeassetrecord.
    zcl_rtr_createchangeasset_main=>get_instance( )->delete_all_to_asset_entity( EXPORTING it_keys     = keys
                                                                                 CHANGING  ct_result   = result
                                                                                           cs_mapped   = mapped
                                                                                           cs_failed   = failed
                                                                                           cs_reported = reported ).
  ENDMETHOD.

  METHOD precheck_postcreatechangeasset.
    READ ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
         ENTITY createchangeasset
         FIELDS ( assetuuid isprocessed ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).

    DELETE lt_result WHERE isprocessed IS INITIAL.
    DELETE lt_result WHERE    returntype = 'S'
                           OR returntype = 'A'.

    IF lines( lt_result ) > 0.
      failed-createchangeasset = VALUE #( ( %tky        = keys[ 1 ]-%tky
                                            %fail-cause = if_abap_behv=>cause-unspecific ) ).
      reported-createchangeasset = VALUE #(
          ( %tky        = keys[ 1 ]-%tky
            %msg        = new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                       number   = '016'
                                       severity = if_abap_behv_message=>severity-error )
            %action     = VALUE #( simulatecreatechangeasset = if_abap_behv=>mk-on )
            %state_area = 'PRECHECK_POSTING' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_simulatecreatechangea.
    READ ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
         ENTITY createchangeasset
         FIELDS ( assetuuid isprocessed ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_result).

    DELETE lt_result WHERE isprocessed IS INITIAL.
    DELETE lt_result WHERE    returntype = 'S'
                           OR returntype = 'A'.

    IF lines( lt_result ) > 0.
      failed-createchangeasset = VALUE #( ( %tky        = keys[ 1 ]-%tky
                                            %fail-cause = if_abap_behv=>cause-unspecific ) ).
      reported-createchangeasset = VALUE #(
          ( %tky        = keys[ 1 ]-%tky
            %msg        = new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                       number   = '016'
                                       severity = if_abap_behv_message=>severity-error )
            %action     = VALUE #( simulatecreatechangeasset = if_abap_behv=>mk-on )
            %state_area = 'PRECHECK_SIMULATE' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD createchangeassetappjob.
    DATA lt_assetlineno TYPE RANGE OF zr_rtr_createchangeassettp-assetlineno.

    DATA(lv_uname)           = cl_abap_context_info=>get_user_technical_name( ).
    DATA(lv_from_lineno_int) = abs( VALUE #( keys[ 1 ]-%param-assetfromlineno OPTIONAL ) ).
    DATA(lv_to_lineno_int)   = abs( VALUE #( keys[ 1 ]-%param-assettolineno OPTIONAL ) ).
    DATA(lv_from_lineno)     = CONV lcl_createchangeasset_buffer=>ty_assetlineno( lv_from_lineno_int ).
    DATA(lv_to_lineno)       = CONV lcl_createchangeasset_buffer=>ty_assetlineno( lv_to_lineno_int ).

    IF     lv_from_lineno IS NOT INITIAL
       AND lv_to_lineno   IS NOT INITIAL
       AND lv_from_lineno  > lv_to_lineno.
      reported-%other = VALUE #( ( new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                                number   = '017'
                                                v1       = |{ lv_from_lineno_int NUMBER = USER }|
                                                v2       = |{ lv_to_lineno_int NUMBER = USER }|
                                                severity = if_abap_behv_message=>severity-error ) ) ).
      RETURN.
    ENDIF.

    IF     lv_from_lineno IS NOT INITIAL
       AND lv_to_lineno   IS NOT INITIAL.
      lt_assetlineno = VALUE #( ( sign = 'I' option = 'BT' low = lv_from_lineno high = lv_to_lineno ) ).
    ELSEIF     lv_from_lineno IS NOT INITIAL
           AND lv_to_lineno   IS INITIAL.
      lt_assetlineno = VALUE #( ( sign = 'I' option = 'EQ' low = lv_from_lineno ) ).
    ELSEIF     lv_from_lineno IS INITIAL
           AND lv_to_lineno   IS NOT INITIAL.
      lt_assetlineno = VALUE #( ( sign = 'I' option = 'BT' low = 1 high = lv_to_lineno ) ).
    ENDIF.

    SELECT FROM zr_rtr_createchangeassettp WITH
      PRIVILEGED ACCESS
      FIELDS assetuuid,
             assetlineno,
             returntype,
             isprocessed
      WHERE (     createdby      = @lv_uname
              OR  lastchangedby  = @lv_uname )
        AND (     returntype    <> 'S'
              AND returntype    <> 'A' )
        AND isprocessed IS INITIAL
        AND assetlineno IN @lt_assetlineno
      INTO TABLE @FINAL(lt_assetuuid).

    IF lt_assetuuid IS INITIAL.
      reported-%other = VALUE #( ( new_message( id       = 'ZMRTR_ASSET_MSG_1'
                                                number   = '018'
                                                severity = if_abap_behv_message=>severity-information ) ) ).
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_rtr_createchangeassettp IN LOCAL MODE
           ENTITY createchangeasset
           UPDATE FIELDS ( isprocessed ) WITH VALUE #( FOR <ls_assetuuid> IN lt_assetuuid
                                                       ( assetuuid   = <ls_assetuuid>-assetuuid
                                                         isprocessed = abap_true ) )
           " TODO: variable is assigned but never used (ABAP cleaner)
           FAILED FINAL(ls_failed)
           " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED FINAL(ls_reported).

    lcl_createchangeasset_buffer=>gt_assetuuid_key = VALUE #( FOR <ls_assetuuid> IN lt_assetuuid
                                                              ( <ls_assetuuid>-assetuuid ) ).
    lcl_createchangeasset_buffer=>gv_appjob_flag   = abap_true.
    ##NO_TEXT
    lcl_createchangeasset_buffer=>gv_current_action = COND #( WHEN keys[ 1 ]-%param-processmode = 'Simulate'
                                                              THEN '1'      " Simulate Asset
                                                              ELSE '2' ).   " Create/Change Asset
    ##NO_TEXT
    lcl_createchangeasset_buffer=>gv_job_text = COND #( WHEN keys[ 1 ]-%param-processmode = 'Simulate'
                                                        THEN 'Simulate to Create or Change Asset Master'
                                                        ELSE 'Create or Change Asset Master' ).
  ENDMETHOD.
ENDCLASS.

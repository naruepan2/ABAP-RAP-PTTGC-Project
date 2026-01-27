CLASS zcl_ext_expimp_buffering_utils DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_buffer_name TYPE c LENGTH 60.
    TYPES ty_buffer_id   TYPE xstring.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_ext_expimp_buffering_utils.

    METHODS export_buffer_data
      IMPORTING iv_buffer_name TYPE ty_buffer_name
                iv_data        TYPE data
                iv_compression TYPE abap_boolean OPTIONAL.

    METHODS import_buffer_data
      IMPORTING iv_buffer_name  TYPE ty_buffer_name
                iv_clear_buffer TYPE abap_boolean DEFAULT abap_true
      EXPORTING ev_data         TYPE data.

  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO zcl_ext_expimp_buffering_utils.

ENDCLASS.


CLASS zcl_ext_expimp_buffering_utils IMPLEMENTATION.
  METHOD get_instance.
    go_instance = COND #( WHEN go_instance IS NOT BOUND THEN NEW #( ) ELSE go_instance ).
    RETURN go_instance.
  ENDMETHOD.

  METHOD export_buffer_data.
    DATA lv_buffer_id TYPE ty_buffer_id.

    IF iv_compression IS NOT INITIAL.
      TRY.
          EXPORT data = iv_data TO DATA BUFFER lv_buffer_id COMPRESSION ON.
        CATCH cx_sy_compression_error.
          TRY.
              EXPORT data = iv_data TO DATA BUFFER lv_buffer_id.
            CATCH cx_root.
          ENDTRY.
      ENDTRY.
    ELSE.
      TRY.
          EXPORT data = iv_data TO DATA BUFFER lv_buffer_id.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    MODIFY ztext_0010 FROM @( VALUE #( buffer_name = iv_buffer_name
                                       buffer_data = lv_buffer_id ) ).
  ENDMETHOD.

  METHOD import_buffer_data.
    DATA lv_json_string TYPE string.

    CLEAR ev_data.

    SELECT SINGLE * FROM ztext_0010 WHERE buffer_name = @iv_buffer_name INTO @FINAL(ls_ztext_0010).

    IF    sy-subrc                  IS NOT INITIAL
       OR ls_ztext_0010-buffer_data IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        IMPORT data = ev_data FROM DATA BUFFER ls_ztext_0010-buffer_data.
      CATCH cx_root.
        IF iv_clear_buffer IS NOT INITIAL.
          DELETE FROM ztext_0010 WHERE buffer_name = @iv_buffer_name.
        ENDIF.

        RETURN.
    ENDTRY.

    IF iv_clear_buffer IS NOT INITIAL.
      DELETE FROM ztext_0010 WHERE buffer_name = @iv_buffer_name.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

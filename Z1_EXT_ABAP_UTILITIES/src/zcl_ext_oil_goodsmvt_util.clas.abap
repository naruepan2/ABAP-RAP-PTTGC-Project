CLASS zcl_ext_oil_goodsmvt_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS provide_goodsmvt_item_param
      IMPORTING
                !iv_matnr            TYPE matnr
                !iv_werks            TYPE werks_d
                !iv_lgort            TYPE lgort_d
      EXPORTING
                !et_qci_param        TYPE zcl_t2_bapi_goodsmvt_create_oi=>_bapioil2017_gm_itm_crte_param
                !es_merge_parameters TYPE zcl_t2_oib_qci_defaults=>oib_a04
      RAISING   zcx_ext_general_error .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_oil_goodsmvt_util IMPLEMENTATION.


  METHOD provide_goodsmvt_item_param.
    DATA: lt_qci_dflts TYPE zcl_t2_oib_qci_defaults=>oi_t_qci_tab,
          ls_param     TYPE  zcl_t2_bapi_goodsmvt_create_oi=>bapioil2017_gm_itm_crte_param.
    TRY.
        CALL METHOD zcl_t2_oib_qci_defaults=>oib_qci_defaults
          EXPORTING
            i_matnr  = iv_matnr
            i_werks  = iv_werks
            i_lgort  = iv_lgort
          CHANGING
            et_param = lt_qci_dflts.
      CATCH zcx_ext_general_error.
        RETURN.
    ENDTRY.

    LOOP AT lt_qci_dflts INTO DATA(ls_qci_dflts)
                         WHERE par_fltp IS NOT INITIAL OR
                               par_char IS NOT INITIAL .

      ls_param-calculatemissing = 'X'.

      CASE ls_qci_dflts-fieldname.
        WHEN 'MCF'.
          ls_param-metercorrectionfactor   = ls_qci_dflts-par_fltp.
        WHEN 'MTTMP'.     "Oil/Gas Material Temperature
          ls_param-materialtemperature     = ls_qci_dflts-par_fltp.
        WHEN 'MTTEH'.     "Oil/Gas Material Temperature Unit
          ls_param-materialtemperature_uom = ls_qci_dflts-par_char.
        WHEN 'TDICH'.     "Density @ 15°C
          ls_param-testdensity             = ls_qci_dflts-par_fltp.
        WHEN 'TDICHEH'.   "Density UOM
          ls_param-testdensity_uom         = ls_qci_dflts-par_char.
        WHEN 'TSTMP'.     "Test temperature
          ls_param-testtemperature_density =  ls_qci_dflts-par_fltp .
        WHEN 'TSTEH'.     "Test temperature UOM
          ls_param-testtemp_density_uom    = ls_qci_dflts-par_char.
        WHEN 'VAPRES'.    "Vapor Temperature
          ls_param-vaporpressure           =  ls_qci_dflts-par_fltp .
        WHEN 'VAPRESEH'.  "Vapor Temperature uom
          ls_param-vaporpressure_uom       = ls_qci_dflts-par_char.
        WHEN 'MOLWEIGHT'.
          ls_param-molecularweight         =  ls_qci_dflts-par_fltp .
        WHEN 'MOLWEIGHTEH'.
          ls_param-molecularweight_uom     = ls_qci_dflts-par_char.
        WHEN 'THVAL'.
          ls_param-testheatingvalue        = ls_qci_dflts-par_fltp .
        WHEN 'THVALEH'.
          ls_param-testheatingvalue_uom    = ls_qci_dflts-par_char.
      ENDCASE.

    ENDLOOP.
    APPEND ls_param TO et_qci_param.

    IF es_merge_parameters IS SUPPLIED.
      TRY.
          CALL METHOD zcl_t2_oib_qci_defaults=>oi0_qci_merge_parameters
            EXPORTING
              it_param      = lt_qci_dflts
            CHANGING
              cs_parameters = es_merge_parameters.
        CATCH zcx_ext_general_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

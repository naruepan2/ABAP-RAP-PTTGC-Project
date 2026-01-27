" -----------------------------------------------------------------------
" Project Name: SMILE
" Created by : Boontip Roongrassamee
" Created on : Sep 19, 2025
" WRICEF ID  :
" TR Number  : GSDK902921
" -----------------------------------------------------------------------
" Description: post goods movement to ITAS
" -----------------------------------------------------------------------
" Change History
" -----------------------------------------------------------------------
" Date |TR Number |Search Term |Developer |Description
" -------- ----------- ----------- ----------- -------------------------
class ZCL_EXT_BATCH_UTILITIES definition
  public
  final
  create public .

public section.

  types:
    _BAPIRET2 TYPE STANDARD TABLE OF bapiret2                       WITH DEFAULT KEY .
  types:
    ty_qty TYPE p LENGTH 16 DECIMALS 2 .
  types:
    begin of ty_batch_stock,
    material         type i_materialstock_2-material,
    plant            type i_materialstock_2-plant,
    expired_date     type i_batch-shelflifeexpirationdate,
    sloc             type i_materialstock_2-storagelocation,
    batch            type i_materialstock_2-batch,
    current_qty      type i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
    materialbaseunit type i_materialstock_2-materialbaseunit,
    end of ty_batch_stock .
  types:
    tty_batch_stock TYPE STANDARD TABLE OF ty_batch_stock .
  types:
    BEGIN OF ty_batch_stock_key,
        material        TYPE i_materialstock_2-material,
        plant           TYPE i_materialstock_2-plant,
        sloc            TYPE i_materialstock_2-storagelocation,
      END OF ty_batch_stock_key .
  types:
    tty_batch_stock_key TYPE SORTED TABLE OF ty_batch_stock_key WITH UNIQUE KEY material plant .
  types:
    BEGIN OF ty_fifo_key ,
        material TYPE i_materialstock_2-material,
        plant    TYPE i_materialstock_2-plant,
        sloc     TYPE i_materialstock_2-storagelocation,
      END OF ty_fifo_key .
  types:
    BEGIN OF ty_batch,
        batch TYPE i_materialstock_2-batch,
      END OF ty_batch .
  types:
    tty_batch TYPE SORTED TABLE OF ty_batch WITH NON-UNIQUE KEY batch .
  types:
    BEGIN OF ty_batch_avg_input,
        material   TYPE i_materialstock_2-material,
        batch_from TYPE tty_batch,
        batch_to   TYPE i_materialstock_2-batch,
      END OF ty_batch_avg_input .
  types:
    tty_batch_avg_input TYPE STANDARD TABLE OF ty_batch_avg_input .
  types:
    BEGIN OF ty_batch_from_to,
        material   TYPE i_manufacturingorder-material,
        batch_to   TYPE i_manufacturingorder-batch,
        batch_from TYPE i_manufacturingorder-batch,
      END OF ty_batch_from_to .
  types:
    tty_batch_from_to TYPE SORTED TABLE OF ty_batch_from_to WITH UNIQUE KEY material batch_to batch_from .

  class-methods GET_BATCH_STOCK
    importing
      !IT_BATCH_STOCK_KEY type TTY_BATCH_STOCK_KEY
    exporting
      !ET_BATCH_STOCK type TTY_BATCH_STOCK .
  class-methods GET_QTY_BY_BATCH_FIFO
    importing
      !IS_INPUT type TY_FIFO_KEY
      !IV_QTY type TY_QTY
    exporting
      !ET_BATCH_FIFO type TTY_BATCH_STOCK
      !EV_SUBRC type SY-SUBRC
      !EV_MESSAGE type STRING
    changing
      !CT_BATCH_STOCK type TTY_BATCH_STOCK .
  class-methods UPDATE_BATCH_WITH_AVG_VALUE
    importing
      !IT_BATCH_FROM_TO type TTY_BATCH_FROM_TO
      !IV_COMMIT type ABAP_BOOLEAN
      !_DEST_ type RFCDEST default 'NONE'
    exporting
      !EV_ERROR type ABAP_BOOLEAN
      !ET_RETURN type _BAPIRET2 .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_mat_batch,
        material TYPE i_materialstock_2-material,
        batch    TYPE i_materialstock_2-batch,
      END OF ty_mat_batch .

  class-methods _CONVERT_BTCH_FROMTO_AVGINP
    importing
      !IT_BATCH_FROM_TO type TTY_BATCH_FROM_TO
    exporting
      !ET_BATCH_AVG_INPUT type TTY_BATCH_AVG_INPUT .
  class-methods _BAPI_OBJCL_GETDETAIL_OF_BATCH
    importing
      !IS_INPUT type TY_MAT_BATCH
      !_DEST_ type RFCDEST default 'NONE'
    exporting
      !EV_CLASSNUM type ZCL_T2_OBJCL_GETCLASSES=>BAPI1003_ALLOC_LIST-CLASSNUM
      !ET_VALUECHAR type ZCL_T2_MATERIAL_CLASS=>_BAPI1003_ALLOC_VALUES_CHAR
      !ET_VALUECURR type ZCL_T2_MATERIAL_CLASS=>_BAPI1003_ALLOC_VALUES_CURR
      !ET_VALUENUM type ZCL_T2_MATERIAL_CLASS=>_BAPI1003_ALLOC_VALUES_NUM
      !EV_ERROR type ABAP_BOOLEAN
      !ET_RETURN type _BAPIRET2 .
ENDCLASS.



CLASS ZCL_EXT_BATCH_UTILITIES IMPLEMENTATION.


  METHOD GET_BATCH_STOCK.
    DATA: lr_sloc TYPE RANGE OF i_materialstock_2-storagelocation.
    IF it_batch_stock_key[] IS NOT INITIAL.
      SELECT a~material,
             a~plant,
             b~shelflifeexpirationdate AS expired_date,
             a~storagelocation AS sloc,
             a~batch,
             SUM( matlwrhsstkqtyinmatlbaseunit ) AS current_qty,
             a~materialbaseunit
      FROM i_materialstock_2 AS a INNER JOIN i_batch AS b
      ON a~material = b~material
      AND a~plant = b~plant
      AND a~batch = b~batch
                                  INNER JOIN @it_batch_stock_key AS c
      ON a~material = c~material
      AND a~plant = c~plant
      GROUP BY a~material, a~plant, a~storagelocation, a~batch, b~shelflifeexpirationdate, a~materialbaseunit
      ORDER BY a~material, a~plant, b~shelflifeexpirationdate, a~storagelocation, a~batch
      INTO TABLE @et_batch_stock  .

      DELETE et_batch_stock WHERE current_qty = 0.

      READ TABLE it_batch_stock_key TRANSPORTING NO FIELDS WITH KEY sloc = '' ."#EC CI_SORTSEQ
      IF sy-subrc <> 0.
        lr_sloc = VALUE #( FOR <ls_key> IN it_batch_stock_key
                          ( sign   = 'I'
                            option = 'EQ'
                            low = <ls_key>-sloc ) ).
        DELETE et_batch_stock WHERE sloc NOT IN lr_sloc. "filter only sloc from input
      ENDIF.


    ENDIF.
  ENDMETHOD.


  METHOD  GET_QTY_BY_BATCH_FIFO.
    DATA: lt_r_sloc TYPE RANGE OF i_materialstock_2-storagelocation.
    CLEAR: ev_subrc,
           ev_message,
           et_batch_fifo.


    DATA(lv_qty) = iv_qty.
    IF is_input-sloc IS NOT INITIAL.
      lt_r_sloc = VALUE #( ( sign = 'I'
                            option = 'EQ'
                            low = is_input-sloc ) ).
    ENDIF.
    LOOP AT ct_batch_stock ASSIGNING FIELD-SYMBOL(<ls_batch_stock>)
                                     WHERE material = is_input-material
                                     AND   plant    = is_input-plant
                                     AND   sloc     IN lt_r_sloc .
      DATA(ls_batch_stock) = <ls_batch_stock>.
      IF <ls_batch_stock>-current_qty = 0.
        DELETE ct_batch_stock.
        CONTINUE.
      ENDIF.
      IF <ls_batch_stock>-current_qty > lv_qty.
        <ls_batch_stock>-current_qty -= lv_qty.
        APPEND VALUE #( BASE ls_batch_stock
                        current_qty = lv_qty
                      ) TO et_batch_fifo .
        lv_qty = 0.
        EXIT.
      ELSEIF <ls_batch_stock>-current_qty <= lv_qty.
        APPEND ls_batch_stock TO et_batch_fifo.
        lv_qty -=  <ls_batch_stock>-current_qty.
        DELETE ct_batch_stock.
        IF lv_qty = 0.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_qty > 0.
      ev_subrc = 1.
      ev_message = |There is not enough stock for material { is_input-material }| ##NO_TEXT.
    ENDIF.
  ENDMETHOD.


  METHOD update_batch_with_avg_value.
    TYPES:
      BEGIN OF lty_charact_key,
        characteristic TYPE i_clfncharacteristic-characteristic,
      END OF lty_charact_key.
    DATA: ls_mat_batch     TYPE ty_mat_batch,
          lt_valuechar_all TYPE zcl_t2_material_class=>_bapi1003_alloc_values_char,
          lt_valuecurr_all TYPE zcl_t2_material_class=>_bapi1003_alloc_values_curr,
          lt_valuenum_all  TYPE zcl_t2_material_class=>_bapi1003_alloc_values_num,
          lt_valuechar_upd TYPE zcl_t2_material_class=>_bapi1003_alloc_values_char,
          lt_valuecurr_upd TYPE zcl_t2_material_class=>_bapi1003_alloc_values_curr,
          lt_valuenum_upd  TYPE zcl_t2_material_class=>_bapi1003_alloc_values_num,
          lt_charact_key   TYPE SORTED TABLE OF lty_charact_key WITH UNIQUE KEY characteristic,
          lt_return        TYPE zcl_t2_objcl_getclasses=>_bapiret2.
    DATA: lv_objectkey_long TYPE zcl_t2_objcl_getclasses=>cuobn90.

    _convert_btch_fromto_avginp( EXPORTING it_batch_from_to = it_batch_from_to
                                 IMPORTING et_batch_avg_input = DATA(lt_input) ).


    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<ls_input>).
      CLEAR: lt_valuechar_all,
             lt_valuecurr_all,
             lt_valuenum_all,
             lt_valuechar_upd,
             lt_valuecurr_upd ,
             lt_valuenum_upd,
             lt_charact_key,
             lt_return.
*  //// read batch classification to batch ////
      ls_mat_batch = VALUE #( material =  <ls_input>-material
                              batch    =  <ls_input>-batch_to ).
      _bapi_objcl_getdetail_of_batch(
        EXPORTING
          is_input     = ls_mat_batch
          _dest_       = _dest_
        IMPORTING
          ev_error     =  ev_error
          et_return    =  lt_return
          ev_classnum  =  DATA(lv_classnum_to)
          et_valuechar =  DATA(lt_valuechar_to)
          et_valuecurr =  DATA(lt_valuecurr_to)
          et_valuenum  =  DATA(lt_valuenum_to) )    .
      IF ev_error = abap_true.
        append LINES OF lt_return to et_return.
        EXIT.
      ENDIF.
*     ////  read batch classification from batch ////
      LOOP AT <ls_input>-batch_from ASSIGNING FIELD-SYMBOL(<ls_batch_from>).
        IF <ls_batch_from>-batch <> <ls_input>-batch_to.
          ls_mat_batch = VALUE #( material =  <ls_input>-material
                                  batch    =  <ls_batch_from>-batch ).
          _bapi_objcl_getdetail_of_batch(
            EXPORTING
              is_input     = ls_mat_batch
              _dest_       = _dest_
            IMPORTING
              ev_error     =  ev_error
              et_return    =  lt_return
              ev_classnum  =  DATA(lv_classnum)
              et_valuechar =  DATA(lt_valuechar)
              et_valuecurr =  DATA(lt_valuecurr)
              et_valuenum  =  DATA(lt_valuenum) )    .
          IF ev_error = abap_true.
            append LINES OF lt_return to et_return.
            EXIT.
          ENDIF.
          IF lv_classnum IS INITIAL.  "no maintain
            CONTINUE.
          ENDIF.
          IF lv_classnum <> lv_classnum_to.
            ev_error = abap_true.
            APPEND VALUE #(
              type   = 'E'
              id     = 'ZMPPD'
              number = '000'
              message = |Batch class is different between batch from { lv_classnum } and batch to { lv_classnum_to }|    ##NO_TEXT
              ) TO et_return.
            EXIT.
          ENDIF.
          APPEND LINES OF lt_valuecurr TO lt_valuecurr_all .
          APPEND LINES OF lt_valuenum TO lt_valuenum_all .
          APPEND LINES OF lt_valuechar TO lt_valuechar_all .
        ENDIF.
      ENDLOOP.
      IF ev_error = abap_true.
        EXIT.
      ENDIF.

      IF  lt_valuecurr_all IS INITIAL
      AND lt_valuenum_all IS INITIAL
      AND lt_valuechar_all IS INITIAL.
        APPEND VALUE #(
          type   = 'I'
          id     = 'ZMPPD'
          number = '000'
          message = |No value from batch to be updated|    ##NO_TEXT
          ) TO et_return.
        EXIT.
      ENDIF.


      LOOP AT lt_valuenum_all ASSIGNING FIELD-SYMBOL(<ls_valuenum>).
        DATA(ls_key) = VALUE lty_charact_key( characteristic = <ls_valuenum>-charact ).
        INSERT ls_key INTO TABLE lt_charact_key.
      ENDLOOP.
      LOOP AT lt_valuecurr_all ASSIGNING FIELD-SYMBOL(<ls_valuecurr>).
        ls_key = VALUE lty_charact_key( characteristic = <ls_valuecurr>-charact ).
        INSERT ls_key INTO TABLE lt_charact_key.
      ENDLOOP.

      DELETE lt_valuechar_all WHERE value_char IS INITIAL. "#EC CI_STDSEQ
      SORT lt_valuechar_all ASCENDING BY charact.      "#EC CI_SORTLOOP
      DELETE ADJACENT DUPLICATES FROM lt_valuechar_all COMPARING charact .
      lt_valuechar_upd = lt_valuechar_all.

*     //// get characteristic  ////
      SELECT a~characteristic AS charact,
             charcdatatype  AS datatype
      FROM i_clfncharacteristic AS a INNER JOIN @lt_charact_key AS b
      ON a~characteristic = b~characteristic
      INTO TABLE @DATA(lt_charact) .


*   //// calcuate batch classification /////

      DATA: lv_value_from TYPE zcl_t2_material_class=>bapi1003_alloc_values_num-value_from,
            lv_value_to   TYPE zcl_t2_material_class=>bapi1003_alloc_values_num-value_to,
            lv_cnt        TYPE i.
      LOOP AT lt_valuenum_all ASSIGNING <ls_valuenum>
        GROUP BY <ls_valuenum>-charact ASCENDING
        INTO DATA(lv_group_num) .
        READ TABLE lt_charact INTO DATA(ls_charact) WITH KEY charact = lv_group_num. "#EC CI_STDSEQ
        IF ls_charact-datatype <> 'NUM'
        AND ls_charact-datatype <> 'CURR'.
          CONTINUE.
        ENDIF.
        CLEAR: lv_value_from,
               lv_value_to,
               lv_cnt.
        LOOP AT GROUP lv_group_num INTO DATA(ls_valuenum).
          lv_value_from += ls_valuenum-value_from.
          lv_value_to   += ls_valuenum-value_to.
          lv_cnt        += 1.
        ENDLOOP.
        lv_value_from = lv_value_from / lv_cnt.
        lv_value_to = lv_value_to / lv_cnt.
        APPEND VALUE #( BASE CORRESPONDING #( ls_valuenum )
                        value_from =  lv_value_from
                        value_to =  lv_value_to  )  TO lt_valuenum_upd.
      ENDLOOP.

      LOOP AT lt_valuecurr_all ASSIGNING <ls_valuecurr>
        GROUP BY <ls_valuecurr>-charact ASCENDING
        INTO DATA(lv_group_curr) .
        READ TABLE lt_charact INTO ls_charact WITH KEY charact = lv_group_curr. "#EC CI_STDSEQ
        IF ls_charact-datatype <> 'NUM'
        AND ls_charact-datatype <> 'CURR'.
          CONTINUE.
        ENDIF.
        CLEAR: lv_value_from,
               lv_value_to,
               lv_cnt.
        LOOP AT GROUP lv_group_curr INTO DATA(ls_valuecurr).
          lv_value_from += ls_valuecurr-value_from.
          lv_value_to   += ls_valuecurr-value_to.
          lv_cnt        += 1.
        ENDLOOP.
        lv_value_from = lv_value_from / lv_cnt.
        lv_value_to = lv_value_to / lv_cnt.
        APPEND VALUE #( BASE CORRESPONDING #( ls_valuecurr )
                        value_from =  lv_value_from
                        value_to =  lv_value_to  )  TO lt_valuecurr_upd.
      ENDLOOP.


*  //// merge "from batch" to "to batch" /////
      LOOP AT lt_valuenum_to ASSIGNING FIELD-SYMBOL(<ls_valuenum_to>).
        READ TABLE lt_valuenum_upd INTO DATA(ls_valuenum_upd) WITH KEY charact = <ls_valuenum_to>-charact. "#EC CI_STDSEQ
        IF sy-subrc = 0.
          DATA(lv_tabix) = sy-tabix.
          <ls_valuenum_to>-value_from = ls_valuenum_upd-value_from.
          <ls_valuenum_to>-value_to   = ls_valuenum_upd-value_to.
          DELETE lt_valuenum_upd INDEX lv_tabix.
        ENDIF.
      ENDLOOP.
      APPEND LINES OF lt_valuenum_upd TO lt_valuenum_to.
      LOOP AT lt_valuecurr_to ASSIGNING FIELD-SYMBOL(<ls_valuecurr_to>).
        READ TABLE lt_valuecurr_upd INTO DATA(ls_valuecurr_upd) WITH KEY charact = <ls_valuecurr_to>-charact. "#EC CI_STDSEQ
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          <ls_valuecurr_to>-value_from = ls_valuecurr_upd-value_from.
          <ls_valuecurr_to>-value_to   = ls_valuecurr_upd-value_to.
          DELETE lt_valuecurr_upd INDEX lv_tabix.
        ENDIF.
      ENDLOOP.
      APPEND LINES OF lt_valuecurr_upd TO lt_valuecurr_to.
      LOOP AT lt_valuechar_to ASSIGNING FIELD-SYMBOL(<ls_valuechar_to>).
        IF <ls_valuechar_to>-charact = 'ZMM_BATCH_NO'.
          CONTINUE.
        ENDIF.
        READ TABLE lt_valuechar_upd INTO DATA(ls_valuechar_upd) WITH KEY charact = <ls_valuechar_to>-charact. "#EC CI_STDSEQ
        IF sy-subrc = 0.
          lv_tabix = sy-tabix.
          <ls_valuechar_to> = ls_valuechar_upd.
          DELETE lt_valuechar_upd INDEX lv_tabix.
        ENDIF.
      ENDLOOP.
      DELETE lt_valuechar_upd WHERE charact = 'ZMM_BATCH_NO'. "#EC CI_STDSEQ
      APPEND LINES OF lt_valuechar_upd TO lt_valuechar_to.

      IF lt_valuechar_to IS INITIAL
      AND lt_valuecurr_to IS INITIAL
      AND lt_valuenum_to IS INITIAL.
        APPEND VALUE #(
          type   = 'I'
          id     = 'ZMPPD'
          number = '000'
          message = |No value to be updated|    ##NO_TEXT
          ) TO et_return.
        CONTINUE.
      ENDIF.

      TRY.
          ls_mat_batch = VALUE #( material =  <ls_input>-material
                                batch    =  <ls_input>-batch_to ).
          lv_objectkey_long = ls_mat_batch.
          zcl_t2_material_class=>bapi_objcl_change(
            EXPORTING
              classnum           = lv_classnum_to
              classtype          = '023'
              objectkey_long     = lv_objectkey_long
              objecttable        = 'MCH1'
              _dest_             = _dest_
            CHANGING
              allocvaluescharnew =  lt_valuechar_to
              allocvaluescurrnew =  lt_valuecurr_to
              allocvaluesnumnew  =  lt_valuenum_to
              return             =  lt_return  ).
        CATCH cx_aco_application_exception.
        CATCH cx_aco_communication_failure.
        CATCH cx_aco_system_failure.
      ENDTRY.
      READ TABLE lt_return INTO DATA(ls_return) WITH KEY type = 'E'. "#EC CI_STDSEQ
      IF sy-subrc = 0.
        append LINES OF lt_return to et_return.
        ev_error = abap_true.
        EXIT.
      ELSE.
        IF iv_commit = abap_true.
          APPEND  VALUE #(
            type   = 'S'
            id     = 'ZMPPD'
            number = '000'
            message = |Batch { <ls_input>-batch_to } is changed |    ##NO_TEXT
           ) TO et_return.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF ev_error = abap_true.
      DELETE et_return WHERE type = 'S'.
    ELSE.
      IF iv_commit = abap_true.
        TRY.
            CALL METHOD zcl_t2_bapi_transaction=>bapi_transaction_commit
              EXPORTING
                wait   = 'X'
                _dest_ = _dest_.
          CATCH cx_aco_application_exception.
          CATCH cx_aco_communication_failure.
          CATCH cx_aco_system_failure.
        ENDTRY.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD _bapi_objcl_getdetail_of_batch.
    DATA: lv_objectkey_long TYPE zcl_t2_objcl_getclasses=>cuobn90,
          lv_message        TYPE string,
          lt_alloc          TYPE zcl_t2_objcl_getclasses=>_bapi1003_alloc_list.

    lv_objectkey_long = is_input.
    TRY.
        zcl_t2_objcl_getclasses=>bapi_objcl_getclasses(
          EXPORTING
            objecttable_imp    = 'MCH1'
            classtype_imp      = '023'
            objectkey_imp_long = lv_objectkey_long
            _dest_             = _DEST_
          CHANGING
            alloclist          = lt_alloc
            return             = et_return   ) .
      CATCH cx_aco_application_exception.
      CATCH cx_aco_communication_failure.
      CATCH cx_aco_system_failure.
    ENDTRY.
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc = 0.
      ev_error = abap_true.
      RETURN.
    ENDIF.


    READ TABLE lt_alloc INTO DATA(ls_alloc) INDEX 1.
    ev_classnum =   ls_alloc-classnum.
    CLEAR et_return.
    TRY.
        zcl_t2_material_class=>bapi_objcl_getdetail(
         EXPORTING
            classnum         = ls_alloc-classnum
            classtype        = '023'
            objectkey_long   = lv_objectkey_long
            objecttable      = 'MCH1'
            _dest_           = _DEST_
          CHANGING
            allocvalueschar  = et_valuechar
            allocvaluescurr  = et_valuecurr
            allocvaluesnum   = et_valuenum
            return           = et_return  ) .
      CATCH cx_aco_application_exception.
      CATCH cx_aco_communication_failure.
      CATCH cx_aco_system_failure.

    ENDTRY.
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc = 0.
      ev_error = abap_true.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD _CONVERT_BTCH_FROMTO_AVGINP.
    DATA: lt_batch TYPE tty_batch.
    LOOP AT it_batch_from_to INTO DATA(ls_batch_from_to)
    GROUP BY ( material = ls_batch_from_to-material
               batch_to = ls_batch_from_to-batch_to )
    INTO DATA(lv_group_mat_to).

      CLEAR lt_batch.

      LOOP AT GROUP lv_group_mat_to INTO DATA(ls_group).
        INSERT VALUE #( batch = ls_group-batch_from ) INTO TABLE lt_batch.
      ENDLOOP.

      APPEND VALUE #( material   = lv_group_mat_to-material
                      batch_from =  lt_batch
                      batch_to   = lv_group_mat_to-batch_to )
      TO et_batch_avg_input.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

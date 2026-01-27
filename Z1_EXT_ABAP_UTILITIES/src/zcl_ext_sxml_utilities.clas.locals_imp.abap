*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_sample_xml IMPLEMENTATION.
  METHOD sample_xml_display.
    DATA(lo_xml_dyn_util) = zcl_ext_sxml_utilities=>get_instance( ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*    TYPES: BEGIN OF ts_rate,
*             time     TYPE d,
*             currency TYPE c LENGTH 3,
*             rate     TYPE decfloat16,
*           END OF ts_rate.
*    DATA lt_rates TYPE STANDARD TABLE OF ts_rate WITH EMPTY KEY.
*
*    TRY.
*        lo_xml_dyn_util->parse_by_attr_to_table(
*          EXPORTING iv_input_string           = lo_xml_dyn_util->_get_example_xml( )              " your XML string
*                    iv_row_element            = 'Cube'              " leaf rows are <Cube .../>
*                    iv_ns_uri                 = 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
*                    it_inherit_from_ancestors = VALUE string_table( ( `time` ) )
*                    it_attr_map               = VALUE zcl_xml_dyn_util=>tt_attr_map(
*                                                          ( xml_name = 'time'     comp_name = 'TIME' )
*                                                          ( xml_name = 'currency' comp_name = 'CURRENCY' )
*                                                          ( xml_name = 'rate'     comp_name = 'RATE' ) )
*          CHANGING  ct_result                 = lt_rates ).
*
*        io_out->write( lt_rates )
*          CATCH cx_static_check.
*        " handle exception
*    ENDTRY.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Build a line type at runtime
    DATA(lo_line_descr) = cl_abap_structdescr=>create(
        p_components = VALUE cl_abap_structdescr=>component_table(
                                 ( name = 'TIME'     type = cl_abap_elemdescr=>get_d( ) )
                                 ( name = 'CURRENCY' type = cl_abap_elemdescr=>get_c( 3 ) )
                                 ( name = 'RATE'     type = cl_abap_elemdescr=>get_decfloat16( ) ) ) ).

    " Parse and get a dynamic internal table back
    DATA lr_tab TYPE REF TO data.

    TRY.
        lo_xml_dyn_util->parse_by_attr_create(
          EXPORTING iv_input_string           = _get_example_xml_1( )
                    it_row_element            = VALUE #( ( `Cube` ) )
                    iv_ns_uri                 = 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
                    it_inherit_from_ancestors = VALUE #( ( `time` ) )
                    io_line_type              = lo_line_descr
                    it_attr_map               = VALUE zcl_ext_sxml_utilities=>tt_attr_map(
                                                          ( xml_name = 'time'     comp_name = 'TIME' )
                                                          ( xml_name = 'currency' comp_name = 'CURRENCY' )
                                                          ( xml_name = 'rate'     comp_name = 'RATE' ) )
          IMPORTING er_result_tab             = lr_tab ).
      CATCH cx_static_check.
        " handle exception
    ENDTRY.

    FIELD-SYMBOLS <lt_any> TYPE STANDARD TABLE.

    IF lr_tab IS BOUND.
      ASSIGN lr_tab->* TO <lt_any>.
      " further processing
      io_out->write( <lt_any> ).
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    TYPES: BEGIN OF ts_person,
             name  TYPE string, " or C(40)
             title TYPE string, " or C(10)
             age   TYPE i,
           END OF ts_person.
    DATA lt_people TYPE STANDARD TABLE OF ts_person WITH EMPTY KEY.

    TRY.
        lo_xml_dyn_util->parse_by_attr_to_table(
          EXPORTING
            iv_input_string = _get_example_xml_2( )
            it_row_element  = VALUE #( ( `item` ) )   " each <item> is one row
*            it_inherit_from_ancestors = VALUE #( ( `NAME` )
*                                                 ( `TITLE` )
*                                                 ( `AGE` ) )
            it_attr_map     = VALUE zcl_ext_sxml_utilities=>tt_attr_map( ( xml_name = 'NAME'  comp_name = 'NAME'  )
                                                                         ( xml_name = 'TITLE' comp_name = 'TITLE' )
                                                                         ( xml_name = 'AGE'   comp_name = 'AGE'   ) )
          CHANGING
            ct_result       = lt_people ).

        io_out->write( lt_people ).
      CATCH cx_static_check.
        " handle exception
    ENDTRY.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Build a line type at runtime
    lo_line_descr = cl_abap_structdescr=>create(
                        p_components = VALUE cl_abap_structdescr=>component_table(
                                                 ( name = 'INVOICE_NO'   type = cl_abap_elemdescr=>get_c( 10 ) )
                                                 ( name = 'INVOICE_TYPE' type = cl_abap_elemdescr=>get_c( 10 ) )
                                                 ( name = 'INVOICE_DATE' type = cl_abap_elemdescr=>get_d( ) ) ) ).
    CLEAR lr_tab.

    TRY.
        lo_xml_dyn_util->parse_by_attr_create(
          EXPORTING iv_input_string = _get_example_xml_3( )
                    it_row_element  = VALUE #( ( `INV_HEADER` ) )
*                    iv_ns_uri       = 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
*                    it_inherit_from_ancestors = VALUE string_table( ( `INV_HEADER` ) )
                    io_line_type    = lo_line_descr
                    it_attr_map     = VALUE zcl_ext_sxml_utilities=>tt_attr_map(
                                                ( xml_name = 'INVOICE_NO'     comp_name = 'INVOICE_NO' )
                                                ( xml_name = 'INVOICE_TYPE' comp_name = 'INVOICE_TYPE' )
                                                ( xml_name = 'INVOICE_DATE'     comp_name = 'INVOICE_DATE' ) )
          IMPORTING er_result_tab   = lr_tab ).
      CATCH cx_static_check.
        " handle exception
    ENDTRY.

    IF lr_tab IS BOUND.
      ASSIGN lr_tab->* TO <lt_any>.
      " further processing
      io_out->write( <lt_any> ).
    ENDIF.
  ENDMETHOD.

  METHOD _get_example_xml_1.
    rv_xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
             |<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" | &&
             |xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">| &&
             |  <gesmes:subject>Reference rates</gesmes:subject>| &&
             |  <gesmes:Sender>| &&
             |    <gesmes:name>European Central Bank</gesmes:name>| &&
             |  </gesmes:Sender>| &&
             |  <Cube>| &&
             |    <Cube time="2025-08-29">| &&
             |      <Cube currency="USD" rate="1.1658"/>| &&
             |      <Cube currency="JPY" rate="171.72"/>| &&
             |      <Cube currency="BGN" rate="1.9558"/>| &&
             |      <Cube currency="CZK" rate="24.458"/>| &&
             |      <Cube currency="DKK" rate="7.4642"/>| &&
             |      <Cube currency="GBP" rate="0.8668"/>| &&
             |      <Cube currency="HUF" rate="396.9"/>| &&
             |      <Cube currency="PLN" rate="4.2665"/>| &&
             |      <Cube currency="RON" rate="5.0728"/>| &&
             |      <Cube currency="SEK" rate="11.055"/>| &&
             |      <Cube currency="CHF" rate="0.9364"/>| &&
             |      <Cube currency="ISK" rate="143"/>| &&
             |      <Cube currency="NOK" rate="11.7465"/>| &&
             |      <Cube currency="TRY" rate="47.9536"/>| &&
             |      <Cube currency="AUD" rate="1.7865"/>| &&
             |      <Cube currency="BRL" rate="6.3253"/>| &&
             |      <Cube currency="CAD" rate="1.6031"/>| &&
             |      <Cube currency="CNY" rate="8.3155"/>| &&
             |      <Cube currency="HKD" rate="9.0877"/>| &&
             |      <Cube currency="IDR" rate="19207.37"/>| &&
             |      <Cube currency="ILS" rate="3.8953"/>| &&
             |      <Cube currency="INR" rate="102.8035"/>| &&
             |      <Cube currency="KRW" rate="1622.26"/>| &&
             |      <Cube currency="MXN" rate="21.7935"/>| &&
             |      <Cube currency="MYR" rate="4.9255"/>| &&
             |      <Cube currency="NZD" rate="1.9811"/>| &&
             |      <Cube currency="PHP" rate="66.687"/>| &&
             |      <Cube currency="SGD" rate="1.4987"/>| &&
             |      <Cube currency="THB" rate="37.76"/>| &&
             |      <Cube currency="ZAR" rate="20.6758"/>| &&
             |    </Cube>| &&
             |    <Cube time="2025-08-28">| &&
             |      <Cube currency="USD" rate="1.1658"/>| &&
             |      <Cube currency="JPY" rate="171.72"/>| &&
             |      <Cube currency="BGN" rate="1.9558"/>| &&
             |      <Cube currency="CZK" rate="24.458"/>| &&
             |      <Cube currency="DKK" rate="7.4642"/>| &&
             |      <Cube currency="GBP" rate="0.8668"/>| &&
             |      <Cube currency="HUF" rate="396.9"/>| &&
             |      <Cube currency="PLN" rate="4.2665"/>| &&
             |      <Cube currency="RON" rate="5.0728"/>| &&
             |      <Cube currency="SEK" rate="11.055"/>| &&
             |      <Cube currency="CHF" rate="0.9364"/>| &&
             |      <Cube currency="ISK" rate="143"/>| &&
             |      <Cube currency="NOK" rate="11.7465"/>| &&
             |      <Cube currency="TRY" rate="47.9536"/>| &&
             |      <Cube currency="AUD" rate="1.7865"/>| &&
             |      <Cube currency="BRL" rate="6.3253"/>| &&
             |      <Cube currency="CAD" rate="1.6031"/>| &&
             |      <Cube currency="CNY" rate="8.3155"/>| &&
             |      <Cube currency="HKD" rate="9.0877"/>| &&
             |      <Cube currency="IDR" rate="19207.37"/>| &&
             |      <Cube currency="ILS" rate="3.8953"/>| &&
             |      <Cube currency="INR" rate="102.8035"/>| &&
             |      <Cube currency="KRW" rate="1622.26"/>| &&
             |      <Cube currency="MXN" rate="21.7935"/>| &&
             |      <Cube currency="MYR" rate="4.9255"/>| &&
             |      <Cube currency="NZD" rate="1.9811"/>| &&
             |      <Cube currency="PHP" rate="66.687"/>| &&
             |      <Cube currency="SGD" rate="1.4987"/>| &&
             |      <Cube currency="THB" rate="37.76"/>| &&
             |      <Cube currency="ZAR" rate="20.6758"/>| &&
             |    </Cube>| &&
             |  </Cube>| &&
             |</gesmes:Envelope>|.
  ENDMETHOD.

  METHOD _get_example_xml_2.
    rv_xml = |<?xml version="1.0" encoding="UTF-8"?>| &&
             |<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">| &&
             |  <asx:values>| &&
             |    <VALUES>| &&
             |      <item>| &&
             |        <NAME>Horst</NAME>| &&
             |        <TITLE>Herr</TITLE>| &&
             |        <AGE>30</AGE>| &&
             |      </item>| &&
             |      <item>| &&
             |        <NAME>Jutta</NAME>| &&
             |        <TITLE>Frau</TITLE>| &&
             |        <AGE>35</AGE>| &&
             |      </item>| &&
             |      <item>| &&
             |        <NAME>Ingo</NAME>| &&
             |        <TITLE>Herr</TITLE>| &&
             |        <AGE>31</AGE>| &&
             |      </item>| &&
             |    </VALUES>| &&
             |  </asx:values>| &&
             |</asx:abap>|.
  ENDMETHOD.

  METHOD _get_example_xml_3.
    rv_xml =
          |<?xml version="1.0" encoding="UTF-8"?>| &&
          |<INVOICE>| &&
          |<ZTEST_INV_CREATE>| &&
          |<INV_HEADER>| &&
          |<INVOICE_NO>0001</INVOICE_NO>| &&
          |<INVOICE_TYPE>F1</INVOICE_TYPE>| &&
          |<INVOICE_DATE>01.07.2020</INVOICE_DATE>| &&
          |</INV_HEADER>| &&
          |<INV_ITEM>| &&
          |<ZTEST_INV_ITEM>| &&
          |<ITEM_NO>0001</ITEM_NO>| &&
          |<MATERIAL>A001</MATERIAL>| &&
          |<DESCRIPTION>Shirt</DESCRIPTION>| &&
          |<PRICE>200</PRICE>| &&
          |<CURRENCY>THB</CURRENCY>| &&
          |</ZTEST_INV_ITEM>| &&
          |</INV_ITEM>| &&
          |</ZTEST_INV_CREATE>| &&
          |<ZTEST_INV_CREATE>| &&
          |<INV_HEADER>| &&
          |<INVOICE_NO>0002</INVOICE_NO>| &&
          |<INVOICE_TYPE>F1</INVOICE_TYPE>| &&
          |<INVOICE_DATE>02.07.2020</INVOICE_DATE>| &&
          |</INV_HEADER>| &&
          |<INV_ITEM>| &&
          |<ZTEST_INV_ITEM>| &&
          |<ITEM_NO>0001</ITEM_NO>| &&
          |<MATERIAL>A002</MATERIAL>| &&
          |<DESCRIPTION>Shoes</DESCRIPTION>| &&
          |<PRICE>900</PRICE>| &&
          |<CURRENCY>THB</CURRENCY>| &&
          |</ZTEST_INV_ITEM>| &&
          |<ZTEST_INV_ITEM>| &&
          |<ITEM_NO>0002</ITEM_NO>| &&
          |<MATERIAL>A003</MATERIAL>| &&
          |<DESCRIPTION>Cap</DESCRIPTION>| &&
          |<PRICE>500</PRICE>| &&
          |<CURRENCY>THB</CURRENCY>| &&
          |</ZTEST_INV_ITEM>| &&
          |</INV_ITEM>| &&
          |</ZTEST_INV_CREATE>| &&
          |</INVOICE>|.
  ENDMETHOD.
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_main_local IMPLEMENTATION.
  METHOD sample_tmpl_store_client.
**    TYPES:
**      BEGIN OF lty_printheaderform,
**        header1 TYPE c LENGTH 10,
**        header2 TYPE c LENGTH 10,
**      END OF lty_printheaderform.
**
**    TYPES:
**      BEGIN OF lty_printitemform,
**        item1 TYPE c LENGTH 50,
**        item2 TYPE c LENGTH 50,
**        item3 TYPE c LENGTH 50,
**      END OF lty_printitemform.
**
**    TYPES ltty_printitemform TYPE TABLE OF lty_printitemform WITH EMPTY KEY.
**
**    TYPES:
**      BEGIN OF lty_printfooterform,
**        footer1 TYPE c LENGTH 20,
**        footer2 TYPE c LENGTH 20,
**      END OF lty_printfooterform.
**
**    TYPES:
**      BEGIN OF lty_printgiandgrslipform,
**        header TYPE lty_printheaderform,
**        items  TYPE ltty_printitemform,
**        footer TYPE lty_printfooterform,
**      END OF lty_printgiandgrslipform.
**
**    DATA(ls_testprint)  = VALUE lty_printgiandgrslipform( ).
**    ls_testprint-header = VALUE #( header1 = 'Header 1'
**                                   header2 = 'Header 2' ).
**    ls_testprint-items  = VALUE #( ( item1 = 'Item A1'
**                                     item2 = 'Item A2'
**                                     item3 = 'Item A3' )
**                                   ( item1 = 'Item B1'
**                                     item2 = 'Item B2'
**                                     item3 = 'Item B3' ) ).
**    ls_testprint-footer = VALUE #( footer1 = 'Footer 1'
**                                   footer2 = 'Footer 2' ).
**
**    NEW zcl_s4cloud_pdf_utilities( )->build_xml_pdf_with_encode_x64( EXPORTING iv_root_form_node  = 'TESTFORM'
**                                                                               iv_child_form_node = 'form'
**                                                                     IMPORTING ev_xmlpdf          = DATA(lv_xmlpdf)
**                                                                               ev_encodex64       = DATA(lv_encodex64)
**                                                                     CHANGING  cs_data            = ls_testprint ).
**
**    io_out->write( 'XML Data:' ).
**
**    IF lv_xmlpdf IS NOT INITIAL.
**      io_out->write( 'XML Data:' ).
**      io_out->write( lv_xmlpdf ).
**    ENDIF.
**
**    IF lv_encodex64 IS NOT INITIAL.
**      io_out->write( 'Encode X64 Data:' ).
**      io_out->write( lv_encodex64 ).
**    ENDIF.
**
****    TRY.
****        DATA(lo_client) = NEW zcl_fp_tmpl_store_client( iv_destination  = '' ).
****
****        DATA(lv_rendered_pdf) = lo_client->render_pdf( iv_template_name = 'ZMME107/GI_AND_GR_SLIP'
****                                                       iv_xml           = lv_encodex64 ).
****      CATCH cx_root INTO DATA(lx_root).
****    ENDTRY.
  ENDMETHOD.
ENDCLASS.

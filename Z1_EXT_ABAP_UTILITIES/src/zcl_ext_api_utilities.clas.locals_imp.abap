*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_sample_post IMPLEMENTATION.
  METHOD sample_post_material_document.
**********************************************************************
**    TYPES:
**      BEGIN OF lty_MaterialDocumentItem_ODATA,
**        Material                 TYPE string,
**        Plant                    TYPE string,
**        StorageLocation          TYPE string,
**        GoodsMovementType        TYPE string,
**        InventoryValuationType   TYPE string,
**        EntryUnit                TYPE string,
**        QuantityInEntryUnit      TYPE string,
**        MaterialDocumentItemText TYPE string,
**        Batch                    TYPE string,
**      END OF lty_MaterialDocumentItem_ODATA.
**    TYPES ltt_MaterialDocumentItem_ODATA TYPE TABLE OF lty_MaterialDocumentItem_ODATA WITH EMPTY KEY.
**
**    TYPES:
**      BEGIN OF lty_MaterialDocumentHead_ODATA,
**        DocumentDate               TYPE string,
**        PostingDate                TYPE string,
**        MaterialDocumentHeaderText TYPE string,
**        GoodsMovementCode          TYPE string,
**        to_MaterialDocumentItem    TYPE ltt_MaterialDocumentItem_ODATA,
**      END OF lty_MaterialDocumentHead_ODATA.
**
**    DATA lw_MaterialDocumentODATA TYPE lty_MaterialDocumentHead_ODATA.
**
**    DATA lt_url                   TYPE zcl_s4cloud_api_utilities=>tt_url.
**    DATA lt_name_mappings         TYPE /ui2/cl_json=>name_mappings.
**
**    DATA lv_url_get               TYPE string.
**    DATA lv_username              TYPE string.
**    DATA lv_password              TYPE string.
**
**    DATA lr_return                TYPE REF TO data.
**
**    lw_MaterialDocumentODATA-documentdate               = zcl_s4cloud_api_utilities=>convert_abap_timestamp_to_java( ).
**    lw_MaterialDocumentODATA-postingdate                = zcl_s4cloud_api_utilities=>convert_abap_timestamp_to_java( ).
**    lw_MaterialDocumentODATA-materialdocumentheadertext = ''.
**    lw_MaterialDocumentODATA-goodsmovementcode          = '05'.
**    lw_MaterialDocumentODATA-to_materialdocumentitem    = VALUE #(
**        ( Material                 = 'Material'
**          Plant                    = 'Plant'
**          StorageLocation          = 'StorageLocation'
**          GoodsMovementType        = 'GoodsMovementType'
**          Batch                    = 'Batch'
**          InventoryValuationType   = 'InventoryValuationType'
**          EntryUnit                = 'EntryUnit'
**          QuantityInEntryUnit      = 'QuantityInEntryUnit'
**          MaterialDocumentItemText = 'MaterialDocumentItemText' ) ).
**
**    IF lw_MaterialDocumentODATA IS INITIAL.
**      RETURN.
**    ENDIF.
**
**    lv_url_get = |{ zcl_s4cloud_api_utilities=>get_system_url( ) }API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader|.
**
**    lv_username = 'Username to login SAP'.  " Set Username
**    lv_password = 'Password to use n SAp'.  " Set password
**
**    lt_name_mappings = VALUE #( ( abap = 'DOCUMENTDATE'
**                                  json = 'DocumentDate' )
**                                ( abap = 'POSTINGDATE'
**                                  json = 'PostingDate' )
**                                ( abap = 'MATERIALDOCUMENTHEADERTEXT'
**                                  json = 'MaterialDocumentHeaderText' )
**                                ( abap = 'GOODSMOVEMENTCODE'
**                                  json = 'GoodsMovementCode' )
**                                ( abap = 'TO_MATERIALDOCUMENTITEM'
**                                  json = 'to_MaterialDocumentItem' )
**                                ( abap = 'MATERIAL'
**                                  json = 'Material' )
**                                ( abap = 'PLANT'
**                                  json = 'Plant' )
**                                ( abap = 'STORAGELOCATION'
**                                  json = 'StorageLocation' )
**                                ( abap = 'GOODSMOVEMENTTYPE'
**                                  json = 'GoodsMovementType' )
**                                ( abap = 'INVENTORYVALUATIONTYPE'
**                                  json = 'InventoryValuationType' )
**                                ( abap = 'BATCH'
**                                  json = 'Batch' )
**                                ( abap = 'ENTRYUNIT'
**                                  json = 'EntryUnit' )
**                                ( abap = 'QUANTITYINENTRYUNIT'
**                                  json = 'QuantityInEntryUnit' )
**                                ( abap = 'MATERIALDOCUMENTITEMTEXT'
**                                  json = 'MaterialDocumentItemText' ) ).
**
**    lt_url = VALUE #( url = lv_url_get
**                      ( method     = if_web_http_client=>post
**                        json_data  = zcl_s4cloud_api_utilities=>convert_data_to_json(
**                                         iv_data          = lw_MaterialDocumentODATA
**                                         iv_pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
**                                         iv_name_mappings = lt_name_mappings )
**                        get_x_csrf = abap_true ) ).
**
**    " Start execute API
**    NEW zcl_s4cloud_api_utilities(
**      )->create_by_destination( iv_destination = `Destination from SM59`
**      )->execute_requests_multiple( EXPORTING it_url          = lt_url
**                                              iv_username     = lv_username
**                                              iv_password     = lv_password
**                                    IMPORTING et_response     = DATA(lt_response) ).
**
**    LOOP AT lt_response INTO DATA(ls_response).
**      IF ls_response-context IS INITIAL.
**        CONTINUE.
**      ENDIF.
**
**      zcl_s4cloud_api_utilities=>convert_json_to_data( EXPORTING iv_json = ls_response-context
**                                                       CHANGING  cv_data = lr_return ).
**      IF lr_return IS NOT BOUND.
**        CONTINUE.
**      ENDIF.
**    ENDLOOP.
**********************************************************************
**********************************************************************
    DATA(lv_string) =
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |  Sample Post Material Document with execute_requests_multiple method  { cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |TYPES:{ cl_abap_char_utilities=>cr_lf }| &&
      |  BEGIN OF lty_MaterialDocumentItem_ODATA,{ cl_abap_char_utilities=>cr_lf }| &&
      |    Material                 TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    Plant                    TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    StorageLocation          TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    GoodsMovementType        TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    InventoryValuationType   TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    EntryUnit                TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    QuantityInEntryUnit      TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    MaterialDocumentItemText TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    Batch                    TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |  END OF lty_MaterialDocumentItem_ODATA.{ cl_abap_char_utilities=>cr_lf }| &&
      |TYPES ltt_MaterialDocumentItem_ODATA TYPE TABLE OF lty_MaterialDocumentItem_ODATA WITH EMPTY KEY.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |TYPES:{ cl_abap_char_utilities=>cr_lf }| &&
      |  BEGIN OF lty_MaterialDocumentHead_ODATA,{ cl_abap_char_utilities=>cr_lf }| &&
      |    DocumentDate               TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    PostingDate                TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    MaterialDocumentHeaderText TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    GoodsMovementCode          TYPE string,{ cl_abap_char_utilities=>cr_lf }| &&
      |    to_MaterialDocumentItem    TYPE ltt_MaterialDocumentItem_ODATA,{ cl_abap_char_utilities=>cr_lf }| &&
      |  END OF lty_MaterialDocumentHead_ODATA.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lw_MaterialDocumentODATA TYPE lty_MaterialDocumentHead_ODATA.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lt_url                   TYPE zcl_s4cloud_api_utilities=>tt_url.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lt_name_mappings         TYPE /ui2/cl_json=>name_mappings.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_url_get               TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_username              TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_password              TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lr_return                TYPE REF TO data.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lw_MaterialDocumentODATA-documentdate               = zcl_s4cloud_api_utilities=>convert_abap_timestamp_to_java( ).{ cl_abap_char_utilities=>cr_lf }| &&
      |lw_MaterialDocumentODATA-postingdate                = zcl_s4cloud_api_utilities=>convert_abap_timestamp_to_java( ).{ cl_abap_char_utilities=>cr_lf }| &&
      |lw_MaterialDocumentODATA-materialdocumentheadertext = ''.{ cl_abap_char_utilities=>cr_lf }| &&
      |lw_MaterialDocumentODATA-goodsmovementcode          = '05'.{ cl_abap_char_utilities=>cr_lf }| &&
      |lw_MaterialDocumentODATA-to_materialdocumentitem    = VALUE #({ cl_abap_char_utilities=>cr_lf }| &&
      |    ( Material                 = 'Material'{ cl_abap_char_utilities=>cr_lf }| &&
      |      Plant                    = 'Plant'{ cl_abap_char_utilities=>cr_lf }| &&
      |      StorageLocation          = 'StorageLocation'{ cl_abap_char_utilities=>cr_lf }| &&
      |      GoodsMovementType        = 'GoodsMovementType'{ cl_abap_char_utilities=>cr_lf }| &&
      |      Batch                    = 'Batch'{ cl_abap_char_utilities=>cr_lf }| &&
      |      InventoryValuationType   = 'InventoryValuationType'{ cl_abap_char_utilities=>cr_lf }| &&
      |      EntryUnit                = 'EntryUnit'{ cl_abap_char_utilities=>cr_lf }| &&
      |      QuantityInEntryUnit      = 'QuantityInEntryUnit'{ cl_abap_char_utilities=>cr_lf }| &&
      |      MaterialDocumentItemText = 'MaterialDocumentItemText' ) ).{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |IF lw_MaterialDocumentODATA IS INITIAL.{ cl_abap_char_utilities=>cr_lf }| &&
      |  RETURN.{ cl_abap_char_utilities=>cr_lf }| &&
      |ENDIF.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_url_get = zcl_s4cloud_api_utilities=>get_system_url( ) && 'API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader'.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_username = 'Username to login SAP'.  " Set Username{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_password = 'Password to use n SAp'.  " Set password{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lt_name_mappings = VALUE #( ( abap = 'DOCUMENTDATE'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'DocumentDate' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'POSTINGDATE'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'PostingDate' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'MATERIALDOCUMENTHEADERTEXT'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'MaterialDocumentHeaderText' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'GOODSMOVEMENTCODE'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'GoodsMovementCode' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'TO_MATERIALDOCUMENTITEM'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'to_MaterialDocumentItem' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'MATERIAL'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'Material' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'PLANT'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'Plant' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'STORAGELOCATION'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'StorageLocation' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'GOODSMOVEMENTTYPE'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'GoodsMovementType' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'INVENTORYVALUATIONTYPE'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'InventoryValuationType' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'BATCH'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'Batch' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'ENTRYUNIT'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'EntryUnit' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'QUANTITYINENTRYUNIT'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'QuantityInEntryUnit' ){ cl_abap_char_utilities=>cr_lf }| &&
      |                            ( abap = 'MATERIALDOCUMENTITEMTEXT'{ cl_abap_char_utilities=>cr_lf }| &&
      |                              json = 'MaterialDocumentItemText' ) ).{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lt_url = VALUE #( url = lv_url_get{ cl_abap_char_utilities=>cr_lf }| &&
      |                  ( method     = if_web_http_client=>post{ cl_abap_char_utilities=>cr_lf }| &&
      |                    json_data  = zcl_s4cloud_api_utilities=>convert_data_to_json({ cl_abap_char_utilities=>cr_lf }| &&
      |                                         iv_data          = lw_MaterialDocumentODATA{ cl_abap_char_utilities=>cr_lf }| &&
      |                                         iv_pretty_name   = /ui2/cl_json=>pretty_mode-camel_case{ cl_abap_char_utilities=>cr_lf }| &&
      |                                         iv_name_mappings = lt_name_mappings ){ cl_abap_char_utilities=>cr_lf }| &&
      |                    get_x_csrf = abap_true ) ).{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |" Start execute API{ cl_abap_char_utilities=>cr_lf }| &&
      |NEW zcl_s4cloud_api_utilities({ cl_abap_char_utilities=>cr_lf }| &&
      |     )->create_by_destination( iv_destination = `Destination from SM59`{ cl_abap_char_utilities=>cr_lf }| &&
      |     )->execute_requests_multiple( EXPORTING it_url          = lt_url{ cl_abap_char_utilities=>cr_lf }| &&
      |                                             iv_username     = lv_username{ cl_abap_char_utilities=>cr_lf }| &&
      |                                             iv_password     = lv_password{ cl_abap_char_utilities=>cr_lf }| &&
      |                                   IMPORTING et_response     = DATA(lt_response) ).{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |LOOP AT lt_response INTO DATA(ls_response).{ cl_abap_char_utilities=>cr_lf }| &&
      |  IF ls_response-context IS INITIAL.{ cl_abap_char_utilities=>cr_lf }| &&
      |    CONTINUE.{ cl_abap_char_utilities=>cr_lf }| &&
      |  ENDIF.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |  zcl_s4cloud_api_utilities=>convert_json_to_data( EXPORTING iv_json = ls_response-context{ cl_abap_char_utilities=>cr_lf }| &&
      |                                                   CHANGING  cv_data = lr_return ).{ cl_abap_char_utilities=>cr_lf }| &&
      |  IF lr_return IS NOT BOUND.{ cl_abap_char_utilities=>cr_lf }| &&
      |    CONTINUE.{ cl_abap_char_utilities=>cr_lf }| &&
      |  ENDIF.{ cl_abap_char_utilities=>cr_lf }| &&
      |ENDLOOP.{ cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }|.

      io_out->write( lv_string ).
  ENDMETHOD.

  METHOD sample_pickalldelivery.
**********************************************************************
**    DATA lv_url_get  TYPE string.
**    " TODO: variable is assigned but never used (ABAP cleaner)
**    DATA lv_url_post TYPE string.
**    DATA lv_username TYPE string.
**    DATA lv_password TYPE string.
**
**    lv_url_get
**    = |{ zcl_s4cloud_api_utilities=>get_system_url( iv_f_api = 'X' ) }|
**    && |API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader(DeliveryDocument='{ `DELIVERY_ORDER` }')|.
**
**    lv_url_post
**    = |{ zcl_s4cloud_api_utilities=>get_system_url( iv_f_api = 'X' ) }|
**    && |API_OUTBOUND_DELIVERY_SRV;v=0002/PickAllItems?DeliveryDocument='{ `DELIVERY_ORDER` }'|.
**
**    lv_username = 'Username to login SAP'.  " Set Username
**    lv_password = 'Password to use n SAp'.  " Set password
**
**    " Get Token & ETag
**    NEW zcl_s4cloud_api_utilities(
**    )->create_by_url( iv_url = lv_url_get
**    )->execute_request_single( iv_method   = if_web_http_client=>get
**                               iv_username = lv_username
**                               iv_password = lv_password
**    )->get_response_info( IMPORTING eo_response    =
***                                    ev_response_msg =
**                                    er_json_data   = DATA(lo_json_get)
***                                    ev_last_error  =
**                                    es_http_status = DATA(lw_http_status_get)
***                                    et_res_header  =
**    ).
**
**    NEW zcl_s4cloud_api_utilities(
**    )->create_by_destination( iv_destination = `Destination from SM59`
**    )->execute_request_single( iv_method           = if_web_http_client=>post
**                               iv_username         = lv_username
**                               iv_password         = lv_password
**                               iv_force_get_x_csrf = abap_true
**    )->get_response_info( IMPORTING ev_response_msg = DATA(lv_msg)
**                                    er_json_data    = DATA(lo_json_post)
**                                    es_http_status  = DATA(lw_http_status_post)
**    )->destroy( ).
**********************************************************************
**********************************************************************

    DATA(lv_string) =
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |     Sample Pick All Delivery with execute_request_single method      { cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_url_get  TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_url_post TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_username TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |DATA lv_password TYPE string.{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_url_get{ cl_abap_char_utilities=>cr_lf }| &&
      |= \{ zcl_s4cloud_api_utilities=>get_system_url( iv_f_api = 'X' ) \}| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |&& \|API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader(DeliveryDocument='\{ `DELIVERY_ORDER` \}').| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_url_post{ cl_abap_char_utilities=>cr_lf }| &&
      |= \|\{ zcl_s4cloud_api_utilities=>get_system_url( iv_f_api = 'X' ) \}| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |&& \|\|API_OUTBOUND_DELIVERY_SRV;v=0002/PickAllItems?DeliveryDocument='\{ `DELIVERY_ORDER` \}'.| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_username = 'Username to login SAP'.  " Set Username{ cl_abap_char_utilities=>cr_lf }| &&
      |lv_password = 'Password to use n SAp'.  " Set password{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |" Get Token & ETag{ cl_abap_char_utilities=>cr_lf }| &&
      |NEW zcl_s4cloud_api_utilities({ cl_abap_char_utilities=>cr_lf }| &&
      |)->create_by_url( iv_url = lv_url_get{ cl_abap_char_utilities=>cr_lf }| &&
      |)->execute_request_single( iv_method   = if_web_http_client=>get{ cl_abap_char_utilities=>cr_lf }| &&
      |                           iv_username = lv_username{ cl_abap_char_utilities=>cr_lf }| &&
      |                           iv_password = lv_password{ cl_abap_char_utilities=>cr_lf }| &&
      |)->get_response_info( IMPORTING{ cl_abap_char_utilities=>cr_lf }| &&
      |*                                    eo_response    ={ cl_abap_char_utilities=>cr_lf }| &&
      |*                                    ev_response_msg ={ cl_abap_char_utilities=>cr_lf }| &&
      |                                     er_json_data   = DATA(lo_json_get){ cl_abap_char_utilities=>cr_lf }| &&
      |*                                    ev_last_error  ={ cl_abap_char_utilities=>cr_lf }| &&
      |                                     es_http_status = DATA(lw_http_status_get){ cl_abap_char_utilities=>cr_lf }| &&
      |*                                    et_res_header  ={ cl_abap_char_utilities=>cr_lf }| &&
      |).{ cl_abap_char_utilities=>cr_lf }| &&
      |{ cl_abap_char_utilities=>cr_lf }| &&
      |NEW zcl_s4cloud_api_utilities({ cl_abap_char_utilities=>cr_lf }| &&
      |)->create_by_destination( iv_destination = `Destination from SM59`{ cl_abap_char_utilities=>cr_lf }| &&
      |)->execute_request_single( iv_method           = if_web_http_client=>post{ cl_abap_char_utilities=>cr_lf }| &&
      |                           iv_username         = lv_username{ cl_abap_char_utilities=>cr_lf }| &&
      |                           iv_password         = lv_password{ cl_abap_char_utilities=>cr_lf }| &&
      |                           iv_force_get_x_csrf = abap_true{ cl_abap_char_utilities=>cr_lf }| &&
      |)->get_response_info( IMPORTING ev_response_msg = DATA(lv_msg){ cl_abap_char_utilities=>cr_lf }| &&
      |                                er_json_data    = DATA(lo_json_post){ cl_abap_char_utilities=>cr_lf }| &&
      |                                es_http_status  = DATA(lw_http_status_post){ cl_abap_char_utilities=>cr_lf }| &&
      |)->destroy( ).{ cl_abap_char_utilities=>cr_lf }| &&
      |**********************************************************************{ cl_abap_char_utilities=>cr_lf }|.

      io_out->write( lv_string ).
  ENDMETHOD.
ENDCLASS.

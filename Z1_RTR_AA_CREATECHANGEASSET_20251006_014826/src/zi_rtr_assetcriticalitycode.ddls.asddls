@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTS-IMS009: Overall Picking Status VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY ]
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_RTR_AssetCriticalityCode
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE( p_domain_name : 'ZD_RTR_AA_CRITICALITYCODE' ) as Values
  association [0..*] to ZI_RTR_AssetCriticalityCodeTxt as _AssetCriticalityCodeTxt on $projection.AssetCriticalityCode = _AssetCriticalityCodeTxt.AssetCriticalityCode
{
      @ObjectModel.text.association: '_AssetCriticalityCodeTxt'
  key cast( Values.value_low as abap.int1 ) as AssetCriticalityCode,

      _AssetCriticalityCodeTxt
}

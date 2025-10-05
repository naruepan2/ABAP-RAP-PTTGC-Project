@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTS-IMS009: Overall Picking Status VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_RTR_AssetCriticalityCodeTxt
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZD_RTR_AA_CRITICALITYCODE' ) as Texts
{
  key cast( Texts.value_low as abap.int1 ) as AssetCriticalityCode,
      @Semantics.language: true
  key Texts.language                       as language,
      @Semantics.text: true
      Texts.text                           as CriticalityCodeDescription
}

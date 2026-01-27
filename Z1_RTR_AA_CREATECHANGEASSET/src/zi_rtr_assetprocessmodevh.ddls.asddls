@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interface Asset Process Mode'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP ]
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_RTR_ASSETProcessModeVH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZD_RTR_AA_PROCESSMODE' )

{
  key cast( text as abap.char(13) ) as ProcessMode
}
where
  language = 'E'

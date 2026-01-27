@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interface Asset Process Mode'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP ]
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_RTR_ASSETMESSAGESTATUSVH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZD_RTR_AA_MESSAGESTATUS' )

{
  key cast( text as abap.char(15) ) as MessageStatus
}
where
  language = 'E'

@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interface Asset Process Mode'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER, #COLLECTIVE_VALUE_HELP ]
@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_RTR_ASSETMESSAGETYPEVH
  as select distinct from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZD_RTR_AA_MESSAGETYPE' )

{     
      @ObjectModel.text.element: [ 'MessageTypeDescription' ]
      @UI.textArrangement: #TEXT_ONLY
  key value_low                    as MessageValue,
      @UI.hidden: true
      cast( text as abap.char(11) ) as MessageTypeDescription
}
where
  language = 'E'

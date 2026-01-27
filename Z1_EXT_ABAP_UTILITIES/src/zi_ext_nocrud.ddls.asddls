@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'ABAP Extensibilies: CDS for No CRUD'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_EXT_NoCRUD
  as select from I_Language
{
  key Language,

      @EndUserText.label: 'SAP Client'
      $session.client                                                    as SAPClient,

      @EndUserText.label: 'SAP User'
      $session.user                                                      as SAPUser,

      @EndUserText.label: 'Current TimeStamp'
      cast( tstmp_current_utctimestamp( ) as timestamp preserving type ) as CurrentTimeStamp
}
where
  Language = $session.system_language

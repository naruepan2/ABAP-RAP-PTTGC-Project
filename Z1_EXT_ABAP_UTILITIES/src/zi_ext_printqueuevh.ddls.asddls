@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print Queue Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MASTER
}
@Search.searchable: true
@ObjectModel.dataCategory:#VALUE_HELP
@ObjectModel.representativeKey: 'PrintQueue'
define view entity ZI_EXT_PrintQueueVH
  as select from ZI_PrintQueue
{
      @Search: {
           defaultSearchElement: true,
           ranking: #HIGH,
           fuzzinessThreshold: 0.8
          }
  key PrintQueue,

      @Search: {
           defaultSearchElement: true,
           ranking: #HIGH,
           fuzzinessThreshold: 0.8
          }
      PrintQueueDescription,

      PrintQueueOutputFormatName,

      cast ( case
        when substring(PrintQueue, instr(PrintQueue , 'COMP') , 4 ) = 'COMP'
        then substring(PrintQueue, instr(PrintQueue , 'COMP') + 4 , 4 )
        else '10' // Dummy
        end as bukrs )   as Company,

      cast ( case
        when substring(PrintQueue, instr(PrintQueue , 'PLANT') , 5 ) = 'PLANT'
        then substring(PrintQueue, instr(PrintQueue , 'PLANT') + 5 , 4 )
        else '1011' // Dummy
        end as werks_d ) as Plant

}

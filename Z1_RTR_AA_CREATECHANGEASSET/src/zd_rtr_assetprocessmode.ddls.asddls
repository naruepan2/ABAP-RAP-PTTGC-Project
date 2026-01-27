@EndUserText.label: 'Abstract Asset Action Type'
define root abstract entity ZD_RTR_ASSETPROCESSMODE
{
  @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_RTR_ASSETProcessModeVH', element: 'ProcessMode' } } ]
  @EndUserText.label: 'Process Mode'
  @EndUserText.quickInfo: 'Process Mode'
  @UI.defaultValue: 'Simulate'
  @UI.fieldGroup  : [ { position: 10, qualifier: 'ProcessModeGroup' } ]
  ProcessMode     : abap.char(13);

  @EndUserText.label: 'From Line No.'
  @EndUserText.quickInfo: 'From Line No.'
  AssetFromLineNo : abap.int4;

  @EndUserText.label: 'To Line No.'
  @EndUserText.quickInfo: 'To Line No.'
  AssetToLineNo   : abap.int4;
}

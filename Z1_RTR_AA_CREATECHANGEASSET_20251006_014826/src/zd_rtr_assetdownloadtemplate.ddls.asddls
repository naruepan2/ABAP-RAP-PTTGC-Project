@EndUserText.label: 'Abstract Asset From External Source'
define root abstract entity ZD_RTR_ASSETDOWNLOADTEMPLATE
{
  @EndUserText.label        : 'File Name of Asset Template'
  AssetFileName             : abap.string(0);

  @EndUserText.label        : 'Create and change Asset Template (X64)'
  AssetFileContent : abap.string(0);
  
  @EndUserText.label        : 'Mime Type'
  AssetMimeType             : abap.char(128);
}

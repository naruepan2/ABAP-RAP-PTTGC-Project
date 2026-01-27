@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'RTR_AA020 Create and Change Asset Msg.'

@Metadata.allowExtensions: true

@ObjectModel.representativeKey: 'AssetUUID'
@ObjectModel.usageType: { dataClass: #MIXED, serviceQuality: #X, sizeCategory: #XXL }

define view entity ZC_RTR_CreateChangeAssetMsgTP
  as projection on ZR_RTR_CreateChangeAssetMsgTP

  redefine association _CreateChangeAssetParent redirected to parent ZC_RTR_CreateChangeAssetTP

{
  key ReturnMsgUUID,
  key AssetUUID,
      
      @ObjectModel.text.element: [ 'ReturnTypeDescription' ]
      ReturnType,
      ReturnTypeDescription,
      @EndUserText:{ label: 'Message Status', quickInfo: 'Message Status' }
      RunType,
      ReturnMessage,
      ReturnCriticalityCode,
      LocalLastChangedAt,

      /* Associations */
      _AssetCriticalityCode,
      _CreateChangeAssetParent
}

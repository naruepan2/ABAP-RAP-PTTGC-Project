@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'RTR_AA020 Create and Change Asset Msg.'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #XXL, dataClass: #MIXED }

define view entity ZR_RTR_CreateChangeAssetMsgTP
  as select from ztrtr_0102_02_a as CreateChangeAssetMsg
  association        to parent ZR_RTR_CreateChangeAssetTP as _CreateChangeAssetParent on $projection.AssetUUID = _CreateChangeAssetParent.AssetUUID
  association [0..1] to ZI_RTR_AssetCriticalityCode       as _AssetCriticalityCode    on $projection.ReturnCriticalityCode = _AssetCriticalityCode.AssetCriticalityCode
{
  key return_msg_uuid       as ReturnMsgUUID,
  key asset_uuid            as AssetUUID,

      return_type           as ReturnType,

      case return_type
        when 'S'
            then 'Success'
        when 'W'
            then 'Warning'
        when 'E'
            then 'Error'
        when 'A'
            then 'Error'
        else ''
      end                   as ReturnTypeDescription,

      run_type              as RunType,
      return_message        as ReturnMessage,

      @ObjectModel.foreignKey.association: '_AssetCriticalityCode'
      case return_type
        when 'S'
            then 3 // Green
        when 'W'
            then 2 // Yellow
        when 'E'
            then 1 // Red
        when 'A'
            then 1 // Red
        else 0     // Neutral
      end                   as ReturnCriticalityCode,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _CreateChangeAssetParent,
      _AssetCriticalityCode
}
where
     created_by      = $session.user
  or last_changed_by = $session.user

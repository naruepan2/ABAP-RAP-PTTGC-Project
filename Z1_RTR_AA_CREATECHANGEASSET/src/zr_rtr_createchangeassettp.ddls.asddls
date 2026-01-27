@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Intf.View Create and Change Asset Master'

@ObjectModel.usageType: { dataClass: #MIXED, serviceQuality: #X, sizeCategory: #XXL }

define root view entity ZR_RTR_CreateChangeAssetTP
  as select from ztrtr_0102_01_a as CreateChangeAsset

  composition [0..*] of ZR_RTR_CreateChangeAssetMsgTP as _CreateChangeAssetMsg

  association [1..1] to I_CompanyCode                 as _CompanyCode           on  $projection.CompanyCode = _CompanyCode.CompanyCode

  association [0..1] to I_UnitOfMeasure               as _UnitOfMeasure         on  $projection.Baseunit = _UnitOfMeasure.UnitOfMeasure

  association [0..1] to I_Plant                       as _Plant                 on  $projection.Plant = _Plant.Plant

  association [0..*] to I_CostCenter                  as _CostCenter            on  $projection.CostCenter = _CostCenter.CostCenter

  association [0..*] to I_CostCenter                  as _ResponsibleCostCenter on  $projection.CostCenter            = _ResponsibleCostCenter.CostCenter
                                                                                and $projection.ResponsibleCostCenter = _ResponsibleCostCenter.CostCenter

  association [0..*] to I_ProfitCenter                as _ProfitCenter          on  $projection.ProfitCenter = _ProfitCenter.ProfitCenter

  association [0..1] to I_WBSElementData_2            as _WBSElementData        on  $projection.InvestmentProjectWbsElement = _WBSElementData.WBSElementInternalID

  association [0..1] to I_Supplier                    as _Supplier              on  $projection.Supplier = _Supplier.Supplier

  association [0..1] to I_Currency                    as _Currency              on  $projection.CurrencyCode = _Currency.Currency

  association [0..1] to ZI_RTR_AssetCriticalityCode   as _AssetCriticalityCode  on  $projection.ReturnCriticalityCode = _AssetCriticalityCode.AssetCriticalityCode

{
  key asset_uuid                     as AssetUUID,

      process_mode                   as ProcessMode,
      asset_line_no                  as AssetLineNo,

      master_fixed_asset             as MasterFixedAsset,
      fixed_asset                    as FixedAsset,
      asset_class                    as AssetClass,

      @ObjectModel.foreignKey.association: '_CompanyCode'
      company_code                   as CompanyCode,

      fixed_asset_description        as FixedAssetDescription,
      asset_additional_description   as AssetAdditionalDescription,
      master_fixed_asset_description as MasterFixedAssetDescription,
      asset_serial_number            as AssetSerialNumber,
      inventory                      as Inventory,

      quantity                       as Quantity,

      @ObjectModel.foreignKey.association: '_UnitOfMeasure'
      baseunit                       as Baseunit,

      last_inventory_date            as LastInventoryDate,
      inventory_note                 as InventoryNote,
      validity_start_date            as ValidityStartDate,

      @ObjectModel.foreignKey.association: '_CostCenter'
      cost_center                    as CostCenter,

      @ObjectModel.foreignKey.association: '_ResponsibleCostCenter'
      responsible_cost_center        as ResponsibleCostCenter,

      @ObjectModel.foreignKey.association: '_Plant'
      plant                          as Plant,

      asset_location                 as AssetLocation,
      room                           as Room,
      vehicle_license_plate_number   as VehicleLicensePlateNumber,
      personnel_number               as PersonnelNumber,

      @ObjectModel.foreignKey.association: '_ProfitCenter'
      profit_center                  as ProfitCenter,

      segment                        as Segment,
      group1_asset_evaluation_key    as Group1AssetEvaluationKey,
      group2_asset_evaluation_key    as Group2AssetEvaluationKey,
      group3_asset_evaluation_key    as Group3AssetEvaluationKey,
      group4_asset_evaluation_key    as Group4AssetEvaluationKey,
      group5_asset_evaluation_key    as Group5AssetEvaluationKey,
      fixed_asset_group              as FixedAssetGroup,

      @ObjectModel.foreignKey.association: '_Supplier'
      supplier                       as Supplier,

      asset_supplier_name            as AssetSupplierName,
      asset_manufacturer_name        as AssetManufacturerName,
      asset_status_new_purchase      as AssetStatusNewPurchase,
      asset_status_at_purchase       as AssetStatusUsePurchase,
      partner_company                as PartnerCompany,
      asset_country_of_origin        as AssetCountryOfOrigin,
      asset_type_name                as AssetTypeName,
      investment_order               as InvestmentOrder,
      investment_project_wbs_element as InvestmentProjectWbsElement,
      lease_supplier                 as LeaseSupplier,
      lease_agreement                as LeaseAgreement,
      lease_agreement_date           as LeaseAgreementDate,
      lease_term_end_date            as LeaseTermEndDate,
      lease_term_start_date          as LeaseTermStartDate,
      lease_duration_in_fiscal_years as LeaseDurationInFiscalYears,
      lease_duration_in_fiscal_perio as LeaseDurationInFiscalPerio,
      lease_type                     as LeaseType,

      @ObjectModel.foreignKey.association: '_Currency'
      currency_code                  as CurrencyCode,

      base_value_as_new              as BaseValueAsNew,

      purchase_price                 as PurchasePrice,

      leased_asset_note              as LeasedAssetNote,
      no_lease_payments              as NoLeasePayments,
      payment_cycle                  as PaymentCycle,
      advance_payments               as AdvancePayments,

      lease_payment                  as LeasePayment,

      annual_interest_rate           as AnnualInterestRate,
      depreciation_key_anlb01        as DepreciationKeyAnlb01,
      useful_life_in_years_anlb01    as UsefulLifeInYearsAnlb01,
      useful_life_in_periods_anlb01  as UsefulLifeInPeriodsAnlb01,
      depreciation_start_date01      as DepreciationStartDate01,

      scrap_amount_cocd_crcy_anlb01  as ScrapAmountCocdCrcyAnlb01,

      negative_amount_is_allowed01   as NegativeAmountIsAllowed01,
      depreciation_key_anlb15        as DepreciationKeyAnlb15,
      useful_life_in_years_anlb15    as UsefulLifeInYearsAnlb15,
      useful_life_in_periods_anlb15  as UsefulLifeInPeriodsAnlb15,
      depreciation_start_date15      as DepreciationStartDate15,

      scrap_amount_cocd_crcy_anlb15  as ScrapAmountCocdCrcyAnlb15,

      negative_amount_is_allowed15   as NegativeAmountIsAllowed15,

      scrap_amount_cocd_crcy_anlb31  as ScrapAmountCocdCrcyAnlb31,

      scrap_amount_cocd_crcy_anlb35  as ScrapAmountCocdCrcyAnlb35,

      scrap_amount_cocd_crcy_anlb41  as ScrapAmountCocdCrcyAnlb41,

      scrap_amount_cocd_crcy_anlb45  as ScrapAmountCocdCrcyAnlb45,

      return_type                    as ReturnType,

      case return_type
        when 'S'        // Create Success
            then 'Success'
        when 'M'        // Simulate Success
            then 'Success'
        when 'W'
            then 'Warning'
        when 'E'        // Create or Simulate Error
            then 'Error'
        when 'A'        // Upload Error
            then 'Error'
        when 'P'        // Waiting to create or change
            then 'Not Started'
        else ''
      end                            as ReturnTypeDescription,

      run_type                       as RunType,
      return_message                 as ReturnMessage,

      @ObjectModel.foreignKey.association: '_AssetCriticalityCode'
      case return_type
        when 'S'
            then 3 // Green
        when 'M'
            then 3 // Green
        when 'W'
            then 2 // Yellow
        when 'E'
            then 1 // Red
        when 'A'
            then 1 // Red
        else 0     // Neutral
      end                            as ReturnCriticalityCode,

      is_processed                   as IsProcessed,

      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by                as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt,

      _CreateChangeAssetMsg,

      _CompanyCode,
      _UnitOfMeasure,
      _Plant,
      _CostCenter,
      _ProfitCenter,
      _WBSElementData,
      _Supplier,
      _Currency,
      _ResponsibleCostCenter,
      _AssetCriticalityCode
}
where
     created_by      = $session.user
  or last_changed_by = $session.user

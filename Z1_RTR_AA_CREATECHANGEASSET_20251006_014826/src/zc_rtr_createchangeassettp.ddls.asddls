@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Proj.View Create and Change Asset Master'

@Metadata.allowExtensions: true

@ObjectModel.usageType: { dataClass: #MIXED, serviceQuality: #X, sizeCategory: #XXL }

define root view entity ZC_RTR_CreateChangeAssetTP
  provider contract transactional_query
  as projection on ZR_RTR_CreateChangeAssetTP

{
  key AssetUUID,
      @EndUserText:{ label: 'File Type', quickInfo: 'File Type' }
      ProcessMode,
      MasterFixedAsset,
      FixedAsset,
      AssetClass,
      CompanyCode,
      FixedAssetDescription,
      AssetAdditionalDescription,
      MasterFixedAssetDescription,
      AssetSerialNumber,
      Inventory,
      Quantity,
      Baseunit,
      LastInventoryDate,
      InventoryNote,
      ValidityStartDate,
      CostCenter,
      ResponsibleCostCenter,
      Plant,
      AssetLocation,
      Room,
      VehicleLicensePlateNumber,
      PersonnelNumber,
      ProfitCenter,
      Segment,
      Group1AssetEvaluationKey,
      Group2AssetEvaluationKey,
      Group3AssetEvaluationKey,
      Group4AssetEvaluationKey,
      Group5AssetEvaluationKey,
      FixedAssetGroup,
      Supplier,
      AssetSupplierName,
      @EndUserText:{ label: 'Asset Purchase New', quickInfo: 'Asset Purchase New' }
      AssetStatusNewPurchase,
      AssetStatusAtPurchase,
      PartnerCompany,
      AssetCountryOfOrigin,
      AssetTypeName,
      InvestmentOrder,
      InvestmentProjectWbsElement,
      LeaseSupplier,
      LeaseAgreement,
      LeaseAgreementDate,
      LeaseTermEndDate,
      LeaseTermStartDate,
      LeaseDurationInFiscalYears,
      LeaseDurationInFiscalPerio,
      LeaseType,
      CurrencyCode,
      @EndUserText:{ label: 'Base value as new', quickInfo: 'Base value as new' }
      BaseValueAsNew,
      @EndUserText:{ label: 'Purchase Price', quickInfo: 'Purchase Price' }
      PurchasePrice,
      LeasedAssetNote,
      @EndUserText:{ label: 'No. Lease Payments', quickInfo: 'No. Lease Payments' }
      NoLeasePayments,
      @EndUserText:{ label: 'Payment Cycle', quickInfo: 'Payment Cycle' }
      PaymentCycle,
      @EndUserText:{ label: 'Advance Payments', quickInfo: 'Advance Payments' }
      AdvancePayments,
      @EndUserText:{ label: 'Lease Payment', quickInfo: 'Lease Payment' }
      LeasePayment,
      @EndUserText:{ label: 'Annual Interest Rate', quickInfo: 'Annual Interest Rate' }
      AnnualInterestRate,
      @EndUserText:{ label: 'Depreciation Key(01)', quickInfo: 'Depreciation Key(01)' }
      DepreciationKeyAnlb01,
      @EndUserText:{ label: 'Planned Useful Life In Years (01)', quickInfo: 'Planned Useful Life In Years (01)' }
      UsefulLifeInYearsAnlb01,
      @EndUserText:{ label: 'Planned Useful Life in Periods (01)', quickInfo: 'Planned Useful Life in Periods (01)' }
      UsefulLifeInPeriodsAnlb01,
      @EndUserText:{ label: 'Depreciation Calculation Start Date (01)', quickInfo: 'Depreciation Calculation Start Date (01)' }
      DepreciationStartDate01,
      @EndUserText:{ label: 'Scrap value (01)', quickInfo: 'Scrap value (01)' }
      ScrapAmountCocdCrcyAnlb01,
      @EndUserText:{ label: 'Negative Values Allowed (01)', quickInfo: 'Negative Values Allowed (01)' }
      NegativeAmountIsAllowed01,
      @EndUserText:{ label: 'Depreciation Key (15)', quickInfo: 'Depreciation Key (15)' }
      DepreciationKeyAnlb15,
      @EndUserText:{ label: 'Planned Useful Life In Years(15)', quickInfo: 'Planned Useful Life In Years (15)' }
      UsefulLifeInYearsAnlb15,
      @EndUserText:{ label: 'Planned Useful Life in Periods (15)', quickInfo: 'Planned Useful Life in Periods (15)' }
      UsefulLifeInPeriodsAnlb15,
      @EndUserText:{ label: 'Depreciation Calculation Start Date (15)', quickInfo: 'Depreciation Calculation Start Date (15)' }
      DepreciationStartDate15,
      @EndUserText:{ label: 'Scrap value (15)', quickInfo: 'Scrap value (15)' }
      ScrapAmountCocdCrcyAnlb15,
      @EndUserText:{ label: 'Negative Values Allowed (15)', quickInfo: 'Negative Values Allowed (15)' }
      NegativeAmountIsAllowe15,
      @EndUserText:{ label: 'Scrap value (35)', quickInfo: 'Scrap value (31)' }
      ScrapAmountCocdCrcyAnlb31,
      @EndUserText:{ label: 'Scrap value (35)', quickInfo: 'Scrap value (35)' }
      ScrapAmountCocdCrcyAnlb35,
      @EndUserText:{ label: 'Scrap value (41)', quickInfo: 'Scrap value (41)' }
      ScrapAmountCocdCrcyAnlb41,
      @EndUserText:{ label: 'Scrap value (45)', quickInfo: 'Scrap value (45)' }
      ScrapAmountCocdCrcyAnlb45,
      @ObjectModel.text.element: [ 'ReturnTypeDescription' ]
      ReturnType,
      ReturnTypeDescription,
      ReturnMessage,
      ReturnCriticalityCode,
      LocalLastChangedAt,

      /* Associations */
      _CompanyCode,
      _CostCenter,
      _Currency,
      _Plant,
      _ProfitCenter,
      _ResponsibleCostCenter,
      _Supplier,
      _UnitOfMeasure
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'RTR-AP011: Journal Entry'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #XXL, dataClass: #MIXED }

define root view entity ZR_RTR_AP_JournalEntryTP
  as select from I_JournalEntry

{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,

      ReferenceDocumentType,
      OriginalReferenceDocument,
      ReferenceDocumentLogicalSystem,
      BusinessTransactionType,
      AccountingDocumentType,
      TaxReportingDate,
      ExchangeRateDate,
      DocumentDate,
      PostingDate,
      AccountingDocCreatedByUser,
      DocumentReferenceID,
      AccountingDocumentHeaderText,
      Reference1InDocumentHeader,
      Reference2InDocumentHeader,
      AccountingDocumentCreationDate,
      $session.system_date as SystemDate
}

@EndUserText.label: 'Journal Entry Abstract View Parameter'
define root abstract entity ZD_RTR_AP_JournalEntryPostI1
{
  key DummyKey                      : abap.char(1);
      OriginalReferenceDocumentType : awtyp;
      BusinessTransactionType       : glvor;
      AccountingDocumentType        : blart;
      DocumentReferenceID           : xblnr;
      DocumentHeaderText            : bktxt;
      @Semantics.user.createdBy     : true
      CreatedByUser                 : usnam;
      ReversalReason                : stgrd;
      ReversalDate                  : stodt;
      CompanyCode                   : bukrs;
      DocumentDate                  : bldat;
      PostingDate                   : budat;
      ExchangeRateDate              : vdm_v_exchange_rate_date;
      @Semantics.currencyCode       : true
      CurrencyCode                  : waers;
      ExchangeRate                  : ukurs_curr;
      Reference1InDocumentHeader    : xref1_hd;
      Reference2InDocumentHeader    : xref2_hd;

      _Item                         : composition [0..*] of ZD_RTR_AP_JournalEntryGLItems;
      _DebtorItem                   : composition [0..*] of ZD_RTR_AP_JournalEntryARItems;
      _CreditorItem                 : composition [0..*] of ZD_RTR_AP_JournalEntryAPItems;
      _ProductTaxItem               : composition [0..*] of ZD_RTR_AP_JournalEntryTaxItems;
      _WithHoldingTaxItem           : composition [0..*] of ZD_RTR_AP_JournalEntryWHTItems;
}

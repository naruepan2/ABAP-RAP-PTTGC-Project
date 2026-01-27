@EndUserText.label: 'Journal Entry Withholding Tax Items'
define abstract entity ZD_RTR_AP_JournalEntryWHTItems
{
  key DummyKey                    : abap.char(1);
      ReferenceDocumentItem       : docln6;
      WithholdingTaxType          : witht;
      WithholdingTaxCode          : wt_withcd;
      AmountInTransactionCurrency : ze_rtr_ap_journalentry_amount; //(CURTP)= 00
      AmountInCompanyCodeCurrency : ze_rtr_ap_journalentry_amount; //(CURTP)= 10
      TaxBaseAmountInTransCrcy    : ze_rtr_ap_journalentry_amount; //(CURTP)= 00
      TaxBaseAmountInCoCodeCrcy   : ze_rtr_ap_journalentry_amount; //(CURTP)= 10
      _Parent                     : association to parent ZD_RTR_AP_JournalEntryPostI1 on $projection.DummyKey = _Parent.DummyKey;
}

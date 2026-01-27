@EndUserText.label: 'Journal Entry GL Item'
define abstract entity ZD_RTR_AP_JournalEntryAPItems
{
  key DummyKey                      : abap.char(1);
      ReferenceDocumentItem         : docln6;
      Creditor                      : lifnr;
      AmountInTransactionCurrency   : ze_rtr_ap_journalentry_amount; //(CURTP)= 00
      AmountInCompanyCodeCurrency   : ze_rtr_ap_journalentry_amount; //(CURTP)= 10
      AmountInGroupCurrency         : ze_rtr_ap_journalentry_amount; //(CURTP)= 30
      AmountInFreeDefinedCurrency1  : ze_rtr_ap_journalentry_amount; //(CURTP)= 40
      DebitCreditCode               : shkzg;                         // 'S' (Debit -> '+') or 'H' (Credit -> '-')
      AltvRecnclnAccts              : hkont;
      DocumentItemText              : sgtxt;
      AssignmentReference           : acpi_zuonr;
      Reference1IDByBusinessPartner : xref1;
      Reference2IDByBusinessPartner : xref2;
      Reference3IDByBusinessPartner : xref3;
      BranchCode                    : bcode;
      BusinessPlace                 : bupla;
      CreditControlArea             : kkber;
      InvoiceReference              : rebzg;
      InvoiceReferenceFiscalYear    : rebzj;
      DueCalculationBaseDate        : dzfbdt;
      PaymentTerms                  : dzterm;
      PaymentMethod                 : schzw_bseg;
      PaymentMethodSupplement       : uzawe;
      PaymentBlockingReason         : dzlspr;
      AlternativePayee              : kunnr;
      BpBankAccountInternalId       : bvtyp;
      SpecialGLCode                 : umskz;
      TaxCode                       : mwskz;
      PurchasingDocument            : ebeln;
      PurchasingDocumentItem        : ebelp;
      ProfitCenter                  : prctr;
      PayeeIsAlternativePayee       : abap.char(1);
      // When PayeeIsAlternativePayee is marked 'X', _OneTimeCustomerSupplier is filled
      // One-Time Customer
      Name                          : name1_gp;
      Name2                         : name2_gp;
      Name3                         : name3_gp;
      Name4                         : name4_gp;
      @Semantics.address.street     : true
      ShortStreetName               : abap.char(35);
      @Semantics.address.city       : true
      CityName                      : abap.char(35);
      @Semantics.address.postBox    : true
      PostalCode                    : pstlz;
      @Semantics.address.country    : true
      Country                       : land1_gp;
      BankNumber                    : bankl;
      BankAccount                   : bankn;
      TaxNumber3                    : stcd3;
      _Parent                       : association to parent ZD_RTR_AP_JournalEntryPostI1 on $projection.DummyKey = _Parent.DummyKey;
}

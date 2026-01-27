@EndUserText.label: 'Journal Entry Clear Parameter Post Item'
define abstract entity ZD_RTR_JEClearPostItem
{
  key Dummy2                        : abap.char(1);
      Dummy1                        : abap.char(1);

      ReferenceDocumentItem         : docln6;
      PostingKey                    : fis_bschl;    // P - BSEG-BSCHL
      Account                       : racct;        // P - BSEG-HKONT
      SpecialGLCode                 : fac_umskz;
      AmountInTransactionCurrency   : ze_rtr_ap_journalentry_amount;    // P - BSEG-WRBTR
      BranchCode                    : bcode;        // K - BKPF-BRNCH
      BusinessPlace                 : bupla;        // P - BSEG-BUPLA
      DueCalculationBaseDate        : dzfbdt;       // P - BSEG-ZFBDT
      PaymentTerms                  : dzterm;       // P - BSEG-ZTERM
      PaymentMethod                 : schzw_bseg;   // P - BSEG-ZLSCH
      PaymentMethodSupplement       : uzawe;        // P - BSEG-UZAWE
      PaymentBlockingReason         : dzlspr;       // P - BSEG-ZLSPR  ??? 
      BpBankAccountInternalId       : bvtyp;        // P - BSEG-BVTYP   
      DocumentItemText              : sgtxt;        // P - BSEG-SGTXT
      AssignmentReference           : acpi_zuonr;   // P - BSEG-ZUONR
      ValueDate                     : farp_valut;   // P - BSEG-VALUT
      Reference1IdByBusinessPartner : xref1;        // P - BSEG-xref1
      Reference2IdByBusinessPartner : xref2;        // P - BSEG-xref2
      Reference3IdByBusinessPartner : xref3;        // P - BSEG-xref3
      ProfitCenter                  : prctr;        // P - BSEG-PRCTR
      @EndUserText.label: 'Indicator: Individual Payee in Document'
      PayeeIsAlternativePayee       : abap.char(1);         
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

      _Parent                       : association to parent ZD_RTR_JournalEntryClearP on $projection.Dummy1 = _Parent.Dummy1;
}


//BSEG-WRBTR - Amount in local currency

@EndUserText.label: 'Journal Entry GL Item'
define abstract entity ZD_RTR_AP_JournalEntryGLItems
{
  key DummyKey                      : abap.char(1);
      ReferenceDocumentItem         : docln6;
      GLAccount                     : hkont;
      AmountInTransactionCurrency   : ze_rtr_ap_journalentry_amount; //(CURTP)= 00
      AmountInCompanyCodeCurrency   : ze_rtr_ap_journalentry_amount; //(CURTP)= 10
      AmountInGroupCurrency         : ze_rtr_ap_journalentry_amount; //(CURTP)= 30
      AmountInFreeDefinedCurrency1  : ze_rtr_ap_journalentry_amount; //(CURTP)= 40
      DebitCreditCode               : shkzg;                         // 'S' (Debit -> '+') or 'H' (Credit -> '-')
      BusinessPlace                 : bupla;
      DocumentItemText              : sgtxt;
      AssignmentReference           : acpi_zuonr;
      TradingPartner                : rassc;
      ValueDate                     : valut;
      @Semantics                    : { quantity : {unitOfMeasure: 'BaseUnit'} }
      QuantityInEntryUnit           : menge_d;
      BaseUnit                      : meins;
      Plant                         : werks_d;
      Material                      : matnr40;
      Reference1IDByBusinessPartner : xref1;
      Reference2IDByBusinessPartner : xref2;
      Reference3IDByBusinessPartner : xref3;
      // Tax
      TaxCode                       : mwskz;
      //AccountAssignment
      ProfitCenter                  : prctr;
      Segment                       : fb_segment;
      CostCenter                    : kostl;
      OrderID                       : aufnr;
      WBSElement                    : ps_posid_edit;
      ProjectNetwork                : nplnr;
      SalesOrder                    : kdauf;
      SalesOrderItem                : kdpos;
      //ProfitabilitySupplement
      Customer                      : kunnr;
      SoldMaterial                  : artnr;
      SalesOrganization             : vkorg;
      DistributionChannel           : vtweg;
      Division                      : spart;
      _Parent                       : association to parent ZD_RTR_AP_JournalEntryPostI1 on $projection.DummyKey = _Parent.DummyKey;
}

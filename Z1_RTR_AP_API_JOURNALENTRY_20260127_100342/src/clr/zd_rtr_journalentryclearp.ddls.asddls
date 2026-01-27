@EndUserText.label: 'Journal Entry Clear Parameter'
define root abstract entity ZD_RTR_JournalEntryClearP
{
  key Dummy1                     : abap.char(1);
      CompanyCode                : bukrs;                  
      AccountingDocumentType     : blart;                  
      DocumentDate               : bldat;                  
      PostingDate                : budat;                  
      @Semantics.currencyCode       : true
      CurrencyCode               : waers;                  
      CurrencyTranslationDate    : fqm_transaction_date;   
      //      CurrencyTranslationDate    : fac_wwert_d ;
      ExchangeRate               : ukurs_curr;
      DocumentHeaderText         : bktxt;                  
      ReferenceDocument          : xblnr;
//      @Semantics.user.createdBy     : true
//      CreatedByUser              : usnam;
      Reference1InDocumentHeader : xref1_hd;
      Reference2InDocumentHeader : xref2_hd;

      _APARClear                 : composition [0..*] of ZD_RTR_JournalEntryClearAPAR;
      _GLClear                   : composition [0..*] of ZD_RTR_JournalEntryClearGL;
      _Item                      : composition [0..*] of ZD_RTR_JEClearPostItem;

}

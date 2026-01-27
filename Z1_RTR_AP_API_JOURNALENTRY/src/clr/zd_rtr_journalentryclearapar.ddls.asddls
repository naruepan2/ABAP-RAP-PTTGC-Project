@EndUserText.label: 'Journal Entry Clear Parameter AR AP Item'
define abstract entity ZD_RTR_JournalEntryClearAPAR
{
  key Dummy2                : abap.char(1);
      Dummy1                : abap.char(1);
      ReferenceDocumentItem : docln6;
      AccountType           : koart;
      APARAccount           : konko;
      SpecialGLCode         : fac_umskz; // t074u t074t
      //      SpecialGLCode : farp_umsks ;

      _Document             : composition [1..*] of ZD_RTR_JEClearAPARDocument;
      _Parent               : association to parent ZD_RTR_JournalEntryClearP on $projection.Dummy1 = _Parent.Dummy1;
      

}

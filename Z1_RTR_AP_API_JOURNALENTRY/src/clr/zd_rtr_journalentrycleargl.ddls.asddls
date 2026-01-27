@EndUserText.label: 'Journal Entry Clear Parameter - GL Item'
define abstract entity ZD_RTR_JournalEntryClearGL
{
  key Dummy2                : abap.char(1);
      Dummy1                : abap.char(1);
      ReferenceDocumentItem : docln6;
      GLAccount             : saknr;
      
      _Document             : composition [1..*] of ZD_RTR_JEClearGLDocument;
      _Parent               : association to parent ZD_RTR_JournalEntryClearP on $projection.Dummy1 = _Parent.Dummy1;

}

@EndUserText.label: 'Journal Entry Clear - GL Item - Doc.'
define abstract entity ZD_RTR_JEClearGLDocument
{
  key Dummy3             : abap.char(1);
      Dummy2             : abap.char(1);
      AccountingDocument : belnr_d;      
      
      _Parent            : association to parent ZD_RTR_JournalEntryClearGL on $projection.Dummy2 = _Parent.Dummy2;
}

@EndUserText.label: 'Journal Entry Reverse'
define root abstract entity ZD_RTR_AP_JournalEntryReverse
{
  CompanyCode        : bukrs;
  AccountingDocument : belnr_d;
  FiscalYear         : gjahr;
  PostingDate        : budat;
  ReversalReason     : acpi_stgrd;
}

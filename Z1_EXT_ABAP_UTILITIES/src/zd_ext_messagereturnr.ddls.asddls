@EndUserText.label: 'Message Return'
define root abstract entity ZD_EXT_MessageReturnR
{
  key Dummy1 : sysuuid_x16;
      Return : composition [1..*] of ZD_EXT_MessageReturn;

}

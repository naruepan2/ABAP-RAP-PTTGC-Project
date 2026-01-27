@EndUserText.label: 'Get domain fix values'
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.query.implementedBy: 'ABAP:ZCL_EXT_DOMAINFIXVALUE_CE'
define custom entity ZI_EXT_DomainFixValue
{
      @EndUserText.label     : 'domain name'
      @UI.hidden  : true
  key domain_name : sxco_ad_object_name;
      @UI.hidden  : true
  key pos         : abap.numc( 4 );
      @EndUserText.label     : 'lower_limit'
      low         : abap.char( 10 );
      @EndUserText.label     : 'upper_limit'
      high        : abap.char(10);
      @EndUserText.label     : 'Description'
      description : abap.char(60);
}

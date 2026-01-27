@EndUserText.label: 'Message Return'
define abstract entity ZD_EXT_MessageReturn
{
  key Dummy2           : sysuuid_x16;
      Dummy1           : sysuuid_x16;
      Type             : bapi_mtype;
      Id               : symsgid;
      MessageNumber    : symsgno;
      Message          : bapi_msg;
      LogNo            : balognr;
      LogMsgNo         : balmnr;
      MessageV1        : symsgv;
      MessageV2        : symsgv;
      MessageV3        : symsgv;
      MessageV4        : symsgv;
      MessageParameter : bapi_param;
      MessageRow       : bapi_line;
      Field            : bapi_fld;
      MessageSystem    : bapilogsys;
      _Parent          : association to parent ZD_EXT_MessageReturnR on _Parent.Dummy1 = $projection.Dummy1;
}

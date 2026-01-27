@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Calendar Date Functions'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #XL,
    dataClass: #MIXED
}

define view entity ZI_EXT_CALENDARDATEFUNCTBYDATE
  with parameters
    //Enter a valid value; p_date value format is 'YYYYMMDD'
    @Environment.systemField: #SYSTEM_DATE
    p_date     : abap.dats,
    //Enter a valid value; p_language value format is 'E' (English) or '2' (Thailand).
    @Environment.systemField: #SYSTEM_LANGUAGE
    p_language : abap.lang
  as select from ZI_EXT_CALENDARDATEFUNCTIONS ( p_language : $parameters.p_language )
{
  key Today,
      Yesterday,
      Tomorrow,
      isValidDate,
      CalendarDay,
      CalendarWeek,
      CalendarMonth,
      CalendarQuarter,
      CalendarYear,
      WeekDay,
      YearWeek,
      YearQuarter,
      YearMonth,
      FirstDayOfWeekDate,
      FirstDayOfMonthDate,
      LastDayOfMonthDate,
      CalendarDayOfYear,
      YearDay,
      extractYear,
      extractMonth,
      extractDay,
      dateYearNumc,
      currentTimeStamp,
      currenDate,
      currenTime,
      currentDateTime,
      summerTimeMark,
      convertDatsToDatn,
      dayName,
      monthShortName,
      monthName,
      CalendarYearTH,
      CalendarFullDateName,
      /* Associations */
      _CalendarMonth,
      _CalendarQuarter,
      _CalendarWeek,
      _CalendarYear,
      _WeekDay,
      _YearMonth,
      _YearWeek
}
where
  Today = $parameters.p_date;

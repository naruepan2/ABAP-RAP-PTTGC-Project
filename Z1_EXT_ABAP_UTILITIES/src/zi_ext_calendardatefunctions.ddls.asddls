@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Calendar Date Functions'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #XL,
    dataClass: #MIXED
}

define view entity ZI_EXT_CALENDARDATEFUNCTIONS
  with parameters
    //Enter a valid value; p_language value format is 'E' (English) or '2' (Thailand).
    @Environment.systemField: #SYSTEM_LANGUAGE
    p_language : abap.lang
  as select from I_CalendarDate
{
  key CalendarDate                                                        as Today,

      dats_add_days( $projection.Today, -1, 'NULL' )                      as Yesterday,
      dats_add_days( $projection.Today, 1, 'NULL' )                       as Tomorrow,
      dats_is_valid( CalendarDate )                                       as isValidDate, //Ex: 1

      CalendarDay                                                         as CalendarDay,
      CalendarWeek                                                        as CalendarWeek,
      CalendarMonth                                                       as CalendarMonth,
      CalendarQuarter                                                     as CalendarQuarter,
      CalendarYear                                                        as CalendarYear,

      WeekDay                                                             as WeekDay,
      YearWeek                                                            as YearWeek,
      YearQuarter                                                         as YearQuarter,
      YearMonth                                                           as YearMonth,

      FirstDayOfWeekDate                                                  as FirstDayOfWeekDate,
      FirstDayOfMonthDate                                                 as FirstDayOfMonthDate,
      LastDayOfMonthDate                                                  as LastDayOfMonthDate,
      CalendarDayOfYear                                                   as CalendarDayOfYear,
      YearDay                                                             as YearDay,

      // Extract day, month, year with substring
      substring( CalendarDate, 1, 4 )                                     as extractYear,  //YYYY
      substring( CalendarDate, 5, 2 )                                     as extractMonth, //MM
      substring( CalendarDate, 7, 2 )                                     as extractDay,   //DD
      cast( substring( CalendarDate, 1, 4 ) as abap.numc( 4 ) )           as dateYearNumc,

      //Days between today two dates
      //dats_days_between( CalendarDate, dats_add_days( $session.user_date, 10, 'NULL' ) ) as tenDaysBetweenDates,

      //Timestamp
      tstmp_current_utctimestamp( )                                       as currentTimeStamp,
      tstmp_to_dats( tstmp_current_utctimestamp( ),
                     abap_system_timezone( $session.client, 'NULL'),
                     $session.client,
                     'NULL' )                                             as currenDate,
      tstmp_to_tims( tstmp_current_utctimestamp( ),
                     abap_system_timezone( $session.client, 'NULL'),
                     $session.client,
                     'NULL' )                                             as currenTime,
      concat( $projection.currenDate, $projection.currenTime )            as currentDateTime,
      tstmp_to_dst( tstmp_current_utctimestamp( ),
                    abap_system_timezone( $session.client, 'NULL'),
                    $session.client,
                    'NULL' )                                              as summerTimeMark,
      dats_to_datn(CalendarDate,'FAIL','INITIAL')                         as convertDatsToDatn,

      //Month description for Public Cloud. For On-Prem or Private Cloud -> T246 table can be used
      case $parameters.p_language
        when '2'
            then
                case WeekDay
                    when '1' then 'จันทร์'
                    when '2' then 'อังคาร'
                    when '3' then 'พุธ'
                    when '4' then 'พฤหัสบดี'
                    when '5' then 'ศุกร์'
                    when '6' then 'เสาร์'
                    when '7' then 'อาทิตย์'
                    else null
                end
        else
                case WeekDay
                    when '1' then 'Monday'
                    when '2' then 'Tuesday'
                    when '3' then 'Wednesday'
                    when '4' then 'Thusday'
                    when '5' then 'Friday'
                    when '6' then 'Saturday'
                    when '7' then 'Sunday'
                    else null
                end
      end                                                                 as dayName,

      //Month description for Public Cloud. For On-Prem or Private Cloud -> T247 table can be used
      case $parameters.p_language
        when '2'
            then
              case CalendarMonth
                  when '01' then 'ม.ค.'
                  when '02' then 'ก.พ.'
                  when '03' then 'มี.ค.'
                  when '04' then 'เม.ย.'
                  when '05' then 'พ.ค.'
                  when '06' then 'มิ.ย.'
                  when '07' then 'ก.ค.'
                  when '08' then 'ส.ค.'
                  when '09' then 'ก.ย.'
                  when '10' then 'ต.ค.'
                  when '11' then 'พ.ย.'
                  when '12' then 'ธ.ค.'
                  else null
              end
         else
              case CalendarMonth
                  when '01' then 'JAN'
                  when '02' then 'FEB'
                  when '03' then 'MAR'
                  when '04' then 'APR'
                  when '05' then 'MAY'
                  when '06' then 'JUN'
                  when '07' then 'JUL'
                  when '08' then 'AUG'
                  when '09' then 'SEP'
                  when '10' then 'OCT'
                  when '11' then 'NOV'
                  when '12' then 'DEC'
                  else null
              end
      end                                                                 as monthShortName,

      case $parameters.p_language
        when '2'
            then
                case CalendarMonth
                    when '01' then 'มกราคม'
                    when '02' then 'กุมภาพันธ์'
                    when '03' then 'มีนาคม'
                    when '04' then 'เมษายน'
                    when '05' then 'พฤษภาคม'
                    when '06' then 'มิถุนายน'
                    when '07' then 'กรกฎาคม'
                    when '08' then 'สิงหาคม'
                    when '09' then 'กันยายน'
                    when '10' then 'ตุลาคม'
                    when '11' then 'พฤศจิกายน'
                    when '12' then 'ธันวาคม'
                    else null
                    end
        else
                case CalendarMonth
                    when '01' then 'January'
                    when '02' then 'February'
                    when '03' then 'March'
                    when '04' then 'April'
                    when '05' then 'May'
                    when '06' then 'June'
                    when '07' then 'July'
                    when '08' then 'August'
                    when '09' then 'September'
                    when '10' then 'October'
                    when '11' then 'November'
                    when '12' then 'December'
                    else null
                    end
      end                                                                 as monthName,

      substring(dats_add_months( $projection.Today, 6516, 'NULL' ), 1, 4) as CalendarYearTH,

      case $parameters.p_language
        when '2'
            then
              concat_with_space($projection.CalendarDay,
                concat_with_space($projection.monthName, ( substring(dats_add_months( $projection.Today, 6516, 'NULL' ), 1, 4) ), 1), 1)
        else
              concat_with_space($projection.CalendarDay,
                concat_with_space($projection.monthName, $projection.CalendarYear ,1),1)
      end                                                                 as CalendarFullDateName,


      /* Associations */
      _CalendarMonth,
      _CalendarQuarter,
      _CalendarWeek,
      _CalendarYear,
      _WeekDay,
      _YearMonth,
      _YearWeek
}

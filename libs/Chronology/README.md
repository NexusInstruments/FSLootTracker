Chronology
==========
A Wildstar LUA library to format date and time objects as localized strings.

Usage
=====
## Including the Library
```lua
  local Chronology
  Chronology = Apollo.GetPackage("Chronology-1.0").tPackage

  Chronology:GetFormattedDate(GameLib.GetLocalTime())
```

## Localization
The library currently supports localization of Month and Day of Week names. The following languages are supported:

| Language Code | Description |
| ------------- | ----------- |
| "en" | English |
| "fr" | Français (French) |
| "de" | Deutsch (German) |
| "es" | Español (Spanish) |

**Notes**
* The library will default to English ("en") if either no language code is passed or the default language is not changed

## Formatting
Elements of the formatting strings are used to produce strings that are in a desired format.

| Format Code | Description | Example |
| ----------- | ----------- | ------- |
| "{YYYY}" | 4 Digit Year | "2014" |
| "{YY}" | 2 Digit Year | "14" |
| "{MMMM}" | Localized Month Name | "January", "Mayo", "Avril" |
| "{MMM}" | Localized Abbreviated Month Name | "Jan.", "May", "Avr." |
| "{MM}" | 2 Digit Month; zero-padded | "01" |
| "{M}" | Month; not-padded | "1" |
| "{DDDD}" | Localized Day of Week | "Miercoles", "Friday", "Sonntag" |
| "{DDD}" | Localized Abbreviated Day of Week | "Mi", "Fri", "So" |
| "{DD}" | 2 Digit Date; zero-padded | "04", "30" |
| "{D}" | Date digit; not-padded | "1" |
| "{HH}" | 2 Digit Hour (24h); zero-padded | "01", "23" |
| "{H}" | Hour digit (24h); not-padded | "1", "23" |
| "{hh}" | 2 Digit Hour (12h); zero-padded | "01", "11" |
| "{h}" |  Hour digit (12h); not-padded | "1", "11" |
| "{mm}" | 2 Digit Minute; zero-padded | "01", "43" |
| "{m}" | Minute digit; not-padded | "9", "14" |
| "{SS}" | 2 Digit Seconds; zero-padded | "09", "43" |
| "{S}" | Seconds digit; not-padded | "9", "14" |
| "{TT}" | Full Meridian Designator | "AM"/"PM" |
| "{T}" | Short Meridian Designator | "a"/"p" |


Reference
---------
## GetFormattedDate(tDate, strFormat, strLangCode)
| Param | Description |
| ----- | ----------- |
| tDate | A Wildstar (GameLib) date table object |
| strFormat | A format string to use to format the data |
| strLangCode | A language code string to use |

**Notes**
* Default format used for date strings if no format is passed is "{YYYY}-{MM}-{DD}"

**Example**
```lua
  local strDate = Chronology:GetFormattedDate(GameLib.GetLocalTime())
```
**Results**
```
Value of strDate:
----> "2014-07-23"
```

## GetFormattedTime(tDate, strFormat, strLangCode)
| Param | Description |
| ----- | ----------- |
| tDate | A Wildstar (GameLib) date table object |
| strFormat | A format string to use to format the data |
| strLangCode | A language code string to use |

**Notes**
* Default format used for date strings if no format is passed is "{HH}:{mm}:{SS}"

**Example**
```lua
  local strTime = Chronology:GetFormattedTime(GameLib.GetLocalTime())
  local strTime2 = Chronology:GetFormattedTime(GameLib.GetLocalTime(),"{hh}.{mm} {T}")
```
**Results**
```
Value of strTime:
----> "21:32:43"

Value of strTime2:
----> "11.32 p"
```

## GetFormattedDateTime(tDate, strFormat, strLangCode)
| Param | Description |
| ----- | ----------- |
| tDate | A Wildstar (GameLib) date table object |
| strFormat | A format string to use to format the data |
| strLangCode | A language code string to use |

**Notes**
* Default format used for date strings if no format is passed is "{HH}:{mm}:{SS}"

**Example**
```lua
  local strDateTime = Chronology:GetFormattedTime(GameLib.GetLocalTime())
  local strDateTime2 = Chronology:GetFormattedTime(GameLib.GetLocalTime(),"{DDDD} {D} {MMMM} {YYYY} {HH}:{mm}", "es")
```
**Results**
```
Value of strDateTime:
----> "2014-07-23 21:32:43"

Value of strDateTime2:
----> "Martes 23 Julio 2014 21:32"
```
## SetDefaultLanguage(strLangCode)
| Param | Description |
| ----- | ----------- |
| strLangCode | Language code string of default language to use |

## GetMonthString(month, bAbbrv, strLangCode)
| Param | Description |
| ----- | ----------- |
| month | Integer for the month (1 - 12) |
| bAbbrv | Abbreviated value (true/false) |
| strLangCode | A language code string to use |

## GetDayOfWeekString(day, bAbbrv, strLangCode)
| Param | Description |
| ----- | ----------- |
| day | Integer for the day of the week (1 - 7) |
| bAbbrv | Abbreviated value (true/false) |
| strLangCode | A language code string to use |

**Licensed under MIT License**
Copyright (c) 2015 NexusInstruments

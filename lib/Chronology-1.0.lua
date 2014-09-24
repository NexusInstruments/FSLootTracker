local C_MAJOR, C_MINOR = "Chronology-1.0", 2
local C_Pkg = Apollo.GetPackage(C_MAJOR)
if C_Pkg and (C_Pkg.nVersion or 0) >= C_MINOR then
	return -- no upgrade needed
end

-- Set a reference to the actual package or create an empty table
local Chronology = C_Pkg and C_Pkg.tPackage or {}

local ktMonthNumDays = {
	[1] = 31,
	[2] = 28,
	[3] = 31,
	[4] = 30,
	[5] = 31,
	[6] = 30,
	[7] = 31,
	[8] = 31,
	[9] = 30,
	[10] = 31,
	[11] = 30,
	[12] = 31
}

local ktMonths = {
	["en"] = {
		[1] = {full = "January", abbrv = "Jan."},
		[2] = {full = "February", abbrv = "Feb."},
		[3] = {full = "March", abbrv = "Mar."},
		[4] = {full = "April", abbrv = "Apr."},
		[5] = {full = "May", abbrv = "May"},
		[6] = {full = "June", abbrv = "Jun."},
		[7] = {full = "July", abbrv = "Jul."},
		[8] = {full = "August", abbrv = "Aug."},
		[9] = {full = "September", abbrv = "Sep."},
		[10] = {full = "October", abbrv = "Oct."},
		[11] = {full = "November", abbrv = "Nov."},
		[12] = {full = "December", abbrv = "Dec."}
	},
	["fr"] = {
		[1] = {full = "Janvier", abbrv = "Jan."},
		[2] = {full = "Février", abbrv = "Fév."},
		[3] = {full = "Mars", abbrv = "Mar."},
		[4] = {full = "Avril", abbrv = "Avr."},
		[5] = {full = "Mai", abbrv = "Mai"},
		[6] = {full = "Juin", abbrv = "Jun."},
		[7] = {full = "Juillet", abbrv = "Jul."},
		[8] = {full = "Août", abbrv = "Aoû."},
		[9] = {full = "Septembre", abbrv = "Sep."},
		[10] = {full = "Octobre", abbrv = "Oct."},
		[11] = {full = "Novembre", abbrv = "Nov."},
		[12] = {full = "Décembre", abbrv = "Déc."}
	},
	["es"] = {
		[1] = {full = "Enero", abbrv = "Ene."},
		[2] = {full = "Febrero", abbrv = "Feb."},
		[3] = {full = "Marzo", abbrv = "Mar."},
		[4] = {full = "Abril", abbrv = "Abr."},
		[5] = {full = "Mayo", abbrv = "May"},
		[6] = {full = "Junio", abbrv = "Jun."},
		[7] = {full = "Julio", abbrv = "Jul."},
		[8] = {full = "Agosto", abbrv = "Ago."},
		[9] = {full = "Septiembre", abbrv = "Sep."},
		[10] = {full = "Octubre", abbrv = "Oct."},
		[11] = {full = "Noviembre", abbrv = "Nov."},
		[12] = {full = "Diciembre", abbrv = "Dic."}
	},
	["de"] = {
		[1] = {full = "Januar", abbrv = "Jän."},
		[2] = {full = "Februar", abbrv = "Feb."},
		[3] = {full = "März", abbrv = "März"},
		[4] = {full = "April", abbrv = "Apr."},
		[5] = {full = "Mai", abbrv = "Mai"},
		[6] = {full = "Juni", abbrv = "Juni"},
		[7] = {full = "Juli", abbrv = "Juli"},
		[8] = {full = "August", abbrv = "Aug."},
		[9] = {full = "September", abbrv = "Sept."},
		[10] = {full = "Oktober", abbrv = "Okt."},
		[11] = {full = "November", abbrv = "Nov."},
		[12] = {full = "Dezember", abbrv = "Dez."}
	}
}

local ktDaysOfWeek = {
	["en"] = {
		[1] = {full = "Sunday", abbrv = "Sun."},
		[2] = {full = "Monday", abbrv = "Mon."},
		[3] = {full = "Tuesday", abbrv = "Tue."},
		[4] = {full = "Wednesday", abbrv = "Wed."},
		[5] = {full = "Thursday", abbrv = "Thu."},
		[6] = {full = "Friday", abbrv = "Fri."},
		[7] = {full = "Saturday", abbrv = "Sat."}
	},
	["fr"] = {
		[1] = {full = "Dimanche", abbrv = "Dim."},
		[2] = {full = "Lundi", abbrv = "Lun."},
		[3] = {full = "Mardi", abbrv = "Mar."},
		[4] = {full = "Mercredi", abbrv = "Mer."},
		[5] = {full = "Jeudi", abbrv = "Jeu."},
		[6] = {full = "Vendredi", abbrv = "Ven."},
		[7] = {full = "Samedi", abbrv = "Sam."}
	},
	["es"] = {
		[1] = {full = "Domingo", abbrv = "Do"},
		[2] = {full = "Lunes", abbrv = "Lu"},
		[3] = {full = "Martes", abbrv = "Ma"},
		[4] = {full = "Miércoles", abbrv = "Mi"},
		[5] = {full = "Jueves", abbrv = "Ju"},
		[6] = {full = "Viernes", abbrv = "Vi"},
		[7] = {full = "Sábado", abbrv = "Sa"}
	},
	["de"] = {
		[1] = {full = "Sonntag", abbrv = "So"},
		[2] = {full = "Montag", abbrv = "Mo"},
		[3] = {full = "Dienstag", abbrv = "Di"},
		[4] = {full = "Mittwoch", abbrv = "Mi"},
		[5] = {full = "Donnerstag", abbrv = "Do"},
		[6] = {full = "Freitag", abbrv = "Fr"},
		[7] = {full = "Samstag", abbrv = "Sa"}
	}
}

local ktDesignators = {
	AM = { full = "AM", abbrv = "a"}, 
	PM = { full = "PM", abbrv = "p"}
}

Chronology.defaultLanguage = "en"

function Chronology:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   return setmetatable(new, Chronology)
end

function Chronology:SetDefaultLanguage(lang)
	Chronology.defaultLanguage = lang
end

function Chronology:GetDaysInMonth(month, year)
	local d = ktMonthNumDays[month]
  
	-- check for leap year
	if (month == 2) then
		if (math.mod(year,4) == 0) then
			if (math.mod(year,100) == 0)then                
				if (math.mod(year,400) == 0) then                    
					d = 29
				end
			else                
				d = 29
			end
		end
	end

	return d  
end

function Chronology:GetMonthString(month, bAbbrv, lang)
	local localeMonthValues
	if lang ~= nil then
		localeMonthValues = ktMonths[lang]
		if localeMonthValues == nil then
			localeMonthValues = ktMonths[Chronology.defaultLanguage]
		end
	else
		localeMonthValues = ktMonths[Chronology.defaultLanguage]
	end
	
	if month < 1 or month > 12 then 
		return ""
	else
		if bAbbrv then 
			return localeMonthValues[month].abbrv
		else
			return localeMonthValues[month].full
		end
	end
	
	return ""
end

function Chronology:GetDayOfWeekString(day, bAbbrv, lang)
	local localeDayValues
	if lang ~= nil then
		localeDayValues = ktDaysOfWeek[lang]
		if localeDayValues == nil then
			localeDayValues = ktDaysOfWeek[Chronology.defaultLanguage]
		end
	else
		localeDayValues = ktDaysOfWeek[Chronology.defaultLanguage]
	end
	
	if day < 1 or day > 7 then 
		return ""
	else
		if bAbbrv then 
			return localeDayValues[day].abbrv
		else
			return localeDayValues[day].full
		end
	end
	
	return ""	
end

function Chronology:GetHour12(hour)
	local hour12 = hour
	if hour12 > 12 then 
		hour12 = hour12 - 12
	end
	if hour12 == 0 then
		hour12 = 12
	end
	return hour12
end

function Chronology:GetMeridianDesignator(hour, bAbbrv)
	if hour < 0 or hour > 23 then
		return ""
	else
		if hour >= 12 then
			if bAbbrv then 
				return ktDesignators.PM.abbrv
			else
				return ktDesignators.PM.full
			end
		else
			if bAbbrv then 
				return ktDesignators.AM.abbrv
			else
				return ktDesignators.AM.full
			end
		end
	end
	return ""
end

-- Sub-values of Time Table
----------------------
-- nDay
-- nDayOfWeek
-- nMonth
-- nYear
-- nHour
-- nMinute
-- nSecond
-----------------------
-- Default String Date Format is International Standard YYYY-MM-DD
function Chronology:GetFormattedDate(tDate, strFormat, locale)
	local strReturn = ""
	if not strFormat then
		strFormat = "{YYYY}-{MM}-{DD}"
	end
	
	strReturn = strFormat
	strReturn = string.gsub( strReturn, "{YYYY}", tostring(tDate.nYear) )
	strReturn = string.gsub( strReturn, "{YY}", string.format("%02d", string.sub(tostring(tDate.nYear), -3) ) )
	strReturn = string.gsub( strReturn, "{MMMM}", Chronology:GetMonthString(tDate.nMonth, false, locale) )
	strReturn = string.gsub( strReturn, "{MMM}", Chronology:GetMonthString(tDate.nMonth, true, locale) )
	strReturn = string.gsub( strReturn, "{MM}", string.format("%02d", tostring(tDate.nMonth) ) )
	strReturn = string.gsub( strReturn, "{M}", tostring(tDate.nMonth) )
	strReturn = string.gsub( strReturn, "{DDDD}", Chronology:GetDayOfWeekString(tDate.nDayOfWeek, false, locale) )
	strReturn = string.gsub( strReturn, "{DDD}", Chronology:GetDayOfWeekString(tDate.nDayOfWeek, true, locale) )
	strReturn = string.gsub( strReturn, "{DD}", string.format("%02d", tostring(tDate.nDay) ) )
	strReturn = string.gsub( strReturn, "{D}", tostring(tDate.nDay) )	
	
	return strReturn
end

-- Default String Date Format is International Standard 24h HH:mm:SS
function Chronology:GetFormattedTime(tDate, strFormat, locale)
	local strReturn = ""
	if not strFormat then
		strFormat = "{HH}:{mm}:{SS}"
	end
	
	strReturn = strFormat
	strReturn = string.gsub( strReturn, "{HH}", string.format("%02d", tDate.nHour ) )
	strReturn = string.gsub( strReturn, "{H}", tostring(tDate.nHour) )
	strReturn = string.gsub( strReturn, "{hh}", string.format("%02d", Chronology:GetHour12(tDate.nHour) ) )
	strReturn = string.gsub( strReturn, "{h}", tostring(Chronology:GetHour12(tDate.nHour) ) )
	strReturn = string.gsub( strReturn, "{mm}", string.format("%02d", tDate.nMinute ) )
	strReturn = string.gsub( strReturn, "{m}", tostring(tDate.nMinute) )
	strReturn = string.gsub( strReturn, "{SS}", string.format("%02d", tDate.nSecond) )
	strReturn = string.gsub( strReturn, "{S}", tostring(tDate.nSecond) )
	strReturn = string.gsub( strReturn, "{TT}", Chronology:GetMeridianDesignator(tDate.nHour, false) )
	strReturn = string.gsub( strReturn, "{T}", Chronology:GetMeridianDesignator(tDate.nHour, true) )
	
	return strReturn
end

function Chronology:GetFormattedDateTime(tDate, strFormat, locale)
	local strReturn = ""
	if not strFormat then
		strFormat = "{YYYY}-{MM}-{DD} {HH}:{mm}:{SS}"
	end
	
	strReturn = strFormat
	strReturn = Chronology:GetFormattedDate(tDate, strReturn, locale)
	strReturn = Chronology:GetFormattedTime(tDate, strReturn, locale)
	
	return strReturn
end

Apollo.RegisterPackage(Chronology, C_MAJOR, C_MINOR, {})


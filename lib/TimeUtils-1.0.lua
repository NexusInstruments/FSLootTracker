local TimeUtils = {}

local defaultLanguage = "en"
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
		[1] = {full = "Monday", abbrv = "Mon."},
		[2] = {full = "Tuesday", abbrv = "Tue."},
		[3] = {full = "Wednesday", abbrv = "Wed."},
		[4] = {full = "Thursday", abbrv = "Thu."},
		[5] = {full = "Friday", abbrv = "Fri."},
		[6] = {full = "Saturday", abbrv = "Sat."},
		[7] = {full = "Sunday", abbrv = "Sun."}
	},
	["fr"] = {
		[1] = {full = "Lundi", abbrv = "Lun."},
		[2] = {full = "Mardi", abbrv = "Mar."},
		[3] = {full = "Mercredi", abbrv = "Mer."},
		[4] = {full = "Jeudi", abbrv = "Jeu."},
		[5] = {full = "Vendredi", abbrv = "Ven."},
		[6] = {full = "Samedi", abbrv = "Sam."},
		[7] = {full = "Dimanche", abbrv = "Dim."}
	},
	["es"] = {
		[1] = {full = "Lunes", abbrv = "Lu"},
		[2] = {full = "Martes", abbrv = "Ma"},
		[3] = {full = "Miércoles", abbrv = "Mi"},
		[4] = {full = "Jueves", abbrv = "Ju"},
		[5] = {full = "Viernes", abbrv = "Vi"},
		[6] = {full = "Sábado", abbrv = "Sa"},
		[7] = {full = "Domingo", abbrv = "Do"}
	},
	["de"] = {
		[1] = {full = "Montag", abbrv = "Mo"},
		[2] = {full = "Dienstag", abbrv = "Di"},
		[3] = {full = "Mittwoch", abbrv = "Mi"},
		[4] = {full = "Donnerstag", abbrv = "Do"},
		[5] = {full = "Freitag", abbrv = "Fr"},
		[6] = {full = "Samstag", abbrv = "Sa"},
		[7] = {full = "Sonntag", abbrv = "So"}
	}
}

function TimeUtils:new(args)
   local new = { }

   if args then
      for key, val in pairs(args) do
         new[key] = val
      end
   end

   return setmetatable(new, JsonUtils)
end

function TimeUtils:GetMonthString(month, lang, bAbbrv)
	local localeMonthValues
	if lang ~= nil then
		localeMonthValues = ktMonths[lang]
		if localeMonthValues == nil then
			localeMonthValues = ktMonths[defaultLanguage]
		end
	else
		localeMonthValues = ktMonths[defaultLanguage]
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

function TimeUtils:GetDayOfWeekString(day, lang, bAbbrv)
	local localeDayValues
	if lang ~= nil then
		localeDayValues = ktDaysOfWeek[lang]
		if localeDayValues == nil then
			localeDayValues = ktDaysOfWeek[defaultLanguage]
		end
	else
		localeDayValues = ktDaysOfWeek[defaultLanguage]
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

function TimeUtils:GetFormattedDate(tDate)
	
end

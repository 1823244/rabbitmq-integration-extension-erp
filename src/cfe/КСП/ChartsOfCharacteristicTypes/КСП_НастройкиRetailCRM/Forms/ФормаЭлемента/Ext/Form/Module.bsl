﻿
&НаКлиенте
Процедура ТипЗначенияПриИзменении(Элемент)
	Значение = Неопределено;
КонецПроцедуры


&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если Значение <> ЗначениеДоИзменения Тогда
		МенЗап = РегистрыСведений.ксп_ЗначенияНастроекRetailCRM.СоздатьМенеджерЗаписи();
		МенЗап.Настройка 	= ТекущийОбъект.Ссылка;
		МенЗап.Значение		= Значение;
		МенЗап.Записать();
	КонецЕсли;
КонецПроцедуры


&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	МенЗап = РегистрыСведений.ксп_ЗначенияНастроекRetailCRM.СоздатьМенеджерЗаписи();
	МенЗап.Настройка 	= ТекущийОбъект.Ссылка;
	МенЗап.Прочитать();
	Если МенЗап.Выбран() Тогда
		Значение 			= МенЗап.Значение;
		ЗначениеДоИзменения = МенЗап.Значение;
	КонецЕсли;
	
КонецПроцедуры


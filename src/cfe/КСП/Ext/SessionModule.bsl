﻿
&После("УстановкаПараметровСеанса")
Процедура КСП_УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	// Параметры сеанса, инициализация которых требует обращения к одним и тем же данным
	// следует инициализировать сразу группой. Для того, чтобы избежать их повторной инициализации,
	// имена уже установленных параметров сеанса сохраняются в массиве УстановленныеПараметры
	Если ТребуемыеПараметры = Неопределено Тогда
		ТребуемыеПараметры = Новый Массив;
	КонецЕсли;	

	мис_УправлениеЗаданиямиСервер.УстановкаПараметровСеанса(ТребуемыеПараметры);
	
	mis_LoggerServer.УстановкаПараметровСеанса(ТребуемыеПараметры);
	
КонецПроцедуры

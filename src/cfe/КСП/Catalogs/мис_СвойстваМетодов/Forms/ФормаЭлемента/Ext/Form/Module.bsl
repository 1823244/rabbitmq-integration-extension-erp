﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбъектОбъект = РеквизитФормыВЗначение("Объект");

	Для Каждого ТекСтрока Из Объект.Константы Цикл
		
		ТекСтрока.РедактируемоеЗначение	= ОбъектОбъект.Константы[ТекСтрока.НомерСтроки -1].Значение.Получить();
	
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Для Каждого ТекСтрока Из ТекущийОбъект.Константы Цикл
	
		ТекСтрока.Значение = Новый ХранилищеЗначения(Объект.Константы[ТекСтрока.НомерСтроки - 1].РедактируемоеЗначение);
	
	КонецЦикла;
КонецПроцедуры

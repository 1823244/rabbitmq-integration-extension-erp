﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Владелец");
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование = Истина;
	ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
	ЭлементОтбора.ПравоеЗначение = Объект.Ссылка;
	
	СписокПараметров = РеквизитФормыВЗначение("Объект").ПараметрыВызова.Получить();
	Если ТипЗнч(СписокПараметров) = Тип("СписокЗначений") Тогда
		Для Каждого ТекСтрока Из СписокПараметров Цикл
			
			НоваяСтрока = ПараметрыВызова.Добавить();
			НоваяСтрока.Параметр = ТекСтрока.Представление;
			НоваяСтрока.Значение = ТекСтрока.Значение;
		
		КонецЦикла;
	ИначеЕсли ТипЗнч(СписокПараметров) = Тип("ТаблицаЗначений") Тогда
		Для Каждого ТекСтрока Из СписокПараметров Цикл
			
			НоваяСтрока = ПараметрыВызова.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, ТекСтрока);
		
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПоказатьОтчет(Команда)
	мис_ЛоггерКлиент.ОткрытьОтчетПоЛогу(Объект.Ссылка);
КонецПроцедуры

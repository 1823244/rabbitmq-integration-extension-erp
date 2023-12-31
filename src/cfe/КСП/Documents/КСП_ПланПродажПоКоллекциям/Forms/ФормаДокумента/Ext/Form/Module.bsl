﻿
&НаКлиенте
Процедура ОбновитьДерево(ОбновитьПринудительно = Ложь)
	
	Если ОбновитьПринудительно ИЛИ Модифицированность Тогда	
		ОбновитьДеревоНаСервере();	
	КонецЕсли;

КонецПроцедуры

Процедура ОбновитьДеревоНаСервере()

			
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТЗ.Клиент КАК Клиент,
		|	ТЗ.ПланПродаж КАК ПланПродаж
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ТЗ КАК ТЗ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	вт.Клиент КАК Клиент,
		|	вт.ПланПродаж КАК ПланПродаж
		|ИЗ
		|	ВТ КАК вт
		|ИТОГИ
		|	СУММА(ПланПродаж)
		|ПО
		|	Клиент";
	
	Запрос.УстановитьПараметр("ТЗ", Объект.План.Выгрузить());
	РезультатЗапроса = Запрос.Выполнить();
	
	ПромДерево = РезультатЗапроса.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	ЗначениеВРеквизитФормы(ПромДерево, "Дерево");

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьДерево(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПланПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)

	ОбновитьДерево(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура Развенуть(Команда)

	РазвенутьСвернутьДерево();

КонецПроцедуры

&НаКлиенте
Процедура РазвенутьСвернутьДерево(Развенуть = Истина)
	
	
	ЭлементыДерева = Дерево.ПолучитьЭлементы();
	Для каждого ЭлементДерева Из ЭлементыДерева Цикл
		
		ид = ЭлементДерева.ПолучитьИдентификатор();
		Если Развенуть Тогда
			Элементы.Дерево.Развернуть(ид, Истина);			
		иначе
			Элементы.Дерево.Свернуть(ид);						
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура Свернуть(Команда)
	
	РазвенутьСвернутьДерево(Ложь);
	
КонецПроцедуры

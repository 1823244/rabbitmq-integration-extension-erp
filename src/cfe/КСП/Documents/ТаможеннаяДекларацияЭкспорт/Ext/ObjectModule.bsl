﻿// +++ УваровДС 05/12/2023
&После("ОбработкаЗаполнения")
Процедура КСП_ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда 
		Если ДанныеЗаполнения.Свойство("ДокументОснование") Тогда 
			ТипДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения.ДокументОснование);
			Если ТипДанныхЗаполнения = Тип("ДокументСсылка.ПередачаТоваровМеждуОрганизациями") Тогда

				// стандартыным методом заполнение возможно если есть СЧЕТ ФАКТУРЫ 
				////ЗаполнитьПоДокументамОснованиям(ДанныеЗаполнения);
				//ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения.Основание);
				// чтобы подтягивалось налогообложение
				ЭтотОбъект.КСП_НалогообложениеНДС = ДанныеЗаполнения.ДокументОснование.НалогообложениеНДС;
				//
				КСП_КонтрагентПолучателя = ДанныеЗаполнения.ДокументОснование.ОрганизацияПолучатель.КСП_Контрагент;
				ЭтотОбъект.Контрагент = КСП_КонтрагентПолучателя;
				ЭтотОбъект.Партнер = КСП_КонтрагентПолучателя.Партнер;
				ЭтотОбъект.Подразделение = ДанныеЗаполнения.ДокументОснование.Подразделение;
				//// подобран договор в форме Передача товаров по контрагенту и его партнеру и добавлен
				ЭтотОбъект.Договор = ДанныеЗаполнения.ДокументОснование.КСП_ДоговорКонтрагентов;
				// типовым так и так вызывается
				//ИнициализироватьДокумент(ДанныеЗаполнения); 
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры


&ИзменениеИКонтроль("ЗаполнитьПоДокументамОснованиям")
Процедура КСП_ЗаполнитьПоДокументамОснованиям(ДанныеЗаполнения)

	Если ДокументыОснования.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	ПараметрыДекларации = ПолучитьПараметрыТаможеннойДекларацииПоОснованиям();
    #Вставка
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда 
		Если ДанныеЗаполнения.Свойство("ДокументОснование") Тогда 
			ТипДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения.ДокументОснование);
			Если ТипДанныхЗаполнения = Тип("ДокументСсылка.ПередачаТоваровМеждуОрганизациями") Тогда
				Если ПараметрыДекларации.Организация = Неопределено Тогда
					ПараметрыДекларации.Организация = ДанныеЗаполнения.ДокументОснование.Организация;	
				КонецЕсли;
			КонецЕсли;
			Если ТипДанныхЗаполнения = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
				Если ПараметрыДекларации.Организация = Неопределено Тогда
					ПараметрыДекларации.Организация = ДанныеЗаполнения.ДокументОснование.Организация;	
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	#КонецВставки
	Если Не ПараметрыДекларации.Организация = Неопределено Тогда
		ДанныеЗаполнения.Вставить("Организация", ПараметрыДекларации.Организация);
	Иначе
		ВызватьИсключение СтрШаблон(
		НСтр("ru = 'Ввод таможенной декларации на экспорт на основании %1 не требуется.';
		|en = 'Entering export customs declaration based on %1 is not required.'"),
		ДокументыОснования[0].ДокументОснование);
	КонецЕсли;

	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ПараметрыДекларации,, "Организация");

КонецПроцедуры

&После("ПередЗаписью")
Процедура КСП_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ЭтотОбъект.УстановитьНовыйНомер();
КонецПроцедуры


// --- УваровДС
﻿// +++ УваровДС 05/12/2023
&После("ОбработкаЗаполнения")
Процедура КСП_ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда 
		Если ДанныеЗаполнения.Свойство("Основание") Тогда 
			ТипДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения.Основание);
			Если ТипДанныхЗаполнения = Тип("ДокументСсылка.ПередачаТоваровМеждуОрганизациями") Тогда
				Строка = ЭтотОбъект.ДокументыОснования.Добавить();
				Строка.ДокументОснование = ДанныеЗаполнения.Основание;
				
				ЗаполнитьПоДокументамОснованиям(ДанныеЗаполнения);
				ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения.Основание);
				
				ЭтотОбъект.КСП_НалогообложениеНДС = ДанныеЗаполнения.Основание.НалогообложениеНДС;
				
				КСП_КонтрагентПолучателя = ДанныеЗаполнения.Основание.ОрганизацияПолучатель.КСП_Контрагент;
				ЭтотОбъект.Контрагент = КСП_КонтрагентПолучателя;
				ЭтотОбъект.Партнер = КСП_КонтрагентПолучателя.Партнер;
				ЭтотОбъект.Подразделение = ДанныеЗаполнения.Основание.Подразделение;
				// подобран договор в форме Передача товаров по контрагенту и его партнеру и добавлен
				ЭтотОбъект.Договор = ДанныеЗаполнения.Основание.КСП_ДоговорКонтрагентов;
				
				ИнициализироватьДокумент(ДанныеЗаполнения); 
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры
// --- УваровДС
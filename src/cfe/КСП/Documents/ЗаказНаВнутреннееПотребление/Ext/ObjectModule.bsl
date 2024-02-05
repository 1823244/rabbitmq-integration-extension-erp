﻿
&После("ПередЗаписью")
Процедура КСП_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ЭтоНовый() ИЛИ Отказ Тогда
		Возврат;
	КонецЕсли;
	
	МенеджерДок = Документы.ЗаказНаВнутреннееПотребление;
	ТипДокумента = ЭтотОбъект.КСП_ТипДокументаСлужебногоРезерва;
	ПростоЗапись = (РежимЗаписи = РежимЗаписиДокумента.Запись);
	
	// Распределение готовой продукции
	ЭтоРаспределениеГотовойПродукции = (
		ТипДокумента = Перечисления.КСП_ТипДокументаСлужебногоРезерва.РаспределениеГотовойПродукции);
	ДиспетчерРаспределенияЗаписывает = МенеджерДок.КСП_ЭтоЗаписьДиспетчеромРаспределенияГотовойПродукции(ЭтотОбъект);
	
	Если ЭтоРаспределениеГотовойПродукции Тогда
		
		// Временно отключено для отладки работы распределения товаров по каналам продаж Ситько.
		
		//Если НЕ ДиспетчерРаспределенияЗаписывает И НЕ ПростоЗапись Тогда
		//	ТекстИсключения = НСтр(
		//		"ru = 'Документ для распределения готовой продукции можно провести только через
		//		|интерфейс обработки [Диспетчер распределения готовой продукции]'");
		//	ВызватьИсключение ТекстИсключения;
		//КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ТипДокумента) Тогда
			ТекстИсключения = НСтр(
				"ru = 'Для распределения готовой продукции требуется подразделение!'");
			ВызватьИсключение ТекстИсключения;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ЭтотОбъект.КСП_Коллекция) Тогда
			ТекстИсключения = НСтр(
				"ru = 'Для распределения готовой продукции требуется коллекция номенклатуры!'");
			ВызватьИсключение ТекстИсключения;
		КонецЕсли;
		
		РегистрыСведений.КСП_ИсторияРаспределенияГотовойПродукции.ЗаписатьИзмененияРаспределенияДокументом(ЭтотОбъект);
		
	КонецЕсли;
	
КонецПроцедуры

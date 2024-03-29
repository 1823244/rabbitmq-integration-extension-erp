﻿
Процедура КСП_ОбработатьЗачетПредоплаты(Объект, Отказ) Экспорт

	Если ТипЗнч(Объект) = Тип("ДокументОбъект.ПриходныйКассовыйОрдер")
		ИЛИ ТипЗнч(Объект) = Тип("ДокументОбъект.ПоступлениеБезналичныхДенежныхСредств") Тогда
		Если Объект.РасшифровкаПлатежа.Количество() > 0 Тогда
			СчетНаОплату = Объект.РасшифровкаПлатежа[0].ОснованиеПлатежа;
			ЗаказКлиента = Объект.РасшифровкаПлатежа[0].ОбъектРасчетов.Объект;
		КонецЕсли;
		Если ТипЗнч(ЗаказКлиента) = Тип("ДокументСсылка.ЗаказКлиента")
			И ТипЗнч(СчетНаОплату) = Тип("ДокументСсылка.СчетНаОплатуКлиенту")
			И СчетНаОплату.КСП_СуммаЗачетаПредоплаты <> 0 
			И Объект.КСП_СуммаЗачетаПредоплаты < СчетНаОплату.КСП_СуммаЗачетаПредоплаты Тогда
			КСП_СуммаЗачетаПредоплаты = СчетНаОплату.КСП_СуммаЗачетаПредоплаты - Объект.КСП_СуммаЗачетаПредоплаты;
			РезультатПривязкиДокументов = КСП_ПривязатьДокументыОплатыКЗаказу(ЗаказКлиента, КСП_СуммаЗачетаПредоплаты);
			Если ТипЗнч(РезультатПривязкиДокументов) = Тип("Строка") Тогда
				ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Документ не учитывает предоплаты по прчине: " + РезультатПривязкиДокументов + "'"), Объект.Ссылка);
				Отказ = Истина;
			Иначе
				Объект.КСП_СуммаЗачетаПредоплаты = СчетНаОплату.КСП_СуммаЗачетаПредоплаты;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Функция КСП_ПривязатьДокументыОплатыКЗаказу(Знач ЗаказКлиента, Знач КСП_СуммаЗачетаПредоплаты)

	РезультатПривязкиДокументов = Ложь;
	СуммаЗачетаПредоплаты = КСП_СуммаЗачетаПредоплаты;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты КАК ДокументПредоплаты,
		|	СУММА(ПриходныйКассовыйОрдерРасшифровкаПлатежа.Сумма) КАК Сумма
		|ИЗ
		|	РегистрСведений.КСП_ДокументыПредоплатыЗаказаКлиента КАК КСП_ДокументыПредоплатыЗаказаКлиента
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйКассовыйОрдер.РасшифровкаПлатежа КАК ПриходныйКассовыйОрдерРасшифровкаПлатежа
		|		ПО ((ВЫРАЗИТЬ(КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты КАК Документ.ПриходныйКассовыйОрдер)) = ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка)
		|ГДЕ
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ЗаказКлиента = &ЗаказКлиента
		|	И КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты ССЫЛКА Документ.ПриходныйКассовыйОрдер
		|	И ВЫРАЗИТЬ(ПриходныйКассовыйОрдерРасшифровкаПлатежа.ОбъектРасчетов.Объект КАК Документ.ПриходныйКассовыйОрдер) = ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты КАК ДокументПредоплаты,
		|	СУММА(ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Сумма) КАК Сумма
		|ИЗ
		|	РегистрСведений.КСП_ДокументыПредоплатыЗаказаКлиента КАК КСП_ДокументыПредоплатыЗаказаКлиента
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПоступлениеБезналичныхДенежныхСредств.РасшифровкаПлатежа КАК ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа
		|		ПО ((ВЫРАЗИТЬ(КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты КАК Документ.ПоступлениеБезналичныхДенежныхСредств)) = ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Ссылка)
		|ГДЕ
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ЗаказКлиента = &ЗаказКлиента
		|	И КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты ССЫЛКА Документ.ПоступлениеБезналичныхДенежныхСредств
		|	И ВЫРАЗИТЬ(ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.ОбъектРасчетов.Объект КАК Документ.ПоступлениеБезналичныхДенежныхСредств) = ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	КСП_ДокументыПредоплатыЗаказаКлиента.ДокументПредоплаты
		|
		|УПОРЯДОЧИТЬ ПО
		|	Сумма";
	
	Запрос.УстановитьПараметр("ЗаказКлиента", ЗаказКлиента);
	Попытка
		ВыборкаДокументовОплаты = Запрос.Выполнить().Выбрать();
	Исключение
		ЗаписьЖурналаРегистрации(
			"СозданиеДокументовОплатыПоСчетуНаОплатуКлиента.ИзменениеДокументовПредоплаты",
			УровеньЖурналаРегистрации.Ошибка,,
			ЗаказКлиента,
			"Ошибка выборки документов оплаты по <" + Строка(ЗаказКлиента) + ">" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())
		);
		Возврат "Ошибка выборки документов оплаты по <" + Строка(ЗаказКлиента) + ">";
	КонецПопытки;
	
	НачатьТранзакцию();
	Попытка
		МассивДокументовНаУдаление = Новый Массив;
		Пока ВыборкаДокументовОплаты.Следующий() Цикл
			
			ДокументПредоплатыСсылка = ВыборкаДокументовОплаты.ДокументПредоплаты;
			ДокументПредоплатыОбъект = ВыборкаДокументовОплаты.ДокументПредоплаты.ПолучитьОбъект();
			ОбъектРасчетовЗаказКлиента = Справочники.ОбъектыРасчетов.НайтиПоРеквизиту("Объект", ЗаказКлиента);
			
			Для каждого Строка Из ДокументПредоплатыОбъект.РасшифровкаПлатежа Цикл
				Если Строка.ОбъектРасчетов.Объект = ДокументПредоплатыСсылка Тогда
					
					СтруктураПересчетаСуммы = Новый Структура;
					СтруктураПересчетаСуммы.Вставить("ЦенаВключаетНДС", Истина);
					СтруктураДействий = Новый Структура;
					СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
					
					СуммаСтроки = Строка.Сумма;
					Если Строка.Сумма <= СуммаЗачетаПредоплаты Тогда
						Строка.ОбъектРасчетов = ОбъектРасчетовЗаказКлиента;
						Строка.ОснованиеПлатежа = ЗаказКлиента;
						СуммаЗачетаПредоплаты = СуммаЗачетаПредоплаты - СуммаСтроки;
					Иначе
						НоваяСтрока = ДокументПредоплатыОбъект.РасшифровкаПлатежа.Добавить();
						ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
						
						Если ТипЗнч(ДокументПредоплатыОбъект) = Тип("ДокументОбъект.ПриходныйКассовыйОрдер") 
							И НЕ ЗначениеЗаполнено(ДокументПредоплатыОбъект.ДокументОснование) Тогда
							ДокументПредоплатыОбъект.ДокументОснование = ЗаказКлиента;
						КонецЕсли;
						НоваяСтрока.ОбъектРасчетов = ОбъектРасчетовЗаказКлиента;
						НоваяСтрока.ОснованиеПлатежа = ЗаказКлиента;
						НоваяСтрока.Сумма = СуммаЗачетаПредоплаты;
						НоваяСтрока.СуммаВзаиморасчетов = СуммаЗачетаПредоплаты;
						
						Строка.Сумма = Строка.Сумма - СуммаЗачетаПредоплаты;
						Строка.СуммаВзаиморасчетов = Строка.СуммаВзаиморасчетов - СуммаЗачетаПредоплаты;
						
						ОбработкаТабличнойЧастиСервер.ОбработатьСтрокуТЧ(НоваяСтрока, СтруктураДействий, Неопределено);
						
						СуммаЗачетаПредоплаты = 0;
					КонецЕсли;
					
					ОбработкаТабличнойЧастиСервер.ОбработатьСтрокуТЧ(Строка, СтруктураДействий, Неопределено);
					
					Если СуммаЗачетаПредоплаты <= 0 Тогда
						Прервать;
					КонецЕсли;
					
				КонецЕсли;
			КонецЦикла;
			
			ДокументПредоплатыОбъект.Записать(РежимЗаписиДокумента.Проведение);
			
			МассивДокументовНаУдаление.Добавить(ДокументПредоплатыСсылка);
			
			Если СуммаЗачетаПредоплаты <= 0 Тогда
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		КСП_УдалитьЗаписиРСКСП_ДокументыПредоплатыЗаказаКлиента(МассивДокументовНаУдаление);
		РезультатПривязкиДокументов = Истина;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(
			"СозданиеДокументовОплатыПоСчетуНаОплатуКлиента.ИзменениеДокументовПредоплаты",
			УровеньЖурналаРегистрации.Ошибка,,
			ДокументПредоплатыСсылка,
			"Не удалось изменить документы оплаты по <" + Строка(ДокументПредоплатыОбъект) + ">" + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())
		);
		Возврат "Не удалось изменить документы оплаты по <" + Строка(ДокументПредоплатыОбъект) + ">";
	КонецПопытки;
	
	Возврат РезультатПривязкиДокументов
	
КонецФункции

Процедура КСП_УдалитьЗаписиРСКСП_ДокументыПредоплатыЗаказаКлиента(МассивДокументовНаУдаление)

	// Проверяем все ли документы нужно удалять из РС
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка КАК ДокументПредоплаты
		|ИЗ
		|	Документ.ПриходныйКассовыйОрдер.РасшифровкаПлатежа КАК ПриходныйКассовыйОрдерРасшифровкаПлатежа
		|ГДЕ
		|	ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка В (&МассивДокументовНаУдаление)
		|	И ПриходныйКассовыйОрдерРасшифровкаПлатежа.ОбъектРасчетов.Объект = ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка 
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходныйКассовыйОрдерРасшифровкаПлатежа.Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Ссылка
		|ИЗ
		|	Документ.ПоступлениеБезналичныхДенежныхСредств.РасшифровкаПлатежа КАК ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа
		|ГДЕ
		|	ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Ссылка В (&МассивДокументовНаУдаление)
		|	И ТИПЗНАЧЕНИЯ(ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.ОбъектРасчетов.Объект) = ТИП(Справочник.ОбъектыРасчетов) 
		|
		|СГРУППИРОВАТЬ ПО
		|	ПоступлениеБезналичныхДенежныхСредствРасшифровкаПлатежа.Ссылка";
	
	Запрос.УстановитьПараметр("МассивДокументовНаУдаление", МассивДокументовНаУдаление);
	
	ВыборкаДокументовНаОплату = Запрос.Выполнить().Выбрать();
	
	Пока ВыборкаДокументовНаОплату.Следующий() Цикл
		МассивДокументовНаУдаление.Удалить(ВыборкаДокументовНаОплату.ДокументПредоплаты);
	КонецЦикла;
	
	Для каждого ДокументПредоплаты Из МассивДокументовНаУдаление Цикл
		НаборЗаписей = РегистрыСведений.КСП_ДокументыПредоплатыЗаказаКлиента.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ДокументПредоплаты.Установить(ДокументПредоплаты);
		НаборЗаписей.Записать();
	КонецЦикла;
	
КонецПроцедуры

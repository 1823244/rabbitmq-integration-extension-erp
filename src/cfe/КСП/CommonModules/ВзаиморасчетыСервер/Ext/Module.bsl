﻿
&Вместо("ЗаполнитьРасшифровкуПлатежаПоСчетуНаОплату")
Процедура КСП_ЗаполнитьРасшифровкуПлатежаПоСчетуНаОплату(СчетНаОплату, Организация, ЗаказКлиента, ВалютаДокумента, РасшифровкаПлатежа)

	УстановитьПривилегированныйРежим(Истина);

	ОбъектРасчетов = ОбъектыРасчетовСервер.ПолучитьОбъектРасчетовПоСсылке(ЗаказКлиента);

	// Заполнение табличной части "Расшифровка платежа"
	ТекстЗапроса = "
	|ВЫБРАТЬ
	|	РасчетыСКлиентами.СчетНаОплату,
	|	СУММА(
	|		ВЫБОР КОГДА РасчетыСКлиентами.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Расход) ТОГДА
	|			РасчетыСКлиентами.Сумма
	|		ИНАЧЕ
	|			0
	|		КОНЕЦ
	|		) КАК СуммаОплаты
	|ПОМЕСТИТЬ ВтРасчетыПоСчету
	|ИЗ
	|	РегистрНакопления.РасчетыСКлиентами КАК РасчетыСКлиентами
	|ГДЕ
	|	РасчетыСКлиентами.Активность
	|	И РасчетыСКлиентами.СчетНаОплату = &СчетНаОплату
	|СГРУППИРОВАТЬ ПО
	|	РасчетыСКлиентами.СчетНаОплату
	|ИНДЕКСИРОВАТЬ ПО
	|	СчетНаОплату
	|;
	|
	|ВЫБРАТЬ
	|	ЕСТЬNULL(СУММА(Расчеты.КОплатеОстаток - Расчеты.ОплачиваетсяОстаток), 0) КАК СуммаВзаиморасчетов
	|ПОМЕСТИТЬ ВтРасчеты
	|ИЗ
	|	(ВЫБРАТЬ
	|		РасчетыСКлиентами.КОплатеОстаток      КАК КОплатеОстаток,
	|		0                                     КАК ОплачиваетсяОстаток
	|	ИЗ
	|		РегистрНакопления.РасчетыСКлиентамиПланОплат.Остатки(,ОбъектРасчетов = &ОбъектРасчетов) КАК РасчетыСКлиентами
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		РасчетыСКлиентами.ДолгОстаток         КАК КОплатеОстаток,
	|		0                                     КАК ОплачиваетсяОстаток
	|	ИЗ
	|		РегистрНакопления.РасчетыСКлиентамиПоСрокам.Остатки(,ОбъектРасчетов = &ОбъектРасчетов) КАК РасчетыСКлиентами
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		0                                     КАК КОплатеОстаток,
	|		РасчетыСКлиентами.ОплачиваетсяОстаток КАК ОплачиваетсяОстаток
	|	ИЗ
	|		РегистрНакопления.РасчетыСКлиентами.Остатки(,ОбъектРасчетов = &ОбъектРасчетов) КАК РасчетыСКлиентами) КАК Расчеты
	|;
	|
	|ВЫБРАТЬ
	|	СчетНаОплатуКлиенту.Ссылка КАК ОснованиеПлатежа,
	|	ОбъектыРасчетов.Ссылка КАК ОбъектРасчетов,
	|	ОбъектыРасчетов.Организация КАК Организация,
	|	СчетНаОплатуКлиенту.ДокументОснование.Партнер КАК Партнер,
	|	СчетНаОплатуКлиенту.ДокументОснование.Соглашение КАК Соглашение,
	|	
	|	ВЫБОР КОГДА СчетНаОплатуКлиенту.Договор.ПорядокРасчетов = ЗНАЧЕНИЕ(Перечисление.ПорядокРасчетов.ПоДоговорамКонтрагентов) ТОГДА
	|		СчетНаОплатуКлиенту.Договор.СтатьяДвиженияДенежныхСредств
	|	ИНАЧЕ
	|		ВЫБОР КОГДА ЕСТЬNULL(СчетНаОплатуКлиенту.Договор.СтатьяДвиженияДенежныхСредств, ЗНАЧЕНИЕ(Справочник.СтатьиДвиженияДенежныхСредств.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.СтатьиДвиженияДенежныхСредств.ПустаяСсылка) ТОГДА
	|			ВЫРАЗИТЬ(СчетНаОплатуКлиенту.ДокументОснование.Соглашение КАК Справочник.СоглашенияСКлиентами).СтатьяДвиженияДенежныхСредств
	|		ИНАЧЕ
	|			СчетНаОплатуКлиенту.Договор.СтатьяДвиженияДенежныхСредств
	|		КОНЕЦ
	|	КОНЕЦ КАК СтатьяДвиженияДенежныхСредств,
	|	
	|	ЕСТЬNULL(ОбъектыРасчетов.ВалютаВзаиморасчетов,
	|		ЕСТЬNULL(
	|			СчетНаОплатуКлиенту.ДокументОснование.ВалютаВзаиморасчетов, 
	|			СчетНаОплатуКлиенту.ДокументОснование.Валюта)
	|	) КАК ВалютаВзаиморасчетов,
	|	СчетНаОплатуКлиенту.Валюта КАК ВалютаСчета,
	|
	|	СчетНаОплатуКлиенту.СуммаДокумента КАК СуммаСчета,
	|	ЕСТЬNULL(РасчетыСКлиентамиОстатки.СуммаВзаиморасчетов, 0) КАК СуммаВзаиморасчетов,
	|	ЕСТЬNULL(РасчетыСКлиентами.СуммаОплаты, 0) КАК СуммаОплатыПоСчету,
	|
	|	СчетНаОплатуКлиенту.ДокументОснование ССЫЛКА Справочник.ДоговорыКонтрагентов
	|		ИЛИ ЕСТЬNULL(СчетНаОплатуКлиенту.Договор.ПорядокРасчетов = ЗНАЧЕНИЕ(Перечисление.ПорядокРасчетов.ПоДоговорамКонтрагентов), ЛОЖЬ) КАК ОплатаПоДоговору
	|	,СчетНаОплатуКлиенту.КСП_СуммаЗачетаПредоплаты КАК КСП_СуммаЗачетаПредоплаты
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	|	
	|	ЛЕВОЕ СОЕДИНЕНИЕ ВтРасчетыПоСчету КАК РасчетыСКлиентами
	|	ПО
	|		СчетНаОплатуКлиенту.Ссылка = РасчетыСКлиентами.СчетНаОплату
	|	
	|	ЛЕВОЕ СОЕДИНЕНИЕ
	|		ВтРасчеты КАК РасчетыСКлиентамиОстатки
	|	ПО
	|		ИСТИНА
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ОбъектыРасчетов КАК ОбъектыРасчетов
	|		ПО ВЫБОР КОГДА СчетНаОплатуКлиенту.Договор.ПорядокРасчетов = ЗНАЧЕНИЕ(Перечисление.ПорядокРасчетов.ПоДоговорамКонтрагентов) 
	|			ТОГДА СчетНаОплатуКлиенту.Договор
	|			ИНАЧЕ СчетНаОплатуКлиенту.ДокументОснование
	|		КОНЕЦ = ОбъектыРасчетов.Объект
	|		И ОбъектыРасчетов.ТипРасчетов = ЗНАЧЕНИЕ(Перечисление.ТипыРасчетовСПартнерами.РасчетыСКлиентом)
	|		
	|ГДЕ
	|	СчетНаОплатуКлиенту.Ссылка = &СчетНаОплату
	|";

	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("СчетНаОплату", СчетНаОплату);
	Запрос.УстановитьПараметр("ОбъектРасчетов", ОбъектРасчетов);

	СтатьяДДСПоХО = Справочники.СтатьиДвиженияДенежныхСредств.СтатьяДвиженияДенежныхСредствПоХозяйственнойОперации(Перечисления.ХозяйственныеОперации.ПоступлениеОплатыОтКлиента);

	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		НоваяСтрока = РасшифровкаПлатежа.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		Если Не ЗначениеЗаполнено(НоваяСтрока.СтатьяДвиженияДенежныхСредств) Тогда
			НоваяСтрока.СтатьяДвиженияДенежныхСредств = СтатьяДДСПоХО;
		КонецЕсли;

		// Счет может быть выставлен не в валюте взаииморасчетов,
		// поэтому нужно пересчитать его сумму в валюту взаиморасчетов,
		// чтобы сравнить с оплатами по счету и остатками расчетов
		СуммаСчетаВВалютеВзаиморасчетов = Выборка.СуммаСчета;
		Если Выборка.ВалютаСчета <> Выборка.ВалютаВзаиморасчетов Тогда
			Коэффициенты = РаботаСКурсамиВалютУТ.ПолучитьКоэффициентыПересчетаВалюты(Выборка.ВалютаСчета, Выборка.ВалютаВзаиморасчетов, ТекущаяДатаСеанса(), Выборка.Организация,,, ОбъектРасчетов);
			СуммаСчетаВВалютеВзаиморасчетов = Выборка.СуммаСчета * Коэффициенты.КоэффициентПересчетаВВалютуВзаиморасчетов;
		КонецЕсли;
		
		Если ТипЗнч(Выборка.ОбъектРасчетов.Объект) = Тип("ДокументСсылка.ЗаказКлиента")
			И ТипЗнч(Выборка.ОснованиеПлатежа) = Тип("ДокументСсылка.СчетНаОплатуКлиенту")
			И Выборка.КСП_СуммаЗачетаПредоплаты <> 0 Тогда
			Если Выборка.ОплатаПоДоговору Тогда
				СуммаВзаиморасчетов = СуммаСчетаВВалютеВзаиморасчетов - Выборка.СуммаОплатыПоСчету - Выборка.КСП_СуммаЗачетаПредоплаты;
			ИначеЕсли Выборка.СуммаВзаиморасчетов < СуммаСчетаВВалютеВзаиморасчетов Тогда
				СуммаВзаиморасчетов = Выборка.СуммаВзаиморасчетов - Выборка.КСП_СуммаЗачетаПредоплаты;
			ИначеЕсли СуммаСчетаВВалютеВзаиморасчетов > Выборка.СуммаОплатыПоСчету Тогда
				СуммаВзаиморасчетов = СуммаСчетаВВалютеВзаиморасчетов - Выборка.СуммаОплатыПоСчету - Выборка.КСП_СуммаЗачетаПредоплаты;
			Иначе
				СуммаВзаиморасчетов = 0;
			КонецЕсли;
		Иначе
			Если Выборка.ОплатаПоДоговору Тогда
				СуммаВзаиморасчетов = СуммаСчетаВВалютеВзаиморасчетов - Выборка.СуммаОплатыПоСчету;
			ИначеЕсли Выборка.СуммаВзаиморасчетов < СуммаСчетаВВалютеВзаиморасчетов Тогда
				СуммаВзаиморасчетов = Выборка.СуммаВзаиморасчетов;
			ИначеЕсли СуммаСчетаВВалютеВзаиморасчетов > Выборка.СуммаОплатыПоСчету Тогда
				СуммаВзаиморасчетов = СуммаСчетаВВалютеВзаиморасчетов - Выборка.СуммаОплатыПоСчету;
			Иначе
				СуммаВзаиморасчетов = 0;
			КонецЕсли;
		КонецЕсли;
		НоваяСтрока.СуммаВзаиморасчетов = СуммаВзаиморасчетов;

		Если СуммаВзаиморасчетов = СуммаСчетаВВалютеВзаиморасчетов
			И ВалютаДокумента = Выборка.ВалютаСчета Тогда
			НоваяСтрока.Сумма = Выборка.СуммаСчета;
		ИначеЕсли ВалютаДокумента = Выборка.ВалютаВзаиморасчетов Тогда
			НоваяСтрока.Сумма = СуммаВзаиморасчетов;
		Иначе
			Коэффициенты = РаботаСКурсамиВалютУТ.ПолучитьКоэффициентыПересчетаВалюты(ВалютаДокумента, Выборка.ВалютаВзаиморасчетов, ТекущаяДатаСеанса(), Выборка.Организация,,, ОбъектРасчетов);
			НоваяСтрока.Сумма = ?(Коэффициенты.КоэффициентПересчетаВВалютуВзаиморасчетов <> 0, СуммаВзаиморасчетов / Коэффициенты.КоэффициентПересчетаВВалютуВзаиморасчетов, 0);
		КонецЕсли;
	КонецЕсли;

	Если РасшифровкаПлатежа.Количество() = 0 Тогда
		НоваяСтрока = РасшифровкаПлатежа.Добавить();
		НоваяСтрока.СчетНаОплату = СчетНаОплату;
	КонецЕсли;

	ДенежныеСредстваСервер.ЗаполнитьНДСВРасшифровке(РасшифровкаПлатежа,
	ДенежныеСредстваСервер.РасшифровкаПлатежаНДС(Организация, ТекущаяДатаСеанса(), ВалютаДокумента, ОбъектРасчетов, Истина));
	
КонецПроцедуры

&Вместо("СостояниеВзаиморасчетовЗаказа")
// Добавил экспорт
Функция КСП_СостояниеВзаиморасчетовЗаказа(Заказ, ТипРасчетов) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Заказ", Заказ);
	Если ТипРасчетов = Перечисления.ТипыРасчетовСПартнерами.РасчетыСКлиентом Тогда
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	СостоянияЗаказовКлиентов.СуммаОплаты     КАК СуммаОплат,
			|	СостоянияЗаказовКлиентов.ПроцентОплаты   КАК ПроцентОплат,
			|	СостоянияЗаказовКлиентов.СуммаОтгрузки   КАК СуммаОтгрузок,
			|	СостоянияЗаказовКлиентов.ПроцентОтгрузки КАК ПроцентОтгрузок,
			|	СостоянияЗаказовКлиентов.СуммаДолга      КАК СуммаЗадолженности
			|ИЗ
			|	РегистрСведений.СостоянияЗаказовКлиентов КАК СостоянияЗаказовКлиентов
			|ГДЕ
			|	СостоянияЗаказовКлиентов.Заказ = &Заказ";
	Иначе
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	СостоянияЗаказовПоставщикам.СуммаОплаты        КАК СуммаОплат,
			|	СостоянияЗаказовПоставщикам.ПроцентОплаты      КАК ПроцентОплат,
			|	СостоянияЗаказовПоставщикам.СуммаПоступления   КАК СуммаПоставок,
			|	СостоянияЗаказовПоставщикам.ПроцентПоступления КАК ПроцентПоставок,
			|	СостоянияЗаказовПоставщикам.СуммаДолга         КАК СуммаЗадолженности
			|ИЗ
			|	РегистрСведений.СостоянияЗаказовПоставщикам КАК СостоянияЗаказовПоставщикам
			|ГДЕ
			|	СостоянияЗаказовПоставщикам.Заказ = &Заказ";
	КонецЕсли;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Результат = СтруктураСостоянияРасчетов();
		ЗаполнитьЗначенияСвойств(Результат, Выборка);
		Возврат Результат;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

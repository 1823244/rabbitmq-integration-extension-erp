﻿#Область КСП_ОбработчикиСобытийФормы

&НаСервере
&После("ПриЧтенииСозданииНаСервере")
Процедура КСП_ПриЧтенииСозданииНаСервере()
	
	КСП_ЗаполнитьСуммуПланаПродаж();
	
КонецПроцедуры

#КонецОбласти

#Область КСП_СлужебныеПроцедурыИФункции

&НаСервере
&После("ПартнерПриИзмененииСервер")
Процедура КСП_ПартнерПриИзмененииСервер()
	
	КСП_ЗаполнитьСуммуПланаПродаж();
	
КонецПроцедуры

&НаСервере
Процедура КСП_ЗаполнитьСуммуПланаПродаж()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КСП_ПланыПродажСрезПоследних.Коллекция КАК Коллекция,
		|	КСП_ПланыПродажСрезПоследних.Клиент КАК Клиент,
		|	КСП_ПланыПродажСрезПоследних.План КАК План
		|ИЗ
		|	РегистрСведений.КСП_ПланыПродаж.СрезПоследних(
		|			,
		|			Клиент = &Клиент
		|				И Коллекция = &Коллекция) КАК КСП_ПланыПродажСрезПоследних";
	
	Запрос.УстановитьПараметр("Клиент", Объект.Партнер);
	Запрос.УстановитьПараметр("Коллекция", Объект.КСП_Коллекция);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	КСП_ПланПродаж = 0;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		КСП_ПланПродаж = ВыборкаДетальныеЗаписи.План;
	КонецЦикла;
		
КонецПроцедуры

&НаСервере
Процедура КСП_ЗаполнитьКоллекцию(Знач Номенклатура)
	
	Объект.КСП_Коллекция = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Номенклатура, "КоллекцияНоменклатуры");
	КСП_ЗаполнитьСуммуПланаПродаж();
	
КонецПроцедуры

&НаКлиенте
Процедура КСП_КоллекцияПриИзмененииПосле(Элемент)
	
	КСП_ЗаполнитьСуммуПланаПродаж();

КонецПроцедуры

&НаСервере
&После("КонтрагентПриИзмененииСервер")
Процедура КСП_КонтрагентПриИзмененииСервер()
	
	КСП_ЗаполнитьСуммуПланаПродаж();	
	
КонецПроцедуры

&НаКлиенте
Процедура КСП_ТоварыНоменклатураПриИзмененииПосле(Элемент)

	ТекущаяСтрока = Элементы.Товары.ТекущиеДанные;
	
	Если НЕ ЗначениеЗаполнено(Объект.КСП_Коллекция) И ТекущаяСтрока <> Неопределено Тогда
		КСП_ЗаполнитьКоллекцию(ТекущаяСтрока.Номенклатура);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура КСП_ОбработкаПроверкиЗаполненияНаСервереПосле(Отказ, ПроверяемыеРеквизиты)
	
	ПроверкаКоллекцииТоваров(Отказ);
	
КонецПроцедуры

&НаСервере
Процедура ПроверкаКоллекцииТоваров(Отказ)
	
	Если НЕ ЗначениеЗаполнено(Объект.КСП_Коллекция) Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Номенклатура.Ссылка) КАК Представление,
		|	Номенклатура.Ссылка КАК Ссылка,
		|	Номенклатура.КоллекцияНоменклатуры КАК КоллекцияНоменклатуры
		|ИЗ
		|	Справочник.Номенклатура КАК Номенклатура
		|ГДЕ
		|	НЕ Номенклатура.КоллекцияНоменклатуры В ИЕРАРХИИ (&КоллекцияНоменклатуры)
		|	И Номенклатура.Ссылка В(&СписокНоменклатуры)";
	
	Запрос.УстановитьПараметр("КоллекцияНоменклатуры", Объект.КСП_Коллекция);
	Запрос.УстановитьПараметр("СписокНоменклатуры", Объект.Товары.Выгрузить().ВыгрузитьКолонку("Номенклатура"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ОбщегоНазначения.СообщитьПользователю(СтрШаблон("У номенклатуры: ""%1"" не соответствует коллекция по документу", ВыборкаДетальныеЗаписи.Представление),,,, Отказ);
	КонецЦикла;

КонецПроцедуры

&НаСервере
&Вместо("ТоварыВариантОбеспеченияПриИзмененииНаСервере")
Процедура КСП_ТоварыВариантОбеспеченияПриИзмененииНаСервере(ПараметрыЗаполнения)
	
	НужноПривязатьПредоплату = КСП_НужноПривязатьПредоплатуБезСчета();
	
	Если ТипЗнч(НужноПривязатьПредоплату) = Тип("Строка") Тогда
		ОбщегоНазначения.СообщитьПользователю("Не удалось изменить вариант обеспечения по причине" + Символы.ПС + НужноПривязатьПредоплату);
		Возврат;
	ИначеЕсли НужноПривязатьПредоплату = Истина Тогда
		Объект.Товары[Элементы.Товары.ТекущаяСтрока].КСП_НужноПривязатьПредоплатуБезСчета = Истина;
	КонецЕсли;
	
	Изменения = ОбеспечениеВДокументахСервер.ВариантОбеспеченияПриИзменении(
		ЭтотОбъект,
		Элементы.Товары.ТекущаяСтрока);
		
	Режим = ОбеспечениеВДокументахКлиентСервер.РежимВыборДействияНепосредственно();
	ПослеЗаполненияОбеспечения(Изменения, Режим, ПараметрыЗаполнения);
	
КонецПроцедуры

&НаСервере
Функция КСП_ПривязатьПредоплатуКЗаказу()

	РезультатПривязки = "";
	
	НачатьТранзакцию();
	Попытка
		
		
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
	КонецПопытки;
	
	Возврат РезультатПривязки;

КонецФункции

&НаСервере
Функция КСП_НужноПривязатьПредоплатуБезСчета()

	НужноПривязатьПредоплату = Ложь;
	
	// Получаем запрос при создании счета на полату
	Запрос = Новый Запрос;
	Запрос.Текст = КСП_СчетаНаОплату.КСП_ТекстЗапросаДанныхПоДокументу();
	
	Запрос.УстановитьПараметр("ДокументОснование", Объект.Ссылка);
	Запрос.УстановитьПараметр("ТекущаяДатаСеанса", ТекущаяДатаСеанса());
	
	// Выгружаем таблицы для получения суммы текущего платежа и суммы остатка предоплаты
	МассивРезультатов	= Запрос.ВыполнитьПакет();
	ТаблицаТоваров		= МассивРезультатов[1].Выгрузить();
	ВыборкаОплата		= МассивРезультатов[4].Выбрать();
	
	// Выбираем сумму предоплаты
	Если ВыборкаОплата.Следующий() Тогда
		СуммаОстатокПредоплаты = ВыборкаОплата.СуммаОстатокПредоплаты;
	КонецЕсли;
	
	// Если Сумма текущего платежа и сумма предоплаты равны счет не создаем, а устанавливаем признак привязки предоплаты к заказу при проведении
	Если ТаблицаТоваров.Итог("СуммаКОплате") = СуммаОстатокПредоплаты Тогда
		НужноПривязатьПредоплату = Истина;
	КонецЕсли;
	
	Возврат НужноПривязатьПредоплату;

КонецФункции

#КонецОбласти

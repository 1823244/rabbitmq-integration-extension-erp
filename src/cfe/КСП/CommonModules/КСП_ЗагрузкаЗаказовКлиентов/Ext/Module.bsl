﻿&НаКлиенте
Процедура ЗагрузитьФайлыИзКаталога(ИмяКаталога) Экспорт
	
	НайденныеФайлы = НайтиФайлы(ИмяКаталога, ".xlsx", Истина);
	Для каждого текФайл Из НайденныеФайлы Цикл
		ДвоичДанные = Новый ДвоичныеДанные(текФайл.Имя);
		КСП_ЗагрузкаЗаказовКлиентов.ЗагрузкаЗаказа(ДвоичДанные, текФайл.Расширение);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузкаЗаказа(ДвоичДанные, Расширение) Экспорт

	ИмяФайла = ПолучитьИмяВременногоФайла(Расширение);
	ДвоичДанные.Записать(ИмяФайла);
	
	Заказ = Документы.ЗаказКлиента.СоздатьДокумент();
	Заказ.Дата = ТекущаяДата();
	Заказ.Статус = Перечисления.СтатусыЗаказовКлиентов.НеСогласован;
	Заказ.Приоритет = Справочники.Приоритеты.НайтиПоНаименованию("Средний");
	Попытка
		Эксель = Новый COMОбъект("Excel.Application");
		Эксель.DisplayAlerts = 0;
		Эксель.Visible = 0;
	Исключение
   		Возврат;
	КонецПопытки;
	
	ЭксельКнига = Эксель.Workbooks.Open(ИмяФайла);	
	КоличествоСтраниц = 1;
	
	Для НомерЛиста = 1 По КоличествоСтраниц Цикл 
		Лист = ЭксельКнига.Sheets(НомерЛиста);
		КоличествоСтрок = Лист.Cells(1, 1).SpecialCells(11).Row;
		КоличествоКолонок = Лист.Cells(1, 1).SpecialCells(11).Column;
		Если ЗначениеЗаполнено(Лист.Cells(6, 7).Value) Тогда
			Заказ.КСП_Коллекция = Справочники.КоллекцииНоменклатуры.НайтиПоНаименованию(Лист.Cells(6, 7).Value);
		КонецЕсли;
		Если ЗначениеЗаполнено(Лист.Cells(4, 7).Value) Тогда
			Заказ.Контрагент = Справочники.Контрагенты.НайтиПоНаименованию(Лист.Cells(4, 7).Value);
		КонецЕсли;

        МассивРазмеров = Новый Массив;
		Для НомерКолонки = 11 По 19 Цикл
			МассивРазмеров.Добавить(Лист.Cells(10, НомерКолонки).Value);
		КонецЦикла;
		Для НомерСтроки = 13 По КоличествоСтрок Цикл
			Если ЗначениеЗаполнено(Лист.Cells(НомерСтроки, 4).Value) Тогда
				Для НомерКолонки = 11 По 19 Цикл
					Если ЗначениеЗаполнено(Лист.Cells(НомерСтроки, НомерКолонки).Value) Тогда 
						Нстр = Заказ.Товары.Добавить();
						НаименованиеТовара = Лист.Cells(НомерСтроки, 4).Value;
						Модель = Лист.Cells(НомерСтроки, 5).Value;
						Цвет = Лист.Cells(НомерСтроки, 7).Value;
		
						Запрос = Новый Запрос;
						Запрос.Текст = 
							"ВЫБРАТЬ
							|	Номенклатура.Ссылка КАК Ссылка,
							|	ХарактеристикиНоменклатуры.Ссылка КАК Ссылка1,
							|	Номенклатура.Наименование КАК Наименование
							|ИЗ
							|	Справочник.Номенклатура КАК Номенклатура
							|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры
							|		ПО Номенклатура.Ссылка = ХарактеристикиНоменклатуры.Владелец
							|ГДЕ
							|	Номенклатура.Наименование ПОДОБНО ""%"" + &Бренд + ""%""";
						Запрос.УстановитьПараметр("Бренд", НаименованиеТовара);
						Запрос.УстановитьПараметр("Размер", МассивРазмеров[НомерКолонки - 11]);
						
						РезультатЗапроса = Запрос.Выполнить();
						
						ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
						
						Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
							Если СтрНайти(ВыборкаДетальныеЗаписи.Наименование, Модель) И СтрНайти(ВыборкаДетальныеЗаписи.Наименование, Цвет) Тогда
								Нстр.Номенклатура = ВыборкаДетальныеЗаписи.Ссылка;
								поискХарактеристики = "-" + СокрЛП(МассивРазмеров[НомерКолонки - 11] + "-");
								Если СтрНайти(ВыборкаДетальныеЗаписи.Ссылка1, поискХарактеристики) > 0 Тогда
									Нстр.Характеристика = ВыборкаДетальныеЗаписи.Ссылка1;
								КонецЕсли;
							КонецЕсли;
						КонецЦикла;

	//					Если ЗначениеЗаполнено(ТекТовар) Тогда
	//						Нстр.Номенклатура	= ТекТовар;
	//						Нстр.Характеристика = текХарактеристика;
	//
	//						Запрос = Новый Запрос;
	//						Запрос.Текст = 
	//							"ВЫБРАТЬ
	//							|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена
	//							|ИЗ
	//							|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних КАК ЦеныНоменклатурыСрезПоследних
	//							|ГДЕ
	//							|	ЦеныНоменклатурыСрезПоследних.Номенклатура = &Номенклатура";
	//						
	//						Запрос.УстановитьПараметр("Номенклатура", ТекТовар);
	//						
	//						РезультатЗапроса = Запрос.Выполнить();
	//						
	//						ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	//						
	//						Если ВыборкаДетальныеЗаписи.Следующий() Тогда
	//							Нстр.КСП_БазоваяЦена = ВыборкаДетальныеЗаписи.Цена;
	//						КонецЕсли;
	//
	//					КонецЕсли;
						Нстр.КоличествоУпаковок	= Лист.Cells(НомерСтроки, НомерКолонки).Value;
						Нстр.Цена = Лист.Cells(НомерСтроки, 21).Value;
						Нстр.Сумма = Нстр.КоличествоУпаковок * Нстр.Цена;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;	 
	
	Заказ.Записать(РежимЗаписиДокумента.Запись);
	Эксель.Workbooks.Close();
	Эксель.Application.Quit();

	НоваяЗапись = РегистрыСведений.КСП_СведенияОФайлахЗагрузкиЗаказовКлиента.СоздатьМенеджерЗаписи();
	НоваяЗапись.Период = ТекущаяДата();
	НоваяЗапись.Файл = ИмяФайла;
	НоваяЗапись.Заказ = Заказ.Ссылка;
	НоваяЗапись.Режим = Перечисления.КСП_РежимыЗагрузкиФайловЗаказа.Вручную;
	НоваяЗапись.Записать();
КонецПроцедуры
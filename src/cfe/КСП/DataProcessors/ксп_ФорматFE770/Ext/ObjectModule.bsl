﻿Перем лог;
Перем РаспознаноПозиций;
Перем КоличествоОшибок;


// Точка входа
Функция ЗагрузкаДанныхКМНаФулфилменте_FE770(ЧтениеXML, ПолноеИмяФайла, ИмяФайла, пЛог) Экспорт
	
	лог = пЛог;
	
	НастройкиФФ = ОбменСФулфилментСервер.ПолучитьНастройкиФулфилментДляТекущейБазы();
	
	URIПространстваИмен = "http://service.profashionsolutions.ru/fe770";
	ТипОбъекта_labelsRequest = ФабрикаXDTO.тип(URIПространстваИмен, "labelsRequest");
		
	Попытка
		
		labelsRequest = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, ТипОбъекта_labelsRequest);
		ЧтениеXML.Закрыть();
		labelsRequest.Проверить();
		
	Исключение
		Сообщение  = СтрШаблон("Ошибка чтения XML фабрикой XDTO. Причина: %1", ОписаниеОшибки());
		ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
		Возврат ложь;
	КонецПопытки;
	
	РаспознаноПозиций = 0;
	КоличествоОшибок  = 0;	
	
	//ЕНС
	ТаблицаДанных = ПолучитьКодыМаркировкиИзXML(labelsRequest);	
	
	//ЕНС
	РезультатЗапроса = ВыполнитьЗапрос(ИмяФайла, ТаблицаДанных, НастройкиФФ);
	
	//ЕНС
	СоздатьОбновитьДокументы(РезультатЗапроса, ПолноеИмяФайла);
	
	ТекстСообщения = СтрШаблон("Завершили загрузку данных КМ. 
						|Распознано строк %1. Количество ошибок при загрузке: %2",
					РаспознаноПозиций, 
					КоличествоОшибок);
					
	ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, ТекстСообщения);
					
	Возврат КоличествоОшибок = 0; 
	
КонецФункции


// Заполняет таблицу ТаблицаДанных и возвращает ее
//
// Параметры:
//	labelsRequest 	- ОбъектXDTO - 
//
Функция ПолучитьКодыМаркировкиИзXML(labelsRequest) Экспорт

	ТаблицаДанных = _ТаблицаДанных();	
	
	СоответствиеСтатусовОплаты = Новый Соответствие;
	СоответствиеСтатусовОплаты.Вставить("PaidUp", "Оплачен");
	СоответствиеСтатусовОплаты.Вставить("NotPaid", "Не оплачен");
	
	СоответствиеТиповВозврата = Новый Соответствие;
	СоответствиеТиповВозврата.Вставить("client", "Клиентский возврат");
	СоответствиеТиповВозврата.Вставить("postal", "Почтовый возврат");
	СоответствиеТиповВозврата.Вставить("partial", "Частичный возврат");
	
	
	Для каждого ctLabel Из labelsRequest.labels Цикл
		
		Попытка
			
			Если ТипЗнч(ctLabel.operationDate) = Тип("Дата") Тогда
				ДатаСобытия = ctLabel.operationDate;
			Иначе	
				ОписаниеОшибки = "";
				ДатаСобытия = ОбменСФулфилментСервер.ПолучитьДатуИзСтрокиФомата_XSD_duration(ctLabel.operationDate, ОписаниеОшибки);
				Если ДатаСобытия = Неопределено Тогда
					Сообщение  = СтрШаблон("Ошибка чтения даты события (%1). Причина: %2", ctLabel.operationDate, ОписаниеОшибки);
					ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
					КоличествоОшибок = КоличествоОшибок + 1;
					Продолжить;
				КонецЕсли;
			КонецЕсли;	
			
			ДокументДата = Неопределено;
			ДокументНомер = Неопределено;
			ДокументНаименование = Неопределено;
			
			Если Не ctLabel.document = Неопределено Тогда
				
				Если Не ctLabel.document.Свойства().Получить("date") = Неопределено Тогда
					Если ТипЗнч(ctLabel.document.date) = Тип("Дата") Тогда
						ДокументДата = ctLabel.document.date;
					Иначе	
						ДокументДата = ОбменСФулфилментСервер.ПолучитьДатуИзСтрокиФомата_XSD_duration(ctLabel.document.date, ОписаниеОшибки);
						Если ДокументДата = Неопределено Тогда
							Сообщение  = СтрШаблон("Ошибка чтения даты документа (%1). Причина: %2", ctLabel.document.date, ОписаниеОшибки);
							ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
							КоличествоОшибок = КоличествоОшибок + 1;
							Продолжить;
						КонецЕсли;
					КонецЕсли;	
				КонецЕсли;	
				
				Если Не ctLabel.document.Свойства().Получить("number") = Неопределено Тогда
					ДокументНомер = ctLabel.document.number;
				КонецЕсли;	
				
				Если Не ctLabel.document.Свойства().Получить("name") = Неопределено Тогда
					ДокументНаименование = ctLabel.document.name;
				КонецЕсли;	
				
			КонецЕсли;	
			
			ЗаказДата = Неопределено;
			ЗаказНомер = Неопределено;
			
			Если Не ctLabel.order = Неопределено Тогда
				
				Если Не ctLabel.order.Свойства().Получить("date") = Неопределено Тогда
					Если ТипЗнч(ctLabel.order.date) = Тип("Дата") Тогда
						ЗаказДата = ctLabel.order.date;
					Иначе	
						ЗаказДата = ОбменСФулфилментСервер.ПолучитьДатуИзСтрокиФомата_XSD_duration(ctLabel.order.date, ОписаниеОшибки);
						Если ДокументДата = Неопределено Тогда
							Сообщение  = СтрШаблон("Ошибка чтения даты заказа (%1). Причина: %2", ctLabel.order.date, ОписаниеОшибки);
							ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
							КоличествоОшибок = КоличествоОшибок + 1;
							Продолжить;
						КонецЕсли;
					КонецЕсли;	
				КонецЕсли;		
				
				Если Не ctLabel.order.Свойства().Получить("number") = Неопределено Тогда
					ЗаказНомер = ctLabel.order.number;
				КонецЕсли;	
				
			КонецЕсли;	
			
			СтрокаДанных = ТаблицаДанных.Добавить();
			
			СтрокаДанных.КодМаркировки = ОбменСФулфилментСервер.ПолучитьСтрокуСПреобразованиемЭкранированныхСимволов(ctLabel.labelCode);			
			СтрокаДанных.КодМаркировкиДляПоиска = СтрокаДанных.КодМаркировки;
			Если Лев(СтрокаДанных.КодМаркировкиДляПоиска, 4) = "(01)" Тогда
				СтрокаДанных.КодМаркировкиДляПоиска = Сред(СтрокаДанных.КодМаркировкиДляПоиска, 1, 18) + Сред(СтрокаДанных.КодМаркировкиДляПоиска, 23);
				СтрокаДанных.КодМаркировкиДляПоиска = Прав(СтрокаДанных.КодМаркировкиДляПоиска, СтрДлина(СтрокаДанных.КодМаркировкиДляПоиска) - 4);
			КонецЕсли;
			Если Лев(СтрокаДанных.КодМаркировкиДляПоиска, 2) = "01" Тогда
				СтрокаДанных.КодМаркировкиДляПоиска = Сред(СтрокаДанных.КодМаркировкиДляПоиска, 1, 16) + Сред(СтрокаДанных.КодМаркировкиДляПоиска, 19);
				СтрокаДанных.КодМаркировкиДляПоиска = Прав(СтрокаДанных.КодМаркировкиДляПоиска, СтрДлина(СтрокаДанных.КодМаркировкиДляПоиска) - 2);
			КонецЕсли;
			
			СтрокаДанных.ВидОперации = ?(ctLabel.operationType = 1, Перечисления.ВидыДвиженийКМФулфилмент.ВыводИзОборота, Перечисления.ВидыДвиженийКМФулфилмент.ВозвратВОборот);
			СтрокаДанных.ДатаСобытия = ДатаСобытия;
			
			СтрокаДанных.ДокументНаименование = ДокументНаименование;
			СтрокаДанных.ДокументНомер = ДокументНомер;
			СтрокаДанных.ДокументДата = ДокументДата;
			
			СтрокаДанных.НоменклатураНаименование = ctLabel.item.name;
			Если Не ctLabel.item.Свойства().Получить("item_uuid") = Неопределено Тогда
				НоменклатураСсылка = Справочники.Номенклатура.ПолучитьСсылку(новый УникальныйИдентификатор(ctLabel.item.item_uuid));
				Если ОбщегоНазначения.СсылкаСуществует(НоменклатураСсылка) Тогда
					СтрокаДанных.НоменклатураСсылка = НоменклатураСсылка;
				КонецЕсли;	
			КонецЕсли;	
			
			СтрокаДанных.ХарактеристикаНаименование = ctLabel.item.size;
			Если Не ctLabel.item.Свойства().Получить("size_uuid") = Неопределено Тогда
				ХарактеристикаСсылка = Справочники.ХарактеристикиНоменклатуры.ПолучитьСсылку(новый УникальныйИдентификатор(ctLabel.item.size_uuid));
				Если ОбщегоНазначения.СсылкаСуществует(ХарактеристикаСсылка) Тогда
					СтрокаДанных.ХарактеристикаСсылка = ХарактеристикаСсылка;
				КонецЕсли;	
			КонецЕсли;	
			
			СтрокаДанных.Штрихкод = ctLabel.item.ean;
			
			Если Не ctLabel.item.Свойства().Получить("price") = Неопределено Тогда
				СтрокаДанных.Цена = ctLabel.item.price;
			КонецЕсли;	
						
			СтрокаДанных.ЗаказНомер = ЗаказНомер;
			СтрокаДанных.ЗаказДата = ЗаказДата;
			
			Если Не ctLabel.Свойства().Получить("paymentStatus") = Неопределено Тогда
				СтатусОплаты = СоответствиеСтатусовОплаты.Получить(ctLabel.paymentStatus);
				Если СтатусОплаты = Неопределено Тогда
					СтрокаДанных.СтатусОплаты = ctLabel.paymentStatus;
				Иначе
					СтрокаДанных.СтатусОплаты = СтатусОплаты;
				КонецЕсли;	
			КонецЕсли;		
			
			Если Не ctLabel.Свойства().Получить("parcelNumber") = Неопределено Тогда				
				СтрокаДанных.НомерПосылки = ctLabel.parcelNumber;
			КонецЕсли;	
			
			Если Не ctLabel.Свойства().Получить("returnType") = Неопределено Тогда				
				ТипВозврата = СоответствиеТиповВозврата.Получить(ctLabel.returnType);
				Если ТипВозврата = Неопределено Тогда
					СтрокаДанных.ТипВозврата = ctLabel.returnType;
				Иначе
					СтрокаДанных.ТипВозврата = ТипВозврата;
				КонецЕсли;				
			КонецЕсли;	
				
		Исключение
			ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()), "ERR");
			КоличествоОшибок = КоличествоОшибок + 1;
		КонецПопытки;
	
	КонецЦикла;	
	
	Возврат ТаблицаДанных;
		
КонецФункции


// Запрос ищет объекты в базе по данным из XML-файла
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ВыполнитьЗапрос(ИмяФайла, ТаблицаДанных, НастройкиФФ)

	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ТаблицаДанных.КодМаркировки,
	|	ТаблицаДанных.КодМаркировкиДляПоиска,
	|	ТаблицаДанных.ВидОперации,
	|	ТаблицаДанных.ДатаСобытия,
	|	ТаблицаДанных.ДокументНаименование,
	|	ТаблицаДанных.ДокументНомер,
	|	ТаблицаДанных.ДокументДата,
	|	ТаблицаДанных.НоменклатураНаименование,
	|	ТаблицаДанных.НоменклатураСсылка,
	|	ТаблицаДанных.ХарактеристикаНаименование,
	|	ТаблицаДанных.ХарактеристикаСсылка,
	|	ТаблицаДанных.Штрихкод,
	|	ТаблицаДанных.Цена,
	|	ТаблицаДанных.ЗаказНомер,
	|	ТаблицаДанных.ЗаказДата,
	|	ТаблицаДанных.СтатусОплаты,
	|	ТаблицаДанных.НомерПосылки,
	|	ТаблицаДанных.ТипВозврата
	|ПОМЕСТИТЬ ТаблицаДанных_Предварительно
	|ИЗ
	|	&ТаблицаДанных КАК ТаблицаДанных
	|;
	|       
	//ЕНС. Уберу штрихкоды
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ТаблицаДанных.КодМаркировки,
	|	ТаблицаДанных.КодМаркировкиДляПоиска,
	|	ТаблицаДанных.ВидОперации,
	|	ТаблицаДанных.ДатаСобытия,
	|	ТаблицаДанных.ДокументНаименование,
	|	ТаблицаДанных.ДокументНомер,
	|	ТаблицаДанных.ДокументДата,
	|	ТаблицаДанных.НоменклатураНаименование,
	|	ТаблицаДанных.НоменклатураСсылка,
	|	ТаблицаДанных.ХарактеристикаНаименование,
	|	ТаблицаДанных.ХарактеристикаСсылка,
	|	"""" КАК Штрихкод,
	|	ТаблицаДанных.Цена,
	|	ТаблицаДанных.ЗаказНомер,
	|	ТаблицаДанных.ЗаказДата,
	|	ТаблицаДанных.СтатусОплаты,
	|	ТаблицаДанных.НомерПосылки,
	|	ТаблицаДанных.ТипВозврата
	|ПОМЕСТИТЬ ТаблицаДанных
	|ИЗ
	|	ТаблицаДанных_Предварительно КАК ТаблицаДанных
	|;
	|
	
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаДанных.КодМаркировки,
	|	ТаблицаДанных.КодМаркировкиДляПоиска,
	|	ВЫБОР
	|		КОГДА ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|			ТОГДА ЕСТЬNULL(ДанныеПоКМ.Номенклатура, ТаблицаДанных.НоменклатураСсылка)
	|		ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|	КОНЕЦ КАК НоменклатураСсылка,
	|	ВЫБОР
	|		КОГДА ТаблицаДанных.ХарактеристикаСсылка = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)
	|			ТОГДА ЕСТЬNULL(ДанныеПоКМ.Характеристика, ТаблицаДанных.ХарактеристикаСсылка)
	|		ИНАЧЕ ТаблицаДанных.ХарактеристикаСсылка
	|	КОНЕЦ КАК ХарактеристикаСсылка


	|ПОМЕСТИТЬ СопоставлениеПоКодамМаркировки


	|ИЗ
	|	ТаблицаДанных КАК ТаблицаДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ДанныеПоКМ
	|		ПО (ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|				ИЛИ ТаблицаДанных.ХарактеристикаСсылка = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка))
	|			И ТаблицаДанных.КодМаркировкиДляПоиска = ДанныеПоКМ.Штрихкод
	|ГДЕ
	|	НЕ ВЫБОР
	|		КОГДА ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|		ТОГДА ЕСТЬNULL(ДанныеПоКМ.Номенклатура, ТаблицаДанных.НоменклатураСсылка)
	|		ИНАЧЕ ТаблицаДанных.НоменклатураСсылка			КОНЕЦ = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|
	|СГРУППИРОВАТЬ ПО
	|ТаблицаДанных.КодМаркировки,
	|ТаблицаДанных.КодМаркировкиДляПоиска,
	|ВЫБОР
	|	КОГДА ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|		ТОГДА ЕСТЬNULL(ДанныеПоКМ.Номенклатура, ТаблицаДанных.НоменклатураСсылка)
	|	ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|КОНЕЦ,
	|ВЫБОР
	|	КОГДА ТаблицаДанных.ХарактеристикаСсылка = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)
	|		ТОГДА ЕСТЬNULL(ДанныеПоКМ.Характеристика, ТаблицаДанных.ХарактеристикаСсылка)
	|	ИНАЧЕ ТаблицаДанных.ХарактеристикаСсылка
	|КОНЕЦ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СопоставлениеПоКодамМаркировки.КодМаркировки,
	|	СопоставлениеПоКодамМаркировки.КодМаркировкиДляПоиска,
	|	СопоставлениеПоКодамМаркировки.НоменклатураСсылка,
	|	СопоставлениеПоКодамМаркировки.ХарактеристикаСсылка
	|ПОМЕСТИТЬ СопоставлениеПоШтрихкодам
	|ИЗ
	|	СопоставлениеПоКодамМаркировки КАК СопоставлениеПоКодамМаркировки
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ТаблицаДанных.КодМаркировки,
	|	ТаблицаДанных.КодМаркировкиДляПоиска,
	|	ВЫБОР
	|		КОГДА ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|			ТОГДА ЕСТЬNULL(ДанныеПоШК.Номенклатура, ТаблицаДанных.НоменклатураСсылка)
	|		ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|	КОНЕЦ,
	|	ВЫБОР
	|		КОГДА ТаблицаДанных.ХарактеристикаСсылка = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)
	|			ТОГДА ЕСТЬNULL(ДанныеПоШК.Характеристика, ТаблицаДанных.ХарактеристикаСсылка)
	|		ИНАЧЕ ТаблицаДанных.ХарактеристикаСсылка
	|	КОНЕЦ
	|ИЗ
	|	ТаблицаДанных КАК ТаблицаДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ДанныеПоШК
	|		ПО (ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|				ИЛИ ТаблицаДанных.ХарактеристикаСсылка = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка))
	|			И ТаблицаДанных.Штрихкод = ДанныеПоШК.Штрихкод
	|		ЛЕВОЕ СОЕДИНЕНИЕ СопоставлениеПоКодамМаркировки КАК СопоставлениеПоКодамМаркировки
	|		ПО ТаблицаДанных.КодМаркировки = СопоставлениеПоКодамМаркировки.КодМаркировки
	|ГДЕ
	|	СопоставлениеПоКодамМаркировки.НоменклатураСсылка ЕСТЬ NULL
	|	И НЕ ВЫБОР
	|				КОГДА ТаблицаДанных.НоменклатураСсылка = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|					ТОГДА ЕСТЬNULL(ДанныеПоШК.Номенклатура, ТаблицаДанных.НоменклатураСсылка)
	|				ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|			КОНЕЦ = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СопоставлениеПоШтрихкодам.КодМаркировки,
	|	СопоставлениеПоШтрихкодам.КодМаркировкиДляПоиска,
	|	МАКСИМУМ(СопоставлениеПоШтрихкодам.НоменклатураСсылка) КАК НоменклатураСсылка,
	|	МАКСИМУМ(СопоставлениеПоШтрихкодам.ХарактеристикаСсылка) КАК ХарактеристикаСсылка,
	|	КОЛИЧЕСТВО(СопоставлениеПоШтрихкодам.НоменклатураСсылка) КАК КоличествоЗаписей
	|ПОМЕСТИТЬ ДанныеПоШтрихкодам
	|ИЗ
	|	СопоставлениеПоШтрихкодам КАК СопоставлениеПоШтрихкодам
	|
	|СГРУППИРОВАТЬ ПО
	|	СопоставлениеПоШтрихкодам.КодМаркировки,
	|	СопоставлениеПоШтрихкодам.КодМаркировкиДляПоиска
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	&ИмяФайла КАК ИмяФайла,
	|	ТаблицаДанных.КодМаркировки,
	|	ТаблицаДанных.КодМаркировкиДляПоиска,
	|	ТаблицаДанных.ВидОперации КАК ВидОперации,
	|	ТаблицаДанных.ДатаСобытия,
	|	ТаблицаДанных.ДокументНаименование,
	|	ТаблицаДанных.ДокументНомер,
	|	ТаблицаДанных.ДокументДата,
	|	ТаблицаДанных.НоменклатураНаименование,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ДанныеПоШтрихкодам.КоличествоЗаписей, 0) = 1
	|			ТОГДА ДанныеПоШтрихкодам.НоменклатураСсылка
	|		ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|	КОНЕЦ КАК Номенклатура,
	|	ТаблицаДанных.ХарактеристикаНаименование,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ДанныеПоШтрихкодам.КоличествоЗаписей, 0) = 1
	|			ТОГДА ДанныеПоШтрихкодам.ХарактеристикаСсылка
	|		ИНАЧЕ ТаблицаДанных.ХарактеристикаСсылка
	|	КОНЕЦ КАК ХарактеристикаНоменклатуры,
	
	//ЕНС
	//|	ВЫБОР
	//|		КОГДА ЕСТЬNULL(СправочникНоменклатура.ВидНоменклатуры, ЗНАЧЕНИЕ(Справочник.ВидыНоменклатуры.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.ВидыНоменклатуры.Одежда)
	//|			ТОГДА ЗНАЧЕНИЕ(Перечисление.ВидыПродукцииИС.ЛегкаяПромышленность)
	//|		ИНАЧЕ ЗНАЧЕНИЕ(Перечисление.ВидыПродукцииИС.Обувь)
	//|	КОНЕЦ КАК ВидПродукции,
	|	Неопределено КАК ВидПродукции,
	
	|	ТаблицаДанных.Штрихкод,
	|	ТаблицаДанных.Цена,
	//ЕНС
	//|	ЕСТЬNULL(ЗаказИнтернетМагазина.Ссылка, ЗНАЧЕНИЕ(Документ.ЗаказИнтернетМагазина.ПустаяСсылка)) КАК Заказ,
	|	ЕСТЬNULL(ЗаказыКлиентов.Ссылка, ЗНАЧЕНИЕ(Документ.ЗаказКлиента.ПустаяСсылка)) КАК Заказ,
	|	ТаблицаДанных.ЗаказНомер КАК НомерЗаказа,
	|	ТаблицаДанных.ЗаказДата КАК ДатаЗаказа,
	|	ТаблицаДанных.СтатусОплаты,
	|	ТаблицаДанных.НомерПосылки,
	|	ТаблицаДанных.ТипВозврата,
	|	1 КАК Количество,
	|	ЕСТЬNULL(ДанныеПоШтрихкодам.КоличествоЗаписей, 0) КАК КоличествоЗаписейШК,
	|	ЕСТЬNULL(ДвиженияКМФулфилмент.Ссылка, ЗНАЧЕНИЕ(Документ.ДвиженияКМФулфилмент.ПустаяСсылка)) КАК ДокументСсылка,
	|	&Организация КАК Организация,
	|	СправочникНоменклатура.СтавкаНДС
	|ИЗ
	|	ТаблицаДанных КАК ТаблицаДанных
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДанныеПоШтрихкодам КАК ДанныеПоШтрихкодам
	|		ПО ТаблицаДанных.КодМаркировки = ДанныеПоШтрихкодам.КодМаркировки

	//ЕНС
	//|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказИнтернетМагазина КАК ЗаказИнтернетМагазина
	//|		ПО ТаблицаДанных.ЗаказНомер = ЗаказИнтернетМагазина.НомерЗаказа
	//|			И (НАЧАЛОПЕРИОДА(ТаблицаДанных.ЗаказДата, ДЕНЬ) = НАЧАЛОПЕРИОДА(ЗаказИнтернетМагазина.Дата, ДЕНЬ))
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказыКлиентов
	|		ПО ТаблицаДанных.ЗаказНомер = ЗаказыКлиентов.НомерПоДаннымКлиента
	|			И (НАЧАЛОПЕРИОДА(ТаблицаДанных.ЗаказДата, ДЕНЬ) = НАЧАЛОПЕРИОДА(ЗаказыКлиентов.ДатаПоДаннымКлиента, ДЕНЬ))
	
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СправочникНоменклатура
	|		ПО (ВЫБОР
	|				КОГДА ЕСТЬNULL(ДанныеПоШтрихкодам.КоличествоЗаписей, 0) = 1
	|					ТОГДА ДанныеПоШтрихкодам.НоменклатураСсылка
	|				ИНАЧЕ ТаблицаДанных.НоменклатураСсылка
	|			КОНЕЦ = СправочникНоменклатура.Ссылка)
	
	
	//		JOIN     Документ     ДвиженияКМФулфилмент
	
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ДвиженияКМФулфилмент КАК ДвиженияКМФулфилмент
	|		ПО (ДвиженияКМФулфилмент.ИмяФайла = &ИмяФайла)
	|			И ТаблицаДанных.ВидОперации = ДвиженияКМФулфилмент.ВидОперации
	//ЕНС. это проще совсем отключить
	//|			И (ВЫБОР
	//|				КОГДА ЕСТЬNULL(СправочникНоменклатура.ВидНоменклатуры, ЗНАЧЕНИЕ(Справочник.ВидыНоменклатуры.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.ВидыНоменклатуры.Одежда)
	//|					ТОГДА ЗНАЧЕНИЕ(Перечисление.ВидыПродукцииИС.ЛегкаяПромышленность)
	//|				ИНАЧЕ ЗНАЧЕНИЕ(Перечисление.ВидыПродукцииИС.Обувь)
	//|			КОНЕЦ = ДвиженияКМФулфилмент.ВидПродукции)
	
	// ЕНС. в локальной базе у меня нет ссылок на заказы, поэтому поменяю на НомерЗаказа(строка)  и ДатаЗаказа (дата)
	//|			И (ЕСТЬNULL(ЗаказыКлиентов.Ссылка, ЗНАЧЕНИЕ(Документ.ЗаказКлиента.ПустаяСсылка)) = ДвиженияКМФулфилмент.Заказ)
	|			И ТаблицаДанных.ЗаказНомер = ДвиженияКМФулфилмент.НомерЗаказа
	|			И НАЧАЛОПЕРИОДА(ТаблицаДанных.ЗаказДата, ДЕНЬ) = НАЧАЛОПЕРИОДА(ДвиженияКМФулфилмент.ДатаЗаказа, ДЕНЬ)
	
	
	
	|ИТОГИ
	|	МАКСИМУМ(ИмяФайла),
	|	МАКСИМУМ(НомерЗаказа),
	|	МАКСИМУМ(ДатаЗаказа),
	|	МАКСИМУМ(ДокументСсылка),
	|	МАКСИМУМ(Организация)
	|ПО
	|	ВидОперации,
	|	ВидПродукции,
	//|	Заказ");// ЕНС. в локальной базе у меня нет ссылок на заказы, поэтому поменяю ИТОГИ на НомерЗаказа (строка)
	|	НомерЗаказа");
	
	Запрос.УстановитьПараметр("ИмяФайла", ИмяФайла);
	Запрос.УстановитьПараметр("ТаблицаДанных", ТаблицаДанных);
	Запрос.УстановитьПараметр("Организация", НастройкиФФ.Организация);
	
	Попытка
		РезультатЗапроса = Запрос.Выполнить();
	Исключение
		Сообщение = СтрШаблон("Ошибка выполнения запроса: %1", ОписаниеОшибки());
		ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
		ВызватьИсключение;
	КонецПопытки;	
		
	Возврат РезультатЗапроса;
	
КонецФункции


// Описание_метода
//
// Параметры:
//	ПолноеИмяФайла 	- строка - имя файла XML с загружаемыми данными
//
Процедура СоздатьОбновитьДокументы(РезультатЗапроса, ПолноеИмяФайла)
	
	ВыборкаВидОперации = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаВидОперации.Следующий() Цикл
		
		//ЕНС. В ЕРП вид продукции - пустой, т.е. всегда один.
		ВыборкаВидПродукции = ВыборкаВидОперации.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаВидПродукции.Следующий() Цикл
		
			ВыборкаЗаказ = ВыборкаВидПродукции.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаЗаказ.Следующий() Цикл
				
				КоличествоОшибокПоДокументу = 0;
				
				Если Не ЗначениеЗаполнено(ВыборкаЗаказ.Заказ) Тогда
					Сообщение = СтрШаблон("Не найден заказ ИМ %1 от %2", ВыборкаЗаказ.НомерЗаказа, ВыборкаЗаказ.ДатаЗаказа);
					ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
					КоличествоОшибокПоДокументу = КоличествоОшибокПоДокументу + 1;
				//	Продолжить;
				КонецЕсли;
				
				//это документ ДвиженияКМФулфилмент
				Если ЗначениеЗаполнено(ВыборкаЗаказ.ДокументСсылка) Тогда
					ДокументОбъект = ВыборкаЗаказ.ДокументСсылка.ПолучитьОбъект();
				Иначе
					ДокументОбъект = Документы.ДвиженияКМФулфилмент.СоздатьДокумент();
					ДокументОбъект.Дата = ТекущаяДата();
				КонецЕсли;
				
				//ЕНС. Не надо так. Ничего не понятно сходу, какие реквизиты заполняются
				//ЗаполнитьЗначенияСвойств(ДокументОбъект, ВыборкаЗаказ);
				ДокументОбъект.Организация = ВыборкаЗаказ.Организация;
				ДокументОбъект.Заказ 	= ВыборкаЗаказ.Заказ;
				ДокументОбъект.ИмяФайла = ВыборкаЗаказ.ИмяФайла;
				ДокументОбъект.ВидОперации = ВыборкаЗаказ.ВидОперации;
				ДокументОбъект.НомерЗаказа = ВыборкаЗаказ.НомерЗаказа;
				ДокументОбъект.ДатаЗаказа = ВыборкаЗаказ.ДатаЗаказа;
				
				ДокументОбъект.ДвиженияКодовМаркировки.Очистить();
				
				//ЕНС. нет необходимости хранить весь исходный файл в каждом документе. Он хранится в РС.ЗагрузкаДанныхИзФулфилмент
				//ДокументОбъект.ДанныеФайла = Новый ХранилищеЗначения(Новый ДвоичныеДанные(ПолноеИмяФайла));
				
				ВыборкаДанных = ВыборкаЗаказ.Выбрать();
		
				Пока ВыборкаДанных.Следующий() Цикл
					
					ПропуститьСтроку = Ложь;
					
					Если Не ЗначениеЗаполнено(ВыборкаДанных.Номенклатура) Тогда
						Если ВыборкаДанных.КоличествоЗаписейШК = 0 Тогда
							Сообщение = СтрШаблон("Не найдена номенклатура %1 (нет записей по ШК %2, %3)", ВыборкаДанных.НоменклатураНаименование, ВыборкаДанных.КодМаркировкиДляПоиска, ВыборкаДанных.Штрихкод);
						ИначеЕсли ВыборкаДанных.КоличествоЗаписейШК > 1 Тогда
							Сообщение = СтрШаблон("Не найдена номенклатура %1 (несколько записей по ШК %2)", ВыборкаДанных.НоменклатураНаименование, ВыборкаДанных.Штрихкод);
						Иначе	
							Сообщение = СтрШаблон("Не найдена номенклатура %1, КМ %2, ШК %3", ВыборкаДанных.НоменклатураНаименование, ВыборкаДанных.КодМаркировкиДляПоиска, ВыборкаДанных.Штрихкод);
						КонецЕсли;	
						ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
						ПропуститьСтроку = Истина;
					КонецЕсли;
					
					Если Не ЗначениеЗаполнено(ВыборкаДанных.ХарактеристикаНоменклатуры) Тогда
						Если ВыборкаДанных.КоличествоЗаписейШК = 0 Тогда
							Сообщение = СтрШаблон("Не найдена характеристика %1 (нет записей по ШК %2, %3)", ВыборкаДанных.ХарактеристикаНаименование, ВыборкаДанных.КодМаркировкиДляПоиска, ВыборкаДанных.Штрихкод);
						ИначеЕсли ВыборкаДанных.КоличествоЗаписейШК > 1 Тогда
							Сообщение = СтрШаблон("Не найдена характеристика %1 (несколько записей по ШК %2)", ВыборкаДанных.ХарактеристикаНаименование, ВыборкаДанных.Штрихкод);
						Иначе	
							Сообщение = СтрШаблон("Не найдена характеристика %1, КМ %2, ШК %3", ВыборкаДанных.ХарактеристикаНаименование, ВыборкаДанных.КодМаркировкиДляПоиска, ВыборкаДанных.Штрихкод);
						КонецЕсли;	
						ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
						ПропуститьСтроку = Истина;
					КонецЕсли;
				
					Если ПропуститьСтроку Тогда
						КоличествоОшибокПоДокументу = КоличествоОшибокПоДокументу + 1;
					//	Продолжить;
					КонецЕсли;	
						
					НоваяСтрока = ДокументОбъект.ДвиженияКодовМаркировки.Добавить();
					
					// ЕНС. Пока оставлю, возможно в будущем распишу более детально
					ЗаполнитьЗначенияСвойств(НоваяСтрока, ВыборкаДанных);
					
					ОбменСФулфилментСервер.РассчитатьСуммуТабЧасти(НоваяСтрока, ДокументОбъект);
					ОбменСФулфилментСервер.РассчитатьСуммуНДСТабЧасти(НоваяСтрока, ДокументОбъект);
					НоваяСтрока.СуммаСНДС = НоваяСтрока.Сумма;
				
				КонецЦикла;  // самый детальный уровень
				
				//РежимЗаписи = ?(КоличествоОшибокПоДокументу = 0, РежимЗаписиДокумента.Проведение, РежимЗаписиДокумента.Запись);
				РежимЗаписи = РежимЗаписиДокумента.Запись;
				
		        Если ДокументОбъект.ДвиженияКодовМаркировки.Количество() > 0 Тогда
					Попытка
						ДокументОбъект.Записать(РежимЗаписи);
						//ЕНС
						РегистрыСведений.ксп_ВыводИзОборотаИСМП.ДобавитьЗаписьСПустымВыводомИзОборота(ДокументОбъект.Ссылка);
					Исключение
						Сообщение = СтрШаблон("Ошибка записи документа: %1", ОписаниеОшибки());
						ксп_Элис_ОбщегоНазначения.ЗаписатьВЛог(Лог, Сообщение, "ERR");
						КоличествоОшибокПоДокументу = КоличествоОшибокПоДокументу + 1;
					КонецПопытки;
				КонецЕсли;
				
				КоличествоОшибок = КоличествоОшибок + КоличествоОшибокПоДокументу;
				
			КонецЦикла;  // ВыборкаЗаказ
			
		КонецЦикла;  // ВыборкаВидПродукции	
		
	КонецЦикла;  // ВыборкаВидОперации
	
		
КонецПроцедуры



// В эту таблицу собираются данные из загружаемого XML-файла
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция _ТаблицаДанных()
	
	ТаблицаДанных = новый ТаблицаЗначений;
	ТаблицаДанных.Колонки.Добавить("КодМаркировки",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(1024)));
	ТаблицаДанных.Колонки.Добавить("КодМаркировкиДляПоиска",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(1024)));
	ТаблицаДанных.Колонки.Добавить("ВидОперации",новый ОписаниеТипов("ПеречислениеСсылка.ВидыДвиженийКМФулфилмент"));
	ТаблицаДанных.Колонки.Добавить("ДатаСобытия",новый ОписаниеТипов("Дата"));
	ТаблицаДанных.Колонки.Добавить("ДокументНаименование",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(150)));
	ТаблицаДанных.Колонки.Добавить("ДокументНомер",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(50)));
	ТаблицаДанных.Колонки.Добавить("ДокументДата",новый ОписаниеТипов("Дата"));
	ТаблицаДанных.Колонки.Добавить("НоменклатураНаименование",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(1024)));
	ТаблицаДанных.Колонки.Добавить("НоменклатураСсылка",новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	ТаблицаДанных.Колонки.Добавить("ХарактеристикаНаименование",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(1024)));
	ТаблицаДанных.Колонки.Добавить("ХарактеристикаСсылка",новый ОписаниеТипов("СправочникСсылка.ХарактеристикиНоменклатуры"));
	ТаблицаДанных.Колонки.Добавить("Штрихкод",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(1024)));
	ТаблицаДанных.Колонки.Добавить("Цена",новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(15,2))); 
	ТаблицаДанных.Колонки.Добавить("ЗаказНомер",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(50)));
	ТаблицаДанных.Колонки.Добавить("ЗаказДата",новый ОписаниеТипов("Дата"));
	ТаблицаДанных.Колонки.Добавить("СтатусОплаты",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(50)));
	ТаблицаДанных.Колонки.Добавить("НомерПосылки",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(150)));
	ТаблицаДанных.Колонки.Добавить("ТипВозврата",новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(50)));

	Возврат 	ТаблицаДанных;
		
	Возврат Неопределено;
	
КонецФункции

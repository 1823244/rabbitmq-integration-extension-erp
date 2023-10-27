﻿
// Возвращает ссылку справочника по GUID
//
// Параметры:
//	УзелСсылки 	- структура - тэг из формата обмена (Json)
//	ВидСправочника - строка - Вид справочника из базы-приемника, например, Номенклатура
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ПолучитьСсылкуСправочникаСПроверкой(УзелСсылки, ВидСправочника) Экспорт

	Ref = "";
	Если УзелСсылки.Свойство("ref", Ref) Тогда
		Возврат Справочники[ВидСправочника].ПолучитьСсылку(
			Новый УникальныйИдентификатор(Ref));
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

// Возвращает ссылку документа по GUID
//
// Параметры:
//	УзелСсылки 	- структура - 
//	ВидДокумента - строка - например, ПеремещениеТоваров
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ПолучитьСсылкуДокументаСПроверкой(УзелСсылки, ВидДокумента) Экспорт

	Ref = "";
	Если УзелСсылки.Свойство("ref", Ref) Тогда
		Возврат Документы[ВидДокумента].ПолучитьСсылку(
			Новый УникальныйИдентификатор(Ref));
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции


// Добавляет записи в регистры сведений:
// ксп_ОтложенноеПроведение
// ксп_ОтложенноеПроведениеПроблемы
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
Процедура ДобавитьПроблемуОтложенногоПроведения(ДанныеСсылка, ИмяРеквизита, ИмяТаблЧасти=Неопределено, НомерСтрокиТЧ=0, ВидПроблемы) Экспорт
	
	
	НЗ = РегистрыСведений.ксп_ОтложенноеПроведение.СоздатьНаборЗаписей();
	НЗ.Отбор.ДокументСсылка.Установить(ДанныеСсылка);
	
	НЗ.Прочитать();
	Если НЗ.Количество() > 0 Тогда
		
		стрк = НЗ[0];
		
	Иначе 
		
		стрк = НЗ.Добавить();
		стрк.ДокументСсылка = ДанныеСсылка;
			
	КонецЕсли; 

	
	
	Если ВидПроблемы = Перечисления.ксп_ВидыПроблемКачестваДокументов.НетЗначения Тогда
		стрк.СтатусОбъекта = Перечисления.ксп_СтатусыКачестваДокументов.Ошибка;
		
	ИначеЕсли ВидПроблемы = Перечисления.ксп_ВидыПроблемКачестваДокументов.БитаяСсылка Тогда
		стрк.СтатусОбъекта = Перечисления.ксп_СтатусыКачестваДокументов.Ожидание;
		
	КонецЕсли; 
	
	
	
	НЗ.Записать();
	
	//--------------------------------------------
	
	Если ВидПроблемы = Перечисления.ксп_ВидыПроблемКачестваДокументов.НетЗначения Тогда
	ИначеЕсли ВидПроблемы = Перечисления.ксп_ВидыПроблемКачестваДокументов.БитаяСсылка Тогда
		
	КонецЕсли; 
	
	НЗ = РегистрыСведений.ксп_ОтложенноеПроведениеПроблемы.СоздатьНаборЗаписей();
	НЗ.Отбор.ДокументСсылка.Установить(ДанныеСсылка);
	НЗ.Отбор.ИмяРеквизита.Установить(ИмяРеквизита);
	НЗ.Отбор.ИмяТаблЧасти.Установить(ИмяТаблЧасти);
	НЗ.Отбор.НомерСтрокиТЧ.Установить(НомерСтрокиТЧ);
	
	НЗ.Прочитать();
	Если НЗ.Количество() > 0 Тогда
		
		стрк = НЗ[0];
		
	Иначе 
		
		стрк = НЗ.Добавить();
		стрк.ДокументСсылка = ДанныеСсылка;
		стрк.ИмяРеквизита = ИмяРеквизита;
		стрк.ИмяТаблЧасти = ИмяТаблЧасти;
		стрк.НомерСтрокиТЧ = НомерСтрокиТЧ;
		
	КонецЕсли;
	
	стрк.ОписаниеПроблемы = "";
	стрк.ВидПроблемы = ВидПроблемы;
	
	НЗ.Записать();
		
КонецПроцедуры

// ПРоблем нет, добавляем документ к отложенному проведению
Процедура ДобавитьОтложенноеПроведение(ДанныеСсылка) Экспорт
	
	НЗ = РегистрыСведений.ксп_ОтложенноеПроведение.СоздатьНаборЗаписей();
	НЗ.Отбор.ДокументСсылка.Установить(ДанныеСсылка);
	
	НЗ.Прочитать();
	Если НЗ.Количество() > 0 Тогда
		
		стрк = НЗ[0];
		
	Иначе 
		
		стрк = НЗ.Добавить();
		стрк.ДокументСсылка = ДанныеСсылка;
			
	КонецЕсли; 
	
	стрк.СтатусОбъекта = Перечисления.ксп_СтатусыКачестваДокументов.ОК;
	
	НЗ.Записать();
	
	// очистим детали проблемы, если были
	
	НЗ = РегистрыСведений.ксп_ОтложенноеПроведениеПроблемы.СоздатьНаборЗаписей();
	НЗ.Отбор.ДокументСсылка.Установить(ДанныеСсылка);
	НЗ.Записать();
		
КонецПроцедуры

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ПроверитьКачествоДанных(ДокументОбъект, ОбъектОбработкиИмпорта) Экспорт
	
	// проверить шапку

	ЕстьПроблемы = Ложь;
	Для каждого рек Из МассивРеквизитовШапкиДляПроверки(ДокументОбъект, ОбъектОбработкиИмпорта) Цикл
		
		Если НЕ ЗначениеЗаполнено(ДокументОбъект[рек]) Тогда
			
			ксп_ИмпортСлужебный.ДобавитьПроблемуОтложенногоПроведения(
				ДокументОбъект.Ссылка, рек, Неопределено, 0, 
				Перечисления.ксп_ВидыПроблемКачестваДокументов.НетЗначения);
				
			ЕстьПроблемы = Истина;
			
		ИначеЕсли ЗначениеЗаполнено(ДокументОбъект[рек]) 
			И НЕ ЗначениеЗаполнено(ДокументОбъект[рек].ВерсияДанных) Тогда

			ксп_ИмпортСлужебный.ДобавитьПроблемуОтложенногоПроведения(
				ДокументОбъект.Ссылка, рек, Неопределено, 0, 
				Перечисления.ксп_ВидыПроблемКачестваДокументов.БитаяСсылка);
				
			ЕстьПроблемы = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	// todo проверить все Табл Части
	
	
	// в конце - финальная проверка на наличие проблем
	Если НЕ ЕстьПроблемы Тогда
		ксп_ИмпортСлужебный.ДобавитьОтложенноеПроведение(ДокументОбъект.Ссылка);
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

Функция МассивРеквизитовШапкиДляПроверки(ДокументОбъект, ОбъектОбработкиИмпорта) Экспорт
	
	//ПолноеИмя = ДокументОбъект.Метаданные().ПолноеИмя();
	//Если ПолноеИмя = "ЗаказПокупателя" Тогда
	//	Возврат МассивРеквизитовШапкиДляПроверки_ЗаказПокупателя();
	//КонецЕсли;
	
	Возврат ОбъектОбработкиИмпорта.МассивРеквизитовШапкиДляПроверки();
	Возврат Новый Массив;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция МассивРеквизитовШапкиДляПроверки_ЗаказПокупателя() Экспорт
	
	мРеквизиты = Новый Массив;
	мРеквизиты.Добавить("Склад");
	мРеквизиты.Добавить("Организация");
	Возврат мРеквизиты;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиБанковскийСчет(НомерСчета, БИК) Экспорт
		
	Банк = НайтиБанк(БИК);
	Если НЕ ЗначениеЗаполнено(Банк) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	БанковскиеСчета.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.БанковскиеСчета КАК БанковскиеСчета
		|ГДЕ
		|	БанковскиеСчета.НомерСчета = &НомерСчета
		|	И БанковскиеСчета.Банк = &Банк";
	
	Запрос.УстановитьПараметр("НомерСчета", НомерСчета);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.ссылка;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиБанк(БИК) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КлассификаторБанков.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.КлассификаторБанков КАК КлассификаторБанков
		|ГДЕ
		|	КлассификаторБанков.Код = &Код";
	
	Запрос.УстановитьПараметр("Код", БИК);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиДисконтнуюКарту(Штрихкод, МагнитныйКод) Экспорт

	Если ЗначениеЗаполнено(МагнитныйКод) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ИнформационныеКарты.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.ИнформационныеКарты КАК ИнформационныеКарты
			|ГДЕ
			|	ИнформационныеКарты.КодКарты = &КодКарты";
		
		Запрос.УстановитьПараметр("КодКарты", МагнитныйКод);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Возврат ВыборкаДетальныеЗаписи.Ссылка;
		КонецЦикла;
	КонецЕсли;

	Если ЗначениеЗаполнено(Штрихкод) Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	Штрихкоды.Владелец КАК ИнфКарта
			|ИЗ
			|	РегистрСведений.Штрихкоды КАК Штрихкоды
			|ГДЕ
			|	Штрихкоды.Штрихкод = &Штрихкод";
		
		Запрос.УстановитьПараметр("Штрихкод", Штрихкод);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Возврат ВыборкаДетальныеЗаписи.ИнфКарта;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	ТипыНалогообложенияНДС 	- строка/структура - перечисление в ЕРП "ТипыНалогообложенияНДС"
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция УчитыватьНДС(ТипыНалогообложенияНДС)   Экспорт
 
	Если ТипЗнч(ТипыНалогообложенияНДС) = Тип("Структура") Тогда
		_ТипыНалогообложенияНДС = ТипыНалогообложенияНДС.Значение;
	Иначе 
		_ТипыНалогообложенияНДС = ТипыНалогообложенияНДС;
	КонецЕсли;
	
	Если _ТипыНалогообложенияНДС =  "НалоговыйАгентПоНДС" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПоФактическомуИспользованию" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПродажаНаЭкспорт" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПродажаНеОблагаетсяНДС" Тогда
		Возврат Ложь;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПродажаОблагаетсяЕНВД" Тогда
		Возврат Ложь;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПродажаОблагаетсяНДС" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ЭкспортСырьевыхТоваровУслуг" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ЭкспортНесырьевыхТоваров" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ВводОСВЭксплуатацию" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ОпределяетсяРаспределением" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ОблагаетсяНДСУПокупателя" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПроизводствоСДЦ" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ЭлектронныеУслуги" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "РеализацияРаботУслугНаЭкспорт" Тогда
		Возврат Истина;
	ИначеЕсли _ТипыНалогообложенияНДС =  "ПродажаПоПатенту" Тогда
		Возврат Ложь;
	ИначеЕсли _ТипыНалогообложенияНДС =  "РеверсивноеОбложениеНДС" Тогда
		Возврат Истина;
		
	КонецЕсли;

	Возврат ЛОЖЬ;
	
КонецФункции

// Возвращает Перечисление.СтавкиНДС. Для Розницы
//
// Параметры:
//	УзелСправочника 	- строка - Узел справочника СтавкиНДС из ЕРП
//		Например, для номенклатуры:
 //      "СтавкаНДС": {
 //           "type": "Справочник.СтавкиНДС",
 //           "Ref": "5352d82a-eda6-11ed-8b9e-04ed33c124eb",
 //           "isFolder": false,
 //           "Code": "",
 //           "ПеречислениеСтавкаНДС": {
 //               "type": "Перечисление.СтавкиНДС",
 //               "Значение": "НДС20",
 //               "Представление": "20%"
 //           },
 //           "Predefined": false
 //       },
//
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ОпределитьСтавкуНДСПоСправочникуЕРП(УзелСправочника) Экспорт
	
	СтавкаНДС = УзелСправочника.ПеречислениеСтавкаНДС.Значение;//строка
	
	Если СтавкаНДС = "НДС18" Тогда
		Возврат Перечисления.СтавкиНДС.НДС18;
	ИначеЕсли СтавкаНДС = "НДС18_118" Тогда
		Возврат Перечисления.СтавкиНДС.НДС18_118;
	ИначеЕсли СтавкаНДС = "НДС10" Тогда
		Возврат Перечисления.СтавкиНДС.НДС10;
	ИначеЕсли СтавкаНДС = "НДС10_110" Тогда
		Возврат Перечисления.СтавкиНДС.НДС10_110;
	ИначеЕсли СтавкаНДС = "НДС0" Тогда
		Возврат Перечисления.СтавкиНДС.НДС0;
	ИначеЕсли СтавкаНДС = "БезНДС" Тогда
		Возврат Перечисления.СтавкиНДС.БезНДС;
	ИначеЕсли СтавкаНДС = "НДС20" Тогда
		Возврат Перечисления.СтавкиНДС.НДС20;
	ИначеЕсли СтавкаНДС = "НДС20_120" Тогда
		Возврат Перечисления.СтавкиНДС.НДС20_120;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

// Возвращает Справочник.СтавкиНДС. Для ЕРП
//
// Параметры:
//	УзелСправочника 	- строка - Узел перечисления СтавкиНДС из Розницы
//		Например, для номенклатуры:
				// "СтавкаНДС": {
				//    "type": "Перечисление.СтавкиНДС",
				//    "Значение": "НДС20",
				//    "Представление": "20%"
				//},
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
// Использование
//	СтрокаТЧ.СтавкаНДС = ксп_ИмпортСлужебный.ОпределитьСтавкуНДСПоПеречислениюРозницы(стрк.СтавкаНДС);
//
Функция ОпределитьСтавкуНДСПоПеречислениюРозницы(Узел) Экспорт
	
	Если НЕ Узел.Свойство("Значение") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СтавкаНДС = Узел.Значение;//строка
	
	
	Рез = Неопределено;
	Если СтавкаНДС = "НДС18" Тогда
		Рез = Справочники.СтавкиНДС.НДС18;
	ИначеЕсли СтавкаНДС = "НДС18_118" Тогда
		Рез = Перечисления.СтавкиНДС.НДС18_118;
	ИначеЕсли СтавкаНДС = "НДС10" Тогда
		Рез = Перечисления.СтавкиНДС.НДС10;
	ИначеЕсли СтавкаНДС = "НДС10_110" Тогда
		Рез = Перечисления.СтавкиНДС.НДС10_110;
	ИначеЕсли СтавкаНДС = "НДС0" Тогда
		Рез = Перечисления.СтавкиНДС.НДС0;
	ИначеЕсли СтавкаНДС = "БезНДС" Тогда
		Рез = Перечисления.СтавкиНДС.БезНДС;
	ИначеЕсли СтавкаНДС = "НДС20" Тогда
		Рез = Перечисления.СтавкиНДС.НДС20;
	ИначеЕсли СтавкаНДС = "НДС20_120" Тогда
		Рез = Перечисления.СтавкиНДС.НДС20_120;
	КонецЕсли;
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтавкиНДС.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.СтавкиНДС КАК СтавкиНДС
		|ГДЕ
		|	СтавкиНДС.ПеречислениеСтавкаНДС = &ПеречислениеСтавкаНДС";
	
	Запрос.УстановитьПараметр("ПеречислениеСтавкаНДС", Рез);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
	Возврат Неопределено;
	
КонецФункции

// Поиск внешнего перечисления в спр ксп_КлассификаторПеречислений
//
// Параметры:
//	ВнешняяСистема		- Строка - например, "ЕРП"
//	Объект				- Строка - например, "Справочник.НаборыУпаковок"
//	Значение 			- Строка - например, "БазовыеЕдиницыИзмерения", для справочника - имя предопределенного элемента
//									для перечисления - имя значения
//
// Возвращаемое значение:
//	Тип: Спр ссылка ксп_КлассификаторПеречислений
//
Функция НайтиПеречисление(ВнешняяСистема, Объект, Значение) Экспорт
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ксп_КлассификаторПеречислений.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ксп_КлассификаторПеречислений КАК ксп_КлассификаторПеречислений
		|ГДЕ
		|	ксп_КлассификаторПеречислений.КодВнешнейСистемы = &КодВнешнейСистемы
		|	И ксп_КлассификаторПеречислений.ОбъектИсточник = &ОбъектИсточник
		|	И ксп_КлассификаторПеречислений.Значение = &Значение";
		
	
	Запрос.УстановитьПараметр("Значение", Значение);
	
	Запрос.УстановитьПараметр("КодВнешнейСистемы", ВнешняяСистема);
	Запрос.УстановитьПараметр("ОбъектИсточник", Объект);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	
	Возврат Неопределено;
	
КонецФункции

// алгоритм взят из КД2
//		
		// принципы импорта единиц измерения:
		//
		// Если в ЕРП Владелец элемента спр "УпаковкиЕдиницыИзмерения":
		//	* Справочники.НаборыУпаковок.БазовыеЕдиницыИзмерения 
		//	или
		//	* не указан
		// То это Базовая Единица
		// Ищем эту Единицу в Рознице в спр "БазовыеЕдиницыИзмерения" по Наименование
		//
		// Пример тэга из ЕРП:
		//
		//"ЕдиницаИзмерения": {
		//    "type": "Справочник.УпаковкиЕдиницыИзмерения",
		//    "Ref": "4d3d3ed8-eda6-11ed-8b9e-04ed33c124eb",
		//    "isFolder": false,
		//    "Parent": {
		//        "type": "Справочник.УпаковкиЕдиницыИзмерения"
		//    },
		//    "Code": "796 ",
		//    "Owner": {
		//        "type": "Справочник.НаборыУпаковок",
		//        "Ref": "c91bef45-eda5-11ed-8b9e-04ed33c124eb",
		//        "isFolder": false,
		//        "Code": ""
		//    }
		//},		
//		
		// Если же в ЕРП владельцем спр "УпаковкиЕдиницыИзмерения" является спр Номенклатура,
		// то ищем в Рознице в спр "УпаковкиНоменклатуры" по:
		// * Владелец
		// * ЕдиницаИзмерения - спр ссылка  "БазовыеЕдиницыИзмерения"
		//
//
//
// Параметры:
//	УзелЕдиницы 		- строка - тэг из json-текста
//	УзелНоменклатуры 	- строка - тэг из json-текста
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиЕдиницуИзмерения(УзелЕдиницы, УзелНоменклатуры = Неопределено) Экспорт
	
	Наименование = "";
	УзелЕдиницы.Свойство("Наименование", Наименование);
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Владелец = "";
	УзелЕдиницы.Свойство("Owner", Владелец);
	
	Если (НЕ ЗначениеЗаполнено(Владелец)) 
		ИЛИ
		(Владелец.type = "Справочник.НаборыУпаковок"
		И
		Владелец.Predefined = true
		И
		Владелец.PredefinedName = "БазовыеЕдиницыИзмерения")
		Тогда
		Возврат Справочники.БазовыеЕдиницыИзмерения.НайтиПоНаименованию(УзелЕдиницы.Наименование, Истина);
	КонецЕсли;
		
	Если ЗначениеЗаполнено(Владелец) И Владелец.type = "Справочник.Номенклатура" Тогда
		
		Если ЗначениеЗаполнено(УзелНоменклатуры) Тогда
			Запрос = Новый Запрос;
			Запрос.Текст = 
				"ВЫБРАТЬ
				|	УпаковкиНоменклатуры.Ссылка КАК Ссылка
				|ИЗ
				|	Справочник.УпаковкиНоменклатуры КАК УпаковкиНоменклатуры
				|ГДЕ
				|	УпаковкиНоменклатуры.Наименование = &Наименование
				|	И УпаковкиНоменклатуры.Владелец = &Владелец";
			
			//через имя общ модуля, чтобы ПИ работало
			Владелец = ксп_ИмпортСлужебный.НайтиНоменклатуру(УзелНоменклатуры);
			
			Запрос.УстановитьПараметр("Владелец", Владелец);
			
			РезультатЗапроса = Запрос.Выполнить();
			
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
			
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				Возврат ВыборкаДетальныеЗаписи.Ссылка;
			КонецЦикла;
		КонецЕсли;	
		
	КонецЕсли;
	
		
	Возврат Неопределено;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиНоменклатуру(УзелНоменклатуры) Экспорт
	
	НоменклатураГУИД = "";
	Если УзелНоменклатуры.Свойство("Ref", НоменклатураГУИД) Тогда
		Возврат Справочники.Номенклатура.ПолучитьСсылку(Новый УникальныйИдентификатор(НоменклатураГУИД));
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

Функция НайтиХарактеристику(УзелХарактеристики) Экспорт
	
	ХарактеристикаГУИД = "";
	Если УзелХарактеристики.Свойство("Ref", ХарактеристикаГУИД) Тогда
		Возврат Справочники.ХарактеристикиНоменклатуры.ПолучитьСсылку(Новый УникальныйИдентификатор(ХарактеристикаГУИД));
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

// todo Возмоно надо сделать через мэппинг
Функция НайтиКассуККМ(Узел) Экспорт
	
	гуид = "";
	Если Узел.Свойство("Ref", гуид) Тогда
		Возврат Справочники.КассыККМ.ПолучитьСсылку(Новый УникальныйИдентификатор(гуид));
	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

Функция НайтиКонтрагента(Узел, ВнешняяСистема) Экспорт

	Контрагент = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		Контрагент = РегистрыСведений.ксп_МэппингСправочникКонтрагенты.ПоМэппингу(ГУИД, ВнешняяСистема);
		Если НЕ ЗначениеЗаполнено(Контрагент) ИЛИ НЕ ЗначениеЗаполнено(Контрагент.ВерсияДанных) Тогда
			Контрагент = Справочники.Контрагенты.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
		КонецЕсли;
	КонецЕсли;
	Возврат Контрагент;
	
КонецФункции


// Описание_метода
//
// Параметры:
//	УзелДоговора - строка  - поиск договора по гуиду
//	УзелКонтрагента - строка - пока не используется
//	КонтрагентСсылка - СправочникСсылка.Контрагенты - пока не используется
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиДоговор(УзелДоговора, УзелКонтрагента = Неопределено, КонтрагентСсылка = Неопределено) Экспорт

	Рез = Неопределено;
	ГУИД = "";
	Если УзелДоговора.Свойство("Ref", ГУИД) Тогда
		Рез = Справочники.ДоговорыКонтрагентов.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
	КонецЕсли;
	
	Возврат Рез;
		
КонецФункции

Функция НайтиОрганизацию(Узел, ВнешняяСистема) Экспорт
	
	Организация = Неопределено;
	гуид = "";
	Если узел.Свойство("Ref", гуид) Тогда
		Организация = РегистрыСведений.ксп_МэппингСправочникОрганизации.ПоМэппингу(гуид, ВнешняяСистема);
		Если НЕ ЗначениеЗаполнено(Организация) ИЛИ НЕ ЗначениеЗаполнено(Организация.ВерсияДанных) Тогда
			Организация = Справочники.Организации.ПолучитьСсылку(Новый УникальныйИдентификатор(гуид));
		КонецЕсли;
	КонецЕсли;
		
	Возврат Организация;
	
КонецФункции

// Возвращает пользователя для подстановки в документы
// Это может быть предопределенный элемеент
// или какой-то еще
//
// Параметры:
//	нет
//
// Возвращаемое значение:
//	Тип: СправочникСсылка.Пользователи
//
Функция ОтветственныйПоУмолчанию() Экспорт
	
	// заглушка. Вернем битую ссылку, ее пока достаточно
	Возврат Справочники.Пользователи.ПолучитьСсылку(Новый УникальныйИдентификатор);
	
КонецФункции

#Область Склад

// ищет склад при импорте - по узлу json-текста
Функция НайтиСклад(Узел, ВнешняяСистема) Экспорт

	Склад = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		Склад = НайтиСкладПоГУИД(ГУИД, ВнешняяСистема);
	КонецЕсли;
	Возврат Склад;
	
КонецФункции

// ищет склад по ГУИД в мэппинге, если там нет - в справочнике
Функция НайтиСкладПоГУИД(ГУИД, ВнешняяСистема) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ГУИД) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Склад = РегистрыСведений.ксп_МэппингСправочникСклады.ПоМэппингу(ГУИД, ВнешняяСистема);
	Если НЕ ЗначениеЗаполнено(Склад) ИЛИ НЕ ЗначениеЗаполнено(Склад.ВерсияДанных) Тогда
		Склад = Справочники.Склады.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
	КонецЕсли;
	Возврат Склад;
	
КонецФункции

#КонецОбласти


#Область КлючиАналитикиУчетаНоменклатуры

// Использовать этот!!!!!
//
// Параметры:
//	Номенклатура 	- СправочникСсылка.Номенклатура - 
//	Склады		 	- СправочникСсылка.Склады - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиСоздатьКлючАналитикиНом(Номенклатура, Склад) Экспорт
	
	Рез = НайтиКлючАналитикиНом(Номенклатура, Склад);

	Если НЕ ЗначениеЗаполнено(Рез) Тогда
		
		 Возврат СоздатьКлючАналитикиНом(Номенклатура, Склад);
		 
	КонецЕсли;		
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиКлючАналитикиНом(Номенклатура, Склад) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Спр.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.КлючиАналитикиУчетаНоменклатуры КАК Спр
		|ГДЕ
		|	Спр.Номенклатура = &Номенклатура
		|	И Спр.МестоХранения = &МестоХранения
		|	И Спр.Характеристика = &Характеристика
		|	И Спр.ТипМестаХранения = &ТипМестаХранения";
	
	Запрос.УстановитьПараметр("МестоХранения", Склад);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("ТипМестаХранения", Перечисления.ТипыМестХранения.Склад);
	// todo возможно придется доделывать
	Запрос.УстановитьПараметр("Характеристика", Неопределено);
	// нужно ли это?
	//Запрос.УстановитьПараметр("СкладскаяТерритория", Склад);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.ссылка;
	КонецЦикла;
			
	Возврат Неопределено;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция СоздатьКлючАналитикиНом(Номенклатура, Склад) Экспорт
	
		
	Рез = Справочники.КлючиАналитикиУчетаНоменклатуры.СоздатьЭлемент();
	Рез.МестоХранения = Склад;
	РЕз.Номенклатура = Номенклатура;
	Рез.СкладскаяТерритория = Склад;
	Рез.Наименование = Строка(Номенклатура) + "; " + Строка(Склад);
	Рез.Записать();
	Рез = Рез.Ссылка; // переопределим, чтобы не писать лишний код
		
	Возврат Рез;
	
КонецФункции


#КонецОбласти

#Область ВидыЦен

// ищет элемент при импорте - по узлу json-текста
Функция НайтиВидЦены(Узел, ВнешняяСистема) Экспорт

	Рез = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		Рез = НайтиВидЦеныПоГУИД(ГУИД, ВнешняяСистема);
	КонецЕсли;
	Возврат Рез;
	
КонецФункции

// ищет элемент по ГУИД в мэппинге, если там нет - в справочнике
Функция НайтиВидЦеныПоГУИД(ГУИД, ВнешняяСистема) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ГУИД) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Рез = РегистрыСведений.ксп_МэппингСправочникВидыЦен.ПоМэппингу(ГУИД, ВнешняяСистема);
	
	Если НЕ ЗначениеЗаполнено(Рез) ИЛИ НЕ ЗначениеЗаполнено(Рез.ВерсияДанных) Тогда
		Рез = Справочники.ВидыЦен.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
	КонецЕсли;
	
	Возврат Рез;
	
КонецФункции

#КонецОбласти

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция КонвертацияПеречисления_ХозяйственныеОперации_Розница(Узел) Экспорт
		
	_знч = "";
	ЕстьЗначение = Узел.свойство("Значение",_знч);
	Если НЕ ЕстьЗначение Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	_п = Перечисления.ХозяйственныеОперации;
	
	Если _знч = "ВнутренняяПередачаДенежныхСредств" Тогда
		Возврат _п.ВнутренняяПередачаДенежныхСредств;
	ИначеЕсли _знч = "ВозвратДенежныхСредствОтПоставщика" Тогда
		Возврат _п.ВозвратДенежныхСредствОтПоставщика;
	ИначеЕсли _знч = "ВозвратОплатыКлиенту" Тогда
		Возврат _п.ВозвратОплатыКлиенту;
	ИначеЕсли _знч = "ВозвратОтПокупателя" Тогда
		Возврат _п.ВозвратТоваровОтКлиента;
	ИначеЕсли _знч = "ВозвратПоставщику" Тогда
		Возврат _п.ВозвратТоваровПоставщику;
	ИначеЕсли _знч = "ВозвратТоваровКомитенту" Тогда
		Возврат _п.ВозвратТоваровКомитенту;
	ИначеЕсли _знч = "ВознаграждениеОтКомитента" Тогда
		Возврат _п.ПрочиеДоходы;
	ИначеЕсли _знч = "ВыдачаДенежныхСредствВДругуюКассу" Тогда
		Возврат _п.ВыдачаДенежныхСредствВДругуюКассу;

	ИначеЕсли _знч = "ВыдачаДенежныхСредствВДругуюОрганизацию" Тогда
		Возврат _п.ВыдачаДенежныхСредствПодотчетнику;

	ИначеЕсли _знч = "ВыдачаДенежныхСредствВКассуККМ" Тогда
		Возврат _п.ВыдачаДенежныхСредствВКассуККМ;

	ИначеЕсли _знч = "ВыдачаДенежныхСредствИзКассыККМ" Тогда
		Возврат _п.ВыдачаДенежныхСредствПодотчетнику;

	ИначеЕсли _знч = "ВыплатаЗаработнойПлатыПоВедомостям" Тогда
		Возврат _п.ВыплатаЗарплаты;

	ИначеЕсли _знч = "ВыплатаЗаработнойПлатыРаботнику" Тогда
		Возврат _п.ВыплатаЗарплатыРаботнику;

	ИначеЕсли _знч = "ЗакупкаВСтранахЕАЭС" Тогда
		Возврат _п.ЗакупкаВСтранахЕАЭС;
	ИначеЕсли _знч = "ЗакупкаПоИмпорту" Тогда
		Возврат _п.ЗакупкаПоИмпорту;
	ИначеЕсли _знч = "КомплектацияНоменклатуры" Тогда
		Возврат _п.ПрочиеРасходы;
	ИначеЕсли _знч = "КонвертацияВалюты" Тогда
		Возврат _п.КонвертацияВалюты;
	ИначеЕсли _знч = "КорректировкаВыручки" Тогда
		Возврат _п.КорректировкаПоСогласованиюСторон;

	ИначеЕсли _знч = "ОплатаПоставщику" Тогда
		Возврат _п.ОплатаПоставщику;
	ИначеЕсли _знч = "Оприходование" Тогда
		Возврат _п.ОприходованиеТоваров;

	ИначеЕсли _знч = "ОприходованиеКомиссионныхТоваров" Тогда
		Возврат _п.ОприходованиеТоваров;

	ИначеЕсли _знч = "ОприходованиеПоИнвентаризации" Тогда
		Возврат _п.ОприходованиеТоваров;

	ИначеЕсли _знч = "ОтгрузкаНаВнутренниеНужды" Тогда
		Возврат _п.ПрочиеРасходы;
	ИначеЕсли _знч = "ПередачаТоваровДоРеализации" Тогда
		Возврат _п.ПередачаНаКомиссию;

	ИначеЕсли _знч = "ПередачаТоваровПослеРеализации" Тогда
		Возврат _п.ПередачаНаКомиссию;

	ИначеЕсли _знч = "ПеремещениеТоваров" Тогда
		Возврат _п.ПеремещениеТоваров;
	ИначеЕсли _знч = "ПересортицаТоваров" Тогда
		Возврат _п.ПересортицаТоваров;
	ИначеЕсли _знч = "ПересортицаТоваровСПереоценкой" Тогда
		Возврат _п.ПересортицаТоваровСПереоценкой;

	ИначеЕсли _знч = "ПогашениеПодарочныхСертификатов" Тогда
		Возврат _п.ПрочиеРасходы;
	ИначеЕсли _знч = "ПоступлениеДенежныхСредствИзБанка" Тогда
		Возврат _п.ПоступлениеДенежныхСредствИзБанка;

	ИначеЕсли _знч = "ПоступлениеДенежныхСредствИзДругойКассы" Тогда
		Возврат _п.ПоступлениеДенежныхСредствИзДругойКассы;

	ИначеЕсли _знч = "ПоступлениеДенежныхСредствИзДругойОрганизации" Тогда
		Возврат _п.ПоступлениеДенежныхСредствИзДругойОрганизации;

	ИначеЕсли _знч = "ПоступлениеДенежныхСредствИзКассыККМ" Тогда
		Возврат _п.ПоступлениеДенежныхСредствИзКассыККМ;
	ИначеЕсли _знч = "ПоступлениеОплатыОтКлиента" Тогда
		Возврат _п.ПоступлениеОплатыОтКлиента;
	ИначеЕсли _знч = "ПоступлениеТоваров" Тогда
		Возврат _п.ПоступлениеПрочихАктивов;
	ИначеЕсли _знч = "ПриемНаКомиссию" Тогда
		Возврат _п.ПриемНаКомиссию;
	ИначеЕсли _знч = "ПриемТоваровОтДругойОрганизации" Тогда
		Возврат _п.ПрочиеРасходы;
	ИначеЕсли _знч = "ПрочиеДоходы" Тогда
		Возврат _п.ПрочиеДоходы;
	ИначеЕсли _знч = "ПрочиеРасходы" Тогда
		Возврат _п.ПрочиеРасходы;
	ИначеЕсли _знч = "РеализацияТоваров" Тогда
		Возврат _п.РеализацияВРозницу;
	ИначеЕсли _знч = "СдачаДенежныхСредствВБанк" Тогда
		Возврат _п.СдачаДенежныхСредствВБанк;
	ИначеЕсли _знч = "СписаниеНаЗатраты" Тогда
		Возврат _п.СписаниеТоваров;
	ИначеЕсли _знч = "СписаниеПоИнвентаризации" Тогда
		Возврат _п.СписаниеТоваров;
	КонецЕсли;	
	
	
	Возврат Неопределено;
	
КонецФункции


#Область Касса

// ищет кассу при импорте - по узлу json-текста
Функция НайтиКассу(Узел, ВнешняяСистема) Экспорт

	рез = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		рез = НайтиКассуПоГУИД(ГУИД, ВнешняяСистема);
	КонецЕсли;
	Возврат рез;
	
КонецФункции

// ищет кассу по ГУИД в мэппинге, если там нет - в справочнике
Функция НайтиКассуПоГУИД(ГУИД, ВнешняяСистема) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ГУИД) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	рез = РегистрыСведений.ксп_МэппингСправочникКассы.ПоМэппингу(ГУИД, ВнешняяСистема);
	Если НЕ ЗначениеЗаполнено(рез) ИЛИ НЕ ЗначениеЗаполнено(рез.ВерсияДанных) Тогда
		рез = Справочники.Кассы.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
	КонецЕсли;
	Возврат рез;
	
КонецФункции

#КонецОбласти

Функция НайтиЭквайринговыйТерминал(Узел, ВнешняяСистема) Экспорт

	рез = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		рез = Справочники.ЭквайринговыеТерминалы.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
	КонецЕсли;
	Возврат Рез;
	
КонецФункции

Функция НайтиСкидкуНаценку(Узел, ВнешняяСистема) Экспорт

	Рез = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		Рез = РегистрыСведений.ксп_МэппингСправочникСкидкиНаценки.ПоМэппингу(ГУИД, ВнешняяСистема);
		Если НЕ ЗначениеЗаполнено(Рез) ИЛИ НЕ ЗначениеЗаполнено(Рез.ВерсияДанных) Тогда
			Рез = Справочники.СкидкиНаценки.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
		КонецЕсли;
	КонецЕсли;
	Возврат Рез;
	
КонецФункции


Функция НайтиБонуснуюПрограмму(Узел, ВнешняяСистема) Экспорт

	Рез = Неопределено;
	ГУИД = "";
	Если узел.Свойство("Ref", ГУИД) Тогда
		Рез = РегистрыСведений.ксп_МэппингСправочникБонусныеПрограммы.ПоМэппингу(ГУИД, ВнешняяСистема);
		Если НЕ ЗначениеЗаполнено(Рез) ИЛИ НЕ ЗначениеЗаполнено(Рез.ВерсияДанных) Тогда
			Рез = Справочники.БонусныеПрограммыЛояльности.ПолучитьСсылку(Новый УникальныйИдентификатор(ГУИД));
		КонецЕсли;
	КонецЕсли;
	Возврат Рез;
	
КонецФункции


// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиВидЗапасовСобственныйТовар(Организация) Экспорт
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВидыЗапасов.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ВидыЗапасов КАК ВидыЗапасов
		|ГДЕ
		|	ВидыЗапасов.Организация = &Организация
		|	И ВидыЗапасов.ТипЗапасов = &ТипЗапасов";
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ТипЗапасов", перечисления.ТипыЗапасов.Товар);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

		
	Возврат Неопределено;
	
КонецФункции


// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиСоздатьОбъектРасчетовСКлиентом(ДокументРасчетовСсылка, Организация) Экспорт
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОбъектыРасчетов.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ОбъектыРасчетов КАК ОбъектыРасчетов
		|ГДЕ                                              
		|	ОбъектыРасчетов.Объект = &ДокументРасчетовСсылка
		|	И ОбъектыРасчетов.ТипРасчетов = &ТипРасчетов
		|	И ОбъектыРасчетов.Организация = &Организация";
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("ДокументРасчетовСсылка", ДокументРасчетовСсылка);
	Запрос.УстановитьПараметр("ТипРасчетов", Перечисления.ТипыРасчетовСПартнерами.РасчетыСКлиентом);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Рез = Неопределено;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Рез = ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	Если НЕ ЗначениеЗаполнено(Рез) Тогда
		
		РезОбк = Справочники.ОбъектыРасчетов.СоздатьЭлемент();
		РезОбк.Организация = Организация;
		РезОбк.Объект = ДокументРасчетовСсылка;
		РезОбк.ТипРасчетов = Перечисления.ТипыРасчетовСПартнерами.РасчетыСКлиентом;
		РезОбк.ТипОбъектаРасчетов = Перечисления.ТипыОбъектовРасчетов.ПлатежВозврат;
		РезОбк.состояние = 0;
		
		ДокРасчОбк = ДокументРасчетовСсылка.ПолучитьОбъект();
		Если ДокРасчОбк.Проведен Тогда
			РезОбк.состояние = 1;
		КонецЕсли;
		Если ДокРасчОбк.ПометкаУдаления Тогда
			РезОбк.состояние = 2;
		КонецЕсли;
		
		
		
		РезОбк.Записать();
		
		Рез = РезОбк.Ссылка;
		
	КонецЕсли;


		
	Возврат Рез;
	
КонецФункции

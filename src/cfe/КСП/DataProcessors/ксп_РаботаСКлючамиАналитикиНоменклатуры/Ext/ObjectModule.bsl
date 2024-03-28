﻿Перем ЗапросПоискаВСправочнике;
Перем ЗапросПоискаВРегистре;



// Использовать этот!!!!! Для заполнения колонки "АналитикаУчетаНоменклатуры" в ТЧ "Товары" (и других)
//
// Параметры:
//	Номенклатура 	- СправочникСсылка.Номенклатура - 
//	Склад		 	- СправочникСсылка.Склады - 
//	Характеристика	- СправочникСсылка.ХарактеристикиНоменклатуры - 
//
// Возвращаемое значение:
//	Тип: СправочникСсылка.КлючиАналитикиУчетаНоменклатуры
//
Функция НайтиСоздатьКлючАналитикиНом(Номенклатура, Склад, Характеристика) Экспорт
	
	Рез = НайтиКлючАналитикиНом(Номенклатура, Склад, Характеристика);

	Если НЕ ЗначениеЗаполнено(Рез) Тогда
		
		 Возврат СоздатьКлючАналитикиНом(Номенклатура, Склад, Характеристика);
		 
	КонецЕсли;		
	
КонецФункции

// Напрямую желательно не использовать
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиКлючАналитикиНом(Номенклатура, Склад, Характеристика) Экспорт
		
	ЗапросПоискаВСправочнике.УстановитьПараметр("МестоХранения", Склад);
	ЗапросПоискаВСправочнике.УстановитьПараметр("Номенклатура", Номенклатура);
	ЗапросПоискаВСправочнике.УстановитьПараметр("ТипМестаХранения", Перечисления.ТипыМестХранения.Склад);
	ЗапросПоискаВСправочнике.УстановитьПараметр("Характеристика", Характеристика);
	ЗапросПоискаВСправочнике.УстановитьПараметр("СкладскаяТерритория", Склад);
	
	РезультатЗапроса = ЗапросПоискаВСправочнике.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.КлючАналитики;
	КонецЦикла;
			
	Возврат Неопределено;
	
КонецФункции

// Только создает ключ аналитики
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция СоздатьКлючАналитикиНом(Номенклатура, Склад, Характеристика) Экспорт
			
	Рез = Справочники.КлючиАналитикиУчетаНоменклатуры.СоздатьЭлемент();
	Рез.МестоХранения = Склад;
	РЕз.Номенклатура = Номенклатура;
	Рез.СкладскаяТерритория = Склад;
	Рез.Наименование = Строка(Номенклатура) + "; " + Строка(Склад);
	Рез.ТипМестаХранения = Перечисления.ТипыМестХранения.Склад;
	Рез.Характеристика = Характеристика;
	
	Рез.ДополнительныеСвойства.Вставить("НеРегистрироватьКОбменуRabbitMQ", Истина);
	
	Рез.Записать();
	Рез = Рез.Ссылка; // переопределим, чтобы не писать лишний код
	
	Если НайтиКлючАналитикиНомВрегистре(Номенклатура, Склад, Характеристика) = Неопределено Тогда
		
	КонецЕсли;
	
	Возврат Рез;
	
КонецФункции   

// Напрямую желательно не использовать
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиКлючАналитикиНомВрегистре(Номенклатура, Склад, Характеристика) Экспорт
		
	ЗапросПоискаВРегистре.УстановитьПараметр("МестоХранения", Склад);
	ЗапросПоискаВРегистре.УстановитьПараметр("Номенклатура", Номенклатура);
	ЗапросПоискаВРегистре.УстановитьПараметр("Характеристика", Характеристика);
	
	РезультатЗапроса = ЗапросПоискаВРегистре.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.КлючАналитики;
	КонецЦикла;
			
	Возврат Неопределено;
	
КонецФункции



ЗапросПоискаВСправочнике = Новый Запрос;
ЗапросПоискаВСправочнике.Текст = 
		"ВЫБРАТЬ
		|	Спр.Ссылка КАК КлючАналитики
		|ИЗ
		|	Справочник.КлючиАналитикиУчетаНоменклатуры КАК Спр
		|ГДЕ
		|	Спр.Номенклатура = &Номенклатура
		|	И Спр.МестоХранения = &МестоХранения
		|	И Спр.Характеристика = &Характеристика
		|	И Спр.ТипМестаХранения = &ТипМестаХранения";


ЗапросПоискаВРегистре = Новый Запрос;
ЗапросПоискаВРегистре.Текст = 
		"ВЫБРАТЬ
		|	Рег.КлючАналитики КАК КлючАналитики
		|ИЗ
		|	РегистрСведений.АналитикаУчетаНоменклатуры КАК Рег
		|ГДЕ
		|	Рег.Номенклатура = &Номенклатура
		|	И Рег.МестоХранения = &МестоХранения
		|	И Рег.Характеристика = &Характеристика";


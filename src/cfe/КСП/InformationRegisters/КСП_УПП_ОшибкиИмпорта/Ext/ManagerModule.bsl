﻿
//ВидДокумента = "";
//Склад = Неопределено;
//СкладОтправитель = Неопределено;
//СкладПолучатель = Неопределено;
//ТекстСообщения = "";
//ЛогикаСклад = Неопределено;
//ЛогикаПеремещения = Неопределено;
//Обработчик = Неопределено;
// РегистрыСведений.КСП_УПП_ОшибкиИмпорта.лог(ВидДокумента, Склад, СкладОтправитель, СкладПолучатель, 
//												ТекстСообщения, ЛогикаСклад, ЛогикаПеремещения, Обработчик);
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
Процедура лог(ВидДокумента, 
	Склад, 
	СкладОтправитель, 
	СкладПолучатель, 
	ТекстСообщения = "", 
	ЛогикаСклад = Неопределено, 
	ЛогикаПеремещения = Неопределено, 
	Обработчик = Неопределено, 
	ПредставлениеДокументаУПП = "",
	НомерДокумента = "",
	ДатаДокумента = Неопределено,
	ОшибкаИсправлена = Ложь,
	ГУИДДокументаУПП = "",
	ЗагруженныйДокумент) экспорт
	
	НЗ = РегистрыСведений.КСП_УПП_ОшибкиИмпорта.СоздатьНаборЗаписей();
	
	НЗ.Отбор.ВидДокумента.Установить(ВидДокумента);
	
	НЗ.Отбор.ГУИДДокументаУПП.Установить(ГУИДДокументаУПП);
	
	НовСтр = НЗ.Добавить();
	НовСтр.ВидДокумента = ВидДокумента;
	НовСтр.Склад = Склад;
	НовСтр.СкладОтправитель = СкладОтправитель;
	НовСтр.СкладПолучатель = СкладПолучатель;
	НовСтр.НомерДокумента = НомерДокумента;
	НовСтр.ДатаДокумента = ДатаДокумента;
	
	НовСтр.ТекстСообщения = ТекстСообщения;
	НовСтр.ЛогикаСклад = ЛогикаСклад; 
	НовСтр.ЛогикаПеремещения = ЛогикаПеремещения; 
	НовСтр.Обработчик = Обработчик;
	НовСтр.ПредставлениеДокументаУПП = ПредставлениеДокументаУПП;
	НовСтр.ВремяСобытия = ТекущаяДатаСеанса();
	НовСтр.ОшибкаИсправлена = ОшибкаИсправлена;
	НовСтр.ГУИДДокументаУПП = ГУИДДокументаУПП;
	НовСтр.ЗагруженныйДокумент = ЗагруженныйДокумент;
	
	
	НЗ.Записать();
		
КонецПроцедуры

﻿
#Область УсловияЗапуска

Функция ЕстьЗапретНаЗапускРегламентногоЗадания() Экспорт
		
	ЗначениеКонстанты = Ложь;
	
	Спр = Справочники.мис_СвойстваМетодов.НайтиПоНаименованию("мис_Планировщик");
	
	Если ЗначениеЗаполнено(Спр) Тогда
		ТЧ = Спр.Константы.Выгрузить();
		СтрокаТЧ =  ТЧ.Найти("Терминатор","Имя");
		Если СтрокаТЧ <> Неопределено Тогда
			Попытка
				ЗначениеКонстанты = СтрокаТЧ.Значение.Получить();
			Исключение
				ЗначениеКонстанты = Ложь;
			КонецПопытки;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ТипЗнч(ЗначениеКонстанты) <> Тип("Булево") Тогда
		ЗначениеКонстанты = Ложь;
	КонецЕсли;
	
	Возврат ЗначениеКонстанты; // Истина запрещает запуск
	
КонецФункции

// Параметры
//	Флаг - булево - ИСТИНА - выключить регл задание, ЛОЖЬ - включить
//
Процедура УстановитьЗапретНаЗапускРегламентногоЗадания(Знач Флаг) Экспорт
	
	ТекущееЗначение = ЕстьЗапретНаЗапускРегламентногоЗадания();
	
	Если Флаг = ТекущееЗначение Тогда
		Возврат;
	КонецЕсли;
	
	Спр = Справочники.мис_СвойстваМетодов.НайтиПоНаименованию("мис_Планировщик");
	
	Если ЗначениеЗаполнено(Спр) Тогда
		Для Каждого СтрокаТЧ Из Спр.Константы Цикл
			Если СтрокаТЧ.Имя = "Терминатор" Тогда
				Попытка
					СпрОбъект = Спр.ПолучитьОбъект();
				Исключение
					ЗаписьЖурналаРегистрации("мис_Планировщик",УровеньЖурналаРегистрации.Ошибка,
						,Спр,"Изменение запрета не выполнено! Не удалось заблокировать элемент справочника мис_СвойстваМетодов с наименованием 'мис_Планировщик'! Подробности: "+ОписаниеОшибки());
					Возврат;
				КонецПопытки;
				СпрОбъект.Константы[СтрокаТЧ.НомерСтроки-1].Значение = Новый ХранилищеЗначения(Флаг);
				Попытка
					СпрОбъект.Записать();
				Исключение
					ЗаписьЖурналаРегистрации("мис_Планировщик",УровеньЖурналаРегистрации.Ошибка,
						,Спр,"Изменение запрета не выполнено! Не удалось записать элемент справочника мис_СвойстваМетодов с наименованием 'мис_Планировщик'! Подробности: "+ОписаниеОшибки());
					Возврат;
				КонецПопытки;
				
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

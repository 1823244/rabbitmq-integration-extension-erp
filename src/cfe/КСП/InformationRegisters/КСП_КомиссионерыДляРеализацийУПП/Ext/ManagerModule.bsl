﻿
// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ЭтоКомиссионер(ВнешняяСистема, Контрагент, Договор, ДатаДок) Экспорт
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КСП_КомиссионерыДляРеализацийУПП.ДатаНачала КАК ДатаНачала,
		|	КСП_КомиссионерыДляРеализацийУПП.ДатаОкончания КАК ДатаОкончания
		|ИЗ
		|	РегистрСведений.КСП_КомиссионерыДляРеализацийУПП КАК КСП_КомиссионерыДляРеализацийУПП
		|ГДЕ
		|	КСП_КомиссионерыДляРеализацийУПП.ВнешняяСистема = &ВнешняяСистема
		|	И КСП_КомиссионерыДляРеализацийУПП.Контрагент = &Контрагент
		|	И КСП_КомиссионерыДляРеализацийУПП.Договор = &Договор";
	
	Запрос.УстановитьПараметр("ВнешняяСистема", ВнешняяСистема);
	Запрос.УстановитьПараметр("Договор", Договор);
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если ЗначениеЗаполнено(Выборка.ДатаНачала) Тогда
			Если НЕ ЗначениеЗаполнено(Выборка.ДатаОкончания) Тогда
				Возврат Истина;
			Иначе 
				Если ДатаДок >= Выборка.ДатаНачала Тогда
					Возврат Истина;
				КонецЕсли;
			КонецЕсли;
		Иначе 
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	Возврат Ложь;
	
КонецФункции

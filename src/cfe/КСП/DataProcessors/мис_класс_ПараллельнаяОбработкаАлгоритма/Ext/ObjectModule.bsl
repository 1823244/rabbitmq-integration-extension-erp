﻿// исходная коллекция с данными. РезультатЗапроса, ТаблицаЗначений, СписокЗначений, Массив, рекордсет АДО
// todo: файл XML со списком однотипных тэгов
// todo: файл JSON со списком однотипных тэгов (или массивом)
Перем Коллекция;
Перем RecordSet; // для большей читаемости кода. То же, что и "Коллекция", когда работаем с АДО.
// лог
Перем ИдВызова;
// отключение параллельности и работа в одном потоке
Перем Отладка;
//
Перем РАЗМЕР_ПАКЕТА;
//
Перем ФорсироватьФоновоеВыполнение;// булево. для отладки
//
Перем ИмяМетодаФоновогоЗадания; // строка
// параметры метода, запускаемого в фоне, кроме обязательных трех
Перем ДопПараметры; // структура
//
Перем ОписаниеФоновогоЗадания;// для консоли фоновых заданий
//
Перем ПаузаМеждуПотоками; //число секунд
//
Перем ПаузаМеждуСтрокамиРекордсета;
//
Перем ЛимитФЗ;//число, кол фоновых заданий
//
// Колонки должны быть расположены так же, как рекордсете АДО. заполнление идет по индексу
Перем мТЗРекордсет; //шаблон рекордсета


#Область ПрограммныйИнтерфейс


// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: объект обработки
//
Функция Конструктор(пИдВызова = Неопределено, пОтладка = Ложь) Экспорт
	
	РАЗМЕР_ПАКЕТА 		= Справочники.мис_СвойстваМетодов
						  .ПолучитьРазмерПакета(ИмяМетодаФоновогоЗадания);
	Если не ЗначениеЗаполнено(РАЗМЕР_ПАКЕТА) Тогда
		РАЗМЕР_ПАКЕТА = 1000;
	КонецЕсли; 
	ПаузаМеждуПотоками 	= 1;//в секундах
	Отладка 			= пОтладка;
	ДопПараметры 		= Новый Структура;
	Если пИдВызова <> Неопределено Тогда
		ИдВызова = пИдВызова;
	КонецЕсли; 

	Возврат ЭтотОбъект;
	
КонецФункции
 
// Точка входа. Определяет тип коллекции и запускает нужный метод для обработки
Процедура ОбработатьПараллельно() Экспорт
	
	_ВремРазмерПакета = Справочники.мис_СвойстваМетодов.ПолучитьРазмерПакета(ИмяМетодаФоновогоЗадания);
	Если ТипЗнч(_ВремРазмерПакета) = Тип("Число") Тогда
		РАЗМЕР_ПАКЕТА = _ВремРазмерПакета;
	КонецЕсли; 
	
	Если ТипЗнч(Коллекция) = Тип("РезультатЗапроса") Тогда
		ОбработатьПараллельноРезультатЗапроса();
	ИначеЕсли ТипЗнч(Коллекция) = Тип("ТаблицаЗначений") Тогда
		ОбработатьПараллельноТаблицуЗначений();
	ИначеЕсли ТипЗнч(Коллекция) = Тип("СписокЗначений") Тогда
		ОбработатьПараллельноСписокЗначений();
	ИначеЕсли ТипЗнч(Коллекция) = Тип("Массив") Тогда
		ОбработатьПараллельноМассив();
	КонецЕсли;
	
КонецПроцедуры

// Тип АДО-рекордсета = COMОбъект, поэтому требуется отдельный метод в качестве интерфейса
Процедура ОбработатьПараллельноADORecordset() Экспорт
	
	_ВремРазмерПакета = Справочники.мис_СвойстваМетодов.ПолучитьРазмерПакета(ИмяМетодаФоновогоЗадания);
	Если ТипЗнч(_ВремРазмерПакета) = Тип("Число") Тогда
		РАЗМЕР_ПАКЕТА = _ВремРазмерПакета;
	КонецЕсли; 
	
	ОбработатьПараллельноРекордсетАДО();
	
КонецПроцедуры



#КонецОбласти



#Область ОсновнойАлгоритм

Процедура ОбработатьПараллельноРезультатЗапроса()
	
	СчЗаданий = 0;
	
	// у любого метода, запускаемого в фоне, должно быть 4 параметра:
	// идВызова
	// ТЗРекордсет - таблица значений - колонки повторяют поля запроса
	// счЗаданий - число - номер фонового задания
	// ДопПараметры - структура - остальные параметры метода
	
	Выборка 	= Коллекция.Выбрать();
	мис_ЛоггерСервер.Информация(ИДВызова, "ИНФО", "Количество строк в выборке = " + строка(Выборка.Количество()));
	
	АдресОтветаОбщий = "";
	ДопПараметры.Свойство("АдресОтвета", АдресОтветаОбщий);

	МассивАдресовОтветовФЗ = Новый Массив;
	
	ЕстьЗаписи 	= Выборка.Следующий();
	Пока ЕстьЗаписи Цикл
		
		// Во время длительных процессов может потребоваться прервать выполнение.
		// Проверим константу в справочнике константы процедур. Нужно проверять все задания по цепочке
		Если мис_УправлениеЗаданиямиСлужебный.ЕстьЗапретНаЗапускРегламентногоЗадания() Тогда
			//клог.Инфо("Обработка регламентных заданий завершена. Обнаружен запрет на запуск регл. заданий");
			Прервать;	
		КонецЕсли;
		
		ТЗРекордсет = СформироватьПакетИзРезультатаЗапроса(Выборка, ЕстьЗаписи, Коллекция);
		
		СчЗаданий = СчЗаданий + 1;
		
		МассивПараметровМетодаФЗ = Новый Массив;
		
		// у любого метода, запускаемого в фоне, должно быть 4 параметра:
		МассивПараметровМетодаФЗ.Добавить(ИДВызова);
		МассивПараметровМетодаФЗ.Добавить(ТЗРекордсет);
		МассивПараметровМетодаФЗ.Добавить(СчЗаданий);
		МассивПараметровМетодаФЗ.Добавить(ДопПараметры);
		
		АдресОтвета = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
        ДопПараметры.Вставить("АдресОтвета", АдресОтвета);
		МассивАдресовОтветовФЗ.Добавить(АдресОтвета);
			
		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) ИЛИ ФорсироватьФоновоеВыполнение Тогда
			
			///////////////////////////////////
			// Запуск метода в фоновом задании
			
			ОписаниеЗадачи = Строка(ОписаниеФоновогоЗадания) +
				". Фоновое задание №" + Строка(СчЗаданий) +
				", сеанс=" + Строка(НомерСоединенияИнформационнойБазы());
			
			////{ Без прокси. Можно использовать только методы из общих модулей
			//Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
			//	ИмяМетодаФоновогоЗадания, 
			//	МассивПараметровМетодаФЗ, 
			//	ОписаниеЗадачи, 
			//	ЕстьЗаписи);
			//}
			
			//{ Через прокси. Иначе не будут доступны для выполнения в фоне методы в модулях менеджеров
			// (можно будет использовать только методы из общих модулей)
			_Параметры = Новый Массив;
			_Параметры.Добавить(ИмяМетодаФоновогоЗадания);
			_Параметры.Добавить(МассивПараметровМетодаФЗ);
			
			мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
				"мис_УправлениеЗаданиямиСервер.ПроксиМетодДляЗапускаВФоне", 
				_Параметры, 
				ОписаниеЗадачи, 
				ЕстьЗаписи);
			//}	
			
		Иначе
			///////////////////////////////////
			// Запуск всех пакетов в одном потоке, последовательно
			// способ вызова для файловой базы
			ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяМетодаФоновогоЗадания,МассивПараметровМетодаФЗ);
			
		КонецЕсли;					
		
//		СУУ_УниверсальныеСервер.Пауза(ПаузаМеждуПотоками);
		
	КонецЦикла; 
	
	Если ЗначениеЗаполнено(АдресОтветаОбщий) Тогда
		ПоместитьВоВременноеХранилище(МассивАдресовОтветовФЗ, АдресОтветаОбщий);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьПараллельноТаблицуЗначений()
	
	СчЗаданий = 0;
	
	// у любого метода, запускаемого в фоне, должно быть 4 параметра:
	// идВызова
	// ТЗРекордсет - таблица значений - колонки повторяют поля запроса
	// счЗаданий - число - номер фонового задания
	// ДопПараметры - структура - остальные параметры метода
	
	мис_ЛоггерСервер.Информация(ИДВызова, "ИНФО", "Количество строк в таблице = " + Строка(Коллекция.Количество()));
	
	АдресОтветаОбщий = "";
	ДопПараметры.Свойство("АдресОтвета", АдресОтветаОбщий);

	МассивАдресовОтветовФЗ = Новый Массив;
	
	сч = 0;
	ЕстьЗаписи = сч < Коллекция.Количество();
	Пока ЕстьЗаписи Цикл
		
		// Во время длительных процессов может потребоваться прервать выполнение.
		// Проверим константу в справочнике константы процедур. Нужно проверять все задания по цепочке
		Если мис_УправлениеЗаданиямиСлужебный.ЕстьЗапретНаЗапускРегламентногоЗадания() Тогда
			//клог.Инфо("Обработка регламентных заданий завершена. Обнаружен запрет на запуск регл. заданий");
			Прервать;	
		КонецЕсли;
		
		ТЗРекордсет = СформироватьПакетИзТаблицыЗначений(Коллекция, ЕстьЗаписи, сч);
		
		СчЗаданий = СчЗаданий + 1;
		
		МассивПараметровМетодаФЗ = Новый Массив;
		
		// у любого метода, запускаемого в фоне, должно быть 4 параметра:
		МассивПараметровМетодаФЗ.Добавить(ИДВызова);
		МассивПараметровМетодаФЗ.Добавить(ТЗРекордсет);
		МассивПараметровМетодаФЗ.Добавить(СчЗаданий);
		МассивПараметровМетодаФЗ.Добавить(ДопПараметры);
		
		АдресОтвета = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
        ДопПараметры.Вставить("АдресОтвета", АдресОтвета);
		МассивАдресовОтветовФЗ.Добавить(АдресОтвета);
			
		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) ИЛИ ФорсироватьФоновоеВыполнение Тогда
			
			///////////////////////////////////
			// Запуск метода в фоновом задании
			
			ОписаниеЗадачи = Строка(ОписаниеФоновогоЗадания) +
				". Фоновое задание №" + Строка(СчЗаданий) +
				", сеанс=" + Строка(НомерСоединенияИнформационнойБазы());
			
			////{ Без прокси. Можно использовать только методы из общих модулей
			//Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
			//	ИмяМетодаФоновогоЗадания, 
			//	МассивПараметровМетодаФЗ, 
			//	ОписаниеЗадачи, 
			//	ЕстьЗаписи);
			//}
			
			//{ Через прокси. Иначе не будут доступны для выполнения в фоне методы в модулях менеджеров
			// (можно будет использовать только методы из общих модулей)
			_Параметры = Новый Массив;
			_Параметры.Добавить(ИмяМетодаФоновогоЗадания);
			_Параметры.Добавить(МассивПараметровМетодаФЗ);
			
			мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
				"мис_УправлениеЗаданиямиСервер.ПроксиМетодДляЗапускаВФоне", 
				_Параметры, 
				ОписаниеЗадачи, 
				ЕстьЗаписи);
			//}	
			
		Иначе
			///////////////////////////////////
			// Запуск всех пакетов в одном потоке, последовательно
			// способ вызова для файловой базы
			ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяМетодаФоновогоЗадания,МассивПараметровМетодаФЗ);
			
		КонецЕсли;					
		
//		СУУ_УниверсальныеСервер.Пауза(ПаузаМеждуПотоками);
		
	КонецЦикла; 
	
	Если ЗначениеЗаполнено(АдресОтветаОбщий) Тогда
		ПоместитьВоВременноеХранилище(МассивАдресовОтветовФЗ, АдресОтветаОбщий);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьПараллельноРекордсетАДО()
	
	КоличествоВРекордсетеВсего = 0; // потом придумать, что делать с этим счетчиком
	
	СчЗаданий = 0;
	
	АдресОтветаОбщий = "";
	ДопПараметры.Свойство("АдресОтвета", АдресОтветаОбщий);

	МассивАдресовОтветовФЗ = Новый Массив;
	
	
	Пока НЕ RecordSet.EOF Цикл

		// Во время длительных процессов может потребоваться прервать выполнение.
		// Проверим константу в справочнике константы процедур. Нужно проверять все задания по цепочке
		Если мис_УправлениеЗаданиямиСлужебный.ЕстьЗапретНаЗапускРегламентногоЗадания() Тогда
			//клог.Инфо("Обработка регламентных заданий завершена. Обнаружен запрет на запуск регл. заданий");
			Прервать;	
		КонецЕсли;
		
		ТЗРекордсет 			= СформироватьПакетИзРекордсетаАДО();
		СчЗаданий				= СчЗаданий+1;
		МассивПараметровМетодаФЗ= Новый Массив;
		
		// у любого метода, запускаемого в фоне, должно быть 4 параметра:
		МассивПараметровМетодаФЗ.Добавить(ИДВызова);
		// Так нельзя! Ограничение платформы: невозможно передать значение через хранилище 
		//в запускаемое фоновое задание. Можно только в обратную сторону.
		//Адрес = ПоместитьВоВременноеХранилище(ТЗРекордсет, Новый УникальныйИдентификатор);
		//МассивПараметровМетодаФЗ.Добавить(Адрес);
		МассивПараметровМетодаФЗ.Добавить(ТЗРекордсет);
		МассивПараметровМетодаФЗ.Добавить(СчЗаданий);
		МассивПараметровМетодаФЗ.Добавить(ДопПараметры);
		
		АдресОтвета = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
        ДопПараметры.Вставить("АдресОтвета", АдресОтвета);
		МассивАдресовОтветовФЗ.Добавить(АдресОтвета);
			
		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) ИЛИ ФорсироватьФоновоеВыполнение Тогда
			
			///////////////////////////////////
			// Запуск метода в фоновом задании
			
			ОписаниеЗадачи = Строка(ОписаниеФоновогоЗадания) +
				". Фоновое задание №" + Строка(СчЗаданий) +
				", сеанс=" + Строка(НомерСоединенияИнформационнойБазы());
			
			////{ Без прокси. Можно использовать только методы из общих модулей
			//Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
			//	ИмяМетодаФоновогоЗадания, 
			//	МассивПараметровМетодаФЗ, 
			//	ОписаниеЗадачи, 
			//	ЕстьЗаписи);
			////}
			
			//{ Через прокси. Иначе не будут доступны для выполнения в фоне методы в модулях менеджеров
			// (можно будет использовать только методы из общих модулей)
			_Параметры = Новый Массив;
			_Параметры.Добавить(ИмяМетодаФоновогоЗадания);
			_Параметры.Добавить(МассивПараметровМетодаФЗ);
			
			мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
				"мис_УправлениеЗаданиямиСервер.ПроксиМетодДляЗапускаВФоне", 
				_Параметры, 
				ОписаниеЗадачи, 
				НЕ RecordSet.EOF);
			//}	
			
		Иначе
			///////////////////////////////////
			// Запуск всех пакетов в одном потоке, последовательно.
			// Способ вызова для файловой базы
			
			ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяМетодаФоновогоЗадания,МассивПараметровМетодаФЗ);
			
		КонецЕсли;					
		
		//СУУ_УниверсальныеСервер.Пауза(ПаузаМеждуПотоками);				
			
	КонецЦикла;
	Если ЗначениеЗаполнено(АдресОтветаОбщий) Тогда
		ПоместитьВоВременноеХранилище(МассивАдресовОтветовФЗ, АдресОтветаОбщий);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьПараллельноСписокЗначений()
	
	СчЗаданий = 0;
	
	// у любого метода, запускаемого в фоне, должно быть 4 параметра:
	// идВызова
	// ТЗРекордсет - таблица значений - колонки повторяют поля запроса
	// счЗаданий - число - номер фонового задания
	// ДопПараметры - структура - остальные параметры метода
	
	мис_ЛоггерСервер.Информация(ИДВызова, "ИНФО", "Количество строк в списке значений = " + Строка(Коллекция.Количество()));
	
	АдресОтветаОбщий = "";
	ДопПараметры.Свойство("АдресОтвета", АдресОтветаОбщий);

	МассивАдресовОтветовФЗ = Новый Массив;
	
	сч = 0;
	ЕстьЗаписи = сч < Коллекция.Количество();
	Пока ЕстьЗаписи Цикл
		
		// Во время длительных процессов может потребоваться прервать выполнение.
		// Проверим константу в справочнике константы процедур. Нужно проверять все задания по цепочке
		Если мис_УправлениеЗаданиямиСлужебный.ЕстьЗапретНаЗапускРегламентногоЗадания() Тогда
			//клог.Инфо("Обработка регламентных заданий завершена. Обнаружен запрет на запуск регл. заданий");
			Прервать;	
		КонецЕсли;
		
		ТЗРекордсет = СформироватьПакетИзСпискаЗначений(Коллекция, ЕстьЗаписи, сч);
		
		СчЗаданий = СчЗаданий + 1;
		
		МассивПараметровМетодаФЗ = Новый Массив;
		
		// у любого метода, запускаемого в фоне, должно быть 4 параметра:
		МассивПараметровМетодаФЗ.Добавить(ИДВызова);
		МассивПараметровМетодаФЗ.Добавить(ТЗРекордсет);
		МассивПараметровМетодаФЗ.Добавить(СчЗаданий);
		МассивПараметровМетодаФЗ.Добавить(ДопПараметры);
		
		АдресОтвета = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
        ДопПараметры.Вставить("АдресОтвета", АдресОтвета);
		МассивАдресовОтветовФЗ.Добавить(АдресОтвета);
			
		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) ИЛИ ФорсироватьФоновоеВыполнение Тогда
			
			///////////////////////////////////
			// Запуск метода в фоновом задании
			
			ОписаниеЗадачи = Строка(ОписаниеФоновогоЗадания) +
				". Фоновое задание №" + Строка(СчЗаданий) +
				", сеанс=" + Строка(НомерСоединенияИнформационнойБазы());
			
			////{ Без прокси. Можно использовать только методы из общих модулей
			//Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
			//	ИмяМетодаФоновогоЗадания, 
			//	МассивПараметровМетодаФЗ, 
			//	ОписаниеЗадачи, 
			//	ЕстьЗаписи);
			//}
			
			//{ Через прокси. Иначе не будут доступны для выполнения в фоне методы в модулях менеджеров
			// (можно будет использовать только методы из общих модулей)
			_Параметры = Новый Массив;
			_Параметры.Добавить(ИмяМетодаФоновогоЗадания);
			_Параметры.Добавить(МассивПараметровМетодаФЗ);
			
			мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
				"мис_УправлениеЗаданиямиСервер.ПроксиМетодДляЗапускаВФоне", 
				_Параметры, 
				ОписаниеЗадачи, 
				ЕстьЗаписи);
			//}	
			
		Иначе
			///////////////////////////////////
			// Запуск всех пакетов в одном потоке, последовательно
			// способ вызова для файловой базы
			ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяМетодаФоновогоЗадания,МассивПараметровМетодаФЗ);
			
		КонецЕсли;					
		
		//СУУ_УниверсальныеСервер.Пауза(ПаузаМеждуПотоками);
		
	КонецЦикла; 
	
	Если ЗначениеЗаполнено(АдресОтветаОбщий) Тогда
		ПоместитьВоВременноеХранилище(МассивАдресовОтветовФЗ, АдресОтветаОбщий);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьПараллельноМассив()
	
	СчЗаданий = 0;
	
	// у любого метода, запускаемого в фоне, должно быть 4 параметра:
	// идВызова
	// ТЗРекордсет - таблица значений - колонки повторяют поля запроса
	// счЗаданий - число - номер фонового задания
	// ДопПараметры - структура - остальные параметры метода
	
	мис_ЛоггерСервер.Информация(ИДВызова, "ИНФО", "Количество элементов в массиве = " + Строка(Коллекция.Количество()));
	
	АдресОтветаОбщий = "";
	ДопПараметры.Свойство("АдресОтвета", АдресОтветаОбщий);

	МассивАдресовОтветовФЗ = Новый Массив;
	
	сч = 0;
	ЕстьЗаписи = сч < Коллекция.Количество();
	Пока ЕстьЗаписи Цикл
		
		// Во время длительных процессов может потребоваться прервать выполнение.
		// Проверим константу в справочнике константы процедур. Нужно проверять все задания по цепочке
		Если мис_УправлениеЗаданиямиСлужебный.ЕстьЗапретНаЗапускРегламентногоЗадания() Тогда
			//клог.Инфо("Обработка регламентных заданий завершена. Обнаружен запрет на запуск регл. заданий");
			Прервать;	
		КонецЕсли;
		
		ТЗРекордсет = СформироватьПакетИзМассива(Коллекция, ЕстьЗаписи, сч);
		
		СчЗаданий = СчЗаданий + 1;
		
		МассивПараметровМетодаФЗ = Новый Массив;
		
		// у любого метода, запускаемого в фоне, должно быть 4 параметра:
		МассивПараметровМетодаФЗ.Добавить(ИДВызова);
		МассивПараметровМетодаФЗ.Добавить(ТЗРекордсет);
		МассивПараметровМетодаФЗ.Добавить(СчЗаданий);
		МассивПараметровМетодаФЗ.Добавить(ДопПараметры);
		
		АдресОтвета = ПоместитьВоВременноеХранилище(Неопределено, Новый УникальныйИдентификатор);
        ДопПараметры.Вставить("АдресОтвета", АдресОтвета);
		МассивАдресовОтветовФЗ.Добавить(АдресОтвета);
			
		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) ИЛИ ФорсироватьФоновоеВыполнение Тогда
			
			///////////////////////////////////
			// Запуск метода в фоновом задании
			
			ОписаниеЗадачи = Строка(ОписаниеФоновогоЗадания) +
				". Фоновое задание №" + Строка(СчЗаданий) +
				", сеанс=" + Строка(НомерСоединенияИнформационнойБазы());
			
			////{ Без прокси. Можно использовать только методы из общих модулей
			//Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
			//	ИмяМетодаФоновогоЗадания, 
			//	МассивПараметровМетодаФЗ, 
			//	ОписаниеЗадачи, 
			//	ЕстьЗаписи);
			//}
			
			//{ Через прокси. Иначе не будут доступны для выполнения в фоне методы в модулях менеджеров
			// (можно будет использовать только методы из общих модулей)
			_Параметры = Новый Массив;
			_Параметры.Добавить(ИмяМетодаФоновогоЗадания);
			_Параметры.Добавить(МассивПараметровМетодаФЗ);
			
			мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова,
				"мис_УправлениеЗаданиямиСервер.ПроксиМетодДляЗапускаВФоне", 
				_Параметры, 
				ОписаниеЗадачи, 
				ЕстьЗаписи);
			//}	
			
		Иначе
			///////////////////////////////////
			// Запуск всех пакетов в одном потоке, последовательно
			// способ вызова для файловой базы
			ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяМетодаФоновогоЗадания,МассивПараметровМетодаФЗ);
			
		КонецЕсли;					
		
		//СУУ_УниверсальныеСервер.Пауза(ПаузаМеждуПотоками);
		
	КонецЦикла; 
	
	Если ЗначениеЗаполнено(АдресОтветаОбщий) Тогда
		ПоместитьВоВременноеХранилище(МассивАдресовОтветовФЗ, АдресОтветаОбщий);
	КонецЕсли;
	
КонецПроцедуры


#КонецОбласти

#Область Сеттеры

Функция сетКоллекция(КоллекцияПараметр) Экспорт
	Коллекция = КоллекцияПараметр;
	RecordSet = КоллекцияПараметр;//для большей наглядности
	Возврат ЭтотОбъект;
КонецФункции
	
Функция сетИдВызова(ИдВызоваПараметр) Экспорт
	ИдВызова = ИдВызоваПараметр;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетОтладка(ОтладкаПараметр) Экспорт
	Отладка = ОтладкаПараметр;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетРазмерПакета(РазмерПакетаПараметр) Экспорт
	Если ЗначениеЗаполнено(РазмерПакетаПараметр) Тогда
		РАЗМЕР_ПАКЕТА = РазмерПакетаПараметр;
	КонецЕсли;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетИмяМетодаФоновогоЗадания(ИмяМетодаФоновогоЗаданияПараметр) Экспорт
	ИмяМетодаФоновогоЗадания = ИмяМетодаФоновогоЗаданияПараметр;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетДопПараметры(ДопПараметрыПараметр) Экспорт
	ДопПараметры = ДопПараметрыПараметр;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетОписаниеФоновогоЗадания(ОписаниеФоновогоЗаданияПараметр) Экспорт
	ОписаниеФоновогоЗадания = ОписаниеФоновогоЗаданияПараметр;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетПауза(Секунд) Экспорт
	ПаузаМеждуПотоками = Секунд;
	Возврат ЭтотОбъект;
КонецФункции

Функция сетЛимитФЗ(пЛимитФЗ) Экспорт
	ЛимитФЗ = пЛимитФЗ;
	Возврат ЭтотОбъект;
КонецФункции

// Параметры
//	пТЗРекордсет - строка - ЗначениеВСтрокуВнутр для ТЗ
Функция сетШаблонТЗРекордсет(пТЗРекордсет) Экспорт
	
	Если ЗначениеЗаполнено(пТЗРекордсет) Тогда
		мТЗРекордсет = ЗначениеИзСтрокиВнутр(пТЗРекордсет);
	КонецЕсли;
	
	Возврат ЭтотОбъект;
КонецФункции
 

#КонецОбласти

#Область Геттеры

#КонецОбласти

#Область Служебные



Функция СформироватьПакетИзРекордсетаАДО()
	
	КолвоКолонок = RecordSet.Fields.Count;
	
	КолВПакете = 0;
	
	мис_AdoConnection = Обработки.мис_AdoConnection.Создать();
	
	Если мТЗРекордсет=Неопределено Тогда
		ТЗРекордсет = мис_AdoConnection.ПолучитьПустойТЗРекордсетИзАДОРекордсета(RecordSet);
	Иначе 
		ТЗРекордсет = мТЗРекордсет.СкопироватьКолонки();
	КонецЕсли;
	
	
	Пока НЕ RecordSet.EOF И КолВПакете < РАЗМЕР_ПАКЕТА Цикл
		
		//// Шаблон условия пропуска строк. Не забываем про MoveNext()!!!!
		//Если Условие не выполняется Тогда
		//	RecordSet.MoveNext();
		//	Продолжить;
		//КонецЕсли;
		
		КолВПакете=КолВПакете+1;
		
		ДобавитьСтрокуВТЗРекордсет(ТЗРекордсет, RecordSet);//добавить и заполнить
		
		RecordSet.MoveNext();
		
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

// Добавляет строку в ТЗ и заполняет ее из рекордсета АДО
//
// Параметры:
//	ТЗРекордсет 	- Таблица значений - 
//	Recordset		- АДО рекордсет - 
//
// Возвращаемое значение:
//	Тип: строка ТЗ
//
Функция ДобавитьСтрокуВТЗРекордсет(ТЗРекордсет, Recordset) Экспорт
	
	КолвоКолонок = RecordSet.Fields.Count;
	
	НовСтр = ТЗРекордсет.Добавить();
	Для сч = 0 по КолвоКолонок-1 Цикл     
		Если ТипЗнч(RecordSet.Fields.Item(сч).Value) = тип("COMSafeArray") Тогда
			НовСтр[сч] 		 = RecordSet.Fields.Item(сч).Value.Выгрузить();
		Иначе
			НовСтр[сч] 		 = RecordSet.Fields.Item(сч).Value;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НовСтр;
	
КонецФункции


#КонецОбласти

#Область StaticMethods

// Наполняет пустой ТЗРекордсет из ТЗ, создавая таким образом
// пакет для обработки в фоне
// Параметры
//	ТЗ - исходная ТЗ
Функция СформироватьПакетИзТаблицыЗначений(ТЗ, ЕстьЗаписи, сч) Экспорт
	
	КолВПакете = 0;
	ТЗРекордсет = ТЗ.СкопироватьКолонки();
	Пока ЕстьЗаписи И КолВПакете < РАЗМЕР_ПАКЕТА Цикл

		КолВПакете 		= КолВПакете + 1;
		НовСтр			= ТЗРекордсет.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр, ТЗ[сч]);
		
		сч 				= сч + 1;
		ЕстьЗаписи = сч < ТЗ.Количество();
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

// Наполняет пустой ТЗРекордсет из Масива, создавая таким образом
// пакет для обработки в фоне
// Параметры
//	Массив - исходный массив
Функция СформироватьПакетИзМассива(Массив, ЕстьЗаписи, сч) Экспорт
	
	КолВПакете = 0;
	ТЗРекордсет = Новый ТаблицаЗначений;
	ТЗРекордсет.Колонки.Добавить("_Элемент");
	Пока ЕстьЗаписи И КолВПакете < РАЗМЕР_ПАКЕТА Цикл

		КолВПакете 		= КолВПакете + 1;
		НовСтр			= ТЗРекордсет.Добавить();
		НовСтр._Элемент = Массив[сч];
		
		сч 				= сч + 1;
		ЕстьЗаписи = сч < Массив.Количество();
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

// Наполняет пустой ТЗРекордсет из Списка значений, создавая таким образом
// пакет для обработки в фоне
// Параметры
//	СЗ - исходный СписокЗначений
Функция СформироватьПакетИзСпискаЗначений(СЗ, ЕстьЗаписи, сч) Экспорт
	
	КолВПакете = 0;
	ТЗРекордсет = Новый ТаблицаЗначений;
	ТЗРекордсет.Колонки.Добавить("_Элемент");
	Пока ЕстьЗаписи И КолВПакете < РАЗМЕР_ПАКЕТА Цикл

		КолВПакете 		= КолВПакете + 1;
		НовСтр			= ТЗРекордсет.Добавить();
		НовСтр._Элемент = СЗ[сч].Значение;
		
		сч 				= сч + 1;
		ЕстьЗаписи = сч < СЗ.Количество();
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

// Пустая ТЗ нужна для того, чтобы наполнять ее при обходе результата запроса
// и передавать в фоновое задание.
Функция ПолучитьПустойТЗРекордсетИзРезультатаЗапроса(РезультатЗапроса) Экспорт
	
	ТЗРекордсет = Новый ТаблицаЗначений;
	Для Каждого Кол Из РезультатЗапроса.Колонки Цикл //Коллекция - это РезультатЗапроса
		ТЗРекордсет.Колонки.Добавить(Кол.Имя);
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

// Наполняет пустой ТЗРекордсет из результата запроса, создавая таким образом
// пакет для обработки в фоне
Функция СформироватьПакетИзРезультатаЗапроса(Выборка, ЕстьЗаписи, Коллекция) Экспорт
	
	КолВПакете = 0;
	ТЗРекордсет = ПолучитьПустойТЗРекордсетИзРезультатаЗапроса(Коллекция);
		
	Пока ЕстьЗаписи И КолВПакете < РАЗМЕР_ПАКЕТА Цикл
		КолВПакете 		= КолВПакете + 1;
		НовСтр			= ТЗРекордсет.Добавить();
		ЗаполнитьЗначенияСвойств(НовСтр, Выборка);
		ЕстьЗаписи		= Выборка.Следующий();
	КонецЦикла;
	
	Возврат ТЗРекордсет;
	
КонецФункции

#КонецОбласти


// init

//Коллекция = Неопределено;
ФорсироватьФоновоеВыполнение = Ложь;



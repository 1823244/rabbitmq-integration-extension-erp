﻿
Функция МожноВыполнитьВФоне(Отладка = Ложь) Экспорт
	
	МожноВыполнитьПараллельно = ПараметрыСеанса.мис_ЭтоСервернаяБаза И (Отладка <> Истина) И НЕ ОбщегоНазначения.РежимОтладки();
	
	Возврат МожноВыполнитьПараллельно;
	
КонецФункции



// Меняет тип колонки из числового в строковый
//
// Параметры:
//	ТЗРекордсет 	- таблица значений - 
//	ИмяКолонки 		- строка - 
//
Процедура КонвертироватьКолонкуВСтроковыйТип(ТЗРекордсет, ИмяКолонки) Экспорт
	
	ИмяВременнойКолонки = "_"+СтрЗаменить(Строка(Новый УникальныйИдентификатор()),"-","_");
	
	ТЗРекордсет.Колонки.Добавить(ИмяВременнойКолонки,
		Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(200, ДопустимаяДлина.Переменная), ));
		
	Для Каждого Стрк Из ТЗРекордсет Цикл
		Стрк[ИмяВременнойКолонки] = Формат(Стрк[ИмяКолонки],"ЧГ=;ЧРГ=;ЧРД=");
	КонецЦикла;
	
	ТЗРекордсет.Колонки.Удалить(ТЗРекордсет.Колонки.Найти(ИмяКолонки));
	
	ТЗРекордсет.Колонки.Добавить(ИмяКолонки,
		Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(200, ДопустимаяДлина.Переменная), ));
		
	Для Каждого Стрк Из ТЗРекордсет Цикл
		Стрк[ИмяКолонки] = Стрк[ИмяВременнойКолонки];
	КонецЦикла;
	
	ТЗРекордсет.Колонки.Удалить(ТЗРекордсет.Колонки.Найти(ИмяВременнойКолонки));
		
КонецПроцедуры

// Проверяет возможность запуска задания.
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция ОтменитьЗапуск(ИмяМетодаФон, ИмяГлавногоМетода) Экспорт
	
	ОтменитьЗапуск 		= Справочники.мис_СвойстваМетодов.ВключенФлагПрерыванияПроцедуры(ИмяМетодаФон);
	Если ОтменитьЗапуск Тогда
		//клог.варн("Запуск отменен, т.к. включен флаг прерывания метода "+ИмяМетодаФон);
		Возврат Истина;
	КонецЕсли;
		
	ОтменитьЗапуск 		= Справочники.мис_СвойстваМетодов.ВключенФлагПрерыванияПроцедуры(ИмяГлавногоМетода);
	Если ОтменитьЗапуск Тогда
		//клог.варн("Запуск отменен, т.к. включен флаг прерывания метода "+ИмяГлавногоМетода);
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция МодульЧисла(Знач ПарамЧисло) Экспорт
	Если ТипЗнч(ПарамЧисло)<> Тип("Число") Тогда
		Возврат 0;
	КонецЕсли;
	Возврат ?(ПарамЧисло<0,-1,1)*ПарамЧисло;
КонецФункции

// Возвращает элемент коллекции по ключу. Используется в отчетах
//
Функция СвойствоОбъекта(Элемент,Ключ) Экспорт
	Возврат Элемент[Ключ];
КонецФункции

//СУУ_ТЕА - возвращает таблицу с разбивкой периода по месяцам
//Параметры:
//	ИдВызова
//	ДатаНачала
//	ДатаОкончания
//	Разбивать - если Ложь, тогда возвращается ТЗ с одной строкой без разбивки по месяцам.
//Возвращаемое значение:
//	ТаблицаЗначений
Функция РазбитьПериодПомесячно(Знач ДатаНачала,Знач ДатаОкончания,Разбивать=Истина) Экспорт
	ТЗПериоды = Новый ТаблицаЗначений;
	ТЗПериоды.Колонки.Добавить("ДатаНачала");
	ТЗПериоды.Колонки.Добавить("ДатаОкончания");
	ТЗПериоды.Колонки.Добавить("Последний");
	
	Если Не Разбивать Тогда
		НовПериод               = ТЗПериоды.Добавить();
		НовПериод.ДатаНачала    = ДатаНачала;
		НовПериод.ДатаОкончания = ДатаОкончания;
		НовПериод.Последний     = Истина;
	Иначе
		ТекНачалоПериода = ДатаНачала;
		ТекКонецПериода  = НачалоДня(КонецМесяца(ДатаНачала));
		
		Пока ТекКонецПериода <= ДатаОкончания Цикл
			НовПериод               = ТЗПериоды.Добавить();
			НовПериод.ДатаНачала    = ТекНачалоПериода;
			НовПериод.ДатаОкончания = ТекКонецПериода;
			НовПериод.Последний     = Ложь;
			
			ТекНачалоПериода = НачалоДня(ТекКонецПериода+86400);
			ТекКонецПериода  = НачалоДня(КонецМесяца(ТекНачалоПериода));
		КонецЦикла;
		
		Если ТекНачалоПериода <= ДатаОкончания Тогда
			НовПериод               = ТЗПериоды.Добавить();
			НовПериод.ДатаНачала    = ТекНачалоПериода;
			НовПериод.ДатаОкончания = ДатаОкончания;
			НовПериод.Последний     = Истина;
		Иначе
			ТЗПериоды[ТЗПериоды.Количество()-1].Последний = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат ТЗПериоды;
КонецФункции

Функция ПолучитьПометкуУдаленияДокумента(ВидДокумента, ДокументСсылка) Экспорт
		
		СтараяПометка = Ложь;
		Запрос = Новый Запрос("Выбрать ПометкаУдаления из Документ."+ВидДокумента+" Где Ссылка=&Ссылка");
		Запрос.УстановитьПараметр("Ссылка", ДокументСсылка);
		ЗапРез = Запрос.Выполнить();
		Выборка = ЗапРез.Выбрать();
		Если Выборка.Следующий() Тогда
			СтараяПометка = Выборка.ПометкаУдаления;
		КонецЕсли; 
		Возврат СтараяПометка;
		
КонецФункции

// выполняет http GET-запрос, результат выводит в лог
//
// Параметры:                                    
//	Сервер - строка - например https://yandex.ru
//	Порт - число
//	Пользователь, Пароль, 
//	ИспользоватьSSL - булево - 
//	ТекстЗапроса 	- строка - например "/showStat"
//
Функция ВыполнитьHttpGetЗапрос(Знач ИдВызова, Сервер, Порт, Пользователь, Пароль, ИспользоватьSSL, ТекстЗапроса) экспорт
	
	ВремяНач = ТекущаяУниверсальнаяДатаВМиллисекундах(); 
	
	лог = мис_ЛоггерСервер.гетЛоггер(ИдВызова);                  
	
	Попытка
		Если ИспользоватьSSL Тогда
			SSL = Новый ЗащищенноеСоединениеOpenSSL();
		Иначе 
			SSL = Неопределено;
		КонецЕсли;
		Соединение = Новый HTTPСоединение(Сервер,порт,Пользователь,Пароль,,,SSL);
		
		лог.инфо("Server: "+строка(Сервер));
		лог.инфо("Port: "+строка(Порт));
		лог.инфо("SSL: "+строка(ИспользоватьSSL));
		лог.инфо("Query: "+строка(ТекстЗапроса));
		
		
	  	Запрос = Новый HTTPЗапрос(ТекстЗапроса);

		//Запрос.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
	 
	    Результат = Соединение.Получить(Запрос);
	 
		Если Результат.КодСостояния <> 200 Тогда
			лог.Ерр("Error while executing http-request. Status: " + Результат.КодСостояния
				+Символы.ПС+"Текст запроса:"+Символы.ПС+ТекстЗапроса);
				
		КонецЕсли;
	    
	    json = Результат.ПолучитьТелоКакСтроку(); 
		
		
		
		лог.инфо("Response: "+строка(json));
		
		лог.инфо("finished: time: "+строка(ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНач )+" ms");
		
		Возврат json;
		
	Исключение
		т = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		лог.Ерр("Error while executing ВыполнитьHttpGetЗапрос() "
			+Символы.ПС+"Details: " + т);
	КонецПопытки;
		
КонецФункции

// выполняет http POST-запрос, результат выводит в лог
//
// Параметры:                                    
//	Сервер - строка - например https://yandex.ru
//	Порт - число
//	Пользователь, Пароль, 
//	ИспользоватьSSL - булево - 
//	ТекстЗапроса 	- строка - например "/showStat"
//	ТелоЗапроса 	- строка - 
//
Функция ВыполнитьHttpPostЗапрос(Знач ИдВызова, Сервер, Порт, Пользователь, Пароль, ИспользоватьSSL, ТекстЗапроса, ТелоЗапроса) экспорт
	
	ВремяНач = ТекущаяУниверсальнаяДатаВМиллисекундах(); 
	
	лог = мис_ЛоггерСервер.гетЛоггер(ИдВызова);                  
	
	Попытка
		Если ИспользоватьSSL Тогда
			SSL = Новый ЗащищенноеСоединениеOpenSSL();
		Иначе 
			SSL = Неопределено;
		КонецЕсли;
		Соединение = Новый HTTPСоединение(Сервер,порт,Пользователь,Пароль,,,SSL);

		
	  	Запрос = Новый HTTPЗапрос(ТекстЗапроса);
		
		Запрос.УстановитьТелоИзСтроки(ТелоЗапроса);

		//Запрос.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
	 
	    Результат = Соединение.ОтправитьДляОбработки(Запрос);
	 
		Если Результат.КодСостояния <> 200 Тогда
			лог.Ерр("Error while executing http-request. Status: " + Результат.КодСостояния
				+Символы.ПС+"Текст запроса:"+Символы.ПС+ТекстЗапроса);
				
		КонецЕсли;
	    
	    json = Результат.ПолучитьТелоКакСтроку(); 
		
		лог.инфо("Response: "+строка(json));
		
		лог.инфо("finished: time: "+строка(ТекущаяУниверсальнаяДатаВМиллисекундах() - ВремяНач )+" ms");
		
		Возврат json;
		
	Исключение
		т = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		лог.Ерр("Error while executing ВыполнитьHttpPostЗапрос() "
			+Символы.ПС+"Details: " + т);
	КонецПопытки;
		
КонецФункции





﻿// ++ Вишневский А. 28.03.2023 
#Область ЛогированиеСообщенийВФайл
// если на управляемых формах , то вызов только со стороны сервера 
// обший порядок работы :
// 1. Инициализация структуры логирования
// 2. Использование
// 3. Завернение логирования , это не обязательно , но для освобождения памяти и захвата файла  желательно сделать . 


// Инициализация структуры в которой сохранены параметры записи данных в файл.
//
// Параметры:
//  Каталог  				- Строка 		- Каталог сохранения лог файлов
//  ИмяФайла  				- Строка 		- Имя файла логирования , если не задан то текущая дата . Если файла нет, то он будет создан.
//  ВыводитьДату			- Булево 		- Если Итина, то временная метка содержит дату . Дата не всегда нужна , как правило в логах
//										  	  дата содержится в имени файла. 	
//  ВыводитьВКонсоль		- Булево 		- Дублировать сообщения в консоль выовда.
//  СоответствияСтатусов	- Соответствие 	- При выводе в консоль текстовое событие может соответствовать 
//
// Возвращаемое значение:
//   Структура   			- Структура содержащая параметры выода сообщений в файл, используется в дальнейшем 
//							  для вывода сообщений функцией ЗаписатьВЛог()
//
Функция ИнициализацияЛогированияВФайл(Каталог, ИмяФайла = "" , ВыводитьДату = Ложь , ВыводитьВКонсоль = ложь, СоответствияСтатусов = Неопределено ) Экспорт
	Лог  =новый Структура;
	
	Лог.Вставить("ВыводитьВКонсоль", ВыводитьВКонсоль);
	Лог.Вставить("ВыводитьДату", ВыводитьДату); //Дата по умолчанию не нужна , так как дата есть в имени файла
	Лог.Вставить("ПривестиКМестномуВремени", Истина); //По умолчанию приводим к часовому поясу сервера
	Лог.Вставить("РазделительПриДописыванииНовогоБлока", ""); // для разделения блоков в одном файле при разных итеррациях сообщений

	
	Если ПустаяСтрока(Каталог) Тогда
		Лог.Вставить("ОшибкаИнициализации", Истина);
		Лог.Вставить("ОписаниеОшибкиИнициализации", "Не задан каталог для сохранения файлов логирования.");
		возврат лог;
	КонецЕсли;
	
	// проверка наличия каталога 
	ФайлКаталога = новый Файл(Каталог);
	Если не ФайлКаталога.Существует() Тогда
		Лог.Вставить("ОшибкаИнициализации", Истина);
		Лог.Вставить("ОписаниеОшибкиИнициализации", "Не найден каталог для сохранения файлов логирования.");
		возврат лог;
	КонецЕсли;
	
	// если надо добавляем "\"
	КаталогРез = ?(Прав(Каталог,1)="\",Каталог,Каталог+"\");
	
	// не всегда надо задавать имя , даты может быть достаточно.
	ИмяФайлаРез = ?(ПустаяСтрока(ИмяФайла),Формат(ТекущаяДата(), "ДФ=yyyy-MM-dd"),ИмяФайла);

	ПутьКФайлуЛогирования = КаталогРез+ИмяФайлаРез;
	
	Лог.Вставить("ПутьКФайлуЛогирования", ПутьКФайлуЛогирования);
	
	ФайлЛогирования = Новый Файл(ПутьКФайлуЛогирования);
	
	Лог.Вставить("ВывестиРазделительБлоков", ФайлЛогирования.Существует()); // если файл есть, то там скорее всего есть данные 
	
	
	Попытка
		Лог.Вставить("ФайлЛога", Новый ЗаписьТекста(ПутьКФайлуЛогирования,,,Истина));
	Исключение
		Лог.Вставить("ОшибкаИнициализации", Истина);
		Лог.Вставить("ОписаниеОшибкиИнициализации", "Не возможно открыть\создать файл лога. Причина: "+ОписаниеОшибки());
		возврат лог;
	КонецПопытки;
	
	// Определения соответствия статусов сообщения текстовым представлениям которые задал программист
	Если СоответствияСтатусов = Неопределено Тогда
		СоответствияСтатусов = Новый Соответствие;
	КонецЕсли;
	
	СоответствияСтатусов.Вставить("-",	СтатусСообщения.Обычное);
	СоответствияСтатусов.Вставить("!",	СтатусСообщения.Важное);
	СоответствияСтатусов.Вставить("ERR",СтатусСообщения.ОченьВажное);
	СоответствияСтатусов.Вставить("deb",СтатусСообщения.Информация);
	
	СоответствияСтатусов.Вставить("ИНФОРМАЦИЯ",	СтатусСообщения.Обычное);
	СоответствияСтатусов.Вставить("ПРЕДУПРЕЖДЕНИЕ",	СтатусСообщения.Важное);
	СоответствияСтатусов.Вставить("ОШИБКА",СтатусСообщения.ОченьВажное);
	СоответствияСтатусов.Вставить("ОТЛАДКА",СтатусСообщения.Информация);
	
	Лог.Вставить("СоответствияСтатусов",СоответствияСтатусов);
	
	// инициализация прошла успешно
	Лог.Вставить("ОшибкаИнициализации", ложь);

	возврат Лог;
КонецФункции // ()

// Вывод сообщения в файл лога 
//
// Параметры:
//  Лог  		- Структура - инициализируется функцией ИнициализацияЛогированияВФайл
//  Сообщение  	- Строка 	- содержит текст сообщения
//  Событие  	- Строка 	- Варианты :	{"-", "ERR" , "!", "deb"} 								или 
//											{"ИНФОРМАЦИЯ", "ОШИБКА" , "ПРЕДУПРЕЖДЕНИЕ", "ОТЛАДКА"}
//  ЗаписыватьФайл - Булево	- производить запись в файл после вывода строки, либо нет 
//
// Возвращаемое значение:
//   Булево   	- успех записа сообщения в файл.
Функция ЗаписатьВЛог(Лог, Сообщение , Событие = "-" , ЗаписыватьФайл = Ложь ) экспорт
	                                             
	Если Лог.ОшибкаИнициализации Тогда           
		Возврат истина;
	КонецЕсли;
	
	ДатаСообщенияУниверсальнаяМС	= ТекущаяУниверсальнаяДатаВМиллисекундах();
	ДатаМиллисекунды             	= ДатаСообщенияУниверсальнаяМС % 1000; 
	ДатаПредставлениеМС				= Формат(ДатаСообщенияУниверсальнаяМС % 1000, "ЧЦ=3; ЧН=0; ЧВН=; ЧГ=0");
	
	// вычисляем дату и при необходимости приводим ее к местному времени
	Если Лог.ПривестиКМестномуВремени Тогда
		ДатаЗначение = МестноеВремя(Дата(1, 1, 1) + ДатаСообщенияУниверсальнаяМС / 1000);
	Иначе
		ДатаЗначение = Дата(1, 1, 1) + ДатаСообщенияУниверсальнаяМС / 1000;
	КонецЕсли;	
		
	// не всегда нужна дата , дата может быть в имени файла .
	Если Лог.ВыводитьДату Тогда
		ДатаПредставление = Строка(ДатаЗначение); 
	Иначе 
		ДатаПредставление = Формат(ДатаЗначение, "ДЛФ=T"); 
	КонецЕсли;
	
	ПолноеСообщение = СтрШаблон("%1.%2 [%3]: %4", ДатаПредставление, ДатаПредставлениеМС, Событие,Сообщение);
	
	// если нужно то выводим разлелитель , но один раз .
	Если Лог.ВывестиРазделительБлоков Тогда
		Лог.ВывестиРазделительБлоков = ложь;
		Лог.ФайлЛога.ЗаписатьСтроку(Лог.РазделительПриДописыванииНовогоБлока);
	КонецЕсли;
	
	Лог.ФайлЛога.ЗаписатьСтроку(ПолноеСообщение);
	
	Если Лог.ВыводитьВКонсоль Тогда
		Сообщить(ПолноеСообщение,Лог.СоответствияСтатусов.Получить(Событие));
	КонецЕсли;
	
	Если ЗаписыватьФайл = Истина Тогда
		Лог.ФайлЛога.Закрыть();
		Лог.ФайлЛога.Открыть(Лог.ПутьКФайлуЛогирования,,,Истина);
	КонецЕсли;	
	
	
	
	Возврат истина;
КонецФункции // ()



// Закрывает файл логирования
// Параметры:
//  Лог  		- Структура - инициализируется функцией ИнициализацияЛогированияВФайл
Процедура ЗавершитьЛогирование(Лог) Экспорт 
	
	Лог.ФайлЛога.Закрыть();
	
	Лог = Неопределено;
	
КонецПроцедуры 

#КонецОбласти
// -- Вишневский А. 28.03.2023 

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С МЕТАДАННЫМИ

// Функция возвращает имя табличной части, к которой принадлежит переданная строка
//
// Параметры
//  СтрокаТабличнойЧасти - ссылка на строку табличной части
//
// Возвращаемое значение:
//   Строка - имя табличной части, как оно задано в конфигураторе
//
Функция ПолучитьИмяТабличнойЧастиПоСсылкеНаСтроку(СтрокаТабличнойЧасти) Экспорт
	
	ИмяТабличнойЧасти = Метаданные.НайтиПоТипу(ТипЗнч(СтрокаТабличнойЧасти)).Имя;
	Возврат ИмяТабличнойЧасти;
	
КонецФункции // ПолучитьИмяТабличнойЧастиПоСсылкеНаСтроку()

// Функция возвращает метаданные документа, которому принадлежит переданная строка
//
// Параметры
//  СтрокаТабличнойЧасти - ссылка на строку табличной части
//
// Возвращаемое значение:
//   Метаданные - метаданные документа, как оно задано в конфигураторе
//
Функция ПолучитьМетаданныеДокументаПоСсылкеНаСтроку(СтрокаТабличнойЧасти) Экспорт
	
	МетаданныеДокумента = Метаданные.НайтиПоТипу(ТипЗнч(СтрокаТабличнойЧасти)).Родитель();
	Возврат МетаданныеДокумента;
	
КонецФункции // ПолучитьМетаданныеДокументаПоСсылкеНаСтроку()

// Позволяет определить есть ли среди реквизитов табличной части документа
// реквизит с переданным именем.
//
// Параметры: 
//  ИмяРеквизита - строковое имя искомого реквизита, 
//  МетаданныеДокумента - объект описания метаданных документа, среди реквизитов которого производится поиск.
//  ИмяТабЧасти  - строковое имя табличной части документа, среди реквизитов которого производится поиск
//
// Возвращаемое значение:
//  Истина - нашли реквизит с таким именем, Ложь - не нашли.
//
Функция ЕстьРеквизитТабЧастиДокумента(ИмяРеквизита, МетаданныеДокумента, ИмяТабЧасти) Экспорт
	
	ТабЧасть = МетаданныеДокумента.ТабличныеЧасти.Найти(ИмяТабЧасти);
	Если ТабЧасть = Неопределено Тогда // Нет такой таб. части в документе
		Возврат Ложь;
	Иначе
		Если ТабЧасть.Реквизиты.Найти(ИмяРеквизита) = Неопределено Тогда
			Возврат Ложь;
		Иначе
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
КонецФункции // ЕстьРеквизитТабЧастиДокумента()


// Если в шапке переданного документа есть реквизит с указанным именем, то возвращается его значение.
// Если такого реквизита нет - возвращается Неопределено.
//
// Параметры:
//  ИмяРеквизита - Строка. Имя искомого реквизита.
//  ДокументОбъект - объект переданного документа.
//  МетаданныеДокумента - Метаданные переданного документа.
//  ПустоеЗначение - значение, которое должно вернуться, если в шапке нет такого реквизита,
//  если не передано, то возвращается значение Неопределено.
//
// Возвращаемое значение:
//  Значение реквизита - значение найденного реквизита или ПустоеЗначение.
//
Функция ПолучитьРеквизитШапки(ИмяРеквизита, ДокументОбъект, МетаданныеДокумента, ПустоеЗначение = Неопределено) Экспорт
	
	ЗначениеРеквизита = ?(МетаданныеДокумента.Реквизиты.Найти(ИмяРеквизита) <> Неопределено,
	ДокументОбъект[ИмяРеквизита], ПустоеЗначение);
	
	Возврат ЗначениеРеквизита;
	
КонецФункции // ПолучитьРеквизитШапки()





// ++Бобрышов А. 12.10.2022 Механизм проверки того, является ли база рабочей
Процедура ПередВыполнениемРегламентногоЗадания(Отказ = Ложь) Экспорт
	
	СтрокаСообщения = "";
	Отказ = НЕ ЭтоРабочаяБаза(СтрокаСообщения);
	
	Если Отказ Тогда
		
		ЗаписьЖурналаРегистрации("Перед выполнением регламентного задания",
			УровеньЖурналаРегистрации.Предупреждение, , , СтрокаСообщения);
		
	КонецЕсли;
	
КонецПроцедуры

Функция ЭтоРабочаяБаза(СтрокаСообщения = "") Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ЭтоРабочаяБаза = Истина;
	
	//Если ПолучитьФункциональнуюОпцию("ИспользоватьПроверкуРабочейБазы") Тогда 
		
		СтрокаПодключенияКИнформационнойБазе = НРег(СтрокаСоединенияИнформационнойБазы());
		СтрокаПодключенияКРабочейБазе = НРег(Константы.ксп_СтрокаПодключенияКРабочейБазе.Получить());
		
		ЭтоРабочаяБаза = ЗначениеЗаполнено(СтрокаПодключенияКРабочейБазе)
					И СтрокаПодключенияКИнформационнойБазе = СтрокаПодключенияКРабочейБазе;
					
		СтрокаСообщения = СтрШаблон("Не пройдена проверка рабочей базы.
			|Строка подключения к рабочей базе %1, строка подключения к текущей базе %2",
			СтрокаПодключенияКРабочейБазе, СтрокаПодключенияКИнформационнойБазе);
			
		
	//КонецЕсли;
	
	Возврат ЭтоРабочаяБаза;
	
КонецФункции
// --Бобрышов А. 12.10.2022 Механизм проверки того, является ли база рабочей


#Область РаботаССертификатамиЧестныйЗнак_PUBID_1923573


Функция ПолучитьИНН_ИзСертификата(стрСертификата,Разделитель) Экспорт 
	
	МассивЗначений = СтрРазделить(стрСертификата,Разделитель); 
	Для Каждого элемент Из МассивЗначений Цикл   
	  позиция_ИНН_ООО = СтрНайти(элемент,"ИНН ЮЛ=");
	  Если позиция_ИНН_ООО >0 Тогда  
		  Возврат Сред(СокрЛП(элемент),8);
	  КонецЕсли;
	КонецЦикла;        
		
	
	Для Каждого элемент Из МассивЗначений Цикл 
	  позиция_ИНН_ИП = СтрНайти(элемент,"ИНН="); 
	  Если позиция_ИНН_ИП >0 Тогда  
		  Возврат Сред(СокрЛП(элемент),5);
	  КонецЕсли;	  
	КонецЦикла;        
	
	//МассивЗначений = СтрРазделить(стрСертификата,Разделитель); 
	//Для Каждого элемент Из МассивЗначений Цикл 
	//  позиция = СтрНайти(элемент,"ИНН=");
	//  Если позиция >0 Тогда  
	//	  Возврат Сред(СокрЛП(элемент),5);
	//  КонецЕсли;
	//КонецЦикла;        
			
	Возврат Неопределено;		
КонецФункции  
 
Функция НайтиИндексВМассивеПоСтроке(СтрокаПоиска,МассивЗначений)  Экспорт
	Индекс = 0;
	Для Каждого элемент Из МассивЗначений Цикл
	  позиция = СтрНайти(элемент,СтрокаПоиска); 
	  Если позиция >0 Тогда  
		  Возврат Индекс;
	  КонецЕсли;
	  Индекс = Индекс+1;
	КонецЦикла;        
	
	Возврат Неопределено;
КонецФункции

Функция ПолучитьИНН_ИзСертификатаКлиент(стрСертификата,Разделитель)  Экспорт 
	
	МассивЗначений = СтрРазделить(стрСертификата,Разделитель); 
	Для Каждого элемент Из МассивЗначений Цикл 
	  позиция = СтрНайти(элемент,"ИНН=");
	  Если позиция >0 Тогда  
		  Возврат Сред(СокрЛП(элемент),5);
	  КонецЕсли;
	КонецЦикла;        
			
	Возврат Неопределено;		
КонецФункции  

// Параметры
//	Сервер - строка - DNS-имя или IP-адрес
//	Сертификат - строка - отпечаток сертификата. Подробнее - см. в модуле формы внешней обработки этой публикации
//
Функция ПолучитьТокенНаСервере(Сервер, Сертификат)  Экспорт
	
	//ЕНС
	//базовыйАдрес = "https://markirovka.sandbox.crptech.ru/api/v4/true-api"
	
	// Получение данных для получения токена
	HTTPСоединение =    Новый HTTPСоединение(Сервер,443,,,,,Новый ЗащищенноеСоединениеOpenSSL);
	
	//ЕНС. Нельзя использовать /v4/ - будет ошибка     "error_message": "Токен не действителен. Необходимо получить новый токен аутентификации"
	HTTPЗапрос = новый HTTPЗапрос("/api/v3/true-api/auth/key");
	Заголовки = Новый Соответствие;
	//Заголовки.Вставить("Content-Type", "application/json; charset=UTF-8");
	//Заголовки.Вставить("Accept", "application/json");

	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("GET",HTTPЗапрос);
	
	ОтветСтрока = HTTPОтвет.ПолучитьТелоКакСтроку("UTF-8"); 
	Чтение_JSON = Новый ЧтениеJSON; 
	Чтение_JSON.УстановитьСтроку(ОтветСтрока); 
	ДанныеJSON = ПрочитатьJSON(Чтение_JSON); 
	Чтение_JSON.Закрыть();
	УИД = ДанныеJSON.uuid;
	ДанныеДляПолученияТокена = ДанныеJSON.data;
	//ЗаписатьВЖурнал("Получение данных /api/v4/auth/cert/key" + Символы.ПС + ДанныеДляПолученияТокена);
	
	// Подписание данных для получения токена
	ДанныеДляПолученияТокена = ПодписатьТекст(ЗашифроватьBase64(ДанныеДляПолученияТокена, КодировкаТекста.UTF8),Сертификат,Ложь);
	//ЗаписатьВЖурнал("Подписано сертификатом " + СертификатДляОбмена + Символы.ПС + ДанныеДляПолученияТокена);
	
	// Получение токена с использованием подписанных данных
	Соединение = Новый HTTPСоединение(Сервер,443,,,,,Новый ЗащищенноеСоединениеOpenSSL);
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json; charset=UTF-8");
	Заголовки.Вставить("Accept", "application/json");
	//HTTPЗапрос = Новый HTTPЗапрос("/api/v3/auth/cert/",Заголовки);   
	HTTPЗапрос = Новый HTTPЗапрос("/api/v3/true-api/auth/simpleSignIn",Заголовки);
	Запись_JSON = Новый ЗаписьJSON;
	Запись_JSON.УстановитьСтроку();
	ДанныеДляЗапроса = Новый Структура;
	ДанныеДляЗапроса.Вставить("uuid",УИД);
	ДанныеДляЗапроса.Вставить("data",ДанныеДляПолученияТокена);	
	ЗаписатьJSON(Запись_JSON,ДанныеДляЗапроса);
	СтрокаДляЗапроса = Запись_JSON.Закрыть();
	
	HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаДляЗапроса,КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать);
	Ответ = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Чтение_JSON = Новый ЧтениеJSON;
	Чтение_JSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку());
	
	Токен = ПрочитатьJSON(Чтение_JSON, Ложь).token;	
	
	Возврат Токен;
КонецФункции

// todo Сейчас этот метод показывает на экране список выбора сертификатов (системный, windows).
// Доделать, чтобы использовал сохраненный (придумать, где сохранять)
//
// Параметры:
// 	sThumbprint - отпечаток сертификата, используемого для подписи; строка,
// 		представляющая отпечаток в шестнадцатеричном виде
// 		пример 195934d72dcdf69149901d6632aca4562d8806d8
// 		ТекстДляПодписи должен быть в Base64
// 	bDetached - Истина/Ложь - откреплённая(для подписания документов)/прикреплённая(для получения токена авторизации) подпись
//
Функция ПодписатьТекст(ТекстДляПодписи, sThumbprint, bDetached) Экспорт
	CADESCOM_BASE64_TO_BINARY = 1; // Входные данные пришли в Base64
	CADESCOM_CADES_TYPE = 1; // Тип усовершенствованной подписи
	CAPICOM_AUTHENTICATED_ATTRIBUTE_SIGNING_TIME = 0; // Атрибут штампа времени подписи
	oSigner = Новый COMОбъект("CAdESCOM.CPSigner");
	// Объект, задающий параметры создания и содержащий информацию об усовершенствованной подписи.
	oSigner.Certificate = ПолучитьСертификатПоОтпечатку(sThumbprint);
	oSigningTimeAttr = Новый COMОбъект("CAdESCOM.CPAttribute");
	oSigningTimeAttr.Name = CAPICOM_AUTHENTICATED_ATTRIBUTE_SIGNING_TIME;
	oSigningTimeAttr.Value = ТекущаяДата();
	oSigner.AuthenticatedAttributes2.Add(oSigningTimeAttr);
	ТекстДляПодписи = СокрЛП(ТекстДляПодписи);
	oSignedData = Новый COMОбъект("CAdESCOM.CadesSignedData");
	// Объект CadesSignedData предоставляет свойства и методы для работы с усовершенствованной подписью.
	oSignedData.ContentEncoding = CADESCOM_BASE64_TO_BINARY;
	oSignedData.Content = СокрЛП(ТекстДляПодписи);
	EncodingType = 0;
	sSignedMessage = oSignedData.SignCades(oSigner, CADESCOM_CADES_TYPE,
	bDetached, EncodingType);
	// Метод добавляет к сообщению усовершенствованную подпись.
	Возврат sSignedMessage; // Подпись в формате Base64
КонецФункции    

//Отпечаток - строка HEX
Функция ПолучитьСертификатПоОтпечатку(ОтпечатокСтр) ЭКспорт
	Рез = Неопределено; // Найденный сертификат (Com-объект)
	CAPICOM_CURRENT_USER_STORE = 2;
	//2 - Искать сертификат в ветке "Личное" хранилища.
	CAPICOM_MY_STORE = "My";
	// Указываем, что ветку "Личное" берем из хранилища текущего пользователя
	CAPICOM_STORE_OPEN_READ_ONLY = 0; // Открыть хранилище только на чтение
	oStore = Новый COMОбъект("CAdESCOM.Store"); // Объект описывает хранилище сертификатов
	
	oStore.Open(CAPICOM_CURRENT_USER_STORE, CAPICOM_MY_STORE,
	CAPICOM_STORE_OPEN_READ_ONLY); // Открыть хранилище сертификатов
	// 1 вариант: поиск сертификата по отпечатку
	//CAPICOM_CERTIFICATE_FIND_SHA1_HASH = 0;
	//Certificates = oStore.Certificates.Find(CAPICOM_CERTIFICATE_FIND_SHA1_HASH, ОтпечатокСтр);
	//Рез = Certificates.Item(1);
	
	//2 вариант: обходом по коллекции и сравнение с отпечатком
	Для Каждого ТекСертификат Из oStore.Certificates Цикл
		ТекОтпечаток = ТекСертификат.Thumbprint; // возвращается отпечаток в шестнадцатеричном виде
		Если ВРЕГ(ТекОтпечаток) = ВРЕГ(ОтпечатокСтр) Тогда Рез = ТекСертификат;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	oStore.Close(); // Закрыть хранилище сертификатов и освободить объект 61
	Возврат Рез;
КонецФункции

Функция ЗашифроватьBase64(Строка, Кодировка) Экспорт
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайла, Кодировка);
    ЗаписьТекста.Записать(Строка);
    ЗаписьТекста.Закрыть();
    Двоичные = Новый ДвоичныеДанные(ИмяВременногоФайла);
    Результат = Base64Строка(Двоичные);
	Если Лев(Результат, 4) = "77u/" Тогда
		Результат = Сред(Результат, 5);
	КонецЕсли; 
	Результат = СтрЗаменить(Результат, Символы.ПС, "");
    УдалитьФайлы(ИмяВременногоФайла);
    Возврат Результат;
КонецФункции


#КонецОбласти

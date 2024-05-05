﻿
#Область ПрограммныйИнтерфейс

// Запускает метод в параметре ИмяПроцедуры, как фоновое задание.
// Используется для асинхронного выполнения алгоритма.
//
// Пример (обработка выборки из результатов запроса пакетами по 1000 строк):
//
//	Перем Отладка; // булево. отключает фоновые задания, алгоритм выполняется последовательно
//
//	Результат = результат запроса (или таблица значений, но тогда проверку количества строк надо переделать)
//	ТЗРекордсет = Новый ТаблицаЗначений;
//	Для Каждого Кол Из Результат.Колонки Цикл
//		ТЗРекордсет.Колонки.Добавить(Кол.Имя);
//	КонецЦикла;
//	Выборка = Результат.Выбрать();
//	ЕстьЗаписи = Выборка.Следующий();
//	ВсегоСтрок = 0;
//	СчЗаданий = 0;
//	МассивПараметров = Новый Массив;
//	Пока ЕстьЗаписи Цикл
//		ВсегоСтрок = ВсегоСтрок+1;
//		//Накапливаем информацию из выборки в таблицу по 1000
//		КолВПакете=0;
//		//Формируем пакеты строк
//		ТЗРекордсет.Очистить();
//		Пока ЕстьЗаписи И КолВПакете<1000 Цикл
//			КолВПакете 		= КолВПакете+1;
//			НовСтр			= ТЗРекордсет.Добавить();
//			ЗаполнитьЗначенияСвойств(НовСтр, Выборка);
//			ЕстьЗаписи		= Выборка.Следующий();
//		КонецЦикла;
//		СчЗаданий=СчЗаданий+1;
//		МассивПараметров.Очистить();
//		МассивПараметров.Добавить(ИДВызова);
//		МассивПараметров.Добавить(Параметр1);
//		МассивПараметров.Добавить(Параметр2);
//		МассивПараметров.Добавить(ТЗРекордсет);
//		МассивПараметров.Добавить(СчЗаданий);
//		
//		Если ксп_Функции.МожноВыполнитьВФоне(Отладка) Тогда
//			Задача = "Наименование задания. Фоновое задание №"+Строка(СчЗаданий)+
//				", сеанс="+Строка(НомерСоединенияИнформационнойБазы());
//			
//			Обработки.мис_класс_ФоновыеЗадания.ДобавитьФоновоеЗадание(ИдВызова, 
//				"ОбщийМодуль.МетодКоторыйНадоЗапуститьВФоне", 
//				МассивПараметров, 
//				Задача, 
//				ЕстьЗаписи);
//		Иначе
//			//способ вызова для файловой базы
//			ОбщийМодуль.МетодКоторыйНадоЗапуститьВФоне(ИДВызова, Параметр1, Параметр2, ТЗРекордсет, СчЗаданий);
//		КонецЕсли;					
//	КонецЦикла;
//
//реализация метода фонового задания
//
//в методе МетодКоторыйНадоЗапуститьВФоне() надо создать новый ИдВызова на основе переданного!
//НомерЗадания - это параметр
//
//ОбщийМодуль.МетодКоторыйНадоЗапуститьВФоне(Знач ИдВызова, Параметр1, Параметр2, ТЗРекордсет, НомерЗадания) Экспорт
//
//	ПараметрыВызова 	= Новый ХранилищеЗначения(Список_Значений_С_Параметрами, Новый СжатиеДанных(9));
//	ИдВызова			= мис_ЛоггерСервер.СоздатьИдВызова (ИдВызова, "ОбщийМодуль.МетодКоторыйНадоЗапуститьВФоне. Номер задания "+Строка(НомерЗадания), ТекущаяДатаСеанса(), "", ПараметрыВызова);
//...
//
// Параметры
//    ИДВызова 			- спр ИндексЛога - 
//    ИмяПроцедуры 		- строка - имя метода, который запускаем в фоне
//    МассивПараметров 	- массив - параметры этого метода
//    Задача 			- строка - описание задачи для консоли фоновых заданий
//    ЕстьЗаписи 		- булево - признак того, надо ли включать ожидание или пока нет (если Ложь - надо, т.к. массив данных в вызывающем методе закончился)
//    Ключ 				- строка - для поиска фонового задания на кластере
//
Процедура ДобавитьФоновоеЗадание(ИДВызова, ИмяПроцедуры, МассивПараметров, Задача, ЕстьЗаписи, Ключ =Неопределено) Экспорт
	
	клог = мис_ЛоггерСервер.getLogger(ИДВызова,"ДобавитьФоновоеЗадание");
	
	//СУУ_ЕНС 02.01.2021 в режиме отладки и для файловой базы не запускаем фоновые задания
	Если НЕ ксп_Функции.МожноВыполнитьВФоне() Тогда
		клог.Инфо("Метод <%1> выполняется в основном потоке, т.к. включен режим отладки или база - файловая", ИмяПроцедуры);
		ОбщегоНазначения.ВыполнитьМетодКонфигурации(ИмяПроцедуры, МассивПараметров);
		клог.Инфо("Метод <%1> выполнен в основном потоке, т.к. включен режим отладки или база - файловая", ИмяПроцедуры);
		Возврат;
	КонецЕсли;
	
	// получаем список активных фоновых заданий
	Отбор = Новый Структура("Состояние", СостояниеФоновогоЗадания.Активно);
	Попытка
		МассивЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Отбор);
	Исключение
		клог.инфо("Управление фоновыми заданиями. Ошибка получения массива заданий методом ПолучитьФоновыеЗадания.
		|Будет создан новый пустой массив. Подробности:"+Символы.ПС+
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		МассивЗаданий = Новый Массив;
	КонецПопытки;
	
	НомерСеанса = НайтиНомерСеанса(Задача);
	МассивЗаданийОдногоСеанса = ПолучитьМассивЗаданийОдногоСеанса(НомерСеанса, МассивЗаданий, ИмяПроцедуры);
	
	клог.дебаг("общее количество активных заданий (во всех сеансах) = "+строка(МассивЗаданий.Количество()));
	клог.дебаг("количество активных заданий (в текущем сеансе "+строка(НомерСеанса)+") = "+строка(МассивЗаданий.Количество()));
	
	//				запуск														   //
	/////////////////////////////////////////////////////////////////////////////////
	
	Задание = ФоновыеЗадания.Выполнить(ИмяПроцедуры, МассивПараметров, Ключ, Задача);
	МассивЗаданийОдногоСеанса.Добавить(Задание);
	клог.дебаг("добавили задание. Задача "+строка(задача)+". Гуид задания "+Задание.УникальныйИдентификатор);
	МаксПроцессов = ПолучитьМаксимальноеКоличествоАсинхронныхПроцессов(ИмяПроцедуры);
	НачатьОжидание = ЕстьЗаписи <> Истина;
	
	//				ожидание													   //
	/////////////////////////////////////////////////////////////////////////////////
	
	// версия с ожиданием всего пакета (2024-03-18 отключено)
	
	//Если МассивЗаданийОдногоСеанса.Количество() >= МаксПроцессов ИЛИ НачатьОжидание Тогда
	//	// достигнут лимит заданий одного метода или закончились строки выборки, 
	//	// надо включить ожидание всех оставшихся заданий этого пакета
	//	колЗаданий = МассивЗаданийОдногоСеанса.Количество();
	//	Если колЗаданий > 0 Тогда
	//		клог.дебаг("ожидание. начало. Закончились записи в выборке или включен признак ожидания в вызывающем алгоритме, начали ожидание пакета задач из одного сеанса ("+НомерСеанса+"). Количество = "+Строка(колЗаданий)+". Задача "+строка(Задача));
	//		Для сч = 0 По МассивЗаданийОдногоСеанса.Количество()-1 Цикл
	//			клог.дебаг("список ожидаемых заданий: гуид фонового задания "+массивЗаданий[сч].УникальныйИдентификатор);
	//		КонецЦикла;
	//		ОжидатьМассивЗаданий( клог, МассивЗаданийОдногоСеанса, Задача, ИмяПроцедуры );
	//		клог.дебаг("ожидание. конец. Закончили ожидание пакета задач из одного сеанса ("+НомерСеанса+"). Количество = "+Строка(колЗаданий)+". Задача "+строка(Задача));
	//	КонецЕсли;
	//КонецЕсли;
	

	// версия с добавлением по одному заданию вместо завершенного (2024-03-18 добавлено)
	
	
	Если НачатьОжидание Тогда
		// здесь безусловно ждем весь остаток пакета, потому что данных больше не будет
		
		колЗаданий = МассивЗаданийОдногоСеанса.Количество();
		Если колЗаданий > 0 Тогда
			клог.дебаг("ожидание. начало. Закончились записи в выборке или включен признак ожидания в вызывающем алгоритме, начали ожидание пакета задач из одного сеанса ("+НомерСеанса+"). Количество = "+Строка(колЗаданий)+". Задача "+строка(Задача));
			Для сч = 0 По МассивЗаданийОдногоСеанса.Количество()-1 Цикл
				клог.дебаг("список ожидаемых заданий: гуид фонового задания "+массивЗаданий[сч].УникальныйИдентификатор);
			КонецЦикла;
			ОжидатьМассивЗаданий( клог, МассивЗаданийОдногоСеанса, Задача, ИмяПроцедуры );
			клог.дебаг("ожидание. конец. Закончили ожидание пакета задач из одного сеанса ("+НомерСеанса+"). Количество = "+Строка(колЗаданий)+". Задача "+строка(Задача));
		КонецЕсли;
		
	ИначеЕсли МассивЗаданийОдногоСеанса.Количество() >= МаксПроцессов Тогда
		
		колЗаданий = МассивЗаданийОдногоСеанса.Количество();

		СчетчикБезопасности = 0;		
		Пока колЗаданий >= МассивЗаданийОдногоСеанса.Количество() Цикл 
			
			МассивЗаданийОдногоСеанса = ОжидатьМассивЗаданийДоПервогоСвободного( клог, МассивЗаданийОдногоСеанса, Задача, ИмяПроцедуры );
			
			колЗаданий = МассивЗаданийОдногоСеанса.Количество();
			СчетчикБезопасности = СчетчикБезопасности + 1;
			Если СчетчикБезопасности >= 1000000000 Тогда
				ВызватьИсключение "Количество итерация ожидания свободного слота для фонового задания превысило "+строка(СчетчикБезопасности)+"!";
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ФоновоеЗадание

//СУУ_ЕНС 07.01.2021 Устарело. это старый вариант. он не учитывает новый алгоритм работы метода ОжидатьЗавершенияВыполнения()
// Выполняет ожидание фоновых заданий.
// Параметры
//	Задача - строка - описание фонового задания
Процедура ОжидатьМассивЗаданий_( ИдВызова, МассивЗаданий, Задача, ИмяПроцедуры )
	
	Если МассивЗаданий.Количество()=0 Тогда
		мис_ЛоггерСервер.Информация(ИдВызова,"ОжидатьМассивЗаданий()","Массив заданий пуст, выходим из метода.");
		Возврат;
	КонецЕсли;
	
	Попытка
		// Устарела
		//ФоновыеЗадания.ОжидатьЗавершения(МассивЗаданий);
		ФоновыеЗадания.ОжидатьЗавершенияВыполнения(МассивЗаданий);
	Исключение
		т = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		мис_ЛоггерСервер.КритическаяОшибка(ИДВызова, "КритическаяОшибка",
		"Управление фоновыми заданиями. Ошибка выполнения метода ОжидатьЗавершенияВыполнения(). Подробности:"+
			Символы.ПС + т);
		
		//получим все задания, завершенные с ошибкой и выведем их ошибки
		СписокЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("ИмяМетода,Состояние",
			ИмяПроцедуры, СостояниеФоновогоЗадания.ЗавершеноАварийно));
			
		ВывестиОшибкиФоновыхЗаданий(ИдВызова, СписокЗаданий);// выводим в лог
	
		Обработки.мис_класс_УведомленияПользователей.ОтправитьОповещениеОбОшибке(ИдВызова, т, ИмяПроцедуры, Задача);
		//TaskManagementРассылкаПоПочтеСервер.ОтправитьУведомление(ИдВызова, ТекстСообщения, 
		//	"Ошибка выполнения метода ОжидатьЗавершения", "BackgroundJobFail", Неопределено);
		
	КонецПопытки;
	
КонецПроцедуры

// Параметры
//	клог - логгер
//	МассивФонЗаданий - массив - фоновые задания для ожидания
//	ЗадачаСсылка - СправочникСсылка.мис_УправлениеЗаданиями - для формирования письма с ошибкой
//	ИмяПроцедуры - строка - для поиска сбойных фоновых заданий и вывода в лог их ошибок
//
Процедура ОжидатьМассивЗаданий(клог, МассивФонЗаданий, ЗадачаСсылка, ИмяПроцедуры) Экспорт
	
	колЗаданий = МассивФонЗаданий.Количество();
	НомерИтерации = 1;
	
	клог.дебаг("Завершенные и ошибочные задания будут удаляться из массива ожидания");
	
	Попытка
		ЕстьАктивные = Истина;
		Пока ЕстьАктивные И колЗаданий > 0 Цикл
			МассивФонЗаданий = ФоновыеЗадания.ОжидатьЗавершенияВыполнения(МассивФонЗаданий);
			ЕстьАктивные = Ложь;
			клог.дебаг("Номер итерации = %1", НомерИтерации);
			клог.дебаг("Начинаем ожидание. Количество фоновых заданий = %1", колЗаданий);
			Для сч_ = -МассивФонЗаданий.Количество()+1 По 0 Цикл
				// Это условие только для детализации лога, чтобы выделить ошибку
				н_ = МассивФонЗаданий[-сч_].Наименование;
				с_ = МассивФонЗаданий[-сч_].Состояние;
				Если с_ = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
					клог.ерр("Задание %1 имеет статус %2", н_, СостояниеФоновогоЗадания.ЗавершеноАварийно);
					МассивФонЗаданий.Удалить(-сч_);
				ИначеЕсли с_ <> СостояниеФоновогоЗадания.Активно Тогда
					клог.дебаг("Задание %1 имеет статус %2", н_, с_);
					МассивФонЗаданий.Удалить(-сч_);
				Иначе
					ЕстьАктивные = Истина;
					клог.дебаг("Задание %1 имеет статус %2", н_, СостояниеФоновогоЗадания.Активно);
				КонецЕсли;
			КонецЦикла;
			//Для Каждого ФоновоеЗадание_ Из МассивФонЗаданий Цикл
			//	клог.инфо("Задание %1 имеет статус %2", ФоновоеЗадание_.Наименование, ФоновоеЗадание_.Состояние);
			//	Если ФоновоеЗадание_.Состояние = СостояниеФоновогоЗадания.Активно Тогда
			//		ЕстьАктивные = Истина;
			//		//Прервать;
			//	КонецЕсли;
			//КонецЦикла;
			колЗаданий = МассивФонЗаданий.Количество();
			НомерИтерации=НомерИтерации+1;
		КонецЦикла;
		клог.дебаг("Завершили ожидание. Количество фоновых заданий = %1", колЗаданий);
	Исключение
		т = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		клог.ерр("Ошибка ОжидатьЗавершенияВыполнения(). Подробности: "+т);
		
		Если ЗначениеЗаполнено(ИмяПроцедуры) Тогда
			//получим все задания, завершенные с ошибкой и выведем их ошибки
			СписокЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("ИмяМетода,Состояние",
				ИмяПроцедуры, СостояниеФоновогоЗадания.ЗавершеноАварийно));
				
			ВывестиОшибкиФоновыхЗаданий(клог, СписокЗаданий);// выводим в лог
		КонецЕсли;
	
		//Обработки.мис_класс_УведомленияПользователей.ОтправитьОповещениеОбОшибке(клог.гетИдВызова(), т, ЗадачаСсылка.ПроцедураСПараметрами, ЗадачаСсылка);
	КонецПопытки;
	
КонецПроцедуры

Функция ОжидатьМассивЗаданийДоПервогоСвободного(клог, МассивФонЗаданий, ЗадачаСсылка, ИмяПроцедуры) Экспорт
	
	колЗаданий = МассивФонЗаданий.Количество();
	
	клог.дебаг("Завершенные и ошибочные задания будут удаляться из массива ожидания");
	
	Попытка
		
		МассивФонЗаданий = ФоновыеЗадания.ОжидатьЗавершенияВыполнения(МассивФонЗаданий);
		клог.дебаг("Начинаем ожидание. Количество фоновых заданий = %1", колЗаданий);
		Для сч_ = -МассивФонЗаданий.Количество()+1 По 0 Цикл
			// Это условие только для детализации лога, чтобы выделить ошибку
			н_ = МассивФонЗаданий[-сч_].Наименование;
			с_ = МассивФонЗаданий[-сч_].Состояние;
			Если с_ = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
				клог.ерр("Задание %1 имеет статус %2", н_, СостояниеФоновогоЗадания.ЗавершеноАварийно);
				МассивФонЗаданий.Удалить(-сч_);
			ИначеЕсли с_ <> СостояниеФоновогоЗадания.Активно Тогда
				клог.дебаг("Задание %1 имеет статус %2", н_, с_);
				МассивФонЗаданий.Удалить(-сч_);
			Иначе
				клог.дебаг("Задание %1 имеет статус %2", н_, СостояниеФоновогоЗадания.Активно);
			КонецЕсли;
		КонецЦикла;

		клог.дебаг("Завершили ожидание. Количество фоновых заданий = %1", колЗаданий);
		
		Возврат МассивФонЗаданий;
		
	Исключение
		т = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		клог.ерр("Ошибка ОжидатьЗавершенияВыполнения(). Подробности: "+т);
		
		Если ЗначениеЗаполнено(ИмяПроцедуры) Тогда
			//получим все задания, завершенные с ошибкой и выведем их ошибки
			СписокЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("ИмяМетода,Состояние",
				ИмяПроцедуры, СостояниеФоновогоЗадания.ЗавершеноАварийно));
				
			ВывестиОшибкиФоновыхЗаданий(клог, СписокЗаданий);// выводим в лог
		КонецЕсли;
	
		//Обработки.мис_класс_УведомленияПользователей.ОтправитьОповещениеОбОшибке(клог.гетИдВызова(), т, ЗадачаСсылка.ПроцедураСПараметрами, ЗадачаСсылка);
	КонецПопытки;
	
	Возврат МассивФонЗаданий;
	
	
КонецФункции

#КонецОбласти

// Выбирает из всего массива фоновых заданий только те, которые имеют номер сеанса, указанный
// задаче из параметра Задача (строка)
Функция ПолучитьМассивЗаданийОдногоСеанса(НомерСеанса, МассивЗаданий, ИмяПроцедуры) Экспорт
		
	// выбор из всех заданий с этим именем метода только тех, которые имеют один и тот же номер сеанса
	Если НомерСеанса = "" ИЛИ ТипЗнч(МассивЗаданий) <> Тип("Массив") ИЛИ МассивЗаданий.Количество() = 0 Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	МассивЗаданий2 = Новый Массив;
	Для сч = 0 По МассивЗаданий.Количество()-1 Цикл
		Если Найти(НРег(МассивЗаданий[сч]["Наименование"]), "сеанс="+НомерСеанса) > 0 И МассивЗаданий[сч]["ИмяМетода"] = ИмяПроцедуры Тогда
			МассивЗаданий2.Добавить(МассивЗаданий[сч]);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивЗаданий2;
		
КонецФункции

Функция НайтиНомерСеанса(Задача) Экспорт
		
	// поиск номера сеанса в параметре Задача
	НомерСеанса = "";
	Поз=Найти(нрег(Задача), "сеанс=");
	Если Поз>0 Тогда
		НомерСеанса = Сред(Задача, Поз+6);// с позиции сразу после "=" и до конца строки
	КонецЕсли;
	Возврат НомерСеанса;
	
КонецФункции


#Область УведомленияОбОшибках

Процедура РассылкаУведомленийОбОшибке(ИДВызова, ОписаниеОшибки, ИмяПроцедуры, Задание) Экспорт
	
	Если НЕ ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСПочтовымиСообщениями") Тогда
		Возврат;
	КонецЕсли;
	
	ОМ = ОбщегоНазначения.ОбщийМодуль("РаботаСПочтовымиСообщениями");
	Если НЕ ОМ.ДоступнаОтправкаПисем() Тогда
		Возврат;
	КонецЕсли;
	
	СистемнаяУчетнаяЗапись = ОМ.СистемнаяУчетнаяЗапись();
	
	Если НЕ ОМ.УчетнаяЗаписьНастроена(СистемнаяУчетнаяЗапись,Истина,Ложь) Тогда
		Возврат;
	КонецЕсли;
	
	мис_ЛоггерСервер.Ошибка(ИДВызова, "Ошибка",
	"Управление фоновыми заданиями. Ошибка выполнения метода ОжидатьЗавершения. Подробности:"+Символы.ПС+ОписаниеОшибки);
	
	// получим все задания, завершенные с ошибкой и выведем их ошибки
	ВывестиОшибкиФоновыхЗаданий(ИдВызова,
		ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("ИмяМетода,Состояние", ИмяПроцедуры,
			СостояниеФоновогоЗадания.ЗавершеноАварийно)));
	
	ТекстСообщения = "
	|<!DOCTYPE html>
	|<html lang=""ru"">
	|<title>Оповещение</title>
	|<head><meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"">
	|Ошибка выполнения метода ОжидатьЗавершения()
	|</head>
	|<body>
	|Ошибка выполнения метода ОжидатьЗавершения().<br>
	|Задание: "+Задание.Наименование+", код "+Задание.Код+"<br>
	|Подробности смотрите в логе выполнения задания.<br>
	|
	|<br>
	|<br>
	|Отправлено системой оповещений 1С<br>
	|</body>
	|</html>			
	|";
	
	ИдентификаторСообщения = "";
	
	// todo доделать справочник адресов для рассылки ошибок фоновых заданий
	ПараметрыОтправки = Новый Структура;
	ПараметрыОтправки.Вставить("Кому", "123@mail.ru"); // массив, строка
	ПараметрыОтправки.Вставить("Тема", "Ошибка выполнения метода ОжидатьЗавершения()");
	ПараметрыОтправки.Вставить("Тело", ТекстСообщения);
	ПараметрыОтправки.Вставить("Важность", ВажностьИнтернетПочтовогоСообщения.Высокая); //ВажностьИнтернетПочтовогоСообщения
	ПараметрыОтправки.Вставить("Вложения", Неопределено);
	ПараметрыОтправки.Вставить("ТипТекста", ТипТекстаПочтовогоСообщения.HTML);//Строка, Перечисление.ТипыТекстовЭлектронныхПисем, ТипТекстаПочтовогоСообщения
	ПараметрыОтправки.Вставить("ПротоколПочты", "SMTP"); // еще можно IMAP
	ПараметрыОтправки.Вставить("ИдентификаторСообщения", ИдентификаторСообщения);// возвращаемый парам
	ПараметрыОтправки.Вставить("ОшибочныеПолучатели", Неопределено);//Соответствие. Те, кому письмо не дошло

	ОМ.ОтправитьПочтовоеСообщение(СистемнаяУчетнаяЗапись,ПараметрыОтправки);
		
КонецПроцедуры
 
//перебирает список заданий и выводит в лог ошибки
//Параметры:
//	СписокЗаданий - список фоновых заданий, завершенных аварийно, получать вот так: 
//		ФоновыеЗадания.ПолучитьФоновыеЗадания(Новый Структура("ИмяМетода,Состояние", ИмяПроцедуры, СостояниеФоновогоЗадания.ЗавершеноАварийно));
//Возвращаемое значение:
//	нет
//
Функция ВывестиОшибкиФоновыхЗаданий(ИдВызова, СписокЗаданий) Экспорт
	клог = мис_ЛоггерСервер.getLogger(ИдВызова,"Ошибки фонового задания");
	Для Каждого Задание Из СписокЗаданий Цикл
		ВывестиОшибкиФоновогоЗадания(клог, Задание);
	КонецЦикла;
	
КонецФункции

//Выводит в лог ошибку одного задания
//Параметры:
//	Задание -  фоновое задание, завершенное аварийно, 
//Возвращаемое значение:
//	нет
//
Функция ВывестиОшибкиФоновогоЗадания(клог, Задание) Экспорт
	Инфо = Задание.ИнформацияОбОшибке;
	Если Инфо<>Неопределено Тогда
		клог.ерр("Вывод информации об ошибке:");
		клог.ерр("Задание: %1", Задание.Наименование);
		клог.ерр("Начало: %1", 			Задание.Начало);
		клог.ерр("Конец: %1", 			Задание.Конец);
		клог.ерр("ИмяМетода: %1", 		Задание.ИмяМетода);
		клог.ерр("ИсходнаяСтрока: %1", 	Задание.ИсходнаяСтрока);
		клог.ерр("НомерСтроки: %1", 	Задание.НомерСтроки);
		клог.ерр("Описание: %1", 		Задание.Описание);
		клог.ерр("Причина: %1", 		Задание.Причина);
		
	Иначе
		клог.ерр("У сбойного задания невозможно получить реквизит ИнформацияОбОшибке, он равен Неопределено!");
		
	КонецЕсли;
КонецФункции

#КонецОбласти

Функция ПолучитьМаксимальноеКоличествоАсинхронныхПроцессов(ИмяМетода) Экспорт	
	
	КОЛИЧЕСТВО_ФОНОВЫХ_ПРОЦЕССОВ_ПО_УМОЛЧАНИЮ = 3;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Спр.ПараллельныхПроцессов КАК КолПараллельныхПроцессов
		|ИЗ
		|	Справочник.мис_СвойстваМетодов КАК Спр
		|ГДЕ
		|	Спр.Наименование = &ИмяМетода";
	
	Запрос.УстановитьПараметр("ИмяМетода", ИмяМетода);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.КолПараллельныхПроцессов > 0 Тогда
			Возврат ВыборкаДетальныеЗаписи.КолПараллельныхПроцессов;	
		КонецЕсли;
	КонецЦикла;
	
	Лимит = Константы.мис_ЛимитФоновыхЗаданий.Получить();
	Если Лимит > 0 Тогда
		Возврат Лимит;
	КонецЕсли;
	
	Возврат КОЛИЧЕСТВО_ФОНОВЫХ_ПРОЦЕССОВ_ПО_УМОЛЧАНИЮ;

КонецФункции

﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДвоичныеДанныеФайла = ДокументОбъект.ДанныеФайла.Получить();
	
	Если Не ДвоичныеДанныеФайла = Неопределено Тогда
		
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml");
		ДвоичныеДанныеФайла.Записать(ИмяВременногоФайла);
		ТекстФайлаXML.Прочитать(ИмяВременногоФайла, КодировкаТекста.UTF8, "");
		
		Попытка
			УдалитьФайлы(ИмяВременногоФайла);
		Исключение
		КонецПопытки;
		
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(ЗагруженныеДокументы.Отбор, "ИмяФайла", Объект.ИмяФайла, ВидСравненияКомпоновкиДанных.Равно,,, РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(ЗагруженныеДокументы.Отбор, "Ссылка", Объект.Ссылка, ВидСравненияКомпоновкиДанных.НеРавно,,, РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный);
	
	МассивИменБлокируемыхЭлементов = Новый Массив;
	МассивИменБлокируемыхЭлементов.Добавить("Дата");
	МассивИменБлокируемыхЭлементов.Добавить("Организация");
	МассивИменБлокируемыхЭлементов.Добавить("ВидПродукции");
	МассивИменБлокируемыхЭлементов.Добавить("ВидОперации");
	МассивИменБлокируемыхЭлементов.Добавить("Заказ");
	МассивИменБлокируемыхЭлементов.Добавить("НомерЗаказа");
	МассивИменБлокируемыхЭлементов.Добавить("ДатаЗаказа");
	МассивИменБлокируемыхЭлементов.Добавить("ИмяФайла");
	МассивИменБлокируемыхЭлементов.Добавить("ДвиженияКодовМаркировки");
	
	Если Не РольДоступна("ПолныеПрава") Тогда
		Для Каждого ИмяБлокируемогоЭлемента Из МассивИменБлокируемыхЭлементов Цикл
			Элементы[ИмяБлокируемогоЭлемента].ТолькоПросмотр = Истина;
		КонецЦикла;	
		Элементы.ДвиженияКодовМаркировки.ИзменятьСоставСтрок = Ложь;
		Элементы.ДвиженияКодовМаркировки.ИзменятьПорядокСтрок = Ложь;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ДвиженияКодовМаркировкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	//Если Не РольДоступна("ПолныеПрава") Тогда
	//	
	//	СтандартнаяОбработка = Ложь;
	//	
	//	Если ВыбраннаяСтрока = Неопределено Или Поле = Неопределено Тогда
	//		Возврат;
	//	КонецЕсли;	
	//			
	//	Если Поле.Имя = "ДвиженияКодовМаркировкиНоменклатура" Или Поле.Имя = "ДвиженияКодовМаркировкиХарактеристикаНоменклатуры" Тогда
	//		ИмяКолонки = Сред(Поле.Имя, 24);
	//		СтрокаТабличнойЧасти = Объект.ДвиженияКодовМаркировки.НайтиПоИдентификатору(ВыбраннаяСтрока);
	//		ОткрытьЗначение(СтрокаТабличнойЧасти[ИмяКолонки]);
	//	КонецЕсли;	
	//		
	//КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаПриИзменении(Элемент)
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(ЗагруженныеДокументы.Отбор, "ИмяФайла", Объект.ИмяФайла, ВидСравненияКомпоновкиДанных.Равно,,, РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный);
КонецПроцедуры

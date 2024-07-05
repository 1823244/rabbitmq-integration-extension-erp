﻿&Вместо("ОбработкаПроведения")
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если НЕ ДополнительныеСвойства.Свойство("НеРегистрироватьКОбменуRabbitMQ") Тогда 
		
		Возврат;
		
	КонецЕсли; 
	
	Если НЕ АвтоматическоеЗакрытиеВозможно() Тогда 
		
	    Возврат;
		
	КонецЕсли;
	
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	КассоваяСмена.Номер                      КАК НомерКассовойСмены,
	|	КассоваяСмена.Ссылка                     КАК КассоваяСмена,
	|	КассоваяСмена.Статус                     КАК СтатусКассовойСмены,
	|	КассоваяСмена.СтатусРегламентныхОпераций КАК СтатусРегламентныхОпераций,
	|	
	|	КассоваяСмена.Организация          КАК Организация,
	|	КассоваяСмена.КассаККМ             КАК КассаККМ,
	|	КассоваяСмена.ФискальноеУстройство КАК ФискальноеУстройство,
	|	
	|	ВЫБОР
	|		КОГДА КассоваяСмена.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыКассовойСмены.Открыта)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК СменаОткрыта,
	|	
	|	ВЫБОР
	|		КОГДА КассоваяСмена.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыКассовойСмены.Открыта)
	|			ТОГДА КассоваяСмена.НачалоКассовойСмены
	|		ИНАЧЕ КассоваяСмена.ОкончаниеКассовойСмены
	|	КОНЕЦ КАК ДатаИзмененияСтатуса,
	|	КассоваяСмена.АдресРасчетов КАК АдресРасчетов,
	|	КассоваяСмена.МестоРасчетов КАК МестоРасчетов
	|ИЗ
	|	Документ.КассоваяСмена КАК КассоваяСмена
	|ГДЕ
	|	КассоваяСмена.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	КассоваяСмена.Дата УБЫВ,
	|	КассоваяСмена УБЫВ";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	ОписаниеКассовойСмены = РозничныеПродажи.ОписаниеКассовойСмены();
	
	Если Выборка.Следующий() Тогда
		
		ЗаполнитьЗначенияСвойств(ОписаниеКассовойСмены, Выборка);
		
		Если (ТекущаяДатаСеанса() - ОписаниеКассовойСмены.ДатаИзмененияСтатуса >= 86400)
			И Выборка.СменаОткрыта Тогда
			ОписаниеКассовойСмены.Ошибка24Часа = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ЭтотОбъект.КассаККМ) Тогда
		РозничныеПродажи.КСП_ЗаполнитьОписаниеКассовойСменыПоКассеККМ(ОписаниеКассовойСмены, ЭтотОбъект.КассаККМ);
	КонецЕсли;

	
	ПарыДокументовСформированы = РозничныеПродажи.ЗаполнитьОтчетыОРозничныхПродажахИВозвратах(ОписаниеКассовойСмены, "", Ложь);
	
	Если Не ПарыДокументовСформированы Тогда 
		
		Отказ = Истина;
		
	КонецЕсли;
	
	
	
КонецПроцедуры

Функция АвтоматическоеЗакрытиеВозможно() 
	
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("КассоваяСмена", Ссылка);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ЧекККМ.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ЧекККМ КАК ЧекККМ
	|ГДЕ
	|	ЧекККМ.ПометкаУдаления = ЛОЖЬ
	|	И ЧекККМ.Проведен = ЛОЖЬ
	|	И ЧекККМ.КассоваяСмена = &КассоваяСмена";
	
	Результат = Запрос.Выполнить();
	
	Возврат Результат.Пустой();
		
КонецФункции
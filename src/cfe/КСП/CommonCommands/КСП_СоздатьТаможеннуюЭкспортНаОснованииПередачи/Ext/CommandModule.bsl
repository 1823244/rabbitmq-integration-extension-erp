﻿
// +++ УваровДС 05/12/2023
// команда для добавления механизма ввода на основании таможенной на экспорт на основании передачи товара между организацией
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
   	СтруктураДанных = Новый Структура("ДокументОснование", ПараметрКоманды);
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", СтруктураДанных);
	ОткрытьФорму("Документ.ТаможеннаяДекларацияЭкспорт.ФормаОбъекта", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);

КонецПроцедуры
// --- УваровДС

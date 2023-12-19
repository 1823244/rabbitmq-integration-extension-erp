﻿//Процедура ПриОпределенииНастроек(Настройки) Экспорт
//	Настройки.ДобавитьКомандыПечати = Истина;
//	Настройки.ДобавитьКомандыОтчетов = Истина;
//	Настройки.Размещение.Добавить(Метаданные.Документы.ТаможеннаяДекларацияЭкспорт);
//КонецПроцедуры                                                                    

//// +++ УваровДС 14/12/2023
//// Команды для печатных форм
//Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
//	КомандаПечати = КомандыПечати.Добавить(); 
//	КомандаПечати.Идентификатор = "ПФ_MXL_Декларация_Экспорт";
//	КомандаПечати.Представление = НСтр("ru = 'Печать декларации (КСП)'");
//	КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
//КонецПроцедуры
//// --- УваровДС

//Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт 
//	
//	ПечатнаяФорма = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "ПФ_MXL_Декларация_Экспорт"); 
//	
//	Если ПечатнаяФорма <> Неопределено Тогда 
//		ПечатнаяФорма.ТабличныйДокумент = СформироватьПечатнуюФорму_ПФ_MXL_Декларация_Экспорт(МассивОбъектов); 
//		ПечатнаяФорма.СинонимМакета = НСтр("ru = 'Печать декларации экспорт'"); 
//	КонецЕсли;
//	
//КонецПроцедуры 

// 
//Функция СформироватьПечатнуюФорму_ПФ_MXL_Декларация_Экспорт(МассивОбъектов) Экспорт 
//	
//	Док = МассивОбъектов[0]; 
//	//Тут заполняем печатную форму 
//	//Макет = ПолучитьМакет("Макет"); 
//	//ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок"); 
//	//ТабличныйДокумент.Вывести(ОбластьЗаголовок); 
//	ТабличныйДокумент = Новый ТабличныйДокумент; 
//	Возврат ТабличныйДокумент;
//	
//КонецФункции 
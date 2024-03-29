﻿&НаСервере
Процедура ПриЗагрузкеПользовательскихНастроекНаСервере(Настройки)
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	Если ЭтаФорма.Параметры.Свойство("ИндексЛога") Тогда
		
		ПараметрСКДИдВызова = ОтчетОбъект.КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ИдВызова"));
		ПараметрСКДтолькоОшибки = ОтчетОбъект.КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ТолькоОшибки"));
		
		Если НЕ ПараметрСКДИдВызова = Неопределено Тогда
			
			ПараметрСКДИдВызова.Значение = ЭтаФорма.Параметры.ИндексЛога;
			ПараметрСКДтолькоОшибки.Значение = ЭтаФорма.Параметры.ТолькоОшибки;
			
			ПараметрПользовательскойНастройкиИдВызова = ОтчетОбъект.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ПараметрСКДИдВызова.ИдентификаторПользовательскойНастройки);
			ПараметрПользовательскойНастройкиТолькоОшибки = ОтчетОбъект.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Найти(ПараметрСКДтолькоОшибки.ИдентификаторПользовательскойНастройки);
			
			Если НЕ ПараметрПользовательскойНастройкиИдВызова = Неопределено Тогда
				ПараметрПользовательскойНастройкиИдВызова.Значение = ЭтаФорма.Параметры.ИндексЛога;
			КонецЕсли;
				Если НЕ ПараметрПользовательскойНастройкиТолькоОшибки = Неопределено Тогда
				ПараметрПользовательскойНастройкиТолькоОшибки.Значение = ЭтаФорма.Параметры.ТолькоОшибки;
			КонецЕсли;
			
		КонецЕсли;
	КонецЕсли;
	ЗначениеВРеквизитФормы(ОтчетОбъект, "Отчет");
КонецПроцедуры

&НаСервере
Процедура ПередЗагрузкойВариантаНаСервере(Настройки)
	ПараметрСКДИдВызова = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ИдВызова"));
	ПараметрСКДТолькоОшибки = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("ТолькоОшибки"));
	
	Если НЕ ПараметрСКДИдВызова = Неопределено
	   И ЭтаФорма.Параметры.Свойство("ИндексЛога") Тогда
		
		ПараметрСКДИдВызова.Значение = ЭтаФорма.Параметры.ИндексЛога;
	КонецЕсли;
	
	Если НЕ ПараметрСКДТолькоОшибки = Неопределено
	   И ЭтаФорма.Параметры.Свойство("ТолькоОшибки") Тогда
		
		ПараметрСКДТолькоОшибки.Значение = ЭтаФорма.Параметры.ТолькоОшибки;
	КонецЕсли;
КонецПроцедуры

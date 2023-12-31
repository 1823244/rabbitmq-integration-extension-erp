﻿Функция НайтиИсториюКоллекции (Номенклатура, Коллекция) Экспорт
	
	Запрос = Новый запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ксп_ИсторияИзмененийКоллекцииНоменклатуры.Номенклатура КАК Номенклатура,
	|	ксп_ИсторияИзмененийКоллекцииНоменклатуры.Коллекция КАК Коллекция
	|ИЗ
	|	РегистрСведений.ксп_ИсторияИзмененийКоллекцииНоменклатуры КАК ксп_ИсторияИзмененийКоллекцииНоменклатуры
	|ГДЕ
	|	ксп_ИсторияИзмененийКоллекцииНоменклатуры.Коллекция = &Коллекция
	|	И ксп_ИсторияИзмененийКоллекцииНоменклатуры.Номенклатура = &Номенклатура";
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Коллекция", Коллекция);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		НЗ = РегистрыСведений.ксп_ИсторияИзмененийКоллекцииНоменклатуры.СоздатьНаборЗаписей();
		НЗ.Отбор.Номенклатура.Установить(Номенклатура);
		НЗ.Отбор.Коллекция.Установить(Коллекция);
		стрк = НЗ.Добавить();
		стрк.Номенклатура = Номенклатура;
		стрк.Коллекция = Коллекция;  
		НЗ.Записать();
		
	КонецЕсли;
	
	
	
КонецФункции
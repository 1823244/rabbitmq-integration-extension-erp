﻿
Процедура ОбработкаПроведения(Отказ, Режим)

	НаборЗаписей = РегистрыСведений.КСП_ИдентификаторыТоваровДляПоказа.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Регистратор.Установить(Ссылка);
	Для Каждого ТекСтрокаИдентификаторы Из Идентификаторы Цикл
		Движение = НаборЗаписей.Добавить();
		Движение.Регистратор = Ссылка;
		Движение.Период = Дата;
		Движение.ИзмерениеКоллекция = Проект;
		Движение.Номенклатура = ТекСтрокаИдентификаторы.Номенклатура;
		Движение.Идентификатор = ТекСтрокаИдентификаторы.Идентификатор;
	КонецЦикла;
    НаборЗаписей.Записать();
	
КонецПроцедуры

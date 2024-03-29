﻿
Процедура ДобавитьОтложенноеПроведение(ДанныеСсылка) Экспорт
	
	НЗ = РегистрыСведений.ксп_ОтложенноеПроведение.СоздатьНаборЗаписей();
	НЗ.Отбор.ДокументСсылка.Установить(ДанныеСсылка);
	
	стрк = НЗ.Добавить();
	стрк.ДокументСсылка = ДанныеСсылка;
	
	стрк.СтатусОбъекта = Перечисления.ксп_СтатусыКачестваДокументов.ОК;
	стрк.СтатусПроведения = Перечисления.КСП_СтатусыОтложенногоПроведения.НеПроведен;
	
	стрк.ДатаОбработки = ТекущаяДатаСеанса();
	
	НЗ.Записать();
		
КонецПроцедуры

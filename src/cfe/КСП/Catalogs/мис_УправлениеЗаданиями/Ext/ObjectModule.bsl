﻿
Процедура ПередЗаписью(Отказ)
	Если ЭтоНовый() Или Не ЗначениеЗаполнено(Идентификатор) Тогда
		Идентификатор = Новый УникальныйИдентификатор;
	КонецЕсли;
КонецПроцедуры

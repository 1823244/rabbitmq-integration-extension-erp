﻿
&НаСервере
Процедура СоздатьДопНастройкиНаСервере()

	РегистрыСведений.ксп_ДополнительныеНастройкиИнтеграций.ДобавитьЗапись(
		"ДокументОтчетОРозничныхПродажах_ВидЦены",
		"retail",
		Неопределено);

	РегистрыСведений.ксп_ДополнительныеНастройкиИнтеграций.ДобавитьЗапись(
		"ДокументОтчетОРозничныхПродажах_НалогообложениеНДС",
		"retail",
		Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС);

КонецПроцедуры

&НаКлиенте
Процедура СоздатьДопНастройки(Команда)
	СоздатьДопНастройкиНаСервере();
КонецПроцедуры

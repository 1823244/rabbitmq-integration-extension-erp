﻿
&После("ОбработкаПроведения")
Процедура КСП_ОбработкаПроведения(Объект, Отказ, РежимПроведения)
	
	КСП_СчетаНаОплату.КСП_ОбработатьЗачетПредоплаты(Объект, Отказ);
	
КонецПроцедуры

﻿
// +++ УваровДС 12/12/2023
// чтобы в договоре организаций можно было выбирать Экспорт
&НаСервере
&После("ПриЧтенииСозданииНаСервере")
Процедура КСП_ПриЧтенииСозданииНаСервере()
	ПараметрыЗаполнения = Справочники.ДоговорыМеждуОрганизациями.ПараметрыЗаполненияНалогообложенияНДС(Объект);
	ПараметрыЗаполнения.ЭтоОперацияМеждуОрганизациями = Ложь;
	УчетНДСУП.ЗаполнитьСписокВыбораНалогообложенияНДСПродажи(Элементы.НалогообложениеНДС,
															Объект.НалогообложениеНДС,
															ПараметрыЗаполнения,
															УчетНДСКэшированныеЗначенияПараметров);
КонецПроцедуры
// --- УваровДС
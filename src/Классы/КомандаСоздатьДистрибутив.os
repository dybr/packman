
#Использовать v8runner
#Использовать logos

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
    ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Создание дистрибутива по манифесту EDF");
    // TODO - с помощью tool1cd можно получить из хранилища
    // на больших историях версий получается массивный xml дамп таблицы
    Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ФайлМанифеста", "Путь к манифесту сборки");
    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-out", "Выходной каталог");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "-setup", "Собирать дистрибутив вида setup.exe");
    Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "-files", "Собирать дистрибутив вида 'файлы поставки'");
    Парсер.ДобавитьКоманду(ОписаниеКоманды);
     
КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие ключей командной строки и их значений
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
    Параметры = РазобратьПараметры(ПараметрыКоманды);
    УправлениеКонфигуратором = ОкружениеСборки.ПолучитьКонфигуратор();
    ВыполнитьСборку(
        УправлениеКонфигуратором,
        Параметры.ФайлМанифеста,
        Параметры.СобиратьИнсталлятор,
        Параметры.СобиратьФайлыПоставки,
        Параметры.ВыходнойКаталог);
    
КонецФункции

Процедура ВыполнитьСборку(Знач УправлениеКонфигуратором, Знач ФайлМанифеста, Знач СобиратьИнсталлятор, Знач СобиратьФайлыПоставки, Знач ВыходнойКаталог) Экспорт
    
    Информация = СобратьИнформациюОКонфигурации(УправлениеКонфигуратором);
    СоздатьДистрибутивПоМанифесту(УправлениеКонфигуратором, ФайлМанифеста, Информация.Версия, СобиратьИнсталлятор, СобиратьФайлыПоставки, ВыходнойКаталог);
    
КонецПроцедуры

Функция СобратьИнформациюОКонфигурации(Знач УправлениеКонфигуратором)
    
    Лог.Информация("Запускаю приложение для сбора информации о метаданных");
    
    ФайлДанных = Новый Файл(ОбъединитьПути(УправлениеКонфигуратором.КаталогСборки(), "v8-metadata.info"));
    Если ФайлДанных.Существует() Тогда
        УдалитьФайлы(ФайлДанных.ПолноеИмя);
    КонецЕсли;
    
    ОбработкаСборщик = Новый Файл(ПутьКОбработкеСборщикуДанных());
    Если Не ОбработкаСборщик.Существует() Тогда
        ВызватьИсключение СтрШаблон("Не обнаружена обработка сбора данных в каталоге '%1'", ОбработкаСборщик.ПолноеИмя);
    КонецЕсли;
    
    УправлениеКонфигуратором.ЗапуститьВРежимеПредприятия(ФайлДанных.ПолноеИмя, Истина, "/Execute""" + ОбработкаСборщик.ПолноеИмя + """");
    
    Возврат ПрочитатьИнформациюОМетаданных(ФайлДанных.ПолноеИмя);
    
КонецФункции

Функция ПутьКОбработкеСборщикуДанных()
    Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "../../tools/СборИнформацииОМетаданных.epf");
КонецФункции

Функция ПрочитатьИнформациюОМетаданных(Знач ИмяФайла)
    
    Результат = Новый Структура();
    ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла);
    Пока Истина Цикл
        Стр = ЧтениеТекста.ПрочитатьСтроку();
        Если Стр = Неопределено Тогда
            Прервать;
        КонецЕсли;
        
        Позиция = Найти(Стр, "=");
        Если Позиция = 0 Тогда
            Продолжить;
        КонецЕсли;
        
        Результат.Вставить(Лев(Стр, Позиция-1), Сред(Стр, Позиция+1));
        
    КонецЦикла;
    
    Если Не Результат.Свойство("Версия") Тогда
        ЧтениеТекста.Закрыть();
        ВызватьИсключение "Не найдено поле Версия в файле метаданных";
    КонецЕсли;
    
    ЧтениеТекста.Закрыть();
    
    Возврат Результат;
    
КонецФункции // ПрочитатьИнформациюОМетаданных()

Функция СоздатьДистрибутивПоМанифесту(
    Знач УправлениеКонфигуратором,
    Знач ФайлМанифеста,
    Знач ВерсияМетаданных,
    Знач СобиратьИнсталлятор,
    Знач СобиратьФайлыПоставки,
    Знач ВыходнойКаталог)
    
    Сборщик = Новый СборщикДистрибутива;
    Сборщик.ФайлМанифеста = ФайлМанифеста;
    Сборщик.СоздаватьИнсталлятор = СобиратьИнсталлятор;
    Сборщик.СоздаватьФайлыПоставки = СобиратьФайлыПоставки;
    Сборщик.ВыходнойКаталог = ВыходнойКаталог; 
    
    Сборщик.Собрать(УправлениеКонфигуратором, ВерсияМетаданных, ВерсияМетаданных);
    
КонецФункции // СоздатьДистрибутивПоМанифесту(Знач УправлениеКонфигуратором, Знач ПараметрыКоманды)

Функция РазобратьПараметры(Знач ПараметрыКоманды) Экспорт
    
    Результат = Новый Структура;
    
    Если ПустаяСтрока(ПараметрыКоманды["ФайлМанифеста"]) Тогда
        ВызватьИсключение "Не задан путь к манифесту сборки (*.edf)";
    КонецЕсли;
    
    Результат.Вставить("ФайлМанифеста", ПараметрыКоманды["ФайлМанифеста"]);
    Результат.Вставить("СобиратьИнсталлятор", ПараметрыКоманды["-setup"]);
    Результат.Вставить("СобиратьФайлыПоставки", ПараметрыКоманды["-files"]);
    Результат.Вставить("ВыходнойКаталог", ПараметрыКоманды["-out"]);
    
    Возврат Результат;
    
КонецФункции

///////////////////////////////////////////////////////////////////////////////////

Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
Лог.УстановитьУровень(УровниЛога.Отладка);

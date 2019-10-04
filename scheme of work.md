# Инсталляция

#### 1. Запуск инсталлятора.
#### 2. Выводится окно приветствия с лицензионным соглашением.
#### 3. Вывод меню выбора установки редакций операционных систем.

Меню формируется из результатов обработки скрипта, который обходит папки, с редакциями ОС и проверятет в них наличие файлов key-license, получая названия ОС из значения переменной PRETTY_NAME.  
***Структура os-release файла в каталоге (один файл на каталог с редакцией системы):***
```
NAME="UBLinux"
ID=ublinux
VARIANT="Server"
VERSION="AR.03"
VERSION_ID="ar.03"
VERSION_CODENAME=andromeda
ID_LIKE=arch
PRETTY_NAME="UBLinux Server AR.01 (Andromeda)"
BUILD_ID="02.10.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux"
ID=ublinux
VARIANT="Desktop Enterprise"
VERSION="AL.02"
VERSION_ID="al.02"
VERSION_CODENAME=antlia
ID_LIKE=alpine
PRETTY_NAME="UBLinux Desktop Enterprise AL.02 (Antlia)"
BUILD_ID="02.11.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux"
ID=ublinux
VARIANT="Desktop Basic"
VERSION="DE.03"
VERSION_ID="de.03"
VERSION_CODENAME=apus
ID_LIKE=debian
PRETTY_NAME="UBLinux Desktop Basic DE.03 (Apus)"
BUILD_ID="02.12.2019"
ANSI_COLOR="1;34"
HOME_URL="http://ublinux.com/"
```
```
NAME="UBLinux Adara"
ID=ublinux
VARIANT="Server"
VERSION="AR.01"
VERSION_ID="ar.01"
VERSION_CODENAME=andromeda
ID_LIKE=arch
PRETTY_NAME="UBLinux Adara Server AR.01 (Andromeda)"
BUILD_ID="02.10.2019"
ANSI_COLOR="1;31"
HOME_URL="http://ublinux.com/"

```
```
NAME="UBLinux Adara"
ID=ublinux
VARIANT="Desktop Enterprise"
VERSION="AL.04"
VERSION_ID="al.04"
VERSION_CODENAME=aquila
ID_LIKE=alpine
PRETTY_NAME="UBLinux Desktop Enterprise AL.04 (Aquila)"
BUILD_ID="04.10.2019"
ANSI_COLOR="1;31"
HOME_URL="http://ublinux.com/"
```
Где
> NAME - имя ОС
> ID - идентификатор ОС.  
> VARIANT - редакция ОС.  
> VERSION - версия ОС, две первые буквы указывают на то, на базе какого дистрибутива основана ОС (Ar - Arch Linux, Al - Alpine Linux, De - Debian, Ce - CentOS), последующие цифры указывают на порядковый номер сборки.  
> VERSION_ID - идентификатор версии ос. Тоже самое, что VERSION, но используется только нижний регистр.  
> VERSION_CODENAME - кодовое имя ОС, присваивается произвольно в алфавитном порядке из названий созвездий, звёзд, планет, животных и т.д.  
> ID_LIKE - название дистрибутива, на базе которого основана ОС.  
> PRETTY_NAME - полное название дистрибутива ОС.  
> BUILD_ID - дата сборки дистрибутива ОС в формате "ДД.ММ.ГГГГ".  
> ANSI_COLOR - цвет вывода имени дистрибутива в консоле (формат ANSI color).  
> HOME_URL - домашняя страница пректа.

***Структура каталогов на носителе (локальный или сетевой):***  
В корне накопителя или примонтированного каталога (в случае сетевой установки) содержится каталог или каталоги, доступных для установки, редакций дистрибутивов. Папки имеют названия по имени, версии ОС. Например, UBLinux Adara Server AR.01. В этих папках кроме файла os-release присутствуют файлы-модули ОС и файл key-license. Файл key-license необходим для процедуры сетевой установки системы и получения обновлений для системы.

Файл генерируется случайным образом, для каждого экземпляра лицензии, через утилиту uuidgen с параметром r, на сервере или клиенте????? 

***Структура файла key-license на клиенте:***
```
bb58e360-a00f-4834-9243-c352dc4bd4c5
```

Если инсталлятор не обнаружил каталогов с ОС и её модулями, происходит соединение с сервером обновлений для запуска процедуры установки системы по сети с локального или удалёненого сервера обновлений.

Данные, передающиеся с клиентской машины на сервер:
1.Идентификатор лицензии (данные берутся из файла key-license).

Обработка на сервере:
1. Принять данные о лицензии (ключ);
2. Найти по идентификатору соответствующую запись в json файл-схеме

***Структура JSON-файла на сервере:***
```
{
"bb58e360-a00f-4834-9243-c352dc4bd4c5":
{
"org": "John Doe",
"date": "01.01.2020",
"type": "03,02",
},
"62f662f8-a094-418e-9b99-54921b0511bf":
{
"org": "Vasya Pupkin",
"date": "01.01.2025",
"type": "02",
}
"2e97d29a-dd50-49d3-9436-981e57125d49":
{
"org": "Tobias Boon",
"date": "01.01.2022",
"type": "11,12",
},
"e213effb-25d3-42c0-86a8-ffa0d029675b":
{
"org": "To Yama To Kanawa",
"date": "01.01.2030",
"type": "12",
}
}
```
Где
> * "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" - ключ лицензии, сгенерированный случайным образом;
> * "org" - название организации, владельца лицензии;
> * "date" - Дата окончания срока действия лицензии (дата окончания срока поддержки в формате ДД.ММ.ГГГГ);
> * "type" - код типа лицензии (Server, Enterprise, Basic или их комбинации).
>   * 01 - UBLinux Desktop Basic
>   * 02 - UBLinux Desktop Enterpise
>   * 03 - UBLinux Server
>   * 11 - UBLinux Adara Desktop Enterpise
>   * 12 - UBLinux Adara Server

#### 4. Извлечь данные: дата окончания лицензии, тип лицензии;
#### 5. Если дата окончания лицензии пройдена, формируем ответ клиенту, в котором содержится отказ;
#### 6. Если дата окончания не пройдена, проверяем, какие типы лицензий доступны;
#### 7. Формируем ответ клиенту, в котором содержатся данные для доступа к репозиторию.


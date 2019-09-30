# Инсталляция

При запуске инсталлятора выводится окно приветствия с лицензионным соглашением.
После попадаем на меню выбора установки редакций операционных систем.
Это меню формируется из результатов обработки скрипта, который обходит папки с редакциями ОС и проверятет в них наличие файлоф os-release.
Структура os-release файла в каталоге :
```
NAME="UBLinux"
VERSION="Arc.01 (Adromeda)"
ID=ublinux
ID_LIKE=archlinux
PRETTY_NAME="UBLinux Arc.01"
VERSION_ID="Arc.01"
HOME_URL="http://ublinux.com/"
SUPPORT_URL="http://help.ublinux.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ublinux/"
UBUNTU_CODENAME=andromeda
```
```
NAME="UBLinux"
VERSION="Alp.01 (Cassiopeia)"
ID=ublinux
ID_LIKE=alpinelinux
PRETTY_NAME="UBLinux Alp.01"
VERSION_ID="Alp.01"
HOME_URL="http://ublinux.com/"
SUPPORT_URL="http://help.ublinux.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ublinux/"
UBUNTU_CODENAME=cassiopeia
```
```
NAME="UBLinux"
VERSION="Deb.01 (Cassiopeia)"
ID=ublinux
ID_LIKE=debian
PRETTY_NAME="UBLinux Deb.01"
VERSION_ID="Deb.01"
HOME_URL="http://ublinux.com/"
SUPPORT_URL="http://help.ublinux.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ublinux/"
UBUNTU_CODENAME=cassiopeia
```
Необходимо редакции доделать (Server, Desktop).

Структура каталогов на носителе:
Корень-

Данные, передающиеся с клиентской машины на сервер:
1.Идентификатор лицензии (ключ сгенерирован случайным образом для каждого экземпляра лицензии).

Данные лицензии содержат в себе:
Тип лицензии (Server, Enterprise, Basic или их комбинации), на это отводится два символа. Например, 01-Server, 02-Enterpise, 03-Basic, 04-Server&Enterprise, 11-Adara_Server, 12-Adara_Enterpise, 14-Adara_Server&Adara_Enterprise;
Дата окончания лицензии, на это отводится 8 символов. Например, 23012020;
Версия системы, на это отводится 4 символа (первые два символа - основная версия, последние два - минорная версия). Например, 0122;
Блоки разделяются двоеточием.

Структура данных лицензии:
04:23012020:0122

Структура файла с зашифрованными данными лицензии на клиенте:
8F0763A7-9630A7CC-7001177E-E199430C

Обработка на сервере:
1. Принять данные о лицензии (ключ);
2. Найти по идентификатору соответствующую запись в json файл-схеме

Структура JSON-файла на сервере:
```
{
"8F0763A7-9630A7CC-7001177E-E199430C":
{
"org": "John Doe",
"date": "01.01.2020",
"type": "Server,Enterprise",
"version": "1.20"
},
"6A1478C2-0367F3DD-5001673D-A400279F":
{
"org": "Vasya Pupkin",
"date": "01.01.2025",
"type": "Enterprise",
"version": "1.18"
}
}
```

3. Извлечь данные: дата окончания лицензии, тип лицензии;
4. Если дата окончания лицензии пройдена, формируем ответ клиенту, в котором содержится отказ;
5. Если дата окончания не пройдена, проверяем, какие типы лицензий доступны;
6. Формируем ответ клиенту, в котором содержатся данные для доступа к репозиторию.


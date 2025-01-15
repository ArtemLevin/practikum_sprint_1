# Укажите образ, который будет использоваться для создания контейнера.
# Вы можете подобрать наиболее подходящий для вас: https://hub.docker.com/_/python
FROM python:3.10

# Выберите папку, в которой будут размещаться файлы проекта внутри контейнера.
# Имейте в виду, что команда WORKDIR создаст папку /opt/app, если её ещё нет,
# и перейдеёт в эту папку, то есть все команды после WORKDIR будут выполнены в
# папке /opt/app
WORKDIR /opt/app

# Заведите необходимые переменные окружения
ENV DJANGO_SETTINGS_MODULE 'config.settings'


# Скопируйте в контейнер файлы, которые редко меняются.
# Рекомендуем использовать скрипт run_uwsgi.sh в качестве точки входа в приложение.
# Там вы можете выполнить необходимые процедуры перед запуском приложения,
# такие как сбор статики, создание суперпользователя и даже применение миграций
COPY run_uwsgi.sh run_uwsgi.sh
COPY requirements.txt requirements.txt
COPY uwsgi/uwsgi.ini uwsgi.ini

# Установите зависимости, предварительно обновив менеджер пакетов pip
RUN  pip install --upgrade pip \
     && pip install -r requirements.txt
# Установите uwsgi через pip
RUN pip install uwsgi
# Скопируйте все оставшиеся файлы. Для ускорения сборки образа эту команду стоит разместить ближе к концу файла.
# Точка в команде COPY означает текущую папку.
# Так мы просим docker скопировать все файлы из текущей папки в текущую папку в контейнере (/opt/app)
COPY . .

# Укажите порт, на котором приложение будет доступно внутри Docker-сети
EXPOSE 8000

# Укажите, как запускать ваш сервис.
# Инструкция ENTRYPOINT указывает точку входа в приложение.
# Для простоты мы сразу запускаем uwsgi, но вам, возможно, будет удобнее тут указать файл run_uwsgi.sh,
# а запуск приложения осуществлять в нём
ENTRYPOINT ["uwsgi", "--strict", "--ini", "uwsgi/uwsgi.ini"]
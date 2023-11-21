# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from ubuntu


# update packages
run apt-get update

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_ROOT_USER_ACTION=ignore

# install required packages
RUN apt-get install -y python3-venv python3-dev python3-pip nginx software-properties-common vim uwsgi



RUN python3 -m venv django

WORKDIR /django
COPY requirements.txt /django

ENV PATH="/django/bin:$PATH"
RUN /bin/bash -c "source /django/bin/activate"


RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt
RUN /django/bin/django-admin startproject django_app

COPY . /django
COPY config/default /etc/nginx/sites-available/

RUN /bin/bash -c 'mkdir /etc/uwsgi/emperor.d'

COPY config/app1_uwsgi.ini /etc/uwsgi/emperor.d/
COPY config/app2_uwsgi.ini /etc/uwsgi/emperor.d/

RUN chmod +x /django/run.sh

ENTRYPOINT ["/django/run.sh"]

EXPOSE 8000

CMD bash

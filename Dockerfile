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

# install required packages
RUN apt-get install -y python3-venv python3-dev python3-pip nginx software-properties-common vim


WORKDIR /django
COPY . /django
ENV PATH="/django/bin:$PATH"

RUN ls /django

RUN /bin/bash -c "source /django/Project/Scripts/activate"
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt
COPY config/default /etc/nginx/sites-available/
RUN /bin/bash -c 'mkdir /etc/uwsgi-emperor' && \
    /bin/bash -c 'mkdir /etc/uwsgi-emperor/vassals'
COPY /config/emperor.ini /etc/uwsgi-emperor/ && \
     /config/django.ini /etc/uwsgi-emperor/vassals/

RUN service nginx restart

expose 80
cmd ["uwsgi", "--emperor", "/etc/uwsgi-emperor/emperor.ini"]

#!/bin/bash
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
flask db init
flask db migrate
flask db upgrade
flask crontab add
deactivate

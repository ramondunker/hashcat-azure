from flask import Blueprint
from flask import render_template, redirect, url_for, flash, request
from app.lib.base.provider import Provider


bp = Blueprint('install', __name__)


@bp.route('/', methods=['GET'])
def index():
    provider = Provider()
    users = provider.users()
    password_complexity = provider.password_complexity()

    if users.get_user_count() > 0:
        flash('Application has already been configured.', 'error')
        return redirect(url_for('home.index'))

    return render_template(
        'install/index.html',
        complexity=password_complexity.get_requirement_description()
    )


@bp.route('/save', methods=['POST'])
def save():
    provider = Provider()
    users = provider.users()
    settings = provider.settings()

    if users.get_user_count() > 0:
        flash('Application has already been configured.', 'error')
        return redirect(url_for('home.index'))

    username = request.form['username'].strip()
    password = request.form['password'].strip()
    full_name = request.form['full_name'].strip()
    email = request.form['email'].strip()
    hashcat_binary = '/usr/local/bin/hashcat'
    hashcat_rules_path = '/opt/rules'
    hashcat_masks_path = '/opt/masks'
    wordlists_path = '/opt/wordlists'
    uploaded_hashes_path = '/opt/hashes'

    if len(username) == 0 or len(password) == 0 or len(full_name) == 0 or len(email) == 0:
        flash('Please fill in all the fields', 'error')
        return redirect(url_for('install.index'))

    if not users.save(0, username, password, full_name, email, 1, 0, 1):
        flash('Could not create user: ' + users.get_last_error(), 'error')
        return redirect(url_for('install.index'))

    settings.save('hashcat_binary', hashcat_binary)
    settings.save('hashcat_rules_path', hashcat_rules_path)
    settings.save('hashcat_masks_path', hashcat_masks_path)
    settings.save('wordlists_path', wordlists_path)
    settings.save('uploaded_hashes_path', uploaded_hashes_path)
    flash('Please login as the newly created administrator', 'success')
    return redirect(url_for('home.index'))

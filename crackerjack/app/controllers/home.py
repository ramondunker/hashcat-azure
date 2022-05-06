from flask import Blueprint
from flask_login import current_user
from flask import render_template, redirect, url_for, flash, request
from app.lib.base.provider import Provider


bp = Blueprint('home', __name__)


@bp.route('/', methods=['GET'])
def index():
    # This function deliberately doesn't have a @login_required parameter because we want to run a check for a
    # 'first-visit' type scenario, in order to create the administrator.

    provider = Provider()
    users = provider.users()
    if users.get_user_count() == 0:
        # Looks like we need to setup the administrator.
        return redirect(url_for('install.index'))

    if not current_user.is_authenticated:
        return redirect(url_for('auth.login'))

    healthcheck = provider.healthcheck()

    errors = healthcheck.run(provider)
    if len(errors) > 0:
        for error in errors:
            flash(error, 'error')

    show_all = 'all' in request.args
    active = None if show_all else True

    sessions = provider.sessions()

    if current_user.admin:
        all_sessions = sessions.get(active=active)
    else:
        all_sessions = sessions.get(user_id=current_user.id, active=active)
        
    processes = sessions.get_running_processes()

    return render_template(
        'home/index.html',
        sessions=all_sessions,
        processes=processes,
        show_all=show_all
    )

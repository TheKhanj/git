if [ -z "$_INC_USER" ]; then
	_INC_USER=1

	_user_check() {
		if [ "$(whoami)" != "git" ]; then
			echo "error: this script must be run as the 'git' user." >&2
			exit 1
		fi
	}
fi

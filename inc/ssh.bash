if [ -z "$_INC_SSH" ]; then
	_INC_SSH=1

	_ssh_trust() {
		local host="$1"
		local known="${HOME}/.ssh/known_hosts"

		if ! [ -d "$(dirname "${known}")" ]; then
			mkdir -p "$(dirname "${known}")"
			chmod 700 "$(dirname "${known}")"
		fi

		if ! [ -f "${known}" ]; then
			touch "${known}"
			chmod 600 "${known}"
		fi

		if cat "${known}" |
			awk '{ print $1 }' |
			grep "${host}" -q >/dev/null; then
			echo "info: ssh: ${host} already trusted" >&2
			return 0
		fi

		ssh-keyscan "${host}" >>"${known}"
	}
fi

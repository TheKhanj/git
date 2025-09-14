if [ -z "$_INC_GITSRV" ]; then
	_INC_GITSRV=1

	_gitsrv_list_repos() {
		find /srv/git | grep '\.git$' | sed 's/\.git$//'
	}

	_gitsrv_init() {
		useradd -m -s /bin/bash git || true

		local dir
		local file

		dir="/home/git/.ssh"
		if ! [ -d "$dir" ]; then
			mkdir -p "$dir"
			chown git:git "$dir"
			chmod 755 "$dir"
		fi

		file="/home/git/.ssh/authorized_keys"
		cp conf/authorized_keys "$file"
		chown git:git "$file"
		chmod 644 "$file"

		dir="/srv/git"
		if ! [ -d "$dir" ]; then
			mkdir -p "/srv/git"
			chown git:git "$dir"
			chmod 755 "$dir"
		fi

		dir="/home/git/@git"
		if ! [ -d "$dir" ]; then
			ln -s /srv/git/thekhanj/git /home/git/@git
			chown git:git "$dir"
			chmod 755 "$dir"
		fi

		file="/home/git/.ssh/github"
		if ! [ -f "$file" ]; then
			ssh-keygen -t ed25519 -C "github" -f "$file"
			chown git:git "$file" "${file}.pub"
			echo "warning: don't forget to add public key to github: ${file}.pub"
		fi
	}
fi

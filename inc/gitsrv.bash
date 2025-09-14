if [ -z "$_INC_GITSRV" ]; then
	_INC_GITSRV=1

	. inc/user.bash

	_gitsrv_list_repos() {
		find /home/git | grep '\.git$' | sed 's/\.git$//'
	}

	_gitsrv_rsync_all() {
		local dir
		case "$(hostname)" in
		'black')
			dir="/mnt/purple/srv/git"
			;;
		*)
			echo "gitsrv: error: host \"$(hostname)\" does not support syncing" >&2
			return 1
			;;
		esac

		rsync -avt --delete git@thekhanj.ir:. "$dir" --info=progress2
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

		file="/home/git/.ssh/id_ed25519_github"
		if ! [ -f "$file" ]; then
			ssh-keygen -t ed25519 -C "github" -f "$file"
			chown git:git "$file" "${file}.pub"

			echo "warning: gitsrv: don't forget to add public key to github: ${file}.pub" >&2
		fi

		file="/home/git/.ssh/config"
		if ! [ -f "$file" ]; then
			tee "$file" >/dev/null <<-EOF
				Host github.com
				    HostName github.com
				    User git
				    IdentityFile ~/.ssh/id_ed25519_github
			EOF
			chown git:git "$file"
			chmod 600 "$file"
		fi
	}
fi

if [ -z "$_INC_GITSRV" ]; then
	_INC_GITSRV=1

	_gitsrv_list_repos() {
		find /srv/git | grep '\.git$' | sed 's/\.git$//'
	}

	_gitsrv_init() {
		useradd -m -s /bin/bash || true
		su - git <<-EOF
			cd "\$HOME"
			mkdir -p .ssh
			echo '$(cat conf/authorized_keys)' > .ssh/authorized_keys
			chmod 644 .ssh/authorized_keys
		EOF
	}
fi

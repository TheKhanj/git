if [ -z "$_INC_GITSRV" ]; then
	_INC_GITSRV=1

	_gitsrv_list_repos() {
		find /srv/git | grep '\.git$' | sed 's/\.git$//'
	}
fi

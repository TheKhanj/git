if [ -z "$_INC_GITHUB" ]; then
	_INC_GITHUB=1

	. 'inc/gitsrv.bash'

	PAT='some shit, my mistake, i will fix it in future :), technically i am from future right now 😱'
	USERNAME=thekhanj

	_github_list_repos() {
		local page=1
		local repos

		while :; do
			repos=$(
				curl -s -u "$USERNAME:$PAT" \
					"https://api.github.com/user/repos?per_page=100&page=$page" |
					jq -r '.[].ssh_url' |
					grep -i '^git@github.com:thekhanj'
			)

			[ -z "$repos" ] && break

			echo "$repos"
			((page++))
		done
	}

	_github_clone_all() {
		local concurrency="${1:-10}"

		if ! [ -d "/srv/git" ]; then
			echo "error: directory /srv/git does not exist: run \"gitsrv init\" first" >&2
			return 1
		fi

		# shellcheck disable=SC2016
		_github_list_repos |
			parallel -j "$concurrency" '
				repo_url={}
				repo_name=$(basename "$repo_url" .git)
				target="/srv/git/$repo_name"
				if [ ! -d "$target" ]; then
						echo "Cloning $repo_url into $target"
						git clone "$repo_url" "$target"
				else
						echo "$target already exists, skipping"
				fi
			'
	}

	# shellcheck disable=SC2016
	_github_pull_all() {
		local concurrency="${1:-10}"

		_gitsrv_list_repos |
			parallel -j "$concurrency" '
				dir={}
				cd "$dir"
				git pull
			'
	}

	# shellcheck disable=SC2016
	_github_push_all() {
		local concurrency="${1:-10}"

		_gitsrv_list_repos |
			parallel -j "$concurrency" '
				dir={}
				cd "$dir"
				git push
			'
	}
fi

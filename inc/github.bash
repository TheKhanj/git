if [ -z "$_INC_GITHUB" ]; then
	_INC_GITHUB=1

	. 'inc/ssh.bash'
	. 'inc/user.bash'
	. 'inc/gitsrv.bash'

	_github_list_repos() {
		local page=1
		local repos

		if [ -z "$GITHUB_USERNAME" ]; then
			echo "error: github: GITHUB_USERNAME is not set" >&2
			return 1
		fi
		if [ -z "$GITHUB_PAT" ]; then
			echo "error: github: GITHUB_PAT is not set" >&2
			return 1
		fi

		while :; do
			repos=$(
				curl -s -u "$GITHUB_USERNAME:$GITHUB_PAT" \
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

		_user_check
		_github_trust
		# shellcheck disable=SC2016
		_github_list_repos |
			parallel -j "$concurrency" '
				repo_url={}
				repo_name=$(basename "$repo_url" .git)
				target="/home/git/$repo_name"
				if [ ! -d "$target" ]; then
						echo "info: github: cloning $repo_url into $target" >&2
						git clone "$repo_url" "$target"
				else
						echo "info: github: $target already exists, skipping" >&2
				fi
			'
	}

	_github_pull_all() {
		local concurrency="${1:-10}"

		_user_check
		_github_trust
		# shellcheck disable=SC2016
		_gitsrv_list_repos |
			parallel -j "$concurrency" '
				dir={}
				cd "$dir"
				git pull
			'
	}

	_github_push_all() {
		local concurrency="${1:-10}"

		_user_check
		_github_trust
		# shellcheck disable=SC2016
		_gitsrv_list_repos |
			parallel -j "$concurrency" '
				dir={}
				cd "$dir"
				git push
			'
	}

	_github_trust() {
		_ssh_trust "github.com"
	}
fi

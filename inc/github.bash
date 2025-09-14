if [ -z "$_INC_GITHUB" ]; then
	_INC_GITHUB=1

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
fi

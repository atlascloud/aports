#!/bin/sh
# shellcheck disable=SC2039,SC2155

MIRROR_URI="http://dl-cdn.alpinelinux.org/alpine/$RELEASE"
APORTS_DIR="${APORTS_DIR:-/home/build}"

die() {
	echo "$@" 1>&2
	echo 1>&2
	exit 1
}

# Prints names of repo's subdirs (i.e. abuilds) that contains APKBUILDs which
# has been changed/created in the specified revisions. The abuild names are
# printed in a build order.
changed_abuilds() {
	local repo="$1"
	local commit_ish="$2"

	# Get names of repo's subdirectories with modified APKBUILD,
	# but ignore deleted ones.
	local committed_aports="$(git diff-tree -r --relative="$repo" --name-only --diff-filter=ACMR \
					"$commit_ish" -- '*APKBUILD' | xargs -I% dirname % | xargs)"
	local uncommitted_aports="$(git status -s -u -- "${repo}"/*APKBUILD | xargs -I% dirname % | cut -f2 -d/)"

	# remove duplicates from the lists
	local aports="$(echo -e "$committed_aports"\\n"$uncommitted_aports" | uniq)"

	# Sort abuilds by build order.
	# ap builddirs -d "$(pwd)/$repo" $aports 2>/dev/null | xargs -I% basename %
	echo "$aports"
}

# Replaces /etc/apk/repositories with repositories at $MIRROR_URI that are on
# the same or higher level than the given repo (main > community > testing)
# and after that runs `apk update`.
#
# $1: the target repository; main, community, or testing
set_repositories_for() {
	local target_repo="$1"

	local repo; for repo in main community ; do # testing
		echo "Adding $MIRROR_URI/$repo to /etc/apk/repositories"
		echo "$MIRROR_URI/$repo" | sudo tee -a /etc/apk/repositories
		[ "$repo" = "$target_repo" ] && break
	done

	sudo apk update
}

cd "$APORTS_DIR" || exit

mkdir -p "$HOME"/packages/"$RELEASE"/main/x86_64

# lay down private key file
echo -en "${SIGNING_KEY}" > ~/.abuild/packages@kws1.com-5f35c485.rsa
sudo cp ~/.abuild/packages@kws1.com-5f35c485.rsa.pub /etc/apk/keys/

commit_range="$(git rev-parse 'HEAD^1')..HEAD"

echo 'Diffstat:'
git --no-pager diff --color --stat "$commit_range"

# shellcheck disable=SC2043
for repo in znver1 main; do
	set_repositories_for "$repo"

	oIFS=$IFS
	IFS="
"
	for pkgname in $(changed_abuilds "$repo" "$commit_range"); do
		qname="$repo/$pkgname"

		echo "$pkgname" "Building package $qname"
		cd "$qname" || continue

		if abuild -r; then
			checkapk || :
			successful_pkgs="$successful_pkgs $qname"
		else
			failed_pkgs="$failed_pkgs $qname"
		fi

		cd "$APORTS_DIR" || exit
		echo "$pkgname"
	done

	IFS=$oIFS
done

# find ~
# env

printf '\n----\n'
if [ -n "$successful_pkgs" ]; then
	echo "Successfully built packages:$successful_pkgs"
fi
if [ -n "$failed_pkgs" ]; then
	die "Failed to build packages:$failed_pkgs"

elif [ -z "$successful_pkgs" ]; then
	echo 'No packages found to be built.'
fi

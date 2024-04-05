#!/bin/sh

set -x

if ! git config user.name ; then
    # some configuration in case we push any changes
    git config --global user.name github-actions
    git config --global user.email github-actions@github.com
    git config --global core.pager ''
fi

# check each packages latest version, update the APKBUILD and commit if any changes
for pkg in $( cd main && find . -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
    echo "checking $pkg"
    [ -f "./checkers/$pkg" ] || continue # if we don't have a checker, skip

    latest_version=$(./checkers/"$pkg")
    echo "latest version: $latest_version"
    sed -i "s:pkgver=.*:pkgver=$latest_version:" main/"$pkg"/APKBUILD
    sed -i "s:pkgrel=.*:pkgrel=0:" main/"$pkg"/APKBUILD

    # FIXME we shouldn't create the PR if only the pkgrel has changed
    # also we are pushing all commits to branches rather than just the one
    # maybe a git reset will fix that

    if ! git diff --stat --exit-code main/"$pkg" ; then
        git branch -av
        # if the branch already exists, we can assume the original PR
        # already exists and just hasn't been merged yet
        git branch -a | grep -q "package_bump/main/$pkg-$latest_version" && continue

        echo "Changes found in main/$pkg. Updating checksum & committing."
        task docker:checksum PKG=main/"$pkg"

        git checkout -b package_bump/main/"$pkg"-"$latest_version"

        git add main/"$pkg"
        git commit -m "main/$pkg: upgrade to $latest_version

        Automated package bump"
        # push any changes we may have committed
        # we do this here so each update package becomes it's own branch
        # which can then be PR'ed separately
        git push origin package_bump/main/"$pkg"-"$latest_version"
        gh config set prompt disabled
        gh pr create --assignee iggy --fill
    fi
done

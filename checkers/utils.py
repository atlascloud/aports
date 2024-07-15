import requests
import sys
# from pkg_resources import parse_version # deprecated
from packaging import version

def get_latest_gh_tag(proj: str, must_have: str = "", ignore: str = "") -> str:
    """find latest version based on gh tags

    :param proj:
        github project i.e. ``ceph/ceph``
    """
    highest_version = version.parse('0.0.0')

    r = requests.get('https://api.github.com/repos/' + proj + '/tags?per_page=100')

    j = r.json()

    for t in j:
        if isinstance(t, str):
            print("t", t, file=sys.stderr)
        if t.get('name') and t['name'] != "":
            try:
                vers = version.parse(t['name'])
            except InvalidVersion:
                # probably some weird tag (I've seen nightly as an example)
                continue
            if must_have != "":
                if must_have not in t['name']:
                    continue
            if ignore != "":
                if ignore in t['name']:
                    continue
            if vers > highest_version:
                highest_version = vers

    return highest_version


def get_latest_gh_releases(proj: str, must_have: str = "", ignore: str = "") -> str:
    """find latest version based on gh releases

    :param proj:
        github project i.e. ``adguardteam/adguardhome``
    """
    highest_version = version.parse('0.0.0')

    r = requests.get('https://api.github.com/repos/' + proj + '/releases?per_page=100')

    j = r.json()

    for t in j:
        # I think tag_name is safer to use here than name, but they seem to be
        # the same in most of the stuff I looked at
        if t.get('tag_name') and t['tag_name'] != "":
            try:
                vers = version.parse(t['tag_name'])
            except InvalidVersion:
                # probably some weird tag (I've seen nightly as an example)
                continue
            if must_have != "":
                if must_have not in t['tag_name']:
                    continue
            if ignore != "":
                if ignore in t['tag_name']:
                    continue
            if vers > highest_version:
                highest_version = vers

    return highest_version

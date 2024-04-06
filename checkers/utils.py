import requests
# from pkg_resources import parse_version # deprecated
from packaging import version

def get_latest_gh_tag(proj: str, filter_not: str = None) -> str:
    """find latest version based on gh tags

    :param proj:
        github project i.e. ``ceph/ceph``
    """
    highest_version = '0.0.0'

    r = requests.get('https://api.github.com/repos/' + proj + '/tags')

    j = r.json()

    for t in j:
        if t['name'].startswith('v'):
            vers = t['name'].replace('v', '')
            # # in ceph land X.2.X versions are the current stable
            if filter_not:
                if filter_not not in vers:
                    continue
            if version.parse(vers) > version.parse(highest_version):
                highest_version = vers

    return highest_version


def get_latest_gh_releases(proj: str, filter_not: str = None) -> str:
    """find latest version based on gh tags

    :param proj:
        github project i.e. ``ceph/ceph``
    """
    highest_version = '0.0.0'

    r = requests.get('https://api.github.com/repos/' + proj + '/tags')

    j = r.json()

    for t in j:
        if t['name'].startswith('v'):
            vers = t['name'].replace('v', '')
            # # in ceph land X.2.X versions are the current stable
            if filter_not:
                if filter_not not in vers:
                    continue
            if version.parse(vers) > version.parse(highest_version):
                highest_version = vers

    return highest_version
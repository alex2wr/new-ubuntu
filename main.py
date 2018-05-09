#!/usr/bin/python3
# ******************************************************************************#
# Author: Alex Moreno                                                           #
# Date: 4/07/2018                                                               #
# Description: This scripts is meant to customize a new Ubuntu instalation by   #
# doing the following:                                                          #
#   1. Downlaods and adds keys                                                  #
#   2. Adds sources either repositories or ppa as used                          #
#       in the command apt-get-repository                                       #
#   3. Installs packages                                                        #
#   4. Adds fstab entries to MyDS shares in nfs format                          #
#   5. Downloads files from internet as with wget and installs them if possible #
# Notes:                                                                        #
# ******************************************************************************#

__version__ = 0.5

import apt
import os
# import fstab
import xml.etree.ElementTree as ET
import aptsources.sourceslist as SL
import softwareproperties.SoftwareProperties as SP
from collections import defaultdict
import apt_pkg as AP
import wget


class GetFromXML:
    """
    This class takes an XML file containing all data needed to install debian type
    packages organized with the tags: <key> <repository> <ppa> <package> <entry>
    Use the included template.xml as a start point.
    """
    def __init__(self, data_XML):
        self._data_XML = data_XML
        print('The object ', end='')
        print(self.__class__.__name__, end='')
        print(' has been initialized with {} as the path for XML data source file'.format(data_XML))

    def get_values(self, tags_dict):
        print('Getting values from {} and adding them to dict var according to XML tags.'.format(self._data_XML))
        root = ET.parse(self._data_XML).getroot()
        d = defaultdict(list)
        d.update(tags_dict)
        for k in tags_dict:
            if k == 'key':
                print("Adding the following keys to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
                    self.key = v.text
            elif k == 'repository':
                print("Adding the following repository to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
            elif k == 'ppa':
                print("Adding the following ppa to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
            elif k == 'package':
                print("Adding the following package to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
            elif k == 'entry':
                print("Adding the following entry to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
            elif k == 'download':
                print("Adding the following download to dict var: ")
                for v in root.iter(k):
                    print(v.text)
                    d[k].append(v)
        return d

    @property
    def key(self):
        return

    @key.setter
    def key(self, value):
        _value = []
        _value.append(value)


class InstallPackages:

    @staticmethod
    def add_sources(self, soruce_val):
        root = ET.parse(soruce_val).getroot()
        for repo in root.iter('repository'):                        # e stands for element
            if repo.get('install') == 'True':
                source = SL.SourcesList()
                SE = SL.SourceEntry
                sl = SE.mysplit(repo, repo.text)                        # sl = split line
                # source.backup()
                if 'arch' in sl[1]:
                    pass
                    # source.add(sl[0], sl[2], sl[3], sl[4], sl[1])
                else:
                    pass
                    # source.add(sl[0], sl[1], sl[2], sl[3])
        for ppa in root.iter('ppa'):
            if ppa.get('install') == 'True':
                SPsp = SP.SoftwareProperties()
                # key = SP.ppa.AddPPASigningKey()
                SPsp.add_source_from_line(ppa.text)
        source.save()                                     # Remove this comment for release version

    @staticmethod
    def add_keys(self, key_value):
        wget.download(key_value)
        # code here to add keys

    @staticmethod
    def install_packages(self, data_XML):
        cache = apt.Cache()
        root = ET.parse(data_XML).getroot()
        for element in root.iter('package'):
            try:
                if element.get('install') == 'True':
                    package = cache[element.text]
                    print(element.text + ' will be installed')
                    package.mark_install()
                    package.commit()
                else:
                    print(element.text + ' will NOT be installed')
            except KeyError as e:
                print(e.args)
                print('Unable to find package: ' + package.name)
                print('Make sure package name is spelled correctly in the source XML file.')


class MyFstab:
    """
        This is my class definition to operate on fstab as the fstab module does not
        have documentation or/nor could I find examples online to follow.  The file
        operation is simple enough to write my own class.
    """
    def __init__(self, myfstab='/etc/fstab'):
        self._fstab = myfstab
        print('The object ', end='')
        print(self.__class__.__name__, end='')
        print(' has been initialized with {} as the path for fstab'.format(myfstab))

    def read_all(self):
        f = open(self._fstab, 'r')
        for line in f:
            print(line, end='')
        f.close()

    def append_nline(self, line):
        f = open(self._fstab, 'r+')
        for l in f:
            if line in l:
                break
        else:
            f.writelines(line + '\n')
        f.close()


class GetDownloads:

    @staticmethod
    def download(self, key_value):
        return wget.download(key_value)


class InstallDownloads:
    pass


class SetSettings:
    pass


def main():
    print('Started running {} script.'.format(__file__))
    # This data dictionary keys have to match with the if/elif from the .get_values() method.
    data_path = os.path.dirname(os.path.realpath(__file__))
    data_file = os.path.join(data_path, 'data.xml')
    data_var = dict(key=[], repository=[], ppa=[], package=[], entry=[], download=[])
    xml = GetFromXML(data_file)
    xml.get_values(data_var)                    # Because this method returns, it can be set equal to a var
    ip = InstallPackages()
    ae = MyFstab()
    for tg, dk in data_var.items().__iter__():                  # dk: dict key
        for i, v in enumerate(dk):
            print('Processing {} from source xml file.'.format(v.text))
            if v.attrib['install'] == 'True':
                if tg == 'key':
                    # ip.add_keys(v.text)
                    # InstallPackages.add_keys(v.text)
                    xml.key[0]
                if tg == 'repository' or tg == 'ppa':
                    ip.add_sources(v.text)
                if tg == 'package':
                    pass
                    # ip.install_packages()
                if tg == 'entry':
                    ae.append_nline(v.text)
                if tg == 'download':
                    wget.download(v.text)

    print('Finished running {} script.'.format(__file__))


if __name__ == '__main__': main()



#!/usr/bin/env python

from lxml import etree

build_idx = 3
tree = etree.parse('config.xml')

root = tree.getroot()
current_version = root.attrib['ios-CFBundleVersion']

tokens = current_version.split('.')
tokens[build_idx] = str(int(tokens[build_idx]) + 1)

root.attrib['ios-CFBundleVersion']  = '.'.join(tokens)


with open('./config.xml', 'w') as file_handle:
    file_handle.write(etree.tostring(tree, pretty_print=True, encoding='utf8', method='xml', xml_declaration=True))


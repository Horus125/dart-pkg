#!/usr/bin/env python
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import argparse
import os
import shutil
import subprocess
import sys
import tempfile

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path += [os.path.join(SCRIPT_PATH, 'third_party/PyYAML-3.12/lib')]
import yaml


DEST_PATH = os.path.join(os.path.dirname(SCRIPT_PATH), 'pub')


LICENSE_FILES = ['LICENSE', 'LICENSE.txt']


IGNORED_EXTENSIONS = ['css', 'html', 'jpg', 'js', 'log', 'old', 'out', 'png', 'zip']

LOCAL_PACKAGES = {
  'analyzer': '//dart/pkg/analyzer',
  'flutter': '//lib/flutter/packages/flutter',
  'typed_mock': '//dart/pkg/typed_mock',
  'http': '//apps/modules/packages/flutter-http',
}

FORBIDDEN_PACKAGES = ['mojo', 'mojo_services']

def parse_packages_file(dot_packages_path):
    """ parse the list of packages and paths in .packages file """
    packages = []
    with open(dot_packages_path) as dot_packages:
        # The packages specification says both '\r' and '\n' are valid line
        # delimiters, which matches Python's 'universal newline' concept.
        # Packages specification: https://github.com/dart-lang/dart_enhancement_proposals/blob/master/Accepted/0005%20-%20Package%20Specification/DEP-pkgspec.md
        contents = dot_packages.read()
        for line in unicode.splitlines(unicode(contents)):
            if line.startswith('#'):
                continue
            delim = line.find(':')
            if delim == -1:
                continue
            name = line[:delim]
            path = line[delim + 1:-1]
            packages.append((name, path))
    return packages


def parse_full_dependencies(yaml_path):
    """ parse the content of a pubspec.yaml """
    with open(yaml_path) as yaml_file:
        parsed = yaml.safe_load(yaml_file)
        if not parsed:
            raise Exception('Could not parse yaml file: %s' % yaml_file)
        package_name = parsed['name']
        get_deps = lambda dep_type: parsed[dep_type] if dep_type in parsed and parsed[dep_type] else {}
        deps = get_deps('dependencies')
        dev_deps = get_deps('dev_dependencies')
        dep_overrides = get_deps('dependency_overrides')
        return (package_name, deps, dev_deps, dep_overrides)


def parse_dependencies(yaml_path):
    """ parse the dependency map out of a pubspec.yaml """
    _, deps, _, _ = parse_full_dependencies(yaml_path)
    return deps


def write_build_file(build_gn_path, package_name, name_with_version, deps):
    """ writes BUILD.gn file for Dart package with dependencies """
    with open(build_gn_path, 'w') as build_gn:
        build_gn.write('''# This file is generated by importer.py for %s

import("//build/dart/dart_package.gni")

dart_package("%s") {
  package_name = "%s"

  source_dir = "lib"

  deps = [
''' % (name_with_version, package_name, package_name))
        for dep in deps:
            if dep in LOCAL_PACKAGES:
                build_gn.write('    "%s",\n' % LOCAL_PACKAGES[dep])
            else:
                build_gn.write('    "//third_party/dart-pkg/pub/%s",\n' % dep)
        build_gn.write('''  ]
}
''')


def main():
    parser = argparse.ArgumentParser('Import dart packages from pub')
    parser.add_argument('--pubspecs', nargs='+',
                        help='Paths to packages containing pubspec.yaml files')
    parser.add_argument('--projects', nargs='+',
                        help='Paths to projects containing dependency files')
    args = parser.parse_args()
    tempdir = tempfile.mkdtemp()
    try:
        importer_dir = os.path.join(tempdir, 'importer')
        os.mkdir(importer_dir)
        packages = {}
        additional_deps = {}
        for path in args.pubspecs:
            yaml_file = os.path.join(path, 'pubspec.yaml')
            package_name, _, dev_deps, _ = parse_full_dependencies(yaml_file)
            packages[package_name] = path
            additional_deps.update(dev_deps)
        with open(os.path.join(importer_dir, 'pubspec.yaml'), 'w') as pubspec:
            pubspec.write('''name: importer
dependencies:
''')
            for package_name in packages.keys():
                pubspec.write(r'''  %s: any
''' % package_name)
            for dep, version in additional_deps.iteritems():
                if dep in packages:
                    continue
                # Note: this won't work for path dependencies.
                pubspec.write(r'''  %s: "%s"
''' % (dep, version))
            for project in args.projects:
                yaml_file = os.path.join(project, 'dart_dependencies.yaml')
                project_deps = parse_dependencies(yaml_file)
                for dep, version in project_deps.iteritems():
                    pubspec.write('''  %s: "%s"
''' % (dep, version))
            # Add dependency overrides for roots.
            pubspec.write(r'''dependency_overrides:
''')
            for package_name, path in packages.iteritems():
                pubspec.write(r'''  %s:
    path: %s
''' % (package_name, path))
        pub_cache_dir = os.path.join(tempdir, 'pub_cache')
        os.mkdir(pub_cache_dir)
        env = os.environ
        env['PUB_CACHE'] = pub_cache_dir
        subprocess.check_call(['flutter', 'pub', 'get'], cwd=importer_dir, env=env)
        if os.path.exists(DEST_PATH):
            shutil.rmtree(DEST_PATH)
        packages = parse_packages_file(os.path.join(importer_dir, '.packages'))
        for package in packages:
            if not package[1].startswith('file://'):
                continue
            source_dir = package[1][len('file://'):]
            if not os.path.exists(source_dir):
                continue
            if source_dir.find('pub.dartlang.org') == -1:
                continue
            package_name = package[0]
            # Don't import packages that live canonically in the tree.
            if package_name in LOCAL_PACKAGES:
                continue
            if package_name in FORBIDDEN_PACKAGES:
                print 'Warning: dependency on forbidden package %s' % package_name
                continue
            # We expect the .packages file to point to a directory called 'lib'
            # inside the overall package, which will contain the LICENSE file
            # and other potentially useful directories like 'bin'.
            source_base_dir = os.path.dirname(os.path.abspath(source_dir))
            name_with_version = os.path.basename(source_base_dir)
            has_license = any(os.path.exists(os.path.join(source_base_dir, file_name))
                              for file_name in LICENSE_FILES)
            if not has_license:
                print 'Could not find license file for %s, skipping' % package_name
                continue
            pubspec_path = os.path.join(source_base_dir, 'pubspec.yaml')
            deps = []
            if os.path.exists(pubspec_path):
                deps = parse_dependencies(pubspec_path)
            dest_dir = os.path.join(DEST_PATH, package_name)
            shutil.copytree(source_base_dir, dest_dir,
                            ignore=shutil.ignore_patterns(
                                *('*.' + extension for extension in IGNORED_EXTENSIONS)))
            # We don't need the 'test' directory of packages we import as that
            # directory exists to test that package and some of our packages
            # have very heavy test directories, so nuke those.
            test_path = os.path.join(dest_dir, 'test')
            if os.path.exists(test_path):
                shutil.rmtree(test_path)
            write_build_file(os.path.join(dest_dir, 'BUILD.gn'), package_name,
                             name_with_version, deps)

    finally:
        shutil.rmtree(tempdir)

if __name__ == '__main__':
    sys.exit(main())

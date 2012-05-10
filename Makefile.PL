use inc::Module::Install;
name 'Data-DestructuringAssignment';
all_from 'lib/Data/DestructuringAssignment.pm';
readme_from 'lib/Data/DestructuringAssignment.pm';

githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

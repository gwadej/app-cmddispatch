use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Subcmd',
    AUTHOR              => 'G. Wade Johnson <wade@cpan.org>',
    VERSION_FROM        => 'lib/App/Subcmd.pm',
    ABSTRACT_FROM       => 'lib/App/Subcmd.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-Subcmd-*' },
);

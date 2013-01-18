use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::CmdDispatch',
    AUTHOR              => 'G. Wade Johnson <wade@cpan.org>',
    VERSION_FROM        => 'lib/App/CmdDispatch.pm',
    ABSTRACT_FROM       => 'lib/App/CmdDispatch.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'Config::Tiny' => 0,
        'Term::ReadLine' => 0,
    },
    LICENSE             => 'perl',
    META_MERGE          => {
        resources => {
            repository => 'https://github.com/gwadej/app-cmddispatch',
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-CmdDispatch-*' },
);

use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Log::Any::Adapter::Fille',
    AUTHOR           => q{Mikhail Ivanov <m.ivanych@gmail.com>},
    VERSION_FROM     => 'lib/Log/Any/Adapter/Fille.pm',
    ABSTRACT_FROM    => 'lib/Log/Any/Adapter/Fille.pm',
    LICENSE          => 'perl_5',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'utf8::all' => 0,
        'Log::Any'  => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Log-Any-Adapter-Fille-*' },
);

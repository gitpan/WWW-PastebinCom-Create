use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::PastebinCom::Create',
    license             => 'perl',
    dist_author         => 'Zoffix Znet <zoffix@cpan.org>',
    dist_version_from   => 'lib/WWW/PastebinCom/Create.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Carp'           => 1.04,
        'URI'            => 1.35,
        'LWP::UserAgent' => 2.036,
        'overload'       => 1.04,
    },
    add_to_cleanup      => [ 'WWW-PastebinCom-Create-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();

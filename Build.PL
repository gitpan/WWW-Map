use strict;
use warnings;
use Module::Build;

my $builder =
    Module::Build->new
        ( module_name         => 'WWW::Map',
          license             => 'perl',
          dist_author         => 'David Rolsky <autarch@urth.org>',
          requires            => { 'Geography::States' => 0,
                                   'Params::Validate'  => 0,
                                   'Test::More'        => 0,
                                 },
          add_to_cleanup      => [ 'WWW-Map-*' ],
          create_makefile_pl  => 'passthrough',
          sign                => 1,
);

$builder->create_build_script();

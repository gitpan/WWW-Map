#!/usr/bin/perl -w

use strict;

use Test::More tests => 11;

use WWW::Map;

use URI;
use URI::QueryParam;

{
    my $map = WWW::Map->new( country => 'switzerland',
                             address => 'rue de Paquis 25',
                             city    => 'Geneva',
                             state   => 'Geneve',
                             postal_code => '1201',
                           );

    my $uri = $map->uri;

    ok( $uri, 'some sort of url was generated' );

    my $obj = $map->uri_object;

    is( $obj->scheme, 'http', 'URL scheme is http' );

    is( $obj->host, 'www.multimap.com', 'URL host is www.multimap.com' );

    is( $obj->path, '/map/places.cgi', 'URL path is /map/places.cgi' );

    my %expect = ( addr2       => 'rue de Paquis 25',
                   addr3       => 'Geneva',
                   pc          => '1201',
                   db          => 'CH',
                   client      => 'public',
                   advanced    => '',
                   overviewmap => '',
                 );

    while ( my ( $k, $v ) = each %expect )
    {
        is( $obj->query_param($k), $v, "URL query param $k should be $v" );
    }
}

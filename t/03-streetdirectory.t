#!/usr/bin/perl -w

use strict;

use Test::More tests => 18;

use WWW::Map;

use URI;
use URI::QueryParam;

{
    my $map = WWW::Map->new( country => 'australia',
                             address => '606 Station Street',
                             city    => 'Box Hill',
                             state   => 'Victoria',
                             postal_code => '3128',
                           );

    my $uri = $map->uri;

    ok( $uri, 'some sort of url was generated' );

    my $obj = $map->uri_object;

    is( $obj->scheme, 'http', 'URL scheme is http' );

    is( $obj->host, 'www.street-directory.com.au', 'URL host is www.street-directory.com.au' );

    is( $obj->path, '/aus_new/index.cgi', 'URL path is /aus_new/index.cgi' );

    my %expect = ( StreetNo    => '606',
                   StreetName  => 'Station',
                   Suburb      => 'Box Hill',
                   CountryName => 'VIC',
                   PostCode    => '3128',
                   StreetType  => 'ALL',
                 );

    while ( my ( $k, $v ) = each %expect )
    {
        is( $obj->query_param($k), $v, "URL query param $k should be $v" );
    }
}

{
    my $map = WWW::Map->new( country => 'australia',
                             address => 'ABC Station Street',
                             city    => 'Box Hill',
                             state   => 'Victoria',
                             postal_code => '3128',
                           );

    ok( ! $map, 'No map object was returned.' );
}

{
    my $map = WWW::Map->new( country => 'australia',
                             address => '606 Station Street',
                             city    => 'Box Hill',
                             postal_code => '3128',
                           );

    ok( ! $map, 'No map object was returned.' );
}

{
    my $map = WWW::Map->new( country => 'singapore',
                             address => '208 Jalan Besar',
                             city    => 'Singapore',
                             state   => 'Singapore',
                             postal_code => '208894',
                           );

    my $uri = $map->uri;

    ok( $uri, 'some sort of url was generated' );

    my $obj = $map->uri_object;

    is( $obj->scheme, 'http', 'URL scheme is http' );

    is( $obj->host, 'www.streetdirectory.com.sg', 'URL host is www.streetdirectory.com.sg' );

    is( $obj->path, '/map.jsp', 'URL path is /map.jsp' );

    my %expect = ( postalcode => '208894',
                 );

    while ( my ( $k, $v ) = each %expect )
    {
        is( $obj->query_param($k), $v, "URL query param $k should be $v" );
    }
}

{
    my $map = WWW::Map->new( country => 'singapore',
                             address => '208 Jalan Besar',
                             city    => 'Singapore',
                             state   => 'Singapore',
                           );

    ok( ! $map, 'No map object was returned.' );
}

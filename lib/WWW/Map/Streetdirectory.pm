package WWW::Map::Streetdirectory;

use strict;

use Geography::States;

use base 'WWW::Map';


my %Query = ( australia => { StreetType => 'ALL' },
              singapore => {},
            );

my %Host  = ( australia => 'www.street-directory.com.au',
              singapore => 'www.streetdirectory.com.sg',
            );

my %Path  = ( australia => '/aus_new/index.cgi',
              singapore => '/map.jsp',
            );

sub Countries { keys %Query }

sub new
{
    my $class = shift;
    my %p = @_;

    my %query = %{ $Query{ $p{country} } };

    my $m = "_$p{country}_query";
    $class->$m( \%p, \%query )
        or return;

    return bless { host  => $Host{ $p{country} },
                   path  => $Path{ $p{country} },
                   query => \%query,
                 }, $class;
}

sub _singapore_query
{
    shift;
    my ( $p, $q ) = @_;

    return unless defined $p->{postal_code};

    $q->{postalcode} = $p->{postal_code};

    return 1;
}

sub _australia_query
{
    shift;
    my ( $p, $q ) = @_;

    return unless defined $p->{state};

    return unless defined $p->{address};

    return unless defined $p->{postal_code} || defined $p->{city};

    $p->{address} =~ s/\s*\b(?:road|rd|street|st|ave|av|avenue|dr|
                               drive|ct|court|freeway|highway|
                               blvd|boulevard|ln|lane)\b//ix;

    return unless $p->{address} =~ /^(\d+)(?:-\d+)?\s+(.+)/;

    $q->{StreetNo}   = $1;
    $q->{StreetName} = $2;

    $q->{Suburb} = $p->{city}
        if defined $p->{city};

    $q->{PostCode} = $p->{postal_code}
        if defined $p->{postal_code};

    if ( length $p->{state} > 3 )
    {
        $p->{state} = Geography::States->new('Australia')->state( $p->{state} );
    }

    return unless $p->{state};

    $q->{CountryName} = $p->{state};

    return 1;
}


1;

__END__

=head1 NAME

WWW::Map::Streetdirectory - A WWW::Map subclass for streetdirectory.com

=head1 SYNOPSIS

    use WWW::Map;

    my $map = WWW::Map->new( country => 'australia',
                             address => '606 Station Street',
                             city    => 'Box Hill',
                             state   => 'Victoria',
                             postal_code => '3128',
                           );

    my $uri = $map->uri;

=head1 DESCRIPTION

This subclass generates links to streetdirectory.com.  There are
several host names for this service, each for a different country.

=head1 COUNTRIES

This subclass handles Australia and Singapore.

=head1 new() PARAMETERS

For Singapore, all that is required is a "postal_code".

For Australia, you must provide "address", "state", and either "city"
or "postal_code".  Some additional parsing is done on the address to
remove the "street/ave/etc" portion, and to separate out the street
number from the name.  If this fails, then an object cannot be
created.

=head1 AUTHOR

David Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-map@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 David Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=cut


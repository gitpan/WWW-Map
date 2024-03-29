package WWW::Map;

use strict;

use vars qw($VERSION);

$VERSION = 0.01;

use Class::Factory::Util;
use URI;

use Params::Validate qw( validate_with SCALAR UNDEF );


my %CountryToClass;

BEGIN
{
    for my $class ( map { __PACKAGE__ . '::' . $_ } __PACKAGE__->subclasses )
    {
        eval "use $class";
        die $@ if $@;

        foreach my $country ( map { lc } $class->Countries )
        {
            push @{ $CountryToClass{$country} }, $class;
        }
    }
}

use constant NEW_SPEC => { country     => { type => SCALAR },
                           address     => { type => UNDEF | SCALAR, optional => 1 },
                           city        => { type => UNDEF | SCALAR, optional => 1 },
                           state       => { type => UNDEF | SCALAR, optional => 1 },
                           postal_code => { type => UNDEF | SCALAR, optional => 1 },
                           subclass    => { type => UNDEF | SCALAR, optional => 1 },
                         };

sub new
{
    my $class = shift;
    my %p = validate_with( params => \@_,
                           spec   => NEW_SPEC,
                           allow_extra => 1,
                         );

    my $subclass;
    if ( $p{subclass} )
    {
        if ( $p{subclass} =~ /::/ )
        {
            $subclass = $p{subclass};
        }
        else
        {
            $subclass = __PACKAGE__  . '::' . $p{subclass};
        }

        delete $p{subclass};
    }

    unless ($subclass)
    {
        my $country = $class->_sanitize_country( $p{country} );

        die "No subclasses registered to handle the given country: $p{country}\n"
            unless exists $CountryToClass{$country};

        $subclass = $CountryToClass{$country}[0];

        $p{country} = $country;
    }

    return $subclass->new(%p);
}

sub _sanitize_country
{
    shift;
    my $country = shift;

    if ( $country =~ /united\s+states/i )
    {
        $country = 'usa';
    }

    return lc $country;
}

sub uri_object
{
    my $self = shift;

    my $uri = URI->new( '' );

    foreach my $k ( qw( scheme host path ) )
    {
        my $m = "_$k";
        $uri->$k( $self->$m() )
            if $self->can($m);
    }

    $uri->query_form( $self->_query )
        if $self->can('_query');

    return $uri->canonical;
}

sub uri
{
    $_[0]->uri_object->as_string;
}

sub _scheme { $_[0]->{scheme} ? $_[0]->{scheme} : 'http' }

sub _host  { $_[0]->{host} }
sub _path  { $_[0]->{path} }
sub _query { $_[0]->{query} }


1;

__END__

=head1 NAME

WWW::Map - An API for generating links to online map services

=head1 SYNOPSIS

    use WWW::Map;

    my $map = WWW::Map->new( country => 'usa',
                             address => '100 Some Street',
                             city    => 'Testville',
                             state   => 'MN',
                             postal_code => '12345',
                           );

    my $uri = $map->uri;

=head1 DESCRIPTION

This class defines an API for classes which generate links to various
online map services like MapQuest or Multimap.  It also provides a
constructor which will dispatch to an appropriate subclass based on
the country being mapped.

=head1 METHODS

=head2 new()

This method constructs a new object of some C<WWW::Map> subclass.

This method accepts the following parameters:

=over 4

=item * country

This parameter determined which subclass will be used.  If more than
one subclass is available for the country, then one will be chosen
more or less at random.  You can provide a "subclass" parameter to
override the default choice.

This parameter is B<required>.

=item * address

=item * city

=item * state

The state or province.  Subclasses should be designed to handle either
the full name or a standard abbreviation.

=item * postal_code

The postal or zip code.

=item * subclass

This can be a full class name like C<My::Map> or just an identifier
for an existing C<WWW::Map> subclass, like C<MapQuest>.

=back

Subclasses may require certain parameters, and may also accept
additional parameters besides those listed.

If the parameter given are not sufficient to generate a map URI for
the given country, then this method will simply return false.

=head2 uri()

This method returns a string containing the URI of the map link.

=head2 uri_object()

This method returns a URI object representing the map link.

=head1 SUBCLASSING

Creating a subclass that implements map links is quite simple.  The
subclass needs to provide a few methods.  See the subclasses
distributed with this module for examples.

=head2 Countries()

This class method should return an array of country names which the
subclass can handle.

=head2 new()

This method will receive the same parameters as are given to
C<< WWW::Map->new >>, and should return a new object of the given
subclass.

If the parameters it receives aren't sufficient to create a map link,
it should simply call a bare C<return>.

=head2 _scheme(), _host(), _path(), _query()

These methods are used when constructing a C<URI> object.  By default,
these methods simply look at the "scheme", "host", "path", and "query"
keys of the object.  The C<_scheme()> method will default to "http".

You are free to override any of these methods in your subclass.

=head1 LEGAL BITS

Please check with each service provider regarding their terms of
service.  Some of them may impose certain conditions on how they can
be linked to.  The author(s) of these modules are not responsible for
any violations of a provider's terms of service committed when using
URIs generated by these modules.

=head1 SEE ALSO

WWW::Map::MapQuest, WWW::Map::Multimap, WWW::Map::Streetdirectory

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

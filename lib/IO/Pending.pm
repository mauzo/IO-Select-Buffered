package IO::Pending;

=head1 NAME

IO::Pending - Inquire about buffered data on a filehandle

=head1 SYNOPSIS

    if (pending_read $FH) {
        # $FH has buffered data to read
    }

    if (pending_write $FH) {
        # $FH has buffered data to write
    }

=head1 DESCRIPTION

IO::Pending provides information about the buffers PerlIO uses when
reading from and writing to a buffered filehandle.

=cut

use 5.008001;
use warnings;
use strict;

our $VERSION = "1";

use Exporter "import";
our @EXPORT_OK = qw[
    pending_read pending_write pending_bytes
];

use XSLoader;
XSLoader::load __PACKAGE__, $VERSION;

=head1 FUNCTIONS

=head2 pending_read

    pending_read $FH

This returns true if a filehandle has buffered read data. It returns
false if the filehandle has buffers we can look at and they are empty,
or undef if the filehandle is unbuffered, tied, not open for reading, or
otherwise inaccessible.

This function only works on true PerlIO filehandles, not on handles
which are tied. It also only works on layers which implement
C<PerlIO_get_cnt>, which includes C<:perlio>, all layers derived from
C<:perlio> (such as C<:crlf>, C<:encoding> and C<:via>), C<:scalar>, and
C<:stdio> if perl knows how to look inside your sytems stdio buffers.
Notably it does B<not> include mod_perl's C<:APR> layer.

Note that this looks all the way down the PerlIO stack: just because a
lower layer has buffered data does not necessarily mean you can read
from the filehandle without blocking. It may be that data will disappear
before it gets to the top of the stack, if there is an intermediate
filtering layer.

=head2 pending_write

    pending_write $FH

This returns true if the filehandle has buffered write data. While this
also only works on PerlIO filehandles, not tied handles, it ought to
work with any layer which buffers writes.

=head2 pending_bytes

    pending_bytes $FH

This returns the number of bytes in the read buffer of the top layer of
a filehandle. In the common case of C<:unix:perlio> filehandles this
will be the number of bytes perl has read from the underlying file
descriptor but not yet returned to your program. If there are more
layers there may be more data buffered this function cannot see.

This function works under the same circumstances as C<pending_read>, and
returns undef if it cannot interrogate a filehandle.

Note that this returns the number of B<bytes> in the buffer. If this is
a C<:utf8> filehandle this may not be the same as the number of
characters which can be read before reading from a lower layer.

=head1 BUGS

This module is part of the IO-Select-Buffered distribution, so please
report any bugs to <bug-IO-Select-Buffered@rt.cpan.org>.

This does not work on tied filehandles, and cannot without extending the
TIEHANDLE interface.

It would be nice to provide a function to return the amount of space
left in a write buffer (or at least, to tell us if there is any), but
PerlIO doesn't provide that information.

Possibly C<pending_bytes> ought to run over the buffer with
C<utf8_length> if the layer is marked utf8, though that raises
irritating questions about what to do if the data in the buffer isn't
valid utf8.

=head1 AUTHOR

Ben Morrow <ben@morrow.me.uk>.

=head1 COPYRIGHT

Copyright 2012 Ben Morrow.

Released under the 2-clause BSD licence.

=cut

1;

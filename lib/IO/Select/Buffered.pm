package IO::Select::Buffered;

=head1 NAME

IO::Select::Buffered - IO::Select for buffered filehandles

=head1 SYNOPSIS

    my $sel = IO::Select::Buffered->new($FH);

    if ($FH->can_read(0)) {
        # $FH is either readable or has already buffered read data
    }

    if ($FH->can_flush(0)) {
        # $FH has buffered write data and the fd is writable, so it can
        # be flushed
    }

=head1 DESCRIPTION

L<IO::Select|C<IO::Select>> is not very useful when working with buffered
filehandles. Since the select(2) syscall only returns the state of the
OS fds, it is necessary to use sysread and syswrite and perform your own
buffering, otherwise you lose track of the data perl has buffered.

This subclass extends C<IO::Select> to take account of the data Perl has
buffered. It uses L<IO::Pending|C<IO::Pending>> to inspect PerlIO's
buffers, so you should see the caveats in that module's documentation.

=cut

use 5.008001;
use warnings;
use strict;

our $VERSION = "1";

use parent "IO::Select";

use Carp;
use Scalar::Util    qw/openhandle/;
use IO::Pending     qw/pending_read pending_write/;

=head1 METHODS

C<IO::Select::Buffered> inherits from L<IO::Select|C<IO::Select>>; I
will just document the differences here.

=head2 add

Unlike C<IO::Select>'s C<add> method, this will only accept real Perl
filehandles. It will not accept numbers: if you really want to use this
module to select on a fd, open an unbuffered filehandle like this

    open my $FH, "<&=:unix", $fd;

This is necessary since we need to be able to inspect the buffers (if
there are any).

=cut

sub add {
    my ($vec, @fhs) = @_;
    if (my @bad = grep !openhandle($_), @fhs) {
        Carp::croak sprintf "Bad filehandle%s: %s",
            (@bad > 1 ? "s" : ""), join ", ", @bad;
    }
    $vec->IO::Select::add(@fhs);
}

=head2 can_read

This method will return immediately if any of the filehandles have
buffered data which has not been read yet. If none have, it will
perform an ordinary select for reading.

=cut

sub can_read {
    my ($vec, $timeout) = @_;

    if (my @h = grep pending_read($_), $vec->handles) {
        return @h;
    }
    $vec->IO::Select::can_read($timeout);
}

=head2 can_sysread

This is just a passthrough to C<< IO::Select->can_read >>, in case you
need to check the readability of the underlying fds.

=cut

sub can_sysread { $_[0]->IO::Select::can_read($_[1]) }

=head2 can_write

This behaves the same as C<< IO::Select->can_write >>: it selects for
writability of the underlying fd. It will B<not> return early if a
filehandle has space available in the write buffer, because
C<IO::Pending> doesn't know how to detect that.

=head2 can_flush

    my @can = $sel->can_flush($timeout);

This returns a list of filehandles which have data buffered to write,
and whose underlying fd is writable. These are the filehandles where
calling C<IO::Handle::flush> will do something useful. (Note that this
function cannot guarantee the whole buffer can be flushed, so set
nonblocking mode if you need to.)

=cut

sub can_flush {
    my ($vec, $timeout) = @_;

    my @h = grep pending_write($_), $vec->handles
        or return;
    my $sel = IO::Select->new(@h);
    $sel->can_write($timeout);
}

=head2 select

    my ($can_read, $can_flush, $has_err) =
        IO::Select::Buffered->select($read, $flush, $err, $timeout);

This differs from C<< IO::Select->select >> in that the handles
represented by the second argument will not be checked for writing (like
C<can_write>), they will be checked for flushing (like C<can_flush>). 

=cut

sub select {
    my (undef, $r, $w, $e, $t) = @_;

    # if we have pending reads, just return them
    if ($r and my @r = grep pending_read($_), $r->handles) {
        return \@r, [], [];
    }

    $w and $w = IO::Select->new(
        grep pending_write($_), $w->handles
    );

    IO::Select->select($r, $w, $e, $t);
}

=head1 BUGS

Please report bugs to <bug-IO-Select-Buffered@rt.cpan.org>.

=head1 AUTHOR

Ben Morrow <ben@morrow.me.uk>

=head1 COPYRIGHT

Copyright 2012 Ben Morrow.

Released under the 2-clause BSD licence.

=cut

1;

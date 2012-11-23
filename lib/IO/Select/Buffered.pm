package IO::Select::Buffered;

use 5.008001;
use warnings;
use strict;

our $VERSION = "1";

use parent "IO::Select";

use Carp;
use Scalar::Util    qw/openhandle/;
use IO::Pending     qw/pending_read pending_write/;

sub add {
    my ($vec, @fhs) = @_;
    if (my @bad = grep !openhandle($_), @fhs) {
        Carp::croak sprintf "Bad filehandle%s: %s",
            (@bad > 1 ? "s" : ""), join ", ", @bad;
    }
    $vec->IO::Select::add(@fhs);
}

sub can_read {
    my ($vec, $timeout) = @_;

    if (my @h = grep pending_read($_), $vec->handles) {
        return @h;
    }
    $vec->IO::Select::can_read($timeout);
}

sub can_sysread { $_[0]->IO::Select::can_read($_[1]) }

sub can_flush {
    my ($vec, $timeout) = @_;

    my @h = grep pending_write($_), $vec->handles
        or return;
    my $sel = IO::Select->new(@h);
    $sel->can_write($timeout);
}

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

1;

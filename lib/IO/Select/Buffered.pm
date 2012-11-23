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
    $vec->SUPER::add(@fhs);
}

sub can_read {
    my ($vec, $timeout) = @_;

    if (my @h = grep pending_read($_), $vec->handles) {
        return @h;
    }
    $vec->SUPER::can_read($timeout);
}

sub can_flush {
    my ($vec, $timeout) = @_;

    my @h = grep pending_write($_), $vec->handles
        or return;
    my $sel = IO::Select->new(@h);
    $sel->can_write($timeout);
}

1;

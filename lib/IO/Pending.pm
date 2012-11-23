package IO::Pending;

use 5.010;
use warnings;
use strict;

our $VERSION = "1";

use Exporter "import";
our @EXPORT_OK = qw[
    pending_read pending_write pending_bytes
];

use XSLoader;
XSLoader::load __PACKAGE__, $VERSION;

1;

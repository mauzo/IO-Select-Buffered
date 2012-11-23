#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "perliol.h"

/* The standard typemap wants these typedefs */
typedef PerlIO *InputStream;
typedef PerlIO *OutputStream;

MODULE = IO::Pending  PACKAGE = IO::Pending

int
pending_read (f)
        InputStream f
    PPCODE:
        if (!PerlIOValid(f)) XSRETURN_UNDEF;
        for (; PerlIOValid(f); f = PerlIONext(f)) {
            if (PerlIO_has_cntptr(f) && PerlIO_get_cnt(f))
                XSRETURN_YES;
        }
        XSRETURN_NO;

int
pending_write (f)
        OutputStream f
    PPCODE:
        if (!PerlIOValid(f)) XSRETURN_UNDEF;
        for (; PerlIOValid(f); f = PerlIONext(f)) {
            if (PerlIOBase(f)->flags & PERLIO_F_WRBUF)
                XSRETURN_YES;
        }
        XSRETURN_NO;

int
pending_bytes (f)
        InputStream f
    CODE:
        if (!PerlIOValid(f) || !PerlIO_has_cntptr(f))
            XSRETURN_UNDEF;
        RETVAL = PerlIO_get_cnt(f);
    OUTPUT:
        RETVAL

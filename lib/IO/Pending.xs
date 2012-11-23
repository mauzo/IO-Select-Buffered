#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "perliol.h"

MODULE = IO::Pending  PACKAGE = IO::Pending

int
pending_read (sv)
        SV *sv
    PPCODE:
        IO      *io;
        PerlIO  *f;
        int     hascnt = 0;

        if (!(io = sv_2io(sv)) ||
            mg_find((SV *)io, PERL_MAGIC_tiedscalar) ||
            !(f = IoIFP(io)) ||
            !PerlIOValid(f) ||
            !(PerlIOBase(f)->flags & PERLIO_F_CANREAD)
        )
            XSRETURN_UNDEF;

        for (; PerlIOValid(f); f = PerlIONext(f)) {
            if (PerlIO_has_cntptr(f))
                hascnt = 1;
            else
                continue;
            if (PerlIO_get_cnt(f))
                XSRETURN_YES;
        }
        if (hascnt) XSRETURN_NO;
        else        XSRETURN_UNDEF;

int
pending_write (sv)
        SV *sv
    PPCODE:
        IO      *io;
        PerlIO  *f;

        if (!(io = sv_2io(sv)) ||
            mg_find((SV *)io, PERL_MAGIC_tiedscalar) ||
            !(f = IoOFP(io)) ||
            !PerlIOValid(f) ||
            !(PerlIOBase(f)->flags & PERLIO_F_CANWRITE)
        )
            XSRETURN_UNDEF;

        for (; PerlIOValid(f); f = PerlIONext(f)) {
            if (PerlIOBase(f)->flags & PERLIO_F_WRBUF)
                XSRETURN_YES;
        }
        XSRETURN_NO;

int
pending_bytes (sv)
        SV *sv
    PREINIT:
        IO      *io;
        PerlIO  *f;
    INIT:
        if (!(io = sv_2io(sv)) ||
            mg_find((SV *)io, PERL_MAGIC_tiedscalar) ||
            !(f = IoIFP(io)) ||
            !PerlIOValid(f) ||
            !(PerlIOBase(f)->flags & PERLIO_F_CANREAD) ||
            !PerlIO_has_cntptr(f)
        )
            XSRETURN_UNDEF;
    CODE:
        RETVAL = PerlIO_get_cnt(f);
    OUTPUT:
        RETVAL

package WWW::PastebinCom::Create;

use warnings;
use strict;

our $VERSION = '0.001';

use Carp;
use URI;
use LWP::UserAgent;
use overload q|""| => sub { shift->paste_uri };

sub new {
    my $class = shift;
    croak "Must have even number of arguments to the constructor"
        if @_ & 1;

    my %args = @_;
    
    unless ( $args{timeout} ) {
        $args{timeout} = 30;
    }
    unless ( $args{ua} ) {
        $args{ua} = LWP::UserAgent->new(
            timeout => $args{timeout},
            agent   => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US;'
                        . ' rv:1.8.1.12) Gecko/20080207 Ubuntu/7.10 (gutsy)'
                        . ' Firefox/2.0.0.12',

        );
    }

    return bless \%args, $class;
}

sub paste {
    my $self = shift;
    croak "Must have even number of arguments to paste() method"
        if @_ & 1;

    my %args = @_;
    $args{ +lc } = delete $args{ $_ } for keys %args;

    unless ( defined $args{text} ) {
        $self->error( 'Missing or undefined `text` argument' );
        return;
    }
        

    $self->paste_uri( undef );
    $self->error( undef );

    %args = (
        format  => 'text',
        expiry  => 'd',
        poster  => '',
        email   => '',
        paste   => 'Send',

        %args,
    );

    $args{format} = lc $args{format};

    my $valid_formats = $self->get_valid_formats;
    unless ( exists $valid_formats->{ $args{format} } ) {
        croak "Invalid syntax-highlight format was specified\n"
                . "Use ->get_valid_formats() method to get full list"
                . " of valid values";
    }

    croak "Invalid `expiry` argument. Must be either 'f', 'd' or 'm'"
        if $args{expiry} ne 'd'
            and $args{expiry} ne 'm'
            and $args{expiry} ne 'f';

    $args{code2} = delete $args{text};
    my $uri = URI->new('http://pastebin.com/');

    my $response = $self->{ua}->post( $uri, \%args );

     if ( $response->is_success or $response->is_redirect ) {
        return $self->paste_uri( $response->header('Location') );
     }
     else {
         $self->error( $response->status_line );
         return;
     }
}

sub error {
    my $self = shift;
    if ( @_ ) {
        $self->{ ERROR } = shift;
    }
    return $self->{ ERROR };
}

sub paste_uri {
    my $self = shift;
    if ( @_ ) {
        $self->{ PASTE_URI } = shift;
    }
    return $self->{ PASTE_URI };
}

sub get_valid_formats {
    return {
        text        => 'None',
        bash        => 'Bash',
        c           => 'C',
        cpp         => 'C++',
        html4strict => 'HTML',
        java        => 'Java',
        javascript  => 'Javascript',
        lua         => 'Lua',
        perl        => 'Perl',
        php         => 'PHP',
        python      => 'Python',
        ruby        => 'Ruby',
        abap        => 'ABAP',
        actionscript => 'ActionScript',
        ada         => 'Ada',
        apache      => 'Apache Log File',
        applescript => 'AppleScript',
        asm         => 'ASM (NASM based)',
        asp         => 'ASP',
        autoit      => 'AutoIt',
        blitzbasic  => 'Blitz Basic',
        bnf         => 'BNF',
        c_mac       => 'C for Macs',
        caddcl      => 'CAD DCL',
        cadlisp     => 'CAD Lisp',
        cpp         => 'C++',
        csharp      => 'C#',
        cfm         => 'ColdFusion',
        css         => 'CSS',
        d           => 'D',
        delphi      => 'Delphi',
        diff        => 'Diff',
        dos         => 'DOS',
        eiffel      => 'Eiffel',
        fortran     => 'Fortran',
        freebasic   => 'FreeBasic',
        genero      => 'Genero',
        gml         => 'Game Maker',
        groovy      => 'Groovy',
        haskell     => 'Haskell',
        idl         => 'IDL',
        ini         => 'INI',
        inno        => 'Inno Script',
        java        => 'Java',
        javascript  => 'Javascript',
        latex       => 'Latex',
        lisp        => 'Lisp',
        matlab      => 'MatLab',
        m68k        => 'M68000 Assembler',
        mpasm       => 'MPASM',
        mirc        => 'mIRC',
        mysql       => 'MySQL',
        nsis        => 'NullSoft Installer',
        objc        => 'Objective C',
        ocaml       => 'OCaml',
        oobas       => 'Openoffice.org BASIC',
        oracle8     => 'Oracle 8',
        pascal      => 'Pascal',
        plswl       => 'PL/SQL',
        qbasic      => 'QBasic/QuickBASIC',
        rails       => 'Rails',
        robots      => 'Robots',
        scheme      => 'Scheme',
        smalltalk   => 'Smalltalk',
        smarty      => 'Smarty',
        sql         => 'SQL',
        tcl         => 'TCL',
        vb          => 'VisualBasic',
        vbnet       => 'VB.NET',
        visualfoxpro => 'VisualFoxPro',
        xml         => 'XML',
        z80         => 'Z80 Assembler',
    };
}


1;

__END__

=head1 NAME

WWW::PastebinCom::Create - paste to L<http://pastebin.com> from Perl.

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WWW::PastebinCom::Create;

    my $paste = WWW::PastebinCom::Create->new;

    $paste->paste( text => 'lots and lost of text to paste' )
        or die "Error: " . $paste->error;

    print "Your paste can be found on $paste\n";

=head1 DESCRIPTION

The module provides means of pasting large texts into
L<http://pastebin.com> pastebin site.

=head1 CONSTRUCTOR

=head2 new

    my $paste = WWW::PastebinCom::Create->new;

    my $paste = WWW::PastebinCom::Create->new(
        timeout => 10,
    );

    my $paste = WWW::PastebinCom::Create->new(
        ua => LWP::UserAgent->new(
            timeout => 10,
            agent   => 'PasterUA',
        ),
    );

Constructs and returns a brand new yummy juicy WWW::PastebinCom::Create
object. Takes two argument, both are I<optional>. Possible arguments are
as follows:

=head3 timeout

    ->new( timeout => 10 );

B<Optional>. Specifies the C<timeout> argument of L<LWP::UserAgent>'s
constructor, which is used for pasting. B<Defaults to:> C<30> seconds.

=head3 ua

    ->new( ua => LWP::UserAgent->new( agent => 'Foos!' ) );

B<Optional>. If the C<timeout> argument is not enough for your needs
of mutilating the L<LWP::UserAgent> object used for pasting, feel free
to specify the C<ua> argument which takes an L<LWP::UserAgent> object
as a value. B<Note:> the C<timeout> argument to the constructor will
not do anything if you specify the C<ua> argument as well. B<Defaults to:>
plain boring default L<LWP::UserAgent> object with C<timeout> argument
set to whatever C<WWW::PastebinCom::Create>'s C<timeout> argument is
set to.

=head1 METHODS

=head2 paste

    $paste->paste( text => 'long long text' )
        or die "Failed to paste: " . $paste->error;

    my $paste_uri = $paste->paste(
        text => 'long long text',
        format => 'perl',
        poster => 'Zoffix',
        expiry => 'm',
    ) or die "Failed to paste: " . $paste->error;

Instructs the object to pastebin some text. If pasting succeeded returns
a URI pointing to your paste, otherwise returns either C<undef> or
an empty list (depending on the context) and the reason for the failure
will be avalable via C<error()> method (see below).

Note: you don't have to store the return value. There is a C<paste_uri()>
method as well as overloaded construct; see C<paste_uri()> method's
description below.

Takes one mandatory and
three optional arguments which are as follows:

=head3 text

    ->paste( text => 'long long long long text to paste' );

B<Mandatory>. The C<text> argument must contain the text to paste. If
C<text>'s value is undefined the C<paste()> method will return either
C<undef> or an empty list (depending on the context) and the C<error()>
method will contain a message about undefined C<text>.

=head3 format

    ->paste( text => 'foo', format => 'perl' );

B<Optional>. Specifies the format of the paste to enable specific syntax
highlights on L<http://pastebin.com>. The list of possible values is
very long, see C<get_valid_formats()> method below for information
on how to obtain possible valid values for the C<format> argument.
B<Defaults to:> C<text> (plain text paste).

=head3 poster

    ->paste( text => 'foo', poster => 'Zoffix Znet' );

B<Optional>. Specifies the name of the person pasting the text.
B<Defaults to:> empty string, which leads to C<Anonymous> apearing on
L<http://pastebin.com>

=head3 expiry

    ->paste( text => 'foo', expiry => 'f' );

B<Optional>. Specifies when the paste should expire.
B<Defaults to:> C<d> (expire the paste in one day). Takes three possible
values:

=over 5

=item d

When C<expiry> is set to value C<d>, the paste will expire in one day.

=item m

When C<expiry> is set to value C<m>, the paste will expire in one month.

=item f

When C<expiry> is set to value C<f>, the paste will (should) stick around
"forever".

=back

=head2 error

    $paste->paste( text => 'foos' )
        or die "Error: " . $paste->error;

If the C<paste()> method failed to paste your text for any reason
(including your text being undefined) it will return either C<undef>
or an empty list depending on the context. When that happens you will
be able to find out the reason of the error via C<error()> method.
Returns a scalar containing human readable message describing the error.
Takes no arguments.

=head2 paste_uri (and overloads)

    print "You can find your pasted text on " . $paste->paste_uri . "\n";

    # or by interpolating the WWW::PastebinCom::Create object directly:
    print "You can find your pasted text on $paste\n";

Takes no arguments. Returns a URI pointing to the L<http://pastebin.com>
page containing the text you have pasted. If you call this method before
pasting anything or if C<paste()> method failed the C<paste_uri> will
return either C<undef> or an empty list depending on the context.

B<Note:> the WWW::PastebinCom::Create object is overloaded so instead
of calling C<paste_uri> method you could simply interpolate the
WWW::PastebinCom::Create object. For example:

    my $paster = WWW::PastebinCom::Create->new;
    $paster->paste( text => 'long text' )
        or die "Failed to paste: " . $paster->error;
        
    print "Your paste is located on $paster\n";

=head2 get_valid_formats

    my $valid_formats_hashref = $paste->get_valid_formats;

Takes no arguments. Returns a hashref, keys of which will be valid
values of the C<format> argument to C<paste()> method and values of which
will be explanation of semi-cryptic codes.

=head1 AUTHOR

Zoffix Znet, C<< <zoffix at cpan.org> >>
(L<http://zoffix.com>, L<http://haslayout.net>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-pastebincom-create at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-PastebinCom-Create>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::PastebinCom::Create

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-PastebinCom-Create>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-PastebinCom-Create>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-PastebinCom-Create>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-PastebinCom-Create>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Zoffix Znet, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

package String::Query::To::Regexp;

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(query2re);

# AUTHORITY
# DATE
# DIST
# VERSION

sub query2re {
    my $opts = ref($_[0]) eq 'HASH' ? shift : {};
    my $bool   = $opts->{bool} // 'and';
    my $ci     = $opts->{ci};
    my $word   = $opts->{word};
    my $opt_re = $opts->{re};

    return qr// unless @_;
    my @re_parts;
    for my $query0 (@_) {
        my ($neg, $query) = $query0 =~ /\A(-?)(.*)/;

        if ($opt_re) {
            if (ref $query0 eq 'Regexp') {
                $query = $query0;
            } else {
                require Regexp::From::String;
                $query = Regexp::From::String::str_maybe_to_re($query);
                $query = quotemeta($query) unless ref $query eq 'Regexp';
            }
        } else {
            $query = quotemeta $query;
        }

        if ($word) {
            push @re_parts, $neg ? "(?!.*\\b$query\\b)" : "(?=.*\\b$query\\b)";
        } else {
            push @re_parts, $neg ? "(?!.*$query)" : "(?=.*$query)";
        }
    }
    my $re = $bool eq 'or' ? "(?:".join("|", @re_parts).")" : join("", @re_parts);
    return $ci ? qr/\A$re.*\z/is : qr/\A$re.*\z/s;
}

1;
# ABSTRACT: Convert query to regular expression

=head1 SYNOPSIS

 use String::Query::To::Regexp qw(query2re);

 my $re;

 $re = query2re("foo");                       # => qr/\A(?=.*foo).*\z/s   -> string must contain 'foo'
 $re = query2re({ci=>1}, "foo";               # => qr/\A(?=.*foo).*\z/is  -> string must contain 'foo', case-insensitively
 $re = query2re("foo", "bar");                # => qr/\A(?=.*foo)(?=.*bar).*\z/s   -> string must contain 'foo' and 'bar', order does not matter
 $re = query2re("foo", "-bar");               # => qr/\A(?=.*foo)(?!.*bar).*\z/s   -> string must contain 'foo' but must not contain 'bar'
 $re = query2re({bool=>"or"}, "foo", "bar");  # => qr/\A(?:(?=.*foo)|(?!.*bar)).*\z/s  -> string must contain 'foo' or 'bar'
 $re = query2re({word=>1}, "foo", "bar");     # => qr/\A(?=.*\bfoo\b)(?!.*\bbar\b).*\z/s  -> string must contain words 'foo' and 'bar'; 'food' or 'lumbar' won't match


=head1 DESCRIPTION

This module provides L</query2re> function to convert one or more string queries
to a regular expression. Features of the queries:

=over

=item * Negative searching using the I<-FOO> syntax

=back


=head1 FUNCTIONS

=head2 query2re

Usage:

 my $re = query2re([ \%opts , ] @query);

Create a regular expression object from query C<@query>.

Known options:

=over

=item * bool

Str. Default C<and>. Either C<and> or C<or>.

=item * word

Bool. Default false. If set to true, queries must be separate words.

=item * ci

Bool. Default false. If set to true, will do case-insensitive matching

=item * re

Bool. Default false. If set to true, will allow regexes in C<@query> as well as
converting string queries of the form C</foo/> to regex using
L<Regexp::From::String>.

=back


=head1 SEE ALSO

=cut

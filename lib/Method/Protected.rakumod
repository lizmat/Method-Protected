my multi sub trait_mod:<is>(Method:D $method, :$protected!) is export {
    my $package := $method.package;

    # Did not install lock logic yet
    unless $package.^attributes.first(*.name eq '$!LOCK') {
        my $attribute := Attribute.new(:name<$!LOCK>, :type(Lock), :$package);
        $package.^add_attribute: $attribute;

        $package.^add_method: 'LOCK', my method LOCK() {
            $attribute.get_value(self)
              // $attribute.set_value(self, Lock.new)
        }
    }

    # Install the wrapper
    my $name := $method.name;
    $method.wrap: my method (|c) is raw {
        my &original = nextcallee;
        self.LOCK.protect: { original(self, |c) }
    }

    # Make the adapted method self-identify with the correct name
    $method.^set_name($name);
}

=begin pod

=head1 NAME

Method::Protected - add "is protected" trait to methods

=head1 SYNOPSIS

=begin code :lang<raku>

use Method::Protected;

my @words = "/usr/share/dict/words".IO.lines;

class Frobnicate {
    has %!hash;
    method pick() is protected { %!hash{@words.pick}++ }
    method hash() is protected { %!hash.clone          }
}

# Set up 2 threads massively updating a single hash
my $frobnicator = Frobnicate.new;
start { loop { $frobnicator.pick }
start { loop { $frobnicator.pick }

# Start reporter
until $frobnicator.hash.elems == @words.elems {
    say $frobnicator.hash.elems;
    sleep .1;
}

=end code

=head1 DESCRIPTION

Method::Protected provides an C<is protected> trait to methods in a class.
If applied to a method, all calls to that method will be protected by a
L<Lock|https://docs.raku.org/type/Lock>, making sure that any other method
call to this method (or any other method protected by the trait) from
another thread, will block until the call is finished.

Functionally this is similar to what the
L<OO::Monitor|https://raku.land/cpan:JNTHN/OO::Monitors> does, except that
with this module this logic is only applied to methods that actuall have
the C<is protected> trait applied.

=head1 THEORY OF OPERATION

When the trait is applied on a method, the class of the method id checked
whether it already has a C<$!LOCK> attribute.  If not, then that attribute
is added, and the associated accessor method C<LOCK> is also added.  Then
the method will be L<wrapped|https://docs.raku.org/routine/wrap> with code
that will protect the execution of the original body of the method.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Method-Protected . Comments and
Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

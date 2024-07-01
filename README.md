[![Actions Status](https://github.com/lizmat/Method-Protected/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/lizmat/Method-Protected/actions) [![Actions Status](https://github.com/lizmat/Method-Protected/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Method-Protected/actions) [![Actions Status](https://github.com/lizmat/Method-Protected/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Method-Protected/actions)

NAME
====

Method::Protected - add "is protected" trait to methods

SYNOPSIS
========

```raku
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
await start {
    until $frobnicator.hash.elems == @words.elems {
        say $frobnicator.hash.elems;
        sleep .1;
    }
}
```

DESCRIPTION
===========

Method::Protected provides an `is protected` trait to methods in a class. If applied to a method, all calls to that method will be protected by a [Lock](https://docs.raku.org/type/Lock), making sure that any other method call to this method (or any other method protected by the trait) from another thread, will block until the call is finished.

Functionally this is similar to what the [OO::Monitor](https://raku.land/cpan:JNTHN/OO::Monitors) does, except that with this module this logic is only applied to methods that actuall have the `is protected` trait applied.

THEORY OF OPERATION
===================

When the trait is applied on a method, the class of the method id checked whether it already has a `$!LOCK` attribute. If not, then that attribute is added, and the associated accessor method `LOCK` is also added. Then the method will be [wrapped](https://docs.raku.org/routine/wrap) with code that will protect the execution of the original body of the method.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Method-Protected . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2024 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


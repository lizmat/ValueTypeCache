[![Actions Status](https://github.com/lizmat/ValueTypeCache/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/ValueTypeCache/actions) [![Actions Status](https://github.com/lizmat/ValueTypeCache/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/ValueTypeCache/actions) [![Actions Status](https://github.com/lizmat/ValueTypeCache/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/ValueTypeCache/actions)

NAME
====

ValueTypeCache - A role to cache Value Type classes

SYNOPSIS
========

```raku
use ValueTypeCache;

sub id(%h --> Str:D) {
    %h<x> //= 0;
    %h<y> //= 0;
    "%h<x>,%h<y>"
}

class Point does ValueTypeCache[&id] {
    has $.x;
    has $.y;
}

say Point.new.WHICH;  # Point|0,0

# fill a bag with random Points
my $bag = bag (^1000).map: {
  Point.new: x => (-10..10).roll, y => (-10..10).roll
}
say $bag.elems;  # less than 1000
```

DESCRIPTION
===========

The `ValueTypeCache` distribution provides a `ValueTypeCache` role that mixes the logic of creating a proper ValueType class **and** making sure that each unique ValueType only exists once in memory, into a single class.

The role takes a `Callable` parameterization to indicate how a unique ID should be created from the parameters given (as a hash) with the call to the `new` method. You can also adapt the given hash making sure any default values are properly applied. If there's already an object created with the returned ID, then no new object will be created but the one from the cache will be returned.

A class is considered to be a value type if the `.WHICH` method returns an object of the `ValueObjAt` class: that then indicates that objects that return the same `WHICH` value, are in fact identical and can be used interchangeably.

This is specifically important when using set operators (such as `(elem)`, or `Set`s, `Bag`s or `Mix`es, or any other functionality that is based on the `===` operator functionality, such as `unique` and `squish`.

The format of the value that is being returned by `WHICH` is only valid during a run of a process. So it should **not** be stored in any permanent medium.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/ValueTypeCache . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2020, 2021, 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


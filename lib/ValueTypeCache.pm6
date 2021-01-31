use v6.d;

# Using nqp for optimal performance
use nqp;

role ValueTypeCache:ver<0.0.4>:auth<cpan:ELIZABETH>[&args2str] {
    has $!WHICH;

    my $cache     := nqp::hash;
    my $lock      := Lock.new;
    my str $prefix = nqp::concat(::?CLASS.^name,'|');

    method !SET-WHICH(\WHICH) {
        $!WHICH := nqp::box_s(WHICH,ValueObjAt);
        self
    }
    multi method WHICH(::?CLASS:D:) { $!WHICH }

    method bless(*%_) {
        my str $WHICH = nqp::concat($prefix,args2str(%_));
        $lock.protect: {
            nqp::ifnull(
              nqp::atkey($cache,$WHICH),
              nqp::bindkey(
                $cache,
                $WHICH,
                self.Mu::bless(|%_)!SET-WHICH($WHICH)
              )
            )
        }
    }
}

=begin pod

=head1 NAME

ValueTypeCache - A role to cache Value Type classes

=head1 SYNOPSIS

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

=head1 DESCRIPTION

The ValueTypeCache role mixes the logic of creating a proper ValueType class
B<and> making sure that each unique ValueType only exists once in memory, into
a class.

The role takes a C<Callable> parameterization to indicate how a unique ID
should be created from the parameters given (as a hash) with the call to the
C<new> method.  You can also adapt the given hash making sure any default
values are properly applied.  If there's already an object created with the
returned ID, then no new object will be created but the one from the cache
will be returned.

A class is considered to be a value type if the C<.WHICH> method returns an
object of the C<ValueObjAt> class: that then indicates that objects that
return the same C<WHICH> value, are in fact identical and can be used
interchangeably.

This is specifically important when using set operators (such as C<(elem)>,
or C<Set>s, C<Bag>s or C<Mix>es, or any other functionality that is based
on the C<===> operator functionality, such as C<unique> and C<squish>.

The format of the value that is being returned by C<WHICH> is only valid
during a run of a process.  So it should B<not> be stored in any permanent
medium.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/ValueTypeCache . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2020,2021 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4

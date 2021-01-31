use v6.*;
use Test;
use ValueTypeCache;

plan 2;

sub id(%h --> Str:D) {
    %h<x> //= 0;
    %h<y> //= 0;
    "%h<x>,%h<y>"
}
class Point does ValueTypeCache[&id] {
    has $.x;
    has $.y;
}

is-deeply Point.new.WHICH, ValueObjAt.new("Point|0,0"),
  'is the basic .WHICH ok';

my $bag = bag (^1000).map: {
    Point.new: x => (-10..10).roll, y => (-10..10).roll
}

ok $bag.elems < 1000, 'should be fewer than 1000 different points';

# vim: expandtab shiftwidth=4

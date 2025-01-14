# Using nqp for optimal performance
use nqp;

role ValueTypeCache[&args2str] {
    has $!WHICH;

    my $cache     := nqp::hash;
    my $lock      := Lock.new;
    my str $prefix = nqp::concat(::?CLASS.^name,'|');

    method !SET-WHICH(\WHICH) {
        $!WHICH := nqp::box_s(WHICH,ValueObjAt);  # UNCOVERABLE
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

# vim: expandtab shiftwidth=4

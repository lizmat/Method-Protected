my &protected = my method (|c) {
    my &original = nextcallee;
    self.LOCK.protect: { original(self, |c) }
}
my &protected-raw = my method (|c) is raw {
    my &original = nextcallee;
    self.LOCK.protect: { original(self, |c) }
}

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

    # Install the correct wrapper
    my $name := $method.name;
    $method.wrap: $method.rw ?? &protected-raw.clone !! &protected.clone;

    # Make the adapted method self-identify with the correct name
    $method.^set_name($name);
}

# vim: expandtab shiftwidth=4

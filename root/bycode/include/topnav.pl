#
# Header component, displays:
#  - a logo
#  - a horizontal navigation
#
my @nav = (
    {
        display => 'home',
        c => 'Root',
        a => 'index',
    },
    {
        display => 'products',
        c => 'Products',
        a => 'index',
    },
    {
        display => 'persons',
        c => 'Persons',
        a => 'index',
    },
    {
        display => 'hierarchy',
        c => 'Hierarchy',
        a => 'index',
    },
    {
        display => 'test',
        c => 'Products',
        a => 'test',
    },
    {
        display => 'explore',
        c => 'Explore',
        a => 'index',
    },
    {
        display => 'logout',
        c => 'Login',
        a => 'logout',
    },
);

sub RUN {
    # find the active nav item
    foreach my $navitem (@nav) {
        $navitem->{co} = ref(c->controller);
        $navitem->{cc} = ref(c->controller);
        if (ref(c->controller) eq ref(c->controller($navitem->{c}))) {
            $navitem->{count}++;
            $navitem->{count}++ if (c->action eq c->controller->action_for($navitem->{a}));
        }
    }
    my ($active_item) = sort { $b->{count} <=> $a->{count} } @nav;
    $active_item ||= $nav[0];
    with {id => 'topnav'} ul {
        foreach my $navitem (@nav) {
            li {
                class 'active' if ($navitem == $active_item);
                with {href => c->uri_for(c->controller($navitem->{c})->action_for($navitem->{a}))}
                    a { $navitem->{display} };
            };
        }
    };
}
# use YAML;
# pre { Dump(\@nav) };
# products/uritest.pl

#
# summary of test-cases
#
our @uri_list = (
    { block => 'uri_for relative',
      sub   => 'uri_for',
      uris  => [
        { desc    => 'invalid relative',
          args    => "'xxx'",
          comment => 'should die' },
        { desc    => '',
          args    => "'../dummy/xxx'",
          comment => 'should die' },
        { desc    => 'valid relative',
          args    => "'detail'",
          comment => '' },
        { desc    => '',
          args    => "'../login/register'",
          comment => '' },
    ]},
    { block => 'uri_for absolute',
      sub   => 'uri_for',
      uris  => [
        { desc    => 'invalid absolute',
          args    => "'/products/xxx'",
          comment => 'should die' },
        { desc    => 'valid absolute',
          args    => "'/login/register'",
          comment => '' },
    ]},
    { block => 'uri_for action()',
      sub   => 'uri_for',
      uris  => [
        { desc    => 'invalid action',
          args    => "c->action('dummy')",
          comment => 'should die' },
        { desc    => 'valid action',
          args    => "c->action('show')",
          comment => '' },
        { desc    => 'valid chained action',
          args    => "c->action('detail')",
          comment => '' },
    ]},
    { block => 'uri_for controller()->action()',
      sub   => 'uri_for',
      uris  => [
        { desc    => 'invalid',
          args    => "c->controller('Products')->action_for('dummy')",
          comment => 'should die' },
        { desc    => 'valid',
          args    => "c->controller('Products')->action_for('show')",
          comment => '' },
        { desc    => 'valid chained',
          args    => "c->controller('Products')->action_for('detail')",
          comment => '' },
        { desc    => 'valid chained w/arg',
          args    => ["c->controller('Products')->action_for('detail')",42],
          comment => '' },
    ]},
    { block => 'uri_for_action',
      sub   => 'uri_for_action',
      uris  => [
        { desc    => 'invalid absolute',
          args    => "'/products/dummy'",
          comment => '' },
        { desc    => 'invalid relative',
          args    => "'products/dummy'",
          comment => '' },
        { desc    => '',
          args    => "'products'",
          comment => '' },
        { desc    => 'valid relative',
          args    => "'index'",
          comment => '' },
        { desc    => '',
          args    => "'products/index'",
          comment => '' },
        { desc    => 'valid relative chained',
          args    => "'products/detail'",
          comment => '' },
        { desc    => 'valid global',
          args    => "'login/logout'",
          comment => '' },
        { desc    => 'valid chained',
          args    => "'products/thing'",
          comment => '' },
        { desc    => 'relative too long',
          args    => "'products/index/test'",
          comment => '' },
        { desc    => 'relative w/ args',
          args    => ["'products/detail'",42],
          comment => '' },
        { desc    => 'relative too long w/ args',
          args    => ["'products/detail/xxx'",42],
          comment => '' },
        { desc    => 'absolute',
          args    => "'/products/index'",
          comment => '' },
        { desc    => '',
          args    => "'/products/detail'",
          comment => '' },
        { desc    => '',
          args    => "'/products/thing'",
          comment => '' },
        { desc    => '',
          args    => "'/login/logout'",
          comment => '' },
        { desc    => '',
          args    => ["'/products/detail'",42],
          comment => '' },
      ],
    },
);

#
# generate a single row
#
sub make_row {
    my $sub = shift;
    my $uri = shift;
    my $class = shift;
        
    trow {
        class $class if ($class);
        
        my $args = join(',', (ref($uri->{args}) 
                                 ? (@{$uri->{args}}) 
                                 : ($uri->{args}) )
                       );
        my $code = "c->$sub($args)";
        my $result = eval $code;
        $result = '- dies -' if ($@);
        
        for ($uri->{desc}, $code, $result, $uri->{comment} || '') {
            tcol { $_ };
        }
    };
}

#
# construct an entire block
#
sub make_block {
    my $block = shift;
    
    tbody {
        trow {
            with {colspan => 4, class => 'big'}
            tcol {
                b{ $block->{block} };
            };
        };
        
        my $i = 1;
        foreach my $test (@{$block->{uris}}) {
            my $class;
            if ($i == scalar(@{$block->{uris}})) {
                $class = 'lined'
            }
            make_row($block->{sub} || 'uri_for', $test, $class);
            $i++;
        }
    };
}

sub RUN {
    h1 {'URI Test page'};
    
    with { class => 'list', style => {width => '950px'} }
    table {
        thead {
            trow {
                th { 'description' };
                th { 'code' };
                th { 'URI' };
                th { 'comment' };
            };
        };
        
        make_block($_)
            for (@uri_list);
    };
}

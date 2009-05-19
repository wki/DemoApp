h1 { 'Request password' };

if (c->stash->{message}) {
    with { style => {'background-color' => '#ff5555', color => '#ffffff', 'font-weight' => 'bold', padding => '4px'} }
    div { c->stash->{message} };
}

br;
br;

print RAW c->stash->{form}->render;

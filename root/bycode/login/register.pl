use YAML;

h1 { 'Please register' };

if (c->stash->{message}) {
    with { style => {'background-color' => '#ff5555', color => '#ffffff', 'font-weight' => 'bold', padding => '4px'} }
    div { c->stash->{message} };
}

br;
br;

print RAW c->stash->{form}->render;

br;
br;

my $person = c->model('DB::Person');
# my $person_name = $person->get_column('person_name');

print OUT "person: " . ref($person); br;

print OUT "columns: " . join(',', cat_app::Schema::Result::Person->columns); br;

pre {
    Dump(cat_app::Schema::Result::Person->column_info('person_name'));
}
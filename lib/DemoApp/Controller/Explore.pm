package DemoApp::Controller::Explore;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Devel::Symdump;
use Pod::POM;
use Pod::POM::View::HTML;

=head1 NAME

DemoApp::Controller::Explore - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 new

instantiate the Controller but defer initialization until first use

=cut

sub new {
    my $class = shift;
    my $c = shift;
    
    my $self = $class->next::method($c, @_);
    $self->{packages} = undef; # indicate we are un-initialized.
    # $self->_initialize($c);
    
    return $self;
}

#
# setup everything - scan all packages
#
sub _initialize {
    my $self = shift;
    my $c = shift;
    
    #
    # read all packages of Catalyst or the running application
    #
    my $appname = ref($self);
    $appname =~ s{::.*\z}{}xms;

    my @packages = (
        sort { $a cmp $b }
        map { s{/}{::}xmsg; s{\.pm\Z}{}; $_; }
        #grep { m{\A(?:CatalystX?|$appname)\b}xms }
        keys(%INC)
    );
    
    #
    # collect subs and supers of all packages
    #
    my %info_for = ();
    foreach my $package (@packages) {
        my $package_file = $package;
        $package_file =~ s{::}{/}xmsg;
        $package_file .= '.pm';
        my $classpath = $INC{$package_file};
        
        my @subs = map {s{\A .* ::}{}xms; $_;}
                   sort Devel::Symdump->new($package)->functions();
        no strict 'refs';
        my @isa = @{"${package}::ISA"};
        use strict 'refs';
        
        $info_for{$package}->{has_sub}      = { map  { ($_ => 1) } @subs };
        $info_for{$package}->{isa}          = \@isa;
        $info_for{$package}->{doc}          = $self->_collect_head2_pod_entries($classpath, grep {m{\A [a-z]}xms} @subs);
        $info_for{$package}->{derieved}     = [];
        $info_for{$package}->{supers}       = [];
    }

    #
    # fill all classes into their SUPERs as "derieved"
    #
    foreach my $package (@packages) { #sort keys %info_for) {
        foreach my $superclass (grep {exists($info_for{$_})} @{$info_for{$package}->{isa}}) {
            push @{ $info_for{$superclass}->{derieved} }, $package;
        }
    }
    
    #
    # recursively collect all supers
    #
    foreach my $package (@packages) {
        my @supers = $self->_get_all_supers($package, \%info_for);
        $info_for{$package}->{supers} = \@supers;
        
        my @subs = keys %{ $info_for{$package}->{has_sub} };
        push @{$info_for{$package}->{sub_definition}->{$_}}, $package
            for @subs;
        foreach my $super (@supers) {
            my @inherited = map {s{\A .* ::}{}xms; $_;}
                            Devel::Symdump->new($super->[0])->functions();
            push @{$info_for{$package}->{sub_definition}->{$_}}, $super->[0]
                for @inherited;
            push @subs, @inherited;
        }
        my %sub_seen = map {($_ => 1)} @subs;
        $info_for{$package}->{has_method}   = { map  { ($_ => 1) }             keys %sub_seen };
        $info_for{$package}->{public_subs}  = [ sort grep { m{\A [a-z]}xms }   keys %sub_seen ];
        $info_for{$package}->{private_subs} = [ sort grep { m{\A _}xms }       keys %sub_seen ];
        $info_for{$package}->{special_subs} = [ sort grep { m{\A [^a-z_]}xms } keys %sub_seen ];
        
        #
        # fill missing doc entries if possible
        #
        SUB:
        foreach my $sub (keys %sub_seen) {
            next SUB if (exists($info_for{$package}->{doc}->{$sub}));
            foreach my $super (@supers) {
                next if (!exists($info_for{$super->[0]}));
                if (exists($info_for{$super->[0]}->{doc}->{$sub})) {
                    # $info_for{$package}->{doc}->{$sub} = "$super->[0]'s documentation:<br>$info_for{$super->[0]}->{doc}->{$sub}";
                    $info_for{$package}->{doc}->{$sub} = $info_for{$super->[0]}->{doc}->{$sub};
                    next SUB;
                }
            }
        }
    }
    
    #
    # save everything in $self
    #
    $self->{packages} = \@packages;
    $self->{package_info} = \%info_for;
}

#
# recursively collect all superclasses for a given class
#
sub _get_all_supers {
    my $self = shift;
    my $package = shift;
    my $info_for = shift;
    my $depth = shift || 1;
    my @supers = ();
    
    die "inheritance recursion error"
        if ($depth > 100); # avoid endless loops in circular inheritances

    if (!exists($info_for->{$package})) {
        push @supers, [$package, $depth];
    } else {
        foreach my $superclass (@{$info_for->{$package}->{isa}}) {
            push @supers, [$superclass, $depth];
            push @supers, $self->_get_all_supers($superclass, $info_for, $depth+1);
        }
    }
    
    my %seen;
    return map { $seen{$_->[0]}++ ? () : $_ } @supers;
}

#
# find head2 entries for a class
#
sub _collect_head2_pod_entries {
    my $self = shift;
    my $classpath = shift;
    my @methods = @_;
    
    my $parser = Pod::POM->new();
    my $pom = $parser->parse($classpath) or return;
    my @h2list = map { ($_->head2()) } ($pom->head1());

    my %pod_for;
    foreach my $method (@methods) {
        my ($head2) = grep {$_->title =~ m{\b $method \b}xms} (@h2list);
        if ($head2) {
            # $pod_for{$method} = $head2->content()->present('Pod::POM::View::HTML');
            $pod_for{$method} = $head2->present('Pod::POM::View::HTML');
            # $info->{methods}->{$method}->{text} = $head2->content()->present('Pod::POM::View::Text');
        }
        
    }
    
    return \%pod_for;
}

=head2 begin

=cut

sub begin :Private {
    my $self = shift;
    my $c = shift;
    
    #
    # first-request setup if needed
    #
    $self->_initialize($c) if (!$self->{packages});
    
    #
    # setup basic templates
    #
    $c->stash->{current_view} = 'ByCode';
    $c->stash->{title} = 'Explore';
    # $c->stash->{yield}->{header} = 'include/explore/header.pl';
    $c->stash->{yield}->{leftnav} = 'include/explore/leftnav.pl';

    # header/footer set in Root/auto
    # $c->stash->{yield}->{header} = 'include/topnav.pl';
    # $c->stash->{yield}->{footer} = 'include/footer.pl';
    
    #
    # setup packages for displaying
    #
    $c->stash->{packages} = $self->{packages};
}

sub end :ActionClass('RenderView') {}

=head2 index

=cut

sub index :Local {
    my $self = shift;
    my $c = shift;
}

=head2 package

=cut

sub package :Local :Args(1) {
    my $self = shift;
    my $c = shift;
    my $package = shift;
    
    #
    # setup templates
    #
    $c->stash->{package} = $package;
    $c->stash->{title} = "Explore - $package";
    $c->stash->{package_info} = $self->{package_info};
    $c->stash->{yield}->{content} = 'explore/package.pl';
}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__END__

#!/usr/bin/perl
###
### CHANGE THE following line
###  and the sub is_interesting if necesarry...
###
use lib qw(/Users/wolfgang/proj/jifty.org/Jifty-DBI/trunk/lib
           /Users/wolfgang/proj/jifty.org/jifty/trunk/lib);

use Jifty::Everything; # the module we want to analyze

sub is_interesting {
    my $classname = shift;
    return ($classname =~ m{\A Jifty}xms);
}

#
# you don't need to change something below...
#
#######################################################################

use Getopt::Std;

use Devel::Symdump;
use Pod::POM;
use Pod::POM::View::Text;
use Pod::POM::View::HTML;

use Text::Wrap;

use HTML::Table;

# use List::Utils qw();
use List::MoreUtils qw(uniq);

use Data::Dumper; $Data::Dumper::Sortkeys = 1;

#
# step 0 -  read options
#
my %opts;
getopts('hvf:', \%opts);
usage() if ($opts{h});
my $debug = $opts{d} ? 1 : 0;
my $verbose = ($opts{v}||$opts{d}) ? 1 : 0;
my $format = $opts{f} || 'html';

my $dest_dir = 'html';

print STDERR "starting...\n" if ($verbose);

#
# variables to hold our stuff...
#
my @classes = sort
              grep {m{\A Jifty}xms}
              keys(%INC);

my %info_for_class = ();  # methods / super

#
# step 1 - collect info
#
print STDERR "collecting...\n" if ($verbose);
foreach my $classfile (@classes) {
    my $classname = $classfile;
    $classname =~ s{/}{::}gxms;
    $classname =~ s{\.pm \z}{}xms;
    my @subs = map {s{\A .* ::}{}xms; $_;}
               sort Devel::Symdump->new($classname)->functions();
    my @supers = @{"${classname}::ISA"};

    $info_for_class{$classname}->{classfile}  = $classfile;
    $info_for_class{$classname}->{classpath}  = $INC{$classfile};
    $info_for_class{$classname}->{methods}    = { map {($_ => {})} (@subs) };   # list of methods
    $info_for_class{$classname}->{super}      = \@supers;                       # direct superclasses
    $info_for_class{$classname}->{derieved}   = [];                             # directly derieved ones
}
print STDERR "   done\n" if ($verbose);

#
# step 2 - fill all classes into their SUPERs as "derieved"
#
foreach my $classname (sort keys %info_for_class) {
    my $info = $info_for_class{$classname};
    foreach my $superclass (@{$info->{super}}) {
        if (is_interesting($superclass)) {
            push @{ $info_for_class{$superclass}->{derieved} }, $classname;
        }
    }
}

#
# step 3 - retrieve all DOC texts if possible as HTML and Text
#
foreach my $classname (sort keys %info_for_class) {
    my $info = $info_for_class{$classname};

    #
    # build POD Parser and extract =head2 lines
    #
    my $parser = Pod::POM->new();
    # print STDERR "classpath = $info->{classpath}\n" if ($debug > 1);
    my $pom = $parser->parse($info->{classpath}) or warn $parser->error();
    my @h2list = map { ($_->head2()) } ($pom->head1());
    print STDERR "# of headlines #2: " . scalar(@h2list) . "\n" if ($debug > 1);
    print STDERR "Titles: " . join(", ", map {$_->title()} (@h2list)) . "\n" if ($debug > 1);

    #
    # fill in =head2 lines for all defined methods
    #
    foreach my $method (keys(%{$info->{methods}})) {
        if (scalar(@h2list) && $method =~ m{\A[_a-zA-Z]}xms) {
            my ($head2) = grep {$_->title =~ m{\A \s* $method \s* \z}xms} (@h2list);
            if ($head2) {
                $info->{methods}->{$method}->{html} = $head2->content()->present('Pod::POM::View::HTML');
                $info->{methods}->{$method}->{text} = $head2->content()->present('Pod::POM::View::Text');
            }
        }
    }
}

# print Data::Dumper->Dump([\%info_for_class],["info_for_class"]); exit;

if ($format eq 'html') {
    print STDERR "making HTML...\n" if ($verbose);
    output_as_html();
} elsif ($format eq 'text') {
    output_as_text();
}
exit;

#
# write HTML output
#
sub output_as_html {
    my @nav_frame = ();
    foreach my $classname (sort keys %info_for_class) {
        print STDERR "$classname -> HTML...\n" if ($debug);
        my $info = $info_for_class{$classname};

        #
        # Header
        #
        my $head = "<h1>$classname</h1>\n";

        #
        # Inheritance
        #
        my $inheritance = "<b>$classname</b>\n";
        my @supers = get_all_supers($classname);
        if (scalar(@supers)) {
            my $i = 1;
            while ($i < 10) { # primitive recursion limit...
                my @supers_this_level = map {$_->[0]} grep { $_->[1] == $i } @supers;
                last if (!scalar(@supers_this_level));
                $inheritance = join(", ",map {make_link($_)} @supers_this_level) . "<br />" . $inheritance;
                $i++;
            }
        }

        if (scalar(@{$info->{derieved}})) {
            $inheritance .= "<br />\n" . join(", ", map {make_link($_)} @{$info->{derieved}}) . "\n";
        }

        #
        # all methods
        #
        my $table = new HTML::Table(-cols => 2,
                                    -cellspacing => 0,
                                    -cellpadding => 4,
                                    -border => 1,);
        my $tr = 1;
        foreach my $method (uniq
                            sort {lc($a) cmp lc($b)}
                            map { keys(%{$info_for_class{$_->[0]}->{methods}}) }
                            ([$classname,0], @supers)) {
            my @previous = ();
            foreach my $superclass (map {$_->[0]} @supers) {
                if (class_has_method($superclass, $method)) {
                    push @previous, $superclass;
                }
            }

            my $tr_class = 'local';
            my @doctext = ();
            if (class_has_method($classname, $method)) {
                #
                # defined here...
                #
                if (@previous) {
                    push @doctext,"overloaded from " . make_link($previous[0], $method);
                    $tr_class = 'overloaded';
                }
            } else {
                push @doctext, "defined in " . join(", ", map {make_link($_, $method)} @previous);
                $tr_class = 'inherited';
            }

            if (class_has_method($classname, $method) &&
                exists($info->{methods}->{$method}->{html})) {
                push @doctext, $info->{methods}->{$method}->{html};
            } else {
                foreach my $superclass (map {$_->[0]} @supers) {
                    if (class_has_method($superclass, $method) &&
                        exists($info_for_class{$superclass}->{methods}->{$method}->{html})) {
                        push @doctext, '';
                        push @doctext, "Documentation in " . make_link($superclass, $method) . ":";
                        push @doctext, $info_for_class{$superclass}->{methods}->{$method}->{html};
                        last;
                    }
                }
            }

            $table->setCell($tr,1,"<a name='$method'>$method</a>");
            $table->setCell($tr,2,join('<br />',@doctext));
            $table->setRowVAlign($tr, 'top');
            $table->setRowClass($tr, $tr_class);

            $tr++;
        }

        #
        # build html
        #
        my $html = $head . "<h2>Inheritance</h2>" . $inheritance . "<h2>Methods</h2>" . $table;

        #
        # create html file
        #
        my $filename = make_filename($classname);
        my $htmlfile;
        open($htmlfile, ">", "$dest_dir/$filename") or die "cannot write file '$filename'";
        print $htmlfile $html;
        close($htmlfile);

        #
        # append to nav frame
        #
        push @nav_frame, [$classname, $filename];
    }

    #
    # build frameset and nav frame
    #
    my $htmlfile;
    open($htmlfile, ">", "$dest_dir/nav.html") or die "cannot write file '$nav.html'";
    print $htmlfile join('<br />', map {qq{<a href="$_->[1]" target="content">$_->[0]</a>}} @nav_frame);
    close($htmlfile);

    open($htmlfile, ">", "$dest_dir/index.html") or die "cannot write file '$nav.html'";
    print $htmlfile qq{<frameset cols="200,*">
      <frame name="nav" src="nav.html" />
      <frame name="content" src="$nav_frame[0]->[1].html" />
    </frameset>};
    close($htmlfile);

}

#
# print text info
#
sub output_as_text {
    foreach my $classname (sort keys %info_for_class) {
        my $info = $info_for_class{$classname};
        # print Data::Dumper->Dump([$info, $classname]);
        my $parser = Pod::POM->new();
        my $pom = $parser->parse($info->{classpath}) or warn $parser->error();
        my ($methods) = grep {$_->title =~ m{methods}ixms} ($pom->head1());

        print "$classname (" . join(", ", @{$info->{super}}) . ")\n";

        if (exists($info->{derieved})) {
            print "  --> " . join(", ", @{$info->{derieved}}) . "\n\n";
        }

        foreach my $sub (sort keys(%{$info->{methods}})) {
            # $sub =~ s{\A .* ::}{}xms;
            print wrap('  ','  ',"$sub\n");

            if ($methods) {
                my ($head) = grep {$_->title =~ m{\A \s* $sub \s* \z}xms} ($methods->head2());
                if ($head) {
                    print fill('    ','    ',$head->content()->present('Pod::POM::View::Text')) . "\n";
                }
            }
            print "\n";
        }
        print "\n\n";
    }
}

#
# get all superclass-names
#
sub get_all_supers {
    my $classname = shift;
    my $depth = shift || 1;
    my @supers = ();

    if (exists($info_for_class{$classname})) {
        foreach my $superclass (@{$info_for_class{$classname}->{super}}) {
            push @supers, [$superclass, $depth];
            push @supers, get_all_supers($superclass, $depth+1);
        }
    }

    my %seen;
    return map { $seen{$_->[0]}++ ? () : $_ } @supers;
}

#
# simple helper: decide if a class has a method
#
sub class_has_method {
    my $classname = shift;
    my $method = shift;

    if (exists($info_for_class{$classname}) &&
        exists($info_for_class{$classname}->{methods}->{$method})) {
        return 1;
    }

    return 0;
}

#
# make filename from class
#
sub make_filename {
    my $classname = shift;

    my $filename = $classname;
    $filename =~ s{[^0-9a-zA-Z_]}{_}xmsg;

    return "$filename.html";
}

#
# make a link to a class
#
sub make_link {
    my $classname = shift;
    my $anchor = shift || '';

    if (is_interesting($classname)) {
        my $filename = make_filename($classname);
        $filename .= "#$anchor" if ($anchor);
        return qq{<a href="$filename">$classname</a>};
    } else {
        return $classname;
    }
}

#
# usage hints
#
sub usage {
    my $msg = shift || '';

    print STDERR "$msg\n\n" if ($msg);

    print STDERR "jifty_symlist [options]\n";
    print STDERR "  -h      this info\n";
    print STDERR "  -v      be verbose\n";
    print STDERR "  -f fmt  specify format to be generated (text|html)\n";
    print STDERR "\n";
    exit;
}

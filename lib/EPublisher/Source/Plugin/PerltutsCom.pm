package EPublisher::Source::Plugin::PerltutsCom;

=encoding utf-8

=cut

# ABSTRACT: Get POD from tutorials published on perltuts.com

use strict;
use warnings;

use Data::Dumper;
use Encode;
use File::Basename;
use LWP::Simple;

use EPublisher::Source::Base;

our @ISA = qw( EPublisher::Source::Base );

our $VERSION = 0.3;

# implementing the interface to EPublisher::Source::Base
sub load_source{
    my ($self) = @_;

    $self->publisher->debug( '100: start ' . __PACKAGE__ );

    my $options = $self->_config;
    
    return '' unless $options->{name};

    my $name = $options->{name};

    # fetching the requested tutorial from metacpan
    $self->publisher->debug( "103: fetch tutorial $name" );

    my $pod = LWP::Simple::get(
        'http://perltuts.com/tutorials/' . $name . '?format=pod'
    );

    my $regex = qr/<div \s+ id="content" \s+ class="row"> .*? not \s+ found/;

    if ( !$pod || $pod =~ $regex ) { 
        $self->publisher->debug(
            "103: tutorial $name does not exist"
        );
        return;
    };


    # perltuts.com always provides utf-8 encoded data, so we have
    # to decode it otherwise the target plugins may produce garbage
    eval{ $pod = decode( 'utf-8', $pod ); };

    my $title    = $name;
    my $info = { pod => $pod, filename => $name, title => $title };
    my @pod = $info;

    # make some nice debug output for what is in $info
    my $pod_short;
    if ($pod =~ m/(.{50})/s) {
        $pod_short = $1 . '[...]';
    }
    else {
        $pod_short = $pod;
    }

    $self->publisher->debug(
        "103: passed info: "
        . "filename => $name, "
        . "title => $title, "
        . 'pod => ' . substr($pod, 0, 30) . '<<<<CUT<<<<'
    );

    return @pod;
}

1;

=head1 SYNOPSIS

  my $source_options = { type => 'PerltutsCom', name => 'Moose' };
  my $url_source     = EPublisher::Source->new( $source_options );
  my $pod            = $url_source->load_source;

=head1 METHODS

=head2 load_source

  $url_source->load_source;

reads the URL 

=cut

#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use EPublisher::Source::Plugin::PerltutsCom;

my $error = '';

{
  package # private
      MockEPublisher;

  use Test::More;

  sub new { return bless {}, shift }
  sub debug { $error .= $_[1] . "\n"; };
}

{
    $error = '';

    my $config = {};
    my $obj    = EPublisher::Source::Plugin::PerltutsCom->new( $config );
    $obj->publisher( MockEPublisher->new );

    my @pods = $obj->load_source;

    # if tutorial does not exist I expect an empty array as return
    is scalar @pods, 0, 'inexisting tutorial name';
    is $error, "100: start EPublisher::Source::Plugin::PerltutsCom\n400: No tutorial name given\n";
}

{
    $error = '';

    my $config = { name => 'PDL' };
    my $obj    = EPublisher::Source::Plugin::PerltutsCom->new( $config );
    $obj->publisher( MockEPublisher->new );

    my @pods = $obj->load_source;

    # if tutorial does not exist I expect an empty array as return
    is scalar @pods, 0, 'inexisting tutorial name';
    like $error, qr"103: fetch tutorial PDL";
}

done_testing();

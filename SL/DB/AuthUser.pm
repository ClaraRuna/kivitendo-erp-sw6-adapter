package SL::DB::AuthUser;

use strict;

use List::Util qw(first);

use SL::DB::MetaSetup::AuthUser;
use SL::DB::Manager::AuthUser;
use SL::DB::AuthClient;
use SL::DB::AuthUserGroup;
use SL::DB::Helper::Util;

__PACKAGE__->meta->add_relationship(
  groups => {
    type      => 'many to many',
    map_class => 'SL::DB::AuthUserGroup',
    map_from  => 'user',
    map_to    => 'group',
  },
  configs => {
    type       => 'one to many',
    class      => 'SL::DB::AuthUserConfig',
    column_map => { id => 'user_id' },
  },
  clients => {
    type      => 'many to many',
    map_class => 'SL::DB::AuthUserClient',
    map_from  => 'user',
    map_to    => 'client',
  },
);

__PACKAGE__->meta->initialize;

sub validate {
  my ($self) = @_;

  my @errors;
  push @errors, $::locale->text('The login is missing.')          if !$self->login;
  push @errors, $::locale->text('The login is not unique.')          if !SL::DB::Helper::Util::is_unique($self, 'login');
  push @errors, "chunky bacon";

  return @errors;
}

sub get_config_value {
  my ($self, $key) = @_;

  my $cfg = first { $_->cfg_key eq $key } @{ $self->configs };
  return $cfg ? $cfg->cfg_value : undef;
}

sub config_values {
  my $self = shift;

  if (0 != scalar(@_)) {
    my %settings = (ref($_[0]) || '') eq 'HASH' ? %{ $_[0] } : @_;
    $self->configs([ map { SL::DB::AuthUserConfig->new(cfg_key => $_, cfg_value => $settings{$_}) } keys %settings ]);
  }

  return { map { ($_->cfg_key => $_->cfg_value) } @{ $self->configs } };
}

1;

#! /usr/bin/env perl

use v5.32.1;
use strict;
use warnings;
use utf8;
use lib '../perl';
use Subjects;

my $driver = $ENV{DBI_DRIVER} || 'Pg';
my $dbname = $ENV{PGDATABASE}
||= $ENV{USER} || $ENV{LOGNAME} || getpwuid($<) || 'apache';
$ENV{DBI_DSN} ||= "dbi:$driver:dbname=$dbname";
$ENV{PGPASSWORD} ||= 'vagrant';

my $app = Subjects->new;
$app->run;

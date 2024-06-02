#! /usr/bin/env perl

=encoding utf8

=head1 NAME

insert_test_records.pl - Insert test records into the database

=head1 SYNOPSIS

    insert_test_records.pl [-m MAX_OBJECTS] RECORDS

=head1 DESCRIPTION

This script inserts test records into the database.

=cut

use v5.32.1;
use strict;
use warnings;
use utf8;
use Getopt::Std;
use Time::Local qw(timelocal_posix);
use POSIX qw(strftime);
use DBI;

use constant USAGE => <<"_END_OF_USAGE_";
Usage:
    $0 [-m MAX_OBJECTS] RECORDS
For more information, see:
    perldoc -F $0
_END_OF_USAGE_

use constant BASE_EPOCH => timelocal_posix(0, 0, 0, 31, 4, 2017 - 1900);
my $VERSION = '0.1.0-SNAPSHOT';

sub HELP_MESSAGE { say USAGE }

$Getopt::Std::STANDARD_HELP_VERSION = 1;
my %opts;
getopts('m:', \%opts);
my $max_objects = $opts{m} || 0;
my $records;
unless ($records = $ARGV[0]) { die USAGE }

my $driver = $ENV{DBI_DRIVER} || 'Pg';
my $user = $ENV{USER} || $ENV{LOGNAME} || getpwuid($<) || 'vagrant';
my $dbname = $ENV{PGDATABASE} || $user;
my $data_source = $ENV{DBI_DSN} || "dbi:$driver:dbname=$dbname";
my $password = $ENV{PGPASSWORD};
my $dbh = DBI->connect($data_source, $user, $password, {
    RaiseError => 1, AutoCommit => 0
}) or die join(
    ' ', 'Could not connect to database:',
    $DBI::err, $DBI::state, $DBI::errstr
);
my ($i, $j);
eval {
    my $subject_sth = $dbh->prepare(<<'_END_OF_INSERT_INTO_SUBJECTS_');
        INSERT INTO dwh.subjects (
            subject_id, subject_number, subject, address, details,
            affiliation, visitor, contact_to,
            enter_at, work_at, end_at, exit_at, results
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
_END_OF_INSERT_INTO_SUBJECTS_
    my $objects_sth = $dbh->prepare(<<'_END_OF_INSERT_INTO_OBJECTS_');
        INSERT INTO dwh.objects (
            subject_id, object_id, category, object_type, object_name
        ) VALUES (?, ?, ?, ?, ?)
_END_OF_INSERT_INTO_OBJECTS_
    for ($i = 0; $i < $records; ++$i) {
        my $subject_id = $i;
        my $subject_number = $i;
        my $subject = "Subject $subject_id";
        my $address = "Address $subject_id";
        my $details = "Details $subject_id " x 25;
        my $affiliation = "Affiliation $subject_id";
        my $visitor = "Visitor $subject_id";
        my $contact_to = "Contact to $subject_id";
        my $enter_at = strftime('%Y-%m-%d %H:%M:%S', localtime(
            BASE_EPOCH + $i
        ));
        my $work_at = strftime('%Y-%m-%d %H:%M:%S', localtime(
            BASE_EPOCH + $i + 3600
        ));
        my $end_at = strftime('%Y-%m-%d %H:%M:%S', localtime(
            BASE_EPOCH + $i + 7200
        ));
        my $exit_at = strftime('%Y-%m-%d %H:%M:%S', localtime(
            BASE_EPOCH + $i + 10800
        ));
        my $results = "Results $subject_id";
        $subject_sth->execute(
            $subject_id, $subject_number, $subject, $address, $details,
            $affiliation, $visitor, $contact_to,
            $enter_at, $work_at, $end_at, $exit_at, $results
        );
        for ($j = 0; $j < $i % $max_objects; ++$j) {
            my $object_id = $j;
            my $category = $j % 10;
            my $object_type = $j % 100;
            my $object_name = $i . 'object' . $j;
            $objects_sth->execute(
                $subject_id, $object_id, $category, $object_type, $object_name
            );
        }
    }
    $dbh->commit;
    $dbh->disconnect;
};
if ($@) {
    die join(
        ' ', 'Could not insert test records:',
        $DBI::lasth->err, $DBI::lasth->state, $DBI::lasth->errstr, $@
    );
}

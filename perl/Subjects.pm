package Subjects;
use v5.32.1;
use strict;
use warnings;
use utf8;
use base 'CGI::Application';
use DBI;
use CGI::Session;
use Mojo::Log;

use constant Q_FROM => <<'_END_OF_Q_FROM_';
SELECT subject_number, subject, address, affiliation, visitor, contact_to,
       enter_at, work_at, end_at, exit_at, results, details,
       cnt, disp.object_name AS object_name, object_names
FROM dwh.subjects AS s LEFT JOIN (
    SELECT subject_id, COUNT(1) AS cnt FROM dwh.objects GROUP BY subject_id
) AS cnt ON s.subject_id = cnt.subject_id
LEFT JOIN (
    SELECT
        subject_id, object_name,
        ROW_NUMBER() OVER(PARTITION BY subject_id ORDER BY object_name) AS num
    FROM dwh.objects
) AS disp ON s.subject_id = disp.subject_id
         AND disp.num = 1
LEFT JOIN (
    SELECT
        subject_id, concat_ws(',', array_agg (object_name)) AS object_names
    FROM dwh.objects
    GROUP BY subject_id
) AS o ON s.subject_id = o.subject_id
_END_OF_Q_FROM_

sub setup($) {
    my $self = shift;
    $self->mode_param('rm');
    $self->run_modes([qw/display/]);
    $self->start_mode('display');
    $self->{dbh} = DBI->connect or die join(
        ' ', 'Could not connect to database:',
        $DBI::err, $DBI::state, $DBI::errstr
    );
    $self->{dbh}->{RaiseError} = 1;
}

sub display($) {
    my $self = shift;
    my $sth = $self->{dbh}->prepare(Q_FROM);
    $sth->execute;

}

#!/usr/bin/perl -w

use DBI;
use File::Spec;

################################################################################
##### BEGIN CONFIG #############################################################
################################################################################

## mysql user database name
$db ="mythconverg";

## mysql database user name
$user = "mythtv";

## mysql database password
$pass = "9up8LRIR";

## mysql hostname : in most cases "localhost" but it can be diffrent, too
$host="localhost";

# No 'next file' for files in this dirs, ignore them
@ignored_dirs = ('3D', 'Action', 'Anime', 'Comedy', 'Documentary', 'Drama', 'Family', 'Horror', 'Internet Movies', "Jacob ''s", 'MEU', 'Movies', 'Western');

################################################################################
##### END OF CONFIG ############################################################
################################################################################

## Return code
my $rc = 0;

## Establish DB connection
$dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);

############################################################################
#################  Set childids to have auto playlists  ####################
############################################################################

$query = "SELECT intid, title, filename FROM ".$db.".videometadata WHERE 1=1";
   
if (@ignored_dirs > 0)
{   
    foreach (@ignored_dirs)
    {  
        $query .= " AND filename NOT LIKE '" . $_ . "'";
    }
}

$query .= " ORDER BY filename;";

$sqlQuery  = $dbh->prepare($query)
or die "Can't prepare $query: $dbh->errstr\n";
$rv = $sqlQuery->execute
or die "can't execute the query: $sqlQuery->errstr";
   
if ($sqlQuery->rows > 0)
{
    $rows = $sqlQuery->fetchall_arrayref();

    for ($i = 0; $i < $#{$rows}; $i++)
    {  
        (undef,$directories,undef) = File::Spec->splitpath($$rows[$i][2]);
        @dirs = File::Spec->splitdir($directories);

        my $in_ignored_dir = 0;

        foreach (@dirs)
        {  
            $in_ignored_dir = (in_array($_, \@ignored_dirs)) ? 1 : $in_ignored_dir;
        }
        next if ($in_ignored_dir);

        $query = "update ".$db.".videometadata set childid='".$$rows[$i+1][0]."' where intid='".$$rows[$i][0]."';";

        $sqlQuery  = $dbh->prepare($query)
        or die "Can't prepare $query: $dbh->errstr\n";
        $rv = $sqlQuery->execute
        or die "can't execute the query: $sqlQuery->errstr";
    }

    # Run a final query which sets last 'next file' to the first file of your videos
    $query = "update ".$db.".videometadata set childid='".$$rows[0][0]."' where intid='".$$rows[$#{$rows}][0]."';";

    $sqlQuery  = $dbh->prepare($query)
    or die "Can't prepare $query: $dbh->errstr\n";
    $rv = $sqlQuery->execute
    or die "can't execute the query: $sqlQuery->errstr";
}

$rc = $sqlQuery->finish;

############################################################################
######################### Some functions ###################################
############################################################################

sub in_array
{
    my ($item, $array) = @_;
    my %hash = map { $_ => 1 } @$array;
    if ($hash{$item}) { return 1; } else { return 0; }
}

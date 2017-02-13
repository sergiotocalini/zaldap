#!/opt/csw/bin/perl -w

#====================================================================
# What's this ?
#====================================================================
# Script designed for cacti [ http://www.cacti.net ]
# Gets operations from the OpenLDAP (2.2.x and further) monitor branch
# You have to configure OpenLDAP with --enable-monitor and
# set database monitor in slapd.conf in order to use this script
#
# Copyright (C) 2009 Clement OUDOT
# Copyright (C) 2009 LTB-project.org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#====================================================================

#====================================================================
# Modules
#====================================================================
use strict;
use Net::LDAP;
use Getopt::Std;

#====================================================================
# Configuration
#====================================================================
# Command line parameters
my ( $host, $port, $binddn, $bindpw, $timeout, $ldap_version ) = &options;

# Name of the Operations branch in monitor
my $branch = "cn=Operations,cn=Monitor";

#====================================================================
# options() subroutine
#====================================================================
sub options {

    # Init Options Hash Table
    my %opts;
    getopt( 'hpDWtv', \%opts );
    &usage unless exists $opts{"h"};
    $opts{"p"} = 389 unless exists $opts{"p"};
    $opts{"t"} = 5   unless exists $opts{"t"};
    $opts{"v"} = 3   unless exists $opts{"v"};

    return ( $opts{"h"}, $opts{"p"}, $opts{"D"}, $opts{"W"}, $opts{"t"},
        $opts{"v"} );
}

#====================================================================
# usage() subroutine
#====================================================================
sub usage {
    print STDERR
"Usage: $0 -h host [-p port] [-D binddn -W bindpw] [-t timeout] [-v ldap_version]\n";
    print STDERR "Default values are :\n";
    print STDERR
"port: 389\nbinddn/bindpw: without (anonymous connection)\ntimeout: 5\nldap_version: 3\n";
    exit 1;
}

#====================================================================
# Connection to OpenLDAP monitor
#====================================================================
# Create LDAP connection
my $ldap = Net::LDAP->new(
    $host,
    port    => $port,
    version => $ldap_version,
    timeout => $timeout
) or die "Unable to connect to $host on port $port\n";

# Bind (anonymous or no)
my $bind;

if ( $binddn && $bindpw ) {
    $bind = $ldap->bind( $binddn, password => $bindpw );
}
else {
    $bind = $ldap->bind;
}

if ( $bind->code ) {
    print STDERR "Bind : " . $bind->error . "\n";
    exit 1;
}

# Search
my $search = $ldap->search(
    base   => $branch,
    scope  => 'one',
    filter => 'objectClass=*',
    attrs  => [ 'monitorOpInitiated', 'monitorOpCompleted', 'cn' ]
);

if ( $search->code ) {
    print STDERR "Search : " . $search->error . "\n";
    $ldap->unbind;
    exit 1;
}

# Unbind
$ldap->unbind;

#====================================================================
# Parse results
#====================================================================
foreach ( $search->entries ) {
    my $cn        = lc( $_->get_value('cn') );
    my $initiated = $_->get_value('monitorOpInitiated');
    my $completed = $_->get_value('monitorOpCompleted');
    $initiated = "U" unless defined $initiated;
    $completed = "U" unless defined $completed;
    print "$cn-initiated:$initiated ";
    print "$cn-completed:$completed ";
}

print "\n";

#====================================================================
# Exit
#====================================================================
exit 0;

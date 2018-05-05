#!/usr/bin/perl
=head1 NAME

 ssoStatus.pl

=head1 SYNOPSIS

 IntroscopeEPAgent.properties configuration
 
 N.B.:
 'names' property value is arbitrary, but must be unique.
 'command' and 'delayInSeconds' properties must also match the 'names' property
 'delayInSeconds' has a minimum value of 15. For a longer delay, use increments
 of 15.

 introscope.epagent.plugins.stateless.names=STATUS
 introscope.epagent.stateless.STATUS.command=perl <epa_home>/epaplugins/sso/status/ssoStatus.pl
 introscope.epagent.stateless.STATUS.delayInSeconds=15

=head1 DESCRIPTION

 Provides and up/down status (0=down; 1=up) for each given process.
 The default gives you the status of the SM Policy Server (smpolicysrv).

 To see help information:

 perl <epa_home>/epaplugins/sso/status/ssoStatus.pl --help

 To see captured output, use the DEBUG flag:

 perl <epa_home>/epaplugins/sso/status/ssoStatus.pl --debug

=head1 CAVEATS

 None reported at this time.

=head1 ISSUE TRACKING

 Submit any bugs/enhancements to:
 https://github.com/htdavis/ca-apm-epa-sso/issues

=head1 AUTHOR

 Hiko Davis, Sr Engineering Service Architect, CA Technologies

=head1 COPYRIGHT

 Copyright (c) 2018

 This plug-in is provided AS-IS, with no warranties, so please test thoroughly!

=cut

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl",
         "$FindBin::Bin/../../lib/perl");
use Wily::PrintMetric;

use Getopt::Long;


##### Do not modify the subroutines unless you know what you're doing! ###### 
sub usage {
    print "Unknown option: @_\n" if ( @_ );
    print "\nusage: $0\n\n";
    print "To see debug output:\n";
    print "\t$0 --debug\n";
    exit 1;
}

sub printMetric {
# expects 5 input values IN ORDER to create the XML string
# Type- Metric type; refer to EPA guide for types available
# Resource- Metric node name for your metric
# Subresource- (optional) Node name created under Resource; must pass an
#  empty string if not used
# Name- Metric name
# Value- Metric value (to be converted to an integer)
    Wily::PrintMetric::printMetric( type        => "$_[0]",
                                    resource    => "$_[1]",
                                    subresource => "$_[2]",
                                    name        => "$_[3]",
                                    value       => int($_[4]),
                                    );  
}
########################## END OF SUBROUTINES ###############################


my ($help, $debug);
&usage if ( not GetOptions( 'help|?' => \$help,
                            'debug!' => \$debug,
                          )
            or defined $help );

      
########################## START MAIN PROGRAM ###############################

# TODO Update @procs with the process names you want to find
# use a single space as a delimiter
my @procs = qw(smpolicysrv);

# iterate through each process to monitor
foreach my $proc (@procs) {
    print "process: $proc\n" if $debug;
    chomp $proc;
    my $psCommand = "ps -ef|grep $proc|head -1";
    my $psResults = undef;
    my $procName = undef;
    
    $psResults = `$psCommand`;
    print "results: $psResults\n" if $debug;
    
    # TODO Update this if block to match more than one process from @proc
    if ($proc eq "smpolicysrv") {
        $procName = "PolicyServerProcess";
    }
    print "process name: $procName\n" if $debug;
    
    my $resource = "SiteMinderManager|SiteMinderReporter";
    my $subResource = "OSResource-Linux|" . $procName . "|" . $proc;
    print "metric path: $resource$subResource\n" if $debug;

    # parse results; report zero if word 'grep' is found
    if ($psResults =~ m/grep/) {
        &printMetric("IntCounter", $resource, $subResource, "Status", "0");
    } else {
        &printMetric("IntCounter", $resource, $subResource, "Status", "1");
    }
}

exit 0;

#!/usr/bin/perl
=head1 NAME

 ssoProcMon.pl

=head1 SYNOPSIS

 IntroscopeEPAgent.properties configuration
 
 N.B.:
 'names' property value is arbitrary, but must be unique.
 'command' and 'delayInSeconds' properties must also match the 'names' property
 'delayInSeconds' has a minimum value of 15. For a longer delay, use increments
 of 15.

 introscope.epagent.plugins.stateless.names=PROCMON
 introscope.epagent.stateless.PROCMON.command=perl <epa_home>/epaplugins/sso/procmon/ssoProcMon.pl
 introscope.epagent.stateless.PROCMON.delayInSeconds=15

=head1 DESCRIPTION

 Returns Resident Set Size (RSS) and CPU values for each monitored process.

 To see help information:

 perl <epa_home>/epaplugins/sso/procmon/ssoProcMon.pl --help

 To see captured output, use the DEBUG flag:

 perl <epa_home>/epaplugins/sso/procmon/ssoProcMon.pl --debug

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
                                    value       => sprintf("%.0f", "$_[4]"),
                                    );  
}
########################## END OF SUBROUTINES ###############################


my ($help, $debug);
&usage if ( not GetOptions( 'help|?' => \$help,
                            'debug!' => \$debug, )
            or defined $help );

      
########################## START MAIN PROGRAM ###############################

my ($admCommand, $smpCommand);
my (@admResults, @smpResults);
my $total=0;
my $resource = "SiteMinderManager|SiteMinderReporter";
my @procs = qw(adminui smpolicysrv);

# grab adminui tab stop 10
$smpCommand='ps -eaf|awk \'/(\.*\/adminui\/runtime\/bin\/java)/&&!/grep/{print $2}\'|xargs -n1 ps vww|awk \'NF>5&&!/PID/{printf "%s\t%s\t%s\n",$8,$9,$10;t+=$7;c+=$11}\'';
# grab smpolicysrv at EOL
$admCommand='ps -eaf|awk \'/(smpolicysrv)/&&!/grep/{print $2}\'|xargs -n1 ps vww|awk \'NF>5&&!/PID/{printf "%s\t%s\t%s\n",$8,$9,$NF;t+=$7;c+=$11}\'';
    
if ($debug) {
    @admResults = <<"EOF" =~ m/(^.*\n)/mg;
597324\t15.2\t/CA/siteminder/adminui/runtime/bin/java
EOF
    @smpResults = <<"EOF" =~ m/(^.*\n)/mg;
589560\t1.51\tsmpolicysrv
EOF
} else {
    # report zeros if processes are stopped
    my $smpStatus = `ps -ef|grep smpolicysrv|head -1`;
    my $admStatus = `ps -ef|grep adminui.*java|head -1`;
    if ($smpStatus =~ m/grep/) {
        # report zero values
        splice(@smpResults, 0, 0, "0    0.0 smpolicysrv");
    } else {
        @smpResults = `$smpCommand`;
    }
    if ($admStatus =~ m/grep/) {
        # report zero values
        splice(@admResults, 0, 0, "0    0.0 /CA/siteminder/adminui/runtime/bin/java");
    } else {
        @admResults = `$admCommand`;
    }
}
print "admresults: " . $admResults[0] if $debug;
print "smpresults: " . $smpResults[0] if $debug;


# loop through each process and report results
foreach my $proc (@procs) {
    chomp $proc;
    my $procName;
    my ($rss,$cpu);
    if ($proc eq "adminui") {
        $procName = "AdminUiProcess";
        # split the result values
        if ($admResults[0] =~ /\s/) {
            ($rss,$cpu,undef) = split(/\s+/, $admResults[0]);
        } else {
            ($rss,$cpu,undef) = split(/\t/, $admResults[0]);
        }
    } else {
        $procName = "PolicyServerProcess";
        # split the result values
        if ($smpResults[0] =~ /\s/) {
            ($rss,$cpu,undef) = split(/\s+/, $smpResults[0]);
        } else {
            ($rss,$cpu,undef) = split(/\t/, $smpResults[0]);
        }
    }
    # set the metric subresource value
    my $subResource = "OSResource-Linux|" . $procName . "|" . $proc;
    print "metric path: $resource$subResource\n" if $debug;
    print "rss: $rss\n" if $debug;
    print "cpu: $cpu\n" if $debug;
    # report results
    &printMetric("LongCounter", $resource, $subResource, "RSS", $rss);
    &printMetric("IntCounter", $resource, $subResource, "CPU", $cpu);
    # total up RSS value
    ($total+=$_) for $rss;
}

# report the total resident memory usage
&printMetric("LongCounter", $resource, "OSResource-Linux|Memory", "Total Resident Memory (KB)", $total);

exit 0;
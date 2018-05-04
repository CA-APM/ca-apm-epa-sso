# EPAgent Plugins for CA SSO

The EPAgent Plug-ins for CA SSO monitors SiteMinder processes.

ssoProcMon.pl - returns CPU & RSS for each SM process.
ssoStatus.pl - returns up/down status for SM Policy Server.  

## Dependencies
Tested with CA APM 9.x.x/10.x.x EM, EPAgent 9.x.x/10.x.x, Linux 2.6.x, and Perl 5.16/5.22.

## Known Issues
None to report at this time.

# Licensing
Field Extensions are provided under the Apache License, version 2.0. See [Licensing](https://www.apache.org/licenses/LICENSE-2.0).

# Prerequisite
An installed and configured EPAgent on the SiteMinder Policy Server.

Find the version 9.6 to 10.x documentation on the [CA APM documentation wiki.](https://docops.ca.com)

# Install and Configure EPA Plug-ins for CA SSO
1. Extract the plug-ins to \<*EPAgent_Home*\>/epaplugins.
2. Configure the IntroscopeEPAgent.properties file in \<*EPAgent_Home*\> by adding these stateless plug-in properties:

    introscope.epagent.plugins.stateless.names=PROCMON,STATUS (can be appended to a previous entry)  
    introscope.epagent.stateless.PROCMON.command=perl <epa_home>/epaplugins/sso/procmon/ssoProcMon.pl  
    introscope.epagent.stateless.PROCMON.delayInSeconds=30  
    introscope.epagent.stateless.STATUS.command=perl <epa_home>/epaplugins/sso/status/ssoStatus.pl  
    introscope.epagent.stateless.STATUS.delayInSeconds=15  

# Use EPAgent Plug-ins for CA SSO
Start the EPAgent using the provided control script in \<*EPAgent_Home*\>/bin.

# Debug and Troubleshoot
Update the root logger in \<epa_home\>/IntroscopeEPAgent.properties from INFO to DEBUG, then save. No need to restart the JVM.
You can also manually execute the plugins from a console and use perl's built-in debugger.

# Limitations
None to report at this time.

# Support
This document and plug-in are made available from CA Technologies. They are provided as examples at no charge as a courtesy to the CA APM Community at large. This plug-in might require modification for use in your environment. However, this plug-in is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. This plug-in is not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. The plug-in can be used and distributed freely amongst the CA APM Community, but not sold. As such, it is unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this plug-in implies that you understand and agree to the terms listed herein.
Although this plug-in is unsupported, please let us know if you have any problems or questions. You can add comments to the CA APM Community site so that the author(s) can attempt to address the issue or question.
Unless explicitly stated otherwise this plug-in is only supported on the same platforms as the CA APM Java agent.

# Change Log
Changes for each version of the field extension.

Version | Author | Comment
--------|--------|--------
1.0 | Hiko Davis | First bundled version of the field extension.


## Support URL
[https://github.com/htdavis/ca-apm-fieldpack-epa-sso](https://github.com/htdavis/ca-apm-epa-sso)

## Short Description
Monitor CA SSO

## Categories
Server Monitoring

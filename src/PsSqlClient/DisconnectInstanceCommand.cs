
using System;
using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;
using System.Security;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    public class DisconnectInstanceCommand : PSCmdlet
    {
        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SqlConnection Connection { get; set; }

        protected override void ProcessRecord()
        {
            Connection.Close();
            WriteVerbose($"Connection to {Connection.DataSource} is {Connection.State}");
        }

    }
}

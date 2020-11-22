
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
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SqlConnection Connection { get; set; } = ConnectInstanceCommand.SessionConnection;

        protected override void ProcessRecord()
        {
            Connection.Close();
            WriteVerbose($"Connection to {Connection.DataSource} is {Connection.State}");
            if (ConnectInstanceCommand.SessionConnection == Connection) {
                ConnectInstanceCommand.SessionConnection = null;
            }
        }

    }
}

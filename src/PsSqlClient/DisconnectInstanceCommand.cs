using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    public class DisconnectInstanceCommand : ClientCommand
    {
        [Parameter(
            Position = 0,
            ValueFromPipeline = true
        )]
        [ValidateNotNullOrEmpty()]
        public new SqlConnection Connection { get; set; } = ConnectInstanceCommand.SessionConnection;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            Connection.Close();
            WriteVerbose($"Connection to [{Connection.DataSource}].[{Connection.Database}] is {Connection.State}");
            if (ConnectInstanceCommand.SessionConnection == Connection) {
                ConnectInstanceCommand.SessionConnection = null;
            }
        }
    }
}

using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{
    [Cmdlet(VerbsDiagnostic.Test, "Connection")]
    [OutputType(typeof(bool))]
    public class TestConnectionCommand : ClientCommand
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

            WriteVerbose($"Connection to [{Connection.DataSource}].[{Connection.Database}] is {Connection.State}");
            switch (Connection.State)
            {
                case System.Data.ConnectionState.Open:
                    break;
                default:
                    WriteObject(false);
                    return;
            }

            using (var command = new SqlCommand(cmdText: "SELECT DATABASEPROPERTYEX(DB_NAME(), 'Status') AS Status", connection: Connection))
            {
                var status = command.ExecuteScalar();
                WriteVerbose($"Database [{Connection.DataSource}].[{Connection.Database}] is {status}");
                switch (status)
                {
                    case "ONLINE":
                        break;

                    default:
                        WriteObject(false);
                        return;
                }
            }

            WriteObject(true);
        }
    }
}

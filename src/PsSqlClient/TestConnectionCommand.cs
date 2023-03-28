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

        [Parameter()]
        public SwitchParameter Reconnect { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if (!TestConnection())
            {
                WriteObject(false);
                return;
            }

            try
            {
                if (!TestDatabase())
                {
                    WriteObject(false);
                    return;
                }
            }
            catch (SqlException ex)
            {
                if (Reconnect.IsPresent)
                {
                    WriteVerbose($"Reconnect [{Connection.DataSource}].[{Connection.Database}]");
                    Connection.Open();
                    if (!TestDatabase())
                    {
                        WriteObject(false);
                        return;
                    }
                }
                else
                {
                    WriteVerbose(ex.Message);
                    WriteObject(false);
                    return;
                }
            }

            WriteObject(true);
        }

        private bool TestConnection()
        {

            WriteVerbose($"Connection to [{Connection.DataSource}].[{Connection.Database}] is {Connection.State}");
            switch (Connection.State)
            {
                case System.Data.ConnectionState.Open:
                    return true;
                default:
                    return false;
            }
        }

        private bool TestDatabase()
        {
            using (var command = new SqlCommand(cmdText: "SELECT DATABASEPROPERTYEX(DB_NAME(), 'Status') AS Status", connection: Connection))
            {
                var status = command.ExecuteScalar();
                WriteVerbose($"Database [{Connection.DataSource}].[{Connection.Database}] is {status}");
                switch (status)
                {
                    case "ONLINE":
                        return true;

                    default:
                        return false;
                }
            }
        }
    }
}

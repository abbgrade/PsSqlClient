using System.Management.Automation;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Disconnect, "Instance")]
    public class DisconnectInstanceCommand : ClientCommand
    {
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

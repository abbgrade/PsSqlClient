
using System;
using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;
using System.Security;

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

using System;
using System.Management.Automation;
using System.Data.SqlClient;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = "ConnectionString")]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        [Parameter(
            ParameterSetName = "ConnectionString",
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString { get; set; }

        protected override void ProcessRecord()
        {
            switch (ParameterSetName)
            {
                case "ConnectionString":
                    WriteVerbose("Connect by connection string");
                    var connection = new SqlConnection(ConnectionString);
                    connection.Open();
                    WriteVerbose($"Connection to {connection.DataSource} is {connection.State}");
                    WriteObject(connection);
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }
        }

    }
}

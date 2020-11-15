using System;
using System.Security;
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

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string DataSource { get; set; }

        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId { get; set; }

        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SecureString Password { get; set; }

        protected override void ProcessRecord()
        {
            SqlConnection connection;
            switch (ParameterSetName)
            {
                case "ConnectionString":
                    WriteVerbose("Connect by connection string");
                    connection = new SqlConnection(ConnectionString);
                    break;

                case "Properties_IntegratedSecurity": {
                    WriteVerbose("Connect by Integrated Security");
                    var connectionString = $"Data Source='{DataSource}'";
                    connectionString += ";Integrated Security=True";
                    connection = new SqlConnection(connectionString);
                    break;
                }

                case "Properties_SQLServerAuthentication": {
                    WriteVerbose("Connect by SQL Server Authentication");
                    Password.MakeReadOnly();
                    var credential = new SqlCredential(userId:UserId, password: Password);
                    var connectionString = $"Data Source='{DataSource}'";
                    connection = new SqlConnection(connectionString, credential: credential);
                    break;
                }

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }
            connection.Open();
            WriteVerbose($"Connection to {connection.DataSource} is {connection.State}");
            WriteObject(connection);
        }

    }
}


using System;
using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;
using System.Security;
#if AZURE
using Microsoft.Azure.Services.AppAuthentication;
#endif

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
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
            switch (ParameterSetName)
            {
                case "ConnectionString":
                    WriteVerbose("Connect by connection string");
                    builder.ConnectionString = ConnectionString;
                    connection = new SqlConnection(connectionString:builder.ConnectionString);
                    break;

                case "Properties_IntegratedSecurity": {
                    WriteVerbose("Connect by Integrated Security");
                    builder.DataSource = DataSource;
                    if (DataSource.EndsWith("database.windows.net")) {
#if AZURE
                        connection = new SqlConnection(connectionString: builder.ConnectionString);
                        var token = new AzureServiceTokenProvider().GetAccessTokenAsync("https://database.windows.net").Result;
                        connection.AccessToken = token;
#else
                        throw new System.NotImplementedException("Azure authentication is not implemented");
#endif
                    } else {
                        builder.IntegratedSecurity = true;
                        connection = new SqlConnection(connectionString: builder.ConnectionString);
                    }
                    break;
                }

                case "Properties_SQLServerAuthentication": {
                    WriteVerbose("Connect by SQL Server Authentication");
                    Password.MakeReadOnly();
                    builder.DataSource = DataSource;
                    connection = new SqlConnection(
                        connectionString: builder.ConnectionString,
                        credential: new SqlCredential(userId:UserId, password: Password)
                    );
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

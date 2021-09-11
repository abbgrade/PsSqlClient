
using System;
using System.Data.SqlClient;
using System.Management.Automation;
using System.Security;
using System.Threading;
using Microsoft.Azure.Services.AppAuthentication;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = "ConnectionString")]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        internal static SqlConnection SessionConnection { get; set; }

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

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public int RetryCount { get; set; } = 0;

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public int RetryInterval { get; set; } = 10;

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
                        connection = new SqlConnection(connectionString: builder.ConnectionString);
                        var token = new AzureServiceTokenProvider().GetAccessTokenAsync("https://database.windows.net").Result;
                        connection.AccessToken = token;
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

            int retryIndex = 0;
            do {
                retryIndex += 1;
                try {
                    connection.Open();
                    WriteVerbose($"Connection to {connection.DataSource} is {connection.State}");
                    break;
                }
                catch (SqlException ex) {
                    WriteError(new ErrorRecord(
                        exception: ex,
                        errorId:ex.Number.ToString(),
                        errorCategory:ErrorCategory.OpenError,
                        targetObject:null
                    ));
                    if (retryIndex < RetryCount) {
                        WriteVerbose($"Wait {RetryInterval}s for connection attemp {retryIndex}.");
                        Thread.Sleep(new TimeSpan(hours:0, minutes:0, seconds:RetryInterval));
                    } else {
                        throw ex;
                    }
                }
            } while (retryIndex < RetryCount);

            SessionConnection = connection;
            WriteObject(connection);
        }

    }
}

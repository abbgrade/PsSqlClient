using System;
using Microsoft.Data.SqlClient;
using System.Management.Automation;
using System.Security;
using System.Threading;
using System.Reflection;
#if AZURE_INTEGRATED
using Microsoft.Azure.Services.AppAuthentication;
#endif

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = "ConnectionString")]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        internal static SqlConnection SessionConnection { get; set; }

        #region Parameters

        [Parameter(
            ParameterSetName = "ConnectionString",
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Server", "ServerName", "ServerInstance")]
        public string DataSource { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = "Properties_SQLServerAuthentication",
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Database", "DatabaseName")]
        public string InitialCatalog { get; set; }

        [Parameter(
            ParameterSetName = "Properties_IntegratedSecurity",
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }

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

        #endregion

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            SniLoader.Load();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            SqlConnection connection;
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
            switch (ParameterSetName)
            {
                case "ConnectionString":
                    WriteVerbose("Connect by connection string");
                    builder.ConnectionString = ConnectionString;
                    connection = new SqlConnection(connectionString: builder.ConnectionString);
                    break;

                case "Properties_IntegratedSecurity":
                    WriteVerbose("Connect by Integrated Security");
                    builder.DataSource = DataSource;
                    if (InitialCatalog != null)
                        builder.InitialCatalog = InitialCatalog;
#if AZURE_INTEGRATED
                    if (DataSource.EndsWith("database.windows.net")) {
                        connection = new SqlConnection(connectionString: builder.ConnectionString);
                        if ( AccessToken == null )
                            AccessToken = new AzureServiceTokenProvider().GetAccessTokenAsync("https://database.windows.net").Result;
                        connection.AccessToken = AccessToken;
                    } else {
#endif
                    builder.IntegratedSecurity = true;
                    connection = new SqlConnection(connectionString: builder.ConnectionString);
#if AZURE_INTEGRATED
                    }
#endif
                    break;

                case "Properties_SQLServerAuthentication":
                    WriteVerbose("Connect by SQL Server Authentication");
                    Password.MakeReadOnly();
                    builder.DataSource = DataSource;
                    if (InitialCatalog != null)
                        builder.InitialCatalog = InitialCatalog;
                    connection = new SqlConnection(
                        connectionString: builder.ConnectionString,
                        credential: new SqlCredential(userId: UserId, password: Password)
                    );
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }

            int retryIndex = 0;
            do
            {
                retryIndex += 1;
                try
                {
                    connection.Open();
                    WriteVerbose($"Connection to [{connection.DataSource}].[{connection.Database}] is {connection.State}");
                    break;
                }
                catch (SqlException ex)
                {
                    WriteError(new ErrorRecord(
                        exception: ex,
                        errorId: ex.Number.ToString(),
                        errorCategory: ErrorCategory.OpenError,
                        targetObject: null
                    ));
                    if (retryIndex < RetryCount)
                    {
                        WriteVerbose($"Wait {RetryInterval}s for connection attemp {retryIndex}.");
                        Thread.Sleep(new TimeSpan(hours: 0, minutes: 0, seconds: RetryInterval));
                    }
                    else
                    {
                        throw ex;
                    }
                }
            } while (retryIndex < RetryCount);

            SessionConnection = connection;
            WriteObject(connection);
        }
    }
}

using System;
using Microsoft.Data.SqlClient;
using System.Management.Automation;
using System.Security;
using System.Threading;
using System.Runtime.InteropServices;
using System.IO;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = PARAMETERSET_CONNECTION_STRING)]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        #region ParameterSets
        private const string PARAMETERSET_CONNECTION_STRING     = "ConnectionString";
        private const string PARAMETERSET_PROPERTIES_INTEGRATED = "Properties_IntegratedSecurity";
        private const string PARAMETERSET_PROPERTIES_CREDENTIAL = "Properties_Credential";
        #endregion

        internal static SqlConnection SessionConnection { get; set; }

        #region Parameters
        [Parameter(
            ParameterSetName = PARAMETERSET_CONNECTION_STRING,
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Server", "ServerName", "ServerInstance")]
        public string DataSource { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            ValueFromPipelineByPropertyName = true
        )]
        public int? Port { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Database", "DatabaseName")]
        public string InitialCatalog { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            ValueFromPipelineByPropertyName = true
        )]
        public int? ConnectTimeout { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_INTEGRATED,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL,
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

            if (!RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                return;

            var runtimeIdentifier = RuntimeInformation.ProcessArchitecture switch
            {
                Architecture.X86 => "win-x86",
                Architecture.X64 => "win-x64",
                Architecture.Arm => "win-arm",
                Architecture.Arm64 => "win-arm64",
                _ => null
            };

            if (runtimeIdentifier == null)
                return;

            var dllPath = Path.Combine(
                Path.GetDirectoryName(typeof(ConnectInstanceCommand).Assembly.Location),
                "runtimes",
                runtimeIdentifier,
                "native",
                "Microsoft.Data.SqlClient.SNI.dll"
            );
            WriteVerbose($"Load {dllPath}");
            NativeLibrary.Load(dllPath);
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            try
            {
                SqlConnection connection;
                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                switch (ParameterSetName)
                {
                    case PARAMETERSET_CONNECTION_STRING:
                        WriteVerbose("Connect by connection string");
                        builder.ConnectionString = ConnectionString;
                        connection = new SqlConnection(connectionString: builder.ConnectionString);
                        break;

                    case PARAMETERSET_PROPERTIES_INTEGRATED:
                    case PARAMETERSET_PROPERTIES_CREDENTIAL:
                        WriteVerbose("Connect by properties");

                        builder.DataSource = DataSource;

                        if (Port != null)
                            builder.DataSource += $",{Port.Value}";

                        if (InitialCatalog != null)
                            builder.InitialCatalog = InitialCatalog;

                        if (ConnectTimeout != null)
                            builder.ConnectTimeout = ConnectTimeout.Value;

                        switch (ParameterSetName)
                        {

                            case PARAMETERSET_PROPERTIES_INTEGRATED:

                                if (DataSource.EndsWith("database.windows.net"))
                                {
                                    WriteVerbose("Authenticate by Azure Active Directory / Integrated Security");
                                    builder.Authentication = SqlAuthenticationMethod.ActiveDirectoryIntegrated;
                                }
                                else
                                {
                                    WriteVerbose("Authenticate by Windows Active Directory / Integrated Security");
                                    builder.IntegratedSecurity = true;
                                }

                                connection = new SqlConnection(connectionString: builder.ConnectionString);
                                break;

                            case PARAMETERSET_PROPERTIES_CREDENTIAL:

                                Password.MakeReadOnly();

                                if (DataSource.EndsWith("database.windows.net"))
                                {
                                    WriteVerbose("Authenticate by Azure Active Directory Credential");
                                    builder.Authentication = SqlAuthenticationMethod.ActiveDirectoryPassword;
                                }
                                else
                                {
                                    WriteVerbose("Authenticate by Sql Credential");
                                }

                                connection = new SqlConnection(
                                    connectionString: builder.ConnectionString,
                                    credential: new SqlCredential(userId: UserId, password: Password)
                                );
                                break;

                            default:
                                throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
                        }

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
                            WriteVerbose($"Wait {RetryInterval}s for connection attemp {retryIndex}/{RetryCount}.");
                            Thread.Sleep(new TimeSpan(hours: 0, minutes: 0, seconds: RetryInterval));
                        }
                        else
                        {
                            throw;
                        }
                    }
                } while (retryIndex < RetryCount);

                SessionConnection = connection;
                WriteObject(connection);

            } catch (Exception ex)
            {
                WriteVerbose($"Exception thrown {ex}.");
                throw;
            }
        }
    }
}

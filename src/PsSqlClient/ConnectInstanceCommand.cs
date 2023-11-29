using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;
using System;
using System.Diagnostics;
using System.IO;
using System.Management.Automation;
using System.Net;
using System.Runtime.InteropServices;
using System.Security;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = PARAMETERSET_PROPERTIES_BASIC)]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        #region ParameterSets
        private const string PARAMETERSET_CONNECTION_STRING = "ConnectionString";
        private const string PARAMETERSET_CONNECTION_STRING_TOKEN = "ConnectionString_withToken";
        private const string PARAMETERSET_CONNECTION_STRING_ACQUIRE_TOKEN = "ConnectionString_acquireToken";
        private const string PARAMETERSET_PROPERTIES_BASIC = "Properties_Basic";
        private const string PARAMETERSET_PROPERTIES_BASIC_TOKEN = "Properties_Basic_withToken";
        private const string PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN = "Properties_Basic_acquireToken";
        private const string PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES = "Properties_Credential";
        private const string PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT = "Properties_CredentialObject";
        #endregion

        private enum AuthenticationClass
        {
            BasicAuthentication,
            CredentialAuthentication,
            TokenAuthentication
        }

        internal static SqlConnection SessionConnection { get; set; }
        private SqlConnectionStringBuilder ConnectionStringBuilder { get; set; } = new();

        private bool IsAzureSql
        {
            get { return DataSource.Contains("database.windows.net", StringComparison.InvariantCultureIgnoreCase); }
        }

        #region Parameters
        #region Connection String
        [Parameter(
            ParameterSetName = PARAMETERSET_CONNECTION_STRING,
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_CONNECTION_STRING_TOKEN,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_CONNECTION_STRING_ACQUIRE_TOKEN,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string ConnectionString
        {
            get { return ConnectionStringBuilder.ConnectionString; }
            set
            {
                ConnectionStringBuilder.ConnectionString = value;

                // move user id from connection string to credential
                if (!string.IsNullOrWhiteSpace(ConnectionStringBuilder.UserID))
                {
                    if (UserId != null && UserId != ConnectionStringBuilder.UserID)
                    {
                        WriteWarning($"Conflicting user from parameter '{UserId}' and connection string '{ConnectionStringBuilder.UserID}'.");
                    }

                    WriteVerbose("move user id from connection string to property.");
                    UserId = ConnectionStringBuilder.UserID;
                    ConnectionStringBuilder.Remove("User ID");
                }

                // move password from connection string to credential
                if (!string.IsNullOrWhiteSpace(ConnectionStringBuilder.Password))
                {
                    var connectionStringSecurePassword = new NetworkCredential("", ConnectionStringBuilder.Password).SecurePassword;
                    if (Password != null && Password != connectionStringSecurePassword)
                    {
                        WriteWarning("Conflicting password from parameter and connection string'.");
                    }

                    WriteVerbose("move password from connection string to property.");
                    Password = connectionStringSecurePassword;
                    ConnectionStringBuilder.Remove("Password");
                }
            }
        }
        #endregion
        #region Target Parameters

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Server", "ServerName", "ServerInstance")]
        public string DataSource
        {
            get { return ConnectionStringBuilder.DataSource; }
            set { ConnectionStringBuilder.DataSource = value; }
        }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            ValueFromPipelineByPropertyName = true
        )]
        public int? Port { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            Position = 1,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            Position = 1,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("Database", "DatabaseName")]
        public string InitialCatalog
        {
            get { return ConnectionStringBuilder.InitialCatalog; }
            set { ConnectionStringBuilder.InitialCatalog = value; }
        }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true
        )]
        public SwitchParameter TrustServerCertificate
        {
            get
            {
                return ConnectionStringBuilder.TrustServerCertificate;
            }
            set
            {
                ConnectionStringBuilder.TrustServerCertificate = value;
            }
        }

        #endregion
        #region Robustness Parameter

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            ValueFromPipelineByPropertyName = true
        )]
        public int ConnectTimeout
        {
            get { return ConnectionStringBuilder.ConnectTimeout; }
            set { ConnectionStringBuilder.ConnectTimeout = value; }
        }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            ValueFromPipelineByPropertyName = true
        )]
        [Alias("RetryCount")]
        public int ConnectRetryCount
        {
            get { return ConnectionStringBuilder.ConnectRetryCount; }
            set { ConnectionStringBuilder.ConnectRetryCount = value; }
        }


        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT,
            ValueFromPipelineByPropertyName = true
        )]
        [Alias("RetryInterval")]
        public int ConnectRetryInterval
        {
            get { return ConnectionStringBuilder.ConnectRetryInterval; }
            set { ConnectionStringBuilder.ConnectRetryInterval = value; }
        }

        #endregion
        #region Authentication Parameter

        [Parameter()]
        public SqlAuthenticationMethod Authentication
        {
            get { return ConnectionStringBuilder.Authentication; }
            set { ConnectionStringBuilder.Authentication = value; }
        }

        [Parameter()]
        public SwitchParameter IntegratedSecurity
        {
            get { return new SwitchParameter(ConnectionStringBuilder.IntegratedSecurity); }
            set { ConnectionStringBuilder.IntegratedSecurity = value.IsPresent; }
        }

        #region Token Parameter
        [Parameter(
            Mandatory = true,
            ParameterSetName = PARAMETERSET_CONNECTION_STRING_TOKEN
        )]
        [Parameter(
            Mandatory = true,
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }

        [Parameter(
            Mandatory = true,
            ParameterSetName = PARAMETERSET_CONNECTION_STRING_ACQUIRE_TOKEN
        )]
        [Parameter(
            Mandatory = true,
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN
        )]
        public SwitchParameter AcquireToken { get; set; }


        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_ACQUIRE_TOKEN
        )]
        public string Resource { get; set; } = "https://database.windows.net";
        #endregion
        #region Credential Parameter

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT
        )]
        public PSCredential Credential
        {
            get
            {
                if (UserId == null || Password.Length == 0)
                    return null;
                return new PSCredential(userName: UserId, password: Password);
            }
            set
            {
                UserId = value.UserName;
                Password = value.Password;
            }
        }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SecureString Password { get; set; }

        #endregion
        #endregion
        #endregion

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            WriteVerbose($"ParameterSet: {ParameterSetName}");
            LoadSqlClientDll();
            InitAuthenticationClass();
        }

        private void LoadSqlClientDll()
        {
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


        private AuthenticationClass _authenticationClass;

        private void InitAuthenticationClass()
        {
            if (AcquireToken.IsPresent)
            {
                WriteVerbose("Token will be acquired. Use token-based authentication.");
                _authenticationClass = AuthenticationClass.TokenAuthentication;

                AccessToken = new DefaultAzureCredential().GetToken(
                    new TokenRequestContext(scopes: new string[] { Resource + "/.default" }) { }
                ).Token;
                WriteDebug($"AccessToken:${AccessToken}");
            }
            else if (!string.IsNullOrWhiteSpace(AccessToken))
            {
                WriteVerbose("Token was provided. Use token-based authentication.");
                _authenticationClass = AuthenticationClass.TokenAuthentication;
            }
            else if (Credential != null)
            {
                WriteVerbose("Credential was provided. Use credential-based authentication.");
                _authenticationClass = AuthenticationClass.CredentialAuthentication;
            }
            else
            {
                WriteVerbose("Any token or credential was provided. Use basic authentication.");
                _authenticationClass = AuthenticationClass.BasicAuthentication;
            }

            WriteVerbose($"Authentication: {_authenticationClass}.{Authentication}");
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            ValidateAuthenticationParameter();

            // apply parameters
            if (Port != null)
                DataSource += $",{Port.Value}";

            if (ConnectTimeout < ConnectRetryCount * ConnectRetryInterval)
            {
                ConnectTimeout = ConnectRetryCount * ConnectRetryInterval;
                WriteVerbose($"Change ConnectTimeout to {ConnectTimeout}, based on ConnectRetryCount and ConnectRetryInterval.");
            }

            // connect
            try
            {
                SqlConnection connection = CreateSqlConnection();
                OpenConnection(connection);
                SessionConnection = connection;
            }
            catch (PipelineStoppedException)
            {
                throw;
            }
            catch (Exception ex)
            {
                WriteVerbose($"Exception thrown {ex}.");
                throw;
            }
        }
        private SqlConnection CreateSqlConnection()
        {
            WriteVerbose($"ConnectionString: {ConnectionString}");
            // create connection
            SqlConnection connection;
            switch (_authenticationClass)
            {
                case AuthenticationClass.BasicAuthentication:
                    connection = new SqlConnection(connectionString: ConnectionString);
                    break;
                case AuthenticationClass.CredentialAuthentication:
                    Password.MakeReadOnly();
                    connection = new SqlConnection(
                        connectionString: ConnectionString,
                        credential: new SqlCredential(userId: UserId, password: Password)
                    );
                    break;
                case AuthenticationClass.TokenAuthentication:
                    connection = new SqlConnection(connectionString: ConnectionString)
                    {
                        AccessToken = AccessToken
                    };
                    break;
                default:
                    throw new NotSupportedException();
            }

            return connection;
        }

        private void OpenConnection(SqlConnection connection)
        {
            // open connection
            var connectStopwatch = Stopwatch.StartNew();
            try
            {
                WriteDebug($"Open connection with connection string: ${ ConnectionString }");
                connection.Open();
            }
            catch (SqlException ex)
            {
                WriteError(new ErrorRecord(
                    exception: ex,
                    errorId: ex.Number.ToString(),
                    errorCategory: ErrorCategory.OpenError,
                    targetObject: $"[{DataSource}].[InitialCatalog]"
                ));
            }
            finally
            {
                connectStopwatch.Stop();
                WriteVerbose($"Connection to [{connection.DataSource}].[{connection.Database}] is {connection.State} after {connectStopwatch.Elapsed}");
                WriteObject(connection);
            }
        }

        private void ValidateAuthenticationParameter()
        {
            // validate parameters
            try
            {
                switch (Authentication)
                {
                    case SqlAuthenticationMethod.NotSpecified:
                        switch (_authenticationClass)
                        {
                            case AuthenticationClass.BasicAuthentication:
                                if (IsAzureSql)
                                {
                                    Authentication = SqlAuthenticationMethod.ActiveDirectoryDefault;
                                    WriteVerbose($"Apply default authentication for Azure SQL: {Authentication}.");
                                }
                                break;

                            case AuthenticationClass.CredentialAuthentication:
                                if (IsAzureSql)
                                {
                                    Authentication = SqlAuthenticationMethod.ActiveDirectoryPassword;
                                    WriteVerbose($"Apply default authentication for Azure SQL: {Authentication}.");
                                }
                                else
                                {
                                    Authentication = SqlAuthenticationMethod.SqlPassword;
                                    WriteVerbose($"Apply default authentication for SQL Server: {Authentication}.");
                                }
                                break;
                        }
                        break;

                    case SqlAuthenticationMethod.SqlPassword:
                        if (_authenticationClass != AuthenticationClass.CredentialAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {_authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryPassword:
                        if (_authenticationClass != AuthenticationClass.CredentialAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {_authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryIntegrated:
                        if (_authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {_authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryInteractive:
                        if (_authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {_authenticationClass}.");

                        if (!Environment.UserInteractive)
                        {
                            throw new InvalidOperationException("Cannot use interactive authentication in a non-interactive PowerShell session.");
                        }
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryServicePrincipal:
                        throw new NotSupportedException();

                    case SqlAuthenticationMethod.ActiveDirectoryDeviceCodeFlow:
                        throw new NotSupportedException();

                    case SqlAuthenticationMethod.ActiveDirectoryManagedIdentity:
                        throw new NotSupportedException();

                    case SqlAuthenticationMethod.ActiveDirectoryMSI:
                        throw new NotSupportedException();

                    case SqlAuthenticationMethod.ActiveDirectoryDefault:
                        if (_authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {_authenticationClass}.");
                        break;
                }
            }
            catch (InvalidOperationException ex)
            {
                WriteError(new ErrorRecord(
                    exception: ex,
                    errorId: null,
                    errorCategory: ErrorCategory.InvalidOperation,
                    targetObject: null
                ));
            }
            catch (NotSupportedException)
            {
                WriteWarning($"{Authentication} is currently not supported or tested.");
            }
        }
    }
}

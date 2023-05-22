using System;
using Microsoft.Data.SqlClient;
using System.Management.Automation;
using System.Security;
using System.Runtime.InteropServices;
using System.IO;
using System.Net;

namespace PsSqlClient
{
    [Cmdlet(VerbsCommunications.Connect, "Instance", DefaultParameterSetName = PARAMETERSET_PROPERTIES_BASIC)]
    [OutputType(typeof(SqlConnection))]
    public class ConnectInstanceCommand : PSCmdlet
    {
        #region ParameterSets
        private const string PARAMETERSET_CONNECTION_STRING = "ConnectionString";
        private const string PARAMETERSET_CONNECTION_STRING_TOKEN = "ConnectionString_withToken";
        private const string PARAMETERSET_PROPERTIES_BASIC = "Properties_Basic";
        private const string PARAMETERSET_PROPERTIES_BASIC_TOKEN = "Properties_Basic_withToken";
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
        [ValidateNotNullOrEmpty()]
        public string ConnectionString
        {
            get { return ConnectionStringBuilder.ConnectionString; }
            set {
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
                    ConnectionStringBuilder.UserID = null;
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
                    ConnectionStringBuilder.Password = null;
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
            set { ConnectionStringBuilder.CommandTimeout = value; }
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
        public SqlAuthenticationMethod Authentication {
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
            ParameterSetName = PARAMETERSET_CONNECTION_STRING_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [Parameter(
            Mandatory = true,
            ParameterSetName = PARAMETERSET_PROPERTIES_BASIC_TOKEN,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty()]
        public string AccessToken { get; set; }
        #endregion
        #region Credential Parameter

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_OBJECT
        )]
        public PSCredential Credential { get; set; }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string UserId
        {
            get { 
                return Credential?.UserName;
            }
            set {
                if (string.IsNullOrWhiteSpace(value))
                    value = null;

                Credential = new PSCredential(userName: value, password: Password);
            }
        }

        [Parameter(
            ParameterSetName = PARAMETERSET_PROPERTIES_CREDENTIAL_PROPERTIES,
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SecureString Password
        {
            get
            {
                return Credential?.Password;
            }
            set
            {
                Credential = new PSCredential(userName: UserId, password: value);
            }
        }
        #endregion
        #endregion
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

            WriteVerbose($"ParameterSet: {ParameterSetName}");

            // determine authentication class
            AuthenticationClass authenticationClass;
            if (!string.IsNullOrWhiteSpace(AccessToken))
            {
                WriteVerbose("Token was provided. Use token-based authentication.");
                authenticationClass = AuthenticationClass.TokenAuthentication;
            } else if (Credential != null)
            {
                WriteVerbose("Credential was provided. Use credential-based authentication.");
                authenticationClass = AuthenticationClass.CredentialAuthentication;
            } else
            {
                WriteVerbose("Any token or credential was provided. Use basic authentication.");
                authenticationClass = AuthenticationClass.BasicAuthentication;
            }

            WriteVerbose($"Authentication: {authenticationClass}.{Authentication}");

            // validate parameters
            try
            {
                switch (Authentication)
                {
                    case SqlAuthenticationMethod.NotSpecified:
                        switch (authenticationClass)
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
                                } else
                                {
                                    Authentication = SqlAuthenticationMethod.SqlPassword;
                                    WriteVerbose($"Apply default authentication for SQL Server: {Authentication}.");
                                }
                                break;
                        }
                        break;

                    case SqlAuthenticationMethod.SqlPassword:
                        if (authenticationClass != AuthenticationClass.CredentialAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryPassword:
                        if (authenticationClass != AuthenticationClass.CredentialAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryIntegrated:
                        if (authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {authenticationClass}.");
                        break;

                    case SqlAuthenticationMethod.ActiveDirectoryInteractive:
                        if (authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {authenticationClass}.");

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
                        if (authenticationClass != AuthenticationClass.BasicAuthentication)
                            throw new InvalidOperationException($"{Authentication} is not supported with {authenticationClass}.");
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

            // apply parameters
            if (Port != null)
                DataSource += $",{Port.Value}";

            // connect
            try
            {
                // create connection
                SqlConnection connection = authenticationClass switch
                {
                    AuthenticationClass.BasicAuthentication => new SqlConnection(connectionString: ConnectionString),
                    AuthenticationClass.CredentialAuthentication => new SqlConnection(
                                                connectionString: ConnectionString,
                                                credential: new SqlCredential(userId: UserId, password: Password)
                                            ),
                    AuthenticationClass.TokenAuthentication => new SqlConnection(connectionString: ConnectionString)
                    {
                        AccessToken = AccessToken
                    },
                    _ => throw new NotSupportedException(),
                };

                // open connection
                try
                {
                    connection.Open();
                    WriteVerbose($"Connection to [{connection.DataSource}].[{connection.Database}] is {connection.State}");
                }
                catch (SqlException ex)
                {
                    WriteError(new ErrorRecord(
                        exception: ex,
                        errorId: ex.Number.ToString(),
                        errorCategory: ErrorCategory.OpenError,
                        targetObject: null
                    ));
                }

                SessionConnection = connection;
                WriteObject(connection);

            }
            catch (Exception ex)
            {
                WriteVerbose($"Exception thrown {ex}.");
                throw;
            }
        }
    }
}

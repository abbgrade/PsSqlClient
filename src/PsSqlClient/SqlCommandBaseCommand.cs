
using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Management.Automation;

namespace PsSqlClient
{
    public abstract class SqlCommandBaseCommand : PSCmdlet
    {

        [Parameter(
            ParameterSetName = nameof(CommandType.Text),
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Command", "Query")]
        public string Text { get; set; }

        [Parameter(
            ParameterSetName = "TextFile",
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public FileInfo InputFile { get; set; }

        [Parameter(
            ParameterSetName = nameof(CommandType.StoredProcedure),
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string Procedure { get; set; }

        [Parameter(
            ParameterSetName = nameof(CommandType.StoredProcedure),
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string Schema { get; set; }

        [Parameter(
            ParameterSetName = nameof(CommandType.StoredProcedure),
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string Database { get; set; }

        [Parameter(
            Position = 1,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public Hashtable Parameter { get; set; }

        [Parameter(
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SqlConnection Connection { get; set; } = ConnectInstanceCommand.SessionConnection;

        [Parameter(
            Mandatory = false,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public int? Timeout { get; set; }

        private void SqlInfoMessageEventHandler(object sender, SqlInfoMessageEventArgs e)
        {
            WriteInformation(messageData: e, tags: null);
        }

        protected abstract void ProcessSqlCommand(SqlCommand command);

        protected override void ProcessRecord()
        {
            if (Connection == null)
                throw new ArgumentNullException(
                    paramName: nameof(Connection),
                    message: "Specify Connection parameter or run Connect-TSqlInstance command."
                );
            else
                WriteVerbose($"Execute on [{Connection.DataSource}].[{Connection.Database}]");

            Connection.InfoMessage += SqlInfoMessageEventHandler;

            var command = new SqlCommand() {
                Connection = Connection
            };

            switch (ParameterSetName)
            {
                case nameof(CommandType.Text):
                    command.CommandType = CommandType.Text;
                    command.CommandText = Text;
                    break;

                case "TextFile":
                    command.CommandType = CommandType.Text;
                    command.CommandText = File.ReadAllText(InputFile.FullName);
                    break;

                case nameof(CommandType.StoredProcedure):
                    command.CommandType = CommandType.StoredProcedure;
                    if ( Database != null) {
                        command.CommandText = $"[{Database}].";
                    }
                    if ( Schema != null) {
                        command.CommandText += $"[{Schema}].";
                    }
                    if ( command.CommandText != null) {
                        command.CommandText += $"[{Procedure}]";
                    } else {
                        command.CommandText = Procedure;
                    }
                    break;

                default:
                    throw new NotImplementedException($"ParameterSetName {ParameterSetName} is not implemented");
            }

            if (Timeout.HasValue)
            {
                command.CommandTimeout = Timeout.Value;
            }

            if ( Parameter != null ) {
                foreach (DictionaryEntry item in Parameter)
                {
                    command.Parameters.Add(
                        new SqlParameter(parameterName: item.Key.ToString(), value: item.Value)
                    );
                }
            }

            ProcessSqlCommand(command);

            Connection.InfoMessage -= SqlInfoMessageEventHandler;
        }
    }
}

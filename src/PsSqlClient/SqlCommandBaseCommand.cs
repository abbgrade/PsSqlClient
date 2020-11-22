
using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{

    public abstract class SqlCommandBaseCommand : PSCmdlet
    {

        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string Text { get; set; }

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

        protected override void BeginProcessing() {
            Connection.InfoMessage += SqlInfoMessageEventHandler;
        }

        protected override void EndProcessing() {
            Connection.InfoMessage -= SqlInfoMessageEventHandler;
        }

        protected abstract void ProcessSqlCommand(SqlCommand command);

        protected override void ProcessRecord()
        {
            var command = new SqlCommand(cmdText: Text, connection: Connection);
            if (Timeout.HasValue)
            {
                command.CommandTimeout = Timeout.Value;
            }

            if ( Parameter != null ) {
                foreach (DictionaryEntry item in Parameter)
                {
                    command.Parameters.Add(
                        new SqlParameter(parameterName: $"@{item.Key}", value: item.Value)
                    );
                }
            }

            ProcessSqlCommand(command);
        }

    }
}

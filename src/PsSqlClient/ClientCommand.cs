using System;
using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{
    public abstract class ClientCommand : PSCmdlet
    {

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        public SqlConnection Connection { get; set; } = ConnectInstanceCommand.SessionConnection;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            if (Connection == null)
                throw new PSArgumentNullException(
                    paramName: nameof(Connection),
                    message: "Specify Connection parameter or run Connect-TSqlInstance command."
                );

            Connection.InfoMessage += Connection_InfoMessage;
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();

            Connection.InfoMessage -= Connection_InfoMessage;
        }

        private void Connection_InfoMessage(object sender, SqlInfoMessageEventArgs e)
        {
            WriteInformation(messageData: e, tags: null);
            foreach (var error in e.Errors)
                ProcessSqlError((SqlError)error);
            WriteVerbose(e.Message);
        }

        private void ProcessSqlError(SqlError error)
        {
            switch (error.Class)
            {
                case 0:
                    WriteVerbose(error.Message);
                    break;
                default:
                    WriteVerbose($"Class:{error.Class}, LineNumber:{error.LineNumber}, Message:{error.Message}, Number:{error.Number}, Procedure:{error.Procedure}, Server:{error.Server}, Source:{error.Source}, State:{error.State}");
                    WriteError(new ErrorRecord(
                        exception: new Exception(error.ToString()),
                        errorId: error.Number.ToString(),
                        errorCategory: ErrorCategory.NotSpecified,
                        targetObject: null
                    ));
                    break;
            }
        }
    }
}

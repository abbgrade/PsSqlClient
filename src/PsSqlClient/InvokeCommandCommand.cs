
using System.Management.Automation;
using System.Data;
using System.Data.SqlClient;

namespace PsSqlClient
{

    [Cmdlet(VerbsLifecycle.Invoke, "Command")]
    [OutputType(typeof(PSObject))]
    public class InvokeCommandCommand : PSCmdlet
    {

        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public string Text { get; set; }

        [Parameter(
            Position = 1,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public SqlConnection Connection { get; set; }

        [Parameter(
            Position = 2,
            Mandatory = false,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty()]
        public int? Timeout { get; set; }

        protected override void ProcessRecord()
        {
            var command = new SqlCommand(cmdText: Text, connection: Connection);
            if (Timeout.HasValue)
            {
                command.CommandTimeout = Timeout.Value;
            }

            var dataTable = new DataTable();
            using (var dataAdapter = new SqlDataAdapter(command))
            {
                dataAdapter.Fill(dataTable);
            }
            foreach (DataRow row in dataTable.Rows)
            {
                var output = new PSObject();
                foreach (DataColumn column in dataTable.Columns)
                {
                    output.Members.Add(
                        new PSNoteProperty(
                            name:column.ColumnName,
                            value:row[column]
                        )
                    );
                }
                WriteObject(row);
            }
        }

    }
}

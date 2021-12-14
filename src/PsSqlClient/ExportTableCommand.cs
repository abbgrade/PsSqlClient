using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{

    [Cmdlet(VerbsData.Export, "Table")]
    public class ExportTableCommand : ClientCommand
    {

        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true
        )]
        [ValidateNotNullOrEmpty()]
        public PSObject InputObject { get; set; }

        [Parameter(Position = 1, Mandatory = true)]
        [ValidateNotNullOrEmpty()]
        public string Table { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public int? BatchSize { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public int? Timeout { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter CheckConstraints { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter FireTriggers { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter KeepIdentity { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter KeepNulls { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter TableLock { get; set; }

        [Parameter(ValueFromPipelineByPropertyName = true)]
        public SwitchParameter UseInternalTransaction { get; set; }

        private SqlBulkCopy bulkCopy;
        private DataTable tempTable;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();

            var options = SqlBulkCopyOptions.Default;

            if (CheckConstraints.IsPresent) {
                options |= SqlBulkCopyOptions.CheckConstraints;
            }

            if (FireTriggers.IsPresent) {
                options |= SqlBulkCopyOptions.FireTriggers;
            }

            if (KeepIdentity.IsPresent) {
                options |= SqlBulkCopyOptions.KeepIdentity;
            }

            if (KeepNulls.IsPresent) {
                options |= SqlBulkCopyOptions.KeepNulls;
            }

            if (TableLock.IsPresent) {
                options |= SqlBulkCopyOptions.TableLock;
            }

            if (UseInternalTransaction.IsPresent) {
                options |= SqlBulkCopyOptions.UseInternalTransaction;
            }

            bulkCopy = new SqlBulkCopy(
                connection: Connection,
                copyOptions: options,
                externalTransaction: null
            );

            if (BatchSize.HasValue)
            {
                bulkCopy.BatchSize = BatchSize.Value;
            }

            if (Timeout.HasValue)
            {
                bulkCopy.BulkCopyTimeout = Timeout.Value;
            }

            bulkCopy.DestinationTableName = Table;

            tempTable = new DataTable();
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();

            bulkCopy.WriteToServer(tempTable);
            bulkCopy.Close();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            if ( tempTable.Columns.Count == 0 ) {
                foreach (var property in InputObject.Properties) {
                    tempTable.Columns.Add(property.Name);
                }
            }
            var row = tempTable.NewRow();
            foreach (var property in InputObject.Properties) {
                row[property.Name] = property.Value;
            }
            tempTable.Rows.Add(row);
        }
    }
}

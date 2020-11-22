
using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{

    [Cmdlet(VerbsLifecycle.Invoke, "Command")]
    [OutputType(typeof(PSObject))]
    public class InvokeCommandCommand : SqlCommandBaseCommand
    {
        protected override void ProcessSqlCommand(SqlCommand command)
        {
            var dataSet = new DataSet();
            using (var dataAdapter = new SqlDataAdapter(command))
            {
                dataAdapter.Fill(dataSet);
            }

            foreach (DataTable dataTable in dataSet.Tables)
            {
                foreach (DataRow row in dataTable.Rows)
                {
                    var output = new PSObject();
                    foreach (DataColumn column in dataTable.Columns)
                    {
                        output.Members.Add(
                            new PSNoteProperty(
                                name:column.ColumnName,
                                value:row.IsNull(column.ColumnName) ? null : row[column]
                            )
                        );
                    }
                    WriteObject(output);
                }
            }
        }

    }
}

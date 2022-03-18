using System.Data;
using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace PsSqlClient
{

    [Cmdlet(VerbsCommon.Get, "Value", DefaultParameterSetName = nameof(CommandType.Text))]
    [OutputType(typeof(PSObject))]
    public class GetValueCommand : SqlCommandBaseCommand
    {
        protected override void ProcessSqlCommand(SqlCommand command)
        {
            WriteObject(command.ExecuteScalar());
        }
    }
}

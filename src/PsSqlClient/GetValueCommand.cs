
using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
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

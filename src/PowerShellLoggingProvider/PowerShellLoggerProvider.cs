using Microsoft.Extensions.Logging;
using System;

namespace PowerShellLoggingProvider
{
    public class PowerShellLoggerProvider : ILoggerProvider
    {
        public ILogger CreateLogger(string categoryName)
        {
            return new PowershellLogger();
        }

        public void Dispose()
        {
            throw new NotImplementedException();
        }
    }
}

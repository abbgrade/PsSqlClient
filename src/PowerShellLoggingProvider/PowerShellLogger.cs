using Microsoft.Extensions.Logging;
using System;
using System.Management.Automation;

namespace PowerShellLoggingProvider
{
    public class PowerShellLogger : ILogger
    {
        private readonly PSCmdlet _cmdlet;

        public PowerShellLogger(PSCmdlet cmdlet)
        {
            _cmdlet = cmdlet;
        }

        public IDisposable BeginScope<TState>(TState state)
        {
            throw new NotImplementedException();
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            throw new NotImplementedException();
        }

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            switch (logLevel)
            {
                case LogLevel.Debug:
                    _cmdlet.WriteDebug(formatter(state, exception));
                    break;

                case LogLevel.Information:
                case LogLevel.Trace:
                    _cmdlet.WriteVerbose(formatter(state, exception));
                    break;

                case LogLevel.Warning:
                    _cmdlet.WriteWarning(formatter(state, exception));
                    break;

                case LogLevel.Error:
                case LogLevel.Critical:
                    _cmdlet.WriteError(new ErrorRecord(
                        exception: exception, 
                        errorId: exception.GetType().Name, 
                        errorCategory: ErrorCategory.NotSpecified, 
                        targetObject: null
                    ));
                    break;

                default:
                    throw new NotImplementedException(nameof(logLevel));
            }
        }
    }
}

---
external help file: PsSqlClient.dll-Help.xml
Module Name: PsSqlClient
online version:
schema: 2.0.0
---

# Connect-TSqlInstance

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Properties_Basic (Default)
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-TrustServerCertificate] [-ConnectTimeout <Int32>] [-ConnectRetryCount <Int32>]
 [-ConnectRetryInterval <Int32>] [-Authentication <SqlAuthenticationMethod>] [-IntegratedSecurity]
 [<CommonParameters>]
```

### ConnectionString
```
Connect-TSqlInstance [-ConnectionString] <String> [-Authentication <SqlAuthenticationMethod>]
 [-IntegratedSecurity] [<CommonParameters>]
```

### ConnectionString_withToken
```
Connect-TSqlInstance [-ConnectionString] <String> [-Authentication <SqlAuthenticationMethod>]
 [-IntegratedSecurity] -AccessToken <String> [<CommonParameters>]
```

### ConnectionString_acquireToken
```
Connect-TSqlInstance [-ConnectionString] <String> [-Authentication <SqlAuthenticationMethod>]
 [-IntegratedSecurity] [-AcquireToken] [<CommonParameters>]
```

### Properties_Basic_withToken
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [-InitialCatalog] <String>
 [-TrustServerCertificate] [-ConnectTimeout <Int32>] [-ConnectRetryCount <Int32>]
 [-ConnectRetryInterval <Int32>] [-Authentication <SqlAuthenticationMethod>] [-IntegratedSecurity]
 -AccessToken <String> [<CommonParameters>]
```

### Properties_Basic_acquireToken
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [-InitialCatalog] <String>
 [-ConnectTimeout <Int32>] [-ConnectRetryCount <Int32>] [-ConnectRetryInterval <Int32>]
 [-Authentication <SqlAuthenticationMethod>] [-IntegratedSecurity] [-AcquireToken] [-Resource <String>]
 [<CommonParameters>]
```

### Properties_Credential
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-TrustServerCertificate] [-ConnectTimeout <Int32>] [-ConnectRetryCount <Int32>]
 [-ConnectRetryInterval <Int32>] [-Authentication <SqlAuthenticationMethod>] [-IntegratedSecurity]
 [-UserId] <String> [-Password] <SecureString> [<CommonParameters>]
```

### Properties_CredentialObject
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-TrustServerCertificate] [-ConnectTimeout <Int32>] [-ConnectRetryCount <Int32>]
 [-ConnectRetryInterval <Int32>] [-Authentication <SqlAuthenticationMethod>] [-IntegratedSecurity]
 [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AccessToken
{{ Fill AccessToken Description }}

```yaml
Type: String
Parameter Sets: ConnectionString_withToken, Properties_Basic_withToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectTimeout
{{ Fill ConnectTimeout Description }}

```yaml
Type: Int32
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Basic_acquireToken, Properties_Credential, Properties_CredentialObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionString
{{ Fill ConnectionString Description }}

```yaml
Type: String
Parameter Sets: ConnectionString
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ConnectionString_withToken, ConnectionString_acquireToken
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DataSource
{{ Fill DataSource Description }}

```yaml
Type: String
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Basic_acquireToken, Properties_Credential, Properties_CredentialObject
Aliases: Server, ServerName, ServerInstance

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InitialCatalog
{{ Fill InitialCatalog Description }}

```yaml
Type: String
Parameter Sets: Properties_Basic, Properties_Credential, Properties_CredentialObject
Aliases: Database, DatabaseName

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Properties_Basic_withToken, Properties_Basic_acquireToken
Aliases: Database, DatabaseName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
{{ Fill Password Description }}

```yaml
Type: SecureString
Parameter Sets: Properties_Credential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Port
{{ Fill Port Description }}

```yaml
Type: Int32
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Basic_acquireToken, Properties_Credential, Properties_CredentialObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserId
{{ Fill UserId Description }}

```yaml
Type: String
Parameter Sets: Properties_Credential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Authentication
{{ Fill Authentication Description }}

```yaml
Type: SqlAuthenticationMethod
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConnectRetryCount
{{ Fill ConnectRetryCount Description }}

```yaml
Type: Int32
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Basic_acquireToken, Properties_Credential, Properties_CredentialObject
Aliases: RetryCount

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectRetryInterval
{{ Fill ConnectRetryInterval Description }}

```yaml
Type: Int32
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Basic_acquireToken, Properties_Credential, Properties_CredentialObject
Aliases: RetryInterval

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: Properties_CredentialObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IntegratedSecurity
{{ Fill IntegratedSecurity Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AcquireToken
{{ Fill AcquireToken Description }}

```yaml
Type: SwitchParameter
Parameter Sets: ConnectionString_acquireToken, Properties_Basic_acquireToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Resource
{{ Fill Resource Description }}

```yaml
Type: String
Parameter Sets: Properties_Basic_acquireToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrustServerCertificate
{{ Fill TrustServerCertificate Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Properties_Basic, Properties_Basic_withToken, Properties_Credential, Properties_CredentialObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Nullable`1[[System.Int32, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
### System.Security.SecureString
### System.Int32
## OUTPUTS

### Microsoft.Data.SqlClient.SqlConnection
## NOTES

## RELATED LINKS

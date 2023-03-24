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

### Properties_IntegratedSecurity (Default)
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-ConnectTimeout <Int32>] [-RetryCount <Int32>] [-RetryInterval <Int32>] [<CommonParameters>]
```

### ConnectionString
```
Connect-TSqlInstance [-ConnectionString] <String> [-RetryCount <Int32>] [-RetryInterval <Int32>]
 [<CommonParameters>]
```

### Properties_Credential
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-ConnectTimeout <Int32>] [-UserId] <String> [-Password] <SecureString> [-RetryCount <Int32>]
 [-RetryInterval <Int32>] [<CommonParameters>]
```

### Properties_AccessToken
```
Connect-TSqlInstance [-DataSource] <String> [-Port <Int32>] [[-InitialCatalog] <String>]
 [-ConnectTimeout <Int32>] -AccessToken <String> [-RetryCount <Int32>] [-RetryInterval <Int32>]
 [<CommonParameters>]
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
Parameter Sets: Properties_AccessToken
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
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential, Properties_AccessToken
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

### -DataSource
{{ Fill DataSource Description }}

```yaml
Type: String
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential, Properties_AccessToken
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
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential, Properties_AccessToken
Aliases: Database, DatabaseName

Required: False
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
Parameter Sets: Properties_IntegratedSecurity, Properties_Credential, Properties_AccessToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RetryCount
{{ Fill RetryCount Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RetryInterval
{{ Fill RetryInterval Description }}

```yaml
Type: Int32
Parameter Sets: (All)
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

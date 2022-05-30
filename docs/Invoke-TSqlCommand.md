---
external help file: PsSqlClient.dll-Help.xml
Module Name: PsSqlClient
online version:
schema: 2.0.0
---

# Invoke-TSqlCommand

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Text (Default)
```
Invoke-TSqlCommand [-Text] <String> [[-Parameter] <Hashtable>] [-Timeout <Int32>] [-Connection <SqlConnection>]
 [<CommonParameters>]
```

### TextFile
```
Invoke-TSqlCommand [-InputFile] <FileInfo> [[-Parameter] <Hashtable>] [-Timeout <Int32>]
 [-Connection <SqlConnection>] [<CommonParameters>]
```

### StoredProcedure
```
Invoke-TSqlCommand [-Procedure] <String> [-Schema <String>] [-Database <String>] [[-Parameter] <Hashtable>]
 [-Timeout <Int32>] [-Connection <SqlConnection>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Connection
{{ Fill Connection Description }}

```yaml
Type: SqlConnection
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
{{ Fill Database Description }}

```yaml
Type: String
Parameter Sets: StoredProcedure
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputFile
{{ Fill InputFile Description }}

```yaml
Type: FileInfo
Parameter Sets: TextFile
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Parameter
{{ Fill Parameter Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Procedure
{{ Fill Procedure Description }}

```yaml
Type: String
Parameter Sets: StoredProcedure
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Schema
{{ Fill Schema Description }}

```yaml
Type: String
Parameter Sets: StoredProcedure
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Text
{{ Fill Text Description }}

```yaml
Type: String
Parameter Sets: Text
Aliases: Command, Query

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Timeout
{{ Fill Timeout Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.IO.FileInfo

### System.Collections.Hashtable

### System.Nullable`1[[System.Int32, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS

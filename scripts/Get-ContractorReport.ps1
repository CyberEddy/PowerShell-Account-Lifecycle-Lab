<#
.SYNOPSIS
Reports contractor account status using fictional employee data.

.DESCRIPTION
Contractors expire the day after their EndDate.
This script generates a report only; it does not modify accounts.
#>

param(
    [datetime]$AsOfDate = (Get-Date).Date
)

# Stop if a file operation fails.
$ErrorActionPreference = 'Stop'

# Locate folders relative to this script.
$inputPath = Join-Path $PSScriptRoot '../data/employees.csv'
$reportFolder = Join-Path $PSScriptRoot '../reports'
$reportPath = Join-Path $reportFolder 'contractor-review.csv'

# Read the employee roster.
$employees = @(Import-Csv -LiteralPath $inputPath)

# Evaluate contractors only.
$report = @(
    foreach ($employee in $employees) {
        if ($employee.EmployeeType -ne 'Contractor') {
            continue
        }

        $status = ''
        $endDate = [datetime]::MinValue

        # CSV values are text, so check True/False explicitly.
        if ($employee.AccountEnabled -notin @('True', 'False')) {
            $status = 'Review: invalid account status'
        }
        elseif ($employee.AccountEnabled -eq 'False') {
            $status = 'Already disabled'
        }
        elseif ([string]::IsNullOrWhiteSpace($employee.EndDate)) {
            $status = 'Review: missing end date'
        }
        else {
            # Require an unambiguous YYYY-MM-DD date.
            $validDate = [datetime]::TryParseExact(
                $employee.EndDate,
                'yyyy-MM-dd',
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None,
                [ref]$endDate
            )

            if (-not $validDate) {
                $status = 'Review: invalid end date'
            }
            elseif ($endDate.Date -lt $AsOfDate.Date) {
                $status = 'Offboarding required'
            }
            else {
                $status = 'No action: contract not expired'
            }
        }

        # Build one report row per contractor.
        [pscustomobject]@{
            EmployeeId      = $employee.EmployeeId
            DisplayName     = $employee.DisplayName
            UserPrincipalName = $employee.UserPrincipalName
            EndDate         = $employee.EndDate
            AccountEnabled  = $employee.AccountEnabled
            ReviewDate      = $AsOfDate.ToString('yyyy-MM-dd')
            Status          = $status
        }
    }
)

if ($report.Count -eq 0) {
    Write-Host 'No contractor records found. No report generated.'
    return
}

# Create the report folder and save the results.
New-Item -ItemType Directory -Path $reportFolder -Force | Out-Null

$report | Export-Csv -LiteralPath $reportPath -NoTypeInformation -Encoding UTF8

# Display a readable summary.
$report | Format-Table DisplayName, EndDate, Status -AutoSize
Write-Host "Report saved to: $reportPath"

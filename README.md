# PowerShell Account Lifecycle Lab

A PowerShell lab that processes fictional employee records, identifies
expired contractor accounts, and generates a contractor review report.

This project demonstrates account lifecycle reporting relevant to
IT administration and identity and access management (IAM).

## Current Scope

The script evaluates CSV records and generates a report only.
It does not connect to Active Directory or Microsoft Entra ID,
disable accounts, or modify the source employee data.

All employee records are fictional.

## Features

- Read employee records from a CSV file.
- Evaluate contractors while excluding regular employees.
- Identify expired contractors whose accounts remain enabled.
- Recognize accounts that are already disabled.
- Flag missing or invalid end dates for enabled contractors.
- Flag invalid account status values.
- Export results to CSV and display a console summary.
- Support a specified review date for reproducible testing.

## Expiration Rule

A contractor's end date is their final permitted day of access.

For example, a contractor whose end date is September 7, 2026:
- Is not expired on September 7.
- Is expired on September 8.

This is a lab assumption. A production implementation would need
an agreed cutoff time and time zone.

## Repository Files

| File | Purpose |
|---|---|
| `data/employees.csv` | Fictional employee roster |
| `scripts/Get-ContractorReport.ps1` | Contractor review script |
| `reports/sample-contractor-review-2026-09-07.csv` | Saved example output |

## Run the Lab

Download and extract the repository, then open PowerShell in the
project folder containing `data` and `scripts`.

Run the baseline test:

```powershell
.\scripts\Get-ContractorReport.ps1 -AsOfDate '2026-09-07'
```

The script displays the results and writes:

`reports/contractor-review.csv`

Running the script again replaces that generated report.

To review records using today's local date:

```powershell
.\scripts\Get-ContractorReport.ps1
```

## Verified Tests

The following results were verified by running the script in
Windows PowerShell.

| Record | September 7 result |
|---|---|
| Avery Morgan | Excluded: regular employee |
| Jordan Lee | Offboarding required |
| Taylor Brooks | No action: contract not expired |
| Casey Rivera | Already disabled |
| Morgan Chen | Review: missing end date |
| Riley Patel | No action: contract not expired |

A second run using September 8, 2026 confirmed that Riley Patel
changed to `Offboarding required`.

```powershell
.\scripts\Get-ContractorReport.ps1 -AsOfDate '2026-09-08'
```

Invalid-date and invalid-account-status handling are implemented
but have not yet been tested.

A missing-column test renamed `EmployeeType` to `EmployeeTyp`.
The script correctly stopped with:
`Missing required CSV column: EmployeeType`.

The original CSV was restored, and a subsequent baseline run
produced the expected contractor results.

## Downloaded Script Troubleshooting

If PowerShell blocks the downloaded script as unsigned, review
its contents before unblocking that specific file:

```powershell
Unblock-File -LiteralPath .\scripts\Get-ContractorReport.ps1
```

This removes the downloaded-file marker; it does not change
the execution policy or override a requirement that all scripts
be signed.

## Limitations

- Decisions rely on the supplied CSV, not live account information.
- Disabled contractors are reported without further end-date checks.
- Complete CSV schema and duplicate-record validation are not yet implemented.
- This is a learning lab, not a production offboarding tool.
- Input validation checks for empty rosters, required columns,
  missing employee IDs, invalid employee types, and duplicate IDs.
  Missing-column handling has been tested; the other validation
  checks have not yet been individually tested.

## Planned Improvements

- Expand validation coverage and add automated tests.
- Generate a separate report containing only actionable findings.
- Add account actions within an isolated test environment.
- Document safeguards before introducing account changes.

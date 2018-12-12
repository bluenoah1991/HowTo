# Run PowerShell prompt as administrator
# execute "Set-ExecutionPolicy UnRestricted"
# Choose A

git add . ; git commit -m "TEMP"
$ChromiumVersionString = 'UnknownVersion'
if ([System.IO.File]::Exists((Resolve-Path .\chrome\VERSION))) {
	$ContentArray = (Get-Content .\chrome\VERSION) -split '='
	$ChromiumVersionString = [String]::Format('{1}.{3}.{5}.{7}', [System.Object[]]$ContentArray)
}
git archive -o ..\Archive-$ChromiumVersionString-$(Get-Date -Format 'yyyyMMddHHmmss').zip HEAD `
	(git diff --name-only HEAD~1)
git reset --mixed HEAD~1

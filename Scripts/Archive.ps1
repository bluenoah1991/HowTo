# Run PowerShell prompt as administrator
# execute "Set-ExecutionPolicy UnRestricted"
# Choose A

git add . ; git commit -m "TEMP"
git archive -o ..\Archive-$(Get-Date -Format 'yyyyMMddHHmmss').zip HEAD `
	(git diff --name-only HEAD~1)
git reset --mixed HEAD~1

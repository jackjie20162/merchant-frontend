Get-ChildItem -Recurse -File 'D:\go_work\simple-admin\merchant-frontend\src' | ForEach-Object { $_.FullName.Replace('D:\go_work\simple-admin\merchant-frontend\src\', '') }

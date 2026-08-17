Get-ChildItem -Recurse -File 'D:\go_work\simple-admin\store-console-frontend\src' | ForEach-Object { $_.FullName.Replace('D:\go_work\simple-admin\store-console-frontend\src\', '') }

Get-ChildItem -Recurse D:\go_work\simple-admin\merchant-frontend\src -File | Where-Object { $_.Extension -in '.vue','.js','.ts' } | ForEach-Object { $_.FullName }

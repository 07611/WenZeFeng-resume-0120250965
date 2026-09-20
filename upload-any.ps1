param([string]$Path)

Add-Type -AssemblyName System.Windows.Forms

if (-not $Path) {
  $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description = "选择要上传的项目文件夹（里面要有 .git）"
  $dialog.ShowNewFolderButton = $false
  $result = $dialog.ShowDialog()
  if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "已取消选择。"
    exit
  }
  $Path = $dialog.SelectedPath
}

Set-Location $Path
Write-Host ""
Write-Host "当前文件夹：$Path"

if (-not (Test-Path (Join-Path $Path ".git"))) {
  Write-Host "错误：这个文件夹不是 Git 仓库（没有 .git 目录），请先 git init 并关联远程仓库。"
  exit
}

$remote = (git remote get-url origin 2>$null)
if (-not $remote) {
  Write-Host "错误：该文件夹没有关联 GitHub 远程仓库 origin。"
  exit
}
Write-Host "远程仓库：$remote"

git add -A
git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
  $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
  git commit -m "update: 项目更新 $stamp"
  Write-Host "正在推送到 GitHub..."
  git push
  Write-Host "推送完成。"
} else {
  Write-Host "没有需要上传的新修改。"
}

if ($remote -match 'github\.com[:/]([^/]+)/([^/.]+)') {
  $user = $matches[1]
  $repo = $matches[2]
  $pages = "https://$user.github.io/$repo/"
  Write-Host ""
  Write-Host "线上地址：$pages"
  Start-Process $pages
} else {
  Write-Host "无法自动识别 GitHub Pages 地址。"
}
Write-Host "完成。"

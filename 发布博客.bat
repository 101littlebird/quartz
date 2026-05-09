@echo off

chcp 65001 >nul

setlocal enabledelayedexpansion

:: ========== 配置区：改成你自己的路径 ==========

set "DRAFT_DIR=D:\obsidianmall\2026blog"

set "PROJECT_DIR=C:\Users\tour1\101littlebird.github.io"

set "CONTENT_DIR=%PROJECT_DIR%\content"

set "BRANCH_NAME=v4"

:: ==============================================

echo ==============================================

echo Quartz 博客一键发布工具

echo ==============================================

echo.

:: 1. 输入要发布的博客目录名

set /p "POST_NAME=请输入要发布的博客目录名（草稿文件夹名）: "

set "DRAFT_POST=%DRAFT_DIR%\%POST_NAME%"

set "TARGET_POST=%CONTENT_DIR%\%POST_NAME%"

:: 检查草稿是否存在

if not exist "%DRAFT_POST%" (

echo ❌ 错误：草稿目录 "%DRAFT_POST%" 不存在！

pause

exit /b 1

)

:: 2. 复制草稿到 content 目录

echo.

echo 🔄 正在复制草稿到 content 目录...

xcopy "%DRAFT_POST%" "%TARGET_POST%" /E /I /Y /Q

if %errorlevel% neq 0 (

echo ❌ 错误：复制文件失败！

pause

exit /b 1

)

echo ✅ 复制完成！

:: 3. 进入项目目录，提交并推送到 GitHub

echo.

echo 🚀 正在提交并推送到 GitHub...

cd /d "%PROJECT_DIR%"

:: 添加所有变更

git add .

:: 检查是否有变更需要提交

git diff --cached --quiet

if %errorlevel% equ 0 (

echo ⚠️ 没有新的变更需要提交，退出发布。

pause

exit /b 0

)

:: 提交

git commit -m "发布新博客: %POST_NAME%"

if %errorlevel% neq 0 (

echo ❌ 错误：提交失败！

pause

exit /b 1

)

:: 推送到远程分支

git push origin %BRANCH_NAME%

if %errorlevel% neq 0 (

echo ❌ 错误：推送到 GitHub 失败！

pause

exit /b 1

)

echo.

echo ==============================================

echo ✅ 发布成功！

echo 已推送至 GitHub 分支 %BRANCH_NAME%，Cloudflare Pages 将自动开始构建。

echo 等待几分钟后，访问你的博客查看更新。

echo ==============================================

pause

endlocal
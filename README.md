# 营销反作弊系统原型

本仓库用于保存和发布营销反作弊系统 HTML 原型。

## 文件说明

- `index.html`：仓库访问入口，自动跳转至主原型。
- `营销反作弊系统原型.html`：当前主原型文件。
- `scripts/sync-prototype.ps1`：检测受控文件变化并提交、同步至 GitHub。
- `scripts/install-auto-sync.ps1`：在 Windows 中安装每 5 分钟执行一次的自动同步任务。

## 同步范围

仓库采用文件白名单，只同步上述原型及维护文件。同目录中的 PRD、截图、表格和其他原型不会被提交。

## 自动同步

本机计划任务 `MarketingAntiCheatPrototypeSync` 每 5 分钟检查一次。仅在受控文件发生变化时创建提交并推送；未发生变化时不会产生空提交。


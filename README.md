# DeepSeek Harness Windows Launcher

一个非官方的 Windows 桌面启动器，让
[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 可以像普通应用一样启动。

![Launcher icon](assets/DeepSeek-Harness-preview.png)

> [!IMPORTANT]
> 本项目不是 DeepSeek 官方项目，也不包含 DeepSeek Harness 本体。

## 功能

- 双击桌面快捷方式，静默启动 `dsh web`
- 自动等待本地服务就绪并打开浏览器
- 检测 `http://127.0.0.1:3080/`，避免重复启动服务
- 把启动输出写入 `%USERPROFILE%\.dsh\launcher\dsh-web.log`
- 不需要修改系统级 PowerShell 执行策略
- 提供独立卸载脚本，不会删除 DeepSeek Harness 或用户配置

## 环境要求

- Windows 10 或 Windows 11
- Node.js
- DeepSeek Harness：`npm install --global @deepseek-ai/dsh`

## 安装

克隆仓库后，在 PowerShell 中运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install.ps1
```

如果尚未安装 DeepSeek Harness，可以让安装脚本一并安装：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install.ps1 -InstallDeepSeekHarness
```

安装完成后，桌面会出现 **DeepSeek Harness** 快捷方式。

## 使用

双击桌面的 **DeepSeek Harness**。启动器会：

1. 检查端口 `3080` 上的 Web UI 是否已响应。
2. 如果没有响应，在隐藏窗口中运行 `dsh.cmd web`。
3. 最多等待 30 秒。
4. 使用默认浏览器打开 <http://127.0.0.1:3080/>。

DeepSeek Harness 以桌面快捷方式的“起始位置”为默认文件系统位置；安装脚本将其设置为你的 Documents 目录。进入 Web UI 后仍需选择实际工作区。

关闭浏览器标签页不会结束后台服务。再次双击快捷方式只会重新打开页面，不会重复启动服务。

## 卸载启动器

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Uninstall.ps1
```

连同启动日志一起删除：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Uninstall.ps1 -RemoveLog
```

卸载脚本只删除桌面快捷方式和 `%USERPROFILE%\.dsh\launcher` 中属于本项目的文件。它不会卸载 `@deepseek-ai/dsh`，也不会删除其他 `.dsh` 配置。

## 验证项目

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test.ps1
```

验证内容包括 PowerShell 语法、VBScript 语法、必需文件以及 ICO 文件结构。

## 实现原理

Windows 快捷方式启动 `wscript.exe`，由 VBScript 在无终端窗口的情况下管理 `dsh.cmd web`。启动器使用 Windows 自带的 WinHTTP 组件检查服务状态，因此没有额外运行时依赖。

项目刻意不修改 `Set-ExecutionPolicy`。安装命令中的 `-ExecutionPolicy Bypass` 只对该次 PowerShell 进程生效。

## 安全说明

- 服务只绑定到 `127.0.0.1:3080`。
- API Key 仍由 DeepSeek Harness 自身管理；本启动器不会读取或保存密钥。
- 启动日志可能包含 DeepSeek Harness 输出。分享日志前请自行检查敏感信息。
- 建议在运行安装脚本前先阅读脚本内容。

## 许可证

启动器代码使用 [MIT License](LICENSE)。图标归属和上游许可证见
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

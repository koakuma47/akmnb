# AKM Launcher 代码签名指南

> 说明：**可信证书必须自行购买**（约 ¥1000-4000/年），本仓库只提供签名脚本与 CI 接入，
> 不含任何证书文件。

## 1. 为什么需要签名

Windows SmartScreen 与部分杀毒软件会对「未签名 + PyInstaller 打包」的 EXE 报警。
签名后：

- SmartScreen 不再提示「未知发布者」（信誉需时间累积）
- EXE 属性页显示你的公司/个人名
- 用户可以校验发布者，减少「是不是病毒」的疑虑

## 2. 证书类型

| 类型 | 价格量级 | 特点 |
| --- | --- | --- |
| OV 代码签名 | 便宜 | 需要企业/个体资质审核，信誉累积较慢 |
| EV 代码签名 | 贵 | 硬件令牌（USB），SmartScreen 立即信任 |
| 自签名 | 免费 | **只对导入了证书的机器有效**，公开分发无意义，仅用于本地测试 |

购买渠道：DigiCert、Sectigo、SSL.com、Certum 等，或国内代理商（如 WoSign 系）。
交付形式通常是 `.pfx` 文件（OV）或 USB Token（EV，需要厂商工具导出 pfx 或改用云签名）。

## 3. 本地签名

```powershell
# 1) 签名（PFX 方式）
powershell -ExecutionPolicy Bypass -File sign.ps1 `
    -FilePath AKM_Launcher.exe `
    -PfxPath D:\cert\akm.pfx `
    -PfxPassword "你的密码"

# 2) 构建时一步完成（build.ps1 会先构建再签名、再跑自检、再打包）
powershell -ExecutionPolicy Bypass -File build.ps1 -Sign `
    -PfxPath D:\cert\akm.pfx -PfxPassword "你的密码"
```

脚本会调用 `signtool sign /fd SHA256 /td SHA256 /tr http://timestamp.digicert.com`
并自动做 `signtool verify /pa`。找不到 signtool 时请安装
**Windows SDK（Signing Tools for Desktop Apps）**。

## 4. 本地测试用自签名证书

```powershell
powershell -ExecutionPolicy Bypass -File sign.ps1 -CreateSelfSigned -OutPfx test.pfx -OutPassword 123456
powershell -ExecutionPolicy Bypass -File sign.ps1 -FilePath AKM_Launcher.exe -PfxPath test.pfx -PfxPassword 123456
# 让本机信任它（仅测试机执行一次）
Import-PfxCertificate -FilePath test.pfx -CertStoreLocation Cert:\LocalMachine\Root -Password (ConvertTo-SecureString 123456 -AsPlainText -Force)
```

## 5. GitHub Actions 自动签名

在仓库 **Settings → Secrets and variables → Actions** 添加：

| Secret | 内容 |
| --- | --- |
| `WINDOWS_CERT_PFX_BASE64` | pfx 文件的 base64（见下） |
| `WINDOWS_CERT_PASSWORD` | pfx 密码 |

生成 base64：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("D:\cert\akm.pfx")) | Set-Clipboard
```

没有配置这两个 Secret 时，workflow 会打印
`no WINDOWS_CERT_PFX_BASE64 secret - skipping signing` 并继续出包（不签名）。

## 6. 注意事项

- **EV 证书（USB Token）无法直接塞进 CI**，需要厂商的云签名服务
  （DigiCert KeyLocker / SSL.com eSigner），此时把 `sign.ps1` 的 signtool 调用
  换成厂商 CLI 即可。
- 证书文件与密码**绝不提交到仓库**（`.gitignore` 已排除 `*.pfx`，建议再加 `*.p12`）。
- 签名要在 **zip 打包之前**完成，`build.ps1` / CI 都遵循这个顺序。
- 时间戳服务器很重要：证书过期后，带时间戳的旧版本仍然有效。

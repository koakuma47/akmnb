# 上传到 GitHub（隐私已处理）

这个文件夹是**可以直接公开**的源码副本，由作者本地的项目目录筛出来生成。

## 1. 里面有什么

```
win1_gui.py             主程序（单文件，24k+ 行）
lang/*.json             五套语言包（zh / en / ja / ru / ar）
akm_icon.ico            应用图标（exe 和窗口都用它）
build.ps1 / sign.ps1    本地打包 / 代码签名脚本
SIGNING.md              签名说明（含 pfx 占位示例）
update.example.json     自动更新清单模板
mod_alias.json          中文名 → Modrinth slug 别名表
tools/lang_extract.py   语言包提取小工具
.github/workflows/build.yml  GitHub Actions 自动打包（打 tag 触发）
README.md / RELEASE_NOTES.txt  说明与更新日志
LICENSE                 MIT
.gitignore              已加固
.gitattributes          保持字节原样（* -text，不转换换行符）
PUBLISH.md              本文件
```

## 2. 特意**没有**包含（隐私 / 私有内容）

| 文件 | 为什么不上传 |
|---|---|
| `config.json` | 本机游戏目录、内存设置、client_id 等本地配置 |
| `auth.json` | **微软 refresh_token / access_token**，等同于账号钥匙 |
| `logs/`、`installer.log` | 本地路径、报错堆栈 |
| `.minecraft/`、`release/`、`*.exe`、`icons/` | 游戏文件、构建产物、图标缓存 |
| `donate.png` | **补给站收款码（个人收款信息）** |
| `qr_payload.py` | 收款码的加密负载 + 解密密钥 |
| `tubiao.png` | 未使用的临时图 |
| `*.pfx / *.p12 / *.pem / *.key` | 代码签名证书与私钥 |

源码级脱敏三处：

1. `AFDIAN_URL` → `https://afdian.net/a/your-id`（原来的个人补给站地址已替换）
2. README 里所有本地绝对路径 → `.` / 相对路径
3. 收款码缺失时程序自动降级为「收款码未配置」，其它功能不受影响
   （已跑 `import win1_gui` 验证：`import ok B0.5`）

> 保留项：`MS_DEFAULT_CLIENT_ID = "00000000402b5328"` 是 Minecraft 设备码登录用的
> **公开客户端 ID**（不是密钥，很多第三方启动器都用它），删掉会导致正版登录不可用；
> 想换成自己的应用可以在 `config.json` 的 `client_id` 覆盖。
> `win1_gui.py` 里 `C:\Program Files\Eclipse Adoptium\...` 这类是 Java 的标准安装路径，
> 用来找系统 Java，不含任何个人信息。

## 3. 上传方式（任选一种）

### 方式 A：装了 Git（推荐，已实测通过）

Git for Windows 2.56.0（含 Git Credential Manager）安装位置：
`C:\Program Files\Git\cmd\git.exe`，新开的终端里直接 `git --version` 就能用。

```powershell
cd <这个文件夹>
git init -b main
git config core.autocrlf false          # 关键：不做换行符转换，仓库字节 = 本地字节
git config user.name  "<用户名>"
git config user.email "<用户名>@users.noreply.github.com"
git add .
git commit -m "AKM Launcher B0.5 source"
git remote add origin https://github.com/<用户名>/<仓库名>.git
git push -u origin main
```

仓库里已带 `.gitattributes`（内容 `* -text`），以后修改也不会被自动改换行符，
所以 `win1_gui.py` 的 SHA256 和本地完全一致（B0.5 为 `4BCE71E1…E551E`）。

如果远端已经有一个 `Initial commit`（网页上勾了 README 建库），push 会被拒
（`! [rejected] main -> main (fetch first)`），按下面处理，保留一个干净的历史：

```powershell
git fetch origin
git reset --soft origin/main            # HEAD 落到远端那次提交，本地文件不动
git commit -m "AKM Launcher B0.5 source"
git push -u origin main
```

第一次 push 若没凭据会弹浏览器登录（GCM）；本机已缓存
`git:https://github.com` 凭据，所以直接就能推。也可以改用 PAT：

```powershell
git remote set-url origin https://<用户名>:<PAT>@github.com/<用户名>/<仓库名>.git
```

推完自检（应看到 20 个文件、没有 `auth.json` / `config.json` / `donate.png`）：

```powershell
git ls-tree -r --name-only HEAD
```

### 方式 B：没装 Git，用 GitHub API（脚本已备好）

1. GitHub → Settings → Developer settings → Personal access tokens →
   Fine-grained token，勾 **Contents: Read and write**
   （想让它自动建仓库再加 **Administration: Read and write**）
2. 在**你自己的终端**里设置环境变量（别贴到聊天里）：

```powershell
$env:GITHUB_TOKEN = "github_pat_xxx"
$env:GITHUB_OWNER = "你的用户名"
$env:GITHUB_REPO  = "akm-launcher"
```

3. 先干跑看清单，再真跑：

```powershell
python "<项目目录>\tools\gh_push.py"            # 只列文件，不写 GitHub
python "<项目目录>\tools\gh_push.py" --apply    # 建仓库 + 逐个上传
```

脚本放在私有目录（不在本仓库里）。默认建成 **private**，加 `--public` 才是公开仓库，
方便你先自己检查一遍。

### 方式 C：让 AI 帮你传

把仓库地址给我，我帮你核对上传后的文件清单、大小是否一致，再帮你加 tag / 写 Release。
PAT 建议你留本地自己跑方式 B。

## 4. 之后怎么更新

改了主程序之后（这个文件夹已经是 git 仓库，直接增量提交）：

```powershell
cd <这个文件夹>
python "<私有项目目录>\_publish_build.py"       # 重新生成脱敏副本（覆盖本目录文件）
git status                                      # 看一眼改了哪些
git add -A
git commit -m "update: 改了什么"
git push                                        # 首次已 -u，之后不用带 origin main
```

## 5. 上传后建议做的 3 件事

1. 仓库 Settings 里确认可见性（先 Private 自测更稳）
2. 打个 tag 试跑 Actions：`git tag vB0.5 && git push origin vB0.5`
   （workflow 会自动打包 exe 并生成 Release；没配签名 secret 就跳过签名）
3. 如果以前误传过 `auth.json`，立刻去微软账号页面吊销令牌并重新登录

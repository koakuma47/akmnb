其实理论上大肥鱼才是作，所以你能看出来下面的内容ai味爆棚

# AKM Launcher (Adaptive Kinetic Minecraft) B0.5

1985 Windows 1.0 工业风格的单人 Minecraft 启动器，位于 `.`。
GUI 仅使用 Python 标准库 `tkinter`，启动引擎使用可选的
`minecraft-launcher-lib`。

## 运行

**方式一：双击 EXE（推荐）**

```text
.\AKM_Launcher.exe
```

**方式二：源码运行**

```bat
cd /d .
python win1_gui.py
```

无窗口自检（检查文件初始化、词库、Modrinth / Fabric 联通与依赖）：

```bat
python win1_gui.py --selftest
```

打包 EXE 的自检结果会写入 EXE 同目录的 `logs\selftest.log`，不弹控制台。

依赖（源码运行需要；EXE 已内置 `minecraft-launcher-lib`）：

```bat
python -m pip install --upgrade minecraft-launcher-lib
```

启动 Minecraft 1.21.1 需要 **Java 21**。若自动检测失败，在 `config.json`
的 `java` 字段填写 `javaw.exe` 的绝对路径。

## 默认游戏目录（PCL 风格：启动器自带 .minecraft）

首次运行会在**启动器同目录**自动创建并补齐标准目录，玩家下载的版本直接进这里，
不需要手动选路径：

```text
.\
├─ AKM_Launcher.exe
├─ config.json
└─ .minecraft\            ← 所有版本 / 模组 / 资源都落在这里
   ├─ versions\           # 下载的原版 / Forge / NeoForge / Fabric / Quilt
   ├─ libraries\          # 依赖库
   ├─ assets\             # 原版资源
   ├─ runtime\            # Mojang 运行时 + 内置 akm-java-*
   ├─ mods\               # 模组（未开启版本隔离时）
   ├─ saves\ config\ resourcepacks\ shaderpacks\ screenshots\
   ├─ logs\ crash-reports\ defaultconfigs\
```

- 默认路径由 `_default_minecraft_dir()` 返回 `<EXE 所在目录>\.minecraft`，
  即 `config.json` 的 `minecraft_dir` 默认值；打包 EXE 里 `BASE_DIR` 就是 EXE 目录。
- `bootstrap_files()` 每次启动都会 `ensure_dir` 上面这些子目录（缺哪个补哪个），
  所以第一次打开就是干净可用的空目录，随后 `[下载原版]` / `[模组加载器]` /
  模组装配都会直接写进去。
- 把整个启动器文件夹复制给别人，对方的游戏文件也会落在自己的 `.minecraft`，
  不会污染系统盘其它位置。
- 想用别的目录：主页 `VERSION // …` 标题右侧 `[ 浏览 ]` 选择任意
  `.minecraft`（或其中的 `versions` 文件夹），会写回 `config.json`。
- 想恢复出厂：删掉 `.minecraft` 与 `config.json`，再次启动会自动重建。

## 语言设置（v1.6rc1 新增，v1.7rc1 外置语言包 + 阿拉伯语排版）

`设置 → 语言`，可选 **简体中文 / English / 日本語 / Русский / العربية**，
选择后写入 `config.json` 的 `language` 字段：

- 会询问是否立即重建界面；确认后**同一个进程里**直接重建窗口（约 0.2 秒），不启动第二个进程
- 选择「暂不重启」时菜单立即更新，其余窗口下次打开时生效
- 有下载 / 启动任务在跑时只保存设置，等任务结束后重启生效

### 外置语言包（`lang/*.json`）

所有文案都在启动器目录下的 `lang/` 里，**不用改代码就能加语种**：

```
lang/
  zh.json   en.json   ja.json   ru.json   ar.json
```

```jsonc
{
  "code": "en",
  "name": "English",
  "version": 2,
  "strings":  { "menu.game": "Game", "inst.start": "[ Install ]", "...": "..." },
  "phrases":  { "确定": "OK", "实例 {0}": "Instances {0}", "...": "..." }
}
```

- `strings`：`tr("key")` 用的键值表（菜单、按钮、安装/下载窗口）
- `phrases`：**中文原文 → 译文**，用于覆盖所有对话框里的散装中文；
  `{0}` / `{1}` 占位符会自动匹配（如 `实例 {0}` → `Instances 3`）
- 双语标题按两半分别翻译：`工具 // OptiFine` → `Tools // OptiFine`
- 查找顺序：启动器目录 `lang/` → 打包内置 `lang/` → 代码内置表 → 原文
- 菜单里的三个新入口：`打开语言包目录` / `重新加载语言包` / `导出未翻译文本...`
  （导出当前语言还缺哪些中文，填好值放进 `phrases` 即生效）
- 命令行核对覆盖率：`python tools/lang_extract.py`

### 中文模式不再有英文标题

中文下所有 `ENGLISH // 中文` 标题只显示中文（`JAVA RUNTIME // 内置 Java`
→ `内置 Java`），窗口标题为 `AKM 启动器 // …`。

### 阿拉伯语排版（v1.7rc1）

Tk 本身不支持阿拉伯语的连写与从右往左排版，启动器内置了一个轻量整形器：

- 按相邻字母选择 **isolated / final / initial / medial** 四种字形
- `لا` 等 lam-alef 连字合并
- 按 RTL 规则做视觉重排，同时保持 `MC 1.20.1`、`Java 21` 这类拉丁/数字片段
  内部顺序不变，括号/Bracket 自动镜像
- 只对阿拉伯语生效，其它语言零开销

**覆盖面**：英文模式下主窗口 + 常见对话框共 159 条可见文案，只有 6 条仍是中文
（其中 2 条是语言名称本身），即约 96% 可见文案已翻译；`en` 语言包内含
116 条 `phrases` + 87 条 `strings`。ja / ru / ar 使用同一套键与短语表。


## 一键安装：原版 + 模组加载器（v1.5rc5 新增）

入口：主页 `[ 下载 / 安装 ]`、`[ 模组加载器 ]`，或 `游戏 → 下载 / 安装游戏（原版 + 加载器）...`

一个窗口把「下原版」和「装加载器」合成一次操作，不会再下两次：

1. 选版本（列表或直接输入 `1.21.4`）
2. 选 `INSTALL CONTENT // 安装内容`：**仅原版 / Fabric / Forge / NeoForge / Quilt**
3. 选加载器版本（默认 `[AUTO]` = 最新，右侧会拉取该 MC 版本可用的全部加载器版本）
4. 点 `[ 开始安装 ]`

执行顺序（一个任务、一个取消按钮、一份进度）：

```
原版文件：version JSON → client.jar → libraries → asset index → assets → logging
        ↓ 直接复用上面下好的文件
加载器：Forge/NeoForge 安装器（或 Fabric/Quilt 版本 JSON+库）
        ↓
写 config.json: launch_version = 加载器版本 id，可直接点火
```

- **不会重复下载**：原版文件存在时按大小/SHA1 直接跳过；加载器的库装进同一个
  `.minecraft/libraries`，安装器也直接读刚写好的 `versions/<mc>/<mc>.json`
- 装完自动把 `launch_version` 锁到加载器版本 id（如 `fabric-1.21.4-0.16.9`），
  主页版本栏直接选中，点 `[ IGNITE 点火起飞 ]` 就能进游戏
- 只想要原版就选「仅原版」，行为和以前的原版下载一致

### 下载详情窗口（看正在下什么）

开始安装会自动弹出（`config.json` 的 `download_detail` 设为 `false` 可关掉），
也可以随时用 `[ 下载详情 ]` 按钮或 `游戏 → 下载详情窗口（看正在下什么）...` 打开：

```
TASK // 1.21.4 + Fabric
PHASE // LIBRARIES   37 / 128   速度 2.4 MB/s   已用 00:21   新下载 96 / 缓存 31 / 失败 0
──────────────────────────────────────────────────────────────────────
[##############]  72%       1.2 MB/1.6 MB   cloth-config-11.1.136.jar
[############--]  41%       3.1 MB/7.5 MB   fabric-loader-0.16.9.jar
...
另外 21 个文件在后台并发下载
最近完成 //
  [DONE   ] client.jar                                             23.1 MB
  [CACHED ] indexes/5.json                                        409.6 KB
```

- 每个正在传输的文件一行：**迷你进度条 + 百分比 + 已下/总大小 + 文件名**
- 资源对象显示 index 里的真实名字（`minecraft/sounds/...`），不是一堆哈希
- 顶部汇总：当前阶段、阶段进度、实时速度、耗时、新下载/缓存/失败数量
- `[ 复制清单 ]` 把当前列表复制到剪贴板，方便贴给别人看哪里卡住
- 关闭窗口不影响下载；下载中随时可以再开


### 下载源与校验（原版文件）

- 主页 `[ 下载 / 安装 ]`、`[ 模组加载器 ]`，或 `游戏 → 下载 / 安装游戏（原版 + 加载器）...`

功能：

- 自动获取 Mojang 版本清单，列表显示 `REL / SNAP / BETA / ALPHA` 与发布日期；
  也可以直接在版本号输入框填写任意版本。
- 三种下载源（**默认镜像优先**）：
  - **镜像优先（推荐）**：BMCLAPI 优先，官方 Mojang 兜底 —— 国内速度最快，
    新装默认就是它；
  - **自动**：与镜像优先相同（BMCLAPI 优先，官方兜底）；
  - **官方优先**：官方 Mojang 优先，BMCLAPI 兜底。
  可在安装窗口里临时切换，也可在 `设置 -> 下载源` 或设置页里永久修改。
- 安装内容：版本 JSON、客户端 jar、libraries、natives、asset index、
  assets objects、logging config；客户端 / 库 / 资源索引 / 资源对象均做
  SHA1 校验。
- 资源索引等小型元数据固定使用官方源；客户端、库与资源对象按所选源优先，
  失败会自动切换另一源。
- **并发 + 连接复用（v1.5rc4 提速）**：库 12 路、资源 24 路并发；每个工作线程
  复用一条 TLS 长连接（keep-alive），不再为每个小文件重新握手；单文件超时
  25s（库 60s / 客户端 90s），卡住的镜像连接会很快被放弃并切到另一个源。
- **镜像资源地址修正（v1.5rc4）**：BMCLAPI 的资源对象路径是
  `bmclapi2.bangbang93.com/assets/<前两位>/<hash>`；旧版本写成了
  `/assets/<hash>`，导致 3600 多个资源每个都先吃一个 404、再重试一次、
  再等 0.6 秒才回落官方源 —— 这是「下载原版特别慢」的主要原因。
- **源健康度（v1.5rc4）**：某个源连续失败 6 次会被本次安装跳过，
  不再对 3600 个文件重复撞同一个坏源。
- **微文件提速（v1.6rc1）**：BMCLAPI 对每个资源对象都会回一个 302，跳到
  随机的 `bmclapiNN` CDN 节点，而且每个文件都换节点 —— 一个几百字节的资源
  也要重新 DNS + TLS 握手，实测 ~1.0s/文件。现在启动器会**记住 302 指向的
  节点**，之后直接请求 `节点/download/<hash>?name=<hash>`，跳过 302 并且
  每个线程复用一条长连接：实测 300 个微文件 7.8 秒（25.9 ms/个，38.6 个/秒，
  0 失败、0 回落官方）。
- **临时文件名带线程号**：`<文件>.<线程>.part`，避免同一资源被并发引用时
  两个线程抢同一个 `.part`（Windows 会报「另一个程序正在使用此文件」）。
- 状态栏会显示实时速度：`ASSETS // 1200 / 3598  // 42.5/s`、
  `CLIENT JAR // 6.2 MB / 22.1 MB  // 1.8 MB/s`。
- 安装成功后写入 `versions\<id>\.akm_vanilla.json`，主页版本列表自动选中
  该版本；之后点火会直接使用 AKM 安装的档案，跳过重复安装。
- 不额外下载 Java 运行时，使用系统 Java 21；也可在 `config.json` 的
  `java` 字段指定 `javaw.exe`。


## 工具箱与外观设置

### 顶栏横幅（v1.7rc9 重绘）

```text
┌─ ▣ AKM LAUNCHER │ MINECRAFT 启动器 // 1985 风格控制台 ┈┈┈┈┈┈┈┈ [ B0.1 ] ─┐
```

- 高度 34 → 40，5 段竖向渐变（`#0A6C6C → #0E7E7E → #0A6C6C`）+ 左上高光、
  右下阴影的立体描边，像 1985 的窗口标题栏，不再是一条纯青色硬边
- 左侧「方框套实心块」窗口标记，标题后是亮线 + 暗线组成的雕刻分隔线，
  副标题用略暗的白（`#E9FCFC`）区分层级
- 副标题到右侧版本徽标之间有一条点状引导线；版本号从空心描边框改成
  深青填充 + 白描边的小徽标
- 底部保留 2px 白色搁板 + 1px 黑线
- 换背景壁纸后：渐变和立体描边自动隐藏、文字与徽标转白，整条横幅透出壁纸；
  清除壁纸后自动恢复渐变

### 工具箱（`工具` 菜单）

顶栏只保留 5 个菜单：`游戏` / `账号` / `工具` / `设置` / `关于`。
`工具 -> 打开工具箱页面...` 可打开资源导航页面，`常用网站` 子菜单可直接
跳到单个站点。

收录站点按类别整理：

| 类别 | 站点 |
| --- | --- |
| 百科 | MC百科、Minecraft Wiki 中文 |
| 模组 | Modrinth、CurseForge |
| 整合包 | Modrinth Modpacks、CurseForge Modpacks |
| 官方 | Minecraft 官网、官方下载、Mojang |
| 加载器 | Forge、NeoForge、Fabric、Quilt |
| 工具 | OptiFine |
| 社区 | Planet Minecraft、MineBBS |

页面支持关键字搜索（如 `modrinth`、`forge`、`百科`）、双击或回车打开、
`[ 复制链接 ]` 复制地址。链接使用系统默认浏览器打开，启动器本身不下载
站点内容。

### 设置与颜色

入口：顶栏 `[设置] -> [外观 / 背景 / 内存...]`。设置页提供：

- **界面风格（B0.5，矢量风测试中）**：`[ 1985 复古 ]`（默认）/ `[ 矢量风（测试） ]`，
  矢量风另有 `[ 靛蓝 ] [ 极光绿 ] [ 晚霞橙 ]` 三套配色，点一下立即重绘整个窗口
  （详见下节「界面风格」）
- 六种预设：**经典青蓝**、**EGA 蓝**、**琥珀橙**、**森林绿**、**酒红**、
  **石板灰**；
- 四个可自定义颜色槽：主强调色、主背景色、次背景色、文字颜色；
  可直接输入 `#RRGGBB`，或点击 `[ 选择 ]` 使用系统调色板；
- 实时预览与 `[ 应用主题 ]`：立即重绘主窗口、菜单、状态栏、列表选中色
  与后续打开的对话框，并写入 `config.json`；
- `[ 恢复默认 ]` 恢复经典青蓝；`[设置] -> [恢复默认主题]` 可直接重置。

主题保存在 `config.json` 的 `theme` 对象中，重启后自动加载：

```json
"theme": {
  "surface": "#FFFFFF",
  "secondary": "#D4D0C8",
  "accent": "#008080",
  "text": "#000000"
}
```

### 背景图片（自定义壁纸）

**主打入口**：`[设置] -> [外观 / 背景 / 内存...]` 最上面的
`WALLPAPER // 启动器背景（铺满整个窗口）` 区域（带缩略图预览）。
也可以走菜单 `[设置] -> [导入背景图片...] / [清除背景图片]`。

支持的格式：**PNG / JPG / BMP / GIF / WEBP / TIFF**（走 Windows 自带
GDI+ 解码，不需要装任何第三方库）。导入后：

- **整张图铺满整个窗口**：图片画在窗口最底层，标题条、左右两栏之间的
  留白、左栏下方的「桌面区」、底部横条全部透出壁纸；
- 标题条本身也换成同一张图的暗化切片，文字直接画在图上（带压暗保证可读）；
- 左栏控制台与右栏战备架变成「浮在壁纸上的窗口」，高度按内容收缩，
  所以壁纸始终占窗口 30% 以上的可见面积；设了「面板透明」后两栏本身也是
  半透明磨砂玻璃，壁纸会从面板缝隙里透出来；
- 两种显示方式：**铺满裁切**（默认，不留黑边）/ **完整显示**（整张图都看得到，
  按主背景色留白）；
- **压暗 0-60%**：照片太花看不清字时往上拉，只压暗壁纸，不影响界面文字；
- **面板透明 0-60%（v1.7rc4 新增，默认 45%）**：左右两栏变成半透明磨砂玻璃，
  壁纸从面板的留白、按钮与列表的缝隙里继续透出来，不再是一整块白板；
- 拉伸窗口会自动重新裁切/缩放（约 0.4 秒防抖），渲染在后台线程，不卡界面；
- 配置写进 `config.json` 的 `wallpaper` / `wallpaper_fit` / `wallpaper_dim` /
  `panel_alpha`，下次启动自动加载；图片被删或损坏时自动回落纯白背景并在状态栏提示。

> 只用标准库实现：`ctypes` 调 GDI+ 做解码与高质量双三次缩放，
> `zlib` 现写 PNG，再交给 `tk.PhotoImage`，所以 EXE 体积几乎不变。

### 半透明面板是怎么做的（v1.7rc4）

Tk 控件本身没有透明度，所以这里用「磨砂玻璃」模拟：

1. 每个面板下面垫一张**同区域的壁纸切片**（`src_box` 精确对齐整窗壁纸，
   拉伸窗口时按面板尺寸重新裁切，缝隙里的贴图与桌面完全对得上）；
2. 切片上再糊一层白色遮罩，透明比例就是设置里的「面板透明」（0 = 原来的纯白面板）；
3. 面板里的白底控件按**所在位置**取切片上的颜色重新上色（同色钳制 ±26），
   所以整栏颜色跟着壁纸的明暗/色调自然过渡，而不是一块死白；
4. 按钮的 hover 变青色，鼠标移开后回到它自己那块玻璃色，不会闪回白色；
5. 调到 0 会立刻恢复原来的纯白面板；清除背景时同样全部回滚。

> 文字始终保持黑色，遮罩保证背景再花也能看清；GDI+ 渲染加了锁，
> 设置页预览和后台重绘不会同时跑（并发 GDI+ 启动/关闭会拖崩进程）。


## 界面风格（B0.5：矢量风测试中）

入口：`[设置] -> [外观 / 背景 / 内存...]` 里的 **`STYLE // 界面风格`** 一行。

```text
[ 1985 复古 * ]   [ 矢量风（测试） ]
矢量风配色   [ 靛蓝 * ]  [ 极光绿 ]  [ 晚霞橙 ]
```

- **1985 复古**（默认）：黑边方块、纯色标题条、Consolas 等宽字体，原来的样子
- **矢量风（测试）**：
  - 左右两栏变成 **圆角卡片**（Canvas 平滑多边形 + 柔和阴影 + 1px 细边），
    页面底色和卡片底色分开，窗口默认尺寸提到 1040×720
  - 按钮 **去掉黑框** 变成扁平块，鼠标悬停整块填强调色
  - 顶栏换成 **圆角 hero 条**：圆角图标 + 大标题 + 半透明分隔线 + 圆角药丸版本徽标
  - `启动控制` / `模组战备架` 这类小标题改成纯色文字，不再画黑框
  - 输入框改成 1px 细边框，聚焦时边框变强调色
  - 正文/按钮字体切到 **Microsoft YaHei UI**（找不到就退 Segoe UI / Verdana）
  - 三套配色：靛蓝 `#3B62F6` / 极光绿 `#0E9F6E` / 晚霞橙 `#E8590C`
- **切换即时生效**：颜色、边框、字体、横幅、卡片全部就地重绘，不用重启；
  选择写入 `config.json` 的 `ui_style`（`retro` / `vector`）和 `ui_style_palette`
- **测试阶段说明**：
  - 只用 tkinter 自己的 Canvas 绘制（没有引入第三方库），圆角是平滑多边形，
    不是位图抗锯齿，贴近看会有 1px 的锯齿
  - 热切换时按钮宽度仍按旧字体算，重启一次启动器后完全对齐
  - 换过壁纸时卡片会压在壁纸上（和磨砂玻璃面板叠加），觉得乱就把「面板透明」调 0
  - 随时点 `[ 1985 复古 ]` 切回，所有边框/字体逐项还原


## 主流启动器同款功能（v1.4b6 新增）

这一版把 PCL2 / HMCL / Prism 常见的能力补了进来，并且都做进了现有界面：

| 功能 | 位置 | 说明 |
| --- | --- | --- |
| **账号皮肤头像** | 左栏身份区 64×64 | 按 UUID 拉取正版皮肤头（mc-heads → Crafatar → Minotar 三级兜底），拉不到就用名字生成像素脸；点头像直接打开账号库 |
| **每实例游玩时长** | 版本列表 / 版本标题 | 启动时开始计时，退出后累加进 `config.json` 的 `instances`；列表行显示 `· 3h20m`，标题显示 `累计 … · 上次 …` |
| **实例 / 总时长统计** | 底部状态栏 | `实例 2` `已玩 12h` 实时统计（含当前 MC 版本与加载器） |
| **真实进度条** | 底部状态栏 | 安装核心 / 加载器 / 资源时显示百分比进度条，任务结束自动隐藏 |
| **下载测速** | 底部状态栏右侧 | 所有下载共享字节计数器，实时显示 `1.2 MB/s`，空闲自动隐藏 |
| **JVM 参数自定义** | 设置 → `JVM // 启动参数` | 支持任意 `-XX:` 参数，内置「G1 平衡（推荐）」「低配 / 4G 以下」两个预设，追加在 `-Xms/-Xmx` 之后 |
| **崩溃报告分析** | 工具 → 崩溃报告分析 | 自动读最新 `crash-reports/*.txt`，识别内存不足 / Java 版本 / 缺前置 / Mixin 冲突 / 重复模组 / 显卡问题，给出中文建议 + 关键行 + 导出复制；游戏崩溃弹窗里也会主动问一句 |
| **存档管理** | 工具 → 存档管理 | 列出存档（大小 / 最近修改），一键 `备份所选`（打包到 `.minecraft\akm-backups\`）、打开所选、打开目录 |

这些都不需要额外依赖：头像用 `urllib` + Tk 自带 PNG 解码，测速只在 `download_file` 里加了一行计数器。

## 实例卡片墙 / 模组更新 / 深色主题（v1.5rc1 新增）

### 实例卡片墙（游戏 → 实例管理）

- 每个已安装版本是一张卡片：像素方块缩略图、版本 id、`加载器 · MC 版本 · 模组数 · 占用空间`、`已玩 xx · 上次 …`
- 卡片按钮：`[ 启动 ]`（切到该实例并立刻点火）、`[ 打开 ]`、`[ 复制 ]`
- `[ 复制 ]` 会整目录复制 `versions/<id>` → 新名字，并自动重写版本 JSON 的 `id`、把 `<id>.json` / `<id>.jar` 改成新名字（**一键复制实例**）
- 顶部汇总：`N 个实例 · 总游玩 X`，支持鼠标滚轮滚动、3 列自适应

### 模组更新检测（游戏 → 模组更新检测）

- 读取当前生效的 `mods\*.jar`，逐个算 **SHA1**，批量 POST 到 Modrinth
  `version_files/update`（带上当前加载器与 MC 版本）
- 列表显示 `[可更新] 文件名 -> 新版本号 (加载器)` / `[已最新]`
- `[ 更新所选 ]` / `[ 全部更新 ]`：下载新 jar → 删除旧 jar → 自动重新检测
- 未上架 Modrinth 的本地模组会显示 `[已最新]`，不会被误删

### 深色主题（设置 → 颜色预设）

- 新增 4 套深色预设：**深夜蓝**、**暗夜青**、**午夜紫**、**石墨黑**（共 10 套）
- 预设改成 5 列两排按钮，换肤立即重绘窗口 / 菜单 / 列表 / 状态栏 / 对话框
- 深色下标题条文字自动改用白色（设了背景图时同样保证可读），状态栏 chips、实例卡片、诊断窗口都会跟着变

## 终止下载 / 终止启动（v1.5rc3 新增）

底部状态栏右侧会按需出现一个黑色按钮，**只在有长任务时显示**：

| 正在做什么 | 按钮文字 | 点了之后 |
| --- | --- | --- |
| 原版下载 / 加载器安装 | `[ 终止下载 ]` | 立刻中断，已完成的文件保留，可续传 |
| 模组批量下载 | `[ 终止下载 ]` | 停止后续任务，已下好的 jar 保留 |
| 点火启动序列 | `[ 终止启动 ]` | 中断启动，**不会创建游戏进程**，可随时重新点火 |
| 游戏正在运行 | `[ 结束游戏 ]` | 二次确认后结束 Minecraft 进程 |

- 菜单同样有入口：`游戏 → 终止当前任务（下载 / 启动）...`
- 状态机会变：`LAUNCH: CANCELLED`，状态栏再提示「启动已终止 // 游戏进程没有创建」
- 下载终止后不会弹「装配完成」窗，只在状态栏写一行「已终止 // 已完成的文件保留」

### 原版下载窗口里的取消（v1.5rc4 强化）

下载中窗口底部有 4 个按钮：`[ 刷新清单 ]` `[ 开始下载 ]` `[ 取消下载 ]` `[ 关闭 ]`。

- `[ 取消下载 ]` 只有下载进行中才可点，点击会弹确认框：
  「确定要终止当前的原版下载吗？· 正在下载的文件会立即停止 · 已经下载好的文件会保留 · 之后可以重新点 [ 开始下载 ] 继续」
- 确认后状态立刻变成 `CANCELLING // 正在停止下载，请稍候 ...`，
  下载线程在**当前 256 KiB 数据块**结束时退出（实测 1～2 秒内停下，
  大文件也一样），`.part` 临时文件自动清理
- 停下后状态写 `CANCELLED // 已取消，已下载文件保留，可重新开始`，
  `[ 开始下载 ]` / `[ 刷新清单 ]` 重新可用
- `[ 关闭 ]` 在下载中会走同一个确认流程，不会静默把窗口关掉留下后台任务
- 状态栏的 `[ 终止下载 ]` 也会先确认再终止，两个入口行为一致



## 小游戏：贪吃蛇 / 2048 / 扫雷 / 俄罗斯方块（v1.5rc2 起）

### 什么时候会出现

下载 / 安装 / 启动时，右下角会弹一个**不挡路的小气泡**：

```
MINI GAME // 小游戏
原版 1.20.1 下载 正在进行，等着也是等着 ——
要不要玩一局小游戏？
[ 贪吃蛇 ] [ 2048 ] [ 扫雷 ] [ 方块 ]
                                    [ 继续等 ]   □ 以后不再提示
```

- 触发点：**原版下载、加载器安装、模组批量下载、点火启动**
- 非模态（不抢焦点、不阻塞下载），5 分钟内只弹一次，正在玩的时候不再弹
- 点任意游戏按钮立刻开局；点 `[ 继续等 ]` 或勾「以后不再提示」就不再打扰

### 四个游戏（`小游戏` 菜单）

| 游戏 | 玩法 | 最高分字段 |
| --- | --- | --- |
| 经典贪吃蛇 | 方向键/WASD 移动，吃圆点 +10，空格暂停，开局按方向键开始 | `snake_best` |
| 2048 | 方向键/WASD 合并相同数字，凑到 2048 即胜利，R 重开 | `game_2048_best` |
| 扫雷 9×9·10 雷 | 左键翻开、右键插旗，**第一下必定安全**，计时挑战最快通关 | `minesweeper_best`（秒） |
| 俄罗斯方块 | ← → 移动，↑/W 旋转，↓ 软降，空格硬降，P 暂停；带落点虚影与 NEXT 预览 | `tetris_best` |

- 全部支持 `R` 重开、`Esc` 关闭；窗口跟随主题（深色也适配）
- 每个游戏都是「纯逻辑模型 + Tk 渲染」两层，逻辑可单独测试
- 菜单里还有：`最高分 / 玩法...`（四款一览）、`下载 / 启动时提示小游戏`（开关）、`关闭提示窗口`、`重置最高分`

## 主界面布局（v1.7rc2 紧凑版）

默认窗口 `1040x640`（最小 `940x560`）—— 与 PCL2 / HMCL 的默认尺寸接近但略大一圈
（HMCL ≈ 958×620、PCL2 ≈ 1000×620）。界面按「壁纸桌面 + 两个窗口」组织：

- 最底层是整窗壁纸（没设背景时是纯白桌面）；
- 顶部一条 34px 单行页眉：左侧小「窗口」标记 + `AKM LAUNCHER` + 竖分隔线 +
  副标题，右侧版本号装在描边框里，底边一条白色斜面 + 黑色硬线（1985 斜面）；
  设了背景时页眉变成同一张图的暗化切片，所有线条自动转白；
- 左栏「控制台」窗口按内容自然收缩（约 366px 高），下方留出桌面区；
- 右栏「战备架」窗口占满剩余高度（v1.7rc5 起是图标墙）；
- 底部保留 92px 桌面横条（仅设了背景时出现），再下面是状态栏。

> v1.7rc2 把外框留白从 22px 收到 14px、页眉 32→30px、左栏最小宽 372→340px，
> v1.7rc5 页眉回到 34px（多了斜面与版本框），战备架列表行宽按新面板宽度重排
> （标题 18 字、版本摘要 16 字、slug 12 字，超出用 `~` 截断），版本信息行超过
> 38 字也会 `…` 截断；设置页改成可滚动，安装窗口列表由 9 行收到 6 行、
> 加载器列表 4→3 行，最小尺寸 640×600。

**左栏 `CONTROL CONSOLE // 启动控制`（10 行控件）**

- 账号卡：64×64 皮肤头像 + `MICROSOFT // 名字` + 授权状态一行（点头像打开账号库）
- `IGN [ 输入框 ] UUID 6419fcdf…d1a7 [ 微软登录 ]` 全在一行，回车即点火
- 版本区标题即选中状态：`VERSION // 1.20.1-forge-…` / `VERSION // AUTO (1.21.1)`，
  右侧 `[ 刷新 ]` `[ 浏览 ]`
- 版本列表固定 3 行高，`[AUTO]` 永远在第一行
- `[x] 版本隔离` + `[ 注销/离线 ]` `[ 赞助 ]` 同一行
- `[ 下载原版 ]` `[ 模组加载器 ]`
- `[  IGNITE 点火起飞  ]`（全界面唯一的大按钮）

**右栏 `MODRINTH ARSENAL // 模组战备架`**

- 第一行就是搜索：`SEARCH [ 输入框 ] [ 检索 ] [ 热门 ]`
- 加载器筛选一行：自动 / Forge / NeoForge / Fabric / Quilt / 全部
- `[ 版本栏 ▼ ]` + 当前 MC / 加载器 / 已安装数量，右侧一行小字提示
  （双击直装 · 多选 · `*` = 支持当前版本）；版本栏默认收起
- 模组列表占满剩余高度（窗口越高列表越长），**v1.7rc5 起是图标墙**：
  每张卡片上面是模组头像（48×48，Modrinth `icon.png`），下面是模组名
  （最多两行，按空格 / 驼峰断词）和下载量；宽度变化时自动重排列数（当前
  1040 宽 ≈ 4 列），支持滚轮、方向键、`Ctrl+单击` 多选
- 底部：`已显示 N / M 条` + `[ 更多 → ]`，再下一行
  `[ 装配所选 ]` / `[ 一键性能全家桶 ]`

**底部状态栏（v1.4b6 两行式）**

- 第一行：`[LAUNCH: IDLE]` `MC 1.20.1` `FORGE` `实例 2` `已玩 12h`
  + 安装时的百分比进度条 + 实时下载速度（`1.2 MB/s`）
- 第二行：完整状态文字（不再被截断）

**6 个菜单**

| 菜单 | 内容 |
| --- | --- |
| 游戏 | **终止当前任务**、原版下载、模组加载器、Java 运行时、导入整合包、**实例管理**、**模组更新检测**、游戏版本、加载器、光影 / 材质、刷新热门榜 |
| 账号 | 微软登录、已记住账号、浏览器登录、刷新令牌、离线模式、复制 UUID、清除授权 |
| 工具 | 工具箱、常用网站、联机教程、复制 IP、**存档管理**、**崩溃报告分析**、打开 .minecraft / mods / logs |
| 小游戏 | **经典贪吃蛇**、**2048**、**扫雷**、**俄罗斯方块**、最高分/玩法、下载时提示开关、关闭提示窗、重置最高分 |
| 设置 | 外观 / 背景 / 内存、导入或清除背景、下载源、恢复默认主题、检查更新、自动更新、重读配置、config.json |
| 关于 | 关于、运行环境自检、打开程序目录、补给赞助、爱发电、安装依赖、退出 |

## 首次启动流程

1. 程序自动创建 `config.json`、`auth.json`、`mod_alias.json`、
   `.minecraft\` 与 `logs\`。
2. 右侧战备架自动拉取 Modrinth 热门榜（`index=downloads`，默认前 8 款，
   绑定 `mc_version` + `loader` facets）。
3. 左侧 `VERSION // …`（标题即当前选中版本）会列出 `.minecraft\versions\`
   中已安装的版本：
   - `[AUTO]`：点火时自动解析并安装 Fabric / 原版核心；
   - `[FABRIC]` / `[VANILLA]` / `[FORGE]` / `[QUILT]`：选中后按该版本点火；
   - `[ 刷新 ]`：外部安装新版本后重新扫描；
   - `[ 浏览 ]`：选择任意 `.Minecraft` 目录或 `versions` 文件夹；
     若直接选中 `versions\<版本id>` 文件夹，会自动锁定该版本。
4. 在左侧输入离线角色名，回车或点击 `[ IGNITE 点火起飞 ]`。
5. 首次点火会安装版本清单与游戏核心（库 / 资源 / 语言文件），
   进度实时输出到状态栏；之后启动只做校验。

## 微软正版登录（设备代码流）

主入口：主页 `[ 微软登录 ]`，或
`[账号] -> [微软设备代码登录（推荐）]`。

这是类似 PCL2 的 **Microsoft Device Code Flow**，默认**无需配置 Azure
Client ID**：

1. 点击登录后，启动器用内置 Xbox Client ID 向
   `https://login.live.com/oauth20_connect.srf` 申请设备码，
   scope 为 `service::user.auth.xboxlive.com::MBI_SSL`（Xbox Live REST 的
   RPS scope，与 prismarine-auth 的 live 流程一致）。
   注意：`XboxLive.signin offline_access` 只适用于 Entra/MSAL 公共客户端，
   用在内置 Xbox 客户端上会在授权完成后被微软拒绝（
   `must sign in again ... grant access to the requested scope`）。
2. 自动把 `user_code` 写入系统剪贴板，并打开
   `https://microsoft.com/link`；窗口显示：
   `微软安全设备码: [ XXXX-XXXX ] (已自动复制)`。
3. 用户在网页输入代码并完成账号授权。
4. 启动器在后台线程按 `interval` 轮询 token 端点（附带
   `?client_id=` 与设备码 Cookie，与 Prismarine/PCL 同类实现一致），
   处理 `authorization_pending` / `slow_down`，不会阻塞 UI。
5. 轮询窗口内如果微软判定验证码失效（例如超过 15 分钟），启动器会
   在原窗口内直接换成新的验证码并重新复制到剪贴板，**不会重复弹出
   新窗口或反复打开浏览器**；本次登录会话最长等待 60 分钟。
   只有验证码正常有效超过 5 分钟后失效才会自动续码，避免
   “刚出码就失效”时无限重试。
6. 授权完成后依次换取 Xbox Live Token、XSTS Token、
   Minecraft Access Token，并读取
   `https://api.minecraftservices.com/minecraft/profile` 的角色名与 UUID。
   注意 `user.auth.xboxlive.com` 的 `RpsTicket` 前缀：Live/MBI_SSL 令牌用
   `t=<token>`，Entra/Azure 令牌用 `d=<token>`（混用会返回 HTTP 401）。
7. 成功后关闭验证码窗口，弹出
   `正版登录成功 / 已登录到正版 Minecraft` 提示，左侧身份卡显示
   `[AUTH: 微软正版] COMMANDER {ms_name}`，并提供
   `[注销登录 / 切换离线]`。

登录窗口底部还提供：

- `[ 打开授权页 ]`：重新打开 `https://microsoft.com/link`
- `[ 复制验证码 ]`：再次复制当前 `user_code`
- `[ 我已授权，立即检查 ]`：跳过轮询等待，立刻向微软查询授权结果
- `[ 取消登录 ]`：终止本次设备码登录

### 登录诊断日志

设备码登录的每一步（申请验证码、每次轮询的 HTTP 状态与微软错误码、
Xbox / XSTS / Minecraft 交换结果、成功或失败原因）都会写入：

```text
logs\device_login.log
```

如果登录仍然失败，可以直接查看该文件定位微软返回的具体错误。

高级选项：如果希望使用自己的 Azure 应用，在 `config.json` 填入
`device_client_id`（Azure 公共客户端应用 ID，启用
**Allow public client flows**），或设置环境变量 `AKM_MS_CLIENT_ID`；
此时改用 `https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode`。

### auth.json 与记住账号

登录成功后 `auth.json` 写入：

```json
{
  "mode": "microsoft",
  "ms_name": "玩家正版名",
  "ms_uuid": "玩家 UUID",
  "ms_refresh_token": "Refresh Token"
}
```

同时保留 `username`、`uuid`、`access_token`、`refresh_token` 等兼容字段，
供现有点火逻辑使用。启动器每次启动时，若为 `microsoft` 模式，会在后台
用 `ms_refresh_token` 静默刷新，无需重复设备码授权。

- `[账号] -> [已记住账号...]` 打开账号库，可查看/切换/删除已记住账号。
- 最多保存 8 个账号；Refresh Token 只保存在本机 `auth.json`。
- `[清除本地授权]` 只清除当前会话，不删除已记住账号。
- 浏览器联动保留为备用入口，设备代码流是默认方式。

### 异常处理

- 用户在网页端拒绝：提示“授权被拒绝”。
- **账号需要重新登录**（微软返回
  `invalid_grant: The user could not be authenticated / must sign in again`）：
  这是无密码账号（只用身份验证器/邮箱验证码）常见的失败。启动器会弹窗
  说明原因，并提供一键打开 `account.live.com/password/Change` 设置密码；
  之后重新登录时在授权页选择「其他登录方法 → 使用我的密码」。
- **验证码已被消耗**（`device_code has already been used`）：
  自动在同一窗口换成新验证码（最多 2 次），不会重复打开浏览器。
- 验证码正常使用超过 5 分钟后失效才自动续码；刚下发就失效时直接给出
  微软原始错误，不再循环弹窗。
- 网络失败 / Client ID 无效：明确提示检查网络或 Azure 应用配置。
- 账号没有 Minecraft: Java 版：提示“该账户未拥有 Minecraft: Java 版”。
- 所有轮询与 Xbox/Minecraft 令牌交换都在后台线程执行，UI 保持响应；
  窗口关闭按钮会取消轮询。

## 模组加载器安装（Forge / NeoForge / Fabric / Quilt）

入口：

- 主页 `[ 模组加载器 ]`
- 或 `[游戏] -> [安装模组加载器...]`

功能：

- 四选一加载器：**Forge**、**NeoForge**、**Fabric**、**Quilt**。
- 加载器选项下方新增 **OFFICIAL DOWNLOAD // 官方下载入口** 一行：
  `[ Forge 官网 ]`、`[ NeoForge 官网 ]`、`[ Fabric 官网 ]`、`[ Quilt 官网 ]`，
  点击直接用系统浏览器打开对应下载页。即使版本元数据被网络阻断，这条路始终可用。
- 版本元数据获取带 **25 秒硬超时**：不会再出现选 NeoForge 后一直卡在
  `LOADING ...` 的情况；超时或失败时自动兜底：
  - **NeoForge：优先走 BMCLAPI 镜像**（`bmclapi2.bangbang93.com/maven/...`），
    20 个 MC 版本、1.21.1 有 259 个加载器版本全部可见，状态栏显示
    `MIRROR // 已改用 BMCLAPI 镜像的 NeoForge 版本表`
  - NeoForge 安装器同样从 BMCLAPI 下载后本地执行（官方 maven 不可达也能开始安装）；
    若安装器自身拉依赖失败，会提示用 `[ NeoForge 官网 ]` 手动安装
  - Forge：官方 API 失败时改用 `promotions_slim.json`（状态栏显示
    `MIRROR // 已改用 Forge 官方 promotions 数据`）
- 左列只显示该加载器实际支持的 Minecraft 版本，按版本降序排列；
  已安装的原版版本前带 `*`。
- 右列只显示所选 Minecraft 版本适配的加载器版本，首行为
  `[AUTO] 最新适配版本`，也可以手动选择具体版本；已安装的加载器版本
  前带 `*`。
- 基础原版缺失时，先按 `download_source` 使用官方 / BMCLAPI 双源安装
  该原版，再执行加载器安装。
- 安装完成后自动锁定安装版本，并写入：
  `launch_version`、`mc_version`、`loader`、`loader_version`。
- 加载器元数据与安装器使用官方加载器源（Fabric / Quilt Meta、
  Forge / NeoForge Maven）；基础原版仍使用双源。
- Forge / NeoForge 的安装处理器需要 Java。默认使用 PATH 中的 Java 21；
  安装旧版 Forge 时，请在 `config.json` 的 `java` 字段指定兼容的
  Java 8 / 17 可执行文件。

### NeoForge 安装失败排查（B0.3）

**症状**：点安装后立刻弹 `NeoForge 安装器执行失败 (exit 1)`，把安装器日志翻出来是：

```text
There is no minecraft launcher profile in "…\.minecraft", you need to run the launcher first!
There was an error during installation
```

**原因**：Forge / NeoForge 的安装器要求目标 `.minecraft` 目录里有
`launcher_profiles.json`（官方启动器写的那个文件）。AKM 的档案存在自己的
`config.json` 里，全新的游戏目录里没有这个文件，所以新机器上装 NeoForge
必然失败。

**B0.3 的处理**：

1. 安装前自动补建一个最小 `launcher_profiles.json`（已存在则原样不动），
   Forge / Fabric / Quilt 走同一条前置检查
2. 安装前先从 **BMCLAPI 镜像预取安装器自带的 ~150 个依赖库**到
   `<game>\libraries`（安装器看到 `Checksum valid` 就跳过），
   避免逐个去 `maven.neoforged.net` 拉、每个都可能卡 30 秒超时
3. 安装器失败时把日志存到 `logs/neoforge-<版本>-<时间>.log`，错误框里给出路径
4. 错误分类提示：缺 profile / Java 版本太低 / `maven.neoforged.net` 连不上，
   不再一律说「可能是网络问题」

> 安装器自带的 `--mirror` 参数只影响 Mojang 的库，不会把 NeoForge 自己的
> maven 换到镜像，所以 AKM 用的是「预取依赖」这条路，而不是 `--mirror`。

## 内存分配（-Xms / -Xmx）

入口：`[设置] -> [外观 / 背景 / 内存...]`（内存、外观、背景、下载源都在同一个设置窗口）。

- 窗口顶部显示本机 **物理内存**（如 `物理内存: 31 GB`，由 `GlobalMemoryStatusEx` 读取）。
- 两条滑杆分别控制 **最小堆 -Xms** 与 **最大堆 -Xmx**，范围 1 GB ~ 物理内存 GB 数。
- 快捷按钮 `[ 2G ] [ 4G ] [ 8G ] [ 16G ]`：一键设置最大值（最小值超过时会自动下调）。
- `[ 推荐 ]`：取物理内存的一半，限制在 2 GB ~ 16 GB 之间。
- `[ 应用内存 ]`：写入 `config.json` 的 `memory.min` / `memory.max`（形如 `8192M`），
  并立即在底部提示 `生效参数: -Xms1024M -Xmx8192M`。
- 校验与提示：
  - 最大值 < 最小值：保存时自动对齐为相等
  - 最大值 ≥ 物理内存：提示 `已超过物理内存，游戏可能无法启动`
  - 接近物理内存上限：提示 `建议给系统留 2 GB 左右`
- 启动时会重新归一化一次（`normalize_memory_config`），
  实际传给 JVM 的命令行固定为 `-Xms<min>M -Xmx<max>M`，
  并在日志里打印 `内存分配: -Xms1024M / -Xmx4096M`。
- 手工编辑 `config.json` 也支持 `2G` / `3072M` / `2048` 等写法，启动时统一换算成 MB。

## 内置 Java 运行时（8 / 11 / 17 / 21 / 25）

入口：`[游戏] -> [Java 运行时管理...]`。

- 一次列出 5 个 Temurin JRE 版本，标注用途：

  | Java | 适用 |
  | --- | --- |
  | 8 | MC 1.6 ~ 1.16.5，旧版 Forge / 老模组 |
  | 11 | MC 1.16.5 ~ 1.17.1 过渡版本 |
  | 17 | MC 1.18 ~ 1.20.4（Forge 1.20.x / NeoForge 20.x） |
  | 21 | MC 1.20.5 ~ 1.21.x（NeoForge 21.x 必需） |
  | 25 | MC 1.21.9+ / 新快照（可选） |

- `[ 下载 / 更新选中 ]`：下载并解压到 `<游戏目录>\runtime\akm-java-<major>\`。
  下载源优先 **清华 Adoptium 镜像**（`mirrors.tuna.tsinghua.edu.cn/Adoptium`），
  失败自动回退 **Adoptium 官方 API**。
- `[ 全部下载 ]`：一次装齐缺失版本（合计约 200 MB），带进度条与逐版本状态。
- `[ 设为启动 Java ]`：把该 `java.exe` 绝对路径写入 `config.json` 的 `java` 字段（列表里带 `*`）。
- `[ 自动选择 ]`：清空 `java` 字段，回到按版本要求自动挑选（**推荐默认**）。
- `[ 删除选中 ]`：删除该 runtime 目录；若正被固定使用，会自动回退为自动选择。
- `[ 打开 runtime 目录 ]`：方便查看已下载的运行时。
- 自动挑选逻辑（`find_java_executable`）会把 `runtime\**\bin\java.exe` 纳入候选，
  再按 `version.json` 的 `javaVersion.majorVersion` 选满足要求且最小的版本。
- 实测：Java 21（46.7 MB）下载 + 解压约 6 秒，解压后 144.5 MB，
  `--selftest` 会输出 `[JAVA] runtime : Java21 (144.5 MB)`。

## 版本隔离（模组防冲突）

入口：左侧 `VERSION ISOLATION // 版本隔离` 勾选框。

- **开启后**，每个具体版本使用自己的游戏目录：

  ```text
  <游戏目录>\versions\<版本 id>\
  ├─ mods\            # 该版本专属模组
  ├─ config\
  ├─ saves\
  ├─ resourcepacks\
  ├─ shaderpacks\
  └─ screenshots\
  ```

  版本清单 / libraries / assets 仍然共享，只隔离「玩家数据 + 模组」。
- 模组装配（双装、`[装配所选]`、`[一键性能全家桶]`）会写入当前版本的
  `versions\<id>\mods`，状态栏提示 `版本隔离生效 // 模组写入 versions\<id>\mods`。
- `[工具] -> [打开 mods 目录]` 会自动打开当前生效的 mods 目录。
- 启动时 `gameDirectory` 指向隔离目录，日志打印
  `版本隔离: 游戏目录 -> ...versions\<id>`；存档、配置、截图都落在该版本内。
- **AUTO 模式不生效**：未选择具体版本时勾选会提示先选版本
  （因为不知道要隔离到哪个目录）。
- 关闭后立即回到全局 `mods` / 共享存档，已下载的隔离文件保留在版本目录里，不会丢。
- 状态保存在 `config.json` 的 `version_isolation`，左侧版本信息会显示
  `SELECTED // 26.3-forge-66.1.0 // ISO: versions\26.3-forge-66.1.0`。

## 启动状态与无法启动排查

底部状态栏左侧新增常驻 `LAUNCH` 状态块：

- `IDLE`：空闲
- `PREPARING` / `AUTH`：点火准备与身份处理
- `LOCAL READY` / `LOADER READY`：本地版本/加载器版本已就绪
- `CHECK CORE` / `INSTALL CORE` / `REPAIR`：核心校验、首次安装或修复
- `BUILD CMD` / `STARTING`：组装命令、拉起进程
- `RUNNING 00:12`：游戏运行中，实时显示运行时长（青蓝底）
- `EXITED 0`：正常退出（灰底）
- `CRASH <code>` / `FAILED`：异常退出或点火失败（黑底白字）

启动可靠性调整：

- 已安装且存在的版本**不再每次点火都联网重装**，直接使用本地文件启动。
- 仅当客户端 jar 缺失、启动命令组装失败，或类路径中缺少库文件时，
  才自动执行一次修复。
- 自动解析 Java：优先 `config.json` 的 `java` 字段，其次 PATH 中的
  `java`，最后游戏目录内由 mll 安装的 `runtime`；找不到会直接提示，
  不会静默失败。
- 按版本 JSON 的 `javaVersion` 选择 Java。如果该版本要求更高 Java
  （例如快照需要 Java 25）而本机没有，AKM 会自动下载对应 Mojang
  runtime 后再启动；首次可能需要较长时间，状态栏会显示
  `LAUNCH: JAVA RUNTIME` 与下载进度。
- 游戏异常退出会弹窗显示退出码与 `logs\launch-*.log` 路径，
  左下角同步显示 `CRASH <code>`。
- 常见无法启动原因：
  - Java 版本不匹配（1.21.1 需要 Java 21，旧 Forge 可能需要 Java 8/17）
  - `config.json` 中 `java` 路径错误
  - 本地版本文件不完整或被杀毒软件锁定
  - 选择的自定义版本 JSON 损坏
  - 游戏目录权限不足

## 图标墙（v1.7rc5，v1.7rc6 提速 + 全量补齐）

模组战备架、光影 / 材质包下载这两个列表都改成了「图标在上、名字在下」的卡片墙
（`IconGrid`，纯 Tk 实现：`Canvas` + 一格格固定尺寸的 `Frame`）：

- 卡片 = 48×48 头像 + 名称（最多两行）+ 下载量，边框是 1px 实线，选中时整张
  变青底白字；宽度一变自动重排列数（4 列 → 3 列 → …），滚轮 / ↑↓←→ / Enter
  都能用，`Ctrl+单击` 多选（战备架支持多选装配）
- **头像下载是 6 路并发的**，一张墙通常 2-3 秒填满（实测冷缓存：战备架 8 张
  2.1 秒、光影 30 张 3.2 秒；有磁盘缓存时几乎是瞬间）
- **两个来源，自动兜底**（v1.7rc6）：
  1. 先用 `/search` 返回的 `icon_url`（`..._96.webp`，只有 5-35 KB，最快）——
     但它是 **WebP**，GDI+ 读不了，所以交给 Windows shell 缩略图接口
     （`IShellItemImageFactory` + `GetDIBits`）解码成 48×48 PNG；
  2. 失败再退到 `https://cdn.modrinth.com/data/<project_id>/icon.png`
     （真 PNG，但常常是原始大图，而且有些项目根本没这个别名，会 400）；
  3. 两条都不行才显示项目首字母占位
- 头像下载先查内存缓存，再查磁盘缓存 `icons/`（程序目录，写不进去就退到
  `%USERPROFILE%\.akm_launcher_icons`），缓存超过 400 张自动清理最旧的；
  某个项目连续失败 2 次后本次运行不再重试

## 模组版本体检（v1.7rc7 起 · v1.7rc8 一键装新版 · B0.2 一键更新全部 + CurseForge 移植）

**入口（三处，随手就能点）：**

- 右栏战备架底部那颗青色按钮 **`[ 模组体检 ]`**（`装配所选` / `一键性能全家桶` 右边，最显眼）
- 菜单 `游戏 → 模组版本体检（拖入 jar）...`
- 体检窗口内还可以 `[ 选择 jar... ]` / `[ 扫描当前 mods ]`

一句话：**告诉它你要玩哪个 MC 版本（比如 1.21），把下载好的 jar 拖进来，它告诉你
哪些模组确实有 1.21 的版本、哪些该排除，并可以直接把命中的升到最新。**

- 拖放：直接把 `.jar` 或整个 `mods` 文件夹**拖进窗口**（Windows 原生
  `WM_DROPFILES`，纯 ctypes 实现，没用任何第三方库）；也可以点
  `[ 选择 jar... ]` / `[ 扫描当前 mods ]`
- 目标版本：默认取当前选中版本的 MC 号，可手改，另带 `1.21.1 / 1.21 / 1.20.1 /
  1.19.2` 快捷按钮和「含 x.y.z 子版本」开关（1.21 是否也算 1.21.1 / 1.21.4）
- 结论优先级（这就是它比别的启动器准的地方）：
  1. **Modrinth 逐版本核对**：`POST /v2/version_files/update` 带去
     `game_versions=["1.21"]`，只有真的**发布过 1.21 构建**的 jar 才会被返回，
     同时给出该项目 1.21 的最新版本号（顺手提示「可升级」）；
  2. 再拉 `GET /v2/projects?ids=[...]` 拿项目支持的完整 MC 列表，
     被排除的条目会写明「最高只到 1.19.2」；
  3. 没被 Modrinth 收录（自建包 / 魔改 jar）时，回落到 **jar 内部声明**：
     `fabric.mod.json` 的 `depends.minecraft`、`quilt.mod.json`、
     `META-INF/mods.toml` / `neoforge.mods.toml` 的 `versionRange`、
     老 Forge 的 `mcmod.info`，都支持 `>=1.20 <1.22`、`[1.20.1,1.21)`、
     `~1.21`、`1.21.x` 这些写法；
  4. 连声明都没有时，才用文件名里的 `+mc1.21` / `-1.20.1-` 推断
- 结果表：`[ OK ] / [MISS] / [ ?? ]` 三色行，列出模组名、本地版本、加载器、
  判定依据与「最新适配版本」；默认**只显示命中**（勾掉「只看命中」可看全部）
- **体检完自动问要不要装最新版（v1.7rc8）**：只要命中的条目里有「目标版本上的
  更新构建」，体检结束会弹窗列出 `当前版本 → 目标版本` 的对照，确认后
  逐个下载、校验 SHA1、写进 `mods/`，旧 jar 自动删除；任何一个失败只跳过它，
  装完自动重新体检一遍。窗口里也有常驻的 `[ 安装最新版本 ]` 按钮
- 右侧动作：`[ 导出报告 ]`（txt 清单，含判定依据）、
  `[ 移出不兼容 → ]`（把不兼容的 jar 移进 `mods/_incompatible_<版本>/`，
  只是移走，随时能还原，游戏也不会加载子目录里的 jar）
- 全程不联网也能用（勾掉「联网核对 Modrinth」即纯本地判定）

### 一键更新全部（B0.2）

- 结果里凡是有「目标版本上的更新构建」的模组，底部按钮会直接带数量：
  `[ 一键更新全部 (3) ]`
- 点一下确认，4 路并发下载 + SHA1 校验 + 替换旧 jar，装完自动重新体检一遍
- 每行明细里已经标了 `(可升级)`，可以先看清楚再点

### 装到哪个版本文件夹（B0.4）

体检识别完成后会先弹一个 **`INSTALL TARGET // 装到哪个版本文件夹？`** 窗口：

```text
当前版本 mods      D:\…\.minecraft\versions\1.20.1-forge-47.4.28\mods
1.20.1             D:\…\.minecraft\versions\1.20.1\mods
1.21.1-forge-52.1  D:\…\.minecraft\versions\1.21.1-forge-52.1\mods
目标 [ D:\…\versions\1.21.1\mods                    ]  [ 浏览... ]
                                       [ 就装这里 ]  [ 取消 ]
```

- 列表里是「当前版本的 mods + 每个已安装版本的 mods」，默认选中当前那个
- `[ 浏览... ]` 打开系统的选文件夹窗口，选版本目录也行，AKM 会自动补 `\mods`
- `[ 就装这里 ]` 之后，底部灰条常驻 `安装到 // <路径>`，
  体检窗口里也有常驻的 `[ 目标文件夹... ]` 随时改
- **装到别的版本不会删原版本的旧 jar**：只有目标就是原 jar 所在目录时，
  才会在装好后替换掉旧文件；装到别的文件夹时原模组原样留着
- 装配/移植版下载完成后自动重新体检，新装进目标文件夹的文件也会进结果表

### CurseForge 移植版本检测（B0.2，默认开启）

勾选框 `联网查 CurseForge 移植` 打开后，体检会对**在 Modrinth 上没有目标版本构建**的
模组再去 CurseForge 查一遍：

```text
[ OK ] Create            mc1.20.1-6.0.8    FORGE   有 1.20.1 构建 // 最新 6.0.8
[ CF ] Some Mod          2.1.0              FORGE   CurseForge 移植版：somemod-1.20.1-2.2.0.jar (release)
[MISS] Old Mod           1.7.3              FORGE   无 1.20.1 构建 // 最高只到 1.19.2 // CF 无该版本
```

- 蓝色 `[ CF ]` = CurseForge 上有这个 MC 版本的移植构建
- 体检结束自动弹窗：`有 N 个模组在 MC x 上没有原版构建，但 CurseForge 上有移植版本`，
  列出 `本地模组 → 文件名` 对照；确认后直接下载进当前 `mods`
  （按文件大小校验，原 jar 保留），装完自动重新体检
- 面板上常驻 `[ 下移植版 (N) ]`，之前点了否随时能补装
- 防误装：CurseForge 项目标题要和本地模组名对得上（括号/符号去掉后互为子串），
  加载器也要一致（Quilt 视作可以用 Fabric 包），否则不认这一条
- 只查没命中的模组，最多 40 个、4 路并发；`[ 导出报告 ]` 里会带上
  `CurseForge 移植: 文件名 (版本) 项目页`
- 数据来源：CurseForge 官方 API 需要私有 Key，这里读公开的 **cfwidget 镜像**（项目 +
  文件列表），下载走 `edge.forgecdn.net` 直链，不需要填任何 Key

> 字体（v1.7rc8）：全界面从「Courier New 8/9 全加粗」换成
> **Consolas 10（正文）/ 9（小字）不加粗**，标题仍加粗；等宽所以 ASCII 表格
> 依然对齐，但笔画更细、屏幕上看久了不扎眼。窗口最小高度顺带提高到 660。


## 一键全家桶（B0.1 新增：机械动力）

右栏主按钮下面多了一颗整行的黑色按钮 **`[ 一键安装机械动力全家桶 ]`**，
点开后是一个独立窗口（`CREATE PACK // 机械动力全家桶`）：

```text
目标 // MC 1.20.1 · FORGE · 写入 …\versions\1.20.1-forge-47.4.28\mods
共 16 项 // 可装 15 // 已勾选 15
[x] 机械动力 Create            核心  [ OK ] mc1.20.1-6.0.8   本体：齿轮 / 动能 / 自动化产线
[x] Flywheel 渲染后端          前置  [ OK ] 1.1.3            Create 6 的渲染库，必须一起装
[ ] Fabric API                 前置  不适用                  Fabric / Quilt 版必需前置
[x] Create Crafts & Additions  附属  [ OK ] forge-1.20.1-…   电动机 / 交流发电机
…
```

- **打开就自动适配**：按当前 `VERSION` 解析出的 MC 版本 + 加载器，逐条去 Modrinth
  查「这个版本上有没有构建」，命中显示 `[ OK ] 版本号`（绿色），没有就 `[ 无适配 ]`
  （红色）并自动取消勾选；加载器不对的条目（比如 Forge 环境下的 Fabric API）
  直接标 `不适用` 且不可勾选
- **多 slug 候选**：机械动力本体在 Modrinth 分成两个项目，`create`（Forge / NeoForge）
  和 `create-fabric`（Fabric / Quilt），条目按顺序试，谁有构建就用谁；Flywheel 同理
  （新版 `flw-vanillin` → 旧版 `flywheel`）
- 面板按钮：`[ 核心 + 前置 ]` 只留本体/渲染库/前置、`[ 全选 ]`、`[ 全不选 ]`、
  `[ 重新探测 ]`（换过版本/加载器后重查）、`[ 开始装配 ]`
- 装配走的是战备架同一条下载链路：4 路并发、写进当前 `mods`（版本隔离生效时写进
  `versions\<id>\mods`）、已有的同名 jar 自动跳过
- 窗口底部常驻一行提示：**全家桶会持续更新**（农夫乐事 / 沉浸工程 / 应用能源 2 /
  通用机械 / Tetra …），后续版本会按同样的方式加进来

| 条目 | Modrinth 项目 | 说明 |
| --- | --- | --- |
| 机械动力 Create | `create` / `create-fabric` | 本体 |
| Flywheel 渲染后端 | `flw-vanillin` / `flywheel` | Create 6 必备 |
| Fabric API | `fabric-api` | 仅 Fabric / Quilt |
| Crafts & Additions | `createaddition` | 动能 ↔ 电力 |
| Create Deco | `create-deco` | 装饰方块 |
| Create Jetpack | `create-jetpack` | 喷气背包 |
| Ore Excavation | `create-ore-excavation` | 矿脉钻井 |
| Enchantment Industry | `create-enchantment-industry` | 液态经验 |
| Steam 'n' Rails | `create-steam-n-rails` | 蒸汽机车（1.20.1） |
| Copycats+ | `copycats` | 仿制方块 |
| Connected | `create-connected` | 传动件扩展 |
| Mechanical Extruder | `create-mechanical-extruder` | 造石机 |
| Confectionery | `create-confectionery` | 甜品线 |
| Encased | `create-encased` | 装甲齿轮箱 |
| Train Parts | `create-train-parts` | 列车零件 |
| Central Kitchen | `create-central-kitchen` | 中央厨房 |

> 版本号规则（B0.1 起）：`APP_VERSION` 换成字母系列 `B0.1`，比较函数
> `parse_app_version` 先比字母段（A=1、B=2…）再比数字，所以 `B0.1` 排在
> `1.7rc9` 之上，老版本能正常收到这次更新；界面上的徽标/关于页会自动显示
> `B0.1`（不再加 `v` 前缀）。发布包名同步为 `AKM_Launcher_B0.1.zip`。


## Modrinth 战备架

- **右侧顶部 `LOADER FILTER // 加载器筛选`**：`自动 / Forge / NeoForge / Fabric / Quilt / 全部`
  - `自动`：使用当前所选版本自带的加载器（默认）
  - 指定某个加载器：榜单与搜索都**只返回该加载器可用的模组**（硬约束，不会混入纯 Fabric 模组）
  - `全部`：不做加载器过滤
  - 选择写入 `config.json` 的 `mod_filter_loader`，重启后保留
- **选版本即联动**：左侧 `VERSION // …` 选中任意版本后，右侧计数栏立刻变成
  `HOT 8 // 26.3/FORGE` 这类范围提示，并按「解析出的 MC 版本 + 加载器」重新装载。
  版本 id 解析（`parse_version_id`）覆盖：

  | 版本 id 形态 | 解析结果 |
  | --- | --- |
  | `26.3-forge-66.1.0` | MC 26.3 / Forge 66.1.0 |
  | `1.21.1-Forge_52.1.16` | MC 1.21.1 / Forge 52.1.16 |
  | `fabric-loader-0.19.5-26.3` | MC 26.3 / Fabric 0.19.5 |
  | `neoforge-21.1.264` | MC 1.21.1 / NeoForge 21.1.264 |
  | `26.3` / `26.4-snapshot-5` | MC 26.3 / MC 26.4（无加载器） |
  | `AKM的大世界`、`All the Mods 10 - ATM10` | 读 JSON：`inheritsFrom`、`net.minecraftforge:forge:<mc>-<ver>`、`--fml.mcVersion` / `--fml.forgeVersion` / `--fml.neoForgeVersion` |

- **榜单空时的降级**（计数栏会写明原因）：
  1. 当前版本 + 加载器
  2. 全部版本 + 加载器（`26.3 无记录 // 显示全部版本`）
  3. 当前版本 + 全部加载器（仅当筛选为 `全部`）
  4. 全站热门
- **搜索遵守同一筛选**：加载器是硬约束，只放宽 MC 版本，因此
  `QUERY create // 30/1717 条 // 全部版本 / FORGE // 本体无 26.3 版本`
  仍然全部是 Forge 可用模组；筛选下确实没有结果时会提示
  `NO MATCH // 0 条 // FILTER // MC 26.3 // FORGE // 可切到 [全部] 再搜`。
- **可展开版本栏（VERSION BAR）**：右侧标题下方 `[ 版本栏 ▲ ]` / `[ 版本栏 ▼ ]`
  - `已安装 // INSTALLED`：按本地 `versions\` 列出（带 `[FORGE]` / `[FABRIC]`
    / `[NEOFORG]` / `[VANILLA]` 标签），点击=锁定该版本为点火目标，
    右侧榜单立即按它的 MC + 加载器重载
  - `常用版本 // COMMON MC`：取 Modrinth `/tag/game_version` 的最新 release
    （当前 103 个，显示前 15 个，包含 26.3 / 26.2 / 26.1.2 …），
    点击=按该 MC 筛选模组；若本地已装同 MC 版本会自动转成「锁定」，
    否则清空点火版本并提示 `尚未安装，请先用 [下载原版] 或 [模组加载器] 安装`
    （避免把模组装进别的版本目录）
  - 顶部摘要：`当前 // MC 26.3 // FORGE // 已安装 1 个版本`
  - 展开 / 收起状态写入 `config.json` 的 `mod_version_bar_open`，重启保留
- **列表直接列出游戏版本**：每行形如

  ```text
  [📦 GAME] Create        28.2M  *MC 26.3,1.21.1,1.20.1,+2  create
  [📦 GAME] Create        28.2M  -MC 1.21.1,1.20.1,1.19.2,+5  create-fabric
  ```

  - 最多显示 3 个最高版本，其余用 `,+N` 表示
  - 行首 `*` = 支持当前筛选的 MC 版本（可直接装）；`-` = 不支持（装了会失败）
  - 单击任意行，状态栏会列出**完整支持版本**（最多 10 个 + `+N`），
    方便先确认再双击装配
  把中文换成英文 Slug，例如 `钠 -> sodium`、`机械动力 / 创造 / 机械 / 动力 -> create`、
  `匠魂 -> tinkers-construct`、`宝可梦 -> cobblemon`、`JEI -> jei`。
- **本体优先命中**：命中词库后先按 slug 直接取 `/project/{slug}`，
  所以搜「机械动力」时列表第一行一定是 Create 本体（若当前筛选的加载器不支持该本体，则不会强行插入）。
- **共 30 条/页**（`modrinth.search_limit`，上限 100），点 `[ 更多结果 ]`
  按 `offset` 继续翻页，计数栏显示 `QUERY create // 30/144 条`。
- **本体版本提示**：本体不含当前 MC 时，计数栏追加
  `本体无 26.3 版本`；单击预览若该条目缺当前版本/加载器，会提示
  `警告: 无 26.3 版本 / 无 FORGE 构建，装配会失败`。
- **未收录中文词**：仍按原文检索，并在状态栏用 `difflib` 给出相近词，
  例如搜「机械动」会提示 `机械动力 / 机械 / 机械动力镐 ...`。
- 单击条目：状态栏预览简介与下载量。
- 双击条目 / 列表回车：立即拉取该模组对应 `mc_version` + `loader`
  的最新 `.jar` 写入当前游戏目录的 `mods\`。
- `Ctrl` / `Shift` 多选后点击 `[ 装配所选 ]`：`ThreadPoolExecutor`
  四路并发下载，互不阻塞。
- `[ 一键性能全家桶 ]`：并发装配 Sodium、Lithium、FerriteCore、Krypton、
  EntityCulling、ImmediatelyFast、C2ME、ModernFix。
- 每条结果固定显示 `MC <最高适配版本>`：取该模组 Modrinth
  `game_versions` / `versions` 中最高的正式版本；列表单击预览时状态栏
  也会同步显示。
- 所有网络请求带合法 `User-Agent`，失败会状态栏提示并弹窗兜底。

## 光影与材质包下载（SHADER / RESOURCEPACK）

入口：

- 顶部菜单 `[游戏] -> [光影 / 材质] -> [光影下载...]`
- 顶部菜单 `[游戏] -> [光影 / 材质] -> [材质包下载...]`
- 菜单里的 `打开 shaderpacks 目录` / `打开 resourcepacks 目录` 直达安装位置

窗口结构（`SHADER / RESOURCEPACK // 光影与材质下载`）：

```text
[光影] [材质包]   MC 版本 [1.20.1 ▾]  [ 刷新榜单 ]
[ 搜索框 ........................ ] [ 检索 ]
[双击=下载] [单击=预览] ... [ ] 装入全局 .minecraft
+------------------------------------------+
| [ SHADER ] Complementary ...  72.5M  ... |
+------------------------------------------+
状态行 / ASCII 进度条
[ 下载选中 ]  [ 打开目标目录 ]  [ 关闭 ]
```

- **数据源**：Modrinth 官方 API，`project_type=shader` / `project_type=resourcepack`，
  与模组战备架同一套 `http_json` + 重试 + 合法 `User-Agent`。
- **榜单 / 检索**：空搜索框 = 按下载量取热门（`index=downloads`）；
  输入关键词走 `index=relevance`，`MC 版本` 下拉是硬筛选
  （`全部版本` 表示不过滤）；当前筛选无记录时自动放宽为全部版本，
  状态行会写 `1.20.1 无记录 // 显示全部版本`。
- **中文词库**：内置 `CONTENT_ALIAS_DEFAULT`，例如
  `光影 -> complementary-reimagined`、`BSL -> bsl-shaders`、
  `原版材质 -> faithful-32x`、`鲜活动画 -> fresh-animations`、
  `简约材质 -> bare-bones`、`字体 -> smooth-font`；
  未收录的词直接按原文搜，也可直接输入 slug。
- **下载**：双击条目或 `[ 下载选中 ]`，按当前 `MC 版本` 取该工程的最新正式版，
  下载主文件（`.zip` / `.jar`）并校验 Modrinth 提供的 **SHA1**：
  - 光影 -> `shaderpacks\`
  - 材质包 -> `resourcepacks\`
  - 开启版本隔离时默认装进当前实例
    `.minecraft\versions\<版本>\shaderpacks|resourcepacks`；
    勾选 `装入全局 .minecraft` 则装进共享目录。
  - 目标目录已有同名文件时直接跳过（状态行 `已存在 ...`），不重复下载。
  - 下载过程状态行显示 `下载 xxx.zip :: 42% (512/1200 KiB)`，
    右侧 ASCII 进度条同步推进；完成后弹窗汇总「成功 / 跳过 / 失败」。
- **预览**：单击条目，状态行显示 `[SHADER] 名称 // 下载量 // 支持: 26.3,26.2,...`
  （最多 10 个版本 + `+N`）。
- **注意**：光影本身只是资源文件，需在整合包 / 版本里安装
  **Iris** 或 **OptiFine** 才能在游戏内启用；材质包进游戏后
  `选项 -> 资源包` 里手动启用（可用 `P` 快速换包的是第三方模组，不是原版）。
- `MODRINTH CDN` 在国内可能较慢（实测部分节点 ~80 KB/s），
  大文件请耐心等待进度条，界面不会卡死（下载在后台线程）。

## 补给站 / 加密收款码

入口（三处等价）：

- 主界面左侧控制台 `[ 赞助 ]`
- 顶部菜单 `[关于] -> [补给赞助（收款码）...]`
- 顶部菜单 `[关于] -> [打开爱发电主页]`

> `[关于]` 菜单里只有 `打开补给站面板（收款码）` / `打开爱发电主页` / `复制赞助链接`
> 三项；不再提供「修改赞助链接」入口。需要更换链接时，直接编辑 `config.json`
> 的 `afdian_url` 字段即可。

弹出的是 1985 Windows 1.0 风格面板：纯白底、1 像素黑实线边框、Courier New
等宽粗体，底部两个复古方块按钮：

- `[ 🌐 访问爱发电主页 ]` → `https://afdian.net/a/your-id`
- `[ 收到并关闭 ]` → 关闭弹窗

按钮绑定 `<Enter>` / `<Leave>`，鼠标悬停时切换为黑底白字 / 青蓝底白字并改为
下沉边框，离开后复原。状态栏同时打印：

```text
>>> [SUPPLY] 已激活官方能量补给通道 (爱发电: your-id)
```

### 收款码的加密与内存解密

`donate.png` 不会被明文打包，也不会在运行时落盘：

1. `make_qr_payload.py` 读取 `donate.png`，生成 16 字节随机密钥
   （`os.urandom(16)`），逐字节循环异或加密；
2. 输出 `qr_payload.py`，只包含两个整数列表：

   ```python
   QR_CIPHER_KEY = bytes([...])
   ENCRYPTED_QR_DATA = bytes([...])
   ```

   文件内没有 Base64 文本，也没有 `\x89PNG` 文件头，无法用特征搜索直接提取；
3. 启动器在打开补给面板时才在内存中异或还原，校验 PNG 文件头后转成 Base64
   交给 `tk.PhotoImage(data=...)` 渲染，图像对象保存在 `self._donate_photo`
   避免被垃圾回收导致白屏；
4. 全程不写任何临时文件，关闭弹窗即释放图像引用。

替换自己的收款码：

```text
1. 把新的收款码命名为 donate.png 放到 win1_gui.py 同目录；
2. python make_qr_payload.py
3. 重新运行/打包启动器
```

脚本会校验真实 PNG 文件头。如果图片其实是 JPEG 但被改名成 `.png`
（常见于微信/支付宝保存的图片），脚本会给出提示；安装 Pillow 后可自动转换，
或先用画图/截图工具另存为真正的 PNG。

`--selftest` 会额外输出一行载荷状态，便于确认打包是否带上加密数据：

```text
[DATA] qr payload   : OK (key 16B / data 69767B / plain-magic no)
```

## 配置项（config.json）

| 键 | 默认值 | 说明 |
| --- | --- | --- |
| `minecraft_dir` | `.minecraft` | 游戏目录，绝对路径；无 D 盘时回退 `<EXE目录>\game` |
| `launch_version` | 空 | 主页版本档案选中的版本 id；空 = 自动模式 |
| `mc_version` | `1.21.1` | 目标版本，可在 `[游戏] -> [游戏版本]` 切换 |
| `loader` | `fabric` | `fabric` / `quilt` / `forge` / `neoforge` / `vanilla`（模组筛选；自动安装仅 Fabric/原版） |
| `loader_version` | 空 | 空则自动解析 Fabric 稳定加载器版本 |
| `java` | 空 | 自定义 `java.exe` 路径；空 = 按版本要求自动挑选（内置 Java 见 `[游戏] -> [Java 运行时管理...]`） |
| `memory.min` / `memory.max` | `1024M` / `4096M` | JVM 内存参数；可在 `[设置] -> [外观 / 背景 / 内存...]` 用滑杆调整 |
| `version_isolation` | `false` | 版本隔离：`true` 时每个版本使用 `versions\<id>\` 作为独立游戏目录（模组 / 存档 / 配置各自独立） |
| `mod_filter_loader` | `auto` | 战备架加载器筛选：`auto` / `forge` / `neoforge` / `fabric` / `quilt` / `all` |
| `window.width` / `window.height` | `854` / `480` | 游戏窗口尺寸 |
| `client_id` | 公共 Xbox ID | 浏览器联动使用的 Client ID，一般无需修改 |
| `device_client_id` | 空 | 可选：Azure 公共客户端应用 ID；为空时使用内置 Xbox Client ID 的 Live 设备码 |
| `auth_flow` | `live` | `live`（内置设备码）/ `device`（Azure 设备码）/ `browser`（浏览器备用） |
| `download_source` | `mirror` | 原版下载源：`mirror`（默认，BMCLAPI 优先）/ `auto` / `official` |
| `wallpaper` | 空 | 自定义背景图片的绝对路径；空 = 纯白桌面。可在设置页最上方 `WALLPAPER` 区域导入 |
| `wallpaper_fit` | `cover` | 背景显示方式：`cover` 铺满裁切 / `contain` 完整显示（按主背景色留白） |
| `wallpaper_dim` | `0` | 背景压暗百分比 `0`-`60`，只压暗壁纸，不影响界面 |
| `panel_alpha` | `45` | 面板半透明百分比 `0`-`60`：`0` = 原来的纯白面板，越大壁纸透出越多（磨砂玻璃效果） |
| `jvm_args` | 空 | 追加的 JVM 参数（`-XX:...`），在设置页 `JVM // 启动参数` 里编辑或选预设 |
| `instances` | `{}` | 每个实例的游玩统计：`{"<版本id>": {"play_seconds": 7200, "last_played": 1760000000}}` |
| `mini_game_prompt` | `true` | 下载 / 启动时是否弹「要不要来一局贪吃蛇」提示（菜单与设置页都能关） |
| `snake_best` | `0` | 贪吃蛇最高分 |
| `game_2048_best` | `0` | 2048 最高分 |
| `minesweeper_best` | `0` | 扫雷最快通关秒数（0 = 未通关） |
| `tetris_best` | `0` | 俄罗斯方块最高分 |
| `theme.surface` / `theme.secondary` / `theme.accent` / `theme.text` | `#FFFFFF` / `#D4D0C8` / `#008080` / `#000000` | 启动器主题色，可在 `[设置] -> [外观 / 背景 / 内存...]` 修改 |
| `afdian_url` | 示例地址 | 爱发电个性主页；请替换为你自己的主页 |
| `modrinth.hot_limit` | `8` | 默认看板数量 |
| `modrinth.search_limit` | `20` | 检索结果数量 |
| `modrinth.index` | `downloads` | 默认榜单排序 |

## 快捷键

- 离线角色名输入框 `Enter`：点火。
- 搜索框 `Enter`：中文检索。
- 战备架列表 `Enter`：下载当前条目。
- 列表双击：直装。
- `[工具] -> [打开日志目录]`：查看 `launch-*.log`。

## 目录结构

```text
.\
├─ AKM_Launcher.exe     # 双击即可运行（已内置依赖）
├─ win1_gui.py          # 完整启动器源码
├─ config.json          # 自动生成
├─ auth.json            # 自动生成（含令牌，注意保密）
├─ mod_alias.json       # 自动生成的中英文词库（120 条）
├─ README_AKM.md
└─ logs\                # launch-*.log / selftest.log

.minecraft\
├─ mods\                # 全局模组（未开启版本隔离时使用）
├─ versions\            # Fabric / 原版版本清单与核心
│   └─ 26.3-forge-66.1.0\
│       ├─ mods\ config\ saves\   # 版本隔离时的独立目录
├─ libraries\           # 依赖库
├─ runtime\             # Mojang 运行时 + 内置 akm-java-8/11/17/21/25
└─ assets\              # 资源与语言文件
```

## 应用图标

- 源图：`tubiao.png`（59×60，32 位带透明通道）
- 生成物：`akm_icon.ico`（7 帧：16/24/32/48/64/128/256，BMP-DIB 帧格式）
- 运行时通过 `self.root.iconbitmap(default=...)` 应用到主窗口及后续弹出的所有
  对话框（`_apply_app_icon`，按 `_MEIPASS` → 程序目录的顺序查找）
- 打包时用 `--icon` 写入 EXE 资源，并用 `--add-data` 一并打包，保证窗口图标可用

更换图标：

```text
1. 用新的 tubiao.png 覆盖同名文件；
2. 重新生成 akm_icon.ico（多尺寸）；
3. 按下面的命令重新打包。
```

注意：如果只是把 PNG 改成 `.png` 扩展名的 ICO，或让 PyInstaller 直接处理带
PNG 压缩帧的 ICO，在没有 Pillow 的机器上 PyInstaller 会静默回退成默认图标。
本项目使用的 ICO 是 BMP-DIB 帧，不依赖 Pillow。

`--selftest` 会输出图标状态：

```text
[UI  ] app icon     : OK (akm_icon.ico, 372526B)
```

## 重新打包 EXE

```bat
python -m pip install --upgrade pyinstaller minecraft-launcher-lib
cd /d .
python -m PyInstaller --noconfirm --clean --onefile --windowed ^
  --name AKM_Launcher ^
  --icon ".\akm_icon.ico" ^
  --add-data ".\akm_icon.ico;." ^
  --distpath "." ^
  --workpath ".\_build" ^
  --specpath ".\_build" ^
  --collect-all minecraft-launcher-lib ^
  win1_gui.py
```

说明：

- `--windowed` 不弹控制台；`--onefile` 为单文件 EXE。
- EXE 同目录的 `config.json` / `auth.json` / `mod_alias.json` 与
  `logs\` 会持久保存，不会写入临时解包目录。
- 未签名 EXE 首次运行可能触发 Windows SmartScreen，选择“仍要运行”即可。
- 若只运行源码，则不需要打包步骤。

## 整合包导入（.mrpack / .zip）

入口：`[游戏] -> [导入整合包...]`。

- **Modrinth `.mrpack`（推荐，全自动）**
  1. 读取包内 `modrinth.index.json`，解析 `dependencies.minecraft`
     与 `forge` / `neoforge` / `fabric-loader` / `quilt-loader`
  2. 原版缺失时自动按 `download_source` 安装对应 MC 版本
  3. 自动安装对应加载器（已装则跳过）
  4. 生成独立实例 `versions\PACK-<包名>\`，复制加载器 profile 并改写 `id`，
     保留 `inheritsFrom` 指向基础版本
  5. 按 `files[]` 逐个下载到包内 `path`（校验 sha1、跳过
     `env.client = unsupported` 的仅服务端模组）
  6. 解压 `overrides` / `client-overrides`（内容平铺到实例根目录，防 zip-slip）
  7. 写 `akm_pack.json` 记录来源与失败清单
- **普通 `.zip`（部分导入）**
  - 仅提取 `mods` / `config` / `defaultconfigs` / `resourcepacks` /
    `shaderpacks` / `scripts` / `kubejs` 到新实例
  - 基础版本取当前选中的 `launch_version`（没有则 `mc_version`），
    复制其 profile 并 `inheritsFrom` 到原版本
  - 没有 `mods/` 目录会明确报错并建议改用 `.mrpack`
- 导入完成后自动：
  - 切换 `launch_version` 到新实例
  - 开启版本隔离（`version_isolation = true`），保证只加载该包 mods
  - 刷新左侧版本档案、版本栏、右侧榜单
- 导入过程有独立进度窗口（ASCII 进度条 + 当前文件名），可随时取消，
  已下载文件保留；重新导入同名包会复用/补齐文件。

## 联机教程（蓝盾 / 局域网）

入口：顶部菜单 `[工具] -> [联机教程（蓝盾 / 虚拟局域网）...]`。

- 教程页为可滚动文本，包含：
  1. 联机前准备（版本/加载器一致、模组一致、正版与离线区别、防火墙放行）
  2. **方案 A：蓝盾虚拟局域网**（房主建网络 → 好友加入 →
     复制虚拟 IP → 房主「对局域网开放」→ 好友 `IP:端口` 直连）
  3. 方案 B：公网 / 端口映射
  4. 常见问题（连接超时、Unknown host、Incompatible mod set、
     白名单、端口每次变化、离线进正版服被拒）
  5. 安全提示
- `[ 复制本机 IP ]`：自动列出本机 IPv4（优先 `10.` / `192.168.` / `172.`
  虚拟网段）并复制，弹窗展示全部地址
- `[ 复制教程全文 ]`：整段教程复制到剪贴板，方便发给好友
- 启动器**不内置也不提供蓝盾下载链接**，只讲使用方法；
  蓝盾请通过其官方渠道获取

## 自动更新

入口：`[设置] -> [检查更新...]` / `[设置] -> [自动更新设置...]`。

- 更新信息来自一个 JSON 清单（示例见 `update.example.json`）：

  ```json
  {
    "version": "1.4b4",
    "url": "https://example.com/AKM_Launcher_v1.4b4.zip",
    "sha256": "<zip 的 SHA256>",
    "page": "https://example.com/download",
    "notes": "更新说明"
  }
  ```

- 配置项：`config.json` 的 `update_url`（清单地址，留空=关闭）、
  `update_check`（启动时自动检查，默认 `true`）
- 启动后 1.5 秒静默检查（有更新才弹窗）；手动检查会提示「已是最新版本」
- 弹窗显示版本对比 + 更新说明，可选：
  - `[ 立即更新 ]`：下载 → 校验 SHA256 → 若是 zip 自动取出 `AKM_Launcher.exe`
    → 生成 `_apply_update.bat`（等待进程退出 → 覆盖 → 重启 → 自删）→ 自动重启
  - `[ 打开下载页 ]`：只跳转，不下载
  - `[ 稍后 ]`
- 源码运行时（非 EXE）不会自我替换，只提示下载地址
- 下载失败 / 校验失败会在弹窗中说明，并保留旧版本可继续使用

## 打包 / 签名 / CI

| 文件 | 用途 |
| --- | --- |
| `build.ps1` | 一键构建：读版本号 → 装依赖 → 重新生成收款码载荷 → PyInstaller → 可选签名 → 自检 → 生成 `release\` 目录 + zip + SHA256 |
| `sign.ps1` | Authenticode 签名（自动找 signtool，支持时间戳；`-CreateSelfSigned` 可生成测试证书） |
| `SIGNING.md` | 证书类型 / 购买建议 / 本地与 CI 签名步骤 |
| `.github/workflows/build.yml` | push `v*` tag 自动构建 + 可选签名 + 发布 Release + 上传 artifact |
| `update.example.json` | 自动更新清单模板 |
| `.gitignore` | 排除 `auth.json` / `config.json` / `.minecraft` / `logs` / 构建产物 |

本地出包：

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
# 带签名
powershell -ExecutionPolicy Bypass -File build.ps1 -Sign -PfxPath cert.pfx -PfxPassword ****
```

CI 签名需要仓库 Secrets：`WINDOWS_CERT_PFX_BASE64`、`WINDOWS_CERT_PASSWORD`
（没配置就跳过签名，照常出包）。


## 公开分发前检查清单

准备公开分享这个启动器时，建议按下面处理：

1. **不要打包敏感文件**
   - `auth.json`：里面有微软令牌（明文），分发前删除
   - `config.json`：含个人游戏目录、爱发电链接等，可删除让程序重新生成
   - `logs\`：含本机路径与登录日志
   - `mod_alias.json`：可保留（纯词库，无隐私）
2. **`.minecraft` 目录不要一起打包**（动辄十几 GB，且含存档与账号缓存）
   - 只发 `AKM_Launcher.exe`（+ 可选 `README_AKM.md`、`akm_icon.ico`）
3. **替换为你自己的赞助信息**（可选）
   - `config.json` 的 `afdian_url`
   - 收款码加密载荷需重新生成：改 `donate.png` 后运行
     `python make_qr_payload.py`，再重新打包
4. **首次运行提示**
   - 用户首次启动会自动在 EXE 同目录创建空 `.minecraft` 并写入默认
     `config.json`、`auth.json`、`mod_alias.json`
5. **依赖**
   - EXE 已内置 `minecraft-launcher-lib`，无需用户装 Python
   - 若用源码分发，需 `pip install minecraft-launcher-lib`


## 安全提示

- `auth.json` 内含 Refresh Token，请勿上传或分享。
- 赞助入口只通过 `webbrowser.open()` 打开配置的 HTTPS 页面，不接收、
  不存储任何支付凭据。
- 所有网络与子进程操作都在后台线程执行，Tkinter 主循环不会被阻塞。
  `python make_qr_payload.py` 生成 `qr_payload.py`，再改 `AFDIAN_URL`
- 第一次运行会自动生成 `config.json` / `auth.json`，这两个文件已在
  `.gitignore` 里，**不要提交**

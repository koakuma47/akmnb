# AKM Launcher (Adaptive Kinetic Minecraft) G1.17

**免费开源：不收费、无内购、无付费版 —— 任何向你收费的都是盗卖。**

一个 1985 Windows 复古风格的 Minecraft 启动器，作用是省掉手动装游戏这一步：

- 微软账号登录，或者离线登录
- 一键装好原版 + 模组加载器（Forge / NeoForge / Fabric / Quilt），自动配 Java
- 从 Modrinth 找模组、下载、检查版本是否对得上
- 顺手管实例、光影、材质包和整合包

## 下载

**最新正式版：G1.17**

- 直接下载：<https://github.com/koakuma47/akmnb/releases/download/vG1.17/AKM_Launcher_vG1.17.zip>
- 发布页（历史版本 + SHA256 校验文件）：<https://github.com/koakuma47/akmnb/releases/tag/vG1.17>

单文件免安装，解压后双击 `AKM_Launcher.exe` 就能用，不需要装 Python。
下载后想核对完整性，可以和发布页里 `SHA256.txt` 的值比对一下。

> **G1.17：模组装完先试跑一次 —— 进不去就自动把缺的前置补上。**
> 体检窗口新增 `[ 启动试跑 ]` 和「装完自动试跑」（默认开）：更新或补前置成功后，
> 自动用当前目标版本拉一次游戏，日志出现 `Sound engine started` 就立刻关掉算通过；
> 失败时解析 `Mod ID: 'x', Requested by: 'y'`（Forge/NeoForge）与
> `which is missing!`（Fabric/Quilt），自动从 Modrinth 按目标 MC + 加载器补装再复跑。
> **进得去但日志里有 `broken mod state` 也算没装对**，同样会补。
> 实测：只放 Alex's Mobs（缺 citadel）→ 12 秒判缺 → 自动补 `citadel-2.6.3`（SHA1 通过）→ 15 秒进主菜单。
>
> G1.16：新增「快速启动专用线路」，点火准备压到 0.81 秒；闪退会说人话（坏 jar / Java 版本 / 内存）。
> G1.15：用 76 个真实 1.20 Forge 模组（355 MB）跑通了「装 1.21.1 NeoForge → 体检 → 更新」全链路。
> G1.14：修体检窗口进度条压住选项行。
> G1.13：模组更新进度条 + 4 条 Range 分片下载（实测 34 KB/s → 51 KB/s）。
> G1.12：不再自动重扫/自动开装，逐行勾选决定更新哪个。

## 怎么用

1. 下载上面的 zip，解压到任意文件夹（别放在需要管理员权限的目录）
2. 双击 `AKM_Launcher.exe`
3. 登录：正版点 `[ 微软登录 ]` 按提示走；没有正版就切离线模式，填个名字
4. 左侧选版本 → `[ 下载 / 安装 ]` 装游戏 → 装好后点 `[ 点燃起飞 ]`
5. 装模组：右边「模组战备架」里翻热门榜或搜索，挑好后 `[ 装配所选 ]`

需要 Java 21，启动器会自己找；找不到可以在设置里手动指定 `javaw.exe`。

## 免费声明

- 这个启动器**完全免费**，不收费、没有内购、没有付费解锁版。
- 如果你在淘宝 / 闲鱼 / QQ 群之类的地方**花钱**买到它，那是盗卖，请立刻举报，别付款。
- 唯一官方地址是 <https://github.com/koakuma47/akmnb>，别处发的包不保证是原版。
- 源码以 MIT 协议开源，欢迎自己编译；但请不要拿它卖钱或做成收费版。

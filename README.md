# AKM Launcher (Adaptive Kinetic Minecraft) G1.3

**免费开源：不收费、无内购、无付费版 —— 任何向你收费的都是盗卖。**

一个 1985 Windows 复古风格的 Minecraft 启动器，作用是省掉手动装游戏这一步：

- 微软账号登录，或者离线登录
- 一键装好原版 + 模组加载器（Forge / NeoForge / Fabric / Quilt），自动配 Java
- 从 Modrinth 找模组、下载、检查版本是否对得上
- 顺手管实例、光影、材质包和整合包

## 下载

**最新正式版：G1.3**

- 直接下载：<https://github.com/koakuma47/akmnb/releases/download/vG1.3/AKM_Launcher_vG1.3.zip>
- 发布页（历史版本 + SHA256 校验文件）：<https://github.com/koakuma47/akmnb/releases/tag/vG1.3>

单文件免安装，解压后双击 `AKM_Launcher.exe` 就能用，不需要装 Python。
下载后想核对完整性，可以和发布页里 `SHA256.txt` 的值比对一下。

> **G1.3 更新：装原版变快了。** 之前 client.jar 这类大文件只开一条连接，实测只有
> 0.2~0.4 MB/s；现在 ≥4 MB 的文件会切成多段、按大小开 8/16/32 条连接同时拉，
> 同一条线路能到 1 MB/s 以上（32 连接实测峰值 2.3 MB/s），装 1.20.1 时客户端那一步
> 从 70 秒缩到 23 秒。另外 BMCLAPI 的 `/version/x/client` 其实是两次 302 跳到 Mojang，
> 现在只解析一次，分片直接连 CDN。

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

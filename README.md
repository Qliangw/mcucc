# MCUCC (MCU C Compiler) 通用智能体插件

MCUCC 是一款严格的、编译器中立的智能体插件，专为构建裸机单片机（MCU）工程而设计。它强制使用标准开源工具链（GCC/Clang），禁止生成专有的 IDE 配置文件（如 Keil/IAR），确保硬件与软件目录的严格分离，并建立了一个具备自分析与修复能力的编译闭环。

## 安装说明

抛弃冗繁的文件下载步骤。我们提供了一套系统级“网络引导程序（Network Bootstrapper）”。仅需复制对应操作系统的一行代码直接执行即可，它将依靠自身的流感知实时为您获取所有文件注入沙盒。

### Windows 系统
在终端（或 CMD 命令提示符）执行以下这行云抓取指令（无需安装 Git 或解压包）：
```powershell
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Qliangw/mcucc/main/install.ps1' -OutFile 'install.ps1'; .\install.ps1"
```

### Linux / Mac 系统
在系统自带 Bash 终端闭环执行：
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Qliangw/mcucc/main/install.sh)"
```

## 使用说明

安装配置完成后，您可以直接输入触发词 `/mcucc`，或正常提示 AI 助手（例如：“帮我初始化一个新的 MCU 工程”）。此时，该智能体插件将严格执行以下流程：

1. **环境验证**：静默调用 `scripts/check_env.ps1`，验证宿主机否已正确安装并暴露了所需的 GCC 编译器变量。
2. **沙盒级架构划分**：构建层级严谨的项目目录。强制将芯片手册、PCB 原理图等隔离于 `hardware/` 目录；所有相关的 C 源码和开发域隔离至 `software/` 目录。
3. **中立型 Makefile 生成**：输出一份基于 `CC` 环境变参的纯文本 `Makefile`，确保后续开发可在 `arm-none-eabi-gcc`、`clang` 等编译器链条间无痛平移。
4. **高能效排错（核心闭环）**：代码输出后自动隐匿执行 `make` 测试。遇到编译、链接报错时，AI 严禁立即提问并中止，必须自动溯源排查 `.ld` （链接脚本）与 `startup.s` （启动汇编）等底层细节直至成功。
5. **强实证交付**：仅当终端实际输出并验证 `.elf` 与 `.hex` 文件后，才向用户呈报最终运行无误的源码架构。

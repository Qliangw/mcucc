#!/bin/bash
# MCUCC Cloud Bootstrapper (Network-Aware)

BASE_URL="https://raw.githubusercontent.com/Qliangw/mcucc/main"
TARGET_DIR=""
AGENTS=""

# 兼容本地执行逻辑或管道流执行
PLUGIN_ROOT=$(dirname "$0")

get_mcucc_file() {
    local rel_path=$1
    local dest=$2
    local local_path="$PLUGIN_ROOT/$rel_path"
    if [ -f "$local_path" ]; then
        cp "$local_path" "$dest"
    else
        echo -e "    \033[1;30m[Cloud Fetch] Pulling -> $BASE_URL/$rel_path\033[0m"
        curl -sL "$BASE_URL/$rel_path" -o "$dest" || echo -e "\033[1;31m[ERROR] 下载 $rel_path 失败\033[0m"
    fi
}

echo -e "\n\033[1;36m[MCUCC Bootstrapper] 欢迎使用。请输入您要注入 MCUCC 的工程绝对路径？\033[0m"
read -p "（直接按 ENTER 键代表当前路径: $(pwd)）: " TARGET_DIR
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR=$(pwd)
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "\033[1;31m[ERROR] 目录未找到: $TARGET_DIR\033[0m"
    exit 1
fi

echo -e "\n\033[1;36m[MCUCC 云部署系统] 请选择 AI组合配置（支持多选，例如 1,3）\033[0m"
echo "  [1] Cursor IDE        (云端拉取并写入 .cursor/rules)"
echo "  [2] Claude / 纯终端   (由于剪贴板管控，Linux环境将只生成备忘入口链接)"
echo "  [3] 原生 .agents 规范 (跨网络重建层级)"
echo "  [4] 全系静默全装      (全部都要！)"
read -p "请输入: " AGENTS

echo -e "\n\033[1;33m=== 开始从云端部署安全屋至: $TARGET_DIR ===\033[0m"

if [[ $AGENTS == *"4"* || $AGENTS == *"1"* ]]; then
    mkdir -p "$TARGET_DIR/.cursor/rules"
    get_mcucc_file "cursor/rules/mcucc.mdc" "$TARGET_DIR/.cursor/rules/mcucc.mdc"
    echo -e "\033[1;32m[OK] Cursor IDE 核心规则写入完成 -> $TARGET_DIR/.cursor/rules\033[0m"
fi

if [[ $AGENTS == *"4"* || $AGENTS == *"2"* ]]; then
    README_PATH="$TARGET_DIR/MCUCC_CLAUDE_README.txt"
    echo "获取 MCUCC 架构法典（SKILL.md）请直达链接并复制其原文：" > "$README_PATH"
    echo "$BASE_URL/skills/mcucc/SKILL.md" >> "$README_PATH"
    echo -e "\033[1;32m[OK] Claude 规则纯净版链接入口 -> $README_PATH\033[0m"
fi

if [[ $AGENTS == *"4"* || $AGENTS == *"3"* ]]; then
    mkdir -p "$TARGET_DIR/.agents/skills/mcucc/scripts"
    get_mcucc_file "skills/mcucc/SKILL.md" "$TARGET_DIR/.agents/skills/mcucc/SKILL.md"
    get_mcucc_file "scripts/check_env.ps1" "$TARGET_DIR/.agents/skills/mcucc/scripts/check_env.ps1"
    echo -e "\033[1;32m[OK] 原生平台 .agents 规范代码库已映射落盘 -> $TARGET_DIR/.agents\033[0m"
fi

echo -e "\n\033[1;36m[MCUCC Installer] 🎯 云端部署完毕！\033[0m\n"

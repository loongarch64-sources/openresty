#!/bin/bash

TARGET_FILE="util/mirror-tarballs"

# 检查文件是否存在
if [ ! -f "$TARGET_FILE" ]; then
    echo "错误: 找不到文件 $TARGET_FILE"
    exit 1
fi

echo "正在通过 sed 注入 LoongArch 适配逻辑..."

# 使用 sed -i 进行原地修改
# 逻辑说明：
# 1. 查找模式：匹配包含 "openresty/luajit2" 和 "tar.gz" 的行（这是原脚本的特征）
# 2. 执行操作 (c\)：将匹配到的整行替换为下面的多行代码块
# 3. 注意：Shell 变量 $ver 在 sed 中需要转义为 \$ver，以便在生成的脚本中保留变量形式

sed -i.bak -E '
/github.com\/openresty\/luajit2.*tar.gz/{
# 读取下一行 (即 tar -xzf ...) 到模式空间
N
# 将当前行(下载)和下一行(解压)替换为新的 LoongArch 代码块
c\
# LoongArch 适配：强制使用 Loongson 分支的 ZIP 包 \
URL="https://github.com/loongson/luajit2/archive/refs/heads/v2.1-agentzh-loongarch64.zip" \
FILENAME="LuaJIT-$ver.zip" \
$root/util/get-tarball "$URL" -O "$FILENAME" || exit 1 \
unzip "$FILENAME" || exit 1 
}
' "$TARGET_FILE"

# 修正清理逻辑：在清理命令中追加 *.zip
# 匹配 rm -f *.tar.gz 或类似的清理行
sed -i.bak2 '/rm \*\.tar\.bz2/a\rm *.zip' "$TARGET_FILE"

# 清理备份文件
rm -f "$TARGET_FILE".bak "$TARGET_FILE".bak2

echo "修改完成。"

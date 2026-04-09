#!/bin/bash
set -euo pipefail

UPSTREAM_OWNER=openresty
UPSTREAM_REPO=openresty
VERSION="${1}"
echo "   🏢 Org:   ${UPSTREAM_OWNER}"
echo "   📦 Proj:  ${UPSTREAM_REPO}"
echo "   🏷️  Ver:   ${VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DISTS="${ROOT_DIR}/dists"
SRCS="${ROOT_DIR}/srcs"

mkdir -p "${DISTS}/${VERSION}" "${SRCS}"

# ==========================================
# 👇 用户自定义构建逻辑 (示例)
# ==========================================

echo "🔧 Compiling ${UPSTREAM_OWNER}/${UPSTREAM_REPO} ${VERSION}..."

# 1. 准备阶段：安装依赖、下载代码、应用补丁等
prepare()
{
    echo "📦 [Prepare] Setting up build environment..."
    
    # TODO: 在此处添加准备命令
    # 例如：apt-get update && apt-get install -y build-essential
    # 例如：git clone -b ${VERSION} --depth=1 https://github.com/openresty/openresty ${SRCS}/${VERSION}
    # 例如：patch -p1 < patches/loongarch-fix.patch
    
    if [ ! -d "${SRCS}/${VERSION}" ]; then
    	git clone -b ${VERSION} --depth=1 https://github.com/openresty/openresty ${SRCS}/${VERSION}
        pushd ${SRCS}/${VERSION}
        ${SCRIPT_DIR}/patch.sh
        popd
    fi

    
    echo "✅ [Prepare] Environment ready."
}

# 2. 编译阶段：核心构建命令
build()
{
    echo "🔨 [Build] Compiling source code..."
    
    # TODO: 在此处添加编译命令
    # 例如：make -j$(nproc) ARCH=loongarch64
    # 例如：cmake -DCMAKE_BUILD_TYPE=Release .. && make
    
    pushd ${SRCS}/${VERSION}
    ./util/mirror-tarballs
    popd
    echo "✅ [Build] Compilation finished."
}

# 3. 后处理阶段：整理产物、清理临时文件、验证版本
post_build()
{
    echo "📦 [Post-Build] Organizing artifacts..."
    
    # TODO: 在此处添加整理命令
    # 例如：mkdir -p dists && cp binary dist/${VERSION}
    # 例如：strip dist/binary
    
    mv ${SRCS}/${VERSION}/openresty-${VERSION#v}.tar.gz ${DISTS}/${VERSION}/
    echo "✅ [Post-Build] Artifacts ready in ./dists/${VERSION}."
}

# 主入口
main()
{
    prepare
    build
    post_build
}

main

# ==========================================
# 👆 自定义逻辑结束
# ==========================================

cat > "${DISTS}/${VERSION}/release.txt" <<EOF
Project: ${UPSTREAM_REPO}
Organization: ${UPSTREAM_OWNER}
Version: ${VERSION}
Build Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

echo "✅ Compilation finished."
ls -lh "${DISTS}/${VERSION}"

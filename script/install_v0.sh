#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 检查并安装 unzip
if ! command -v unzip >/dev/null 2>&1; then
    echo -e "${GREEN}未检测到 unzip，正在尝试安装...${NC}"
    if command -v apt >/dev/null 2>&1; then
        apt update && apt install -y unzip
    elif command -v yum >/dev/null 2>&1; then
        yum install -y unzip
    else
        echo "无法自动安装 unzip，请手动安装后重试。"
        exit 1
    fi
fi

# 下载 nezha-agent.zip
# 判断系统架构
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_FILE="nezha-agent-amd.zip"
elif [ "$ARCH" = "aarch64" ] || [[ "$ARCH" =~ "arm" ]]; then
    DOWNLOAD_FILE="nezha-agent-arm.zip"
else
    echo -e "未检测到支持的架构: $ARCH"
    exit 1
fi

echo -e "${GREEN}检测到系统架构为: ${ARCH}${NC}"
echo -e "${GREEN}正在下载 ${DOWNLOAD_FILE}...${NC}"

# 执行下载
wget -O nezha-agent.zip "https://gh.635635.xyz/https://github.com/johntea11/nezha/releases/download/v0/${DOWNLOAD_FILE}"

# 解压文件
echo -e "${GREEN}解压 nezha-agent...${NC}"
unzip -o ${DOWNLOAD_FILE}

# 创建目录并移动文件
echo -e "${GREEN}创建目录并移动文件...${NC}"
mkdir -p /opt/nezha/agent
mv nezha-agent /opt/nezha/agent/
chmod +x /opt/nezha/agent/nezha-agent

# 获取用户输入
read -p "请输入哪吒服务端 域名或IP:端口 ：" NEZHA_SERVER
read -p "请输入哪吒服务端 密钥 ： " NEZHA_KEY

# 创建 systemd 服务文件
echo -e "${GREEN}创建 systemd 启动服务...${NC}"
cat <<EOF > /etc/systemd/system/nezha-agent.service
[Unit]
Description=哪吒探针监控端
ConditionFileIsExecutable=/opt/nezha/agent/nezha-agent

[Service]
StartLimitInterval=5
StartLimitBurst=10
ExecStart=/opt/nezha/agent/nezha-agent -s ${NEZHA_SERVER} -p ${NEZHA_KEY}
WorkingDirectory=/root
Restart=always
RestartSec=120
EnvironmentFile=-/etc/sysconfig/nezha-agent

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd，启用并启动服务
echo -e "${GREEN}启动哪吒探针服务...${NC}"
systemctl daemon-reload
systemctl enable nezha-agent
systemctl restart nezha-agent

# 提示完成
echo -e "${GREEN}哪吒探针已安装并启动成功！${NC}"

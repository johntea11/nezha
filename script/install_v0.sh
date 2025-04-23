#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 下载 nezha-agent.zip
echo -e "${GREEN}正在下载 nezha-agent.zip...${NC}"
wget -O nezha-agent.zip https://gh.635635.xyz/https://github.com/johntea11/nezha/releases/download/v0/nezha-agent.zip

# 解压文件
echo -e "${GREEN}解压 nezha-agent.zip...${NC}"
unzip -o nezha-agent.zip

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

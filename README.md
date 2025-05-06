# LinuxEnvConfig

Ubuntu / Debian / Kali Linux 基础环境配置脚本

```
 ─────────────────────────────────────────────────────

    *************  LinuxEnvConfig  *************

    适配系统: Ubuntu / Debian / Kali (基于Debian)
    脚本作用: Linux 基础环境配置

                --- Made by mingy ---

 ─────────────────────────────────────────────────────
```

## 脚本使用

```bash
git clone https://gitee.com/yijingsec/LinuxEnvConfig.git

cd LinuxEnvConfig

sudo bash LinuxEnvConfig.sh
```

![image](images/image.png)

## 脚本功能

1. 基础配置
2. 配置 APT
3. 配置 JDK
4. 配置 Miniconda3
5. 配置 Docker
6. 配置 Docker-compose
7. 配置 Vulfocus
8. 配置 ARL
9. 配置 Metasploit-framework
10. 配置 Viper
11. 配置 Empire
12. 配置 Starkiller
13. 配置 Dnscat2
14. 配置 Beef
15. 配置 Bluelotus
16. 配置 HFish
17. 配置 CTFd
18. 配置 AWVS
19. 配置 ocr_api_server
20. 配置 oh-my-zsh

### 基础配置

1. 启用 ROOT 用户
2. 启用 SSH 服务
3. 允许 ROOT 用户 SSH 登录
4. 设置 NameServer
5. 获取当前主机网卡及 IP 地址信息
6. 解除 DNS 协议 53 端口占用
7. 返回主菜单

### 配置 APT

> **APT 源**: 是Linux系统（如Debian/Ubuntu）的软件包管理仓库，提供海量开源软件的安装和更新服务，支持自定义镜像源加速下载，是系统维护和软件部署的核心基础设施。

1. 华为云
2. 阿里云
3. 腾讯云
4. 清华大学
5. 北京大学
6. 中国科大
7. 官方APT源

### 配置 JDK

> **JDK**: 作为Java开发工具集合，包含编译器、调试器等核心组件，是任何Java程序开发和运行的基础环境。

1. 安装 OracleJDK
2. 安装 OpenJDK
3. 删除当前 JDK 环境
4. 返回主菜单

#### 安装 OracleJDK

> **OracleJDK**: 是Oracle公司维护的Java商业版本，包含性能优化和商业支持，适合企业级应用开发。

1. Oracle JDK 8 LTS
2. Oracle JDK 11 LTS
3. Oracle JDK 17 LTS
4. Oracle JDK 21 LTS
5. Oracle JDK 22 LTS
6. Oracle JDK 23 LTS
7. 返回主菜单

#### 安装 OpenJDK

>  **OpenJDK**: 是开源的Java开发工具包，完全遵循GPL协议，为开发者提供跨平台的Java运行和开发环境。

1. OpenJDK 11 LTS
2. OpenJDK 17 LTS
3. OpenJDK 21 LTS
4. OpenJDK 22 LTS
5. OpenJDK 23 LTS
6. 返回到主菜单

### 配置 Miniconda3

>  **Miniconda3**: 是Anaconda的轻量级替代版本，仅包含Python和Conda基础环境，支持快速创建隔离的虚拟环境，专为科学计算和数据分析开发者提供灵活的包管理方案。

1. 安装 Miniconda3
2. 卸载 Miniconda3
3. 配置 Miniconda3 软件源
4. 返回主菜单

### 配置 Docker

>  **Docker**: 是领先的容器化平台，利用轻量级虚拟化技术实现应用隔离，显著提升开发测试和部署效率。

1. 安装 Docker
2. 卸载 Docker
3. 配置 Docker 国内镜像
4. 获取 Docker 国内镜像源配置
5. 取消 Docker 国内镜像
6. 配置 Docker 网络代理
7. 获取 Docker 网络代理配置
8. 取消 Docker 网络代理
9. 更新 Docker 镜像源列表
10. 拉取 Docker 镜像
11. 返回主菜单

### 配置 Docker-compose

>  **docker-compose**: 作为容器编排工具，通过YAML文件定义多容器应用，简化了复杂微服务环境的部署和管理流程。

1. 安装 Docker-compose
2. 卸载 Docker-compose
3. 返回主菜单

### 配置 Vulfocus

>  **Vulfocus**: 专注于漏洞靶场环境，提供一键部署的漏洞复现场景，可用于安全研究、教学培训和攻防演练。

1. 安装 Vulfocus
2. 卸载 Vulfocus
3. 返回主菜单

### 配置 ARL

>  **ARL**:（Asset Reconnaissance Lighthouse）资产侦察灯塔系统，自动化收集子域名、端口服务等信息，帮助安全团队快速绘制企业网络资产图谱。

1. 安装 ARL
2. 停止 ARL
3. 启动 ARL
4. 卸载 ARL
5. 添加指纹
6. 返回主菜单

### 配置 Metasploit-framework

> **Metasploit-framework**: 是最著名的渗透测试框架，包含数千个漏洞利用模块，提供从扫描到提权的完整攻击链，是安全研究人员必备工具。

1. 安装 Metasploit-framework
2. 卸载 Metasploit-framework
3. 返回主菜单

### 配置 Viper

>  **Viper**: 是一款模块化渗透测试平台，集成多种漏洞利用模块，支持团队协作和会话管理，主要服务于专业安全人员的红队评估工作。

1. 安装 Viper
2. 更新 Viper 版本
3. 更新 Viper 密码
4. 启动 Viper
5. 关闭 Viper
6. 卸载 Viper
7. 返回主菜单

### 配置 Empire

>  **Empire**: 作为PowerShell后渗透框架，具有免杀性强、模块丰富等特点，适用于Windows域环境下的权限维持、横向移动等高级持续性威胁模拟。

1. 安装 Empire
2. 更新 Empire
3. 启动 Empire
4. 关闭 Empire
5. 卸载 Empire
6. 返回主菜单

### 配置 Starkiller

>  **Starkiller**: 是Empire框架的现代化图形界面，简化了命令控制操作流程，支持模块化攻击载荷管理，使后渗透测试更加高效直观。

1. 安装 Starkiller
2. 更新 Starkiller
3. 关闭 Starkiller
4. 启动 Starkiller
5. 卸载 Starkiller
6. 返回主菜单

### 配置 Dnscat2

>  **DNSCat2**: 是一款基于DNS协议的隐蔽通信工具，利用DNS查询建立加密隧道，常被红队用于绕过防火墙限制，实现C2远控和数据渗透。

1. 安装 Dnscat2
2. 启动 Dnscat2 (直连模式)
3. 启动 Dnscat2 (中继模式)
4. 返回主菜单

### 配置 Beef

>  **BeEF**: 作为浏览器漏洞利用框架，专注于客户端攻击，能够通过XSS等漏洞控制受害者浏览器，实现会话劫持、内网探测等渗透测试功能。

1. 安装 Beef
2. 关闭 Beef
3. 启动 Beef
4. 卸载 Beef
5. 返回主菜单

### 配置 Bluelotus

> **BlueLotus_XSSReceiver**: 是一款专为 **XSS漏洞实战检测与数据分析** 设计的开源平台，由国内知名安全团队蓝莲花（BlueLotus）开发。其核心功能是作为 **恶意XSS攻击数据的接收端**，通过部署在云服务器或内网的Web服务，实时捕获攻击者通过XSS漏洞触发的请求（如Cookie劫持、页面重定向、键盘记录等），并提供可视化日志、攻击溯源和自动化告警功能。

1. 安装 Bluelotus
2. 关闭 Bluelotus
3. 启动 Bluelotus
4. 卸载 Bluelotus
5. 返回主菜单

### 配置 HFish

> **HFish**: 是一款开源的分布式蜜罐平台，具有多协议支持、高交互性和实时告警等特点，主要用于构建欺骗防御体系，通过模拟各类服务诱捕攻击者行为并收集威胁情报。

1. 安装 HFish
2. 更新 HFish
3. 关闭 HFish
4. 启动 HFish
5. 卸载 HFish
6. 获取数据库信息
7. 返回主菜单

### 配置 CTFd

> **CTFd**: 是一个开源的 **CTF（Capture The Flag，夺旗赛）平台框架**，专为网络安全竞赛设计。它提供了题目管理、队伍排名、动态积分、自动化计分等功能，适用于线下/线上 CTF 比赛、教学演练或企业内训。

1. 安装 CTFd
2. 卸载 CTFd
3. 返回主菜单

### 配置 AWVS

> **AWVS**:（Acunetix Web Vulnerability Scanner）是一款知名的 **自动化 Web 应用安全扫描工具**，由 Acunetix 公司开发，主要用于检测网站、Web 应用程序和 API 中的安全漏洞。它被广泛用于渗透测试、安全审计和漏洞管理，帮助开发者和安全团队快速发现并修复潜在风险。

1. 安装 AWVS
2. 卸载 AWVS
3. 返回主菜单

### 配置 ocr_api_server

> **ocr_api_server**: 使用ddddocr库构建的最简OCR（光学字符识别）API服务器。它支持通过Docker部署，并提供了多种运行方式和参数配置，以满足不同的OCR和目标检测需求。项目的主要功能包括OCR识别、目标检测以及滑块验证的处理。

1. 安装 ocr_api_server
2. 卸载 ocr_api_server
3. 返回主菜单

### 配置 oh-my-zsh

> **oh-my-zsh**: 是一个基于 Zsh（一种功能强大的 Unix/Linux Shell）的开源框架，用于管理和增强 Zsh 的配置。它提供了丰富的主题、插件和便捷的功能，大幅提升了终端的使用体验，尤其适合开发者和系统管理员。

1. 安装 oh-my-zsh
2. 更新 oh-my-zsh
3. 卸载 oh-my-zsh
4. 配置 oh-my-zsh 主题
5. 配置 oh-my-zsh 插件
6. 返回主菜单

### 配置crAPI

> **crAPI**: OWASP crAPI（Completely Ridiculous API）是由OWASP（开放 Web 应用安全项目）推出的一个专门用于 API 安全测试和学习的靶场项目。API（应用程序编程接口）在各类软件系统中扮演着至关重要的角色。然而，API 的安全问题也日益凸显。OWASP crAPI 正是为了帮助安全专业人员、开发人员和爱好者更好地理解和实践 API 安全测试而设计的。它提供了一个模拟真实 API 环境的平台，让用户可以在其中尝试各种攻击技术，学习如何发现和修复 API 中的安全漏洞。

1. 安装 crAPI 靶场
2. 卸载 crAPI 靶场
3. 停止 crAPI 靶场
4. 启动 crAPI 靶场
5. 返回主菜单
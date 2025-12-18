#!/bin/bash

# 检查Python3和pip3环境配置的脚本

# 检查python3是否存在
check_python3() {
    if command -v python3 &> /dev/null; then
        echo "✓ python3 found: $(command -v python3)"
        PYTHON3_VERSION=$(python3 --version)
        echo "  Version: $PYTHON3_VERSION"
        return 0
    else
        echo "✗ python3 not found"
        return 1
    fi
}

# 检查pip3是否存在
check_pip3() {
    if command -v pip3 &> /dev/null; then
        echo "✓ pip3 found: $(command -v pip3)"
        PIP3_VERSION=$(pip3 --version)
        echo "  Version: $PIP3_VERSION"
        return 0
    else
        echo "✗ pip3 not found"
        return 1
    fi
}

# 配置pip国内镜像源
configure_pip_mirror() {
    echo "Configuring pip mirror..."

    # 获取用户主目录
    USER_HOME=$(eval echo ~$USER)

    # 创建pip配置目录
    mkdir -p "$USER_HOME/.pip"

    # 配置阿里云镜像源
    cat > "$USER_HOME/.pip/pip.conf" << EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host = mirrors.aliyun.com
EOF

    echo "✓ Pip mirror configured successfully"
    echo "  Configuration file: $USER_HOME/.pip/pip.conf"
    echo "  Mirror source: Aliyun (https://mirrors.aliyun.com/pypi/simple/)"

    # 验证配置
    echo "Verifying configuration..."
    pip3 config list | grep index-url
}

# 创建虚拟环境
create_virtual_environment() {
    echo "Creating virtual environment..."
    if python3 -m venv venv; then
        echo "✓ Virtual environment created successfully"
        return 0
    else
        echo "✗ Failed to create virtual environment"
        return 1
    fi
}

# 激活虚拟环境
activate_virtual_environment() {
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        echo "✓ Virtual environment activated"
        return 0
    else
        echo "✗ Virtual environment activation script not found"
        return 1
    fi
}

# 安装初始依赖包
install_requirements() {
    if [ -f "init-requirements.txt" ]; then
        echo "Installing initial requirements..."
        if pip install -r init-requirements.txt; then
            echo "✓ Requirements installed successfully"
            return 0
        else
            echo "✗ Failed to install requirements"
            return 1
        fi
    else
        echo "⚠ init-requirements.txt not found, skipping requirement installation"
        return 0
    fi
}

# 主函数
main() {
    echo "Checking Python3 environment configuration..."

    # 执行所有检查
    if check_python3 && check_pip3; then
        echo "All checks passed!"

        # 配置pip镜像源
        configure_pip_mirror

        # 创建并激活虚拟环境
        if create_virtual_environment && activate_virtual_environment; then
            # 安装依赖包
            install_requirements
        fi

        echo "Python3 environment check and configuration completed!"
    else
        echo "Environment check failed!"
        exit 1
    fi
}

# 执行主函数
main

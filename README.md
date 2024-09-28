
## 第 1 章 VSCode C 程序开发入门：基础环境搭建

一个简单的 C 程序示例，展示如何用 VSC (VSCode) 开发、编译和调试64位程序，该程序运行的目标主机在 Windows 和 Linux 上，开发环境是 Windows 10 Home。

该示例展示了如何配置 VSC 工程，以适应不同的编译和运行环境。

### 1.1 环境搭建

- [VSCode](https://code.visualstudio.com/)
  
  [下载 VSCodeUserSetup-x64-1.93.1.exe](
  https://vscode.download.prss.microsoft.com/dbazure/download/stable/38c31bc77e0dd6ae88a4e9cc93428cc27a56ba40/VSCodeUserSetup-x64-1.93.1.exe)

- [MSYS2](https://www.msys2.org/)

  [下载 msys2-x86_64-20240727.exe](https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe)

  下载安装完毕打开 msys2.exe，在命令行窗口安装下面的组件。或者下载相应的源码包安装：

    - MinGW64 （必备）
    - MinGW32 （可选）
    - UCRT64 （可选）
    - CLANG64 （可选）

- [cygwin64](https://cygwin.com/)

  这个用于从 Windows 上 ssh  登录到 Linux 机器的命令行工具。（可选）
  
- 配置系统环境变量

  以上软件安装完毕，列出 Windows 系统环境变量。我习惯于把开发环境安装在 DEVPACK 目录下面，程序代码放在 WORKSPACE 下面。路径名称里不能包含空格、中文等。我的配置如下:

        _DEVPACK_ROOT=C:\DEVPACK
        _DEVPACK_ROOT_BASH=/C/DEVPACK

        _WORKSPACE_ROOT=C:\WORKSPACE
        _WORKSPACE_ROOT_BASH=/C/WORKSPACE

        // 这里的 MSYS2_PATH_TYPE=inherit 将从 Windows 继承 PATH 环境变量
        MSYS2_PATH_TYPE=inherit
        MSYS2_HOME=%_DEVPACK_ROOT_BASH%/msys64

        MINGW64_BIN_PATH=%_DEVPACK_ROOT%\msys64\mingw64\bin
        MINGW64_BIN_PATH_BASH=%_DEVPACK_ROOT_BASH%/msys64/mingw64/bin

        MINGW64_ROOT=%_DEVPACK_ROOT%\msys64\mingw64
        MINGW64_ROOT_BASH=%_DEVPACK_ROOT_BASH%/msys64/mingw64

        MSVSCODE_HOME=%_DEVPACK_ROOT%\MicrosoftVSCode
        NASM_WIN64_HOME=%_DEVPACK_ROOT%\MicrosoftVSCode%\nasm-2.15.05\nasm-2.15.05-win64

        CYGWIN_HOME=%_DEVPACK_ROOT%\cygwin64

  **NOTE：** 必须确保环境变量配置正确。由于 Windows 环境变量展开次序按字母排序，所以在字母表后面的环境变量名才能引用字母表前面的变量名。字母开头的环境变量总是能引用到下划线开头的环境变量。如果环境变量首字母一样，则比较第二个字母，依次类推。

### 1.2 编写示例

#### 1.2.1 创建工程目录 helloworld

工程目录结构如下（/ 表示目录，否则是文件）：

```
helloworld/                      (项目/工程目录)
    |
    +-- .gitignore
    +-- .vscode/                 (该目录存放 VSCode 用到的配置文件)
        |
        +-- c_cpp_properties.json
        +-- launch.json
        +-- settings.json
        +-- tasks.json
    +-- build/                   (编译产生的临时文件存放目录)
    +-- dist/                    (最终发布的程序文件存放目录)
    +-- src/                     (放源代码的目录)
        |
        + common/
            |
            +-- cstrbuf.h        (引用的头文件)
        +-- helloworld.c         (main 函数程序源文件)
    +-- LICENSE
    +-- README.md
    +-- Makefile
    +-- ...

```

#### 1.2.2 修改 VSCode 配置文件

- c_cpp_properties.json
  
  主要由微软提供的 C/C++ 扩展（C/C++ extension from Microsoft）使用。它主要用于:

  - 提供更好的代码补全和代码分析功能。
  - 指定使用的编译器及其版本。
  - 设置头文件搜索路径和预处理器宏定义。
  - 为不同的开发平台定制不同的配置。

- launch.json
  
  用于配置调试会话的文件。它定义了调试器如何启动和运行程序。这里我们都统一使用 gdb 调试 cppdbg 类型的程序。当我们用 VSC 双击打开 helloworld.c 文件，按 [F5]，就会启动调试，VSC 会在它左上角让你选择一个 launch 项（由下面的 name 指定，windows 上调试本地程序选：(debug) mingw run），然后启动对应的调试配置，其中 preLaunchTask 说明 launch 之前运行的 task 的 label，所以要配置好这个 task（在 tasks.json 中）。下面的 launch.json 含有2个调试启动项：

    ```
    {
        "version": "0.2.0",
        "configurations": [        
                {
                "name": "(debug) mingw run",
                "preLaunchTask": "mingw64 debug",
                },
                {
                "name": "(debug) linux run",
                "preLaunchTask": "linux64 debug",
                }
        ]
    }
    ```

- tasks.json

  用于配置任务（tasks）的文件。这些任务可以是编译代码、运行测试、构建项目等自动化任务。每个任务有一个唯一的标签 label 指定，通常写一个 shell 脚本作为任务执行的 command。然后按菜单：... > 终端 > 运行 > 任务；或者当你启动调试会话时，VSCode 会先执行 preLaunchTask 中指定的 task (tasks.json 中定义的任务)，然后再启动调试。

  任务的主要功能和用途：
   
    - 编译代码：如编译 C++ 或 Java 代码。
    - 运行脚本：如执行 Python 或 Shell 脚本。
    - 构建项目：如使用构建工具（Make、Gradle、Maven）构建项目。
    - 其他任务：如清理生成文件、打包等。

  例如下面的 tasks.json 含有 3 个任务：
  
  ```
    {
	// See https://go.microsoft.com/fwlink/?LinkId=733558
	// for the documentation about the tasks.json format
	"version": "2.0.0",
	"tasks": [
		{
			"label": "mingw64 debug",
			"type": "shell",
			"command": "${env:VULKAN_DEV_ROOT_BASH}/Samples/${workspaceFolderBasename}/make-debug-x86_64.sh"

		},
		{
			"label": "linux64 debug",
			"type": "shell",
			"command": "${workspaceFolder}/make-debug-x86_64.sh"
		},
		{
			"label": "Task: test vars",
			"type": "shell",
			"command": "echo",
			"args": [
				"${env:VULKAN_DEV_ROOT_BASH}/Samples/${workspaceFolderBasename}"
			]
		}
	]
  }
  ```

- settings.json

  用于定义 VSC 的外观和行为。比如命令行窗口等。

  - 全局设置（文件 -> 首选项 -> 设置 -> 用户）
  
    C:/Users/用户名/AppData/Roaming/Code/User/settings.json

  - 项目设置（文件 -> 首选项 -> 设置 -> 工作区）
  
    .vscode/settings.json
  
  尽量不要更改全局设置。  


#### 1.2.3 开始写 C 代码 helloworld.c

  按标准 C 格式写代码，写 Makefile 文件，配置任务，然后按 [F5] 调试。可以设置断点，查看变量的值。

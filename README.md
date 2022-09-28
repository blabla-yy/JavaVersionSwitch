#  JavaVersionSwitch
macOS JDK版本切换GUI(SwiftUI)应用


![Image text](https://raw.github.com/blabla-yy/repositry/main/JavaVersionSwitch/screenshot.png)

## 特点
- 一键切换zsh Java环境
- 支持自动获取当前JDK信息。
- 支持自动获取macOS内置JDK，以及HomeBrew安装的JDK信息

## 系统要求
- SwiftUI框架限制，需要macOS 12.0以上
- 目前仅支持zsh

## 说明
- 只是一个简单的小应用，还没有开发错误信息提示。
- 工作原理是根据选择的jdk制作软链接，并在~/.zshrc中配置了PATH。所以卸载后，请手动删除这些的配置。


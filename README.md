# libsodium Windows ARM64 Builder

> [!IMPORTANT]
> **Unofficial project / 非官方项目**
>
> 本仓库不是 libsodium 官方仓库，也不是 libsodium 官方发布渠道或官方二进制分发文件。
> 本仓库由第三方维护，仅使用 GitHub Actions 从
> [libsodium 官方上游仓库](https://github.com/jedisct1/libsodium)
> 获取源码，在原生 Windows ARM64 runner 上构建、测试并打包二进制文件。
>
> 本项目与 libsodium 上游作者/维护者没有隶属、赞助或背书关系。
> 如需官方源码、官方发布包、安全公告或支持，请以 libsodium 官方渠道为准。

用 GitHub Actions 自动构建、测试并打包 **Windows ARM64 (AArch64)** 版本的
[libsodium](https://github.com/jedisct1/libsodium)。

本仓库 **不修改、不重新许可 libsodium**。libsodium 仍由其原作者按照
**ISC License** 授权。由本仓库生成的第三方二进制包会包含上游 `LICENSE`
文件以及可追溯的构建元数据。

## 项目定位

这个仓库提供的是：

- 第三方构建脚本和 GitHub Actions workflow
- 从官方 libsodium upstream 获取源码后的 Windows ARM64 原生构建
- 自动测试、打包、SHA-256 校验与构建信息记录
- 可选的 GitHub Release 自动发布

这个仓库 **不提供或声称提供**：

- libsodium 官方发布文件
- libsodium 官方签名或官方构建证明
- libsodium 官方支持
- 对第三方生成二进制与官方二进制完全一致的保证

如果你的使用场景对供应链、合规或密码学组件来源有严格要求，请自行审核
workflow、锁定上游 commit、验证构建日志，并根据需要进行独立复现构建和签名。

## 特性

- Windows ARM64 原生 GitHub-hosted runner：`windows-11-arm`
- 使用 libsodium 官方支持的 Zig 构建入口
- 默认使用固定的 Zig 0.15.2 稳定版本，避免 nightly 漂移；该版本作为当前发布基线
- 同时构建 static + shared
- 在 ARM64 Windows runner 上执行 libsodium 测试
- 自动生成 SHA-256 校验文件
- 每个 ZIP 都包含 libsodium 上游许可证
- 支持手动指定 upstream branch / tag / commit
- 推送 `libsodium-*` tag 时自动创建 GitHub Release
- 不把 libsodium 源码 vendoring 到本仓库，始终从官方 upstream checkout

## 推荐用法

### 1. 创建 GitHub 仓库

将本仓库内容直接推送到你自己的 GitHub 仓库：

```bash
git init
git add .
git commit -m "Initial Windows ARM64 libsodium builder"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/YOUR_REPO.git
git push -u origin main
```

### 2. 手动构建

进入 GitHub：

`Actions` → `Build libsodium Windows ARM64` → `Run workflow`

默认构建：

```text
stable
```

也可以指定：

```text
1.0.22-RELEASE
1.0.21-RELEASE
master
stable
<commit SHA>
```

默认 Zig 版本固定为：

```text
0.15.2
```

手动 workflow 也允许显式指定其他 Zig 版本用于兼容性测试。

> 对可重复发布，建议同时锁定 libsodium release tag/commit SHA 和 Zig 版本，
> 不要把浮动的 `stable`、`master` 或 Zig nightly 当作正式发布基线。

### 3. 创建正式 Release

例如希望发布 libsodium `1.0.22-RELEASE`：

```bash
git tag libsodium-1.0.22-RELEASE
git push origin libsodium-1.0.22-RELEASE
```

Workflow 会自动：

1. 从 `jedisct1/libsodium` checkout `1.0.22-RELEASE`
2. 在 Windows ARM64 上构建
3. 运行 ARM64 原生测试
4. 打包 ZIP
5. 生成 SHA256
6. 创建对应 GitHub Release

> Release 仍然是 **本仓库的非官方第三方构建产物**，不是 libsodium 官方 Release。

## 产物

ZIP 的内容类似：

```text
libsodium-windows-arm64/
├── include/
├── lib/
├── bin/
├── LICENSE.libsodium
└── BUILD-INFO.txt
```

实际库文件名由 libsodium 的官方 Zig 构建规则决定。MSVC ABI 的 shared library
通常使用 `sodium` 作为库名，因此请以 ZIP 中实际文件为准，不要在下游脚本中
假设 DLL 一定叫 `libsodium.dll`。

每个 Release/Artifact 的使用者都应同时核对：

- `BUILD-INFO.txt` 中的上游 ref / commit
- workflow 日志中实际使用的 Zig 版本
- `SHA256SUMS.txt`
- ZIP 内的 `LICENSE.libsodium`

## 下游 CMake 示例

推荐显式指定头文件目录和实际生成的 `.lib`：

```cmake
find_path(SODIUM_INCLUDE_DIR sodium.h
    PATHS "${SODIUM_ROOT}/include"
    NO_DEFAULT_PATH)

find_library(SODIUM_LIBRARY
    NAMES sodium libsodium
    PATHS "${SODIUM_ROOT}/lib"
    NO_DEFAULT_PATH)

target_include_directories(your_target PRIVATE "${SODIUM_INCLUDE_DIR}")
target_link_libraries(your_target PRIVATE "${SODIUM_LIBRARY}")
```

如果使用 shared library，运行时还需要确保生成的 DLL 位于应用程序目录或
`PATH` 中。

## Workflow 触发规则

手动：

```yaml
workflow_dispatch:
```

Release：

```text
libsodium-1.0.22-RELEASE
libsodium-1.0.21-RELEASE
```

仓库 tag 的 `libsodium-` 前缀会被移除，剩余部分直接作为上游 libsodium 的 Git ref。

## 为什么使用原生 Windows ARM64 runner？

交叉编译只能证明“编译成功”。原生 `windows-11-arm` runner 还能真正运行 ARM64
测试程序，因此能更早发现 ABI、CPU 特性或运行时问题。

## 许可证

### 本仓库

本仓库自己的 CI、脚本和说明文件采用 ISC License，见 [`LICENSE`](LICENSE)。

### libsodium

libsodium 是独立的第三方项目，由上游作者按照 ISC License 授权：

https://github.com/jedisct1/libsodium

本仓库不会移除或替换它的许可声明。CI 会把上游 checkout 中的 `LICENSE`
原样复制为：

```text
LICENSE.libsodium
```

并放进每个二进制 ZIP。

详见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

### 名称与来源说明

“libsodium”名称仅用于说明本仓库所构建的上游软件及兼容目标，不表示本项目是
libsodium 官方项目、官方镜像、官方构建服务或经官方认可的分发渠道。

## 安全 / 可重复构建建议

正式分发时建议：

- 使用明确的 libsodium release tag 或 commit SHA
- 使用固定的 Zig 稳定版本
- 查看 Actions 日志中的 upstream commit 和 Zig version
- 核对生成的 `SHA256SUMS.txt`
- 不要把未验证的 fork 当成 upstream
- 对高安全场景自行增加签名、provenance/SLSA 和独立复现构建
- 对依赖的 GitHub Actions 定期审核并尽可能锁定到完整 commit SHA

## Upstream

- Repository: https://github.com/jedisct1/libsodium
- Documentation: https://doc.libsodium.org/
- Official releases: https://github.com/jedisct1/libsodium/releases

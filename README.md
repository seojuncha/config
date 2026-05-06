## Linux Server Directory Layout

```
/workspace
  /src            # 소스(깃 저장소)만
  /build          # 빌드 산출물(프로젝트별)
  /cache          # ccache, pip, cargo, npm 등 캐시
  /images         # QEMU rootfs, disk.img, initramfs 등 (활성 작업분)
  /data           # 실험 데이터(중기), 입력/출력
  /tools          # 빌드 도구/스크립트(개인 유틸)
  /tmp            # 대용량 임시(필요 시)
  /notes          # 리서치 노트, 실험 메모
  /bin            # 개인 실행파일(선택)
```

핵심 포인트:
- src는 “Git 관리” 중심, 나머지는 “생성물/캐시”로 분리
- 빌드/캐시가 소스 repo 내부를 오염시키지 않음
- 정리/백업 정책을 디렉토리 단위로 쉽게 적용 가능

archive:
```
/archive
  /backups
  /snapshots
  /images
  /datasets
  /recordings
  /exports
```

## With Git
- ref repository(`main`)
- 

```
/workspace/src
  /.repos/                 # “기준 저장소” 보관
    qemu.git/
    musl.git/
    linux.git/
    xv6.git/

  /emulator/qemu/           # 실제 작업 트리(worktree)
  /libc/musl/
  /linux/linux/
  /os/xv6/

 /workspace/build
   /qemu/...
   /musl/...
   /linux/...
   /xv6/...
```

## Example 1: Linux Kernel
### Step 1. Bare repo
```bash
cd /workspace/src/.repos
git clone --bare https://github.com/torvalds/linux.git linux.git
git --git-dir=/workspace/src/.repos/linux.git fetch --all --tags
```

### Step 2. Worktree
```bash
git --git-dir=/workspace/src/.repos/linux.git worktree add /workspace/src/linux/linux-main master
git --git-dir=/workspace/src/.repos/linux.git branch /workspace/src/linux/linux-exp master
git --git-dir=/workspace/src/.repos/linux.git worktree add /workspace/src/linux/linux-stable v6.6
```

```bash
git --git-dir=/workspace/src/.repos/linux.git worktree list
```

```bash
git --git-dir=/workspace/src/.repos/linux.git fetch --all --tags
```

```bash
cd /workspace/src/linux/linux-main
git pull --ff-only
```

### Step 3. out-of-tree build
```bash
mkdir -p /workspace/build/linux/{main,stable,exp}
```

### Step 4. Build
```bash
sudo apt update
sudo apt install -y \
  build-essential bc bison flex libssl-dev libelf-dev \
  dwarves pahole ccache \
  libncurses-dev
```

```bash
cd /workspace/src/linux/linux-main
make O=/workspace/build/linux/main defconfig
make O=/workspace/build/linux/main -j"$(nproc)"
```


## Example 2: QEMU
### Step 1. Bare
```bash
mkdir -p /workspace/src/.repos /workspace/src/emulator
cd /workspace/src/.repos
git clone --bare https://gitlab.com/qemu-project/qemu.git qemu.git
```

### Step 2. Worktree
```bash
git --git-dir=/workspace/src/.repos/qemu.git worktree add /workspace/src/emulator/qemu-master master
git --git-dir=/workspace/src/.repos/qemu.git worktree add /workspace/src/emulator/qemu-exp stable-10.1
git --git-dir=/workspace/src/.repos/qemu.git worktree add /workspace/src/emulator/qemu-v11.0.0 v11.0.0
```
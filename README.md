# NimSysLoader

A Nim-based shellcode loader utilizing direct syscalls via SysWhispers2 for core functionality.

## Setup & Usage

1. Clone the repository:
```powershell
git clone https://github.com/jeffaf/NimSysLoader.git
cd NimSysLoader
```

2. Install required Nim packages:
```powershell
nimble install winim
```

3. Compile:
```powershell
nim c -d:release NimSysLoader.nim
```

## Features
- Direct syscalls for core operations:
  - Memory allocation (NtAllocateVirtualMemory)
  - Thread creation (NtCreateThreadEx)
  - Handle management (NtClose)
- Base64 shellcode loading support
- Minimized usage of standard Windows APIs

## Dependencies
- Nim
- Winim module (for Windows type definitions and helper functions)
- SysWhispers2 (integrated via syscalls.nim)

## Credits
- [SysWhispers2](https://github.com/jthuraisamy/SysWhispers2)
- [NimlineWhispers2](https://github.com/ajpc500/NimlineWhispers2)

## Disclaimer
This tool is created for educational and research purposes only.
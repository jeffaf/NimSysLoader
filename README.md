# NimSysLoader

NimSysLoader is a shellcode loader written in Nim that uses direct syscalls for execution.

## Features
- Direct syscalls using SysWhispers2
- No API hooks
- Clean memory allocation
- Base64 shellcode support

## Requirements
- Nim
- Winim

## Installation
```bash
git clone https://github.com/jeffaf/NimSysLoader.git
cd NimSysLoader
nimble install winim
```

## Usage
1. Compile:
```bash
nim c -d:release nimsysloader.nim
```
2. Replace payload in nimsysloader.nim with your preferred base64 encoded shellcode. Only msfvenom has been tested. 

3. Run:
```bash
nimsysloader.exe
```

## Credits
- SysWhispers2: [github.com/jthuraisamy/SysWhispers2](https://github.com/jthuraisamy/SysWhispers2)
- NimlineWhispers2: [github.com/ajpc500/NimlineWhispers2](https://github.com/ajpc500/NimlineWhispers2)

## Disclaimer
This tool is for educational and research purposes only.
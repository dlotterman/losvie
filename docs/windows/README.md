# Windows

## Answer files / autounattend
[GenerateAnswerFile](https://github.com/SvenGroot/GenerateAnswerFile) is a very useful too.

The file in this folder was generated with:

```
./GenerateAnswerFile autounattend.xml `
    -Install CleanEfi `
    -LocalAccount "MPAdmin,PASSWORD123asd" `
    -AutoLogonUser MPAdmin `
    -AutoLogonPassword PASSWORD123asd `
    -ImageIndex 2 `
    -FirstLogonScript "C:/losvie/losvie-win-ip-by-mac.ps1" `
    -EnableRemoteDesktop
```

The script is added by 

## Unpacking and Repacking

### Unpack

Mount ISO
add `sources/$OEM$/$1` path

TODO add more docs here

## xorriso

For EFI

```
sudo xorriso -as mkisofs \
  -iso-level 3 \
  -rock \
  -J -R \
  -disable-deep-relocation \
  -untranslated-filenames \
  -b boot/etfsboot.com \
  -no-emul-boot \
  -boot-load-size 8 \
  -eltorito-alt-boot \
  -eltorito-platform efi \
  -b efi/microsoft/boot/efisys_noprompt.bin \
  -V "SSS_X64FREE_EN-US_DV9" \
  -volset "SSS_X64FREE_EN-US_DV9" \
  -publisher "MICROSOFT CORPORATION" \
  -p "MICROSOFT CORPORATION, ONE MICROSOFT WAY, REDMOND WA 98052, (425) 882-8080"     -A "CDIMAGE 2.56 (01/01/2005 TM)" \
  -isohybrid-gpt-basdat \
  -o /tmp/tmp/win_custom.iso \
  /tmp/export_win
```
BIOS?

```
genisoimage   -o /tmp/tmp/3windows.iso   -b boot/etfsboot.com   -no-emul-boot   -boot-load-seg 0x07C0   -boot-load-size 8   -iso-level 2   -udf   -joliet   -joliet-long   -full-iso9660-filenames   -relaxed-filenames   -D   -N   -V "WINDOWS_INSTALL" -allow-limited-size   /tmp/export_win
  ```

## Docs Links
- https://stackoverflow.com/questions/57697329/how-to-assign-static-ip-based-on-mac-address-using-powershell-script-in-windows
- https://blog.linux-ng.de/2025/01/02/build-unattended-windows-iso/
- https://www.reddit.com/r/linuxquestions/comments/1igw7uo/repack_windows_iso/

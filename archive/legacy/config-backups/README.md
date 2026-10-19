# archive/legacy/config-backups — 配置备份

| 文件 | 来源 | 说明 |
|---|---|---|
| `LegWheel.uvprojx-20261019.bak` | `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx` | 2026-10-19 清理 19 条失效 include 前的原文件（55,476 B） |

## 回退

```powershell
Copy-Item archive\legacy\config-backups\LegWheel.uvprojx-20261019.bak firmware\LegWheel\MDK-ARM\LegWheel.uvprojx -Force
```

> 改 `uvprojx` 前先复制备份；Build 验证通过后再提交。不要在 Keil 打开工程时保存覆盖磁盘文件。

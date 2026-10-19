# hardware/bom — 物料清单

放：整车 BOM（名称、型号、数量、供应商、价格、交期、替代料）。

规则：
- 一行一个物料；与 `hardware/electronics/` 的选型对应；
- 价格/交期标日期；
- 关键件（电机/板卡/IMU/电池/继电器）给链接或资料路径；
- 变更在 `CHANGELOG.md` 记录。

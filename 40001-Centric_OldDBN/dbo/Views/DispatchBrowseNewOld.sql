
/*
=============================================
Version:	1.0
Programmer:	Karl Daws
Date:		4/Jul/2016
Reason:		Flat table of [DispatchBrowseNew] from Old Centric

=============================================
*/

CREATE VIEW [dbo].[DispatchBrowseNewOld]
AS

SELECT
PROD_PROD_TRANS_GROUP_MAP_ID,
CREATED_DATE,
SHIFT_DATE,
SHIFT,
HAUL_PROVIDER,
WencoID,
DUMP_TIMESTAMP,
SOURCE,
WET_TONNES,
Dry_TONNES,
BCM,
DESTINATION,
MOVEMENT_TYPE,
TRUCK,
LOADER,
TruckOperatorID,
LoaderOperatorID,
SourceMaterialType,
TargetMaterialType,
NV,
Ni,
Co,
Mg,
Al,
Fe,
Cr,
Mn,
Zn,
Cu,
Si,
Ca,
Cl,
SA,
SM,
FZ,
LI,
FEL,
MAF,
PC,
UM,
SIL,
EDITING_NOTE,
EXTERNAL_SOURCE_KEY,
Entry_Type,
ENABLED,
TENEMENT
FROM DispatchBrowseNew
WHERE SHIFT_DATE < cast('1/1/14' as datetime)


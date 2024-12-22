
create view [dbo].[MMOM_OldCentric_TP_DBN] as
--230416
SELECT *

FROM (
	

	
	SELECT
	1 AS verCentric,
    CREATED_DATE,
    SHIFT_DATE,
    SHIFT,
    HAUL_PROVIDER,
    WencoID,
    SOURCE,
    WET_TONNES,
    Dry_TONNES,
    BCM,
    NULL MoistureFactor,
    NULL SpecificGravit,
    NULL RT_CHECK,
    DESTINATION,
    MOVEMENT_TYPE,
    TRUCK,
    LOADER,
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
	FROM Centric_OldDBN.dbo.DispatchBrowseNewOld
	--WHERE SHIFT_DATE < cast('1/1/14' as datetime)
) a
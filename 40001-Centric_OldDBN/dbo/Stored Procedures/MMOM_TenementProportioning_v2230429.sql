--exec MMOM_TenementProportioning_v2 
CREATE procedure [dbo].[MMOM_TenementProportioning_v2230429] as
-- 230416
-- Use this to materialise Stockpile Tenement Proportions from Old Centric.
-- These can then be used by CentricBalance (Centry)
-- Run time approx 15m


-- =============================================
--SP by tenement v1.50

-- 14/Mar/2012 - Modified query so that it includes the rehandle from 'TPROM1' & TPROM2' (tenement 390692)
-- 15/Mar/2012 - Added destination <> source to WHERE statements, excludes rehandle to itself
-- 30/Sep/2012 - Added WHERE tenement IS NOT NULL to stockpiled queries, prevents any rehandle to stockpiles registering
-- v1.50
-- 26/Jun/2013 - Tidied up code
-- 02/Jan/2014 Added destination LIKE '%ROM%' for rehandle, this doesn't count misallocated loads being rehandled off the satellite ROM's
-- 04/Jul/2016 KDaws - DBN now has TENEMENT column, removed references to Wenco database.
-- =============================================

DECLARE @build_dates TABLE (
	stockpile varchar(24),
	ident int,
	sp_build_end_last datetime,
	sp_build_start_next datetime
)

DECLARE @stockpiled TABLE (
	stockpile varchar(24),
	tenement varchar(8),
	ident int,
	sp_build_end_last datetime,
	sp_build_start_next datetime,
	sp_build_end_next datetime,
	wet_tonnes decimal(24,3),
	dry_tonnes decimal(24,3)
)


declare
-- list of BUs that had non-null TENEMENT
@sps varchar(max) = '0101ROM4,0102BUND,0102WLAT,0104CLEARING,0105BF,0105RED,0303BLUE,0401RED,0403ROM2,0403ROMSKIN,0404BUND,0405GRAVEL,0410INPIT,0410WD,0501ORANGE,0501ROM5,0501ROMCONST2,0501SKYCONST,0502LAT1,0503RED,0503SKYWAY,0701RED,0703BF,0902TNEST,0906SKYWAY,1302INPIT,1303RDCONST,1304BLUE,1401BF,1753RDCONST,1753RDCONST1,1801BFEAST,1801BLUEN,1801INPIT,1801LAT1,1801ORANGEN,1801WDS,1802PLASTICCLAYS,1803BUND,1900BF,1901BUND,1903BF,1903BRG,1903RAMP,1952INPIT,1956BUND,2301ROM2,2302BUND,2304INPIT,MISCWATE,MME_HUB,ROMC,0101gravel,0101ROM1,0101ROM3,0102ERAMP,0102LAT,0102SKYWAY,0303BF,0303ORANGE,0303RDCONST,0401BF,0403GRAVEL,0403RDCONST,0405BUND,0405INPIT,0405RAMP,0411RDCONST,0411ROM1,0411ROM3,0501BLUE,0501ROM2,0501ROMCONST,0502INPITFIB,0503BLUEN,0503ORANGE,0802BF,0902INPIT,0906FIBROUS,0906LAT4,1405RDCONST,1801RDCONST1,1801ROM2,1806SKYWAY,1854BF,1901GRAVEL,1901RDCON2,1901ROM1,1901SKYWAY,1954RED,1956 RDCONST,2101SKYWAY,2301BUND,2301ROM1_SKIN,2301ROM3,2302INPIT,2302RAMP,2303BF,2401BF,2401FIBROUS,2401RAMP,ROMB,ROMD,SCATSPILE,SKYWAY,WETSCATSDUMP1,0101BUND,0101NTHRAMP,0101ROM2,0101TNEST,0102RAMP,0105LAT,0403ROMCONST,0404RDCONST,0411BUND,0501BLUE2,0502INPIT,0503RDCONST,0503RDCONST1,0503REDN,0805BF,0906LAT1,0906RDCONST1,0906WD,13.3RdConst1,1303INPIT,1303ROM1,1304ORANGE,1304ROM1,1401ORANGE,1401WD,1405INPIT,1753INPIT,1753ORANGE,1753RDCONST3,1753ROMCONST,1801BFRmp,1801RDCON2,1801REDS,1801ROMCONST,1803INPIT,1806LAT,1854INPIT,1854RDCONS2,1900BUND,1901ORANGE,1901ROMCONST,1951INPIT,1954RDCONST,1955BF,2301INPIT,2303INPIT,2401BLUE,2401FIBROUS2,2401LAT1,2401WD,HLROMPAD1,OFFICEPAD,ROMA,ROME,ROMWASTE,0101ORANGE,0102BF,0105ORANGE,0105RDCONST,0304BF,0404RAMP,0404ROMRD,0405RDCON,0411INPIT,0501RDCONST2,0501ROM4,0502BF,0503BF,0503ORANGEN,0702INPIT,0801FIBROUS,0906BF,0906BUND,1302WD,1303LAT,1303ROM2,1304BF,1304INPIT,1304ROM2,1401RDCONST,1401SKYWAY,1405ROM1,1405ROM4,1701BUND,1753TOPSOIL2,1801BUND,1900WD,1901INPIT,1901RED2,1903BLUE,1951ORANGE,1954BUND,1954ROMCONST,1955RDCONST,2101BF,2301ORANGE,2301RAMP,2301ROM5,2301ROM6,2301SKYWAY,2303BUND,2304BUND,2401LAT2,2401LAT3,2401RDCONST,PLANTRDCONST,0101RDCONST,0101RDCONST2,0101WD,0102ELAT,0102RDCONST,0202WD,0204PIPE,0303FIBROUS WD,0303ROM1,0303SKYWAY,0401INPIT,0403BF,0403ROM4,0403ROM6,0404INPIT,0404RDCONST2,0405GRAVEL2,0410RDCONST,0411BLUE,0501BF,0501BUND,0501FIBWD,0501ORANGE2,0501RED,0501WD,0502RDCONST,0503BLUE,0503GRAVEL,0503INPIT,0503ROMCONST,0701ORANGE,0702BF,0703LAT,0801INPIT,0801WD,0906EASTRAMP,0906INPIT,0906LAT6,0906ORANGE,1303BLUE,1303ORANGE,1303SKYWAY,1401BLUE,1401ROM2,1405ORANGE,1405WD,1753LATERITE,1803RDCONST,1806BF,1854LAT1,1854SKYWYRMP,1901RAMP,1901ROM3,1903RED,1909RDCONST,1951RED,1951ROM5,1954BLUE,2101BUND,2101INPIT,2101RAMP,2301FIBROUS,2302BF,2304BF,2402INPIT,2402RDCONST,SCOUR_PIT1,0101BLUE,0101ROMCONST,0403BLUE,0403ORANGE,0403ROM1,0403ROMACCESS,0404BF,0404BLUE,0404ORANGE,0405RED,0410RMP,0410WDRMP,0411LAT,0460BF,0501ROMCON,0501SKYWAY,0503RDCONST2,0503WD,0701BLUE,0703TOPSOIL,0801BF,0901BF,0902WD,0906LAT2,0906ORANGE2,0906SKYWAY2,1303RED,1304LAT,1401INPIT,1401RMPCONST,1404BUND,1404INPIT,1404RDCONST,1405SKYWAY,1753RDCONST2,1753RED,1801BF,1801BLUES,1801RDCONST,1806INPIT,1806WD,1854NTHRAMP,1900INPIT,1901ROM4,1904ROM2CONS,1955INPIT,2301BLUE,2301ORANGE2,2301RDCONST2,2301ROM1,2302LAT,2401BUND,2401ORANGE,2401SKYWAY,2402BUND,2402LAT,BULONG2,ROMRDCON,ROMRDCONST,0101STHRAMP,0102INPIT,0105BLUE,0303RED,0304ROM1,0403INPIT,0403RDCONSTR,0403SKYWAY,0404SKYWAY,0405ORANGE,0405SKYCON,0410BUND,0411ROM4,0501INPIT,0501RDCONST3,0501RMP,0501ROM3,0503BUND,0503FIBROUS,0503RED1,0601RDCONST,0801OB,0906RDCONST,1303BUND,1303ROMCONST,1303WD,1304BUND,1309BUND,1401RED,1404BF,1405BF,1405ROM2,1405ROM3,1753BUND,1753ROM1,1753SKYWYRMP,1801BFWEST,1801RMPWA,1801SKYWAY,1801WD,1806BRG,1854ROM4,1901BLUE,1901RED1,1901REDCONST,1903BUND,1903INPIT,1903ORANGE1,1909BUND,1951BF,1952BF,1954INPIT,1954ORANGE,1954RDCONST2,2301RED,2301ROM4,2301WD,2401LAT4,2401RED,4.3 Rmp,8ROMRDCONST,HLTAILSPIPE,ROMF_SKIN,0101BF,0101INPIT,0101SKYWAY,0105BUND,0105INPIT,0303BUND,0303ROM2,0304ROM2,0403RED,0403ROM3,0403ROM5,0404RDCONST1,0404RED,0405BLUE,0405ROMACC,0410SKYWAY,0411BF,0411ORANGE,0411ROM2,0501RDCON,0501ROM1,0502BUND,0801RDCONST,0802WD,0902RDCONST,0906BLUE,0906LAT3,0906ORANGECON,1303BF,1303ROM3,1309INPIT,1401BUND,1401RMCO,1401ROM1,1401ROM3,1405BLUE,1405RED,1753BLUE,1801ORANGES,1801PLASTICCLAYN,1801REDN,1801ROM1,1801ROM3,1854BUND,1854RDCONST1,1900RDCONST,1901RDCONST,1901ROM2,1951BLUE,1952BUND,1954ROM1,1956INPIT,2101RDCONST,2301BF,2301LAT2,2301RDCONST,2301ROMCONST,2302RDCONST,2401INPIT,LOSTWORLDCLEARING'
,@datefrom date = '2013-12-1'
,@dateto date = '2013-12-31'

/*
Dependencies:
MMOM_OldCentric_TP_DBN view
[fnGetOpeningStockpileDate_TenementProportioningv2] scalar function
*/

INSERT INTO @build_dates (stockpile, ident, sp_build_end_last, sp_build_start_next)
--z_fnStockpileBuildEndLastStartNext
SELECT
stockpile,
row_number() OVER(PARTITION BY stockpile ORDER BY sp_build_end_last) AS ident,
sp_build_end_last,
sp_build_start_next
FROM (
	SELECT
	stockpile,
	MAX(sp_build_end_last) AS sp_build_end_last,
	sp_build_start_next
	FROM (
		SELECT
		SBD.stockpile,
		SBD.sp_build_end_last,
		MIN(DBN.shift_date) AS sp_build_start_next
		FROM (
			SELECT
			stockpile,
			sp_build_end_last
			FROM (
				--List all shift dates between @datefrom and @dateto and cross join with each stockpile name
				SELECT
				date AS shift_date,
				stockpile,
				--dbo.fnGetOpeningStockpileDate
				dbo.[fnGetOpeningStockpileDate_TenementProportioningv2](stockpile,date) AS sp_build_end_last
				FROM (
					SELECT
					date,
					business_unit_name 
					AS stockpile
					FROM dbo.create_daterange2(@datefrom,@dateto)
					CROSS JOIN old_centric.dbo.business_unit  AS BU
					WHERE 
					BU.business_unit_name IN (SELECT item FROM dbo.Split_List(@sps,',')) --(@sps)
					
				) a
			) b
			GROUP BY
			stockpile,
			sp_build_end_last
		) AS SBD
		INNER JOIN (
			--Find first load of the following build
			SELECT
			destination AS stockpile,
			shift_date
			FROM MMOM_OldCentric_TP_DBN
			WHERE 
			destination IN (SELECT item FROM dbo.Split_List(@sps,',')) --(@sps)
			GROUP BY
			shift_date,
			destination
		) AS DBN
		ON SBD.stockpile = DBN.stockpile AND DBN.shift_date > SBD.sp_build_end_last
		GROUP BY
		SBD.stockpile,
		SBD.sp_build_end_last
	) a
	GROUP BY
	stockpile,
	sp_build_start_next
) b


--SELECT * FROM @build_dates


INSERT INTO @stockpiled (stockpile, tenement, ident, sp_build_end_last, sp_build_start_next)
--Calculates the tonnes dumped on the stockpile for the current build grouped by tenement
SELECT
sp_build.stockpile,
DBN.tenement,
sp_build.ident,
sp_build.sp_build_end_last,
sp_build.sp_build_start_next
FROM @build_dates AS sp_build
LEFT OUTER JOIN (
	--All loads <= @dateto and >= sp_build_start_next
	--Modified to include rehandle from TPROM1 and TPROM2 at MME
	SELECT
	DESTINATION AS stockpile,
	SOURCE,
	CASE
		WHEN TENEMENT IS NULL AND SOURCE IN ('TPROM1','TPROM2')
		THEN '390692'
		ELSE TENEMENT
	END AS TENEMENT,
	SHIFT_DATE,
	SUM(WET_TONNES) AS WET_TONNES,
	SUM(DRY_TONNES) AS DRY_TONNES
	FROM 
	--DispatchBrowseNew_UnionOldNew
	MMOM_OldCentric_TP_DBN
	WHERE entry_type  = 'Dispatch'
	AND DESTINATION IN (select item as item from dbo.Split_List(@Sps,','))
	--(@Sps is null or bu.BUSINESS_UNIT in (select item as item from dbo.Split_List(@Sps,',')))
	AND DESTINATION <> SOURCE
	AND SHIFT_DATE <= @dateto
	GROUP BY
	DESTINATION,
	SOURCE,
	TENEMENT,
	SHIFT_DATE
) AS DBN 
ON sp_build.stockpile = DBN.stockpile
AND DBN.shift_date >= sp_build.sp_build_start_next
WHERE TENEMENT IS NOT NULL
GROUP BY
sp_build.stockpile,
sp_build.ident,
DBN.tenement,
sp_build_end_last,
sp_build_start_next

--SELECT * FROM @stockpiled

--Update sp build records with sp_build_end_next
--If a build has been complete (depleted) inser the end_last date into the previous builds end_next date
UPDATE @stockpiled
SET sp_build_end_next = sp_update.sp_build_end_next
FROM @stockpiled AS sp
INNER JOIN (
	SELECT 
	sp1.stockpile,
	sp1.tenement,
	sp1.ident,
	sp1.sp_build_end_last,
	sp1.sp_build_start_next,
	sp2.sp_build_end_last AS sp_build_end_next
	FROM @stockpiled AS sp1
	LEFT OUTER JOIN @stockpiled AS sp2
	ON sp1.stockpile = sp2.stockpile
	AND sp1.ident + 1 = sp2.ident
) sp_update
ON sp.stockpile = sp_update.stockpile
AND sp.ident = sp_update.ident

--SELECT * FROM @stockpiled

--Update the stockpile build records with WT & DT's by tenement
UPDATE @stockpiled
SET wet_tonnes = sp_update.WET_TONNES, dry_tonnes = sp_update.DRY_TONNES
FROM @stockpiled AS sp
INNER JOIN (
	SELECT
	sp_build.stockpile,
	DBN.tenement,
	sp_build.ident,
	sp_build.sp_build_end_last,
	sp_build.sp_build_start_next,
	SUM(DBN.WET_TONNES) AS WET_TONNES,
	SUM(DBN.DRY_TONNES) AS DRY_TONNES
	FROM @stockpiled AS sp_build
	LEFT OUTER JOIN (
		--Modified to include rehandle from TPROM1 and TPROM2 at MME
		SELECT
		DESTINATION AS stockpile,
		SOURCE,
		CASE
			WHEN TENEMENT IS NULL AND SOURCE IN ('TPROM1','TPROM2')
			THEN '390692'
			ELSE TENEMENT
		END AS TENEMENT,
		SHIFT_DATE,
		SUM(WET_TONNES) AS WET_TONNES,
		SUM(DRY_TONNES) AS DRY_TONNES
		FROM 
		--DispatchBrowseNew_UnionOldNew
		MMOM_OldCentric_TP_DBN
		WHERE Entry_Type = 'Dispatch'
		--AND DESTINATION IN (@stockpilelist)
		AND DESTINATION IN (select item as item from dbo.Split_List(@Sps,','))
		AND DESTINATION <> SOURCE
		AND SHIFT_DATE <= @dateto
		GROUP BY
		DESTINATION,
		SOURCE,
		TENEMENT,
		SHIFT_DATE
	) AS DBN
	ON sp_build.stockpile = DBN.stockpile
	AND sp_build.tenement = DBN.tenement
	AND ((DBN.shift_date BETWEEN sp_build.sp_build_start_next AND sp_build.sp_build_end_next)
			OR (DBN.shift_date >= sp_build.sp_build_start_next AND sp_build.sp_build_end_next IS NULL))
	WHERE DBN.TENEMENT IS NOT NULL
	GROUP BY
	sp_build.stockpile,
	sp_build.ident,
	DBN.tenement,
	sp_build_end_last,
	sp_build_start_next
) sp_update
ON sp.stockpile = sp_update.stockpile
AND sp.tenement = sp_update.tenement
AND sp.ident = sp_update.ident

--SELECT * FROM @stockpiled


--Stockpiled, expit and rehandle tonnages for selected stockpiles grouped by build ident and tenement
SELECT
stockpiled.stockpile,
stockpiled.tenement,
stockpiled.ident,
stockpiled.sp_build_end_last,
stockpiled.sp_build_start_next,
stockpiled.sp_build_end_next,
stockpiled.stockpiled_WT,
stockpiled.stockpiled_DT,
stockpiled.stockpiled_WT_total,
stockpiled.stockpiled_DT_total--,
--expit.expit_WT,
--expit.expit_DT,
--stockpiled.stockpiled_DT/stockpiled_DT_total*rehandled.rehandle_WT AS rehandled_WT,
--stockpiled.stockpiled_DT/stockpiled_DT_total*rehandled.rehandle_DT AS rehandled_DT
into MMOM_TenementProportioning_v2_Materialised_230428_01
FROM (
	SELECT
	stockpiled.stockpile,
	stockpiled.tenement,
	stockpiled.ident,
	stockpiled.sp_build_end_last,
	stockpiled.sp_build_start_next,
	stockpiled.sp_build_end_next,
	stockpiled.wet_tonnes AS stockpiled_WT,
	stockpiled.dry_tonnes AS stockpiled_DT,
	stockpiled_totals.wet_tonnes AS stockpiled_WT_total,
	stockpiled_totals.dry_tonnes AS stockpiled_DT_total
	FROM (
		SELECT
		stockpile,
		tenement,
		ident,
		sp_build_end_last,
		sp_build_start_next,
		sp_build_end_next,
		SUM(wet_tonnes) AS wet_tonnes,
		SUM(dry_tonnes) AS dry_tonnes
		FROM @stockpiled
		GROUP BY
		stockpile,
		tenement,
		ident,
		sp_build_end_last,
		sp_build_start_next,
		sp_build_end_next
	) stockpiled
	INNER JOIN (
		SELECT
		stockpile,
		ident,
		SUM(wet_tonnes) AS wet_tonnes,
		SUM(dry_tonnes) AS dry_tonnes
		FROM @stockpiled
		GROUP BY
		stockpile,
		ident
	) stockpiled_totals
	ON stockpiled.stockpile = stockpiled_totals.stockpile
	AND stockpiled.ident = stockpiled_totals.ident
) stockpiled

--LEFT OUTER JOIN (
--	--All ex-pit loads between @datefrom and @dateto
--	SELECT
--	sp_build.stockpile,
--	DBN.tenement,
--	sp_build.ident,
--	sp_build.sp_build_end_last,
--	sp_build.sp_build_start_next,
--	SUM(DBN.WET_TONNES) AS expit_WT,
--	SUM(DBN.DRY_TONNES) AS expit_DT
--	FROM @stockpiled AS sp_build
--	INNER JOIN (
--		SELECT
--		DESTINATION AS stockpile,
--		TENEMENT,
--		SHIFT_DATE,
--		SUM(WET_TONNES) AS WET_TONNES,
--		SUM(DRY_TONNES) AS DRY_TONNES
--		FROM DispatchBrowseNew
--		WHERE MOVEMENT_TYPE = 'Ex-pit'
--		AND Entry_Type  = 'Dispatch'
--		AND SHIFT_DATE BETWEEN @datefrom AND @dateto
--		--AND DESTINATION IN (@stockpilelist)
--		AND DESTINATION IN (select item as item from dbo.Split_List(@Sps,','))
--		GROUP BY
--		DESTINATION,
--		TENEMENT,
--		SHIFT_DATE
--	) DBN
--	ON sp_build.stockpile = DBN.stockpile
--	AND sp_build.tenement = DBN.TENEMENT
--	AND ((DBN.SHIFT_DATE BETWEEN sp_build.sp_build_start_next AND sp_build.sp_build_end_next)
--		OR (DBN.SHIFT_DATE >= sp_build.sp_build_start_next AND sp_build.sp_build_end_next IS NULL))
--	GROUP BY
--	sp_build.stockpile,
--	DBN.tenement,
--	sp_build.ident,
--	sp_build.sp_build_end_last,
--	sp_build.sp_build_start_next
--) AS expit
--ON stockpiled.stockpile = expit.stockpile
--AND stockpiled.tenement = expit.tenement
--AND stockpiled.ident = expit.ident

--LEFT OUTER JOIN (
--	--Rehandle from stockpiles between @datefrom and @dateto, rehandle to itself is not included
--	SELECT
--	sp_build.stockpile,
--	sp_build.ident,
--	sp_build.sp_build_end_last,
--	sp_build.sp_build_start_next,
--	sp_build.sp_build_end_next,
--	SUM(DBN.WET_TONNES) AS rehandle_WT,
--	SUM(DBN.DRY_TONNES) AS rehandle_DT
--	FROM (
--		--Need to group data as it is split by tenement
--		SELECT
--		stockpile,
--		ident,
--		sp_build_end_last,
--		sp_build_start_next,
--		sp_build_end_next
--		FROM @stockpiled
--		GROUP BY
--		stockpile,
--		ident,
--		sp_build_end_last,
--		sp_build_start_next,
--		sp_build_end_next
--	) sp_build
--	INNER JOIN (
--		SELECT
--		SOURCE AS stockpile,
--		SHIFT_DATE,
--		SUM(WET_TONNES) AS WET_TONNES,
--		SUM(DRY_TONNES) AS DRY_TONNES
--		FROM DispatchBrowseNew
--		WHERE MOVEMENT_TYPE = 'Rehandle'
--		AND Entry_Type  = 'Dispatch'
--		AND SHIFT_DATE BETWEEN @datefrom AND @dateto
--		--AND SOURCE IN (@stockpilelist)
--		AND source IN (select item as item from dbo.Split_List(@Sps,','))
--		AND DESTINATION <> SOURCE
--		AND DESTINATION LIKE '%ROM%'
--		GROUP BY
--		SOURCE,
--		SHIFT_DATE
--	) DBN
--	ON sp_build.stockpile = DBN.stockpile
--	AND ((DBN.SHIFT_DATE BETWEEN sp_build.sp_build_start_next AND sp_build.sp_build_end_next)
--		OR (DBN.SHIFT_DATE >= sp_build.sp_build_start_next AND sp_build.sp_build_end_next IS NULL))
--	GROUP BY
--	sp_build.stockpile,
--	sp_build.ident,
--	sp_build.sp_build_end_last,
--	sp_build.sp_build_start_next,
--	sp_build.sp_build_end_next
--) AS rehandled
--ON stockpiled.stockpile = rehandled.stockpile
--AND stockpiled.ident = rehandled.ident

ORDER BY stockpile,
ident,
tenement
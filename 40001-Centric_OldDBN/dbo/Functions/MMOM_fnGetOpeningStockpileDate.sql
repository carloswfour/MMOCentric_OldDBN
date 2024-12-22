

-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	Returns the last date a stockpile was effectively zeroed for the purposes of determining the composition of a stockpile
--				Looks at adjustmenets <= the @cutoffDate
-- 
-- Modified: 
-- v1.1 6/Mar/2014 KDaws - Modified for use in Centric 1.4
-- v1.2 17/Mar/2014 KDaws - Need to be able to look at Old Centric data as well. Looks at New Centric first, then Old Centric if nothing is found
-- v1.3 20/Apr/2015 KDaws - Modified New Centric section to cater for adjustments with timestamps. Considers @cutoffDate to be a shift date, determines the adjustment shift date before applying the @cutoffDate.
-- v1.4 11/Apr/2016 KDaws - Added BUJ.EDITING_NOTE NOT LIKE '%EXCLUDE%' to allow certain adjustments to be ignored for reporting purposes ie for determining when a stockpile has been depleted.
-- v1.5 06/Oct/2020 KDaws - murntfms01.Centric migrated to Old_Centric
-- =============================================

CREATE FUNCTION [dbo].[MMOM_fnGetOpeningStockpileDate] (@stockpileName VARCHAR(100),@cutoffDate DATETIME)
RETURNS DATETIME
AS
BEGIN

	DECLARE @maxDateZeroed DATETIME
	SET @maxDateZeroed = NULL

	/*Basic Checks*/
	--Check Variables
	IF @stockpileName IS NULL
	RETURN NULL

	IF @cutoffDate IS NULL
	RETURN NULL

	--Date checking
	IF @cutoffDate < '02-Jan-07'
	SET @cutoffdate = '02-Jan-07'


	--Check Stockpile Exists
	DECLARE @exists INTEGER 
	SELECT @exists = COUNT(*) FROM Old_Centric.dbo.business_unit WHERE BUSINESS_UNIT_NAME = @stockpilename AND BUSINESS_UNIT_TYPE_ID = 6
	SELECT @exists = COUNT(*) FROM centric.dbo.business_unit WHERE BUSINESS_UNIT = @stockpilename AND BUSINESS_UNIT_TYPE_ID = 6
	IF @exists <> 1
	RETURN NULL


	/******* NEW CENTRIC *******/
	SELECT @maxDateZeroed = CONVERT(VARCHAR(10),MAX(SHIFT_DATE),101) --Remove 23:59:59 from RECORD_DATE
	FROM (
		SELECT
		BUSINESS_UNIT,
		BUJ.RECORD_DATE,
		CASE
			WHEN DATEPART(hh, RECORD_DATE) >= 6 THEN DATEADD(dd, DATEDIFF(dd, 0, RECORD_DATE), 0)
			WHEN DATEPART(hh, RECORD_DATE) BETWEEN 0 AND 6 THEN DATEADD(dd, DATEDIFF(dd, 0, DATEADD(d,-1,RECORD_DATE)), 0)
		END AS SHIFT_DATE
		FROM centric.dbo.BUSINESS_UNIT_JOURNAL AS BUJ
		INNER JOIN centric.dbo.BUSINESS_UNIT AS BU
		ON BU.BUSINESS_UNIT_ID = BUJ.BUSINESS_UNIT_ID
		WHERE BUJ.RECORD_DATE >= '1/1/14'
		AND BUJ.BUSINESS_UNIT_JOURNAL_ENTRY_TYPE_ID IN (3,4,7)
		AND BU.BUSINESS_UNIT = @stockpileName
		AND BUJ.ENABLED <> 0
		AND BUJ.EDITING_NOTE NOT LIKE '%EXCLUDE%'
	) a
	WHERE SHIFT_DATE <= @cutoffDate
	GROUP BY BUSINESS_UNIT

	IF @maxDateZeroed IS NOT NULL
	BEGIN
		--Found adjustment in new Centric, return date
		RETURN @maxDateZeroed
	END


	--Didn't find in new Centric
	IF @maxDateZeroed IS NULL
	BEGIN
		/******* OLD CENTRIC *******/

		/* stockpile has been zeroed since initial import by auto process or survey (less than 1000 tonnes) maxdate before cutoff period) */
		SELECT @maxDateZeroed = stockpileAdjustments.maxZeroedDate
		FROM (
			SELECT 
			MAX(buj.record_date) AS maxZeroedDate 
			FROM Old_Centric.dbo.BUSINESS_UNIT AS bu
			INNER JOIN Old_Centric.dbo.BUSINESS_UNIT_JOURNAL AS buj
			ON bu.BUSINESS_UNIT_ID = buj.Business_Unit_ID 
			WHERE buj.editing_note = 'Adjustment to bring balance back to positive' 
			AND bu.BUSINESS_UNIT_NAME = @stockpileName
			AND buj.record_date < '1/1/14'
			AND buj.record_date <= @cutoffDate
			AND buj.enabled = -1
		
			UNION
		
			SELECT 
			MAX(buj.record_date) AS maxZeroedDate 
			FROM Old_Centric.dbo.[BUSINESS_UNIT] AS bu
			INNER JOIN Old_Centric.dbo.[BUSINESS_UNIT_JOURNAL] AS buj
			ON bu.BUSINESS_UNIT_ID = buj.Business_Unit_ID 
			WHERE buj.[EDITING_NOTE] LIKE 'Adjustment to hit%'
			AND CAST(LTRIM(REPLACE(buj.EDITING_NOTE,'Adjustment to hit target tonnage of :','')) AS NUMERIC) < 1000
			AND bu.BUSINESS_UNIT_NAME = @stockpileName
			AND buj.record_date < '1/1/14'
			AND buj.record_date <= @cutoffDate
			AND buj.enabled = -1
		) stockpileAdjustments

		/* if the stockpile has never been zeroed then return 2-jan-07 as this is how far back the data goes */
		IF @maxDateZeroed IS NULL
		SET @maxDateZeroed = '02-Jan-07'
		
	END

	RETURN @maxDateZeroed

END
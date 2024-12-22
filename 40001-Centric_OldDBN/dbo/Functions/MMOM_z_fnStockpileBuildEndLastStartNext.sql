
CREATE FUNCTION [dbo].[MMOM_z_fnStockpileBuildEndLastStartNext] (	
	@datefrom AS datetime,
	@dateto AS datetime,
	@sps AS varchar(max)
)
RETURNS TABLE
AS
RETURN
(


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
				dbo.MMOM_fnGetOpeningStockpileDate(stockpile,date) AS sp_build_end_last
				FROM (
					SELECT
					date,
					business_unit AS stockpile
					FROM create_daterange2(@datefrom,@dateto)
					CROSS JOIN centric.dbo.business_unit AS BU
					WHERE 
					BU.business_unit IN (SELECT item FROM dbo.Split_List(@sps,',')) --(@sps)
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
			FROM --DispatchBrowseNew_UnionOldNew
			Centric_OldDBN.dbo.DispatchBrowseNew
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

)
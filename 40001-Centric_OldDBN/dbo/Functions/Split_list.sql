
--

CREATE FUNCTION [dbo].[Split_list]
(
	@ItemList NVARCHAR(4000), 
	@delimiter CHAR(1)
)
RETURNS @IDTable TABLE (Item nVARCHAR(50))  
AS      

BEGIN    
	DECLARE @tempItemList NVARCHAR(4000)
	SET @tempItemList = @ItemList

	DECLARE @i INT    
	DECLARE @Item NVARCHAR(4000)

	SET @tempItemList = REPLACE (@tempItemList, ' ', '')
	SET @i = CHARINDEX(@delimiter, @tempItemList)

	WHILE (LEN(@tempItemList) > 0)
	BEGIN
		IF @i = 0
			SET @Item = '' + @tempItemList + ''
		ELSE
			SET @Item = '' + LEFT(@tempItemList, @i - 1) + ''
		INSERT INTO @IDTable(Item) VALUES(@Item)
		IF @i = 0
			SET @tempItemList = ''
		ELSE
			SET @tempItemList = RIGHT(@tempItemList, LEN(@tempItemList) - @i)
		SET @i = CHARINDEX(@delimiter, @tempItemList)
	END 
	RETURN
END
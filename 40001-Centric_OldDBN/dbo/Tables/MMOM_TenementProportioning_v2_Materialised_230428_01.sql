CREATE TABLE [dbo].[MMOM_TenementProportioning_v2_Materialised_230428_01] (
    [stockpile]           VARCHAR (24)    NULL,
    [tenement]            VARCHAR (8)     NULL,
    [ident]               INT             NULL,
    [sp_build_end_last]   DATETIME        NULL,
    [sp_build_start_next] DATETIME        NULL,
    [sp_build_end_next]   DATETIME        NULL,
    [stockpiled_WT]       DECIMAL (38, 3) NULL,
    [stockpiled_DT]       DECIMAL (38, 3) NULL,
    [stockpiled_WT_total] DECIMAL (38, 3) NULL,
    [stockpiled_DT_total] DECIMAL (38, 3) NULL
);


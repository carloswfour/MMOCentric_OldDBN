CREATE TABLE [dbo].[DispatchBrowseNew] (
    [PROD_PROD_TRANS_GROUP_MAP_ID] INT              NOT NULL,
    [CREATED_DATE]                 DATETIME         NOT NULL,
    [SHIFT_DATE]                   DATETIME         NOT NULL,
    [SHIFT]                        VARCHAR (5)      NOT NULL,
    [HAUL_PROVIDER]                VARCHAR (5)      NOT NULL,
    [WencoID]                      INT              NULL,
    [DUMP_TIMESTAMP]               INT              NULL,
    [SOURCE]                       VARCHAR (100)    NULL,
    [WET_TONNES]                   DECIMAL (24, 3)  NULL,
    [Dry_TONNES]                   DECIMAL (38, 12) NULL,
    [BCM]                          DECIMAL (38, 12) NULL,
    [DESTINATION]                  VARCHAR (100)    NULL,
    [MOVEMENT_TYPE]                VARCHAR (8)      NOT NULL,
    [TRUCK]                        VARCHAR (1000)   NULL,
    [LOADER]                       VARCHAR (8000)   NULL,
    [TruckOperatorID]              VARCHAR (1000)   NULL,
    [LoaderOperatorID]             VARCHAR (1000)   NULL,
    [SourceMaterialType]           VARCHAR (1000)   NULL,
    [TargetMaterialType]           VARCHAR (1000)   NULL,
    [NV]                           DECIMAL (24, 3)  NULL,
    [Ni]                           DECIMAL (24, 3)  NULL,
    [Co]                           DECIMAL (24, 3)  NULL,
    [Mg]                           DECIMAL (24, 3)  NULL,
    [Al]                           DECIMAL (24, 3)  NULL,
    [Fe]                           DECIMAL (24, 3)  NULL,
    [Cr]                           DECIMAL (24, 3)  NULL,
    [Mn]                           DECIMAL (24, 3)  NULL,
    [Zn]                           DECIMAL (24, 3)  NULL,
    [Cu]                           DECIMAL (24, 3)  NULL,
    [Si]                           DECIMAL (24, 3)  NULL,
    [Ca]                           DECIMAL (24, 3)  NULL,
    [Cl]                           DECIMAL (24, 3)  NULL,
    [SA]                           DECIMAL (24, 3)  NULL,
    [SM]                           DECIMAL (24, 3)  NULL,
    [FZ]                           DECIMAL (24, 3)  NULL,
    [LI]                           DECIMAL (24, 3)  NULL,
    [FEL]                          DECIMAL (24, 3)  NULL,
    [MAF]                          DECIMAL (24, 3)  NULL,
    [PC]                           DECIMAL (24, 3)  NULL,
    [UM]                           DECIMAL (24, 3)  NULL,
    [SIL]                          DECIMAL (24, 3)  NULL,
    [EDITING_NOTE]                 VARCHAR (250)    NULL,
    [EXTERNAL_SOURCE_KEY]          VARCHAR (1000)   NULL,
    [Entry_Type]                   VARCHAR (8)      NOT NULL,
    [ENABLED]                      SMALLINT         NOT NULL,
    [TENEMENT]                     VARCHAR (8)      NULL,
    CONSTRAINT [PK_DispatchBrowseNew] PRIMARY KEY CLUSTERED ([PROD_PROD_TRANS_GROUP_MAP_ID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160704-124946]
    ON [dbo].[DispatchBrowseNew]([SHIFT_DATE] ASC, [HAUL_PROVIDER] ASC, [SOURCE] ASC, [DESTINATION] ASC, [MOVEMENT_TYPE] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MMO_DispatchBrowseNew_01]
    ON [dbo].[DispatchBrowseNew]([MOVEMENT_TYPE] ASC, [SHIFT_DATE] ASC, [SourceMaterialType] ASC, [SOURCE] ASC, [DESTINATION] ASC);


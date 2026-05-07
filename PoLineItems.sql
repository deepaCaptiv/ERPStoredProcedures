USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[Insert_POERPLineItems_FromJson]    Script Date: 05-05-2026 11:43:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE    PROCEDURE [dbo].[Insert_POERPLineItems_FromJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Parse JSON
    ;WITH SourceData AS
    (
        SELECT *
        FROM OPENJSON(@JsonData)
        WITH (
            POERPLineItemId VARCHAR(36),
            LINE_NUM INT,
            ITEM_CODE VARCHAR(100),
            ITEM_DESC NVARCHAR(MAX),
            HSN_SAC VARCHAR(10),
            QTY DECIMAL(18,2),
            UOM VARCHAR(10),
            UNIT_PRICE DECIMAL(18,2),
            LINE_AMOUNT DECIMAL(18,2),
            DELIVERY_DATE DATETIME,
            POLNUpdtedBy BIGINT,
            POLnUpdatedOn DATETIME,
            POERPHeaderId VARCHAR(36),
            DESTINATION_TYPE_CODE VARCHAR(25),
            GST_REVERSE_CHARGE_FLAG VARCHAR(10),
            CATEGORY_SEGMENT1 VARCHAR(40),
            DROP_SHIP_FLAG VARCHAR(10),
            SHIP_TO_ORGANIZATION_ID INT,
            REGIME_CODE VARCHAR(40),
            RELATED_PARTY_FLAG BIT,
            SEZ_FLAG BIT,
            SHIP_TO_COUNTRY VARCHAR(100),
            STOCK_TRANSFER_FLAG BIT,
            HIGH_SEA_SALES_FLAG BIT
        )
    )

    -- Step 2: MERGE (Insert or Update)
    MERGE dbo.POERPLineItems AS Target
    USING SourceData AS Source
    ON Target.POERPLineItemId = Source.POERPLineItemId

    WHEN MATCHED THEN
        UPDATE SET
            Target.LINE_NUM = Source.LINE_NUM,
            Target.ITEM_CODE = Source.ITEM_CODE,
            Target.ITEM_DESC = Source.ITEM_DESC,
            Target.HSN_SAC = Source.HSN_SAC,
            Target.QTY = Source.QTY,
            Target.UOM = Source.UOM,
            Target.UNIT_PRICE = Source.UNIT_PRICE,
            Target.LINE_AMOUNT = Source.LINE_AMOUNT,
            Target.DELIVERY_DATE = Source.DELIVERY_DATE,
            Target.POLNUpdtedBy = Source.POLNUpdtedBy,
            Target.POLnUpdatedOn = Source.POLnUpdatedOn,
            Target.POERPHeaderId = Source.POERPHeaderId,
            Target.DESTINATION_TYPE_CODE = Source.DESTINATION_TYPE_CODE,
            Target.GST_REVERSE_CHARGE_FLAG = Source.GST_REVERSE_CHARGE_FLAG,
            Target.CATEGORY_SEGMENT1 = Source.CATEGORY_SEGMENT1,
            Target.DROP_SHIP_FLAG = Source.DROP_SHIP_FLAG,
            Target.SHIP_TO_ORGANIZATION_ID = Source.SHIP_TO_ORGANIZATION_ID,
            Target.REGIME_CODE = Source.REGIME_CODE,
            Target.RELATED_PARTY_FLAG = Source.RELATED_PARTY_FLAG,
            Target.SEZ_FLAG = Source.SEZ_FLAG,
            Target.SHIP_TO_COUNTRY = Source.SHIP_TO_COUNTRY,
            Target.STOCK_TRANSFER_FLAG = Source.STOCK_TRANSFER_FLAG,
            Target.HIGH_SEA_SALES_FLAG = Source.HIGH_SEA_SALES_FLAG

    WHEN NOT MATCHED THEN
        INSERT (
            POERPLineItemId,
            LINE_NUM,
            ITEM_CODE,
            ITEM_DESC,
            HSN_SAC,
            QTY,
            UOM,
            UNIT_PRICE,
            LINE_AMOUNT,
            DELIVERY_DATE,
            POLNUpdtedBy,
            POLnUpdatedOn,
            POERPHeaderId,
            DESTINATION_TYPE_CODE,
            GST_REVERSE_CHARGE_FLAG,
            CATEGORY_SEGMENT1,
            DROP_SHIP_FLAG,
            SHIP_TO_ORGANIZATION_ID,
            REGIME_CODE,
            RELATED_PARTY_FLAG,
            SEZ_FLAG,
            SHIP_TO_COUNTRY,
            STOCK_TRANSFER_FLAG,
            HIGH_SEA_SALES_FLAG
        )
        VALUES (
            Source.POERPLineItemId,
            Source.LINE_NUM,
            Source.ITEM_CODE,
            Source.ITEM_DESC,
            Source.HSN_SAC,
            Source.QTY,
            Source.UOM,
            Source.UNIT_PRICE,
            Source.LINE_AMOUNT,
            Source.DELIVERY_DATE,
            Source.POLNUpdtedBy,
            Source.POLnUpdatedOn,
            Source.POERPHeaderId,
            Source.DESTINATION_TYPE_CODE,
            Source.GST_REVERSE_CHARGE_FLAG,
            Source.CATEGORY_SEGMENT1,
            Source.DROP_SHIP_FLAG,
            Source.SHIP_TO_ORGANIZATION_ID,
            Source.REGIME_CODE,
            Source.RELATED_PARTY_FLAG,
            Source.SEZ_FLAG,
            Source.SHIP_TO_COUNTRY,
            Source.STOCK_TRANSFER_FLAG,
            Source.HIGH_SEA_SALES_FLAG
        );

		insert into POJsonfromERP
		values('lineitem',@JsonData,getdate())
END
GO



USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[SaveASNLineItemsJson]    Script Date: 05-05-2026 11:06:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE     PROCEDURE [dbo].[SaveASNLineItemsJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate JSON
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            RAISERROR('Invalid or NULL JSON passed to SaveASNLineItemsJson', 16, 1);
            RETURN;
        END

        DECLARE @Result TABLE (
            ASNLineItemId VARCHAR(36),
            ASNId VARCHAR(36)
        );

        -- UPSERT using MERGE
        MERGE dbo.ASNLineItems AS TARGET
        USING (
            SELECT
                ASNLineItemId,
                ASNId,
                [LineNo],
                ItemCode,
                ItemDesc,
                UOM,
                POQty,
                OpenQty,
                ShippedQty,
                NoOfPackage,
                BatchNo
            FROM OPENJSON(@JsonData)
            WITH (
                ASNLineItemId VARCHAR(36),
                ASNId VARCHAR(36),
                [LineNo] INT,
                ItemCode VARCHAR(50),
                ItemDesc NVARCHAR(4000),
                UOM VARCHAR(50),
                POQty DECIMAL(18,2),
                OpenQty DECIMAL(18,2),
                ShippedQty DECIMAL(18,2),
                NoOfPackage INT,
                BatchNo VARCHAR(100)
            )
        ) AS SOURCE
        ON TARGET.ASNLineItemId = SOURCE.ASNLineItemId

        WHEN MATCHED THEN
            UPDATE SET
                ASNId        = SOURCE.ASNId,
                [LineNo]     = SOURCE.[LineNo],
                ItemCode     = SOURCE.ItemCode,
                ItemDesc     = SOURCE.ItemDesc,
                UOM          = SOURCE.UOM,
                POQty        = SOURCE.POQty,
                OpenQty      = SOURCE.OpenQty,
                ShippedQty   = SOURCE.ShippedQty,
                NoOfPackage  = SOURCE.NoOfPackage,
                BatchNo      = SOURCE.BatchNo

        WHEN NOT MATCHED THEN
            INSERT (
                ASNLineItemId,
                ASNId,
                [LineNo],
                ItemCode,
                ItemDesc,
                UOM,
                POQty,
                OpenQty,
                ShippedQty,
                NoOfPackage,
                BatchNo
            )
            VALUES (
                SOURCE.ASNLineItemId,
                SOURCE.ASNId,
                SOURCE.[LineNo],
                SOURCE.ItemCode,
                SOURCE.ItemDesc,
                SOURCE.UOM,
                SOURCE.POQty,
                SOURCE.OpenQty,
                SOURCE.ShippedQty,
                SOURCE.NoOfPackage,
                SOURCE.BatchNo
            )

        OUTPUT
            INSERTED.ASNLineItemId,
            INSERTED.ASNId
        INTO @Result;

        -- Return response
		insert into POJsonfromERP
		values('ASNlineitem',@JsonData,getdate()) 
        SELECT
            'SUCCESS' AS Status,
            ASNLineItemId
          
        FROM @Result;

    END TRY
    BEGIN CATCH
        SELECT
            'ERROR' AS Status,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
    END CATCH
END;
GO



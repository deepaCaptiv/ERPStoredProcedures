USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[SaveGRNLineItemsJson]    Script Date: 05-05-2026 11:04:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SaveGRNLineItemsJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        --   Validate JSON
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            THROW 50001, 'Invalid or NULL JSON passed to SaveGRNLineItemsJson', 1;
        END
		 
        MERGE GRNLineItems AS TARGET
        USING (
            SELECT
                grn_id,
                line_num,
                po_line_num,
                po_shipment_num,
                item_code,
                item_desc,
                qty_ordered,
                qty_received,
                qty_accepted,
                qty_rejected,
                uom,
                grn_line_id,
                unit_price,
                line_amount,
                destination_type,
                subinventory,
                locator_id,
                inspection_status,

                 
                ISNULL(TRY_CAST(NULLIF(created_at, '') AS DATETIME), GETDATE()) AS created_at,
                TRY_CAST(NULLIF(updated_at, '') AS DATETIME) AS updated_at,
                TRY_CAST(NULLIF(deleted_at, '') AS DATETIME) AS deleted_at

            FROM OPENJSON(@JsonData, '$')
            WITH (
                grn_id  VARCHAR(36),
                line_num INT,
                po_line_num INT,
                po_shipment_num INT,
                item_code VARCHAR(50),
                item_desc NVARCHAR(MAX),
                qty_ordered DECIMAL(18,2),
                qty_received DECIMAL(18,2),
                qty_accepted DECIMAL(18,2),
                qty_rejected DECIMAL(18,2),
                uom VARCHAR(10),
                grn_line_id VARCHAR(36),
                unit_price DECIMAL(18,2),
                line_amount DECIMAL(18,2),
                destination_type VARCHAR(25),
                subinventory VARCHAR(30),
                locator_id INT,
                inspection_status VARCHAR(20),

                -- ✅ IMPORTANT: keep as NVARCHAR
                created_at NVARCHAR(50),
                updated_at NVARCHAR(50),
                deleted_at NVARCHAR(50)
            )
        ) AS SOURCE

        ON TARGET.grn_id = SOURCE.grn_id
           AND TARGET.line_num = SOURCE.line_num

        --  UPDATE
        WHEN MATCHED THEN
            UPDATE SET
                po_line_num       = SOURCE.po_line_num,
                po_shipment_num   = SOURCE.po_shipment_num,
                item_code         = SOURCE.item_code,
                item_desc         = SOURCE.item_desc,
                qty_ordered       = SOURCE.qty_ordered,
                qty_received      = SOURCE.qty_received,
                qty_accepted      = SOURCE.qty_accepted,
                qty_rejected      = SOURCE.qty_rejected,
                uom               = SOURCE.uom,
                grn_line_id       = SOURCE.grn_line_id,
                unit_price        = SOURCE.unit_price,
                line_amount       = SOURCE.line_amount,
                destination_type  = SOURCE.destination_type,
                subinventory      = SOURCE.subinventory,
                locator_id        = SOURCE.locator_id,
                inspection_status = SOURCE.inspection_status,
                updated_at        = GETDATE()

        --   INSERT
        WHEN NOT MATCHED THEN
            INSERT (
                grn_id,
                line_num,
                po_line_num,
                po_shipment_num,
                item_code,
                item_desc,
                qty_ordered,
                qty_received,
                qty_accepted,
                qty_rejected,
                uom,
                grn_line_id,
                unit_price,
                line_amount,
                destination_type,
                subinventory,
                locator_id,
                inspection_status,
                created_at,
                updated_at,
                deleted_at
            )
            VALUES (
                SOURCE.grn_id,
                SOURCE.line_num,
                SOURCE.po_line_num,
                SOURCE.po_shipment_num,
                SOURCE.item_code,
                SOURCE.item_desc,
                SOURCE.qty_ordered,
                SOURCE.qty_received,
                SOURCE.qty_accepted,
                SOURCE.qty_rejected,
                SOURCE.uom,
                SOURCE.grn_line_id,
                SOURCE.unit_price,
                SOURCE.line_amount,
                SOURCE.destination_type,
                SOURCE.subinventory,
                SOURCE.locator_id,
                SOURCE.inspection_status,
                SOURCE.created_at,
                ISNULL(SOURCE.updated_at, GETDATE()),
                SOURCE.deleted_at
            );

         
        INSERT INTO POJsonfromERP
        VALUES ('GRNlineitem', @JsonData, GETDATE());

         
        SELECT 
            'SUCCESS' AS Status,
            'Line items upserted successfully' AS Message;

    END TRY
    BEGIN CATCH

        
        SELECT 
            'ERROR' AS Status,
            ERROR_MESSAGE() AS Message,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;

    END CATCH
END;
GO



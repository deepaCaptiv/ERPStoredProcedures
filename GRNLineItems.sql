CREATE      PROCEDURE [dbo].SaveGRNLineItemsJson         
    @JsonData NVARCHAR(MAX)          
AS          
BEGIN          
    SET NOCOUNT ON;          
          
          
    --   Validate JSON      
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0      
        BEGIN      
            THROW 50001, 'Invalid or NULL JSON passed to SaveGRNLineItemsJson', 1;      
        END      
    
  insert into vertiv..POJsonfromERP          
  values('Before grn insert lineitem',@JsonData,getdate())         
              
        
   DECLARE @TempLineItems TABLE        
   (        
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
                created_at datetime,      
                updated_at datetime,    
                deleted_at datetime        
  )        
  INSERT INTO @TempLineItems        
  (        
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
                created_at,      
              updated_at,      
                deleted_at          
        FROM OPENJSON(@JsonData)          
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
                created_at datetime,    
                updated_at datetime,      
                deleted_at datetime                 )          
            
  --SELECT * FROM @TempLineItems    
  --Update Existing LIne Items        
   UPDATE TAR        
   SET          
              
          po_line_num       = SRC.po_line_num,      
                po_shipment_num   = SRC.po_shipment_num,      
                item_code         = SRC.item_code,      
                item_desc         = SRC.item_desc,      
                qty_ordered       = SRC.qty_ordered,      
                qty_received      = SRC.qty_received,      
                qty_accepted      = SRC.qty_accepted,      
                qty_rejected      = SRC.qty_rejected,      
                uom               = SRC.uom,      
                grn_line_id       = SRC.grn_line_id,      
                unit_price        = SRC.unit_price,      
                line_amount       = SRC.line_amount,      
                destination_type  = SRC.destination_type,      
                subinventory      = SRC.subinventory,      
                locator_id        = SRC.locator_id,      
                inspection_status = SRC.inspection_status,      
                updated_at        = GETDATE()      
 FROM @TempLineItems SRC        
 JOIN Vertiv..GRNLineItems TAR         
 ON  SRC.grn_line_id=TAR.grn_line_id            
        
 --Insert new Line Items        
        
        INSERT  INTO Vertiv..GRNLineItems        
  (          
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
  SELECT      
               SRC.grn_id,      
               SRC.line_num,      
               SRC.po_line_num,      
               SRC.po_shipment_num,      
               SRC.item_code,      
               SRC.item_desc,      
               SRC.qty_ordered,      
               SRC.qty_received,      
               SRC.qty_accepted,      
               SRC.qty_rejected,      
               SRC.uom,      
               SRC.grn_line_id,      
               SRC.unit_price,      
               SRC.line_amount,      
               SRC.destination_type,      
               SRC.subinventory,      
               SRC.locator_id,      
               SRC.inspection_status,      
      ISNULL(SRC.created_at, GETDATE()),    
               ISNULL(SRC.updated_at, GETDATE()),    
               SRC.deleted_at     
  FROM @TempLineItems SRC LEFT JOIN Vertiv..GRNLineItems PLI     ON SRC.grn_line_id = PLI.grn_line_id WHERE PLI.grn_line_id IS NULL;       
        
              
  insert into VERTIV..POJsonfromERP          
  values('GRNlineitem',@JsonData,getdate())          
END   
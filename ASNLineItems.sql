USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[SaveASNLineItemsJson]    Script Date: 20-05-2026 15:24:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  ALTER      procedure [dbo].[SaveASNLineItemsJson]       
    @jsondata nvarchar(max)        
as        
begin        
    set nocount on;        
        
        
    --   validate json    
        if @jsondata is null or isjson(@jsondata) = 0    
        begin    
            throw 50001, 'invalid or null json passed to savegrnlineitemsjson', 1;    
        end    
  
  insert into vertiv..pojsonfromerp        
  values('before ASN insert lineitem',@jsondata,getdate())       
            
      
   declare @templineitems table      
   (      
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
  insert into @templineitems      
  (      
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
         
        select   
        
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
                      
        from openjson(@jsondata)        
        with (        
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
          
   
  --update existing line items      
   update tar      
   set        
            
         
		        ASNId        = SRC.ASNId,  
                [LineNo]     = SRC.[LineNo],  
                ItemCode     = SRC.ItemCode,  
                ItemDesc     = SRC.ItemDesc,  
                UOM          = SRC.UOM,  
                POQty        = SRC.POQty,  
                OpenQty      = SRC.OpenQty,  
                ShippedQty   = SRC.ShippedQty,  
                NoOfPackage  = SRC.NoOfPackage,  
                BatchNo      = SRC.BatchNo  
		  
 from @templineitems src      
 join vertiv..ASNLineItems tar       
 on  src.ASNLineItemId=tar.ASNLineItemId          
      
 --insert new line items      
      
        insert  into vertiv..ASNLineItems      
  (        
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
  select    
                src.ASNLineItemId,  
                src.ASNId,  
                src.[LineNo],  
                src.ItemCode,  
                src.ItemDesc,  
                src.UOM,  
                src.POQty,  
                src.OpenQty,  
                src.ShippedQty,  
                src.NoOfPackage,  
                src.BatchNo        
                 
  from @templineitems src
left join vertiv..ASNLineItems pli
    on src.ASNLineItemId = pli.ASNLineItemId
where pli.ASNLineItemId is null;     
      
            
  insert into vertiv..pojsonfromerp        
  values('ASNlineitem',@jsondata,getdate())        
end 
GO



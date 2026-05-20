USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[saveasnlineitemsjson_new]    Script Date: 20-05-2026 15:23:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER      procedure [dbo].[saveasnlineitemsjson_new]       
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
  values('before asn insert lineitem',@jsondata,getdate())       
            
      
   declare @templineitems table      
   (      
                asnlineitemid varchar(36),  
                asnid varchar(36),  
                [lineno] int,  
                itemcode varchar(50),  
                itemdesc nvarchar(4000),  
                uom varchar(50),  
                poqty decimal(18,2),  
                openqty decimal(18,2),  
                shippedqty decimal(18,2),  
                noofpackage int,  
                batchno varchar(100)      
                   
  )      
  insert into @templineitems      
  (      
               asnlineitemid,  
                asnid,  
                [lineno],  
                itemcode,  
                itemdesc,  
                uom,  
                poqty,  
                openqty,  
                shippedqty,  
                noofpackage,  
                batchno       
  )      
         
        select   
        
		        asnlineitemid,  
                asnid,  
                [lineno],  
                itemcode,  
                itemdesc,  
                uom,  
                poqty,  
                openqty,  
                shippedqty,  
                noofpackage,  
                batchno        
                      
        from openjson(@jsondata)        
        with (        
                asnlineitemid varchar(36),  
                asnid varchar(36),  
                [lineno] int,  
                itemcode varchar(50),  
                itemdesc nvarchar(4000),  
                uom varchar(50),  
                poqty decimal(18,2),  
                openqty decimal(18,2),  
                shippedqty decimal(18,2),  
                noofpackage int,  
                batchno varchar(100)      
        )        
          
   
  --update existing line items      
   update tar      
   set        
            
         
		        asnid        = src.asnid,  
                [lineno]     = src.[lineno],  
                itemcode     = src.itemcode,  
                itemdesc     = src.itemdesc,  
                uom          = src.uom,  
                poqty        = src.poqty,  
                openqty      = src.openqty,  
                shippedqty   = src.shippedqty,  
                noofpackage  = src.noofpackage,  
                batchno      = src.batchno  
		  
 from @templineitems src      
 join vertiv..asnlineitems tar       
 on  src.asnlineitemid=tar.asnlineitemid          
      
 --insert new line items      
      
        insert  into vertiv..asnlineitems      
  (        
             asnlineitemid,  
                asnid,  
                [lineno],  
                itemcode,  
                itemdesc,  
                uom,  
                poqty,  
                openqty,  
                shippedqty,  
                noofpackage,  
                batchno        
        )       
  select    
                src.asnlineitemid,  
                src.asnid,  
                src.[lineno],  
                src.itemcode,  
                src.itemdesc,  
                src.uom,  
                src.poqty,  
                src.openqty,  
                src.shippedqty,  
                src.noofpackage,  
                src.batchno        
                 
  from @templineitems src
left join vertiv..asnlineitems pli
    on src.asnlineitemid = pli.asnlineitemid
where pli.asnlineitemid is null;     
      
            
  insert into vertiv..pojsonfromerp        
  values('asnlineitem',@jsondata,getdate())        
end 


GO



public class ClsImage {
public Attachment att {get ;set ;}
public clsimage ()
{
if(apexpages.currentpage().getparameters().get('id') != null)
att  = [Select id, Name , ParentId , body  from Attachment where id =:apexpages.currentpage().getparameters().get('id') ORDER BY CreatedDate DESC  limit 1];
Blobgetter();
}


Public transient String base64Value{get;set;}
Public String Filename{get;set;}
Public String mimeType {get;set;}
Public void  Blobgetter(){
if(ApexPages.currentPage().getParameters().get('id')!= null){
fileName = [Select id,name,body from Attachment where id=:ApexPages.currentPage().getParameters().get('id')].Name;
base64Value=Encodingutil.base64encode([Select id,name,body from Attachment where id=:ApexPages.currentPage().getParameters().get('id')].body);
Map<String,String> mimeTypeMap = new Map<String,String>{'pdf'=>'application/pdf','doc'=>'application/msword','docx'=>'application/vnd.openxmlformats-officedocument.wordprocessingml.document','pic'=>'image/x-pict','png'=>'image/png','gif'=>'image/gif','jpg'=>'image/jpeg','jpeg'=>'image/jpeg','xls'=>'application/vnd.ms-excel','xlsx'=>'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','csv'=>'text/csv','rar'=>'application/x-rar-compressed','zip'=>'application/zip','xhtml'=>'application/xhtml+xml','html'=>'text/html','ppt'=>'application/vnd.ms-powerpoint','mp4'=>'video/mp4'};
if(fileName.contains('.')){
String[] fileNameParts = fileName.split('\\.');
String ext = fileNameParts[fileNameParts.size()-1];

mimeType = mimeTypeMap.get(ext.tolowercase());
}
else{
mimeType = [Select id,name,contentType,body from Attachment where id=:ApexPages.currentPage().getParameters().get('id')].contentType;
}
}
}
}
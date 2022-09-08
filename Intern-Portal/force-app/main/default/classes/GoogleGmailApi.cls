public class GoogleGmailApi {
    
    @future (callout=true)
    public static void sendGmailWithAttachment(String subjectMail,String bodyGmail,String sendTo, String attachment){
		
		String errorMessage ='';
                
        Attachment attach = [Select Id, Body,name,ContentType from Attachment Where Id =: attachment LIMIT 1];
        
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendTo+'\n'+
            			'MIME-Version: 1.0\n'+
                        'Subject: '+subjectMail+'\n' +
                        'Content-Type: multipart/mixed; boundary="foo_bar_baz"\n\n'+
            			
            			 '--foo_bar_baz\n'+
                         'Content-Type: text/html; charset="UTF-8";\n'+
                         '\n\n'+bodyGmail+'\n\n'+
            
            			'--foo_bar_baz\n'+
            			'Content-Type: '+attach.ContentType+'; \n'+
                        'Content-Transfer-Encoding: base64\n'+
                        'Content-Disposition: attachment; filename='+attach.name+'\n\n'+
            			EncodingUtil.base64Encode(attach.Body)+'\n\n--foo_bar_baz--';			


        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/upload/gmail/v1/users/me/messages/send?uploadType=multipart');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'message/rfc822');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+before+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
    
    @future (callout=true)
    public static void sendGmail(String subjectMail,String bodyGmail,String sendTo){
		
		String errorMessage ='';
                
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendTo+'\n'+
                        'Subject: '+subjectMail+'\n' +
                        'Content-Type: text/html \n\n'+bodyGmail;
                        
        System.debug(before);            	
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        paramvalue = paramvalue.replace('+', '-');
        paramvalue = paramvalue.replace('/', '_');
        System.debug(paramvalue);

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'application/json');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
    
    @future (callout=true)
    public static void sendGmailBatch(String subjectMapParam,String dataMapFromParam){
        
        Map<String, String> dataMap = (Map<String, String>)JSON.deserialize(dataMapFromParam, Map<String, String>.class);
        Map<String, String> subjectMap = (Map<String, String>)JSON.deserialize(subjectMapParam, Map<String, String>.class);
        
        
        String endPointBatch = 'callout:Gmail/batch/gmail/v1';
        
        String strBatch = '';
        for(String str : dataMap.keySet()){
            strBatch += '--foobarbaz\nContent-Type:application/http\nContent-Transfer-Encoding: binary\n\n';
            strBatch += 'POST /gmail/v1/users/me/messages/send\n\n';
            
            string body = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+str+'\n'+
                        'Subject: '+subjectMap.get(str)+'\n' +
                        'Content-Type: text/html \n\n'+dataMap.get(str);
            Blob bodyBlob = Blob.valueOf(body);
            string bodyValue = EncodingUtil.base64Encode(bodyBlob);
            bodyValue = bodyValue.replace('+', '-');
            bodyValue = bodyValue.replace('/', '_');
            System.debug(bodyValue);
            strBatch += '{"userId":"me","raw":"'+bodyValue+'"}\n';
        }
        strBatch += '--foobarbaz--';
        System.debug(strBatch);
        HttpRequest httpReqBatch = new HttpRequest();
        httpReqBatch.setEndpoint(endPointBatch);
        httpReqBatch.setMethod('POST');
        httpReqBatch.setHeader('Content-Type', 'multipart/mixed; boundary=foobarbaz');
        httpReqBatch.setBody(strBatch);
        try{
            Http httpBatch = new Http();
            HttpResponse response = httpBatch.send(httpReqBatch);
            if(response.getStatusCode() == 200){
                System.debug(response.getBody());
                // String testStr = '[';
                // List<String> strList = responseBatch.getBody().split('HTTP/1.1 200 OK');
                // for(String str : strList){
                //     if(str.contains('{') && str.contains('}')){
                //         testStr += str.substring(str.indexOf('{'),str.lastindexOf('}')+1)+',';
                //     }   
                // }
                // testStr = testStr.removeEnd(',');
                // testStr += ']';
                // System.debug('testStr'+testStr);
                // List<gMessageWrapper> responseBatchWrap = (List<gMessageWrapper>)JSON.deserialize(testStr,List<gMessageWrapper>.class);
                // System.debug(responseBatchWrap);
            }else if(response.getStatusCode() == 401){
                String errorMessage1 = 'Please refresh access token';
                System.debug(errorMessage1);
            }else{
                String errorMessage1 = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode() +'Message'+response.getBody();
                    System.debug(errorMessage1);
            }
        }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
        }
    }
    
    @future (callout=true)
    public static void sendGmailwithCCSelect(String subjectMail,String bodyGmail,String sendTo){
		
		String errorMessage ='';
        String[] sendToCC = sendTo.split(',');
        System.debug('sendToCC>>'+sendToCC);
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendToCC[0]+'\n'+
                        'cc: '+sendToCC[1]+','+sendToCC[2]+'\n'+
                        'Subject: '+subjectMail+'\n' +
                        'Content-Type: text/html \n\n'+bodyGmail;
                        
        System.debug(before);            	
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        paramvalue = paramvalue.replace('+', '-');
        paramvalue = paramvalue.replace('/', '_');
        System.debug(paramvalue);

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'application/json');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }

    @future (callout=true)
    public static void sendGmailwithCCSelect_single(String subjectMail,String bodyGmail,String sendTo){
		
		String errorMessage ='';
        String[] sendToCC = sendTo.split(',');
        System.debug('sendToCC>>'+sendToCC);
        string before = 'From: MV Clouds <info@mvclouds.com>\n'+
                        'To: '+sendToCC[0]+'\n'+
                        'cc: '+sendToCC[1]+'\n'+
                        'Subject: '+subjectMail+'\n' +
                        'Content-Type: text/html \n\n'+bodyGmail;
                        
        System.debug(before);            	
        Blob beforeblob = Blob.valueOf(before);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        paramvalue = paramvalue.replace('+', '-');
        paramvalue = paramvalue.replace('/', '_');
        System.debug(paramvalue);

        Http httpMail = new Http();
        HttpRequest httpReqMail = new HttpRequest();
        HttpResponse httpResMail = new HttpResponse();
        httpReqMail.setEndpoint('callout:Gmail/gmail/v1/users/me/messages/send');
        httpReqMail.setMethod('POST');
        httpReqMail.setHeader('Content-Type', 'application/json');
        httpReqMail.setHeader('Content-Length', '-1');
        String refreshToknBody = '{"userId":"me","raw":"'+paramvalue+'"}';
        system.debug(refreshToknBody);
        httpReqMail.setBody(refreshToknBody);
    
        try{
            httpResMail = httpMail.send(httpReqMail); 
            if(httpResMail.getStatusCode() == 200){
                System.debug(httpResMail.getBody()); 
            }else{
                String errorMessageMail = 'Unexpected Error while communicating with Google Calendar API. '
                    +'Status '+httpResMail.getBody()+' and Status Code '+httpResMail.getStatuscode();
                System.debug('Error ' + errorMessageMail);
                System.debug(httpResMail);
            }
        }catch(System.Exception e){
            
            System.debug('#### Exception Executed '+e.getStackTraceString() + ' '+e.getMessage());
        } 
    }
}
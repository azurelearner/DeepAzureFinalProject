<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"
import="java.net.URI,
org.apache.http.Header,
org.apache.http.HttpEntity,
org.apache.http.HttpResponse,
org.apache.http.client.HttpClient,
org.apache.http.client.methods.HttpGet,
org.apache.http.client.methods.HttpPost,
org.apache.http.entity.StringEntity,
org.apache.http.impl.client.CloseableHttpClient,
org.apache.http.impl.client.HttpClientBuilder,
org.apache.http.util.EntityUtils,
org.apache.http.client.utils.URIBuilder,
org.json.JSONObject,
org.json.JSONArray,
com.jayway.jsonpath.JsonPath,
org.owasp.encoder.Encode"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
 	String subscriptionKey = "30de815d24c24e94b82ff4462501c483";
	String uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/ocr";
	String myUrl = request.getParameter("myUrl");
	String urlString = null;
	if(myUrl != null){
		urlString = "{\"url\":\"" + myUrl + "\"}"; 
	}
	
	CloseableHttpClient resultClient = HttpClientBuilder.create().build();
	
    String outputText = "";
    
    if(urlString != null){
    	try {
            // Create the URI to access the REST API call to read text in an image.	        
	        URIBuilder uriBuilder = new URIBuilder(uriBase);

            // Request parameters.
            uriBuilder.setParameter("language", "unk"); //AutoDetect
            uriBuilder.setParameter("detectOrientation ", "true");

            // Prepare the URI for the REST API call.
            URI uri = uriBuilder.build();
            HttpPost textRequest = new HttpPost(uri);

            // Request headers.
            textRequest.setHeader("Content-Type", "application/json");
 	        textRequest.setHeader("Ocp-Apim-Subscription-Key", subscriptionKey);
            
            // Request body.
            StringEntity reqEntity = new StringEntity(urlString);
            textRequest.setEntity(reqEntity);

	        HttpResponse resultResponse = resultClient.execute(textRequest);
	        HttpEntity responseEntity = resultResponse.getEntity();
	
	        if (responseEntity != null){
	            // Format and display the JSON response.
	            String jsonString = EntityUtils.toString(responseEntity);
	            JSONObject json = new JSONObject(jsonString);
	            
	            outputText = json.toString(2);
	            System.out.println(outputText);		       
	        }
        }
        catch (Exception e){
            // Display error message.
            System.out.println(e.getMessage());
        }
    }
%> 

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Read printed text in an image</title>
</head>
<body onload='document.getElementById("myUrl").focus();'>   
  <form id="myform" name="myform" method="post" action="ocrImage.jsp">
  <table width="100%" height=200 style="table-layout: fixed;" border=1 bgcolor=#FAFAD cellpadding="2">
    <col width="60%"/> <col width="40%"/>
    <tr>
	    <td colspan="2" align="center">
	      <b>Welcome to my Deep Azure final project</b><br />
	      This web application uses Computer Vision REST API to perform optical character recognition (OCR) to detect printed text in an image.<br />
	      Enter an image URL in the text field, and click the button on the right.<br />
	      The image will show in the left panel, and the JSON response will show in the text area on the right.
	    </td>
    </tr>
    <tr>
    	<td colspan="2" style="margin-left: 15px;">	    
	        Enter image URL: <input type="text" id="myUrl" name="myUrl" size="100">&nbsp;&nbsp;&nbsp;&nbsp;
	        <input id="submit" type="submit" name="submit" value="Analyze Image With Printed Text" />	     
	    </td>
    </tr>
    <tr>
    	<td valign="top">
    		<% if (myUrl != null) { %>
    			<iframe width="100%" height="100%" src="<%= myUrl %>" name="leftside"></iframe>
    		<% } else { %>
    			<iframe width="100%" height="100%" src="about:blank" name="leftside"></iframe>
    		<% } %>
    	</td>
    		
    	<td valign="top">
    		<textArea name="txtarea" id="myText" style="font-family:Arial;font-size:8pt;width:100%;height:100vw"> 
    		<%=Encode.forHtml(outputText)%>          
    		</textArea>
    	</td>
    </tr>
    </table>
  </form> 
</body>
</html>
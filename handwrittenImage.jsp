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
org.json.JSONObject,
org.json.JSONArray,
com.jayway.jsonpath.JsonPath,
org.owasp.encoder.Encode"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
 	String subscriptionKey = "30de815d24c24e94b82ff4462501c483";
	String uriBase = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/recognizeText?handwriting=true";
	String myUrl = request.getParameter("myUrl");
	String urlString = null;
	if(myUrl != null){
		urlString = "{\"url\":\"" + myUrl + "\"}"; 
	}
	
	CloseableHttpClient textClient = HttpClientBuilder.create().build();
	CloseableHttpClient resultClient = HttpClientBuilder.create().build();
	
    String outputText = "";
    
    if(urlString != null){
	    try {
	        // This operation requires two REST API calls. One to submit the image for processing,
	        // the other to retrieve the text found in the image.
	        //
	        // Begin the REST API call to submit the image for processing.
	        URI uri = new URI(uriBase);
	        HttpPost textRequest = new HttpPost(uri);
	
	        // Request headers. Another valid content type is "application/octet-stream".
	        textRequest.setHeader("Content-Type", "application/json");
	        textRequest.setHeader("Ocp-Apim-Subscription-Key", subscriptionKey);
	
	        // Request body.
	        StringEntity requestEntity = new StringEntity(urlString);
	        textRequest.setEntity(requestEntity);
	       
	        // Execute the first REST API call to detect the text.
	        HttpResponse textResponse = textClient.execute(textRequest);
	
	        // Check for success.
	        if (textResponse.getStatusLine().getStatusCode() != 202){
	            // Format and display the JSON error message.
	            HttpEntity entity = textResponse.getEntity();
	            String jsonString = EntityUtils.toString(entity);
	            JSONObject json = new JSONObject(jsonString);
	            outputText = "Error: " + json.toString(2);
	            
	            System.out.println(outputText);
	            
	        }else{
	
		        String operationLocation = null;
		
		        // The 'Operation-Location' in the response contains the URI to retrieve the recognized text.
		        Header[] responseHeaders = textResponse.getAllHeaders();
		        for(Header header : responseHeaders) {
		            if(header.getName().equals("Operation-Location"))
		            {
		                // This string is the URI where you can get the text recognition operation result.
		                operationLocation = header.getValue();
		                break;
		            }
		        }
		
		        // NOTE: The response may not be immediately available. Handwriting recognition is an
		        // async operation that can take a variable amount of time depending on the length
		        // of the text you want to recognize. You may need to wait or retry this operation.
		
		        outputText = "Handwritten text submitted. Waiting 10 seconds to retrieve the recognized text.\n\n";
		        System.out.println(outputText);
		        Thread.sleep(10000);
		
		        // Execute the second REST API call and get the response.
		        HttpGet resultRequest = new HttpGet(operationLocation);
		        resultRequest.setHeader("Ocp-Apim-Subscription-Key", subscriptionKey);
		
		        HttpResponse resultResponse = resultClient.execute(resultRequest);
		        HttpEntity responseEntity = resultResponse.getEntity();
		
		        if (responseEntity != null){
		            // Format and display the JSON response.
		            String jsonString = EntityUtils.toString(responseEntity);
		            JSONObject json = new JSONObject(jsonString);
		            
		            outputText = json.toString(2);
		            System.out.println(outputText);
		            
		        }
	        }
	    }
	    catch (Exception e){
	        System.out.println(e.getMessage());
	    }
    }
%> 

<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Read hand written text in an image</title>
</head>
<body onload='document.getElementById("myUrl").focus();'>   
  <form id="myform" name="myform" method="post" action="handwrittenImage.jsp">
  <table width="100%" height=200 style="table-layout: fixed;" border=1 bgcolor=#FAFAD cellpadding="2">
    <col width="60%"/> <col width="40%"/>
    <tr>
	    <td colspan="2" align="center">
	      <b>Welcome to my Deep Azure final project</b><br />
	      This web application uses Computer Vision REST API to read hand written text in an image.<br />
	      Enter an image URL in the text field, and click the button on the right.<br />
	      The image will show in the left panel, and the JSON response will show in the text area on the right.
	    </td>
    </tr>
    <tr>
    	<td colspan="2" style="margin-left: 15px;">	    
	        Enter image URL: <input type="text" id="myUrl" name="myUrl" size="100">&nbsp;&nbsp;&nbsp;&nbsp;
	        <input id="submit" type="submit" name="submit" value="Analyze Image With Hand Written Text" />	     
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
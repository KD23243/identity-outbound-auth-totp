<%--
  ~ Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~ WSO2 Inc. licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file except
  ~ in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~ http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  --%>

<%@page import="java.util.ArrayList" %>
<%@page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.AuthContextAPIClient" %>
<%@page import="org.wso2.carbon.identity.application.authentication.endpoint.util.Constants" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="org.wso2.carbon.identity.application.authentication.endpoint.util.TenantDataManager" %>
<%@ page import="org.wso2.carbon.identity.core.util.IdentityTenantUtil" %>
<%@ page import="org.wso2.carbon.identity.core.util.IdentityUtil" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="com.google.gson.Gson" %>

<fmt:bundle basename="org.wso2.carbon.identity.application.authentication.endpoint.i18n.Resources">

<%!
    private static final String SERVER_AUTH_URL = "/api/identity/auth/v1.1/";
    private static final String SKEY = "ske";
%>

    <%
        String ske = null;
        if (request.getParameter(SKEY) != null) {
            ske = request.getParameter(SKEY);
        } else {
            String authAPIURL = application.getInitParameter(Constants.AUTHENTICATION_REST_ENDPOINT_URL);
            if (StringUtils.isBlank(authAPIURL)) {
                authAPIURL = IdentityUtil.getServerURL(SERVER_AUTH_URL, true, true);
            }
            if (!authAPIURL.endsWith("/")) {
                authAPIURL += "/";
            }
            authAPIURL += "context/" + request.getParameter(Constants.SESSION_DATA_KEY);
            String contextProperties = AuthContextAPIClient.getContextProperties(authAPIURL);
            Gson gson = new Gson();
            Map<String, Object> parameters = gson.fromJson(contextProperties, Map.class);
            if (parameters != null) {
                ske = (String) parameters.get(SKEY);
            }
        }

        request.getSession().invalidate();
        String queryString = request.getQueryString();
        Map<String, String> idpAuthenticatorMapping = null;
        if (request.getAttribute(Constants.IDP_AUTHENTICATOR_MAP) != null) {
            idpAuthenticatorMapping = (Map<String, String>) request.getAttribute(Constants.IDP_AUTHENTICATOR_MAP);
        }

        String errorMessage = "Authentication Failed! Please Retry";
        String authenticationFailed = "false";

        if (Boolean.parseBoolean(request.getParameter(Constants.AUTH_FAILURE))) {
            authenticationFailed = "true";

            if (request.getParameter(Constants.AUTH_FAILURE_MSG) != null) {
                errorMessage = Encode.forHtmlAttribute(request.getParameter(Constants.AUTH_FAILURE_MSG));

                 if (errorMessage.equalsIgnoreCase("authentication.fail.message")) {
                    errorMessage = "Authentication Failed! Please Retry";
                }
            }
        }
    %>

    <html>
    <head>
        <meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>WSO2 Identity Server</title>

        <link rel="icon" href="images/favicon.png" type="image/x-icon"/>
        <link href="libs/bootstrap_3.4.1/css/bootstrap.min.css" rel="stylesheet">
        <link href="css/Roboto.css" rel="stylesheet">
        <link href="css/custom-common.css" rel="stylesheet">

        <script src="js/scripts.js"></script>
        <script src="assets/js/jquery-3.6.0.min.js"></script>
        <!--[if lt IE 9]>
        <script src="js/html5shiv.min.js"></script>
        <script src="js/respond.min.js"></script>
        <![endif]-->
        <script src="js/gadget.js"></script>
        <script src="js/qrCodeGenerator.js"></script>
    </head>

    <body>

    <jsp:directive.include file="header.jsp"/>

 <!-- page content -->
    <div class="container-fluid body-wrapper">

        <div class="row">
            <div class="col-md-12">

                <!-- content -->
                <div class="container col-xs-10 col-sm-6 col-md-6 col-lg-4 col-centered wr-content wr-login col-centered">
                    <div>
                        <h3 class="wr-title blue-bg padding-double white boarder-bottom-blue margin-none">
                            Enable TOTP  &nbsp;&nbsp;</h3>

                    </div>
                    <div class="boarder-all ">
                        <div class="clearfix"></div>
                        <div class="padding-double login-form">
                            <div id="errorDiv"></div>
                            <%
                                if ("true".equals(authenticationFailed)) {
                            %>
                                    <div class="alert alert-danger" id="failed-msg"><%=errorMessage%></div>
                            <% } %>
                            <div id="alertDiv"></div>
                            <form id="pin_form" name="pin_form" action="../../commonauth"  method="POST">
                                <div id="loginTable1" class="identity-box">
                                    <%
                                        String loginFailed = request.getParameter("authFailure");
                                        if (loginFailed != null && "true".equals(loginFailed)) {
                                            String authFailureMsg = request.getParameter("authFailureMsg");
                                            if (authFailureMsg != null && "login.fail.message".equals(authFailureMsg)) {
                                    %>
                                                <div class="alert alert-error">Authentication Failed! Please Retry</div>
                                    <% } }  %>
                                    <div class="row">
                                        <div class="span6">
                                             <!-- Token Pin -->
                                             <div class="control-group">
                                                <p>You have not enabled TOTP authentication. Please enable it.</p>
                                                <a onclick="validateCheckBox();">Show QR code to scan and enrol the user</a>
                                                <input type="hidden" id="ENABLE_TOTP" name="ENABLE_TOTP" value="false"/>
                                                <input type='hidden' name='ske' id='ske' value='<%=Encode.forHtmlAttribute(ske)%>'/>
                                                 <div class="container" style="width:90% !important; padding-left:0px; padding-right:0px; display:none;" id="qrContainer">
                                                    <div class="panel-group">
                                                        <div class="panel panel-default">
                                                            <div class="panel-heading" style="padding: 5px 5px 25px 5px;">
                                                                <h4 class="panel-title">
                                                                    <a data-toggle="collapse" onclick="initiateTOTP()" style="display:inline-block; float:left; text-decoration: none;">
                                                                    <div id="scanQR" style="overflow:inherit; float:left; padding-right:2px;"><b>+</b></div>
                                                                    </a>
                                                                </h4>
                                                            </div>
                                                            <div id="qrcanvdiv" class="panel-collapse collapse" style="display:none">
                                                                <div id="qrdiv">
                                                                    <form name="qrinp">
                                                                        <input type="numeric" name="ECC" value="1" size="1" style="Display:none" id="ecc">
                                                                        <canvas id="qrcanv" style="display:inline-block; float:right;">
                                                                    </form>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    </div>
                                             </div>
                                             <input type="hidden" name="sessionDataKey"
                                                value='<%=Encode.forHtmlAttribute(request.getParameter("sessionDataKey"))%>'/>
                                             <br><div>
                                                  <input type="button" name="continue" id="continue" value="Continue" class="btn btn-primary">
                                                  <input type="button" name="cancel" id="cancel" value="Cancel" class="btn btn-primary">
                                             </div>
                                        </div>
                                    </div>
                                </div>
                            </form>

                           <div class="clearfix"></div>
                        </div>
                    </div>
                    <!-- /content -->
                </div>
            </div>
            <!-- /content/body -->
        </div>
    </div>

    <!-- footer -->
    <footer class="footer">
        <div class="container-fluid">
            <p>WSO2 Identity Server | &copy;
                <script>document.write(new Date().getFullYear());</script>
                <a href="http://wso2.com/" target="_blank"><i class="icon fw fw-wso2"></i> Inc</a>. All Rights Reserved.
            </p>
        </div>
    </footer>
    <script src="libs/jquery_3.6.0/jquery-3.6.0.js.js"></script>
    <script src="libs/bootstrap_3.4.1/js/bootstrap.min.js"></script>
     <script type="text/javascript">
        $(document).ready(function() {
        	$('#continue').click(function() {
                document.getElementById("ENABLE_TOTP").value = 'true';
                $('#pin_form').submit();
        	});
        	$('#cancel').click(function() {
                document.getElementById("ENABLE_TOTP").value = 'false';
                $('#pin_form').submit();
        	});
        });
     function initiateTOTP(){
        var key =  document.getElementById("ske").value;
        if(key != null) {
		    loadQRCode(key);
 		    toggleFunction();
 		}
 	 }
        </script>
    </body>
    </html>
</fmt:bundle>

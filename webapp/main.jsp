<%@page errorPage="error.jsp"
%><%@page import="org.workcast.streams.HTMLWriter"
%><%@page import="org.workcast.kmail.KMailServlet"
%><%@page import="org.workcast.kmail.MailListener"
%>

<html>
<head>
<link href="kmail.css" rel="styleSheet" type="text/css"/>
</head>
<body>

<h3>Welcome to kMail</h3>

<ul>
<li><a href="list.jsp">List Email Received</a></li>
<li><a href="delete.jsp">Delete All Email</a></li>
</ul>

<h3>Configuration</h3>


<% if (KMailServlet.kmc!=null) { %>
<p>You can send email to this server with the following settings:</p>
<ul>
<li>host:  <% HTMLWriter.writeHtml(out, KMailServlet.kmc.hostName ); %></li>
<li>port:  <% HTMLWriter.writeHtml(out, KMailServlet.kmc.hostPort ); %></li>
</ul>
<p>Message files will be stored for <%= MailListener.storageDays %> days in the folder: <% HTMLWriter.writeHtml(out, KMailServlet.kmc.dataFolder ); %></p>
<% } else { %>
<p>Server configuration problem: </p>
<ul><%
    Throwable t = KMailServlet.fatalServerError;
    while(t!=null) {
        %><li><%
        HTMLWriter.writeHtml(out, t.toString() );
        t=t.getCause();
        %></li><%
    }
    %></ul>
<% } %>


</body>
</html>
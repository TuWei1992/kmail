<%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.util.Vector"
%><%@page import="java.util.List"
%><%@page import="java.util.Date"
%><%@page import="org.workcast.kmail.EmailModel"
%><%@page import="org.workcast.kmail.MailListener"
%><%@page import="org.workcast.streams.HTMLWriter"
%><%@page import="java.text.SimpleDateFormat"
%><%

    List<EmailModel> msgs = MailListener.listAllMessages();

    SimpleDateFormat dFormat = new SimpleDateFormat("MMM dd - HH:mm:ss");

%>
<html>
<head>
<link href="kmail.css" rel="styleSheet" type="text/css"/>
</head>
<body>
<p><a href="main.jsp">Home</a> </p>
<h3>Email Listing</h3>

<table>
<col width="120">
<col width="130">
<col width="540">
<%
int count = 0;
for (EmailModel em : msgs) {
    File msg = em.filePath;
    String name = msg.getName();
    long timestamp=0;
    if (name.startsWith("email") && name.endsWith(".msg")) {
        String tVal = name.substring(5, name.length()-4);
        timestamp = Long.parseLong(tVal);
    }
    if (timestamp==0) {
        timestamp = msg.lastModified();
    }
    count++;
    %>

    <tr><td>
    <a href="msgRaw.jsp?msg=<%HTMLWriter.writeHtml(out,name);%>">(raw)</a>
    <a href="msgTxt.jsp?msg=<%HTMLWriter.writeHtml(out,name);%>">(txt)</a>
    <a href="msgHtml.jsp?msg=<%HTMLWriter.writeHtml(out,name);%>">(html)</a> -
    </td>
    <td><%= dFormat.format(new Date(timestamp)) %> -</td>
    <td colspan="3"><%HTMLWriter.writeHtml(out,em.subject);%></td>
    </tr>

<% } %>
</table>

<p>Total of <%=count%> messages.<br/>
Message files are stored for <%= MailListener.storageDays %> days before discarding.</p>

</body>
</html>


<%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.List"
%><%@page import="org.workcast.kmail.MailListener"
%><%@page import="org.workcast.streams.HTMLWriter"
%><%

    String selectedName = request.getParameter("msg");
    List<File> msgs = MailListener.listAllEmails();
    File foundMsg = null;
    for (File msg : msgs) {
        String name = msg.getName();
        if (selectedName.equals(name)) {
            foundMsg = msg;
        }
    }

    if (foundMsg==null) {
        %>
        <html><body><h1>ERROR: no email message named: <%=selectedName%></h1></body></html>
        <%
        return;
    }
    FileInputStream fis = new FileInputStream(foundMsg);
    InputStreamReader isr = new InputStreamReader(fis, "UTF-8");
    HTMLWriter hw = new HTMLWriter(out);

%>
<html>
<head>
<link href="kmail.css" rel="styleSheet" type="text/css"/>
</head>
<body>
<p><a href="main.jsp">Home</a> | <a href="list.jsp">Email List</a> ---
<a href="msgRaw.jsp?msg=<%=URLEncoder.encode(selectedName)%>">(raw)</a>
<a href="msgTxt.jsp?msg=<%=URLEncoder.encode(selectedName)%>">(txt)</a>
<a href="msgHtml.jsp?msg=<%=URLEncoder.encode(selectedName)%>">(html)</a>
</p>
<h3>Email: <%HTMLWriter.writeHtml(out,selectedName);%></h3>
<hr/>
<div class="emailbox">
<tt>
<%
    int ch = isr.read();
    while (ch>0) {
        if (ch=='\n') {
            out.write("<br/>\n");
        }
        else {
            hw.write((char) ch);
        }
        ch = isr.read();
    }
%>
</tt>
</div>
<hr/>
</body>
</html>
<%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.StringReader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Date"
%><%@page import="java.util.List"
%><%@page import="java.util.Properties"
%><%@page import="javax.mail.Address"
%><%@page import="javax.mail.BodyPart"
%><%@page import="javax.mail.Multipart"
%><%@page import="javax.mail.Session"
%><%@page import="javax.mail.internet.MimeMessage"
%><%@page import="org.workcast.kmail.MailListener"
%><%@page import="org.workcast.streams.HTMLWriter"
%><%@page import="org.workcast.streams.MemFile"
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


    Properties props = new Properties();
    Session mSession = Session.getDefaultInstance(props);

    HTMLWriter hw = new HTMLWriter(out);
    FileInputStream fis = new FileInputStream(foundMsg);

    MimeMessage mm = new MimeMessage(mSession, fis);
    String stringBody = null;
    Multipart mult = null;

    Object content = mm.getContent();
    if (content instanceof String) {
        stringBody = (String)content;
    }
    else if (content instanceof Multipart) {
        mult = (Multipart)content;
    }
    Date mmSentDate = mm.getSentDate();

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
<h3>Email: <%=selectedName%></h3>
<hr/>
<%
    if (stringBody!=null) {
        HTMLWriter.writeHtmlWithLines(out,stringBody);
    }
    else if (mult!=null) {

        %>

        <table>
        <tr><td>From: </td><td> <%writeArray(out, mm.getFrom());%></td></tr>
        <tr><td>To: </td><td> <%writeArray(out, mm.getAllRecipients());%></td></tr>
        <tr><td>Date: </td><td> <%
            if (mmSentDate==null) {
                %><span style="color:red;">(missing from message)</span><%
            }
            else {
                HTMLWriter.writeHtml(out, mmSentDate.toString());
            }
            %></td></tr>
        <tr><td>Subj: </td><td> <%HTMLWriter.writeHtml(out, mm.getSubject());%></td></tr>
        </table>
        <%
        for (int i=0; i<mult.getCount(); i++) {
            BodyPart p = mult.getBodyPart(i);
            Object content2 = p.getContent();
            %><h3>Part <%=(i+1)%> of <%=mult.getCount()%> </h3>
            <div class="emailbox"><%
            if (content2 instanceof String) {
                %><tt><%
                HTMLWriter.writeHtmlWithLines(out,(String)content2);
                %></tt><%
            }
            else {
                out.write("\n<p>Content Type: "+content2.getClass().getName());
                out.write("\n<br/>File name: "+p.getFileName());
                out.write("\n<br/>Description: "+p.getDescription());
                out.write("\n<br/>Size: "+p.getSize()+"\n</p>");
            }
            %></div><%
        }
        %>
        <%
    }
%>
</body>
</html>

<%!

public void SafeStrem() {

}

%>
<%!

public void writeArray(Writer out, Address[] array) throws Exception  {
    for (int i=0; i<array.length; i++) {
        HTMLWriter.writeHtml(out, array[i].toString());
        out.write(" ");
    }
}

%>
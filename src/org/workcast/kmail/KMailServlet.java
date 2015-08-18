package org.workcast.kmail;

import java.io.File;
import java.net.InetAddress;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class KMailServlet extends javax.servlet.http.HttpServlet {

    private static final long serialVersionUID = 1L;
    public static File dataFolder;
    public static KMailConfig kmc;
    public static Exception fatalServerError;

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) {
        //nothing doing
    }

    @Override
    public void init(ServletConfig config) throws ServletException {
        try {
            System.out.println("KMailServlet: Server starting");
            ServletContext sc = config.getServletContext();
            File contextPath = new File(sc.getRealPath("/"));
            kmc = new KMailConfig(contextPath);

            dataFolder = new File(kmc.dataFolder);
            InetAddress bindAddress = InetAddress.getByName(kmc.hostName);
            SMTPServerHandler.startServer(Integer.parseInt(kmc.hostPort), bindAddress);
            System.out.println("KMailServlet: Server started on port "+kmc.hostPort);
            System.out.println("KMailServlet: Server saving data in: "+dataFolder);
        }
        catch (Exception e) {
            fatalServerError = e;
            System.out.println("CHAINMAIL Server crash on initialization: "+e);
        }
    }

}

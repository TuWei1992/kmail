package org.workcast.kmail;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

/**
 * reads the config file into variables
 */
public final class KMailConfig {

    public String hostName;
    public String hostPort;
    public String dataFolder;

    public KMailConfig(File appFolder)  throws Exception {
        File webInfFolder = new File(appFolder, "WEB-INF");
        File configFile = new File(webInfFolder, "config.txt");
        FileInputStream fis = new FileInputStream(configFile);

        Properties props = new Properties();
        props.load(fis);
        fis.close();

        hostName = props.getProperty("hostName");
        if (hostName==null) {
            hostName="127.0.0.1";
        }
        hostPort = props.getProperty("hostPort");
        if (hostPort==null) {
            hostPort="2525";
        }
        dataFolder = props.getProperty("dataFolder");
        if (hostPort==null) {
            hostPort="c:\\KMailData\\";
        }
    }
}

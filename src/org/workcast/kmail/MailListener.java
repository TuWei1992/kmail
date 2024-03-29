package org.workcast.kmail;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.subethamail.smtp.helper.SimpleMessageListener;
import org.workcast.streams.MemFile;

/**
 * Listens to incoming emails and redirects them to the {@code MailSaver} object.
 */
public class MailListener implements SimpleMessageListener {

    //used to generate unique ids for the messages as they come in
    private static long lastUnique = System.currentTimeMillis();

    //configured amount of time (days) that messages should stay in the storage location
    //automatically deleted after this number of days
    public static int storageDays = 5;

    private static final Pattern SUBJECT_PATTERN = Pattern.compile("^Subject: (.*)$");

    /**
     * Creates the listener.
     *
     * @param saver a {@code MailServer} object used to save emails and notify components.
     */
    public MailListener() {
        if (!KMailServlet.dataFolder.exists()) {
            KMailServlet.dataFolder.mkdirs();
        }
    }

    /**
     * Accepts all kind of email <i>(always return true)</i>.
     * <p>
     * Called once for every RCPT TO during a SMTP exchange.<br>
     * Each accepted recipient will result in a separate deliver() call later.
     * </p>
     *
     * @param from the user who send the email.
     * @param recipient the recipient of the email.
     * @return always return {@code true}
     */
    public boolean accept(String from, String recipient) {
        return true;
    }

    /**
     * Receives emails and forwards them to the {@link MailSaver} object.
     */
    @Override
    public void deliver(String from, String recipient, InputStream data) throws IOException {
        try {
            saveEmailAndNotify(from, recipient, data);
        }
        catch(Exception e) {
            throw new IOException("MailListener not able to deliver message from "+from, e);
        }
    }

    /**
     * Saves incoming email in file system and notifies observers.
     *
     * @param from the user who send the email.
     * @param to the recipient of the email.
     * @param data an InputStream object containing the email.
     * @see com.nilhcem.fakesmtp.gui.MainPanel#addObservers to see which observers will be notified
     */
    public static void saveEmailAndNotify(String from, String to, InputStream data) throws Exception {

        MemFile mailContent = new MemFile();
        mailContent.fillWithInputStream(data);
        String subject = getSubjectFromStr(mailContent);

        synchronized (MailListener.class) {
            saveEmailToFile(from, to, subject, mailContent);
        }
    }

    /**
     * Deletes all received emails from file system.
     */
    public static void deleteEmails() {
        File[] children = KMailServlet.dataFolder.listFiles();
        for (File child : children) {
            String name = child.getName();
            if (name.startsWith("email") && name.endsWith(".msg")) {
                child.delete();
            }
        }
    }

    /**
     * scans for and returns all the files that represent email messages.
     * @deprecated - use listAllMessages  instead
     */
    public static List<File> listAllEmails() throws Exception {
        List<File> res = new ArrayList<File> ();
        for (EmailModel em : listAllMessages()) {
			res.add(em.filePath);
		}
        return res;
    }


    /**
     * scans for and returns all the files that represent email messages.
     */
    public static List<EmailModel> listAllMessages() throws Exception {

        //scan for and eliminate any OLD messages hanging around
        long earliestMailLimit = System.currentTimeMillis()-(24L*60*60*1000*storageDays);
        for (File child : KMailServlet.dataFolder.listFiles()) {

            //while scanning the folder, we simply check the timeout.
            //any file older than the timeout is simply deleted, and
            //go on to the next file
            if (child.lastModified()<earliestMailLimit) {
                if (EmailModel.properFilename(child.getName())) {
                    child.delete();
                }
            }
        }

        List<EmailModel> theList =  EmailModel.getAllMessages(KMailServlet.dataFolder);
        sortEmail(theList);
        return theList;
    }


    /**
     * Saves the content of the email passed in parameters in a file.
     *
     * @param mailContent the content of the email to be saved.
     * @return the path of the created file.
     */
    private static void saveEmailToFile(String from, String to, String subject, MemFile mailContent) throws Exception {
        long thisUnique = System.currentTimeMillis();

        if (thisUnique<=lastUnique) {
            thisUnique = ++lastUnique;
        }

        File newFile = new File(KMailServlet.dataFolder, "email"+thisUnique+".msg");
        mailContent.outToOutputStream(new FileOutputStream(newFile));
    }

    /**
     * Gets the subject from the email data passed in parameters.
     *
     * @param data a string representing the email content.
     * @return the subject of the email, or an empty subject if not found.
     */
    private static String getSubjectFromStr(MemFile data) throws Exception {
        BufferedReader reader = new BufferedReader(data.getReader());

        String line;
        while ((line = reader.readLine()) != null) {
             Matcher matcher = SUBJECT_PATTERN.matcher(line);
             if (matcher.matches()) {
                 return matcher.group(1);
             }
        }
        return "[No Subject Found]";
    }

	/**
	* Sorts the list of email messages in reverse chronological order.
	* The newest message will be first.
	*/
    public static void sortEmail(List<EmailModel> coll) {

		Comparator<EmailModel> comparator = new Comparator<EmailModel>() {
		    public int compare(EmailModel c1, EmailModel c2) {
		        if (c1.received < c2.received) {
					return 1;
				} else if (c1.received > c2.received) {
					return -1;
				}
				else {
					return 0;
				}
		    }
		};

        Collections.sort(coll, comparator);
	}

}

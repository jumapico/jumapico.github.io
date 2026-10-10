import java.net.MalformedURLException;
import java.net.URL;
import java.io.*;

import javax.net.ssl.HttpsURLConnection;

public class HttpsClient {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: https-url");
            System.exit(1);
        }
        String https_url = args[0];
        if (!https_url.startsWith("https://")) {
            System.out.println("Error: only https scheme is supported");
            System.exit(1);
        }
        try {
          URL url = new URL(https_url);
          HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
          print_content(con);
        } catch (MalformedURLException e) {
          e.printStackTrace();
        } catch (IOException e) {
          e.printStackTrace();
        }
    }

    private static void print_content(HttpsURLConnection con) {
        try {
            BufferedReader br = new BufferedReader(new InputStreamReader(
                    con.getInputStream()));
            String input;
            while ((input = br.readLine()) != null){
                System.out.println(input);
            }
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}

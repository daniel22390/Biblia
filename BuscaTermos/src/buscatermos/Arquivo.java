
package buscatermos;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *Classe de persistencia de elementos
 * @author Daniel Gomes
 */
public class Arquivo {
    
    public Arquivo(){
        
    }
    
    public void salvaPagina(String termo){
        URL url;
        InputStream is = null;
        BufferedReader br;
        String line;

        try {
            
            url = new URL("https://www.antonimos.com.br/" + termo + "/");
            is = url.openStream();  // throws an IOException
            br = new BufferedReader(new InputStreamReader(is, StandardCharsets.ISO_8859_1));

            File f = new File( "paginasAntonimos/" + termo + ".txt" );
            OutputStream os = (OutputStream) new FileOutputStream( f );
            OutputStreamWriter osw = new OutputStreamWriter( os, "ISO-8859-1" );
            PrintWriter pw = new PrintWriter( osw );
            
            while ((line = br.readLine()) != null) {
                pw.println(line);
            }
            
            pw.close(); 
            osw.close();
            os.close();
        } catch (MalformedURLException mue) {
             System.err.println(termo);
        } catch (IOException ioe) {
             System.err.println(termo);
        } finally {
            try {
                if (is != null) is.close();
            } catch (IOException ioe) {
                System.err.println(termo);
            }
        }
    }
    
    public ArrayList<String> lePagina(String termo) throws FileNotFoundException, IOException{
        ArrayList<String> termos = new ArrayList();
        
        
        InputStream is = new FileInputStream("paginasAntonimos/" + termo + ".txt");
        InputStreamReader isr = new InputStreamReader(is, "UTF8");
        BufferedReader br = new BufferedReader(isr);
        
        String s = br.readLine(); // primeira linha
        String pagina = "";
        while (s != null) {
          pagina += s;
          s = br.readLine();
        }
        Pattern p = Pattern.compile("<div class=\"s-wrapper\">(.+?)</div>");
        Matcher m = p.matcher(pagina);

        while (m.find()) {
            String aux = m.group(1);
            Pattern p2 = Pattern.compile("/\">(.+?)</a>");
            Matcher m2 = p2.matcher(aux);

            while(m2.find()){
              termos.add(m2.group(1));
            }
        } 
        
//        p = Pattern.compile(", <span>([A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+)</span>,");
//        m = p.matcher(pagina);
//        
//        while (m.find()) {
//            if(!termos.contains(m.group(1))){
//                termos.add(m.group(1));
//            }
//        } 
////      
//        
//        p = Pattern.compile("<span>([A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+)</span>.");
//        m = p.matcher(pagina);
//        
//        while (m.find()) {
//            if(!termos.contains(m.group(1))){
//                termos.add(m.group(1));
//            }
//        } 
////        
//        p = Pattern.compile("<span>([A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+)</span>,");
//        m = p.matcher(pagina);
//        
//        while (m.find()) {
//            if(!termos.contains(m.group(1))){
//                termos.add(m.group(1));
//            }
//        } 
//        
        br.close();
        return termos;
    }
    
}

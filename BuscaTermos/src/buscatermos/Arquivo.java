
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
import java.util.Scanner;

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
            
            url = new URL("https://www.sinonimos.com.br/" + termo + "/");
            is = url.openStream();  // throws an IOException
            br = new BufferedReader(new InputStreamReader(is, StandardCharsets.ISO_8859_1));

            File f = new File( "paginas/" + termo + ".txt" );
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
    
    public void lePaginas() throws FileNotFoundException, IOException{
        InputStream is = new FileInputStream("paginas/teste.txt");
        InputStreamReader isr = new InputStreamReader(is, "ISO-8859-1");
        BufferedReader br = new BufferedReader(isr);

        String s = br.readLine(); // primeira linha

        while (s != null) {
          System.out.println(s);
          s = br.readLine();
        }

        br.close();
    }
    
}

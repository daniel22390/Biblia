
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

/**
 *Classe de persistencia de elementos
 * @author Daniel Gomes
 */
public class Arquivo {
    
    public Arquivo(){
        
    }
    
    public void salvaPaginas(){
        URL url;
        InputStream is = null;
        BufferedReader br;
        String line;

        try {
            File f = new File( "paginas/teste.txt" );
            OutputStream os = (OutputStream) new FileOutputStream( f );
            OutputStreamWriter osw = new OutputStreamWriter( os, "ISO-8859-1" );
            PrintWriter pw = new PrintWriter( osw );
            
            url = new URL("https://www.sinonimos.com.br/briga/");
            is = url.openStream();  // throws an IOException
            br = new BufferedReader(new InputStreamReader(is, StandardCharsets.ISO_8859_1));

            while ((line = br.readLine()) != null) {
                pw.println(line);
                System.out.println(line);
            }
            
            pw.close(); 
            osw.close();
            os.close();
        } catch (MalformedURLException mue) {
             mue.printStackTrace();
        } catch (IOException ioe) {
             ioe.printStackTrace();
        } finally {
            try {
                if (is != null) is.close();
            } catch (IOException ioe) {
                
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

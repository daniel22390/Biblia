
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
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *Classe de persistencia de elementos
 * @author Daniel Gomes
 */
public class Arquivo {
    
    Map<String, ArrayList<String>> flexoes = new LinkedHashMap<>();
    String flexoesText = "";
    
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
    
    public void carregaFlexoes() throws FileNotFoundException, UnsupportedEncodingException, IOException{
        InputStream is = new FileInputStream("flexoes.txt");
        InputStreamReader isr = new InputStreamReader(is, "UTF8");
        BufferedReader br = new BufferedReader(isr);
        
        String s = br.readLine(); // primeira linha
        int i = 0;
        while (s != null) {
            flexoesText += s;
            Pattern p = Pattern.compile("(.+?):");
            Matcher m = p.matcher(s);
            
            String chave = "";
            while (m.find()) {
                chave = m.group(1);
            }
            
            Pattern p2 = Pattern.compile(" (.+?),");
            Matcher m2 = p2.matcher(s);
            
            ArrayList<String> values = new ArrayList<>();
            while (m2.find()) {
                if(!values.contains(m2.group(1)))
                   values.add(m2.group(1));
            }
            flexoes.put(chave, values);
            
            s = br.readLine();
        }
    }
    
    public void pesquisaConexao(Connection con) throws SQLException{
        for (Map.Entry<String, ArrayList<String>> entry : flexoes.entrySet()) {
            String key = entry.getKey();
            ArrayList<String> value = entry.getValue();
            
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT idTermo FROM Termo where termo = '" + key + "'");
            if ( rs.next() ) {
                int idTermo = Integer.parseInt(rs.getString("idTermo"));
                Statement stmt2 = con.createStatement();
                ResultSet rs2 = stmt2.executeQuery("SELECT Termo_idTermo FROM TERMO_HAS_FLEXAO where Termo_idTermo = '" + idTermo + "'");
                if(!rs2.next()){
                    System.out.println(key);
                }
            } 
        }
    }
    
     public void incluiFlexao(Connection con){
         boolean valida = false;
         for (Map.Entry<String, ArrayList<String>> entry : flexoes.entrySet()) {
            String key = entry.getKey();
            ArrayList<String> value = entry.getValue();

            int idTermo = 0;
            
            if(key.equals("trilhar")){
                valida = true;
            }
            
            if(valida){
                System.out.println(key);
                //inclui a chave no banco
                try{
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT idTermo FROM Termo where termo = '" + key + "'");
                    if ( rs.next() ) {
                        idTermo = Integer.parseInt(rs.getString("idTermo"));
                    } 

                    else{
                        Statement stmt4 = con.createStatement();
                        ResultSet rs4 = stmt4.executeQuery("SELECT idTermo FROM termo where idTermo = (select max(idTermo) from termo)");
                        if(rs4.next()){
                            idTermo = Integer.parseInt(rs4.getString("idTermo")) + 1;
                            try {
                                PreparedStatement pst = con.prepareStatement("INSERT INTO TERMO(idTermo, termo, peso) " +
                                       "VALUES ('"+ idTermo +"', '" + key + "', '0')");
                                    pst.executeUpdate();
                            } catch(Exception e){
                                System.err.println("Erro: " + e);
                            }
                        }
                    }

                    PreparedStatement pst2 = con.prepareStatement("INSERT INTO TERMO_HAS_FLEXAO(Termo_idTermo, Termo_idFlexao, peso) " +
                        "VALUES ('"+ idTermo +"', '" + idTermo + "', 0)");
                     pst2.executeUpdate();
                } catch(Exception e){
                    System.err.println("Erro: " + e);
                }

                //inclui as conjugaçoes no banco
                for (String conjugacao : value) {
                    try{
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT idTermo FROM Termo where termo = '" + conjugacao + "'");
                        int idConjug = 0;
                        if ( rs.next() ) {
                            idConjug = Integer.parseInt(rs.getString("idTermo"));
                        } 

                        else{
                            Statement stmt4 = con.createStatement();
                            ResultSet rs4 = stmt4.executeQuery("SELECT idTermo FROM termo where idTermo = (select max(idTermo) from termo)");
                            if(rs4.next()){
                                idConjug = Integer.parseInt(rs4.getString("idTermo")) + 1;
                                try {
                                    PreparedStatement pst = con.prepareStatement("INSERT INTO TERMO(idTermo, termo, peso) " +
                                           "VALUES ('"+ idConjug +"', '" + conjugacao + "', '0')");
                                        pst.executeUpdate();
                                } catch(Exception e){
                                    System.err.println("Erro: " + e);
                                }
                            }
                        }

                        PreparedStatement pst2 = con.prepareStatement("INSERT INTO TERMO_HAS_FLEXAO(Termo_idTermo, Termo_idFlexao, peso) " +
                                "VALUES ('"+ idConjug +"', '" + idTermo + "', 0)");
                             pst2.executeUpdate();
                    } catch(Exception e){
                        System.err.println("Erro: " + e);
                    }
                }
             }
         }
    }
     
    public void geraTermossemRad(Connection con) throws SQLException, FileNotFoundException, UnsupportedEncodingException, IOException{
        File f = new File( "radicais.txt" );
        OutputStream os = (OutputStream) new FileOutputStream( f );
        OutputStreamWriter osw = new OutputStreamWriter( os, "ISO-8859-1" );
        PrintWriter pw = new PrintWriter( osw );
        
        
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT idTermo, termo FROM Termo where Radical_idRadical is null");
        while ( rs.next() ) {
           String termo = rs.getString("termo");
           pw.println(termo);
        }
            
        pw.close(); 
        osw.close();
        os.close();
    }
    
}

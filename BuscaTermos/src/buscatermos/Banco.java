package buscatermos;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Acesso ao banco da Biblia
 * @author Daniel Gomes
 */
public class Banco {
    final private String driver = "com.mysql.jdbc.Driver";
    final private String url = "jdbc:mysql://locahost/biblia";
    final private String usuario = "root";
    final private String senha = "";
    private Connection conexao;
    public Statement statement;
    public ResultSet resultset;
    
    public Banco(){
        
    }
    
    public void recebeTermos(Connection conn){
        Arquivo arq = new Arquivo();
        
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs;
 
            rs = stmt.executeQuery("SELECT idTermo, termo FROM Termo where idTermo >= 23598 && idTermo <= 28677");
            while ( rs.next() ) {
                String termo = rs.getString("termo");
                String idTermo = rs.getString("idTermo");
                System.out.println(idTermo + " " + termo);
                arq.salvaPagina(termo);
            }
            conn.close();
        } catch (Exception e) {
            System.err.println("Got an exception! ");
            System.err.println(e.getMessage());
        }
    }
    
    public Connection iniciaConexao() throws SQLException{
        Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblia", "root", "");
        System.out.println("Conectado!");
        return conexao;
    }
    
    public void semCaracteresEspeciais(Connection conn){
        Arquivo arq = new Arquivo();
        
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs;
 
            rs = stmt.executeQuery("SELECT idTermo, termo FROM Termo where idTermo >= 12080 && idTermo <= 28677");
            while ( rs.next() ) {
                String termo = rs.getString("termo");
                String idTermo = rs.getString("idTermo");
                File f = new File( "paginasAntonimos/" + termo + ".txt" );
                if(!f.exists()) { 
                   String remove = removeAcentos(termo);
                   arq.salvaPagina(remove);
                }    
            }
            conn.close();
        } catch (Exception e) {
            System.err.println("Got an exception! ");
            System.err.println(e.getMessage());
        }
    }
    
      public String removeAcentos(String str) {

        str = Normalizer.normalize(str, Normalizer.Form.NFD);
        str = str.replaceAll("[^\\p{ASCII}]", "");
        return str;

      }
      
      public void leTermos(Connection conn){
        Arquivo arq = new Arquivo();
        int id = 28678;
        
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs;
 
            rs = stmt.executeQuery("SELECT idTermo, termo FROM Termo where idTermo >= 1657 && idTermo <= 28677");
            while ( rs.next() ) {
                String termo = rs.getString("termo");
                String idTermo = rs.getString("idTermo");
                System.out.println(idTermo + ": " + termo);
                File f = new File( "paginasAntonimos/" + termo + ".txt" );
                if(f.exists()) { 
                   ArrayList<String> sinonimos = arq.lePagina(termo);
                   for (String sinonimo : sinonimos) {
                    Statement stmt2 = conn.createStatement();
                    ResultSet rs2 = stmt2.executeQuery("SELECT idTermo FROM Termo where termo = '" + sinonimo + "'");
                    if(rs2.next()){
                        int idReturn = Integer.parseInt(rs2.getString("idTermo"));
                        PreparedStatement pst = conn.prepareStatement("INSERT INTO TERMO_HAS_ANTONIMO(Termo_idTermo, Termo_idAntonimo) " +
                           "VALUES ('"+ idTermo +"', '" + idReturn + "')");
                        pst.executeUpdate();
                    }
                    else{
                        Statement stmt4 = conn.createStatement();
                        ResultSet rs4 = stmt4.executeQuery("SELECT idTermo FROM termo where idTermo = (select max(idTermo) from termo)");
                        if(rs4.next()){
                            int idNovo = Integer.parseInt(rs4.getString("idTermo")) + 1;
                            try {
                                PreparedStatement pst = conn.prepareStatement("INSERT INTO TERMO(idTermo, termo, peso) " +
                                       "VALUES ('"+ idNovo +"', '" + sinonimo + "', '0')");
                                    pst.executeUpdate();
                                
                                PreparedStatement pst2 = conn.prepareStatement("INSERT INTO TERMO_HAS_ANTONIMO(Termo_idTermo, Termo_idAntonimo) " +
                                   "VALUES ('"+ idTermo +"', '" + idNovo + "')");
                                pst2.executeUpdate();
                            } catch(Exception e){
                                System.out.println(e);
                            }
                        }
                        
                    }
                   }
                } else{
                    
                }
            }
            conn.close();
        }
        catch (Exception e) {
            System.err.println("Got an exception! ");
            System.err.println(e.getMessage());
        }
      }
      
    
}

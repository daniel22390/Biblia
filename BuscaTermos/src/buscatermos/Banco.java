package buscatermos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JOptionPane;

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
        try {
            Statement stmt = conn.createStatement();
            ResultSet rs;
 
            rs = stmt.executeQuery("SELECT termo FROM Termo");
            while ( rs.next() ) {
                String termo = rs.getString("termo");
                System.out.println(termo);
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
}

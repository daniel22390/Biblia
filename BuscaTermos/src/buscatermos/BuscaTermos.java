package buscatermos;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *Busca de termos pelo site sinonimos.com.br
 * @author Daniel Gomes
 */
public class BuscaTermos {

    public static void main(String[] args) throws IOException, SQLException {
        Banco banco = new Banco();
        Connection con = banco.iniciaConexao();
        
//        banco.semCaracteresEspeciais(con);
       
//        banco.leTermos(con);
        
        Arquivo arq = new Arquivo();
        arq.geraTermossemRad(con);
    }
    
   
    
}

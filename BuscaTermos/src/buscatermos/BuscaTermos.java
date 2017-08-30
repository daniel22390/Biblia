package buscatermos;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Hashtable;

/**
 *Busca de termos pelo site sinonimos.com.br
 * @author Daniel Gomes
 */
public class BuscaTermos {

    public static void main(String[] args) throws IOException, SQLException {
        Banco banco = new Banco();
        Connection con = banco.iniciaConexao();
        banco.recebeTermos(con);
    }
    
}

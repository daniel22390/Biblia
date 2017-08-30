package buscatermos;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

/**
 *Busca de termos pelo site sinonimos.com.br
 * @author Daniel Gomes
 */
public class BuscaTermos {

    public static void main(String[] args) throws IOException, SQLException {
        Arquivo arq = new Arquivo();
//        arq.lePaginas();
        Banco banco = new Banco();
        Connection con = banco.iniciaConexao();
        banco.recebeTermos(con);
    }
    
}
